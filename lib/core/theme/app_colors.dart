import 'package:flutter/material.dart';

/// Centralized color palette for the app.
class AppColors {
  AppColors._();

  // ── Primary palette ──
  static const Color primary = Color(0xFF1089FF);
  static const Color accent = Color(0xFF4E9AFF);
  static const Color highlight = Color(0xFF00D2FC);

  // ── Background gradients ──
  static const Color bgGradient1 = Color(0xFF0A1931);
  static const Color bgGradient2 = Color(0xFF150E56);

  // ── Legacy colors (from ListColor) ──
  static const Color primaryCyan = Color.fromARGB(255, 54, 255, 201);
  static const Color cyanColor = Color.fromARGB(255, 14, 241, 249);
  static const Color selectedColor = Color.fromARGB(255, 95, 169, 164);
  static const Color nonPrimary = Color.fromARGB(255, 95, 169, 164);
  static const Color gradientTop = Color.fromARGB(255, 61, 139, 197);
  static const Color gradientBottom = Color.fromARGB(255, 123, 249, 174);

  // ── Text colors ──
  static const Color textBlack = Color.fromARGB(255, 75, 73, 73);
  static const Color textWhite = Color.fromARGB(255, 255, 255, 255);
  static const Color textGray = Color.fromARGB(255, 135, 137, 161);

  // ── Card ──
  static const Color cardBackground = Color.fromARGB(255, 255, 255, 255);

  // ── Surah card category colors ──
  static const List<Color> makkiyyahGradient = [
    Color(0xFF1E88E5),
    Color(0xFF42A5F5),
  ];
  static const List<Color> madaniyyahGradient = [
    Color(0xFF7B1FA2),
    Color(0xFF9C27B0),
  ];
}
