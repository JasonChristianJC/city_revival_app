import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_helper.dart';
import '../../../core/widgets/sacred_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../data/daily_verse_repository.dart';
import 'verse_archive_screen.dart';

class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verseAsync = ref.watch(todayVerseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return verseAsync.when(
      loading: () => const SacredCard(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(width: 140, height: 16),
            SizedBox(height: 12),
            ShimmerLoading(width: double.infinity, height: 48),
            SizedBox(height: 12),
            ShimmerLoading(width: double.infinity, height: 48),
            SizedBox(height: 12),
            ShimmerLoading(width: 100, height: 20),
          ],
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (verse) {
        final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(verse.verseDate);

        return SacredCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          border: Border.all(
            color: AppColors.divineGold.withOpacity(isDark ? 0.45 : 0.35),
            width: 1.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.divineGold.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppColors.divineGold,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "TODAY'S PROMISE",
                        style: TextStyle(
                          color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VerseArchiveScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history, size: 14),
                    label: const Text(
                      'Archive',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.divineGoldDark,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                formattedDate,
                style: TextStyle(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Stacked English Verse
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCardAlt.withOpacity(0.6)
                      : AppColors.parchmentCream.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    left: BorderSide(
                      color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                      width: 3.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${verse.verseEn}"',
                      style: AppTheme.scriptureEnStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Stacked Tamil Verse
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCardAlt.withOpacity(0.6)
                      : AppColors.parchmentCream.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    left: const BorderSide(
                      color: AppColors.divineGold,
                      width: 3.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${verse.verseTa}"',
                      style: AppTheme.tamilTextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Reference and Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.divineGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      verse.reference,
                      style: TextStyle(
                        color: isDark ? AppColors.divineGoldLight : AppColors.primaryBurgundyDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  // 1-Tap WhatsApp Share & General Share Row
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final msg = ShareHelper.formatDailyVerseMessage(
                            verseEn: verse.verseEn,
                            verseTa: verse.verseTa,
                            reference: verse.reference,
                            dateFormatted: formattedDate,
                          );
                          ShareHelper.shareToWhatsApp(
                            context: context,
                            message: msg,
                          );
                        },
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 16),
                        label: const Text('Status Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final msg = ShareHelper.formatDailyVerseMessage(
                            verseEn: verse.verseEn,
                            verseTa: verse.verseTa,
                            reference: verse.reference,
                            dateFormatted: formattedDate,
                          );
                          ShareHelper.shareGeneral(message: msg);
                        },
                        icon: const Icon(Icons.share_outlined, size: 20),
                        tooltip: 'Share',
                        color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
