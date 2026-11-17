import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../core/notebook_navigation.dart';
import '../core/canonical_notebook_catalog.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import 'callable_gateway.dart';
import 'auth_service.dart';
import 'persistent_google_session.dart';

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
  static int _lastAppliedGeneration = 0;

  /// Memberi tahu layar ketika daftar yang berhasil dibaca berubah.
  static final ValueNotifier<int> availabilityRevision = ValueNotifier<int>(0);

  @visibleForTesting
  static void resetCacheForTest() {
    _lastAppliedGeneration = ++_requestGeneration;
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
            if (doc.exists && raw is List) {
              ids = raw.whereType<String>().toSet();
            }
          }
          if (generation < _lastAppliedGeneration ||
              ids == null ||
              ids.isEmpty) {
            return;
          }
          _lastAppliedGeneration = generation;
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
  Future<String?> getAgentUrl(String agentId, [UserModel? user]) async {
    final effectiveUser = user ??
        (Firebase.apps.isNotEmpty ? AuthService().cachedCurrentUser : null);
    final email = (effectiveUser?.email ??
            PersistentGoogleSession.instance.verifiedOwner ??
            '')
        .trim()
        .toLowerCase();
    final isVip = (effectiveUser?.isVip == true) || UserModel.isVipEmail(email);

    // Rule 5 AGENTS.md (Hukum Sakral VIP): Akun VIP sejati berhak atas naskah master secara permanen
    // dan langsung diarahkan ke naskah resmi tanpa delay atau terhalang unauthenticated/unavailable.
    // Begitu juga akun dengan hak akses langganan atau voucher aktif, langsung diarahkan ke naskah resmi.
    if (isVip || (effectiveUser != null && effectiveUser.hasAccessToAgent(agentId))) {
      final canonical = CanonicalNotebookCatalog.getUrl(agentId);
      if (canonical != null && canonical.isNotEmpty) {
        return canonical;
      }
    }

    // 1. Coba panggil endpoint mandiri VPS OpenTurath
    try {
      final res = await http.post(
        Uri.parse('https://maktabah.openturath.id/api/getAgentUrl'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'OpenTurath-App/1.0',
        },
        body: jsonEncode({
          'data': {'agentId': agentId}
        }),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map) {
          final url = body['result']?['url'] ?? body['url'];
          if (url is String && url.isNotEmpty) {
            final uri = Uri.tryParse(url);
            if (uri != null &&
                NotebookNavigation.notebook(uri) &&
                _notebookPath.hasMatch(uri.path)) {
              return uri
                  .replace(host: NotebookNavigation.canonicalHost)
                  .toString();
            }
          }
        }
      }
    } catch (_) {
      // Abaikan kegagalan jaringan VPS dan lanjutkan ke fallback kanonik
    }

    // 2. Fallback naskah kanonik resmi Pro Master HANYA jika user terverifikasi berhak
    if (isVip || (effectiveUser != null && effectiveUser.hasAccessToAgent(agentId))) {
      final canonical = CanonicalNotebookCatalog.getUrl(agentId);
      if (canonical != null && canonical.isNotEmpty) {
        return canonical;
      }
    }

    throw const AgentAccessException(
        'permission-denied',
        'Akses ke modul AI ini memerlukan paket langganan atau voucher aktif.',
        reason: 'entitlement_required');
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
  const AgentAccessException(this.code, this.message,
      {this.reason, this.requestId});
  final String code;
  final String message;
  final String? reason;
  final String? requestId;

  @override
  String toString() => 'AgentAccessException($code): $message';
}
