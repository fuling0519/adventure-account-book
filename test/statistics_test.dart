import 'package:adventurer_pouch/models/category.dart';
import 'package:adventurer_pouch/models/transaction.dart';
import 'package:adventurer_pouch/providers/statistics_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates only the selected month and clamps spending ratio', () {
    final categories = [
      const Category(
          id: 'food', name: '飲食', icon: '🍜', type: TransactionType.expense),
      const Category(
          id: 'salary', name: '薪資', icon: '💰', type: TransactionType.income),
    ];
    final transactions = [
      _transaction(
          TransactionType.income, 1000, 'salary', DateTime(2026, 9, 1)),
      _transaction(TransactionType.expense, 1200, 'food', DateTime(2026, 9, 2)),
      _transaction(
          TransactionType.income, 9999, 'salary', DateTime(2026, 8, 31)),
    ];

    final stats = calculateMonthlyStatistics(transactions, categories,
        now: DateTime(2026, 9, 17));

    expect(stats.income, 1000);
    expect(stats.expense, 1200);
    expect(stats.balance, -200);
    expect(stats.spendingRatio, 1);
    expect(stats.byCategory.single.amount, 1200);
  });
}

AppTransaction _transaction(
    TransactionType type, int amount, String categoryId, DateTime date) {
  return AppTransaction(
      type: type,
      amount: amount,
      categoryId: categoryId,
      date: date,
      createdAt: date,
      updatedAt: date);
}
