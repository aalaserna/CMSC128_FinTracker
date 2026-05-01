import '../../pages/expense_model.dart';
import '../helpers/expense_aggregator.dart';
import '../helpers/insight_factory.dart';
import '../models/analytics_result.dart';
import '../models/financial_insight.dart';
import '../models/insight_type.dart';

class SavingsAnalyzer {
  final ExpenseAggregator _agg;

  SavingsAnalyzer({ExpenseAggregator? aggregator})
      : _agg = aggregator ?? ExpenseAggregator();

  AnalyticsResult generateSavingsSuggestions(List<Expense> allExpenses) {
    final now = DateTime.now();
    final thisMonth = _agg.forMonth(allExpenses, now.year, now.month);
    final lastMonth = _agg.previousMonth(allExpenses, now);

    final double thisTotal = _agg.total(thisMonth);
    final double lastTotal = _agg.total(lastMonth);
    final categories = _agg.totalsByCategory(thisMonth);
    final insights = <FinancialInsight>[];

    // Saved more than last month
    if (lastTotal > 0 && thisTotal < lastTotal) {
      final double saved = lastTotal - thisTotal;
      insights.add(FinancialInsight(
        title: 'You\'re Saving More!',
        message: 'You spent ₱${saved.toStringAsFixed(2)} less this month than last. '
            'If you keep this up, you\'ll save ₱${(saved * 12).toStringAsFixed(0)} a year.',
        type: InsightType.positive,
        severity: InsightSeverity.good,
        emoji: '🎉',
      ));
    }

    // Food spending tip
    final double foodSpend = categories['food'] ?? 0.0;
    if (foodSpend > 0 && thisTotal > 0) {
      final double foodPct = (foodSpend / thisTotal) * 100;
      if (foodPct > 40) {
        insights.add(FinancialInsight(
          title: 'Food Is Your Biggest Expense',
          message: 'Food accounts for ${foodPct.toStringAsFixed(1)}% of your spending. '
              'Cooking at home even 2 extra days a week could save up to '
              '₱${(foodSpend * 0.20).toStringAsFixed(0)} monthly.',
          type: InsightType.savingsTip,
          severity: InsightSeverity.warning,
          emoji: '🍱',
        ));
      }
    }

    // Transport tip
    final double transpoSpend = categories['transpo'] ?? 0.0;
    if (transpoSpend > 0) {
      insights.add(FinancialInsight(
        title: 'Transport Optimization',
        message: 'You spent ₱${transpoSpend.toStringAsFixed(2)} on transport. '
            'Carpooling or scheduling errands together can cut this by 20–30%.',
        type: InsightType.savingsTip,
        severity: InsightSeverity.neutral,
        emoji: '🚌',
      ));
    }

    // Weekend spending tip
    final weekendData = _agg.weekendVsWeekday(thisMonth);
    if (weekendData['weekendAvg']! > weekendData['weekdayAvg']! * 1.3) {
      insights.add(FinancialInsight(
        title: 'Set a Weekend Budget',
        message: 'You spend '
            '${((weekendData['weekendAvg']! / weekendData['weekdayAvg']! - 1) * 100).toStringAsFixed(0)}% '
            'more on weekends than weekdays. Setting a weekend cash limit can help significantly.',
        type: InsightType.savingsTip,
        severity: InsightSeverity.neutral,
        emoji: '📅',
      ));
    }

    // 50/30/20 rule suggestion
    if (thisTotal > 0) {
      final double suggestedSavings = thisTotal * 0.20;
      insights.add(FinancialInsight(
        title: 'The 50/30/20 Rule',
        message: 'Based on your ₱${thisTotal.toStringAsFixed(0)} monthly spend, '
            'try setting aside ₱${suggestedSavings.toStringAsFixed(0)} (20%) as savings. '
            'Small consistent amounts build up fast.',
        type: InsightType.savingsTip,
        severity: InsightSeverity.neutral,
        emoji: '💡',
      ));
    }

    // Recurring expense detection
    final recurring = _agg.detectRecurring(allExpenses);
    for (final r in recurring.take(2)) {
      insights.add(FinancialInsight(
        title: 'Recurring: ${r['name']}',
        message: '"${r['name']}" appears ${r['count']} times across your records '
            'totaling ₱${r['total'].toStringAsFixed(2)}. '
            'Review if this is still necessary.',
        type: InsightType.recurringExpense,
        severity: InsightSeverity.neutral,
        emoji: '🔄',
      ));
    }

    if (insights.isEmpty) insights.add(InsightFactory.keepRecording());

    return AnalyticsResult(
      label: 'Savings Suggestions',
      insights: insights,
      generatedAt: DateTime.now(),
    );
  }
}