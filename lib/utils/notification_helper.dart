import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  // =========== ENGINE & SAFETY ============

  // Engine that talks to android/ios
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  // Don't start the engine twice
  static bool _initialized = false;

  // =========== CHANNEL ID (MAILBOX) ============

  // Every notification must belong to a channel
  // Force Android to refresh settings to create new mailbox with updated settings
  static const String _channelId = 'expense_reminder_channel_v2';

  static Future<void> _syncLocalTimeZone() async {
    try {
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone()
          .timeout(const Duration(seconds: 2));
      final String name = tzResult is String ? tzResult : tzResult.toString();
      tz.setLocalLocation(tz.getLocation(name));
      debugPrint('Local timezone synced: $name');
    } catch (e) {
      // Keep app resilient even if timezone plugin fails on some OEM devices.
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Manila'));
        debugPrint('Timezone sync failed, using Asia/Manila fallback: $e');
      } catch (_) {
        debugPrint('Timezone sync failed and fallback could not be applied: $e');
      }
    }
  }

  static Future<void> ensureInitialized() async {
    // Is the engine already running
    if (_initialized) return;

    // Set global clock (in my city)
    tz.initializeTimeZones();
    await _syncLocalTimeZone();

    // Use app's icon as symbol on the notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Folder holding instructions of the phone
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    // ========== INITIALIZE ============= 
    // Connect to phone system
    await _plugin.initialize(
      initializationSettings,
      // When user taps on notification, print in console
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );
    // Foundation is ready
    _initialized = true;
  }

  // ========== VIP PASS ==============
  // Pass notification because Android blocks app from waking up to save battery
  static Future<void> checkBatteryOptimizations() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        // Don't put app to sleep when baterry optimization is on
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  // =============== ALERT STYLE ==============
  // How the notification should look like and act
  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    _channelId, // Use v2 ID defined earlier
    'Expense Tracking Reminders', // Name user will see in Android settings
    channelDescription: 'Reminders to log expenses based on user frequency.',
    importance: Importance.max, // Set to max for heads-up notifications (dropdown)
    priority: Priority.high, // Tell android it's an important message
    ticker: 'Expense reminder', // Text that scrolls in status bar 
    playSound: true, 
    enableVibration: true,
    fullScreenIntent: true, // Helps wake the screen on supported devices
  );

  // Wrap style into general details obj that the plugin can understand
  static const NotificationDetails _details =
      NotificationDetails(android: _androidDetails);

  // ========= ANDROID 13/14 GATEKEEPERS =========

  // Trigger allow notifications? popup when opening the app
  static Future<void> _requestAndroidNotificationPermissionIfNeeded() async {
      if (!Platform.isAndroid) return;
      
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // 1. Request standard notification permission (Heads-up/Sounds)
      await androidImpl?.requestNotificationsPermission();
      
      // 2. Request/Check Exact Alarm permission
      try {
        await androidImpl?.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint("Could not request exact alarm permission: $e");
      }
  }

  // ======== TEST LAB ===========

  // Verify if icon, sound, and permission are working before the real reminders
  static Future<void> showTestNotification({String? message}) async {
    // Make sure engine is plugged in
    await ensureInitialized();
    try {
      // Ask for Allow popup
      await _requestAndroidNotificationPermissionIfNeeded();
      // Instant  show
      await _plugin.show(
        999, // id for this specific notification
        'Notifications enabled', // title
        message ?? 'You will receive reminders at your chosen time.', // body
        _details, // style
      );
    } catch (e) {
      debugPrint('Failed to show test notification: $e');
    }
  }

  // ========== TIMER CHECK =============
  // Test if app can successfully talk to the phone's alarm system
  static Future<void> scheduleOneShotTest({Duration delay = const Duration(seconds: 10)}) async {
    // See if notification works when app is not actively doing something
    await ensureInitialized();
    await _syncLocalTimeZone();
    // Get current time
    final now = tz.TZDateTime.now(tz.local);
    // Add 10 seconds to "now" to give time to hit save
    final when = now.add(delay);
    
    // Talk specifically to the Android side of the plugin
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      debugPrint("Android plugin implementation not found!");
      return;
    }
    // PLAN A : Exact Alarm (interrupts sleep)
    // This is when user has toggled allow exact alarm in settings
    try {
      await _requestAndroidNotificationPermissionIfNeeded();
      
      // 1. Resolve the specific Android implementation
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // 2. Use 'scheduleMode' instead of 'androidScheduleMode'
        await androidPlugin.zonedSchedule(
          998,
          'Test Timer Success!',
          'This appeared after 10 seconds.',
          when,
          _details.android, // <--- Add .android here
          scheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint("Scheduled successfully for: $when");
      }
    } catch (e) {
      debugPrint("Direct Android schedule failed: $e");
    }
  }

  // =============== EL BRAIN ===============

  static Future<void> scheduleFromPrefs() async {
    // ====== GATEKEEPERS ======
    await ensureInitialized();
    await _syncLocalTimeZone();
    final prefs = await SharedPreferences.getInstance();
    // Set to true in customizations when user clicks Save
    // If false, helper stops immediately to save battery recalculating schedule
    final pending = prefs.getBool('pendingSchedule') ?? false;
    // IF user toggled notifs off, call cancelALll() and set pending to false
    final enabled = prefs.getBool('notificationsEnabled') ?? false;

    if (!pending) return;

    try {
      if (!enabled) {
        await _plugin.cancelAll();
        await prefs.setBool('pendingSchedule', false);
        return;
      }

      // Before setting a new reminmer, delete old ones to prevent double notifs
      await _requestAndroidNotificationPermissionIfNeeded();
      await _plugin.cancelAll();

      // Fetch exact hour, and min from time picker
      final freq = prefs.getString('reminderFrequency') ?? 'Daily';
      final hour = prefs.getInt('reminderHour') ?? 20;
      final minute = prefs.getInt('reminderMinute') ?? 0;

      final now = tz.TZDateTime.now(tz.local);
      
      // Create scheduled time for TODAY
      var nextSchedule = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If it's earlier than 'now', or even 'now' within the same minute, 
      // move to tomorrow to avoid a 'time in the past' error.
      if (nextSchedule.isBefore(now.add(const Duration(seconds: 5)))) {
        nextSchedule = nextSchedule.add(const Duration(days: 1));
      }

      debugPrint(
        'Scheduling reminder. tz=${tz.local.name}, now=$now, next=$nextSchedule, '
        'freq=$freq, h=$hour, m=$minute',
      );

      // ====== FREQUENCY TYPE ======
      DateTimeComponents? matchComponents;
      int notificationId;

      if (freq == 'Daily') {
        // Repeat at this time everyday
        matchComponents = DateTimeComponents.time;
        notificationId = 100;
      } else if (freq == 'Weekly') {
        matchComponents = DateTimeComponents.dayOfWeekAndTime;
        notificationId = 200;
      } else if (freq == 'Monthly') {
        matchComponents = DateTimeComponents.dayOfMonthAndTime;
        notificationId = 300;
      } else {
        notificationId = 400;
      }

      // 3. ONLY cancel that specific ID, not everything
      await _plugin.cancel(notificationId);
      // ====== HAND OFF TO ANDROID ========
      try {
        await _plugin.zonedSchedule(
          notificationId,
          'Time to Track Your Expenses!',
          "Don't forget to log your recent expenses to stay within your budget.",
          nextSchedule,
          _details,
          payload: 'expense_reminder',
          // Prefer exact alarm when available.
          // Ignore wwhat OS is doing, wake up CPU and show exactly at time
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchComponents,
        );
      } catch (exactError) {
        // If exact alarms are denied on this device/OS, keep the same schedule
        // but use inexact mode so user still receives reminders at set time.
        debugPrint('Exact schedule failed, retrying inexact: $exactError');
        await _plugin.zonedSchedule(
          notificationId,
          'Time to Track Your Expenses!',
          "Don't forget to log your recent expenses to stay within your budget.",
          nextSchedule,
          _details,
          payload: 'expense_reminder',
          // Retry inexact if exact fails
          // Waits for OS if OS is delayed doing something else before showing notifs
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchComponents,
        );
      }

      await prefs.setBool('pendingSchedule', false);
      debugPrint('Notification scheduled successfully for: $nextSchedule');
    } catch (e) {
      debugPrint('scheduleFromPrefs failed: $e');
    }
  }

  // ========= EMERGENCY STOP =========
  // Wipes every scheduled reminder from phones memory and set pending to false
  static Future<void> cancelAll({bool clearPending = true}) async {
    await ensureInitialized();
    await _plugin.cancelAll();
    if (clearPending) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pendingSchedule', false);
    }
  }
}