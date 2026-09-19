import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/l10n/app_dictionary.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/widgets/corpus_kind_control.dart';
import 'package:openturath_ai/widgets/specialist_card.dart';
import 'package:openturath_ai/widgets/tahawwulat_flagship_card.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    OTTypography.useSystemFontFallback = true;
  });

  String tr(String key, {Map<String, Object> args = const {}}) =>
      AppDictionary.translate(key, 'id', args: args);

  Widget surface(Widget child, {double scale = 1}) => MaterialApp(
    locale: const Locale('id'),
    supportedLocales: const [Locale('id'), Locale('en'), Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), child: child))),
  );

  testWidgets('library action does not also launch its parent assistant', (tester) async {
    var opened = 0;
    var library = 0;
    await tester.pumpWidget(surface(SpecialistCard(
      title: 'Fikih Syafii', scopeLabel: 'Kajian teks dan rujukan',
      onOpen: () => opened++, onOpenLibrary: () => library++,
    )));
    await tester.tap(find.byTooltip(tr('membership.library_title', args: {'title': tr('Fikih Syafii')})));
    await tester.pump();
    expect(library, 1);
    expect(opened, 0);
    await tester.tap(find.text(tr('Fikih Syafii')));
    await tester.pump();
    expect(opened, 1);
    expect(library, 1);
  });

  testWidgets('narrow enlarged directory preserves controls and role identity', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 780);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final agent = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    String? openedRole;
    var openedMain = 0;
    CorpusKind kind = CorpusKind.discipline;
    await tester.pumpWidget(surface(Column(children: [
      CorpusKindControl(value: kind, onChanged: (value) => kind = value),
      const SizedBox(height: 20),
      TahawwulatFlagshipCard(agent: agent, isSubscribed: true,
        onOpenMain: () => openedMain++, onOpenSubAgent: (role) => openedRole = role.id),
    ]), scale: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(tr('membership.scholar_heritage')));
    expect(kind, CorpusKind.scholar);
    final expand = find.text(tr('membership.specialist_count', args: {'count': agent.subAgents!.length}));
    await tester.ensureVisible(expand);
    await tester.tap(expand);
    await tester.pumpAndSettle();
    final firstRole = agent.subAgents!.first;
    await tester.ensureVisible(find.text(tr(firstRole.name)));
    await tester.tap(find.text(tr(firstRole.name)));
    await tester.pump();
    expect(openedRole, firstRole.id);
    expect(openedMain, 0);
    expect(tester.takeException(), isNull);
  });
}
