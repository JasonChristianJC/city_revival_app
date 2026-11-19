import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/prayer_request.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PrayerRepository(supabase);
});

class PrayerRepository {
  final SupabaseClient _supabase;

  PrayerRepository(this._supabase);

  Future<bool> submitPrayerRequest(PrayerRequest request) async {
    try {
      await _supabase.from('prayer_requests').insert(request.toInsertJson());
      return true;
    } catch (e) {
      // If error occurs, rethrow or return false
      return false;
    }
  }
}
