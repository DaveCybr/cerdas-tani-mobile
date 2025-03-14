import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ResultDatabase {
  static final ResultDatabase instance = ResultDatabase._init();
  factory ResultDatabase() => instance;
  ResultDatabase.internal();

  static Database? _database;

  ResultDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('result_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      liter INTEGER NOT NULL,
      konsentrasi INTEGER NOT NULL,
      name_recipe TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE result (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name_nutrient TEXT NOT NULL,
      weight REAL NOT NULL,
      price REAL NOT NULL,
      type TEXT NOT NULL,
      id_history INTEGER NOT NULL,
      FOREIGN KEY (id_history) REFERENCES history (id)
    )
    ''');
  }

  Future<List<Map<String, dynamic>>> getHistories() async {
    final db = await instance.database;
    final result = await db.query('history');
    return result;
  }

  Future<List<Map<String, dynamic>>> getFertilizersByHistoryId(
      int historyId) async {
    final db = await ResultDatabase.instance.database;
    return await db.query(
      'result',
      where: 'id_history = ?',
      whereArgs: [historyId],
    );
  }
}
