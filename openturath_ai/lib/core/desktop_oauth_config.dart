/// Klien OAuth jenis Desktop (proyek open-turath) untuk login Google di Windows.
///
/// Rahasia klien aplikasi desktop tidak bersifat rahasia sungguhan menurut Google
/// (RFC 8252): keamanan alurnya dijaga PKCE dan redirect loopback 127.0.0.1. Nilai dapat
/// diganti saat build: --dart-define=DESKTOP_OAUTH_CLIENT_ID=... --dart-define=DESKTOP_OAUTH_CLIENT_SECRET=...
class DesktopOAuthConfig {
  static const clientId = String.fromEnvironment(
    'DESKTOP_OAUTH_CLIENT_ID',
    defaultValue:
        '255541559800-vlqgf0ofi3oth9qiprge1623ku438q5p.apps.googleusercontent.com',
  );
  static const clientSecret = String.fromEnvironment(
    'DESKTOP_OAUTH_CLIENT_SECRET',
    defaultValue: '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',
  );
}
