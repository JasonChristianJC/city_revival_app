import React from 'react';
import {
  LayoutDashboard,
  BookOpen,
  BellRing,
  Video,
  Radio,
  BookMarked,
  Coins,
  HeartHandshake,
  Send,
  ShieldCheck,
  LogOut,
  UserCheck,
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export type TabKey =
  | 'overview'
  | 'daily_verse'
  | 'announcements'
  | 'sermons'
  | 'live_stream'
  | 'magazines'
  | 'giving'
  | 'prayer_requests'
  | 'notifications'
  | 'audit_logs';

interface SidebarProps {
  currentTab: TabKey;
  onSelectTab: (tab: TabKey) => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ currentTab, onSelectTab }) => {
  const { user, logout } = useAuth();

  const navItems: { key: TabKey; label: string; icon: React.ReactNode; visible: boolean }[] = [
    {
      key: 'overview',
      label: 'Dashboard Overview',
      icon: <LayoutDashboard size={18} />,
      visible: true,
    },
    {
      key: 'daily_verse',
      label: 'Daily Promise Verse',
      icon: <BookOpen size={18} />,
      visible: true,
    },
    {
      key: 'announcements',
      label: 'Announcements',
      icon: <BellRing size={18} />,
      visible: true,
    },
    {
      key: 'sermons',
      label: 'Sermons Library',
      icon: <Video size={18} />,
      visible: true,
    },
    {
      key: 'live_stream',
      label: 'Live Stream Control',
      icon: <Radio size={18} />,
      visible: true,
    },
    {
      key: 'magazines',
      label: 'Paripoorana Jeevan',
      icon: <BookMarked size={18} />,
      visible: true,
    },
    {
      key: 'giving',
      label: 'Giving & Vision 2035',
      icon: <Coins size={18} />,
      visible: true,
    },
    {
      key: 'prayer_requests',
      label: 'Confidential Prayers',
      icon: <HeartHandshake size={18} />,
      visible: true,
    },
    {
      key: 'notifications',
      label: 'Push Notifications',
      icon: <Send size={18} />,
      visible: true,
    },
    {
      key: 'audit_logs',
      label: 'Admin Audit Logs',
      icon: <ShieldCheck size={18} />,
      visible: true,
    },
  ];

  const badge = { label: 'Administrator', bg: 'bg-[#8F2638] text-white' };

  return (
    <aside className="w-64 bg-[#F1EBDD] border-r border-[#E5DEC9] flex flex-col h-screen select-none">
      {/* Brand Header */}
      <div className="p-5 border-b border-[#E5DEC9] bg-[#FAF7F0]">
        <div className="flex items-center space-x-3">
          <img
            src="/church_logo.png"
            alt="City Revival AG Church"
            className="w-10 h-10 rounded-full object-contain bg-white border border-[#E5DEC9] shadow-xs"
          />
          <div>
            <h1 className="text-sm font-bold text-[#8F2638] tracking-tight leading-tight uppercase">
              City Revival AG
            </h1>
            <p className="text-[11px] text-[#77736F] font-medium tracking-wide">
              ADMIN CONTROL PANEL
            </p>
          </div>
        </div>
      </div>

      {/* Navigation List */}
      <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-1">
        {navItems
          .filter((item) => item.visible)
          .map((item) => {
            const isActive = currentTab === item.key;
            return (
              <button
                key={item.key}
                onClick={() => onSelectTab(item.key)}
                className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors ${
                  isActive
                    ? 'bg-[#8F2638] text-white shadow-xs'
                    : 'text-[#292929] hover:bg-[#EAE2D0] hover:text-[#8F2638]'
                }`}
              >
                <span className={isActive ? 'text-white' : 'text-[#8F2638]'}>
                  {item.icon}
                </span>
                <span>{item.label}</span>
              </button>
            );
          })}
      </nav>

      {/* User Info & Logout Footer */}
      <div className="p-4 border-t border-[#E5DEC9] bg-[#FAF7F0]">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center space-x-2 truncate">
            <UserCheck size={16} className="text-[#8F2638] shrink-0" />
            <div className="truncate">
              <p className="text-xs font-semibold text-[#292929] truncate">
                {user?.email || 'pastor@cityrevivalagchurch.org'}
              </p>
              <span
                className={`inline-block px-1.5 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider ${badge.bg}`}
              >
                {badge.label}
              </span>
            </div>
          </div>
        </div>

        <button
          onClick={logout}
          className="w-full flex items-center justify-center space-x-2 px-3 py-2 rounded-lg text-xs font-medium text-[#77736F] hover:text-[#8F2638] hover:bg-[#EAE2D0] transition-colors border border-[#E5DEC9]"
        >
          <LogOut size={14} />
          <span>Sign Out Safely</span>
        </button>
      </div>
    </aside>
  );
};
