import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'localization.dart';

abstract final class ScholarlyFonts {
  static TextStyle outfit({TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? height, TextDecoration? decoration}) => Loc.isArabic
        ? GoogleFonts.scheherazadeNew(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: 0, height: height == null || height < 1.85 ? 1.85 : height, decoration: decoration)
        : GoogleFonts.outfit(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: letterSpacing, height: height, decoration: decoration);
  static TextStyle newsreader({TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? height, TextDecoration? decoration}) => Loc.isArabic
        ? GoogleFonts.scheherazadeNew(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: 0, height: height == null || height < 1.85 ? 1.85 : height, decoration: decoration)
        : GoogleFonts.newsreader(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: letterSpacing, height: height, decoration: decoration);
  static TextStyle scheherazadeNew({TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? height, TextDecoration? decoration}) => GoogleFonts.scheherazadeNew(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: 0, height: height == null || height < 1.85 ? 1.85 : height, decoration: decoration);
  static TextStyle firaCode({TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? height, TextDecoration? decoration}) => GoogleFonts.firaCode(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: letterSpacing, height: height, decoration: decoration);
  static TextStyle sourceCodePro({TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? height, TextDecoration? decoration}) => GoogleFonts.sourceCodePro(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: letterSpacing, height: height, decoration: decoration);
  static TextStyle jetBrainsMono({TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? height, TextDecoration? decoration}) => GoogleFonts.jetBrainsMono(textStyle: textStyle, color: color, backgroundColor: backgroundColor,
      fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle,
      letterSpacing: letterSpacing, height: height, decoration: decoration);
}
