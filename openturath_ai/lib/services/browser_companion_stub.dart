import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class CompanionIdentity {
  const CompanionIdentity({
    required this.uid,
    required this.googleSub,
    required this.email,
  });
  final String uid;
  final String googleSub;
  final String email;
}

/// Chrome native messaging is a desktop capability. Fail explicitly elsewhere.
class BrowserCompanionRuntime extends ChangeNotifier {
  BrowserCompanionRuntime({required this.identity});
  final CompanionIdentity? Function() identity;
  bool get connected => false;
  String get status => 'unsupported';
  Future<void> start() async => throw FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'Penghubung ini memerlukan aplikasi desktop dan Google Chrome.',
      );
  Future<void> stop() async {}
  Future<Map<String, dynamic>> ask({
    required String expectedUid,
    required String notebookId,
    required String question,
    required String requestId,
    List<List<Object?>>? history,
    String? conversationId,
  }) async {
    await start();
    throw StateError('Unsupported transport');
  }
}
