/// Server-normalized statuses supported by this application's DOKU contract.
/// A successful HTTP/callable response alone never confirms payment. Other
/// gateway vocabularies (for example CAPTURE) need an explicit server mapping.
String paymentStatus(Object? value) => value is String ? value.trim().toUpperCase() : 'UNKNOWN';

bool isConfirmedPayment(Map<String, dynamic> response) {
  if (response['success'] == false) return false;
  return const {'SUCCESS', 'PAID'}.contains(paymentStatus(response['status']));
}

bool isFailedPayment(Map<String, dynamic> response) =>
    const {'FAILED', 'EXPIRED', 'CANCELLED', 'CANCELED', 'DENIED', 'REFUNDED'}
        .contains(paymentStatus(response['status']));

/// Exact checkout hosts from DOKU's integration and the existing GoAkal
/// catalog. Additional providers require a reviewed backend integration.
bool isAllowedPaymentUrl(String value, {bool initial = false}) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme != 'https' || uri.userInfo.isNotEmpty ||
      uri.host.isEmpty || (uri.hasPort && uri.port != 443)) return false;
  const gatewayHosts = {
    'checkout.doku.com', 'jokul.doku.com', 'staging.doku.com',
    'goakal.com', 'app.midtrans.com', 'app.sandbox.midtrans.com',
  };
  const callbackHosts = {
    'openturath.ai', 'www.openturath.ai',
    'openturath.id', 'www.openturath.id',
    'openturath-ai.web.app', 'openturath.web.app',
  };
  return gatewayHosts.contains(uri.host.toLowerCase()) ||
      (!initial && callbackHosts.contains(uri.host.toLowerCase()));
}
