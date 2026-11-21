import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://lmlwtnvieynlywtujkyv.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_h4QrmjLDJtNNe4bhMbJHMg_eq-QyB6d';

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
});

/**
 * Upload a file to a Supabase Storage bucket and return its public URL.
 */
export async function uploadStorageFile(
  bucket: string,
  filePath: string,
  file: File
): Promise<{ url: string | null; error: Error | null }> {
  try {
    const { error: uploadError } = await supabase.storage
      .from(bucket)
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: true,
      });

    if (uploadError) {
      return { url: null, error: uploadError };
    }

    const { data } = supabase.storage.from(bucket).getPublicUrl(filePath);
    return { url: data.publicUrl, error: null };
  } catch (err: any) {
    return { url: null, error: err };
  }
}

/**
 * Permanently delete a file from a Supabase Storage bucket given its public URL or storage path.
 */
export async function deleteStorageFile(
  bucket: string,
  fileUrlOrPath?: string | null
): Promise<{ success: boolean; error: Error | null }> {
  if (!fileUrlOrPath) return { success: true, error: null };

  try {
    let cleanPath = fileUrlOrPath.trim();

    // Check if it is a full URL
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      const publicMarker = `/storage/v1/object/public/${bucket}/`;
      const signMarker = `/storage/v1/object/sign/${bucket}/`;
      const directMarker = `/${bucket}/`;

      if (cleanPath.includes(publicMarker)) {
        cleanPath = cleanPath.substring(cleanPath.indexOf(publicMarker) + publicMarker.length);
      } else if (cleanPath.includes(signMarker)) {
        cleanPath = cleanPath.substring(cleanPath.indexOf(signMarker) + signMarker.length);
      } else if (cleanPath.includes(directMarker)) {
        cleanPath = cleanPath.substring(cleanPath.indexOf(directMarker) + directMarker.length);
      } else {
        // External URL (e.g., YouTube thumbnail or Google Drive), not hosted in this bucket
        return { success: true, error: null };
      }
    }

    // Strip URL parameters / hashes
    cleanPath = cleanPath.split('?')[0].split('#')[0];

    // Decode URL encoding (e.g. %20 -> space)
    try {
      cleanPath = decodeURIComponent(cleanPath);
    } catch (_) {}

    // Trim leading slash
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    if (!cleanPath) return { success: true, error: null };

    const { error } = await supabase.storage.from(bucket).remove([cleanPath]);
    if (error) {
      console.warn(`[Supabase Storage] Failed to remove ${cleanPath} from ${bucket}:`, error.message);
      return { success: false, error };
    }

    console.info(`[Supabase Storage] Permanently removed ${cleanPath} from ${bucket}.`);
    return { success: true, error: null };
  } catch (err: any) {
    console.warn(`[Supabase Storage] Exception while deleting file:`, err);
    return { success: false, error: err };
  }
}

/**
 * Record an administrative action into admin_audit_logs.
 */
export async function logAdminAction(
  adminEmail: string,
  action: string,
  targetTable: string,
  recordId?: string,
  details?: Record<string, any>
) {
  try {
    await supabase.from('admin_audit_logs').insert({
      admin_email: adminEmail,
      action,
      target_table: targetTable,
      record_id: recordId,
      details,
    });
  } catch (err) {
    console.error('Failed to write audit log:', err);
  }
}
