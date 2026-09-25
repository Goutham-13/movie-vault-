import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/skeleton_loader.dart';

class HeroReleaseCarousel extends StatefulWidget {
  final List<MediaItem>? items;
  final bool isLoading;
  final Function(MediaItem media) onMediaTap;
  final Function(MediaItem media)? onFavoriteToggle;

  const HeroReleaseCarousel({
    super.key,
    required this.items,
    this.isLoading = false,
    required this.onMediaTap,
    this.onFavoriteToggle,
  });

  @override
  State<HeroReleaseCarousel> createState() => _HeroReleaseCarouselState();
}

class _HeroReleaseCarouselState extends State<HeroReleaseCarousel> {
  static const int _kInfinitePages = 10000;
  late PageController _pageController;
  int _currentPage = _kInfinitePages ~/ 2;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.74, initialPage: _currentPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final list = widget.items ?? [];
      if (list.length <= 1 || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        height: 410,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Center(
          child: SkeletonLoader(width: 260, height: 380, borderRadius: 28),
        ),
      );
    }

    final mediaList = widget.items ?? [];
    if (mediaList.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 420,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _kInfinitePages,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final actualIndex = index % mediaList.length;
          final media = mediaList[actualIndex];
          final isFocused = (_currentPage % mediaList.length) == actualIndex;
          final posterUrl = ApiConstants.getPosterUrl(media.posterPath, quality: 'w500');

          return AnimatedScale(
            scale: isFocused ? 1.0 : 0.88,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTap: () => widget.onMediaTap(media),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Oversized Poster Card with Rank Badge & iOS Heart Button
                  Container(
                    height: 340,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withOpacity(isFocused ? 0.35 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Poster Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: posterUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: posterUrl,
                                  width: double.infinity,
                                  height: 340,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: AppColors.cardElevated),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppColors.cardElevated,
                                    child: const Center(
                                      child: Icon(CupertinoIcons.film, size: 48, color: AppColors.textMuted),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.cardElevated,
                                  child: const Center(
                                    child: Icon(CupertinoIcons.film, size: 48, color: AppColors.textMuted),
                                  ),
                                ),
                        ),

                        // Top-Left Oversized Rank Badge ("1", "2", "3")
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${actualIndex + 1}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Top-Right Favorite iOS Heart Button
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () {
                                if (widget.onFavoriteToggle != null) {
                                  widget.onFavoriteToggle!(media);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title & Age Rating Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          media.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          media.adult ? '18+' : '15',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Runtime & Rating Subtitle
                  Text(
                    '★ ${media.voteAverage.toStringAsFixed(1)}  •  ${DurationFormatter.formatMinutes(media.runtime)}  •  ${media.year ?? '2024'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
