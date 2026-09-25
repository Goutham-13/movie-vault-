import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/media_item.dart';
import '../../providers/app_providers.dart';
import '../../widgets/skeleton_loader.dart';
import '../details/media_details_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final collectionState = ref.watch(collectionProvider);

    // Map existing collection items for quick status lookup
    final collectionMap = <String, Map<String, dynamic>>{};
    collectionState.whenData((items) {
      for (final item in items) {
        final media = item['media'] as MediaItem;
        collectionMap[media.localId] = item;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search CineVault'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Large Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).state = val;
              },
              decoration: InputDecoration(
                hintText: 'Search movies, TV shows, anime...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAccent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Search Results View
          Expanded(
            child: searchResultsAsync.when(
              data: (results) {
                if (_searchController.text.trim().isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 16),
                        Text(
                          "Type to search movies & TV shows",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                if (results.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied_rounded, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 16),
                        Text(
                          "No results found on TMDB",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final media = results[index];
                    final posterUrl = ApiConstants.getPosterUrl(media.posterPath, quality: 'w185');
                    final collectionData = collectionMap[media.localId];
                    final currentStatus = collectionData?['entry']?.status;
                    final isFav = collectionData?['entry']?.isFavorite ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MediaDetailsScreen(mediaItem: media),
                            ),
                          );
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 50,
                            height: 75,
                            child: posterUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: posterUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: AppColors.cardElevated),
                          ),
                        ),
                        title: Text(
                          media.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${media.mediaType.toUpperCase()} • ${media.year ?? 'N/A'} • ${media.originalLanguage?.toUpperCase() ?? 'EN'}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 8),

                            // Dynamic Status Actions
                            Row(
                              children: [
                                _ActionChip(
                                  label: '+ Wishlist',
                                  isActive: currentStatus == 'wishlist',
                                  activeColor: AppColors.wishlistChip,
                                  onTap: () {
                                    ref.read(collectionProvider.notifier).updateStatus(media, 'wishlist');
                                  },
                                ),
                                const SizedBox(width: 6),
                                _ActionChip(
                                  label: '+ Watching',
                                  isActive: currentStatus == 'watching',
                                  activeColor: AppColors.watchingChip,
                                  onTap: () {
                                    ref.read(collectionProvider.notifier).updateStatus(media, 'watching');
                                  },
                                ),
                                const SizedBox(width: 6),
                                _ActionChip(
                                  label: '✓ Watched',
                                  isActive: currentStatus == 'watched',
                                  activeColor: AppColors.watchedChip,
                                  onTap: () {
                                    ref.read(collectionProvider.notifier).updateStatus(media, 'watched');
                                  },
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFav ? AppColors.favoritePink : AppColors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    ref.read(collectionProvider.notifier).toggleFavorite(media);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: const SkeletonLoader(width: double.infinity, height: 90),
                ),
              ),
              error: (err, stack) => Center(
                child: Text('Search Error: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
