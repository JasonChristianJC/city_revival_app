import React from 'react';
import { Sidebar } from './Sidebar';
import type { TabKey } from './Sidebar';
import { Header } from './Header';

interface LayoutProps {
  currentTab: TabKey;
  onSelectTab: (tab: TabKey) => void;
  children: React.ReactNode;
  isLive?: boolean;
}

export const Layout: React.FC<LayoutProps> = ({
  currentTab,
  onSelectTab,
  children,
  isLive = false,
}) => {
  return (
    <div className="flex h-screen bg-[#FAF7F0] overflow-hidden text-[#292929]">
      {/* Fixed Sidebar */}
      <Sidebar currentTab={currentTab} onSelectTab={onSelectTab} />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col h-full overflow-hidden">
        <Header currentTab={currentTab} isLive={isLive} />
        <main className="flex-1 overflow-y-auto p-8 bg-[#FAF7F0]/60">
          <div className="max-w-6xl mx-auto">{children}</div>
        </main>
      </div>
    </div>
  );
};
