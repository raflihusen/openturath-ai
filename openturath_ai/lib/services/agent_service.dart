import 'package:cloud_functions/cloud_functions.dart';
import '../models/agent_model.dart';
import '../core/constants.dart';

class AgentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ── Ambil daftar semua agent dari Firestore / model lokal ────
  Future<List<AgentModel>> getAgents() async {
    return AgentModel.defaultAgents;
  }

  // ── Ambil URL agent dari Cloud Function secara aman (Server-Side Entitlement) ────
  Future<String?> getAgentUrl(String agentId) async {
    try {
      final callable = _functions.httpsCallable(AppConstants.fnGetAgentUrl);
      final result = await callable.call({'agentId': agentId});
      final data = Map<String, dynamic>.from(result.data);
      final url = data['url'] as String?;
      if (url != null && url.isNotEmpty) {
        return url;
      }
      throw const AgentAccessException('empty-url', 'URL ruang riset belum tersedia untuk modul ini.');
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw AgentAccessException(
          'permission-denied',
          e.message ?? 'Langganan aktif diperlukan untuk mengakses modul riset ini.',
        );
      }
      throw AgentAccessException(e.code, e.message ?? 'Gagal menghubungi server riset.');
    } catch (e) {
      if (e is AgentAccessException) rethrow;
      throw AgentAccessException('unknown-error', e.toString());
    }
  }

  // ── Catat pertanyaan trial secara atomik di Cloud Functions ───
  Future<TrialUsage> recordQuestion(String agentId) async {
    try {
      final callable = _functions.httpsCallable('recordQuestion');
      final result = await callable.call({'agentId': agentId});
      final data = Map<String, dynamic>.from(result.data);
      return TrialUsage(
        isPremium: data['isPremium'] == true,
        questionsUsed: (data['questionsUsed'] as num?)?.toInt() ?? 0,
        questionsRemaining: (data['questionsRemaining'] as num?)?.toInt(),
      );
    } on FirebaseFunctionsException catch (e) {
      throw AgentAccessException(e.code, e.message ?? 'Gagal mencatat kuota pertanyaan.');
    } catch (e) {
      if (e is AgentAccessException) rethrow;
      throw AgentAccessException('record-error', e.toString());
    }
  }
}

class TrialUsage {
  const TrialUsage({
    required this.isPremium,
    required this.questionsUsed,
    required this.questionsRemaining,
  });

  final bool isPremium;
  final int questionsUsed;
  final int? questionsRemaining;
}

class AgentAccessException implements Exception {
  const AgentAccessException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'AgentAccessException($code): $message';
}
