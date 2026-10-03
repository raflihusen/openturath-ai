class AppConstants {
  // ── App Info ──────────────────────────────────────────────────
  static const String appName = 'OpenTurath AI';
  static const String appNameArabic = 'الذكاء الاصطناعي للعلوم الإسلامية';
  static const String appTagline = 'AI for Islamic Scholarship';

  // ── User Agent Desktop Resmi (Safari macOS untuk WKWebView) ──
  static const String desktopSafariUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15';

  // ── Chrome Mobile User Agent Resmi (Android WebView) ──
  static const String chromeMobileUserAgent =
      'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

  // ── Firestore Collections ─────────────────────────────────────
  static const String colUsers = 'users';
  static const String colAgents = 'agents';
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
  static const int priceTholib1m = 50000;
  static const int priceTholib6m = 299000;
  static const int priceBahits1y = 499000;
  static const int priceAllAiPromo1m = 99000; // Dinonaktifkan sementara
}
