import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'builders/designs/bubble_background.dart';
import 'package:flutter/foundation.dart';
import 'builders/designs/colors.dart';
import 'builders/widgets/forms/addEdit_widget.dart';
import 'builders/widgets/forms/customize_widget.dart';

bool get _supportsNotifications =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
     defaultTargetPlatform == TargetPlatform.iOS ||
     defaultTargetPlatform == TargetPlatform.windows);

class CustomizationPage extends StatefulWidget {
  const CustomizationPage({super.key});

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _budgetAmount = '';
  String _selectedBudgetFrequency = 'Weekly';
  String _selectedReminderFrequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _notificationsEnabled = true;
  double? _savedBudget;

  final List<String> _budgetFrequencies    = ['Weekly', 'Monthly'];
  final List<String> _reminderFrequencies  = ['Daily', 'Weekly', 'Monthly'];
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    if (_supportsNotifications) _initializeNotifications();
    _loadExistingSettings();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  // notifs

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped with payload: ${response.payload}');
      },
    );
  }

  Future<void> _scheduleReminder() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'expense_reminder_channel_id',
          'Expense Tracking Reminders',
          channelDescription: 'Reminders to log expenses based on user frequency.',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var nextSchedule = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      _selectedTime.hour, _selectedTime.minute,
    );
    if (nextSchedule.isBefore(now)) {
      nextSchedule = nextSchedule.add(const Duration(days: 1));
    }

    const String title = 'Time to Track Your Expenses!';
    const String body  =
        'Don\'t forget to log your recent expenses to stay within your budget.';

    DateTimeComponents matchComponents;
    int notificationId = 0;

    if (_selectedReminderFrequency == 'Daily') {
      matchComponents = DateTimeComponents.time;
      notificationId  = 100;
    } else if (_selectedReminderFrequency == 'Weekly') {
      matchComponents = DateTimeComponents.dayOfWeekAndTime;
      notificationId  = 200;
    } else if (_selectedReminderFrequency == 'Monthly') {
      matchComponents = DateTimeComponents.dayOfMonthAndTime;
      notificationId  = 300;
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, title, body, nextSchedule, notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('One-time reminder scheduled.');
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, title, body, nextSchedule, notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchComponents,
    );
    print('${_selectedReminderFrequency} reminder scheduled for ${_selectedTime.format(context)}');
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  // save n load

  void _saveCustomizations() async {
    _budgetAmount = _budgetController.text.trim();

    double? _parseBudget(String text) {
      final cleaned = text.replaceAll(RegExp(r'[^0-9\.]'), '');
      if (cleaned.isEmpty) return null;
      return double.tryParse(cleaned);
    }

    double? budgetToSave;
    if (_budgetAmount.isEmpty) {
      budgetToSave = _savedBudget;
    } else {
      budgetToSave = _parseBudget(_budgetAmount);
    }

    if (budgetToSave == null || budgetToSave < 0) {
      _showTopSnackBar('Please enter a valid budget amount.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budgetAmount', budgetToSave);
    await prefs.setString('budgetCycle', _selectedBudgetFrequency);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('cycleStartEpochMs', DateTime.now().millisecondsSinceEpoch);
    prefs.setBool("isFirstTime", false);

    setState(() => _savedBudget = budgetToSave);

    if (_supportsNotifications) {
      if (_notificationsEnabled) {
        await _scheduleReminder();
      } else {
        await flutterLocalNotificationsPlugin.cancelAll();
      }
    }

    if (_supportsNotifications) {
      final pending =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      _showTopSnackBar('${pending.length} pending notifications found (see console)');
    } else {
      _showTopSnackBar('Notifications not supported on Windows; settings saved.');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseHomePage()),
    );
  }

  Future<void> _loadExistingSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final b = prefs.getDouble('budgetAmount');
    if (b != null) setState(() => _savedBudget = b);

    final cycle = prefs.getString('budgetCycle');
    if (cycle != null && _budgetFrequencies.contains(cycle)) {
      setState(() => _selectedBudgetFrequency = cycle);
    }

    final notif = prefs.getBool('notificationsEnabled');
    if (notif != null) setState(() => _notificationsEnabled = notif);
  }

  String _formatCurrency(double value) => '₱${value.toStringAsFixed(2)}';

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    if (!enabled && _supportsNotifications) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  void _showTopSnackBar(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2E3A59),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => entry.remove(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  Future<void> _checkPendingNotifications() async {
    if (_supportsNotifications) {
      final pending =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      for (final p in pending) {
        print('Pending: id=${p.id}, title=${p.title}, body=${p.body}, payload=${p.payload}');
      }
      _showTopSnackBar('Pending reminders: ${pending.length}');
    } else {
      _showTopSnackBar('Notifications are not supported on Windows.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF3),
      body: Stack(
        children: [
          // Background bubbles
          Bubble(top: -30,  right: -20, size: 160, opacity: 0.45),
          Bubble(top:  40,  right:  30, size:  80, opacity: 0.30),
          Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          Bubble(bottom:  60, left:  20, size:  90, opacity: 0.25),
          Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),

          // content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // page title
                  const Text(
                    'Customizations',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colorNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // card
                  Container(
                    decoration: BoxDecoration(
                      color: colorCardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card subtitle
                        const Text(
                          'Shape your account around\nyour habits and goals.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorBodyText,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // budget
                        buildLabel('Set your budget'),
                        buildBudgetInputField(
                          controller: _budgetController,
                          savedBudget: _savedBudget,
                          formatCurrency: _formatCurrency,
                        ),
                        const SizedBox(height: 16),

                        // budget cycle
                        buildLabel('Choose your budget cycle'),
                        buildDropdownSelector(
                          value: _selectedBudgetFrequency,
                          items: _budgetFrequencies,
                          onChanged: (v) =>
                              setState(() => _selectedBudgetFrequency = v!),
                        ),
                        const SizedBox(height: 16),

                        buildNotificationToggle(
                            notificationsEnabled: _notificationsEnabled,
                            onChanged: _updateNotificationsEnabled,
                          ),
                        // reminder settings
                        Visibility(
                          visible: _notificationsEnabled,
                          maintainState: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Divider(color: colorDivider, height: 28),
                              buildLabel('Set your reminder frequency'),
                              buildReminderRow(
                                context: context,
                                selectedReminderFrequency: _selectedReminderFrequency,
                                reminderFrequencies: _reminderFrequencies,
                                onFrequencyChanged: (v) =>
                                    setState(() => _selectedReminderFrequency = v!),
                                selectedTime: _selectedTime,
                                onTimeTap: () => _selectTime(context),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // done button
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saveCustomizations,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorNavy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}