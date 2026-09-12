import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import 'doku_service.dart';

class SubscriptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DokuService _dokuService = DokuService();

  /// Normalisasi kode voucher: hapus spasi, ubah huruf kapital, hapus tanda strip
  static String normalizeCode(String input) {
    return input.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  }

  // ── Klaim Kode Redeem Santri (Voucher Akses 7 Hari, dsb) ─────
  Future<Map<String, dynamic>> redeemAccessCode(String code) async {
    try {
      final normalized = normalizeCode(code);
      final callable = FirebaseFunctions.instance.httpsCallable('redeemCode');
      final result = await callable.call({'code': normalized});
      final data = result.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'success': true, 'message': 'Kode akses sudah aktif.'};
    } on FirebaseFunctionsException catch (e) {
      return {'success': false, 'message': e.message ?? 'Gagal menukarkan kode akses.'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kendala koneksi: $e'};
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
    final resolvedAmount = amount ?? _getPriceForPlan(plan);
    final resolvedTitle = planTitle ?? _getTitleForPlan(plan);

    // Eksekusi checkout DOKU melalui Cloud Functions
    return await _dokuService.createCheckoutSession(
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

  // ── Cek status transaksi secara aktif (inquiry ke DOKU API via Cloud Function) ──
  Future<Map<String, dynamic>> verifyPaymentStatus({
    required String invoiceNumber,
    String? trxId,
  }) async {
    // 1. Panggil checkPaymentStatus Cloud Function yang inquiry langsung ke DOKU
    final res = await _dokuService.checkPaymentStatus(invoiceNumber: invoiceNumber);
    if (res['status'] == 'SUCCESS' || res['success'] == true) {
      return res;
    }

    // 2. Fallback cek Firestore transaction jika ada trxId
    if (trxId != null && trxId.isNotEmpty) {
      final doc = await _db.collection(AppConstants.colTransactions).doc(trxId).get();
      if (doc.exists && doc.data()?['status'] == 'success') {
        return {'success': true, 'status': 'SUCCESS'};
      }
    }

    return res;
  }

  // ── Legacy polling helper ────────────────────────────────────
  Future<String> checkPaymentStatus(String trxId) async {
    final doc =
        await _db.collection(AppConstants.colTransactions).doc(trxId).get();
    if (!doc.exists) return 'pending';
    return (doc.data()?['status'] ?? 'pending') as String;
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
        return 'Paket Tholib (1 Bulan)';
      case AppConstants.planTholib6m:
        return 'Paket Tholib (6 Bulan)';
      case AppConstants.planBahits1y:
        return 'Paket Bahits (1 Tahun)';
      case 'all_ai_1m':
        return 'Paket Promo Semua AI (1 Bulan)';
      default:
        return 'Langganan OpenTurath AI';
    }
  }
}
