import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_helper.dart';
import '../../../core/widgets/sacred_card.dart';
import '../data/daily_verse_repository.dart';

class VerseArchiveScreen extends ConsumerWidget {
  const VerseArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archiveAsync = ref.watch(verseArchiveProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promise Verse Archive'),
      ),
      body: archiveAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.divineGold),
        ),
        error: (err, _) => Center(
          child: Text('Error loading archive: $err'),
        ),
        data: (verses) {
          if (verses.isEmpty) {
            return const Center(
              child: Text('No previous verses recorded.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verse = verses[index];
              final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(verse.verseDate);

              return SacredCard(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.divineGoldLight : AppColors.primaryWine,
                          ),
                        ),
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18, color: Color(0xFF25D366)),
                          onPressed: () {
                            final msg = ShareHelper.formatDailyVerseMessage(
                              verseEn: verse.verseEn,
                              verseTa: verse.verseTa,
                              reference: verse.reference,
                              dateFormatted: dateStr,
                            );
                            ShareHelper.shareToWhatsApp(
                              context: context,
                              message: msg,
                            );
                          },
                          tooltip: 'Share to WhatsApp',
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      '"${verse.verseEn}"',
                      style: AppTheme.scriptureEnStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '"${verse.verseTa}"',
                      style: AppTheme.tamilTextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.divineGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          verse.reference,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? AppColors.divineGoldLight : AppColors.primaryBurgundyDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
