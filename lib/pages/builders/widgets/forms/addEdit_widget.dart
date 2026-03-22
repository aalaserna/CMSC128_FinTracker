import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../designs/colors.dart';

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorBodyText,
      ),
    ),
  );
}

Widget buildTextInput({
  TextEditingController? controller,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  required ValueChanged<String> onChanged,
  FormFieldValidator<String>? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    validator: validator,
    style: const TextStyle(fontSize: 15, color: colorBodyText),
    decoration: InputDecoration(
      filled: true,
      fillColor: colorFieldBg,
      hintText: hint,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    ),
  );
}

Widget formDropdownSelector({
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

// expense category 
Widget buildExpenseCategoryDropdown({
  required String value,
  required ValueChanged<String?> onChanged,
}) {
  const validCategories = ['transpo', 'food', 'education', 'wants'];
  final safeValue = validCategories.contains(value) ? value : 'food';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: colorFieldBg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: safeValue,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: colorBodyText),
        style: const TextStyle(
          color: colorBodyText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: colorFieldBg,
        items: const [
          DropdownMenuItem(value: 'transpo',   child: Text('Transpo')),
          DropdownMenuItem(value: 'food',      child: Text('Food')),
          DropdownMenuItem(value: 'education', child: Text('Education')),
          DropdownMenuItem(value: 'wants',     child: Text('Wants')),
        ],
        onChanged: onChanged,
      ),
    ),
  );
}

// date picker
Widget buildDatePicker({
  required BuildContext context,
  required DateTime selectedDate,
  required ValueChanged<DateTime> onDateChanged,
}) {
  return GestureDetector(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) onDateChanged(picked);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: colorFieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate(selectedDate),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorBodyText,
            ),
          ),
          const Icon(Icons.calendar_month_rounded, size: 18, color: colorBodyText),
        ],
      ),
    ),
  );
}

String formattedDate(DateTime d) {
  const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}