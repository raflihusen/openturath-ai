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

  static const Map<String, String> _canonicalMasterNotebookUrls = {
    'fiqh_syafii':
        'https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862',
    'fiqh_syafii_muhaqqiq':
        'https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862',
    'fiqh_tahawwulat':
        'https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4',
    'fiqh_tahawwulat_muhaqqiq':
        'https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4',
    'fiqh_tahawwulat_bayan':
        'https://notebooklm.google.com/notebook/483d0291-0a70-411c-bff0-f1ea4b83b2fd',
    'fiqh_tahawwulat_mukhtabir':
        'https://notebooklm.google.com/notebook/ac61a7a0-87e7-42a5-a30f-980ff74a78d8',
    'fiqh_tahawwulat_habib':
        'https://notebooklm.google.com/notebook/6673e79a-7156-42e1-b116-bc1653a32094',
    'fiqh_tahawwulat_khatib':
        'https://notebooklm.google.com/notebook/1288e413-9569-47a3-892f-64008e53c1e8',
    'nahwu':
        'https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06',
    'hadits':
        'https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6',
    'tafsir':
        'https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe',
    'ushul_fiqh':
        'https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12',
  };

  // ── Ambil URL agent dari Cloud Function secara aman (Server-Side Entitlement) ────
  Future<String?> getAgentUrl(String agentId) async {
    try {
      final result = await _functions
          .call(AppConstants.fnGetAgentUrl, {'agentId': agentId});
      final data = Map<String, dynamic>.from(result as Map);
      var url = data['url'] as String?;
      
      // Sanitasi ke Master Notebook resmi terverifikasi agar tidak diarahkan ke klon tidak terdaftar
      if (_canonicalMasterNotebookUrls.containsKey(agentId)) {
        url = _canonicalMasterNotebookUrls[agentId];
      }

      if (url != null && url.isNotEmpty) {
        return url;
      }
      throw const AgentAccessException(
          'empty-url', 'URL asisten belum tersedia untuk bidang ini.');
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw AgentAccessException(
          'permission-denied',
          e.message ?? 'Langganan diperlukan untuk membuka asisten ini.',
        );
      }
      throw AgentAccessException(
          e.code, e.message ?? 'Tidak dapat terhubung ke server.');
    } catch (e) {
      if (e is AgentAccessException) rethrow;
      throw AgentAccessException('unknown-error', e.toString());
    }
  }

  // ── Catat pertanyaan trial secara atomik di Cloud Functions ───
  Future<TrialUsage> recordQuestion(String agentId) async {
    try {
      final result =
          await _functions.call('recordQuestion', {'agentId': agentId});
      final data = Map<String, dynamic>.from(result as Map);
      return TrialUsage(
        isPremium: data['isPremium'] == true,
        questionsUsed: (data['questionsUsed'] as num?)?.toInt() ?? 0,
        questionsRemaining: (data['questionsRemaining'] as num?)?.toInt(),
      );
    } on FirebaseFunctionsException catch (e) {
      throw AgentAccessException(
          e.code, e.message ?? 'Gagal mencatat kuota pertanyaan.');
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
