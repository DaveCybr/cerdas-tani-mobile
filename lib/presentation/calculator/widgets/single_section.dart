import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/calculator/widgets/table_striped.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SingleSection<T> extends StatelessWidget {
  final String title;
  final Map<String, dynamic> Function(BuildContext context) getProviderData;

  const SingleSection({
    super.key,
    required this.title,
    required this.getProviderData, // Fungsi untuk mendapatkan data dari provider
  });

  @override
  Widget build(BuildContext context) {
    // Function to update keys
    Map<String, dynamic> updateKeys(
        Map<String, dynamic> original, Map<String, dynamic> keyMapping) {
      Map<String, dynamic> updated = {};
      original.forEach((category, elements) {
        updated[category] = elements.map((key, value) =>
            MapEntry(keyMapping[key] ?? key.toString().toLowerCase(), value));
      });
      return updated;
    }

    Map<String, dynamic> keyMapping = {
      'N': 'no3',
      // Add more mappings if needed
    };
    Map<String, dynamic> reverseKeyMapping = {
      'no3': 'N',
      // Add more mappings if needed
    };

    return Flexible(
      flex: 3,
      child: Container(
        height: 360,
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.card
                : Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SpaceHeight(10),
              Consumer<T>(
                builder: (context, providerData, child) {
                  final selectedNutrients = getProviderData(context);

                  // print("$selectedNutrients");
                  // print(selectedNutrients[0].calculated_ppm);

                  // Default keys untuk macro dan micro
                  var defaultMacroKeys = ["no3", "P", "K", "Ca", "Mg", "S"]
                      .map((e) => e.toLowerCase());
                  var defaultMicroKeys = ["Fe", "Mn", "Zn", "B", "Cu", "Mo"]
                      .map((e) => e.toLowerCase());

                  Map<String, dynamic> nutrients;
                  // Ambil data macro dan micro dari selectedNutrients
                  final macro = Map<String, dynamic>.from(
                      selectedNutrients['macro'] ?? {});
                  final micro = Map<String, dynamic>.from(
                      selectedNutrients['micro'] ?? {});

                  // print("kanan");
                  // print("$");
                  dynamic formatNutrientValue(dynamic value) {
                    double numericValue;

                    // Check if the value is an int, convert to double
                    if (value is int) {
                      numericValue = value.toDouble();
                    } else if (value is double) {
                      numericValue = value;
                    } else if (value is String) {
                      // Try to parse the string to a double
                      numericValue = double.tryParse(value) ?? 0.0;
                    } else {
                      numericValue = 0.0;
                    }

                    // Round or format the value
                    double roundedValue =
                        double.parse(numericValue.toStringAsFixed(2));

                    // If the value is an integer, return it as an int
                    if (roundedValue == roundedValue.roundToDouble()) {
                      return roundedValue.round();
                    } else {
                      return roundedValue;
                    }
                  }

                  if (selectedNutrients['calculated_ppm'] != null) {
                    nutrients = Map<String, dynamic>.from(
                            selectedNutrients['calculated_ppm'])
                        .map((key, value) =>
                            MapEntry(key, formatNutrientValue(value)));

                    if (nutrients.isEmpty) {
                      nutrients = {
                        for (var key in defaultMacroKeys) key: 0,
                        for (var key in defaultMicroKeys) key: 0,
                      };
                    }
                  } else {
                    Map<String, dynamic> updatedNutrients =
                        updateKeys(selectedNutrients, keyMapping);
                    // print("kiri");
                    if (updatedNutrients.isEmpty) {
                      nutrients = {
                        for (var key in defaultMacroKeys) key: 0,
                        for (var key in defaultMicroKeys) key: 0,
                      };
                    } else {
                      nutrients = {
                        for (var key in defaultMacroKeys)
                          key: formatNutrientValue(
                              updatedNutrients['macro'][key] ?? 0.0),
                        for (var key in defaultMicroKeys)
                          key: formatNutrientValue(
                              updatedNutrients['micro'][key] ?? 0.0),
                      };
                    }
                  }
                  int tempVal = nutrients.remove('no3')!;

                  nutrients = {
                    'n': tempVal,
                    ...nutrients,
                  };
                  // print(updateKeys(nutrients, reverseKg));
                  return TableStriped(nutrients: nutrients);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
