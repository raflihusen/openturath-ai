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
  // Loader dan login dicerminkan dari `motion/src/spec.ts` (Remotion). Splash
  // kini hanya didefinisikan di sini; konstanta SPLASH di Remotion arsip lama.
  static const int splashTotalMs = 2700;
  static const Duration splashTotal = Duration(milliseconds: splashTotalMs);

  /// Splash tidak menahan navigasi lebih lama dari ini; ketuk untuk melewati.
  static const Duration splashHold = Duration(milliseconds: splashTotalMs);

  /// Gerak dikurangi: hanya bingkai akhir, tahan sebentar.
  static const Duration splashHoldStill = Duration(milliseconds: 700);

  // Urutan (ms): kitab naik satu per satu, lengkung digambar menaunginya,
  // kitab melebur menjadi logo (lengkung terisi, kubah naik, dua halaman
  // terbuka), wordmark huruf demi huruf, garis tipis, lalu semboyan.
  static const int splashShelfStaggerMs = 80;
  static const int splashShelfRiseMs = 520;
  static const int splashDrawStartMs = 450;
  static const int splashDrawEndMs = 1050;
  static const int splashFillStartMs = 950;
  static const int splashFillEndMs = 1300;
  static const int splashDomeStartMs = 1100;
  static const int splashDomeEndMs = 1500;
  static const int splashPagesStartMs = 1300;
  static const int splashPagesEndMs = 1700;
  static const int splashWordStartMs = 1500;
  static const int splashWordLetterMs = 360;
  static const int splashWordStaggerMs = 45;
  static const int splashRuleStartMs = 1950;
  static const int splashRuleEndMs = 2300;
  static const int splashTagStartMs = 2100;
  static const int splashTagEndMs = 2700;

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
