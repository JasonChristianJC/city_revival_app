import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sacred_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../data/announcement_repository.dart';
import 'announcement_detail_screen.dart';

class AnnouncementFeed extends ConsumerWidget {
  final VoidCallback? onViewAll;

  const AnnouncementFeed({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LATEST ANNOUNCEMENTS',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isDark ? AppColors.divineGold : AppColors.primaryWine,
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Icon(Icons.campaign, color: AppColors.divineGold, size: 20),
            ],
          ),
        ),
        announcementsAsync.when(
          loading: () => SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(right: 12),
                child: ShimmerLoading(width: 280, height: 180, borderRadius: 16),
              ),
            ),
          ),
          error: (err, _) => const SizedBox.shrink(),
          data: (items) {
            if (items.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final ann = items[index];

                  return Container(
                    width: 290,
                    margin: const EdgeInsets.only(right: 14, bottom: 8),
                    child: SacredCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AnnouncementDetailScreen(announcement: ann),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ann.isUrgent
                                      ? AppColors.liveRed.withOpacity(0.15)
                                      : AppColors.divineGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ann.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: ann.isUrgent ? AppColors.liveRed : AppColors.divineGoldDark,
                                  ),
                                ),
                              ),
                              if (ann.date != null)
                                Text(
                                  ann.date!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ann.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              ann.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Read more',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
