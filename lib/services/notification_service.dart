import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const String channelId = 'kumpul_in_reminders';
  static const String channelName = 'Pengingat Event Baraya';
  static const String channelDescription = 'Notifikasi H-1 sebelum kegiatan komunitas';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _plugin;
  bool get isInitialized => _isInitialized;

  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const LinuxInitializationSettings linuxSettings =
          LinuxInitializationSettings(
        defaultActionName: 'Buka Notifikasi',
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      final initialized = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      _isInitialized = initialized ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('NotificationService init error (handled safely): $e');
      return false;
    }
  }

  Future<bool> scheduleH1Reminder({
    required int id,
    required String eventTitle,
    required DateTime eventDateTime,
    String? location,
  }) async {
    try {
      await init();

      // H-1 (24 hours before)
      var scheduledTime = eventDateTime.subtract(const Duration(hours: 24));
      // If event is in less than 24 hours, schedule for 1 minute from now for demo
      if (scheduledTime.isBefore(DateTime.now())) {
        scheduledTime = DateTime.now().add(const Duration(seconds: 10));
      }

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      final dateStr = DateFormat('EEEE, d MMM yyyy - HH:mm', 'id_ID').format(eventDateTime);
      final body = location != null && location.isNotEmpty
          ? 'Besok ada "$eventTitle" di $location ($dateStr)!'
          : 'Besok ada "$eventTitle" ($dateStr)! Jangan lupa hadir ya!';

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        id,
        '⏰ Reminder H-1: $eventTitle',
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      return true;
    } catch (e) {
      debugPrint('Notification schedule error (fallback gracefully): $e');
      return false;
    }
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await init();

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('Instant notification error: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }
}