import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/answer_direction.dart';

void main() {
  test('Arabic vowel marks stay inside one isolated phrase', () {
    const text = 'Makna السَّعَادَة dalam kitab.';
    expect(isolateArabicPhrases(text),
        'Makna \u2067السَّعَادَة\u2069 dalam kitab.');
  });
  test('Latin explanation keeps its base direction around Arabic phrases', () {
    const text =
        'Menurut Al-Habib, kebahagiaan (السعادة) dijelaskan pada hlm. 70.';
    expect(answerDirection(text), TextDirection.ltr);
    final shown = isolateArabicPhrases(text);
    expect(shown, contains('(\u2067السعادة\u2069)'));
    expect(shown.replaceAll(RegExp('[\u2067\u2069]'), ''), text);
  });
  test(
      'fenced examples preserve blank lines and Arabic introductions split from Latin prose',
      () {
    const code = '```dart\nfinal label = \'السعادة\';\n\nprint(label);\n```';
    expect(answerDisplayBlocks(code), [code]);
    expect(isolateArabicPhrases(code), code);
    expect(answerDisplayBlocks('بسم الله\nPenjelasan sumber'),
        ['بسم الله', 'Penjelasan sumber']);
  });
  test('Arabic quote and Markdown heading retain their own direction', () {
    expect(answerDirection('## معنى السعادة'), TextDirection.rtl);
    expect(answerDirection('## Penjelasan السعادة'), TextDirection.ltr);
    expect(answerDirection('70. قال المؤلف'), TextDirection.rtl);
    expect(answerDirection('٧٠. Read the source'), TextDirection.ltr);
    expect(answerDirection('70. Read the source'), TextDirection.ltr);
  });
}
