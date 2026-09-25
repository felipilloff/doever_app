import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'reminder_service.dart';

final class LocalReminders implements ReminderService {
  LocalReminders({this.onOpen});
  final void Function(String taskId)? onOpen;
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  @override
  bool get supported =>
      !kIsWeb && defaultTargetPlatform != TargetPlatform.linux;
  Future<void> _initialize() =>
      _initializing ??= _init().catchError((Object e) {
        _initializing = null;
        throw e;
      });
  Future<void> _init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        windows: WindowsInitializationSettings(
          appName: 'Doever',
          appUserModelId: 'app.doever.doever',
          guid: '4e4193ef-3387-4da4-929c-8ec0124bd75d',
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) onOpen?.call(response.payload!);
      },
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!supported) return false;
    await _initialize();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: false, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: false, sound: true) ??
            false;
      default:
        return true;
    }
  }

  @override
  Future<void> schedule({
    required int id,
    required String taskId,
    required String title,
    required DateTime at,
  }) async {
    if (!supported) {
      throw UnsupportedError('Scheduled notifications unavailable');
    }
    await _initialize();
    await _plugin.zonedSchedule(
      id: id,
      title: 'Doever',
      body: title,
      payload: taskId,
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      // Inexact avoids special alarm permission; Android may batch delivery.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task reminders',
          channelDescription: 'Reminders you assign to tasks',
          visibility: NotificationVisibility.private,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    if (!supported) return;
    await _initialize();
    await _plugin.cancel(id: id);
  }
}
