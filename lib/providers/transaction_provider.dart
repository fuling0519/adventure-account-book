import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/category_dao.dart';
import '../database/database.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

final categoryProvider = FutureProvider<List<Category>>((ref) {
  return CategoryDao(AppDatabase.instance).getAll();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<AppTransaction>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<AppTransaction>> {
  @override
  Future<List<AppTransaction>> build() {
    return ref.read(transactionRepositoryProvider).getAll();
  }

  Future<void> add(AppTransaction transaction) async {
    await ref.read(transactionRepositoryProvider).insert(transaction);
    ref.invalidateSelf();
  }

  Future<void> edit(AppTransaction transaction) async {
    await ref.read(transactionRepositoryProvider).update(transaction);
    ref.invalidateSelf();
  }

  Future<void> remove(int id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}
