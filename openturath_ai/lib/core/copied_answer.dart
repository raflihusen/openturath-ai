import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/agent_model.dart';
import '../models/bookmark_model.dart';

BookmarkModel copiedAnswerBookmark(String answer, AgentModel agent) {
  final text = answer.trim();
  if (text.isEmpty || text.length > 200000) throw ArgumentError('Invalid answer length');
  final firstLine = text.split('\n').first;
  return BookmarkModel(
    id: sha256.convert(utf8.encode('${agent.id}:$text')).toString(),
    title: firstLine.length > 80 ? firstLine.substring(0, 80) : firstLine,
    agentId: agent.id, agentTitle: agent.title, fieldName: agent.category, fieldId: agent.fieldId,
    arabicExcerpt: '', fullAnswer: text, bookReference: '', pageNumber: '', createdAt: DateTime.now(),
  );
}
