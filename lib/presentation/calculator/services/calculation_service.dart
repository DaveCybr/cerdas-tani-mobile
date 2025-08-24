// ========================================
// UPDATED CALCULATION API SERVICE - calculation_api_service.dart
// ========================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../dashboard/nutrients/models/nutrient_model.dart';
import '../../dashboard/recipes/models/recipe_model.dart';

class CalculationApiService {
  static const String baseUrl =
      'http://sirangga.satelliteorbit.cloud/api/v1'; // Ganti dengan URL API Anda
  static const Duration timeout = Duration(seconds: 30);

  /// Calculate nutrition based on recipe and selected fertilizers
  static Future<Map<String, dynamic>> calculateNutrition({
    required RecipeModel recipe,
    required List<NutrientModel> fertilizers,
    required double volumeLiters,
    required double concentrationFactor,
  }) async {
    try {
      // Prepare request data according to your API format
      final requestData = {
        "recipe": {
          "no3": recipe.nitrateNitrogen,
          "nh4": recipe.ammoniumNitrogen,
          "p": recipe.phosphorus,
          "k": recipe.potassium,
          "ca": recipe.calcium,
          "mg": recipe.magnesium,
          "s": recipe.sulfur,
          "fe": recipe.iron,
          "mn": recipe.manganese,
          "zn": recipe.zinc,
          "b": recipe.boron,
          "cu": recipe.copper,
          "mo": recipe.molybdenum,
        },
        "volume_liters": volumeLiters,
        "concentration_factor": concentrationFactor,
        "fertilizers":
            fertilizers
                .map(
                  (fertilizer) => {
                    "id": fertilizer.id.toString(),
                    "name": fertilizer.name,
                    "formula": fertilizer.formula,
                    "price_per_kg": fertilizer.pricePerKg,
                    "no3": fertilizer.no3,
                    "nh4": fertilizer.nh4,
                    "p": fertilizer.p,
                    "k": fertilizer.k,
                    "ca": fertilizer.ca,
                    "mg": fertilizer.mg,
                    "s": fertilizer.s,
                    "fe": fertilizer.fe,
                    "mn": fertilizer.mn,
                    "zn": fertilizer.zn,
                    "b": fertilizer.b,
                    "cu": fertilizer.cu,
                    "mo": fertilizer.mo,
                  },
                )
                .toList(),
      };

      print('Sending API Request: ${json.encode(requestData)}');

      // Send HTTP POST request
      final response = await http
          .post(
            Uri.parse('$baseUrl/calculate'), // Sesuaikan dengan endpoint Anda
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestData),
          )
          .timeout(timeout);

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Return response in the format expected by the UI
        return {
          'success': true,
          'data': responseData, // Return the actual API response structure
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          'details': response.body,
        };
      }
    } catch (e) {
      print('API Error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// Mock calculation that matches the real API response structure
  static Future<Map<String, dynamic>> mockCalculateNutrition({
    required RecipeModel recipe,
    required List<NutrientModel> fertilizers,
    required double volumeLiters,
    required double concentrationFactor,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock response that matches actual API structure
    return {
      'success': true,
      'data': {
        'substances':
            fertilizers.map((fertilizer) {
              // Mock calculation based on fertilizer type
              double baseAmount = 0.0;
              double costPerGram = fertilizer.pricePerKg / 1000;

              if (fertilizer.name.toLowerCase().contains('nitrate')) {
                baseAmount = 120.0 + (fertilizer.hashCode % 50);
              } else if (fertilizer.name.toLowerCase().contains('phosphate')) {
                baseAmount = 45.0 + (fertilizer.hashCode % 30);
              } else if (fertilizer.name.toLowerCase().contains('sulfate')) {
                baseAmount = 85.0 + (fertilizer.hashCode % 40);
              } else if (fertilizer.name.toLowerCase().contains('edta')) {
                baseAmount = 15.0 + (fertilizer.hashCode % 20);
              } else {
                baseAmount = 25.0 + (fertilizer.hashCode % 35);
              }

              return {
                'substance_name': fertilizer.name,
                'formula': fertilizer.formula,
                'amount_g': baseAmount,
                'units': 'g',
                'preparation_cost': baseAmount * costPerGram,
              };
            }).toList(),

        'elements': [
          {
            'element': 'N (NO3-)',
            'result_ppm': recipe.nitrateNitrogen * 0.95,
            'ge': '+17.4%',
            'ie': '+/- 0.1%',
            'water_ppm': 0,
          },
          {
            'element': 'N (NH4+)',
            'result_ppm': recipe.ammoniumNitrogen * 0.93,
            'ge': '+608.1%',
            'ie': '+/- 0.1%',
            'water_ppm': 0,
          },
          {
            'element': 'P',
            'result_ppm': recipe.phosphorus * 0.98,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
          {
            'element': 'K',
            'result_ppm': recipe.potassium * 0.97,
            'ge': '-32.6%',
            'ie': '+/- 0.1%',
            'water_ppm': 0,
          },
          {
            'element': 'Ca',
            'result_ppm': recipe.calcium * 0.96,
            'ge': '-22.4%',
            'ie': '+/- 0.1%',
            'water_ppm': 0,
          },
          {
            'element': 'Mg',
            'result_ppm': recipe.magnesium * 0.94,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
          {
            'element': 'S',
            'result_ppm': recipe.sulfur * 0.99,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
          {
            'element': 'Fe',
            'result_ppm': recipe.iron * 0.92,
            'ge': '+1,788.4%',
            'ie': '+/- 0.1%',
            'water_ppm': 0,
          },
          {
            'element': 'Mn',
            'result_ppm': recipe.manganese * 0.91,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
          {
            'element': 'Zn',
            'result_ppm': recipe.zinc * 0.89,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
          {
            'element': 'B',
            'result_ppm': recipe.boron * 0.93,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
          {
            'element': 'Cu',
            'result_ppm': recipe.copper * 0.88,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
          {
            'element': 'Mo',
            'result_ppm': recipe.molybdenum * 0.87,
            'ge': '-100.0%',
            'ie': '+/- 0%',
            'water_ppm': 0,
          },
        ],
      },
    };
  }

  /// Validate API response format (updated for new structure)
  static bool validateApiResponse(Map<String, dynamic> response) {
    try {
      final data = response['data'];
      if (data == null) return false;

      // Check for new API structure
      if (data.containsKey('elements') && data.containsKey('substances')) {
        final elements = data['elements'];
        final substances = data['substances'];

        return elements is List &&
            substances is List &&
            elements.isNotEmpty &&
            substances.isNotEmpty;
      }

      // Check for old API structure (backward compatibility)
      return data.containsKey('target_ppm') &&
          data.containsKey('result_ppm') &&
          data.containsKey('fertilizer_amounts');
    } catch (e) {
      print('Error validating API response: $e');
      return false;
    }
  }

  /// Format error message for user display
  static String formatErrorMessage(Map<String, dynamic> errorResponse) {
    if (errorResponse['error'] != null) {
      String error = errorResponse['error'].toString();
      if (error.contains('Network error')) {
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (error.contains('HTTP 400')) {
        return 'Data input tidak valid. Periksa kembali resep dan pupuk yang dipilih.';
      } else if (error.contains('HTTP 404')) {
        return 'Endpoint API tidak ditemukan. Hubungi administrator.';
      } else if (error.contains('HTTP 500')) {
        return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
      } else if (error.contains('TimeoutException')) {
        return 'Permintaan timeout. Periksa koneksi internet Anda.';
      }
    }
    return 'Terjadi kesalahan tidak dikenal. Silakan coba lagi.';
  }

  /// Parse substances from API response to fertilizer amounts format
  static List<Map<String, dynamic>> parseSubstancesToFertilizerAmounts(
    List<dynamic> substances,
  ) {
    return substances.map((substance) {
      return {
        'fertilizer_id': '',
        'fertilizer_name': substance['substance_name'] ?? 'Unknown',
        'formula': substance['formula'] ?? '',
        'grams': (substance['amount_g'] ?? 0.0).toDouble(),
        'cost': (substance['preparation_cost'] ?? 0.0).toDouble(),
        'units': substance['units'] ?? 'g',
      };
    }).toList();
  }

  /// Parse elements from API response to result PPM format
  static Map<String, double> parseElementsToResultPPM(List<dynamic> elements) {
    Map<String, double> tempResultPPM = {};

    for (var element in elements) {
      final elementName = element['element'] as String?;
      final resultPpm = (element['result_ppm'] ?? 0.0).toDouble();

      switch (elementName) {
        case 'N (NO3-)':
          tempResultPPM['NO3'] = resultPpm;
          break;
        case 'N (NH4+)':
          tempResultPPM['NH4'] = resultPpm;
          break;
        case 'P':
          tempResultPPM['Posphor'] = resultPpm;
          break;
        case 'K':
          tempResultPPM['Kalium'] = resultPpm;
          break;
        case 'Ca':
          tempResultPPM['Calcium'] = resultPpm;
          break;
        case 'Mg':
          tempResultPPM['Magnesium'] = resultPpm;
          break;
        case 'S':
          tempResultPPM['Sulfur'] = resultPpm;
          break;
        case 'Fe':
          tempResultPPM['Fe'] = resultPpm;
          break;
        case 'Mn':
          tempResultPPM['Mangan'] = resultPpm;
          break;
        case 'Zn':
          tempResultPPM['Zink'] = resultPpm;
          break;
        case 'B':
          tempResultPPM['Boron'] = resultPpm;
          break;
        case 'Cu':
          tempResultPPM['Cu'] = resultPpm;
          break;
        case 'Mo':
          tempResultPPM['Molibdenum'] = resultPpm;
          break;
      }
    }

    // Combine NO3 and NH4 into total Nitrogen
    final no3Value = tempResultPPM['NO3'] ?? 0.0;
    final nh4Value = tempResultPPM['NH4'] ?? 0.0;

    return {
      'Nitrogen': no3Value + nh4Value,
      'Posphor': tempResultPPM['Posphor'] ?? 0.0,
      'Kalium': tempResultPPM['Kalium'] ?? 0.0,
      'Magnesium': tempResultPPM['Magnesium'] ?? 0.0,
      'Calcium': tempResultPPM['Calcium'] ?? 0.0,
      'Sulfur': tempResultPPM['Sulfur'] ?? 0.0,
      'Fe': tempResultPPM['Fe'] ?? 0.0,
      'Mangan': tempResultPPM['Mangan'] ?? 0.0,
      'Zink': tempResultPPM['Zink'] ?? 0.0,
      'Boron': tempResultPPM['Boron'] ?? 0.0,
      'Cu': tempResultPPM['Cu'] ?? 0.0,
      'Molibdenum': tempResultPPM['Molibdenum'] ?? 0.0,
    };
  }

  /// Calculate total cost from substances
  static double calculateTotalCostFromSubstances(List<dynamic> substances) {
    double totalCost = 0.0;
    for (var substance in substances) {
      totalCost += (substance['preparation_cost'] ?? 0.0).toDouble();
    }
    return totalCost;
  }
}
