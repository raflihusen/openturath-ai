import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/screens/subscription_screen.dart';

// Mulai berjalan: Senin, 26 Okt 2026, 20:00 WIB = 13:00 UTC.
DateTime _beforeStart() => DateTime.utc(2026, 10, 26, 12, 59);
DateTime _atStart() => DateTime.utc(2026, 10, 26, 13);
DateTime _duringOffer() => DateTime.utc(2026, 10, 28, 5, 30, 15);
DateTime _afterOffer() => DateTime.utc(2026, 11, 6);

Future<void> _pumpAt(WidgetTester tester, DateTime Function() clock,
    {double width = 800}) async {
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: PromoCountdownBanner(clock: clock),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  group('PromoCountdownBanner', () {
    testWidgets('hanya menampilkan angka, tanpa tulisan lain', (tester) async {
      await _pumpAt(tester, _duringOffer);
      expect(find.text('08 : 07 : 29 : 45'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('diam di 10 hari penuh sebelum pukul 20:00 WIB 26 Okt 2026',
        (tester) async {
      await _pumpAt(tester, _beforeStart);
      expect(find.text('10 : 00 : 00 : 00'), findsOneWidget);
      await _pumpAt(tester, _atStart);
      expect(find.text('10 : 00 : 00 : 00'), findsOneWidget);
    });

    testWidgets('nol setelah penawaran berakhir', (tester) async {
      await _pumpAt(tester, _afterOffer);
      expect(find.text('00 : 00 : 00 : 00'), findsOneWidget);
    });

    testWidgets('merah solid dan selebar pil periode (maks 440)',
        (tester) async {
      await _pumpAt(tester, _duringOffer);
      final box = tester.widget<Container>(find.descendant(
        of: find.byType(PromoCountdownBanner),
        matching: find.byType(Container),
      ));
      expect((box.decoration as BoxDecoration).color, const Color(0xFFB91C1C));
      expect(tester.getSize(find.byType(Container).first).width, 440);

      await _pumpAt(tester, _duringOffer, width: 360);
      expect(tester.getSize(find.byType(Container).first).width, 328);
    });

    testWidgets('berdetak tiap detik tanpa galat', (tester) async {
      await _pumpAt(tester, _duringOffer);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
