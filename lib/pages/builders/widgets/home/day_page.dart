import 'package:flutter/material.dart';
import '../../../expense_model.dart';
import '../../../../utils/date_utils.dart';
import '../../../../utils/expense_calculations.dart';
import '../../../summary.dart';
import 'summary_card.dart';
import 'transaction_item.dart';

class DayPage extends StatelessWidget {
  final DateTime date;
  final List<Expense> allExpenses;
  final List<DateTime> weekDates;
  final double userBudget;
  final void Function(int realIndex) onEdit;
  final void Function(Expense item, int realIndex) onDelete;
  final VoidCallback onSummaryTap;

  const DayPage({
    super.key,
    required this.date,
    required this.allExpenses,
    required this.weekDates,
    required this.userBudget,
    required this.onEdit,
    required this.onDelete,
    required this.onSummaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayExpenses = allExpenses
        .where((e) => isSameDay(e.date, date))
        .toList();

    final dayName = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ][date.weekday - 1];
    final dateString = '$dayName, ${date.day}';

    return Column(
      children: [
        // Summary cards row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Spent This Week',
                  amount: '₱${calculateWeeklySpent(allExpenses, weekDates).toStringAsFixed(2)}',
                )),
              const SizedBox(width: 8),
              // Balance Left Button
              Expanded(
                child: GestureDetector(
                  onTap: onSummaryTap,
                  child: SummaryCard(
                    title: 'Left to Spend',
                    amount: getBalanceLeft(allExpenses, weekDates, userBudget),
                  ),
                )
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryCard(
                  title: 'Savings',
                  amount: getSavings(allExpenses, weekDates, userBudget),
                )),
            ],
          ),
        ),

        // Daily total pill
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            'Today\'s Total ($dateString): ${getDayTotal(allExpenses, date)}',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Expense list
        Expanded(
          child: dayExpenses.isEmpty
              ? Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    'You have no expenses for $dayName.\nTap the + button to log an expense.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: dayExpenses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = dayExpenses[index];
                    final realIndex = allExpenses.indexOf(item);

                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                      onDismissed: (_) => onDelete(item, realIndex),
                      child: TransactionItem(
                        item: item,
                        onEdit: () => onEdit(realIndex),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}