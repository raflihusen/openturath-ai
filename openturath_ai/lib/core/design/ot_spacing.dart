import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Spacing Tokens (Base-4 Rhythm)
/// Menolak angka acak (13, 19, 27, 31). Menggunakan ritme proporsional kelipatan 4.
class OTSpacing {
  static const double xxs = 2.0; // Celah optis terkecil
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
  static const double jumbo = 64.0;

  // ── Standard Padding Presets ──
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(vertical: base);
  static const EdgeInsets card = EdgeInsets.all(base);
  static const EdgeInsets cardCompact = EdgeInsets.all(md);
  static const EdgeInsets row = EdgeInsets.symmetric(horizontal: base, vertical: md);

  // ── Gap Widgets ──
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapBase = SizedBox(height: base, width: base);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);
  static const SizedBox gapHuge = SizedBox(height: huge, width: huge);
}
