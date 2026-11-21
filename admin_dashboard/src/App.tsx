import React, { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { Layout } from './components/Layout';
import type { TabKey } from './components/Sidebar';
import { LoginScreen } from './pages/LoginScreen';
import { DashboardOverview } from './pages/DashboardOverview';
import { DailyVerseManager } from './pages/DailyVerseManager';
import { AnnouncementManager } from './pages/AnnouncementManager';
import { SermonManager } from './pages/SermonManager';
import { LiveStreamManager } from './pages/LiveStreamManager';
import { MagazineManager } from './pages/MagazineManager';
import { GivingManager } from './pages/GivingManager';
import { PrayerRequestManager } from './pages/PrayerRequestManager';
import { NotificationManager } from './pages/NotificationManager';
import { AuditLogViewer } from './pages/AuditLogViewer';

const DashboardContent: React.FC = () => {
  const { user, loading } = useAuth();
  const [currentTab, setCurrentTab] = useState<TabKey>('overview');
  const [isLive, setIsLive] = useState(false);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#FAF7F0] flex items-center justify-center">
        <div className="flex flex-col items-center space-y-3">
          <img
            src="/church_logo.png"
            alt="City Revival AG Church"
            className="w-14 h-14 rounded-full object-contain bg-white border border-[#E5DEC9] shadow-sm animate-pulse"
          />
          <p className="text-xs font-semibold text-[#8F2638] tracking-widest uppercase">
            Loading Control Panel...
          </p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <LoginScreen />;
  }

  const renderTab = () => {
    switch (currentTab) {
      case 'overview':
        return (
          <DashboardOverview
            onNavigate={(tab) => setCurrentTab(tab)}
            isLive={isLive}
            onToggleLive={() => setIsLive(!isLive)}
          />
        );
      case 'daily_verse':
        return <DailyVerseManager />;
      case 'announcements':
        return <AnnouncementManager />;
      case 'sermons':
        return <SermonManager />;
      case 'live_stream':
        return <LiveStreamManager isLive={isLive} setIsLive={setIsLive} />;
      case 'magazines':
        return <MagazineManager />;
      case 'giving':
        return <GivingManager />;
      case 'prayer_requests':
        return <PrayerRequestManager />;
      case 'notifications':
        return <NotificationManager />;
      case 'audit_logs':
        return <AuditLogViewer />;
      default:
        return (
          <DashboardOverview
            onNavigate={(tab) => setCurrentTab(tab)}
            isLive={isLive}
            onToggleLive={() => setIsLive(!isLive)}
          />
        );
    }
  };

  return (
    <Layout currentTab={currentTab} onSelectTab={setCurrentTab} isLive={isLive}>
      {renderTab()}
    </Layout>
  );
};

export default function App() {
  return (
    <AuthProvider>
      <DashboardContent />
    </AuthProvider>
  );
}
