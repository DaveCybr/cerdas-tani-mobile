import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider with ChangeNotifier {
  final GetStorage _storage = GetStorage();
  String _themeMode = "Terang"; // Default ke Terang

  ThemeProvider() {
    _loadTheme();
  }

  String get themeMode => _themeMode;

  ThemeMode get currentTheme {
    switch (_themeMode) {
      case "Gelap":
        return ThemeMode.dark;
      case "Sistem":
        return ThemeMode.system;
      default: // Default ke Terang
        return ThemeMode.light;
    }
  }

  void setTheme(String theme) {
    _themeMode = theme;
    _storage.write('themeMode', theme);
    notifyListeners();
  }

  void _loadTheme() {
    final savedTheme = _storage.read('themeMode');
    if (savedTheme != null) {
      _themeMode = savedTheme;
    }
    notifyListeners();
  }
}
