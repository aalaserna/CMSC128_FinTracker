import 'package:flutter/material.dart';
import 'expense_model.dart';
import '../database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'monthly_view.dart';
import 'expenses/edit/edit_expense_page.dart';
import '../utils/date_utils.dart';
import 'builders/widgets/home/day_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static double userBudget = 0.0;
  static final List<Expense> expenses = [];
  static final GlobalKey<_HomePageState> homePageStateKey =
      GlobalKey<_HomePageState>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Color kSelectedBlue = const Color(0xFF5E6C85);

  late List<DateTime> weekDates;
  late String currentMonthName;
  late TabController _tabController;
  late DateTime _currentWeekStart;

  Future<void> loadExpenses() async {
    final data = await DBHelper().getAllExpenses();
    setState(() {
      HomePage.expenses.clear();
      HomePage.expenses.addAll(data);
    });
  }

  DateTime getSelectedDate() => weekDates[_tabController.index];

  @override
  void initState() {
    loadExpenses();
    super.initState();
    final now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    weekDates = getWeekDates(_currentWeekStart);
    _loadBudget();

    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    currentMonthName = months[now.month - 1];

    _tabController = TabController(
      length: weekDates.length,
      vsync: this,
      initialIndex: now.weekday - 1,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble('budgetAmount');
    if (saved != null) setState(() => HomePage.userBudget = saved);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteExpenseWithUndo(Expense item, int index) {
    setState(() => HomePage.expenses.removeAt(index));

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
                  const Icon(Icons.delete_outline_rounded,
                      color: Colors.white70, size: 20),
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
                      setState(() => HomePage.expenses.insert(index, item));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
          if (!undone && item.id != null) {
            await DBHelper().deleteExpense(item.id!);
          }
        });
  }

  void _editExpense(int index, String name, double amount, String category,
      DateTime date, String details) async {
    final old = HomePage.expenses[index];
    final updated = Expense(
      id: old.id,
      name: name,
      amount: amount,
      category: category,
      date: date,
      details: details,
    );
    if (updated.id != null) await DBHelper().updateExpense(updated);
    setState(() => HomePage.expenses[index] = updated);
  }

  void _openEditExpenseDialog(int index) async {
    final expense = HomePage.expenses[index];
    final updated = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (_) => EditExpensePage(expense: expense)),
    );
    if (updated != null) {
      _editExpense(index, updated.name, updated.amount, updated.category,
          updated.date, updated.details);
    }
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
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.black),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlyViewPage()),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => setState(() {
                    _currentWeekStart =
                        _currentWeekStart.subtract(const Duration(days: 7));
                    weekDates = getWeekDates(_currentWeekStart);
                    _tabController.animateTo(0);
                  }),
                ),
                Expanded(
                  child: Row(
                    children: weekDates.asMap().entries.map((entry) {
                      final index = entry.key;
                      final date = entry.value;
                      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                          [date.weekday - 1];
                      final isSelected = _tabController.index == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(index),
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
                                Text(dayName,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
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
                  onPressed: () => setState(() {
                    _currentWeekStart =
                        _currentWeekStart.add(const Duration(days: 7));
                    weekDates = getWeekDates(_currentWeekStart);
                    _tabController.animateTo(0);
                  }),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: weekDates.map((date) => DayPage(
                date: date,
                allExpenses: HomePage.expenses,
                weekDates: weekDates,
                userBudget: HomePage.userBudget,
                onEdit: _openEditExpenseDialog,
                onDelete: _deleteExpenseWithUndo,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}