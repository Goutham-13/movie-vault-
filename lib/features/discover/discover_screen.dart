import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/media_item.dart';
import '../../providers/app_providers.dart';
import '../home/widgets/horizontal_media_list.dart';
import '../details/media_details_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  int? _selectedGenreId;
  String _selectedMediaType = 'movie';

  final List<Map<String, dynamic>> _genres = [
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 18, 'name': 'Drama'},
    {'id': 14, 'name': 'Fantasy'},
    {'id': 27, 'name': 'Horror'},
    {'id': 878, 'name': 'Sci-Fi'},
    {'id': 53, 'name': 'Thriller'},
  ];

  @override
  Widget build(BuildContext context) {
    final trendingAsync = ref.watch(trendingMediaProvider);
    final popularMoviesAsync = ref.watch(popularMoviesProvider);
    final popularTvAsync = ref.watch(popularTvProvider);
    final upcomingAsync = ref.watch(upcomingMoviesProvider);
    final topRatedAsync = ref.watch(topRatedMoviesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discover Cinema'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Type Toggle (Movies / TV Shows)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Movies'),
                    selected: _selectedMediaType == 'movie',
                    selectedColor: AppColors.primaryAccent,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMediaType = 'movie');
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('TV Shows'),
                    selected: _selectedMediaType == 'tv',
                    selectedColor: AppColors.primaryAccent,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMediaType = 'tv');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Genre Chips Scrollable Row
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenreId == genre['id'];

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(genre['name']),
                      selected: isSelected,
                      selectedColor: AppColors.secondaryAccent,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGenreId = selected ? genre['id'] : null;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Trending Section
            trendingAsync.when(
              data: (items) => HorizontalMediaList(
                title: "Trending Worldwide",
                subtitle: "Most popular cinema & TV this week",
                items: items,
                onMediaTap: (media) => _openDetails(context, media),
              ),
              loading: () => const HorizontalMediaList(title: "Trending", isLoading: true, onMediaTap: _noop),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Popular Movies Section
            popularMoviesAsync.when(
              data: (items) => HorizontalMediaList(
                title: "Popular Movies",
                items: items,
                onMediaTap: (media) => _openDetails(context, media),
              ),
              loading: () => const HorizontalMediaList(title: "Popular Movies", isLoading: true, onMediaTap: _noop),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Popular TV Shows Section
            popularTvAsync.when(
              data: (items) => HorizontalMediaList(
                title: "Popular TV Shows",
                items: items,
                onMediaTap: (media) => _openDetails(context, media),
              ),
              loading: () => const HorizontalMediaList(title: "Popular TV Shows", isLoading: true, onMediaTap: _noop),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Upcoming Movies Section
            upcomingAsync.when(
              data: (items) => HorizontalMediaList(
                title: "Upcoming Releases",
                items: items,
                onMediaTap: (media) => _openDetails(context, media),
              ),
              loading: () => const HorizontalMediaList(title: "Upcoming", isLoading: true, onMediaTap: _noop),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Top Rated Section
            topRatedAsync.when(
              data: (items) => HorizontalMediaList(
                title: "All-Time Top Rated",
                items: items,
                onMediaTap: (media) => _openDetails(context, media),
              ),
              loading: () => const HorizontalMediaList(title: "Top Rated", isLoading: true, onMediaTap: _noop),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, MediaItem media) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MediaDetailsScreen(mediaItem: media)),
    );
  }

  static void _noop(MediaItem media) {}
}
