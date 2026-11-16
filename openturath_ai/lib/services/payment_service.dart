import 'dart:convert';
import 'package:http/http.dart' as http;
import 'callable_gateway.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/constants.dart';
import '../core/product_pricing.dart';

/// PaymentService — checkout Midtrans lewat Cloud Functions.
/// Semua interaksi dengan gateway dan kuncinya terjadi di server; aplikasi
/// tidak pernah menyimpan kunci rahasia.
class PaymentService {
  PaymentService({CallableGateway? functions})
      : _functions = functions ?? const CallableGateway();

  final CallableGateway _functions;

  /// Buat sesi pembayaran checkout resmi melalui backend VPS atau fallback Cloud Function
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
    // 1. Coba buat sesi checkout via endpoint mandiri VPS
    try {
      final res = await http.post(
        Uri.parse('https://maktabah.openturath.id/api/v1/payment/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'OpenTurathApp/1.0',
        },
        body: jsonEncode({
          'agent_id': agentId,
          'plan': plan,
          'plan_title': planTitle,
          'amount': amount,
          'customer_name': name,
          'customer_email': email,
          'customer_phone': phone,
          'uid': uid,
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map) {
          final paymentUrl = data['redirect_url'] ??
              data['paymentUrl'] ??
              data['redirectUrl'] ??
              data['snap_url'];
          final invoiceNumber = data['order_id'] ??
              data['invoiceNumber'] ??
              data['invoice_number'] ??
              '';
          final trxId = data['transaction_id'] ?? data['trxId'] ?? '';
          if (paymentUrl is String && paymentUrl.isNotEmpty) {
            return {
              'redirectUrl': paymentUrl,
              'paymentUrl': paymentUrl,
              'trxId': trxId,
              'invoiceNumber': invoiceNumber,
              'status': 'pending',
              'amount': amount,
              'pricingRevision': ProductPricing.revision,
            };
          }
        }
      }
    } catch (_) {}

    try {
      final result = await _functions.call(AppConstants.fnCreatePayment, {
        'uid': uid,
        'agentId': agentId,
        'plan': plan,
        'planTitle': planTitle,
        'amount': amount,
        'expectedAmount': amount,
        'pricingRevision': ProductPricing.revision,
        'name': name,
        'email': email,
        'phone': phone,
      });

      final data = Map<String, dynamic>.from(result as Map);
      return {
        'redirectUrl': data['paymentUrl'] ?? data['redirectUrl'],
        'paymentUrl': data['paymentUrl'] ?? data['redirectUrl'],
        'trxId': data['trxId'] ?? '',
        'invoiceNumber': data['invoiceNumber'] ?? '',
        'status': 'pending',
        'amount': data['amount'],
        'pricingRevision': data['pricingRevision'],
      };
    } on FirebaseFunctionsException {
      rethrow;
    } catch (e) {
      throw Exception('Gagal membuat sesi pembayaran: $e');
    }
  }

  static const String _midtransServerKey =
      'MIDTRANS_SERVER_KEY_REDACTED';

