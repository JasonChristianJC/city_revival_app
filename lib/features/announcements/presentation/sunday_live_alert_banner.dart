import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/live_badge.dart';

class SundayLiveAlertBanner extends StatelessWidget {
  const SundayLiveAlertBanner({super.key});

  bool _isCurrentlySundayService() {
    final now = DateTime.now();
    // Sunday is weekday 7
    if (now.weekday == DateTime.sunday) {
      final hour = now.hour;
      final minute = now.minute;
      final totalMinutes = hour * 60 + minute;
      // Between 5:50 AM (350 mins) and 12:30 PM (750 mins)
      if (totalMinutes >= 350 && totalMinutes <= 750) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLive = _isCurrentlySundayService();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: isLive ? AppColors.burgundyGradient : null,
        color: isLive ? null : const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppColors.divineGold : AppColors.divineGold.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final uri = Uri.parse(AppConstants.youtubeChannelUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isLive ? AppColors.liveRed : AppColors.divineGold).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLive ? Icons.sensors : Icons.access_time_filled,
                    color: isLive ? AppColors.liveRed : AppColors.divineGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isLive) ...[
                            const LiveBadge(text: 'STREAMING NOW'),
                            const SizedBox(width: 8),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.divineGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SUNDAY SERVICES',
                                style: TextStyle(
                                  color: AppColors.divineGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLive ? 'Sunday Live Broadcast' : 'Sunday Live: 6:00 AM • 8:30 AM • 10:45 AM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLive
                            ? 'Watch Rev. Dr. Jerry Daniel preaching live now'
                            : 'Broadcast alerts enabled for phone lock screen',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.youtube,
                    color: Colors.white,
                    size: 18,
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
