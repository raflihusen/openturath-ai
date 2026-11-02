import '../core/localization.dart';
import '../core/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../core/notebook_navigation.dart';
import '../models/agent_model.dart';
import 'callable_gateway.dart';
import '../core/constants.dart';

class AgentService {
  AgentService({
    CallableGateway? functions,
    @visibleForTesting Future<Set<String>?> Function()? activeIdsLoader,
  })  : _functions = functions ?? const CallableGateway(),
        _activeIdsLoader = activeIdsLoader;

  final CallableGateway _functions;
  final Future<Set<String>?> Function()? _activeIdsLoader;

  static Set<String>? _cachedActiveIds;
  static DateTime? _lastAgentsFetch;
  static int _requestGeneration = 0;

  /// Memberi tahu layar ketika daftar yang berhasil dibaca berubah.
  static final ValueNotifier<int> availabilityRevision = ValueNotifier<int>(0);

  @visibleForTesting
  static void resetCacheForTest() {
    _requestGeneration++;
    _cachedActiveIds = null;
    _lastAgentsFetch = null;
  }


  /// Whitelist peluncuran perdana bawaan: Hanya Fikih Tahawwulat & Fikih Syafi'i (dan subagennya).
  static const defaultLaunchActiveIds = <String>{
    'fiqh_tahawwulat',
    'fiqh_tahawwulat_muhaqqiq',
    'fiqh_tahawwulat_bayan',
    'fiqh_tahawwulat_mukhtabir',
    'fiqh_tahawwulat_habib',
    'fiqh_tahawwulat_khatib',
    'fiqh_syafii',
    'fiqh_syafii_muhaqqiq',
  };

  static List<AgentModel> _applyActiveStatus(
      List<AgentModel> baseAgents, Set<String> activeIds) {
    if (AppConfig.isGuruEdition) {
      return baseAgents
          .map((agent) => agent.copyWith(status: 'active'))
          .toList();
    }
    return baseAgents.map((agent) {
      final isDirectActive = activeIds.contains(agent.id);
      final isParentActive = (agent.id.startsWith('fiqh_tahawwulat') &&
              activeIds.contains('fiqh_tahawwulat')) ||
          (agent.id.startsWith('fiqh_syafii') &&
              activeIds.contains('fiqh_syafii'));

      if (isDirectActive || isParentActive) {
        return agent.copyWith(status: 'active');
      } else {
        return agent.copyWith(status: 'coming_soon');
      }
    }).toList();
  }

  /// Sinkronisasi instan daftar agen dengan status aktif/rilis saat ini
  static List<AgentModel> getActiveAgentsSync() {
    final activeIds = _cachedActiveIds ?? defaultLaunchActiveIds;
    return _applyActiveStatus(AgentModel.defaultAgents, activeIds);
  }

  // ── Ambil daftar semua agent dari Firestore / model lokal dengan filtering OTA ────
  Future<List<AgentModel>> getAgents({
    bool forceRefresh = false,
    FirebaseFirestore? firestore,
  }) async {
    final now = DateTime.now();
    final shouldFetch = forceRefresh ||
        _cachedActiveIds == null ||
        _lastAgentsFetch == null ||
        now.difference(_lastAgentsFetch!).inSeconds >= 60;

    if (shouldFetch) {
      final generation = ++_requestGeneration;
      Future<void> refresh() async {
        try {
          Set<String>? ids;
          if (_activeIdsLoader != null) {
            ids = await _activeIdsLoader!();
          } else {
            final db = firestore ??
                (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);
            if (db == null) return;
            final doc = await db
                .collection('app_config')
                .doc('agents')
                .get(const GetOptions(source: Source.serverAndCache));
            final raw = doc.data()?['active_agent_ids'];
            if (doc.exists && raw is List) ids = raw.whereType<String>().toSet();
          }
          if (generation != _requestGeneration || ids == null || ids.isEmpty) {
            return;
          }
          final changed = !setEquals(_cachedActiveIds, ids);
          _cachedActiveIds = Set<String>.unmodifiable(ids);
          _lastAgentsFetch = DateTime.now();
          if (changed) availabilityRevision.value++;
        } catch (_) {
          // Pertahankan daftar terakhir bila pembacaan gagal.
        }
      }

      // Timeout membatasi tunggu layar, bukan membuang hasil Firestore yang
      // terlambat. Bila berhasil belakangan, notifier memperbarui layar.
      await refresh().timeout(const Duration(seconds: 3), onTimeout: () {});
    }

    return getActiveAgentsSync();
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
          e.message ?? Loc.tr('ui_5d804a44a9'),
        );
      }
      throw AgentAccessException(
          e.code, e.message ?? Loc.tr('errServiceUnavailable'));
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
