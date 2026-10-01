import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/models/agent_model.dart';
import 'package:openturath_ai/services/agent_session_manager.dart';
import 'package:openturath_ai/services/callable_gateway.dart';
import 'package:openturath_ai/services/notebook_chat_controller.dart';
import 'package:openturath_ai/services/notebook_chat_service.dart';
import 'package:openturath_ai/widgets/notebook_backend_chat_tab.dart';

class _Gateway extends CallableGateway {
  final requests = <Map<String, dynamic>>[];
  final pending = <Completer<dynamic>>[];

  @override
  Future<dynamic> call(String name, [Map<String, dynamic>? data]) {
    expect(name, 'askAgent');
    requests.add(data!);
    final result = Completer<dynamic>();
    pending.add(result);
    return result.future;
  }

  void reply(int index, {String answer = 'Jawaban fixture [1]'}) {
    pending[index].complete({
      'requestId': requests[index]['requestId'],
      'answer': answer,
      'citations': [
        {
          'sourceId': '11111111-1111-1111-1111-111111111111',
          'citationNumber': 1,
          'excerpt': 'Kutipan fixture'
        }
      ],
      'operatorSession': 'secret-fixture',
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final agent =
      AgentModel.defaultAgents.firstWhere((item) => item.id == 'fiqh_syafii');

  test('one authenticated backend call returns native answer and citation data',
      () async {
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => 'reader',
        service: NotebookChatService(gateway: gateway));
    final request = chat.send('Pertanyaan fixture');
    expect(chat.isGenerating, isTrue);
    expect(gateway.requests.single.keys.toSet(),
        {'agentId', 'question', 'requestId', 'expectedUid'});
    expect(gateway.requests.single['expectedUid'], 'reader');
    expect(gateway.requests.single['requestId'],
        matches(RegExp(r'^[a-f0-9]{32}$')));
    gateway.reply(0);
    await request;
    expect(chat.isGenerating, isFalse);
    expect(chat.messages.last.text, 'Jawaban fixture [1]');
    expect(chat.messages.last.citations, ['[1] Kutipan fixture']);
    expect(chat.messages.last.text.contains('secret-fixture'), isFalse);
    chat.dispose();
  });

  test('simultaneous sends never duplicate an in-flight question', () async {
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => 'reader',
        service: NotebookChatService(gateway: gateway));
    final request = chat.send('Pertanyaan pertama');
    await chat.send('Pertanyaan kedua');
    expect(gateway.requests, hasLength(1));
    gateway.reply(0);
    await request;
    chat.dispose();
  });

  test('logout clears history and discards late responses', () async {
    String? uid = 'reader';
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => uid,
        service: NotebookChatService(gateway: gateway));
    final request = chat.send('Pertanyaan akun pertama');
    uid = null;
    chat.synchronizeOwner();
    gateway.reply(0);
    await request;
    expect(chat.messages, isEmpty);
    expect(chat.isGenerating, isFalse);
    await chat.send('Pertanyaan saat logout');
    expect(gateway.requests, hasLength(1));
    expect(chat.error, contains('masuk'));
    chat.dispose();
  });

  test(
      'a late response cannot alter a new account conversation or its busy state',
      () async {
    var uid = 'reader';
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => uid,
        service: NotebookChatService(gateway: gateway));
    final first = chat.send('Akun pertama');
    uid = 'other';
    chat.synchronizeOwner();
    final second = chat.send('Akun kedua');
    gateway.reply(0, answer: 'Jawaban akun pertama');
    await first;
    expect(chat.isGenerating, isTrue);
    expect(chat.messages.single.text, 'Akun kedua');
    expect(gateway.requests.last['expectedUid'], 'other');
    gateway.reply(1, answer: 'Jawaban akun kedua');
    await second;
    expect(chat.messages.last.text, 'Jawaban akun kedua');
    chat.dispose();
  });

  test('failed connector does not create an assistant message or retry',
      () async {
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => 'reader',
        service: NotebookChatService(gateway: gateway));
    final request = chat.send('Pertanyaan fixture');
    gateway.pending.single.completeError(FirebaseFunctionsException(
        code: 'unavailable', message: 'Bearer secret-fixture'));
    await request;
    expect(chat.messages, hasLength(1));
    expect(chat.messages.single.isUser, isTrue);
    expect(chat.error, isNot(contains('secret-fixture')));
    expect(chat.isGenerating, isFalse);
    expect(gateway.requests, hasLength(1));
    chat.dispose();
  });

  test('malformed response is discarded', () async {
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => 'reader',
        service: NotebookChatService(gateway: gateway));
    final request = chat.send('Pertanyaan fixture');
    gateway.pending.single
        .complete({'requestId': 'wrong', 'answer': 'wrong', 'citations': []});
    await request;
    expect(chat.messages, hasLength(1));
    expect(chat.error, isNotNull);
    chat.dispose();
  });

  test('disposing the tab suppresses pending updates', () async {
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => 'reader',
        service: NotebookChatService(gateway: gateway));
    final request = chat.send('Pertanyaan fixture');
    chat.dispose();
    gateway.reply(0);
    await request;
    expect(chat.messages, isEmpty);
  });

  testWidgets(
      'real native tab sends, displays citations and accepts the next question without a WebView',
      (tester) async {
    final gateway = _Gateway();
    final chat = NotebookChatController(
        agentId: agent.id,
        currentUid: () => 'reader',
        service: NotebookChatService(gateway: gateway));
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: NotebookBackendChatTab(
      session: AgentSessionTab(agent: agent),
      controller: chat,
      accountChanges: const Stream.empty(),
    ))));
    expect(find.byType(InAppWebView), findsNothing);
    await tester.enterText(find.byType(TextField), 'Pertanyaan fixture');
    await tester.tap(find.byTooltip('Kirim telaah'));
    await tester.pump();
    gateway.reply(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Jawaban fixture [1]'), findsOneWidget);
    await tester.tap(find.text('Rujukan sumber'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('[1] Kutipan fixture'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Pertanyaan berikutnya');
    await tester.tap(find.byTooltip('Kirim telaah'));
    await tester.pump();
    expect(gateway.requests, hasLength(2));
    gateway.reply(1);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
