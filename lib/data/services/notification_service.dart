import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint("Notification clicked: ${details.payload}");
        },
      );
      _isInitialized = true;
      debugPrint("NotificationService initialized successfully");
    } catch (e, st) {
      debugPrint("Error initializing NotificationService: $e\n$st");
    }
  }

  Future<void> scheduleWatchReminder({
    required int id,
    required String title,
    required String mediaTitle,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) await init();
    try {
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);
      if (scheduledTz.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint("Reminder time is in the past, skipping schedule");
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        'cinevault_reminders',
        'Watch Reminders',
        channelDescription: 'Notifications for upcoming movie and TV show watch reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        id,
        'CineVault Watch Reminder',
        'Time to watch: $mediaTitle',
        scheduledTz,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Scheduled notification #$id for $mediaTitle at $scheduledDate");
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint("Error cancelling notification #$id: $e");
    }
  }
}
