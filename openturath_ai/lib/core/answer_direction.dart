import 'package:flutter/widgets.dart';

/// Direction is determined by the first strong letter, never by the presence
/// of an Arabic fragment somewhere in a Latin paragraph. Numbers are neutral.
TextDirection answerDirection(String text) {
  final first = RegExp(
          r'[A-Za-z\u00C0-\u024F\u0620-\u064A\u066E-\u06D3\u06FA-\u06FC\u0750-\u077F\u08A0-\u08C9]')
      .firstMatch(text.replaceAll(RegExp(r'^\s*(?:#{1,6}|>|[-*])\s*'), ''));
  if (first == null) return TextDirection.ltr;
  return RegExp(
              r'[\u0620-\u064A\u066E-\u06D3\u06FA-\u06FC\u0750-\u077F\u08A0-\u08C9]')
          .hasMatch(first.group(0)!)
      ? TextDirection.rtl
      : TextDirection.ltr;
}

/// Isolation is a display transformation only. Clipboard and stored answers
/// must continue to use the original text, without added control characters.
String isolateArabicPhrases(String text) {
  if (answerDirection(text) == TextDirection.rtl ||
      RegExp(r'^\s*(?:`{3,}|~{3,})').hasMatch(text)) return text;
  return text.replaceAllMapped(
    RegExp(
        r'[\u0620-\u064A\u066E-\u06D3\u06FA-\u06FC\u0750-\u077F\u08A0-\u08C9]+(?:[ \t]+[\u0620-\u064A\u066E-\u06D3\u06FA-\u06FC\u0750-\u077F\u08A0-\u08C9]+)*'),
    (match) => '\u2067${match.group(0)}\u2069',
  );
}

/// Keep fenced Markdown intact and split unstructured bilingual lines when
/// their reading direction changes, including replies without blank lines.
List<String> answerDisplayBlocks(String text) {
  final result = <String>[];
  final current = <String>[];
  String? fence;
  void flush() {
    if (current.isNotEmpty) result.add(current.join('\n'));
    current.clear();
  }

  for (final line in text.split('\n')) {
    final marker = RegExp(r'^\s*(`{3,}|~{3,})').firstMatch(line)?.group(1);
    if (marker != null) {
      if (fence == null) {
        flush();
        fence = marker[0];
      } else if (marker[0] == fence) {
        current.add(line);
        flush();
        fence = null;
        continue;
      }
    }
    if (fence == null && line.trim().isEmpty) {
      flush();
      continue;
    }
    final structured = current
        .any((part) => RegExp(r'^\s*(?:[-*+]\s|\d+[.)]\s|\|)').hasMatch(part));
    if (fence == null &&
        current.isNotEmpty &&
        !structured &&
        answerDirection(current.first) != answerDirection(line)) flush();
    current.add(line);
  }
  flush();
  return result;
}
