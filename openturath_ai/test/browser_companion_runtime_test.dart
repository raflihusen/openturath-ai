import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:openturath_ai/services/browser_companion_runtime.dart';

const notebook = '11111111-1111-1111-1111-111111111111';
const conversation = '22222222-2222-2222-2222-222222222222';
const source = '33333333-3333-3333-3333-333333333333';
const clientId = 'ffffffffffffffffffffffffffffffff';
const requestId = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

Matcher code(String value) => isA<FirebaseFunctionsException>().having(
      (error) => error.code,
      'safe error code',
      value,
    );

Future<Map<String, dynamic>> metadata(Directory directory) async =>
    Map<String, dynamic>.from(
      jsonDecode(
        await File(p.join(directory.path, 'runtime.json')).readAsString(),
      ) as Map,
    );

Future<({int status, Map<String, dynamic> body})> post(
  Map<String, dynamic> runtime,
  String path,
  Map<String, dynamic> body, {
  String? host,
  String? origin,
  String? authorization,
  ContentType? contentType,
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  try {
    final request = await client.postUrl(
      Uri.parse('http://127.0.0.1:${runtime['port']}$path'),
    );
    request.headers.set(
      HttpHeaders.hostHeader,
      host ?? '127.0.0.1:${runtime['port']}',
    );
    request.headers.set(
      HttpHeaders.authorizationHeader,
      authorization ?? 'Bearer ${runtime['bearer']}',
    );
    if (origin != null) request.headers.set('origin', origin);
    request.headers.contentType = contentType ?? ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close().timeout(const Duration(seconds: 2));
    final decoded = jsonDecode(
      await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 2)),
    );
    return (
      status: response.statusCode,
      body: Map<String, dynamic>.from(decoded as Map),
    );
  } finally {
    client.close(force: true);
  }
}

Map<String, dynamic> envelope(
  Map<String, dynamic> runtime, {
  String client = clientId,
}) =>
    {'clientId': client, 'epoch': runtime['epoch']};

Future<void> attach(
  Map<String, dynamic> runtime, {
  String client = clientId,
}) async {
  final response = await post(runtime, '/attach', {
    ...envelope(runtime, client: client),
    'protocol': 1,
  });
  expect(response.status, 200);
  expect(response.body, {'ok': true});
}

