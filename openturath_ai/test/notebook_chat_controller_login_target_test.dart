import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/notebook_chat_controller.dart';
import 'package:openturath_ai/services/notebook_chat_service.dart';

class _Failure extends NotebookChatService {
  const _Failure(this.code);
  final String code;
  @override
  Future<NotebookChatReply> ask(
      {required String expectedUid,
      required String agentId,
      required String question,
      required String requestId}) async {
    throw FirebaseFunctionsException(code: code, message: 'Fixture only');
  }
}

void main() {
  for (final code in ['unauthenticated', 'notebook-session-required']) {
    test('controller gives the proper login target for $code', () async {
      final controller = NotebookChatController(
          agentId: 'fixture-agent',
          currentUid: () => 'fixture-reader',
          service: _Failure(code));
      await controller.send('Fixture question');
      expect(controller.isGenerating, isFalse);
      expect(controller.messages, hasLength(1));
      if (code == 'unauthenticated') {
        expect(controller.error, 'Silakan masuk kembali ke OpenTurath.');
        expect(controller.error, isNot(contains('NotebookLM')));
      } else {
        expect(controller.error, contains('ruang asisten'));
        expect(controller.error, contains('profil Chrome'));
        expect(controller.error, contains('akun Google yang sama'));
      }
      controller.dispose();
    });
  }
}
