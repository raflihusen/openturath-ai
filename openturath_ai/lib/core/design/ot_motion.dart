import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// OpenTurath V6 — quiet motion shared by every native surface.
class OTMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 180);
  static const Duration sheet = Duration(milliseconds: 280);
  static const Duration transition = Duration(milliseconds: 320);
  static const Duration stagger = Duration(milliseconds: 45);

  static const Curve curve = Cubic(0.16, 1, 0.3, 1);
  static const Curve sheetCurve = Curves.easeOutQuart;
  static const double pressedScale = 0.985;

  // ── Scholarly Haptic Feedback ──
  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void light() {
    HapticFeedback.lightImpact();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }
}
