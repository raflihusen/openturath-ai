import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'agent_service.dart';
import 'browser_companion.dart';
import 'notebook_chat_service.dart';

/// Personal browser session transport; Firebase still owns app entitlement.
class BrowserCompanionChatService extends NotebookChatService {
  BrowserCompanionChatService({AgentService? agents})
      : _agents = agents ?? AgentService();

  final AgentService _agents;
  static final runtime = BrowserCompanionRuntime(identity: currentIdentity);
  static final Map<String, _Conversation> _conversations = {};
  static StreamSubscription<User?>? _accountChanges;
  static String? _ownerKey;
  static int _generation = 0;
  static Future<void>? _starting;

  static CompanionIdentity? currentIdentity() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous || !user.emailVerified) return null;
    final providers = user.providerData.where((p) => p.providerId == 'google.com');
    if (providers.length != 1) return null;
    final provider = providers.single;
    final email = user.email?.trim().toLowerCase();
    if (email == null ||
        email.isEmpty ||
        provider.email?.trim().toLowerCase() != email ||
        !RegExp(r'^\d{1,64}$').hasMatch(provider.uid)) return null;
    return CompanionIdentity(uid: user.uid, googleSub: provider.uid, email: email);
  }

  static String? _key(CompanionIdentity? owner) => owner == null
      ? null
      : '${owner.uid}|${owner.googleSub}|${owner.email}';

  static Future<void> start() =>
      _starting ??= _start().whenComplete(() => _starting = null);

  static Future<void> _start() async {
    final generation = _generation;
    final owner = currentIdentity();
    if (owner == null) {
      throw FirebaseFunctionsException(code: 'unauthenticated',
          message: 'Masuk dengan akun Google Anda terlebih dahulu.');
    }
    final key = _key(owner);
    if (_ownerKey != key) {
      await runtime.stop();
      _conversations.clear();
    }
    if (generation != _generation || _key(currentIdentity()) != key) {
      throw FirebaseFunctionsException(code: 'unauthenticated',
          message: 'Akun berubah ketika penghubung disiapkan.');
    }
    _ownerKey = key;
    _accountChanges ??= FirebaseAuth.instance.userChanges().listen((_) {
      if (_ownerKey != _key(currentIdentity())) unawaited(stop());
    });
    await runtime.start();
    if (generation != _generation || _key(currentIdentity()) != key) {
      await stop();
      throw FirebaseFunctionsException(code: 'unauthenticated',
          message: 'Akun berubah ketika penghubung disiapkan.');
    }
  }

  static Future<void> stop() async {
    _generation++;
    _ownerKey = null;
    _conversations.clear();
    await runtime.stop();
  }

  void _checkOwner(String expectedUid, String ownerKey, int generation) {
    if (currentIdentity()?.uid != expectedUid ||
        _key(currentIdentity()) != ownerKey || _ownerKey != ownerKey ||
        _generation != generation) {
      throw FirebaseFunctionsException(code: 'unauthenticated',
          message: 'Akun berubah. Buka kembali percakapan untuk akun aktif.');
    }
  }

  @override
  Future<NotebookChatReply> ask({required String expectedUid,
    required String agentId, required String question, required String requestId}) async {
    if (question.trim().isEmpty || question.length > 8000) {
      throw FirebaseFunctionsException(code: 'invalid-argument',
          message: 'Pertanyaan kosong atau terlalu panjang.');
    }
    await start();
    final ownerKey = _ownerKey!;
    final generation = _generation;
    _checkOwner(expectedUid, ownerKey, generation);
    if (!runtime.connected) {
      throw FirebaseFunctionsException(code: 'unavailable',
          message: 'Penghubung Google Chrome belum tersambung.');
    }
    try {
      // Resolve from the authenticated server on every send; never client catalog.
      final url = await _agents.getAgentUrl(agentId);
      _checkOwner(expectedUid, ownerKey, generation);
      if (url == null) throw const AgentAccessException('failed-precondition', 'Alamat kajian belum tersedia.');
      final notebookId = Uri.parse(url).pathSegments.where((p) => p.isNotEmpty).last;
      await _agents.recordQuestion(agentId);
      _checkOwner(expectedUid, ownerKey, generation);
      final conversationKey = '$ownerKey|$notebookId';
      final conversation = _conversations[conversationKey];
      final raw = await runtime.ask(expectedUid: expectedUid,
          notebookId: notebookId, question: question.trim(), requestId: requestId,
          history: conversation?.history, conversationId: conversation?.id);
      _checkOwner(expectedUid, ownerKey, generation);
      final reply = NotebookChatService.decodeReply(raw, requestId);
      final next = _Conversation(raw['conversationId'] as String,
          [...?conversation?.history, [reply.answer, null, 2], [question.trim(), null, 1]]);
      // Keep bounded context in memory only. Conversation IDs never become auth.
      while (next.history.length > 40 || jsonEncode(next.history).length > 110000) {
        if (next.history.length < 2) break;
        next.history.removeRange(0, 2);
      }
      _conversations[conversationKey] = next;
      return reply;
    } on AgentAccessException catch (error) {
      throw FirebaseFunctionsException(code: error.code, message: error.message);
    }
  }
}

class _Conversation {
  _Conversation(this.id, this.history);
  final String id;
  final List<List<Object?>> history;
}
