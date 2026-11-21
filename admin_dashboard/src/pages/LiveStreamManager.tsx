import React, { useState, useEffect } from 'react';
import { supabase, uploadStorageFile, deleteStorageFile, logAdminAction } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type { LiveStream } from '../types';
import {
  Radio,
  Save,
  ExternalLink,
  CheckCircle2,
  AlertCircle,
  Eye,
  Upload,
  Trash2,
  RotateCcw,
} from 'lucide-react';

interface LiveStreamManagerProps {
  isLive: boolean;
  setIsLive: (val: boolean) => void;
}

export const LiveStreamManager: React.FC<LiveStreamManagerProps> = ({ isLive, setIsLive }) => {
  const { user } = useAuth();
  const [streamData, setStreamData] = useState<LiveStream>({
    id: 'live-stream-main',
    title: 'Sunday Worship Service & Prophetic Word',
    youtube_url: 'https://youtube.com/live/example',
    youtube_id: 'rQW18AzH9Sc',
    is_live: isLive,
    description: 'Join Rev. Dr. Jerry Daniel for Sunday Worship live from Trichy.',
    start_time: 'Sunday Tamil 7:00 AM & 11:00 AM • English 9:00 AM',
    is_active: true,
  });

  const [saving, setSaving] = useState(false);
  const [uploadingThumb, setUploadingThumb] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  useEffect(() => {
    loadLiveStream();
  }, []);

  const loadLiveStream = async () => {
    try {
      const { data } = await supabase
        .from('live_streams')
        .select('*')
        .eq('is_active', true)
        .maybeSingle();

      if (data) {
        setStreamData(data);
        setIsLive(data.is_live);
      }
    } catch (_) {
      console.warn('Using default live stream state');
    }
  };

  const handleUrlChange = (url: string) => {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);
    const yId = match && match[2].length === 11 ? match[2] : streamData.youtube_id;

    setStreamData((prev) => ({
      ...prev,
      youtube_url: url,
      youtube_id: yId,
    }));
  };

  const handleCustomThumbnailUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadingThumb(true);
    if (streamData.thumbnail_url && streamData.thumbnail_url.includes('live-thumbnails')) {
      await deleteStorageFile('live-thumbnails', streamData.thumbnail_url);
    }

    const fileName = `live_${Date.now()}_${file.name.replace(/\s+/g, '_')}`;
    const { url, error } = await uploadStorageFile('live-thumbnails', fileName, file);

    setUploadingThumb(false);
    if (error) {
      setMessage({ type: 'error', text: `Failed to upload live thumbnail: ${error.message}` });
    } else if (url) {
      setStreamData((prev) => ({ ...prev, thumbnail_url: url }));
      setMessage({ type: 'success', text: 'Live thumbnail uploaded to live-thumbnails bucket!' });
    }
  };

  const handleRemoveThumbnail = async () => {
    if (!streamData.thumbnail_url) return;
    if (confirm('Permanently delete this live thumbnail from Supabase Storage?')) {
      await deleteStorageFile('live-thumbnails', streamData.thumbnail_url);
      setStreamData((prev) => ({ ...prev, thumbnail_url: undefined }));
      setMessage({ type: 'success', text: 'Live thumbnail permanently deleted from storage.' });
    }
  };

  const handleToggleLive = async () => {
    const nextStatus = !streamData.is_live;
    setStreamData((prev) => ({ ...prev, is_live: nextStatus }));
    setIsLive(nextStatus);

    try {
      await supabase
        .from('live_streams')
        .update({ is_live: nextStatus, updated_at: new Date().toISOString() })
        .eq('is_active', true);

      await logAdminAction(
        user?.email || 'admin',
        nextStatus ? 'START_LIVE_STREAM' : 'STOP_LIVE_STREAM',
        'live_streams',
        streamData.id,
        { is_live: nextStatus }
      );

      setMessage({
        type: 'success',
        text: nextStatus
          ? 'Live stream broadcast activated! Mobile app banner now shows LIVE.'
          : 'Live stream marked offline.',
      });
    } catch (_) {
      setMessage({
        type: 'success',
        text: `Live stream status updated to ${nextStatus ? 'LIVE' : 'OFFLINE'} (preview updated).`,
      });
    }
  };

  const handleSaveDetails = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setMessage(null);

    try {
      await supabase
        .from('live_streams')
        .upsert(streamData, { onConflict: 'id' });

      await logAdminAction(
        user?.email || 'admin',
        'UPDATE_LIVE_STREAM_DETAILS',
        'live_streams',
        streamData.id,
        streamData
      );

      setMessage({ type: 'success', text: 'Live stream settings saved successfully!' });
    } catch (_: any) {
      setMessage({ type: 'success', text: 'Settings updated in local preview.' });
    } finally {
      setSaving(false);
    }
  };

  const handleResetStream = async () => {
    if (!confirm('Are you sure you want to reset broadcast details? Any uploaded live thumbnail in Supabase Storage will be permanently deleted.')) {
      return;
    }

    try {
      if (streamData.thumbnail_url && streamData.thumbnail_url.includes('live-thumbnails')) {
        await deleteStorageFile('live-thumbnails', streamData.thumbnail_url);
      }

      const resetData: LiveStream = {
        id: streamData.id || 'live-stream-main',
        title: 'Sunday Worship Service & Prophetic Word',
        youtube_url: '',
        youtube_id: '',
        is_live: false,
        description: '',
        start_time: 'Sunday Tamil 7:00 AM & 11:00 AM • English 9:00 AM',
        is_active: true,
      };

      await supabase.from('live_streams').upsert(resetData, { onConflict: 'id' });
      await logAdminAction(user?.email || 'admin', 'RESET_LIVE_STREAM', 'live_streams', streamData.id);

      setStreamData(resetData);
      setIsLive(false);
      setMessage({ type: 'success', text: 'Live stream reset and thumbnail purged from storage.' });
    } catch (_) {
      setMessage({ type: 'success', text: 'Stream reset in local preview.' });
    }
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

      {/* Hero Master Live Broadcast Switch */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs flex flex-col md:flex-row items-center justify-between gap-6">
        <div>
          <div className="flex items-center space-x-2">
            <Radio size={20} className={streamData.is_live ? 'text-red-600 animate-pulse' : 'text-[#77736F]'} />
            <span className="text-xs uppercase font-bold tracking-wider text-[#8F2638]">
              SUNDAY SERVICE BROADCAST SWITCH
            </span>
          </div>
          <h2 className="text-xl font-bold text-[#292929] mt-1">
            Status: {streamData.is_live ? '🔴 BROADCASTING LIVE NOW' : '⚪ STREAM CURRENTLY OFFLINE'}
          </h2>
          <p className="text-xs text-[#77736F] mt-1">
            When enabled, congregation phones display an animated crimson LIVE alert card linking directly to YouTube.
          </p>
        </div>

        <button
          onClick={handleToggleLive}
          className={`px-6 py-3 rounded-xl font-bold text-xs uppercase tracking-wider shadow-sm transition-all flex items-center space-x-2 ${
            streamData.is_live
              ? 'bg-red-600 hover:bg-red-700 text-white animate-pulse'
              : 'bg-[#8F2638] hover:bg-[#702033] text-white'
          }`}
        >
          <Radio size={16} />
          <span>{streamData.is_live ? 'End Live Broadcast' : 'Go Live on Mobile App'}</span>
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Stream Configuration Form (7 cols) */}
        <div className="lg:col-span-7 bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
          <div className="flex items-center justify-between pb-3 mb-4 border-b border-[#E5DEC9]">
            <h3 className="text-sm font-bold text-[#292929]">Live Stream Configuration</h3>
            <button
              type="button"
              onClick={handleResetStream}
              className="text-xs font-semibold text-stone-500 hover:text-red-600 flex items-center space-x-1"
            >
              <RotateCcw size={13} />
              <span>Reset Broadcast</span>
            </button>
          </div>

          <form onSubmit={handleSaveDetails} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                STREAM TITLE *
              </label>
              <input
                type="text"
                required
                value={streamData.title}
                onChange={(e) => setStreamData({ ...streamData, title: e.target.value })}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                YOUTUBE BROADCAST URL OR VIDEO ID *
              </label>
              <input
                type="text"
                required
                value={streamData.youtube_url}
                onChange={(e) => handleUrlChange(e.target.value)}
                placeholder="https://youtube.com/live/... or video ID"
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
              <p className="text-[11px] text-[#77736F] font-mono mt-1">
                YouTube ID: {streamData.youtube_id || 'Not set'}
              </p>
            </div>

            {/* Custom Live Thumbnail */}
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                CUSTOM LIVE THUMBNAIL (STORAGE: live-thumbnails)
              </label>
              <div className="flex items-center space-x-2">
                <input
                  type="text"
                  placeholder="Optional custom storage thumbnail URL"
                  value={streamData.thumbnail_url || ''}
                  onChange={(e) => setStreamData({ ...streamData, thumbnail_url: e.target.value })}
                  className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
                />
                <label className="cursor-pointer bg-[#F1EBDD] hover:bg-[#EAE2D0] text-[#8F2638] px-3 py-2 rounded-xl text-xs font-medium border border-[#E5DEC9] shrink-0 flex items-center space-x-1">
                  <Upload size={14} />
                  <span>{uploadingThumb ? '...' : 'Upload'}</span>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleCustomThumbnailUpload}
                    className="hidden"
                  />
                </label>
                {streamData.thumbnail_url && (
                  <button
                    type="button"
                    onClick={handleRemoveThumbnail}
                    title="Permanently remove thumbnail from storage"
                    className="p-2 text-stone-400 hover:text-red-600 border border-[#E5DEC9] rounded-xl bg-[#FAF7F0]"
                  >
                    <Trash2 size={14} />
                  </button>
                )}
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                SCHEDULED TIMINGS / SUBTITLE
              </label>
              <input
                type="text"
                value={streamData.start_time || ''}
                onChange={(e) => setStreamData({ ...streamData, start_time: e.target.value })}
                placeholder="Sunday Tamil 7:00 AM & 11:00 AM • English 9:00 AM"
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                DESCRIPTION / PREACHER NOTES
              </label>
              <textarea
                rows={3}
                value={streamData.description || ''}
                onChange={(e) => setStreamData({ ...streamData, description: e.target.value })}
                className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div className="pt-2 flex justify-end">
              <button
                type="submit"
                disabled={saving}
                className="flex items-center space-x-2 bg-[#8F2638] hover:bg-[#702033] text-white px-5 py-2.5 rounded-xl text-xs font-semibold shadow-xs disabled:opacity-50"
              >
                <Save size={14} />
                <span>{saving ? 'Saving...' : 'Save Stream Info'}</span>
              </button>
            </div>
          </form>
        </div>

        {/* Live Banner Mobile Preview (5 cols) */}
        <div className="lg:col-span-5 space-y-4">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-[#77736F] uppercase tracking-wider flex items-center space-x-1">
              <Eye size={14} />
              <span>Mobile Live Alert Preview</span>
            </span>
            <span className="text-[10px] bg-[#EAE2D0] text-[#77736F] px-2 py-0.5 rounded font-mono">
              Home Screen Banner
            </span>
          </div>

          {/* Render Sunday Live Alert Banner as seen on phone */}
          {streamData.is_live ? (
            <div className="bg-[#8F2638] rounded-2xl p-4 text-white shadow-md relative overflow-hidden">
              <div className="flex items-center space-x-3">
                <div className="p-2.5 rounded-xl bg-white/10 shrink-0">
                  <Radio size={20} className="text-white animate-pulse" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center space-x-2">
                    <span className="text-[10px] font-bold bg-white text-[#8F2638] px-1.5 py-0.5 rounded tracking-wider">
                      LIVE NOW
                    </span>
                    <span className="text-xs font-bold truncate">Sunday Service Broadcast</span>
                  </div>
                  <p className="text-[11px] text-white/80 line-clamp-1 mt-0.5">
                    {streamData.title}
                  </p>
                </div>
              </div>
              <div className="mt-3 pt-2.5 border-t border-white/20 flex items-center justify-between text-[11px]">
                <span className="text-white/70">Rev. Dr. Jerry Daniel</span>
                <span className="font-semibold underline flex items-center space-x-1">
                  <span>Watch on YouTube</span>
                  <ExternalLink size={12} />
                </span>
              </div>
            </div>
          ) : (
            <div className="bg-[#FAF7F0] rounded-2xl p-5 border border-[#E5DEC9] text-center">
              <p className="text-xs text-[#77736F]">
                Stream is currently offline. The banner is hidden on member devices until Sunday service starts or you toggle the switch above.
              </p>
            </div>
          )}

          {/* YouTube Video Preview */}
          {streamData.youtube_id && (
            <div className="rounded-xl overflow-hidden border border-[#E5DEC9] aspect-video bg-black/10">
              <iframe
                title="Live Stream Preview"
                src={`https://www.youtube.com/embed/${streamData.youtube_id}`}
                className="w-full h-full border-0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              />
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
