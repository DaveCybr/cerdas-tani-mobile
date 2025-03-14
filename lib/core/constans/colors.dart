import 'package:flutter/material.dart';

// Your existing color palette
class AppColors {
  static const Color dark = Color(0xff141421);
  static const Color light = Color(0xfff2f7ff);
  static const Color green = Color(0xff6fb236);
  static const Color lightgreen = Color(0xffa1e434);
  static const Color darkgreen = Color(0xff7ec414);
  static const Color lightblue = Color(0xff6cd3fe);
  static const Color darkblue = Color(0xff287ed1);
  static const Color card = Color(0xff1e1e2c);
  static const Color disabled = Color(0xff8891A1);
  static const Color primary = Color(0xFF1FCC79);
  static const Color Secondary = Color(0xFFFF6464);
  static const Color mainText = Color(0xFF2E3E5C);
  static const Color SecondaryText = Color(0xFF9FA5C0);
  static const Color outline = Color(0xFFD0DBEA);
  static const Color form = Color(0xFFF4F5F7);
}

class AppTheme {
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.dark,
    scaffoldBackgroundColor: AppColors.dark,
    cardColor: AppColors.card,
    disabledColor: AppColors.disabled,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkblue,
      secondary: AppColors.green,
      surface: AppColors.card,
      background: AppColors.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.light,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.light),
      bodyMedium: TextStyle(color: AppColors.light),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkblue,
        foregroundColor: AppColors.light,
      ),
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.light,
    scaffoldBackgroundColor: AppColors.light,
    cardColor: Colors.white,
    disabledColor: AppColors.disabled,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightblue,
      secondary: AppColors.lightgreen,
      surface: Colors.white,
      background: AppColors.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.light,
      foregroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightblue,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
