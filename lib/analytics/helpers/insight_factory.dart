import '../models/financial_insight.dart';
import '../models/insight_type.dart';

// builder for common insights to avoid repetition across analyzers
class InsightFactory {
  static FinancialInsight noData() => const FinancialInsight(
        title: 'Not Enough Data',
        message: 'Record more transactions to unlock detailed insights. '
            'Aim for at least a week of data!',
        type: InsightType.positive,
        severity: InsightSeverity.neutral,
        emoji: '📝',
      );

  static FinancialInsight keepRecording() => const FinancialInsight(
        title: 'Keep Recording!',
        message: 'Add more transactions to get personalized savings suggestions.',
        type: InsightType.positive,
        severity: InsightSeverity.neutral,
        emoji: '📝',
      );

  static FinancialInsight lookingGood() => const FinancialInsight(
        title: 'Looking Good!',
        message: 'No major spending risks detected this month. Keep it up!',
        type: InsightType.positive,
        severity: InsightSeverity.good,
        emoji: '✅',
      );
}