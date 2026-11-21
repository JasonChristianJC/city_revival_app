import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Lock, Mail, AlertCircle, ArrowRight, ShieldCheck } from 'lucide-react';

export const LoginScreen: React.FC = () => {
  const { login, error, loading, setDemoUser } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) return;
    setIsSubmitting(true);
    await login(email, password);
    setIsSubmitting(false);
  };

  return (
    <div className="min-h-screen bg-[#FAF7F0] flex flex-col justify-center items-center px-4 py-12 relative overflow-hidden">
      {/* Subtle decorative background watermarks */}
      <div className="absolute top-0 right-0 -mr-20 -mt-20 w-96 h-96 rounded-full bg-[#F1EBDD] opacity-60 pointer-events-none" />
      <div className="absolute bottom-0 left-0 -ml-20 -mb-20 w-80 h-80 rounded-full bg-[#F1EBDD] opacity-60 pointer-events-none" />

      <div className="max-w-md w-full relative z-10">
        {/* Church Seal & Header */}
        <div className="text-center mb-8">
          <img
            src="/church_logo.png"
            alt="City Revival AG Church"
            className="w-20 h-20 rounded-full mx-auto object-contain bg-white border-2 border-[#E5DEC9] shadow-md mb-4"
          />
          <h1 className="text-2xl font-serif font-bold text-[#8F2638] tracking-tight">
            City Revival AG Church
          </h1>
          <p className="text-xs uppercase font-semibold text-[#77736F] tracking-widest mt-1">
            Mobile App Administration
          </p>
          <div className="mt-2 text-xs italic text-[#77736F]">
            "A House of Prayer for All Nations" • Trichy
          </div>
        </div>

        {/* Login Card */}
        <div className="bg-white rounded-2xl shadow-sm border border-[#E5DEC9] p-8">
          <h2 className="text-lg font-bold text-[#292929] mb-1">
            Authorized Sign In
          </h2>
          <p className="text-xs text-[#77736F] mb-6">
            Enter your church administrator credentials to access the console.
          </p>

          {error && (
            <div className="mb-5 p-3 rounded-xl bg-red-50 border border-red-200 flex items-start space-x-2 text-xs text-red-700">
              <AlertCircle size={16} className="shrink-0 mt-0.5 text-red-600" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1.5 uppercase tracking-wide">
                Admin Email Address
              </label>
              <div className="relative">
                <Mail
                  size={16}
                  className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#77736F]"
                />
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="pastor@cityrevivalagchurch.org"
                  className="w-full pl-10 pr-4 py-2.5 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-sm text-[#292929] focus:outline-none focus:ring-2 focus:ring-[#8F2638]/30 focus:border-[#8F2638]"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1.5 uppercase tracking-wide">
                Password
              </label>
              <div className="relative">
                <Lock
                  size={16}
                  className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#77736F]"
                />
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••••••"
                  className="w-full pl-10 pr-4 py-2.5 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-sm text-[#292929] focus:outline-none focus:ring-2 focus:ring-[#8F2638]/30 focus:border-[#8F2638]"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={isSubmitting || loading}
              className="w-full mt-2 flex items-center justify-center space-x-2 bg-[#8F2638] hover:bg-[#702033] text-white py-2.5 rounded-xl text-sm font-semibold transition-colors shadow-sm disabled:opacity-50"
            >
              <span>{isSubmitting ? 'Authenticating...' : 'Sign In to Control Panel'}</span>
              <ArrowRight size={16} />
            </button>
          </form>

          {/* Quick Demo Sign-in for Preview & Testing */}
          <div className="mt-8 pt-6 border-t border-[#E5DEC9]">
            <p className="text-[11px] font-semibold text-[#77736F] uppercase tracking-wider text-center mb-3">
              Fast Preview for Testing
            </p>
            <button
              type="button"
              onClick={() => setDemoUser()}
              className="w-full flex items-center justify-center space-x-2 py-2 px-3 rounded-lg border border-[#8F2638]/20 bg-[#FAF7F0] hover:bg-[#8F2638] hover:text-white group transition-all text-xs font-semibold text-[#8F2638]"
            >
              <ShieldCheck size={16} className="text-[#8F2638] group-hover:text-white" />
              <span>Continue as Administrator</span>
            </button>
          </div>
        </div>

        <p className="text-center text-[11px] text-[#77736F] mt-6">
          City Revival AG Church • Trichy, Tamil Nadu • Mobile Backend v2.0
        </p>
      </div>
    </div>
  );
};
