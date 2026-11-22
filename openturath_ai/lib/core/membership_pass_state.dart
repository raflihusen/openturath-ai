import 'app_copy.dart';
import 'app_config.dart';
import 'entitlement_keys.dart';
import 'localization.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';

enum MembershipPassState {
  locked,
  trialPro,
  activePro,
  expiringSoon,
  paymentPending,
  paymentFailed,
  permanent,
}

class MembershipPassSummary {
  const MembershipPassSummary({
    required this.state,
    required this.badge,
    required this.accessLabel,
    required this.supportingLabel,
    required this.expiryLabel,
    required this.expiresAt,
    required this.ctaLabel,
    this.agentIds = const [],
  });

  final MembershipPassState state;
  final String badge;
  final String accessLabel;
  final String supportingLabel;
  final String expiryLabel;
  final DateTime? expiresAt;
  final String ctaLabel;
  final List<String> agentIds;

  bool get isOpen => switch (state) {
        MembershipPassState.locked ||
        MembershipPassState.paymentPending ||
        MembershipPassState.paymentFailed =>
          false,
        _ => true,
      };
}

MembershipPassSummary resolveMembershipPass(UserModel? user, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  // Owner-designated VIP status takes precedence over every paid package.
  if (AppConfig.isGuruEdition || user?.isVip == true) {
    return MembershipPassSummary(
      state: MembershipPassState.permanent,
      badge: 'VIP',
      accessLabel: AppCopy.allAssistantsAvailable,
      supportingLabel: AppCopy.permanentAccessLabel,
      expiryLabel: AppCopy.validUntil,
      expiresAt: null,
      ctaLabel: AppCopy.manageAccess,
    );
  }
  final entitlements =
      user?.entitlements ?? const <String, ModuleEntitlement>{};
  final values = entitlements.entries.toList();
  final active = values.where((entry) {
    final entitlement = entry.value;
    return (entitlement.status == 'active' || entitlement.status == 'trial') &&
        (entitlement.plan == 'permanent' ||
            (entitlement.expiry != null &&
                entitlement.expiry!.isAfter(reference)));
  }).toList();
  if (active.isEmpty && user?.subscriptionExpiry?.isAfter(reference) == true) {
    final expiry = user!.subscriptionExpiry;
    final expiring = expiry != null && expiry.difference(reference).inDays <= 3;
    return MembershipPassSummary(
      state: expiring
          ? MembershipPassState.expiringSoon
          : MembershipPassState.activePro,
      badge: user.isTrial ? 'TRIAL' : 'PRO',
      accessLabel: AppCopy.allAssistantsAvailable,
      supportingLabel:
          expiring ? AppCopy.accessExpiringSoon : AppCopy.readyToUse,
      expiryLabel: AppCopy.validUntil,
      expiresAt: expiry,
      ctaLabel: expiring ? AppCopy.renewPro : AppCopy.manageSubscription,
    );
  }
  if (active.isEmpty) {
    final hasPending = values.any((entry) =>
        entry.value.status == 'pending' ||
        entry.value.paymentStatus == 'pending');
    final hasFailed = values.any((entry) =>
        entry.value.status == 'failed' ||
        entry.value.paymentStatus == 'failed');
    if (hasPending) {
      return _base(
        MembershipPassState.paymentPending,
        AppCopy.preparingProAccess,
        AppCopy.paymentBeingVerified,
        AppCopy.viewPaymentStatus,
        badge: 'GRATIS',
      );
    }
    if (hasFailed) {
      return _base(
        MembershipPassState.paymentFailed,
        AppCopy.accessNotYetActive,
        AppCopy.paymentNotSuccessful,
        AppCopy.tryPaymentAgain,
        badge: 'GRATIS',
      );
    }
    return _base(
      MembershipPassState.locked,
      AppCopy.notSubscribed,
      AppCopy.chooseAssistantAndPlan,
      AppCopy.chooseProPlan,
      badge: 'GRATIS',
    );
  }

  bool isFullAllKey(String k) => k == 'all_access' || k == 'all_ai';
  bool isSpecialistsBundleKey(String k) =>
      k == 'all_specialists' || k == 'all_disciplines';
  bool isAnyAllKey(String k) => isFullAllKey(k) || isSpecialistsBundleKey(k);

  final paid = active.where((entry) =>
      entry.value.paymentStatus == 'paid' ||
      (entry.value.plan != 'trial' && entry.value.status != 'trial')).toList();

  final List<MapEntry<String, ModuleEntitlement>> selected;
  if (paid.isNotEmpty) {
    // Dahulukan paket berbayar di atas voucher coba.
    // Bila pengguna memegang Semua AI (all_specialists) DAN Fikih Tahawwulat,
    // pertahankan keduanya agar rincian akses dan tanggal kedaluwarsa terdekat akurat.
    final paidFullAll = paid.where((e) => isFullAllKey(e.key)).toList();
    final paidSpecialists =
        paid.where((e) => isSpecialistsBundleKey(e.key)).toList();
    if (paidFullAll.isNotEmpty) {
      selected = paidFullAll;
    } else if (paidSpecialists.isNotEmpty) {
      final paidTahawwulat = paid
          .where((e) =>
              e.key == 'fiqh_tahawwulat' ||
              entitlementKeys[e.key] == 'fiqh_tahawwulat')
          .toList();
      selected = [...paidSpecialists, ...paidTahawwulat];
    } else {
      selected = paid;
    }
  } else {
    final all = active.where((entry) => isAnyAllKey(entry.key)).toList();
    selected = all.isNotEmpty ? all : active;
  }

  final isTrial = paid.isEmpty && active.every(
      (entry) => entry.value.plan == 'trial' || entry.value.status == 'trial');
  final isPermanent =
      selected.every((entry) => entry.value.plan == 'permanent');
  final expiries = selected
      .map((entry) => entry.value.expiry)
      .whereType<DateTime>()
      .toList()
    ..sort();
  final expiry = expiries.isEmpty ? null : expiries.first;
  final hasSelectedFullAll = selected.any((entry) => isFullAllKey(entry.key));
  final hasSelectedSpecialists =
      selected.any((entry) => isSpecialistsBundleKey(entry.key));
  final hasSelectedTahawwulat = selected.any((entry) =>
      entry.key == 'fiqh_tahawwulat' ||
      entitlementKeys[entry.key] == 'fiqh_tahawwulat');
  final activeSpecificCount =
      active.where((entry) => !isAnyAllKey(entry.key)).length;
  final hasCollapsedAllEntry = active.any((entry) => isAnyAllKey(entry.key));
  final visibleActiveCount =
      activeSpecificCount + (hasCollapsedAllEntry ? 1 : 0);
  final String accessLabel;
  if (hasSelectedFullAll ||
      (hasSelectedSpecialists && hasSelectedTahawwulat)) {
    accessLabel = AppCopy.allAssistantsAvailable;
  } else if (hasSelectedSpecialists) {
    accessLabel = Loc.isArabic
        ? 'جميع الذكاءات · باستثناء فقه التحولات'
        : (Loc.language == 'en'
            ? 'All AIs · Excl. Fiqh Tahawwulat'
            : 'Semua AI · Kecuali Fikih Tahawwulat');
  } else if (visibleActiveCount == 1) {
    accessLabel = _singleModuleTitle(selected.first.key);
  } else {
    accessLabel = AppCopy.assistantsAvailableCount(visibleActiveCount);
  }
  if (isPermanent) {
    return MembershipPassSummary(
        state: MembershipPassState.permanent,
        badge: 'PRO',
        accessLabel: accessLabel,
        supportingLabel: AppCopy.permanentAccessLabel,
        expiryLabel: AppCopy.validUntil,
        expiresAt: null,
        ctaLabel: AppCopy.manageAccess,
        agentIds: selected.map((entry) => entry.key).toList());
  }
  if (isTrial) {
    final days = expiry == null ? 0 : expiry.difference(reference).inDays + 1;
    return MembershipPassSummary(
        state: MembershipPassState.trialPro,
        badge: 'TRIAL',
        accessLabel: accessLabel,
        supportingLabel: AppCopy.trialDaysLeft(days),
        expiryLabel: AppCopy.validUntil,
        expiresAt: expiry,
        ctaLabel: AppCopy.chooseProPlan,
        agentIds: selected.map((entry) => entry.key).toList());
  }
  final state = expiry != null && expiry.difference(reference).inDays <= 3
      ? MembershipPassState.expiringSoon
      : MembershipPassState.activePro;
  return MembershipPassSummary(
      state: state,
      badge: 'PRO',
      accessLabel: accessLabel,
      supportingLabel: state == MembershipPassState.expiringSoon
          ? AppCopy.accessExpiringSoon
          : AppCopy.readyToUse,
      expiryLabel: AppCopy.validUntil,
      expiresAt: expiry,
      ctaLabel: state == MembershipPassState.expiringSoon
          ? AppCopy.renewPro
          : AppCopy.manageSubscription,
      agentIds: selected.map((entry) => entry.key).toList());
}

