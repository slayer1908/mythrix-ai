import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local + FCM notifications wrapper.
///
/// V1 covers local notifications for scheduled posts. FCM remote handlers can
/// be wired once a Firebase project is connected.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Logger _log = Logger();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();

    const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initMacOs = DarwinInitializationSettings();
    const initLinux = LinuxInitializationSettings(defaultActionName: 'Open');

    await _plugin.initialize(const InitializationSettings(
      android: initAndroid,
      iOS: initIos,
      macOS: initMacOs,
      linux: initLinux,
    ));

    if (kDebugMode) _log.i('NotificationService ready.');
  }

  /// Schedule a one-shot notification for an upcoming post.
  Future<void> schedulePost({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    if (!_initialized) await init();
    final atTz = tz.TZDateTime.from(at, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      atTz,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mythrix_scheduled_posts',
          'Scheduled posts',
          channelDescription: 'Reminders for scheduled social posts.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async => _plugin.cancel(id);
}

final notificationServiceProvider =
    Provider<NotificationService>((_) => NotificationService.instance);
