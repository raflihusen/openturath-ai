import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Disciplined Radius System
/// Menghindari pembulatan berlebih yang membuat semua elemen tampak sebagai 'kotak kartu'.
class OTRadius {
  static const double hero = 32.0;
  static const double xs = 8.0; // Tag persegi, pegangan, butir daftar
  static const double input = 28.0;
  static const double card = 24.0;
  static const double sheet = 32.0;
  static const double dialog = 28.0;
  static const double chip = 999.0;
  static const double button = 999.0;

  static BorderRadius xsBorder = BorderRadius.circular(xs);
  static BorderRadius inputBorder = BorderRadius.circular(input);
  static BorderRadius cardBorder = BorderRadius.circular(card);
  static BorderRadius sheetBorder =
      const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius dialogBorder = BorderRadius.circular(dialog);
  static BorderRadius chipBorder = BorderRadius.circular(chip);
  static BorderRadius buttonBorder = BorderRadius.circular(button);
}
