// ========================================
// NUTRIENT DETAILS DIALOG
// ========================================

import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../models/nutrient_model.dart';
import 'nutrient_form_dialog.dart';

class NutrientDetailsDialog extends StatelessWidget {
  final NutrientModel nutrient;

  const NutrientDetailsDialog({Key? key, required this.nutrient})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          nutrient.type,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nutrient.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              nutrient.formula,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSection(context, 'Basic Information', [
                      _buildInfoRow('Type', 'Type ${nutrient.type}'),
                      _buildInfoRow(
                        'Price',
                        '\Rp. ${nutrient.pricePerKg.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} per kg',
                      ),
                      _buildInfoRow(
                        'Nutrient Profile',
                        nutrient.nutrientProfile.isNotEmpty
                            ? nutrient.nutrientProfile
                            : 'No nutrients',
                      ),
                      _buildInfoRow(
                        'Total Nitrogen',
                        '${nutrient.totalNitrogen.toStringAsFixed(1)}%',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Macronutrients
                    _buildSection(context, 'Macronutrients (%)', [
                      _buildNutrientRow(
                        'Ammonium Nitrogen (NH₄-N)',
                        nutrient.nh4,
                      ),
                      _buildNutrientRow(
                        'Nitrate Nitrogen (NO₃-N)',
                        nutrient.no3,
                      ),
                      _buildNutrientRow('Phosphorus (P)', nutrient.p),
                      _buildNutrientRow('Potassium (K)', nutrient.k),
                      _buildNutrientRow('Calcium (Ca)', nutrient.ca),
                      _buildNutrientRow('Magnesium (Mg)', nutrient.mg),
                      _buildNutrientRow('Sulfur (S)', nutrient.s),
                    ]),

                    const SizedBox(height: 20),

                    // Micronutrients
                    _buildSection(context, 'Micronutrients (ppm)', [
                      _buildNutrientRow('Iron (Fe)', nutrient.fe),
                      _buildNutrientRow('Manganese (Mn)', nutrient.mn),
                      _buildNutrientRow('Zinc (Zn)', nutrient.zn),
                      _buildNutrientRow('Boron (B)', nutrient.b),
                      _buildNutrientRow('Copper (Cu)', nutrient.cu),
                      _buildNutrientRow('Molybdenum (Mo)', nutrient.mo),
                    ]),

                    const SizedBox(height: 20),

                    // Timestamps
                    _buildSection(context, 'Record Information', [
                      _buildInfoRow('Created', _formatDate(nutrient.createdAt)),
                      _buildInfoRow(
                        'Last Updated',
                        _formatDate(nutrient.updatedAt),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editNutrient(context);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, double value) {
    final hasValue = value > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            hasValue ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: hasValue ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: hasValue ? Colors.black87 : Colors.grey,
                fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            hasValue ? value.toStringAsFixed(1) : '0.0',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: hasValue ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editNutrient(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NutrientFormDialog(nutrient: nutrient),
    );
  }
}
