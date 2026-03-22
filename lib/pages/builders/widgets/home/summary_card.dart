import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFDCE8F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}