/// App entry and AI recovery have different completion requirements.
enum GoogleConnectionPurpose { appEntry, aiRoom }

enum GoogleConnectionResult {
  verified,
  appEntered,
  deferred;

  /// Accept old route results while callers migrate to the explicit contract.
  static bool canResumeAi(Object? result) =>
      result == verified || result == true;
}

abstract final class GoogleConnectionNavigation {
  /// A return-to-app signal only. This never verifies the WebView account.
  static bool isAccountPage(Uri uri) {
    if (uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        uri.host.toLowerCase() != 'myaccount.google.com') {
      return false;
    }
    const authenticationSteps = {
      'signin', 'challenge', 'reauth', 'rejected', 'intro',
    };
    return !uri.pathSegments
        .map((part) => part.toLowerCase())
        .any(authenticationSteps.contains);
  }
}
