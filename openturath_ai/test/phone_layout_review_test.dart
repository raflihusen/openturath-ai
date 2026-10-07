import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/sub_agent_model.dart';
import 'package:openturath_ai/widgets/tahawwulat_flagship_card.dart';
import 'package:openturath_ai/widgets/promo_price.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('koleksi utama tetap ringkas dan semua AI dapat dibuka di ponsel',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final agent = AgentModel.defaultAgents
        .firstWhere((candidate) => candidate.id == 'fiqh_tahawwulat');
    SubAgentModel? opened;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TahawwulatFlagshipCard(
              agent: agent,
              isSubscribed: true,
              onOpenMain: () {},
              onOpenSubAgent: (subAgent) => opened = subAgent,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Al-Muhaqqiq'), findsNothing);
    await tester.tap(find.text('Buka AI Fikih Tahawwulat'));
    await tester.pumpAndSettle();
    // Pilihan dan fungsi baru terlihat setelah masuk ke ruang AI.
    expect(tester.takeException(), isNull);
    expect(find.text('Al-Muhaqqiq'), findsOneWidget);
    expect(find.text('Al-Khatib'), findsOneWidget);

    await tester.ensureVisible(find.text('Al-Muhaqqiq'));
    await tester.tap(find.text('Al-Muhaqqiq'));
    expect(opened?.name, 'Al-Muhaqqiq');
    expect(tester.takeException(), isNull);
  });

  testWidgets('harga paket utama tetap terbaca pada kartu gelap',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ColoredBox(
          color: Color(0xFF18181B),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: PromoPrice(
              amount: 300000,
              regularAmount: 1000000,
              period: '/bulan',
              foregroundColor: Colors.white,
              secondaryColor: Color(0xFFB8B8BE),
            ),
          ),
        ),
      ),
    ));

    final amount = tester.widget<Text>(find.text('Rp 300.000'));
    expect(amount.style?.color, Colors.white);
    expect(tester.takeException(), isNull);
  });
}
