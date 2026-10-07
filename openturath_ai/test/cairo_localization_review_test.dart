import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/localized_legal.dart';
import 'package:openturath_ai/core/arabic_ui_labels.dart';
import 'package:openturath_ai/core/hijri_date_utils.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/widgets/legal_document_sheet.dart';
import 'package:openturath_ai/widgets/assistant_grid_card.dart';

void main() {
  tearDown(() => AppConfig.localeNotifier.value = 'id');
  test('Arabic display isolation preserves canonical contact and regulation text', () {
    const source = 'البريد openturath@gmail.com والنظام 8/1999';
    final display = LocalizedLegal.displayBody(source, locale: 'ar');
    expect(display, contains('\u2066openturath@gmail.com\u2069'));
    expect(display.replaceAll(RegExp('[\u2066\u2069]'), ''), source);
    expect(LocalizedLegal.displayBody(source, locale: 'en'), source);
  });
  test(
      'all legal documents retain section identities and translated full content',
      () {
    for (final id in LegalDocumentId.values) {
      final source = LocalizedLegal.resolve(id, locale: 'id');
      expect(source.sections.map((s) => s.id).toSet().length,
          source.sections.length);
      for (final locale in ['en', 'ar']) {
        final document = LocalizedLegal.resolve(id, locale: locale);
        expect(document.sections.map((s) => s.id),
            source.sections.map((s) => s.id));
        for (var n = 0; n < source.sections.length; n++) {
          final section = document.sections[n];
          expect(section.content, isNotEmpty);
          expect(section.content, isNot(source.sections[n].content));
          if (locale == 'ar') {
            expect(
                RegExp(r'[\u0600-\u06ff]').hasMatch(section.content), isTrue);
          }
          if (source.sections[n].content.contains('openturath@gmail.com')) {
            expect(section.content, contains('openturath@gmail.com'));
          }
          for (final name in [
            'DOKU',
            'NotebookLM',
            'Firebase',
            'SSL/TLS',
            'QRIS'
          ]) {
            if (source.sections[n].content.contains(name)) {
              expect(section.content, contains(name));
            }
          }
        }
      }
    }
  });
  test('calendar fields preserve multiword months and Arabic language identity',
      () {
    AppConfig.localeNotifier.value = 'id';
    expect(HijriDateUtils.hijriParts(DateTime(2026, 10, 7)).month,
        "Rabi'uts Tsani");
    expect(HijriDateUtils.gregorianParts(DateTime(2026, 10, 7)).year, 2026);
    expect(ArabicUiLabels.forAgent('nahwu_sharaf', ''), 'علوم العربية');
  });
  for (final id in LegalDocumentId.values) {
    testWidgets('open ${id.name} updates language without reopening',
        (tester) async {
      tester.view.physicalSize = const Size(720, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      AppConfig.localeNotifier.value = 'id';
      await tester.pumpWidget(LocaleScope(
          child: MaterialApp(
              home: Scaffold(body: LegalDocumentSheet(documentId: id)))));
      for (final locale in ['id', 'en', 'ar']) {
        AppConfig.localeNotifier.value = locale;
        await tester.pumpAndSettle();
        final content = LocalizedLegal.resolve(id);
        expect(find.text(content.title), findsOneWidget);
        expect(find.text(content.sections.first.title), findsOneWidget);
        expect(find.text(content.sections.first.content), findsOneWidget);
        expect(find.text(Loc.tr('close')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
  testWidgets('AI icon actions are independent and visible labels stay absent',
      (tester) async {
    final agent =
        AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_syafii');
    var opened = 0, references = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AssistantGridCard(
                agent: agent,
                onOpen: () => opened++,
                onOpenLibrary: () => references++))));
    expect(find.text(Loc.tr('openAssistant')), findsNothing);
    expect(find.text(Loc.tr('viewReferences')), findsNothing);
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
    expect(opened, 1);
    expect(references, 0);
    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    expect(references, 1);
  });
}
