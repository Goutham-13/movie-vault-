import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/media_item.dart';

class FloatingPosterCard extends StatelessWidget {
  final MediaItem media;
  final VoidCallback onTap;
  final double width;
  final double height;
  final String? badgeText;
  final Color? badgeColor;
  final double? personalRating;

  const FloatingPosterCard({
    super.key,
    required this.media,
    required this.onTap,
    this.width = 135,
    this.height = 200,
    this.badgeText,
    this.badgeColor,
    this.personalRating,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = ApiConstants.getPosterUrl(media.posterPath, quality: 'w342');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height + 56,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Container with Floating Shadow & Rounded Corners
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Poster Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: posterUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            width: width,
                            height: height,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.cardElevated,
                              child: const Center(
                                child: Icon(Icons.movie_rounded, color: AppColors.textMuted),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.cardElevated,
                              child: const Center(
                                child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.cardElevated,
                            child: const Center(
                              child: Icon(Icons.movie_rounded, color: AppColors.textMuted),
                            ),
                          ),
                  ),

                  // Top Media Type / Custom Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.overlayDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder, width: 0.8),
                      ),
                      child: Text(
                        badgeText ?? media.mediaType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Rating Chip or Personal Rating Stars
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: personalRating != null
                                ? AppColors.amberRating
                                : AppColors.amberRating,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            personalRating != null
                                ? personalRating!.toStringAsFixed(1)
                                : media.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              media.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle (Year & Genre)
            Text(
              '${media.year ?? 'N/A'} • ${media.genres.isNotEmpty ? media.genres.first : 'Cinema'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
