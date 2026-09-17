import '../database/database.dart';
import '../database/transaction_dao.dart';
import '../models/transaction.dart';

class TransactionRepository {
  TransactionRepository({AppDatabase? database})
      : _dao = TransactionDao(database ?? AppDatabase.instance);
  final TransactionDao _dao;

  Future<List<AppTransaction>> getAll() => _dao.getAll();
  Future<int> insert(AppTransaction transaction) => _dao.insert(transaction);
  Future<int> update(AppTransaction transaction) => _dao.update(transaction);
  Future<int> delete(int id) => _dao.delete(id);
}
