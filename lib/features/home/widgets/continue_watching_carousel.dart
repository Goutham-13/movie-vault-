import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/media_item.dart';
import '../../../data/models/watch_progress.dart';

class ContinueWatchingCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(MediaItem media, WatchProgress? progress) onResume;

  const ContinueWatchingCarousel({
    super.key,
    required this.items,
    required this.onResume,
  });

  @override
  State<ContinueWatchingCarousel> createState() => _ContinueWatchingCarouselState();
}

class _ContinueWatchingCarouselState extends State<ContinueWatchingCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryAccent, size: 22),
              SizedBox(width: 8),
              Text(
                "Continue Watching",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final media = item['media'] as MediaItem;
              final progress = item['progress'] as WatchProgress?;
              final isFocused = _currentPage == index;

              final backdropUrl = ApiConstants.getBackdropUrl(media.backdropPath);
              final posterUrl = ApiConstants.getPosterUrl(media.posterPath, quality: 'w185');

              final percent = progress?.progressPercentage ?? 0.0;
              final posSec = progress?.currentPositionSeconds ?? 0;
              final totalSec = progress?.totalDurationSeconds ?? (media.runtime ?? 120) * 60;

              String tvSubtitle = '';
              if (media.mediaType == 'tv' && progress != null) {
                tvSubtitle = 'S${progress.currentSeason?.toString().padLeft(2, '0') ?? '01'} • E${progress.currentEpisode?.toString().padLeft(2, '0') ?? '01'}  |  ';
              }

              return AnimatedScale(
                scale: isFocused ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withOpacity(isFocused ? 0.25 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Backdrop Image with Dark Overlay
                        Positioned.fill(
                          child: backdropUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: backdropUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: AppColors.cardElevated),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xEE07080C),
                                  Color(0x9907080C),
                                  Color(0xCC07080C),
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                          ),
                        ),

                        // Card Content (Floating Poster + Media Info + Resume Button)
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Floating Poster Artwork
                                Container(
                                  width: 95,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.6),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: posterUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: posterUrl,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(color: AppColors.cardBorder),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Text Details & Controls
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Media Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryAccent.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          media.mediaType == 'tv' ? 'TV SHOW' : 'MOVIE',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // Title
                                      Text(
                                        media.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Episode / Progress text
                                      Text(
                                        '$tvSubtitle${percent.toInt()}% watched',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondaryAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      Text(
                                        '${DurationFormatter.formatSeconds(posSec)} / ${DurationFormatter.formatSeconds(totalSec)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Progress bar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: (percent / 100.0).clamp(0.0, 1.0),
                                          minHeight: 5,
                                          backgroundColor: AppColors.glassBorder,
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // Resume Button
                                      ElevatedButton.icon(
                                        onPressed: () => widget.onResume(media, progress),
                                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                        label: const Text('Resume'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          elevation: 4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
