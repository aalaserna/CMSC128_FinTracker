import 'package:flutter/material.dart';
import 'expense_model.dart';

/* Stateful widget is needed because the text fields and selected
    data/category will change before submitting the final expense
*/
class AddExpensePage extends StatefulWidget {
  final DateTime initialDate;
  const AddExpensePage({super.key, required this.initialDate});
  
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // Reference and validate form inputs
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String amount = '';
  String category = 'transpo';
  String details = '';
  String customCategory = '';
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            // Input fields
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Expense Name'),
                onChanged: (val) => name = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = val,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter amount';
                  }
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null) {
                    return 'Enter valid amount';
                  }
                  if (parsed <= 0) {
                    return 'Amount must be positive';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'transpo', child: Text('Transportation')),
                  DropdownMenuItem(value: 'food', child: Text('Daily Food')),
                  DropdownMenuItem(value: 'school', child: Text('School')),
                  DropdownMenuItem(value: 'groceries', child: Text('Groceries')),
                  DropdownMenuItem(value: 'bill', child: Text('Bills')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
                onChanged: (val) {
                  if (val != null){
                    setState((){
                      category = val;
                      if (category != 'custom') {
                        customCategory = '';
                      }
                    });
                  }
                },
              ),
              if (category == 'custom')
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Custom Category'),
                  onChanged: (val) => customCategory = val,
                  validator: (val) {
                    if (category == 'custom' &&
                        (val == null || val.trim().isEmpty)) {
                      return 'Enter a custom category';
                    }
                    return null;
                  },
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Details'),
                onChanged: (val) => details = val,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                      'Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add expense button action
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final finalCategory =
                      category == 'custom' ? customCategory.trim().toLowerCase() : category;
                   final newExpense = Expense(
                      name: name,
                      amount: double.parse(amount),
                      category: finalCategory,
                      date: selectedDate,
                      details: details,
                    );
                    Navigator.pop(context, newExpense);
                  }
                },
                child: const Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