Future<Map<String, dynamic>> pollJob(Map<String, dynamic> runtime) async {
  for (var count = 0; count < 100; count++) {
    final response = await post(runtime, '/poll', envelope(runtime));
    expect(response.status, 200);
    if (response.body['job'] != null) {
      return Map<String, dynamic>.from(response.body['job'] as Map);
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('Fixture job was not queued.');
}

Map<String, dynamic> reply(Map<String, dynamic> job) => {
      for (final key in [
        'requestId',
        'epoch',
        'uid',
        'googleSub',
        'email',
        'notebookId',
      ])
        key: job[key],
      'answer': 'Fixture answer that must not be stored in the ledger.',
      'citations': [
        {'sourceId': source, 'citationNumber': 1, 'excerpt': 'Fixture source.'},
      ],
      'conversationId': conversation,
      'accountEmail': job['email'],
    };

void main() {
  test('native identity rejects an absent subject or ambiguous email', () {
    expect(
      () => CompanionIdentity(
        uid: 'fixture',
        googleSub: '',
        email: 'fixture@example.com',
      ),
      throwsArgumentError,
    );
    expect(
      () => CompanionIdentity(
        uid: 'fixture',
        googleSub: '123',
        email: 'Fixture@example.com',
      ),
      throwsArgumentError,
    );
  });

  group(
    'private loopback companion with synthetic identities',
    () {
      late Directory temporary;
      late Directory directory;
      late CompanionIdentity? owner;
      late BrowserCompanionRuntime runtime;

      setUp(() async {
        temporary = await Directory.systemTemp.createTemp(
          'openturath-companion-fixture-',
        );
        directory = Directory(p.join(temporary.path, 'runtime'));
        owner = CompanionIdentity(
          uid: 'fixture-user',
          googleSub: '123456',
          email: 'fixture@example.com',
        );
        runtime = BrowserCompanionRuntime(
          identity: () => owner,
          runtimeDirectory: directory,
          responseTimeout: const Duration(seconds: 2),
        );
      });
      tearDown(() async {
        await runtime.stop();
        runtime.dispose();
        await runtime.stop();
        await temporary.delete(recursive: true);
      });

      test(
        'metadata is private and wrong host, Origin and bearer never attach',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          expect(meta.keys.toSet(), {
            'version',
            'port',
            'bearer',
            'epoch',
            'pid',
          });
          expect(meta['bearer'], matches(RegExp(r'^[0-9a-f]{64}$')));
          expect(meta['epoch'], matches(RegExp(r'^[0-9a-f]{32}$')));
          expect((await directory.stat()).mode & 0x1ff, 0x1c0);
          expect(
            (await File(p.join(directory.path, 'runtime.json')).stat()).mode &
                0x1ff,
            0x180,
          );
          final body = {...envelope(meta), 'protocol': 1};
          expect(
            (await post(
              meta,
              '/attach',
              body,
              host: 'localhost:${meta['port']}',
            ))
                .status,
            403,
          );
          expect(
            (await post(
              meta,
              '/attach',
              body,
              origin: 'https://notebooklm.google.com',
            ))
                .status,
            403,
          );
          expect(
            (await post(meta, '/attach', body, origin: 'null')).status,
            403,
          );
          expect(
            (await post(
              meta,
              '/attach',
              body,
              authorization: 'Bearer ${'0' * 64}',
            ))
                .status,
            403,
          );
          expect(runtime.connected, isFalse);
          await attach(meta);
          expect(runtime.connected, isTrue);
          final second = await post(meta, '/attach', {
            ...envelope(meta, client: 'e' * 32),
            'protocol': 1,
          });
          expect(second.status, 409);
        },
      );

      test(
        'dispatch is durable before exposure and success stores no prompt, answer or bearer',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          const question =
              'Private fixture question that must not enter the ledger.';
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: question,
            requestId: requestId,
          );
          final job = await pollJob(meta);
          final ledgerFile = File(p.join(directory.path, 'ledger.json'));
          final ledger = jsonDecode(await ledgerFile.readAsString()) as Map;
          expect((ledger['records'] as List).single['state'], 'dispatched');
          expect((await post(meta, '/poll', envelope(meta))).body, {
            'job': null,
          });
          final answer = reply(job)
            ..['unexpectedPrivateToken'] = 'MUST_NOT_ESCAPE';
          final response = await post(meta, '/result', {
            ...envelope(meta),
            'result': answer,
          });
          expect(response.status, 200);
          final result = await future;
          expect(result['accountEmail'], owner!.email);
          expect(result['conversationId'], conversation);
          expect(result.containsKey('unexpectedPrivateToken'), isFalse);
          final stored = await ledgerFile.readAsString();
          expect(stored.contains(question), isFalse);
          expect(stored.contains(answer['answer'] as String), isFalse);
          expect(stored.contains(meta['bearer'] as String), isFalse);
          await expectLater(
            runtime.ask(
              expectedUid: owner!.uid,
              notebookId: notebook,
              question: question,
              requestId: requestId,
            ),
            throwsA(code('failed-precondition')),
          );
        },
      );

      test(
        'foreign correlation cannot complete the current owner request',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture question',
            requestId: requestId,
          );
          final job = await pollJob(meta);
          final bad = reply(job)..['googleSub'] = '999999';
          expect(
            (await post(meta, '/result', {
              ...envelope(meta),
              'result': bad,
            }))
                .body['code'],
            'account-mismatch',
          );
          await post(meta, '/result', {
            ...envelope(meta),
            'result': reply(job),
          });
          expect((await future)['answer'], startsWith('Fixture answer'));
        },
      );

      test(
        'the observed browser email is required even with a matching subject echo',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture question',
            requestId: requestId,
          );
          final expected = expectLater(
            future,
            throwsA(code('account-mismatch')),
          );
          final job = await pollJob(meta);
          final bad = reply(job)..['accountEmail'] = 'other@example.com';
          await post(meta, '/result', {...envelope(meta), 'result': bad});
          await expected;
        },
      );

      test(
        'disconnect invalidates dispatched requests without replay after reattach',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture question',
            requestId: requestId,
          );
          final expected = expectLater(future, throwsA(code('uncertain')));
          await pollJob(meta);
          expect((await post(meta, '/disconnect', envelope(meta))).status, 200);
          await expected;
          expect(runtime.connected, isFalse);
          await attach(meta);
          expect((await post(meta, '/poll', envelope(meta))).body, {
            'job': null,
          });
          await expectLater(
            runtime.ask(
              expectedUid: owner!.uid,
              notebookId: notebook,
              question: 'Same ID cannot be reused',
              requestId: requestId,
            ),
            throwsA(code('failed-precondition')),
          );
        },
      );

      test(
        'owner subject changes discard a late answer even if email stays the same',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture question',
            requestId: requestId,
          );
          final expected = expectLater(future, throwsA(code('uncertain')));
          final job = await pollJob(meta);
          owner = CompanionIdentity(
            uid: 'new-fixture-user',
            googleSub: '987654',
            email: 'fixture@example.com',
          );
          expect(
            (await post(meta, '/result', {
              ...envelope(meta),
              'result': reply(job),
            }))
                .body['code'],
            'unauthenticated',
          );
          await expected;
          expect(runtime.connected, isFalse);
          expect(runtime.status, 'signed-out');
        },
      );

      test(
        'logout revokes the client and queued request before it reaches the browser',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture question',
            requestId: requestId,
          );
          final expected = expectLater(
            future,
            throwsA(code('unauthenticated')),
          );
          // Wait for durable queueing, without polling a job into Chrome.
          for (var count = 0; count < 100; count++) {
            final file = File(p.join(directory.path, 'ledger.json'));
            if (await file.exists() &&
                (await file.readAsString()).contains(requestId)) {
              break;
            }
            await Future<void>.delayed(const Duration(milliseconds: 5));
          }
          owner = null;
          expect(
            (await post(meta, '/poll', envelope(meta))).body['code'],
            'unauthenticated',
          );
          await expected;
          await runtime.stop();
          expect(
            await File(p.join(directory.path, 'runtime.json')).exists(),
            isFalse,
          );
        },
      );

      test(
        'timeout is uncertain and no late poll reconstructs the question',
        () async {
          runtime.dispose();
          await runtime.stop();
          runtime = BrowserCompanionRuntime(
            identity: () => owner,
            runtimeDirectory: directory,
            responseTimeout: const Duration(milliseconds: 40),
          );
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          await expectLater(
            runtime.ask(
              expectedUid: owner!.uid,
              notebookId: notebook,
              question: 'Fixture timeout',
              requestId: requestId,
            ),
            throwsA(code('uncertain')),
          );
          expect((await post(meta, '/poll', envelope(meta))).body, {
            'job': null,
          });
          final stored = jsonDecode(
            await File(
              p.join(directory.path, 'ledger.json'),
            ).readAsString(),
          ) as Map;
          expect((stored['records'] as List).single['state'], 'uncertain');
        },
      );

      test(
        'restart retains consumed IDs and never reconstructs a dispatched request',
        () async {
          await runtime.start();
          final first = await metadata(directory);
          await attach(first);
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture restart',
            requestId: requestId,
          );
          final expected = expectLater(future, throwsA(code('uncertain')));
          await pollJob(first);
          await runtime.stop();
          await expected;
          await runtime.start();
          final second = await metadata(directory);
          expect(second['epoch'], isNot(first['epoch']));
          await attach(second);
          expect((await post(second, '/poll', envelope(second))).body, {
            'job': null,
          });
          await expectLater(
            runtime.ask(
              expectedUid: owner!.uid,
              notebookId: notebook,
              question: 'Must not replay',
              requestId: requestId,
            ),
            throwsA(code('failed-precondition')),
          );
        },
      );

      test('metadata from another epoch is preserved on stop', () async {
        await runtime.start();
        final file = File(p.join(directory.path, 'runtime.json'));
        final meta = await metadata(directory);
        meta['epoch'] = '1' * 32;
        await file.writeAsString(jsonEncode(meta), flush: true);
        await runtime.stop();
        expect(await file.exists(), isTrue);
        expect((await metadata(directory))['epoch'], '1' * 32);
      });

      test(
        'symlinked runtime directories are rejected without modifying the target',
        () async {
          final target = Directory(p.join(temporary.path, 'outside'));
          await target.create();
          await Link(directory.path).create(target.path);
          await expectLater(
            runtime.start(),
            throwsA(code('failed-precondition')),
          );
          expect(
            await File(p.join(target.path, 'runtime.json')).exists(),
            isFalse,
          );
        },
      );

      test('only JSON UTF-8 IPC bodies are accepted', () async {
        await runtime.start();
        final meta = await metadata(directory);
        final body = {...envelope(meta), 'protocol': 1};
        expect(
            (await post(meta, '/attach', body, contentType: ContentType.text))
                .status,
            415);
        expect(
            (await post(meta, '/attach', body,
                    contentType:
                        ContentType('application', 'json', charset: 'latin1')))
                .status,
            415);
        expect(runtime.connected, isFalse);
      });

      test('same-client attach maintains heartbeat while an answer is pending',
          () async {
        runtime.dispose();
        await runtime.stop();
        runtime = BrowserCompanionRuntime(
            identity: () => owner,
            runtimeDirectory: directory,
            heartbeatTimeout: const Duration(milliseconds: 300),
            responseTimeout: const Duration(seconds: 2));
        await runtime.start();
        final meta = await metadata(directory);
        await attach(meta);
        final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture slow answer',
            requestId: requestId);
        final job = await pollJob(meta);
        for (var count = 0; count < 2; count++) {
          await Future<void>.delayed(const Duration(milliseconds: 180));
          await attach(meta);
        }
        expect(runtime.connected, isTrue);
        expect((await post(meta, '/poll', envelope(meta))).body, {'job': null});
        await post(meta, '/result', {...envelope(meta), 'result': reply(job)});
        expect((await future)['accountEmail'], owner!.email);
      });

      test('an expired client cannot replay its pending request on attach',
          () async {
        runtime.dispose();
        await runtime.stop();
        runtime = BrowserCompanionRuntime(
            identity: () => owner,
            runtimeDirectory: directory,
            heartbeatTimeout: const Duration(milliseconds: 250),
            responseTimeout: const Duration(seconds: 2));
        await runtime.start();
        final meta = await metadata(directory);
        await attach(meta);
        final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture expired client',
            requestId: requestId);
        final expected = expectLater(future, throwsA(code('uncertain')));
        await pollJob(meta);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(runtime.connected, isFalse);
        await attach(meta);
        await expected;
        expect((await post(meta, '/poll', envelope(meta))).body, {'job': null});
      });

      test(
        'invalid citation shape and unknown error codes remain safe failures',
        () async {
          await runtime.start();
          final meta = await metadata(directory);
          await attach(meta);
          final future = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture invalid citation',
            requestId: requestId,
          );
          final expected = expectLater(
            future,
            throwsA(code('failed-precondition')),
          );
          final job = await pollJob(meta);
          final bad = reply(job)
            ..['citations'] = [
              {'sourceId': source, 'citationNumber': 0, 'excerpt': 'fixture'},
            ];
          await post(meta, '/result', {...envelope(meta), 'result': bad});
          await expected;
          final another = runtime.ask(
            expectedUid: owner!.uid,
            notebookId: notebook,
            question: 'Fixture invalid code',
            requestId: 'b' * 32,
          );
          final anotherExpected = expectLater(
            another,
            throwsA(code('failed-precondition')),
          );
          final next = await pollJob(meta);
          await post(meta, '/result', {
            ...envelope(meta),
            'result': reply(next)..['code'] = 'PRIVATE_RAW_ERROR',
          });
          await anotherExpected;
        },
      );
    },
    skip: !(Platform.isMacOS || Platform.isLinux),
  );
}
