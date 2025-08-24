// ========================================
// INTEGRATED CALCULATOR SCREEN - calculator_screen.dart
// ========================================

import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dashboard/nutrients/models/nutrient_model.dart';
import '../../dashboard/nutrients/providers/nutrient_provider.dart';
import '../../dashboard/recipes/models/recipe_model.dart';
import '../../dashboard/recipes/providers/recipe_provider.dart';

import '../services/calculation_service.dart';

class CalculatorScreenContent extends StatefulWidget {
  const CalculatorScreenContent({Key? key}) : super(key: key);

  @override
  State<CalculatorScreenContent> createState() =>
      _CalculatorScreenContentState();
}

class _CalculatorScreenContentState extends State<CalculatorScreenContent> {
  // Controllers for input fields
  final TextEditingController _volumeController = TextEditingController(
    text: '5',
  );
  final TextEditingController _concentrationController = TextEditingController(
    text: '100',
  );

  // Selected values
  RecipeModel? _selectedRecipe;
  List<NutrientModel> _selectedNutrients = [];

  // Calculation results
  Map<String, double> _targetPPM = {};
  Map<String, double> _resultPPM = {};
  bool _isCalculating = false;

  // API response data
  Map<String, dynamic>? _apiResponse;
  List<Map<String, dynamic>> _fertilizerAmounts = [];
  double _totalCost = 0.0;
  double _ecEstimate = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load initial data
      context.read<RecipeProvider>().loadRecipes();
      context.read<NutrientProvider>().loadNutrients();
    });
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _concentrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kalkulator Hara'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Recipe Selection Card
              _buildRecipeSelectionCard(),
              const SizedBox(height: 16),

              // Nutrient Selection Card
              _buildNutrientSelectionCard(),
              const SizedBox(height: 16),

              // Dosage Input Card
              _buildDosageCard(),
              const SizedBox(height: 16),

              // Nutrient Comparison Table
              _buildNutrientComparisonCard(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 16),

              // Info Text
              Text(
                _getStatusMessage(),
                style: TextStyle(color: _getStatusColor(), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Program Pemupukan',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                GestureDetector(
                  onTap: _showRecipeSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Ganti',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedRecipe?.name ?? 'Resep belum dipilih!',
              style: TextStyle(
                fontSize: 16,
                color: _selectedRecipe == null ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pupuk atau unsur hara',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                GestureDetector(
                  onTap: _showNutrientSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pilih',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedNutrients.isEmpty
                  ? 'Pupuk belum dipilih!'
                  : '${_selectedNutrients.length} pupuk terpilih',
              style: TextStyle(
                fontSize: 16,
                color: _selectedNutrients.isEmpty ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_selectedNutrients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children:
                    _selectedNutrients
                        .map((nutrient) => _buildSelectedNutrientCard(nutrient))
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedNutrientCard(NutrientModel nutrient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              border: Border.all(color: Colors.green[700]!, width: 2),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nutrient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            nutrient.type == 'A'
                                ? Colors.blue[100]
                                : Colors.orange[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Type ${nutrient.type}',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              nutrient.type == 'A'
                                  ? Colors.blue[800]
                                  : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  nutrient.formula,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${nutrient.pricePerKg.toStringAsFixed(0)}/kg',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeNutrient(nutrient),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosageCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dosis:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Volume (L):',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          controller: _volumeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          onChanged: (value) => _onInputChanged(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konsentrasi:',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          controller: _concentrationController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          onChanged: (value) => _onInputChanged(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientComparisonCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perbandingan Nutrisi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Elemen',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Target PPM',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Result PPM',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Nutrient rows
            ..._buildNutrientRows(),

            // Total row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Total PPM',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _getTotalTargetPPM().toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _getTotalResultPPM().toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // EC Estimate if available
            if (_ecEstimate > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EC Estimate:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${_ecEstimate.toStringAsFixed(2)} mS/cm',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _getCalculationPercentage() {
    if (_targetPPM.isEmpty || _resultPPM.isEmpty) return 0;

    double totalAccuracy = 0;
    int nutrientCount = 0;

    // Hitung akurasi untuk setiap nutrisi
    _targetPPM.forEach((nutrient, targetValue) {
      if (targetValue > 0) {
        // Hanya hitung nutrisi yang ada targetnya
        double resultValue = _resultPPM[nutrient] ?? 0.0;
        double accuracy = _calculateNutrientAccuracy(targetValue, resultValue);

        totalAccuracy += accuracy;
        nutrientCount++;

        // Debug print untuk melihat perhitungan
        print(
          '$nutrient - Target: $targetValue, Result: $resultValue, Accuracy: ${accuracy.toStringAsFixed(1)}%',
        );
      }
    });

    // Rata-rata akurasi dari semua nutrisi
    double averageAccuracy =
        nutrientCount > 0 ? totalAccuracy / nutrientCount : 0;

    print('Average Accuracy: ${averageAccuracy.toStringAsFixed(1)}%');

    return averageAccuracy.round().clamp(0, 100);
  }

  // Method helper untuk menghitung akurasi per nutrisi
  double _calculateNutrientAccuracy(double target, double result) {
    if (target == 0) return 0.0;

    double percentage = (result / target) * 100;

    // Sistem penilaian berdasarkan range akurasi
    if (percentage >= 90 && percentage <= 110) {
      // Range ideal: 90-110% = akurasi tinggi (90-100%)
      return 100.0 -
          (percentage - 100).abs() * 1.0; // Maksimal 100%, minimal 90%
    } else if (percentage >= 80 && percentage <= 120) {
      // Range acceptable: 80-89% atau 111-120% = akurasi sedang (60-89%)
      if (percentage < 90) {
        return 60.0 + (percentage - 80) * 3.0; // 80%->60%, 89%->87%
      } else {
        return 60.0 + (120 - percentage) * 3.0; // 111%->87%, 120%->60%
      }
    } else if (percentage >= 60 && percentage <= 150) {
      // Range poor: 60-79% atau 121-150% = akurasi rendah (20-59%)
      if (percentage < 80) {
        return 20.0 + (percentage - 60) * 2.0; // 60%->20%, 79%->58%
      } else {
        return 20.0 + (150 - percentage) * 1.3; // 121%->58%, 150%->20%
      }
    } else {
      // Range very poor: <60% atau >150% = akurasi sangat rendah (0-19%)
      if (percentage < 60) {
        return percentage / 3.0; // Linear scale: 0%->0%, 59%->19.7%
      } else {
        return Math.max(
          0,
          20 - (percentage - 150) * 0.2,
        ); // >150% gets progressively worse
      }
    }
  }

  // Method tambahan untuk mendapatkan detail akurasi per nutrisi
  Map<String, double> _getNutrientAccuracyDetails() {
    Map<String, double> accuracyDetails = {};

    _targetPPM.forEach((nutrient, targetValue) {
      if (targetValue > 0) {
        double resultValue = _resultPPM[nutrient] ?? 0.0;
        double accuracy = _calculateNutrientAccuracy(targetValue, resultValue);
        accuracyDetails[nutrient] = accuracy;
      }
    });

    return accuracyDetails;
  }

  // Update method _buildNutrientRows() untuk menampilkan akurasi per nutrisi
  List<Widget> _buildNutrientRows() {
    final nutrients = [
      'Nitrogen',
      'Posphor',
      'Kalium',
      'Magnesium',
      'Calcium',
      'Sulfur',
      'Fe',
      'Mangan',
      'Zink',
      'Boron',
      'Cu',
      'Molibdenum',
    ];

    Map<String, double> accuracyDetails = _getNutrientAccuracyDetails();

    return nutrients.map((nutrient) {
      final targetValue = _targetPPM[nutrient] ?? 0.0;
      final resultValue = _resultPPM[nutrient] ?? 0.0;
      final accuracy = accuracyDetails[nutrient] ?? 0.0;

      // Warna berdasarkan akurasi
      Color rowColor = Colors.transparent;
      if (resultValue > 0) {
        if (accuracy >= 90) {
          rowColor = Colors.green[50]!;
        } else if (accuracy >= 70) {
          rowColor = Colors.yellow[50]!;
        } else if (accuracy >= 50) {
          rowColor = Colors.orange[50]!;
        } else {
          rowColor = Colors.red[50]!;
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: rowColor,
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(nutrient)),
            Expanded(
              child: Text(
                targetValue.toStringAsFixed(2),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                resultValue.toStringAsFixed(2),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: resultValue > 0 ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Button Mulai
              Expanded(
                flex: 2,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: _canCalculate() ? Colors.green : Colors.grey[400],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow:
                        _canCalculate()
                            ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : null,
                  ),
                  child: InkWell(
                    onTap: _canCalculate() ? _calculateNutrition : null,
                    borderRadius: BorderRadius.circular(30),
                    child: Center(
                      child:
                          _isCalculating
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Mulai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Button Hasil
              Expanded(
                flex: 2,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: _hasResults() ? Colors.orange : Colors.grey[400],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow:
                        _hasResults()
                            ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : null,
                  ),
                  child: InkWell(
                    onTap: _hasResults() ? _showResults : null,
                    borderRadius: BorderRadius.circular(30),
                    child: const Center(
                      child: Text(
                        'Hasil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Indicator persentase
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPercentageColor(),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${_getCalculationPercentage()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _getPercentageTextColor(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Helper methods untuk mendukung widget di atas
  Color _getPercentageColor() {
    final percentage = _getCalculationPercentage();
    if (percentage >= 80) return Colors.green[50]!;
    if (percentage >= 60) return Colors.orange[50]!;
    if (percentage > 0) return Colors.red[50]!;
    return Colors.grey[100]!;
  }

  Color _getPercentageTextColor() {
    final percentage = _getCalculationPercentage();
    if (percentage >= 80) return Colors.green[700]!;
    if (percentage >= 60) return Colors.orange[700]!;
    if (percentage > 0) return Colors.red[700]!;
    return Colors.grey[600]!;
  }

  // ========================================
  // API INTEGRATION METHODS
  // ========================================

  Future<void> _calculateNutrition() async {
    if (!_canCalculate()) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      final volumeLiters = double.parse(_volumeController.text);
      final concentrationFactor = double.parse(_concentrationController.text);

      // Call the real API
      final apiResponse = await CalculationApiService.calculateNutrition(
        recipe: _selectedRecipe!,
        fertilizers: _selectedNutrients,
        volumeLiters: volumeLiters,
        concentrationFactor: concentrationFactor,
      );

      if (apiResponse['success'] == true) {
        // Process successful response
        _processApiResponse(apiResponse['data']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perhitungan berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(CalculationApiService.formatErrorMessage(apiResponse));
      }
    } catch (e) {
      print('Calculation error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  void _processApiResponse(Map<String, dynamic> response) {
    setState(() {
      _apiResponse = response;

      print('Processing API Response: $response');

      // Check if response has the expected structure
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        print('API Response Data: $data');

        // Handle the actual API response structure with 'elements' array
        if (data['elements'] != null) {
          final elements = List<Map<String, dynamic>>.from(data['elements']);
          print('Elements from API: $elements');

          // Create a map to store result PPM values
          Map<String, double> tempResultPPM = {};

          // Process each element from the API response
          for (var element in elements) {
            final elementName = element['element'] as String?;
            final resultPpm = (element['result_ppm'] ?? 0.0).toDouble();

            print('Processing element: $elementName, PPM: $resultPpm');

            // Map API element names to our internal names
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

          _resultPPM = {
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

          print('Final Result PPM: $_resultPPM');
        }

        // Handle substances (fertilizer amounts)
        if (data['substances'] != null) {
          final substances = List<Map<String, dynamic>>.from(
            data['substances'],
          );

          _fertilizerAmounts =
              substances.map((substance) {
                return {
                  'fertilizer_id':
                      '', // API doesn't provide ID, use substance name
                  'fertilizer_name': substance['substance_name'] ?? 'Unknown',
                  'formula': substance['formula'] ?? '',
                  'grams': (substance['amount_g'] ?? 0.0).toDouble(),
                  'cost': (substance['preparation_cost'] ?? 0.0).toDouble(),
                  'units': substance['units'] ?? 'g',
                };
              }).toList();

          print('Fertilizer amounts: $_fertilizerAmounts');
        }

        // Calculate total cost from substances
        _totalCost = 0.0;
        if (data['substances'] != null) {
          final substances = List<Map<String, dynamic>>.from(
            data['substances'],
          );
          for (var substance in substances) {
            _totalCost += (substance['preparation_cost'] ?? 0.0).toDouble();
          }
        }

        // EC estimate - not provided by API, calculate approximate
        // _ecEstimate = _calculateApproximateEC();
      } else {
        print('API response structure not as expected: $response');

        // Fallback: try old structure for backward compatibility
        final data = response['data'] ?? response;

        if (data['result_ppm'] != null) {
          _resultPPM = {
            'Nitrogen':
                (data['result_ppm']['no3'] ?? 0.0) +
                (data['result_ppm']['nh4'] ?? 0.0),
            'Posphor': data['result_ppm']['p'] ?? 0.0,
            'Kalium': data['result_ppm']['k'] ?? 0.0,
            'Magnesium': data['result_ppm']['mg'] ?? 0.0,
            'Calcium': data['result_ppm']['ca'] ?? 0.0,
            'Sulfur': data['result_ppm']['s'] ?? 0.0,
            'Fe': data['result_ppm']['fe'] ?? 0.0,
            'Mangan': data['result_ppm']['mn'] ?? 0.0,
            'Zink': data['result_ppm']['zn'] ?? 0.0,
            'Boron': data['result_ppm']['b'] ?? 0.0,
            'Cu': data['result_ppm']['cu'] ?? 0.0,
            'Molibdenum': data['result_ppm']['mo'] ?? 0.0,
          };

          _fertilizerAmounts = List<Map<String, dynamic>>.from(
            data['fertilizer_amounts'] ?? [],
          );
          _totalCost = (data['total_cost'] ?? 0.0).toDouble();
          // _ecEstimate = (data['ec_estimate'] ?? 0.0).toDouble();
        }
      }
    });
  }

  // ========================================
  // UI HELPER METHODS
  // ========================================

  void _showRecipeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Program Pemupukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          recipeProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                itemCount: recipeProvider.recipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = recipeProvider.recipes[index];
                                  return ListTile(
                                    title: Text(recipe.name),
                                    subtitle: Text(recipe.type),
                                    trailing:
                                        _selectedRecipe?.id == recipe.id
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                            : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedRecipe = recipe;
                                        _updateTargetPPM();
                                        // Clear previous results when recipe changes
                                        _clearResults();
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _showNutrientSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return Consumer<NutrientProvider>(
                builder: (context, nutrientProvider, child) {
                  return SafeArea(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pilih Pupuk',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_selectedNutrients.length} dipilih',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child:
                                nutrientProvider.isLoading
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : ListView.builder(
                                      itemCount:
                                          nutrientProvider.nutrients.length,
                                      itemBuilder: (context, index) {
                                        final nutrient =
                                            nutrientProvider.nutrients[index];
                                        final isSelected = _selectedNutrients
                                            .any((n) => n.id == nutrient.id);

                                        return GestureDetector(
                                          onTap: () {
                                            // Update both main state and modal state
                                            setState(() {
                                              if (isSelected) {
                                                _selectedNutrients.removeWhere(
                                                  (n) => n.id == nutrient.id,
                                                );
                                              } else {
                                                _selectedNutrients.add(
                                                  nutrient,
                                                );
                                              }
                                              // Clear previous results when nutrients change
                                              _clearResults();
                                            });

                                            // Update modal UI immediately
                                            setModalState(() {});
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? Colors.green[50]
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? Colors.green
                                                        : Colors.grey[300]!,
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                // Custom radio button style
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        isSelected
                                                            ? Colors.green
                                                            : Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          isSelected
                                                              ? Colors.green
                                                              : Colors.grey,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child:
                                                      isSelected
                                                          ? const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 12,
                                                          )
                                                          : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            nutrient.name,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  isSelected
                                                                      ? Colors
                                                                          .green[800]
                                                                      : Colors
                                                                          .black87,
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  nutrient.type ==
                                                                          'A'
                                                                      ? Colors
                                                                          .blue[100]
                                                                      : Colors
                                                                          .orange[100],
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              'Type ${nutrient.type}',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    nutrient.type ==
                                                                            'A'
                                                                        ? Colors
                                                                            .blue[800]
                                                                        : Colors
                                                                            .orange[800],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        nutrient.formula,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Rp ${nutrient.pricePerKg.toStringAsFixed(0)}/kg',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Selesai (${_selectedNutrients.length} dipilih)',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  void _removeNutrient(NutrientModel nutrient) {
    setState(() {
      _selectedNutrients.removeWhere((n) => n.id == nutrient.id);
      // Clear previous results when nutrients change
      _clearResults();
    });
  }

  void _updateTargetPPM() {
    if (_selectedRecipe != null) {
      setState(() {
        _targetPPM = {
          'Nitrogen':
              _selectedRecipe!.nitrateNitrogen +
              _selectedRecipe!.ammoniumNitrogen,
          'Posphor': _selectedRecipe!.phosphorus,
          'Kalium': _selectedRecipe!.potassium,
          'Magnesium': _selectedRecipe!.magnesium,
          'Calcium': _selectedRecipe!.calcium,
          'Sulfur': _selectedRecipe!.sulfur,
          'Fe': _selectedRecipe!.iron,
          'Mangan': _selectedRecipe!.manganese,
          'Zink': _selectedRecipe!.zinc,
          'Boron': _selectedRecipe!.boron,
          'Cu': _selectedRecipe!.copper,
          'Molibdenum': _selectedRecipe!.molybdenum,
        };
      });
    }
  }

  void _onInputChanged() {
    // Clear previous results when input changes
    if (_hasResults()) {
      _clearResults();
    }
  }

  void _clearResults() {
    setState(() {
      _resultPPM.clear();
      _apiResponse = null;
      _fertilizerAmounts.clear();
      _totalCost = 0.0;
      _ecEstimate = 0.0;
    });
  }

  bool _canCalculate() {
    return _selectedRecipe != null &&
        _selectedNutrients.isNotEmpty &&
        _volumeController.text.isNotEmpty &&
        _concentrationController.text.isNotEmpty &&
        double.tryParse(_volumeController.text) != null &&
        double.tryParse(_concentrationController.text) != null;
  }

  bool _hasResults() {
    return _apiResponse != null && _resultPPM.isNotEmpty;
  }

  void _showResults() {
    if (!_hasResults()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Belum ada hasil perhitungan. Silakan klik "Mulai" terlebih dahulu.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to results page with complete API response data
    Navigator.pushNamed(
      context,
      '/home/nutrient/calculator/result',
      arguments: {
        'recipe': _selectedRecipe,
        'nutrients': _selectedNutrients,
        'volume': double.parse(_volumeController.text),
        'concentration': double.parse(_concentrationController.text),
        'target_ppm': _targetPPM,
        'result_ppm': _resultPPM,
        'fertilizer_amounts': _fertilizerAmounts,
        'total_cost': _totalCost,
        'ec_estimate': _ecEstimate,
        'api_response': _apiResponse,
      },
    );
  }

  double _getTotalTargetPPM() {
    return _targetPPM.values.fold(0.0, (sum, value) => sum + value);
  }

  double _getTotalResultPPM() {
    return _resultPPM.values.fold(0.0, (sum, value) => sum + value);
  }

  String _getStatusMessage() {
    if (_selectedRecipe == null) {
      return 'Silakan pilih resep pemupukan';
    } else if (_selectedNutrients.isEmpty) {
      return 'Silakan pilih pupuk yang akan digunakan';
    } else if (!_canCalculate()) {
      return 'Periksa input volume dan konsentrasi';
    } else if (_hasResults()) {
      return 'Perhitungan selesai! Klik "Hasil" untuk melihat detail';
    } else {
      return 'Siap untuk kalkulasi. Klik "Mulai" untuk menghitung';
    }
  }

  Color _getStatusColor() {
    if (_selectedRecipe == null ||
        _selectedNutrients.isEmpty ||
        !_canCalculate()) {
      return Colors.red;
    } else if (_hasResults()) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}
