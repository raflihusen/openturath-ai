import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/services/callable_gateway.dart';
import 'package:openturath_ai/services/payment_service.dart';
import 'package:openturath_ai/services/subscription_service.dart';

class _Gateway extends CallableGateway {
  _Gateway(this.response);
  final Future<dynamic> Function() response;
  @override
  Future<dynamic> call(String name, [Map<String, dynamic>? data]) => response();
}

void main() {
  test('transport failure remains an error rather than an unpaid result',
      () async {
    final failure = FirebaseFunctionsException(code: 'unavailable');
    final service =
        PaymentService(functions: _Gateway(() async => throw failure));
    await expectLater(service.checkPaymentStatus(invoiceNumber: 'INV-1'),
        throwsA(same(failure)));
  });

  test('server inquiry error and real pending result remain distinguishable',
      () async {
    for (final status in ['ERROR', 'PENDING']) {
      final service = PaymentService(
          functions:
              _Gateway(() async => {'success': false, 'status': status}));
      final result = await service.checkPaymentStatus(invoiceNumber: 'INV-1');
      final feedback = PaymentInquiryFeedback.forStatus(result['status']);
      expect(feedback.messageKey,
          status == 'ERROR' ? 'paymentCheckUnavailable' : 'paymentPending');
      expect(feedback.terminal, isFalse);
    }
  });

  test(
      'real verification path distinguishes legacy provider error from pending',
      () async {
    for (final response in [
      {
        'success': false,
        'status': 'PENDING',
        'message': 'Status pembayaran belum dapat diperiksa. Silakan coba lagi.'
      },
      {'success': false, 'status': 'ERROR'},
      {
        'success': false,
        'status': 'PENDING',
        'message': 'Pembayaran masih menunggu penyelesaian.'
      },
      {'success': false, 'status': 'expire'},
    ]) {
      final service = SubscriptionService(
          paymentService:
              PaymentService(functions: _Gateway(() async => response)));
      final result =
          await service.verifyPaymentStatus(invoiceNumber: ' INV-1 ');
      final feedback = PaymentInquiryFeedback.forStatus(result['status']);
      final expected = response['status'] == 'expire'
          ? 'paymentExpired'
          : response['message'] == 'Pembayaran masih menunggu penyelesaian.'
              ? 'paymentPending'
              : 'paymentCheckUnavailable';
      expect(result['success'], isFalse);
      expect(feedback.messageKey, expected);
    }
  });

  test('final gateway outcomes stop automatic polling with specific feedback',
      () {
    const expected = {
      'expire': 'paymentExpired',
      'EXPIRED': 'paymentExpired',
      'deny': 'paymentDenied',
      'FAILED': 'paymentDenied',
      'cancel': 'paymentCancelled',
      'CANCELLED': 'paymentCancelled',
      'refund': 'paymentRefunded',
      'CHARGEBACK': 'paymentRefunded',
      'partial_refund': 'paymentPartialRefund',
    };
    for (final entry in expected.entries) {
      final feedback = PaymentInquiryFeedback.forStatus(entry.key);
      expect(feedback.messageKey, entry.value, reason: entry.key);
      expect(feedback.terminal, isTrue, reason: entry.key);
    }
    expect(PaymentInquiryFeedback.forStatus('unknown').messageKey,
        'paymentCheckUnavailable');
  });
}
