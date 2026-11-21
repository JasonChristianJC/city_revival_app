import React from 'react';
import type { TabKey } from './Sidebar';
import { Radio, ShieldAlert } from 'lucide-react';

interface HeaderProps {
  currentTab: TabKey;
  isLive?: boolean;
}

const TAB_TITLES: Record<TabKey, { title: string; subtitle: string }> = {
  overview: {
    title: 'Church Application Overview',
    subtitle: 'Real-time health, activity and summary statistics for City Revival AG Church mobile app.',
  },
  daily_verse: {
    title: 'Daily Promise Verse Publisher',
    subtitle: 'Schedule and manage morning scripture promises in English and Tamil.',
  },
  announcements: {
    title: 'Church Announcements & Service Alerts',
    subtitle: 'Post upcoming fasting prayers, conventions, youth meetings and flyers.',
  },
  sermons: {
    title: 'Sermons Library & Video Archives',
    subtitle: 'Manage messages preached by Rev. Dr. Jerry Daniel and pastoral team.',
  },
  live_stream: {
    title: 'Sunday Live Stream Control',
    subtitle: 'Broadcast YouTube live stream links directly to congregation mobile phones.',
  },
  magazines: {
    title: 'Paripoorana Jeevan Magazine',
    subtitle: 'Upload and publish bi-monthly PDF issues and cover artwork.',
  },
  giving: {
    title: 'Tithes, Offerings & Vision 2035',
    subtitle: 'Safely maintain church UPI VPA, SBI bank details and building fund counters.',
  },
  prayer_requests: {
    title: 'Confidential Pastoral Prayer Requests',
    subtitle: 'Private prayer requests submitted by believers. Accessible strictly to pastoral leadership.',
  },
  notifications: {
    title: 'Congregation Push Notifications',
    subtitle: 'Draft and schedule instant push notification banners to church members.',
  },
  audit_logs: {
    title: 'Administrative Security & Audit Logs',
    subtitle: 'Immutable record of changes made by administrators for accountability.',
  },
};

export const Header: React.FC<HeaderProps> = ({ currentTab, isLive = false }) => {
  const info = TAB_TITLES[currentTab] || {
    title: 'Admin Control Panel',
    subtitle: 'City Revival AG Church',
  };

  return (
    <header className="bg-[#FAF7F0] border-b border-[#E5DEC9] px-8 py-5 flex items-center justify-between">
      <div>
        <h2 className="text-xl font-bold text-[#8F2638] tracking-tight">{info.title}</h2>
        <p className="text-xs text-[#77736F] mt-0.5">{info.subtitle}</p>
      </div>

      <div className="flex items-center space-x-3">
        {isLive ? (
          <span className="flex items-center space-x-1.5 px-3 py-1 rounded-full text-xs font-bold bg-red-100 text-red-700 animate-pulse border border-red-300">
            <Radio size={14} className="text-red-600" />
            <span>LIVE STREAM ACTIVE</span>
          </span>
        ) : (
          <span className="flex items-center space-x-1.5 px-3 py-1 rounded-full text-xs font-medium bg-[#EAE2D0] text-[#77736F]">
            <Radio size={14} className="text-[#77736F]" />
            <span>STREAM OFFLINE</span>
          </span>
        )}

        <div className="flex items-center space-x-1 text-xs text-[#263B63] bg-blue-50 border border-blue-200 px-3 py-1 rounded-full font-medium">
          <ShieldAlert size={14} />
          <span>RLS Active</span>
        </div>
      </div>
    </header>
  );
};
