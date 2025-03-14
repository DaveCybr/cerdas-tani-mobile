import 'dart:io';

import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/calculator/models/fertilizer_model.dart';
import 'package:fertilizer_calculator/presentation/calculator/pages/fertilizer_page.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/fertilizer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FertilizerDetailPage extends StatefulWidget {
  final FertilizerModel fertilizer;
  final bool addPageValue;

  const FertilizerDetailPage(
      {super.key, required this.fertilizer, required this.addPageValue});

  @override
  State<FertilizerDetailPage> createState() => _FertilizerDetailPageState();
}

class _FertilizerDetailPageState extends State<FertilizerDetailPage> {
  bool editPage = false;
  bool addPage = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final Map<String, TextEditingController> macroControllers = {};
  final Map<String, TextEditingController> microControllers = {};
  late String imagePath;

  @override
  void initState() {
    super.initState();
    addPage = widget.addPageValue;
    nameController.text = widget.fertilizer.name;
    categoryController.text = widget.fertilizer.category;
    weightController.text = 1.toString();
    typeController.text = widget.fertilizer.type;
    imageController.text = widget.fertilizer.image;
    imagePath = widget.fertilizer.image;
    originalImagePath = widget.fertilizer.image;
    widget.fertilizer.macro.forEach((key, value) {
      macroControllers[key] = TextEditingController(text: value.toString());
    });
    widget.fertilizer.micro.forEach((key, value) {
      microControllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    weightController.dispose();
    typeController.dispose();
    imageController.dispose();
    for (var controller in macroControllers.values) {
      controller.dispose();
    }
    for (var controller in microControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? originalImagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        imageController.text = pickedFile.path;
      });
    }
  }

