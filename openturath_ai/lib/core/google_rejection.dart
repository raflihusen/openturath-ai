import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Mengenali halaman penolakan Google ("Couldn't sign you in") dari alamat
/// atau teksnya. Hanya membaca; tidak mengubah halaman, cookie, atau sesi.
const googleRejectionPhrases = [
  "couldn't sign you in",
  'browser or app may not be secure',
  "browser doesn't support javascript",
  'tidak dapat membuat anda login',
  'tidak bisa login',
];

bool isGoogleRejectionText(String text) {
  final lower = text.toLowerCase();
  return googleRejectionPhrases.any(lower.contains);
}

Future<bool> isGoogleRejectionPage(
    InAppWebViewController controller, WebUri url) async {
  if (!url.host.toLowerCase().endsWith('accounts.google.com')) return false;
  if (url.path.contains('/signin/rejected')) return true;
  try {
    final text = await controller
        .evaluateJavascript(
            source:
                "(document.body&&document.body.innerText||'').slice(0,2000)")
        .timeout(const Duration(seconds: 3));
    return isGoogleRejectionText('${text ?? ''}');
  } catch (_) {
    return false;
  }
}
