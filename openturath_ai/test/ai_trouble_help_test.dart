import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/widgets/agent_multi_tab_room.dart';
import 'package:openturath_ai/widgets/ai_trouble_help.dart';
import 'package:openturath_ai/widgets/app_error_state.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('kartu muat lambat baru muncul setelah jeda dan memanggil aksi',
      (tester) async {
    var restarted = 0;
    var more = 0;
    await tester.pumpWidget(_wrap(AiSlowLoadHint(
        delay: const Duration(seconds: 15),
        onRestart: () => restarted++,
        onMore: () => more++)));
    expect(find.byKey(const ValueKey('ai-slow-restart')), findsNothing);
    await tester.pump(const Duration(seconds: 16));
    expect(find.text(Loc.tr('aiSlowHint')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ai-slow-restart')));
    await tester.tap(find.byKey(const ValueKey('ai-slow-more')));
    expect(restarted, 1);
    expect(more, 1);
  });

  testWidgets('layar galat menampilkan empat langkah pemulihan',
      (tester) async {
    await tester.pumpWidget(_wrap(AppErrorState(
        title: 'Galat', message: 'Pesan', steps: aiTroubleSteps())));
    for (final step in aiTroubleSteps()) {
      expect(find.text(step), findsOneWidget);
    }
  });

  testWidgets('naskah tersedia di tiga bahasa dan tidak kosong',
      (tester) async {
    for (final code in Loc.supportedCodes) {
      AppConfig.localeNotifier.value = code;
      for (final key in [
        ...aiTroubleStepKeys,
        'aiHelpTitle',
        'aiSlowWaiting',
        'aiSlowHint',
      ]) {
        expect(Loc.tr(key).trim(), isNotEmpty, reason: '$key/$code');
      }
    }
    AppConfig.localeNotifier.value = 'id';
  });

  testWidgets(
      'alur 3 tahap ramah internet lambat: 0-20d bersih, 20-50d peringatan tunggu tanpa tombol, >=50d tombol pemulihan',
      (tester) async {
    AppConfig.localeNotifier.value = 'id';
    var restarted = 0;
    var more = 0;
    await tester.pumpWidget(_wrap(AiSlowLoadHint(
      onRestart: () => restarted++,
      onMore: () => more++,
    )));

    // Tahap 1 (0 - 19 detik): tidak ada pop-up maupun tombol apa pun
    await tester.pump(const Duration(seconds: 19));
    expect(find.byKey(const ValueKey('ai-slow-waiting')), findsNothing);
    expect(find.byKey(const ValueKey('ai-slow-restart')), findsNothing);
    expect(find.byKey(const ValueKey('ai-slow-more')), findsNothing);

    // Tahap 2 (20 - 49 detik): peringatan lembut menunggu, TANPA tombol tutup/buka ulang
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ai-slow-waiting')), findsOneWidget);
    expect(find.text(Loc.tr('aiSlowWaiting')), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-slow-restart')), findsNothing);
    expect(find.byKey(const ValueKey('ai-slow-more')), findsNothing);

    await tester.pump(const Duration(seconds: 29));
    expect(find.byKey(const ValueKey('ai-slow-waiting')), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-slow-restart')), findsNothing);

    // Tahap 3 (>= 50 detik): tombol pemulihan opsional baru muncul
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ai-slow-waiting')), findsNothing);
    expect(find.byKey(const ValueKey('ai-slow-restart')), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-slow-more')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ai-slow-restart')));
    await tester.tap(find.byKey(const ValueKey('ai-slow-more')));
    expect(restarted, 1);
    expect(more, 1);
  });

  test(
      'hard timeout minimal 120 detik dan diperpanjang otomatis bila WebView masih menerima progres',
      () {
    // Di bawah 120 detik tidak pernah diputus meski tanpa progres baru
    expect(
      AgentMultiTabRoom.shouldTimeoutRoomLoad(elapsedSec: 45),
      isFalse,
    );
    expect(
      AgentMultiTabRoom.shouldTimeoutRoomLoad(elapsedSec: 119),
      isFalse,
    );
    // Tepat 120 detik tanpa progres -> timeout
    expect(
      AgentMultiTabRoom.shouldTimeoutRoomLoad(elapsedSec: 120),
      isTrue,
    );
    // 120 - 239 detik TAPI ada progres baru (< 60 detik lalu) -> tetap dilanjutkan
    expect(
      AgentMultiTabRoom.shouldTimeoutRoomLoad(
        elapsedSec: 120,
        sinceLastProgressSec: 10,
      ),
      isFalse,
    );
    expect(
      AgentMultiTabRoom.shouldTimeoutRoomLoad(
        elapsedSec: 185,
        sinceLastProgressSec: 45,
      ),
      isFalse,
    );
    // Progres sudah macet >= 60 detik setelah melewati 120 detik -> timeout
    expect(
      AgentMultiTabRoom.shouldTimeoutRoomLoad(
        elapsedSec: 185,
        sinceLastProgressSec: 60,
      ),
      isTrue,
    );
    // Batas absolut 240 detik -> tetap berhenti agar tidak menggantung selamanya
    expect(
      AgentMultiTabRoom.shouldTimeoutRoomLoad(
        elapsedSec: 240,
        sinceLastProgressSec: 5,
      ),
      isTrue,
    );
  });
}
