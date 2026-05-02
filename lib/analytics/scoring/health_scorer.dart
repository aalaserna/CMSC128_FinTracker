import '../../pages/expense_model.dart';
import '../helpers/expense_aggregator.dart';

// Computes the 0–100 financial health score.
// can be changed pa
class HealthScorer {
  final ExpenseAggregator _agg;

  HealthScorer({ExpenseAggregator? aggregator})
      : _agg = aggregator ?? ExpenseAggregator();

  double calculate(List<Expense> allExpenses) {
    final now = DateTime.now();
    final thisMonth = _agg.forMonth(allExpenses, now.year, now.month);
    final lastMonth = _agg.previousMonth(allExpenses, now);

    double score = 60.0;

    final double thisTotal = _agg.total(thisMonth);
    final double lastTotal = _agg.total(lastMonth);

    // +15 if spending decreased month-over-month
    if (lastTotal > 0 && thisTotal < lastTotal) score += 15;
    // −15 if spending increased by more than 25%
    if (lastTotal > 0 && thisTotal > lastTotal * 1.25) score -= 15;
    // +5 if low transaction frequency (disciplined)
    if (thisMonth.length < 20) score += 5;
    // −10 if any single category > 60% of total spend
    if (thisTotal > 0) {
      final cats = _agg.totalsByCategory(thisMonth);
      for (final v in cats.values) {
        if (v / thisTotal > 0.60) {
          score -= 10;
          break;
        }
      }
    }
    // +10 if weekend spending ≤ weekday (disciplined weekends)
    final wData = _agg.weekendVsWeekday(thisMonth);
    if ((wData['weekendAvg'] ?? 0) <= (wData['weekdayAvg'] ?? 0)) score += 10;
    // −5 for each category consistently trending up >20%
    final thisCategories = _agg.totalsByCategory(thisMonth);
    final lastCategories = _agg.totalsByCategory(lastMonth);
    int risingCats = 0;
    for (final entry in thisCategories.entries) {
      if ((lastCategories[entry.key] ?? 0) > 0 &&
          entry.value > (lastCategories[entry.key]! * 1.20)) {
        risingCats++;
      }
    }
    score -= risingCats * 5;

    return score.clamp(0.0, 100.0);
  }
}