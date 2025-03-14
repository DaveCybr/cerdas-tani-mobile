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
    // final calculateProvider = Provider.of<CalculateProvider>(context);

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

    return Flexible(
      flex: 3,
      child: Column(
        children: [
          // Bagian Akurasi
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.card
                  : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      titleTop,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 10.0,
                      percent: ((double.tryParse(calculateProvider
                                  .calculateResult['accuracy']
                                  .toString()) ??
                              0.0) /
                          100),
                      center: Text(
                        "${calculateProvider.calculateResult['accuracy'] ?? 0}%",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.green,
                      backgroundColor: Colors.grey[800]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Bagian Tes Pupuk
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.card
                  : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      titleBottom,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lingkaran Mulai
                  _buildCircleButton(
                    'Mulai',
                    AppColors.green,
                    () {
                      int liter =
                          int.tryParse(literController.text.trim()) ?? 0;
                      int konsentrasi =
                          int.tryParse(konsentrasiController.text.trim()) ?? 0;
                      // print(
                      //     "Selected Fertilizer ${fertilizerProvider.selectedFertilizers}");
                      // print(
                      //     "Selected Fertilizer Nutrient ${fertilizerProvider.selectedFertilizerNutrients}");
                      // print("Selected Recipe ${recipeProvider.selectedRecipe}");
                      // print(
                      //     "Selected Recipe Nutrient ${recipeProvider.selectedRecipeNutrients}");
                      // calculatorProvider.checkAccuracy(
                      //   recipeProvider.selectedRecipeNutrients,
                      //   fertilizerProvider.selectedFertilizerNutrients,
                      //   fertilizerProvider.selectedFertilizers,
                      //   recipeProvider.selectedRecipe ?? '',
                      //   liter,
                      //   konsentrasi,
                      // );
                      calculateProvider.consentration = konsentrasi;
                      calculateProvider.recipeName =
                          recipeProvider.selectedRecipe!;
                      calculateProvider
                          .fetchNutrientCalculation(
                        volume: liter,
                        targets: formatTargets(
                            recipeProvider.selectedRecipeNutrients!),
                        fertilizers: (fertilizerProvider.selectedFertilizers)
                            .map((fertilizer) => fertilizer.toMapRequest())
                            .toList(),
                      )
                          .then((result) {
                        onCalculate();
                        // print("Calculation Result: $result");
                        // Handle the result
                      }).catchError((error) {
                        // print("Error: $error");
                        // Handle the error
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Lingkaran Hasil
                  _buildCircleButton(
                    'Hasil',
                    Colors.orange,
                    () async {
                      print(calculateProvider.calculateResult);

                      // bool result = await calculatorProvider.checkResult();
                      if (calculateProvider.calculateResult.isNotEmpty ||
                          calculateProvider.isButtonStartClicked) {
                        context.push(
                          const ResultPage(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DoubleSectionHistory extends StatelessWidget {
  final String titleTop;
  final String titleBottom;
  const DoubleSectionHistory({
    super.key,
    required this.titleTop,
    required this.titleBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Column(
        children: [
          // Bagian Akurasi
          Container(
            height: 130,
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.card
                    : Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      titleTop,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 35,
                      lineWidth: 10.0,
                      percent: 0.773,
                      center: const Text(
                        "77,3%",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.green,
                      backgroundColor: Colors.grey[800]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Bagian Tes Pupuk
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.card
                    : Colors.white),
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keterangan:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Volume 100 liter',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'Konsentrasi 100 %',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