MembershipPassSummary _base(
  MembershipPassState state,
  String access,
  String supporting,
  String cta, {
  String badge = 'GRATIS',
}) =>
    MembershipPassSummary(
      state: state,
      badge: badge,
      accessLabel: access,
      supportingLabel: supporting,
      expiryLabel: AppCopy.validUntil,
      expiresAt: null,
      ctaLabel: cta,
    );

String _singleModuleTitle(String key) {
  final canonical = entitlementKeys[key] ?? key;
  final base = switch (canonical) {
    'fiqh_tahawwulat' => Loc.text('Fikih Tahawwulat'),
    'fiqh_syafii' => Loc.text("Fikih Syafi'i"),
    'fiqh_hanafi' => Loc.text('Fikih Hanafi'),
    'fiqh_maliki' => Loc.text('Fikih Maliki'),
    'fiqh_hanbali' || 'fiqh_hambali' => Loc.text('Fikih Hanbali'),
    'fiqh_muqaran' => Loc.text('Perbandingan Mazhab'),
    'fiqh' || 'fatawa_masail' => Loc.text('Fatawa & Masail Fiqhiyyah'),
    'ushul_fiqh' || 'qawaid_fiqhiyyah' => Loc.text('Usul & Kaidah Fikih'),
    'nahwu' || 'nahwu_sharaf' || 'bahasa_arab' => Loc.text('Bahasa Arab'),
    'tafsir' => Loc.text("Tafsir Al-Qur'an"),
    'tajwid_qiraat' => Loc.text("Tajwid & Qira'at"),
    'hadits' => Loc.text('Hadis Nabawi'),
    'musthalah_hadits' => Loc.text('Ilmu Hadis'),
    'syarah_hadits' => Loc.text('Syarah Hadis'),
    'aqidah' => Loc.text('Akidah & Usuluddin'),
    'tarikh' => Loc.text('Sejarah & Sirah'),
    'thabaqat_rijal' => Loc.text('Rijal & Biografi Ulama'),
    'tasawwuf' => Loc.text('Tasawuf & Adzkar'),
    'habib_umar' => Loc.text('Habib Umar bin Hafizh'),
    'imam_ghazali' => Loc.text('Imam Al-Ghazali'),
    'bibliografi_faharis' => Loc.text('Bibliografi & Faharis'),
    _ => '',
  };
  if (base.isNotEmpty) {
    return Loc.isArabic ? base : (base.startsWith('AI ') ? base : 'AI $base');
  }
  for (final agent in AgentModel.defaultAgents) {
    if (agent.id == key || agent.id == canonical) {
      final t = Loc.text(agent.title);
      return Loc.isArabic ? t : (t.startsWith('AI ') ? t : 'AI $t');
    }
  }
  return Loc.isArabic
      ? 'مساعد الذكاء الاصطناعي'
      : (Loc.language == 'en' ? 'AI Assistant' : 'Asisten AI');
}

