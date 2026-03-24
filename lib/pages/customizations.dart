import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import '../main.dart';
import '../utils/notification_helper.dart';

bool get _supportsNotifications =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);

const _navy = Color(0xFF1C2340);
const _cardBg = Color(0xFFBFC8D6);
const _fieldBg = Colors.white;
const _bodyText = Color(0xFF2E3A59);
const _hintText = Color(0xFF8A9BB5);
const _divider = Color(0xFFD0D7E2);

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
    // Use notification helper from utils
    await NotificationHelper.showTestNotification(message: "Syncing notification settings...");
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

    // This tells the helper there is a new schedule to set
    await prefs.setBool('pendingSchedule', true);

    if (_notificationsEnabled) {
      // 1. Check for battery/exact alarm permissions
      await NotificationHelper.checkBatteryOptimizations();
      // 2. Schedule the notification
      await NotificationHelper.scheduleFromPrefs();
      
      // 3. OPTIONAL: Show a test notification immediately to confirm it works
      await NotificationHelper.showTestNotification(
        message: "Reminders set for ${_selectedTime.format(context)}"
      );
    }

    // CRITICAL FIX: Check if the screen is still visible before popping
    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ExpenseHomePage()),
        (route) => false,
      );
      return;
    }

    _showTopSnackBar('Customizations saved.');
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

  String _formatCurrency(double value) => 'PHP ${value.toStringAsFixed(2)}';

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);

    if (enabled && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      try {
        final allowed = await androidImpl?.areNotificationsEnabled();
        if (allowed == false) {
          await androidImpl?.requestNotificationsPermission();
        }
        final nowAllowed = await androidImpl?.areNotificationsEnabled();
        if (nowAllowed != false) {
          await NotificationHelper.showTestNotification(
            message: 'Reminders are enabled. Daily tracking keeps you on budget!',
          );
        }
      } catch (e) {
        debugPrint('Permission request failed: $e');
      }
    }

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
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
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

  // ignore: unused_element
  Future<void> _checkPendingNotifications() async {
    if (_supportsNotifications) {
      final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      _showTopSnackBar('Pending reminders: ${pending.length}');
      return;
    }
    _showTopSnackBar('Notifications are not supported on this platform.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF3),
      body: Stack(
        children: [
          const _Bubble(top: -30, right: -20, size: 160, opacity: 0.45),
          const _Bubble(top: 40, right: 30, size: 80, opacity: 0.30),
          const _Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          const _Bubble(bottom: 60, left: 20, size: 90, opacity: 0.25),
          const _Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Customizations',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Shape your account around\nyour habits and goals.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _bodyText,
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
                          onChanged: (v) => setState(() => _selectedBudgetFrequency = v!),
                        ),
                        const SizedBox(height: 16),
                        _buildNotificationToggle(),
                        Visibility(
                          visible: _notificationsEnabled,
                          maintainState: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Divider(color: _divider, height: 28),
                              _buildLabel('Set your reminder frequency'),
                              _buildReminderRow(context),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: () async {
                            // 1. Show an immediate snackbar so you know the timer started
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Timer started! Lock your phone now.")),
                            );

                            // 2. Trigger the 10-second background timer
                            await NotificationHelper.scheduleOneShotTest(delay: const Duration(seconds: 10));
                          },
                          icon: const Icon(Icons.timer, color: Colors.white),
                          label: const Text("Test 10s Timer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent, // Different color so it stands out
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        // System Alarms
                        ElevatedButton(
                          onPressed: () async {
                            final List<PendingNotificationRequest> pendingReqs = 
                                await flutterLocalNotificationsPlugin.pendingNotificationRequests();
                            
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text("System Alarms: ${pendingReqs.length}"),
                                content: Text(pendingReqs.isEmpty 
                                  ? "Nothing scheduled!" 
                                  : "Scheduled: ${pendingReqs[0].title}"),
                              ),
                            );
                          },
                          child: const Text("Check Samsung Alarm List"),
                        ),
                                              
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saveCustomizations,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _bodyText,
        ),
      ),
    );
  }

  Widget _buildBudgetInputField() {
    return TextField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 15, color: _bodyText),
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldBg,
        hintText: _savedBudget != null ? _formatCurrency(_savedBudget!) : 'Enter your budget here...',
        hintStyle: const TextStyle(color: _hintText, fontSize: 14),
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
          borderSide: const BorderSide(color: _navy, width: 1.5),
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
        color: _fieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _bodyText),
          style: const TextStyle(
            color: _bodyText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: _fieldBg,
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
        const Text(
          'Enable Expense Reminders',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _bodyText,
          ),
        ),
        Switch(
          value: _notificationsEnabled,
          activeThumbColor: _navy,
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
              backgroundColor: _fieldBg,
              foregroundColor: _bodyText,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _bodyText,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.access_time_rounded, size: 16, color: _bodyText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final double opacity;

  const _Bubble({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
