import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
      : _functions = functions ?? const CallableGateway(),
        _hasCustomFunctions = functions != null;

  final CallableGateway _functions;
  final bool _hasCustomFunctions;

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
    // 1. Buat sesi checkout via endpoint mandiri VPS (otoritas utama produksi)
    if (!_hasCustomFunctions) {
      String? idToken;
      try {
        if (Firebase.apps.isNotEmpty) {
          idToken = await FirebaseAuth.instance.currentUser
              ?.getIdToken()
              .timeout(const Duration(seconds: 3), onTimeout: () => null);
        }
      } catch (_) {}

      final canFallbackToCloudFunction =
          Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

      try {
        final res = await http.post(
          Uri.parse('https://maktabah.openturath.id/api/v1/payment/checkout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'OpenTurathApp/1.0',
            if (idToken != null && idToken.isNotEmpty)
              'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'agent_id': agentId,
            'plan': plan,
            'plan_title': planTitle,
            'amount': amount,
            'expected_amount': amount,
            'pricing_revision': ProductPricing.revision,
            'customer_name': name,
            'customer_email': email,
            'customer_phone': phone,
            'uid': uid,
          }),
        ).timeout(const Duration(seconds: 12));

        Map<String, dynamic>? data;
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}

        if (res.statusCode == 200 && data != null) {
          final paymentUrl = data['redirect_url'] ??
              data['paymentUrl'] ??
              data['redirectUrl'] ??
              data['snap_url'];
          final invoiceNumber = data['order_id'] ??
              data['invoiceNumber'] ??
              data['invoice_number'] ??
              '';
          final trxId =
              (data['transaction_id'] ?? data['trxId'] ?? '').toString();
          final rawServerAmount = data['amount'] ?? data['gross_amount'];
          final parsedServerAmount = rawServerAmount is int
              ? rawServerAmount
              : (rawServerAmount is num
                  ? rawServerAmount.toInt()
                  : int.tryParse(rawServerAmount?.toString() ?? ''));
          final serverRevision =
              (data['pricingRevision'] ?? data['pricing_revision'])?.toString();

          if (paymentUrl is String && paymentUrl.isNotEmpty) {
            return {
              'redirectUrl': paymentUrl,
              'paymentUrl': paymentUrl,
              'trxId': trxId,
              'invoiceNumber': invoiceNumber.toString(),
              'status': 'pending',
              'amount': parsedServerAmount ?? amount,
              'pricingRevision':
                  (serverRevision != null && serverRevision.isNotEmpty)
                      ? serverRevision
                      : ProductPricing.revision,
            };
          }
        }

        // Tangani penolakan harga basi atau error bisnis VPS secara eksplisit;
        // jangan diam-diam jatuh ke Cloud Function saat error 4xx atau tanpa FirebaseAuth.
        final serverReason = data?['reason']?.toString();
        final serverMessage =
            (data?['message'] ?? data?['error'])?.toString();
        if (res.statusCode == 409 ||
            res.statusCode == 412 ||
            serverReason == 'price_changed') {
          throw FirebaseFunctionsException(
            code: 'failed-precondition',
            message: serverMessage ??
                'Harga penawaran telah berubah. Muat ulang aplikasi.',
            details: {
              ...?data,
              'reason': serverReason ?? 'price_changed',
              'agentId': agentId,
              'plan': plan,
              if (data?['amount'] != null) 'amount': data!['amount'],
              if (data?['pricingRevision'] != null ||
                  data?['pricing_revision'] != null)
                'pricingRevision':
                    data!['pricingRevision'] ?? data['pricing_revision'],
            },
          );
        }
        if (res.statusCode == 401) {
          throw FirebaseFunctionsException(
            code: 'unauthenticated',
            message: serverMessage ?? 'Sesi akun kedaluwarsa.',
          );
        }
        if (res.statusCode == 403) {
          throw FirebaseFunctionsException(
            code: 'permission-denied',
            message: serverMessage ?? 'Akses transaksi ditolak.',
          );
        }
        if (res.statusCode == 400 || res.statusCode == 422) {
          throw FirebaseFunctionsException(
            code: 'invalid-argument',
            message: serverMessage ?? 'Pilihan paket tidak valid.',
          );
        }
        if (!canFallbackToCloudFunction) {
          throw FirebaseFunctionsException(
            code: 'unavailable',
            message: serverMessage ??
                'Layanan pembayaran sedang sibuk (HTTP ${res.statusCode}).',
          );
        }
      } on FirebaseFunctionsException {
        rethrow;
      } catch (e) {
        if (!canFallbackToCloudFunction) {
          throw FirebaseFunctionsException(
            code: 'unavailable',
            message: 'Gagal terhubung ke server pembayaran: $e',
          );
        }
      }
    }

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
        'trxId': (data['trxId'] ?? '').toString(),
        'invoiceNumber': (data['invoiceNumber'] ?? '').toString(),
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

  /// Periksa status pembayaran transaksi melalui backend VPS / Cloud Function server-side.
  /// Klien tidak pernah menyimpan atau memakai Server Key Midtrans.
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

    // 1. Cek langsung ke backend resmi VPS (maktabah.openturath.id)
    if (!_hasCustomFunctions) {
      try {
        final vpsUrl = Uri.parse(
            'https://maktabah.openturath.id/api/v1/payment/status?invoiceNumber=${Uri.encodeQueryComponent(cleanInvoice)}');
        final resp = await http.get(vpsUrl, headers: {
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 8));

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data is Map<String, dynamic>) {
            final rawStatus =
                (data['status'] ?? '').toString().trim().toUpperCase();
            const terminalStatuses = {
              'EXPIRE',
              'EXPIRED',
              'DENY',
              'DENIED',
              'FAILED',
              'CANCEL',
              'CANCELLED',
              'REFUND',
              'PARTIAL_REFUND',
              'CHARGEBACK',
              'PARTIAL_CHARGEBACK',
            };
            if (terminalStatuses.contains(rawStatus)) {
              return {
                'status': rawStatus,
                'success': false,
                'order_id': cleanInvoice,
                'data': data,
              };
            }
            const pendingStatuses = {
              'PENDING',
              'CHALLENGE',
              'CAPTURE',
              'AUTHORIZE',
            };
            if (pendingStatuses.contains(rawStatus)) {
              return {
                'status': rawStatus,
                'success': false,
                'order_id': cleanInvoice,
                'data': data,
              };
            }
            const successStatuses = {
              'SUCCESS',
              'PAID',
              'SETTLED',
              'SETTLEMENT',
            };
            if (successStatuses.contains(rawStatus) ||
                (rawStatus.isEmpty && data['success'] == true)) {
              return {
                'status': 'SUCCESS',
                'success': true,
                'order_id': cleanInvoice,
                'data': data,
              };
            }
          }
        }
      } catch (_) {}
    }

    // 2. Fallback ke Cloud Function hanya jika disediakan custom gateway atau ada sesi Firebase Auth aktif
    final canCallCloudFunction = _hasCustomFunctions ||
        (Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null);
    if (!canCallCloudFunction) {
      return {
        'status': 'PENDING',
        'success': false,
        'reason': 'inquiry_unavailable',
        'message': 'Status pembayaran belum dapat diperiksa.',
      };
    }

    try {
      final result = await _functions.call(
          AppConstants.fnCheckPaymentStatus, {'invoiceNumber': cleanInvoice});
      return Map<String, dynamic>.from(result as Map);
    } on FirebaseFunctionsException {
      rethrow;
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
