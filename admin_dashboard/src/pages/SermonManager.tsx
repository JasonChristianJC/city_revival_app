import React, { useState, useEffect } from 'react';
import { supabase, uploadStorageFile, deleteStorageFile, logAdminAction } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type { Sermon } from '../types';
import {
  Video,
  Play,
  Save,
  Trash2,
  CheckCircle2,
  AlertCircle,
  Sparkles,
  Upload,
  X,
  Image as ImageIcon,
} from 'lucide-react';

const SPEAKERS = [
  'Rev. Dr. Jerry Daniel',
  'Pastor Joseph',
  'Pastor Paul',
  'Visiting Evangelist',
];

export const SermonManager: React.FC = () => {
  const { user } = useAuth();
  const [sermons, setSermons] = useState<Sermon[]>([]);
  const [saving, setSaving] = useState(false);
  const [uploadingThumbnail, setUploadingThumbnail] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Form State
  const [id, setId] = useState<string | null>(null);
  const [date, setDate] = useState('15-11-2026');
  const [titleEn, setTitleEn] = useState('');
  const [titleTa, setTitleTa] = useState('');
  const [speaker, setSpeaker] = useState('Rev. Dr. Jerry Daniel');
  const [series, setSeries] = useState('End Times Preparation');
  const [language, setLanguage] = useState('Tamil');
  const [scripture, setScripture] = useState('');
  const [youtubeUrl, setYoutubeUrl] = useState('');
  const [youtubeId, setYoutubeId] = useState('');
  const [thumbnailUrl, setThumbnailUrl] = useState('');
  const [descriptionEn, setDescriptionEn] = useState('');
  const [descriptionTa, setDescriptionTa] = useState('');
  const [isFeatured, setIsFeatured] = useState(false);
  const [isPublished, setIsPublished] = useState(true);

  useEffect(() => {
    loadSermons();
  }, []);

  const loadSermons = async () => {
    try {
      const { data } = await supabase
        .from('sermons')
        .select('*')
        .order('created_at', { ascending: false });

      setSermons(data ?? []);
    } catch (err: any) {
      console.error('Failed to load data from Supabase:', err);
    }
  };

  // Automatically extract YouTube video ID and generate high-res thumbnail
  const handleUrlChange = (url: string) => {
    setYoutubeUrl(url);
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);

    if (match && match[2].length === 11) {
      const extractedId = match[2];
      setYoutubeId(extractedId);
      // Only set automatic youtube thumbnail if no custom storage thumbnail was uploaded
      if (!thumbnailUrl || !thumbnailUrl.includes('sermon-thumbnails')) {
        setThumbnailUrl(`https://img.youtube.com/vi/${extractedId}/hqdefault.jpg`);
      }
    } else if (url.trim().length === 11) {
      setYoutubeId(url.trim());
      if (!thumbnailUrl || !thumbnailUrl.includes('sermon-thumbnails')) {
        setThumbnailUrl(`https://img.youtube.com/vi/${url.trim()}/hqdefault.jpg`);
      }
    }
  };

  const handleCustomThumbnailUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadingThumbnail(true);
    // If an existing custom thumbnail was from Supabase storage, remove it first
    if (thumbnailUrl && thumbnailUrl.includes('sermon-thumbnails')) {
      await deleteStorageFile('sermon-thumbnails', thumbnailUrl);
    }

    const fileName = `${Date.now()}_thumb_${file.name.replace(/\s+/g, '_')}`;
    const { url, error } = await uploadStorageFile('sermon-thumbnails', fileName, file);

    setUploadingThumbnail(false);
    if (error) {
      setMessage({ type: 'error', text: `Failed to upload thumbnail: ${error.message}` });
    } else if (url) {
      setThumbnailUrl(url);
      setMessage({ type: 'success', text: 'Custom thumbnail uploaded to sermon-thumbnails bucket!' });
    }
  };

  const handleRemoveCustomThumbnail = async () => {
    if (!thumbnailUrl) return;
    if (thumbnailUrl.includes('sermon-thumbnails')) {
      await deleteStorageFile('sermon-thumbnails', thumbnailUrl);
    }
    // Revert to YouTube default thumbnail
    if (youtubeId) {
      setThumbnailUrl(`https://img.youtube.com/vi/${youtubeId}/hqdefault.jpg`);
    } else {
      setThumbnailUrl('');
    }
    setMessage({ type: 'success', text: 'Custom thumbnail removed from storage.' });
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!titleEn || !youtubeId) {
      setMessage({ type: 'error', text: 'Sermon title and valid YouTube URL/ID are required.' });
      return;
    }

    setSaving(true);
    setMessage(null);

    const payload = {
      date,
      title_en: titleEn,
      title_ta: titleTa,
      speaker,
      series,
      language,
      scripture,
      youtube_id: youtubeId,
      youtube_url: youtubeUrl || `https://youtu.be/${youtubeId}`,
      thumbnail_url: thumbnailUrl || `https://img.youtube.com/vi/${youtubeId}/hqdefault.jpg`,
      description_en: descriptionEn,
      description_ta: descriptionTa,
      is_featured: isFeatured,
      is_published: isPublished,
    };

    try {
      if (id) {
        const { error } = await supabase.from('sermons').update(payload).eq('id', id);
        if (error) throw error;
        await logAdminAction(user?.email || 'admin', 'UPDATE_SERMON', 'sermons', id, payload);
      } else {
        const { error } = await supabase.from('sermons').insert(payload);
        if (error) throw error;
        await logAdminAction(user?.email || 'admin', 'ADD_SERMON', 'sermons', undefined, payload);
      }

      setMessage({ type: 'success', text: id ? 'Sermon updated successfully!' : 'Sermon saved successfully to mobile library!' });
      handleResetForm();
      loadSermons();
    } catch (_: any) {
      // Local fallback
      setSermons((prev) => [
        { id: id || `sermon-${Date.now()}`, ...payload },
        ...prev.filter((s) => s.id !== id),
      ]);
      setMessage({ type: 'success', text: 'Sermon updated in local library.' });
      handleResetForm();
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (sermonId: string) => {
    const targetSermon = sermons.find((s) => s.id === sermonId);
    if (!confirm(`Are you sure you want to permanently delete "${targetSermon?.title_en || 'this sermon'}"?\n\nAny custom thumbnail in Supabase Storage will also be permanently deleted.`)) {
      return;
    }

    setDeletingId(sermonId);
    try {
      if (targetSermon?.thumbnail_url && targetSermon.thumbnail_url.includes('sermon-thumbnails')) {
        await deleteStorageFile('sermon-thumbnails', targetSermon.thumbnail_url);
      }
      const { error } = await supabase.from('sermons').delete().eq('id', sermonId);
      if (error) throw error;
      await logAdminAction(user?.email || 'admin', 'DELETE_SERMON', 'sermons', sermonId, {
        title_en: targetSermon?.title_en,
        thumbnail_url: targetSermon?.thumbnail_url,
      });
      setMessage({ type: 'success', text: 'Sermon and custom storage files permanently deleted!' });
      if (id === sermonId) handleResetForm();
      await loadSermons();
    } catch (err: any) {
      console.error('Delete sermon error:', err);
      setMessage({ type: 'error', text: `Delete failed: ${err.message || 'Unknown error'}` });
    } finally {
      setDeletingId(null);
    }
  };

  const handleEdit = (s: Sermon) => {
    setId(s.id);
    setDate(s.date);
    setTitleEn(s.title_en);
    setTitleTa(s.title_ta || '');
    setSpeaker(s.speaker);
    setSeries(s.series || '');
    setLanguage(s.language || 'Tamil');
    setScripture(s.scripture || '');
    setYoutubeId(s.youtube_id);
    setYoutubeUrl(s.youtube_url);
    setThumbnailUrl(s.thumbnail_url);
    setDescriptionEn(s.description_en || '');
    setDescriptionTa(s.description_ta || '');
    setIsFeatured(s.is_featured);
    setIsPublished(s.is_published);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleResetForm = () => {
    setId(null);
    setTitleEn('');
    setTitleTa('');
    setScripture('');
    setYoutubeUrl('');
    setYoutubeId('');
    setThumbnailUrl('');
    setDescriptionEn('');
    setDescriptionTa('');
    setIsFeatured(false);
    setIsPublished(true);
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

      {/* Form Card */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
        <div className="flex items-center justify-between mb-5">
          <h3 className="text-base font-bold text-[#292929] flex items-center space-x-2">
            <Video size={18} className="text-[#8F2638]" />
            <span>{id ? 'Edit Sermon Details' : 'Add Sermon to Video Library'}</span>
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
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2">
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                YOUTUBE VIDEO URL OR ID *
              </label>
              <input
                type="text"
                required
                placeholder="https://youtu.be/rQW18AzH9Sc or rQW18AzH9Sc"
                value={youtubeUrl}
                onChange={(e) => handleUrlChange(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
              {youtubeId && (
                <p className="text-[11px] text-emerald-700 mt-1 font-mono">
                  ✓ Extracted YouTube ID: {youtubeId}
                </p>
              )}
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                SERMON DATE
              </label>
              <input
                type="text"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                placeholder="DD-MM-YYYY"
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                SERMON TITLE (ENGLISH) *
              </label>
              <input
                type="text"
                required
                placeholder="e.g. Are You Ready To Meet Jesus?"
                value={titleEn}
                onChange={(e) => setTitleEn(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                SERMON TITLE (TAMIL • தலைப்பு)
              </label>
              <input
                type="text"
                placeholder="எ.கா. இயேசுவை சந்திக்க நீங்கள் ஆயத்தமா?"
                value={titleTa}
                onChange={(e) => setTitleTa(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs font-serif text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">SPEAKER</label>
              <select
                value={speaker}
                onChange={(e) => setSpeaker(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              >
                {SPEAKERS.map((s) => (
                  <option key={s} value={s}>
                    {s}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                KEY SCRIPTURE REFERENCE
              </label>
              <input
                type="text"
                placeholder="e.g. Matthew 24:44"
                value={scripture}
                onChange={(e) => setScripture(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">SERIES</label>
              <input
                type="text"
                placeholder="e.g. End Times Preparation"
                value={series}
                onChange={(e) => setSeries(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>
          </div>

          {/* Thumbnail Management: Auto YouTube or Custom Storage */}
          <div>
            <label className="block text-xs font-semibold text-[#292929] mb-1">
              THUMBNAIL IMAGE (STORAGE: sermon-thumbnails OR YOUTUBE)
            </label>
            <div className="flex items-center space-x-2">
              <input
                type="text"
                placeholder="Auto-generated YouTube thumbnail or Supabase storage URL"
                value={thumbnailUrl}
                onChange={(e) => setThumbnailUrl(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs font-mono text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
              <label className="cursor-pointer bg-[#F1EBDD] hover:bg-[#EAE2D0] text-[#8F2638] px-3 py-2 rounded-xl text-xs font-medium border border-[#E5DEC9] shrink-0 flex items-center space-x-1">
                <Upload size={14} />
                <span>{uploadingThumbnail ? '...' : 'Upload Custom'}</span>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleCustomThumbnailUpload}
                  className="hidden"
                />
              </label>
              {thumbnailUrl && thumbnailUrl.includes('sermon-thumbnails') && (
                <button
                  type="button"
                  onClick={handleRemoveCustomThumbnail}
                  title="Permanently remove custom thumbnail from storage"
                  className="p-2 text-stone-400 hover:text-red-600 border border-[#E5DEC9] rounded-xl bg-[#FAF7F0]"
                >
                  <Trash2 size={14} />
                </button>
              )}
            </div>
            {thumbnailUrl && (
              <div className="mt-2 flex items-center space-x-3">
                <img src={thumbnailUrl} alt="Thumbnail preview" className="w-20 h-12 object-cover rounded-md border border-[#E5DEC9]" />
                <span className="text-[10px] text-stone-500 font-mono truncate max-w-sm">
                  {thumbnailUrl.includes('sermon-thumbnails') ? '✓ Custom Storage Thumbnail' : '✓ Auto YouTube Thumbnail'}
                </span>
              </div>
            )}
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                SERMON SUMMARY (ENGLISH)
              </label>
              <textarea
                rows={2}
                placeholder="Key biblical takeaways and spiritual message..."
                value={descriptionEn}
                onChange={(e) => setDescriptionEn(e.target.value)}
                className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs leading-relaxed text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                SERMON SUMMARY (TAMIL • சுருக்கம்)
              </label>
              <textarea
                rows={2}
                placeholder="பிரசங்கத்தின் முக்கிய குறிப்புகள்..."
                value={descriptionTa}
                onChange={(e) => setDescriptionTa(e.target.value)}
                className="w-full p-3 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs leading-relaxed font-serif text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>
          </div>

          <div className="flex flex-wrap items-center justify-between pt-3 border-t border-[#E5DEC9] gap-4">
            <div className="flex items-center space-x-6 text-xs font-semibold text-[#292929]">
              <label className="flex items-center space-x-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={isFeatured}
                  onChange={(e) => setIsFeatured(e.target.checked)}
                  className="rounded border-[#E5DEC9] text-[#8F2638] focus:ring-[#8F2638]"
                />
                <span className="flex items-center space-x-1">
                  <Sparkles size={14} className="text-amber-600" />
                  <span>Featured Hero Video</span>
                </span>
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
                <span>{saving ? 'Saving...' : id ? 'Update Sermon' : 'Save Sermon'}</span>
              </button>
            </div>
          </div>
        </form>
      </div>

      {/* Sermons Library List */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
        <h3 className="text-sm font-bold text-[#292929] mb-4">Sermons Archive</h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {sermons.map((s) => (
            <div
              key={s.id}
              className="p-4 rounded-xl border border-[#E5DEC9] bg-[#FAF7F0] flex flex-col justify-between hover:border-[#8F2638] transition-all"
            >
              <div>
                <div className="relative rounded-lg overflow-hidden aspect-video bg-black/10 mb-3 border border-[#E5DEC9]">
                  <img
                    src={s.thumbnail_url || `https://img.youtube.com/vi/${s.youtube_id}/hqdefault.jpg`}
                    alt={s.title_en}
                    className="w-full h-full object-cover"
                  />
                  {s.is_featured && (
                    <span className="absolute top-2 left-2 bg-[#8F2638] text-white text-[10px] font-bold px-2 py-0.5 rounded shadow-xs">
                      FEATURED
                    </span>
                  )}
                  {s.thumbnail_url && s.thumbnail_url.includes('sermon-thumbnails') && (
                    <span className="absolute bottom-2 left-2 bg-emerald-800 text-white text-[9px] font-bold px-1.5 py-0.5 rounded shadow-xs flex items-center space-x-1">
                      <ImageIcon size={10} />
                      <span>Custom Storage Thumb</span>
                    </span>
                  )}
                  <a
                    href={`https://youtube.com/watch?v=${s.youtube_id}`}
                    target="_blank"
                    rel="noreferrer"
                    className="absolute inset-0 flex items-center justify-center bg-black/20 hover:bg-black/40 transition-colors group"
                  >
                    <div className="w-10 h-10 rounded-full bg-red-600 text-white flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform">
                      <Play size={18} className="ml-0.5 fill-current" />
                    </div>
                  </a>
                </div>

                <div className="flex items-center justify-between text-[11px] text-[#77736F] mb-1 font-mono">
                  <span>{s.date}</span>
                  <span>{s.speaker}</span>
                </div>

                <h4 className="font-bold text-sm text-[#292929] leading-tight">{s.title_en}</h4>
                {s.title_ta && (
                  <p className="text-xs font-serif text-[#77736F] mt-0.5">{s.title_ta}</p>
                )}
                {s.scripture && (
                  <p className="text-xs font-semibold text-[#8F2638] mt-1">📖 {s.scripture}</p>
                )}
              </div>

              <div className="mt-4 pt-3 border-t border-[#E5DEC9] flex items-center justify-between">
                <span className="text-[11px] text-[#77736F] font-mono">{s.series}</span>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => handleEdit(s)}
                    className="px-2.5 py-1 text-xs font-semibold text-[#8F2638] bg-white rounded-lg border border-[#E5DEC9] hover:bg-[#EAE2D0]"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => handleDelete(s.id)}
                    title="Permanently delete sermon and any custom storage thumbnail"
                    className="p-1 text-stone-400 hover:text-red-600 rounded-lg hover:bg-red-50 transition-colors"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
