import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/models/user_model.dart';
import 'package:openturath_ai/screens/google_session_auth_screen.dart';
import 'package:openturath_ai/services/auth_service.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
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
    expect(find.text('Autentikasi Ruang AI Google'), findsOneWidget);

    // Verifikasi email akun yang sama tampil di disclaimer
    expect(find.text('santri.openturath@gmail.com'), findsOneWidget);

    // Verifikasi teks disclaimer pencegahan salah akun
    expect(
      find.textContaining(
          'Silakan masuk ke Google sekali lagi menggunakan akun yang sama'),
      findsOneWidget,
    );
    expect(
      find.textContaining('santri.openturath@gmail.com'),
      findsWidgets,
    );

    final login = Uri.parse(loginUrl!);
    expect(login.host, 'accounts.google.com');
    expect(login.queryParameters['continue'], 'https://notebook.google.com/');

    // Verifikasi webview placeholder ter-mount
    expect(find.byKey(const Key('mock_webview')), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
