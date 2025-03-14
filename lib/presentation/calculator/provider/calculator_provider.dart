import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fertilizer_calculator/data/result_data.dart';
import 'package:flutter/material.dart';

class CalculatorProvider with ChangeNotifier {
  double accuracy = 0.0; // Default 0%
  String statusText = "Silahkan pilih pupuk dan resep"; // Default status
  bool result = false; // Default false
  late int idResult;
  String nameRecipeResult = ''; // Initialize with a default value
  late int literResult;
  late int konsentrasiResult;
  late List<Map<String, dynamic>> fertilizersResult;
  late List<Map<String, dynamic>> weightResult;
  late List<Map<String, dynamic>> priceResult;

  int get getIdResult => idResult;
  String get getNameRecipeResult => nameRecipeResult;
  int get getLiterResult => literResult;
  int get getKonsentrasiResult => konsentrasiResult;
  List<Map<String, dynamic>> get getResultFertilizers => fertilizersResult;
  List<Map<String, dynamic>> get getResultWeight => weightResult;
  List<Map<String, dynamic>> get getResultPrice => priceResult;

  Future<bool> checkResult() async {
    if (result == false) {
      statusText = "Hasil belum ada karena belum ada perhitungan";
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      statusText = "Silahkan pilih pupuk dan resep";
      notifyListeners();
      return false;
    } else {
      statusText = "Silahkan lihat hasilnya!!!";
      return true;
    }
  }

  void checkAccuracy(
      Map<String, dynamic>? recipe,
      Map<String, Map<String, dynamic>> fertilizer,
      List nameFertilizers,
      String nameRecipe,
      int liter,
      int konsentrasi) async {
    statusText = "Sedang diproses...";
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (liter <= 0 || konsentrasi <= 0) {
      accuracy = 0.0;
      statusText = (liter <= 0 && konsentrasi <= 0)
          ? "Liter dan Konsentrasi tidak boleh kosong"
          : (liter <= 0)
              ? "Volume tidak boleh kosong"
              : "Konsentrasi tidak boleh kosong";
      notifyListeners();
      return;
    }

    if (recipe == null ||
        fertilizer.isEmpty ||
        fertilizer.values.every((element) => element.isEmpty)) {
      accuracy = 0.0;
      statusText = "Silahkan pilih pupuk dan resep";
      notifyListeners();
      return;
    }

    int totalNutrients = 0;
    int matchedNutrients = 0;
    double totalPenalty = 0.0;

    // Loop untuk memeriksa nutrisi macro dan micro
    recipe.forEach((category, nutrients) {
      if (nutrients is Map<String, dynamic>) {
        nutrients.forEach((nutrient, requiredValue) {
          // Pastikan nilai yang digunakan adalah double
          double requiredValueDouble = requiredValue is String
              ? double.tryParse(requiredValue) ?? 0.0
              : requiredValue.toDouble();
          double availableValue = fertilizer[category]?[nutrient] is String
              ? double.tryParse(fertilizer[category]?[nutrient]) ?? 0.0
              : (fertilizer[category]?[nutrient] ?? 0.0).toDouble();

          // Hitung penalti dengan faktor kecil untuk mendapatkan rentang 0.1% - 4%
          double penalty = 0.0;
          if (availableValue < requiredValueDouble) {
            // Jika tersedia kurang dari yang dibutuhkan, hitung penalti
            penalty = (requiredValueDouble - availableValue) /
                requiredValueDouble *
                0.04; // Penalti maksimal 4%
          } else if (availableValue > requiredValueDouble) {
            // Jika tersedia lebih banyak dari yang dibutuhkan, beri penalti juga
            penalty = (availableValue - requiredValueDouble) /
                requiredValueDouble *
                0.04; // Penalti maksimal 4%
          }

          // Batasi penalti agar tidak lebih dari 4% dan tidak kurang dari 0.1%
          totalPenalty += penalty.clamp(0.001, 0.04);

          // Jika nutrisi tersedia dan lebih besar dari 0, dianggap cocok
          if (availableValue > 0) {
            matchedNutrients++;
          }
        });

        // Total nutrisi yang ada di dalam kategori (macro atau micro)
        totalNutrients += nutrients.length;
      }
    });

    if (totalNutrients == 0 || fertilizer.isEmpty) {
      accuracy = 0.0;
      statusText = "Silahkan pilih pupuk dan resep";
      result = false;
      notifyListeners();
      return;
    } else {
      // Hitung akurasi sebagai rasio nutrisi yang cocok terhadap total nutrisi
      accuracy = (matchedNutrients / totalNutrients) * (1.0 - totalPenalty);
      accuracy = accuracy.clamp(0.0, 1.0);

      // Mengisi database untuk melihat hasil perhitungan
      result = true;
      List<Map<String, dynamic>> fertilizerNames = nameFertilizers
          .map((fertilizer) => {
                'name': fertilizer.name,
                'weightResult': (liter / 100) * fertilizer.weight,
                'priceResult': fertilizer.price,
                'typeResult': fertilizer.type,
              })
          .toList();
      final db = await ResultDatabase.instance.database;
      int historyId = await db.insert('history', {
        'name': nameRecipe,
        'liter': liter,
        'konsentrasi': konsentrasi,
        'name_recipe': nameRecipe,
      });

      for (var fertilizer in fertilizerNames) {
        await db.insert('result', {
          'name_nutrient': fertilizer['name'],
          'weight': fertilizer['weightResult'],
          'price': fertilizer['priceResult'],
          'type': fertilizer['typeResult'],
          'id_history': historyId,
        });
      }
      idResult = historyId;
      nameRecipeResult = nameRecipe;
      literResult = liter;
      konsentrasiResult = konsentrasi;
      fertilizersResult = fertilizerNames;
      weightResult =
          List.generate(fertilizerNames.length, (index) => {'weight': 0});
      priceResult =
          List.generate(fertilizerNames.length, (index) => {'price': 0});
      addResultToFirestore(nameRecipe, liter, konsentrasi, nameFertilizers);
      await checkResult();
      notifyListeners();
    }
  }

  Future<void> addResultToFirestore(String nameRecipe, int liter,
      int konsentrasi, List nameFertilizers) async {
    try {
      // Referensi ke koleksi Firestore
      final CollectionReference historyRef =
          FirebaseFirestore.instance.collection('history');

      // Siapkan data pupuk dalam format JSON
      List<Map<String, dynamic>> fertilizerData = nameFertilizers
          .map((fertilizer) => {
                'name': fertilizer.name,
                'weightResult': (liter / 100) * fertilizer.weight,
                'priceResult': fertilizer.price,
                'typeResult': fertilizer.type,
              })
          .toList();

      // Tambahkan semua data sebagai satu dokumen JSON
      await historyRef.add({
        'name': nameRecipe,
        'liter': liter,
        'konsentrasi': konsentrasi,
        'fertilizers':
            fertilizerData, // Simpan pupuk sebagai JSON dalam satu dokumen
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Data berhasil ditambahkan ke Firestore dalam bentuk JSON!");
    } catch (e) {
      print("Error saat menambahkan data ke Firestore: $e");
    }
  }
}
