import 'package:flutter/material.dart';

class ClassicGlassTheme {
  // Dark Tahoe Palette
  static const Color darkBg = Color(0xFF0F172A); // Deep slate navy
  static const Color darkGlassSurface = Color(0x331E293B);
  static const Color darkGlassBorder = Color(0x26FFFFFF);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkAccent = Color(0xFF38BDF8); // Bright sky blue

  // Light Tahoe Palette
  static const Color lightBg = Color(0xFFEBF4FF); // Soft glacier ice blue
  static const Color lightGlassSurface = Color(0x80FFFFFF);
  static const Color lightGlassBorder = Color(0x40FFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightAccent = Color(0xFF2563EB); // Royal electric blue

  static Color getBg(bool isDark) => isDark ? darkBg : lightBg;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getAccent(bool isDark) => isDark ? darkAccent : lightAccent;
  static Color getGlassSurface(bool isDark) => isDark ? darkGlassSurface : lightGlassSurface;
  static Color getGlassBorder(bool isDark) => isDark ? darkGlassBorder : lightGlassBorder;
}
