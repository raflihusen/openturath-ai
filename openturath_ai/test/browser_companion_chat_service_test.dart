// Fixture-only lifecycle tests: no Firebase initialization, accounts, or network.
import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/agent_service.dart';
import 'package:openturath_ai/services/browser_companion.dart';
import 'package:openturath_ai/services/browser_companion_chat_service.dart';
import 'package:openturath_ai/services/notebook_chat_service.dart';

const _notebook = '11111111-1111-1111-1111-111111111111';
const _conversation = '22222222-2222-2222-2222-222222222222';
const _source = '33333333-3333-3333-3333-333333333333';

Matcher _code(String value) => isA<FirebaseFunctionsException>().having(
  (error) => error.code,
  'safe error code',
  value,
);

class _Agents extends AgentService {
  _Agents(this.onUrl, this.onRecord);
  final Future<String?> Function() onUrl;
  final Future<void> Function() onRecord;
  int urlCalls = 0;
  int recordCalls = 0;

  @override
  Future<String?> getAgentUrl(String agentId) async {
    expect(agentId, 'fixture-agent');
    urlCalls++;
    return onUrl();
  }

  @override
  Future<TrialUsage> recordQuestion(String agentId) async {
    expect(agentId, 'fixture-agent');
    recordCalls++;
    await onRecord();
    return const TrialUsage(
      isPremium: true,
      questionsUsed: 0,
      questionsRemaining: null,
    );
  }
}

class _Runtime extends BrowserCompanionRuntime {
  _Runtime(this.onAnswer) : super(identity: () => null);
  final Future<void> Function() onAnswer;
  bool available = true;
  String answer = ' Jawaban fixture [1] ';
  final requests = <Map<String, dynamic>>[];
  Map<String, dynamic> Function(Map<String, dynamic>)? alterReply;

  @override
  bool get connected => available;

  @override
  Future<Map<String, dynamic>> ask({
    required String expectedUid,
    required String notebookId,
    required String question,
    required String requestId,
    List<List<Object?>>? history,
    String? conversationId,
  }) async {
    final request = <String, dynamic>{
      'expectedUid': expectedUid,
      'notebookId': notebookId,
      'question': question,
      'requestId': requestId,
      'history': history == null ? null : jsonDecode(jsonEncode(history)),
      'conversationId': conversationId,
    };
    requests.add(request);
    await onAnswer();
    final reply = <String, dynamic>{
      'requestId': requestId,
      'answer': answer,
      'conversationId': _conversation,
      'citations': [
        {
          'sourceId': _source,
          'citationNumber': 1,
          'excerpt': 'Kutipan fixture',
        },
      ],
    };
    return alterReply?.call(reply) ?? reply;
  }
}

class _Harness {
  _Harness({this.deferredStage, String? url})
    : url = url ?? 'https://notebooklm.google.com/notebook/$_notebook/' {
    // Each fixture receives its own owner/generation, including static history.
    final number = ++_counter;
    owner = CompanionIdentity(
      uid: 'fixture-reader-$number',
      googleSub: '${1234567890123456789 + number}',
      email: 'reader$number@example.com',
    );
    identity = owner;
    generation = number * 100;
    agents = _Agents(
      () async {
        await stage('url');
        if (urlError != null) throw urlError!;
        return this.url;
      },
      () async {
        await stage('record');
        if (recordError != null) throw recordError!;
      },
    );
    runtime = _Runtime(() => stage('answer'));
    service = BrowserCompanionChatService(
      agents: agents,
      transport: runtime,
      identity: () => identity,
      prepare: () async {
        prepareCalls++;
        await stage('prepare');
      },
      sessionGeneration: () => generation,
    );
  }

  static int _counter = 0;
  final String? deferredStage;
  String? url;
  final reached = Completer<void>();
  final release = Completer<void>();
  late final CompanionIdentity owner;
  CompanionIdentity? identity;
  late int generation;
  late final _Agents agents;
  late final _Runtime runtime;
  late final BrowserCompanionChatService service;
  AgentAccessException? urlError;
  AgentAccessException? recordError;
  int prepareCalls = 0;
  int sends = 0;

  Future<void> stage(String name) async {
    if (deferredStage != name) return;
    if (!reached.isCompleted) reached.complete();
    await release.future;
  }

  void logoutAndReloginSameOwner() {
    identity = null;
    generation++;
    identity = owner;
  }

  Future<NotebookChatReply> send({String question = ' Pertanyaan fixture '}) =>
      service.ask(
        expectedUid: owner.uid,
        agentId: 'fixture-agent',
        question: question,
        requestId: (++sends).toRadixString(16).padLeft(32, '0'),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final stage in ['prepare', 'url', 'record', 'answer']) {
    test(
      'same-account relogin during $stage rejects the old invocation',
      () async {
        final fixture = _Harness(deferredStage: stage);
        final pending = fixture.send();
        final failure = expectLater(pending, throwsA(_code('unauthenticated')));
        await fixture.reached.future;
        fixture.logoutAndReloginSameOwner();
        fixture.release.complete();
        await failure;
        expect(fixture.runtime.requests, hasLength(stage == 'answer' ? 1 : 0));
        // A new conversation cannot adopt a discarded late result's history.
        if (stage == 'answer') {
          await fixture.send(question: 'Sesudah masuk ulang');
          expect(fixture.runtime.requests.last['history'], isNull);
          expect(fixture.runtime.requests.last['conversationId'], isNull);
        }
      },
    );
  }

