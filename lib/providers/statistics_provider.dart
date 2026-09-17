import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import 'transaction_provider.dart';

class CategoryTotal {
  const CategoryTotal(
      {required this.category, required this.amount, required this.ratio});
  final Category category;
  final int amount;
  final double ratio;
}

class MonthlyStatistics {
  const MonthlyStatistics(
      {required this.income, required this.expense, required this.byCategory});
  final int income;
  final int expense;
  final List<CategoryTotal> byCategory;
  int get balance => income - expense;
  double get spendingRatio => income == 0 ? 0 : (expense / income).clamp(0, 1);
}

final monthlyStatisticsProvider = Provider<MonthlyStatistics>((ref) {
  final transactions =
      ref.watch(transactionProvider).valueOrNull ?? const <AppTransaction>[];
  final categories =
      ref.watch(categoryProvider).valueOrNull ?? const <Category>[];
  return calculateMonthlyStatistics(transactions, categories);
});

MonthlyStatistics calculateMonthlyStatistics(
  List<AppTransaction> transactions,
  List<Category> categories, {
  DateTime? now,
}) {
  final currentDate = now ?? DateTime.now();
  final currentMonth = transactions.where((item) {
    return item.date.year == currentDate.year &&
        item.date.month == currentDate.month;
  }).toList();
  final income = currentMonth
      .where((item) => item.type == TransactionType.income)
      .fold<int>(0, (sum, item) => sum + item.amount);
  final expense = currentMonth
      .where((item) => item.type == TransactionType.expense)
      .fold<int>(0, (sum, item) => sum + item.amount);
  final categoryMap = {
    for (final category in categories) category.id: category
  };
  final totals = <String, int>{};
  for (final item
      in currentMonth.where((item) => item.type == TransactionType.expense)) {
    totals[item.categoryId] = (totals[item.categoryId] ?? 0) + item.amount;
  }
  final byCategory = totals.entries.map((entry) {
    final category = categoryMap[entry.key] ??
        Category(
            id: entry.key,
            name: '其他',
            icon: '📦',
            type: TransactionType.expense);
    return CategoryTotal(
        category: category,
        amount: entry.value,
        ratio: expense == 0 ? 0 : entry.value / expense);
  }).toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));
  return MonthlyStatistics(
      income: income, expense: expense, byCategory: byCategory);
}
