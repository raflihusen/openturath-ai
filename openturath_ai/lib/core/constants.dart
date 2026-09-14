class AppConstants {
  // ── App Info ──────────────────────────────────────────────────
  static const String appName = 'OpenTurath AI';
  static const String appNameArabic = 'الذكاء الاصطناعي للعلوم الإسلامية';
  static const String appTagline = 'Membaca kitab, menelusuri ibarah.';

  // ── Chrome Mobile User Agent Resmi (Mitigasi Error 403 Google) ──
  static const String chromeMobileUserAgent =
      'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.6613.127 Mobile Safari/537.36';

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
  static const int priceTholib1m = 49000;
  static const int priceTholib6m = 299000;
  static const int priceBahits1y = 499000;
  static const int priceAllAiPromo1m = 99000; // Dinonaktifkan sementara
}
