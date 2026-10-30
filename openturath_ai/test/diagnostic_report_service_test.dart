import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:openturath_ai/services/auth_failure_reporter.dart';
import 'package:openturath_ai/services/diagnostic_report_service.dart';

void main() {
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
