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
  const CallableGateway();

  Future<dynamic> call(String name, [Map<String, dynamic>? data]) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final client = http.Client();
      try {
        return await CallableHttpTransport(
          client: client,
          projectId: Firebase.app().options.projectId,
          token: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
        ).call(name, data);
      } finally {
        client.close();
      }
    }
    final result = await FirebaseFunctions.instance.httpsCallable(
      name,
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    ).call(data);
    return result.data;
  }
}

class CallableHttpTransport {
  const CallableHttpTransport({
    required this.client,
    required this.projectId,
    required this.token,
    this.region = 'us-central1',
    this.timeout = const Duration(seconds: 30),
  });

  final http.Client client;
  final String projectId;
  final String region;
  final Future<String?> Function() token;
  final Duration timeout;

  Future<dynamic> call(String name, [Map<String, dynamic>? data]) async {
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(name)) {
      throw ArgumentError.value(name, 'name', 'Invalid callable name');
    }
    try {
      final idToken = await token().timeout(timeout);
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseFunctionsException(
          code: 'unauthenticated', message: 'Silakan masuk kembali ke akun Anda.',
        );
      }
      // No automatic retry: checkout/redeem/quota calls may mutate server state.
      final response = await client.post(
        Uri.https('$region-$projectId.cloudfunctions.net', '/$name'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'data': data}),
      ).timeout(timeout);
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
              .toLowerCase().replaceAll('_', '-'),
          message: error['message'] as String? ?? 'Layanan belum dapat dihubungi.',
          details: error['details'],
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FirebaseFunctionsException(
          code: 'unavailable', message: 'Layanan belum dapat dihubungi.',
        );
      }
      if (decoded.containsKey('result')) return decoded['result'];
      if (decoded.containsKey('data')) return decoded['data'];
      throw const FormatException('Missing callable result');
    } on FirebaseFunctionsException {
      rethrow;
    } on TimeoutException {
      throw FirebaseFunctionsException(
        code: 'deadline-exceeded', message: 'Server belum merespons. Coba kembali.',
      );
    } on FormatException {
      throw FirebaseFunctionsException(
        code: 'internal', message: 'Respons layanan tidak dapat dibaca.',
      );
    } on http.ClientException {
      throw FirebaseFunctionsException(
        code: 'unavailable', message: 'Periksa koneksi internet Anda.',
      );
    }
  }
}
