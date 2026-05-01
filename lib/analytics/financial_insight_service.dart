import '../pages/expense_model.dart';
import 'analyzers/spending_analyzer.dart';
import 'analyzers/savings_analyzer.dart';
import 'analyzers/trends_analyzer.dart';
import 'helpers/expense_aggregator.dart';
import 'models/analytics_result.dart';
import 'scoring/health_scorer.dart';

// structure--- All logic lives in the analyzer/helper/scoring layers.
class FinancialInsightService {
  late final ExpenseAggregator _agg;
  late final HealthScorer _scorer;
  late final SpendingAnalyzer _spending;
  late final SavingsAnalyzer _savings;
  late final TrendsAnalyzer _trends;

  FinancialInsightService() {
    _agg     = ExpenseAggregator();
    _scorer  = HealthScorer(aggregator: _agg);
    _spending = SpendingAnalyzer(aggregator: _agg);
    _savings  = SavingsAnalyzer(aggregator: _agg);
    _trends   = TrendsAnalyzer(aggregator: _agg, scorer: _scorer);
  }

  AnalyticsResult analyzeMonthlySpending(List<Expense> e) =>
      _spending.analyzeMonthlySpending(e);

  AnalyticsResult getMonthlyInsights(List<Expense> e) =>
      _spending.getMonthlyInsights(e);

  AnalyticsResult generateSavingsSuggestions(List<Expense> e) =>
      _savings.generateSavingsSuggestions(e);

  AnalyticsResult detectBudgetRisk(List<Expense> e) =>
      _trends.detectBudgetRisk(e);

  AnalyticsResult analyzeSpendingTrends(List<Expense> e) =>
      _trends.analyzeSpendingTrends(e);

  double calculateFinancialHealthScore(List<Expense> e) =>
      _scorer.calculate(e);

  Map<String, dynamic>? getTopExpenseCategory(List<Expense> e) =>
      _agg.topCategory(e);
}