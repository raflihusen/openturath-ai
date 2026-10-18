import 'package:flutter/material.dart';
import '../localization.dart';

/// Bundled native fonts, deliberately named separately from GoogleFonts assets.
abstract final class NativeFonts {
  static TextStyle outfit(
      {TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? height,
      TextDecoration? decoration}) {
    final arabic = Loc.isArabic;
    return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: 'NativeOutfit',
        fontFamilyFallback: const ['NativeArabicUI', 'NativeInter'],
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: arabic ? 0 : letterSpacing,
        // Teks antarmuka Arab memakai font UI dengan tinggi baris wajar.
        height:
            arabic ? (height == null || height < 1.4 ? 1.5 : height) : height,
        decoration: decoration);
  }

  static TextStyle newsreader(
      {TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? height,
      TextDecoration? decoration}) {
    final arabic = Loc.isArabic;
    return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: 'NativeNewsreader',
        fontFamilyFallback: const ['NativeArabicUI', 'NativeInter'],
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: arabic ? 0 : letterSpacing,
        // Teks antarmuka Arab memakai font UI dengan tinggi baris wajar.
        height:
            arabic ? (height == null || height < 1.4 ? 1.5 : height) : height,
        decoration: decoration);
  }

  static TextStyle scheherazadeNew(
      {TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? height,
      TextDecoration? decoration}) {
    return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: 'NativeArabic',
        fontFamilyFallback: const ['NativeInter'],
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: 0,
        height: height == null || height < 1.85 ? 1.9 : height,
        decoration: decoration);
  }

  static TextStyle jetBrainsMono(
      {TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? height,
      TextDecoration? decoration}) {
    final arabic = Loc.isArabic;
    return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: arabic ? 'NativeArabic' : 'monospace',
        fontFamilyFallback: const ['NativeArabicUI', 'NativeInter'],
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: arabic ? 0 : letterSpacing,
        // Teks antarmuka Arab memakai font UI dengan tinggi baris wajar.
        height:
            arabic ? (height == null || height < 1.4 ? 1.5 : height) : height,
        decoration: decoration);
  }

  static TextStyle sourceCodePro(
      {TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? height,
      TextDecoration? decoration}) {
    final arabic = Loc.isArabic;
    return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: arabic ? 'NativeArabic' : 'monospace',
        fontFamilyFallback: const ['NativeArabicUI', 'NativeInter'],
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: arabic ? 0 : letterSpacing,
        // Teks antarmuka Arab memakai font UI dengan tinggi baris wajar.
        height:
            arabic ? (height == null || height < 1.4 ? 1.5 : height) : height,
        decoration: decoration);
  }

  static TextStyle firaCode(
      {TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? height,
      TextDecoration? decoration}) {
    final arabic = Loc.isArabic;
    return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: arabic ? 'NativeArabic' : 'monospace',
        fontFamilyFallback: const ['NativeArabicUI', 'NativeInter'],
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: arabic ? 0 : letterSpacing,
        // Teks antarmuka Arab memakai font UI dengan tinggi baris wajar.
        height:
            arabic ? (height == null || height < 1.4 ? 1.5 : height) : height,
        decoration: decoration);
  }
}
