import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../l10n/app_localizations.dart';
import '../utils/date_time_utils.dart';

/// Schedules a single local notification before the predicted period.
class ReminderService {
  ReminderService._();

  static const int _notificationId = 1001;
  static const String _channelId = 'strawly_reminders';
  static const String _channelName = 'Period reminders';
  static const int _fireHour = 9;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(_channelId, _channelName),
    iOS: DarwinNotificationDetails(),
  );

  static bool _initialized = false;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<void> init() async {
    if (!isSupported || _initialized) return;
    tzdata.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Requests notification permission. Returns true when granted (or not needed).
  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
  }

  /// Builds the exact title/body used by the production period reminder.
  /// Shared by scheduling and the debug menu so they never drift apart.
  static (String, String) periodReminderPayload(
    AppLocalizations l10n,
    DateTime predictedDate,
    String locale,
  ) {
    return (
      l10n.appName,
      l10n.reminderNotificationBody(
        DateTimeUtils.formatDate(predictedDate, locale),
      ),
    );
  }

  static Future<void> scheduleReminder({
    required DateTime predictedDate,
    required int leadDays,
    required String title,
    required String body,
  }) async {
    if (!isSupported) return;
    await init();
    await cancelReminder();
    final day = DateTime(
      predictedDate.year,
      predictedDate.month,
      predictedDate.day,
    );
    final fireDate = day
        .subtract(Duration(days: leadDays))
        .add(const Duration(hours: _fireHour));
    if (!fireDate.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      _notificationId,
      title,
      body,
      tz.TZDateTime.from(fireDate, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Shows a notification immediately (used by the debug menu).
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (!isSupported) return;
    await init();
    await _plugin.show(_notificationId, title, body, _details);
  }

  static Future<void> cancelReminder() async {
    if (!isSupported) return;
    await _plugin.cancel(_notificationId);
  }
}
