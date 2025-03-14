import 'package:fertilizer_calculator/data/recipe_data.dart';
import 'package:flutter/material.dart';

class RecipeProvider with ChangeNotifier {
  Map<String, dynamic> _recipes = {};
  Map<String, dynamic> get recipes => _recipes;

  String? _selectedRecipe;
  String? get selectedRecipe => _selectedRecipe;

  Map<String, dynamic>? get selectedRecipeNutrients {
    if (_selectedRecipe != null && _recipes.containsKey(_selectedRecipe)) {
      return _recipes[_selectedRecipe]["nutrients"];
    }
    return null;
  }

  Future<void> loadRecipes() async {
    try {
      List<Map<String, dynamic>> recipes = await RecipeHelper().getRecipes();
      Map<String, dynamic> data = {'recipes': {}};

      for (var recipe in recipes) {
        int recipeId = recipe['id'];
        List<Map<String, dynamic>> nutrients =
            await RecipeHelper().getNutrients(recipeId);

        Map<String, dynamic> macro = {};
        Map<String, dynamic> micro = {};

        for (var nutrient in nutrients) {
          if (nutrient['type'] == 'macro') {
            macro[nutrient['name']] = _formatNutrientValue(nutrient['value']);
          } else if (nutrient['type'] == 'micro') {
            micro[nutrient['name']] = _formatNutrientValue(nutrient['value']);
          }
        }

        data['recipes'][recipe['name']] = {
          'nutrients': {
            'macro': macro,
            'micro': micro,
          }
        };
      }

      _recipes = Map<String, dynamic>.from(data['recipes']);
      notifyListeners();
    } catch (e) {
      print('Error loading recipes from database: $e');
    }
  }

  Future<void> addRecipe(String name, Map<String, dynamic> macro,
      Map<String, dynamic> micro) async {
    try {
      final db = await RecipeHelper().database;
      // Insert new recipe
      int recipeId = await db.insert('recipes', {'name': name});
      print('Recipe added: $name with ID: $recipeId');

      // Insert macro nutrients
      for (var key in macro.keys) {
        await db.insert('nutrients', {
          'recipe_id': recipeId,
          'type': 'macro',
          'name': key,
          'value': macro[key],
        });
        print('Macro nutrient added: $key = ${macro[key]}');
      }

      // Insert micro nutrients
      for (var key in micro.keys) {
        await db.insert('nutrients', {
          'recipe_id': recipeId,
          'type': 'micro',
          'name': key,
          'value': micro[key],
        });
        print('Micro nutrient added: $key = ${micro[key]}');
      }

      // Reload recipes to update the list
      await loadRecipes();
    } catch (e) {
      print('Error adding recipe to database: $e');
    }
  }

  Future<void> deleteSelectedRecipe() async {
    if (_selectedRecipe == null) {
      print('Pilih resep terlebih dahulu');
      return;
    }

    try {
      final db = await RecipeHelper().database;
      // Get the recipe ID
      final recipe = await db
          .query('recipes', where: 'name = ?', whereArgs: [_selectedRecipe]);
      if (recipe.isNotEmpty) {
        int recipeId = recipe.first['id'] as int;
        // Delete the recipe and its nutrients
        await db.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
        await db
            .delete('nutrients', where: 'recipe_id = ?', whereArgs: [recipeId]);
        print('Recipe and associated nutrients deleted with ID: $recipeId');
        // Reload recipes to update the list
        await loadRecipes();
        _selectedRecipe = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting recipe from database: $e');
    }
  }

  Future<void> updateRecipe(String oldName, String newName,
      Map<String, dynamic> macro, Map<String, dynamic> micro) async {
    try {
      final db = await RecipeHelper().database;
      // Get the recipe ID
      final recipe =
          await db.query('recipes', where: 'name = ?', whereArgs: [oldName]);
      if (recipe.isNotEmpty) {
        int recipeId = recipe.first['id'] as int;
        // Update recipe name
        await db.update('recipes', {'name': newName},
            where: 'id = ?', whereArgs: [recipeId]);
        // Delete old nutrients
        await db
            .delete('nutrients', where: 'recipe_id = ?', whereArgs: [recipeId]);
        // Insert new macro nutrients
        for (var key in macro.keys) {
          await db.insert('nutrients', {
            'recipe_id': recipeId,
            'type': 'macro',
            'name': key,
            'value': macro[key],
          });
        }
        // Insert new micro nutrients
        for (var key in micro.keys) {
          await db.insert('nutrients', {
            'recipe_id': recipeId,
            'type': 'micro',
            'name': key,
            'value': micro[key],
          });
        }
        print('Recipe updated: $newName with ID: $recipeId');
        // Reload recipes to update the list
        await loadRecipes();
        _selectedRecipe = newName;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating recipe in database: $e');
    }
  }

  void selectRecipe(String name) {
    _selectedRecipe = name;
    notifyListeners();
  }

  String _formatNutrientValue(dynamic value) {
    if (value is double && value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
