import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openturath_ai/models/room_failure.dart';
import 'package:openturath_ai/services/auth_failure_reporter.dart';
import 'package:openturath_ai/services/diagnostic_report_service.dart';

void main() {
  RoomFailure incident() => RoomFailure(stage: 'agent-url', code: 'unavailable',
      agentId: 'fiqh_syafii', attemptId: newDiagnosticId());

  test('identitas laporan hanya dikirim sebagai header dan insiden tidak diduplikasi', () async {
    var calls = 0;
    final failure = incident();
    final client = MockClient((request) async {
      calls++;
      expect(request.headers['Authorization'], 'Bearer fixture-private-token');
      expect(request.body, isNot(contains('fixture-private-token')));
      expect(jsonDecode(request.body)['event_id'], failure.eventId);
      return http.Response('{"ref":"OT-A1B2C3"}', 200);
    });
    for (var i = 0; i < 2; i++) {
      expect(await DiagnosticReportService.send(stage: 's', code: 'c',
          failure: failure, client: client,
          authToken: () async => 'fixture-private-token'), 'OT-A1B2C3');
    }
    expect(calls, 1);
    client.close();
  });

  test('pengiriman gagal boleh dicoba ulang; token gagal tetap dapat melapor anonim', () async {
    var calls = 0;
    final failure = incident();
    final client = MockClient((request) async {
      expect(request.headers.containsKey('Authorization'), false);
      return ++calls == 1 ? http.Response('', 503)
          : http.Response('{"ref":"OT-C3B2A1"}', 200);
    });
    Future<String?> token() async => throw StateError('unavailable');
    expect(await DiagnosticReportService.send(stage: 's', code: 'c',
        failure: failure, client: client, authToken: token), isNull);
    expect(await DiagnosticReportService.send(stage: 's', code: 'c',
        failure: failure, client: client, authToken: token), 'OT-C3B2A1');
    expect(calls, 2);
    client.close();
  });

  test('metadata insiden menolak nilai token yang menyerupai identifier', () {
    final failure = RoomFailure(stage: 'room-load', code: 'load-failed',
        agentId: 'fiqh_syafii', attemptId: 'private.token.value',
        requestId: 'private.token.value', reason: 'private.token.value',
        eventId: 'private.token.value', pageScheme: 'private.token.value');
    expect(jsonEncode(failure.metadata), isNot(contains('private.token.value')));
  });

  test('laporan menyebut skema dan nomor build agar versi kejadian tidak tertukar', () {
    final payload = DiagnosticReportService.payload(stage: 'agent-url', code: 'unavailable');
    expect(payload['schema_version'], 2);
    expect(payload.containsKey('buildNumber'), isTrue);
    expect(payload['edition'], 'standard');
  });

  test('alamat diagnostik membuang skema nonweb dan email di dalam path', () {
    expect(DiagnosticReportService.safePage('javascript://host/private'), 'unknown');
    final page = DiagnosticReportService.safePage(
      'https://accounts.google.com/user/reader%40example.invalid?token=secret');
    expect(page.contains('reader'), isFalse);
    expect(page.contains('secret'), isFalse);
  });
  test('safePage membuang query dan fragmen', () {
    expect(
        DiagnosticReportService.safePage(
            'https://accounts.google.com/signin/v2?token=abc#x'),
        'https://accounts.google.com/signin/v2');
    expect(DiagnosticReportService.safePage('bukan url'), 'unknown');
    expect(DiagnosticReportService.safePage(null), 'unknown');
  });

  test('payload menyamarkan email dan token di jejak langkah', () {
    final p = DiagnosticReportService.payload(
      stage: 'room-load',
      code: 'google-rejected',
      page: 'https://notebooklm.google.com/notebook/x?authuser=a@b.com',
      flags: {'sid_cookie': true},
      breadcrumbs: [
        {'message': 'masuk a@b.com Bearer abc.def', 'category': 'action'}
      ],
    );
    final dump = jsonEncode(p);
    expect(dump.contains('a@b.com'), isFalse);
    expect(dump.contains('abc.def'), isFalse);
    expect(p['page'], 'https://notebooklm.google.com/notebook/x');
    expect(p['stage'], 'room-load');
  });

  test('send mengembalikan kode rujukan, null bila server menolak', () async {
    final ok = await DiagnosticReportService.send(
        stage: 's',
        code: 'c',
        sender: (u, b) async => http.Response('{"ref":"OT-1A2B3C"}', 200));
    expect(ok, 'OT-1A2B3C');
    final bad = await DiagnosticReportService.send(
        stage: 's',
        code: 'c',
        sender: (u, b) async => http.Response('', 429));
    expect(bad, isNull);
    final boom = await DiagnosticReportService.send(
        stage: 's', code: 'c', sender: (u, b) async => throw Exception('x'));
    expect(boom, isNull);
  });

  test('reportOnce hanya mengirim sekali per tahap+kode', () {
    AuthFailureReporter.resetOnceForTest();
    var n = 0;
    Future<http.Response> sender(Uri u, Map<String, String> b) async {
      n++;
      return http.Response('', 204);
    }

    AuthFailureReporter.reportOnce(stage: 'a', code: 'b', sender: sender);
    AuthFailureReporter.reportOnce(stage: 'a', code: 'b', sender: sender);
    AuthFailureReporter.reportOnce(stage: 'a', code: 'c', sender: sender);
    expect(n, 2);
  });
}
