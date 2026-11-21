import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import type { AdminRole, AdminUser } from '../types';

interface AuthContextType {
  user: AdminUser | null;
  role: AdminRole | null;
  loading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => Promise<void>;
  isAdmin: boolean;
  isSuperAdmin: boolean;
  canManageContent: boolean;
  canManagePrayer: boolean;
  setDemoUser: (role?: AdminRole) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AdminUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Check initial active session
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session?.user) {
        mapSupabaseUserToAdmin(session.user);
      } else {
        setUser(null);
        setLoading(false);
      }
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        mapSupabaseUserToAdmin(session.user);
      } else {
        setUser(null);
        setLoading(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const mapSupabaseUserToAdmin = (sbUser: any) => {
    // Single unified 'admin' role stored in trusted app_metadata
    const role: string | undefined =
      sbUser.app_metadata?.role || sbUser.user_metadata?.role;

    if (role !== 'admin') {
      setError('Access Denied: Your account does not have administrative privileges (role "admin") for City Revival AG Church.');
      setUser(null);
      setLoading(false);
      return;
    }

    setError(null);
    setUser({
      id: sbUser.id,
      email: sbUser.email || '',
      role: 'admin',
    });
    setLoading(false);
  };

  const login = async (email: string, password: string): Promise<boolean> => {
    setLoading(true);
    setError(null);
    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (signInError) {
        setError(signInError.message);
        setLoading(false);
        return false;
      }

      if (data.user) {
        const role = data.user.app_metadata?.role || data.user.user_metadata?.role;
        if (role !== 'admin') {
          await supabase.auth.signOut();
          setError('Access Denied: Your account is not configured with the "admin" role in Supabase.');
          setLoading(false);
          return false;
        }

        setUser({
          id: data.user.id,
          email: data.user.email || '',
          role: 'admin',
        });
        setLoading(false);
        return true;
      }

      setLoading(false);
      return false;
    } catch (err: any) {
      setError(err.message || 'Login failed');
      setLoading(false);
      return false;
    }
  };

  const logout = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setError(null);
  };

  // Demo user switcher for review/development environments
  const setDemoUser = (_role?: AdminRole) => {
    setUser({
      id: 'demo-admin-id',
      email: 'jerrydanieltrichy@gmail.com',
      role: 'admin',
    });
    setError(null);
    setLoading(false);
  };

  const role = user?.role || null;
  const isAdmin = role === 'admin';
  const isSuperAdmin = isAdmin;
  const canManageContent = isAdmin;
  const canManagePrayer = isAdmin;

  return (
    <AuthContext.Provider
      value={{
        user,
        role,
        loading,
        error,
        login,
        logout,
        isAdmin,
        isSuperAdmin,
        canManageContent,
        canManagePrayer,
        setDemoUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
