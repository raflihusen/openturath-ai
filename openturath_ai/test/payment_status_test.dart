import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/payment_status.dart';

void main() {
  test('successful inquiry cannot promote an unpaid transaction', () {
    for (final status in ['PENDING', 'processing', 'FAILED', 'EXPIRED', 'ERROR', '', null, 200]) {
      expect(isConfirmedPayment({'success': true, 'status': status}), isFalse,
        reason: 'Request success must not confirm $status');
    }
    expect(isConfirmedPayment({'success': true}), isFalse);
  });
  test('only supported final server statuses confirm payment', () {
    expect(isConfirmedPayment({'status': 'SUCCESS'}), isTrue);
    expect(isConfirmedPayment({'status': ' paid ', 'success': true}), isTrue);
    expect(isConfirmedPayment({'status': 'SUCCESS', 'success': false}), isFalse);
    for (final unsupported in ['CAPTURE', 'SETTLEMENT', 'AUTHORIZED', 'COMPLETED']) {
      expect(isConfirmedPayment({'status': unsupported}), isFalse);
    }
  });
  test('failure classification does not mislabel pending or network errors', () {
    expect(isFailedPayment({'status': 'expired'}), isTrue);
    expect(isFailedPayment({'status': 'REFUNDED'}), isTrue);
    expect(isFailedPayment({'status': 'PENDING'}), isFalse);
    expect(isFailedPayment({'status': 'ERROR'}), isFalse);
  });
  test('initial checkout requires exact secure gateway host', () {
    for (final host in ['checkout.doku.com', 'jokul.doku.com', 'staging.doku.com', 'goakal.com', 'app.midtrans.com', 'app.sandbox.midtrans.com']) {
      expect(isAllowedPaymentUrl('https://$host/checkout/test', initial: true), isTrue);
    }
    for (final url in [
      'http://checkout.doku.com/test', 'https://checkout.doku.com.attacker.test/',
      'https://attacker.test/checkout.doku.com', 'https://user@checkout.doku.com/',
      'https://checkout.doku.com:8443/', 'https://checkout.doku.com./',
      'javascript:alert(1)', 'intent://banking', 'file:///tmp/test',
      'https://openturath.ai/success', 'https://unreviewed.doku.com/',
    ]) {
      expect(isAllowedPaymentUrl(url, initial: true), isFalse, reason: url);
    }
  });
  test('callbacks allow exact app hosts but never a custom external scheme', () {
    expect(isAllowedPaymentUrl('https://openturath-ai.web.app/success'), isTrue);
    expect(isAllowedPaymentUrl('https://openturath.web.app/success'), isTrue);
    expect(isAllowedPaymentUrl('https://openturath.ai/callback'), isTrue);
    expect(isAllowedPaymentUrl('https://openturath.id/callback'), isTrue);
    expect(isAllowedPaymentUrl('https://www.openturath.id/success'), isTrue);
    expect(isAllowedPaymentUrl('https://openturath.ai.attacker.test/success'), isFalse);
    expect(isAllowedPaymentUrl('https://openturath.id.attacker.test/success'), isFalse);
    expect(isAllowedPaymentUrl('bank-app://pay'), isFalse);
  });
}
