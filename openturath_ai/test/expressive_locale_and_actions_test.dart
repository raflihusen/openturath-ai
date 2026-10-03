import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/catalog_section_label.dart';

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
}
