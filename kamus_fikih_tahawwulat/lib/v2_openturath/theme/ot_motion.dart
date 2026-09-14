import 'package:flutter/material.dart';

/// OpenTurath Motion & Transition Standard
class OTMotion {
  static const Duration micro = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration sheet = Duration(milliseconds: 280);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;

  static const double pressedScale = 0.985;
}
