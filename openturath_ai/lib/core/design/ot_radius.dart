import 'package:flutter/material.dart';

/// OpenTurath Design System v2 — Disciplined Radius System
/// Menghindari pembulatan berlebih yang membuat semua elemen tampak sebagai 'kotak kartu'.
class OTRadius {
  static const double input = 12.0;
  static const double card = 12.0;
  static const double sheet = 20.0;
  static const double dialog = 20.0;
  static const double chip = 999.0;
  static const double button = 12.0;

  static BorderRadius inputBorder = BorderRadius.circular(input);
  static BorderRadius cardBorder = BorderRadius.circular(card);
  static BorderRadius sheetBorder = const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius dialogBorder = BorderRadius.circular(dialog);
  static BorderRadius chipBorder = BorderRadius.circular(chip);
  static BorderRadius buttonBorder = BorderRadius.circular(button);
}


