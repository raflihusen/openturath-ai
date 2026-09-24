import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/sub_agent_model.dart';
import 'package:openturath_ai/widgets/tahawwulat_flagship_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('koleksi utama tetap ringkas dan semua asisten dapat dibuka di ponsel',
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

    expect(find.text('Jelajahi 5 asisten'), findsOneWidget);
    expect(find.text('Mengenal Fikih Tahawwulat'), findsOneWidget);
    expect(find.text('Al-Muhaqqiq'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Jelajahi 5 asisten'));
    await tester.pumpAndSettle();
    expect(find.text('Al-Muhaqqiq'), findsOneWidget);
    expect(find.text('Al-Khatib'), findsOneWidget);

    await tester.ensureVisible(find.text('Al-Muhaqqiq'));
    await tester.tap(find.text('Al-Muhaqqiq'));
    expect(opened?.name, 'Al-Muhaqqiq');
    expect(tester.takeException(), isNull);
  });
}
