import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final instance = AppDatabase._();
  Database? _database;

  Future<void> initialize() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasesPath = await getDatabasesPath();
    final databasePath = join(databasesPath, 'adventurer_pouch.db');
    _database =
        await openDatabase(databasePath, version: 1, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense'))
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        amount INTEGER NOT NULL CHECK (amount > 0),
        category_id TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    final categories = [
      ['food', '飲食', '🍜', 'expense'],
      ['transport', '交通', '🚌', 'expense'],
      ['shopping', '購物', '🛍️', 'expense'],
      ['entertainment', '娛樂', '🎮', 'expense'],
      ['housing', '居住', '🏠', 'expense'],
      ['health', '健康', '❤️', 'expense'],
      ['salary', '薪資', '💰', 'income'],
      ['other', '其他', '📦', 'expense'],
    ];
    for (final category in categories) {
      await db.insert('categories', {
        'id': category[0],
        'name': category[1],
        'icon': category[2],
        'type': category[3],
      });
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
