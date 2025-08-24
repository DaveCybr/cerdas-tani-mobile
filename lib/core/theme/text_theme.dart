import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart'; // Pastikan AppColors didefinisikan di sini

final appTextTheme = TextTheme(
  // H1
  headlineLarge: GoogleFonts.poppins(
    color: AppColors.mainText,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  ),
  // H2
  headlineMedium: GoogleFonts.poppins(
    color: AppColors.mainText,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  ),
  // H3
  headlineSmall: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
  // P1
  bodyLarge: GoogleFonts.poppins(
    color: AppColors.secondaryText,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  ),
  // P2
  bodyMedium: GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  ),
  // S
  bodySmall: GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
    letterSpacing: 0.5,
  ),
);
