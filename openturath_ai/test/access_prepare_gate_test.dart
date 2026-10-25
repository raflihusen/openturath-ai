import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/services/subscription_service.dart';
import 'package:openturath_ai/widgets/access_prepare_gate.dart';

Widget _host(Future<bool> Function()? ready, void Function(bool) onBuild) =>
    MaterialApp(
        home: Scaffold(
            body: AccessPrepareGate(
                isReady: ready,
                builder: (context, done, left, panel) {
                  onBuild(done);
                  return Column(
                      children: [Text(done ? 'SIAP' : 'TUNGGU $left'), panel]);
                })));

void main() {
  setUp(() => AppConfig.localeNotifier.value = 'id');

  testWidgets('tanpa pemeriksaan kesiapan, penahan berlaku penuh 30 detik',
      (tester) async {
    await tester.pumpWidget(_host(null, (_) {}));
    await tester.pump(const Duration(seconds: 29));
    expect(find.textContaining('TUNGGU'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('SIAP'), findsOneWidget);
  });

  testWidgets(
      'akses siap lebih awal melepas penahan, tetapi tidak sebelum 8 detik',
      (tester) async {
    await tester.pumpWidget(_host(() async => true, (_) {}));
    await tester.pump(const Duration(seconds: 5));
    expect(find.textContaining('TUNGGU'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('SIAP'), findsOneWidget);
  });

  testWidgets('belum siap atau galat: tetap menunggu sampai batas 30 detik',
      (tester) async {
    await tester.pumpWidget(_host(() async => throw StateError('x'), (_) {}));
    await tester.pump(const Duration(seconds: 15));
    expect(find.textContaining('TUNGGU'), findsOneWidget);
    await tester.pump(const Duration(seconds: 16));
    expect(find.text('SIAP'), findsOneWidget);
  });

  test(
      'alasan terstruktur dari server diterjemahkan, bukan dijadikan "tidak aktif"',
      () {
    AppConfig.localeNotifier.value = 'id';
    String msg(String code, String reason) =>
        SubscriptionService.redeemErrorMessage(
            code, 'pesan server', {'reason': reason});
    expect(msg('failed-precondition', 'trial_active'), contains('Masa coba'));
    expect(msg('failed-precondition', 'needs_google'), contains('Google'));
    expect(msg('failed-precondition', 'misconfigured'), contains('admin'));
    expect(msg('resource-exhausted', 'rate_limited'),
        contains('Terlalu banyak percobaan'));
    expect(msg('resource-exhausted', 'quota'), contains('Kuota'));
    expect(msg('failed-precondition', 'inactive'), contains('tidak aktif'));
    AppConfig.localeNotifier.value = 'en';
    expect(msg('failed-precondition', 'trial_active'), contains('trial'));
    AppConfig.localeNotifier.value = 'id';
  });
}
