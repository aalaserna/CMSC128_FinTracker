import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/db_helper.dart';
import 'edit_page.dart';
import 'expense_model.dart';
import 'monthly_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static double userBudget = 0.0;
  static final List<Expense> expenses = [];
  static final GlobalKey<_HomePageState> homePageStateKey =
      GlobalKey<_HomePageState>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final Color kBlueLight = const Color(0xFFDCE8F5);
  final Color kSelectedBlue = const Color(0xFF5E6C85);

  late List<DateTime> weekDates;
  late String currentMonthName;
  late TabController _tabController;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    loadExpenses();

    final now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    weekDates = _getWeekDates(_currentWeekStart);
    _loadBudget();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    currentMonthName = months[now.month - 1];

    final int todayIndex = now.weekday - 1;
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

  Future<void> loadExpenses() async {
    final data = await DBHelper().getAllExpenses();
    setState(() {
      HomePage.expenses
        ..clear()
        ..addAll(data);
    });
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('budgetAmount');
    if (saved != null) {
      setState(() {
        HomePage.userBudget = saved;
      });
    }
  }

  DateTime getSelectedDate() {
    return weekDates[_tabController.index];
  }

  List<DateTime> _getWeekDates(DateTime startOfWeek) {
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _deleteExpenseWithUndo(Expense item, int index) {
    setState(() {
      HomePage.expenses.removeAt(index);
    });

    final messenger = ScaffoldMessenger.of(context);
    bool undone = false;

    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            duration: const Duration(seconds: 5),
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(185, 28, 35, 64),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Deleted "${item.name}"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      undone = true;
                      messenger.hideCurrentSnackBar();
                      setState(() {
                        HomePage.expenses.insert(index, item);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Undo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .closed
        .then((_) async {
          if (!undone) {
            final id = item.id;
            if (id != null) {
              await DBHelper().deleteExpense(id);
            }
          }
        });
  }

  void _editExpense(
    int index,
    String name,
    double amount,
    String category,
    DateTime date,
    String details,
  ) async {
    final old = HomePage.expenses[index];

    final updatedExpense = Expense(
      id: old.id,
      name: name,
      amount: amount,
      category: category,
      date: date,
      details: details,
    );

    if (updatedExpense.id != null) {
      await DBHelper().updateExpense(updatedExpense);
    }

    setState(() {
      HomePage.expenses[index] = updatedExpense;
    });
  }

  void _openEditExpenseDialog(int index) async {
    final expense = HomePage.expenses[index];

    final updated = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (_) => EditExpensePage(expense: expense),
      ),
    );

    if (updated != null) {
      _editExpense(
        index,
        updated.name,
        updated.amount,
        updated.category,
        updated.date,
        updated.details,
      );
    }
  }

  String _getDayTotal(DateTime date) {
    final dayExpenses = HomePage.expenses.where((e) => _isSameDay(e.date, date)).toList();
    final double total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return '₱${total.toStringAsFixed(2)}';
  }

  double _calculateWeeklySpent() {
    double total = 0.0;
    for (final expense in HomePage.expenses) {
      final bool isInWeek = weekDates.any((d) => _isSameDay(d, expense.date));
      if (isInWeek) {
        total += expense.amount;
      }
    }
    return total;
  }

  String _getBalanceLeft() {
    final double spent = _calculateWeeklySpent();
    final double balance = HomePage.userBudget - spent;
    return '₱${balance.toStringAsFixed(2)}';
  }

  String _getSavings() {
    final double spent = _calculateWeeklySpent();
    double savings = HomePage.userBudget - spent;
    if (savings < 0) savings = 0;
    return '₱${savings.toStringAsFixed(2)}';
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
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MonthlyViewPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () {
                    setState(() {
                      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
                      weekDates = _getWeekDates(_currentWeekStart);
                      _tabController.animateTo(0);
                    });
                  },
                ),
                Expanded(
                  child: Row(
                    children: weekDates.asMap().entries.map((entry) {
                      final index = entry.key;
                      final date = entry.value;
                      final dayName = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ][date.weekday - 1];

                      final bool isSelected = _tabController.index == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(index);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kSelectedBlue
                                  : const Color(0xFFE0E0E0).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () {
                    setState(() {
                      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
                      weekDates = _getWeekDates(_currentWeekStart);
                      _tabController.animateTo(0);
                    });
                  },
                ),
              ],
            ),
          ),
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

  Widget _buildDayPage(DateTime date) {
    final dayExpenses = HomePage.expenses.where((e) => _isSameDay(e.date, date)).toList();

    final dayName = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ][date.weekday - 1];
    final dateString = '$dayName, ${date.day}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard(
                'Weekly Expenses',
                '₱${_calculateWeeklySpent().toStringAsFixed(2)}',
              ),
              const SizedBox(width: 8),
              _buildSummaryCard('Balance Left', _getBalanceLeft()),
              const SizedBox(width: 8),
              _buildSummaryCard('Savings', _getSavings()),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            'Daily Expense ($dateString): ${_getDayTotal(date)}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: dayExpenses.isEmpty
              ? Center(
                  child: Text(
                    'No expenses for ${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1]}.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: dayExpenses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = dayExpenses[index];
                    final realIndex = HomePage.expenses.indexOf(item);

                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      onDismissed: (_) => _deleteExpenseWithUndo(item, realIndex),
                      child: _buildTransactionItem(item, realIndex),
                    );
                  },
                ),
        ),
      ],
    );
  }

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
            Text(
              title,
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
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Expense item, int realIndex) {
    IconData icon;
    Color iconColor;
    switch (item.category) {
      case 'transpo':
        icon = Icons.directions_car_filled;
        iconColor = const Color(0xFF4D78E6);
        break;
      case 'food':
        icon = Icons.fastfood;
        iconColor = const Color.fromARGB(255, 190, 173, 124);
        break;
      case 'school':
        icon = Icons.school;
        iconColor = const Color(0xFFFF7A45);
        break;
      case 'groceries':
        icon = Icons.local_grocery_store;
        iconColor = const Color(0xFF8AD99A);
        break;
      case 'bill':
        icon = Icons.receipt;
        iconColor = const Color.fromARGB(255, 117, 197, 213);
        break;
        case 'custom':
        icon = Icons.account_balance_wallet;
        iconColor = const Color.fromARGB(255, 145, 104, 189);
      default:
        icon = Icons.attach_money;
        iconColor = const Color.fromARGB(255, 75, 93, 129);
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
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
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
            '-₱${item.amount.toStringAsFixed(2)}',
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
}
