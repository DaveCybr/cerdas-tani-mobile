import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/fertilizer_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/recipe_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/calculate_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/fertilizer_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/recipe_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/widgets/double_section.dart';
import 'package:fertilizer_calculator/presentation/calculator/widgets/single_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // Dummy data pupuk
  final TextEditingController literController = TextEditingController();
  final TextEditingController konsentrasiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    literController.text = '100';
    konsentrasiController.text = '100';
  }

  @override
  void dispose() {
    literController.dispose();
    konsentrasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // 🔹 Tambahkan ini agar halaman bisa discroll
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Back & Judul
                const Row(
                  children: [
                    // IconButton(
                    //   onPressed: () => Navigator.pop(context),
                    //   icon: const Icon(Icons.arrow_back, color: Colors.black),
                    // ),
                    SizedBox(width: 8),
                    Text(
                      "Kalkulator Hara",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Nama tanaman
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Program Pemupukan",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Consumer<RecipeProvider>(
                              builder: (context, recipeProvider, child) {
                                return Text(
                                  recipeProvider.selectedRecipe ??
                                      'Resep belum dipilih!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: recipeProvider.selectedRecipe != null
                                        ? AppColors.primary
                                        : AppColors.Secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Potong teks dengan "..."
                                  maxLines: 1, // Batasi teks dalam 1 baris
                                  softWrap: true,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tombol "Ganti"
                      ElevatedButton(
                        onPressed: () {
                          context.push(const RecipePage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          "Ganti",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      // Nama tanaman & informasi pupuk
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pupuk atau unsur hara",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Consumer<FertilizerProvider>(
                              builder: (context, fertilizerProvider, child) {
                                String message = fertilizerProvider
                                        .selectedFertilizers.isNotEmpty
                                    ? fertilizerProvider.selectedFertilizers
                                        .map((fertilizer) => fertilizer.name)
                                        .join(', ')
                                    : 'Pupuk belum dipilih!';

                                return Text(
                                  message,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: fertilizerProvider
                                            .selectedFertilizers.isNotEmpty
                                        ? AppColors.primary
                                        : AppColors.Secondary,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Tambahkan elipsis jika teks terlalu panjang
                                  maxLines: 1, // Batasi teks hanya 1 baris
                                  softWrap: true,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Tombol "Ganti"
                      ElevatedButton(
                        onPressed: () {
                          context.push(const FertilizerPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          "Ganti",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Dosis Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dosis:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Input sejajar
                      Row(
                        children: [
                          // Volume Input
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Volume:',
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width:
                                      45, // Lebar dikurangi agar tidak overflow
                                  child: TextField(
                                    controller: literController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^(100|[1-9][0-9]?)$')),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('liter',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8), // Spacer antar input

                          // Konsentrasi Input
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Konsentrasi:',
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width:
                                      45, // Lebar dikurangi agar tidak overflow
                                  child: TextField(
                                    controller: konsentrasiController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^(100|[1-9][0-9]?)$')),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('%', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: DualSection<RecipeProvider, CalculateProvider>(
                    title: 'Perbandingan Nutrisi',
                    getProviderData1: (context) {
                      final recipeProvider =
                          Provider.of<RecipeProvider>(context);
                      return recipeProvider.selectedRecipeNutrients ?? {};
                    },
                    getProviderData2: (context) {
                      final calculateProvider =
                          Provider.of<CalculateProvider>(context);
                      return calculateProvider.calculateResult ?? {};
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: DoubleSectionTes(
                    titleTop: "Tes",
                    titleBottom: "Tes",
                    literController: literController,
                    konsentrasiController: konsentrasiController,
                    onCalculate: () {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Consumer<CalculateProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          provider
                              .statusText, // Use the provider's statusText here
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
