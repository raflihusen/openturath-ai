import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/answer_direction.dart';

void main() {
  test('Latin explanation keeps its base direction around Arabic phrases', () {
    const text = 'Menurut Al-Habib, kebahagiaan (السعادة) dijelaskan pada hlm. 70.';
    expect(answerDirection(text), TextDirection.ltr);
    final shown = isolateArabicPhrases(text);
    expect(shown, contains('(\u2067السعادة\u2069)'));
    expect(shown.replaceAll(RegExp('[\u2067\u2069]'), ''), text);
  });
  test('Arabic quote and Markdown heading retain their own direction', () {
    expect(answerDirection('## معنى السعادة'), TextDirection.rtl);
    expect(answerDirection('## Penjelasan السعادة'), TextDirection.ltr);
    expect(answerDirection('70. قال المؤلف'), TextDirection.rtl);
    expect(answerDirection('70. Read the source'), TextDirection.ltr);
  });
}
