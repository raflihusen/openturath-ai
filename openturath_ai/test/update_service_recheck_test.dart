import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/update_service.dart';

void main() {
  final t0 = DateTime(2026, 10, 29, 10);

  test('pengecekan pertama selalu jalan', () {
    expect(
        UpdateService.shouldRecheck(now: t0, last: null, ready: false), isTrue);
  });

  test('tidak mengecek ulang sebelum jeda 30 menit', () {
    final soon = t0.add(const Duration(minutes: 29));
    expect(UpdateService.shouldRecheck(now: soon, last: t0, ready: false),
        isFalse);
  });

  test('mengecek ulang tepat di batas jeda dan sesudahnya', () {
    final edge = t0.add(UpdateService.recheckInterval);
    expect(
        UpdateService.shouldRecheck(now: edge, last: t0, ready: false), isTrue);
  });

  test('update yang sudah siap tidak dicek ulang (hindari kedip dialog)', () {
    final later = t0.add(const Duration(days: 2));
    expect(UpdateService.shouldRecheck(now: later, last: t0, ready: true),
        isFalse);
  });
}
