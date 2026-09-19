import 'package:flutter/material.dart';
import '../l10n/language_notifier.dart';

/// Bundled OFL families; method aliases preserve compatibility with v2 widgets.
/// Arabic never inherits italic, Latin tracking, or cramped line height.
abstract final class OTFonts {
  static bool get _arabic => LocaleService.instance.current.isArabic;
  static TextStyle outfit({double? fontSize, FontWeight? fontWeight,
    Color? color, double? letterSpacing, double? height,
    FontStyle? fontStyle, TextDecoration? decoration}) => _arabic
      ? scheherazadeNew(fontSize: fontSize, fontWeight: fontWeight, color: color,
          height: height, decoration: decoration)
      : TextStyle(fontFamily: 'Inter', fontFamilyFallback: const ['Scheherazade New'],
          fontSize: fontSize, fontWeight: fontWeight,
          fontVariations: [FontVariation('wght', (fontWeight ?? FontWeight.w400).value.toDouble())],
          color: color, letterSpacing: letterSpacing, height: height,
          fontStyle: fontStyle, decoration: decoration);

  static TextStyle newsreader({double? fontSize, FontWeight? fontWeight,
    Color? color, double? letterSpacing, double? height,
    FontStyle? fontStyle, TextDecoration? decoration}) => _arabic
      ? scheherazadeNew(fontSize: fontSize, fontWeight: fontWeight, color: color,
          height: height, decoration: decoration)
      : TextStyle(fontFamily: 'Cormorant', fontFamilyFallback: const ['Scheherazade New'],
          fontSize: fontSize, fontWeight: fontWeight,
          fontVariations: [FontVariation('wght', (fontWeight ?? FontWeight.w400).value.clamp(300, 700).toDouble())],
          color: color, letterSpacing: letterSpacing, height: height,
          fontStyle: fontStyle, decoration: decoration);

  static TextStyle scheherazadeNew({double? fontSize, FontWeight? fontWeight,
    Color? color, double? letterSpacing, double? height,
    FontStyle? fontStyle, TextDecoration? decoration}) => TextStyle(
      fontFamily: 'Scheherazade New', fontSize: fontSize,
      fontWeight: fontWeight, color: color, letterSpacing: 0,
      height: (height ?? 1.9) < 1.85 ? 1.85 : (height ?? 1.9),
      fontStyle: FontStyle.normal, decoration: decoration);
}
