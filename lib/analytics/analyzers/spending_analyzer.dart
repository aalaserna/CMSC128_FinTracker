import '../../pages/expense_model.dart';
import '../helpers/expense_aggregator.dart';
import '../helpers/category_utils.dart';
import '../helpers/insight_factory.dart';
import '../models/analytics_result.dart';
import '../models/financial_insight.dart';
import '../models/insight_type.dart';

class SpendingAnalyzer {
  final ExpenseAggregator _agg;

  SpendingAnalyzer({ExpenseAggregator? aggregator})
      : _agg = aggregator ?? ExpenseAggregator();

  AnalyticsResult analyzeMonthlySpending(List<Expense> allExpenses) {
    final now = DateTime.now();
    final thisMonth = _agg.forMonth(allExpenses, now.year, now.month);
    final lastMonth = _agg.previousMonth(allExpenses, now);

    final double thisTotal = _agg.total(thisMonth);
    final double lastTotal = _agg.total(lastMonth);
    final insights = <FinancialInsight>[];

    // Overall month-over-month
    if (lastTotal > 0) {
      final double pct = ((thisTotal - lastTotal) / lastTotal) * 100;
      final bool increased = pct > 0;
      insights.add(FinancialInsight(
        title: increased ? 'Spending Increased' : 'Spending Decreased',
        message: increased
            ? 'You spent ₱${thisTotal.toStringAsFixed(0)} this month — '
                '${pct.abs().toStringAsFixed(1)}% more than last month '
                '(₱${lastTotal.toStringAsFixed(0)}).'
            : 'You spent ₱${thisTotal.toStringAsFixed(0)} this month — '
                '${pct.abs().toStringAsFixed(1)}% less than last month. '
                'Great job keeping it down!',
        type: InsightType.trend,
        severity: increased
            ? (pct > 30 ? InsightSeverity.warning : InsightSeverity.neutral)
            : InsightSeverity.good,
        emoji: increased ? '📈' : '📉',
        metadata: {'thisTotal': thisTotal, 'lastTotal': lastTotal, 'pct': pct},
      ));
    } else if (thisTotal > 0) {
      insights.add(FinancialInsight(
        title: 'First Month Tracked',
        message: 'You spent ₱${thisTotal.toStringAsFixed(2)} this month. '
            'Keep recording to unlock month-over-month comparisons!',
        type: InsightType.trend,
        severity: InsightSeverity.neutral,
        emoji: '🗓️',
      ));
    }

    // Per-category month-over-month
    final thisCategories = _agg.totalsByCategory(thisMonth);
    final lastCategories = _agg.totalsByCategory(lastMonth);

    for (final entry in thisCategories.entries) {
      final cat = entry.key;
      final thisCat = entry.value;
      final lastCat = lastCategories[cat] ?? 0.0;

      if (lastCat > 0) {
        final double catPct = ((thisCat - lastCat) / lastCat) * 100;
        if (catPct.abs() >= 15) {
          insights.add(FinancialInsight(
            title:
                '${CategoryUtils.capitalize(cat)} Spending ${catPct > 0 ? 'Up' : 'Down'}',
            message:
                'Your ${cat.toLowerCase()} spending ${catPct > 0 ? 'increased' : 'decreased'} by '
                '${catPct.abs().toStringAsFixed(1)}% compared to last month '
                '(₱${lastCat.toStringAsFixed(0)} → ₱${thisCat.toStringAsFixed(0)}).',
            type: InsightType.trend,
            severity: catPct > 25
                ? InsightSeverity.warning
                : (catPct < -15 ? InsightSeverity.good : InsightSeverity.neutral),
            emoji: catPct > 0 ? '⬆️' : '⬇️',
          ));
        }
      }
    }

    // Biggest single transaction
    final top = _agg.topExpense(thisMonth);
    if (top != null) {
      insights.add(FinancialInsight(
        title: 'Biggest Transaction',
        message: '"${top.name}" was your single largest expense this month '
            'at ₱${top.amount.toStringAsFixed(2)} under '
            '${CategoryUtils.capitalize(top.category)}.',
        type: InsightType.categoryBreakdown,
        severity: InsightSeverity.neutral,
        emoji: '💳',
      ));
    }

    if (insights.isEmpty) insights.add(InsightFactory.noData());

    return AnalyticsResult(
      label: 'Spending Analysis',
      insights: insights,
      generatedAt: DateTime.now(),
    );
  }

  AnalyticsResult getMonthlyInsights(List<Expense> allExpenses) {
    final now = DateTime.now();
    final thisMonth = _agg.forMonth(allExpenses, now.year, now.month);
    final double total = _agg.total(thisMonth);
    final insights = <FinancialInsight>[];

    if (thisMonth.isEmpty) {
      return AnalyticsResult(
        label: 'Monthly Insights',
        insights: [InsightFactory.noData()],
        generatedAt: DateTime.now(),
      );
    }

    // Category breakdown percentages, sorted by amount
    final categories = _agg.totalsByCategory(thisMonth);
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      final double pct = (entry.value / total) * 100;
      insights.add(FinancialInsight(
        title:
            '${CategoryUtils.capitalize(entry.key)} — ${pct.toStringAsFixed(1)}%',
        message: '₱${entry.value.toStringAsFixed(2)} of your monthly spending '
            'went to ${entry.key.toLowerCase()}.',
        type: InsightType.categoryBreakdown,
        severity: pct > 50
            ? InsightSeverity.warning
            : (pct > 35 ? InsightSeverity.neutral : InsightSeverity.good),
        emoji: entry.key.toLowerCase(), // category key used by InsightCard for icon lookup
        metadata: {'pct': pct, 'amount': entry.value},
      ));
    }

    // Transaction count summary
    insights.add(FinancialInsight(
      title: 'Transaction Volume',
      message:
          'You made ${thisMonth.length} transaction${thisMonth.length == 1 ? '' : 's'} '
          'this month totaling ₱${total.toStringAsFixed(2)}.',
      type: InsightType.categoryBreakdown,
      severity: InsightSeverity.neutral,
      emoji: '🧾',
    ));

    return AnalyticsResult(
      label: 'Monthly Insights',
      insights: insights,
      generatedAt: DateTime.now(),
    );
  }
}