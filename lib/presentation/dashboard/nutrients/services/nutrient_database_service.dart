// ========================================
// NUTRIENT DATABASE SERVICE - nutrient_database_service.dart
// ========================================

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/nutrient_model.dart';

class NutrientDatabaseService {
  static final NutrientDatabaseService _instance =
      NutrientDatabaseService._internal();
  static Database? _database;

  factory NutrientDatabaseService() {
    return _instance;
  }

  NutrientDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'nutrients.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE nutrients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          formula TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('A', 'B')),
          price_per_kg REAL NOT NULL DEFAULT 0.0,
          nh4 REAL NOT NULL DEFAULT 0.0,
          no3 REAL NOT NULL DEFAULT 0.0,
          p REAL NOT NULL DEFAULT 0.0,
          k REAL NOT NULL DEFAULT 0.0,
          ca REAL NOT NULL DEFAULT 0.0,
          mg REAL NOT NULL DEFAULT 0.0,
          s REAL NOT NULL DEFAULT 0.0,
          fe REAL NOT NULL DEFAULT 0.0,
          mn REAL NOT NULL DEFAULT 0.0,
          zn REAL NOT NULL DEFAULT 0.0,
          b REAL NOT NULL DEFAULT 0.0,
          cu REAL NOT NULL DEFAULT 0.0,
          mo REAL NOT NULL DEFAULT 0.0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          UNIQUE(name, formula)
        )
      ''');

      // Create indexes for better performance
      await db.execute('CREATE INDEX idx_nutrients_name ON nutrients(name)');
      await db.execute('CREATE INDEX idx_nutrients_type ON nutrients(type)');
      await db.execute(
        'CREATE INDEX idx_nutrients_formula ON nutrients(formula)',
      );

      print('Database and tables created successfully');
    } catch (e) {
      print('Error creating database: $e');
      rethrow;
    }
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database upgrades if needed in the future
    try {
      if (oldVersion < newVersion) {
        // Add upgrade logic here for future versions
        print('Database upgraded from version $oldVersion to $newVersion');
      }
    } catch (e) {
      print('Error upgrading database: $e');
      rethrow;
    }
  }

  // ========================================
  // CRUD OPERATIONS
  // ========================================

  /// Insert a new nutrient
  Future<int> insertNutrient(NutrientModel nutrient) async {
    try {
      final db = await database;
      final nutrientMap = nutrient.toMap();
      nutrientMap.remove('id'); // Remove id for auto-increment

      final id = await db.insert(
        'nutrients',
        nutrientMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Nutrient inserted with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting nutrient: $e');
      throw DatabaseException('Failed to insert nutrient: $e');
    }
  }

  /// Get all nutrients
  Future<List<NutrientModel>> getAllNutrients() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'nutrients',
        orderBy: 'name ASC',
      );

      return maps.map((map) => NutrientModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all nutrients: $e');
      throw DatabaseException('Failed to get nutrients: $e');
    }
  }

  /// Get nutrient by ID
  Future<NutrientModel?> getNutrientById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'nutrients',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return NutrientModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting nutrient by ID: $e');
      throw DatabaseException('Failed to get nutrient: $e');
    }
  }

  /// Get nutrients by type (A or B)
  Future<List<NutrientModel>> getNutrientsByType(String type) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'nutrients',
        where: 'type = ?',
        whereArgs: [type.toUpperCase()],
        orderBy: 'name ASC',
      );

      return maps.map((map) => NutrientModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting nutrients by type: $e');
      throw DatabaseException('Failed to get nutrients by type: $e');
    }
  }

  /// Search nutrients by name or formula
  Future<List<NutrientModel>> searchNutrients(String query) async {
    try {
      final db = await database;
      final searchQuery = '%${query.toLowerCase()}%';

      final List<Map<String, dynamic>> maps = await db.query(
        'nutrients',
        where: 'LOWER(name) LIKE ? OR LOWER(formula) LIKE ?',
        whereArgs: [searchQuery, searchQuery],
        orderBy: 'name ASC',
      );

      return maps.map((map) => NutrientModel.fromMap(map)).toList();
    } catch (e) {
      print('Error searching nutrients: $e');
      throw DatabaseException('Failed to search nutrients: $e');
    }
  }

  /// Update nutrient
  Future<int> updateNutrient(NutrientModel nutrient) async {
    try {
      final db = await database;
      final updatedNutrient = nutrient.copyWith(updatedAt: DateTime.now());

      final rowsAffected = await db.update(
        'nutrients',
        updatedNutrient.toMap(),
        where: 'id = ?',
        whereArgs: [nutrient.id],
      );

      print('Nutrient updated. Rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Error updating nutrient: $e');
      throw DatabaseException('Failed to update nutrient: $e');
    }
  }

  /// Delete nutrient
  Future<int> deleteNutrient(int id) async {
    try {
      final db = await database;
      final rowsAffected = await db.delete(
        'nutrients',
        where: 'id = ?',
        whereArgs: [id],
      );

      print('Nutrient deleted. Rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Error deleting nutrient: $e');
      throw DatabaseException('Failed to delete nutrient: $e');
    }
  }

  /// Delete all nutrients
  Future<int> deleteAllNutrients() async {
    try {
      final db = await database;
      final rowsAffected = await db.delete('nutrients');

      print('All nutrients deleted. Rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Error deleting all nutrients: $e');
      throw DatabaseException('Failed to delete all nutrients: $e');
    }
  }

  // ========================================
  // ADVANCED QUERIES
  // ========================================

  /// Get nutrients with specific nutrient content
  Future<List<NutrientModel>> getNutrientsWithNutrient(
    String nutrientType,
  ) async {
    try {
      final db = await database;
      String whereClause = '';

      switch (nutrientType.toLowerCase()) {
        case 'nitrogen':
        case 'n':
          whereClause = '(nh4 > 0 OR no3 > 0)';
          break;
        case 'phosphorus':
        case 'p':
          whereClause = 'p > 0';
          break;
        case 'potassium':
        case 'k':
          whereClause = 'k > 0';
          break;
        case 'calcium':
        case 'ca':
          whereClause = 'ca > 0';
          break;
        case 'magnesium':
        case 'mg':
          whereClause = 'mg > 0';
          break;
        case 'sulfur':
        case 's':
          whereClause = 's > 0';
          break;
        case 'iron':
        case 'fe':
          whereClause = 'fe > 0';
          break;
        default:
          whereClause = '1=1'; // Return all if unknown nutrient
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'nutrients',
        where: whereClause,
        orderBy: 'name ASC',
      );

      return maps.map((map) => NutrientModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting nutrients with specific nutrient: $e');
      throw DatabaseException('Failed to get nutrients with nutrient: $e');
    }
  }

  /// Get nutrients in price range
  Future<List<NutrientModel>> getNutrientsInPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'nutrients',
        where: 'price_per_kg BETWEEN ? AND ?',
        whereArgs: [minPrice, maxPrice],
        orderBy: 'price_per_kg ASC',
      );

      return maps.map((map) => NutrientModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting nutrients in price range: $e');
      throw DatabaseException('Failed to get nutrients in price range: $e');
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;

      final totalCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM nutrients'),
          ) ??
          0;

      final typeACount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM nutrients WHERE type = "A"',
            ),
          ) ??
          0;

      final typeBCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM nutrients WHERE type = "B"',
            ),
          ) ??
          0;

      final avgPrice = await db.rawQuery(
        'SELECT AVG(price_per_kg) as avg_price FROM nutrients',
      );
      final averagePrice =
          avgPrice.isNotEmpty
              ? (avgPrice.first['avg_price'] as double?) ?? 0.0
              : 0.0;

      return {
        'total_nutrients': totalCount,
        'type_a_count': typeACount,
        'type_b_count': typeBCount,
        'average_price': averagePrice,
      };
    } catch (e) {
      print('Error getting database stats: $e');
      throw DatabaseException('Failed to get database stats: $e');
    }
  }

  // ========================================
  // BULK OPERATIONS
  // ========================================

  /// Insert multiple nutrients in a transaction
  Future<List<int>> insertNutrients(List<NutrientModel> nutrients) async {
    try {
      final db = await database;
      List<int> insertedIds = [];

      await db.transaction((txn) async {
        for (final nutrient in nutrients) {
          final nutrientMap = nutrient.toMap();
          nutrientMap.remove('id'); // Remove id for auto-increment

          final id = await txn.insert(
            'nutrients',
            nutrientMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          insertedIds.add(id);
        }
      });

      print('Bulk insert completed. ${insertedIds.length} nutrients inserted.');
      return insertedIds;
    } catch (e) {
      print('Error in bulk insert: $e');
      throw DatabaseException('Failed to insert multiple nutrients: $e');
    }
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Check if nutrient exists by name and formula
  Future<bool> nutrientExists(String name, String formula) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'nutrients',
        where: 'name = ? AND formula = ?',
        whereArgs: [name, formula],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking if nutrient exists: $e');
      return false;
    }
  }

  /// Close database connection
  Future<void> close() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
        _database = null;
        print('Database connection closed');
      }
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  /// Delete database file (for testing purposes)
  Future<void> deleteDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'nutrients.db');
      await databaseFactory.deleteDatabase(path);
      _database = null;
      print('Database deleted');
    } catch (e) {
      print('Error deleting database: $e');
    }
  }
}

// Custom exception for database errors
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
