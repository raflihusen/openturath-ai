import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/notebook_navigation.dart';
void main() {
  test('A11 exact HTTPS authentication hosts allowed', () {
    for (final host in ['notebooklm.google.com', 'accounts.google.com', 'accounts.youtube.com']) {
      expect(NotebookNavigation.allowed(Uri.parse('https://$host/')), isTrue);
    }
  });
  test('A11 user content origins, custom ports and deceptive URLs blocked', () {
    for (final url in ['https://sites.google.com/site/phishing',
      'https://evil.googleusercontent.com/', 'https://accounts.google.com.evil.test/',
      'https://user@accounts.google.com/', 'https://accounts.google.com:8443/',
      'http://accounts.google.com/', 'javascript:alert(1)', 'file:///etc/passwd']) {
      expect(NotebookNavigation.allowed(Uri.parse(url)), isFalse, reason: url);
    }
  });
}
