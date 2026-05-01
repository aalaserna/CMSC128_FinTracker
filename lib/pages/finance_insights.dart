import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../analytics/financial_insight_service.dart';
import 'expense_model.dart';
import '../analytics/models/financial_insight.dart';
import '../analytics/models/analytics_result.dart';
import '../analytics/widgets/analytics_bottom_sheet.dart';
import '../analytics/widgets/analytics_action_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // state
  List<Expense> _allExpenses = [];
  bool _initialLoading = true;

  final Map<String, bool> _loadingStates = {
    'spending': false,
    'monthly':  false,
    'savings':  false,
    'health':   false,
    'trends':   false,
  };

  final _service = FinancialInsightService();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final db = DBHelper();
    final data = await db.getAllExpenses();
    if (mounted) {
      setState(() {
        _allExpenses = data;
        _initialLoading = false;
      });
    }
  }

  // analytcs
  Future<void> _runAnalysis(
    String key,
    AnalyticsResult Function(List<Expense>) compute,
  ) async {
    setState(() => _loadingStates[key] = true);

    await Future.delayed(const Duration(milliseconds: 350));

    final result = compute(_allExpenses);

    if (!mounted) return;
    setState(() => _loadingStates[key] = false);
    await AnalyticsBottomSheet.show(context, result);
  }

  Map<String, dynamic> _quickStats() {
    final now = DateTime.now();
    final thisMonth = _allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    final double total = thisMonth.fold(0.0, (s, e) => s + e.amount);
    final double score = _allExpenses.isEmpty
        ? 0
        : _service.calculateFinancialHealthScore(_allExpenses);
    final top = _service.getTopExpenseCategory(thisMonth);
    return {
      'total': total,
      'count': thisMonth.length,
      'score': score,
      'topCat': top?['category'] ?? '—',
    };
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4EE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _quickStats();
    final double score = stats['score'] as double;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4EE),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Financial Assistant',
          style: TextStyle(
            color: Color(0xFF1C2340),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C80A4)),
            tooltip: 'Refresh data',
            onPressed: _loadExpenses,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        color: const Color(0xFF1C2340),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header card with quick stats
              _HeaderCard(stats: stats, score: score),
              const SizedBox(height: 20),

              // section label
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Choose an Analysis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C80A4),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // action buttons
              AnalyticsActionButton(
                label: 'Analyze My Spending',
                icon: Icons.bar_chart_rounded,
                subtitle: 'Month-over-month comparison & top expenses',
                isLoading: _loadingStates['spending']!,
                accentColor: const Color(0xFF1E2A3A),
                onTap: () => _runAnalysis('spending', _service.analyzeMonthlySpending),
              ),
              AnalyticsActionButton(
                label: 'Monthly Insights',
                icon: Icons.calendar_month_rounded,
                subtitle: 'Category breakdown for this month',
                isLoading: _loadingStates['monthly']!,
                accentColor: const Color(0xFF3D5A80),
                onTap: () => _runAnalysis('monthly', _service.getMonthlyInsights),
              ),
              AnalyticsActionButton(
                label: 'Savings Suggestions',
                icon: Icons.lightbulb_outline_rounded,
                subtitle: 'Smart tips based on your habits',
                isLoading: _loadingStates['savings']!,
                accentColor: const Color(0xFF2E7D32),
                onTap: () => _runAnalysis('savings', _service.generateSavingsSuggestions),
              ),
              AnalyticsActionButton(
                label: 'Budget Health Check',
                icon: Icons.favorite_outline_rounded,
                subtitle: 'Overspend alerts & health score',
                isLoading: _loadingStates['health']!,
                accentColor: const Color(0xFF1B5E20),
                onTap: () => _runAnalysis('health', _service.detectBudgetRisk),
              ),
              AnalyticsActionButton(
                label: 'Spending Trends',
                icon: Icons.trending_up_rounded,
                subtitle: 'Weekly patterns & peak spending days',
                isLoading: _loadingStates['trends']!,
                accentColor: const Color(0xFF4A148C),
                onTap: () => _runAnalysis('trends', _service.analyzeSpendingTrends),
              ),
              const SizedBox(height: 20), 
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final double score;

  const _HeaderCard({required this.stats, required this.score});

  Color _scoreColor() {
    if (score >= 70) return const Color(0xFF4CAF50);
    if (score >= 45) return const Color(0xFFFF9800);
    return const Color.fromARGB(255, 255, 152, 150);
  }

  String _scoreLabel() {
    if (score >= 70) return 'Healthy';
    if (score >= 45) return 'Fair';
    return 'Needs Attention';
  }

  String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final double total = stats['total'] as double;
    final int count    = stats['count'] as int;
    final String topCat = stats['topCat'] as String;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month label + health badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthName(now.month)} ${now.year}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (score > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _scoreColor().withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: _scoreColor().withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_rounded,
                          color: _scoreColor(), size: 12),
                      const SizedBox(width: 5),
                      Text(
                        _scoreLabel(),
                        style: TextStyle(
                          color: _scoreColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Total spend
          Text(
            '₱${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Spent this month',
            style: TextStyle(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.receipt_long_rounded,
                label: '$count transactions',
              ),
              const SizedBox(width: 10),
              if (topCat != '—')
                _StatChip(
                  icon: Icons.trending_up_rounded,
                  label: 'Top: ${topCat[0].toUpperCase()}${topCat.substring(1)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}