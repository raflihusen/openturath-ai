import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/auth_failure_reporter.dart';

void main() {
  test('payload hanya memuat kode tetap; nilai liar menjadi unknown', () {
    final p = AuthFailureReporter.payload(
        stage: 'firebase-credential',
        code: 'invalid-credential',
        category: 'user@example.com token=abc',
        platform: 'windows');
    expect(p['category'], 'unknown');
    expect(p['code'], 'invalid-credential');
    expect(p.values.join(' '), isNot(contains('@')));
  });
}
