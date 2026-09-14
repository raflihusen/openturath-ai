import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../core/entitlement_keys.dart';

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

  bool get isPremium => RegExp(
          r'^(tholib(?:_1m|_6m)?|bahits(?:_1y)?|premium|all_access|all_ai.*|single|sultan|pro|voucher(?:_.*)?|redeem(?:_.*)?|custom|full)$')
      .hasMatch(plan);

  bool get isActive =>
      status != 'revoked' &&
      status != 'expired' &&
      expiry != null &&
      expiry!.isAfter(DateTime.now());

  factory ModuleEntitlement.fromMap(Map<String, dynamic> map) {
    return ModuleEntitlement(
      plan: map['plan'] ?? AppConstants.planTrial,
      expiry: map['expiry'] != null
          ? (map['expiry'] is Timestamp
              ? (map['expiry'] as Timestamp).toDate()
              : DateTime.tryParse(map['expiry'].toString()))
          : null,
      status: map['status'] ?? 'active',
      sourceTransactionId: map['source_transaction_id'] ?? map['trx_id'],
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
      trialDurationDays: map['trial_duration_days'] as int?,
      paymentStatus: map['payment_status'] ?? 'none',
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

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.plan,
    required this.questionsUsed,
    this.subscriptionExpiry,
    this.entitlements = const {},
  });

  // ── Global Legacy Helpers ──
  bool get isTrial => plan == AppConstants.planTrial || plan == 'trial';
  bool get isGuest => email.isEmpty || uid.startsWith('guest_');
  bool get isPremium =>
      !isTrial &&
      plan != 'free' &&
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
          plan.startsWith('redeem') ||
          plan.startsWith('voucher') ||
          plan == 'custom' ||
          (subscriptionExpiry != null &&
              subscriptionExpiry!.isAfter(DateTime.now())));

  bool get isSubscriptionActive {
    if (isPremium && subscriptionExpiry != null) {
      return subscriptionExpiry!.isAfter(DateTime.now());
    }
    return false;
  }

  bool get hasAccess {
    if (isSubscriptionActive) return true;
    if (isTrial && questionsUsed < AppConstants.trialQuestionLimit) return true;
    return false;
  }

  int get questionsRemaining {
    if (isPremium) return 9999;
    return AppConstants.trialQuestionLimit - questionsUsed;
  }

  bool get isTrialExhausted =>
      isTrial && questionsUsed >= AppConstants.trialQuestionLimit;

  // ── Modular Entitlement Helpers ──
  ModuleEntitlement? getEntitlement(String agentId) =>
      entitlements[entitlementKeys[agentId] ?? agentId];

  bool isAgentSubscriptionActive(String agentId) {
    // 1. Explicit all_access entitlement
    final all = entitlements['all_access'] ?? entitlements['all_ai'];
    if (all != null && all.isActive && all.isPremium) return true;

    // 2. Specific module entitlement
    final specific = getEntitlement(agentId);
    if (specific != null && specific.isActive && specific.isPremium) {
      return true;
    }

    // If an explicit all_access was REVOKED, deny fallback
    if (all != null && all.status == 'revoked') {
      return false;
    }

    // 3. Account-level active subscription (tholib_1m, tholib_6m, bahits_1y, all_ai*, sultan, full, voucher, etc.)
    if (isSubscriptionActive) {
      if (plan == 'single') {
        return specific != null && specific.isActive && specific.isPremium;
      }
      return true;
    }

    // 4. Fallback legacy plan check
    const legacyPlans = [
      'all_access',
      'all_ai_1m',
      'all_ai_6m',
      'all_ai_1y',
      'all_ai',
      'full',
      'sultan',
      'tholib_1m',
      'tholib_6m',
      'bahits_1y',
      'tholib',
      'bahits',
      'pro',
      'premium',
      'custom',
    ];
    final isLegacyMatching = legacyPlans.contains(plan) ||
        plan.startsWith('all_ai') ||
        plan.startsWith('redeem') ||
        plan.startsWith('voucher');
    return isLegacyMatching && isSubscriptionActive;
  }

  bool hasAccessToAgent(String agentId) {
    // Akses notebook memerlukan hak akses langganan atau voucher aktif (F24: hapus jalur trial tanpa batas server)
    return isAgentSubscriptionActive(agentId);
  }

  int questionsRemainingForAgent(String agentId) {
    if (isAgentSubscriptionActive(agentId)) return 9999;
    return AppConstants.trialQuestionLimit - questionsUsed;
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    // Parse entitlements map
    final Map<String, ModuleEntitlement> parsedEntitlements = {};
    if (data['entitlements'] != null && data['entitlements'] is Map) {
      final rawMap = data['entitlements'] as Map<String, dynamic>;
      rawMap.forEach((key, val) {
        if (val is Map<String, dynamic>) {
          parsedEntitlements[key] = ModuleEntitlement.fromMap(val);
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

    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      plan: data['plan'] ?? AppConstants.planTrial,
      questionsUsed: data['questions_used'] ?? 0,
      subscriptionExpiry: expiry,
      entitlements: parsedEntitlements,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() => {
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
    );
  }
}
