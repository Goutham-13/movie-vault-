import 'package:isar/isar.dart';

@Collection()
class MediaItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String localId;

  @Index()
  int? tmdbId;

  String mediaType; // 'movie' or 'tv'

  String title;
  String? originalTitle;
  String? overview;
  String? posterPath;
  String? backdropPath;
  String? releaseDate;
  int? year;
  String? originalLanguage;
  List<String> genres;
  int? runtime;
  double voteAverage;
  int voteCount;
  double popularity;
  bool adult;
  String source; // 'tmdb' or 'manual'
  DateTime createdAt;
  DateTime updatedAt;

  MediaItem({
    this.id = Isar.autoIncrement,
    required this.localId,
    this.tmdbId,
    required this.mediaType,
    required this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.year,
    this.originalLanguage,
    this.genres = const [],
    this.runtime,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.popularity = 0.0,
    this.adult = false,
    this.source = 'tmdb',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'localId': localId,
      'tmdbId': tmdbId,
      'mediaType': mediaType,
      'title': title,
      'originalTitle': originalTitle,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'releaseDate': releaseDate,
      'year': year,
      'originalLanguage': originalLanguage,
      'genres': genres,
      'runtime': runtime,
      'voteAverage': voteAverage,
      'voteCount': voteCount,
      'popularity': popularity,
      'adult': adult,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] != null ? map['id'] as int : Isar.autoIncrement,
      localId: map['localId'] as String,
      tmdbId: map['tmdbId'] as int?,
      mediaType: map['mediaType'] as String? ?? 'movie',
      title: map['title'] as String,
      originalTitle: map['originalTitle'] as String?,
      overview: map['overview'] as String?,
      posterPath: map['posterPath'] as String?,
      backdropPath: map['backdropPath'] as String?,
      releaseDate: map['releaseDate'] as String?,
      year: map['year'] as int?,
      originalLanguage: map['originalLanguage'] as String?,
      genres: List<String>.from(map['genres'] ?? []),
      runtime: map['runtime'] as int?,
      voteAverage: (map['voteAverage'] as num?)?.toDouble() ?? 0.0,
      voteCount: map['voteCount'] as int? ?? 0,
      popularity: (map['popularity'] as num?)?.toDouble() ?? 0.0,
      adult: map['adult'] as bool? ?? false,
      source: map['source'] as String? ?? 'tmdb',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  factory MediaItem.fromTmdbJson(Map<String, dynamic> json, String mediaType) {
    final title = json['title'] ?? json['name'] ?? 'Untitled';
    final originalTitle = json['original_title'] ?? json['original_name'];
    final releaseDate = json['release_date'] ?? json['first_air_date'];
    int? year;
    if (releaseDate != null && releaseDate.toString().length >= 4) {
      year = int.tryParse(releaseDate.toString().substring(0, 4));
    }

    List<String> genreNames = [];
    if (json['genres'] != null && json['genres'] is List) {
      genreNames = (json['genres'] as List)
          .map((g) => g['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    }

    final tmdbId = json['id'] as int;

    return MediaItem(
      localId: 'tmdb_${mediaType}_$tmdbId',
      tmdbId: tmdbId,
      mediaType: mediaType,
      title: title,
      originalTitle: originalTitle,
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: releaseDate,
      year: year,
      originalLanguage: json['original_language'],
      genres: genreNames,
      runtime: json['runtime'] ?? (json['episode_run_time'] != null && (json['episode_run_time'] as List).isNotEmpty ? json['episode_run_time'][0] : null),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      adult: json['adult'] as bool? ?? false,
      source: 'tmdb',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
