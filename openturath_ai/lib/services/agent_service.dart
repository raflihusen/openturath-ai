import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_config.dart';
import '../core/constants.dart';
import '../core/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../core/notebook_navigation.dart';
import '../core/canonical_notebook_catalog.dart';
import '../core/entitlement_keys.dart';
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
        _hasCustomFunctions = functions != null,
        _activeIdsLoader = activeIdsLoader;

  final CallableGateway _functions;
  final bool _hasCustomFunctions;
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

  @visibleForTesting
  static void seedActiveIdsForTest(Set<String> ids) {
    _lastAppliedGeneration = ++_requestGeneration;
    _cachedActiveIds = Set<String>.unmodifiable(ids);
    _lastAgentsFetch = null;
  }

  /// Daftar agen aktif bawaan saat offline/cold-start sebelum /api/v1/config/agents termuat.
  static const defaultLaunchActiveIds = <String>{
    'fiqh_tahawwulat',
    'fiqh_tahawwulat_muhaqqiq',
    'fiqh_tahawwulat_bayan',
    'fiqh_tahawwulat_mukhtabir',
    'fiqh_tahawwulat_habib',
    'fiqh_tahawwulat_khatib',
    'fiqh_syafii',
    'fiqh_syafii_muhaqqiq',
    'fiqh_hanafi',
    'fiqh_hanafi_muhaqqiq',
    'fiqh_maliki',
    'fiqh_maliki_muhaqqiq',
    'fiqh_hanbali',
    'fiqh_hanbali_muhaqqiq',
    'fiqh_muqaran',
    'fiqh_muqaran_muhaqqiq',
    'hadits',
    'hadits_muhaqqiq',
    'tafsir',
    'tafsir_muhaqqiq',
    'ushul_fiqh',
    'ushul_muhaqqiq',
    'nahwu_sharaf',
    'nahwu_sharaf_muerib',
    'nahwu_sharaf_tashrif',
    'aqidah',
    'tarikh',
    'tasawwuf',
    'tajwid_qiraat',
    'musthalah_hadits',
    'syarah_hadits',
    'thabaqat_rijal',
    'bibliografi_faharis',
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
            // 1. Prioritaskan OTA Config dari Backend VPS Resmi
            try {
              final vpsConfigUrl =
                  Uri.parse('https://maktabah.openturath.id/api/v1/config/agents');
              final resp = await http.get(vpsConfigUrl, headers: {
                'Accept': 'application/json'
              }).timeout(const Duration(seconds: 4));
              if (resp.statusCode == 200) {
                final cData = jsonDecode(resp.body);
                if (cData is Map && cData['active_agent_ids'] is List) {
                  ids = (cData['active_agent_ids'] as List)
                      .whereType<String>()
                      .toSet();
                }
              }
            } catch (_) {}

            // 2. Fallback ke Firestore app_config/agents bila VPS offline
            if (ids == null || ids.isEmpty) {
              final db = firestore ??
                  (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);
              if (db != null) {
                final doc = await db
                    .collection('app_config')
                    .doc('agents')
                    .get(const GetOptions(source: Source.serverAndCache));
                final raw = doc.data()?['active_agent_ids'];
                if (doc.exists && raw is List) {
                  ids = raw.whereType<String>().toSet();
                }
              }
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

  static const _assignedUrlCachePrefix = 'ot_assigned_notebook_v1_';
  static final Map<String, String> _assignedUrlMemoryCache = {};

  static String _assignedCacheKey(String email, String agentId) =>
      '$_assignedUrlCachePrefix${email.trim().toLowerCase()}|$agentId';

  static Future<String?> _readAssignedUrlCache(
      String email, String agentId) async {
    if (email.isEmpty) return null;
    final key = _assignedCacheKey(email, agentId);
    final mem = _assignedUrlMemoryCache[key];
    if (mem != null && mem.isNotEmpty) return mem;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(key);
      if (stored != null && stored.isNotEmpty) {
        _assignedUrlMemoryCache[key] = stored;
        return stored;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> _saveAssignedUrlCache(
      String email, String agentId, String url) async {
    if (email.isEmpty || url.isEmpty) return;
    final key = _assignedCacheKey(email, agentId);
    _assignedUrlMemoryCache[key] = url;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, url);
    } catch (_) {}
  }

  static Future<void> clearAssignedUrlCache([String? email]) async {
    if (email != null && email.trim().isNotEmpty) {
      final prefix = '$_assignedUrlCachePrefix${email.trim().toLowerCase()}|';
      _assignedUrlMemoryCache.removeWhere((k, _) => k.startsWith(prefix));
      try {
        final prefs = await SharedPreferences.getInstance();
        for (final k in prefs.getKeys().toList()) {
          if (k.startsWith(prefix)) await prefs.remove(k);
        }
      } catch (_) {}
      return;
    }
    _assignedUrlMemoryCache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys().toList()) {
        if (k.startsWith(_assignedUrlCachePrefix)) await prefs.remove(k);
      }
    } catch (_) {}
  }

  Future<String?> _fetchVpsAssignedUrl(
    String agentId,
    String email, {
    required bool forceRefresh,
  }) async {
    String? idToken;
    try {
      if (Firebase.apps.isNotEmpty) {
        idToken = await FirebaseAuth.instance.currentUser
            ?.getIdToken()
            .timeout(const Duration(seconds: 2), onTimeout: () => null);
      }
    } catch (_) {}

    final res = await http
        .post(
          Uri.parse('https://maktabah.openturath.id/api/getAgentUrl'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'OpenTurath-App/1.0',
            if (idToken != null && idToken.isNotEmpty)
              'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'data': {
              'agentId': agentId,
              'email': email,
              'forceRefresh': forceRefresh,
            }
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (res.statusCode == 202 ||
        res.statusCode == 200 ||
        res.statusCode == 412) {
      final body = jsonDecode(res.body);
      if (body is Map) {
        final resultObj =
            body['result'] is Map ? body['result'] as Map : body;
        final status = (resultObj['status'] ?? body['status'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        final reason = (resultObj['reason'] ?? body['reason'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        // Jika akses sedang disiapkan di antrean worker (provisioning),
        // JANGAN fallback ke Master ID agar user ke-2.001 tidak terkena Minta Akses.
        if (res.statusCode == 202 ||
            status == 'provisioning' ||
            reason == 'access_provisioning') {
          throw const AgentAccessException(
            'failed-precondition',
            'Akses AI sedang disiapkan oleh server. Mohon tunggu beberapa detik lalu coba lagi.',
            reason: 'access_provisioning',
          );
        }

        final rawUrl = resultObj['url'] ?? body['url'];
        if (res.statusCode == 200 && rawUrl is String && rawUrl.isNotEmpty) {
          final uri = Uri.tryParse(rawUrl.trim());
          if (uri != null &&
              !rawUrl.contains('%') &&
              NotebookNavigation.notebook(uri) &&
              _notebookPath.hasMatch(uri.path) &&
              !uri.hasQuery &&
              !uri.hasFragment) {
            final normalized = uri
                .replace(host: NotebookNavigation.canonicalHost)
                .toString();
            await _saveAssignedUrlCache(email, agentId, normalized);
            return normalized;
          }
        }
      }
    }
    return null;
  }

  // ── Ambil URL agent dari Server / Ledger secara aman (Server-Side Entitlement & Clone Routing) ────
  Future<String?> getAgentUrl(
    String agentId, [
    UserModel? user,
    bool forceRefresh = false,
    void Function(String freshUrl)? onBackgroundRefresh,
  ]) async {
    if (virtualBundleAgentIds.contains(agentId.trim().toLowerCase())) {
      throw const AgentAccessException(
          'invalid-argument',
          'Paket bundel tidak dapat dibuka sebagai satu ruang AI tunggal. Silakan pilih bidang keilmuan spesifik.');
    }
    final effectiveUser = user ??
        (Firebase.apps.isNotEmpty ? AuthService().cachedCurrentUser : null);
    final email = (effectiveUser?.email ??
            PersistentGoogleSession.instance.verifiedOwner ??
            '')
        .trim()
        .toLowerCase();
    final isVip = (effectiveUser?.isVip == true) || UserModel.isVipEmail(email);

    if (!_hasCustomFunctions) {
      var hasAccess = AppConfig.isGuruEdition ||
          isVip ||
          (effectiveUser != null && effectiveUser.hasAccessToAgent(agentId));

      // Jika cache lokal belum menunjukkan akses, sinkronkan dulu status otoritatif dari VPS
      // agar pengguna yang baru saja membayar tidak keliru terkena paywall.
      if (!hasAccess && email.isNotEmpty) {
        try {
          await AuthService.syncUserStatusWithVps(email)
              .timeout(const Duration(seconds: 4));
          final refreshed = AuthService().cachedCurrentUser;
          hasAccess = (refreshed?.isVip == true) ||
              (refreshed != null && refreshed.hasAccessToAgent(agentId));
        } catch (_) {}
      }

      if (!hasAccess) {
        throw const AgentAccessException(
            'permission-denied',
            'Akses ke modul AI ini memerlukan paket langganan atau voucher aktif.',
            reason: 'entitlement_required');
      }

      if (email.isNotEmpty) {
        // Stale-while-revalidate: bila URL kloning untuk (email, agentId) sudah ada
        // di sticky cache dan tidak sedang forceRefresh, langsung kembalikan dalam 0 ms
        // agar WebView segera memuat, sambil menyegarkan penugasan VPS di latar belakang.
        if (!forceRefresh) {
          final sticky = await _readAssignedUrlCache(email, agentId);
          if (sticky != null && sticky.isNotEmpty) {
            Future<void>(() async {
              try {
                final fresh = await _fetchVpsAssignedUrl(agentId, email,
                    forceRefresh: false);
                if (fresh != null && fresh.isNotEmpty && fresh != sticky) {
                  onBackgroundRefresh?.call(fresh);
                }
              } catch (_) {}
            });
            return sticky;
          }
        }

        // Cold cache atau forceRefresh: tanyakan penugasan notebook/kloning ke VPS.
        try {
          final fetched = await _fetchVpsAssignedUrl(agentId, email,
              forceRefresh: forceRefresh);
          if (fetched != null && fetched.isNotEmpty) {
            return fetched;
          }
        } on AgentAccessException {
          rethrow;
        } catch (_) {
          // Lanjut ke fallback katalog master kanonik
        }
      }

      final canonical = CanonicalNotebookCatalog.getUrl(agentId);
      if (canonical != null && canonical.isNotEmpty) {
        final uri = Uri.tryParse(canonical.trim());
        if (uri != null && NotebookNavigation.notebook(uri)) {
          return uri.replace(host: NotebookNavigation.canonicalHost).toString();
        }
        return canonical;
      }

      throw const AgentAccessException(
          'empty-url', 'URL AI belum tersedia untuk bidang ini.');
    }

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
      return uri.replace(host: NotebookNavigation.canonicalHost).toString();
    } on FirebaseFunctionsException catch (e) {
      if (isVip ||
          (effectiveUser != null &&
              (effectiveUser.isVip ||
                  effectiveUser.hasAccessToAgent(agentId)))) {
        final fallback = CanonicalNotebookCatalog.getUrl(agentId);
        if (fallback != null) return fallback;
      }
      final details = e.details is Map ? e.details as Map : const {};
      final reason = details['reason'];
      final requestId = details['request_id'];
      throw AgentAccessException(
        e.code,
        e.message ??
            Loc.tr(e.code == 'permission-denied'
                ? 'ui_5d804a44a9'
                : 'errServiceUnavailable'),
        reason: reason is String &&
                RegExp(r'^[a-z][a-z0-9_]{0,59}$').hasMatch(reason)
            ? reason
            : null,
        requestId: requestId is String &&
                RegExp(r'^[a-f0-9-]{36}$').hasMatch(requestId)
            ? requestId
            : null,
      );
    } catch (e) {
      if (e is AgentAccessException) rethrow;
      if (isVip ||
          (effectiveUser != null &&
              (effectiveUser.isVip ||
                  effectiveUser.hasAccessToAgent(agentId)))) {
        final fallback = CanonicalNotebookCatalog.getUrl(agentId);
        if (fallback != null) return fallback;
      }
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
  const AgentAccessException(this.code, this.message,
      {this.reason, this.requestId});
  final String code;
  final String message;
  final String? reason;
  final String? requestId;

  @override
  String toString() => 'AgentAccessException($code): $message';
}
