import 'package:flutter/material.dart';
import 'expense_model.dart';
import 'dart:core';
import '../database/db_helper.dart';

class HomePage extends StatefulWidget {
  // Note: The expenses list is managed statically now (HomePage.expenses)
  // and edit/delete operations call setState in the _HomePageState via this key/method.
  const HomePage({super.key});

  // Permanent storage for every expense
  static final List<Expense> expenses = [];
  
  // REQUIRED: Global key to access state from outside (e.g., in main.dart's FAB)
  static final GlobalKey<_HomePageState> homePageStateKey = GlobalKey<_HomePageState>();

  @override
  State<HomePage> createState() => _HomePageState();
}

// Set up a stateful widget with mixing for animation control (for TabController)
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  
  final Color kBlueLight = const Color(0xFFDCE8F5);
  final Color kSelectedBlue = const Color(0xFF5E6C85);

  late List<DateTime> weekDates;
  late String currentMonthName;
  late TabController _tabController;

Future<void> loadExpenses() async {
  final data = await DBHelper().getAllExpenses();
  setState(() {
    HomePage.expenses.clear();
    HomePage.expenses.addAll(data);
  });
}

  // REQUIRED: Method to get the currently selected date, called by main.dart
  DateTime getSelectedDate() {
    return weekDates[_tabController.index];
  }

  // Calculates the dates for the current week, starting on Monday.
  List<DateTime> _getCurrentWeekDates() {
    final now = DateTime.now();
    // now.weekday is 1 (Mon) to 7 (Sun). Subtracting (now.weekday - 1) gets us to Monday.
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  @override
  void initState(){
    loadExpenses();
    super.initState();
    weekDates = _getCurrentWeekDates();
    
    final now = DateTime.now();
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    currentMonthName = months[now.month - 1];

    // Find today's index (0-6) and initialize TabController
    int todayIndex = now.weekday - 1; 
    _tabController = TabController(
      length: weekDates.length, 
      vsync: this,
      initialIndex: todayIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); 
    super.dispose();
  }

  void _deleteExpense(int index) async {
    final id = HomePage.expenses[index].id!;
    if (id != null) {
      await DBHelper().deleteExpense(id);
    }
    setState(() {
      HomePage.expenses.removeAt(index);
    });
  }

  void _editExpense(int index, String name, double amount, String category,
      DateTime date, String details) async {
        final old = HomePage.expenses[index];

      final updatedExpense = Expense(
      id: old.id, // PRESERVE DATABASE ID
      name: name,
      amount: amount,
      category: category,
      date: date,
      details: details,
    );
        
   
    // Update the database if the ID exists
    if (updatedExpense.id != null) {
      await DBHelper().updateExpense(updatedExpense);
    }

    // Update the in-memory list and trigger UI refresh
    setState(() {
      HomePage.expenses[index] = updatedExpense;
    });        
  }  
             
  // Edit popup
  void _openEditExpenseDialog(int index) {
    Expense e = HomePage.expenses[index];
    String name = e.name;
    String amountText = e.amount.toStringAsFixed(2); 
    String category = e.category;
    String details = e.details;
    DateTime selectedDate = e.date;
    
    final nameController = TextEditingController(text: name);
    final amountController = TextEditingController(text: amountText);
    final detailsController = TextEditingController(text: details);


    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Expense Name'),
                    controller: nameController,
                    onChanged: (value) => name = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => amountText = value,
                  ),
                  DropdownButtonFormField<String>(
                    value: ['transpo', 'food', 'education', 'wants'].contains(category) ? category : 'transpo',
                    items: const [
                      DropdownMenuItem(value: 'transpo', child: Text('Transpo')),
                      DropdownMenuItem(value: 'food', child: Text('Food')),
                      DropdownMenuItem(value: 'education', child: Text('Education')),
                      DropdownMenuItem(value: 'wants', child: Text('Wants')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) setStateDialog(() => category = value);
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Details'),
                    controller: detailsController,
                    onChanged: (value) => details = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setStateDialog(() => selectedDate = pickedDate);
                          }
                        },
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final double? amount = double.tryParse(amountController.text);
                  if (nameController.text.isNotEmpty && amount != null) {
                    _editExpense(index, nameController.text, amount, category, selectedDate, detailsController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    ).then((_) {
      nameController.dispose();
      amountController.dispose();
      detailsController.dispose();
    });
  }
  
  String _getDayTotal(DateTime date) {
    final dayExpenses = HomePage.expenses.where((e) => _isSameDay(e.date, date)).toList();
    double total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return "₱${total.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          currentMonthName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Custom Day Selector (Row of Buttons) ---
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 8), 
            child: Row(
              children: weekDates.asMap().entries.map((entry) {
                final index = entry.key;
                final date = entry.value;
                final dayName = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday - 1];
                
                bool isSelected = _tabController.index == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4), 
                      decoration: BoxDecoration(
                        color: isSelected ? kSelectedBlue : const Color(0xFFE0E0E0).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName, 
                            style: TextStyle(
                              fontSize: 11, 
                              color: isSelected ? Colors.white70 : Colors.grey
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(), 
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: isSelected ? Colors.white : Colors.grey[700]
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // --- Main Content Area (TabBarView) ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: weekDates.map((date) {
                return _buildDayPage(date);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Widget responsible for showing summary cards and the list of expenses for a specific day
  Widget _buildDayPage(DateTime date) {
    final dayExpenses = HomePage.expenses.where((e) => _isSameDay(e.date, date)).toList();
    
    return Column(
      children: [
        // SUMMARY CARDS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Added vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard("Expenses", _getDayTotal(date)),
              const SizedBox(width: 8),
              _buildSummaryCard("Balance Left", "₱12,000"), 
              const SizedBox(width: 8),
              _buildSummaryCard("Savings", "₱12,000"), 
            ],
          ),
        ),

        const SizedBox(height: 10), // Reduced spacing slightly

        Expanded(
          child: dayExpenses.isEmpty
              ? Center(
                  child: Text(
                    "No expenses for ${['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday - 1]}.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80), 
                  itemCount: dayExpenses.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = dayExpenses[index];
                    final realIndex = HomePage.expenses.indexOf(item);

                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, child: const Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      )),
                      onDismissed: (direction) => _deleteExpense(realIndex),
                      child: _buildTransactionItem(item, realIndex),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Helper widget for the summary cards
  Widget _buildSummaryCard(String title, String amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kBlueLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
            const SizedBox(height: 5),
            Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  // Helper widget for a single transaction row
  Widget _buildTransactionItem(Expense item, int realIndex) {
    IconData icon;
    Color iconColor;
    switch (item.category) {
      case 'transpo':
        icon = Icons.directions_car_filled;
        iconColor = Colors.blue.shade700;
        break;
      case 'food':
        icon = Icons.fastfood;
        iconColor = Colors.red.shade700;
        break;
      case 'education':
        icon = Icons.school;
        iconColor = Colors.green.shade700;
        break;
      case 'wants':
        icon = Icons.shopping_bag;
        iconColor = Colors.purple.shade700;
        break;
      default:
        icon = Icons.attach_money;
        iconColor = Colors.black;
    }

    return Container(
      color: const Color(0xFFECF3FA),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit_square, color: Colors.grey[400], size: 24),
            onPressed: () => _openEditExpenseDialog(realIndex),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(item.category.toUpperCase(), style: TextStyle(color: Colors.blueGrey[300], fontSize: 10)),
              ],
            ),
          ),
          const Spacer(),
          Text("-₱${item.amount.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
        ],
      ),
    );
  }
}