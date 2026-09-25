import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../data/models/media_item.dart';

class TmdbClient {
  final http.Client _client;
  String _apiKey;

  TmdbClient({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? ApiConstants.defaultApiKey;

  void setApiKey(String key) {
    if (key.trim().isNotEmpty) {
      _apiKey = key.trim();
    }
  }

  String get apiKey => _apiKey;

  Future<Map<String, dynamic>> _get(String endpoint, [Map<String, String>? queryParams]) async {
    final params = {'api_key': _apiKey, ...?queryParams};
    final uri = Uri.parse('${ApiConstants.tmdbBaseUrl}$endpoint').replace(queryParameters: params);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint("TMDB API Error (${response.statusCode}): ${response.body}");
        throw Exception("TMDB API returned code ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Network error calling TMDB $endpoint: $e");
      rethrow;
    }
  }

  // Trending Movies & TV
  Future<List<MediaItem>> getTrending({String timeWindow = 'week'}) async {
    final res = await _get('/trending/all/$timeWindow');
    final results = res['results'] as List? ?? [];
    return results
        .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
        .map((item) => MediaItem.fromTmdbJson(item, item['media_type']))
        .toList();
  }

  // Popular Movies / TV
  Future<List<MediaItem>> getPopular(String mediaType) async {
    final res = await _get('/$mediaType/popular');
    final results = res['results'] as List? ?? [];
    return results.map((item) => MediaItem.fromTmdbJson(item, mediaType)).toList();
  }

  // New / Upcoming Releases
  Future<List<MediaItem>> getNewReleases({String mediaType = 'movie'}) async {
    final endpoint = mediaType == 'movie' ? '/movie/now_playing' : '/tv/on_the_air';
    final res = await _get(endpoint);
    final results = res['results'] as List? ?? [];
    return results.map((item) => MediaItem.fromTmdbJson(item, mediaType)).toList();
  }

  // Upcoming Movies
  Future<List<MediaItem>> getUpcoming() async {
    final res = await _get('/movie/upcoming');
    final results = res['results'] as List? ?? [];
    return results.map((item) => MediaItem.fromTmdbJson(item, 'movie')).toList();
  }

  // Top Rated
  Future<List<MediaItem>> getTopRated(String mediaType) async {
    final res = await _get('/$mediaType/top_rated');
    final results = res['results'] as List? ?? [];
    return results.map((item) => MediaItem.fromTmdbJson(item, mediaType)).toList();
  }

  // Multi Search (Movies & TV Shows)
  Future<List<MediaItem>> searchMulti(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _get('/search/multi', {'query': query, 'include_adult': 'false'});
    final results = res['results'] as List? ?? [];
    return results
        .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
        .map((item) => MediaItem.fromTmdbJson(item, item['media_type']))
        .toList();
  }

  // Media Details (with genres, runtime, etc.)
  Future<MediaItem> getDetails(int tmdbId, String mediaType) async {
    final res = await _get('/$mediaType/$tmdbId');
    return MediaItem.fromTmdbJson(res, mediaType);
  }

  // Get Similar / Recommendations
  Future<List<MediaItem>> getRecommendations(int tmdbId, String mediaType) async {
    try {
      final res = await _get('/$mediaType/$tmdbId/recommendations');
      final results = res['results'] as List? ?? [];
      return results.map((item) => MediaItem.fromTmdbJson(item, mediaType)).toList();
    } catch (_) {
      return [];
    }
  }

  // Get TV Season Details (episodes)
  Future<Map<String, dynamic>> getTvSeasonDetails(int tvTmdbId, int seasonNumber) async {
    return await _get('/tv/$tvTmdbId/season/$seasonNumber');
  }

  // Discover Movies or TV Shows with Filters
  Future<List<MediaItem>> discoverMedia({
    required String mediaType,
    int? withGenreId,
    String? sortBy,
    int? year,
    String? language,
  }) async {
    final queryParams = <String, String>{};
    if (withGenreId != null) queryParams['with_genres'] = withGenreId.toString();
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (year != null) {
      if (mediaType == 'movie') {
        queryParams['primary_release_year'] = year.toString();
      } else {
        queryParams['first_air_date_year'] = year.toString();
      }
    }
    if (language != null) queryParams['with_original_language'] = language;

    final res = await _get('/discover/$mediaType', queryParams);
    final results = res['results'] as List? ?? [];
    return results.map((item) => MediaItem.fromTmdbJson(item, mediaType)).toList();
  }

  // Get Watch Providers / Streaming Platforms
  Future<Map<String, dynamic>> getWatchProviders(int tmdbId, String mediaType) async {
    try {
      final res = await _get('/$mediaType/$tmdbId/watch/providers');
      final results = res['results'] as Map<String, dynamic>? ?? {};
      if (results.containsKey('IN')) return results['IN'] as Map<String, dynamic>;
      if (results.containsKey('US')) return results['US'] as Map<String, dynamic>;
      if (results.isNotEmpty) return results.values.first as Map<String, dynamic>;
      return {};
    } catch (_) {
      return {};
    }
  }

  // Get Credits (Cast)
  Future<List<Map<String, String>>> getCredits(int tmdbId, String mediaType) async {
    try {
      final res = await _get('/$mediaType/$tmdbId/credits');
      final cast = res['cast'] as List? ?? [];
      return cast.take(12).map((c) => {
        'name': (c['name'] ?? '').toString(),
        'character': (c['character'] ?? c['job'] ?? '').toString(),
        'profilePath': (c['profile_path'] ?? '').toString(),
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
