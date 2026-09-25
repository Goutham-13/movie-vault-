import 'package:isar/isar.dart';

@Collection()
class TVEpisodeItem {
  Id id = Isar.autoIncrement;

  @Index()
  String mediaId; // Matches MediaItem.localId

  @Index()
  int seasonNumber;

  @Index()
  int episodeNumber;

  String title;
  String? overview;
  String? stillPath;
  int durationMinutes;
  bool isWatched;
  DateTime? watchedAt;

  TVEpisodeItem({
    this.id = Isar.autoIncrement,
    required this.mediaId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.overview,
    this.stillPath,
    this.durationMinutes = 45,
    this.isWatched = false,
    this.watchedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'mediaId': mediaId,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'title': title,
      'overview': overview,
      'stillPath': stillPath,
      'durationMinutes': durationMinutes,
      'isWatched': isWatched,
      'watchedAt': watchedAt?.toIso8601String(),
    };
  }

  factory TVEpisodeItem.fromMap(Map<String, dynamic> map) {
    return TVEpisodeItem(
      id: map['id'] != null ? map['id'] as int : Isar.autoIncrement,
      mediaId: map['mediaId'] as String,
      seasonNumber: map['seasonNumber'] as int,
      episodeNumber: map['episodeNumber'] as int,
      title: map['title'] as String,
      overview: map['overview'] as String?,
      stillPath: map['stillPath'] as String?,
      durationMinutes: map['durationMinutes'] as int? ?? 45,
      isWatched: map['isWatched'] as bool? ?? false,
      watchedAt: map['watchedAt'] != null ? DateTime.parse(map['watchedAt']) : null,
    );
  }

  factory TVEpisodeItem.fromTmdbJson(Map<String, dynamic> json, String mediaId, int season) {
    return TVEpisodeItem(
      mediaId: mediaId,
      seasonNumber: season,
      episodeNumber: json['episode_number'] as int? ?? 1,
      title: json['name'] as String? ?? 'Episode ${json['episode_number']}',
      overview: json['overview'] as String?,
      stillPath: json['still_path'] as String?,
      durationMinutes: json['runtime'] as int? ?? 45,
      isWatched: false,
    );
  }
}
