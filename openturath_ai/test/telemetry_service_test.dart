import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/telemetry_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final telemetry = TelemetryService.instance;

  test('free text removes credentials, quoted secrets, emails and URL query data', () {
    final safe = telemetry.sanitizeData(
      'Bearer abc123.456 password="two secret words" apiKey=key123 '
      'Cookie: SID=cookie123; HSID=secondCookie '
      'ahmad@example.com https://user:pass@example.com/private/path?q=private-query#fragment '
      '/relative?search=private-search');
    for (final secret in ['abc123.456', 'two secret words', 'key123', 'cookie123',
      'secondCookie', 'ahmad@example.com', 'user:pass', '/private/path', 'private-query', 'fragment', 'private-search']) {
      expect(safe, isNot(contains(secret)), reason: secret);
    }
  });

  test('structured secrets are redacted by key through nested maps and lists', () {
    final safe = telemetry.sanitizeValue({
      'headers': {'Authorization': 'unprefixed-secret', 'Set-Cookie': ['secret-cookie']},
      'details': [
        {'access_token': 'token-value', 'refreshToken': {'value': 'nested-secret'}},
        {'userEmail': 'name@example.com', 'noteBody': 'private scholarly note', 'attempt': 2},
      ],
      'link': 'https://example.com/path?value=private',
      'summary': 'raw exception containing arbitrary private data',
    }) as Map<String, dynamic>;
    final encoded = jsonEncode(safe);
    for (final secret in ['unprefixed-secret', 'secret-cookie', 'token-value',
      'nested-secret', 'name@example.com', 'private scholarly note', 'value=private', 'arbitrary private data']) {
      expect(encoded, isNot(contains(secret)), reason: secret);
    }
    expect(safe['details'][1]['attempt'], 2);
  });

  test('email helper retains neither address nor domain', () {
    expect(telemetry.maskEmail('ahmad@example.com'), '[REDACTED_EMAIL]');
    expect(telemetry.maskEmail(''), '');
    expect(telemetry.maskEmail('invalid-email'), '');
  });

  test('recursive structures are bounded', () {
    final recursive = <String, dynamic>{};
    recursive['next'] = recursive;
    expect(jsonEncode(telemetry.sanitizeValue(recursive)), contains('[TRUNCATED]'));
    expect((telemetry.sanitizeValue(List.filled(200, 1)) as List).length, 100);
  });

  test('reporting and breadcrumbs remain safe without Firebase', () async {
    for (var i = 0; i < 25; i++) {
      telemetry.leaveBreadcrumb('Navigation $i', category: 'navigation');
    }
    await expectLater(telemetry.reportError(StateError('test'), StackTrace.current,
      context: 'unit_test'), completes);
  });
}
