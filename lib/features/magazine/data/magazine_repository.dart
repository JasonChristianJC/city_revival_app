import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/magazine.dart';
import 'magazine_download_service.dart';

final magazineDownloadServiceProvider = Provider<MagazineDownloadService>((ref) {
  return MagazineDownloadService();
});

final magazineRepositoryProvider = Provider<MagazineRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final downloadService = ref.watch(magazineDownloadServiceProvider);
  return MagazineRepository(supabase, downloadService);
});

final magazinesProvider = FutureProvider<List<Magazine>>((ref) async {
  final repository = ref.watch(magazineRepositoryProvider);
  return repository.getMagazines();
});

final selectedMagazineYearProvider = StateProvider<int?>((ref) => null);

final magazinesBySelectedYearProvider = Provider<AsyncValue<List<Magazine>>>((ref) {
  final magazinesAsync = ref.watch(magazinesProvider);
  final selectedYear = ref.watch(selectedMagazineYearProvider);

  return magazinesAsync.whenData((magazines) {
    if (magazines.isEmpty) return [];
    final activeYear = selectedYear ?? magazines.first.year;
    return magazines.where((m) => m.year == activeYear).toList();
  });
});

final magazineYearsProvider = Provider<List<int>>((ref) {
  final magazinesAsync = ref.watch(magazinesProvider);
  return magazinesAsync.maybeWhen(
    data: (magazines) {
      final years = magazines.map((m) => m.year).toSet().toList();
      years.sort((a, b) => b.compareTo(a)); // Descending order
      return years;
    },
    orElse: () => [2026, 2025, 2024, 2023, 2022, 2020, 2019, 2018],
  );
});

class MagazineRepository {
  final SupabaseClient _supabase;
  final MagazineDownloadService _downloadService;

  MagazineRepository(this._supabase, this._downloadService);

  Future<List<Magazine>> getMagazines() async {
    try {
      final response = await _supabase
          .from('magazines')
          .select()
          .order('issue_date', ascending: false);

      final list = (response as List).map((json) {
        return Magazine.fromJson(json as Map<String, dynamic>);
      }).toList();

      // Check download status for each
      final updatedList = <Magazine>[];
      for (final mag in list) {
        final localPath = await _downloadService.getLocalPath(mag.id);
        updatedList.add(mag.copyWith(
          isDownloaded: localPath != null,
          localPath: localPath,
        ));
      }

      if (updatedList.isNotEmpty) {
        return updatedList;
      }
    } catch (_) {
      // Fallback
    }

    return _fallbackMagazines;
  }

  static final List<Magazine> _fallbackMagazines = [
    const Magazine(
      id: 'mag-2026-nov-dec',
      title: 'Paripoorana Jeevan — Nov - Dec 2026',
      description: 'Rev. Dr. Jerry Daniel’s Messages from Paripoorana Jeevan',
      pdfUrl:
          'https://fycmdyxllutinvfwdljy.supabase.co/storage/v1/object/public/magazine-pdfs/2026/53bc91a5-dc4f-4e65-9cf7-1f820d0a230f.pdf',
      issueDate: '2026-11-01',
      year: 2026,
      issuePeriod: 'Nov - Dec',
    ),
    const Magazine(
      id: 'mag-2026-sep-oct',
      title: 'Paripoorana Jeevan — Sep - Oct 2026',
      description: 'Rev. Dr. Jerry Daniel’s Messages from Paripoorana Jeevan',
      pdfUrl:
          'https://drive.google.com/file/d/1wBwLQd3JAHTk2TerWFQjE3NrQg8qzuzK/view?usp=drive_link',
      issueDate: '2026-09-01',
      year: 2026,
      issuePeriod: 'Sep - Oct',
    ),
    const Magazine(
      id: 'mag-2026-jul-aug',
      title: 'Paripoorana Jeevan — Jul - Aug 2026',
      description: 'Rev. Dr. Jerry Daniel’s Messages from Paripoorana Jeevan',
      pdfUrl:
          'https://drive.google.com/file/d/1PgaLhrO8OhmiN2lNeOL24pM4TAzEI8wO/view?usp=sharing',
      issueDate: '2026-07-01',
      year: 2026,
      issuePeriod: 'Jul - Aug',
    ),
  ];
}
