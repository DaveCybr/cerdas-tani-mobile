import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DualSection<T1, T2> extends StatelessWidget {
  final String title;
  final Map<String, dynamic> Function(BuildContext context) getProviderData1;
  final Map<String, dynamic> Function(BuildContext context) getProviderData2;

  const DualSection({
    super.key,
    required this.title,
    required this.getProviderData1,
    required this.getProviderData2,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<T1, T2>(
      builder: (context, provider1, provider2, child) {
        final selectedNutrients1 = getProviderData1(context);
        final rawSelectedNutrients2 = getProviderData2(context);

        // Format ulang selectedNutrients2 agar sesuai dengan selectedNutrients1
        final selectedNutrients2 = {
          "macro": {
            "N": rawSelectedNutrients2["calculated_ppm"]?["no3"] ?? 0,
            "P": rawSelectedNutrients2["calculated_ppm"]?["p"] ?? 0,
            "K": rawSelectedNutrients2["calculated_ppm"]?["k"] ?? 0,
            "Ca": rawSelectedNutrients2["calculated_ppm"]?["ca"] ?? 0,
            "Mg": rawSelectedNutrients2["calculated_ppm"]?["mg"] ?? 0,
            "S": rawSelectedNutrients2["calculated_ppm"]?["s"] ?? 0,
          },
          "micro": {
            "Fe": rawSelectedNutrients2["calculated_ppm"]?["fe"] ?? 0,
            "Mn": rawSelectedNutrients2["calculated_ppm"]?["mn"] ?? 0,
            "Zn": rawSelectedNutrients2["calculated_ppm"]?["zn"] ?? 0,
            "B": rawSelectedNutrients2["calculated_ppm"]?["b"] ?? 0,
            "Cu": rawSelectedNutrients2["calculated_ppm"]?["cu"] ?? 0,
            "Mo": rawSelectedNutrients2["calculated_ppm"]?["mo"] ?? 0,
          }
        };

        const defaultMacroKeys = {
          "N": "Nitrogen",
          "P": "Posphor",
          "K": "Kalium",
          "Mg": "Magnesium",
          "Ca": "Calcium",
          "S": "Sulfur"
        };

        const defaultMicroKeys = {
          "Fe": "Fe",
          "Mn": "Mangan",
          "Zn": "Zink",
          "B": "Boron",
          "Cu": "Cu",
          "Mo": "Molibdenum"
        };

        Map<String, Map<String, dynamic>> mergedNutrients = {};

        final macroTarget =
            Map<String, dynamic>.from(selectedNutrients1['macro'] ?? {});
        final microTarget =
            Map<String, dynamic>.from(selectedNutrients1['micro'] ?? {});
        final macroResult =
            Map<String, dynamic>.from(selectedNutrients2['macro'] ?? {});
        final microResult =
            Map<String, dynamic>.from(selectedNutrients2['micro'] ?? {});

        for (var entry in defaultMacroKeys.entries) {
          mergedNutrients[entry.value] = {
            "target": macroTarget[entry.key] ?? 0,
            "result": macroResult[entry.key] ?? 0,
          };
        }

        for (var entry in defaultMicroKeys.entries) {
          mergedNutrients[entry.value] = {
            "target": microTarget[entry.key] ?? 0,
            "result": microResult[entry.key] ?? 0,
          };
        }

        double totalTargetPPM = mergedNutrients.values.fold(
            0.0,
            (sum, item) =>
                sum +
                (double.tryParse(item['target']?.toString() ?? '0') ?? 0.0));

        double totalResultPPM = mergedNutrients.values.fold(
            0.0,
            (sum, item) =>
                sum +
                (double.tryParse(item['result']?.toString() ?? '0') ?? 0.0));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(title,
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      "Elemen",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Target PPM",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Result PPM",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 350,
              child: ListView.builder(
                itemCount: mergedNutrients.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  String key = mergedNutrients.keys.elementAt(index);
                  final nutrientData = mergedNutrients[key] ?? {};

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            key,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            nutrientData['target']?.toString() ?? "0",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            nutrientData['result']?.toString() ?? "0",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // 🔥 Tambahkan baris total di bawah tabel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Warna latar belakang untuk total
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Total PPM",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        totalTargetPPM.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        totalResultPPM.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
