import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/catalog_section_label.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/widgets/assistant_dossier_card.dart';

void main() {
  tearDown(() => AppConfig.localeNotifier.value = 'id');

  test('catalog taxonomy keeps source data while localizing mixed labels', () {
    const source = 'التفسير وعلوم القرآن (Tafsir bi al-Ra’y)';
    AppConfig.localeNotifier.value = 'id';
    expect(CatalogSectionLabel.of(source), 'Tafsir dan Ulumul Quran');
    AppConfig.localeNotifier.value = 'en';
    expect(CatalogSectionLabel.of(source), 'Qur’anic exegesis');
    AppConfig.localeNotifier.value = 'ar';
    expect(CatalogSectionLabel.of(source), 'التفسير وعلوم القرآن');
    expect(source, contains('Tafsir bi al-Ra’y'));
  });

  testWidgets('assistant dossier opens study and reference actions', (tester) async {
    AppConfig.localeNotifier.value = 'id';
    final agent = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_syafii');
    var studies = 0;
    var libraries = 0;

    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: SingleChildScrollView(child: AssistantDossierCard(
        agent: agent,
        position: 2,
        total: 21,
        onOpen: () => studies++,
        onOpenLibrary: () => libraries++,
      )),
    )));

    await tester.tap(find.text('Mulai telaah'));
    await tester.tap(find.text('Lihat pustaka'));
    expect(studies, 1);
    expect(libraries, 1);
    expect(tester.takeException(), isNull);
  });
}
