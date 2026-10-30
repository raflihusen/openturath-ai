import '../core/localization.dart';
import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Uses the documented callable wire protocol where FlutterFire has no plugin.
/// The same server functions continue to enforce authentication and entitlements.
class CallableGateway {
  const CallableGateway({this.timeout = const Duration(seconds: 30)});

  final Duration timeout;

  Future<dynamic> call(String name, [Map<String, dynamic>? data]) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final client = http.Client();
      try {
        return await CallableHttpTransport(
          client: client,
          projectId: Firebase.app().options.projectId,
          token: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
          refreshToken: () async =>
              FirebaseAuth.instance.currentUser?.getIdToken(true),
          timeout: timeout,
        ).call(name, data);
      } finally {
        client.close();
      }
    }
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable(
            name,
            options: HttpsCallableOptions(timeout: timeout),
          )
          .call(data);
      return result.data;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unauthenticated' &&
          FirebaseAuth.instance.currentUser != null) {
        try {
          await FirebaseAuth.instance.currentUser?.getIdToken(true);
          final retryResult = await FirebaseFunctions.instance
              .httpsCallable(
                name,
                options: HttpsCallableOptions(timeout: timeout),
              )
              .call(data);
          return retryResult.data;
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }
}

class CallableHttpTransport {
  const CallableHttpTransport({
    required this.client,
    required this.projectId,
    required this.token,
    this.refreshToken,
    this.region = 'us-central1',
    this.timeout = const Duration(seconds: 30),
  });

  final http.Client client;
  final String projectId;
  final String region;
  final Future<String?> Function() token;

  /// Dipanggil sekali bila server menolak dengan `unauthenticated`. Penolakan
  /// autentikasi terjadi sebelum fungsi berjalan, sehingga mengulang dengan
  /// token segar tidak menggandakan efek mutasi.
  final Future<String?> Function()? refreshToken;
  final Duration timeout;

  Future<dynamic> call(String name, [Map<String, dynamic>? data]) async {
    try {
      return await _attempt(name, data, token);
    } on FirebaseFunctionsException catch (e) {
      final refresh = refreshToken;
      if (e.code != 'unauthenticated' || refresh == null) rethrow;
      return _attempt(name, data, refresh);
    }
  }

  Future<dynamic> _attempt(String name, Map<String, dynamic>? data,
      Future<String?> Function() obtainToken) async {
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(name)) {
      throw ArgumentError.value(name, 'name', 'Invalid callable name');
    }
    try {
      final idToken = await obtainToken().timeout(timeout);
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseFunctionsException(
          code: 'unauthenticated',
          message: Loc.tr('errSignInAgain'),
        );
      }
      // Retry hanya lewat call() untuk penolakan `unauthenticated`.
      final response = await client
          .post(
            Uri.https('$region-$projectId.cloudfunctions.net', '/$name'),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({'data': data}),
          )
          .timeout(timeout);
      if (response.bodyBytes.length > 2 * 1024 * 1024) {
        throw const FormatException('Callable response is too large');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid callable envelope');
      }
      final error = decoded['error'];
      if (error is Map) {
        throw FirebaseFunctionsException(
          code: (error['status'] as String? ?? 'INTERNAL')
              .toLowerCase()
              .replaceAll('_', '-'),
          message:
              error['message'] as String? ?? Loc.tr('errServiceUnavailable'),
          details: error['details'],
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FirebaseFunctionsException(
          code: 'unavailable',
          message: Loc.tr('errServiceUnavailable'),
        );
      }
      if (decoded.containsKey('result')) return decoded['result'];
      if (decoded.containsKey('data')) return decoded['data'];
      throw const FormatException('Missing callable result');
    } on FirebaseFunctionsException {
      rethrow;
    } on TimeoutException {
      throw FirebaseFunctionsException(
        code: 'deadline-exceeded',
        message: Loc.tr('errServerTimeout'),
      );
    } on FormatException {
      throw FirebaseFunctionsException(
        code: 'internal',
        message: Loc.tr('errUnreadableResponse'),
      );
    } on http.ClientException {
      throw FirebaseFunctionsException(
        code: 'unavailable',
        message: Loc.tr('errCheckConnection'),
      );
    }
  }
}
