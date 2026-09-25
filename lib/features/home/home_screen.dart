import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/media_item.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_view.dart';
import 'widgets/continue_watching_carousel.dart';
import 'widgets/hero_release_carousel.dart';
import 'widgets/quick_reminders_bar.dart';
import 'widgets/horizontal_media_list.dart';
import '../search/search_screen.dart';
import '../details/media_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToDiscover;

  const HomeScreen({super.key, required this.onNavigateToDiscover});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning, Goutham";
    } else if (hour < 17) {
      return "Good afternoon, Goutham";
    } else {
      return "Good evening, Goutham";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continueWatchingItems = ref.watch(continueWatchingProvider);
    final wishlistItems = ref.watch(wishlistProvider);
    final watchedItems = ref.watch(watchedProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final newReleasesAsync = ref.watch(newReleasesProvider);
    final trendingAsync = ref.watch(trendingMediaProvider);

    final hasPersonalContent = continueWatchingItems.isNotEmpty ||
        wishlistItems.isNotEmpty ||
        watchedItems.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendingMediaProvider);
            ref.invalidate(newReleasesProvider);
            await ref.read(collectionProvider.notifier).loadCollection();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Dynamic Greeting & Notification Badge
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Welcome to your personal cinema vault",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // iOS Notification Icon Badge
                      remindersAsync.when(
                        data: (reminders) => Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.cardElevated,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: IconButton(
                                icon: const Icon(CupertinoIcons.bell, color: AppColors.textPrimary, size: 22),
                                onPressed: () {},
                              ),
                            ),
                            if (reminders.isNotEmpty)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${reminders.length}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),

                // Compact Search Field Trigger with iOS Search Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.search, color: AppColors.primaryAccent, size: 22),
                          SizedBox(width: 12),
                          Text(
                            "Search movies, shows, anime...",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Top Auto-Moving Continuous Hero Carousel (No category tabs, no start watching button)
                newReleasesAsync.when(
                  data: (items) => HeroReleaseCarousel(
                    items: items,
                    onMediaTap: (media) => _openMediaDetails(context, media),
                    onFavoriteToggle: (media) {
                      ref.read(collectionProvider.notifier).toggleFavorite(media);
                    },
                  ),
                  loading: () => HeroReleaseCarousel(
                    items: const [],
                    isLoading: true,
                    onMediaTap: _noop,
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // 2. Continue Watching Carousel
                if (continueWatchingItems.isNotEmpty) ...[
                  ContinueWatchingCarousel(
                    items: continueWatchingItems,
                    onResume: (media, progress) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MediaDetailsScreen(mediaItem: media),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 3. Active Reminders Section
                remindersAsync.when(
                  data: (reminders) {
                    if (reminders.isEmpty) return const SizedBox.shrink();
                    return QuickRemindersBar(
                      reminders: reminders,
                      onDelete: (reminder) {
                        ref.read(reminderRepositoryProvider).deleteReminder(reminder.notificationId);
                        ref.invalidate(remindersProvider);
                      },
                      onOpen: (reminder) {},
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // 4. Recently Watched Carousel
                if (watchedItems.isNotEmpty) ...[
                  HorizontalMediaList(
                    title: "Recently Watched",
                    subtitle: "Your personal history",
                    collectionItems: watchedItems,
                    onMediaTap: (media) => _openMediaDetails(context, media),
                  ),
                  const SizedBox(height: 24),
                ],

                // 5. Trending Worldwide Carousel
                trendingAsync.when(
                  data: (items) => HorizontalMediaList(
                    title: "Trending Movies & TV",
                    items: items,
                    onMediaTap: (media) => _openMediaDetails(context, media),
                  ),
                  loading: () => const HorizontalMediaList(
                    title: "Trending Movies & TV",
                    isLoading: true,
                    onMediaTap: _noop,
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // 6. Wishlist Carousel
                if (wishlistItems.isNotEmpty) ...[
                  HorizontalMediaList(
                    title: "From Your Wishlist",
                    collectionItems: wishlistItems,
                    onMediaTap: (media) => _openMediaDetails(context, media),
                  ),
                  const SizedBox(height: 24),
                ],

                // Empty Collection State CTA if user hasn't added anything yet
                if (!hasPersonalContent)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: EmptyStateView(
                      icon: CupertinoIcons.film,
                      title: "Your Cinema Vault is Ready",
                      description: "Search movies or explore new releases to start building your personal watchlist and continue-watching library.",
                      buttonText: "Discover Movies",
                      onButtonPressed: onNavigateToDiscover,
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMediaDetails(BuildContext context, MediaItem media) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MediaDetailsScreen(mediaItem: media)),
    );
  }

  static void _noop(MediaItem media) {}
}
