import 'insight_type.dart';

class FinancialInsight {
  final String title;
  final String message;
  final InsightType type;
  final InsightSeverity severity;
  final String? emoji;
  final Map<String, dynamic>? metadata;

  const FinancialInsight({
    required this.title,
    required this.message,
    required this.type,
    required this.severity,
    this.emoji,
    this.metadata,
  });
}