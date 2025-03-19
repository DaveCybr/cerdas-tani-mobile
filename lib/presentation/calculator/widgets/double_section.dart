import 'dart:math';

import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/result_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/calculate_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/fertilizer_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/recipe_provider.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class DoubleSectionTes extends StatelessWidget {
  final String titleTop;
  final String titleBottom;
  final TextEditingController literController;
  final TextEditingController konsentrasiController;
  final VoidCallback onCalculate;

  const DoubleSectionTes({
    super.key,
    required this.titleTop,
    required this.titleBottom,
    required this.literController,
    required this.konsentrasiController,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final calculateProvider =
        Provider.of<CalculateProvider>(context, listen: false);
    final fertilizerProvider =
        Provider.of<FertilizerProvider>(context, listen: false);

    Map<String, dynamic> formatTargets(Map<String, dynamic> targets) {
      return {
        'no3': targets['macro']['N'],
        'p': targets['macro']['P'],
        'k': targets['macro']['K'],
        'ca': targets['macro']['Ca'],
        'mg': targets['macro']['Mg'],
        's': targets['macro']['S'],
        'fe': targets['micro']['Fe'],
        'mn': targets['micro']['Mn'],
        'zn': targets['micro']['Zn'],
        'b': targets['micro']['B'],
        'cu': targets['micro']['Cu'],
        'mo': targets['micro']['Mo'],
      };
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Supaya Row menyesuaikan ukuran isinya
        mainAxisAlignment: MainAxisAlignment.center, // Posisikan ke tengah
        children: [
          // const SizedBox(width: 24), // Jarak antar komponen

          // Button Mulai
          const SizedBox(height: 8),
          _buildCircleButton("Mulai", AppColors.primary, () {
            int liter = int.tryParse(literController.text.trim()) ?? 0;
            int konsentrasi =
                int.tryParse(konsentrasiController.text.trim()) ?? 0;

            calculateProvider.consentration = konsentrasi;
            calculateProvider.recipeName = recipeProvider.selectedRecipe!;
            calculateProvider
                .fetchNutrientCalculation(
              volume: liter,
              targets: formatTargets(recipeProvider.selectedRecipeNutrients!),
              fertilizers: (fertilizerProvider.selectedFertilizers)
                  .map((fertilizer) => fertilizer.toMapRequest())
                  .toList(),
            )
                .then((result) {
              onCalculate();
            }).catchError((error) {
              log(error);
            });
          }),

          const SizedBox(width: 24),

          const SizedBox(height: 8),
          _buildCircleButton("Hasil", Colors.orange, () {
            if (calculateProvider.calculateResult.isNotEmpty ||
                calculateProvider.isButtonStartClicked) {
              context.push(
                const ResultPage(),
              );
            }
          }),
          const SizedBox(width: 24),
          // Accuracy Indicator

          CircularPercentIndicator(
            radius: 32,
            lineWidth: 8.0,
            percent: ((double.tryParse(calculateProvider
                        .calculateResult['accuracy']
                        .toString()) ??
                    0.0) /
                100),
            center: Text(
              "${calculateProvider.calculateResult['accuracy'] ?? 0}%",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            progressColor: AppColors.primary,
            backgroundColor: Colors.grey[300]!,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
