import 'package:fertilizer_calculator/data/result_data.dart';
import 'package:flutter/material.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _histories = [];
  List<Map<String, dynamic>> get histories => _histories;

  Future<void> loadHistories() async {
    try {
      _histories = await ResultDatabase().getHistories();
      // Pastikan nilai tidak null
      _histories = _histories.map((history) {
        return {
          'id': history['id'] as int,
          'name': history['name'] ?? 'Unknown',
          'total_weight': (history['total_weight'] ?? 0.0) as double,
          'total_price': (history['total_price'] ?? 0.0) as double,
          'liter': (history['liter'] ?? 0) as int,
          'konsentrasi': (history['konsentrasi'] ?? 0) as int,
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading histories from database: $e');
    }
  }
}
