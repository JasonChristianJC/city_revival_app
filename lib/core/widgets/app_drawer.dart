import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.velvetCharcoal : AppColors.parchmentCream,
      child: Column(
        children: [
          // ─── Prestigious Sacred Header ───────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6F1728), Color(0xFF380812)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Church Logo / Crest
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: AppColors.divineGold,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.divineGold.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/church_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.church,
                            color: AppColors.divineGold,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CITY REVIVAL AG',
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'CHURCH • TIRUCHI',
                            style: GoogleFonts.cinzel(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.divineGoldLight,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppConstants.seniorPastor,
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Live broadcast tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.divineGold.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Tiruchirappalli, Tamil Nadu, India',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Menu Navigation Items ──────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home_rounded,
                  title: 'Home',
                  subtitle: 'முகப்பு • Daily Verse & Highlights',
                  index: 0,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.campaign_rounded,
                  title: 'Announcements',
                  subtitle: 'அறிவிப்புகள் • Church News & Events',
                  index: 1,
                  badge: 'NEW',
                  badgeColor: AppColors.primaryWine,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.play_circle_filled_rounded,
                  title: 'Sermons & Live',
                  subtitle: 'பிரசங்கங்கள் • Video Hub & Archive',
                  index: 2,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.auto_stories_rounded,
                  title: 'Church Magazine',
                  subtitle: 'பரிபூரண ஜீவன் • Paripoorana Jeevan',
                  index: 3,
                  isDark: isDark,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.favorite_rounded,
                  title: 'Prayer & Giving',
                  subtitle: 'ஜெப விண்ணப்பம் & காணிக்கை',
                  index: 4,
                  isDark: isDark,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Divider(thickness: 0.8),
                ),

                // ─── Ministry & Connect Section ─────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 14, bottom: 6),
                  child: Text(
                    'CHURCH & COMMUNITY',
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                    ),
                  ),
                ),
                _buildActionItem(
                  icon: Icons.schedule_rounded,
                  title: 'Service Timings',
                  subtitle: 'Sunday: 6:00 AM, 8:30 AM, 10:45 AM',
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    _showServiceTimingsDialog(context);
                  },
                ),
                _buildActionItem(
                  icon: Icons.location_on_rounded,
                  title: 'Directions to Church',
                  subtitle: 'Near TVS Tollgate / Cantonment, Trichy',
                  isDark: isDark,
                  onTap: () async {
                    Navigator.pop(context);
                    final mapUri = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=City+Revival+AG+Church+Trichy',
                    );
                    if (await canLaunchUrl(mapUri)) {
                      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                _buildActionItem(
                  icon: Icons.chat_bubble_rounded,
                  title: 'WhatsApp Pastor Helpdesk',
                  subtitle: '+91 94431 00000',
                  iconColor: const Color(0xFF25D366),
                  isDark: isDark,
                  onTap: () async {
                    Navigator.pop(context);
                    final uri = Uri.parse('https://wa.me/919443100000?text=Praise+The+Lord+Pastor');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                _buildActionItem(
                  icon: Icons.smart_display_rounded,
                  title: 'Official YouTube Channel',
                  subtitle: 'Watch Live Broadcasts & Sermons',
                  iconColor: const Color(0xFFE11D48),
                  isDark: isDark,
                  onTap: () async {
                    Navigator.pop(context);
                    final uri = Uri.parse(AppConstants.youtubeChannelUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),

          // ─── Footer ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13151C) : Colors.white.withOpacity(0.7),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'City Revival App',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.primaryWine,
                      ),
                    ),
                    Text(
                      'Version 1.0.0 • Tiruchirappalli',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isDark ? Colors.white38 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.verified,
                  color: AppColors.divineGold,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required bool isDark,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            onSelectTab(index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? AppColors.primaryWine.withOpacity(0.35)
                      : AppColors.primaryWine.withOpacity(0.10))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppColors.divineGold.withOpacity(0.6),
                      width: 1.2,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryWine
                        : (isDark ? Colors.white10 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.divineGold
                        : (isDark ? Colors.white70 : AppColors.primaryWine),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? AppColors.divineGoldLight : AppColors.primaryWine)
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor ?? AppColors.divineGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.divineGold,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: iconColor ?? (isDark ? AppColors.divineGold : AppColors.primaryWine),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceTimingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, color: AppColors.divineGold, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'SUNDAY SERVICE TIMINGS',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              ...AppConstants.sundayServices.map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            s.nameTa,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWine.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.divineGold.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          s.time,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? AppColors.divineGoldLight : AppColors.primaryWine,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
