import 'package:flutter/widgets.dart';

/// Direction is determined by the first strong letter, never by the presence
/// of an Arabic fragment somewhere in a Latin paragraph. Numbers are neutral.
TextDirection answerDirection(String text) {
  final first = RegExp(r'[A-Za-z\u00C0-\u024F\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]')
      .firstMatch(text.replaceAll(RegExp(r'^\s*(?:#{1,6}|>|[-*])\s*'), ''));
  if (first == null) return TextDirection.ltr;
  return RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]')
          .hasMatch(first.group(0)!)
      ? TextDirection.rtl : TextDirection.ltr;
}

/// Isolation is a display transformation only. Clipboard and stored answers
/// must continue to use the original text, without added control characters.
String isolateArabicPhrases(String text) {
  if (answerDirection(text) == TextDirection.rtl) return text;
  return text.replaceAllMapped(
    RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+(?:[ \t]+[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+)*'),
    (match) => '\u2067${match.group(0)}\u2069',
  );
}
