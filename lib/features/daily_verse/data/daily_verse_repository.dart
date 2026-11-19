import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/daily_verse.dart';

final dailyVerseRepositoryProvider = Provider<DailyVerseRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return DailyVerseRepository(supabase);
});

final todayVerseProvider = FutureProvider<DailyVerse>((ref) async {
  final repository = ref.watch(dailyVerseRepositoryProvider);
  return repository.getTodayVerse();
});

final verseArchiveProvider = FutureProvider<List<DailyVerse>>((ref) async {
  final repository = ref.watch(dailyVerseRepositoryProvider);
  return repository.getVerseArchive();
});

class DailyVerseRepository {
  final SupabaseClient _supabase;

  DailyVerseRepository(this._supabase);

  // Default fallback public-domain verses
  static final List<DailyVerse> _fallbackVerses = [
    DailyVerse(
      id: 'verse-1',
      verseDate: DateTime.now(),
      verseEn:
          'For I know the plans I have for you, says the Lord, plans for peace and not for evil, to give you a future and a hope.',
      verseTa:
          'நீங்கள் எதிர்பார்த்திருக்கும் முடிவை உங்களுக்குக் கொடுக்கும்படிக்கு நான் உங்கள்பேரில் நினைத்திருக்கிற நினைவுகளை அறிவேன் என்று கர்த்தர் சொல்லுகிறார்; அவைகள் தீமைக்கல்ல, சமாதானத்துக்கேதுவான நினைவுகளே.',
      reference: 'Jeremiah 29:11',
    ),
    DailyVerse(
      id: 'verse-2',
      verseDate: DateTime.now().subtract(const Duration(days: 1)),
      verseEn:
          'The Lord is my shepherd; I shall not want. He makes me to lie down in green pastures.',
      verseTa:
          'கர்த்தர் என் மேய்ப்பராயிருக்கிறார்; நான் தாழ்ச்சியடையேன். அவர் என்னைப் புல்லுள்ள இடங்களில் படுக்கப்பண்ணுகிறார்.',
      reference: 'Psalm 23:1-2',
    ),
    DailyVerse(
      id: 'verse-3',
      verseDate: DateTime.now().subtract(const Duration(days: 2)),
      verseEn:
          'Fear not, for I am with you; be not dismayed, for I am your God. I will strengthen you and uphold you.',
      verseTa:
          'நீ பயப்படாதே, நான் உன்னுடனே இருக்கிறேன்; திகையாதே, நான் உன் தேவன்; நான் உன்னைப் பலப்படுத்தி உனக்குச் சகாயம்பண்ணுவேன்; என் நீதியின் வலதுகரத்தினால் உன்னைத் தாங்குவேன்.',
      reference: 'Isaiah 41:10',
    ),
    DailyVerse(
      id: 'verse-4',
      verseDate: DateTime.now().subtract(const Duration(days: 3)),
      verseEn:
          'Trust in the Lord with all your heart, and do not lean on your own understanding.',
      verseTa:
          'உன் சுயபுத்தியின்மேல் சாயாமல், உன் முழு இருதயத்தோடும் கர்த்தரில் நம்பிக்கையாயிருந்து, உன் வழிகளிலெல்லாம் அவரை நினைத்துக்கொள்.',
      reference: 'Proverbs 3:5',
    ),
  ];

  Future<DailyVerse> getTodayVerse() async {
    final now = DateTime.now();
    final todayString =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      final response = await _supabase
          .from('daily_verses')
          .select()
          .eq('verse_date', todayString)
          .maybeSingle();

      if (response != null) {
        return DailyVerse.fromJson(response);
      }
    } catch (_) {
      // Supabase table may not yet be created or network offline
    }

    return _fallbackVerses.first;
  }

  Future<List<DailyVerse>> getVerseArchive() async {
    try {
      final response = await _supabase
          .from('daily_verses')
          .select()
          .order('verse_date', ascending: false)
          .limit(30);

      final list = (response as List)
          .map((item) => DailyVerse.fromJson(item as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) {
        return list;
      }
    } catch (_) {
      // Use fallback list
    }

    return _fallbackVerses;
  }
}
