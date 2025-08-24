// ========================================
// 4. Recipe PROVIDER - recipe_provider.dart (FIXED)
// ========================================

import 'package:flutter/foundation.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

enum RecipeStatus { initial, loading, success, error }

class RecipeProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  // State
  RecipeStatus _status = RecipeStatus.initial;
  List<RecipeModel> _recipes = [];
  List<RecipeModel> _filteredRecipes = [];
  RecipeModel? _selectedRecipe;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedType = 'ALL';

  // Getters
  RecipeStatus get status => _status;
  List<RecipeModel> get recipes =>
      _filteredRecipes; // Fixed: changed from Recipes
  List<RecipeModel> get allRecipes =>
      _filteredRecipes; // Fixed: return filtered recipes
  RecipeModel? get selectedRecipe => _selectedRecipe;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  bool get isLoading => _status == RecipeStatus.loading;
  bool get hasError => _status == RecipeStatus.error;
  bool get isEmpty => _filteredRecipes.isEmpty; // Fixed: check filtered recipes

  // Load all Recipes
  Future<void> loadRecipes() async {
    _setStatus(RecipeStatus.loading);
    try {
      _recipes = await _recipeService.getAllrecipe();
      _applyFilters();
      _setStatus(RecipeStatus.success);
    } catch (e) {
      _setError('Failed to load Recipes: $e');
    }
  }

  // Create new Recipe
  Future<bool> createRecipe(RecipeModel recipe) async {
    try {
      // Check if name already exists
      final nameExists = await _recipeService.recipeNameExists(recipe.name);
      if (nameExists) {
        _setError('Recipe with this name already exists');
        return false;
      }

      final id = await _recipeService.createrecipe(recipe);
      if (id > 0) {
        await loadRecipes(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to create Recipe: $e');
      return false;
    }
  }

  // Update Recipe
  Future<bool> updateRecipe(RecipeModel recipe) async {
    try {
      // Check if name already exists (excluding current Recipe)
      final nameExists = await _recipeService.recipeNameExists(
        recipe.name,
        excludeId: recipe.id,
      );
      if (nameExists) {
        _setError('Recipe with this name already exists');
        return false;
      }

      final result = await _recipeService.updaterecipe(recipe);
      if (result > 0) {
        await loadRecipes(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update Recipe: $e');
      return false;
    }
  }

  // Delete Recipe
  Future<bool> deleteRecipe(int id) async {
    try {
      final result = await _recipeService.deleterecipe(id);
      if (result > 0) {
        await loadRecipes(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete Recipe: $e');
      return false;
    }
  }

  // Get Recipe by ID
  Future<void> getRecipeById(int id) async {
    try {
      _selectedRecipe = await _recipeService.getrecipeById(id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to get Recipe: $e');
    }
  }

  // Search Recipes
  void searchRecipes(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  // Filter by type
  void filterByType(String type) {
    // Fixed: Toggle logic - if same type selected, clear filter
    if (_selectedType == type) {
      _selectedType = 'ALL';
    } else {
      _selectedType = type;
    }
    _applyFilters();
  }

  // Apply search and type filters
  void _applyFilters() {
    _filteredRecipes =
        _recipes.where((recipe) {
          // Search filter - check multiple fields
          final matchesSearch =
              _searchQuery.isEmpty ||
              recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              recipe.type.toLowerCase().contains(_searchQuery.toLowerCase());

          // Type filter
          final matchesType =
              _selectedType == 'ALL' || recipe.type == _selectedType;

          return matchesSearch && matchesType;
        }).toList();

    // Sort by name for consistent ordering
    _filteredRecipes.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedType = 'ALL';
    _applyFilters();
  }

  // Select Recipe
  void selectRecipe(RecipeModel? recipe) {
    _selectedRecipe = recipe;
    notifyListeners();
  }

  // Clear selected Recipe
  void clearSelectedRecipe() {
    _selectedRecipe = null;
    notifyListeners();
  }

  // Get unique types
  List<String> getAvailableTypes() {
    final types = _recipes.map((recipe) => recipe.type).toSet().toList();
    types.sort();
    return ['ALL', ...types];
  }

  // Helper methods
  void _setStatus(RecipeStatus status) {
    _status = status;
    if (status != RecipeStatus.error) {
      _errorMessage = '';
    }
    notifyListeners();
  }

  void _setError(String message) {
    _status = RecipeStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    if (_status == RecipeStatus.error) {
      _status = RecipeStatus.initial;
      _errorMessage = '';
      notifyListeners();
    }
  }

  // Refresh
  Future<void> refresh() async {
    clearFilters(); // Clear filters when refreshing
    await loadRecipes();
  }
}
