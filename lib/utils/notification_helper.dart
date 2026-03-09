import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) {
      _initialized = true;
      return;
    }
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _plugin.initialize(initializationSettings);
    _initialized = true;
  }

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'expense_reminder_channel_id',
    'Expense Tracking Reminders',
    channelDescription:
        'Reminders to log expenses based on user frequency.',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    playSound: true,
    enableVibration: true,
    ticker: 'Expense reminder',
  );
  static const NotificationDetails _details =
      NotificationDetails(android: _androidDetails);

  // Show an immediate test notification to verify permissions/channels.
  static Future<void> showTestNotification({String? message}) async {
    await _ensureInitialized();
    try {
      if (Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final allowed = await androidImpl?.areNotificationsEnabled();
        if (allowed == false) {
          await androidImpl?.requestNotificationsPermission();
        }
      }
      await _plugin.show(
        999,
        'Notifications enabled',
        message ?? 'You will receive reminders at your chosen time.',
        _details,
      );
    } catch (_) {}
  }

  // Schedule a one-shot notification after a short delay for testing.
  static Future<void> scheduleOneShotTest({Duration delay = const Duration(seconds: 10)}) async {
    await _ensureInitialized();
    final when = tz.TZDateTime.now(tz.local).add(delay);
    try {
      await _plugin.zonedSchedule(
        998,
        'Test reminder',
        'This is a quick test notification.',
        when,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          998,
          'Test reminder',
          'This is a quick test notification (inexact).',
          when,
          _details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  // Schedules notifications based on stored preferences when pending flag is set.
  static Future<void> scheduleFromPrefs() async {
    await _ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getBool('pendingSchedule') ?? false;
    final enabled = prefs.getBool('notificationsEnabled') ?? false;
    if (!pending) return;

    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux)) {
      await prefs.setBool('pendingSchedule', false);
      return;
    }

    try {
      if (!enabled) {
        await _plugin.cancelAll();
        await prefs.setBool('pendingSchedule', false);
        return;
      }

      // Clear any existing scheduled notifications so updated settings take effect cleanly
      await _plugin.cancelAll();

      final freq = prefs.getString('reminderFrequency') ?? 'Daily';
      final hour = prefs.getInt('reminderHour') ?? 20;
      final minute = prefs.getInt('reminderMinute') ?? 0;

      final now = tz.TZDateTime.now(tz.local);
      var nextSchedule = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (nextSchedule.isBefore(now)) {
        nextSchedule = nextSchedule.add(const Duration(days: 1));
      }

      const details = _details;

      late DateTimeComponents matchComponents;
      late int notificationId;
      if (freq == 'Daily') {
        matchComponents = DateTimeComponents.time;
        notificationId = 100;
      } else if (freq == 'Weekly') {
        matchComponents = DateTimeComponents.dayOfWeekAndTime;
        notificationId = 200;
      } else if (freq == 'Monthly') {
        matchComponents = DateTimeComponents.dayOfMonthAndTime;
        notificationId = 300;
      } else {
        // One-time fallback
        await _plugin.zonedSchedule(
          0,
          'Time to Track Your Expenses!',
          "Don't forget to log your recent expenses to stay within your budget.",
          nextSchedule,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        await prefs.setBool('pendingSchedule', false);
        return;
      }

      try {
        await _plugin.zonedSchedule(
          notificationId,
          'Time to Track Your Expenses!',
          "Don't forget to log your recent expenses to stay within your budget.",
          nextSchedule,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchComponents,
        );
      } catch (_) {
        try {
          await _plugin.zonedSchedule(
            notificationId,
            'Time to Track Your Expenses!',
            "Don't forget to log your recent expenses to stay within your budget.",
            nextSchedule,
            details,
            androidScheduleMode: AndroidScheduleMode.inexact,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: matchComponents,
          );
        } catch (_) {}
      }

      await prefs.setBool('pendingSchedule', false);
    } catch (e) {
      // Never throw
      try {
        await prefs.setBool('pendingSchedule', false);
      } catch (_) {}
    }
  }
}
