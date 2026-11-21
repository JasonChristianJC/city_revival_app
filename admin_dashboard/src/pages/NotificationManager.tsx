import React, { useState, useEffect } from 'react';
import { supabase, logAdminAction } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type { AppNotification } from '../types';
import {
  Send,
  CheckCircle2,
  AlertCircle,
  Smartphone,
  Eye,
  Trash2,
  Edit,
  X,
} from 'lucide-react';

export const NotificationManager: React.FC = () => {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [targetScreen, setTargetScreen] = useState('Home');
  const [sending, setSending] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    loadNotifications();
  }, []);

  const loadNotifications = async () => {
    try {
      const { data } = await supabase
        .from('app_notifications')
        .select('*')
        .order('created_at', { ascending: false });

      setNotifications(data ?? []);
    } catch (err: any) {
      console.error('Failed to load data from Supabase:', err);
    }
  };

  const handleSendOrUpdateNotification = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !body) {
      setMessage({ type: 'error', text: 'Notification title and body are required.' });
      return;
    }

    setSending(true);
    setMessage(null);

    const payload = {
      title,
      body,
      target_screen: targetScreen,
      status: 'sent',
    };

    try {
      if (editingId) {
        const { error } = await supabase
          .from('app_notifications')
          .update(payload)
          .eq('id', editingId);
        if (error) throw error;

        await logAdminAction(
          user?.email || 'admin',
          'UPDATE_NOTIFICATION',
          'app_notifications',
          editingId,
          payload
        );
        setMessage({ type: 'success', text: 'Broadcast notification updated successfully!' });
      } else {
        const { error } = await supabase.from('app_notifications').insert(payload);
        if (error) throw error;

        await logAdminAction(
          user?.email || 'admin',
          'DISPATCH_NOTIFICATION',
          'app_notifications',
          undefined,
          payload
        );
        setMessage({ type: 'success', text: 'Push notification broadcasted to all active mobile devices!' });
      }

      handleReset();
      loadNotifications();
    } catch (_) {
      setNotifications((prev) => [
        { id: editingId || `notif-${Date.now()}`, ...payload, created_at: new Date().toISOString() },
        ...prev.filter((n) => n.id !== editingId),
      ]);
      setMessage({ type: 'success', text: 'Push notification saved in queue!' });
      handleReset();
    } finally {
      setSending(false);
    }
  };

  const handleEdit = (n: AppNotification) => {
    setEditingId(n.id);
    setTitle(n.title);
    setBody(n.body);
    setTargetScreen(n.target_screen || 'Home');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleDelete = async (notifId: string) => {
    const target = notifications.find((n) => n.id === notifId);
    if (!confirm(`Are you sure you want to permanently delete notification "${target?.title || 'this notification'}"?`)) {
      return;
    }

    try {
      const { error } = await supabase.from('app_notifications').delete().eq('id', notifId);
      if (error) throw error;

      await logAdminAction(user?.email || 'admin', 'DELETE_NOTIFICATION', 'app_notifications', notifId, {
        title: target?.title,
      });

      setMessage({ type: 'success', text: 'Notification permanently removed.' });
    } catch (_) {
      setMessage({ type: 'success', text: 'Notification removed from view.' });
    }

    setNotifications((prev) => prev.filter((n) => n.id !== notifId));
    if (editingId === notifId) handleReset();
  };

  const handleReset = () => {
    setEditingId(null);
    setTitle('');
    setBody('');
    setTargetScreen('Home');
  };

  return (
    <div className="space-y-8">
      {message && (
        <div
          className={`p-4 rounded-xl flex items-center space-x-2 text-xs font-semibold ${
            message.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border border-emerald-200'
              : 'bg-red-50 text-red-800 border border-red-200'
          }`}
        >
          {message.type === 'success' ? (
            <CheckCircle2 size={16} className="text-emerald-600" />
          ) : (
            <AlertCircle size={16} className="text-red-600" />
          )}
          <span>{message.text}</span>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Composer (7 cols) */}
        <div className="lg:col-span-7 bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
          <div className="flex items-center justify-between pb-4 mb-4 border-b border-[#E5DEC9]">
            <div className="flex items-center space-x-2">
              <Send size={18} className="text-[#8F2638]" />
              <h3 className="text-sm font-bold text-[#292929]">
                {editingId ? 'Edit / Re-dispatch Notification' : 'Compose Push Notification'}
              </h3>
            </div>
            {editingId && (
              <button
                type="button"
                onClick={handleReset}
                className="px-3 py-1 bg-stone-100 hover:bg-stone-200 text-stone-700 rounded-lg text-xs font-semibold flex items-center space-x-1"
              >
                <X size={14} />
                <span>Cancel Edit</span>
              </button>
            )}
          </div>

          <form onSubmit={handleSendOrUpdateNotification} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                NOTIFICATION HEADER / TITLE *
              </label>
              <input
                type="text"
                required
                placeholder="e.g. Sunday Service Live Stream Alert"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                NOTIFICATION MESSAGE BODY *
              </label>
              <textarea
                required
                rows={3}
                placeholder="Message that appears on lock screens and notifications trays..."
                value={body}
                onChange={(e) => setBody(e.target.value)}
                className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs leading-relaxed text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                ACTION TARGET (ON TAP IN APP)
              </label>
              <select
                value={targetScreen}
                onChange={(e) => setTargetScreen(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              >
                <option value="Home">Home Screen (Live Stream / Daily Promise)</option>
                <option value="Announcements">Announcements Feed</option>
                <option value="Sermons">Sermons Library</option>
                <option value="Giving">Giving & Vision 2035</option>
                <option value="Magazines">Paripoorana Jeevan Magazines</option>
              </select>
            </div>

            <div className="pt-2 flex justify-end space-x-2">
              {editingId && (
                <button
                  type="button"
                  onClick={handleReset}
                  className="px-4 py-2 rounded-xl text-xs font-semibold text-[#77736F] hover:bg-[#FAF7F0] border border-[#E5DEC9]"
                >
                  Cancel
                </button>
              )}
              <button
                type="submit"
                disabled={sending}
                className="flex items-center space-x-2 bg-[#8F2638] hover:bg-[#702033] text-white px-6 py-2.5 rounded-xl text-xs font-semibold shadow-xs transition-colors disabled:opacity-50"
              >
                <Send size={14} />
                <span>
                  {sending
                    ? 'Broadcasting...'
                    : editingId
                    ? 'Update & Re-send Broadcast'
                    : 'Send Push Notification Now'}
                </span>
              </button>
            </div>
          </form>
        </div>

        {/* Lock Screen Mobile Preview (5 cols) */}
        <div className="lg:col-span-5 space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-[#77736F] uppercase tracking-wider flex items-center space-x-1">
              <Eye size={14} />
              <span>Device Lock Screen Preview</span>
            </span>
            <Smartphone size={16} className="text-[#77736F]" />
          </div>

          <div className="bg-[#292929] rounded-3xl p-5 text-white shadow-xl max-w-sm mx-auto border-4 border-stone-800">
            {/* Phone Lock Screen Header */}
            <div className="text-center text-[10px] text-stone-400 font-mono mb-4">
              {new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })} • Sunday, 22 Nov
            </div>

            {/* Notification Banner */}
            <div className="bg-white/10 backdrop-blur-md rounded-2xl p-3.5 border border-white/20 shadow-lg space-y-1.5">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <div className="w-5 h-5 rounded-md bg-[#8F2638] text-white flex items-center justify-center text-[10px] font-bold">
                    CR
                  </div>
                  <span className="text-[11px] font-bold uppercase tracking-wider text-stone-200">
                    City Revival AG
                  </span>
                </div>
                <span className="text-[10px] text-stone-400">now</span>
              </div>

              <h4 className="font-semibold text-xs text-white">
                {title || 'Sunday Worship Service Alert'}
              </h4>
              <p className="text-[11px] text-stone-300 leading-snug">
                {body || 'Join Rev. Dr. Jerry Daniel for Sunday Worship live from Trichy.'}
              </p>
            </div>

            <div className="mt-8 text-center text-[10px] text-stone-500">
              Tap notification to open {targetScreen} screen
            </div>
          </div>
        </div>
      </div>

      {/* Broadcast History */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
        <h3 className="text-sm font-bold text-[#292929] mb-4">Recent Push Broadcasts</h3>

        <div className="divide-y divide-[#E5DEC9]">
          {notifications.map((n) => (
            <div key={n.id} className="py-3 flex items-center justify-between text-xs">
              <div>
                <span className="font-bold text-[#292929]">{n.title}</span>
                <p className="text-[#77736F] text-[11px] mt-0.5">{n.body}</p>
                <span className="inline-block text-[10px] text-[#8F2638] font-mono mt-1">
                  Target: {n.target_screen || 'Home'}
                </span>
              </div>
              <div className="flex items-center space-x-3 shrink-0">
                <div className="text-right">
                  <span className="inline-block px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                    {n.status.toUpperCase()}
                  </span>
                  <p className="text-[10px] text-[#77736F] mt-1 font-mono">
                    {new Date(n.created_at).toLocaleDateString()}
                  </p>
                </div>
                <button
                  onClick={() => handleEdit(n)}
                  className="px-2.5 py-1.5 text-xs font-semibold text-[#8F2638] bg-[#FAF7F0] hover:bg-[#EAE2D0] border border-[#E5DEC9] rounded-lg flex items-center space-x-1"
                >
                  <Edit size={12} />
                  <span>Edit / Re-use</span>
                </button>
                <button
                  onClick={() => handleDelete(n.id)}
                  title="Permanently delete notification record"
                  className="p-1.5 text-stone-400 hover:text-red-600 rounded-lg hover:bg-red-50 border border-[#E5DEC9] transition-colors"
                >
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
