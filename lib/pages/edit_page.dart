import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'expense_model.dart';

const _navy     = Color(0xFF1C2340);
const _cardBg   = Color(0xFFBFC8D6);
const _fieldBg  = Colors.white;
const _bodyText = Color(0xFF2E3A59);
const _hintText = Color(0xFF8A9BB5);
const _pageBg   = Color(0xFFDDE4EE);

class EditExpensePage extends StatefulWidget {
  final Expense expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();

  late String name;
  late String amountText;
  late String category;
  late String details;
  late DateTime selectedDate;

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    name        = widget.expense.name;
    amountText  = widget.expense.amount.toStringAsFixed(2);
    category    = widget.expense.category;
    details     = widget.expense.details;
    selectedDate = widget.expense.date;

    _nameController    = TextEditingController(text: name);
    _amountController  = TextEditingController(text: amountText);
    _detailsController = TextEditingController(text: details);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  String _formattedDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double? amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) return;

      final updated = Expense(
        id:       widget.expense.id,
        name:     _nameController.text.trim(),
        amount:   amount,
        category: category,
        date:     selectedDate,
        details:  _detailsController.text.trim(),
      );
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          _Bubble(top: -30,  right: -20, size: 160, opacity: 0.45),
          _Bubble(top:  40,  right:  30, size:  80, opacity: 0.30),
          _Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          _Bubble(bottom:  60, left:  20, size:  90, opacity: 0.25),
          _Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),

          // centered content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Page title
                      const Text(
                        'Edit expense',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // card
                      Container(
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Description
                            _buildLabel('Description'),
                            _buildTextInput(
                              controller: _nameController,
                              hint: 'Enter description here',
                              onChanged: (v) => name = v,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter a name' : null,
                            ),
                            const SizedBox(height: 14),

                            // Amount
                            _buildLabel('Amount'),
                            _buildTextInput(
                              controller: _amountController,
                              hint: 'Enter amount here',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                              onChanged: (v) => amountText = v,
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

                            // Update button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _navy,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Update',
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
            ),
          ),

          // back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
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

  //helper

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
    required TextEditingController controller,
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
    final validCategories = ['transpo', 'food', 'education', 'wants'];
    final safeCategory = validCategories.contains(category) ? category : 'transpo';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _fieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeCategory,
          isExpanded: true,
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
    return GestureDetector(
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
            const Icon(Icons.calendar_month_rounded, size: 18, color: _bodyText),
          ],
        ),
      ),
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