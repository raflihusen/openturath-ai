import 'package:flutter/foundation.dart';

import 'answer_citation.dart';

/// Model representasi pesan obrolan mandiri untuk antarmuka native OpenTurath AI.
@immutable
class TurathChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isThinking;
  final List<String> citations;

  /// Locator terstruktur untuk [citations]; ikut tersimpan saat jawaban diarsipkan.
  final List<AnswerCitation> references;

  const TurathChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isThinking = false,
    this.citations = const [],
    this.references = const [],
  });

  TurathChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    bool? isThinking,
    List<String>? citations,
    List<AnswerCitation>? references,
  }) {
    return TurathChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isThinking: isThinking ?? this.isThinking,
      citations: citations ?? this.citations,
      references: references ?? this.references,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurathChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          isUser == other.isUser &&
          isThinking == other.isThinking;

  @override
  int get hashCode => Object.hash(id, text, isUser, isThinking);
}
