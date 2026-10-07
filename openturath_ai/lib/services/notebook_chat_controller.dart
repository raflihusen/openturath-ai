import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../models/answer_citation.dart';
import '../models/turath_chat_message.dart';
import 'notebook_chat_service.dart';

class NotebookChatController extends ChangeNotifier {
  NotebookChatController(
      {required this.agentId,
      required this.currentUid,
      NotebookChatService service = const NotebookChatService()})
      : _service = service;

  final String agentId;
  final String? Function() currentUid;
  final NotebookChatService _service;
  final List<TurathChatMessage> _messages = [];
  String? _owner;
  int _epoch = 0;
  bool _disposed = false;
  bool isGenerating = false;
  String? error;

  List<TurathChatMessage> get messages => List.unmodifiable(_messages);

  void synchronizeOwner() {
    if (_disposed || _owner == currentUid()) return;
    _owner = currentUid();
    _epoch++;
    _messages.clear();
    isGenerating = false;
    error = null;
    notifyListeners();
  }

  Future<void> send(String question) async {
    if (_disposed) return;
    synchronizeOwner();
    if (isGenerating || question.trim().isEmpty) return;
    final owner = _owner;
    if (owner == null || question.length > 8000) {
      error = owner == null
          ? 'Silakan masuk ke OpenTurath.'
          : 'Pertanyaan terlalu panjang.';
      notifyListeners();
      return;
    }
    final epoch = _epoch;
    final random = Random.secure();
    final id = List.generate(
            16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
    _messages.add(TurathChatMessage(
        id: '${id}_q',
        text: question.trim(),
        isUser: true,
        timestamp: DateTime.now()));
    isGenerating = true;
    error = null;
    notifyListeners();
    try {
      final reply = await _service.ask(
          expectedUid: owner,
          agentId: agentId,
          question: question,
          requestId: id);
      if (_disposed || epoch != _epoch || currentUid() != owner) return;
      _messages.add(TurathChatMessage(
          id: '${id}_a',
          text: reply.answer,
          isUser: false,
          timestamp: DateTime.now(),
          citations: reply.citations.map((ref) => ref.display).toList(),
          references: reply.citations
              .map((ref) => AnswerCitation(
                  sourceId: ref.sourceId,
                  number: ref.number,
                  excerpt: ref.excerpt))
              .toList()));
    } on FirebaseFunctionsException catch (failure) {
      if (_disposed || epoch != _epoch || currentUid() != owner) return;
      error = switch (failure.code) {
        'unauthenticated' => 'Silakan masuk kembali ke OpenTurath.',
        'notebook-session-required' =>
          'Buka ruang AI di profil Chrome tempat penghubung dipasang, lalu masuk dengan akun Google yang sama dengan OpenTurath.',
        'permission-denied' => 'Akses kajian ini belum aktif untuk akun Anda.',
        'account-mismatch' =>
          'Akun Google di Chrome berbeda. Gunakan akun yang sama dengan OpenTurath.',
        'uncertain' =>
          'Pengiriman terputus. Pertanyaan mungkin sudah diterima; tidak dikirim ulang otomatis.',
        'busy' => 'Tunggu jawaban percakapan yang sedang berjalan.',
        'unavailable' =>
          'Penghubung AI belum tersambung. Periksa koneksi Anda.',
        'failed-precondition' =>
          'Koneksi AI di aplikasi belum diaktifkan.',
        'resource-exhausted' =>
          'Terlalu banyak pertanyaan. Silakan tunggu sebentar.',
        'deadline-exceeded' =>
          'Respons belum diterima. Pertanyaan tidak dikirim ulang otomatis.',
        _ =>
          'AI belum dapat menjawab. Pertanyaan tidak dikirim ulang otomatis.',
      };
    } catch (_) {
      if (_disposed || epoch != _epoch || currentUid() != owner) return;
      error =
          'AI belum dapat dihubungi. Pertanyaan tidak dikirim ulang otomatis.';
    } finally {
      if (!_disposed && epoch == _epoch) {
        if (currentUid() != owner) {
          synchronizeOwner();
        } else {
          isGenerating = false;
          notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _messages.clear();
    super.dispose();
  }
}
