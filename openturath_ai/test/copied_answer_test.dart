import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/copied_answer.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
      'Copied answer persists in Saved, keeps full text, and never crosses accounts',
      () async {
    final service = BookmarkService();
    final agent = AgentModel.defaultAgents.first;
    final answer = copiedAnswerBookmark('Jawaban pertama\nالنص العربي', agent);
    await service.addBookmark(answer, userId: 'alice');
    final saved = await service.getBookmarks(userId: 'alice');
    expect(saved.single.fullAnswer, 'Jawaban pertama\nالنص العربي');
    expect(saved.single.agentId, agent.id);
    expect(await service.getBookmarks(userId: 'bob'), isEmpty);
  });
  test(
      'Repeated copy deduplicates but different answers and assistants stay separate',
      () async {
    final service = BookmarkService();
    final agents = AgentModel.defaultAgents;
    for (var i = 0; i < 2; i++) {
      await service.addBookmark(
          copiedAnswerBookmark('Jawaban satu', agents.first),
          userId: 'alice');
    }
    expect((await service.getBookmarks(userId: 'alice')).length, 1);
    await service.addBookmark(copiedAnswerBookmark('Jawaban dua', agents.first),
        userId: 'alice');
    await service.addBookmark(copiedAnswerBookmark('Jawaban satu', agents[1]),
        userId: 'alice');
    expect((await service.getBookmarks(userId: 'alice')).length, 3);
  });
  test('Empty copies cannot create a saved item', () {
    expect(() => copiedAnswerBookmark('  ', AgentModel.defaultAgents.first),
        throwsArgumentError);
  });
}
