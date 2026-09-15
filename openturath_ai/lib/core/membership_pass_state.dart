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
    return entitlement.status != 'revoked' &&
        entitlement.status != 'expired' &&
        (entitlement.plan == 'permanent' ||
            (entitlement.expiry != null &&
                entitlement.expiry!.isAfter(reference)));
  }).toList();
  if (active.isEmpty && user?.isSubscriptionActive == true) {
    final expiry = user!.subscriptionExpiry;
    final expiring = expiry != null && expiry.difference(reference).inDays <= 3;
    return MembershipPassSummary(
      state: expiring
          ? MembershipPassState.expiringSoon
          : MembershipPassState.activePro,
      badge: 'PRO',
      accessLabel: 'Semua asisten tersedia',
      supportingLabel: expiring ? 'Masa akses hampir berakhir' : 'Siap digunakan',
      expiryLabel: 'Berlaku hingga',
      expiresAt: expiry,
      ctaLabel: expiring ? 'Perpanjang Pro' : 'Kelola langganan',
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
        'Menyiapkan akses Pro',
        'Pembayaran sedang diperiksa',
        'Lihat status pembayaran',
        badge: 'PRO',
      );
    }
    if (hasFailed) {
      return _base(
        MembershipPassState.paymentFailed,
        'Akses belum aktif',
        'Pembayaran belum berhasil',
        'Coba pembayaran lagi',
        badge: 'GRATIS',
      );
    }
    return _base(
      MembershipPassState.locked,
      'Belum berlangganan',
      'Pilih asisten dan paket yang sesuai untuk mulai bertanya.',
      'Pilih paket Pro',
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
      ? 'Semua asisten tersedia'
      : selected.length == 1
          ? '1 asisten tersedia'
          : '${selected.length} asisten tersedia';
  if (isPermanent) {
    return MembershipPassSummary(
        state: MembershipPassState.permanent,
        badge: 'PRO',
        accessLabel: accessLabel,
        supportingLabel: 'Tanpa batas waktu',
        expiryLabel: 'Berlaku hingga',
        expiresAt: null,
        ctaLabel: 'Kelola akses',
        agentIds: selected.map((entry) => entry.key).toList());
  }
  if (isTrial) {
    final days = expiry == null ? 0 : expiry.difference(reference).inDays + 1;
    return MembershipPassSummary(
        state: MembershipPassState.trialPro,
        badge: 'PRO',
        accessLabel: accessLabel,
        supportingLabel: 'Masa coba · $days hari',
        expiryLabel: 'Berlaku hingga',
        expiresAt: expiry,
        ctaLabel: 'Pilih paket Pro',
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
          ? 'Masa akses hampir berakhir'
          : 'Siap digunakan',
      expiryLabel: 'Berlaku hingga',
      expiresAt: expiry,
      ctaLabel: state == MembershipPassState.expiringSoon
          ? 'Perpanjang Pro'
          : 'Kelola langganan',
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
      expiryLabel: 'Berlaku hingga',
      expiresAt: null,
      ctaLabel: cta,
    );
