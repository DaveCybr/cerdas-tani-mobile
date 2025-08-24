// ========================================
// 3. recipe SERVICE - recipe_service.dart
// ========================================

import 'package:sqflite/sqflite.dart';
import '../models/recipe_model.dart';
import 'database_service.dart';

class RecipeService {
  final DatabaseService _databaseService = DatabaseService.instance;
  static const String _tableName = 'recipes';

  // Create new recipe
  Future<int> createrecipe(RecipeModel recipe) async {
    try {
      final db = await _databaseService.database;
      final id = await db.insert(
        _tableName,
        recipe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  // Get all recipe
  Future<List<RecipeModel>> getAllrecipe() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return RecipeModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get recipe: $e');
    }
  }

  // Get recipe by ID
  Future<RecipeModel?> getrecipeById(int id) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return RecipeModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get recipe: $e');
    }
  }

  // Search recipe by name
  Future<List<RecipeModel>> searchrecipe(String query) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'name LIKE ? OR type LIKE ? OR brand LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return RecipeModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to search recipe: $e');
    }
  }

  // Get recipe by type
  Future<List<RecipeModel>> getrecipeByType(String type) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return RecipeModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to get recipe by type: $e');
    }
  }

  // Update recipe
  Future<int> updaterecipe(RecipeModel recipe) async {
    try {
      final db = await _databaseService.database;
      final updatedrecipe = recipe.copyWith(updatedAt: DateTime.now());

      return await db.update(
        _tableName,
        updatedrecipe.toMap(),
        where: 'id = ?',
        whereArgs: [recipe.id],
      );
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  // Delete recipe
  Future<int> deleterecipe(int id) async {
    try {
      final db = await _databaseService.database;
      return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  // Bulk insert recipe
  Future<void> bulkInsertrecipe(List<RecipeModel> recipe) async {
    try {
      final db = await _databaseService.database;
      final batch = db.batch();

      for (final recipe in recipe) {
        batch.insert(_tableName, recipe.toMap());
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to bulk insert recipe: $e');
    }
  }

  // Get recipe count
  Future<int> getrecipeCount() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get recipe count: $e');
    }
  }

  // Check if recipe name exists
  Future<bool> recipeNameExists(String name, {int? excludeId}) async {
    try {
      final db = await _databaseService.database;
      String whereClause = 'LOWER(name) = ?';
      List<dynamic> whereArgs = [name.toLowerCase()];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final result = await db.query(
        _tableName,
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check recipe name: $e');
    }
  }
}
