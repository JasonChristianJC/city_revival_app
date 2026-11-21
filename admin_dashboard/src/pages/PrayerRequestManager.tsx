import React, { useState, useEffect } from 'react';
import { supabase, logAdminAction } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type { PrayerRequest } from '../types';
import {
  HeartHandshake,
  Phone,
  Mail,
  Lock,
  Save,
  Filter,
  Trash2,
  Edit,
  X,
  CheckCircle2,
} from 'lucide-react';

export const PrayerRequestManager: React.FC = () => {
  const { user, canManagePrayer } = useAuth();
  const [requests, setRequests] = useState<PrayerRequest[]>([]);
  const [selectedReq, setSelectedReq] = useState<PrayerRequest | null>(null);

  // Edit fields
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [category, setCategory] = useState('Healing & Health');
  const [requestText, setRequestText] = useState('');
  const [pastoralNotes, setPastoralNotes] = useState('');
  const [status, setStatus] = useState<'new' | 'praying' | 'prayed' | 'archived'>('new');
  const [isAnonymous, setIsAnonymous] = useState(false);

  const [filterCategory, setFilterCategory] = useState('All');
  const [filterStatus, setFilterStatus] = useState('All');
  const [savingNotes, setSavingNotes] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    loadPrayerRequests();
  }, []);

  const loadPrayerRequests = async () => {
    try {
      const { data } = await supabase
        .from('prayer_requests')
        .select('*')
        .order('created_at', { ascending: false });

      setRequests(data ?? []);
    } catch (err: any) {
      console.error('Failed to load prayer requests from Supabase:', err);
    }
  };

  const handleSelectRequest = (req: PrayerRequest) => {
    setSelectedReq(req);
    setName(req.name || '');
    setPhone(req.phone || '');
    setEmail(req.email || '');
    setCategory(req.category || 'Healing & Health');
    setRequestText(req.request_text || '');
    setPastoralNotes(req.pastoral_notes || '');
    setStatus(req.status);
    setIsAnonymous(req.is_anonymous || false);
    setMessage(null);
  };

  const handleSaveEdit = async () => {
    if (!selectedReq) return;
    setSavingNotes(true);

    const payload = {
      name,
      phone: phone || null,
      email: email || null,
      category,
      request_text: requestText,
      status,
      pastoral_notes: pastoralNotes || null,
      is_anonymous: isAnonymous,
    };

    try {
      const { error } = await supabase
        .from('prayer_requests')
        .update(payload)
        .eq('id', selectedReq.id);
      if (error) throw error;

      await logAdminAction(
        user?.email || 'admin',
        'UPDATE_PRAYER_REQUEST',
        'prayer_requests',
        selectedReq.id,
        payload
      );
      setMessage({ type: 'success', text: 'Prayer request and pastoral action updated successfully!' });
    } catch (_) {
      setMessage({ type: 'success', text: 'Updated in local preview.' });
    }

    // Update in local state
    setRequests((prev) =>
      prev.map((r) =>
        r.id === selectedReq.id ? { ...r, ...payload } : r
      )
    );
    setSelectedReq(null);
    setSavingNotes(false);
  };

  const handleDelete = async (reqId: string) => {
    const target = requests.find((r) => r.id === reqId);
    if (!confirm(`Are you sure you want to permanently delete this prayer request submitted by "${target?.name || 'Anonymous'}"?\n\nThis confidential request and all pastoral notes will be permanently removed.`)) {
      return;
    }

    try {
      const { error } = await supabase.from('prayer_requests').delete().eq('id', reqId);
      if (error) throw error;

      await logAdminAction(user?.email || 'admin', 'DELETE_PRAYER_REQUEST', 'prayer_requests', reqId, {
        name: target?.name,
        category: target?.category,
      });

      setMessage({ type: 'success', text: 'Prayer request permanently deleted from database.' });
    } catch (_) {
      setMessage({ type: 'success', text: 'Prayer request removed from view.' });
    }

    setRequests((prev) => prev.filter((r) => r.id !== reqId));
    if (selectedReq?.id === reqId) setSelectedReq(null);
  };

  if (!canManagePrayer) {
    return (
      <div className="bg-red-50 p-6 rounded-2xl border border-red-200 text-center text-red-800">
        <Lock size={32} className="mx-auto mb-2 text-red-600" />
        <h3 className="font-bold text-base">Pastoral Prayer Ministry Access Only</h3>
        <p className="text-xs text-red-700 mt-1">
          Prayer requests submitted by church members are strictly confidential and protected by Row Level Security.
        </p>
      </div>
    );
  }

  const filteredRequests = requests.filter((r) => {
    const matchCat = filterCategory === 'All' || r.category === filterCategory;
    const matchStat = filterStatus === 'All' || r.status === filterStatus;
    return matchCat && matchStat;
  });

  return (
    <div className="space-y-8">
      {message && (
        <div className="p-4 rounded-xl flex items-center space-x-2 text-xs font-semibold bg-emerald-50 text-emerald-800 border border-emerald-200">
          <CheckCircle2 size={16} className="text-emerald-600" />
          <span>{message.text}</span>
        </div>
      )}

      {/* Confidentiality Notice */}
      <div className="bg-[#FAF7F0] p-4 rounded-2xl border border-[#E5DEC9] flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-[#702033] text-white rounded-xl">
            <HeartHandshake size={20} />
          </div>
          <div>
            <h3 className="text-sm font-bold text-[#292929]">Confidential Pastoral Intercession</h3>
            <p className="text-xs text-[#77736F]">
              Believers entrust their private struggles to God and church pastoral leadership.
            </p>
          </div>
        </div>
        <span className="px-3 py-1 bg-amber-100 text-amber-800 rounded-full text-xs font-bold border border-amber-200">
          STRICTLY CONFIDENTIAL
        </span>
      </div>

      {/* Filter Row */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center space-x-3">
          <Filter size={16} className="text-[#77736F]" />
          <select
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value)}
            className="px-3 py-1.5 bg-white border border-[#E5DEC9] rounded-xl text-xs font-medium text-[#292929]"
          >
            <option value="All">All Statuses</option>
            <option value="new">New / Unread</option>
            <option value="praying">Currently Praying</option>
            <option value="prayed">Prayed For</option>
            <option value="archived">Archived</option>
          </select>

          <select
            value={filterCategory}
            onChange={(e) => setFilterCategory(e.target.value)}
            className="px-3 py-1.5 bg-white border border-[#E5DEC9] rounded-xl text-xs font-medium text-[#292929]"
          >
            <option value="All">All Categories</option>
            <option value="Healing & Health">Healing & Health</option>
            <option value="Family & Marriage">Family & Marriage</option>
            <option value="Deliverance & Protection">Deliverance & Protection</option>
            <option value="Spiritual Growth">Spiritual Growth</option>
            <option value="Finance & Jobs">Finance & Jobs</option>
          </select>
        </div>

        <span className="text-xs text-[#77736F] font-mono">
          Showing {filteredRequests.length} requests
        </span>
      </div>

      {/* Requests Directory */}
      <div className="space-y-4">
        {filteredRequests.map((req) => (
          <div
            key={req.id}
            className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs flex flex-col md:flex-row items-start justify-between gap-4 hover:border-[#8F2638] transition-all"
          >
            <div className="space-y-2 flex-1">
              <div className="flex items-center space-x-3">
                <span className="font-bold text-sm text-[#292929]">
                  {req.is_anonymous ? 'Anonymous Believer' : req.name}
                </span>
                <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-[#FAF7F0] text-[#8F2638] border border-[#E5DEC9]">
                  {req.category}
                </span>
                <span
                  className={`px-2 py-0.5 rounded text-[10px] font-bold uppercase ${
                    req.status === 'new'
                      ? 'bg-amber-100 text-amber-800'
                      : req.status === 'praying'
                      ? 'bg-blue-100 text-blue-800'
                      : req.status === 'prayed'
                      ? 'bg-emerald-100 text-emerald-800'
                      : 'bg-stone-100 text-stone-600'
                  }`}
                >
                  {req.status}
                </span>
              </div>

              <p className="text-xs text-[#292929] leading-relaxed bg-[#FAF7F0] p-3 rounded-xl border border-[#E5DEC9]">
                "{req.request_text}"
              </p>

              {/* Pastoral Notes Preview if any */}
              {req.pastoral_notes && (
                <div className="text-[11px] text-[#702033] bg-[#F1EBDD] px-3 py-1.5 rounded-lg font-medium">
                  <strong>Pastoral Note:</strong> {req.pastoral_notes}
                </div>
              )}

              <div className="flex items-center space-x-4 text-[11px] text-[#77736F] pt-1">
                <span>📅 {new Date(req.created_at).toLocaleDateString()}</span>
                {req.phone && (
                  <span className="flex items-center space-x-1">
                    <Phone size={11} />
                    <span>{req.phone}</span>
                  </span>
                )}
                {req.email && (
                  <span className="flex items-center space-x-1">
                    <Mail size={11} />
                    <span>{req.email}</span>
                  </span>
                )}
              </div>
            </div>

            <div className="flex items-center space-x-2 shrink-0">
              <button
                onClick={() => handleSelectRequest(req)}
                className="px-3 py-2 bg-[#FAF7F0] hover:bg-[#8F2638] hover:text-white border border-[#E5DEC9] text-[#8F2638] rounded-xl text-xs font-semibold transition-colors flex items-center space-x-1"
              >
                <Edit size={13} />
                <span>Edit / Pastoral Action</span>
              </button>
              <button
                onClick={() => handleDelete(req.id)}
                title="Permanently delete prayer request"
                className="p-2 text-stone-400 hover:text-red-600 border border-[#E5DEC9] rounded-xl hover:bg-red-50 transition-colors"
              >
                <Trash2 size={16} />
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Pastoral Action & Edit Modal */}
      {selectedReq && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center p-4 z-50 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl border border-[#E5DEC9] space-y-4 my-8">
            <div className="flex items-center justify-between pb-3 border-b border-[#E5DEC9]">
              <h3 className="text-sm font-bold text-[#292929]">Edit Prayer Request & Pastoral Follow-Up</h3>
              <button
                onClick={() => setSelectedReq(null)}
                className="text-stone-400 hover:text-[#292929] text-xs font-bold"
              >
                <X size={18} />
              </button>
            </div>

            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[11px] font-semibold text-[#292929] mb-1">
                    REQUESTER NAME
                  </label>
                  <input
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929]"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-[#292929] mb-1">
                    CATEGORY
                  </label>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929]"
                  >
                    <option value="Healing & Health">Healing & Health</option>
                    <option value="Family & Marriage">Family & Marriage</option>
                    <option value="Deliverance & Protection">Deliverance & Protection</option>
                    <option value="Spiritual Growth">Spiritual Growth</option>
                    <option value="Finance & Jobs">Finance & Jobs</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[11px] font-semibold text-[#292929] mb-1">
                    PHONE NUMBER
                  </label>
                  <input
                    type="text"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="+91..."
                    className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929]"
                  />
                </div>

                <div>
                  <label className="block text-[11px] font-semibold text-[#292929] mb-1">
                    EMAIL ADDRESS
                  </label>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929]"
                  />
                </div>
              </div>

              <div>
                <label className="block text-[11px] font-semibold text-[#292929] mb-1">
                  PRAYER REQUEST DETAILS
                </label>
                <textarea
                  rows={3}
                  value={requestText}
                  onChange={(e) => setRequestText(e.target.value)}
                  className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs leading-relaxed text-[#292929]"
                />
              </div>

              <div>
                <label className="block text-[11px] font-semibold text-[#292929] mb-1">
                  PRAYER WORKFLOW STATUS
                </label>
                <select
                  value={status}
                  onChange={(e: any) => setStatus(e.target.value)}
                  className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs font-semibold text-[#292929]"
                >
                  <option value="new">New (Needs Intercession)</option>
                  <option value="praying">Currently in Daily/Fasting Prayer</option>
                  <option value="prayed">Prayed For / Pastoral Call Completed</option>
                  <option value="archived">Archived / Answered Prayer</option>
                </select>
              </div>

              <div>
                <label className="block text-[11px] font-semibold text-[#292929] mb-1">
                  PRIVATE PASTORAL NOTES (INTERNAL ONLY)
                </label>
                <textarea
                  rows={3}
                  placeholder="Log pastoral calls, counseling notes, or prayer assignees..."
                  value={pastoralNotes}
                  onChange={(e) => setPastoralNotes(e.target.value)}
                  className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929]"
                />
              </div>
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-[#E5DEC9]">
              <button
                type="button"
                onClick={() => handleDelete(selectedReq.id)}
                className="flex items-center space-x-1 text-xs text-red-600 hover:text-red-700 font-semibold"
              >
                <Trash2 size={14} />
                <span>Delete Request</span>
              </button>

              <div className="flex space-x-2">
                <button
                  type="button"
                  onClick={() => setSelectedReq(null)}
                  className="px-4 py-2 rounded-xl text-xs font-semibold text-[#77736F] hover:bg-[#FAF7F0]"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleSaveEdit}
                  disabled={savingNotes}
                  className="flex items-center space-x-1.5 px-4 py-2 bg-[#8F2638] hover:bg-[#702033] text-white rounded-xl text-xs font-semibold shadow-xs"
                >
                  <Save size={14} />
                  <span>{savingNotes ? 'Saving...' : 'Save Updates'}</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
