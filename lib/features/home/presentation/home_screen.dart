import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/sacred_card.dart';
import '../../announcements/presentation/announcement_feed.dart';
import '../../announcements/presentation/sunday_live_alert_banner.dart';
import '../../daily_verse/presentation/daily_verse_card.dart';
import '../../giving/presentation/building_fund_card.dart';
import '../../sermons/data/sermon_repository.dart';
import '../../sermons/presentation/sermon_card.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(int tabIndex) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSermons = ref.watch(sermonsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'CITY REVIVAL AG CHURCH',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Tiruchirappalli • Senior Pastor Rev. Dr. Jerry Daniel',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: AppColors.divineGoldLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Church Location',
            onPressed: () async {
              final mapUri = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=City+Revival+AG+Church+Trichy',
              );
              if (await canLaunchUrl(mapUri)) {
                await launchUrl(mapUri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sermonsProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Feature 1: Daily Promise Verse (Tamil & English Together)
              const DailyVerseCard(),

              // Feature 2: Sunday Live Broadcast Alert Banner
              const SundayLiveAlertBanner(),

              // Quick Action Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildQuickAction(
                      icon: Icons.video_library,
                      label: 'Sermons',
                      color: AppColors.primaryWine,
                      onTap: () => onNavigateTab(1),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAction(
                      icon: Icons.auto_stories,
                      label: 'Magazines',
                      color: AppColors.divineGoldDark,
                      onTap: () => onNavigateTab(2),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAction(
                      icon: Icons.volunteer_activism,
                      label: 'Give UPI',
                      color: const Color(0xFF16A34A),
                      onTap: () => onNavigateTab(3),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAction(
                      icon: Icons.lock_person,
                      label: 'Prayer',
                      color: const Color(0xFF7C3AED),
                      onTap: () => onNavigateTab(3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Feature 2: Instant Announcements Feed
              const AnnouncementFeed(),

              const SizedBox(height: 16),

              // Recent Sermons Section (Feature 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT SERMONS',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onNavigateTab(1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),

              recentSermons.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (sermons) {
                  if (sermons.isEmpty) return const SizedBox.shrink();
                  final displayList = sermons.take(2).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: displayList.map((s) => SermonCard(sermon: s)).toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Vision 2035 Church Building Fund Card (Feature 5)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: BuildingFundCard(),
              ),

              const SizedBox(height: 16),

              // Church Timings Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SacredCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: AppColors.divineGold, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'SUNDAY SERVICE SCHEDULE',
                            style: GoogleFonts.cinzel(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      ...AppConstants.sundayServices.map((service) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    service.nameTa,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? Colors.white60 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.divineGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  service.time,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isDark ? AppColors.divineGoldLight : AppColors.divineGoldDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.25), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
