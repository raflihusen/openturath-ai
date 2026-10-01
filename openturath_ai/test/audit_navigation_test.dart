import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/notebook_navigation.dart';
void main() {
  test('only official HTTPS notebook hosts are allowed in the WebView', () {
    for (final host in [
      'notebooklm.google.com',
      'notebook.google.com',
    ]) {
      expect(NotebookNavigation.allowed(Uri.parse('https://$host/')), isTrue);
    }
  });
  test('Google auth hosts are recognized but blocked inside the WebView', () {
    for (final host in [
      'accounts.google.com',
      'accounts.google.co.id',
      'myaccount.google.com',
      'accounts.youtube.com',
      'consent.google.com',
      'ogs.google.com',
    ]) {
      final uri = Uri.parse('https://$host/ServiceLogin');
      expect(NotebookNavigation.authentication(uri), isTrue);
      expect(NotebookNavigation.allowed(uri), isFalse);
      expect(NotebookNavigation.notebook(uri), isFalse);
    }
  });
  test('notebook sign-in routes cannot receive notebook scripts', () {
    for (final path in ['/login', '/signin', '/ServiceLogin', '/u/0/signin']) {
      final uri = Uri.parse('https://notebooklm.google.com$path');
      expect(NotebookNavigation.authentication(uri), isTrue);
      expect(NotebookNavigation.notebook(uri), isFalse);
    }
    final deceptive = Uri.parse('https://accounts.google.com.attacker.invalid/');
    expect(NotebookNavigation.authentication(deceptive), isFalse);
    expect(NotebookNavigation.allowed(deceptive), isFalse);
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
