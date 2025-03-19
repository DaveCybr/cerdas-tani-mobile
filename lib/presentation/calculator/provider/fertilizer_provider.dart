import 'dart:convert';
import 'dart:io';
import 'package:fertilizer_calculator/data/fertilizer_data.dart';
import 'package:fertilizer_calculator/presentation/calculator/models/fertilizer_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FertilizerProvider with ChangeNotifier {
  String? _selectedValue; // Variabel untuk menyimpan selectedValue

  String? get selectedValue => _selectedValue;

  void setSelectedValue(String? value) {
    _selectedValue = value;
    notifyListeners();
  }

  List<FertilizerModel> selectedFertilizers = [];
  Map<String, bool> fertilizerCheckboxStatus = {};
  Map<String, Map<String, dynamic>> totalNutrients = {
    'macro': {},
    'micro': {},
  };

  void addFertilizerCheck(FertilizerModel fertilizer) {
    selectedFertilizers.add(fertilizer);
    fertilizerCheckboxStatus[fertilizer.name] = true;

    fertilizer.macro.forEach((key, value) {
      totalNutrients['macro']![key] =
          ((totalNutrients['macro']![key] ?? 0) + value)
              .clamp(0.0, double.infinity);
      totalNutrients['macro']![key] =
          (totalNutrients['macro']![key]! * 1000).round() / 1000.0;
    });

    fertilizer.micro.forEach((key, value) {
      totalNutrients['micro']![key] =
          ((totalNutrients['micro']![key] ?? 0) + value)
              .clamp(0.0, double.infinity);
      totalNutrients['micro']![key] =
          (totalNutrients['micro']![key]! * 1000).round() / 1000.0;
    });

    totalNutrients['macro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);
    totalNutrients['micro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);

    notifyListeners();
  }

  void removeFertilizerCheck(FertilizerModel fertilizer) {
    selectedFertilizers.removeWhere((item) => item.name == fertilizer.name);
    fertilizerCheckboxStatus.remove(fertilizer.name);

    fertilizer.macro.forEach((key, value) {
      if (totalNutrients['macro']!.containsKey(key)) {
        totalNutrients['macro']![key] = (totalNutrients['macro']![key]! - value)
            .clamp(0.0, double.infinity);
        totalNutrients['macro']![key] =
            (totalNutrients['macro']![key]! * 1000).round() / 1000.0;
      }
    });

    fertilizer.micro.forEach((key, value) {
      if (totalNutrients['micro']!.containsKey(key)) {
        totalNutrients['micro']![key] = (totalNutrients['micro']![key]! - value)
            .clamp(0.0, double.infinity);
        totalNutrients['micro']![key] =
            (totalNutrients['micro']![key]! * 1000).round() / 1000.0;
      }
    });

    totalNutrients['macro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);
    totalNutrients['micro']
        ?.updateAll((key, value) => value == 0.0 ? 0 : value);

    bool allZero = totalNutrients.values.every(
        (nutrientMap) => nutrientMap.values.every((value) => value == 0));
    if (allZero) {
      totalNutrients['macro'] =
          totalNutrients['macro']!.map((key, _) => MapEntry(key, 0));
      totalNutrients['micro'] =
          totalNutrients['micro']!.map((key, _) => MapEntry(key, 0));
    }

    notifyListeners();
  }

  Map<String, Map<String, dynamic>> get selectedFertilizerNutrients {
    return totalNutrients;
  }

  bool isFertilizerChecked(String name) {
    return fertilizerCheckboxStatus[name] ?? false;
  }

  void autoSelectFertilizers(
      List<FertilizerModel> fertilizers, Map<String, dynamic> targetNutrients) {
    selectedFertilizers.clear();
    fertilizerCheckboxStatus.clear();
    totalNutrients['macro']?.clear();
    totalNutrients['micro']?.clear();

    for (var fertilizer in fertilizers) {
      bool meetsTarget = true;

      fertilizer.macro.forEach((key, value) {
        double currentTotal = (totalNutrients['macro']?[key] ?? 0.0) +
            (value is String
                ? double.tryParse(value) ?? 0.0
                : value.toDouble());
      });

      fertilizer.micro.forEach((key, value) {
        double currentTotal = (totalNutrients['micro']?[key] ?? 0.0) +
            (value is String
                ? double.tryParse(value) ?? 0.0
                : value.toDouble());
      });

      if (meetsTarget && !selectedFertilizers.contains(fertilizer)) {
        addFertilizerCheck(fertilizer);
      }
    }

    notifyListeners();
  }

  void resetAutoSelection() {
    selectedFertilizers.clear();
    fertilizerCheckboxStatus.clear();
    totalNutrients['macro']?.clear();
    totalNutrients['micro']?.clear();
    notifyListeners();
  }

  Future<String> saveImageToAppDir(String? imagePath) async {
    if (imagePath == null || imagePath.startsWith('assets/')) {
      return imagePath ?? '';
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
      return imagePath;
    }
  }

  Future<void> updateFertilizer(
    String oldName,
    String newName,
    String? newImagePath,
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
        Object? currentImagePath = fertilizer.first['image'];
        final imagePathToSave = newImagePath != null
            ? await saveImageToAppDir(newImagePath)
            : currentImagePath;

        await db.update(
          'fertilizers',
          {
            'name': newName,
            'image': imagePathToSave,
            'category': category,
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
    String? imagePath,
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
      final fertilizer = await db.query(
        'fertilizers',
        where: 'name = ?',
        whereArgs: [name],
      );

      if (fertilizer.isNotEmpty) {
        int fertilizerId = fertilizer.first['id'] as int;
        final imagePath = fertilizer.first['image'] as String;
        final imageFile = File(imagePath);

        if (await imageFile.exists()) {
          await imageFile.delete();
        }

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
