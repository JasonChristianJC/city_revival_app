import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import {
  BookOpen,
  BellRing,
  Video,
  Radio,
  BookMarked,
  HeartHandshake,
  Coins,
  ShieldCheck,
  Plus,
} from 'lucide-react';
import type { TabKey } from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';

interface DashboardOverviewProps {
  onNavigate: (tab: TabKey) => void;
  isLive: boolean;
  onToggleLive: () => void;
}

export const DashboardOverview: React.FC<DashboardOverviewProps> = ({
  onNavigate,
  isLive,
  onToggleLive,
}) => {
  const { user, isSuperAdmin, canManagePrayer } = useAuth();
  const [stats, setStats] = useState({
    versesCount: 4,
    announcementsCount: 4,
    sermonsCount: 2,
    magazinesCount: 3,
    prayerRequestsCount: 1,
  });

  const [recentLogs, setRecentLogs] = useState<any[]>([
    {
      action: 'SYSTEM_BOOT',
      admin_email: 'pastor@cityrevivalagchurch.org',
      target_table: 'daily_verses',
      created_at: new Date().toISOString(),
    },
    {
      action: 'UPDATE_BUILDING_FUND',
      admin_email: 'pastor@cityrevivalagchurch.org',
      target_table: 'building_fund',
      created_at: new Date(Date.now() - 3600000).toISOString(),
    },
  ]);

  useEffect(() => {
    async function loadStats() {
      try {
        const [vRes, aRes, sRes, mRes] = await Promise.all([
          supabase.from('daily_verses').select('id', { count: 'exact', head: true }),
          supabase.from('announcements').select('id', { count: 'exact', head: true }),
          supabase.from('sermons').select('id', { count: 'exact', head: true }),
          supabase.from('magazines').select('id', { count: 'exact', head: true }),
        ]);

        let prayerCount = 1;
        if (canManagePrayer) {
          const pRes = await supabase.from('prayer_requests').select('id', { count: 'exact', head: true }).eq('status', 'new');
          if (pRes.count !== null && pRes.count !== undefined) prayerCount = pRes.count;
        }

        setStats((prev) => ({
          ...prev,
          versesCount: vRes.count ?? prev.versesCount,
          announcementsCount: aRes.count ?? prev.announcementsCount,
          sermonsCount: sRes.count ?? prev.sermonsCount,
          magazinesCount: mRes.count ?? prev.magazinesCount,
          prayerRequestsCount: prayerCount,
        }));

        if (isSuperAdmin) {
          const { data: logs } = await supabase
            .from('admin_audit_logs')
            .select('*')
            .order('created_at', { ascending: false })
            .limit(4);
          if (logs && logs.length > 0) setRecentLogs(logs);
        }
      } catch (err) {
        console.warn('Using default demo stats:', err);
      }
    }
    loadStats();
  }, [canManagePrayer, isSuperAdmin]);

  return (
    <div className="space-y-8">
      {/* Welcome & Quick Action Banner */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <span className="text-xs uppercase font-bold tracking-wider text-[#8F2638]">
            CHURCH LEADERSHIP PORTAL
          </span>
          <h1 className="text-2xl font-serif font-bold text-[#292929] mt-0.5">
            Welcome, {user?.email?.split('@')[0] || 'Pastor'}
          </h1>
          <p className="text-xs text-[#77736F] mt-1">
            Managing City Revival AG Church • Trichy congregation mobile services.
          </p>
        </div>

        <div className="flex items-center space-x-3">
          <button
            onClick={() => onNavigate('daily_verse')}
            className="flex items-center space-x-2 bg-[#8F2638] hover:bg-[#702033] text-white px-4 py-2.5 rounded-xl text-xs font-semibold shadow-xs transition-colors"
          >
            <Plus size={14} />
            <span>Publish Daily Verse</span>
          </button>
          <button
            onClick={onToggleLive}
            className={`flex items-center space-x-2 px-4 py-2.5 rounded-xl text-xs font-semibold shadow-xs transition-colors border ${
              isLive
                ? 'bg-red-50 text-red-700 border-red-300 hover:bg-red-100'
                : 'bg-white text-[#292929] border-[#E5DEC9] hover:bg-[#FAF7F0]'
            }`}
          >
            <Radio size={14} className={isLive ? 'text-red-600 animate-pulse' : 'text-[#77736F]'} />
            <span>{isLive ? 'End Live Stream' : 'Go Live on YouTube'}</span>
          </button>
        </div>
      </div>

      {/* Metric Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Daily Verses */}
        <div
          onClick={() => onNavigate('daily_verse')}
          className="bg-white p-5 rounded-2xl border border-[#E5DEC9] hover:border-[#8F2638] transition-all cursor-pointer shadow-xs group"
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-[#77736F] uppercase tracking-wide">
              Daily Verses
            </span>
            <div className="w-8 h-8 rounded-lg bg-[#FAF7F0] flex items-center justify-center text-[#8F2638] group-hover:bg-[#8F2638] group-hover:text-white transition-colors">
              <BookOpen size={16} />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold text-[#292929]">{stats.versesCount}</span>
            <span className="text-xs text-[#77736F] ml-2 font-medium">scheduled</span>
          </div>
          <p className="text-[11px] text-[#8F2638] mt-2 font-semibold">Today's promise active →</p>
        </div>

        {/* Announcements */}
        <div
          onClick={() => onNavigate('announcements')}
          className="bg-white p-5 rounded-2xl border border-[#E5DEC9] hover:border-[#8F2638] transition-all cursor-pointer shadow-xs group"
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-[#77736F] uppercase tracking-wide">
              Announcements
            </span>
            <div className="w-8 h-8 rounded-lg bg-[#FAF7F0] flex items-center justify-center text-[#8F2638] group-hover:bg-[#8F2638] group-hover:text-white transition-colors">
              <BellRing size={16} />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold text-[#292929]">{stats.announcementsCount}</span>
            <span className="text-xs text-[#77736F] ml-2 font-medium">published</span>
          </div>
          <p className="text-[11px] text-[#8F2638] mt-2 font-semibold">Service alerts & events →</p>
        </div>

        {/* Sermons */}
        <div
          onClick={() => onNavigate('sermons')}
          className="bg-white p-5 rounded-2xl border border-[#E5DEC9] hover:border-[#8F2638] transition-all cursor-pointer shadow-xs group"
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-[#77736F] uppercase tracking-wide">
              Sermons
            </span>
            <div className="w-8 h-8 rounded-lg bg-[#FAF7F0] flex items-center justify-center text-[#8F2638] group-hover:bg-[#8F2638] group-hover:text-white transition-colors">
              <Video size={16} />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold text-[#292929]">{stats.sermonsCount}</span>
            <span className="text-xs text-[#77736F] ml-2 font-medium">archived</span>
          </div>
          <p className="text-[11px] text-[#8F2638] mt-2 font-semibold">Rev. Dr. Jerry Daniel →</p>
        </div>

        {/* Magazines */}
        <div
          onClick={() => onNavigate('magazines')}
          className="bg-white p-5 rounded-2xl border border-[#E5DEC9] hover:border-[#8F2638] transition-all cursor-pointer shadow-xs group"
        >
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-[#77736F] uppercase tracking-wide">
              Magazines
            </span>
            <div className="w-8 h-8 rounded-lg bg-[#FAF7F0] flex items-center justify-center text-[#8F2638] group-hover:bg-[#8F2638] group-hover:text-white transition-colors">
              <BookMarked size={16} />
            </div>
          </div>
          <div className="mt-3">
            <span className="text-2xl font-bold text-[#292929]">{stats.magazinesCount}</span>
            <span className="text-xs text-[#77736F] ml-2 font-medium">issues</span>
          </div>
          <p className="text-[11px] text-[#8F2638] mt-2 font-semibold">Paripoorana Jeevan →</p>
        </div>
      </div>

      {/* Two Columns: Vision 2035 & Confidential Prayer / Audit Logs */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Vision 2035 Building Fund Tracker */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-2">
              <div className="p-2 bg-[#FAF7F0] text-[#8F2638] rounded-lg">
                <Coins size={18} />
              </div>
              <div>
                <h3 className="text-sm font-bold text-[#292929]">Vision 2035 Sanctuary Fund</h3>
                <p className="text-xs text-[#77736F]">5,000-seat sanctuary in Tiruchirappalli</p>
              </div>
            </div>
            {isSuperAdmin && (
              <button
                onClick={() => onNavigate('giving')}
                className="text-xs font-semibold text-[#8F2638] hover:underline"
              >
                Edit Target
              </button>
            )}
          </div>

          <div className="space-y-3">
            <div className="flex justify-between items-baseline">
              <span className="text-xs text-[#77736F]">Collected so far:</span>
              <span className="text-lg font-bold text-[#8F2638]">₹4,35,00,000 (₹4.35 Cr)</span>
            </div>
            <div className="w-full bg-[#FAF7F0] h-3 rounded-full overflow-hidden border border-[#E5DEC9]">
              <div
                className="bg-[#8F2638] h-full rounded-full transition-all duration-1000"
                style={{ width: '43.5%' }}
              />
            </div>
            <div className="flex justify-between items-baseline text-xs text-[#77736F]">
              <span>Progress: 43.5%</span>
              <span>Target: ₹10,00,00,000 (₹10.0 Cr)</span>
            </div>
          </div>

          <div className="mt-5 p-3 rounded-xl bg-[#FAF7F0] border border-[#E5DEC9] flex items-center justify-between text-xs">
            <span className="text-[#77736F]">Direct UPI Giving:</span>
            <span className="font-mono font-semibold text-[#292929]">ppr.01285.02022024.00405561@cnrb</span>
          </div>
        </div>

        {/* Prayer Requests / Live Stream Status */}
        <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-2">
                <div className="p-2 bg-[#FAF7F0] text-[#702033] rounded-lg">
                  <HeartHandshake size={18} />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-[#292929]">Confidential Prayer Ministry</h3>
                  <p className="text-xs text-[#77736F]">Believers' prayer submissions</p>
                </div>
              </div>
              {canManagePrayer && (
                <button
                  onClick={() => onNavigate('prayer_requests')}
                  className="text-xs font-semibold text-[#8F2638] hover:underline"
                >
                  View All
                </button>
              )}
            </div>

            <div className="p-4 rounded-xl bg-[#FAF7F0] border border-[#E5DEC9]">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs font-semibold text-[#77736F]">Pending Intercessory Requests</p>
                  <p className="text-2xl font-bold text-[#702033] mt-1">
                    {stats.prayerRequestsCount}
                  </p>
                </div>
                <div className="text-right">
                  <span className="inline-block px-2 py-0.5 text-[10px] font-bold rounded bg-amber-100 text-amber-800 border border-amber-200">
                    STRICTLY CONFIDENTIAL
                  </span>
                  <p className="text-[11px] text-[#77736F] mt-1">RLS Protected</p>
                </div>
              </div>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-[#E5DEC9] flex items-center justify-between text-xs text-[#77736F]">
            <span>Sunday Service Timings:</span>
            <span className="font-medium text-[#292929]">Tamil: 7:00 AM & 11:00 AM • English: 9:00 AM</span>
          </div>
        </div>
      </div>

      {/* Security & Audit Summary */}
      {isSuperAdmin && (
        <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-2">
              <ShieldCheck size={18} className="text-[#8F2638]" />
              <h3 className="text-sm font-bold text-[#292929]">Recent Administrative Activity</h3>
            </div>
            <button
              onClick={() => onNavigate('audit_logs')}
              className="text-xs font-semibold text-[#8F2638] hover:underline"
            >
              Full Audit Trail →
            </button>
          </div>

          <div className="divide-y divide-[#E5DEC9] text-xs">
            {recentLogs.map((log, idx) => (
              <div key={idx} className="py-2.5 flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <span className="font-mono font-semibold px-2 py-0.5 rounded bg-[#FAF7F0] text-[#8F2638] border border-[#E5DEC9]">
                    {log.action}
                  </span>
                  <span className="text-[#77736F]">{log.admin_email}</span>
                </div>
                <span className="text-[#77736F] text-[11px]">
                  {new Date(log.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
