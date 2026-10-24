import 'package:flutter/material.dart';

/// OpenTurath Design System — Monochrome Editorial Palette
/// Prinsip Karakter Visual: Perpustakaan digital turath, ruang dialog ilmiah, dan katalog kitab modern.
/// Bukan: SaaS generik, fintech, AI neon/gradient, ataupun kartu warna-warni.
/// Kedalaman dibangun melalui kontras, tipografi, ruang kosong, hairline border, dan tekstur kertas arsip.
///
/// KONTRAK: berkas ini adalah SATU-SATUNYA tempat nilai warna mentah boleh ditulis.
/// Seluruh `screens/` dan `widgets/` wajib mengambil warna dari sini.
class OTColors {
  // ── 1. Light Mode (Neutral Paper) ──
  static const Color canvasLight =
      Color(0xFFF6F6F6); // Kertas hangat untuk ruang dialog ilmiah
  static const Color surfaceLight = Color(
      0xFFFFFFFF); // Panel utama, bottom sheet, dialog, kartu, input field
  static const Color surfaceSubtleLight =
      Color(0xFFEDEDED); // Kontainer tonal sekunder
  static const Color textPrimaryLight = Color(0xFF171717);
  static const Color textSecondaryLight = Color(0xFF606060);
  static const Color textTertiaryLight = Color(0xFF6B6B6B); // Placeholder, hint
  static const Color borderLight = Color(0xFFDADADA);
  static const Color borderSubtleLight = Color(0xFFEBEBEB);
  static const Color borderStrongLight = Color(0xFF767676);
  static const Color accentLight = Color(0xFF171717);
  static const Color primaryContainerLight = Color(0xFFF0F0F0);
  static const Color onPrimaryContainerLight = Color(0xFF171717);

  // ── 2. Dark Mode (Neutral Ink) ──
  static const Color canvasDark = Color(0xFF151515);
  static const Color surfaceDark = Color(0xFF292929);
  static const Color surfaceSubtleDark = Color(0xFF353535);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFB8B8B8);
  static const Color textTertiaryDark = Color(0xFF9A9A9A); // Placeholder, hint
  static const Color borderDark = Color(0xFF454545);
  static const Color borderSubtleDark = Color(0xFF2D2D2D);
  static const Color borderStrongDark = Color(0xFF808080);
  static const Color accentDark = Color(0xFFF5F5F5);
  static const Color primaryContainerDark = Color(0xFF222222);
  static const Color onPrimaryContainerDark = Color(0xFFF5F5F5);

  // ── 3. Tinta Balik (Foreground di atas permukaan ber-accent) ──
  // Tombol primer diisi `accent`, sehingga labelnya wajib memakai `onAccent`.
  // Token inilah pengganti resmi `Colors.white` / `Colors.black` di seluruh UI.
  static const Color onAccentLight = surfaceLight;
  static const Color onAccentDark = Color(0xFF171717);

  // ── 4. Permukaan Terbalik (Snackbar, tooltip, pil gelap di mode terang) ──
  static const Color inverseSurfaceLight = textPrimaryLight;
  static const Color inverseSurfaceDark = Color(0xFF2B2B2B);
  static const Color onInverseSurface = Color(0xFFF5F5F5);

  // ── 5. Status rujukan — dibedakan dengan label dan ikon ──
  // Dipakai HANYA sebagai penanda status marja' / terverifikasi, tidak pernah dekoratif.
  static const Color marjaLight = Color(0xFF4A4A4A); // Tinta status
  static const Color marjaDark =
      Color(0xFFC4C4C4); // Tinta status di mode gelap

  // Penanda Fikih Tahawwulat (Monochrome Editorial):
  // Menjaga kepatuhan Aturan Sakral #9 AGENTS.md (zero amber/orange/yellow).
  static const Color tahawwulat = textPrimaryLight;

  // ── 6. Status kritis — satu-satunya warna di luar tinta dan kertas ──
  // Merah hanya untuk galat dan aksi permanen, selalu bersama ikon dan pesan.
  static const Color errorLight = Color(0xFFB91C1C);
  static const Color errorDark = Color(0xFFF87171);
  static const Color errorContainerLight = Color(0xFFFEF2F2);
  static const Color errorContainerDark = Color(0xFF2F1616);
  static const Color destructiveLight = errorLight;
  static const Color destructiveDark = errorDark;

  // ── 6b. Dasar bayangan dan scrim; selalu dipakai dengan alpha ──
  static const Color shadow = Color(0xFF000000);

  // ── 7. Context-Aware Adaptive Helpers ──
  static Color canvas(bool isDark) => isDark ? canvasDark : canvasLight;
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceSubtle(bool isDark) =>
      isDark ? surfaceSubtleDark : surfaceSubtleLight;
  static Color border(bool isDark) => isDark ? borderDark : borderLight;
  static Color borderSubtle(bool isDark) =>
      isDark ? borderSubtleDark : borderSubtleLight;
  static Color borderStrong(bool isDark) =>
      isDark ? borderStrongDark : borderStrongLight;
  static Color textPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool isDark) =>
      isDark ? textTertiaryDark : textTertiaryLight;
  static Color accent(bool isDark) => isDark ? accentDark : accentLight;
  static Color onAccent(bool isDark) => isDark ? onAccentDark : onAccentLight;
  static Color primaryContainer(bool isDark) =>
      isDark ? primaryContainerDark : primaryContainerLight;
  static Color onPrimaryContainer(bool isDark) =>
      isDark ? onPrimaryContainerDark : onPrimaryContainerLight;

  /// Blok terbalik: hitam di mode terang, putih di mode gelap. Teks di
  /// atasnya memakai [onInverted] dan [onInvertedMuted].
  static Color inverted(bool isDark) => textPrimary(isDark);
  static Color onInverted(bool isDark) => canvas(isDark);
  static Color onInvertedMuted(bool isDark) =>
      canvas(isDark).withValues(alpha: 0.72);

  static Color inverseSurface(bool isDark) =>
      isDark ? inverseSurfaceDark : inverseSurfaceLight;
  static Color marja(bool isDark) => isDark ? marjaDark : marjaLight;
  static Color destructive(bool isDark) =>
      isDark ? destructiveDark : destructiveLight;
  static Color error(bool isDark) => isDark ? errorDark : errorLight;
  static Color errorContainer(bool isDark) =>
      isDark ? errorContainerDark : errorContainerLight;
}