  test(
    'missing Google identity or wrong UID never prepares or checks entitlement',
    () async {
      final fixture = _Harness();
      fixture.identity = null;
      await expectLater(fixture.send(), throwsA(_code('unauthenticated')));
      fixture.identity = CompanionIdentity(
        uid: 'other-reader',
        googleSub: '999',
        email: 'other@example.com',
      );
      await expectLater(fixture.send(), throwsA(_code('unauthenticated')));
      expect(fixture.prepareCalls, 0);
      expect(fixture.agents.urlCalls, 0);
      expect(fixture.agents.recordCalls, 0);
      expect(fixture.runtime.requests, isEmpty);
    },
  );

  test(
    'same UID with a changed Google subject fails during preparation',
    () async {
      final fixture = _Harness(deferredStage: 'prepare');
      final pending = fixture.send();
      final failure = expectLater(pending, throwsA(_code('unauthenticated')));
      await fixture.reached.future;
      fixture.identity = CompanionIdentity(
        uid: fixture.owner.uid,
        googleSub: '999',
        email: fixture.owner.email,
      );
      fixture.release.complete();
      await failure;
      expect(fixture.agents.urlCalls, 0);
      expect(fixture.runtime.requests, isEmpty);
    },
  );

  test(
    'disconnected companion performs no entitlement calls or dispatch',
    () async {
      final fixture = _Harness();
      fixture.runtime.available = false;
      await expectLater(fixture.send(), throwsA(_code('unavailable')));
      expect(fixture.prepareCalls, 1);
      expect(fixture.agents.urlCalls, 0);
      expect(fixture.agents.recordCalls, 0);
      expect(fixture.runtime.requests, isEmpty);
    },
  );

  for (final stage in ['url', 'record']) {
    test('server permission denial during $stage prevents dispatch', () async {
      final fixture = _Harness();
      const error = AgentAccessException('permission-denied', 'Fixture denied');
      if (stage == 'url') {
        fixture.urlError = error;
      } else {
        fixture.recordError = error;
      }
      await expectLater(fixture.send(), throwsA(_code('permission-denied')));
      expect(fixture.agents.urlCalls, 1);
      expect(fixture.agents.recordCalls, stage == 'record' ? 1 : 0);
      expect(fixture.runtime.requests, isEmpty);
    });
  }

  test(
    'missing server notebook address prevents quota call and dispatch',
    () async {
      final fixture = _Harness()..url = null;
      await expectLater(fixture.send(), throwsA(_code('failed-precondition')));
      expect(fixture.agents.recordCalls, 0);
      expect(fixture.runtime.requests, isEmpty);
    },
  );

  test(
    'trailing-slash notebook URL, normalized reply, and follow-up history',
    () async {
      final fixture = _Harness();
      final reply = await fixture.send();
      expect(reply.answer, 'Jawaban fixture [1]');
      expect(reply.citations.single.sourceId, _source);
      expect(reply.citations.single.number, 1);
      expect(reply.citations.single.display, '[1] Kutipan fixture');
      final first = fixture.runtime.requests.single;
      expect(first['notebookId'], _notebook);
      expect(first['question'], 'Pertanyaan fixture');
      expect(first['history'], isNull);
      await fixture.send(question: 'Lanjutan');
      expect(fixture.agents.urlCalls, 2);
      expect(fixture.agents.recordCalls, 2);
      expect(fixture.runtime.requests.last['conversationId'], _conversation);
      expect(fixture.runtime.requests.last['history'], [
        ['Jawaban fixture [1]', null, 2],
        ['Pertanyaan fixture', null, 1],
      ]);
    },
  );

  test(
    'history stays within forty triplets and drops oversized context',
    () async {
      final fixture = _Harness();
      for (var index = 0; index < 22; index++) {
        await fixture.send(question: 'Pertanyaan $index');
      }
      final history = fixture.runtime.requests.last['history'] as List;
      expect(history, hasLength(40));
      expect(history[1], ['Pertanyaan 1', null, 1]);
      expect(jsonEncode(history).length, lessThanOrEqualTo(110000));
      fixture.runtime.answer = List.filled(110001, 'ع').join();
      await fixture.send(question: 'Jawaban panjang');
      fixture.runtime.answer = 'Ringkas';
      await fixture.send(question: 'Lanjutan setelah konteks panjang');
      expect(fixture.runtime.requests.last['history'], isEmpty);
    },
  );

  test('malformed reply never enters follow-up history', () async {
    final fixture = _Harness();
    fixture.runtime.alterReply = (reply) => {...reply, 'requestId': 'stale'};
    await expectLater(fixture.send(), throwsA(_code('unavailable')));
    fixture.runtime.alterReply = null;
    await fixture.send();
    expect(fixture.runtime.requests.last['history'], isNull);
  });

  test('empty and overlong question reject before preparation', () async {
    final fixture = _Harness();
    await expectLater(
      fixture.send(question: '  '),
      throwsA(_code('invalid-argument')),
    );
    await expectLater(
      fixture.send(question: List.filled(8001, 'x').join()),
      throwsA(_code('invalid-argument')),
    );
    expect(fixture.prepareCalls, 0);
    expect(fixture.agents.urlCalls, 0);
    expect(fixture.runtime.requests, isEmpty);
  });
}
