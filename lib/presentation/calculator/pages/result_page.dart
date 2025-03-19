import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/calculate_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    final calculatorProvider = Provider.of<CalculateProvider>(context);
    final requiredFertilizers = List<Map<String, dynamic>>.from(
        calculatorProvider.calculateResult['required_fertilizers'] ?? []);

    final totalWeight =
        calculatorProvider.calculateTotalWeight(requiredFertilizers);

    final weightPerType =
        calculatorProvider.calculateWeightPerType(requiredFertilizers);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hasil Perhitungan',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
          left: 15,
          right: 15,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Resep
              Center(
                child: Text(
                  calculatorProvider.recipeName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),

              // Informasi Volume dan Konsentrasi
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.card
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Volume : ${calculatorProvider.volumeInLiter} Liter',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Konsentrasi : ${calculatorProvider.consentration}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceHeight(20),

              // Tabel Hasil Pupuk
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.card
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Table(
                  border: TableBorder.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.card,
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      children: [
                        _buildTableCell('Pupuk', Colors.white),
                        _buildTableCell('Tipe', Colors.white),
                        _buildTableCell('Berat\n(grams)', Colors.white),
                      ],
                    ),

                    // Data Rows
                    ...calculatorProvider
                        .calculateResult['required_fertilizers']
                        .map(
                          (fertilizer) => TableRow(
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.card
                                  : Colors.white,
                            ),
                            children: [
                              _buildTableCell(fertilizer['Fertilizer']),
                              _buildTableCell(fertilizer['Type'].toString()),
                              _buildTableCell(
                                  fertilizer['Weight (grams)'].toString()),
                            ],
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
              const SpaceHeight(20),

              // Catatan Tambahan
              Container(
                padding: const EdgeInsets.all(12),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.card
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '- Total berat pupuk = ${totalWeight} grams',
                      style: const TextStyle(fontSize: 14),
                    ),
                    ...weightPerType.entries.map((entry) {
                      return Text(
                        '- Berat pupuk tipe ${entry.key} = ${entry.value.toStringAsFixed(2)} grams',
                        style: const TextStyle(fontSize: 14),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SpaceHeight(20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function untuk membuat cell tabel
  Widget _buildTableCell(String text, [Color? textColor]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? AppColors.dark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
