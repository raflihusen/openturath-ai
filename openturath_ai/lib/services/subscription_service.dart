import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization.dart';
import '../core/constants.dart';
import 'auth_service.dart';
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

      // Dapatkan data akun pengguna aktif
      final auth = AuthService();
      final user = auth.cachedCurrentUser;
      var email = (user?.email ?? '').trim().toLowerCase();
      var uid = user?.uid ?? '';

      if (email.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          email = (prefs.getString('webview_session_owner') ??
                  prefs.getString('google_session_email') ??
                  prefs.getString('notebook_google_email') ??
                  '')
              .trim()
              .toLowerCase();
          if (email.isNotEmpty && uid.isEmpty) {
            uid = 'web_$email';
          }
        } catch (_) {}
      }
      if (uid.isEmpty && email.isNotEmpty) {
        uid = 'web_$email';
      }

      final payload = jsonEncode({
        'code': normalized,
        'email': email,
        'uid': uid,
        'deviceId': fingerprint.deviceId,
        'deviceModel': fingerprint.model,
        'deviceBrand': fingerprint.brand,
        'isPhysicalDevice': fingerprint.isPhysicalDevice,
      });

      // 1. Tembak endpoint resmi VPS Maktabah OpenTurath (FastAPI / Caddy / Cloudflare)
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'OpenTurathApp/1.0',
      };
      http.Response? response;
      try {
        response = await http
            .post(
              Uri.parse('https://maktabah.openturath.id/api/redeem-code'),
              headers: headers,
              body: payload,
            )
            .timeout(const Duration(seconds: 15));
      } catch (e) {
        debugPrint('[SubscriptionService] Network error calling redeem-code: $e');
        return {
          'success': false,
          'code': 'network_error',
          'message': Loc.tr('networkError'),
        };
      }

      // Coba parsing JSON dari respons server
      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        // Format respon bukan JSON (misal HTML Cloudflare atau plain text 500)
      }

      if (response.statusCode == 200 && data != null && data['success'] == true) {
        if (email.isNotEmpty) {
          unawaited(AuthService.establishVerifiedWebUser(email));
        }
        return data;
      }

      if (data != null) {
        final errCode = (data['code'] as String?) ?? 'failed';
        final serverMsg = data['message'] as String?;
        final msg = (serverMsg != null && serverMsg.isNotEmpty)
            ? serverMsg
            : redeemErrorMessage(errCode);
        return {
          'success': false,
          'code': errCode,
          'message': msg,
        };
      }

      // Jika server mengembalikan non-JSON (seperti 500 Internal Server Error)
      if (response.statusCode >= 500) {
        return {
          'success': false,
          'code': 'server_error',
          'message':
              'Server voucher sedang mengalami kendala (${response.statusCode}). Mohon hubungi admin atau coba sesaat lagi.',
        };
      }

      return {
        'success': false,
        'code': 'http_${response.statusCode}',
        'message':
            'Gagal memproses voucher (${response.statusCode}). Coba lagi nanti.',
      };
    } catch (e) {
      debugPrint('[SubscriptionService] Unhandled error: $e');
      return {'success': false, 'message': Loc.tr('networkError')};
    }
  }

  /// Apakah penyediaan akses (berbagi notebook) untuk penukaran [code] atau
  /// pembayaran [invoice] milik pengguna sudah selesai. Galat apa pun dianggap
  /// belum siap, sehingga penahan hitungan tetap berlaku sebagai cadangan.
  Future<bool> isAccessReady({String? code, String? invoice}) async {
    // Pada backend VPS, penukaran voucher via SQLite/grants dicatat seketika (instant grant)
    if (code != null) return true;
    try {
      final data = await const CallableGateway().call('getAccessReadiness', {
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
