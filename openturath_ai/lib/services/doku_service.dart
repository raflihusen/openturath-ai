import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants.dart';

/// DokuService — Layanan checkout DOKU yang aman & terpusat.
/// Seluruh kalkulasi signature HMAC dan interaksi ke API DOKU
/// dieksekusi secara eksklusif oleh Cloud Functions (server-side),
/// sehingga tidak ada Secret Key yang tersimpan di dalam client/APK.
class DokuService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Buat sesi pembayaran checkout resmi melalui Cloud Function createCheckout
  Future<Map<String, dynamic>> createCheckoutSession({
    required String uid,
    required String agentId,
    required String plan,
    required String planTitle,
    required int amount,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        AppConstants.fnCreatePayment,
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );
      final result = await callable.call({
        'uid': uid,
        'agentId': agentId,
        'plan': plan,
        'planTitle': planTitle,
        'amount': amount,
        'name': name,
        'email': email,
        'phone': phone,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      return {
        'redirectUrl': data['paymentUrl'] ?? data['redirectUrl'],
        'paymentUrl': data['paymentUrl'] ?? data['redirectUrl'],
        'trxId': data['trxId'] ?? '',
        'invoiceNumber': data['invoiceNumber'] ?? '',
        'status': 'pending',
      };
    } catch (e) {
      throw Exception('Gagal membuat sesi pembayaran DOKU: $e');
    }
  }

  /// Periksa status pembayaran secara aktif langsung ke Cloud Functions
  /// yang memverifikasi transaksi langsung ke DOKU Orders API.
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String invoiceNumber,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        AppConstants.fnCheckPaymentStatus,
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );
      final result = await callable.call({'invoiceNumber': invoiceNumber});
      return Map<String, dynamic>.from(result.data as Map);
    } catch (e) {
      return {
        'success': false,
        'status': 'ERROR',
        'error': e.toString(),
      };
    }
  }
}
