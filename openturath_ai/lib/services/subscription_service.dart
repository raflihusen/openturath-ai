import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/payment_status.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import 'device_service.dart';
import 'doku_service.dart';

class SubscriptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DokuService _dokuService = DokuService();

  /// Normalisasi kode voucher: hapus spasi, ubah huruf kapital, hapus tanda strip
  static String normalizeCode(String input) {
    return input.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  }

  static String redeemErrorMessage(String code, [String? serverMessage]) {
    final c = code.toLowerCase().replaceAll('_', '-');
    if (serverMessage != null && serverMessage.isNotEmpty) {
      final lowerMsg = serverMessage.toLowerCase();
      if (lowerMsg.contains('perangkat') || lowerMsg.contains('ponsel')) {
        return serverMessage;
      }
    }
    if (c.contains('not-found')) return 'Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda.';
    if (c.contains('already-exists') || c.contains('already-used')) {
      return 'Kode ini sudah pernah ditukarkan sebelumnya.';
    }
    if (c.contains('deadline-exceeded') || c.contains('expired')) return 'Masa berlaku kode voucher ini telah berakhir.';
    if (c.contains('failed-precondition')) {
      if (serverMessage != null && serverMessage.contains('ponsel')) {
        return serverMessage;
      }
      return 'Kode voucher ini sudah tidak aktif.';
    }
    if (c.contains('resource-exhausted') || c.contains('quota')) return 'Kuota penukaran untuk kode voucher ini sudah habis.';
    if (c.contains('unauthenticated')) return 'Silakan masuk ke akun Anda lalu coba kembali.';
    if (c.contains('invalid-argument')) return 'Format penulisan kode voucher belum sesuai.';
    if (c.contains('permission-denied')) return 'Kode voucher ini tidak dapat digunakan untuk akun Anda.';
    if (c.contains('unavailable')) return 'Layanan belum dapat dihubungi. Periksa koneksi lalu coba lagi.';
    return 'Kode voucher belum dapat diaktifkan. Silakan periksa kembali kode Anda.';
  }

  // ── Klaim Kode Redeem Santri (Voucher Akses 7 Hari, dsb) ─────
  Future<Map<String, dynamic>> redeemAccessCode(
    String code, {
    DeviceFingerprint? customFingerprint,
  }) async {
    try {
      final normalized = normalizeCode(code);
      final fingerprint = customFingerprint ?? await DeviceService().getDeviceFingerprint();
      final callable = FirebaseFunctions.instance.httpsCallable('redeemCode');
      final result = await callable.call({
        'code': normalized,
        'deviceId': fingerprint.deviceId,
        'deviceModel': fingerprint.model,
        'deviceBrand': fingerprint.brand,
        'isPhysicalDevice': fingerprint.isPhysicalDevice,
      });
      final data = result.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'success': false, 'message': 'Respons server belum valid. Muat ulang status akses sebelum mencoba kembali.'};
    } on FirebaseFunctionsException catch (e) {
      final serverMsg = e.message;
      if (serverMsg != null &&
          serverMsg.isNotEmpty &&
          (serverMsg.contains('perangkat') || serverMsg.contains('ponsel'))) {
        return {'success': false, 'message': serverMsg};
      }
      return {'success': false, 'message': redeemErrorMessage(e.code, serverMsg)};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi bermasalah. Periksa internet Anda lalu coba lagi.'};
    }
  }

  // ── Sinkronkan Transaksi GoAkal Secara Otomatis ───────────────
  Future<Map<String, dynamic>> syncAkalPurchases() async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('syncAkalPurchases');
      final result = await callable.call();
      final data = result.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {
        'success': false,
        'synced': <String>[],
        'message': 'Respons sinkronisasi belum valid. Coba lagi.'
      };
    } on FirebaseFunctionsException catch (e) {
      return {
        'success': false,
        'synced': <String>[],
        'message': e.message ?? 'Gagal menyinkronkan data GoAkal.'
      };
    } catch (e) {
      return {
        'success': false,
        'synced': <String>[],
        'message': 'Gagal menghubungi server. Periksa koneksi internet Anda.'
      };
    }
  }

  // ── Buat Payment Request resmi ke DOKU Payment Gateway ───────
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
    if (FirebaseAuth.instance.currentUser?.uid != uid) {
      throw StateError('Akun telah berubah. Buka ulang halaman pembayaran.');
    }
    final resolvedAmount = amount ?? _getPriceForPlan(plan);
    final resolvedTitle = planTitle ?? _getTitleForPlan(plan);

    // Eksekusi checkout DOKU melalui Cloud Functions
    final session = await _dokuService.createCheckoutSession(
      uid: uid,
      agentId: agentId,
      plan: plan,
      planTitle: resolvedTitle,
      amount: resolvedAmount,
      name: name,
      email: email,
      phone: phone,
    );
    if (FirebaseAuth.instance.currentUser?.uid != uid) {
      throw StateError('Akun telah berubah. Buka ulang halaman pembayaran.');
    }
    final url = session['paymentUrl'];
    if (url is! String || !isAllowedPaymentUrl(url, initial: true)) {
      throw StateError('Tautan pembayaran dari server belum dapat digunakan.');
    }
    return session;
  }

  // ── Cek status transaksi secara aktif (inquiry ke DOKU API via Cloud Function) ──
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

    final ownerUid = FirebaseAuth.instance.currentUser?.uid;
    if (ownerUid == null) {
      return {'success': false, 'status': 'UNAUTHENTICATED'};
    }
    // Only the server inquiry can confirm payment. It must authorize invoice
    // ownership, verify gateway signatures and derive the authoritative amount.
    final response = await _dokuService.checkPaymentStatus(invoiceNumber: cleanInvoice);
    if (FirebaseAuth.instance.currentUser?.uid != ownerUid) {
      return {'success': false, 'status': 'ACCOUNT_CHANGED'};
    }
    return {
      ...response,
      'status': paymentStatus(response['status']),
      'success': isConfirmedPayment(response),
      'paymentConfirmed': isConfirmedPayment(response),
    };
  }

  // ── Legacy polling helper ────────────────────────────────────
  Future<String> checkPaymentStatus(String trxId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || trxId.trim().isEmpty) return 'pending';
    final doc = await _db.collection(AppConstants.colTransactions).doc(trxId).get();
    if (!doc.exists || FirebaseAuth.instance.currentUser?.uid != uid ||
        doc.data()?['uid'] != uid) return 'pending';
    final status = doc.data()?['status'];
    return status is String ? status : 'pending';
  }

  // ── Stream status user secara real-time ───────────────────────
  Stream<UserModel?> watchUserSubscription(String uid) {
    return _db
        .collection(AppConstants.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  int _getPriceForPlan(String plan) {
    switch (plan) {
      case AppConstants.planTholib1m:
        return AppConstants.priceTholib1m;
      case AppConstants.planTholib6m:
        return AppConstants.priceTholib6m;
      case AppConstants.planBahits1y:
        return AppConstants.priceBahits1y;
      case 'all_ai_1m':
        return AppConstants.priceAllAiPromo1m;
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


