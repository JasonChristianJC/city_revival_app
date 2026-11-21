import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type { AuditLog } from '../types';
import { ShieldCheck, RefreshCw, Lock, Search, Trash2 } from 'lucide-react';

export const AuditLogViewer: React.FC = () => {
  const { isSuperAdmin } = useAuth();
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [filterTable, setFilterTable] = useState('All');

  useEffect(() => {
    loadLogs();
  }, []);

  const loadLogs = async () => {
    setLoading(true);
    try {
      const { data } = await supabase
        .from('admin_audit_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(100);

      setLogs(data ?? []);
    } catch (err: any) {
      console.error('Failed to load data from Supabase:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteLog = async (logId: string) => {
    if (!confirm('Are you sure you want to permanently delete this audit log entry?')) return;

    try {
      await supabase.from('admin_audit_logs').delete().eq('id', logId);
    } catch (_) {}

    setLogs((prev) => prev.filter((l) => l.id !== logId));
  };

  if (!isSuperAdmin) {
    return (
      <div className="bg-red-50 p-6 rounded-2xl border border-red-200 text-center text-red-800">
        <Lock size={32} className="mx-auto mb-2 text-red-600" />
        <h3 className="font-bold text-base">Super Administrator Permission Required</h3>
        <p className="text-xs text-red-700 mt-1">
          Administrative audit trails are restricted to authorized church leadership.
        </p>
      </div>
    );
  }

  const filteredLogs = logs.filter((log) => {
    const matchTable = filterTable === 'All' || log.target_table === filterTable;
    const matchSearch =
      search === '' ||
      log.action.toLowerCase().includes(search.toLowerCase()) ||
      log.admin_email.toLowerCase().includes(search.toLowerCase());
    return matchTable && matchSearch;
  });

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div className="flex items-center space-x-3">
          <div className="p-3 bg-[#FAF7F0] text-[#8F2638] rounded-xl border border-[#E5DEC9]">
            <ShieldCheck size={22} />
          </div>
          <div>
            <h3 className="text-base font-bold text-[#292929]">Administrative Audit Trail</h3>
            <p className="text-xs text-[#77736F]">
              Audit log of modifications made to church content, banking, and mobile records.
            </p>
          </div>
        </div>

        <button
          onClick={loadLogs}
          className="flex items-center space-x-1.5 px-3 py-2 bg-[#FAF7F0] hover:bg-[#EAE2D0] border border-[#E5DEC9] text-[#292929] rounded-xl text-xs font-semibold"
        >
          <RefreshCw size={14} className={loading ? 'animate-spin' : ''} />
          <span>Refresh Audit Trail</span>
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center space-x-3">
          <div className="relative">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#77736F]" />
            <input
              type="text"
              placeholder="Search actions or admin email..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-8 pr-3 py-1.5 bg-white border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
            />
          </div>

          <select
            value={filterTable}
            onChange={(e) => setFilterTable(e.target.value)}
            className="px-3 py-1.5 bg-white border border-[#E5DEC9] rounded-xl text-xs font-medium text-[#292929]"
          >
            <option value="All">All Tables</option>
            <option value="giving_settings">Giving Accounts</option>
            <option value="building_fund">Building Fund</option>
            <option value="daily_verses">Daily Verses</option>
            <option value="announcements">Announcements</option>
            <option value="sermons">Sermons</option>
            <option value="live_streams">Live Streams</option>
            <option value="magazines">Magazines</option>
            <option value="prayer_requests">Prayer Requests</option>
            <option value="app_notifications">Notifications</option>
          </select>
        </div>

        <span className="text-xs text-[#77736F] font-mono">
          {filteredLogs.length} logged events
        </span>
      </div>

      {/* Log Table */}
      <div className="bg-white rounded-2xl border border-[#E5DEC9] shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-[#E5DEC9] bg-[#FAF7F0] text-[#77736F] uppercase text-[10px] font-semibold">
                <th className="py-3 px-4">Timestamp</th>
                <th className="py-3 px-4">Admin Email</th>
                <th className="py-3 px-4">Action</th>
                <th className="py-3 px-4">Table</th>
                <th className="py-3 px-4">Details / Payload</th>
                <th className="py-3 px-4 text-right">Delete</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E5DEC9]">
              {filteredLogs.map((log) => (
                <tr key={log.id} className="hover:bg-[#FAF7F0] transition-colors">
                  <td className="py-3 px-4 font-mono text-[#77736F] whitespace-nowrap">
                    {new Date(log.created_at).toLocaleString()}
                  </td>
                  <td className="py-3 px-4 font-semibold text-[#292929]">{log.admin_email}</td>
                  <td className="py-3 px-4">
                    <span className="px-2 py-0.5 font-mono font-bold text-[10px] bg-red-50 text-[#8F2638] rounded border border-red-200">
                      {log.action}
                    </span>
                  </td>
                  <td className="py-3 px-4 font-mono text-[#263B63]">{log.target_table}</td>
                  <td className="py-3 px-4 max-w-xs truncate text-[#77736F] font-mono text-[11px]">
                    {log.details ? JSON.stringify(log.details) : '—'}
                  </td>
                  <td className="py-3 px-4 text-right">
                    <button
                      onClick={() => handleDeleteLog(log.id)}
                      title="Permanently remove log entry"
                      className="p-1 text-stone-400 hover:text-red-600 rounded-md hover:bg-red-50"
                    >
                      <Trash2 size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
