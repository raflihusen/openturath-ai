import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'localization.dart';

abstract final class ScholarlyFonts {
  static const List<String> arabicFallback = ['Scheherazade New'];

  static TextStyle outfit({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => Loc.isArabic
      ? TextStyle(
          fontFamily: 'Scheherazade New',
          fontFamilyFallback: arabicFallback,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: 0,
          height: height == null || height < 1.85 ? 1.85 : height,
          decoration: decoration,
        )
      : TextStyle(
          fontFamily: 'Outfit',
          fontFamilyFallback: arabicFallback,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          decoration: decoration,
        );

  static TextStyle newsreader({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => Loc.isArabic
      ? TextStyle(
          fontFamily: 'Scheherazade New',
          fontFamilyFallback: arabicFallback,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: 0,
          height: height == null || height < 1.85 ? 1.85 : height,
          decoration: decoration,
        )
      : TextStyle(
          fontFamily: 'Newsreader',
          fontFamilyFallback: arabicFallback,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          decoration: decoration,
        );

  static TextStyle scheherazadeNew({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => TextStyle(
        fontFamily: 'Scheherazade New',
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: 0,
        height: height == null || height < 1.85 ? 1.85 : height,
        decoration: decoration,
      );

  // Preset Kaligrafi Arab Watermark
  static TextStyle arabicWatermark({
    required double fontSize,
    Color? color,
    double height = 1.35,
  }) => TextStyle(
        fontFamily: 'Scheherazade New',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        height: height,
        color: color,
        letterSpacing: 0,
      );

  // Preset Aksen Judul Arab pada Kartu Bento (27px, line-height 1.5)
  static TextStyle arabicCardAccent({
    double fontSize = 26,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.5,
  }) => TextStyle(
        fontFamily: 'Scheherazade New',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
        letterSpacing: 0,
      );

  // Preset Kutipan Naskah Arab Otentik (seperti di Q001: 20-22px, Bold 700, line-height 1.9)
  static TextStyle arabicQuote({
    double fontSize = 20,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
    double height = 1.9,
  }) => TextStyle(
        fontFamily: 'Scheherazade New',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color,
        letterSpacing: 0,
      );

  static TextStyle firaCode({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => GoogleFonts.firaCode(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );

  static TextStyle sourceCodePro({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => GoogleFonts.sourceCodePro(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );

  static TextStyle jetBrainsMono({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => GoogleFonts.jetBrainsMono(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );
}
