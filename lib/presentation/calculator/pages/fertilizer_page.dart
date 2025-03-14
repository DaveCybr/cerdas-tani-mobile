import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/data/fertilizer_data.dart';
import 'package:fertilizer_calculator/presentation/calculator/models/fertilizer_model.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/fertilizer_detail_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/fertilizer_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/recipe_provider.dart';
import 'package:fertilizer_calculator/presentation/calculator/widgets/fertilizer_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FertilizerPage extends StatefulWidget {
  const FertilizerPage({super.key});

  @override
  State<FertilizerPage> createState() => _FertilizerPageState();
}

class _FertilizerPageState extends State<FertilizerPage> {
  bool isChecked = false;
  String? selectedValue; // Nilai default diatur ke null
  final List<String> recipeOptions = [
    'Indonesia',
    'Internasional',
  ];
  List<FertilizerModel> fertilizers = [];
  bool isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _loadFertilizers();
  }

  Future<void> _loadFertilizers() async {
    final db = FertilizerDatabase.instance;
    final data = await db.getAllFertilizers();
    setState(() {
      fertilizers = data;
    });
  }

  List<FertilizerModel> get filteredFertilizers {
    if (selectedValue == null || selectedValue!.isEmpty) {
      return []; // Tidak ada pupuk yang ditampilkan jika lokasi kosong
    } else if (selectedValue == 'Indonesia') {
      return fertilizers
          .where((fertilizer) => fertilizer.category == 'Indonesia')
          .toList();
    } else if (selectedValue == 'Internasional') {
      return fertilizers
          .where((fertilizer) => fertilizer.category == 'Internasional')
          .toList();
    } else {
      return []; // Tidak ada pupuk yang ditampilkan jika tidak ada kategori yang sesuai
    }
  }

  void _toggleFabVisibility() {
    setState(() {
      isFabVisible = !isFabVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final fertilizerProvider = Provider.of<FertilizerProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                if (scrollNotification.metrics.axis == Axis.vertical) {
                  if (scrollNotification.metrics.pixels > 0 && isFabVisible) {
                    setState(() {
                      isFabVisible = false;
                    });
                  } else if (scrollNotification.metrics.pixels <= 0 &&
                      !isFabVisible) {
                    setState(() {
                      isFabVisible = true;
                    });
                  }
                }
              }
              return false;
            },
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: 15,
                    right: 15,
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Temukan Pupuk Terbaik\ndi Sekitarmu',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.card
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pupuk Berasal : ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedValue,
                                  isExpanded: true,
                                  menuWidth: MediaQuery.of(context).size.width,
                                  hint: Text(
                                    'Pilih Lokasi',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : AppColors.card,
                                    ),
                                  ),
                                  dropdownColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.card
                                      : Colors.white,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.card,
                                  ),
                                  items: recipeOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedValue = newValue;
                                    });
                                  },
                                  selectedItemBuilder: (BuildContext context) {
                                    return recipeOptions
                                        .map<Widget>((String value) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          value,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SpaceHeight(15),
                      Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.card
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'Pilih Otomatis',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // tap untuk otomatis pilih pupuk menyesuaikan resep yang dipilih, agar pupuk yang dipilih, nutrisinya memenuhi dari keinginan resep
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isChecked = !isChecked;
                                });
                                if (isChecked) {
                                  fertilizerProvider.autoSelectFertilizers(
                                    filteredFertilizers,
                                    recipeProvider.selectedRecipeNutrients ??
                                        {},
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(9.0)),
                                  color: isChecked
                                      ? AppColors.darkgreen
                                      : Colors
                                          .grey, // Change color based on state
                                ),
                                child: Icon(
                                  isChecked
                                      ? Icons.check
                                      : null, // Show check icon if checked
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SpaceHeight(25),
                      filteredFertilizers.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredFertilizers.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 0.6,
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                              ),
                              itemBuilder: (context, index) => FertilizerCard(
                                data: filteredFertilizers[index],
                                detailFertilizer: () {
                                  // Navigate to another page to show fertilizer details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FertilizerDetailPage(
                                        fertilizer: filteredFertilizers[index],
                                        addPageValue: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Column(
                              children: [
                                Icon(
                                  Icons.warning, // Ikon lokasi
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Pupuk Tidak Tersedia',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                const SpaceHeight(20)
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: 16.0,
            right: isFabVisible ? 16.0 : -60.0,
            child: GestureDetector(
              onTap: _toggleFabVisibility,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: FloatingActionButton(
                  backgroundColor: AppColors.darkblue,
                  onPressed: () {
                    // Navigasi ke halaman FertilizerDetailPage dengan addPage = true
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FertilizerDetailPage(
                          fertilizer: FertilizerModel(
                            image: '',
                            name: '',
                            category: '',
                            price: 0,
                            weight: 0,
                            type: '',
                            macro: {
                              'N': 0,
                              'P': 0,
                              'K': 0,
                              'Ca': 0,
                              'Mg': 0,
                              'S': 0,
                            },
                            micro: {
                              'Fe': 0,
                              'Mn': 0,
                              'Zn': 0,
                              'Cu': 0,
                              'B': 0,
                              'Mo': 0,
                            },
                          ),
                          addPageValue: true,
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    color: AppColors.light,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
