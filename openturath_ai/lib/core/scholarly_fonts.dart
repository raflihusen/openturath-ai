import 'package:flutter/material.dart';
import 'design/native_fonts.dart';
import 'localization.dart';

abstract final class ScholarlyFonts {
  static TextStyle outfit(
          {TextStyle? textStyle,
          Color? color,
          Color? backgroundColor,
          double? fontSize,
          FontWeight? fontWeight,
          FontStyle? fontStyle,
          double? letterSpacing,
          double? height,
          TextDecoration? decoration}) =>
      Loc.isArabic
          // Antarmuka Arab: font UI (bukan font kitab), tanpa jarak huruf.
          ? (textStyle ?? const TextStyle()).copyWith(
              fontFamily: 'NativeArabicUI',
              fontFamilyFallback: const ['NativeInter'],
              color: color,
              backgroundColor: backgroundColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              letterSpacing: 0,
              height: height == null || height < 1.4 ? 1.5 : height,
              decoration: decoration)
          : NativeFonts.outfit(
              textStyle: textStyle,
              color: color,
              backgroundColor: backgroundColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              letterSpacing: letterSpacing,
              height: height,
              decoration: decoration);
  static TextStyle newsreader(
          {TextStyle? textStyle,
          Color? color,
          Color? backgroundColor,
          double? fontSize,
          FontWeight? fontWeight,
          FontStyle? fontStyle,
          double? letterSpacing,
          double? height,
          TextDecoration? decoration}) =>
      Loc.isArabic
          // Antarmuka Arab: font UI (bukan font kitab), tanpa jarak huruf.
          ? (textStyle ?? const TextStyle()).copyWith(
              fontFamily: 'NativeArabicUI',
              fontFamilyFallback: const ['NativeInter'],
              color: color,
              backgroundColor: backgroundColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              letterSpacing: 0,
              height: height == null || height < 1.4 ? 1.5 : height,
              decoration: decoration)
          : NativeFonts.newsreader(
              textStyle: textStyle,
              color: color,
              backgroundColor: backgroundColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              letterSpacing: letterSpacing,
              height: height,
              decoration: decoration);
  static TextStyle scheherazadeNew(
          {TextStyle? textStyle,
          Color? color,
          Color? backgroundColor,
          double? fontSize,
          FontWeight? fontWeight,
          FontStyle? fontStyle,
          double? letterSpacing,
          double? height,
          TextDecoration? decoration}) =>
      NativeFonts.scheherazadeNew(
          textStyle: textStyle,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: 0,
          height: height == null || height < 1.85 ? 1.85 : height,
          decoration: decoration);
  static TextStyle firaCode(
          {TextStyle? textStyle,
          Color? color,
          Color? backgroundColor,
          double? fontSize,
          FontWeight? fontWeight,
          FontStyle? fontStyle,
          double? letterSpacing,
          double? height,
          TextDecoration? decoration}) =>
      NativeFonts.firaCode(
          textStyle: textStyle,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          decoration: decoration);
  static TextStyle sourceCodePro(
          {TextStyle? textStyle,
          Color? color,
          Color? backgroundColor,
          double? fontSize,
          FontWeight? fontWeight,
          FontStyle? fontStyle,
          double? letterSpacing,
          double? height,
          TextDecoration? decoration}) =>
      NativeFonts.sourceCodePro(
          textStyle: textStyle,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          decoration: decoration);
  static TextStyle jetBrainsMono(
          {TextStyle? textStyle,
          Color? color,
          Color? backgroundColor,
          double? fontSize,
          FontWeight? fontWeight,
          FontStyle? fontStyle,
          double? letterSpacing,
          double? height,
          TextDecoration? decoration}) =>
      NativeFonts.jetBrainsMono(
          textStyle: textStyle,
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          height: height,
          decoration: decoration);
}
