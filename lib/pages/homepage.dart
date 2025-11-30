import 'package:flutter/material.dart';
import 'expense_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static final List<Expense> expenses = [];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday -1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

late List<DateTime> weekDates; 

  @override
  void initState(){
    super.initState();
    weekDates = getCurrentWeekDates(); 
    _tabController = TabController(length: weekDates.length, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose(); 
  }

  void _deleteExpense(int index) {
    setState(() {
      HomePage.expenses.removeAt(index);
    });
  }

  void _editExpense(int index, String name, double amount, String category,
      DateTime date, String details) {
    setState(() {
      HomePage.expenses[index] = Expense(
        name: name,
        amount: amount,
        category: category,
        date: date,
        details: details,
      );
    });
  }

  void _openEditExpenseDialog(int index) {
    Expense e = HomePage.expenses[index];
    String name = e.name;
    String amount = e.amount.toString();
    String category = e.category;
    String details = e.details;
    DateTime selectedDate = e.date;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(labelText: 'Expense Name'),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    controller: TextEditingController(text: amount),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => amount = value,
                  ),
                  DropdownButtonFormField(
                    value: category,
                    items: const [
                      DropdownMenuItem(
                          value: 'transpo', child: Text('Transpo')),
                      DropdownMenuItem(value: 'food', child: Text('Food')),
                      DropdownMenuItem(
                          value: 'education', child: Text('Education')),
                      DropdownMenuItem(value: 'wants', child: Text('Wants')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => category = value);
                      }
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Details'),
                    controller: TextEditingController(text: details),
                    onChanged: (value) => details = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                          'Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
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
                  if (name.isNotEmpty && double.tryParse(amount) != null) {
                    _editExpense(
                        index,
                        name,
                        double.parse(amount),
                        category,
                        selectedDate,
                        details);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = HomePage.expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Expenses"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: weekDates.map((date) => Tab(
            text: '${['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday-1]} ${date.day}/${date.month}',
          )).toList(),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: weekDates.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value; 
          // Filter expenses by selected weekday
          final filtered = HomePage.expenses.where((e) {
            return e.date.year == weekDates[index].year &&
                   e.date.month == weekDates[index].month &&
                   e.date.day == weekDates[index].day;
          }).toList();

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade200,
                child: Text(
                  'Weekly Sum: ₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

            Expanded(
              child: filtered.isEmpty
                    ? Center(child: Text('No expenses for $day.'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final e = filtered[index];
                          final realIndex = HomePage.expenses.indexOf(e);

                          return ListTile(
                            title: Text(e.name),
                            subtitle: Text(
                              '₱${e.amount.toStringAsFixed(2)} • ${e.category}\n'
                              '${e.details.isNotEmpty ? "${e.details}\n" : ""}'
                              '${e.date.toLocal().toString().split(' ')[0]}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _openEditExpenseDialog(realIndex),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color.fromARGB(255, 94, 23, 18)),
                                  onPressed: () => _deleteExpense(realIndex),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}