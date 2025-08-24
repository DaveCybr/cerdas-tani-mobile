// ========================================
// NUTRIENT PROVIDER - nutrient_provider.dart
// ========================================

import 'package:flutter/material.dart';

import '../models/nutrient_model.dart';
import '../services/nutrient_service.dart';

class NutrientProvider extends ChangeNotifier {
  final NutrientService _nutrientService = NutrientService();

  // State variables
  List<NutrientModel> _nutrients = [];
  List<NutrientModel> _filteredNutrients = [];
  NutrientModel? _selectedNutrient;
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedType = 'All'; // All, A, B
  Map<String, dynamic> _databaseStats = {};

  // Getters
  List<NutrientModel> get nutrients => _nutrients;
  List<NutrientModel> get filteredNutrients => _filteredNutrients;
  NutrientModel? get selectedNutrient => _selectedNutrient;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  Map<String, dynamic> get databaseStats => _databaseStats;
  bool get hasError => _errorMessage.isNotEmpty;
  bool get hasNutrients => _nutrients.isNotEmpty;

  // ========================================
  // STATE MANAGEMENT METHODS
  // ========================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // ========================================
  // NUTRIENT OPERATIONS
  // ========================================

  /// Load all nutrients
  Future<void> loadNutrients() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _nutrientService.getAllNutrients();

      if (result.isSuccess) {
        _nutrients = result.data ?? [];
        _applyFilters();
        await _loadDatabaseStats();
      } else {
        _setError(result.errorMessage ?? 'Failed to load nutrients');
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new nutrient
  Future<bool> createNutrient(NutrientModel nutrient) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _nutrientService.createNutrient(nutrient);

      if (result.isSuccess) {
        await loadNutrients(); // Refresh list
        return true;
      } else {
        _setError(result.errorMessage ?? 'Failed to create nutrient');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update existing nutrient
  Future<bool> updateNutrient(NutrientModel nutrient) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _nutrientService.updateNutrient(nutrient);

      if (result.isSuccess) {
        await loadNutrients(); // Refresh list
        return true;
      } else {
        _setError(result.errorMessage ?? 'Failed to update nutrient');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete nutrient
  Future<bool> deleteNutrient(int id) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _nutrientService.deleteNutrient(id);

      if (result.isSuccess) {
        await loadNutrients(); // Refresh list
        if (_selectedNutrient?.id == id) {
          _selectedNutrient = null;
        }
        return true;
      } else {
        _setError(result.errorMessage ?? 'Failed to delete nutrient');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Import multiple nutrients
  Future<bool> importNutrients(List<NutrientModel> nutrients) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _nutrientService.importNutrients(nutrients);

      if (result.isSuccess) {
        await loadNutrients(); // Refresh list
        return true;
      } else {
        _setError(result.errorMessage ?? 'Failed to import nutrients');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================
  // FILTERING AND SEARCHING
  // ========================================

  /// Set search query and apply filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Set type filter and apply filters
  void setTypeFilter(String type) {
    _selectedType = type;
    _applyFilters();
  }

  /// Apply current filters to nutrient list
  void _applyFilters() {
    List<NutrientModel> filtered = List.from(_nutrients);

    // Apply type filter
    if (_selectedType != 'All') {
      filtered =
          filtered
              .where((n) => n.type.toUpperCase() == _selectedType.toUpperCase())
              .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered
              .where(
                (n) =>
                    n.name.toLowerCase().contains(query) ||
                    n.formula.toLowerCase().contains(query) ||
                    n.nutrientProfile.toLowerCase().contains(query),
              )
              .toList();
    }

    _filteredNutrients = filtered;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedType = 'All';
    _applyFilters();
  }

  // ========================================
  // SELECTION MANAGEMENT
  // ========================================

  /// Select a nutrient
  void selectNutrient(NutrientModel? nutrient) {
    _selectedNutrient = nutrient;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedNutrient = null;
    notifyListeners();
  }

  // ========================================
  // STATISTICS AND ANALYTICS
  // ========================================

  /// Load database statistics
  Future<void> _loadDatabaseStats() async {
    try {
      final result = await _nutrientService.getDatabaseStats();
      if (result.isSuccess) {
        _databaseStats = result.data ?? {};
      }
    } catch (e) {
      debugPrint('Error loading database stats: $e');
    }
  }

  /// Get nutrients grouped by type
  Map<String, List<NutrientModel>> get nutrientsByType {
    Map<String, List<NutrientModel>> grouped = {'A': [], 'B': []};

    for (final nutrient in _nutrients) {
      grouped[nutrient.type]?.add(nutrient);
    }

    return grouped;
  }

  /// Get price statistics
  Map<String, double> get priceStats {
    if (_nutrients.isEmpty) return {};

    final prices = _nutrients.map((n) => n.pricePerKg).toList();
    prices.sort();

    return {
      'min': prices.first,
      'max': prices.last,
      'average': prices.reduce((a, b) => a + b) / prices.length,
      'median':
          prices.length % 2 == 0
              ? (prices[prices.length ~/ 2 - 1] + prices[prices.length ~/ 2]) /
                  2
              : prices[prices.length ~/ 2],
    };
  }

  // ========================================
  // UTILITY METHODS
  // ========================================

  /// Refresh data
  Future<void> refresh() async {
    await loadNutrients();
  }

  /// Clear all data
  void clear() {
    _nutrients.clear();
    _filteredNutrients.clear();
    _selectedNutrient = null;
    _searchQuery = '';
    _selectedType = 'All';
    _databaseStats.clear();
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}

// ========================================
// HELPER CLASSES
// ========================================

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}

class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final String? successMessage;

  ServiceResult._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.successMessage,
  });

  factory ServiceResult.success(T? data, {String? message}) {
    return ServiceResult._(
      isSuccess: true,
      data: data,
      successMessage: message,
    );
  }

  factory ServiceResult.error(String message) {
    return ServiceResult._(isSuccess: false, errorMessage: message);
  }
}
