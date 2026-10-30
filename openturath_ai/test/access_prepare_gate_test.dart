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
                builder: (context, done, left, panel, ready) {
                  onBuild(ready);
                  return Column(children: [
                    Text(ready
                        ? 'SIAP'
                        : done
                            ? 'SELESAI TANPA KONFIRMASI'
                            : 'TUNGGU $left'),
                    panel
                  ]);
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

  testWidgets(
      'belum siap atau galat: setelah 30 detik tidak pernah dinyatakan siap',
      (tester) async {
    await tester.pumpWidget(_host(() async => throw StateError('x'), (_) {}));
    await tester.pump(const Duration(seconds: 15));
    expect(find.textContaining('TUNGGU'), findsOneWidget);
    await tester.pump(const Duration(seconds: 16));
    expect(find.text('SIAP'), findsNothing);
    expect(find.text('SELESAI TANPA KONFIRMASI'), findsOneWidget);
  });

  testWidgets('hasil pemeriksaan terakhir tetap terbit setelah timer berhenti',
      (tester) async {
    final last = Completer<bool>();
    var calls = 0;
    await tester.pumpWidget(_host(() {
      calls++;
      return calls == 11 ? last.future : Future.value(false);
    }, (_) {}));
    for (var second = 0; second < 30; second++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(calls, 11);
    expect(find.text('SELESAI TANPA KONFIRMASI'), findsOneWidget);
    last.complete(true);
    await tester.pump();
    expect(find.text('SIAP'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hasil pemeriksaan terlambat aman setelah layar ditutup',
      (tester) async {
    final pending = Completer<bool>();
    await tester.pumpWidget(_host(() => pending.future, (_) {}));
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(true);
    await tester.pump();
    expect(tester.takeException(), isNull);
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
import 'dart:async';