  void showSnackBar(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _updateFertilizer(
      BuildContext context, FertilizerProvider fertilizerProvider) async {
    String oldName = widget.fertilizer.name;
    String newName = nameController.text;
    String image = imageController.text;
    String category = categoryController.text;
    int weight = 1;
    String type = typeController.text;
    Map<String, dynamic> macro = {
      for (var key in macroControllers.keys)
        key: double.tryParse(macroControllers[key]!.text) ?? 0
    };
    Map<String, dynamic> micro = {
      for (var key in microControllers.keys)
        key: double.tryParse(microControllers[key]!.text) ?? 0.0
    };

    if (newName.isEmpty) {
      showSnackBar(context, 'Nama pupuk tidak boleh kosong!', false);
      return;
    }
    if (category.isEmpty) {
      showSnackBar(context, 'Kategori tidak boleh kosong!', false);
      return;
    }
    if (weight == 0) {
      showSnackBar(context, 'Berat tidak boleh kosong!', false);
      return;
    }
    if (type.isEmpty) {
      showSnackBar(context, 'Tipe tidak boleh kosong!', false);
      return;
    }

    await fertilizerProvider.updateFertilizer(
      oldName,
      newName,
      image,
      category,
      weight,
      type,
      macro,
      micro,
    );
    showSnackBar(context, 'Pupuk berhasil diubah!', true);
    context.pushReplacement(const FertilizerPage());
  }

  Future<void> _addFertilizer(
      BuildContext context, FertilizerProvider fertilizerProvider) async {
    String image = imageController.text;
    String name = nameController.text;
    String category = categoryController.text;
    int weight = int.tryParse(weightController.text) ?? 0;
    String type = typeController.text;
    Map<String, dynamic> macro = {
      for (var key in macroControllers.keys)
        key: double.tryParse(macroControllers[key]!.text) ?? 0
    };
    Map<String, dynamic> micro = {
      for (var key in microControllers.keys)
        key: double.tryParse(microControllers[key]!.text) ?? 0.0
    };

    if (name.isEmpty) {
      showSnackBar(context, 'Nama pupuk tidak boleh kosong!', false);
      return;
    }
    if (category.isEmpty) {
      showSnackBar(context, 'Kategori tidak boleh kosong!', false);
      return;
    }
    if (weight == 0) {
      showSnackBar(context, 'Berat tidak boleh kosong!', false);
      return;
    }
    if (type.isEmpty) {
      showSnackBar(context, 'Tipe tidak boleh kosong!', false);
      return;
    }

    await fertilizerProvider.addFertilizer(
      image,
      name,
      category,
      weight,
      type,
      macro,
      micro,
    );
    showSnackBar(context, 'Pupuk berhasil ditambahkan!', true);

    context.pushReplacement(const FertilizerPage());
  }

  @override
  Widget build(BuildContext context) {
    final fertilizerProvider = Provider.of<FertilizerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fertilizer.name),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: (editPage || addPage) ? _pickImage : null,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.disabled.withOpacity(0.5),
                        ),
                        child: ClipOval(
                          child: imagePath.isNotEmpty
                              ? (imagePath.startsWith('assets/')
                                  ? Image.asset(imagePath, fit: BoxFit.cover)
                                  : Image(
                                      image: FileImage(File(imagePath)),
                                      fit: BoxFit.cover))
                              : (originalImagePath?.isNotEmpty ?? false)
                                  ? (originalImagePath!.startsWith('assets/')
                                      ? Image.asset(originalImagePath!,
                                          fit: BoxFit.cover)
                                      : Image(
                                          image: FileImage(
                                              File(originalImagePath!)),
                                          fit: BoxFit.cover))
                                  : const Icon(Icons.image_not_supported,
                                      size: 100, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  editPage || addPage
                      ? TextField(
                          controller: nameController,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Masukkan nama pupuk',
                            hintStyle: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: AppColors.disabled,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          widget.fertilizer.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.disabled, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Kategori', 'Tipe'].map((e) {
                            return Expanded(
                              child: Column(children: [
                                Text(
                                  e,
                                  style: const TextStyle(
                                    color: AppColors.disabled,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ]),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  editPage || addPage
                                      ? DropdownButton<String>(
                                          value: [
                                            'Indonesia',
                                            'Internasional'
                                          ].contains(categoryController.text)
                                              ? categoryController.text
                                              : null,
                                          items: ['Indonesia', 'Internasional']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              categoryController.text =
                                                  newValue!;
                                            });
                                          },
                                        )
                                      : Text(
                                          widget.fertilizer.category,
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                ],
                              ),
                            ),
                            // Expanded(
                            //   child: Column(
                            //     children: [
                            //       editPage || addPage
                            //           ? TextField(
                            //               controller: weightController,
                            //               decoration: null,
                            //               keyboardType: TextInputType.number,
                            //               style: const TextStyle(fontSize: 14),
                            //               textAlign: TextAlign.center,
                            //               inputFormatters: [
                            //                 FilteringTextInputFormatter
                            //                     .digitsOnly, // Hanya angka
                            //                 LengthLimitingTextInputFormatter(
                            //                     4), // Maksimal 4 digit (1000)
                            //                 FilteringTextInputFormatter.allow(
                            //                     RegExp(r'^(1000|[0-9]{1,3})$')),
                            //               ],
                            //             )
                            //           : Text(
                            //               widget.fertilizer.weight.toString(),
                            //               style: const TextStyle(fontSize: 14),
                            //               textAlign: TextAlign.center,
                            //             ),
                            //     ],
                            //   ),
                            // ),
                            Expanded(
                              child: Column(
                                children: [
                                  editPage || addPage
                                      ? DropdownButton<String>(
                                          value: ['A', 'B']
                                                  .contains(typeController.text)
                                              ? typeController.text
                                              : null,
                                          items: ['A', 'B'].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              typeController.text = newValue!;
                                            });
                                          },
                                        )
                                      : Text(
                                          widget.fertilizer.type,
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkblue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Nutrisi Macro',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                    children: widget.fertilizer.macro.keys.map((nutrient) {
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
                    children: widget.fertilizer.macro.keys.map((nutrient) {
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
                                  )
                                : Text(
                                    widget.fertilizer.macro[nutrient]
                                        .toString(),
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkgreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Nutrisi Micro',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                    children: widget.fertilizer.micro.keys.map((nutrient) {
                      return Expanded(
                        child: Column(
                          children: [
                            Text(
                              nutrient,
                              style: const TextStyle(
                                color: AppColors.lightgreen,
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
                    children: widget.fertilizer.micro.keys.map((nutrient) {
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
                                  )
                                : Text(
                                    widget.fertilizer.micro[nutrient]
                                        .toString(),
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!addPage)
                  Expanded(
                    child: editPage
                        ? Container(
                            height: 75,
                            margin: const EdgeInsets.only(
                                right: 8), // Memberikan spasi di kanan
                            decoration: BoxDecoration(
                              color: AppColors.light.withOpacity(0.9),
                              borderRadius:
                                  BorderRadius.circular(12), // Radius melingkar
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
                                  editPage = false;
                                  addPage = false;
                                  imagePath = originalImagePath!;
                                  imageController.text =
                                      originalImagePath ?? '';
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
                                      height: 8), // Spasi antara ikon dan teks
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
                              borderRadius:
                                  BorderRadius.circular(12), // Radius melingkar
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
                                      height: 8), // Spasi antara ikon dan teks
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
                // Tombol Hapus atau Simpan
                Expanded(
                  child: Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.light.withOpacity(0.9),
                      borderRadius:
                          BorderRadius.circular(12), // Radius melingkar
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.1), // Bayangan halus
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (editPage) {
                          _updateFertilizer(context, fertilizerProvider);
                        } else if (addPage) {
                          _addFertilizer(context, fertilizerProvider);
                        } else {
                          String fertilizerName = widget.fertilizer.name;
                          await fertilizerProvider
                              .deleteFertilizerByName(fertilizerName);
                          showSnackBar(
                              context, 'Pupuk berhasil dihapus!', true);
                          context.pushReplacement(const FertilizerPage());
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            editPage || addPage
                                ? Icons.check
                                : Icons.delete, // Ikon Hapus atau Simpan
                            size: 30,
                            color:
                                editPage || addPage ? Colors.green : Colors.red,
                          ),
                          const SizedBox(
                              height: 8), // Spasi antara ikon dan teks
                          Text(
                            editPage || addPage ? 'Simpan' : 'Hapus',
                            style: const TextStyle(
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
    );
  }
}
