import 'package:isar/isar.dart';

@Collection()
class CollectionEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String mediaId; // Matches MediaItem.localId

  @Index()
  String status; // 'wishlist', 'watching', 'watched'

  @Index()
  bool isFavorite;

  double personalRating; // 0.0 to 5.0

  DateTime addedAt;
  DateTime? watchedAt;
  String? notes;
  DateTime lastUpdated;

  CollectionEntry({
    this.id = Isar.autoIncrement,
    required this.mediaId,
    required this.status,
    this.isFavorite = false,
    this.personalRating = 0.0,
    required this.addedAt,
    this.watchedAt,
    this.notes,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'mediaId': mediaId,
      'status': status,
      'isFavorite': isFavorite,
      'personalRating': personalRating,
      'addedAt': addedAt.toIso8601String(),
      'watchedAt': watchedAt?.toIso8601String(),
      'notes': notes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CollectionEntry.fromMap(Map<String, dynamic> map) {
    return CollectionEntry(
      id: map['id'] != null ? map['id'] as int : Isar.autoIncrement,
      mediaId: map['mediaId'] as String,
      status: map['status'] as String? ?? 'wishlist',
      isFavorite: map['isFavorite'] as bool? ?? false,
      personalRating: (map['personalRating'] as num?)?.toDouble() ?? 0.0,
      addedAt: map['addedAt'] != null
          ? DateTime.parse(map['addedAt'])
          : DateTime.now(),
      watchedAt: map['watchedAt'] != null
          ? DateTime.parse(map['watchedAt'])
          : null,
      notes: map['notes'] as String?,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  CollectionEntry copyWith({
    String? status,
    bool? isFavorite,
    double? personalRating,
    DateTime? watchedAt,
    String? notes,
    DateTime? lastUpdated,
  }) {
    return CollectionEntry(
      id: id,
      mediaId: mediaId,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      personalRating: personalRating ?? this.personalRating,
      addedAt: addedAt,
      watchedAt: watchedAt ?? this.watchedAt,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}
