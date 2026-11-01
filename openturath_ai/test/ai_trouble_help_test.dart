import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
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
      for (final key in [...aiTroubleStepKeys, 'aiHelpTitle', 'aiSlowHint']) {
        expect(Loc.tr(key).trim(), isNotEmpty, reason: '$key/$code');
      }
    }
    AppConfig.localeNotifier.value = 'id';
  });
}
