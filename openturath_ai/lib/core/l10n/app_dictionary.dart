import 'package:flutter/widgets.dart';
import '../../models/agent_model.dart';
import 'language_notifier.dart';
import 'shared_dictionary.dart';
import 'shell_dictionary.dart';
import 'library_dictionary.dart';
import 'notes_dictionary.dart';
import 'membership_dictionary.dart';
import 'core_dictionary.dart';
import 'legal_dictionary.dart';
import 'catalog_dictionary.dart';
import 'room_dictionary.dart';

abstract final class AppDictionary {
  static final Map<String, Map<String, String>> entries = Map.unmodifiable({
    ...coreDictionary, ...legalDictionary, ...catalogDictionary,
    ...roomDictionary, ...shellDictionary, ...libraryDictionary,
    ...notesDictionary, ...membershipDictionary, ...sharedDictionary,
  });
  static String translate(String key, String languageCode,
      {Map<String, Object> args = const {}}) {
    final language = const ['id', 'en', 'ar'].contains(languageCode) ? languageCode : 'id';
    var entry = entries[key];
    var values = args;
    // Compatibility for dynamic source phrases only: registered templates,
    // anchored literal segments, no evaluation of input or translation of notes.
    if (entry == null) {
      for (final template in _templates) {
        final match = template.pattern.firstMatch(key);
        if (match == null) continue;
        entry = entries[template.key];
        values = {for (var i = 0; i < template.names.length; i++)
          template.names[i]: _templateValue(template.names[i], match.group(i + 1)!), ...args};
        break;
      }
    }
    var text = entry?[language] ?? entry?['id'] ?? key;
    text = text.replaceAllMapped(RegExp(r'\{([a-zA-Z0-9_]+)\}'), (match) {
      final value = values[match[1]];
      if (value == null) return match[0]!;
      return value is num ? formatUiNumber(value, languageCode: language) : value.toString();
    });
    return text;
  }
  static Object _templateValue(String name, String value) {
    // Convert quantities only. IDs, phone numbers, prices and source citations
    // keep their literal form, including leading zeroes and decimal separators.
    if (const {'count', 'total', 'days', 'day', 'year', 'jilid', 'pages'}.contains(name)) {
      return int.tryParse(value) ?? value;
    }
    return value;
  }
  static final List<_SourceTemplate> _templates = [
    for (final key in entries.keys)
      if (key.contains('{') && !RegExp(r'^[a-z]+\.').hasMatch(key)) _SourceTemplate(key),
  ];
}
class _SourceTemplate {
  _SourceTemplate(this.key) {
    final tokens = RegExp(r'\{([a-zA-Z0-9_]+)\}').allMatches(key);
    var offset = 0;
    final buffer = StringBuffer('^');
    for (final token in tokens) {
      buffer.write(RegExp.escape(key.substring(offset, token.start)));
      buffer.write('(.+?)');
      names.add(token[1]!);
      offset = token.end;
    }
    buffer.write(RegExp.escape(key.substring(offset)));
    buffer.write(r'$');
    pattern = RegExp(buffer.toString(), dotAll: true);
  }
  final String key;
  final List<String> names = [];
  late final RegExp pattern;
}
extension AppTranslations on BuildContext {
  String get languageCode => AppLocaleScope.maybeOf(this)?.languageCode ??
    Localizations.maybeLocaleOf(this)?.languageCode ??
    LocaleService.instance.current.languageCode;
  String tr(String key, {Map<String, Object> args = const {}}) =>
    AppDictionary.translate(key, languageCode, args: args);
  String agentTitle(AgentModel agent) => tr(agent.title);
  String uiNumber(Object number) => formatUiNumber(number, languageCode: languageCode,
    easternArabicDigits: AppLocaleScope.maybeOf(this)?.easternArabicDigits);
}
