import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/agent_model.dart';
import '../models/answer_citation.dart';
import '../models/bookmark_model.dart';
import 'bookmark_content.dart';

BookmarkModel copiedAnswerBookmark(
  String answer,
  AgentModel agent, {
  List<AnswerCitation> citations = const [],
}) {
  final text = answer.trim();
  if (text.isEmpty || text.length > 200000) {
    throw ArgumentError('Invalid answer length');
  }
  return BookmarkModel(
    id: sha256.convert(utf8.encode('${agent.id}:$text')).toString(),
    title: aiAnswerTitle(text, agent.title),
    agentId: agent.id,
    agentTitle: agent.title,
    fieldName: agent.category,
    fieldId: agent.fieldId,
    arabicExcerpt: '',
    fullAnswer: text,
    bookReference: '',
    pageNumber: '',
    createdAt: DateTime.now(),
    documentKind: BookmarkDocumentKind.aiAnswer,
    verificationStatus: BookmarkVerificationStatus.unverified,
    citations: citations,
  );
}
