import '../models/media_item.dart';
import '../models/collection_entry.dart';
import '../models/watch_progress.dart';
import '../models/tv_episode.dart';
import '../services/isar_service.dart';

class CollectionRepository {
  final IsarService _isarService;

  CollectionRepository({IsarService? isarService})
      : _isarService = isarService ?? IsarService();

  // Get full collection with details
  Future<List<Map<String, dynamic>>> getFullCollection() async {
    final entries = await _isarService.getAllCollectionEntries();
    final items = <Map<String, dynamic>>[];

    for (final entry in entries) {
      final media = await _isarService.getMediaItem(entry.mediaId);
      final progress = await _isarService.getWatchProgress(entry.mediaId);
      if (media != null) {
        items.add({
          'entry': entry,
          'media': media,
          'progress': progress,
        });
      }
    }
    return items;
  }

  // Get items by status (wishlist, watching, watched)
  Future<List<Map<String, dynamic>>> getCollectionByStatus(String status) async {
    final all = await getFullCollection();
    return all.where((item) => (item['entry'] as CollectionEntry).status == status).toList();
  }

  // Get favorites
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final all = await getFullCollection();
    return all.where((item) => (item['entry'] as CollectionEntry).isFavorite).toList();
  }

  // Get single item detail
  Future<Map<String, dynamic>?> getMediaDetail(String localId) async {
    final media = await _isarService.getMediaItem(localId);
    if (media == null) return null;
    final entry = await _isarService.getCollectionEntry(localId);
    final progress = await _isarService.getWatchProgress(localId);
    final tvEpisodes = media.mediaType == 'tv'
        ? await _isarService.getTVEpisodesForMedia(localId)
        : <TVEpisodeItem>[];

    return {
      'media': media,
      'entry': entry,
      'progress': progress,
      'tvEpisodes': tvEpisodes,
    };
  }

  // Add / Update status (Wishlist, Watching, Watched)
  Future<void> updateStatus({
    required MediaItem mediaItem,
    required String newStatus,
  }) async {
    await _isarService.saveMediaItem(mediaItem);
    var entry = await _isarService.getCollectionEntry(mediaItem.localId);

    final now = DateTime.now();
    if (entry == null) {
      entry = CollectionEntry(
        mediaId: mediaItem.localId,
        status: newStatus,
        addedAt: now,
        watchedAt: newStatus == 'watched' ? now : null,
        lastUpdated: now,
      );
    } else {
      entry = entry.copyWith(
        status: newStatus,
        watchedAt: newStatus == 'watched' ? (entry.watchedAt ?? now) : entry.watchedAt,
        lastUpdated: now,
      );
    }

    await _isarService.saveCollectionEntry(entry);

    // Initialize watch progress if moving to 'watching'
    if (newStatus == 'watching') {
      var progress = await _isarService.getWatchProgress(mediaItem.localId);
      if (progress == null) {
        final defaultDuration = (mediaItem.runtime ?? 120) * 60;
        progress = WatchProgress(
          mediaId: mediaItem.localId,
          mediaType: mediaItem.mediaType,
          currentPositionSeconds: 0,
          totalDurationSeconds: defaultDuration,
          progressPercentage: 0.0,
          currentSeason: mediaItem.mediaType == 'tv' ? 1 : null,
          currentEpisode: mediaItem.mediaType == 'tv' ? 1 : null,
          episodeDurationSeconds: mediaItem.mediaType == 'tv' ? 45 * 60 : 0,
          lastUpdated: now,
        );
        await _isarService.saveWatchProgress(progress);
      }
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(MediaItem mediaItem) async {
    await _isarService.saveMediaItem(mediaItem);
    var entry = await _isarService.getCollectionEntry(mediaItem.localId);
    final now = DateTime.now();

    if (entry == null) {
      entry = CollectionEntry(
        mediaId: mediaItem.localId,
        status: 'wishlist',
        isFavorite: true,
        addedAt: now,
        lastUpdated: now,
      );
    } else {
      entry = entry.copyWith(
        isFavorite: !entry.isFavorite,
        lastUpdated: now,
      );
    }

    await _isarService.saveCollectionEntry(entry);
  }

  // Save Personal Rating & Notes
  Future<void> updateRatingAndNotes({
    required String mediaId,
    required double rating,
    required String? notes,
  }) async {
    var entry = await _isarService.getCollectionEntry(mediaId);
    if (entry != null) {
      entry = entry.copyWith(
        personalRating: rating,
        notes: notes,
        lastUpdated: DateTime.now(),
      );
      await _isarService.saveCollectionEntry(entry);
    }
  }

  // Update Watch Progress
  Future<void> updateWatchProgress(WatchProgress progress) async {
    await _isarService.saveWatchProgress(progress);

    // Auto mark watched if progress >= 95%
    if (progress.progressPercentage >= 95.0) {
      final entry = await _isarService.getCollectionEntry(progress.mediaId);
      if (entry != null && entry.status != 'watched') {
        final updatedEntry = entry.copyWith(
          status: 'watched',
          watchedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );
        await _isarService.saveCollectionEntry(updatedEntry);
      }
    }
  }

  // Save manual movie/show
  Future<void> saveManualMedia({
    required MediaItem mediaItem,
    required String initialStatus,
  }) async {
    await _isarService.saveMediaItem(mediaItem);
    final now = DateTime.now();
    final entry = CollectionEntry(
      mediaId: mediaItem.localId,
      status: initialStatus,
      addedAt: now,
      watchedAt: initialStatus == 'watched' ? now : null,
      lastUpdated: now,
    );
    await _isarService.saveCollectionEntry(entry);

    if (initialStatus == 'watching') {
      final progress = WatchProgress(
        mediaId: mediaItem.localId,
        mediaType: mediaItem.mediaType,
        currentPositionSeconds: 0,
        totalDurationSeconds: (mediaItem.runtime ?? 120) * 60,
        progressPercentage: 0.0,
        currentSeason: mediaItem.mediaType == 'tv' ? 1 : null,
        currentEpisode: mediaItem.mediaType == 'tv' ? 1 : null,
        episodeDurationSeconds: mediaItem.mediaType == 'tv' ? 45 * 60 : 0,
        lastUpdated: now,
      );
      await _isarService.saveWatchProgress(progress);
    }
  }

  // Save TV Episode Watched Status
  Future<void> toggleTvEpisodeWatched(TVEpisodeItem episode) async {
    final updated = TVEpisodeItem(
      id: episode.id,
      mediaId: episode.mediaId,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      overview: episode.overview,
      stillPath: episode.stillPath,
      durationMinutes: episode.durationMinutes,
      isWatched: !episode.isWatched,
      watchedAt: !episode.isWatched ? DateTime.now() : null,
    );
    await _isarService.saveTVEpisode(updated);
  }

  // Remove from collection
  Future<void> removeFromCollection(String mediaId) async {
    await _isarService.deleteCollectionEntry(mediaId);
  }
}
