import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Disciplined Radius System
/// Menghindari pembulatan berlebih yang membuat semua elemen tampak sebagai 'kotak kartu'.
class OTRadius {
  static const double row = 12.0;
  static const double input = 14.0;
  static const double card = 20.0;
  static const double feature = 26.0;
  static const double sheet = 28.0;
  static const double dialog = 20.0;
  static const double chip = 10.0;
  static const double button = 14.0;

  static BorderRadius rowBorder = BorderRadius.circular(row);
  static BorderRadius inputBorder = BorderRadius.circular(input);
  static BorderRadius cardBorder = BorderRadius.circular(card);
  static BorderRadius featureBorder = BorderRadius.circular(feature);
  static BorderRadius sheetBorder =
      const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius dialogBorder = BorderRadius.circular(dialog);
  static BorderRadius chipBorder = BorderRadius.circular(chip);
  static BorderRadius buttonBorder = BorderRadius.circular(button);
}
