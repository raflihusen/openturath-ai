import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// OpenTurath Design System v2 — Typography (3-Layer Strict Architecture)
/// 1. Brand Layer: Editorial Serif (hanya untuk Brand, Editorial Hero, dan Judul Korpus)
/// 2. Interface Layer: Clean Sans (untuk tombol, navigasi, pengaturan, formulir, metadata, harga)
/// 3. Arabic Scholarly Layer: Tajawal
class OTTypography {
  /// Flag to bypass runtime font loading in test and air-gapped environments.
  static bool useSystemFontFallback = false;

  // ── Private font builders with test/offline fallback ──
  static TextStyle _newsreader({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Newsreader',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _outfit({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Outfit',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  static TextStyle _tajawal({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Tajawal',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.tajawal(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  // ── 1. Brand & Editorial Layer (Serif / Newsreader) ──
  static TextStyle brandLogo({Color? color}) => _newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle editorialHero({Color? color}) => _newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: color,
      );

  static TextStyle corpusTitle({Color? color}) => _newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  // ── 2. Interface Layer (Modern Sans / Outfit) ──
  static TextStyle screenTitle({Color? color}) => _outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle sectionHeading({Color? color}) => _outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle cardTitle({Color? color}) => _outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle body({Color? color}) => _outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => _outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle caption({Color? color}) => _outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: color,
      );

  static TextStyle captionMedium({Color? color}) => _outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle button({Color? color}) => _outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle price({Color? color}) => _outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  // ── 3. Arabic Scholarly Layer (Tajawal) ──
  static TextStyle arabicDisplay({Color? color}) => _tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: color,
      );

  static TextStyle arabicReading({Color? color}) => _tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.6,
        color: color,
      );

  static TextStyle arabicQuote({Color? color}) => _tajawal(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: color,
      );
}
