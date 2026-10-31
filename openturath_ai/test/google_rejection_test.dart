import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/google_rejection.dart';

void main() {
  test('halaman penolakan Google dikenali tanpa peka huruf', () {
    expect(isGoogleRejectionText("Couldn't sign you in"), isTrue);
    expect(
        isGoogleRejectionText('This BROWSER or app may not be secure.'), isTrue);
    expect(isGoogleRejectionText("Your browser doesn't support JavaScript"),
        isTrue);
  });

  test('halaman masuk biasa tidak dianggap penolakan', () {
    expect(isGoogleRejectionText('Sign in\nUse your Google Account'), isFalse);
    expect(isGoogleRejectionText(''), isFalse);
  });
}
