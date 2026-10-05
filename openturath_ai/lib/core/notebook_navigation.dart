class NotebookNavigation {
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
      'Koneksi asisten di dalam aplikasi belum mendukung sesi akun ini. '
      'Login ulang OpenTurath tidak menyambungkan sesi asisten. '
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
    if (uri.scheme == 'about' || uri.scheme == 'data' || uri.scheme == 'blob') {
      return true;
    }
    if (!_trustedHttps(uri)) return false;
    final host = uri.host.toLowerCase();
    return authentication(uri) ||
        host == 'google.com' ||
        host.endsWith('.google.com') ||
        host.endsWith('.google.co.id') ||
        host.endsWith('.gstatic.com') ||
        host.endsWith('.googleusercontent.com') ||
        host.endsWith('.youtube.com') ||
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
}
