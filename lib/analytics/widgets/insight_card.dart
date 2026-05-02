import 'package:flutter/material.dart';
import '../models/financial_insight.dart';
import '../models/insight_type.dart';
import '../helpers/category_utils.dart';

class InsightCard extends StatelessWidget {
  final FinancialInsight insight;
  const InsightCard({super.key, required this.insight});

  Color _severityColor() {
    switch (insight.severity) {
      case InsightSeverity.good:     return const Color(0xFF2E7D32);
      case InsightSeverity.neutral:  return const Color(0xFF3D5A80);
      case InsightSeverity.warning:  return const Color(0xFFE65100);
      case InsightSeverity.critical: return const Color(0xFFC62828);
    }
  }

  Color _severityBg() {
    switch (insight.severity) {
      case InsightSeverity.good:     return const Color(0xFFE8F5E9);
      case InsightSeverity.neutral:  return const Color(0xFFEEF2FB);
      case InsightSeverity.warning:  return const Color(0xFFFFF3E0);
      case InsightSeverity.critical: return const Color(0xFFFFEBEE);
    }
  }

  IconData _resolveIcon() {
    if (insight.type == InsightType.categoryBreakdown && insight.emoji != null) {
      return CategoryUtils.iconForCategory(insight.emoji!);
    }
    return CategoryUtils.iconForInsightType(insight.type.name);
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor();
    final bg    = _severityBg();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity stripe
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          // Icon badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _resolveIcon(),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C2340),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}