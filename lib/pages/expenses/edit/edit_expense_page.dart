import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../builders/designs/bubble_background.dart';
import '../../builders/widgets/forms/addEdit_widget.dart';
import '../../expense_model.dart';
import '../../builders/designs/colors.dart';

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
    name         = widget.expense.name;
    amountText   = widget.expense.amount.toStringAsFixed(2);
    category     = widget.expense.category;
    details      = widget.expense.details;
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
      backgroundColor: colorPageBg,
      body: Stack(
        children: [
          // bg bubbles
          Bubble(top: -30,  right: -20, size: 160, opacity: 0.45),
          Bubble(top:  40,  right:  30, size:  80, opacity: 0.30),
          Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          Bubble(bottom:  60, left:  20, size:  90, opacity: 0.25),
          Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),

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
                          color: colorNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

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
                            // Description
                            buildLabel('Description'),
                            buildTextInput(
                              controller: _nameController,
                              hint: 'Enter description here',
                              onChanged: (v) => name = v,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter a name' : null,
                            ),
                            const SizedBox(height: 14),

                            // Amount
                            buildLabel('Amount'),
                            buildTextInput(
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
                            buildLabel('Category'),
                            buildExpenseCategoryDropdown(
                              value: category,
                              onChanged: (v) {
                                if (v != null) setState(() => category = v);
                              },
                            ),
                            const SizedBox(height: 14),

                            // Date Spent
                            buildLabel('Date Spent'),
                            buildDatePicker(
                              context: context,
                              selectedDate: selectedDate,
                              onDateChanged: (d) => setState(() => selectedDate = d),
                            ),
                            const SizedBox(height: 24),

                            // Update button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorNavy,
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
                          color: colorNavy, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: colorNavy,
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
}