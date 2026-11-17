import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/copied_answer.dart';
import 'package:openturath_ai/models/agent_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('copiedAnswerBookmark extracts title and stores trimmed answer', () {
    final agent = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');

    const arabicAnswer = '''خويصة النفس والرقابة الأبوية: في زمن انعدام الرقابة العامة، يجب أن تعود الرقابة إلى البيوت.
إحياء سنة الستر ورفض التشهير: إذا وصلك مقطع مسرب فاحذفه.''';

    final bookmark = copiedAnswerBookmark(arabicAnswer, agent);
    expect(bookmark.agentId, 'fiqh_tahawwulat');
    expect(bookmark.fullAnswer, arabicAnswer);
    expect(bookmark.title.isNotEmpty, isTrue);
  });

  test('Clipboard.setData stores text correctly', () async {
    String? storedClipboard;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        storedClipboard = (call.arguments as Map)['text'] as String?;
        return null;
      }
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': storedClipboard};
      }
      return null;
    });

    const textToCopy = 'أن الجهاز الذي في أيديهما ليس صديقاً آمناً.';
    await Clipboard.setData(const ClipboardData(text: textToCopy));
    expect(storedClipboard, textToCopy);

    final data = await Clipboard.getData(Clipboard.kTextPlain);
    expect(data?.text, textToCopy);
  });
}
