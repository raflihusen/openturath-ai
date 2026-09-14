import 'package:flutter/foundation.dart';

/// Representation of a definition in Arabic, English, and Indonesian.
@immutable
class DefinitionText {
  final String ar;
  final String id;
  final String en;

  const DefinitionText({
    required this.ar,
    required this.id,
    required this.en,
  });

  factory DefinitionText.fromJson(Map<String, dynamic> json) {
    return DefinitionText(
      ar: json['ar'] as String? ?? '',
      id: json['id'] as String? ?? '',
      en: json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ar': ar,
        'id': id,
        'en': en,
      };
}

/// A specific definition with unique ID, text in 3 languages, and its book source.
@immutable
class Definition {
  final String uid; // e.g. "1-0"
  final DefinitionText text;
  final String source;

  const Definition({
    required this.uid,
    required this.text,
    required this.source,
  });

  factory Definition.fromJson(Map<String, dynamic> json, int termId, int index) {
    return Definition(
      uid: json['uid'] as String? ?? '$termId-$index',
      text: DefinitionText.fromJson(json['text'] as Map<String, dynamic>? ?? {}),
      source: json['source'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'text': text.toJson(),
        'source': source,
      };
}

/// Main Term entity in Kamus Fikih Tahawwulat.
@immutable
class Term {
  final int id;
  final String arabic;
  final String english;
  final String indonesian;
  final List<Definition> definitions;

  const Term({
    required this.id,
    required this.arabic,
    required this.english,
    required this.indonesian,
    required this.definitions,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    final termId = json['id'] as int? ?? 0;
    final rawDefs = json['definitions'] as List<dynamic>? ?? [];
    
    final defs = <Definition>[];
    for (var i = 0; i < rawDefs.length; i++) {
      final d = rawDefs[i];
      if (d is Map<String, dynamic>) {
        defs.add(Definition.fromJson(d, termId, i));
      }
    }

    return Term(
      id: termId,
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String? ?? '',
      indonesian: json['indonesian'] as String? ?? '',
      definitions: List.unmodifiable(defs),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'english': english,
        'indonesian': indonesian,
        'definitions': definitions.map((d) => d.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Term && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
