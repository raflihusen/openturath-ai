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
      expiryLabel: 'Berlaku sampai',
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
      return _base(MembershipPassState.paymentPending, 'Menyiapkan akses Pro',
          'Pembayaran sedang diverifikasi', 'Lihat status pembayaran');
    }
    if (hasFailed) {
      return _base(MembershipPassState.paymentFailed, 'Akses belum aktif',
          'Pembayaran belum berhasil', 'Coba pembayaran lagi');
    }
    return _base(
        MembershipPassState.locked,
        'Belum ada akses aktif',
        'Pilih paket untuk mulai menggunakan asisten kajian.',
        'Lihat pilihan paket');
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
  final isMixedExpiry = expiries
          .map((item) => item.toIso8601String().substring(0, 10))
          .toSet()
          .length >
      1;
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
        expiryLabel: 'Masa berlaku',
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
        expiryLabel: 'Berakhir pada',
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
      expiryLabel: isMixedExpiry ? 'Yang berakhir lebih dulu' : 'Berlaku sampai',
      expiresAt: expiry,
      ctaLabel: state == MembershipPassState.expiringSoon
          ? 'Perpanjang Pro'
          : 'Kelola langganan',
      agentIds: selected.map((entry) => entry.key).toList());
}

MembershipPassSummary _base(MembershipPassState state, String access,
        String supporting, String cta) =>
    MembershipPassSummary(
        state: state,
        badge: 'PRO',
        accessLabel: access,
        supportingLabel: supporting,
        expiryLabel: '',
        expiresAt: null,
        ctaLabel: cta);
