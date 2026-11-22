import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/notebook_navigation.dart';

void main() {
  group('NotebookNavigation', () {
    test('notebook URLs are identified as notebook and NOT signInFlow', () {
      final notebookUri =
          Uri.parse('https://notebooklm.google.com/notebook/abc-123-xyz');
      expect(NotebookNavigation.notebook(notebookUri), isTrue);
      expect(NotebookNavigation.allowed(notebookUri), isTrue);
      expect(NotebookNavigation.signInFlow(notebookUri), isFalse);
    });

    test('Google sign-in URLs are identified as signInFlow and NOT notebook',
        () {
      final signInUri = Uri.parse('https://accounts.google.com/ServiceLogin');
      final v3SignInUri =
          Uri.parse('https://accounts.google.com/v3/signin/identifier');
      expect(NotebookNavigation.notebook(signInUri), isFalse);
      expect(NotebookNavigation.signInFlow(signInUri), isTrue);
      expect(NotebookNavigation.notebook(v3SignInUri), isFalse);
      expect(NotebookNavigation.signInFlow(v3SignInUri), isTrue);
    });

    test('Notebook host with login path is recognized as authentication', () {
      final notebookLoginUri = Uri.parse('https://notebooklm.google.com/login');
      expect(NotebookNavigation.authentication(notebookLoginUri), isTrue);
      expect(NotebookNavigation.notebook(notebookLoginUri), isFalse);
      expect(NotebookNavigation.signInFlow(notebookLoginUri), isTrue);
    });

    test('Notebook hosts (including /login) are never interactive Google sign-in',
        () {
      for (final raw in [
        'https://notebook.google.com/',
        'https://notebook.google.com/login',
        'https://notebooklm.google.com/',
        'https://notebooklm.google.com/login',
      ]) {
        final uri = Uri.parse(raw);
        expect(NotebookNavigation.isNotebookHost(uri), isTrue, reason: raw);
        expect(NotebookNavigation.isInteractiveGoogleSignIn(uri), isFalse,
            reason: raw);
      }

      expect(
        NotebookNavigation.isInteractiveGoogleSignIn(
            Uri.parse('https://myaccount.google.com/')),
        isFalse,
      );
      expect(
        NotebookNavigation.isInteractiveGoogleSignIn(
            Uri.parse('https://accounts.google.com/v3/signin/identifier')),
        isTrue,
      );
      expect(
        NotebookNavigation.isInteractiveGoogleSignIn(
            Uri.parse('https://accounts.google.com/ServiceLogin')),
        isTrue,
      );
      expect(
        NotebookNavigation.isInteractiveGoogleSignIn(
            Uri.parse('https://consent.google.com/ml')),
        isTrue,
      );
    });

    test('directGoogleLoginUrl goes straight to accounts.google.com/ServiceLogin',
        () {
      final url = Uri.parse(
        NotebookNavigation.directGoogleLoginUrl(email: 'santri@example.com'),
      );
      expect(url.scheme, 'https');
      expect(url.host, 'accounts.google.com');
      expect(url.path, '/ServiceLogin');
      expect(url.queryParameters['continue'], 'https://notebook.google.com/');
      expect(url.queryParameters['Email'], 'santri@example.com');
    });
  });
}
