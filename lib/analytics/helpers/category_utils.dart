import 'package:flutter/material.dart';

class CategoryUtils {
  static String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  static String dayName(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  static String healthScoreMessage(double score) {
    if (score >= 80) {
      return 'Excellent! Your finances are in great shape. Keep building on these habits.';
    }
    if (score >= 65) {
      return 'Good standing. A few areas to watch, but you\'re managing well overall.';
    }
    if (score >= 45) {
      return 'Fair health. Some spending patterns need attention — check the alerts below.';
    }
    return 'Needs attention. Your spending is trending in a risky direction. Review your top categories.';
  }

  // icon per category for insights  
  static IconData iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':       return Icons.restaurant_rounded;
      case 'groceries':  return Icons.shopping_cart_rounded;
      case 'transpo':    return Icons.directions_bus_rounded;
      case 'school':     return Icons.menu_book_rounded;
      case 'bill':       return Icons.receipt_long_rounded;
      case 'custom':     return Icons.shopping_bag_rounded;
      case 'health':     return Icons.local_hospital_rounded;
      case 'clothing':   return Icons.checkroom_rounded;
      case 'travel':     return Icons.flight_rounded;
      case 'coffee':     return Icons.coffee_rounded;
      case 'rent':       return Icons.home_rounded;
      case 'utilities':  return Icons.bolt_rounded;
      case 'savings':    return Icons.savings_rounded;
      default:           return Icons.attach_money_rounded;
    }
  }

  // fallback icons
  static IconData iconForInsightType(String insightTypeKey) {
    switch (insightTypeKey) {
      case 'spendingAlert':     return Icons.warning_amber_rounded;
      case 'trend':             return Icons.show_chart_rounded;
      case 'categoryBreakdown': return Icons.pie_chart_outline_rounded;
      case 'savingsTip':        return Icons.lightbulb_outline_rounded;
      case 'weekendPattern':    return Icons.weekend_rounded;
      case 'healthScore':       return Icons.favorite_outline_rounded;
      case 'recurringExpense':  return Icons.repeat_rounded;
      case 'positive':          return Icons.check_circle_outline_rounded;
      default:                  return Icons.info_outline_rounded;
    }
  }
}