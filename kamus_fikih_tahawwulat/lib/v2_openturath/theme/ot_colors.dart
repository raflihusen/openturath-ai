import 'package:flutter/material.dart';

/// OpenTurath Design System — Color Palette (The Quiet Scholar)
/// Filosofi: Konten adalah tokoh utama. UI mundur satu langkah.
class OTColors {
  // ── 1. Light Canvas & Surfaces (Warm Stone Off-White & Pure Paper) ──
  static const Color canvasLight = Color(0xFFFAFAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSubtleLight = Color(0xFFF4F4F5);
  static const Color borderLight = Color(0xFFE4E4E7);
  static const Color borderSubtleLight = Color(0xFFF1F5F9);

  // ── 2. Light Typography ──
  static const Color textPrimaryLight = Color(0xFF18181B); // Ink black
  static const Color textSecondaryLight = Color(0xFF52525B); // Zinc 600 (>4.5:1 WCAG AA)
  static const Color textTertiaryLight = Color(0xFF71717A); // Zinc 500

  // ── 3. Dark Canvas & Surfaces (Deep Obsidian) ──
  static const Color canvasDark = Color(0xFF0E0E10); // Deep obsidian
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900
  static const Color surfaceSubtleDark = Color(0xFF27272A); // Zinc 800 inset
  static const Color borderDark = Color(0xFF27272A); // 0.8px - 1px hairline
  static const Color borderSubtleDark = Color(0xFF1E1E22);

  // ── 4. Dark Typography ──
  static const Color textPrimaryDark = Color(0xFFFAFAFA); // Zinc 50
  static const Color textSecondaryDark = Color(0xFFA1A1AA); // Zinc 400 (>7.0:1 WCAG AAA)
  static const Color textTertiaryDark = Color(0xFF71717A); // Zinc 500

  // ── 5. Scholarly Accents (Sovereign Amber for Fikih Tahawwulat) ──
  static const Color sovereignAmber = Color(0xFFD97706); // Amber korpus Tahawwulat
  static const Color sovereignAmberBg = Color(0x1AD97706); // 10% amber wash
  static const Color accentLight = Color(0xFF18181B);
  static const Color accentDark = Color(0xFFFAFAFA);

  // ── 6. Semantic ──
  static const Color success = Color(0xFF10B981);
  static const Color destructive = Color(0xFFDC2626);

  // ── Helpers ──
  static Color canvas(bool isDark) => isDark ? canvasDark : canvasLight;
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceSubtle(bool isDark) => isDark ? surfaceSubtleDark : surfaceSubtleLight;
  static Color border(bool isDark) => isDark ? borderDark : borderLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool isDark) => isDark ? textTertiaryDark : textTertiaryLight;
  static Color accent(bool isDark) => isDark ? accentDark : accentLight;
}
