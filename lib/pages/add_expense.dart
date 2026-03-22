import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'expense_model.dart';

const _navy     = Color(0xFF1C2340);
const _cardBg   = Color(0xFFBFC8D6);
const _fieldBg  = Colors.white;
const _bodyText = Color(0xFF2E3A59);
const _hintText = Color(0xFF8A9BB5);
const _pageBg   = Color(0xFFDDE4EE);

class AddExpensePage extends StatefulWidget {
  final DateTime initialDate;
  const AddExpensePage({super.key, required this.initialDate});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String name     = '';
  String amount   = '';
  String category = 'food';
  String details  = '';
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  String _formattedDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          // bg bubble 
          _Bubble(top: -30,  right: -20, size: 160, opacity: 0.45),
          _Bubble(top:  40,  right:  30, size:  80, opacity: 0.30),
          _Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          _Bubble(bottom:  60, left:  20, size:  90, opacity: 0.25),
          _Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // Page title
                  const Text(
                    'Add a new expense',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  //card
                  Container(
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          _buildLabel('Title'),
                          _buildTextInput(
                            hint: 'Enter description here',
                            onChanged: (v) => name = v,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Enter a name' : null,
                          ),
                          const SizedBox(height: 14),

                          // Amount
                          _buildLabel('Amount'),
                          _buildTextInput(
                            hint: 'Enter amount here',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            onChanged: (v) => amount = v,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter amount';
                              final p = double.tryParse(v.trim());
                              if (p == null) return 'Enter valid amount';
                              if (p <= 0)    return 'Amount must be positive';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Category
                          _buildLabel('Category'),
                          _buildDropdown(),
                          const SizedBox(height: 14),

                          // Date Spent
                          _buildLabel('Date Spent'),
                          _buildDateRow(context),
                          const SizedBox(height: 24),

                          // Add Expense button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final newExpense = Expense(
                                    name: name,
                                    amount: double.parse(amount),
                                    category: category,
                                    date: selectedDate,
                                    details: details,
                                  );
                                  Navigator.pop(context, newExpense);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Add Expense',
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
                  ),
                ],
              ),
            ),
          ),
          ),

          // back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          color: _navy, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: _navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //helpers

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _bodyText,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: _bodyText),
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldBg,
        hintText: hint,
        hintStyle: const TextStyle(color: _hintText, fontSize: 14),
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
          borderSide: const BorderSide(color: _navy, width: 1.5),
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: category,
          decoration: const InputDecoration(border: InputBorder.none),
          icon: const Icon(Icons.keyboard_arrow_down, color: _bodyText),
          style: const TextStyle(
            color: _bodyText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: _fieldBg,
          items: const [
            DropdownMenuItem(value: 'transpo',   child: Text('Transpo')),
            DropdownMenuItem(value: 'food',      child: Text('Food')),
            DropdownMenuItem(value: 'education', child: Text('Education')),
            DropdownMenuItem(value: 'wants',     child: Text('Wants')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => category = v);
          },
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      children: [
        // Date pill
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: BoxDecoration(
                color: _fieldBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formattedDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _bodyText,
                    ),
                  ),
                  const Icon(Icons.calendar_month_rounded,
                      size: 18, color: _bodyText),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// bubble deco

class _Bubble extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final double opacity;

  const _Bubble({
    this.top, this.bottom, this.left, this.right,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }
}