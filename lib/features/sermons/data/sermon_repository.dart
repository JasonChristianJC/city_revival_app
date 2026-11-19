import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/sermon.dart';

final sermonRepositoryProvider = Provider<SermonRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SermonRepository(supabase);
});

final sermonsProvider = FutureProvider<List<Sermon>>((ref) async {
  final repository = ref.watch(sermonRepositoryProvider);
  return repository.getSermons();
});

final selectedSpeakerProvider = StateProvider<String>((ref) => 'All');
final sermonSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredSermonsProvider = Provider<AsyncValue<List<Sermon>>>((ref) {
  final sermonsAsync = ref.watch(sermonsProvider);
  final selectedSpeaker = ref.watch(selectedSpeakerProvider);
  final query = ref.watch(sermonSearchQueryProvider).toLowerCase().trim();

  return sermonsAsync.whenData((sermons) {
    return sermons.where((sermon) {
      // Speaker filter
      final matchesSpeaker = selectedSpeaker == 'All' ||
          sermon.speaker.toLowerCase().contains(selectedSpeaker.toLowerCase());

      // Search filter (English title, Tamil title, scripture, series)
      final matchesQuery = query.isEmpty ||
          sermon.titleEn.toLowerCase().contains(query) ||
          sermon.titleTa.toLowerCase().contains(query) ||
          sermon.scripture.toLowerCase().contains(query) ||
          sermon.series.toLowerCase().contains(query);

      return matchesSpeaker && matchesQuery;
    }).toList();
  });
});

class SermonRepository {
  final SupabaseClient _supabase;

  SermonRepository(this._supabase);

  // Fallback sermons in case of offline launch
  static final List<Sermon> _fallbackSermons = [
    const Sermon(
      id: 'sermon-1',
      date: '15-11-2026',
      titleEn: 'Are You Ready To Meet Jesus?',
      titleTa: 'இயேசுவை சந்திக்க நீங்கள் ஆயத்தமா?',
      series: 'End Times Preparation',
      speaker: 'Rev. Dr. Jerry Daniel',
      language: 'Tamil',
      scripture: 'Matthew 24:44',
      youtubeId: 'rQW18AzH9Sc',
      isFeatured: true,
      youtubeUrl: 'https://youtu.be/rQW18AzH9Sc',
      descriptionEn:
          'A powerful prophetic call to be watchful, prayerful, and prepared for the glorious return of our Lord and Savior Jesus Christ.',
      descriptionTa:
          'நம் ஆண்டவராகிய இயேசுகிறிஸ்துவின் மகிமையுள்ள வருகைக்கு விழிப்பாயும் ஜெபத்தோடும் ஆயத்தமாயிருக்க ஒரு தீர்க்கதரிசன அழைப்பு.',
      thumbnailUrl: 'https://img.youtube.com/vi/rQW18AzH9Sc/hqdefault.jpg',
    ),
    const Sermon(
      id: 'sermon-2',
      date: '08-11-2026',
      titleEn: 'The Prophetic Signs of His Coming',
      titleTa: 'அவர் வருகையின் தீர்க்கதரிசன அடையாளங்கள்',
      series: 'End Times Preparation',
      speaker: 'Rev. Dr. Jerry Daniel',
      language: 'Tamil',
      scripture: 'Matthew 24:3,33',
      youtubeId: 'vfYdbJGlvKM',
      isFeatured: false,
      youtubeUrl: 'https://youtu.be/vfYdbJGlvKM',
      descriptionEn:
          'Understanding current world events through the light of Bible prophecy and Biblical truth.',
      descriptionTa:
          'வேதாகம தீர்க்கதரிசனத்தின் வெளிச்சத்தில் இன்றைய உலக நிகழ்வுகளைப் புரிந்துகொள்ளுதல்.',
      thumbnailUrl: 'https://img.youtube.com/vi/vfYdbJGlvKM/hqdefault.jpg',
    ),
  ];

  Future<List<Sermon>> getSermons() async {
    try {
      final response = await _supabase
          .from('site_content')
          .select('content')
          .eq('id', 'site-content')
          .maybeSingle();

      if (response != null && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final rawSermons = content['sermons'] as List?;
        if (rawSermons != null && rawSermons.isNotEmpty) {
          return rawSermons
              .map((s) => Sermon.fromJson(s as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback to offline cached/preloaded sermons
    }

    return _fallbackSermons;
  }
}
