import 'package:flutter/foundation.dart';

class AppConstants {
  // ── App Info ──────────────────────────────────────────────────
  static const String appName = 'OpenTurath AI';
  static const String appTagline = 'AI for Islamic Scholarship';

  // ── User Agent Desktop Resmi (Safari macOS / Chrome Windows) ──
  static const String desktopSafariUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15';

  static const String desktopWindowsUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';

  static String get desktopUserAgent =>
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS)
          ? desktopSafariUserAgent
          : desktopWindowsUserAgent;

  // ── Chrome Mobile User Agent Resmi (Android WebView) ──
  static const String chromeMobileUserAgent =
      'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

  // ── Firestore Collections ─────────────────────────────────────
  static const String colUsers = 'users';
  static const String colTransactions = 'transactions';

  // ── Subscription Plans ────────────────────────────────────────
  static const String planTrial = 'trial';
  static const String planTholib1m = 'tholib_1m';
  static const String planTholib6m = 'tholib_6m';
  static const String planBahits1y = 'bahits_1y';

  // ── Firebase Cloud Functions ───────────────────────────────────
  static const String fnGetAgentUrl = 'getAgentUrl';
  static const String fnCreatePayment = 'createCheckout';
  static const String fnCheckPaymentStatus = 'checkPaymentStatus';

  // ── Pricing (Rupiah) ──────────────────────────────────────────
  static const int priceTholib1m = 49000;
  static const int priceTholib6m = 249000;
  static const int priceBahits1y = 499000;
}
