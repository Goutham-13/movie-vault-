import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/models/media_item.dart';
import '../../../data/models/collection_entry.dart';

class MediaFileCardWidget extends StatelessWidget {
  final MediaItem media;
  final CollectionEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MediaFileCardWidget({
    super.key,
    required this.media,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = ApiConstants.getPosterUrl(media.posterPath, quality: 'w185');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // File Document Thumbnail Preview Sleeve
              Container(
                width: 60,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: posterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: posterUrl,
                              width: 60,
                              height: 84,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.cardElevated),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.cardElevated,
                                child: const Icon(CupertinoIcons.film, color: AppColors.textMuted, size: 24),
                              ),
                            )
                          : Container(
                              color: AppColors.cardElevated,
                              child: const Icon(CupertinoIcons.film, color: AppColors.textMuted, size: 24),
                            ),
                    ),
                    // File Corner Tag
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.doc_text_fill,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // File Metadata Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File Name
                    Text(
                      media.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // File Meta (Type, Year, Duration)
                    Text(
                      '${media.mediaType.toUpperCase()} • ${media.year ?? '2024'} • ${DurationFormatter.formatMinutes(media.runtime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating & File Tag
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.star_fill, size: 12, color: AppColors.amberRating),
                              const SizedBox(width: 4),
                              Text(
                                entry.personalRating > 0
                                    ? entry.personalRating.toStringAsFixed(1)
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: entry.status == 'watched'
                                ? AppColors.emeraldSuccess.withOpacity(0.2)
                                : entry.status == 'watching'
                                    ? AppColors.watchingChip.withOpacity(0.2)
                                    : AppColors.wishlistChip.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: entry.status == 'watched'
                                  ? AppColors.emeraldSuccess
                                  : entry.status == 'watching'
                                      ? AppColors.watchingChip
                                      : AppColors.wishlistChip,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete / Option Button with iOS Trash Icon
              IconButton(
                icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
