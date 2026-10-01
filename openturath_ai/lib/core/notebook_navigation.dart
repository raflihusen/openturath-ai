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

  // Google OAuth must run in a supported browser, never in this app WebView.
  static bool allowed(Uri uri) =>
      _trustedHttps(uri) &&
      hosts.contains(uri.host.toLowerCase()) &&
      !authentication(uri);

  static bool notebook(Uri uri) => allowed(uri);
}
