import 'package:cloud_functions/cloud_functions.dart';

import 'callable_gateway.dart';

class NotebookChatCitation {
  const NotebookChatCitation(this.sourceId, this.number, this.excerpt);
  final String sourceId;
  final int number;
  final String? excerpt;

  String get display => excerpt == null || excerpt!.isEmpty
      ? 'Rujukan [$number]'
      : '[$number] $excerpt';
}

class NotebookChatReply {
  const NotebookChatReply(this.answer, this.citations);
  final String answer;
  final List<NotebookChatCitation> citations;
}

/// Calls OpenTurath's backend using the existing Firebase identity.
/// Google operator sessions and upstream conversation IDs never enter the app.
class NotebookChatService {
  const NotebookChatService({
    CallableGateway gateway = const CallableGateway(
      timeout: Duration(seconds: 100),
    ),
  }) : _gateway = gateway;

  final CallableGateway _gateway;

  Future<NotebookChatReply> ask({
    required String expectedUid,
    required String agentId,
    required String question,
    required String requestId,
  }) async {
    if (question.trim().isEmpty || question.length > 8000) {
      throw FirebaseFunctionsException(
        code: 'invalid-argument',
        message: 'Pertanyaan kosong atau terlalu panjang.',
      );
    }
    final raw = await _gateway.call('askAgent', {
      'agentId': agentId,
      'question': question.trim(),
      'requestId': requestId,
      'expectedUid': expectedUid,
    });
    return decodeReply(raw, requestId);
  }

  /// Shared validation for normalized replies from either transport.
  static NotebookChatReply decodeReply(Object? raw, String requestId) {
    final invalid = FirebaseFunctionsException(
      code: 'unavailable',
      message: 'Jawaban asisten belum dapat dibaca.',
    );
    if (raw is! Map ||
        raw['requestId'] != requestId ||
        raw['answer'] is! String ||
        (raw['answer'] as String).trim().isEmpty ||
        (raw['answer'] as String).length > 128000 ||
        raw['citations'] is! List ||
        (raw['citations'] as List).length > 100) {
      throw invalid;
    }
    final citations = <NotebookChatCitation>[];
    final uuid =
        RegExp(r'^[a-fA-F0-9]{8}(?:-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$');
    for (final ref in raw['citations'] as List) {
      if (ref is! Map ||
          ref['sourceId'] is! String ||
          !uuid.hasMatch(ref['sourceId'] as String) ||
          ref['citationNumber'] is! int ||
          (ref['citationNumber'] as int) < 1 ||
          (ref['citationNumber'] as int) > 1000 ||
          (ref['excerpt'] != null &&
              (ref['excerpt'] is! String ||
                  (ref['excerpt'] as String).length > 4000))) {
        throw invalid;
      }
      citations.add(NotebookChatCitation(
        ref['sourceId'] as String,
        ref['citationNumber'] as int,
        ref['excerpt'] as String?,
      ));
    }
    return NotebookChatReply(
      (raw['answer'] as String).trim(),
      List.unmodifiable(citations),
    );
  }
}
