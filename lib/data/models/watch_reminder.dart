import 'package:isar/isar.dart';

@Collection()
class WatchReminder {
  Id id = Isar.autoIncrement;

  @Index()
  String mediaId;

  String title;
  DateTime reminderDateTime;
  bool enabled;

  @Index(unique: true, replace: true)
  int notificationId;

  WatchReminder({
    this.id = Isar.autoIncrement,
    required this.mediaId,
    required this.title,
    required this.reminderDateTime,
    this.enabled = true,
    required this.notificationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'mediaId': mediaId,
      'title': title,
      'reminderDateTime': reminderDateTime.toIso8601String(),
      'enabled': enabled,
      'notificationId': notificationId,
    };
  }

  factory WatchReminder.fromMap(Map<String, dynamic> map) {
    return WatchReminder(
      id: map['id'] != null ? map['id'] as int : Isar.autoIncrement,
      mediaId: map['mediaId'] as String,
      title: map['title'] as String,
      reminderDateTime: DateTime.parse(map['reminderDateTime'] as String),
      enabled: map['enabled'] as bool? ?? true,
      notificationId: map['notificationId'] as int,
    );
  }
}
