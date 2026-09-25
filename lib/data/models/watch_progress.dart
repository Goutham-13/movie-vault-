import 'package:isar/isar.dart';

@Collection()
class WatchProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String mediaId; // Matches MediaItem.localId

  String mediaType; // 'movie' or 'tv'

  int currentPositionSeconds;
  int totalDurationSeconds;
  double progressPercentage;

  int? currentSeason;
  int? currentEpisode;
  int episodeDurationSeconds;

  DateTime lastUpdated;

  WatchProgress({
    this.id = Isar.autoIncrement,
    required this.mediaId,
    required this.mediaType,
    this.currentPositionSeconds = 0,
    this.totalDurationSeconds = 0,
    this.progressPercentage = 0.0,
    this.currentSeason,
    this.currentEpisode,
    this.episodeDurationSeconds = 0,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'mediaId': mediaId,
      'mediaType': mediaType,
      'currentPositionSeconds': currentPositionSeconds,
      'totalDurationSeconds': totalDurationSeconds,
      'progressPercentage': progressPercentage,
      'currentSeason': currentSeason,
      'currentEpisode': currentEpisode,
      'episodeDurationSeconds': episodeDurationSeconds,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WatchProgress.fromMap(Map<String, dynamic> map) {
    return WatchProgress(
      id: map['id'] != null ? map['id'] as int : Isar.autoIncrement,
      mediaId: map['mediaId'] as String,
      mediaType: map['mediaType'] as String? ?? 'movie',
      currentPositionSeconds: map['currentPositionSeconds'] as int? ?? 0,
      totalDurationSeconds: map['totalDurationSeconds'] as int? ?? 0,
      progressPercentage: (map['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      currentSeason: map['currentSeason'] as int?,
      currentEpisode: map['currentEpisode'] as int?,
      episodeDurationSeconds: map['episodeDurationSeconds'] as int? ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  WatchProgress copyWith({
    int? currentPositionSeconds,
    int? totalDurationSeconds,
    double? progressPercentage,
    int? currentSeason,
    int? currentEpisode,
    int? episodeDurationSeconds,
    DateTime? lastUpdated,
  }) {
    return WatchProgress(
      id: id,
      mediaId: mediaId,
      mediaType: mediaType,
      currentPositionSeconds: currentPositionSeconds ?? this.currentPositionSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      currentSeason: currentSeason ?? this.currentSeason,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      episodeDurationSeconds: episodeDurationSeconds ?? this.episodeDurationSeconds,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}
