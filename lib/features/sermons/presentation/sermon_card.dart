import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sacred_card.dart';
import '../domain/sermon.dart';
import 'sermon_player_screen.dart';

class SermonCard extends StatelessWidget {
  final Sermon sermon;

  const SermonCard({super.key, required this.sermon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SacredCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SermonPlayerScreen(sermon: sermon),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with play button overlay
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: sermon.thumbnailUrl,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 170,
                    color: Colors.grey.shade300,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 170,
                    color: AppColors.primaryBurgundyDark,
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, size: 54, color: AppColors.divineGold),
                    ),
                  ),
                ),
              ),

              // Dark overlay with Play icon
              Container(
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.black.withOpacity(0.35),
                ),
              ),

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryWine.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divineGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              // Speaker Tag on top left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBurgundyDark.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.divineGold.withOpacity(0.5)),
                  ),
                  child: Text(
                    sermon.speaker,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Date Tag on top right
              if (sermon.date.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sermon.date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sermon.titleEn,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sermon.titleTa.isNotEmpty && sermon.titleTa != sermon.titleEn) ...[
                  const SizedBox(height: 4),
                  Text(
                    sermon.titleTa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.tamilTextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.divineGoldLight : AppColors.divineGoldDark,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (sermon.scripture.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.menu_book, size: 14, color: AppColors.divineGold),
                          const SizedBox(width: 4),
                          Text(
                            sermon.scripture,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.divineGoldDark,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    const Row(
                      children: [
                        Text(
                          'Watch Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryWine,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryWine),
                      ],
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
