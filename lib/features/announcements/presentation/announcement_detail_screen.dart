import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_helper.dart';
import '../../../core/widgets/sacred_card.dart';
import '../domain/announcement.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final ChurchAnnouncement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(announcement.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final text = '''
📢 *${announcement.title}*
${announcement.date != null ? "📅 Date: ${announcement.date}\n" : ""}
${announcement.description}

✝️ *${AppConstants.churchName}*
Senior Pastor: ${AppConstants.seniorPastor}
''';
              ShareHelper.shareGeneral(message: text, subject: announcement.title);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.flyerUrl != null && announcement.flyerUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: announcement.flyerUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 220,
                    color: AppColors.primaryBurgundyDark,
                    child: const Center(
                      child: Icon(Icons.campaign, size: 48, color: AppColors.divineGold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Category & Date Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: announcement.isUrgent
                        ? AppColors.liveRed.withOpacity(0.15)
                        : AppColors.divineGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: announcement.isUrgent ? AppColors.liveRed : AppColors.divineGold,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    announcement.category.toUpperCase(),
                    style: TextStyle(
                      color: announcement.isUrgent ? AppColors.liveRed : AppColors.divineGoldDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (announcement.date != null) ...[
                  const SizedBox(width: 10),
                  Icon(
                    Icons.event,
                    size: 16,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    announcement.date!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Title English
            Text(
              announcement.title,
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryWine,
              ),
            ),

            // Title Tamil
            if (announcement.titleTa.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                announcement.titleTa,
                style: AppTheme.tamilTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.divineGoldLight : AppColors.divineGoldDark,
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Description English
            Text(
              announcement.description,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textPrimaryLight,
              ),
            ),

            // Description Tamil
            if (announcement.descriptionTa.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                announcement.descriptionTa,
                style: AppTheme.tamilTextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: isDark ? Colors.white.withOpacity(0.85) : AppColors.textPrimaryLight,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Church branding footer card
            SacredCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.church, color: AppColors.divineGold, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.churchName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Senior Pastor: ${AppConstants.seniorPastor}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
