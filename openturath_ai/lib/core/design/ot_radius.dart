import 'package:flutter/material.dart';

/// OpenTurath radius scale.
///
/// Keep the silhouette quiet: small elements use 8, controls use 12, and
/// content panels use 16. A fully rounded shape is reserved for selection
/// chips and prominent single actions.
class OTRadius {
  static const double small = 8.0;
  static const double control = 12.0;
  static const double input = control;
  static const double card = 16.0;
  static const double sheet = 24.0;
  static const double dialog = 16.0;
  static const double chip = 999.0;
  static const double button = control;

  static BorderRadius smallBorder = BorderRadius.circular(small);
  static BorderRadius controlBorder = BorderRadius.circular(control);
  static BorderRadius inputBorder = BorderRadius.circular(input);
  static BorderRadius cardBorder = BorderRadius.circular(card);
  static BorderRadius sheetBorder =
      const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius dialogBorder = BorderRadius.circular(dialog);
  static BorderRadius chipBorder = BorderRadius.circular(chip);
  static BorderRadius buttonBorder = BorderRadius.circular(button);
}
