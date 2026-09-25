import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/media_item.dart';
import '../data/models/watch_reminder.dart';
import '../data/services/isar_service.dart';
import '../data/repositories/collection_repository.dart';
import '../data/repositories/tmdb_repository.dart';
import '../data/repositories/reminder_repository.dart';

// Repositories
final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return CollectionRepository(isarService: isar);
});

final tmdbRepositoryProvider = Provider<TmdbRepository>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return TmdbRepository(isarService: isar);
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return ReminderRepository(isarService: isar);
});

// Collection State Notifier
class CollectionStateNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final CollectionRepository _repository;

  CollectionStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCollection();
  }

  Future<void> loadCollection() async {
    try {
      state = const AsyncValue.loading();
      final items = await _repository.getFullCollection();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(MediaItem media, String newStatus) async {
    await _repository.updateStatus(mediaItem: media, newStatus: newStatus);
    await loadCollection();
  }

  Future<void> toggleFavorite(MediaItem media) async {
    await _repository.toggleFavorite(media);
    await loadCollection();
  }

  Future<void> updateRatingAndNotes(String mediaId, double rating, String? notes) async {
    await _repository.updateRatingAndNotes(mediaId: mediaId, rating: rating, notes: notes);
    await loadCollection();
  }

  Future<void> updateProgress(dynamic progress) async {
    await _repository.updateWatchProgress(progress);
    await loadCollection();
  }

  Future<void> remove(String mediaId) async {
    await _repository.removeFromCollection(mediaId);
    await loadCollection();
  }

  Future<void> saveManualMedia(MediaItem media, String initialStatus) async {
    await _repository.saveManualMedia(mediaItem: media, initialStatus: initialStatus);
    await loadCollection();
  }
}

final collectionProvider =
    StateNotifierProvider<CollectionStateNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repo = ref.watch(collectionRepositoryProvider);
  return CollectionStateNotifier(repo);
});

// Filtered Selectors
final continueWatchingProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final collectionState = ref.watch(collectionProvider);
  return collectionState.when(
    data: (items) => items.where((item) => (item['entry']).status == 'watching').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final wishlistProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final collectionState = ref.watch(collectionProvider);
  return collectionState.when(
    data: (items) => items.where((item) => (item['entry']).status == 'wishlist').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final watchedProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final collectionState = ref.watch(collectionProvider);
  return collectionState.when(
    data: (items) => items.where((item) => (item['entry']).status == 'watched').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final favoritesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final collectionState = ref.watch(collectionProvider);
  return collectionState.when(
    data: (items) => items.where((item) => (item['entry']).isFavorite).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Reminders Provider
final remindersProvider = FutureProvider<List<WatchReminder>>((ref) async {
  final repo = ref.watch(reminderRepositoryProvider);
  return await repo.getActiveReminders();
});

// TMDB Discovery & Search Providers
final trendingMediaProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(tmdbRepositoryProvider);
  return await repo.getTrending();
});

final newReleasesProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(tmdbRepositoryProvider);
  return await repo.getNewReleases();
});

final popularMoviesProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(tmdbRepositoryProvider);
  return await repo.getPopular('movie');
});

final popularTvProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(tmdbRepositoryProvider);
  return await repo.getPopular('tv');
});

final upcomingMoviesProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(tmdbRepositoryProvider);
  return await repo.getUpcoming();
});

final topRatedMoviesProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(tmdbRepositoryProvider);
  return await repo.getTopRated('movie');
});

// Search Query & Search Results
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<MediaItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(tmdbRepositoryProvider);
  return await repo.searchMulti(query);
});

// Filter & Sort State for Collection Screen
class FilterState {
  final List<String> status;
  final List<String> mediaType;
  final String? genre;
  final int? year;
  final String sortBy; // 'addedAt', 'title', 'rating', 'year'
  final bool isAscending;

  FilterState({
    this.status = const [],
    this.mediaType = const [],
    this.genre,
    this.year,
    this.sortBy = 'addedAt',
    this.isAscending = false,
  });

  FilterState copyWith({
    List<String>? status,
    List<String>? mediaType,
    String? genre,
    int? year,
    String? sortBy,
    bool? isAscending,
  }) {
    return FilterState(
      status: status ?? this.status,
      mediaType: mediaType ?? this.mediaType,
      genre: genre,
      year: year,
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

final collectionFilterProvider = StateProvider<FilterState>((ref) => FilterState());
