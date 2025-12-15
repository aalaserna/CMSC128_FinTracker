import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; 
//import 'homepage.dart';
import 'expense_model.dart';
import '../database/db_helper.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadExpensesFromDB();
  }

  Future<void> loadExpensesFromDB() async {
    final db = DBHelper();
    final data = await db.getAllExpenses();

    setState(() {
      _expenses = data;
      _isLoading = false;
    });
  }

  /*
  =======================================
  Helper: calculate expenses for the week
  =======================================
  */

  Map<String, dynamic> calculateWeeklySummary() {
    if (_expenses.isEmpty) {
      return {
        'total': 0.0,
        'categories': [],
        'startOfWeek': DateTime.now(), // Included for display in the UI
        'endOfWeek': DateTime.now(), // Included for display in the UI
      };
    }    

    // ===== Determine Current Week's Date Range =====

    // Today (with time component)
    final now = DateTime.now();
    
    // 1. Calculate Start of the Week (Monday, 00:00:00)
    // We normalize 'now' to midnight before calculating the start of the week.
    // This is the CRUCIAL fix to ensure the date range is accurate regardless of time of day.
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final startOfWeek = todayMidnight.subtract(Duration(days: now.weekday - 1));
    
    // 2. Calculate End of the Week (Sunday, 23:59:59)
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));


    // ===== Filter Expenses For Current Week =====
    final List<Expense> weeklyExpensesList = _expenses.where((e) {
      // Compare only the date (normalize the expense date)
      final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
      
      // Must be greater than or equal to startOfWeek AND less than or equal to endOfWeek
      return (expenseDate.isAfter(startOfWeek) || expenseDate.isAtSameMomentAs(startOfWeek)) &&
             (expenseDate.isBefore(endOfWeek) || expenseDate.isAtSameMomentAs(endOfWeek));
    }).toList();

    // ===== Calculate the Total Weekly Expense =====
    final double total = weeklyExpensesList.fold(0.0, (sum, e) => sum + e.amount);

    // ===== Group and Calculate Totals for each category
    Map<String, double> categoryTotals = {};
    for (var expense in weeklyExpensesList) {
      categoryTotals.update(
        expense.category, 
        (value) => value + expense.amount, 
        ifAbsent: () => expense.amount
      );
    }

    // ===== Build data for legend (all categories)
    final List<Map<String, dynamic>> categoryData = categoryTotals.entries.map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getColorForCategory(entry.key),
      };
    }).toList();

    // ===== Build data for chart (positive amounts only)
    final double positiveSum = categoryTotals.values
        .where((v) => v > 0)
        .fold(0.0, (sum, v) => sum + v);

    final List<Map<String, dynamic>> chartData = categoryTotals.entries
        .where((e) => e.value > 0)
        .map((entry) {
      final percent = positiveSum > 0 ? ((entry.value / positiveSum) * 100).round() : 0;
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getColorForCategory(entry.key),
        'percent': percent,
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
      case 'food': return Colors.yellow.shade600;
      case 'education': return Colors.blue.shade600;
      case 'transpo': return Colors.red.shade600;
      case 'wants': return Colors.purple.shade600;
      default: return Colors.blueGrey.shade400; // 'Others' or uncategorized
    }
  }

// Helper function to convert calculated data into fl_chart format
  List<PieChartSectionData> _getPieChartSections(List<Map<String, dynamic>> categoryData) {
    if (categoryData.isEmpty) {
      // Return a single default section for a gray/empty look if there's no data
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '0%',
          radius: 100,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ];
    }
    
    return categoryData.map((data) {
      final color = data['color'] as Color;
      final value = data['amount'] as double;
      final title = '${data['percent']}%';
      
      return PieChartSectionData(
        color: color,
        value: value,
        title: title,
        radius: 100, // Size of the chart slices
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        // Only show percentage title if the slice is large enough to read
        showTitle: (data['percent'] as int) > 5, 
      );
    }).toList();
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
      List<Map<String, dynamic>>.from((summary['categories'] ?? const []) as List);
    final List<Map<String, dynamic>> chartData =
      List<Map<String, dynamic>>.from((summary['chartCategories'] ?? const []) as List);
    final DateTime start = summary['startOfWeek'] as DateTime; 
    final DateTime end = summary['endOfWeek'] as DateTime;
    
    // Format dates for display
    String dateFormatter(DateTime date) => 
      '${date.month}/${date.day}';
    
    // Prepare data for the Pie Chart (only positive categories)
    final pieChartSections = _getPieChartSections(chartData);
    final isDataEmpty = chartData.isEmpty;
    

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, // Hide the default AppBar area
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Title Section ---
              const Text(
                'Summary of Expenses',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(height: 16),

              // --- Week Range Display (NEW) ---
              Text(
                'Week: ${dateFormatter(start)} - ${dateFormatter(end)}',
                style: TextStyle(fontSize: 14, color: Colors.deepPurple.shade600, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // --- Total Expense Section ---
              const Text(
                'Total Expense for the week',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              // Shows the total weekly expenses
              Text(
                '₱${weeklyExpenses.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 30),

              // --- Pie Chart Implementation ---
              Center(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      centerSpaceRadius: 0, // No center space for the image design
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2, // Slight gap between sections
                    ),
                  ),
                ),
              ),
              
              // --- Category List (Legend) ---
              const SizedBox(height: 40),
              Card(
                elevation: 0,
                color: Colors.blueGrey.shade100, // Background color for the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: categoryData.map((data) => CategoryListItem(
                      color: data['color'] as Color,
                      category: data['name'] as String,
                      amount: data['amount'] as double,
                    )).toList(),
                  ),
                ),
              ),
              if (isDataEmpty) // Display a message if no data is present
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(
                      'No expenses recorded for this week.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget for the Category List Items
class CategoryListItem extends StatelessWidget {
  final Color color;
  final String category;
  final double amount;

  const CategoryListItem({
    super.key,
    required this.color,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Colored dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              // Category Name
              Text(
                category,
                style: TextStyle(
                  fontSize: 16, 
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.w500
                ),
              ),
            ],
          ),
          // Amount (Placeholder text style matching image)
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16, 
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}