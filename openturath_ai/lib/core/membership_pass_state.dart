import 'app_copy.dart';
import 'app_config.dart';
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
  if (AppConfig.isGuruEdition) {
    return const MembershipPassSummary(
      state: MembershipPassState.permanent,
      badge: 'GURU',
      accessLabel: 'Akses Penuh Seluruh Khazanah Turats',
      supportingLabel: 'Akses Khusus Kehormatan Guru',
      expiryLabel: 'Permanen',
      expiresAt: null,
      ctaLabel: '',
    );
  }
  final reference = now ?? DateTime.now();
  // Owner-designated VIP status takes precedence over every paid package.
  if (user?.isVip == true) {
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

  final all = active
      .where((entry) => entry.key == 'all_access' || entry.key == 'all_ai')
      .toList();
  final selected = all.isNotEmpty ? all : active;
  final isTrial = active.every(
      (entry) => entry.value.plan == 'trial' || entry.value.status == 'trial');
  final isPermanent =
      selected.every((entry) => entry.value.plan == 'permanent');
  final expiries = selected
      .map((entry) => entry.value.expiry)
      .whereType<DateTime>()
      .toList()
    ..sort();
  final expiry = expiries.isEmpty ? null : expiries.first;
  final accessLabel = all.isNotEmpty
      ? AppCopy.allAssistantsAvailable
      : AppCopy.assistantsAvailableCount(selected.length);
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
