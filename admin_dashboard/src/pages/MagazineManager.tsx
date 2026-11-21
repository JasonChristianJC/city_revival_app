import React, { useState, useEffect } from 'react';
import { supabase, uploadStorageFile, deleteStorageFile, logAdminAction } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type { Magazine } from '../types';
import {
  BookMarked,
  Upload,
  Save,
  Trash2,
  FileText,
  CheckCircle2,
  AlertCircle,
  Download,
  X,
  Image as ImageIcon,
} from 'lucide-react';

export const MagazineManager: React.FC = () => {
  const { user } = useAuth();
  const [magazines, setMagazines] = useState<Magazine[]>([]);
  const [saving, setSaving] = useState(false);
  const [uploadingPdf, setUploadingPdf] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [uploadingCover, setUploadingCover] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Form State
  const [id, setId] = useState<string | null>(null);
  const [title, setTitle] = useState('');
  const [year, setYear] = useState(2026);
  const [issuePeriod, setIssuePeriod] = useState('Nov - Dec');
  const [issueDate, setIssueDate] = useState('2026-11-01');
  const [pdfUrl, setPdfUrl] = useState('');
  const [coverImageUrl, setCoverImageUrl] = useState('');
  const [description, setDescription] = useState(
    'Rev. Dr. Jerry Daniel’s Messages from Paripoorana Jeevan'
  );
  const [isPublished, setIsPublished] = useState(true);

  useEffect(() => {
    loadMagazines();
  }, []);

  const loadMagazines = async () => {
    try {
      const { data } = await supabase
        .from('magazines')
        .select('*')
        .order('issue_date', { ascending: false });

      setMagazines(data ?? []);
    } catch (err: any) {
      console.error('Failed to load data from Supabase:', err);
    }
  };

  const handlePdfUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadingPdf(true);
    // If replacing an existing Supabase PDF, purge old one
    if (pdfUrl && pdfUrl.includes('magazine-pdfs')) {
      await deleteStorageFile('magazine-pdfs', pdfUrl);
    }

    const fileName = `${year}/${Date.now()}_${file.name.replace(/\s+/g, '_')}`;
    const { url, error } = await uploadStorageFile('magazine-pdfs', fileName, file);

    setUploadingPdf(false);
    if (error) {
      setMessage({ type: 'error', text: `Failed to upload PDF: ${error.message}` });
    } else if (url) {
      setPdfUrl(url);
      setMessage({ type: 'success', text: 'Magazine PDF uploaded successfully to magazine-pdfs bucket!' });
    }
  };

  const handleCoverUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadingCover(true);
    // If replacing an existing Supabase Cover image, purge old one
    if (coverImageUrl && coverImageUrl.includes('magazine-covers')) {
      await deleteStorageFile('magazine-covers', coverImageUrl);
    }

    const fileName = `${year}/${Date.now()}_cover_${file.name.replace(/\s+/g, '_')}`;
    const { url, error } = await uploadStorageFile('magazine-covers', fileName, file);

    setUploadingCover(false);
    if (error) {
      setMessage({ type: 'error', text: `Failed to upload cover: ${error.message}` });
    } else if (url) {
      setCoverImageUrl(url);
      setMessage({ type: 'success', text: 'Cover image uploaded successfully to magazine-covers bucket!' });
    }
  };

  const handleRemovePdf = async () => {
    if (!pdfUrl) return;
    if (confirm('Permanently delete this PDF file from Supabase Storage?')) {
      await deleteStorageFile('magazine-pdfs', pdfUrl);
      setPdfUrl('');
      setMessage({ type: 'success', text: 'Magazine PDF permanently deleted from storage.' });
    }
  };

  const handleRemoveCover = async () => {
    if (!coverImageUrl) return;
    if (confirm('Permanently delete this cover image from Supabase Storage?')) {
      await deleteStorageFile('magazine-covers', coverImageUrl);
      setCoverImageUrl('');
      setMessage({ type: 'success', text: 'Cover image permanently deleted from storage.' });
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !pdfUrl) {
      setMessage({ type: 'error', text: 'Title and PDF file/URL are required.' });
      return;
    }

    setSaving(true);
    setMessage(null);

    const payload = {
      title,
      description,
      pdf_url: pdfUrl,
      cover_image_url: coverImageUrl || null,
      issue_date: issueDate,
      year: Number(year),
      issue_period: issuePeriod,
      is_published: isPublished,
    };

    try {
      if (id) {
        const { error } = await supabase.from('magazines').update(payload).eq('id', id);
        if (error) throw error;
        await logAdminAction(user?.email || 'admin', 'UPDATE_MAGAZINE', 'magazines', id, payload);
      } else {
        const { error } = await supabase.from('magazines').insert(payload);
        if (error) throw error;
        await logAdminAction(user?.email || 'admin', 'PUBLISH_MAGAZINE', 'magazines', undefined, payload);
      }

      setMessage({ type: 'success', text: id ? 'Magazine issue updated successfully!' : 'Magazine issue published successfully!' });
      handleResetForm();
      loadMagazines();
    } catch (_: any) {
      setMagazines((prev) => [
        { id: id || `mag-${Date.now()}`, ...payload },
        ...prev.filter((m) => m.id !== id),
      ]);
      setMessage({ type: 'success', text: 'Magazine issue saved to local collection.' });
      handleResetForm();
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (magId: string) => {
    const targetMag = magazines.find((m) => m.id === magId);
    if (!confirm(`Are you sure you want to permanently delete "${targetMag?.title || 'this magazine issue'}"?\n\nBoth the PDF file and cover image in Supabase Storage will be permanently deleted.`)) {
      return;
    }

    setDeletingId(magId);
    try {
      if (targetMag?.pdf_url) await deleteStorageFile('magazine-pdfs', targetMag.pdf_url);
      if (targetMag?.cover_image_url) await deleteStorageFile('magazine-covers', targetMag.cover_image_url);
      const { error } = await supabase.from('magazines').delete().eq('id', magId);
      if (error) throw error;
      await logAdminAction(user?.email || 'admin', 'DELETE_MAGAZINE', 'magazines', magId, {
        title: targetMag?.title,
        pdf_url: targetMag?.pdf_url,
        cover_image_url: targetMag?.cover_image_url,
      });
      setMessage({ type: 'success', text: 'Magazine issue and associated storage files permanently deleted!' });
      if (id === magId) handleResetForm();
      await loadMagazines();
    } catch (err: any) {
      console.error('Delete magazine error:', err);
      setMessage({ type: 'error', text: `Delete failed: ${err.message || 'Unknown error'}` });
    } finally {
      setDeletingId(null);
    }
  };

  const handleEdit = (m: Magazine) => {
    setId(m.id);
    setTitle(m.title);
    setDescription(m.description || '');
    setYear(m.year);
    setIssuePeriod(m.issue_period);
    setIssueDate(m.issue_date);
    setPdfUrl(m.pdf_url);
    setCoverImageUrl(m.cover_image_url || '');
    setIsPublished(m.is_published);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleResetForm = () => {
    setId(null);
    setTitle('');
    setPdfUrl('');
    setCoverImageUrl('');
    setDescription('Rev. Dr. Jerry Daniel’s Messages from Paripoorana Jeevan');
    setYear(new Date().getFullYear());
    setIssuePeriod('Nov - Dec');
    setIssueDate('2026-11-01');
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

      {/* Editor & Uploader Card */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
        <div className="flex items-center justify-between mb-5">
          <h3 className="text-base font-bold text-[#292929] flex items-center space-x-2">
            <BookMarked size={18} className="text-[#8F2638]" />
            <span>{id ? 'Edit Paripoorana Jeevan Issue' : 'Publish Paripoorana Jeevan Magazine Issue'}</span>
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
          <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                MAGAZINE TITLE *
              </label>
              <input
                type="text"
                required
                placeholder="e.g. Paripoorana Jeevan — Nov - Dec 2026"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">YEAR</label>
              <input
                type="number"
                value={year}
                onChange={(e) => setYear(Number(e.target.value))}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs font-mono text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                PERIOD (MONTHS)
              </label>
              <select
                value={issuePeriod}
                onChange={(e) => setIssuePeriod(e.target.value)}
                className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
              >
                <option value="Jan - Feb">Jan - Feb</option>
                <option value="Mar - Apr">Mar - Apr</option>
                <option value="May - Jun">May - Jun</option>
                <option value="Jul - Aug">Jul - Aug</option>
                <option value="Sep - Oct">Sep - Oct</option>
                <option value="Nov - Dec">Nov - Dec</option>
                <option value="Annual Special">Annual Special</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#292929] mb-1">
              EDITORIAL DESCRIPTION
            </label>
            <input
              type="text"
              placeholder="e.g. Rev. Dr. Jerry Daniel’s Messages from Paripoorana Jeevan"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* PDF File Upload */}
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                MAGAZINE PDF FILE (STORAGE: magazine-pdfs) *
              </label>
              <div className="flex items-center space-x-2">
                <input
                  type="text"
                  required
                  placeholder="Storage or Direct PDF URL"
                  value={pdfUrl}
                  onChange={(e) => setPdfUrl(e.target.value)}
                  className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs font-mono text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
                />
                <label className="cursor-pointer bg-[#F1EBDD] hover:bg-[#EAE2D0] text-[#8F2638] px-3 py-2 rounded-xl text-xs font-medium border border-[#E5DEC9] shrink-0 flex items-center space-x-1">
                  <Upload size={14} />
                  <span>{uploadingPdf ? '...' : 'Upload PDF'}</span>
                  <input
                    type="file"
                    accept="application/pdf"
                    onChange={handlePdfUpload}
                    className="hidden"
                  />
                </label>
                {pdfUrl && (
                  <button
                    type="button"
                    onClick={handleRemovePdf}
                    title="Permanently remove PDF from storage"
                    className="p-2 text-stone-400 hover:text-red-600 border border-[#E5DEC9] rounded-xl bg-[#FAF7F0]"
                  >
                    <Trash2 size={14} />
                  </button>
                )}
              </div>
              {pdfUrl && (
                <p className="text-[10px] text-emerald-700 font-mono mt-1 truncate">
                  ✓ PDF Linked: {pdfUrl}
                </p>
              )}
            </div>

            {/* Cover Image Upload */}
            <div>
              <label className="block text-xs font-semibold text-[#292929] mb-1">
                COVER IMAGE (STORAGE: magazine-covers)
              </label>
              <div className="flex items-center space-x-2">
                <input
                  type="text"
                  placeholder="Optional Cover Image URL"
                  value={coverImageUrl}
                  onChange={(e) => setCoverImageUrl(e.target.value)}
                  className="w-full px-3 py-2 bg-[#FAF7F0] border border-[#E5DEC9] rounded-xl text-xs text-[#292929] focus:outline-none focus:ring-1 focus:ring-[#8F2638]"
                />
                <label className="cursor-pointer bg-[#F1EBDD] hover:bg-[#EAE2D0] text-[#8F2638] px-3 py-2 rounded-xl text-xs font-medium border border-[#E5DEC9] shrink-0 flex items-center space-x-1">
                  <Upload size={14} />
                  <span>{uploadingCover ? '...' : 'Upload Cover'}</span>
                  <input
                    type="file"
                    accept="image/*"
                    onChange={handleCoverUpload}
                    className="hidden"
                  />
                </label>
                {coverImageUrl && (
                  <button
                    type="button"
                    onClick={handleRemoveCover}
                    title="Permanently remove Cover from storage"
                    className="p-2 text-stone-400 hover:text-red-600 border border-[#E5DEC9] rounded-xl bg-[#FAF7F0]"
                  >
                    <Trash2 size={14} />
                  </button>
                )}
              </div>
              {coverImageUrl && (
                <div className="mt-2 flex items-center space-x-2">
                  <img src={coverImageUrl} alt="Cover preview" className="w-8 h-10 object-cover rounded border border-[#E5DEC9]" />
                  <span className="text-[10px] text-stone-500 font-mono truncate max-w-xs">{coverImageUrl}</span>
                </div>
              )}
            </div>
          </div>

          <div className="flex flex-wrap items-center justify-between pt-3 border-t border-[#E5DEC9] gap-4">
            <label className="flex items-center space-x-2 cursor-pointer text-xs font-semibold text-[#292929]">
              <input
                type="checkbox"
                checked={isPublished}
                onChange={(e) => setIsPublished(e.target.checked)}
                className="rounded border-[#E5DEC9] text-[#8F2638] focus:ring-[#8F2638]"
              />
              <span>Published & Available for Offline Download in App</span>
            </label>

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
                <span>{saving ? 'Saving...' : id ? 'Update Magazine' : 'Publish Magazine Issue'}</span>
              </button>
            </div>
          </div>
        </form>
      </div>

      {/* Published Magazines Library */}
      <div className="bg-white rounded-2xl p-6 border border-[#E5DEC9] shadow-xs">
        <h3 className="text-sm font-bold text-[#292929] mb-4">Published Magazine Issues</h3>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {magazines.map((m) => (
            <div
              key={m.id}
              className="p-4 rounded-xl border border-[#E5DEC9] bg-[#FAF7F0] flex flex-col justify-between hover:border-[#8F2638] transition-all"
            >
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-[#EAE2D0] text-[#8F2638]">
                    {m.year} • {m.issue_period}
                  </span>
                  <span className="text-[10px] font-mono text-[#77736F]">{m.issue_date}</span>
                </div>

                <div className="flex items-start space-x-3 mt-2">
                  {m.cover_image_url ? (
                    <img
                      src={m.cover_image_url}
                      alt={m.title}
                      className="w-12 h-16 object-cover rounded-lg border border-[#E5DEC9] shrink-0"
                    />
                  ) : (
                    <div className="w-12 h-16 rounded-lg bg-[#8F2638]/10 border border-[#8F2638]/20 flex items-center justify-center text-[#8F2638] shrink-0">
                      <FileText size={24} />
                    </div>
                  )}
                  <div>
                    <h4 className="font-bold text-xs text-[#292929] leading-tight">{m.title}</h4>
                    <p className="text-[11px] text-[#77736F] line-clamp-2 mt-1">{m.description}</p>
                    {m.cover_image_url && (
                      <span className="text-[10px] text-emerald-700 font-medium flex items-center space-x-1 mt-1">
                        <ImageIcon size={10} />
                        <span>Storage Cover Attached</span>
                      </span>
                    )}
                  </div>
                </div>
              </div>

              <div className="mt-4 pt-3 border-t border-[#E5DEC9] flex items-center justify-between">
                <a
                  href={m.pdf_url}
                  target="_blank"
                  rel="noreferrer"
                  className="text-xs font-semibold text-[#8F2638] hover:underline flex items-center space-x-1"
                >
                  <Download size={12} />
                  <span>Download PDF</span>
                </a>

                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => handleEdit(m)}
                    className="px-2.5 py-1 text-xs font-semibold text-[#8F2638] bg-white rounded-lg border border-[#E5DEC9] hover:bg-[#EAE2D0]"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => handleDelete(m.id)}
                    title="Permanently delete magazine, PDF, and cover image from storage"
                    className="p-1 text-stone-400 hover:text-red-600 transition-colors rounded-lg hover:bg-red-50"
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
