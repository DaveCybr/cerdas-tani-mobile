// ========================================
// 2. HYDROBUDDY-STYLE DATABASE SERVICE - database_service.dart
// ========================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recipe_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'hydrobuddy_app.db';
  static const int _databaseVersion = 2; // Updated for new schema

  // Table name
  static const String _recipeTable = 'recipes';

  // Singleton
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create recipes table with HydroBuddy-style structure
    await db.execute('''
      CREATE TABLE $_recipeTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        
        -- Primary nutrients (HydroBuddy inputs)
        nitrate_nitrogen REAL NOT NULL DEFAULT 0,
        ammonium_nitrogen REAL NOT NULL DEFAULT 0,
        calcium REAL NOT NULL DEFAULT 0,
        sulfur REAL NOT NULL DEFAULT 0,
        potassium REAL NOT NULL DEFAULT 0,
        phosphorus REAL NOT NULL DEFAULT 0,
        magnesium REAL NOT NULL DEFAULT 0,
        
        -- Micronutrients
        iron REAL NOT NULL DEFAULT 0,
        manganese REAL NOT NULL DEFAULT 0,
        zinc REAL NOT NULL DEFAULT 0,
        boron REAL NOT NULL DEFAULT 0,
        copper REAL NOT NULL DEFAULT 0,
        molybdenum REAL NOT NULL DEFAULT 0,
        
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for faster searches
    await db.execute('''
      CREATE INDEX idx_recipe_name ON $_recipeTable (name)
    ''');

    await db.execute('''
      CREATE INDEX idx_recipe_type ON $_recipeTable (type)
    ''');

    await db.execute('''
      CREATE INDEX idx_recipe_crop ON $_recipeTable (target_crop)
    ''');

    // Insert default HydroBuddy-style recipes
    await _insertDefaultRecipes(db);
  }

  Future<void> _insertDefaultRecipes(Database db) async {
    final defaultRecipes = [RecipeModel.lettuce()];

    for (final recipe in defaultRecipes) {
      await db.insert(_recipeTable, recipe.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from old schema to HydroBuddy style
      await db.execute('DROP TABLE IF EXISTS $_recipeTable');
      await _onCreate(db, newVersion);
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Helper method to reset database (useful for development)
  Future<void> resetDatabase() async {
    await deleteDatabase();
    _database = await _initDatabase();
  }

  // Get database info for debugging
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final recipeCount = await db.rawQuery(
      "SELECT COUNT(*) as count FROM $_recipeTable",
    );

    return {
      'database_name': _databaseName,
      'version': _databaseVersion,
      'tables': tables,
      'recipe_count': recipeCount.first['count'],
    };
  }

  // Get recipes by crop type (HydroBuddy feature)
  Future<List<RecipeModel>> getRecipesByCrop(String crop) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _recipeTable,
      where: 'target_crop = ?',
      whereArgs: [crop],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return RecipeModel.fromMap(maps[i]);
    });
  }

  // Get recipes by EC
}
