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
      body: Container(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Center(
                child: Text(
                  'Kalkulator Nutrisi\nHidroponik',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Tambahan opsional
                ),
              ),
              const SpaceHeight(15),
              const Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    color: Colors.grey,
                  ),
                  Text(
                    ' Komposisi dan Dosis Pupuk Nutrisi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              Container(
                height: 165,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.card
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              context.push(const RecipePage());
                            },
                            child: Container(
                              width: 60, // Lebar lingkaran
                              height: 60, // Tinggi lingkaran
                              decoration: BoxDecoration(
                                shape:
                                    BoxShape.circle, // Membuat bentuk lingkaran
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.card
                                    : Colors.white,
                                border: const Border.fromBorderSide(
                                  BorderSide(width: 4, color: Colors.green),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Resep', // Teks di dalam lingkaran
                                  style: TextStyle(
                                    fontSize: 15, // Ukuran font
                                    fontWeight:
                                        FontWeight.bold, // Ketebalan font
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SpaceHeight(15),
                          InkWell(
                            onTap: () {
                              context.push(const FertilizerPage());
                            },
                            child: Container(
                              width: 60, // Lebar lingkaran
                              height: 60, // Tinggi lingkaran
                              decoration: BoxDecoration(
                                shape:
                                    BoxShape.circle, // Membuat bentuk lingkaran
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.card
                                    : Colors.white,
                                border: const Border.fromBorderSide(
                                  BorderSide(width: 4, color: Colors.red),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Pupuk', // Teks di dalam lingkaran
                                  style: TextStyle(
                                    fontSize: 15, // Ukuran font
                                    fontWeight:
                                        FontWeight.bold, // Ketebalan font
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SpaceWidth(20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section: Keterangan
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Keterangan:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Consumer<RecipeProvider>(
                                builder: (context, recipeProvider, child) {
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.5, // Atur lebar maksimal
                                    child: Text(
                                      recipeProvider.selectedRecipe != null
                                          ? 'Resep: ${recipeProvider.selectedRecipe}'
                                          : 'Resep belum dipilih.',
                                      style: TextStyle(
                                        color: recipeProvider.selectedRecipe !=
                                                null
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                },
                              ),
                              Consumer<FertilizerProvider>(
                                builder: (context, fertilizerProvider, child) {
                                  String message = fertilizerProvider
                                          .selectedFertilizers.isNotEmpty
                                      ? 'Pupuk: ${fertilizerProvider.selectedFertilizers.map((fertilizer) => fertilizer.name).join(', ')}'
                                      : 'Belum memilih pupuk';

                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      message,
                                      style: TextStyle(
                                        color: fertilizerProvider
                                                .selectedFertilizers.isNotEmpty
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SpaceHeight(2),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dosis:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SpaceHeight(2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Volume: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 25,
                                    child: TextField(
                                      controller: literController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly, // Hanya angka
                                        LengthLimitingTextInputFormatter(
                                            3), // Batas maksimal 3 karakter
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^(100|[1-9][0-9]?)$')),
                                      ],
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'liter',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Konsentrasi: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 25,
                                    child: TextField(
                                      controller: konsentrasiController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly, // Hanya angka
                                        LengthLimitingTextInputFormatter(
                                            3), // Batas maksimal 3 karakter
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^(100|[1-9][0-9]?)$')),
                                      ],
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SingleSection<RecipeProvider>(
                    title: 'Resep yang diinginkan',
                    getProviderData: (context) {
                      final recipeProvider =
                          Provider.of<RecipeProvider>(context);
                      return recipeProvider.selectedRecipeNutrients ?? {};
                    },
                  ),
                  const SizedBox(width: 10),
                  SingleSection<FertilizerProvider>(
                    title: 'Pupuk yang digunakan',
                    getProviderData: (context) {
                      final calculateProvider =
                          Provider.of<CalculateProvider>(context, listen: true);

                      // print(calculateProvider.calculateResult);

                      // final fertilizerProvider =
                      // Provider.of<FertilizerProvider>(context);
                      return calculateProvider.calculateResult;
                    },
                  ),
                  const SizedBox(width: 10),
                  DoubleSectionTes(
                    titleTop: 'Akurasi',
                    titleBottom: 'Tes Pupuk',
                    literController: literController,
                    konsentrasiController: konsentrasiController,
                    onCalculate: () {
                      setState(() {});
                    },
                  )
                ],
              ),
              Consumer<CalculateProvider>(
                builder: (context, provider, child) {
                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.card
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        provider
                            .statusText, // Use the provider's statusText here
                        style: const TextStyle(
                          fontSize: 15, // Ukuran font
                          fontWeight: FontWeight.bold, // Ketebalan font
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
