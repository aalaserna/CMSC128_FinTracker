import 'package:flutter/material.dart';
import '../../../expense_model.dart';

class TransactionItem extends StatelessWidget {
  final Expense item;
  final VoidCallback onEdit;

  const TransactionItem({
    super.key,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (item.category) {
      case 'transpo':
        icon = Icons.directions_car_filled;
        iconColor = Colors.blue.shade700;
        break;
      case 'food':
        icon = Icons.fastfood;
        iconColor = Colors.red.shade700;
        break;
      case 'education':
        icon = Icons.school;
        iconColor = Colors.green.shade700;
        break;
      case 'wants':
        icon = Icons.shopping_bag;
        iconColor = Colors.purple.shade700;
        break;
      default:
        icon = Icons.attach_money;
        iconColor = Colors.black;
    }

    return Container(
      color: const Color(0xFFECF3FA),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit_square, color: Colors.grey[400], size: 24),
            onPressed: onEdit,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.category.toUpperCase(),
                  style: TextStyle(color: Colors.blueGrey[300], fontSize: 10),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '-₱${item.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}