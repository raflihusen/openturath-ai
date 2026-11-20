import 'app_copy.dart';
import 'app_config.dart';
import 'localization.dart';
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

  final paid = active.where((entry) =>
      entry.value.paymentStatus == 'paid' ||
      (entry.value.plan != 'trial' && entry.value.status != 'trial')).toList();

  final List<MapEntry<String, ModuleEntitlement>> selected;
  if (paid.isNotEmpty) {
    // Dahulukan paket berbayar di atas voucher coba
    final paidAll = paid.where((entry) =>
        entry.key == 'all_access' ||
        entry.key == 'all_ai' ||
        entry.key == 'all_specialists').toList();
    selected = paidAll.isNotEmpty ? paidAll : paid;
  } else {
    final all = active
        .where((entry) => entry.key == 'all_access' || entry.key == 'all_ai')
        .toList();
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
  final hasSelectedAll = selected.any((entry) =>
      entry.key == 'all_access' ||
      entry.key == 'all_ai' ||
      entry.key == 'all_specialists');
  final activeSpecificCount = active
      .where((entry) => entry.key != 'all_access' && entry.key != 'all_ai')
      .length;
  final hasCollapsedAllEntry = active
      .any((entry) => entry.key == 'all_access' || entry.key == 'all_ai');
  final visibleActiveCount =
      activeSpecificCount + (hasCollapsedAllEntry ? 1 : 0);
  final accessLabel = hasSelectedAll
      ? AppCopy.allAssistantsAvailable
      : (visibleActiveCount == 1
          ? _singleModuleTitle(selected.first.key)
          : AppCopy.assistantsAvailableCount(visibleActiveCount));
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
  final base = switch (key) {
    'fiqh_tahawwulat' => Loc.text('Fikih Tahawwulat'),
    'fiqh_syafii' => Loc.text("Fikih Syafi'i"),
    'fiqh_hanafi' => Loc.text('Fikih Hanafi'),
    'fiqh_maliki' => Loc.text('Fikih Maliki'),
    'fiqh_hanbali' || 'fiqh_hambali' => Loc.text('Fikih Hanbali'),
    'fiqh_muqaran' => Loc.text('Perbandingan Mazhab'),
    'fiqh' || 'fatawa_masail' => Loc.text('Fatawa & Masail Fiqhiyyah'),
    'ushul_fiqh' || 'qawaid_fiqhiyyah' => Loc.text('Ushul & Kaidah Fikih'),
    'nahwu' || 'nahwu_sharaf' || 'bahasa_arab' => Loc.text('Bahasa Arab'),
    'tafsir' => Loc.text("Tafsir Al-Qur'an"),
    'tajwid_qiraat' => Loc.text("Tajwid & Qira'at"),
    'hadits' => Loc.text('Hadis Nabawi'),
    'musthalah_hadits' => Loc.text('Ilmu Hadits'),
    'syarah_hadits' => Loc.text('Syarah Hadits'),
    'aqidah' => Loc.text('Akidah & Ushuluddin'),
    'tarikh' => Loc.text('Sejarah & Sirah'),
    'thabaqat_rijal' => Loc.text('Rijal & Biografi Ulama'),
    'tasawwuf' => Loc.text('Tasawuf & Adzkar'),
    'habib_umar' => Loc.text('Habib Umar bin Hafizh'),
    'imam_ghazali' => Loc.text('Imam Al-Ghazali'),
    'bibliografi_faharis' => Loc.text('Bibliografi & Faharis'),
    _ => AppCopy.allAssistantsAvailable,
  };
  if (base == AppCopy.allAssistantsAvailable) return base;
  return Loc.isArabic ? base : (base.startsWith('AI ') ? base : 'AI $base');
}

