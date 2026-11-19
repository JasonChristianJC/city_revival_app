import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sacred_card.dart';
import '../data/magazine_repository.dart';
import '../domain/magazine.dart';
import 'pdf_reader_screen.dart';

class MagazineCard extends ConsumerStatefulWidget {
  final Magazine magazine;

  const MagazineCard({super.key, required this.magazine});

  @override
  ConsumerState<MagazineCard> createState() => _MagazineCardState();
}

class _MagazineCardState extends ConsumerState<MagazineCard> {
  bool _isDownloading = false;
  double _progress = 0.0;

  Future<void> _handleDownload() async {
    final downloadService = ref.read(magazineDownloadServiceProvider);

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
    });

    try {
      await downloadService.downloadMagazine(
        widget.magazine,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p;
            });
          }
        },
      );
      if (mounted) {
        ref.invalidate(magazinesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.magazine.issuePeriod} ${widget.magazine.year} saved for offline reading!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: AppColors.liveRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SacredCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PdfReaderScreen(magazine: widget.magazine),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Magazine Cover Header
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: AppColors.burgundyGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // Background pattern / icon
                Positioned(
                  right: -10,
                  bottom: -15,
                  child: Icon(
                    Icons.auto_stories,
                    size: 130,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            child: Text(
                              widget.magazine.issuePeriod.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryBurgundyDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.magazine.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'பரிபூரண ஜீவன்',
                            style: GoogleFonts.muktaMalar(
                              color: AppColors.divineGoldLight,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PARIPOORANA JEEVAN',
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Download progress indicator
          if (_isDownloading)
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.divineGold),
            ),

          // Content info & Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.magazine.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (widget.magazine.isDownloaded) ...[
                            const Icon(
                              Icons.offline_pin,
                              size: 15,
                              color: AppColors.successGreen,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Downloaded for offline reading',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.cloud_outlined,
                              size: 15,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Available to download',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white54 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Download icon button
                if (!widget.magazine.isDownloaded)
                  IconButton(
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download, color: AppColors.primaryWine),
                    tooltip: 'Download for Offline Reading',
                    onPressed: _isDownloading ? null : _handleDownload,
                  ),

                // Read Button
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfReaderScreen(magazine: widget.magazine),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryWine,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Read'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
