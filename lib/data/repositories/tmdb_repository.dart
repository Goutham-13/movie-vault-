import '../models/media_item.dart';
import '../../core/network/tmdb_client.dart';
import '../services/isar_service.dart';

class TmdbRepository {
  final TmdbClient _tmdbClient;
  final IsarService _isarService;

  TmdbRepository({TmdbClient? tmdbClient, IsarService? isarService})
      : _tmdbClient = tmdbClient ?? TmdbClient(),
        _isarService = isarService ?? IsarService();

  TmdbClient get client => _tmdbClient;

  // Fallback / Initial Seed Data with valid TMDB image URLs
  static final List<MediaItem> _fallbackCinemaList = [
    MediaItem(
      localId: 'tmdb_movie_157336',
      tmdbId: 157336,
      mediaType: 'movie',
      title: 'Interstellar',
      overview: 'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
      posterPath: '/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      backdropPath: '/xJHokMbljvjADYdit5fKSuVftv.jpg',
      releaseDate: '2014-11-05',
      year: 2014,
      originalLanguage: 'en',
      genres: ['Sci-Fi', 'Adventure', 'Drama'],
      runtime: 169,
      voteAverage: 8.4,
      source: 'tmdb',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      localId: 'tmdb_movie_155',
      tmdbId: 155,
      mediaType: 'movie',
      title: 'The Dark Knight',
      overview: 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets.',
      posterPath: '/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      backdropPath: '/nMK2819zaatKGBDi9zES5GcnYVo.jpg',
      releaseDate: '2008-07-16',
      year: 2008,
      originalLanguage: 'en',
      genres: ['Action', 'Crime', 'Drama'],
      runtime: 152,
      voteAverage: 8.5,
      source: 'tmdb',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      localId: 'tmdb_movie_693134',
      tmdbId: 693134,
      mediaType: 'movie',
      title: 'Dune: Part Two',
      overview: 'Follow the mythic journey of Paul Atreides as he unites with Chani and the Fremen while on a path of revenge against the conspirators who destroyed his family.',
      posterPath: '/czom1F6xbAiRMx2v6yd44ut2jGf.jpg',
      backdropPath: '/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg',
      releaseDate: '2024-02-27',
      year: 2024,
      originalLanguage: 'en',
      genres: ['Sci-Fi', 'Adventure'],
      runtime: 166,
      voteAverage: 8.3,
      source: 'tmdb',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      localId: 'tmdb_tv_1396',
      tmdbId: 1396,
      mediaType: 'tv',
      title: 'Breaking Bad',
      overview: 'Walter White, a New Mexico chemistry teacher, is diagnosed with Stage III cancer and given a prognosis of only two years left to live. He chooses to enter a dangerous world of drugs and crime to secure his family\'s financial future.',
      posterPath: '/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg',
      backdropPath: '/tsRy63MuZvMuGQyUYabhlTVaB43.jpg',
      releaseDate: '2008-01-20',
      year: 2008,
      originalLanguage: 'en',
      genres: ['Drama', 'Crime'],
      runtime: 47,
      voteAverage: 8.9,
      source: 'tmdb',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      localId: 'tmdb_movie_872585',
      tmdbId: 872585,
      mediaType: 'movie',
      title: 'Oppenheimer',
      overview: 'The story of J. Robert Oppenheimer\'s role in the development of the atomic bomb during World War II.',
      posterPath: '/ptPr1kL4WSu3IHBhefstgPOmfl.jpg',
      backdropPath: '/rL1d960j1cT8hJq4k2Y2l8z0a6d.jpg',
      releaseDate: '2023-07-19',
      year: 2023,
      originalLanguage: 'en',
      genres: ['Drama', 'History'],
      runtime: 180,
      voteAverage: 8.1,
      source: 'tmdb',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MediaItem(
      localId: 'tmdb_tv_94605',
      tmdbId: 94605,
      mediaType: 'tv',
      title: 'Arcane',
      overview: 'Amid the fraught balance between the rich city of Piltover and the seedy underbelly of Zaun, two sisters fight on opposite sides of a war between band technologies and incompatible beliefs.',
      posterPath: '/ab8H6t092W85H7b9d5g5rQc6aH.jpg',
      backdropPath: '/uDgy6hyPd32qVyaEuvYtStsUQh7.jpg',
      releaseDate: '2021-11-06',
      year: 2021,
      originalLanguage: 'en',
      genres: ['Animation', 'Sci-Fi', 'Action'],
      runtime: 40,
      voteAverage: 8.7,
      source: 'tmdb',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<List<MediaItem>> getTrending({String timeWindow = 'week'}) async {
    try {
      final items = await _tmdbClient.getTrending(timeWindow: timeWindow);
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      return _getCachedMediaWithFallback();
    }
  }

  Future<List<MediaItem>> getPopular(String mediaType) async {
    try {
      final items = await _tmdbClient.getPopular(mediaType);
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      return _getCachedMediaWithFallback(mediaType: mediaType);
    }
  }

  Future<List<MediaItem>> getNewReleases({String mediaType = 'movie'}) async {
    try {
      final items = await _tmdbClient.getNewReleases(mediaType: mediaType);
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      return _getCachedMediaWithFallback(mediaType: mediaType);
    }
  }

  Future<List<MediaItem>> getUpcoming() async {
    try {
      final items = await _tmdbClient.getUpcoming();
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      return _getCachedMediaWithFallback(mediaType: 'movie');
    }
  }

  Future<List<MediaItem>> getTopRated(String mediaType) async {
    try {
      final items = await _tmdbClient.getTopRated(mediaType);
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      return _getCachedMediaWithFallback(mediaType: mediaType);
    }
  }

  Future<List<MediaItem>> searchMulti(String query) async {
    try {
      final items = await _tmdbClient.searchMulti(query);
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      final cached = await _getCachedMediaWithFallback();
      return cached.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  Future<MediaItem> getDetails(int tmdbId, String mediaType) async {
    final localId = 'tmdb_${mediaType}_$tmdbId';
    try {
      final item = await _tmdbClient.getDetails(tmdbId, mediaType);
      await _isarService.saveMediaItem(item);
      return item;
    } catch (_) {
      final cached = await _isarService.getMediaItem(localId);
      if (cached != null) return cached;
      final fallback = _fallbackCinemaList.firstWhere(
        (m) => m.tmdbId == tmdbId,
        orElse: () => _fallbackCinemaList.first,
      );
      return fallback;
    }
  }

  Future<List<MediaItem>> getRecommendations(int tmdbId, String mediaType) async {
    try {
      final items = await _tmdbClient.getRecommendations(tmdbId, mediaType);
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      return _fallbackCinemaList.where((m) => m.tmdbId != tmdbId).toList();
    }
  }

  Future<List<MediaItem>> discoverMedia({
    required String mediaType,
    int? withGenreId,
    String? sortBy,
    int? year,
    String? language,
  }) async {
    try {
      final items = await _tmdbClient.discoverMedia(
        mediaType: mediaType,
        withGenreId: withGenreId,
        sortBy: sortBy,
        year: year,
        language: language,
      );
      _cacheMediaItems(items);
      return items;
    } catch (_) {
      return _getCachedMediaWithFallback(mediaType: mediaType);
    }
  }

  void _cacheMediaItems(List<MediaItem> items) {
    for (final item in items) {
      _isarService.saveMediaItem(item);
    }
  }

  Future<List<MediaItem>> _getCachedMediaWithFallback({String? mediaType}) async {
    final cached = await _isarService.getAllMediaItems();
    if (cached.isNotEmpty) {
      if (mediaType != null) {
        final filtered = cached.where((m) => m.mediaType == mediaType).toList();
        if (filtered.isNotEmpty) return filtered;
      }
      return cached;
    }
    
    // Seed database with curated fallback cinema items
    _cacheMediaItems(_fallbackCinemaList);
    if (mediaType != null) {
      return _fallbackCinemaList.where((m) => m.mediaType == mediaType).toList();
    }
    return _fallbackCinemaList;
  }
}
