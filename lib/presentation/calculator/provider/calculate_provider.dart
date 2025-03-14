import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class CalculateProvider extends ChangeNotifier {
  Map<String, dynamic> calculateResult = {};
  int volumeInLiter = 0;
  int consentration = 0;
  String recipeName = "";
  String statusText = "Silahkan pilih pupuk dan resep";
  bool isButtonStartClicked = false;
  List<Map<String, dynamic>> calculationHistory = [];
  List<Map<String, dynamic>> calculationDataFromFirebase = [];

  static const Uuid uuid = Uuid();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, dynamic> removeZeroValues(Map<String, dynamic> map) {
    map.removeWhere((key, value) => value == 0);
    return map;
  }

  Map<String, dynamic> formatKey(Map<String, dynamic> map) {
    var newMap = <String, dynamic>{};
    map.forEach((key, value) {
      String newKey = key.toLowerCase();
      if (newKey == 'n') {
        newKey = 'no3';
      }
      newMap[newKey] = value;
    });
    return newMap;
  }

  Future<Map<String, dynamic>> fetchNutrientCalculation({
    required int volume,
    required Map<String, dynamic>? targets,
    required List<Map<String, dynamic>> fertilizers,
  }) async {
    try {
      statusText = "Loading";
      notifyListeners();
      final url =
          Uri.parse('http://sirangga.satelliteorbit.cloud/api/calculate');
      volumeInLiter = volume;
      // Remove zero values from nutrient_content in selected fertilizers
      List<Map<String, dynamic>> filteredFertilizers =
          fertilizers.map((fertilizer) {
        Map<String, dynamic> nutrientContent = fertilizer['nutrient_content'];
        nutrientContent = removeZeroValues(nutrientContent);
        nutrientContent = formatKey(nutrientContent);
        fertilizer['nutrient_content'] = nutrientContent;
        return fertilizer;
      }).toList();

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "volume": volume,
          "targets": targets,
          "fertilizers": filteredFertilizers,
        }),
      );
      // print(jsonEncode({
      //   "volume": volume,
      //   "targets": targets,
      //   "fertilizers": filteredFertilizers,
      // }));
      if (response.statusCode == 200) {
        statusText = "Proses Kalkulasi Berhasil !!!";
        isButtonStartClicked = true;
        calculateResult = jsonDecode(response.body);

        // Get the current user's Google account ID
        User? user = auth.currentUser;
        String googleAccountId = user?.uid ?? "unknown_user";
        print("Google Account ID : ${GetStorage().read('google_account_id')}");
        // Generate a unique ID and store the response data
        String uniqueId = uuid.v4();
        // print({
        //   "id": uniqueId,
        //   "timestamp": DateTime.now().toString(),
        //   "volume": volume,
        //   "targets": targets,
        //   "fertilizers": filteredFertilizers,
        //   "result": calculateResult,
        //   "google_account_id": googleAccountId
        // });
        Map<String, dynamic> calculationData = {
          "id": uniqueId,
          "timestamp": DateTime.now().toString(),
          "volume": volume,
          "consentration": consentration,
          "targets": targets,
          "recipe_name": recipeName,
          "result": calculateResult,
          "google_account_id": googleAccountId,
        };
        calculationHistory.add(calculationData);

        // Store the calculation data in Firestore
        await firestore
            .collection('history')
            .doc(uniqueId)
            .set(calculationData);
        notifyListeners();
      }
      return jsonDecode(response.body);
    } catch (e) {
      statusText = "Proses Kalkulasi Gagal !!!";
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCalculationsByGoogleAccountId() async {
    try {
      String googleAccountId = await GetStorage().read("google_account_id");
      QuerySnapshot querySnapshot = await firestore
          .collection('history')
          .where('google_account_id', isEqualTo: googleAccountId)
          .get();

      List<Map<String, dynamic>> calculations = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
      calculationDataFromFirebase = calculations;
      return calculations;
    } catch (e) {
      rethrow;
    }
  }
}
