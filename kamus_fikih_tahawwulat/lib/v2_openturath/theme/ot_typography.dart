import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// OpenTurath Design System — 3-Layer Strict Typography
/// 1. Brand Layer: Newsreader (Editorial Serif)
/// 2. Interface Layer: Outfit (Modern Clean Sans)
/// 3. Arabic Scholarly Layer: Tajawal (Naskh Proporsional, height 1.6-1.8)
class OTTypography {
  // ── 1. Brand & Editorial Layer (Newsreader Serif) ──
  static TextStyle brandWordmark({Color? color}) => GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle editorialHero({Color? color}) => GoogleFonts.newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.25,
        color: color,
      );

  static TextStyle corpusTitle({Color? color}) => GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  // ── 2. Interface Layer (Outfit Sans) ──
  static TextStyle screenTitle({Color? color}) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle sectionHeading({Color? color}) => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle cardTitle({Color? color}) => GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle body({Color? color}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: color,
      );

  static TextStyle captionMedium({Color? color}) => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle microPill({Color? color}) => GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle button({Color? color}) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      );

  // ── 3. Arabic Scholarly Layer (Tajawal Khat Naskh) ──
  static TextStyle arabicDisplay({Color? color}) => GoogleFonts.tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.6,
        color: color,
      );

  static TextStyle arabicReading({Color? color}) => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.7,
        color: color,
      );

  static TextStyle arabicQuote({Color? color}) => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.75,
        color: color,
      );
}