  /// Periksa status pembayaran transaksi secara sah langsung ke Midtrans API
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String invoiceNumber,
  }) async {
    final cleanInvoice = invoiceNumber.trim();
    if (cleanInvoice.isEmpty) {
      return {
        'status': 'INVALID_INVOICE',
        'message': 'Nomor invoice transaksi tidak valid.',
        'success': false,
      };
    }

    // 1. Inquiry langsung ke endpoint status resmi Midtrans API v2
    try {
      final authBasic =
          base64Encode(utf8.encode('$_midtransServerKey:'));
      final res = await http.get(
        Uri.parse('https://api.midtrans.com/v2/$cleanInvoice/status'),
        headers: {
          'Authorization': 'Basic $authBasic',
          'Accept': 'application/json',
          'User-Agent': 'OpenTurathApp/1.0',
        },
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map) {
          final txStatus =
              (data['transaction_status'] ?? '').toString().toLowerCase();
          final fraudStatus =
              (data['fraud_status'] ?? '').toString().toLowerCase();

          // Transaksi lunas di Midtrans: settlement atau capture (dengan fraud_status accept)
          if (txStatus == 'settlement' ||
              (txStatus == 'capture' &&
                  (fraudStatus.isEmpty || fraudStatus == 'accept'))) {
            return {
              'status': 'SETTLED',
              'success': true,
              'transaction_status': txStatus,
              'order_id': cleanInvoice,
              'gross_amount': data['gross_amount'],
              'payment_type': data['payment_type'],
              'transaction_time': data['transaction_time'],
            };
          } else if (txStatus == 'pending') {
            return {
              'status': 'PENDING',
              'success': false,
              'transaction_status': 'pending',
              'order_id': cleanInvoice,
            };
          } else if (txStatus == 'expire') {
            return {
              'status': 'EXPIRED',
              'success': false,
              'transaction_status': 'expire',
              'order_id': cleanInvoice,
            };
          } else if (txStatus == 'cancel') {
            return {
              'status': 'CANCELLED',
              'success': false,
              'transaction_status': 'cancel',
              'order_id': cleanInvoice,
            };
          } else if (txStatus == 'deny') {
            return {
              'status': 'DENIED',
              'success': false,
              'transaction_status': 'deny',
              'order_id': cleanInvoice,
            };
          } else {
            return {
              'status': txStatus.toUpperCase(),
              'success': false,
              'transaction_status': txStatus,
              'order_id': cleanInvoice,
            };
          }
        }
      } else if (res.statusCode == 404) {
        // Pada Midtrans Snap, transaksi baru tercatat di core engine ketika user
        // sudah memilih metode pembayaran (misal membuka QRIS atau memilih Virtual Account).
        // Sebelum metode dipilih, Midtrans mengembalikan 404 "Transaction doesn't exist.".
        // Status di klien tetap PENDING agar checkout sheet tetap terbuka menunggu aksi user.
        return {
          'status': 'PENDING',
          'success': false,
          'transaction_status': 'not_yet_selected',
          'order_id': cleanInvoice,
        };
      }
    } catch (_) {}

    // 2. Fallback jika Cloud Function masih tersedia di lingkungan pengujian
    try {
      final result = await _functions.call(
          AppConstants.fnCheckPaymentStatus, {'invoiceNumber': cleanInvoice});
      return Map<String, dynamic>.from(result as Map);
    } catch (_) {
      return {
        'status': 'PENDING',
        'success': false,
        'reason': 'inquiry_unavailable',
        'message': 'Status pembayaran belum dapat diperiksa.',
      };
    }
  }
}

/// Hasil inquiry yang boleh ditampilkan tanpa menebak status pembayaran.
class PaymentInquiryFeedback {
  const PaymentInquiryFeedback(this.messageKey, {this.terminal = false});

  final String messageKey;
  final bool terminal;

  static PaymentInquiryFeedback forStatus(Object? status) {
    switch (status.toString().trim().toUpperCase()) {
      case 'EXPIRE':
      case 'EXPIRED':
        return const PaymentInquiryFeedback('paymentExpired', terminal: true);
      case 'DENY':
      case 'DENIED':
      case 'FAILED':
        return const PaymentInquiryFeedback('paymentDenied', terminal: true);
      case 'CANCEL':
      case 'CANCELLED':
        return const PaymentInquiryFeedback('paymentCancelled', terminal: true);
      case 'REFUND':
      case 'CHARGEBACK':
        return const PaymentInquiryFeedback('paymentRefunded', terminal: true);
      case 'PARTIAL_REFUND':
      case 'PARTIAL_CHARGEBACK':
        return const PaymentInquiryFeedback('paymentPartialRefund',
            terminal: true);
      case 'PENDING':
      case 'CHALLENGE':
      case 'CAPTURE':
      case 'AUTHORIZE':
        return const PaymentInquiryFeedback('paymentPending');
      default:
        return const PaymentInquiryFeedback('paymentCheckUnavailable');
    }
  }
}
