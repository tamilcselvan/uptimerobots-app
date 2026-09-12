import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/monitor.dart';

/// Stable 31-bit id for [FlutterLocalNotificationsPlugin.show], derived
/// from the composite monitor id so repeat notifications for the same
/// monitor replace each other instead of stacking.
int stableNotificationId(String monitorId) => monitorId.hashCode & 0x7fffffff;

/// Wraps flutter_local_notifications behind a single init + show call.
/// Safe to call from the main isolate or a background isolate (Workmanager)
/// — each creates its own instance/plugin binding.
class NotificationService {
  static const _channelId = 'monitor_status_changes';
  static const _channelName = 'Monitor status changes';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
        linux: linuxSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> notifyStatusChange({
    required int notificationId,
    required String accountLabel,
    required String friendlyName,
    required MonitorStatus oldStatus,
    required MonitorStatus newStatus,
  }) async {
    await init();

    final isDown = newStatus == MonitorStatus.down || newStatus == MonitorStatus.seemsDown;
    final title = isDown ? '🔴 $friendlyName is down' : '🟢 $friendlyName is back up';
    final body = '$accountLabel · ${_label(oldStatus)} → ${_label(newStatus)}';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Alerts when a monitored URL goes down or recovers',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  String _label(MonitorStatus status) => switch (status) {
        MonitorStatus.up => 'Up',
        MonitorStatus.down => 'Down',
        MonitorStatus.seemsDown => 'Seems down',
        MonitorStatus.paused => 'Paused',
        MonitorStatus.notCheckedYet => 'Not checked yet',
      };
}
