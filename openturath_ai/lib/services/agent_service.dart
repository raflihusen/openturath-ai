import 'package:cloud_functions/cloud_functions.dart';
import '../core/notebook_navigation.dart';
import '../models/agent_model.dart';
import 'callable_gateway.dart';
import '../core/constants.dart';

class AgentService {
  AgentService({CallableGateway? functions})
      : _functions = functions ?? const CallableGateway();

  final CallableGateway _functions;

  // ── Ambil daftar semua agent dari Firestore / model lokal ────
  Future<List<AgentModel>> getAgents() async {
    return AgentModel.defaultAgents;
  }

  static final _notebookPath = RegExp(
    r'^/notebook/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/?$',
  );

  // ── Ambil URL agent dari Cloud Function secara aman (Server-Side Entitlement) ────
  Future<String?> getAgentUrl(String agentId) async {
    try {
      final result = await _functions
          .call(AppConstants.fnGetAgentUrl, {'agentId': agentId});
      if (result is! Map) {
        throw const AgentAccessException(
            'invalid-response', 'Respons alamat AI tidak valid.');
      }
      final url = result['url'];
      if (url == null || url == '') {
        throw const AgentAccessException(
            'empty-url', 'URL AI belum tersedia untuk bidang ini.');
      }
      if (url is! String) {
        throw const AgentAccessException(
            'invalid-url', 'Alamat AI dari server tidak valid.');
      }
      final uri = Uri.tryParse(url);
      if (uri == null ||
          url != url.trim() ||
          url.contains('%') ||
          !NotebookNavigation.notebook(uri) ||
          !_notebookPath.hasMatch(uri.path) ||
          uri.hasQuery ||
          uri.hasFragment) {
        throw const AgentAccessException(
            'invalid-url', 'Alamat AI dari server tidak valid.');
      }
      // The authenticated server owns notebook selection and entitlement checks.
      // Preserve its exact notebook ID/path and validate before normalizing only
      // the legacy Google host to the verified Google redirect destination.
      return uri.replace(host: NotebookNavigation.canonicalHost).toString();
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw AgentAccessException(
          'permission-denied',
          e.message ?? 'Langganan diperlukan untuk membuka AI ini.',
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
