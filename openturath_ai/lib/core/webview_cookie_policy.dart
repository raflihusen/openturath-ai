import 'package:flutter/foundation.dart';

/// Keep macOS sessions in WebKit's persistent website data store.
///
/// The plugin's shared-cookie option copies Foundation's HTTP cookie jar into
/// WebKit when a view is created. Replaying that separate jar can overwrite
/// Google cookies refreshed by an existing WebView. WebKit already shares its
/// persistent store across these views without the Foundation bridge.
abstract final class WebViewCookiePolicy {
  static bool get sharedCookiesEnabled =>
      kIsWeb || defaultTargetPlatform != TargetPlatform.macOS;
}
