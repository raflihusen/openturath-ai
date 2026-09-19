import 'app_copy.dart';
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
  final entitlements =
      user?.entitlements ?? const <String, ModuleEntitlement>{};
  final values = entitlements.entries.toList();
  final active = values.where((entry) {
    final entitlement = entry.value;
    return entitlement.isPremium && entitlement.isActiveAt(reference);
  }).toList();
  if (active.isEmpty && entitlements.isEmpty &&
      user?.subscriptionExpiry?.isAfter(reference) == true) {
    final expiry = user!.subscriptionExpiry;
    final expiring = expiry != null && expiry.difference(reference).inDays <= 3;
    return MembershipPassSummary(
      state: expiring
          ? MembershipPassState.expiringSoon
          : MembershipPassState.activePro,
      badge: 'PRO',
      accessLabel: 'Akses sesuai paket ${user.plan}',
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
        badge: 'PRO',
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
  final isTrial = selected.every((entry) => entry.value.plan == 'trial');
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
        badge: 'PRO',
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


