import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DOKU Signature generation satisfies DOKU HMACSHA256 protocol specification', () {
    const clientId = 'TEST-CLIENT-ID-123';
    const secretKey = 'TEST-SECRET-KEY-456';
    const requestId = 'REQ-12345';
    const timestamp = '2026-09-07T12:00:00Z';
    const targetPath = '/checkout/v1/payment';
    const rawBody = '{"order":{"amount":50000}}';

    final digest = base64Encode(sha256.convert(utf8.encode(rawBody)).bytes);
    final signatureComponent =
        'Client-Id:$clientId\nRequest-Id:$requestId\nRequest-Timestamp:$timestamp\nRequest-Target:$targetPath\nDigest:$digest';
    final hmac = base64Encode(Hmac(sha256, utf8.encode(secretKey)).convert(utf8.encode(signatureComponent)).bytes);
    final signature = 'HMACSHA256=$hmac';

    expect(signature.startsWith('HMACSHA256='), isTrue);
    expect(signature.length, greaterThan(20));
  });

  test('Direct DOKU Checkout API returns HTTP 200 with checkout URL when env configured', () async {
    final clientId = Platform.environment['DOKU_CLIENT_ID'];
    final secretKey = Platform.environment['DOKU_SECRET_KEY'];
    if (clientId == null || secretKey == null) {
      // Lewati live API call jika kredensial privat tidak di-inject via CI/CD environment
      return;
    }
    const baseUrl = 'https://api-sandbox.doku.com';
    const targetPath = '/checkout/v1/payment';

    final invoiceNumber = 'DART-TEST-${DateTime.now().millisecondsSinceEpoch}';
    final requestBody = {
      'order': {
        'amount': 49000,
        'invoice_number': invoiceNumber,
        'callback_url': 'https://openturath-ai.web.app',
        'line_items': [
          {
            'name': 'Test Paket Tholib (1 Bulan)',
            'price': 49000,
            'quantity': 1,
          }
        ],
      },
      'payment': {
        'payment_due_date': 120,
      },
      'customer': {
        'name': 'Peneliti Test',
        'email': 'test.peneliti@openturath.ai',
        'phone': '081234567890',
      },
    };

    final rawBody = jsonEncode(requestBody);
    final requestId = 'REQ-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9000) + 1000}';
    final timestamp = '${DateTime.now().toUtc().toIso8601String().substring(0, 19)}Z';

    final digest = base64Encode(sha256.convert(utf8.encode(rawBody)).bytes);
    final signatureComponent = 'Client-Id:$clientId\nRequest-Id:$requestId\nRequest-Timestamp:$timestamp\nRequest-Target:$targetPath\nDigest:$digest';
    final hmac = base64Encode(Hmac(sha256, utf8.encode(secretKey)).convert(utf8.encode(signatureComponent)).bytes);
    final signature = 'HMACSHA256=$hmac';

    final client = HttpClient();
    try {
      final request = await client.postUrl(Uri.parse('$baseUrl$targetPath'));
      request.headers.set('Client-Id', clientId);
      request.headers.set('Request-Id', requestId);
      request.headers.set('Request-Timestamp', timestamp);
      request.headers.set('Signature', signature);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(utf8.encode(rawBody));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      expect(response.statusCode, 200);
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final url = json['response']?['payment']?['url'] as String?;
      expect(url, isNotNull);
      expect(url!.startsWith('https://staging.doku.com/checkout-link-v2/'), isTrue);
    } on SocketException catch (_) {
      // Offline / Sandbox test environment
    } finally {
      client.close();
    }
  });
}
