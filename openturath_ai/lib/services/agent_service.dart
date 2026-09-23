import 'package:cloud_functions/cloud_functions.dart';
import '../models/agent_model.dart';
import 'callable_gateway.dart';
import '../core/constants.dart';

class AgentService {
  final CallableGateway _functions = const CallableGateway();

  // ── Ambil daftar semua agent dari Firestore / model lokal ────
  Future<List<AgentModel>> getAgents() async {
    return AgentModel.defaultAgents;
  }

  // ── Ambil URL agent dari Cloud Function secara aman (Server-Side Entitlement) ────
  Future<String?> getAgentUrl(String agentId) async {
    try {
      final result = await _functions.call(AppConstants.fnGetAgentUrl, {'agentId': agentId});
      final data = Map<String, dynamic>.from(result as Map);
      final url = data['url'] as String?;
      if (url != null && url.isNotEmpty) {
        return url;
      }
      throw const AgentAccessException('empty-url', 'URL asisten belum tersedia untuk bidang ini.');
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw AgentAccessException(
          'permission-denied',
          e.message ?? 'Langganan diperlukan untuk membuka asisten ini.',
        );
      }
      throw AgentAccessException(e.code, e.message ?? 'Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is AgentAccessException) rethrow;
      throw AgentAccessException('unknown-error', e.toString());
    }
  }

  // ── Catat pertanyaan trial secara atomik di Cloud Functions ───
  Future<TrialUsage> recordQuestion(String agentId) async {
    try {
      final result = await _functions.call('recordQuestion', {'agentId': agentId});
      final data = Map<String, dynamic>.from(result as Map);
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
