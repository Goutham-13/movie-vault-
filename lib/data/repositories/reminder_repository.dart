import '../models/watch_reminder.dart';
import '../services/isar_service.dart';
import '../services/notification_service.dart';

class ReminderRepository {
  final IsarService _isarService;
  final NotificationService _notificationService;

  ReminderRepository({
    IsarService? isarService,
    NotificationService? notificationService,
  })  : _isarService = isarService ?? IsarService(),
        _notificationService = notificationService ?? NotificationService();

  Future<List<WatchReminder>> getActiveReminders() async {
    final all = await _isarService.getAllReminders();
    return all.where((r) => r.enabled).toList();
  }

  Future<void> addReminder({
    required String mediaId,
    required String mediaTitle,
    required DateTime reminderDateTime,
  }) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    final reminder = WatchReminder(
      mediaId: mediaId,
      title: mediaTitle,
      reminderDateTime: reminderDateTime,
      enabled: true,
      notificationId: notificationId,
    );

    await _isarService.saveReminder(reminder);
    await _notificationService.scheduleWatchReminder(
      id: notificationId,
      title: 'Watch Reminder',
      mediaTitle: mediaTitle,
      scheduledDate: reminderDateTime,
    );
  }

  Future<void> deleteReminder(int notificationId) async {
    await _notificationService.cancelReminder(notificationId);
    await _isarService.deleteReminder(notificationId);
  }
}
