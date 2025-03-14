import 'dart:convert';
import 'dart:io';

import 'package:fertilizer_calculator/data/fertilizer_data.dart';
import 'package:fertilizer_calculator/presentation/calculator/models/fertilizer_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FertilizerProvider with ChangeNotifier {
  List<FertilizerModel> selectedFertilizers = [];
  Map<String, bool> fertilizerCheckboxStatus =
      {}; // Untuk menyimpan status checkbox
  Map<String, Map<String, dynamic>> totalNutrients = {
    'macro': {},
    'micro': {},
  };

  // Menambahkan fertilizer dan memperbarui total nutrisi
  void addFertilizerCheck(FertilizerModel fertilizer) {
    selectedFertilizers.add(fertilizer);
    fertilizerCheckboxStatus[fertilizer.name] = true;

    // Menambahkan nutrisi macro dengan pembulatan
    fertilizer.macro.forEach((key, value) {
      totalNutrients['macro']![key] =
          ((totalNutrients['macro']![key] ?? 0) + value)
              .clamp(0.0, double.infinity);
      totalNutrients['macro']![key] =
          (totalNutrients['macro']![key]! * 1000).round() / 1000.0;
    });

    // Menambahkan nutrisi micro dengan pembulatan
    fertilizer.micro.forEach((key, value) {
      totalNutrients['micro']![key] =
          ((totalNutrients['micro']![key] ?? 0) + value)
              .clamp(0.0, double.infinity);
      totalNutrients['micro']![key] =
          (totalNutrients['micro']![key]! * 1000).round() / 1000.0;
    });

    // Mengupdate nilai nutrisi menjadi 0 jika ada yang 0.0
    totalNutrients['macro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);
    totalNutrients['micro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);

    notifyListeners();
  }

  // Menghapus fertilizer dan mengurangi total nutrisi
  void removeFertilizerCheck(FertilizerModel fertilizer) {
    // Hapus pupuk dari selectedFertilizers
    selectedFertilizers.removeWhere((item) => item.name == fertilizer.name);

    // Hapus status checkbox dari fertilizerCheckboxStatus
    fertilizerCheckboxStatus.remove(fertilizer.name);

    // Mengurangi nutrisi macro dan micro dengan pembulatan
    fertilizer.macro.forEach((key, value) {
      if (totalNutrients['macro']!.containsKey(key)) {
        // Mengurangi nilai, membulatkan ke tiga angka desimal, dan memastikan tidak negatif
        totalNutrients['macro']![key] = (totalNutrients['macro']![key]! - value)
            .clamp(0.0, double.infinity);
        totalNutrients['macro']![key] =
            (totalNutrients['macro']![key]! * 1000).round() / 1000.0;
      }
    });

    fertilizer.micro.forEach((key, value) {
      if (totalNutrients['micro']!.containsKey(key)) {
        // Mengurangi nilai, membulatkan ke tiga angka desimal, dan memastikan tidak negatif
        totalNutrients['micro']![key] = (totalNutrients['micro']![key]! - value)
            .clamp(0.0, double.infinity);
        totalNutrients['micro']![key] =
            (totalNutrients['micro']![key]! * 1000).round() / 1000.0;
      }
    });

    // Mengupdate nilai nutrisi menjadi 0 jika ada yang 0.0
    totalNutrients['macro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);
    totalNutrients['micro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);

    // Periksa apakah semua nilai di totalNutrients adalah 0
    bool allZero = totalNutrients.values.every(
        (nutrientMap) => nutrientMap.values.every((value) => value == 0));

    if (allZero) {
      // Set semua nilai di totalNutrients menjadi 0 tanpa koma
      totalNutrients['macro'] =
          totalNutrients['macro']!.map((key, _) => MapEntry(key, 0));
      totalNutrients['micro'] =
          totalNutrients['micro']!.map((key, _) => MapEntry(key, 0));
    }

    // Update UI
    notifyListeners();
  }

  // Mendapatkan total nutrisi yang terakumulasi
  Map<String, Map<String, dynamic>> get selectedFertilizerNutrients {
    return totalNutrients;
  }

  // Memeriksa apakah fertilizer telah dipilih
  bool isFertilizerChecked(String name) {
    return fertilizerCheckboxStatus[name] ?? false;
  }

  void autoSelectFertilizers(
      List<FertilizerModel> fertilizers, Map<String, dynamic> targetNutrients) {
    selectedFertilizers.clear();
    fertilizerCheckboxStatus.clear();
    totalNutrients['macro']?.clear();
    totalNutrients['micro']?.clear();

    // Algoritma pencarian kombinasi sederhana
    for (var fertilizer in fertilizers) {
      bool meetsTarget = true;

      fertilizer.macro.forEach((key, value) {
        double currentTotal = (totalNutrients['macro']?[key] ?? 0.0) +
            (value is String
                ? double.tryParse(value) ?? 0.0
                : value.toDouble());

        // Cek apakah total melebihi target
        // if (currentTotal >
        //     (targetNutrients['macro']?[key] is String
        //         ? double.tryParse(targetNutrients['macro']?[key]) ??
        //             double.infinity
        //         : targetNutrients['macro']?[key]?.toDouble() ??
        //             double.infinity)) {
        //   meetsTarget = false;
        // }
      });

      fertilizer.micro.forEach((key, value) {
        double currentTotal = (totalNutrients['micro']?[key] ?? 0.0) +
            (value is String
                ? double.tryParse(value) ?? 0.0
                : value.toDouble());

        // Cek apakah total melebihi target
        // if (currentTotal >
        //     (targetNutrients['micro']?[key] is String
        //         ? double.tryParse(targetNutrients['micro']?[key]) ??
        //             double.infinity
        //         : targetNutrients['micro']?[key]?.toDouble() ??
        //             double.infinity)) {
        //   meetsTarget = false;
        // }
      });

      // Hanya tambahkan pupuk jika memenuhi target
      if (meetsTarget && !selectedFertilizers.contains(fertilizer)) {
        addFertilizerCheck(fertilizer);
      }
    }
    notifyListeners();
  }

  Future<String> saveImageToAppDir(String? imagePath) async {
    if (imagePath == null || imagePath.startsWith('assets/')) {
      return imagePath ??
          ''; // Jika null atau dari assets, tetap pakai yang ada
    }

    final appDir = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory('${appDir.path}/images');

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    final file = File(imagePath);
    if (await file.exists()) {
      final newImagePath =
          '${imageDirectory.path}/${file.uri.pathSegments.last}';
      await file.copy(newImagePath);
      return newImagePath;
    } else {
      print('File tidak ditemukan: $imagePath');
      return imagePath; // Jika file tidak ada, tetap pakai path asli
    }
  }

  Future<void> updateFertilizer(
    String oldName,
    String newName,
    String? newImagePath, // Bisa null jika user tidak mengubah gambar
    String category,
    int weight,
    String type,
    Map<String, dynamic> macro,
    Map<String, dynamic> micro,
  ) async {
    try {
      final db = await FertilizerDatabase.instance.database;
      final fertilizer = await db.query(
        'fertilizers',
        where: 'name = ?',
        whereArgs: [oldName],
      );

      if (fertilizer.isNotEmpty) {
        int fertilizerId = fertilizer.first['id'] as int;
        print('fertilizerId: $fertilizerId');

        Object? currentImagePath = fertilizer.first['image'];
        final imagePathToSave = newImagePath != null
            ? await saveImageToAppDir(newImagePath)
            : currentImagePath; // Pakai gambar lama jika tidak ada perubahan

        await db.update(
          'fertilizers',
          {
            'name': newName,
            'image': imagePathToSave,
            'category': category,
            // 'price': price,
            'weight': weight,
            'type': type,
            'macro': jsonEncode(macro),
            'micro': jsonEncode(micro),
          },
          where: 'id = ?',
          whereArgs: [fertilizerId],
        );
        print('Fertilizer updated: $newName with ID: $fertilizerId');
      }
    } catch (e) {
      print('Error updating fertilizer: $e');
    }
  }

  Future<void> addFertilizer(
    String? imagePath, // Bisa null jika user tidak memilih gambar
    String name,
    String category,
    int weight,
    String type,
    Map<String, dynamic> macro,
    Map<String, dynamic> micro,
  ) async {
    try {
      final imagePathToSave = await saveImageToAppDir(imagePath);

      final db = await FertilizerDatabase.instance.database;
      await db.insert('fertilizers', {
        'image': imagePathToSave,
        'name': name,
        'category': category,
        'price': 0,
        'weight': weight,
        'type': type,
        'macro': jsonEncode(macro),
        'micro': jsonEncode(micro),
      });
      print('Fertilizer added: $name');
    } catch (e) {
      print('Error adding fertilizer: $e');
    }
  }

  Future<void> deleteFertilizerByName(String name) async {
    try {
      final db = await FertilizerDatabase.instance.database;

      // Get the fertilizer details by name
      final fertilizer = await db.query(
        'fertilizers',
        where: 'name = ?',
        whereArgs: [name],
      );

      if (fertilizer.isNotEmpty) {
        // Get the fertilizer ID and image path
        int fertilizerId = fertilizer.first['id'] as int;
        final imagePath = fertilizer.first['image'] as String;

        // Delete the image file if it exists
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }

        // Delete the fertilizer from the database
        await db.delete(
          'fertilizers',
          where: 'id = ?',
          whereArgs: [fertilizerId],
        );

        print('Fertilizer deleted with name: $name');
      } else {
        print('Fertilizer not found with name: $name');
      }
    } catch (e) {
      print('Error deleting fertilizer from database: $e');
    }
  }
}
