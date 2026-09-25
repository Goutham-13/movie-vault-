import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/media_item.dart';
import '../../data/models/collection_entry.dart';
import '../../providers/app_providers.dart';
import '../../widgets/star_rating_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../details/media_details_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedItems = ref.watch(watchedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Watch History'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: watchedItems.isEmpty
          ? const EmptyStateView(
              icon: Icons.history_rounded,
              title: "No Watch History Yet",
              description: "Movies and TV shows you mark as watched will build your timeline here.",
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: watchedItems.length,
              itemBuilder: (context, index) {
                final item = watchedItems[index];
                final media = item['media'] as MediaItem;
                final entry = item['entry'] as CollectionEntry;

                final watchedDate = entry.watchedAt ?? entry.lastUpdated;
                final timelineHeader = DateFormatter.formatWatchedTimelineHeader(watchedDate);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MediaDetailsScreen(mediaItem: media)),
                      );
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timelineHeader,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryAccent,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          DateFormatter.formatTime(watchedDate),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          media.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StarRatingBar(rating: entry.personalRating, starSize: 16),
                            const SizedBox(width: 8),
                            Text(
                              entry.personalRating > 0
                                  ? "${entry.personalRating.toStringAsFixed(1)} / 5.0"
                                  : "Unrated",
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
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
