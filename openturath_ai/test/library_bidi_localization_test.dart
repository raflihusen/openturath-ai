import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/l10n/library_dictionary.dart';

void main() {
  test('bibliographic numbers preserve order, punctuation and adjacent spaces', () {
    expect(libraryBidi('ت. 204 هـ؛ 12–14؛ 1,348+ مجلد', 'ar'),
        'ت. \u2066204\u2069 هـ؛ \u206612–14\u2069؛ \u20661,348+\u2069 مجلد');
    expect(libraryBidi('≤ 300 هـ', 'ar'), '\u2066≤ 300\u2069 هـ');
    expect(libraryBidi('١٢/٣٤ هـ', 'ar'), '\u2066١٢/٣٤\u2069 هـ');
    expect(libraryBidi('12–14 AH', 'en'), '12–14 AH');
    expect(libraryBidi('الطبعة 2، 1440 هـ', 'en'),
        'الطبعة \u20662\u2069، \u20661440\u2069 هـ');
  });

  test('a second rendering pass does not add nested numeric isolates', () {
    final once = libraryBidi('204 هـ، 3/12', 'ar');
    expect(libraryBidi(once, 'ar'), once);
  });

  test('source book and author names survive locale changes verbatim', () {
    for (final code in ['id', 'en', 'ar']) {
      expect(librarySourceLabel('كتاب الأم', code), 'كتاب الأم');
      expect(librarySourceLabel('الإمام الشافعي', code), 'الإمام الشافعي');
      expect(librarySourceLabel('Matan', code), 'Matan');
      expect(librarySourceLabel('Jilid 2', code), 'Jilid 2');
    }
    expect(librarySourceLabel('غير معروف', 'en'), 'Unknown');
    expect(librarySourceLabel('بدون عنوان', 'id'), 'Tanpa judul');
  });

  test('collection metadata has one translated unit with original counts', () {
    expect(libraryDataLabel('400+ Jilid', 'en'), '400+ volumes');
    expect(libraryDataLabel('58 Kitab Fisik', 'ar'),
        '\u206658\u2069 كتاب مطبوع');
    expect(libraryDataLabel('Mutaqaddimin', 'ar'), 'المتقدمون');
    expect(libraryDataLabel('Unreviewed source wording', 'ar'),
        'Unreviewed source wording');
  });

  test('library keys have all locales and matching named placeholders', () {
    final placeholders = RegExp(r'\{\w+\}');
    for (final entry in libraryDictionary.entries) {
      expect(entry.value.keys.toSet(), {'id', 'en', 'ar'}, reason: entry.key);
      final expected = placeholders.allMatches(entry.value['id']!)
          .map((match) => match[0]).toSet();
      for (final code in ['id', 'en', 'ar']) {
        expect(entry.value[code], isNotEmpty, reason: '${entry.key}: $code');
        expect(placeholders.allMatches(entry.value[code]!)
            .map((match) => match[0]).toSet(), expected,
            reason: '${entry.key}: $code');
      }
    }
  });
}
