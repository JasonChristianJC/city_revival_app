import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/share_helper.dart';
import '../../../core/widgets/sacred_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../data/announcement_repository.dart';
import '../domain/announcement.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  final Widget? drawer;

  const AnnouncementsScreen({super.key, this.drawer});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Fasting Prayer',
    'Sunday Live Alert',
    'Convention',
    'Youth Meeting',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: widget.drawer,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'ANNOUNCEMENTS',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 16,
              ),
            ),
            Text(
              'திருச்சபை அறிவிப்புகள் • City Revival AG',
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
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Announcements',
            onPressed: () {
              ref.invalidate(announcementsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(announcementsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Category filter chips
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                          selectedColor: AppColors.primaryWine,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.divineGold
                                  : (isDark ? Colors.white12 : Colors.grey.shade300),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Announcement Items List
            announcementsAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ShimmerLoading(width: double.infinity, height: 180, borderRadius: 16),
                  ),
                  childCount: 4,
                ),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.liveRed),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load announcements',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(announcementsProvider),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                final filtered = _selectedCategory == 'All'
                    ? items
                    : items.where((i) => i.category == _selectedCategory).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 64,
                            color: isDark ? Colors.white24 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No announcements in $_selectedCategory',
                            style: GoogleFonts.cinzel(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Check back soon for church updates and notices',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final announcement = filtered[index];
                        return _buildAnnouncementCard(
                          context: context,
                          announcement: announcement,
                          isDark: isDark,
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required BuildContext context,
    required ChurchAnnouncement announcement,
    required bool isDark,
  }) {
    return SacredCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnnouncementDetailScreen(announcement: announcement),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional Flyer Image
          if (announcement.flyerUrl != null && announcement.flyerUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: announcement.flyerUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: announcement.isUrgent
                            ? AppColors.liveRed.withOpacity(0.12)
                            : AppColors.primaryWine.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: announcement.isUrgent
                              ? AppColors.liveRed.withOpacity(0.4)
                              : AppColors.divineGold.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            announcement.isUrgent ? Icons.priority_high : Icons.label_important,
                            size: 13,
                            color: announcement.isUrgent ? AppColors.liveRed : AppColors.primaryWine,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            announcement.isUrgent ? 'URGENT NOTICE' : announcement.category,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: announcement.isUrgent ? AppColors.liveRed : AppColors.primaryWine,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (announcement.date != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            announcement.date!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // English Title
                Text(
                  announcement.title,
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    color: isDark ? AppColors.divineGoldLight : AppColors.primaryWine,
                  ),
                ),

                // Tamil Title
                if (announcement.titleTa.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    announcement.titleTa,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Excerpt
                Text(
                  announcement.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark ? Colors.white60 : Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        foregroundColor: isDark ? AppColors.divineGold : AppColors.primaryWine,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text(
                        'Read Full Notice',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnnouncementDetailScreen(announcement: announcement),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 19),
                      tooltip: 'Share Announcement',
                      onPressed: () {
                        final text = '''
📢 *${announcement.title}*
${announcement.date != null ? "📅 Date: ${announcement.date}\n" : ""}${announcement.description}

✝️ *${AppConstants.churchName}*
Senior Pastor: ${AppConstants.seniorPastor}
''';
                        ShareHelper.shareGeneral(message: text, subject: announcement.title);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
