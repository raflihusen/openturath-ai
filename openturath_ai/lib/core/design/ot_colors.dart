import 'package:flutter/material.dart';

/// OpenTurath Design System — Monochrome Editorial Palette
/// Prinsip Karakter Visual: Perpustakaan digital turath, ruang telaah akademik, dan katalog kitab modern.
/// Bukan: SaaS generik, fintech, AI neon/gradient, ataupun kartu warna-warni.
/// Kedalaman dibangun melalui kontras, tipografi, ruang kosong, hairline border, dan tekstur kertas arsip.
class OTColors {
  // ── 1. Light Mode (Warm Archival Paper) ──
  static const Color canvasLight = Color(0xFFF6F6F3); // Latar utama aplikasi (tekstur kertas arsip hangat)
  static const Color surfaceLight = Color(0xFFFFFFFF); // Panel utama, bottom sheet, dialog, kartu, input field
  static const Color surfaceSubtleLight = Color(0xFFEEEEEB); // Area sekunder, track selector, header list
  static const Color textPrimaryLight = Color(0xFF171717); // Teks utama, heading, tombol primer (ink black)
  static const Color textSecondaryLight = Color(0xFF656560); // Metadata, deskripsi kitab, label sekunder
  static const Color textTertiaryLight = Color(0xFF92928C); // Placeholder, informasi minor, divider halus
  static const Color borderLight = Color(0xFFDDDDD8); // Garis pembatas standar (1.0px hairline)
  static const Color borderSubtleLight = Color(0xFFEEEEEB);
  static const Color borderStrongLight = Color(0xFFB8B8B1); // Garis aktif, state fokus, pemisah penting
  static const Color accentLight = Color(0xFF171717); // Ink black

  // ── 2. Dark Mode (Quiet Obsidian Scholar) ──
  static const Color canvasDark = Color(0xFF111110); // Latar utama aplikasi (obsidian hangat)
  static const Color surfaceDark = Color(0xFF181817); // Panel utama, sheet, dialog, kartu
  static const Color surfaceSubtleDark = Color(0xFF222220); // Area sekunder, background chip
  static const Color textPrimaryDark = Color(0xFFF4F4F0); // Teks utama, heading, tombol inverse
  static const Color textSecondaryDark = Color(0xFFB2B2AA); // Metadata, deskripsi
  static const Color textTertiaryDark = Color(0xFF85857F); // Placeholder, label minor
  static const Color borderDark = Color(0xFF30302E); // Garis pembatas standar (1.0px)
  static const Color borderSubtleDark = Color(0xFF222220);
  static const Color borderStrongDark = Color(0xFF4B4B47); // Garis aktif, pemisah seksi
  static const Color accentDark = Color(0xFFF4F4F0); // Clean white

  // ── 3. Sovereign Amber (Khusus Penanda Khazanah Tahawwulat) ──
  static const Color sovereignAmber = Color(0xFFD97706);
  static const Color sovereignAmberBg = Color(0x1AD97706);

  // ── 4. Semantic Status Fungsional (Bukan Dekorasi) ──
  static const Color success = Color(0xFF10B981); // Hijau status fungsional
  static const Color destructive = Color(0xFFDC2626); // Merah peringatan/hapus/error

  // ── 5. Context-Aware Adaptive Helpers ──
  static Color canvas(bool isDark) => isDark ? canvasDark : canvasLight;
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceSubtle(bool isDark) => isDark ? surfaceSubtleDark : surfaceSubtleLight;
  static Color border(bool isDark) => isDark ? borderDark : borderLight;
  static Color borderStrong(bool isDark) => isDark ? borderStrongDark : borderStrongLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color textTertiary(bool isDark) => isDark ? textTertiaryDark : textTertiaryLight;
  static Color accent(bool isDark) => isDark ? accentDark : accentLight;
}
