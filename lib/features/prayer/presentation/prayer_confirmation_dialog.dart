import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sacred_button.dart';

class PrayerConfirmationDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const PrayerConfirmationDialog({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebratory Cross / Hands Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.divineGold.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.volunteer_activism,
                size: 38,
                color: AppColors.primaryBurgundyDark,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Prayer Request Received',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.divineGold : AppColors.primaryWine,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Senior Pastor ${AppConstants.seniorPastor} and our pastoral intercessory prayer team will faithfully lift up your burden in prayer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
              ),
            ),

            const SizedBox(height: 18),

            // Comforting Scripture Promise Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardAlt
                    : AppColors.parchmentCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.divineGold.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '"Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God."',
                    textAlign: TextAlign.center,
                    style: AppTheme.scriptureEnStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '— Philippians 4:6',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.divineGoldLight : AppColors.divineGoldDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            SacredButton(
              label: 'Amen & Done',
              width: double.infinity,
              onPressed: onDismiss,
              variant: SacredButtonVariant.primaryWine,
            ),
          ],
        ),
      ),
    );
  }
}
