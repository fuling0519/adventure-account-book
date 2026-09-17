import 'database.dart';
import '../models/category.dart';

class CategoryDao {
  CategoryDao(this._database);
  final AppDatabase _database;

  Future<List<Category>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map(Category.fromMap).toList();
  }
}
