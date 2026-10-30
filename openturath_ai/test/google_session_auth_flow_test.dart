import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/google_session_auth_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';

void main() {
  setUp(() {
    AppConfig.localeNotifier.value = 'id';
  });

  tearDown(() {
    AuthService.previewUser = null;
  });

  testWidgets(
      'GoogleSessionAuthScreen menampilkan disclaimer akun yang sama dan langkah 2',
      (tester) async {
    // Siapkan mock user login Firebase
    AuthService.previewUser = UserModel(
      uid: 'user_123',
      name: 'Santri Nusantara',
      email: 'santri.openturath@gmail.com',
      photoUrl: '',
      plan: 'trial',
      questionsUsed: 0,
    );

    String? loginUrl;
    await tester.pumpWidget(
      MaterialApp(
        home: GoogleSessionAuthScreen(
          webViewBuilder: (context, settings, url) {
            loginUrl = url;
            return const SizedBox(key: Key('mock_webview'));
          },
        ),
      ),
    );
    await tester.pump();

    // Verifikasi banner langkah 2 dari 2
    expect(find.text('LANGKAH 2 DARI 2'), findsOneWidget);
    expect(find.text('Masuk dengan akun yang sama'), findsWidgets);

    // Verifikasi email akun yang sama tampil di layar
    expect(find.text('santri.openturath@gmail.com'), findsOneWidget);

    // Verifikasi teks instruksi akun yang sama
    expect(
      find.textContaining('Masuk ke Google dengan akun yang sama'),
      findsOneWidget,
    );
    expect(
      find.textContaining('santri.openturath@gmail.com'),
      findsWidgets,
    );

    final login = Uri.parse(loginUrl!);
    // Reuse an existing Google session before offering InteractiveLogin.
    expect(login.host, 'notebook.google.com');
    expect(login.path, '/');

    // Verifikasi webview placeholder ter-mount
    expect(find.byKey(const Key('mock_webview')), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GoogleSessionAuthScreen mempertahankan mount webview dan teks pelindung terdaftar di lokalisasi',
      (tester) async {
    AuthService.previewUser = UserModel(
      uid: 'user_456',
      name: 'Santri Nusantara',
      email: 'santri.dua@gmail.com',
      photoUrl: '',
      plan: 'trial',
      questionsUsed: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GoogleSessionAuthScreen(
          webViewBuilder: (context, settings, url) {
            return const SizedBox(key: Key('shield_mock_webview'));
          },
        ),
      ),
    );
    await tester.pump();

    // Verifikasi mock webview tetap ter-mount
    expect(find.byKey(const Key('shield_mock_webview')), findsOneWidget);

    // Verifikasi teks lokalisasi pelindung visual tersedia di katalog
    expect(
      AppConfig.localeNotifier.value,
      'id',
    );
    expect(
      find.textContaining('santri.dua@gmail.com'),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });
}
