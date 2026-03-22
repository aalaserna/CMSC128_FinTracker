import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/db_helper.dart';
import 'expense_model.dart';

class MonthlyViewPage extends StatefulWidget {
  const MonthlyViewPage({super.key});

  @override
  State<MonthlyViewPage> createState() => _MonthlyViewPageState();
}

class _MonthlyViewPageState extends State<MonthlyViewPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Expense> _allExpenses = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAllExpenses();
  }

  // Fetch data from DB
  Future<void> _loadAllExpenses() async {
    final data = await DBHelper().getAllExpenses();
    setState(() {
      _allExpenses = data;
    });
  }

  // Math Helpers
  double _getMonthlyTotal() {
    return _allExpenses
        .where((expense) => 
            expense.date.year == _focusedDay.year && 
            expense.date.month == _focusedDay.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double _getSelectedDayTotal() {
    if (_selectedDay == null) return 0.0;
    return _getExpensesForDay(_selectedDay!).fold(0.0, (sum, e) => sum + e.amount);
  }

  // Dot markers to show that there are expenses on the given day
  List<Expense> _getExpensesForDay(DateTime day) {
    return _allExpenses.where((expense) {
      return expense.date.year == day.year &&
             expense.date.month == day.month &&
             expense.date.day == day.day;
    }).toList();
  }

  // Helper to map categories to specific colors
  Color _getMarkerColor(String category) {
    switch (category.toLowerCase()) {
      case 'transpo':
        return Colors.blue.shade700;
      case 'food':
        return Colors.red.shade700;
      case 'education':
        return Colors.green.shade700;
      case 'wants':
        return Colors.purple.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildSummaryCard(String title, String amount, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Expense item) {
    IconData icon;
    Color iconColor;
    switch (item.category.toLowerCase()) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.category.toUpperCase(),
                  style: TextStyle(color: Colors.blueGrey[300], fontSize: 10),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            "-₱${item.amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayExpenses = _selectedDay != null ? _getExpensesForDay(_selectedDay!) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Monthly View',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.black),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar<Expense>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2070, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getExpensesForDay,
              
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color.fromARGB(255, 157, 174, 204),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color.fromARGB(255, 220, 232, 245),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.black),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              
              // Custom Dots according to recorded expenses for the day
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();

                  // Limit to 3 dots, and check if we need a "+"
                  const maxDots = 3;
                  final showPlus = events.length > maxDots;
                  final visibleEvents = events.take(maxDots).toList();

                  return Positioned(
                    bottom: 5,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...visibleEvents.map((expense) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              height: 7,
                              width: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getMarkerColor(expense.category),
                              ),
                            )),
                        if (showPlus)
                          const Padding(
                            padding: EdgeInsets.only(left: 1.0),
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 77, 99, 111),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },

              // This fires when swiping left/right to change the month, 
              // or when tapping the chevrons in the header.
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay; // Selects the 1st day of the new month
                  _selectedDay = focusedDay;
                });
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard(
                  "Monthly Total",
                  "₱${_getMonthlyTotal().toStringAsFixed(2)}",
                  const Color(0xFFDCE8F5),
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  "Daily Total",
                  "₱${_getSelectedDayTotal().toStringAsFixed(2)}",
                  const Color(0xFFEAEAF4),
                ),
              ],
            ),
          ),

          Expanded(
            child: selectedDayExpenses.isEmpty
              ? Center(
                  child: Text(
                    'No expenses for ${_selectedDay?.month}/${_selectedDay?.day}.',
                    style: const TextStyle(
                      color: Colors.grey, 
                      fontSize: 16
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: selectedDayExpenses.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = selectedDayExpenses[index];
                    return _buildTransactionItem(item);
                  },
              ),
          ),
        ],
      ),
    );
  }
}