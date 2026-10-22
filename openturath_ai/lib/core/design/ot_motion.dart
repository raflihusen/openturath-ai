import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// OpenTurath Design System v2 — Quiet Motion & Haptics
/// Gerakan tenang yang tidak mendominasi konsentrasi dialog ilmiah santri.
class OTMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration sheet = Duration(milliseconds: 280);
  static const Duration transition = Duration(milliseconds: 320);

  // ── Gerak pembuka, memuat, dan login ──
  // Dicerminkan dari `motion/src/spec.ts` (Remotion). Ubah keduanya bersama.
  static const int splashTotalMs = 1400;
  static const Duration splashTotal = Duration(milliseconds: splashTotalMs);

  /// Splash tidak menahan navigasi lebih lama dari ini.
  static const Duration splashHold = Duration(milliseconds: 900);
  static const int splashDrawStartMs = 0;
  static const int splashDrawEndMs = 600;
  static const int splashMarkStartMs = 380;
  static const int splashMarkEndMs = 860;
  static const int splashEchoStartMs = 460;
  static const int splashEchoStaggerMs = 110;
  static const int splashEchoDurationMs = 760;
  static const int splashEchoCount = 3;
  static const int splashWordStartMs = 700;
  static const int splashWordEndMs = 1150;
  static const double splashWordShift = 8;

  static const Duration loaderLoop = Duration(milliseconds: 1800);
  static const double loaderSweep = 0.22;

  static const int loginLayerStaggerMs = 60;
  static const int loginLayerDurationMs = 420;
  static const int loginGlowEndMs = 900;
  static const int loginHeadlineMs = 520;
  static const int loginSubtitleMs = 760;
  static const int loginButtonMs = 880;
  static const int loginLegalMs = 1000;
  static const int loginRevealMs = 420;

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
    HapticFeedback.mediumImpact();
  }
}
