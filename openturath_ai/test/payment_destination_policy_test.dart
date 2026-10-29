import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/payment_destination_policy.dart';

void main() {
  bool ok(String u) => PaymentDestinationPolicy.isAllowed(Uri.parse(u));
  test('apex dan subdomain domain pembayaran resmi diizinkan', () {
    for (final u in [
      'https://app.midtrans.com/snap/v4/redirection/x',
      'https://bca.co.id/x',
      'https://klikpay.klikbca.com/x',
      'https://bsi.co.id/x',
      'https://epay.bri.co.id/x',
      'https://link.dana.id/x',
      'https://shopee.co.id/x',
    ]) {
      expect(ok(u), isTrue, reason: u);
    }
  });
  test('http, domain tiruan, dan akhiran menyerupai tetap ditolak', () {
    for (final u in [
      'http://app.midtrans.com/x',
      'https://midtrans.com.evil.test/x',
      'https://evilmidtrans.com/x',
      'https://notbca.co.id/x',
      'https://example.com/x',
    ]) {
      expect(ok(u), isFalse, reason: u);
    }
  });
}
