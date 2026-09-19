import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/copied_answer.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Copied answer persists in Saved, keeps full text, and never crosses guest namespaces', () async {
    final service = BookmarkService();
    final agent = AgentModel.defaultAgents.first;
    final answer = copiedAnswerBookmark('Jawaban pertama\nالنص العربي', agent);
    await service.addBookmark(answer, userId: 'guest_alice');
    final saved = await service.getBookmarks(userId: 'guest_alice');
    expect(saved.single.fullAnswer, 'Jawaban pertama\nالنص العربي');
    expect(saved.single.agentId, agent.id);
    expect(await service.getBookmarks(userId: 'guest_bob'), isEmpty);
  });
  test('Repeated copy deduplicates but different answers and assistants stay separate', () async {
    final service = BookmarkService();
    final agents = AgentModel.defaultAgents;
    for (var i = 0; i < 2; i++) {
      await service.addBookmark(copiedAnswerBookmark('Jawaban satu', agents.first), userId: 'guest_alice');
    }
    expect((await service.getBookmarks(userId: 'guest_alice')).length, 1);
    await service.addBookmark(copiedAnswerBookmark('Jawaban dua', agents.first), userId: 'guest_alice');
    await service.addBookmark(copiedAnswerBookmark('Jawaban satu', agents[1]), userId: 'guest_alice');
    expect((await service.getBookmarks(userId: 'guest_alice')).length, 3);
  });
  test('Empty copies cannot create a saved item', () {
    expect(() => copiedAnswerBookmark('  ', AgentModel.defaultAgents.first), throwsArgumentError);
  });
}


