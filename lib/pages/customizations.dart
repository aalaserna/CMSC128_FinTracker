import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'builders/designs/bubble_background.dart';
import 'package:fins/themes/logic/app_themes.dart';

import '../main.dart';
import '../utils/notification_helper.dart';

bool get _supportsNotifications =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);

class CustomizationPage extends StatefulWidget {
  const CustomizationPage({super.key});

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _selectedBudgetFrequency = 'Weekly';
  String _selectedReminderFrequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _notificationsEnabled = true;
  double? _savedBudget;

  final List<String> _budgetFrequencies = ['Weekly', 'Monthly'];
  final List<String> _reminderFrequencies = ['Daily', 'Weekly', 'Monthly'];
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    if (_supportsNotifications) {
      _initializeNotifications();
    }
    _loadExistingSettings();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await NotificationHelper.ensureInitialized();
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveCustomizations() async {
    final prefs = await SharedPreferences.getInstance();

    final parsedBudget = double.tryParse(_budgetController.text.trim());
    final budgetToStore = parsedBudget ?? _savedBudget ?? 0.0;

    await prefs.setDouble('budgetAmount', budgetToStore);
    await prefs.setString('budgetCycle', _selectedBudgetFrequency);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('reminderFrequency', _selectedReminderFrequency);
    await prefs.setInt('reminderHour', _selectedTime.hour);
    await prefs.setInt('reminderMinute', _selectedTime.minute);
    await prefs.setBool('pendingSchedule', true);
    await prefs.setBool('hasCompletedOnboarding', true);
    await prefs.setBool('isFirstTime', false);

    if (_notificationsEnabled) {
      await NotificationHelper.checkBatteryOptimizations();
      await NotificationHelper.scheduleFromPrefs();
      await NotificationHelper.showTestNotification(
        message: 'Reminders set for ${_selectedTime.format(context)}',
      );
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseHomePage()),
      (route) => false,
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

    final savedFreq = prefs.getString('reminderFrequency');
    if (savedFreq != null && _reminderFrequencies.contains(savedFreq)) {
      setState(() => _selectedReminderFrequency = savedFreq);
    }

    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');
    if (hour != null && minute != null) {
      setState(() => _selectedTime = TimeOfDay(hour: hour, minute: minute));
    }
  }

  String _formatCurrency(double value) => '₱${value.toStringAsFixed(2)}';

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);

    if (enabled && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      try {
        final allowed = await androidImpl?.areNotificationsEnabled();
        if (allowed == false) {
          await androidImpl?.requestNotificationsPermission();
        }
      } catch (e) {
        debugPrint('Permission request failed: $e');
      }
    }

    if (!enabled && _supportsNotifications) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Bubble(top: -30, right: -20, size: 160, opacity: 0.45),
          const Bubble(top: 40, right: 30, size: 80, opacity: 0.30),
          const Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          const Bubble(bottom: 60, left: 20, size: 90, opacity: 0.25),
          const Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Customizations',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.onPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Shape your account around\nyour habits and goals.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.onSurface,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildLabel('Set your budget'),
                        _buildBudgetInputField(),
                        const SizedBox(height: 16),
                        _buildLabel('Choose your budget cycle'),
                        _buildDropdownSelector(
                          value: _selectedBudgetFrequency,
                          items: _budgetFrequencies,
                          onChanged: (v) =>
                              setState(() => _selectedBudgetFrequency = v!),
                        ),
                        const SizedBox(height: 16),
                        _buildNotificationToggle(),
                        Visibility(
                          visible: _notificationsEnabled,
                          maintainState: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(color: context.surface, height: 28),
                              _buildLabel('Set your reminder frequency'),
                              _buildReminderRow(context),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saveCustomizations,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: context.surface,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: context.onSurface,
        ),
      ),
    );
  }

  Widget _buildBudgetInputField() {
    return TextField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 15, color: context.onPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.onSurface.withOpacity(0.1),
        hintText: _savedBudget != null
            ? _formatCurrency(_savedBudget!)
            : 'Enter your budget here...',
        hintStyle: TextStyle(color: context.hintText, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: context.primary),
          style: TextStyle(
            color: context.primary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: context.surface,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Enable Expense Reminders',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.primary,
          ),
        ),
        Switch(
          value: _notificationsEnabled,
          activeThumbColor: context.primary,
          onChanged: _updateNotificationsEnabled,
        ),
      ],
    );
  }

  Widget _buildReminderRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildDropdownSelector(
            value: _selectedReminderFrequency,
            items: _reminderFrequencies,
            onChanged: (v) => setState(() => _selectedReminderFrequency = v!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => _selectTime(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: context.surface.withOpacity(0.1),
              foregroundColor: context.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: context.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
