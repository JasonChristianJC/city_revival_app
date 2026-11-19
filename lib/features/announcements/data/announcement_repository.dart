import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/announcement.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AnnouncementRepository(supabase);
});

final announcementsProvider = FutureProvider<List<ChurchAnnouncement>>((ref) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncements();
});

class AnnouncementRepository {
  final SupabaseClient _supabase;

  AnnouncementRepository(this._supabase);

  static final List<ChurchAnnouncement> _fallbackAnnouncements = [
    const ChurchAnnouncement(
      id: 'ann-1',
      title: 'Sunday Worship Services & Live Broadcast',
      titleTa: 'ஞாயிறு ஆராதனைகள் & நேரலை ஒளிபரப்பு',
      description:
          'Join us for 1st Service at 6:00 AM (Tamil), 2nd Service at 8:30 AM (Tamil), and 3rd Service at 10:45 AM (English & Youth). Live on YouTube.',
      descriptionTa:
          '1வது ஆராதனை காலை 6:00 (தமிழ்), 2வது ஆராதனை காலை 8:30 (தமிழ்), 3வது ஆராதனை காலை 10:45 (ஆங்கிலம் & வாலிபர்). யூடியூபில் நேரலையில் இணைந்திடுங்கள்.',
      date: 'Every Sunday',
      category: 'Sunday Live Alert',
      isUrgent: true,
      flyerUrl: 'https://img.youtube.com/vi/rQW18AzH9Sc/maxresdefault.jpg',
    ),
    const ChurchAnnouncement(
      id: 'ann-2',
      title: '21 Days Fasting Prayer for Spiritual Revival',
      titleTa: '21 நாட்கள் உபவாச ஜெபம் - ஆவிக்குரிய எழுப்புதல்',
      description:
          'Seeking God for church growth, family blessings, healing, and revival across Tiruchirappalli and Tamil Nadu. Daily evening gathering at 7:00 PM.',
      descriptionTa:
          'திருச்சபை வளர்ச்சி, குடும்ப ஆசீர்வாதம், சுகம் மற்றும் திருச்சி எங்கும் எழுப்புதலுக்காக தேவனை நாடுதல். தினசரி மாலை 7:00 மணிக்கு ஜெபக் கூடுதல்.',
      date: 'Ongoing Prayer Season',
      category: 'Fasting Prayer',
      isUrgent: true,
    ),
    const ChurchAnnouncement(
      id: 'ann-3',
      title: 'Vision 2035: Building Fund Milestone',
      titleTa: 'விஷன் 2035: புதிய ஆலய கட்டுமான நிதி',
      description:
          'We give thanks to God for raising over ₹4.35 Crores toward our 5,000-seat sanctuary in Tiruchirappalli. Prayerfully support this kingdom project.',
      descriptionTa:
          'திருச்சியில் 5,000 இருக்கைகள் கொண்ட புதிய ஆலய கட்டுமானத்திற்காக இதுவரை ₹4.35 கோடி நிதியளித்த தேவனுக்கே மகிமை. தொடர்ந்து உங்கள் பங்களிப்பை தாருங்கள்.',
      date: 'Vision 2035',
      category: 'Convention',
      isUrgent: false,
    ),
    const ChurchAnnouncement(
      id: 'ann-4',
      title: 'Youth Revival Fellowship: IGNITE',
      titleTa: 'வாலிபர் எழுப்புதல் ஐக்கியம்: இக்னைட்',
      description:
          'Special gathering for college students and working youths every Saturday at 6:30 PM. Powerful praise, worship, and prophetic word.',
      descriptionTa:
          'கல்லூரி மாணவர்கள் மற்றும் இளம் ஊழியர்களுக்கான சிறப்பு கூட்டம் ஒவ்வொரு சனிக்கிழமை மாலை 6:30 மணிக்கு. ஆராதனை மற்றும் தீர்க்கதரிசன செய்தி.',
      date: 'Every Saturday 6:30 PM',
      category: 'Youth Meeting',
      isUrgent: false,
    ),
  ];

  Future<List<ChurchAnnouncement>> getAnnouncements() async {
    try {
      final response = await _supabase
          .from('site_content')
          .select('content')
          .eq('id', 'site-content')
          .maybeSingle();

      if (response != null && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final rawAnnouncements = content['announcements'] as List?;
        if (rawAnnouncements != null && rawAnnouncements.isNotEmpty) {
          return rawAnnouncements
              .map((item) => ChurchAnnouncement.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback if network or parsing issue
    }

    return _fallbackAnnouncements;
  }
}
