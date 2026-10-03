import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/widgets/numbered_assistant_list_card.dart';

void main() {
  group('NumberedAssistantListCard Tests', () {
    testWidgets('NumberedAssistantListCard merender nomor dua digit dan judul tanpa subtitle',
        (WidgetTester tester) async {
      final sampleAgents = AgentModel.defaultAgents
          .where((a) => a.id == 'fiqh_syafii' || a.id == 'fiqh_hanafi')
          .toList();

      AgentModel? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberedAssistantListCard(
              agents: sampleAgents,
              selectedAgentId: 'fiqh_syafii',
              onSelect: (agent) => selected = agent,
              isDark: false,
            ),
          ),
        ),
      );

      // Verifikasi Nomor 01 dan 02
      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);

      // Verifikasi Judul Asisten muncul
      expect(find.text("Fikih Syafi'i"), findsOneWidget);
      expect(find.text('Fikih Hanafi'), findsOneWidget);

      // Verifikasi subtitle/deskripsi TIDAK MUNCUL sama sekali di baris
      expect(find.text("Matan, syarah, dan hasyiyah mu'tabarah."), findsNothing);
      expect(find.text('Zhahir Ar-Riwayah, syarah, dan fatwa.'), findsNothing);
      expect(find.text('Deskripsi panjang yang tidak boleh muncul di baris'), findsNothing);

      // Verifikasi Interaksi tap
      await tester.tap(find.text('Fikih Hanafi'));
      await tester.pump();
      expect(selected?.id, equals('fiqh_hanafi'));
    });
  });
}
