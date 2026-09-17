import 'database.dart';
import '../models/transaction.dart';

class TransactionDao {
  TransactionDao(this._database);
  final AppDatabase _database;

  Future<List<AppTransaction>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(AppTransaction.fromMap).toList();
  }

  Future<int> insert(AppTransaction transaction) async {
    final db = await _database.database;
    return db.insert('transactions', transaction.toMap());
  }

  Future<int> update(AppTransaction transaction) async {
    final db = await _database.database;
    return db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
