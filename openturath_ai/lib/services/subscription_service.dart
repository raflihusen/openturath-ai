import '../core/localization.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants.dart';
import 'device_service.dart';
import 'payment_service.dart';
import 'callable_gateway.dart';

class SubscriptionService {
  SubscriptionService({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService();

  final PaymentService _paymentService;

  static bool isCheckoutPriceChange({
    required String code,
    String? message,
    Object? details,
  }) {
    if (code.toLowerCase() != 'failed-precondition') return false;
    if (details is Map && details['reason'] == 'price_changed') return true;
    return details == null &&
        message == 'Harga penawaran telah berubah. Muat ulang aplikasi.';
  }

  /// Normalisasi kode voucher: hapus spasi, ubah huruf kapital, hapus tanda strip
  static String normalizeCode(String input) {
    return input.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  }

  static String redeemErrorMessage(String code,
      [String? serverMessage, Object? details]) {
    final c = code.toLowerCase().replaceAll('_', '-');
    // Alasan terstruktur dari server didahulukan: pesan Indonesia dari server
    // tidak ikut ditampilkan, dan satu kode galat tidak lagi menutupi sebab
    // yang berbeda-beda.
    final reason = details is Map ? details['reason'] : null;
    final byReason = switch (reason) {
      'not_found' => 'redeemNotFound',
      'inactive' => 'redeemInactive',
      'quota' => 'redeemQuota',
      'expired' => 'redeemExpired',
      'already_redeemed' => 'redeemUsed',
      'trial_active' => 'redeemTrialActive',
      'trial_claimed' => 'redeemTrialClaimed',
      'needs_google' => 'redeemNeedsGoogle',
      'misconfigured' => 'redeemMisconfigured',
      'rate_limited' => 'redeemRateLimited',
      'physical_device_only' => 'redeemPhysicalOnly',
      'device_used' => 'redeemDeviceUsed',
      'device_identity' => 'redeemDeviceIdentity',
      _ => null,
    };
    if (byReason != null) return Loc.tr(byReason);
    if (serverMessage != null && serverMessage.isNotEmpty) {
      final lowerMsg = serverMessage.toLowerCase();
      if (lowerMsg.contains('perangkat') || lowerMsg.contains('ponsel')) {
        return serverMessage;
      }
    }
    if (c.contains('not-found')) {
      return Loc.tr('redeemNotFound');
    }
    if (c.contains('already-exists') || c.contains('already-used')) {
      return Loc.tr('redeemUsed');
    }
    if (c.contains('deadline-exceeded') || c.contains('expired')) {
      return Loc.tr('redeemExpired');
    }
    if (c.contains('failed-precondition')) {
      if (serverMessage != null && serverMessage.contains('ponsel')) {
        return serverMessage;
      }
      return Loc.tr('redeemInactive');
    }
    if (c.contains('resource-exhausted') || c.contains('quota')) {
      return Loc.tr('redeemQuota');
    }
    if (c.contains('unauthenticated')) {
      return Loc.tr('redeemSignInFirst');
    }
    if (c.contains('invalid-argument')) {
      return Loc.tr('redeemBadFormat');
    }
    if (c.contains('permission-denied')) {
      return Loc.tr('redeemNotForAccount');
    }
    if (c.contains('unavailable')) {
      return Loc.tr('redeemServiceUnavailable');
    }
    return Loc.tr('redeemNotActivated');
  }

  // ── Klaim Kode Redeem Santri (Voucher Akses 7 Hari, dsb) ─────
  Future<Map<String, dynamic>> redeemAccessCode(
    String code, {
    DeviceFingerprint? customFingerprint,
  }) async {
    try {
      final normalized = normalizeCode(code);
      final fingerprint =
          customFingerprint ?? await DeviceService().getDeviceFingerprint();
      final data = await const CallableGateway().call('redeemCode', {
        'code': normalized,
        'deviceId': fingerprint.deviceId,
        'deviceModel': fingerprint.model,
        'deviceBrand': fingerprint.brand,
        'isPhysicalDevice': fingerprint.isPhysicalDevice,
      });
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'success': true};
    } on FirebaseFunctionsException catch (e) {
      final serverMsg = e.message;
      if (serverMsg != null &&
          serverMsg.isNotEmpty &&
          (serverMsg.contains('perangkat') || serverMsg.contains('ponsel'))) {
        return {'success': false, 'message': serverMsg};
      }
      return {
        'success': false,
        'message': redeemErrorMessage(e.code, serverMsg, e.details)
      };
    } catch (e) {
      return {'success': false, 'message': Loc.tr('networkError')};
    }
  }

  /// Apakah penyediaan akses (berbagi notebook) untuk penukaran [code] atau
  /// pembayaran [invoice] milik pengguna sudah selesai. Galat apa pun dianggap
  /// belum siap, sehingga penahan hitungan tetap berlaku sebagai cadangan.
  Future<bool> isAccessReady({String? code, String? invoice}) async {
    try {
      final data = await const CallableGateway().call('getAccessReadiness', {
        if (code != null) 'code': normalizeCode(code),
        if (invoice != null) 'invoice': invoice,
      });
      return data is Map && data['ready'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── Buat sesi pembayaran lewat Cloud Functions ───────
  Future<Map<String, dynamic>> createPayment({
    required String uid,
    required String agentId,
    required String plan,
    required String name,
    required String email,
    required String phone,
    String? planTitle,
    int? amount,
  }) async {
    final resolvedAmount = amount ?? _getPriceForPlan(plan);
    final resolvedTitle = planTitle ?? _getTitleForPlan(plan);

    return await _paymentService.createCheckoutSession(
      uid: uid,
      agentId: agentId,
      plan: plan,
      planTitle: resolvedTitle,
      amount: resolvedAmount,
      name: name,
      email: email,
      phone: phone,
    );
  }

  // ── Cek status transaksi secara aktif (inquiry gateway via Cloud Function) ──
  Future<Map<String, dynamic>> verifyPaymentStatus({
    required String invoiceNumber,
    String? trxId,
  }) async {
    final cleanInvoice = invoiceNumber.trim();
    if (cleanInvoice.isEmpty) {
      return {
        'success': false,
        'status': 'INVALID_INVOICE',
        'message': 'Nomor invoice transaksi tidak valid.'
      };
    }

    // Status ditanyakan server ke gateway; klien tidak pernah memutuskan lunas sendiri.
    final res =
        await _paymentService.checkPaymentStatus(invoiceNumber: cleanInvoice);

    // Validasi ketat respon server Cloud Function: hanya status final yang dianggap lunas
    final rawStatus = (res['status'] ?? '').toString().toUpperCase().trim();
    // Backend lama memakai PENDING untuk galat inquiry. Pertahankan arti
    // galat tersebut sampai semua instalasi memakai kontrak ERROR yang baru.
    final legacyInquiryError = rawStatus == 'PENDING' &&
        (res['message'] ?? '')
            .toString()
            .startsWith('Status pembayaran belum dapat diperiksa.');
    final isSuccess =
        rawStatus == 'SUCCESS' || rawStatus == 'SETTLED' || rawStatus == 'PAID';
    if (isSuccess) {
      return {
        'success': true,
        'status': 'SUCCESS',
        'data': res,
      };
    }

    return {
      'success': false,
      'status': legacyInquiryError || res['reason'] == 'inquiry_unavailable'
          ? 'ERROR'
          : rawStatus.isNotEmpty
              ? rawStatus
              : 'ERROR',
      'data': res,
      if (res['message'] != null) 'message': res['message'],
    };
  }

  // ── Legacy polling helper ────────────────────────────────────

  // ── Stream status user secara real-time ───────────────────────

  int _getPriceForPlan(String plan) {
    switch (plan) {
      case AppConstants.planTholib1m:
        return AppConstants.priceTholib1m;
      case AppConstants.planTholib6m:
        return AppConstants.priceTholib6m;
      case AppConstants.planBahits1y:
        return AppConstants.priceBahits1y;
      default:
        return AppConstants.priceTholib1m;
    }
  }

  String _getTitleForPlan(String plan) {
    switch (plan) {
      case AppConstants.planTholib1m:
        return 'Modul AI (1 Bulan)';
      case AppConstants.planTholib6m:
        return 'Modul AI (6 Bulan)';
      case AppConstants.planBahits1y:
        return 'Modul AI (1 Tahun)';
      default:
        return 'Langganan Modul AI OpenTurath';
    }
  }
}
