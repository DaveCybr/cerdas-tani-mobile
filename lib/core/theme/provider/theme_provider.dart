import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  static const _key = 'isDarkMode';

  bool _isDarkMode = false;

  ThemeProvider(this.prefs) {
    _isDarkMode = prefs.getBool(_key) ?? false;
    print("isdarrrkkkk:$_isDarkMode");
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get theme => _isDarkMode ? AppTheme.dark : AppTheme.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    prefs.setBool(_key, _isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    prefs.setBool(_key, value);
    notifyListeners();
  }
}
