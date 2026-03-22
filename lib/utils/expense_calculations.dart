import '../pages/expense_model.dart';
import 'date_utils.dart';

double calculateWeeklySpent(List<Expense> expenses, List<DateTime> weekDates) {
  double total = 0.0;
  for (var expense in expenses) {
    if (weekDates.any((d) => isSameDay(d, expense.date))) {
      total += expense.amount;
    }
  }
  return total;
}

String getWeeklyTotal(List<Expense> expenses, List<DateTime> weekDates) {
  return '₱${calculateWeeklySpent(expenses, weekDates).toStringAsFixed(2)}';
}

String getDayTotal(List<Expense> expenses, DateTime date) {
  final dayExpenses = expenses.where((e) => isSameDay(e.date, date)).toList();
  final total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
  return '₱${total.toStringAsFixed(2)}';
}

String getBalanceLeft(List<Expense> expenses, List<DateTime> weekDates, double budget) {
  final balance = budget - calculateWeeklySpent(expenses, weekDates);
  return '₱${balance.toStringAsFixed(2)}';
}

String getSavings(List<Expense> expenses, List<DateTime> weekDates, double budget) {
  double savings = budget - calculateWeeklySpent(expenses, weekDates);
  if (savings < 0) savings = 0;
  return '₱${savings.toStringAsFixed(2)}';
}