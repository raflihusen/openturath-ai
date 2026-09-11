import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

/// Model Hak Akses Per Modul Notebook / Kitab (Canonical Entitlement)
class ModuleEntitlement {
  final String plan;
  final DateTime? expiry;
  final String status; // 'active', 'expired', 'trial'
  final String? sourceTransactionId;
  final DateTime? updatedAt;

  const ModuleEntitlement({
    required this.plan,
    this.expiry,
    this.status = 'active',
    this.sourceTransactionId,
    this.updatedAt,
  });

  bool get isPremium =>
      plan != AppConstants.planTrial &&
      (plan == AppConstants.planTholib1m ||
          plan == AppConstants.planTholib6m ||
          plan == AppConstants.planBahits1y ||
          plan == 'all_ai_1m' ||
          plan == 'all_access' ||
          plan == 'full' ||
          plan.startsWith('all_ai') ||
          plan.startsWith('redeem') ||
          plan.startsWith('voucher') ||
          plan == 'custom');

  bool get isActive {
    if (status != 'active') return false;
    if (plan == 'lifetime' || plan == 'sultan_lifetime' || plan == 'all_access_lifetime') {
      return true;
    }
    if (expiry == null) {
      // Paket bertenggat tanpa expiry date dianggap data tidak lengkap
      return false;
    }
    return expiry!.isAfter(DateTime.now());
  }

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
    );
  }

  Map<String, dynamic> toMap() => {
        'plan': plan,
        'expiry': expiry != null ? Timestamp.fromDate(expiry!) : null,
        'status': status,
        'source_transaction_id': sourceTransactionId,
        'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
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
  bool get isTrial => plan == AppConstants.planTrial;
  bool get isGuest => email.isEmpty || uid.startsWith('guest_');
  bool get isPremium =>
      plan != AppConstants.planTrial &&
      (plan == AppConstants.planTholib1m ||
          plan == AppConstants.planTholib6m ||
          plan == AppConstants.planBahits1y ||
          plan == 'all_ai_1m' ||
          plan == 'all_access' ||
          plan == 'full' ||
          plan.startsWith('all_ai') ||
          plan.startsWith('redeem') ||
          plan.startsWith('voucher') ||
          plan == 'custom');

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
  ModuleEntitlement? getEntitlement(String agentId) {
    // 1. Cek langsung dengan ID agent
    if (entitlements.containsKey(agentId)) {
      return entitlements[agentId];
    }
    // 2. Normalisasi sub-agen (misal fiqh_tahawwulat_muhaqqiq -> fiqh_tahawwulat)
    for (final entry in entitlements.entries) {
      if (agentId == entry.key || agentId.startsWith('${entry.key}_')) {
        // Khusus fiqh_tahawwulat merupakan field independen, jangan tertukar dengan rumpun fiqh umum
        if (entry.key == 'fiqh' && agentId.startsWith('fiqh_tahawwulat')) {
          continue;
        }
        return entry.value;
      }
    }
    return null;
  }

  bool isAgentSubscriptionActive(String agentId) {
    // 1. Cek hak akses global All Access (Paket Semua AI)
    final allAccess = entitlements['all_access'] ?? entitlements['all_ai'];
    if (allAccess != null) {
      if (allAccess.status == 'revoked') return false;
      if (allAccess.isActive && allAccess.isPremium) {
        return true;
      }
    }
    // 2. Cek hak akses modul spesifik
    final ent = getEntitlement(agentId);
    if (ent != null) {
      if (ent.status == 'revoked') return false;
      return ent.isActive && ent.isPremium;
    }
    // 3. Jika peta entitlement terisi, batasi strictly pada modul yang terdaftar
    if (entitlements.isNotEmpty) {
      return false;
    }
    // 4. Fallback legacy HANYA jika plan akun adalah paket all_access eksplisit
    final isLegacyAllAccess = plan == 'all_access' ||
        plan == 'full' ||
        plan == AppConstants.planBahits1y ||
        plan.startsWith('all_ai') ||
        plan.startsWith('redeem_all') ||
        plan.startsWith('voucher_all');
    return isLegacyAllAccess && isSubscriptionActive;
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
        'entitlements': entitlements.map((k, v) => MapEntry(k, v.toMap())),
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
