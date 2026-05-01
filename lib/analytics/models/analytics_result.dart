import 'financial_insight.dart';

class AnalyticsResult {
  final String label;
  final List<FinancialInsight> insights;
  final double? score;
  final DateTime generatedAt;

  const AnalyticsResult({
    required this.label,
    required this.insights,
    this.score,
    required this.generatedAt,
  });

  bool get isEmpty => insights.isEmpty;
}