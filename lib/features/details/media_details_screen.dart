import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/duration_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/media_item.dart';
import '../../data/models/collection_entry.dart';
import '../../data/models/watch_progress.dart';
import '../../providers/app_providers.dart';
import '../../widgets/star_rating_bar.dart';
import '../home/widgets/horizontal_media_list.dart';

class MediaDetailsScreen extends ConsumerStatefulWidget {
  final MediaItem mediaItem;

  const MediaDetailsScreen({super.key, required this.mediaItem});

  @override
  ConsumerState<MediaDetailsScreen> createState() => _MediaDetailsScreenState();
}

class _MediaDetailsScreenState extends ConsumerState<MediaDetailsScreen> {
  late MediaItem _media;
  List<MediaItem> _recommendations = [];
  Map<String, dynamic>? _watchProviders;
  List<Map<String, String>> _credits = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _media = widget.mediaItem;
    _fetchDetailsAndRecommendations();
  }

  Future<void> _fetchDetailsAndRecommendations() async {
    final tmdbRepo = ref.read(tmdbRepositoryProvider);
    try {
      if (_media.source == 'tmdb' && _media.tmdbId != null) {
        final fullDetails = await tmdbRepo.getDetails(_media.tmdbId!, _media.mediaType);
        final recs = await tmdbRepo.getRecommendations(_media.tmdbId!, _media.mediaType);
        final providers = await tmdbRepo.getWatchProviders(_media.tmdbId!, _media.mediaType);
        final cast = await tmdbRepo.getCredits(_media.tmdbId!, _media.mediaType);
        if (mounted) {
          setState(() {
            _media = fullDetails;
            _recommendations = recs;
            _watchProviders = providers;
            _credits = cast;
            _isLoadingRecommendations = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingRecommendations = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionState = ref.watch(collectionProvider);
    Map<String, dynamic>? collectionData;

    collectionState.whenData((items) {
      for (final item in items) {
        if ((item['media'] as MediaItem).localId == _media.localId) {
          collectionData = item;
          break;
        }
      }
    });

    final entry = collectionData?['entry'] as CollectionEntry?;
    final progress = collectionData?['progress'] as WatchProgress?;
    final currentStatus = entry?.status;
    final isFavorite = entry?.isFavorite ?? false;

    final backdropUrl = ApiConstants.getBackdropUrl(_media.backdropPath);
    final posterUrl = ApiConstants.getPosterUrl(_media.posterPath, quality: 'w500');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section with Backdrop, Backdrop Filter, and Overlapping Poster
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Backdrop Image
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: backdropUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: backdropUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(color: AppColors.cardElevated),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x8007080C),
                          AppColors.background,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Back Button & Favorite Top Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFavorite ? AppColors.favoritePink : Colors.white,
                            ),
                            onPressed: () {
                              ref.read(collectionProvider.notifier).toggleFavorite(_media);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overlapping Poster Artwork Positioning
                Positioned(
                  bottom: -60,
                  left: 20,
                  child: Container(
                    width: 120,
                    height: 175,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: posterUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: posterUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.cardElevated,
                              child: const Icon(Icons.movie_rounded, size: 40),
                            ),
                    ),
                  ),
                ),

                // Title Header beside Overlapping Poster
                Positioned(
                  bottom: 10,
                  left: 155,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _media.mediaType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _media.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_media.originalTitle != null && _media.originalTitle != _media.title) ...[
                        const SizedBox(height: 2),
                        Text(
                          _media.originalTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 75),

            // Metadata Chips (Year, Runtime, Language, TMDB Rating)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _MetaBadge(icon: Icons.calendar_today_rounded, label: _media.year?.toString() ?? 'N/A'),
                  const SizedBox(width: 10),
                  _MetaBadge(icon: Icons.access_time_rounded, label: DurationFormatter.formatMinutes(_media.runtime)),
                  const SizedBox(width: 10),
                  _MetaBadge(icon: Icons.language_rounded, label: _media.originalLanguage?.toUpperCase() ?? 'EN'),
                  const SizedBox(width: 10),
                  _MetaBadge(
                    icon: Icons.star_rounded,
                    label: _media.voteAverage.toStringAsFixed(1),
                    iconColor: AppColors.amberRating,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main Primary Actions Bar (+ Wishlist, ▶ Start Watching, ✓ Watched)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatusActionButton(
                      label: currentStatus == 'wishlist' ? 'In Wishlist' : 'Wishlist',
                      icon: CupertinoIcons.bookmark_fill,
                      isActive: currentStatus == 'wishlist',
                      activeColor: AppColors.wishlistChip,
                      onPressed: () {
                        ref.read(collectionProvider.notifier).updateStatus(_media, 'wishlist');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatusActionButton(
                      label: currentStatus == 'watching' ? 'Watching' : 'Start',
                      icon: CupertinoIcons.play_fill,
                      isActive: currentStatus == 'watching',
                      activeColor: AppColors.watchingChip,
                      onPressed: () {
                        ref.read(collectionProvider.notifier).updateStatus(_media, 'watching');
                        _showProgressEditorSheet(context, _media, progress);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatusActionButton(
                      label: currentStatus == 'watched' ? 'Watched' : 'Watched',
                      icon: CupertinoIcons.check_mark_circled_solid,
                      isActive: currentStatus == 'watched',
                      activeColor: AppColors.watchedChip,
                      onPressed: () {
                        ref.read(collectionProvider.notifier).updateStatus(_media, 'watched');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resume Progress Banner if Watching
            if (currentStatus == 'watching' && progress != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _media.mediaType == 'tv'
                                ? "Resume S${progress.currentSeason?.toString().padLeft(2, '0')} E${progress.currentEpisode?.toString().padLeft(2, '0')}"
                                : "You stopped at ${DurationFormatter.formatSeconds(progress.currentPositionSeconds)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (progress.progressPercentage / 100).clamp(0.0, 1.0),
                            backgroundColor: AppColors.glassBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
                      onPressed: () => _showProgressEditorSheet(context, _media, progress),
                    ),
                  ],
                ),
              ),

            // Personal Rating & Notes Card
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Personal Rating & Notes",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showRatingNotesDialog(context, entry?.personalRating ?? 0.0, entry?.notes),
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StarRatingBar(rating: entry?.personalRating ?? 0.0, starSize: 22),
                      const SizedBox(width: 10),
                      Text(
                        entry?.personalRating != null && entry!.personalRating > 0
                            ? "${entry.personalRating.toStringAsFixed(1)} / 5.0"
                            : "Not rated yet",
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (entry?.notes != null && entry!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '"${entry.notes}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Overview Section
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _media.overview ?? 'No overview available.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Genres Chips
            if (_media.genres.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _media.genres.map((g) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        g,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Where to Watch / Streaming Platforms Section
            _buildWatchProvidersSection(),

            // Top Cast & Crew Section
            _buildCastSection(),

            // Reminder Trigger Button
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showReminderDialog(context),
                  icon: const Icon(Icons.notifications_active_rounded, color: AppColors.amberRating),
                  label: const Text("Set Watch Reminder"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),

            // Similar / Recommendations Carousel
            const SizedBox(height: 28),
            HorizontalMediaList(
              title: "Similar & Recommendations",
              items: _recommendations,
              isLoading: _isLoadingRecommendations,
              onMediaTap: (media) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MediaDetailsScreen(mediaItem: media)),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchProvidersSection() {
    if (_watchProviders == null) return const SizedBox.shrink();

    final flatrate = (_watchProviders!['flatrate'] as List?) ?? [];

    if (flatrate.isEmpty) {
      final releaseDateStr = _media.releaseDate;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.tv, color: AppColors.primaryAccent, size: 20),
                  SizedBox(width: 10),
                  Text(
                    "OTT Release Status (India)",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amberRating.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(CupertinoIcons.time, color: AppColors.amberRating, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Not Released on Indian OTT Platforms Yet",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          releaseDateStr != null && releaseDateStr.isNotEmpty
                              ? "Theatrical Release: $releaseDateStr • Expected OTT premiere: ~45–90 days post premiere"
                              : "Expected OTT release on CineVault: ~45–90 days following theatrical release",
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(CupertinoIcons.tv, color: AppColors.primaryAccent, size: 22),
                SizedBox(width: 10),
                Text(
                  "Streaming on OTT (India)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: flatrate.map((provider) => _buildProviderBadge(provider)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderBadge(dynamic provider) {
    final name = (provider['provider_name'] ?? '').toString();
    final logoPath = (provider['logo_path'] ?? '').toString();
    final logoUrl = ApiConstants.getPosterUrl(logoPath, quality: 'w185');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                width: 22,
                height: 22,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.play_circle_fill_rounded, size: 20, color: AppColors.primaryAccent),
              ),
            )
          else
            const Icon(Icons.play_circle_fill_rounded, size: 20, color: AppColors.primaryAccent),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    if (_credits.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Top Cast & Crew",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _credits.length,
              itemBuilder: (context, index) {
                final c = _credits[index];
                final name = c['name'] ?? '';
                final character = c['character'] ?? '';
                final profilePath = c['profilePath'] ?? '';
                final profileUrl = ApiConstants.getPosterUrl(profilePath, quality: 'w185');

                return Container(
                  width: 75,
                  margin: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.cardElevated,
                        backgroundImage: profileUrl.isNotEmpty ? CachedNetworkImageProvider(profileUrl) : null,
                        child: profileUrl.isEmpty ? const Icon(Icons.person_rounded, color: AppColors.textMuted) : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        character,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressEditorSheet(BuildContext context, MediaItem media, WatchProgress? currentProgress) {
    int posSec = currentProgress?.currentPositionSeconds ?? 0;
    int totSec = currentProgress?.totalDurationSeconds ?? ((media.runtime ?? 120) * 60);
    int season = currentProgress?.currentSeason ?? 1;
    int episode = currentProgress?.currentEpisode ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final percent = totSec > 0 ? (posSec / totSec * 100).clamp(0.0, 100.0) : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Update Playback Progress - ${media.title}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  if (media.mediaType == 'tv') ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: season,
                            decoration: const InputDecoration(labelText: 'Season'),
                            items: List.generate(15, (i) => i + 1)
                                .map((s) => DropdownMenuItem(value: s, child: Text('Season $s')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => season = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: episode,
                            decoration: const InputDecoration(labelText: 'Episode'),
                            items: List.generate(30, (i) => i + 1)
                                .map((e) => DropdownMenuItem(value: e, child: Text('Episode $e')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setSheetState(() => episode = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    "Position: ${DurationFormatter.formatSeconds(posSec)} / ${DurationFormatter.formatSeconds(totSec)} (${percent.toInt()}%)",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryAccent),
                  ),
                  Slider(
                    value: posSec.toDouble().clamp(0.0, totSec.toDouble()),
                    min: 0,
                    max: totSec.toDouble(),
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) {
                      setSheetState(() {
                        posSec = val.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final updatedProgress = WatchProgress(
                              mediaId: media.localId,
                              mediaType: media.mediaType,
                              currentPositionSeconds: posSec,
                              totalDurationSeconds: totSec,
                              progressPercentage: percent,
                              currentSeason: media.mediaType == 'tv' ? season : null,
                              currentEpisode: media.mediaType == 'tv' ? episode : null,
                              episodeDurationSeconds: 45 * 60,
                              lastUpdated: DateTime.now(),
                            );
                            ref.read(collectionProvider.notifier).updateProgress(updatedProgress);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Save Progress", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRatingNotesDialog(BuildContext context, double currentRating, String? currentNotes) {
    double rating = currentRating;
    final notesController = TextEditingController(text: currentNotes);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text("Rate & Add Notes"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StarRatingBar(
                    rating: rating,
                    starSize: 32,
                    isInteractive: true,
                    onRatingChanged: (newRating) {
                      setDialogState(() => rating = newRating);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: "Add your personal notes...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(collectionProvider.notifier).updateRatingAndNotes(
                          _media.localId,
                          rating,
                          notesController.text.trim(),
                        );
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReminderDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 2));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Set Watch Reminder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Remind me to watch ${_media.title}"),
              const SizedBox(height: 16),
              ListTile(
                title: Text("Date: ${DateFormatter.formatFullDate(selectedDate)}"),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    selectedDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      selectedDate.hour,
                      selectedDate.minute,
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                ref.read(reminderRepositoryProvider).addReminder(
                      mediaId: _media.localId,
                      mediaTitle: _media.title,
                      reminderDateTime: selectedDate,
                    );
                ref.invalidate(remindersProvider);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Watch reminder set successfully!")),
                );
              },
              child: const Text("Set Reminder"),
            ),
          ],
        );
      },
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _MetaBadge({required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onPressed;

  const _StatusActionButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : AppColors.cardElevated,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: isActive ? 4 : 0,
      ),
    );
  }
}
