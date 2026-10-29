/// Kebijakan tujuan navigasi WebView pembayaran (OT-F005).
///
/// Domain dicocokkan sebagai domain itu sendiri ATAU subdomainnya. Pencocokan
/// `endsWith('.domain')` saja menolak alamat apex (mis. `bca.co.id`) sehingga
/// pembeli tersangkut di halaman bank tanpa pesan apa pun.
class PaymentDestinationPolicy {
  static const _domains = <String>[
    // OpenTurath
    'openturath.id', 'openturath.ai', 'openturath-ai.web.app',
    'open-turath.web.app', 'open-turath.firebaseapp.com',
    // Midtrans / Veritrans
    'midtrans.com', 'veritrans.co.id',
    // Bank
    'bca.co.id', 'klikbca.com', 'mandiri.co.id', 'bri.co.id', 'bni.co.id',
    'bsi.co.id', 'cimbniaga.co.id', 'permata.co.id', 'permatabank.com',
    'danamon.co.id',
    // Dompet digital & paylater yang dialihkan Midtrans Snap
    'gopay.co.id', 'gojek.com', 'gojek.link', 'shopeepay.co.id',
    'shopee.co.id', 'shp.ee', 'ovo.id', 'dana.id', 'linkaja.id',
    'akulaku.com', 'kredivo.com',
  ];

  static bool isAllowed(Uri uri) {
    if (uri.scheme != 'https') return false;
    final host = uri.host.toLowerCase();
    return _domains.any((d) => host == d || host.endsWith('.$d'));
  }
}
