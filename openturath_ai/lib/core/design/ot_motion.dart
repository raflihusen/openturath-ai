import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// OpenTurath Design System v2 — Quiet Motion & Haptics
/// Gerakan tenang yang tidak mendominasi konsentrasi telaah ilmiah santri.
class OTMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration sheet = Duration(milliseconds: 280);
  static const Duration transition = Duration(milliseconds: 320);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve sheetCurve = Curves.easeOutQuart;

  // ── Scholarly Haptic Feedback ──
  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void light() {
    HapticFeedback.lightImpact();
  }

  static void success() {
    HapticFeedback.selectionClick();
  }
}


