import '../../pages/expense_model.dart';
import '../helpers/expense_aggregator.dart';
import '../helpers/category_utils.dart';
import '../helpers/insight_factory.dart';
import '../models/analytics_result.dart';
import '../models/financial_insight.dart';
import '../models/insight_type.dart';
import '../scoring/health_scorer.dart';

class TrendsAnalyzer {
  final ExpenseAggregator _agg;
  final HealthScorer _scorer;

  TrendsAnalyzer({ExpenseAggregator? aggregator, HealthScorer? scorer})
      : _agg = aggregator ?? ExpenseAggregator(),
        _scorer = scorer ?? HealthScorer();

  AnalyticsResult analyzeSpendingTrends(List<Expense> allExpenses) {
    final now = DateTime.now();
    final thisMonth = _agg.forMonth(allExpenses, now.year, now.month);
    final insights = <FinancialInsight>[];

    // Peak spending day of week
    final dayTotals = _agg.totalsByDayOfWeek(thisMonth);
    if (dayTotals.isNotEmpty) {
      final topDay    = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final bottomDay = dayTotals.entries.reduce((a, b) => a.value < b.value ? a : b);
      insights.add(FinancialInsight(
        title: 'Peak Spending Day',
        message: '${CategoryUtils.dayName(topDay.key)} is your biggest spending day '
            '(₱${topDay.value.toStringAsFixed(2)} this month). '
            '${CategoryUtils.dayName(bottomDay.key)} is your most frugal day.',
        type: InsightType.weekendPattern,
        severity: InsightSeverity.neutral,
        emoji: '📆',
      ));
    }

    // Weekend vs weekday average
    final wData = _agg.weekendVsWeekday(thisMonth);
    final double wkEnd = wData['weekendAvg']!;
    final double wkDay = wData['weekdayAvg']!;
    if (wkEnd > 0 || wkDay > 0) {
      final bool weekendHigher = wkEnd > wkDay;
      insights.add(FinancialInsight(
        title: weekendHigher ? 'Weekend Spender' : 'Weekday Spender',
        message: weekendHigher
            ? 'You spend an average of ₱${wkEnd.toStringAsFixed(0)}/day on weekends '
              'vs ₱${wkDay.toStringAsFixed(0)}/day on weekdays.'
            : 'Interestingly, your weekday average (₱${wkDay.toStringAsFixed(0)}/day) '
              'exceeds your weekend average (₱${wkEnd.toStringAsFixed(0)}/day).',
        type: InsightType.weekendPattern,
        severity: (wkEnd > wkDay * 1.5) ? InsightSeverity.warning : InsightSeverity.neutral,
        emoji: weekendHigher ? '🌅' : '💼',
      ));
    }

    // Weekly breakdown within the current month
    final weeklyData = _agg.weeklyBreakdown(thisMonth, now);
    for (int i = 0; i < weeklyData.length; i++) {
      final w = weeklyData[i];
      insights.add(FinancialInsight(
        title: 'Week ${i + 1}',
        message: 'Week ${i + 1} total: ₱${w['total'].toStringAsFixed(2)} '
            'across ${w['count']} transaction${w['count'] == 1 ? '' : 's'}.',
        type: InsightType.trend,
        severity: InsightSeverity.neutral,
        emoji: '📊',
        metadata: w,
      ));
    }

    // Top category for the month
    final topCat = _agg.topCategory(thisMonth);
    if (topCat != null) {
      insights.add(FinancialInsight(
        title: 'Top Category This Month',
        message: '${CategoryUtils.capitalize(topCat['category'] as String)} dominates '
            'your spending at ₱${(topCat['amount'] as double).toStringAsFixed(2)}.',
        type: InsightType.categoryBreakdown,
        severity: InsightSeverity.neutral,
        emoji: (topCat['category'] as String).toLowerCase(), // category key for icon lookup
      ));
    }

    if (insights.isEmpty) insights.add(InsightFactory.noData());

    return AnalyticsResult(
      label: 'Spending Trends',
      insights: insights,
      generatedAt: DateTime.now(),
    );
  }

  AnalyticsResult detectBudgetRisk(List<Expense> allExpenses) {
    final now = DateTime.now();
    final thisMonth = _agg.forMonth(allExpenses, now.year, now.month);
    final lastMonth = _agg.previousMonth(allExpenses, now);

    final double thisTotal = _agg.total(thisMonth);
    final double lastTotal = _agg.total(lastMonth);
    final double score = _scorer.calculate(allExpenses);
    final insights = <FinancialInsight>[];

    // Health score summary card
    insights.add(FinancialInsight(
      title: 'Financial Health Score: ${score.toStringAsFixed(0)}/100',
      message: CategoryUtils.healthScoreMessage(score),
      type: InsightType.healthScore,
      severity: score >= 70
          ? InsightSeverity.good
          : (score >= 45 ? InsightSeverity.neutral : InsightSeverity.warning),
      emoji: score >= 70 ? '💚' : (score >= 45 ? '💛' : '🔴'),
      metadata: {'score': score},
    ));

    // Projected overspend alert
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int daysPassed  = now.day;
    if (daysPassed > 5 && lastTotal > 0) {
      final double projected = (thisTotal / daysPassed) * daysInMonth;
      if (projected > lastTotal * 1.15) {
        insights.add(FinancialInsight(
          title: 'Projected Overspend Alert',
          message: 'At your current pace, you\'re on track to spend '
              '₱${projected.toStringAsFixed(0)} this month — '
              '${((projected / lastTotal - 1) * 100).toStringAsFixed(0)}% more than last month.',
          type: InsightType.spendingAlert,
          severity: InsightSeverity.warning,
          emoji: '⚠️',
        ));
      }
    }

    // Per-category overspend alerts
    final thisCategories = _agg.totalsByCategory(thisMonth);
    final lastCategories = _agg.totalsByCategory(lastMonth);

    for (final entry in thisCategories.entries) {
      final lastCatTotal = lastCategories[entry.key] ?? 0.0;
      if (lastCatTotal > 0) {
        final double ratio = entry.value / lastCatTotal;
        if (ratio >= 1.0) {
          insights.add(FinancialInsight(
            title: '${CategoryUtils.capitalize(entry.key)} Over Budget',
            message: 'You\'ve already matched or exceeded last month\'s '
                '${entry.key.toLowerCase()} spending '
                '(₱${entry.value.toStringAsFixed(0)} vs ₱${lastCatTotal.toStringAsFixed(0)}).',
            type: InsightType.spendingAlert,
            severity: InsightSeverity.critical,
            emoji: '🚨',
          ));
        } else if (ratio >= 0.80) {
          insights.add(FinancialInsight(
            title: '${CategoryUtils.capitalize(entry.key)} Nearing Limit',
            message: 'You\'re at ${(ratio * 100).toStringAsFixed(0)}% of last month\'s '
                '${entry.key.toLowerCase()} spend. '
                '₱${(lastCatTotal - entry.value).toStringAsFixed(0)} remaining.',
            type: InsightType.spendingAlert,
            severity: InsightSeverity.warning,
            emoji: '⚠️',
          ));
        }
      }
    }

    if (insights.length == 1) insights.add(InsightFactory.lookingGood());

    return AnalyticsResult(
      label: 'Budget Health Check',
      insights: insights,
      score: score,
      generatedAt: DateTime.now(),
    );
  }
}