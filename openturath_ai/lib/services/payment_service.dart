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

  /// Periksa status pembayaran lewat Cloud Function yang menanyakan gateway.
  Future<Map<String, dynamic>> checkPaymentStatus({
    required String invoiceNumber,
  }) async {
    final result = await _functions.call(
        AppConstants.fnCheckPaymentStatus, {'invoiceNumber': invoiceNumber});
    return Map<String, dynamic>.from(result as Map);
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
