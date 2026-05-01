import '../../pages/expense_model.dart';

// helpers
class ExpenseAggregator {
  List<Expense> forMonth(List<Expense> expenses, int year, int month) {
    return expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  List<Expense> previousMonth(List<Expense> expenses, DateTime now) {
    final year  = now.month == 1 ? now.year - 1 : now.year;
    final month = now.month == 1 ? 12 : now.month - 1;
    return forMonth(expenses, year, month);
  }

  double total(List<Expense> expenses) =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> totalsByCategory(List<Expense> expenses) {
    final result = <String, double>{};
    for (final e in expenses) {
      result.update(
        e.category.toLowerCase(),
        (v) => v + e.amount,
        ifAbsent: () => e.amount,
      );
    }
    return result;
  }

  Map<int, double> totalsByDayOfWeek(List<Expense> expenses) {
    final byDay = <int, double>{};
    for (final e in expenses) {
      byDay.update(e.date.weekday, (v) => v + e.amount,
          ifAbsent: () => e.amount);
    }
    return byDay;
  }

  Map<String, double> weekendVsWeekday(List<Expense> expenses) {
    final weekday = expenses.where((e) => e.date.weekday <= 5).toList();
    final weekend = expenses.where((e) => e.date.weekday > 5).toList();

    final weekdayDays = weekday
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .length;
    final weekendDays = weekend
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .length;

    return {
      'weekdayAvg': weekdayDays > 0 ? total(weekday) / weekdayDays : 0.0,
      'weekendAvg': weekendDays > 0 ? total(weekend) / weekendDays : 0.0,
    };
  }

  List<Map<String, dynamic>> weeklyBreakdown(
      List<Expense> expenses, DateTime now) {
    final int firstDay = DateTime(now.year, now.month, 1).weekday;
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final weeks = <Map<String, dynamic>>[];

    int startDay = 1;
    while (startDay <= daysInMonth) {
      final int endDay =
          (startDay + (8 - (firstDay % 7 == 0 ? 7 : firstDay % 7)) - 1)
              .clamp(startDay, daysInMonth);

      final weekExpenses =
          expenses.where((e) => e.date.day >= startDay && e.date.day <= endDay).toList();

      weeks.add({
        'startDay': startDay,
        'endDay': endDay,
        'total': total(weekExpenses),
        'count': weekExpenses.length,
      });
      startDay = endDay + 1;
    }
    return weeks;
  }

  List<Map<String, dynamic>> detectRecurring(List<Expense> expenses) {
    final grouped = <String, List<Expense>>{};
    for (final e in expenses) {
      grouped.putIfAbsent(e.name.toLowerCase().trim(), () => []).add(e);
    }
    return grouped.entries
        .where((entry) => entry.value.length >= 2)
        .map((entry) => {
              'name': _capitalize(entry.key),
              'count': entry.value.length,
              'total': total(entry.value),
            })
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  Expense? topExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  Map<String, dynamic>? topCategory(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    final cats = totalsByCategory(expenses);
    if (cats.isEmpty) return null;
    final top = cats.entries.reduce((a, b) => a.value > b.value ? a : b);
    return {'category': top.key, 'amount': top.value};
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}