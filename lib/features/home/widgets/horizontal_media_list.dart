import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/skeleton_loader.dart';
import 'floating_poster_card.dart';

class HorizontalMediaList extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<MediaItem>? items;
  final List<Map<String, dynamic>>? collectionItems;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final Function(MediaItem media) onMediaTap;

  const HorizontalMediaList({
    super.key,
    required this.title,
    this.subtitle,
    this.items,
    this.collectionItems,
    this.isLoading = false,
    this.onSeeAll,
    required this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 260,
          child: isLoading
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(right: 14),
                    child: const SkeletonLoader(width: 135, height: 200),
                  ),
                )
              : items != null
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items!.length,
                      itemBuilder: (context, index) {
                        final media = items![index];
                        return FloatingPosterCard(
                          media: media,
                          onTap: () => onMediaTap(media),
                        );
                      },
                    )
                  : collectionItems != null
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: collectionItems!.length,
                          itemBuilder: (context, index) {
                            final item = collectionItems![index];
                            final media = item['media'] as MediaItem;
                            final entry = item['entry'];
                            return FloatingPosterCard(
                              media: media,
                              personalRating: entry.personalRating > 0 ? entry.personalRating : null,
                              badgeText: entry.status.toUpperCase(),
                              badgeColor: entry.status == 'watched'
                                  ? AppColors.emeraldSuccess
                                  : entry.status == 'watching'
                                      ? AppColors.watchingChip
                                      : AppColors.wishlistChip,
                              onTap: () => onMediaTap(media),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
