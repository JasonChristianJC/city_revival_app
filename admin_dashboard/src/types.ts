export type AdminRole = 'admin';

export interface AdminUser {
  id: string;
  email: string;
  role: AdminRole;
}

export interface DailyVerse {
  id: string;
  verse_date: string;
  verse_en: string;
  verse_ta: string;
  reference: string;
  is_published: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface Announcement {
  id: string;
  title: string;
  title_ta: string;
  description: string;
  description_ta: string;
  flyer_url?: string | null;
  event_date?: string | null;
  event_time?: string | null;
  category: string;
  is_urgent: boolean;
  is_featured: boolean;
  is_published: boolean;
  action_url?: string | null;
  created_at?: string;
}

export interface Sermon {
  id: string;
  date: string;
  title_en: string;
  title_ta: string;
  series: string;
  speaker: string;
  language: string;
  scripture: string;
  youtube_id: string;
  youtube_url: string;
  thumbnail_url: string;
  description_en: string;
  description_ta: string;
  duration?: string;
  notes?: string;
  is_featured: boolean;
  is_published: boolean;
  created_at?: string;
}

export interface LiveStream {
  id: string;
  title: string;
  youtube_url: string;
  youtube_id: string;
  is_live: boolean;
  thumbnail_url?: string;
  description?: string;
  start_time?: string;
  is_active: boolean;
  updated_at?: string;
}

export interface Magazine {
  id: string;
  title: string;
  description: string;
  pdf_url: string;
  cover_image_url?: string | null;
  issue_date: string;
  year: number;
  issue_period: string;
  is_published: boolean;
  created_at?: string;
}

export interface GivingSettings {
  id: string;
  upi_id: string;
  upi_payee_name?: string;
  payee_name?: string;
  payment_note?: string;
  bank_name: string;
  account_holder: string;
  account_number: string;
  ifsc_code: string;
  branch_name: string;
  notes?: string;
  updated_at?: string;
}

export interface BuildingFund {
  id: string;
  project_title?: string;
  project_name?: string;
  sanctuary_description?: string;
  tagline?: string;
  target_amount: number;
  collected_amount: number;
  target_capacity?: number;
  sanctuary_capacity?: number;
  is_active?: boolean;
  updated_at?: string;
}

export interface PrayerRequest {
  id: string;
  name: string;
  phone?: string | null;
  email?: string | null;
  category: string;
  request_text: string;
  is_anonymous: boolean;
  status: 'new' | 'praying' | 'prayed' | 'archived';
  pastoral_notes?: string | null;
  created_at: string;
}

export interface AuditLog {
  id: string;
  admin_email: string;
  action: string;
  target_table: string;
  record_id?: string;
  details?: Record<string, any>;
  created_at: string;
}

export interface AppNotification {
  id: string;
  title: string;
  body: string;
  target_screen?: string;
  status: string;
  created_at: string;
}
