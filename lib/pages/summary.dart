import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'expense_model.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Expense> _expenses = [];
  bool _isLoading = true;
  late DateTime _selectedWeek;
  List<DateTime> _availableWeeks = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    _selectedWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    loadExpensesFromDB();
  }

  Future<void> loadExpensesFromDB() async {
    final db = DBHelper();
    final data = await db.getAllExpenses();

    setState(() {
      _expenses = data;
      _generateAvailableWeeks();
      _isLoading = false;
    });
  }

  void _generateAvailableWeeks() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);

    final currentStartOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    final List<DateTime> weeks = [];
    DateTime weekStart = currentStartOfWeek;

    while (true) {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final isInCurrentMonth =
          weekStart.month == now.month || weekEnd.month == now.month;

      if (!isInCurrentMonth) {
        break;
      }

      weeks.add(weekStart);
      weekStart = weekStart.subtract(const Duration(days: 7));
    }

    _availableWeeks = weeks.reversed.toList();
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Map<String, dynamic> calculateWeeklySummary() {
    final startOfWeek = DateTime(
      _selectedWeek.year,
      _selectedWeek.month,
      _selectedWeek.day,
    );

    final endOfWeek = startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  
    if (_expenses.isEmpty) {
      return {
        'total': 0.0,
        'categories': <Map<String, dynamic>>[],
        'chartCategories': <Map<String, dynamic>>[],
        'startOfWeek': startOfWeek,
        'endOfWeek': endOfWeek,
      };
    }

    final List<Expense> weeklyExpensesList = _expenses.where((e) {
      final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
      return (expenseDate.isAfter(startOfWeek) ||
              expenseDate.isAtSameMomentAs(startOfWeek)) &&
          (expenseDate.isBefore(endOfWeek) ||
              expenseDate.isAtSameMomentAs(endOfWeek));
    }).toList();

    final double total =
        weeklyExpensesList.fold(0.0, (sum, e) => sum + e.amount);

    final Map<String, double> categoryTotals = {};
    for (final expense in weeklyExpensesList) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final List<Map<String, dynamic>> categoryData =
        categoryTotals.entries.map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getColorForCategory(entry.key),
      };
    }).toList();

    final List<Map<String, dynamic>> chartData = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getColorForCategory(entry.key),
      };
    }).toList();

    return {
      'total': total,
      'categories': categoryData,
      'chartCategories': chartData,
      'startOfWeek': startOfWeek,
      'endOfWeek': endOfWeek,
    };
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color.fromARGB(255, 190, 173, 124);
      case 'school':
        return const Color(0xFFFF7A45);
      case 'transpo':
        return const Color(0xFF4D78E6);
      case 'groceries':
        return const Color(0xFF8AD99A);
      case 'bill':
        return const Color.fromARGB(255, 117, 197, 213);
      case 'custom':
        return const Color.fromARGB(255, 187, 107, 227);
      default:
        return const Color(0xFFBFC7D5);
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'school':
        return Icons.school;
      case 'transpo':
        return Icons.directions_car;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'bill':
        return Icons.receipt;
      case 'custom':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  List<PieChartSectionData> _getPieChartSections(
    List<Map<String, dynamic>> categoryData,
  ) {
    if (categoryData.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '',
          radius: 58,
        ),
      ];
    }

    return categoryData.map((data) {
      return PieChartSectionData(
        color: data['color'] as Color,
        value: data['amount'] as double,
        title: '',
        radius: 58,
      );
    }).toList();
  }

  int _transactionCountForCategory(String category) {
    final startOfWeek = DateTime(
      _selectedWeek.year,
      _selectedWeek.month,
      _selectedWeek.day,
    );

    final endOfWeek = startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return _expenses.where((e) {
      final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
      return e.category.toLowerCase() == category.toLowerCase() &&
          (expenseDate.isAfter(startOfWeek) ||
              expenseDate.isAtSameMomentAs(startOfWeek)) &&
          (expenseDate.isBefore(endOfWeek) ||
              expenseDate.isAtSameMomentAs(endOfWeek));
    }).length;
  }

  Widget _expenseTile({
    required Color color,
    required String title,
    required double amount,
    required IconData icon,
    required int transactions,
  }) {
    final displayTitle =
        title.isNotEmpty ? title[0].toUpperCase() + title.substring(1) : title;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$transactions transaction${transactions == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202124),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = calculateWeeklySummary();
    final double weeklyExpenses = summary['total'] as double;
    final List<Map<String, dynamic>> categoryData =
        List<Map<String, dynamic>>.from(
      (summary['categories'] ?? const []) as List,
    );
    final List<Map<String, dynamic>> chartData =
        List<Map<String, dynamic>>.from(
      (summary['chartCategories'] ?? const []) as List,
    );

    final pieChartSections = _getPieChartSections(chartData);
    final isDataEmpty = chartData.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4EE),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Weekly Expense',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₱${weeklyExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E2723),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Spent this week',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: SizedBox(
                      height: 210,
                      width: 210,
                      child: PieChart(
                        PieChartData(
                          sections: pieChartSections,
                          centerSpaceRadius: 52,
                          sectionsSpace: 0,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE3E5E8)),
                    ),
                    child: DropdownButton<DateTime>(
                      isExpanded: true,
                      value: _availableWeeks.contains(_selectedWeek)
                          ? _selectedWeek
                          : (_availableWeeks.isNotEmpty ? _availableWeeks.first : _selectedWeek),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      items: _availableWeeks.map((weekStart) {
                        final endOfWeek = weekStart.add(const Duration(days: 6));
                        return DropdownMenuItem<DateTime>(
                          value: weekStart,
                          child: Text(
                            '${_formatFullDate(weekStart)} - ${_formatFullDate(endOfWeek)}',
                          ),
                        );
                      }).toList(),
                      onChanged: (DateTime? newWeek) {
                        if (newWeek != null) {
                          setState(() {
                            _selectedWeek = newWeek;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...categoryData.map(
              (data) => _expenseTile(
                color: data['color'] as Color,
                title: data['name'] as String,
                amount: data['amount'] as double,
                icon: _getIconForCategory(data['name'] as String),
                transactions:
                    _transactionCountForCategory(data['name'] as String),
              ),
            ),
            if (isDataEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    'No expenses recorded for this week.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}