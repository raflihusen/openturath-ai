import 'package:flutter/foundation.dart';

/// Locator rujukan satu kutipan pada jawaban asisten. Disimpan bersama catatan
/// agar jawaban yang diarsipkan tetap bisa ditelusuri ke sumbernya.
@immutable
class AnswerCitation {
  const AnswerCitation({
    required this.sourceId,
    required this.number,
    this.excerpt,
  });

  final String sourceId;
  final int number;
  final String? excerpt;

  String get display => excerpt == null || excerpt!.isEmpty
      ? 'Rujukan [$number]'
      : '[$number] $excerpt';

  Map<String, dynamic> toJson() => {
        'sourceId': sourceId,
        'number': number,
        'excerpt': excerpt,
      };

  static AnswerCitation? tryParse(Object? value) {
    if (value is! Map) return null;
    final sourceId = value['sourceId'];
    final number = value['number'];
    final excerpt = value['excerpt'];
    if (sourceId is! String || sourceId.isEmpty || number is! int) return null;
    return AnswerCitation(
      sourceId: sourceId,
      number: number,
      excerpt: excerpt is String ? excerpt : null,
    );
  }

  static List<AnswerCitation> listFromJson(Object? value) => value is List
      ? value.map(tryParse).whereType<AnswerCitation>().toList()
      : const [];

  @override
  bool operator ==(Object other) =>
      other is AnswerCitation &&
      other.sourceId == sourceId &&
      other.number == number &&
      other.excerpt == excerpt;

  @override
  int get hashCode => Object.hash(sourceId, number, excerpt);
}
