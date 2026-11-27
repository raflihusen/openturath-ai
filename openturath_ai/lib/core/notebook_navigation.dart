class NotebookNavigation {
  // Google redirects the legacy host here. Use the destination directly so
  // unavailable legacy DNS routes cannot prevent the redirect from starting.
  static const canonicalHost = 'notebook.google.com';
  static const canonicalOrigin = 'https://$canonicalHost';
  static const hosts = {
    'notebooklm.google.com',
    'notebook.google.com',
  };
  static const _authenticationHosts = {
    'accounts.google.com',
    'accounts.google.co.id',
    'myaccount.google.com',
    'accounts.youtube.com',
    'consent.google.com',
    'ogs.google.com',
  };
  static const authenticationMessage =
      'Koneksi AI di dalam aplikasi belum mendukung sesi akun ini. '
      'Login ulang OpenTurath tidak menyambungkan sesi AI. '
      'Silakan kembali ke beranda.';

  static bool _trustedHttps(Uri uri) =>
      uri.scheme == 'https' && uri.userInfo.isEmpty && uri.port == 443;

  static bool authentication(Uri uri) =>
      _trustedHttps(uri) &&
      (_authenticationHosts.contains(uri.host.toLowerCase()) ||
          (hosts.contains(uri.host.toLowerCase()) &&
              uri.path
                  .toLowerCase()
                  .split('/')
                  .any(const {'login', 'signin', 'servicelogin'}.contains)));

  /// Halaman milik Google yang dilewati selama proses masuk (verifikasi dua
  /// langkah, penyetelan sesi). Hanya HTTPS ke domain Google; halaman ini
  /// ditampilkan apa adanya, tanpa skrip dari aplikasi.
  static bool signInFlow(Uri uri) {
    if (notebook(uri)) return false;
    if (uri.scheme == 'about' || uri.scheme == 'data' || uri.scheme == 'blob') {
      return true;
    }
    if (!_trustedHttps(uri)) return false;
    final host = uri.host.toLowerCase();
    return authentication(uri) ||
        host == 'google.com' ||
        (host.endsWith('.google.com') && !hosts.contains(host)) ||
        host.endsWith('.google.co.id') ||
        host.endsWith('.gstatic.com') ||
        host.endsWith('.googleusercontent.com') ||
        host == 'accounts.youtube.com' ||
        host.endsWith('.googleapis.com') ||
        host.endsWith('.recaptcha.net') ||
        RegExp(r'^accounts\.google\.[a-z.]{2,6}$').hasMatch(host);
  }

  // Skrip aplikasi hanya berjalan di halaman notebook, tidak di halaman masuk.
  static bool allowed(Uri uri) =>
      _trustedHttps(uri) &&
      hosts.contains(uri.host.toLowerCase()) &&
      !authentication(uri);

  static bool notebook(Uri uri) => allowed(uri);

  static const _upsellHosts = {
    'one.google.com',
    'workspace.google.com',
    'pay.google.com',
    'store.google.com',
  };

  /// Benar jika URL adalah halaman penawaran/upgrade Google One atau Gemini Pro
  /// (mis. tombol "ترقية" / "Upgrade" saat kuota harian habis). Wajib diblokir.
  static bool isUpsellDestination(Uri uri) {
    final host = uri.host.toLowerCase();
    if (_upsellHosts.contains(host)) return true;
    final path = uri.path.toLowerCase();
    if (hosts.contains(host) || host == 'gemini.google.com') {
      return path.contains('/upgrade') ||
          path.contains('/plus') ||
          path.contains('/plans') ||
          path.contains('/pricing') ||
          path.contains('/subscriptions');
    }
    return false;
  }

  /// Benar untuk SEMUA halaman pada host Notebook (`notebook.google.com` /
  /// `notebooklm.google.com`), termasuk `/`, `/login`, dan `/notebook/...`.
  /// Tidak boleh pernah terekspos tanpa pelindung di layar masuk Google.
  static bool isNotebookHost(Uri uri) =>
      _trustedHttps(uri) && hosts.contains(uri.host.toLowerCase());

  /// Benar HANYA pada halaman masuk/OAuth/verifikasi interaktif milik Google
  /// (`accounts.google.*`, `consent.google.com`, `accounts.youtube.com`),
  /// dan TIDAK pernah benar pada host Notebook ataupun `myaccount.google.com`.
  static bool isInteractiveGoogleSignIn(Uri uri) {
    if (!_trustedHttps(uri)) return false;
    final host = uri.host.toLowerCase();
    if (hosts.contains(host) || host == 'myaccount.google.com') {
      return false;
    }
    return host == 'accounts.google.com' ||
        host == 'accounts.google.co.id' ||
        host == 'accounts.youtube.com' ||
        host == 'consent.google.com' ||
        RegExp(r'^accounts\.google\.[a-z.]{2,6}$').hasMatch(host);
  }

  /// URL masuk Google langsung ke `accounts.google.com/ServiceLogin` agar
  /// pengguna tidak pernah diarahkan ke landing page Gemini Notebook / NotebookLM.
  ///
  /// - Jika belum ada sesi Google: langsung menampilkan form resmi Google
  ///   ("Sign in — Use your Google Account").
  /// - Jika cookie sesi Google sudah aktif: otomatis dialihkan ke [continueUrl]
  ///   secara senyap di balik pelindung animasi OpenTurath.
  static String directGoogleLoginUrl({String? email, String? continueUrl}) {
    final cleanEmail = (email ?? '').trim();
    final targetContinue = (continueUrl ?? '').trim().isNotEmpty
        ? continueUrl!.trim()
        : '$canonicalOrigin/';
    return Uri.https('accounts.google.com', '/ServiceLogin', {
      'continue': targetContinue,
      if (cleanEmail.isNotEmpty) 'Email': cleanEmail,
    }).toString();
  }
}
