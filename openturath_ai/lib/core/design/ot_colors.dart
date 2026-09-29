import 'package:flutter/material.dart';

/// OpenTurath Design System — Monochrome Editorial Palette
/// Prinsip Karakter Visual: Perpustakaan digital turath, ruang telaah akademik, dan katalog kitab modern.
/// Bukan: SaaS generik, fintech, AI neon/gradient, ataupun kartu warna-warni.
/// Kedalaman dibangun melalui kontras, tipografi, ruang kosong, hairline border, dan tekstur kertas arsip.
///
/// KONTRAK: berkas ini adalah SATU-SATUNYA tempat nilai warna mentah boleh ditulis.
/// Seluruh `screens/` dan `widgets/` wajib mengambil warna dari sini.
class OTColors {
  // ── 1. Light Mode (Warm Archival Paper) ──
  static const Color canvasLight = Color(0xFFF7F7F3); // Kertas hangat untuk ruang telaah
  static const Color surfaceLight = Color(0xFFFFFFFF); // Panel utama, bottom sheet, dialog, kartu, input field
  static const Color surfaceSubtleLight = Color(0xFFEFF0E9); // Kontainer tonal sekunder
  static const Color textPrimaryLight = Color(0xFF1D2128);
  static const Color textSecondaryLight = Color(0xFF535A64);
  static const Color textTertiaryLight = Color(0xFF535A64);
  static const Color borderLight = Color(0xFFC9CFD6);
  static const Color borderSubtleLight = Color(0xFFE3E6E5);
  static const Color borderStrongLight = Color(0xFF667487);
  static const Color accentLight = Color(0xFF3159A5);
  static const Color primaryContainerLight = Color(0xFFDCE6FF);
  static const Color onPrimaryContainerLight = Color(0xFF172B54);

  // ── 2. Dark Mode (Quiet Obsidian Scholar) ──
  static const Color canvasDark = Color(0xFF12151B);
  static const Color surfaceDark = Color(0xFF1C212A);
  static const Color surfaceSubtleDark = Color(0xFF262D37);
  static const Color textPrimaryDark = Color(0xFFF1F3F8);
  static const Color textSecondaryDark = Color(0xFFC0C7D2);
  static const Color textTertiaryDark = Color(0xFFC0C7D2);
  static const Color borderDark = Color(0xFF687382);
  static const Color borderSubtleDark = Color(0xFF37404A);
  static const Color borderStrongDark = Color(0xFF92A0B2);
  static const Color accentDark = Color(0xFFA9C5FF);
  static const Color primaryContainerDark = Color(0xFF263C65);
  static const Color onPrimaryContainerDark = Color(0xFFDAE6FF);

  // ── 3. Tinta Balik (Foreground di atas permukaan ber-accent) ──
  // Tombol primer diisi `accent`, sehingga labelnya wajib memakai `onAccent`.
  // Token inilah pengganti resmi `Colors.white` / `Colors.black` di seluruh UI.
  static const Color onAccentLight = surfaceLight;
  static const Color onAccentDark = Color(0xFF14294C);

  // ── 4. Permukaan Terbalik (Snackbar, tooltip, pil gelap di mode terang) ──
  static const Color inverseSurfaceLight = textPrimaryLight;
  static const Color inverseSurfaceDark = Color(0xFF262D37);
  static const Color onInverseSurface = Color(0xFFF1F3F8);

  // ── 5. Sage Zaitun — satu-satunya warna non-monokrom ──
  // Dipakai HANYA sebagai penanda status marja' / terverifikasi, tidak pernah dekoratif.
  static const Color marjaLight = Color(0xFF3D4A3E); // Hijau zaitun sangat tua
  static const Color marjaDark = Color(0xFF9CAF9E); // Sage terang agar terbaca di obsidian

  // ── 6. Merah Bata Redup (Status kritis, bukan merah neon) ──
  static const Color destructiveLight = Color(0xFF8C2F2F);
  static const Color destructiveDark = Color(0xFFC97B74);

  // ── 7. Context-Aware Adaptive Helpers ──
  static Color canvas(bool isDark) => isDark ? canvasDark : canvasLight;
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceSubtle(bool isDark) => isDark ? surfaceSubtleDark : surfaceSubtleLight;
  static Color border(bool isDark) => isDark ? borderDark : borderLight;
  static Color borderStrong(bool isDark) => isDark ? borderStrongDark : borderStrongLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool isDark) => isDark ? textTertiaryDark : textTertiaryLight;
  static Color accent(bool isDark) => isDark ? accentDark : accentLight;
  static Color onAccent(bool isDark) => isDark ? onAccentDark : onAccentLight;
  static Color primaryContainer(bool isDark) =>
      isDark ? primaryContainerDark : primaryContainerLight;
  static Color onPrimaryContainer(bool isDark) =>
      isDark ? onPrimaryContainerDark : onPrimaryContainerLight;
  static Color inverseSurface(bool isDark) => isDark ? inverseSurfaceDark : inverseSurfaceLight;
  static Color marja(bool isDark) => isDark ? marjaDark : marjaLight;
  static Color destructive(bool isDark) => isDark ? destructiveDark : destructiveLight;
}
