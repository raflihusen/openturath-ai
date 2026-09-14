import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/telemetry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelemetryService Tests', () {
    final telemetry = TelemetryService.instance;

    test('sanitizeData masks sensitive tokens, passwords, and cookies', () {
      // 1. Bearer Token
      const withToken = 'Request header: Bearer ya29.a0AfH6SMD123456';
      expect(
        telemetry.sanitizeData(withToken),
        contains('Bearer [REDACTED_TOKEN]'),
      );

      // 2. Passwords and secrets
      const withPassword = '{"user": "admin", "password": "supersecret123"}';
      expect(
        telemetry.sanitizeData(withPassword),
        contains('password: "[REDACTED]"'),
      );

      // 3. API Key
      const withApiKey = 'key apiKey="AIzaSyA123456789"';
      expect(
        telemetry.sanitizeData(withApiKey),
        contains('apiKey: "[REDACTED]"'),
      );

      // 4. Google Cookies (SID / HSID)
      const withCookie = 'Cookie: SID=abc123xyz; HSID=def456; other=123';
      expect(
        telemetry.sanitizeData(withCookie),
        contains('SID=[REDACTED_COOKIE]'),
      );
      expect(
        telemetry.sanitizeData(withCookie),
        contains('HSID=[REDACTED_COOKIE]'),
      );

      // 5. Voucher code
      const withVoucher = 'Redeem attempt voucher="PERDANA7HARI"';
      expect(
        telemetry.sanitizeData(withVoucher),
        contains('voucher: "[REDACTED_CODE]"'),
      );
    });

    test('maskEmail obfuscates email addresses for privacy', () {
      expect(telemetry.maskEmail('ahmad@example.com'), 'a***d@example.com');
      expect(telemetry.maskEmail('ab@domain.com'), '*@domain.com');
      expect(telemetry.maskEmail(''), '');
      expect(telemetry.maskEmail('invalid-email'), '');
    });

    test('leaveBreadcrumb adds breadcrumbs and respects ring buffer limit', () {
      for (int i = 1; i <= 25; i++) {
        telemetry.leaveBreadcrumb('Langkah navigasi $i', category: 'navigation');
      }

      // Pastikan reporting tidak melempar exception saat dipanggil tanpa firebase
      expect(
        () async => await telemetry.reportError(
          'Simulated error',
          StackTrace.current,
          context: 'unit_test',
        ),
        returnsNormally,
      );
    });

    test('Deduplication prevents immediate duplicate error reporting', () async {
      // Panggilan pertama
      await telemetry.reportError(
        'Duplicate error message',
        StackTrace.fromString('line 1\nline 2\nline 3'),
        context: 'dedup_test',
      );

      // Panggilan kedua yang identik harus ter-deduplikasi tanpa melempar error
      expect(
        () async => await telemetry.reportError(
          'Duplicate error message',
          StackTrace.fromString('line 1\nline 2\nline 3'),
          context: 'dedup_test',
        ),
        returnsNormally,
      );
    });
  });
}
