import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/google_connection_flow.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/google_session_auth_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';

void main() {
  setUp(() {
    AppConfig.localeNotifier.value = 'id';
    AuthService.previewUser = UserModel(
      uid: 'user_mock',
      name: 'Santri Nusantara',
      email: 'santri.mock@gmail.com',
      photoUrl: '',
      plan: 'trial',
      questionsUsed: 0,
    );
  });

  tearDown(() {
    AuthService.previewUser = null;
  });

  testWidgets(
      'GoogleSessionAuthScreen pada alur masuk aplikasi (appEntry) memuat login NotebookLM resmi tanpa banner Langkah 2',
      (tester) async {
    String? loginUrl;
    await tester.pumpWidget(
      MaterialApp(
        home: GoogleSessionAuthScreen(
          purpose: GoogleConnectionPurpose.appEntry,
          webViewBuilder: (context, settings, url) {
            loginUrl = url;
            return const SizedBox(key: Key('mock_webview'));
          },
        ),
      ),
    );
    await tester.pump();

    // Verifikasi alur 1 login: tidak ada banner "LANGKAH 2 DARI 2"
    expect(find.text('LANGKAH 2 DARI 2'), findsNothing);
    expect(find.text('Masuk ke OpenTurath'), findsOneWidget);

    final login = Uri.parse(loginUrl!);
    expect(login.host, 'notebook.google.com');
    expect(login.path, '/login');
    expect(login.queryParameters['continue'], 'https://notebook.google.com/');

    // Verifikasi webview placeholder ter-mount
    expect(find.byKey(const Key('mock_webview')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'GoogleSessionAuthScreen pada alur bilik AI (aiRoom) menampilkan panduan akun yang sama',
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
          purpose: GoogleConnectionPurpose.aiRoom,
          webViewBuilder: (context, settings, url) {
            return const SizedBox(key: Key('shield_mock_webview'));
          },
        ),
      ),
    );
    await tester.pump();

    // Verifikasi mock webview tetap ter-mount
    expect(find.byKey(const Key('shield_mock_webview')), findsOneWidget);

    // Verifikasi email akun yang sama tampil di panduan
    expect(
      find.textContaining('santri.dua@gmail.com'),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });
}
