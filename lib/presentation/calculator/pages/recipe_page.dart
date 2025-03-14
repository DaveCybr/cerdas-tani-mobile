import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/recipe_provider.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  bool editPage = false;
  bool addPage = false;

  final TextEditingController nameController = TextEditingController();
  final Map<String, TextEditingController> macroControllers = {
    'N': TextEditingController(),
    'P': TextEditingController(),
    'K': TextEditingController(),
    'Mg': TextEditingController(),
    'Ca': TextEditingController(),
    'S': TextEditingController(),
  };
  final Map<String, TextEditingController> microControllers = {
    'Fe': TextEditingController(),
    'Mn': TextEditingController(),
    'Zn': TextEditingController(),
    'B': TextEditingController(),
    'Cu': TextEditingController(),
    'Mo': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.loadRecipes();
  }

  void showSnackBar(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _addRecipe(
      BuildContext context, RecipeProvider recipeProvider) async {
    String name = nameController.text.trim();
    Map<String, dynamic> macro = {
      for (var key in macroControllers.keys)
        key: int.tryParse(macroControllers[key]!.text) ?? 0
    };
    Map<String, dynamic> micro = {
      for (var key in microControllers.keys)
        key: double.tryParse(microControllers[key]!.text) ?? 0.0
    };

    // Validasi input tidak boleh kosong
    if (name.isEmpty) {
      showSnackBar(context, 'Nama resep tidak boleh kosong!', false);
      return;
    }
    if (macro.values.every((value) => value == 0) &&
        micro.values.every((value) => value == 0)) {
      showSnackBar(context, 'Minimal satu nutrisi harus diisi!', false);
      return;
    }

    // Jika valid, tambahkan data
    await recipeProvider.addRecipe(name, macro, micro);
    showSnackBar(context, 'Resep berhasil ditambahkan!', true);

    // Tutup form tambah
    setState(() {
      addPage = false;
    });
  }

  Future<void> _deleteRecipe(
      BuildContext context, RecipeProvider recipeProvider) async {
    try {
      await recipeProvider.deleteSelectedRecipe();
      setState(() {
        editPage = false;
      });
      showSnackBar(context, 'Resep berhasil dihapus!', true);
    } catch (e) {
      showSnackBar(context, 'Gagal menghapus resep: $e', false);
    }
  }

  Future<void> _updateRecipe(
      BuildContext context, RecipeProvider recipeProvider) async {
    String oldName = recipeProvider.selectedRecipe!;
    String newName = nameController.text;

    Map<String, dynamic> macro = {
      for (var key in macroControllers.keys)
        key: int.tryParse(macroControllers[key]!.text) ?? 0
    };
    Map<String, dynamic> micro = {
      for (var key in microControllers.keys)
        key: double.tryParse(microControllers[key]!.text) ?? 0.0
    };

    if (newName.isEmpty) {
      showSnackBar(context, 'Nama resep tidak boleh kosong', false);
      return;
    }

    try {
      await recipeProvider.updateRecipe(oldName, newName, macro, micro);
      setState(() {
        editPage = false;
      });
      showSnackBar(context, 'Resep berhasil diperbarui!', true);
    } catch (e) {
      showSnackBar(context, 'Gagal mengupdate resep: $e', false);
    }
  }

  void _populateControllers(RecipeProvider recipeProvider) {
    if (recipeProvider.selectedRecipe != null) {
      nameController.text = recipeProvider.selectedRecipe!;
      final nutrients = recipeProvider.selectedRecipeNutrients;
      if (nutrients != null) {
        nutrients['macro'].forEach((key, value) {
          macroControllers[key]?.text = value.toString();
        });
        nutrients['micro'].forEach((key, value) {
          microControllers[key]?.text = value.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    if (editPage) {
      _populateControllers(recipeProvider);
    }
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.01,
              left: 15,
              right: 15,
            ),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Resep Nutrisi\npada Hidroponik',
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
                        'Nama Resep : ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: addPage || editPage
                            ? TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Masukkan Nama Resep',
                                  border: InputBorder.none,
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: recipeProvider.selectedRecipe,
                                  isExpanded: true,
                                  menuMaxHeight:
                                      MediaQuery.of(context).size.height - 250,
                                  menuWidth: MediaQuery.of(context).size.width,
                                  hint: Text(
                                    'Pilih Nama Resep',
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
                                  items: recipeProvider.recipes.keys
                                      .map((String recipeName) {
                                    return DropdownMenuItem<String>(
                                      value: recipeName,
                                      child: Text(
                                        recipeName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: editPage
                                      ? null // Menonaktifkan dropdown jika editPage adalah true
                                      : (String? newValue) {
                                          if (newValue != null) {
                                            recipeProvider
                                                .selectRecipe(newValue);
                                          }
                                        },
                                  selectedItemBuilder: (BuildContext context) {
                                    return recipeProvider.recipes.keys
                                        .map((String recipeName) {
                                      return DropdownMenuItem<String>(
                                        value: recipeName,
                                        child: Text(
                                          recipeName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                      ),
                      if (!(editPage || addPage))
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              addPage = true;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.add,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SpaceHeight(10),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkblue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Nutrisi Makro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SpaceHeight(5),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightblue, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            ['N', 'P', 'K', 'Mg', 'Ca', 'S'].map((nutrient) {
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  nutrient,
                                  style: const TextStyle(
                                    color: AppColors.lightblue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            ['N', 'P', 'K', 'Mg', 'Ca', 'S'].map((nutrient) {
                          final value =
                              recipeProvider.selectedRecipeNutrients?['macro']
                                      ?[nutrient] ??
                                  0;
                          return Expanded(
                            child: Column(
                              children: [
                                editPage || addPage
                                    ? TextFormField(
                                        controller: macroControllers[nutrient],
                                        style: const TextStyle(fontSize: 14),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly, // Hanya angka
                                          LengthLimitingTextInputFormatter(
                                              4), // Maksimal 4 digit (1000)
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^(1000|[0-9]{1,3})$')),
                                        ],
                                      )
                                    : Text(value
                                        .toString()), // Jika tidak dalam mode edit/tambah
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SpaceHeight(10),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkgreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Nutrisi Mikro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SpaceHeight(5),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightgreen, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            ['Fe', 'Mn', 'Zn', 'B', 'Cu', 'Mo'].map((nutrient) {
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  nutrient,
                                  style: const TextStyle(
                                    color: AppColors.lightblue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            ['Fe', 'Mn', 'Zn', 'B', 'Cu', 'Mo'].map((nutrient) {
                          final value = recipeProvider
                                          .selectedRecipeNutrients !=
                                      null &&
                                  recipeProvider
                                          .selectedRecipeNutrients!['micro'] !=
                                      null
                              ? (recipeProvider
                                          .selectedRecipeNutrients!['micro']
                                      [nutrient] ??
                                  0)
                              : 0; // Default ke 0 jika tidak ada data
                          return Expanded(
                            child: Column(
                              children: [
                                editPage || addPage
                                    ? TextFormField(
                                        controller: microControllers[nutrient],
                                        style: const TextStyle(fontSize: 14),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly, // Hanya angka
                                          LengthLimitingTextInputFormatter(
                                              4), // Maksimal 4 digit (1000)
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^(1000|[0-9]{1,3})$')),
                                        ],
                                      )
                                    : Text(value
                                        .toString()), // Jika tidak dalam mode edit/tambah
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SpaceHeight(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: addPage || editPage
                          ? Container(
                              height: 75,
                              margin: const EdgeInsets.only(
                                  right: 8), // Memberikan spasi di kanan
                              decoration: BoxDecoration(
                                color: AppColors.light.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(
                                    12), // Radius melingkar
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Bayangan halus
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    addPage = false;
                                    editPage = false;
                                  });
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined, // Ikon Sunting
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Spasi antara ikon dan teks
                                    Text(
                                      'Batal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 75,
                              margin: const EdgeInsets.only(
                                  right: 8), // Memberikan spasi di kanan
                              decoration: BoxDecoration(
                                color: AppColors.light.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(
                                    12), // Radius melingkar
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Bayangan halus
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    editPage = true;
                                  });
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit, // Ikon Sunting
                                      size: 30,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Spasi antara ikon dan teks
                                    Text(
                                      'Sunting',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    // Tombol Hapus
                    Expanded(
                      child: addPage || editPage
                          ? Container(
                              height: 75,
                              margin: const EdgeInsets.only(
                                  left: 8), // Memberikan spasi di kiri
                              decoration: BoxDecoration(
                                color: AppColors.light.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(
                                    12), // Radius melingkar
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Bayangan halus
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (addPage) {
                                    _addRecipe(context, recipeProvider);
                                  } else if (editPage) {
                                    _updateRecipe(context, recipeProvider);
                                  }
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check, // Ikon Hapus
                                      size: 30,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Spasi antara ikon dan teks
                                    Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 75,
                              margin: const EdgeInsets.only(
                                  left: 8), // Memberikan spasi di kiri
                              decoration: BoxDecoration(
                                color: AppColors.light.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(
                                    12), // Radius melingkar
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(0.1), // Bayangan halus
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  _deleteRecipe(context, recipeProvider);
                                },
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete, // Ikon Hapus
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                        height:
                                            8), // Spasi antara ikon dan teks
                                    Text(
                                      'Hapus',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
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
}
