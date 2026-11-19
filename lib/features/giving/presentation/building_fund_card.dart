import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/upi_helper.dart';
import '../../../core/widgets/sacred_card.dart';

class BuildingFundCard extends StatelessWidget {
  const BuildingFundCard({super.key});

  @override
  Widget build(BuildContext context) {
    const target = AppConstants.vision2035TargetAmount;
    const collected = AppConstants.vision2035CollectedAmount;
    const progress = collected / target; // 0.435 (43.5%)

    return SacredCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Burgundy Header Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: AppColors.burgundyGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.divineGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'VISION 2035',
                        style: TextStyle(
                          color: AppColors.primaryBurgundyDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Icon(Icons.church, color: AppColors.divineGold, size: 24),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppConstants.vision2035Title,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.vision2035Subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Progress and details
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pledged & Collected:',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey),
                    ),
                    Text(
                      '₹4.35 Crores (${(progress * 100).toStringAsFixed(1)}%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.divineGoldDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Linear Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.divineGold),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Target Goal: ₹10.0 Crores',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Give Building Fund Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      UpiHelper.launchUpiPayment(
                        context: context,
                        appType: UpiAppType.generic,
                        amount: '2000',
                        note: 'Vision 2035 Building Fund - ${AppConstants.churchName}',
                      );
                    },
                    icon: const Icon(Icons.handshake, size: 18),
                    label: const Text('Partner With Vision 2035 (₹2,000)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryWine,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
