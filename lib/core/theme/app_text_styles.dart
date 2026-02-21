import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized text styles for the app.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle header({
    Color color = AppColors.textWhite,
    double fontSize = 25.0,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle body({
    Color color = AppColors.textWhite,
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle description({
    Color color = AppColors.textBlack,
    double fontSize = 13.0,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle arabic({
    Color color = AppColors.textWhite,
    double fontSize = 24.0,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      fontFamily: 'ScheherazadeNew',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
