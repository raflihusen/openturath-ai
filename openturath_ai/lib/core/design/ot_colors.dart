import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Color Palette (Quiet Scholar Adaptive)
/// Filosofi: Konten adalah tokoh utama. UI mundur satu langkah.
/// Nuansa islami muncul dari isi teks, aksara Arab, dan keanggunan tata letak, bukan dekorasi berlebihan.
class OTColors {
  // ── 1. Light Canvas & Surfaces (Warm Off-White & Pure Paper) ──
  static const Color canvasLight = Color(0xFFFAFAF9); // Warm stone off-white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white card/sheet
  static const Color surfaceSubtleLight = Color(0xFFF4F4F5); // Inset container bg
  static const Color borderLight = Color(0xFFE4E4E7); // 1px subtle hairline
  static const Color borderSubtleLight = Color(0xFFF1F5F9);

  // ── 2. Light Typography (High Contrast, Readable) ──
  static const Color textPrimaryLight = Color(0xFF18181B); // Ink black
  static const Color textSecondaryLight = Color(0xFF52525B); // Zinc 600 (>4.5:1 WCAG AA)
  static const Color textTertiaryLight = Color(0xFF71717A); // Zinc 500

  // ── 3. Dark Canvas & Surfaces (Deep Obsidian & Slate) ──
  static const Color canvasDark = Color(0xFF0E0E10); // Deep obsidian
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900 elevated surface
  static const Color surfaceSubtleDark = Color(0xFF27272A); // Zinc 800 inset
  static const Color borderDark = Color(0xFF27272A); // 1px hairline dark border
  static const Color borderSubtleDark = Color(0xFF1E1E22);

  // ── 4. Dark Typography (Clean White & High Contrast Gray) ──
  static const Color textPrimaryDark = Color(0xFFFAFAFA); // Zinc 50
  static const Color textSecondaryDark = Color(0xFFA1A1AA); // Zinc 400 (>7.0:1 WCAG AAA)
  static const Color textTertiaryDark = Color(0xFFA1A1AA); // Zinc 500

  // ── 5. Scholarly Accents (Muted Intellectual Sapphire & Emerald) ──
  static const Color accentLight = Color(0xFF2563EB); // Intellectual sapphire
  static const Color accentDark = Color(0xFF60A5FA); // Soft scholarly sapphire
  static const Color sovereignAmber = Color(0xFFD97706); // Amber for Tahawwulat sovereign corpus
  static const Color sovereignAmberBg = Color(0x1AD97706); // 10% amber wash

  // ── 6. Semantic Colors ──
  static const Color success = Color(0xFF10B981); // Emerald green (hanya saat bermakna)
  static const Color destructive = Color(0xFFDC2626); // Red (hanya logout/delete/error)

  // ── Context-Aware Adaptive Helpers ──
  static Color canvas(bool isDark) => isDark ? canvasDark : canvasLight;
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceSubtle(bool isDark) => isDark ? surfaceSubtleDark : surfaceSubtleLight;
  static Color border(bool isDark) => isDark ? borderDark : borderLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool isDark) => isDark ? textTertiaryDark : textTertiaryLight;
  static Color accent(bool isDark) => isDark ? accentDark : accentLight;
}
