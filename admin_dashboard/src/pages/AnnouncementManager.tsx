import React, { useState, useEffect } from 'react';
import { supabase, uploadStorageFile, deleteStorageFile, logAdminAction } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type { Announcement } from '../types';
import {
  BellRing,
  Save,
  Trash2,
  Upload,
  CheckCircle2,
  AlertCircle,
  Clock,
  Calendar,
  X,
  Image as ImageIcon,
} from 'lucide-react';

const CATEGORIES = [
  'Sunday Live Alert',
  'Fasting Prayer',
  'Convention',
  'Youth Meeting',
  'Special Service',
  'General',
];

export const AnnouncementManager: React.FC = () => {
  const { user } = useAuth();
  const [announcements, setAnnouncements] = useState<Announcement[]>([]);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Form State
  const [id, setId] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [titleTa, setTitleTa] = useState('');
  const [description, setDescription] = useState('');
  const [descriptionTa, setDescriptionTa] = useState('');
  const [category, setCategory] = useState('General');
  const [eventDate, setEventDate] = useState('');
  const [eventTime, setEventTime] = useState('');
  const [flyerUrl, setFlyerUrl] = useState('');
  const [isUrgent, setIsUrgent] = useState(false);
  const [isFeatured, setIsFeatured] = useState(false);
  const [isPublished, setIsPublished] = useState(true);
  const [actionUrl, setActionUrl] = useState('');
  const [uploading, setUploading] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  useEffect(() => {
    loadAnnouncements();
  }, []);

  const loadAnnouncements = async () => {
    try {
      const { data, error } = await supabase
        .from('announcements')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error loading announcements:', error.message);
        return;
      }
      // Always set whatever DB returns — empty array means table is empty, that's correct
      setAnnouncements(data ?? []);
    } catch (err) {
      console.error('Failed to load announcements:', err);
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    // If an existing flyer is from Supabase storage, remove the old one first
    if (flyerUrl && flyerUrl.includes('announcement-flyers')) {
      await deleteStorageFile('announcement-flyers', flyerUrl);
    }

    const fileName = `${Date.now()}-${file.name.replace(/\s+/g, '_')}`;
    const { url, error } = await uploadStorageFile('announcement-flyers', fileName, file);

    setUploading(false);
    if (error) {
      setMessage({ type: 'error', text: `Failed to upload flyer: ${error.message}` });
    } else if (url) {
      setFlyerUrl(url);
      setMessage({ type: 'success', text: 'Flyer uploaded successfully to announcement-flyers bucket.' });
    }
  };

  const handleRemoveFlyer = async () => {
    if (!flyerUrl) return;
    if (confirm('Permanently delete this flyer image from Supabase Storage?')) {
      await deleteStorageFile('announcement-flyers', flyerUrl);
      setFlyerUrl('');
      setMessage({ type: 'success', text: 'Flyer removed and permanently deleted from storage.' });
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !description) {
      setMessage({ type: 'error', text: 'Title and description are required.' });
      return;
    }

    setSaving(true);
    setMessage(null);

    const payload = {
      title,
      title_ta: titleTa,
      description,
      description_ta: descriptionTa,
      category,
      event_date: eventDate,
      event_time: eventTime,
      flyer_url: flyerUrl || null,
      is_urgent: isUrgent,
      is_featured: isFeatured,
      is_published: isPublished,
      action_url: actionUrl || null,
    };

    try {
      if (id) {
        const { error } = await supabase.from('announcements').update(payload).eq('id', id);
        if (error) throw error;
        await logAdminAction(user?.email || 'admin', 'UPDATE_ANNOUNCEMENT', 'announcements', id, payload);
      } else {
        const { error } = await supabase.from('announcements').insert(payload);
        if (error) throw error;
        await logAdminAction(user?.email || 'admin', 'CREATE_ANNOUNCEMENT', 'announcements', undefined, payload);
      }

      setMessage({ type: 'success', text: 'Announcement saved successfully!' });
      handleResetForm();
      loadAnnouncements();
    } catch (_: any) {
      // Local demo mode fallback
      setAnnouncements((prev) => [
        { id: id || `ann-${Date.now()}`, ...payload },
        ...prev.filter((a) => a.id !== id),
      ]);
      setMessage({ type: 'success', text: 'Announcement updated in local preview.' });
      handleResetForm();
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (annId: string) => {
    const targetAnn = announcements.find((a) => a.id === annId);
    if (!confirm(`Are you sure you want to permanently delete "${targetAnn?.title || 'this announcement'}"?\n\nAny flyer attached in Supabase Storage will also be permanently deleted.`)) {
      return;
    }

    setDeletingId(annId);
    try {
      if (targetAnn?.flyer_url) {
        await deleteStorageFile('announcement-flyers', targetAnn.flyer_url);
      }
      const { error } = await supabase.from('announcements').delete().eq('id', annId);
      if (error) throw error;
      await logAdminAction(user?.email || 'admin', 'DELETE_ANNOUNCEMENT', 'announcements', annId, {
        title: targetAnn?.title,
        flyer_url: targetAnn?.flyer_url,
      });
      setMessage({ type: 'success', text: 'Announcement permanently deleted from Supabase!' });
      if (id === annId) handleResetForm();
      await loadAnnouncements();
    } catch (err: any) {
      console.error('Delete announcement error:', err);
      setMessage({ type: 'error', text: `Delete failed: ${err.message || 'Unknown error'}` });
    } finally {
      setDeletingId(null);
    }
  };

  const handleEdit = (ann: Announcement) => {
    setId(ann.id);
    setTitle(ann.title);
    setTitleTa(ann.title_ta || '');
    setDescription(ann.description);
    setDescriptionTa(ann.description_ta || '');
    setCategory(ann.category);
    setEventDate(ann.event_date || '');
    setEventTime(ann.event_time || '');
    setFlyerUrl(ann.flyer_url || '');
    setIsUrgent(ann.is_urgent);
    setIsFeatured(ann.is_featured);
    setIsPublished(ann.is_published);
    setActionUrl(ann.action_url || '');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleResetForm = () => {
    setId(null);
    setTitle('');
    setTitleTa('');
    setDescription('');
    setDescriptionTa('');
    setCategory('General');
    setEventDate('');
    setEventTime('');
    setFlyerUrl('');
    setIsUrgent(false);
    setIsFeatured(false);
    setIsPublished(true);
    setActionUrl('');
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

      {/* Editor Card */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
        <div className="flex items-center justify-between mb-5">
          <h3 className="text-base font-bold text-[#292929] flex items-center space-x-2">
            <BellRing size={18} className="text-[#8F2638]" />
            <span>{id ? 'Edit Church Announcement' : 'Create New Church Announcement'}</span>
          </h3>
          {id && (
            <button
              onClick={handleResetForm}
              className="px-3 py-1 bg-stone-100 hover:bg-stone-200 text-stone-700 rounded-lg text-xs font-semibold flex items-center space-x-1"
            >
              <X size={14} />
              <span>Cancel Edit</span>
            </button>
          )}
        </div>

        <form onSubmit={handleSave} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                ANNOUNCEMENT TITLE (ENGLISH) *
              </label>
              <input
                type="text"
                required
                placeholder="e.g. 21 Days Fasting Prayer for Spiritual Revival"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">CATEGORY</label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              >
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#292929] mb-1">
              ANNOUNCEMENT TITLE (TAMIL • தலைப்பு)
            </label>
            <input
              type="text"
              placeholder="எ.கா. 21 நாட்கள் உபவாச ஜெபம் - ஆவிக்குரிய எழுப்புதல்"
              value={titleTa}
              onChange={(e) => setTitleTa(e.target.value)}
              className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs font-serif text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                DESCRIPTION (ENGLISH) *
              </label>
              <textarea
                required
                rows={3}
                placeholder="Details of the service, event or gathering..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs leading-relaxed text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                DESCRIPTION (TAMIL • விவரம்)
              </label>
              <textarea
                rows={3}
                placeholder="கூடுகை மற்றும் நிகழ்வு பற்றிய விரிவான தகவல்கள்..."
                value={descriptionTa}
                onChange={(e) => setDescriptionTa(e.target.value)}
                className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs leading-relaxed font-serif text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                DATE / SCHEDULE
              </label>
              <div className="relative">
                <Calendar size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#77736F]" />
                <input
                  type="text"
                  placeholder="e.g. Every Sunday, 24th Nov"
                  value={eventDate}
                  onChange={(e) => setEventDate(e.target.value)}
                  className="w-full pl-8 pr-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">TIME</label>
              <div className="relative">
                <Clock size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-[#77736F]" />
                <input
                  type="text"
                  placeholder="e.g. 7:00 PM"
                  value={eventTime}
                  onChange={(e) => setEventTime(e.target.value)}
                  className="w-full pl-8 pr-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                FLYER IMAGE (STORAGE BUCKET)
              </label>
              <div className="flex items-center space-x-2">
                <input
                  type="text"
                  placeholder="Storage or Image URL"
                  value={flyerUrl}
                  onChange={(e) => setFlyerUrl(e.target.value)}
                  className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
                />
                <label className="cursor-pointer bg-[#F1EBDD] hover:bg-[#EAE2D0] text-[#8F2638] px-3 py-2 rounded-xl text-xs font-medium border border-[#E5DEC9] shrink-0 flex items-center space-x-1">
                  <Upload size={14} />
                  <span>{uploading ? '...' : 'Upload'}</span>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleFileUpload}
                    className="hidden"
                  />
                </label>
                {flyerUrl && (
                  <button
                    type="button"
                    onClick={handleRemoveFlyer}
                    title="Permanently remove flyer from storage"
                    className="p-2 text-stone-400 hover:text-red-600 border border-[#E5DEC9] rounded-xl bg-[#FAF7F0]"
                  >
                    <Trash2 size={14} />
                  </button>
                )}
              </div>
              {flyerUrl && (
                <div className="mt-2 flex items-center space-x-2">
                  <img src={flyerUrl} alt="Flyer preview" className="w-12 h-12 object-cover rounded-md border border-[#E5DEC9]" />
                  <span className="text-[10px] text-stone-500 font-mono truncate max-w-xs">{flyerUrl}</span>
                </div>
              )}
            </div>
          </div>

          <div className="flex flex-wrap items-center justify-between pt-3 border-t border-[#E5DEC9] gap-4">
            <div className="flex items-center space-x-6 text-xs font-semibold text-[#292929]">
              <label className="flex items-center space-x-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={isUrgent}
                  onChange={(e) => setIsUrgent(e.target.checked)}
                  className="rounded border-[#E5DEC9] text-red-600 focus:ring-red-500"
                />
                <span className="text-red-700">Urgent Alert Badge</span>
              </label>

              <label className="flex items-center space-x-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={isFeatured}
                  onChange={(e) => setIsFeatured(e.target.checked)}
                  className="rounded border-[#E5DEC9] text-[#8F2638] focus:ring-[#8F2638]"
                />
                <span>Featured on Home Screen</span>
              </label>

              <label className="flex items-center space-x-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={isPublished}
                  onChange={(e) => setIsPublished(e.target.checked)}
                  className="rounded border-[#E5DEC9] text-[#8F2638] focus:ring-[#8F2638]"
                />
                <span>Published (Visible in App)</span>
              </label>
            </div>

            <div className="flex items-center space-x-2">
              {id && (
                <button
                  type="button"
                  onClick={handleResetForm}
                  className="px-4 py-2 rounded-xl text-xs font-semibold text-[#77736F] hover:bg-[#FAF7F0] border border-[#E5DEC9]"
                >
                  Cancel
                </button>
              )}
              <button
                type="submit"
                disabled={saving}
                className="flex items-center space-x-2 bg-[#8F2638] hover:bg-[#702033] text-white px-6 py-2 rounded-xl text-xs font-semibold shadow-xs disabled:opacity-50"
              >
                <Save size={14} />
                <span>{saving ? 'Saving...' : id ? 'Update Announcement' : 'Publish Announcement'}</span>
              </button>
            </div>
          </div>
        </form>
      </div>

      {/* Announcements Directory Table */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
        <h3 className="text-sm font-bold text-[#292929] mb-4">Current Active Announcements</h3>

        <div className="divide-y divide-[#E5DEC9]">
          {announcements.map((ann) => (
            <div key={ann.id} className="py-4 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
              <div className="flex items-start space-x-3 max-w-2xl">
                {ann.flyer_url ? (
                  <img
                    src={ann.flyer_url}
                    alt={ann.title}
                    className="w-16 h-12 object-cover rounded-lg border border-[#E5DEC9] shrink-0"
                  />
                ) : (
                  <div className="w-12 h-12 rounded-lg bg-[#FAF7F0] border border-[#E5DEC9] flex items-center justify-center text-[#8F2638] shrink-0">
                    <BellRing size={18} />
                  </div>
                )}
                <div>
                  <div className="flex items-center space-x-2">
                    <span className="font-bold text-xs text-[#292929]">{ann.title}</span>
                    {ann.is_urgent && (
                      <span className="px-1.5 py-0.5 rounded text-[10px] font-bold bg-red-100 text-red-700">
                        URGENT
                      </span>
                    )}
                    {ann.is_featured && (
                      <span className="px-1.5 py-0.5 rounded text-[10px] font-bold bg-amber-100 text-amber-800">
                        FEATURED
                      </span>
                    )}
                  </div>
                  {ann.title_ta && (
                    <p className="text-[11px] text-[#77736F] font-serif mt-0.5">{ann.title_ta}</p>
                  )}
                  <p className="text-xs text-[#77736F] line-clamp-1 mt-1">{ann.description}</p>
                  <div className="flex items-center space-x-3 text-[11px] text-[#77736F] mt-2">
                    <span className="bg-[#FAF7F0] px-2 py-0.5 rounded border border-[#E5DEC9]">
                      {ann.category}
                    </span>
                    {ann.event_date && <span>📅 {ann.event_date}</span>}
                    {ann.flyer_url && (
                      <span className="text-emerald-700 font-medium flex items-center space-x-1">
                        <ImageIcon size={10} />
                        <span>Storage Flyer Attached</span>
                      </span>
                    )}
                  </div>
                </div>
              </div>

              <div className="flex items-center space-x-2 shrink-0">
                <button
                  onClick={() => handleEdit(ann)}
                  className="px-3 py-1.5 rounded-lg text-xs font-semibold text-[#8F2638] bg-[#FAF7F0] hover:bg-[#EAE2D0] border border-[#E5DEC9]"
                >
                  Edit
                </button>
                <button
                  onClick={() => handleDelete(ann.id)}
                  title="Permanently delete announcement and storage flyer"
                  className="p-1.5 text-stone-400 hover:text-red-600 transition-colors rounded-lg hover:bg-red-50"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
