import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/copied_answer.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/models/answer_citation.dart';
import 'package:openturath_ai/models/bookmark_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const citations = [
    AnswerCitation(
        sourceId: '11111111-2222-3333-4444-555555555555',
        number: 1,
        excerpt: 'قال المصنف'),
    AnswerCitation(
        sourceId: '66666666-7777-8888-9999-000000000000', number: 2),
  ];

  test('Saved answer keeps its source locators through local storage',
      () async {
    final service = BookmarkService();
    final agent = AgentModel.defaultAgents.first;
    await service.addBookmark(
        copiedAnswerBookmark('Jawaban bersitasi', agent, citations: citations),
        userId: 'alice');
    final saved = (await service.getBookmarks(userId: 'alice')).single;
    expect(saved.citations, citations);
    expect(saved.citations.first.display, '[1] قال المصنف');
    expect(saved.citations.last.display, 'Rujukan [2]');
  });

  test('Notes written before citations existed still load', () {
    final legacy = BookmarkModel.fromJson({
      'id': 'legacy',
      'title': 'Catatan lama',
      'fullAnswer': 'Isi',
      'createdAt': '2026-09-01T00:00:00.000',
    });
    expect(legacy.citations, isEmpty);
    expect(legacy.toJson().containsKey('citations'), isFalse);
  });

  test('Malformed citation entries are dropped, valid ones are kept', () {
    final parsed = AnswerCitation.listFromJson([
      {'sourceId': 'abc', 'number': 3, 'excerpt': 'teks'},
      {'sourceId': '', 'number': 1},
      {'sourceId': 'abc', 'number': 'satu'},
      'bukan map',
    ]);
    expect(parsed, [
      const AnswerCitation(sourceId: 'abc', number: 3, excerpt: 'teks'),
    ]);
  });
}
