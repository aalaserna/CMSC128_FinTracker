import 'package:flutter/material.dart';
import '../models/analytics_result.dart';
import 'health_score_ring.dart';
import 'insight_card.dart';

class AnalyticsBottomSheet extends StatelessWidget {
  final AnalyticsResult result;
  const AnalyticsBottomSheet({super.key, required this.result});

  static Future<void> show(BuildContext context, AnalyticsResult result) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnalyticsBottomSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxH = MediaQuery.of(context).size.height * 0.82;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F4EE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    result.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C2340),
                    ),
                  ),
                ),
                if (result.score != null) HealthScoreRing(score: result.score!),
              ],
            ),
          ),
          Text(
            'Generated just now · ${result.insights.length} insight${result.insights.length == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: result.insights.length,
              itemBuilder: (_, i) => InsightCard(insight: result.insights[i]),
            ),
          ),
        ],
      ),
    );
  }
}