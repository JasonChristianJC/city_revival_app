import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_helper.dart';
import '../../../core/widgets/sacred_card.dart';
import '../domain/sermon.dart';

class SermonPlayerScreen extends StatefulWidget {
  final Sermon sermon;

  const SermonPlayerScreen({super.key, required this.sermon});

  @override
  State<SermonPlayerScreen> createState() => _SermonPlayerScreenState();
}

class _SermonPlayerScreenState extends State<SermonPlayerScreen> {
  late YoutubePlayerController _ytController;
  bool _isAudioOnly = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: widget.sermon.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        forceHD: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_ytController.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _ytController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _ytController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.divineGold,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primaryWine,
          handleColor: AppColors.divineGold,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sermon Hub'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share Sermon',
                onPressed: () {
                  final text = '''
✝️ *${widget.sermon.titleEn}*
${widget.sermon.titleTa.isNotEmpty ? "${widget.sermon.titleTa}\n" : ""}
Speaker: ${widget.sermon.speaker}
${widget.sermon.scripture.isNotEmpty ? "Scripture: ${widget.sermon.scripture}\n" : ""}
Watch here: ${widget.sermon.youtubeUrl}

*${AppConstants.churchName}*
''';
                  ShareHelper.shareGeneral(message: text, subject: widget.sermon.titleEn);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Player or Audio-Only Visualizer
                if (!_isAudioOnly)
                  player
                else
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: AppColors.burgundyGradient,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.headphones,
                          size: 54,
                          color: AppColors.divineGold,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'AUDIO LISTENING MODE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Saving data • High fidelity audio stream',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        IconButton(
                          iconSize: 42,
                          color: AppColors.divineGold,
                          icon: Icon(
                            _ytController.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                          ),
                          onPressed: () {
                            setState(() {
                              _ytController.value.isPlaying
                                  ? _ytController.pause()
                                  : _ytController.play();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // Controls row: Audio Mode Toggle & Fullscreen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Audio Mode Toggle
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          setState(() {
                            _isAudioOnly = !_isAudioOnly;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isAudioOnly
                                ? AppColors.divineGold.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isAudioOnly ? AppColors.divineGold : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isAudioOnly ? Icons.headphones : Icons.videocam,
                                size: 16,
                                color: _isAudioOnly ? AppColors.divineGoldDark : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isAudioOnly ? 'Audio Mode Active' : 'Switch to Audio Mode',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _isAudioOnly ? AppColors.divineGoldDark : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Speaker Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWine.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.sermon.speaker,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.divineGoldLight : AppColors.primaryWine,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Sermon Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title English
                      Text(
                        widget.sermon.titleEn,
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primaryWine,
                        ),
                      ),

                      // Title Tamil
                      if (widget.sermon.titleTa.isNotEmpty &&
                          widget.sermon.titleTa != widget.sermon.titleEn) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.sermon.titleTa,
                          style: AppTheme.tamilTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.divineGoldLight : AppColors.divineGoldDark,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Metadata chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (widget.sermon.scripture.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.menu_book,
                              label: widget.sermon.scripture,
                              color: AppColors.divineGoldDark,
                            ),
                          if (widget.sermon.date.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.calendar_today,
                              label: widget.sermon.date,
                              color: Colors.grey.shade700,
                            ),
                          if (widget.sermon.series.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.bookmark,
                              label: widget.sermon.series,
                              color: AppColors.primaryWine,
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      if (widget.sermon.descriptionEn.isNotEmpty ||
                          widget.sermon.descriptionTa.isNotEmpty) ...[
                        SacredCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sermon Summary & Notes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (widget.sermon.descriptionEn.isNotEmpty)
                                Text(
                                  widget.sermon.descriptionEn,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                  ),
                                ),
                              if (widget.sermon.descriptionTa.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  widget.sermon.descriptionTa,
                                  style: AppTheme.tamilTextStyle(
                                    fontSize: 13.5,
                                    color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Church Footer banner
                      SacredCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.church, color: AppColors.divineGold, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppConstants.churchName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Senior Pastor: ${AppConstants.seniorPastor}',
                                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
