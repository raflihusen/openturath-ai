import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/scholarly_markdown.dart';

void main() {
  test('assigns the direction from first strong script, not a later quote', () {
    expect(ScholarlyMarkdown.directionOf('Pengantar: قَالَ'), TextDirection.ltr);
    expect(ScholarlyMarkdown.directionOf('> قَالَ: introduction'), TextDirection.rtl);
    expect(ScholarlyMarkdown.directionOf('123'), TextDirection.ltr);
  });
  test('preserves fenced code with blank lines', () {
    const source = 'Pengantar\n\n```dart\nfinal value = 1;\n\nprint(value);\n```\n\nPenutup';
    final blocks = ScholarlyMarkdown.blocks(source);
    expect(blocks.length, 3);
    expect(blocks[1], '```dart\nfinal value = 1;\n\nprint(value);\n```');
  });
  test('separates prose paragraphs for independent Arabic direction', () {
    final blocks = ScholarlyMarkdown.blocks('Catatan Latin\n\nالنص العربي');
    expect(blocks.length, 2);
    expect(ScholarlyMarkdown.directionOf(blocks[1]), TextDirection.rtl);
  });
}
