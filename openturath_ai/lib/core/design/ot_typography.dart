import 'package:flutter/material.dart';
import '../scholarly_fonts.dart';
import '../localization.dart';

/// OpenTurath Design System — Typography (3-Pilar Arsitektur Baku)
/// 1. Editorial & Heading Layer: Newsreader (Display, Page Title, Nama Kitab Besar)
/// 2. Interface Layer: Outfit (Tombol, Navigasi, Input, Chip, Metadata, Angka Indeks)
/// 3. Arabic & Turats Layer: Scheherazade New (Naskh murni teks Arab, matan, syarah, ibarah)
///
/// Hapus total ketergantungan pada font Amiri dan Tajawal.
class OTTypography {
  /// Flag to bypass runtime font loading in test and air-gapped environments.
  static bool useSystemFontFallback = false;

  // ── 1. Newsreader (Editorial & Heading) ──
  static TextStyle _newsreader({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: Loc.isArabic ? 'Scheherazade New' : 'Newsreader',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height:
            Loc.isArabic && (height == null || height < 1.85) ? 1.85 : height,
        color: color,
      );
    }
    return ScholarlyFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: Loc.isArabic && (height == null || height < 1.85) ? 1.85 : height,
      color: color,
    );
  }

  // ── 2. Outfit (Interface, UI, Metadata & Body) ──
  static TextStyle _outfit({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: Loc.isArabic ? 'Scheherazade New' : 'Outfit',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height:
            Loc.isArabic && (height == null || height < 1.85) ? 1.85 : height,
        color: color,
      );
    }
    return ScholarlyFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: Loc.isArabic && (height == null || height < 1.85) ? 1.85 : height,
      color: color,
    );
  }

  // ── 3. Scheherazade New (Arabic Scholarly Turats) ──
  static TextStyle _scheherazadeNew({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    if (useSystemFontFallback) {
      return TextStyle(
        fontFamily: 'Scheherazade New',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height:
            Loc.isArabic && (height == null || height < 1.85) ? 1.85 : height,
        color: color,
      );
    }
    return ScholarlyFonts.scheherazadeNew(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: Loc.isArabic && (height == null || height < 1.85) ? 1.85 : height,
      color: color,
    );
  }

  // ── Editorial & Heading Styles ──
  static TextStyle brandLogo({Color? color}) => _newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -.4,
        color: color,
      );

  static TextStyle displayLarge({Color? color}) => _newsreader(
        fontSize: 36,
        fontWeight: FontWeight.w500,
        letterSpacing: -1.0,
        color: color,
      );

  static TextStyle pageTitle({Color? color}) => _newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: color,
      );

  static TextStyle editorialHero({Color? color}) => _newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.25,
        color: color,
      );

  static TextStyle bookTitle({Color? color}) => _newsreader(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle screenTitle({Color? color}) => _newsreader(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle corpusTitle({Color? color}) => _newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  // ── Interface & Body Styles ──
  static TextStyle sectionTitle({Color? color}) => _outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
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

  static TextStyle metadataTag({Color? color}) => _outfit(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
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

  // ── Arabic Scholarly Layer (Scheherazade New) ──
  static TextStyle arabicDisplay({Color? color, double height = 1.85}) =>
      _scheherazadeNew(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: Loc.isArabic && height < 1.85 ? 1.85 : height,
        color: color,
      );

  static TextStyle arabicReading({Color? color, double height = 1.85}) =>
      _scheherazadeNew(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: Loc.isArabic && height < 1.85 ? 1.85 : height,
        color: color,
      );

  static TextStyle arabicIbarah({Color? color, double height = 1.85}) =>
      _scheherazadeNew(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: Loc.isArabic && height < 1.85 ? 1.85 : height,
        color: color,
      );

  static TextStyle arabicQuote({Color? color, double height = 1.85}) =>
      _scheherazadeNew(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: Loc.isArabic && height < 1.85 ? 1.85 : height,
        color: color,
      );
}
