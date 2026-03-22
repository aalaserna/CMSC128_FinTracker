import 'package:flutter/material.dart';
import '../../designs/colors.dart';
// import 'forms_widget.dart';


Widget buildDropdownSelector({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colorFieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: colorBodyText),
          style: const TextStyle(
            color: colorBodyText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: colorFieldBg,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

Widget buildBudgetInputField({
  required TextEditingController controller,
  required double? savedBudget,
  required String Function(double) formatCurrency,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: const TextStyle(fontSize: 15, color: colorBodyText),
    decoration: InputDecoration(
      filled: true,
      fillColor: colorFieldBg,
      hintText: savedBudget != null
          ? formatCurrency(savedBudget)
          : 'Enter your budget here...',
      hintStyle: const TextStyle(color: colorHintText, fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
        borderSide: const BorderSide(color: colorNavy, width: 1.5),
      ),
    ),
  );
}

Widget buildNotificationToggle({
  required bool notificationsEnabled,
  required ValueChanged<bool> onChanged,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Enable Expense Reminders',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorBodyText,
        ),
      ),
      Switch(
        value: notificationsEnabled,
        activeColor: colorNavy,
        onChanged: onChanged,
      ),
    ],
  );
}

Widget buildReminderRow({
  required BuildContext context,
  required String selectedReminderFrequency,
  required List<String> reminderFrequencies,
  required ValueChanged<String?> onFrequencyChanged,
  required TimeOfDay selectedTime,
  required VoidCallback onTimeTap,
}) {
  return Row(
    children: [
      Expanded(
        flex: 3,
        child: buildDropdownSelector(
          value: selectedReminderFrequency,
          items: reminderFrequencies,
          onChanged: onFrequencyChanged,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 2,
        child: GestureDetector(
          onTap: onTimeTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: colorFieldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedTime.format(context),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorBodyText,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.access_time_rounded,
                    size: 16, color: colorBodyText),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}