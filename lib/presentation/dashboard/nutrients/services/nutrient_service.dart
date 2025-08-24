// ========================================
// NUTRIENT SERVICE - nutrient_service.dart
// ========================================

import 'package:flutter/foundation.dart';
import '../models/nutrient_model.dart';
import '../providers/nutrient_provider.dart';
import 'nutrient_database_service.dart';

class NutrientService {
  final NutrientDatabaseService _databaseService = NutrientDatabaseService();

  // ========================================
  // BUSINESS LOGIC METHODS
  // ========================================

  /// Validate nutrient data before saving
  ValidationResult validateNutrient(NutrientModel nutrient) {
    List<String> errors = [];

    // Name validation
    if (nutrient.name.trim().isEmpty) {
      errors.add('Name is required');
    } else if (nutrient.name.length < 2) {
      errors.add('Name must be at least 2 characters');
    }

    // Formula validation
    if (nutrient.formula.trim().isEmpty) {
      errors.add('Formula is required');
    }

    // Type validation
    if (!['A', 'B'].contains(nutrient.type.toUpperCase())) {
      errors.add('Type must be A or B');
    }

    // Price validation
    if (nutrient.pricePerKg < 0) {
      errors.add('Price cannot be negative');
    }

    // Nutrient content validation
    if (nutrient.totalNitrogen < 0 || nutrient.p < 0 || nutrient.k < 0) {
      errors.add('Nutrient percentages cannot be negative');
    }

    // Check if total macronutrients exceed 100%
    double totalMacro =
        nutrient.totalNitrogen +
        nutrient.p +
        nutrient.k +
        nutrient.ca +
        nutrient.mg +
        nutrient.s;
    if (totalMacro > 100) {
      errors.add('Total macronutrients cannot exceed 100%');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Create nutrient with validation
  Future<ServiceResult<int>> createNutrient(NutrientModel nutrient) async {
    try {
      // Validate input
      final validation = validateNutrient(nutrient);
      if (!validation.isValid) {
        return ServiceResult.error(validation.errors.join(', '));
      }

      // Check if nutrient already exists
      final exists = await _databaseService.nutrientExists(
        nutrient.name.trim(),
        nutrient.formula.trim(),
      );

      if (exists) {
        return ServiceResult.error(
          'Nutrient with this name and formula already exists',
        );
      }

      // Create nutrient
      final id = await _databaseService.insertNutrient(nutrient);
      return ServiceResult.success(
        id,
        message: 'Nutrient created successfully',
      );
    } catch (e) {
      debugPrint('Error creating nutrient: $e');
      return ServiceResult.error('Failed to create nutrient: ${e.toString()}');
    }
  }

  /// Update nutrient with validation
  Future<ServiceResult<bool>> updateNutrient(NutrientModel nutrient) async {
    try {
      if (nutrient.id == null) {
        return ServiceResult.error('Nutrient ID is required for update');
      }

      // Validate input
      final validation = validateNutrient(nutrient);
      if (!validation.isValid) {
        return ServiceResult.error(validation.errors.join(', '));
      }

      // Check if nutrient exists
      final existing = await _databaseService.getNutrientById(nutrient.id!);
      if (existing == null) {
        return ServiceResult.error('Nutrient not found');
      }

      // Update nutrient
      final rowsAffected = await _databaseService.updateNutrient(nutrient);

      if (rowsAffected > 0) {
        return ServiceResult.success(
          true,
          message: 'Nutrient updated successfully',
        );
      } else {
        return ServiceResult.error('No changes were made');
      }
    } catch (e) {
      debugPrint('Error updating nutrient: $e');
      return ServiceResult.error('Failed to update nutrient: ${e.toString()}');
    }
  }

  /// Delete nutrient with confirmation
  Future<ServiceResult<bool>> deleteNutrient(int id) async {
    try {
      // Check if nutrient exists
      final existing = await _databaseService.getNutrientById(id);
      if (existing == null) {
        return ServiceResult.error('Nutrient not found');
      }

      // Delete nutrient
      final rowsAffected = await _databaseService.deleteNutrient(id);

      if (rowsAffected > 0) {
        return ServiceResult.success(
          true,
          message: 'Nutrient deleted successfully',
        );
      } else {
        return ServiceResult.error('Failed to delete nutrient');
      }
    } catch (e) {
      debugPrint('Error deleting nutrient: $e');
      return ServiceResult.error('Failed to delete nutrient: ${e.toString()}');
    }
  }

  /// Get all nutrients
  Future<ServiceResult<List<NutrientModel>>> getAllNutrients() async {
    try {
      final nutrients = await _databaseService.getAllNutrients();
      return ServiceResult.success(nutrients);
    } catch (e) {
      debugPrint('Error getting nutrients: $e');
      return ServiceResult.error('Failed to get nutrients: ${e.toString()}');
    }
  }

  /// Get nutrient by ID
  Future<ServiceResult<NutrientModel?>> getNutrientById(int id) async {
    try {
      final nutrient = await _databaseService.getNutrientById(id);
      return ServiceResult.success(nutrient);
    } catch (e) {
      debugPrint('Error getting nutrient: $e');
      return ServiceResult.error('Failed to get nutrient: ${e.toString()}');
    }
  }

  /// Search nutrients
  Future<ServiceResult<List<NutrientModel>>> searchNutrients(
    String query,
  ) async {
    try {
      if (query.trim().isEmpty) {
        return getAllNutrients();
      }

      final nutrients = await _databaseService.searchNutrients(query.trim());
      return ServiceResult.success(nutrients);
    } catch (e) {
      debugPrint('Error searching nutrients: $e');
      return ServiceResult.error('Failed to search nutrients: ${e.toString()}');
    }
  }

  /// Get nutrients by type
  Future<ServiceResult<List<NutrientModel>>> getNutrientsByType(
    String type,
  ) async {
    try {
      if (!['A', 'B'].contains(type.toUpperCase())) {
        return ServiceResult.error('Invalid type. Must be A or B');
      }

      final nutrients = await _databaseService.getNutrientsByType(type);
      return ServiceResult.success(nutrients);
    } catch (e) {
      debugPrint('Error getting nutrients by type: $e');
      return ServiceResult.error(
        'Failed to get nutrients by type: ${e.toString()}',
      );
    }
  }

  /// Get database statistics
  Future<ServiceResult<Map<String, dynamic>>> getDatabaseStats() async {
    try {
      final stats = await _databaseService.getDatabaseStats();
      return ServiceResult.success(stats);
    } catch (e) {
      debugPrint('Error getting database stats: $e');
      return ServiceResult.error(
        'Failed to get database stats: ${e.toString()}',
      );
    }
  }

  /// Import nutrients from list
  Future<ServiceResult<List<int>>> importNutrients(
    List<NutrientModel> nutrients,
  ) async {
    try {
      List<String> validationErrors = [];
      List<NutrientModel> validNutrients = [];

      // Validate all nutrients first
      for (int i = 0; i < nutrients.length; i++) {
        final validation = validateNutrient(nutrients[i]);
        if (!validation.isValid) {
          validationErrors.add('Row ${i + 1}: ${validation.errors.join(', ')}');
        } else {
          validNutrients.add(nutrients[i]);
        }
      }

      if (validationErrors.isNotEmpty) {
        return ServiceResult.error(
          'Validation errors:\n${validationErrors.join('\n')}',
        );
      }

      if (validNutrients.isEmpty) {
        return ServiceResult.error('No valid nutrients to import');
      }

      // Import valid nutrients
      final ids = await _databaseService.insertNutrients(validNutrients);
      return ServiceResult.success(
        ids,
        message: '${validNutrients.length} nutrients imported successfully',
      );
    } catch (e) {
      debugPrint('Error importing nutrients: $e');
      return ServiceResult.error('Failed to import nutrients: ${e.toString()}');
    }
  }

  /// Calculate nutrient solution based on target values
  Map<String, double> calculateNutrientSolution({
    required List<NutrientModel> availableNutrients,
    required Map<String, double> targetValues,
    required double solutionVolume,
  }) {
    // Simplified calculation - in real app, this would be more complex
    Map<String, double> recommendations = {};

    try {
      for (final nutrient in availableNutrients) {
        double score = 0;

        // Calculate how well this nutrient matches target values
        if (targetValues.containsKey('nitrogen')) {
          score +=
              (nutrient.totalNitrogen / (targetValues['nitrogen'] ?? 1)) * 0.3;
        }
        if (targetValues.containsKey('phosphorus')) {
          score += (nutrient.p / (targetValues['phosphorus'] ?? 1)) * 0.25;
        }
        if (targetValues.containsKey('potassium')) {
          score += (nutrient.k / (targetValues['potassium'] ?? 1)) * 0.25;
        }

        // Simple recommendation based on score
        if (score > 0.1) {
          recommendations[nutrient.name] = (solutionVolume * score).clamp(
            0.1,
            10.0,
          );
        }
      }
    } catch (e) {
      debugPrint('Error calculating nutrient solution: $e');
    }

    return recommendations;
  }
}
