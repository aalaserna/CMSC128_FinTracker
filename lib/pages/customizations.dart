import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz; 
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'dart:io';


class CustomizationPage extends StatefulWidget {
  const CustomizationPage({super.key});

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  //Notification Plugin Instance 
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin(); 

  // State variables for customization options
  String _budgetAmount = ''; // Budget text input
  String _selectedBudgetFrequency = 'Weekly'; 
  String _selectedReminderFrequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0); // Default to 8:00 PM
  bool _notificationsEnabled = true; 

  // Lists for dropdown options
  final List<String> _budgetFrequencies = ['Weekly', 'Monthly'];
  final List<String> _reminderFrequencies = ['Daily', 'Weekly', 'Monthly'];

  // Text controller for the budget input field
  final TextEditingController _budgetController = TextEditingController();

  @override 
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    // Initialize notifications only on supported platforms (Android, iOS, macOS, Linux)
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux) {
      _initializeNotifications();
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  //Notifications 
  void _initializeNotifications() async { 
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped with payload: ${response.payload}');
      },
    );
  }

  //Notification schedule 
  Future<void> _scheduleReminder() async {
    await flutterLocalNotificationsPlugin.cancelAll();
     // 2. Define the notification details for Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expense_reminder_channel_id', // Unique channel ID
      'Expense Tracking Reminders', // Channel name
      channelDescription: 'Reminders to log expenses based on user frequency.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // 3. Set the Time Zone
    // We use tz.local which represents the device's current time zone.
    final now = tz.TZDateTime.now(tz.local);
    
    // 4. Calculate the next exact time for the reminder
    var nextSchedule = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If the selected time is already past today, schedule it for the next appropriate period (e.g., tomorrow)
    if (nextSchedule.isBefore(now)) {
      nextSchedule = nextSchedule.add(const Duration(days: 1));
    }
    
    // 5. Define notification content
    const String title = 'Time to Track Your Expenses!';
    const String body = 'Don\'t forget to log your recent expenses to stay within your budget.';

    // 6. Schedule the notification based on frequency
    DateTimeComponents matchComponents;
    int notificationId = 0;
    
    if (_selectedReminderFrequency == 'Daily') {
      matchComponents = DateTimeComponents.time; // Repeat at the same time every day
      notificationId = 100;
      
    } else if (_selectedReminderFrequency == 'Weekly') {
      matchComponents = DateTimeComponents.dayOfWeekAndTime; // Repeat on the same day/time every week
      notificationId = 200;
      
    } else if (_selectedReminderFrequency == 'Monthly') {
      matchComponents = DateTimeComponents.dayOfMonthAndTime; // Repeat on the same day/time every month
      notificationId = 300;
      
    } else {
      // Default to one-time notification if frequency is somehow invalid
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, 
        title, 
        body, 
        nextSchedule, 
        notificationDetails, 
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('One-time reminder scheduled.');
      return;
    }

    // Schedule the repeating notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      nextSchedule,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchComponents, 
    );
    print('${_selectedReminderFrequency} reminder scheduled for ${_selectedTime.format(context)}');
  }

  // Function to show the time picker dialog (same as before)
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function called when the Done button is pressed
  void _saveCustomizations() async {
    _budgetAmount = _budgetController.text;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isFirstTime", false); // mark setup completed
    // Optionally (re)schedule reminders based on current settings
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux) {
      if (_notificationsEnabled) {
        await _scheduleReminder();
      } else {
        await flutterLocalNotificationsPlugin.cancelAll();
      }
    }

    // Show count of pending scheduled notifications
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux) {
      final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pending.length} pending notifications found (see console)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications not supported on Windows; settings saved.')),
      );
    }

    // Continue to Home page after saving
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseHomePage()),
    );
  } 

  // NEW: Helper widget for the notification toggle switch
  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Enable Expense Reminders',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: _notificationsEnabled,
          onChanged: (bool newValue) {
            setState(() {
              _notificationsEnabled = newValue;
            }); 
          },
        ),
      ],
    );

    // Navigation handled after saving; keep toggle focused on UI state only
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 50),
              // --- Title Section ---
              const Text(
                'Customize your budget and notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // --- 1. Set Your Budget ---
              _buildSectionTitle('Set your budget'),
              _buildBudgetInputField(),
              const SizedBox(height: 20),

              // --- 2. Choose Your Budget Cycle ---
              _buildSectionTitle('Choose your budget cycle'),
              _buildDropdownSelector(
                value: _selectedBudgetFrequency,
                items: _budgetFrequencies,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBudgetFrequency = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              const Divider(height: 30),

              // --- NOTIFICATION TOGGLE ---
              _buildNotificationToggle(),
              const SizedBox(height: 20), 

              // --- 3. Set Your Reminder Frequency ---
              _buildSectionTitle('Set your reminder frequency'),
              _buildReminderRow(context),
              const SizedBox(height: 40),

              // --- 4. Done Button ---
              ElevatedButton(
                onPressed: _saveCustomizations,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Full width button
                  backgroundColor: Colors.blue[900], // Dark color from Figma
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // TEMPORARY: Button to check pending notifications
              TextButton(
                onPressed: _checkPendingNotifications,
                child: const Text('Check Pending Reminders (For Testing)'),
              ),
              // END TEMPORARY
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  // Helper widget for the budget input field
  Widget _buildBudgetInputField() {
    return TextField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Enter your budget here',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  // Helper widget for a generic dropdown selector
  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Helper widget for the reminder frequency and time row
  Widget _buildReminderRow(BuildContext context) {
    return Row(
      children: [
        // Dropdown for Frequency (e.g., Daily)
        Expanded(
          flex: 3,
          child: _buildDropdownSelector(
            value: _selectedReminderFrequency,
            items: _reminderFrequencies,
            onChanged: (newValue) {
              setState(() {
                _selectedReminderFrequency = newValue!;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        // Time Button (e.g., 8:00 PM)
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => _selectTime(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _selectedTime.format(context),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // Inspect currently scheduled notifications for debugging/test
  Future<void> _checkPendingNotifications() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux) {
      final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      for (final p in pending) {
        print('Pending: id=${p.id}, title=${p.title}, body=${p.body}, payload=${p.payload}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pending reminders: ${pending.length}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications are not supported on Windows.')),
      );
    }
  }
}