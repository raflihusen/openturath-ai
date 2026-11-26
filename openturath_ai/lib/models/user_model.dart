import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../core/entitlement_keys.dart';
import '../core/app_config.dart';

/// Model Hak Akses Per Modul Notebook / Kitab (Canonical Entitlement)
class ModuleEntitlement {
  final String plan;
  final DateTime? expiry;
  final String status; // 'active', 'expired', 'trial'
  final String? sourceTransactionId;
  final DateTime? updatedAt;
  final DateTime? startedAt;
  final int? trialDurationDays;
  final String paymentStatus;

  const ModuleEntitlement({
    required this.plan,
    this.expiry,
    this.status = 'active',
    this.sourceTransactionId,
    this.updatedAt,
    this.startedAt,
    this.trialDurationDays,
    this.paymentStatus = 'none',
  });

  bool get isPremium {
    final normalized = plan.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'free' || normalized == 'none') {
      return false;
    }
    return RegExp(
            r'^(trial|tholib(?:_1m|_6m)?|bahits(?:_1y)?|premium|permanent|paid|all_access|all_ai.*|all_specialists(?:_.*)?|all_disciplines(?:_.*)?|single|sultan|pro|voucher(?:_.*)?|redeem(?:_.*)?|custom|full|[a-z0-9_]+_(?:1m|6m|1y))$')
        .hasMatch(normalized);
  }

  bool get isActive {
    final st = status.trim().toLowerCase();
    if (st != 'active' && st != 'trial') return false;
    if (plan.trim().toLowerCase() == 'permanent') return true;
    return expiry != null && expiry!.isAfter(DateTime.now());
  }

  factory ModuleEntitlement.fromMap(Map<String, dynamic> map) {
    final rawDays = map['trial_duration_days'];
    final parsedDays = rawDays is num
        ? rawDays.toInt()
        : int.tryParse(rawDays?.toString() ?? '');
    return ModuleEntitlement(
      plan: map['plan']?.toString() ?? AppConstants.planTrial,
      expiry: map['expiry'] != null
          ? (map['expiry'] is Timestamp
              ? (map['expiry'] as Timestamp).toDate()
              : DateTime.tryParse(map['expiry'].toString()))
          : null,
      status: map['status']?.toString() ?? 'active',
      sourceTransactionId: (map['source_transaction_id'] ?? map['trx_id'])?.toString(),
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] is Timestamp
              ? (map['updated_at'] as Timestamp).toDate()
              : DateTime.tryParse(map['updated_at'].toString()))
          : null,
      startedAt: map['started_at'] != null
          ? (map['started_at'] is Timestamp
              ? (map['started_at'] as Timestamp).toDate()
              : DateTime.tryParse(map['started_at'].toString()))
          : null,
      trialDurationDays: parsedDays,
      paymentStatus: map['payment_status']?.toString() ?? 'none',
    );
  }

  Map<String, dynamic> toMap() => {
        'plan': plan,
        'expiry': expiry != null ? Timestamp.fromDate(expiry!) : null,
        'status': status,
        'source_transaction_id': sourceTransactionId,
        'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'started_at': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'trial_duration_days': trialDurationDays,
        'payment_status': paymentStatus,
      };

  Map<String, dynamic> toJsonMap() => {
        'plan': plan,
        'expiry': expiry?.toIso8601String(),
        'status': status,
        'source_transaction_id': sourceTransactionId,
        'updated_at': updatedAt?.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'trial_duration_days': trialDurationDays,
        'payment_status': paymentStatus,
      };
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String plan; // Legacy global plan fallback
  final int questionsUsed;
  final DateTime? subscriptionExpiry; // Legacy global expiry fallback
  final Map<String, ModuleEntitlement> entitlements;
  final bool _explicitVip;

  bool get isVip => _explicitVip || isVipEmail(email);

  static bool isVipEmail(String? email) {
    if (email == null) return false;
    return _canonicalVipEmails.contains(email.trim().toLowerCase());
  }

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.plan,
    required this.questionsUsed,
    this.subscriptionExpiry,
    this.entitlements = const {},
    bool isVip = false,
  }) : _explicitVip = isVip;

  // ── Global Legacy Helpers ──
  bool get isTrial =>
      !isVip && (plan == AppConstants.planTrial || plan == 'trial');
  bool get isGuest => email.isEmpty || uid.startsWith('guest_');
  bool get isPremium =>
      isVip ||
      (plan != 'free' &&
          (plan == AppConstants.planTholib1m ||
              plan == AppConstants.planTholib6m ||
              plan == AppConstants.planBahits1y ||
              plan == 'tholib' ||
              plan == 'bahits' ||
              plan == 'all_ai_1m' ||
              plan == 'all_ai_6m' ||
              plan == 'all_ai_1y' ||
              plan == 'all_access' ||
              plan == 'all_ai' ||
              plan == 'full' ||
              plan == 'sultan' ||
              plan == 'pro' ||
              plan == 'premium' ||
              plan.startsWith('all_ai') ||
              plan.startsWith('all_specialists') ||
              plan.startsWith('all_disciplines') ||
              plan.startsWith('redeem') ||
              plan.startsWith('voucher') ||
              plan == 'custom' ||
              (subscriptionExpiry != null &&
                  subscriptionExpiry!.isAfter(DateTime.now()))));

  /// Voucher trial dan paket berbayar memakai sumber masa berlaku yang sama.
  /// Jangan pernah menjadikan nama paket sebagai alasan menolak masa berlaku
  /// yang masih aktif dari server.
  bool get isSubscriptionActive =>
      AppConfig.isGuruEdition ||
      isVip ||
      (subscriptionExpiry != null &&
          subscriptionExpiry!.isAfter(DateTime.now()));

  /// Trial is an entitlement with an expiry supplied by the server voucher.
  /// A local question counter must never grant or revoke access.
  bool get hasAccess =>
      AppConfig.isGuruEdition ||
      isSubscriptionActive ||
      entitlements.values
          .any((entitlement) => entitlement.isActive && entitlement.isPremium);

  /// Retained for legacy presentation only. Questions are no longer a quota.
  int get questionsRemaining => hasAccess ? 9999 : 0;

  bool get isTrialExhausted => false;

  // ── Modular Entitlement Helpers ──

  bool isAgentSubscriptionActive(String agentId) {
    if (AppConfig.isGuruEdition) return true;
    // Owner-approved permanent VIP outranks expired or revoked paid packages.
    if (isVip) return true;
    final rawLower = agentId.trim().toLowerCase();
    if (rawLower.isEmpty) return false;
    final mappedKey =
        entitlementKeys[agentId] ?? entitlementKeys[rawLower] ?? rawLower;
    final isTahawwulat = mappedKey == 'fiqh_tahawwulat' ||
        mappedKey.contains('tahawwulat') ||
        rawLower.contains('tahawwulat');

    // 1. Specific module entitlement check FIRST (cek key kanonik maupun key mentah agentId)
    final candidates = <ModuleEntitlement>[
      if (entitlements[mappedKey] != null) entitlements[mappedKey]!,
      if (agentId != mappedKey && entitlements[agentId] != null)
        entitlements[agentId]!,
      if (rawLower != mappedKey &&
          rawLower != agentId &&
          entitlements[rawLower] != null)
        entitlements[rawLower]!,
    ];
    if (candidates.any((e) => e.isActive && e.isPremium)) {
      return true;
    }

    // If a specific module entitlement was explicitly revoked, deny access
    // BEFORE considering global bundle entitlements.
    if (candidates.isNotEmpty &&
        candidates.every((e) => e.status.trim().toLowerCase() == 'revoked')) {
      return false;
    }

    // 2. Explicit all_access entitlement
    final all = entitlements['all_access'] ?? entitlements['all_ai'];
    if (all != null && all.isActive && all.isPremium) {
      return true;
    }

    // 2b. Explicit all_specialists / all_disciplines entitlement (Semua AI kecuali Fikih Tahawwulat)
    final allSpecialists =
        entitlements['all_specialists'] ?? entitlements['all_disciplines'];
    if (!isTahawwulat &&
        mappedKey != 'all_access' &&
        rawLower != 'all_ai' &&
        allSpecialists != null &&
        allSpecialists.isActive &&
        allSpecialists.isPremium) {
      return true;
    }

    // If an explicit all_access was REVOKED and no active specific entitlement, deny access
    if (all != null && all.status.trim().toLowerCase() == 'revoked') {
      return false;
    }

    // 3-5. Legacy global plan/subscriptionExpiry fallbacks ONLY apply when
    // modular entitlements are absent. When modular entitlements exist, expired
    // global/bundle plans must never resurrect access for unpurchased modules.
    if (entitlements.isEmpty && isSubscriptionActive) {
      const globalAllPlans = [
        'all_access',
        'all_ai_1m',
        'all_ai_6m',
        'all_ai_1y',
        'all_ai',
        'full',
        'sultan',
      ];
      final cleanPlan = plan.trim().toLowerCase();
      final isGlobalPlan =
          globalAllPlans.contains(cleanPlan) || cleanPlan.startsWith('all_ai');
      final isAllSpecialistsPlan = !isTahawwulat &&
          mappedKey != 'all_access' &&
          rawLower != 'all_ai' &&
          (cleanPlan == 'all_specialists' ||
              cleanPlan.startsWith('all_specialists_') ||
              cleanPlan == 'all_disciplines' ||
              cleanPlan.startsWith('all_disciplines_'));
      if (isGlobalPlan || isAllSpecialistsPlan) {
        return true;
      }

      // 4. Module-specific plan matching (e.g. 'fiqh_syafii_1m', 'fiqh_tahawwulat_1m')
      final cleanKey = mappedKey.toLowerCase();
      if (cleanPlan == cleanKey || cleanPlan.startsWith('${cleanKey}_')) {
        return true;
      }

      // 5. Legacy all-access plan backward-compatibility
      const legacyAllAccessPlans = [
        AppConstants.planTholib1m,
        AppConstants.planTholib6m,
        AppConstants.planBahits1y,
      ];
      if (legacyAllAccessPlans.contains(cleanPlan) ||
          cleanPlan.startsWith('redeem') ||
          cleanPlan.startsWith('voucher')) {
        return true;
      }
    }

    return false;
  }

  bool hasAccessToAgent(String agentId) {
    // Akses notebook memerlukan hak akses langganan atau voucher aktif spesifik modul
    return isAgentSubscriptionActive(agentId);
  }

  int questionsRemainingForAgent(String agentId) {
    if (isAgentSubscriptionActive(agentId)) return 9999;
    return 0;
  }

  static const _canonicalVipEmails = {
    // Owner & Core Team
    'ramah@ptct.net',
    'raflimaulan@gmail.com',
    'mas.raflihusen@gmail.com',
    'udinvoldigoad05@gmail.com',
    'macbookairm1ku@gmail.com',
    'hus180402@gmail.com',
    // Mitra Kehormatan (Rule 5 AGENTS.md)
    'prilatief@gmail.com',
    // Masyayikh & Asatidz Turats
    'alkhateeb23@gmail.com',
    'omarasb1441@gmail.com',
    'mohammedhalahdal@gmail.com',
    'alshykhkmalbahrmz@gmail.com',
    'ali.bafdhl36@gmail.com',
    'alhamodi65@gmail.com',
    'abualgilani2024@gmail.com',
    'abo.omar5539@gmail.com',
    'ahobh4241@gmail.com',
    'omar739037802@gmail.com',
    'yasser110271@gmail.com',
  };

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    // Parse entitlements map safely even if nested maps are Map<dynamic, dynamic>
    final Map<String, ModuleEntitlement> parsedEntitlements = {};
    final rawEntitlements = data['entitlements'];
    if (rawEntitlements is Map) {
      rawEntitlements.forEach((key, val) {
        if (val is Map) {
          parsedEntitlements[key.toString()] =
              ModuleEntitlement.fromMap(Map<String, dynamic>.from(val));
        }
      });
    }

    DateTime? expiry;
    if (data['subscription_expiry'] != null) {
      final exp = data['subscription_expiry'];
      if (exp is Timestamp) {
        expiry = exp.toDate();
      } else if (exp is String) {
        expiry = DateTime.tryParse(exp);
      } else if (exp is int) {
        expiry = DateTime.fromMillisecondsSinceEpoch(exp);
      }
    }

    final rawEmail = (data['email'] ?? '').toString().trim().toLowerCase();
    final rawQuestions = data['questions_used'];
    final parsedQuestions = rawQuestions is num
        ? rawQuestions.toInt()
        : int.tryParse(rawQuestions?.toString() ?? '') ?? 0;

    return UserModel(
      uid: uid,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      photoUrl: data['photo_url']?.toString() ?? '',
      plan: data['plan']?.toString() ?? AppConstants.planTrial,
      questionsUsed: parsedQuestions,
      subscriptionExpiry: expiry,
      entitlements: parsedEntitlements,
      isVip: data['is_vip'] == true ||
          isVipEmail(rawEmail) ||
          ['vip', 'admin', 'guru', 'special']
              .contains((data['role'] ?? '').toString().toLowerCase()),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() => {
        'is_vip': isVip,
        'name': name,
        'email': email,
        'photo_url': photoUrl,
        'plan': plan,
        'questions_used': questionsUsed,
        'subscription_expiry': subscriptionExpiry != null
            ? Timestamp.fromDate(subscriptionExpiry!)
            : null,
        'entitlements': entitlements.map((k, v) => MapEntry(k, v.toMap())),
      };

  Map<String, dynamic> toJsonMap() => {
        'is_vip': isVip,
        'name': name,
        'email': email,
        'photo_url': photoUrl,
        'plan': plan,
        'questions_used': questionsUsed,
        'subscription_expiry': subscriptionExpiry?.toIso8601String(),
        'entitlements': entitlements.map((k, v) => MapEntry(k, v.toJsonMap())),
      };

  UserModel copyWith({
    int? questionsUsed,
    String? plan,
    DateTime? subscriptionExpiry,
    Map<String, ModuleEntitlement>? entitlements,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      plan: plan ?? this.plan,
      questionsUsed: questionsUsed ?? this.questionsUsed,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      entitlements: entitlements ?? this.entitlements,
      isVip: isVip,
    );
  }
}
