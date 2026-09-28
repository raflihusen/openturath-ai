import '../widgets/adaptive_sheet.dart';
import '../services/desktop_webview_runtime.dart';
import '../widgets/desktop_webview_gate.dart';
import '../core/app_platform.dart';
import '../core/localization.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../core/scholarly_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/checkout_completion.dart';
import '../core/theme.dart';
import '../core/design/ot_colors.dart';
import '../services/subscription_service.dart';
import 'app_loader.dart';
import 'promo_price.dart';

/// DokuCheckoutSheet: In-App Modal Pembayaran DOKU dengan Deteksi Otomatis
/// Menampilkan halaman DOKU di dalam modal aplikasi tanpa perlu terlempar ke Chrome.
/// Dilengkapi background status synchronization (inquiry real-time) yang otomatis
/// mendeteksi keberhasilan pembayaran dan menutup pop-up seketika transaksi tuntas.
class DokuCheckoutSheet extends StatefulWidget {
  final String paymentUrl;
  final String invoiceNumber;
  final String? trxId;
  final String? planTitle;
  final int? amount;
  final int? regularAmount;
  final String periodLabel;

  const DokuCheckoutSheet({
    super.key,
    required this.paymentUrl,
    required this.invoiceNumber,
    this.trxId,
    this.planTitle,
    this.amount,
    this.regularAmount,
    this.periodLabel = '',
  });

  /// Helper untuk membuka modal secara elegan dari layar manapun
  static Future<bool?> show(
    BuildContext context, {
    required String paymentUrl,
    required String invoiceNumber,
    String? trxId,
    String? planTitle,
    int? amount,
    int? regularAmount,
    String periodLabel = '',
  }) {
    return showAdaptiveSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (context) => DokuCheckoutSheet(
        paymentUrl: paymentUrl,
        invoiceNumber: invoiceNumber,
        trxId: trxId,
        planTitle: planTitle,
        amount: amount,
        regularAmount: regularAmount,
        periodLabel: periodLabel,
      ),
    );
  }

  @override
  State<DokuCheckoutSheet> createState() => _DokuCheckoutSheetState();
}

class _DokuCheckoutSheetState extends State<DokuCheckoutSheet> {
  final SubscriptionService _subService = SubscriptionService();

  InAppWebViewController? _webController;
  Timer? _pollTimer;
  StreamSubscription<QuerySnapshot>? _txSubscription;
  double _loadProgress = 0.0;
  bool _isChecking = false;
  bool _isSuccess = false;
  int _pollAttempts = 0;
  bool _isShowingConfirmDialog = false;
  bool _hasPopped = false;
  final _completion = CheckoutCompletion();
  BuildContext? _confirmationContext;

  @override
  void initState() {
    super.initState();

    // 1. Real-time Firestore Listener: mendeteksi instan saat status berubah jadi 'success' (< 1s)
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (widget.invoiceNumber.isNotEmpty && currentUid != null) {
      _txSubscription = FirebaseFirestore.instance
          .collection(AppConstants.colTransactions)
          .where('uid', isEqualTo: currentUid)
          .where('invoice_number', isEqualTo: widget.invoiceNumber)
          .limit(1)
          .snapshots()
          .listen(
        (snap) {
          if (snap.docs.isNotEmpty) {
            final data = snap.docs.first.data() as Map<String, dynamic>?;
            final status = (data?['status'] ?? '').toString().toLowerCase();
            if (status == 'paid' || status == 'success') {
              _triggerSuccess();
            }
          }
        },
        onError: (_) {
          // Jika query ditolak atau gagal, biarkan fail-safe polling tetap berjalan
        },
      );
    }

    // 2. Active inquiry polling setiap 2 detik sebagai fail-safe
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPaymentStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _txSubscription?.cancel();
    _webController = null;
    super.dispose();
  }

  void _triggerSuccess() async {
    if (_isSuccess || _hasPopped || !mounted) return;
    _pollTimer?.cancel();
    _txSubscription?.cancel();
    setState(() {
      _isSuccess = true;
    });

    // Beri jeda 2.2 detik agar pengguna menikmati animasi sukses
    await Future.delayed(const Duration(milliseconds: 2200));
    await _completion.finish(
      dismissConfirmation: () {
        final dialogContext = _confirmationContext;
        if (dialogContext != null &&
            dialogContext.mounted &&
            ModalRoute.of(dialogContext)?.isCurrent == true) {
          Navigator.of(dialogContext).pop(false);
        }
      },
      closeCheckout: () {
        if (mounted &&
            !_hasPopped &&
            ModalRoute.of(context)?.isCurrent == true) {
          _hasPopped = true;
          Navigator.of(context).pop(true);
        }
      },
    );
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking || _isSuccess || _hasPopped || !mounted) return;
    if (widget.invoiceNumber.isEmpty) return;

    _pollAttempts++;
    // F33: Batas maksimal polling 150 kali (5 menit) agar tidak memboroskan sumber daya
    if (_pollAttempts > 60) {
      _pollTimer?.cancel();
      return;
    }

    _isChecking = true;
    try {
      final res = await _subService.verifyPaymentStatus(
        invoiceNumber: widget.invoiceNumber,
        trxId: widget.trxId,
      );

      if (res['status'] == 'SUCCESS' && res['success'] == true) {
        _triggerSuccess();
      }
    } catch (_) {
      // Polling background gagal sementara, lanjut ke tick berikutnya
    } finally {
      if (mounted) {
        _isChecking = false;
      }
    }
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.tryParse(widget.paymentUrl);
    if (uri == null || !_isAllowedPaymentDestination(uri)) return;
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('[DokuCheckout] Gagal membuka browser eksternal: $e');
    }
  }

  Future<bool> _handleWillPop() async {
    if (_isSuccess || _hasPopped) return false;
    if (_isShowingConfirmDialog) return false;

    _isShowingConfirmDialog = true;
    final confirmationDone = Completer<void>();
    _completion.confirmation = confirmationDone.future;
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          _confirmationContext = ctx;
          return AlertDialog(
            backgroundColor:
                isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
            title: Text(
              Loc.tr('ui_56a2f9f730'),
              style: ScholarlyFonts.outfit(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
            content: Text(
              Loc.tr('ui_85f60bf7af'),
              style: ScholarlyFonts.outfit(
                fontSize: 13,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  Loc.tr('ui_5bcbc797a7'),
                  style: ScholarlyFonts.outfit(
                    color: isDark ? AppTheme.accentDark : AppTheme.accentLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  Loc.tr('close'),
                  style: ScholarlyFonts.outfit(
                    color: OTColors.destructive(isDark),
                  ),
                ),
              ),
            ],
          );
        },
      );

      return !_isSuccess && (confirm ?? false);
    } finally {
      _confirmationContext = null;
      _isShowingConfirmDialog = false;
      confirmationDone.complete();
      _completion.confirmation = null;
    }
  }

  /// OT-F005: Destination allowlist ketat untuk WebView transaksi pembayaran
  bool _isAllowedPaymentDestination(Uri uri) {
    if (uri.scheme != 'https') return false;

    final host = uri.host.toLowerCase();

    // Domain aplikasi OpenTurath
    if (host == 'openturath-ai.web.app' ||
        host == 'openturath.ai' ||
        host.endsWith('.openturath.ai')) {
      return true;
    }

    // Domain resmi payment gateway DOKU & sandbox
    if (host == 'doku.com' ||
        host.endsWith('.doku.com') ||
        host == 'doku.id' ||
        host.endsWith('.doku.id')) {
      return true;
    }

    // Platform checkout resmi GoAkal & Midtrans
    if (host == 'goakal.com' ||
        host.endsWith('.goakal.com') ||
        host == 'midtrans.com' ||
        host.endsWith('.midtrans.com') ||
        host == 'veritrans.co.id' ||
        host.endsWith('.veritrans.co.id')) {
      return true;
    }

    // Partner perbankan & e-wallet resmi untuk pembayaran QRIS / VA / Direct Debit
    if (host.endsWith('.bca.co.id') ||
        host.endsWith('.mandiri.co.id') ||
        host.endsWith('.bri.co.id') ||
        host.endsWith('.bni.co.id') ||
        host.endsWith('.cimbniaga.co.id') ||
        host.endsWith('.permata.co.id') ||
        host.endsWith('.gopay.co.id') ||
        host.endsWith('.shopeepay.co.id') ||
        host.endsWith('.ovo.id') ||
        host.endsWith('.dana.id') ||
        host.endsWith('.linkaja.id')) {
      return true;
    }

    return false;
  }

  static const Set<String> _allowedExternalPaymentSchemes = {
    'gojek',
    'gopay',
    'shopeepay',
    'shopee',
    'ovo',
    'dana',
    'linkaja',
    'bca',
    'bankmandiri',
    'brimo',
    'bnicall',
    'cimbclicks',
  };

  /// Validasi ketat skema eksternal untuk deep-linking e-wallet / perbankan
  bool _isAllowedExternalScheme(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (_allowedExternalPaymentSchemes.contains(scheme)) {
      return true;
    }
    // Tolak mentah-mentah skema berbahaya
    if (scheme == 'javascript' ||
        scheme == 'file' ||
        scheme == 'content' ||
        scheme == 'data' ||
        scheme == 'about') {
      return false;
    }
    // Izinkan skema intent hanya jika spesifik untuk pembayaran perbankan/e-wallet
    if (scheme == 'intent') {
      final str = uri.toString().toLowerCase();
      return str.contains('scheme=gojek') ||
          str.contains('scheme=shopeepay') ||
          str.contains('scheme=ovo') ||
          str.contains('scheme=dana') ||
          str.contains('scheme=linkaja') ||
          str.contains('scheme=bca') ||
          str.contains('scheme=mandiri') ||
          str.contains('scheme=bri') ||
          str.contains('scheme=bni');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => DesktopWebViewGate(
        builder: _buildContent,
        externalUrl: _isAllowedPaymentDestination(Uri.parse(widget.paymentUrl))
            ? Uri.parse(widget.paymentUrl)
            : null,
        onClose: () => Navigator.of(context).pop(false),
      );

  Widget _buildContent(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleWillPop();
        if (shouldPop && context.mounted && !_hasPopped) {
          _hasPopped = true;
          Navigator.of(context).pop(false);
        }
      },
      child: Container(
        height: AppPlatform.isDesktop ? double.infinity : screenHeight * 0.92,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: AppPlatform.isDesktop
              ? BorderRadius.circular(AppTheme.radiusCard)
              : const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusCard)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 100 : 40),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          clipBehavior: AppPlatform.isDesktop ? Clip.none : Clip.antiAlias,
          borderRadius: AppPlatform.isDesktop
              ? BorderRadius.circular(AppTheme.radiusCard)
              : const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusCard)),
          child: Stack(
            children: [
              // ── 1. Main Sheet Content (Header + WebView) ──
              Column(
                children: [
                  // Top Drag Handle & Title Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      border:
                          Border(bottom: BorderSide(color: border, width: 1)),
                    ),
                    child: Column(
                      children: [
                        // Drag Indicator
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: border,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusPill),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(30),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusXS),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 18,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.planTitle != null &&
                                            widget.planTitle!.isNotEmpty
                                        ? widget.planTitle!
                                        : Loc.tr('ui_f0874594eb'),
                                    style: ScholarlyFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.amount != null &&
                                      widget.regularAmount != null)
                                    PromoPrice(
                                        amount: widget.amount!,
                                        regularAmount: widget.regularAmount!,
                                        period: widget.periodLabel,
                                        compact: true),
                                  if (widget.invoiceNumber.isNotEmpty)
                                    Text(
                                      widget.invoiceNumber,
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                        color: textSecondary,
                                      ),
                                    )
                                  else if (widget.amount != null &&
                                      widget.amount! > 0)
                                    Text(
                                      'Rp ${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                        color: textSecondary,
                                      ),
                                    )
                                  else
                                    Text(
                                      Loc.tr('ui_9218f901c4'),
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 12,
                                        letterSpacing: 0.3,
                                        color: textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Tombol Buka di Browser Luar (Sangat cepat & lancar di Desktop)
                            IconButton(
                              onPressed: _openInExternalBrowser,
                              icon: Icon(Icons.open_in_browser_rounded,
                                  size: 20, color: textSecondary),
                              tooltip: 'Buka di Browser Eksternal',
                            ),
                            // Tombol Cek Manual / Refresh
                            IconButton(
                              onPressed: _isChecking
                                  ? null
                                  : () {
                                      _webController?.reload();
                                      _checkPaymentStatus();
                                    },
                              icon: _isChecking
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Icon(Icons.sync_rounded,
                                      size: 20, color: textSecondary),
                              tooltip: Loc.tr('ui_1c93ce4af4'),
                            ),
                            // Close Button
                            IconButton(
                              onPressed: () async {
                                final shouldPop = await _handleWillPop();
                                if (shouldPop &&
                                    context.mounted &&
                                    !_hasPopped) {
                                  _hasPopped = true;
                                  Navigator.of(context).pop(false);
                                }
                              },
                              icon: Icon(Icons.close_rounded,
                                  size: 22, color: textSecondary),
                              tooltip: Loc.tr('close'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Linear Progress Bar saat memuat halaman WebView
                  if (_loadProgress < 1.0)
                    LinearProgressIndicator(
                      value: _loadProgress,
                      backgroundColor: Colors.transparent,
                      color: accent,
                      minHeight: 2.5,
                    ),

                  // Desktop helper banner: Info & Quick Browser Button
                  if (AppPlatform.isDesktop)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        border: Border(
                            bottom: BorderSide(color: border, width: 1)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 16,
                            color: accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lebih cepat & lancar? Anda dapat menyelesaikan pembayaran di browser.',
                              style: ScholarlyFonts.outfit(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _openInExternalBrowser,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: accent.withAlpha(isDark ? 50 : 30),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: accent.withAlpha(80), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Buka di Browser',
                                    style: ScholarlyFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: accent,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.launch_rounded,
                                    size: 13,
                                    color: accent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // WebView DOKU / Midtrans
                  Expanded(
                    child: InAppWebView(
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      webViewEnvironment: DesktopWebViewRuntime.environment,
                      initialUrlRequest:
                          URLRequest(url: WebUri(widget.paymentUrl)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        domStorageEnabled: true,
                        databaseEnabled: true,
                        sharedCookiesEnabled: true,
                        thirdPartyCookiesEnabled: true,
                        cacheEnabled: true,
                        clearCache: false,
                        clearSessionCache: false,
                        useHybridComposition: false,
                        disableVerticalScroll: false,
                        disableHorizontalScroll: false,
                        supportZoom: false,
                        builtInZoomControls: false,
                        displayZoomControls: false,
                        mixedContentMode:
                            MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                        allowFileAccess: false,
                        allowContentAccess: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                        supportMultipleWindows: true,
                        forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                        transparentBackground: false,
                        userAgent: AppPlatform.isDesktop
                            ? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
                            : AppConstants.chromeMobileUserAgent,
                      ),
                      onWebViewCreated: (controller) {
                        _webController = controller;
                      },
                      onCreateWindow: (controller, createWindowAction) async {
                        final targetUrl = createWindowAction.request.url;
                        if (targetUrl != null) {
                          await controller.loadUrl(
                            urlRequest: URLRequest(url: targetUrl),
                          );
                          return true;
                        }
                        return false;
                      },
                      onProgressChanged: (controller, progress) {
                        if (mounted) {
                          setState(() {
                            _loadProgress = progress / 100.0;
                          });
                        }
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        final webUri = navigationAction.request.url;
                        if (webUri == null) {
                          return NavigationActionPolicy.CANCEL;
                        }

                        final uri = Uri.tryParse(webUri.toString());
                        if (uri == null) return NavigationActionPolicy.CANCEL;

                        // Deep links untuk aplikasi perbankan atau e-wallet (GoPay, ShopeePay, dsb.)
                        if (uri.scheme != 'http' && uri.scheme != 'https') {
                          if (_isAllowedExternalScheme(uri)) {
                            try {
                              await launchUrl(uri,
                                  mode: AppPlatform.isDesktop
                                      ? LaunchMode.externalApplication
                                      : LaunchMode
                                          .externalNonBrowserApplication);
                            } catch (e) {
                              debugPrint(
                                  '[DokuCheckout] Gagal membuka external payment app: $e');
                            }
                          } else {
                            debugPrint(
                                '[DokuCheckout] External scheme ditolak karena tidak masuk allowlist: ${uri.scheme}');
                          }
                          return NavigationActionPolicy.CANCEL;
                        }

                        if (!_isAllowedPaymentDestination(uri)) {
                          debugPrint(
                              '[DokuCheckout] Navigation to untrusted destination rejected: $webUri');
                          return NavigationActionPolicy.CANCEL;
                        }

                        final urlStr = uri.toString().toLowerCase();

                        // Intersep jika gateway mengarah ke callback URL sukses
                        if (urlStr.contains('openturath-ai.web.app') ||
                            urlStr.contains('callback') ||
                            urlStr.contains('finish') ||
                            urlStr.contains('checkout-success') ||
                            urlStr.contains('success')) {
                          _checkPaymentStatus();
                          return NavigationActionPolicy.ALLOW;
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        if (mounted) {
                          setState(() => _loadProgress = 1.0);
                        }

                        final urlStr = url?.toString().toLowerCase() ?? '';
                        if (urlStr.contains('openturath-ai.web.app') ||
                            urlStr.contains('checkout-link') ||
                            urlStr.contains('success')) {
                          _checkPaymentStatus();
                        }

                        // Pastikan overflow scroll di body/html aktif
                        try {
                          await controller.evaluateJavascript(source: """
                            (function() {
                              document.documentElement.style.overflow = 'auto';
                              document.body.style.overflow = 'auto';
                            })();
                          """);
                        } catch (_) {}

                        // Deteksi instan jika DOM DOKU menampilkan halaman Payment Successful
                        try {
                          final isPaidDom =
                              await controller.evaluateJavascript(source: """
                            (function() {
                              var text = (document.body ? document.body.innerText : '') || '';
                              if (text.includes('Payment Successful') || 
                                  text.includes('Pembayaran Berhasil') || 
                                  text.includes('Berhasil!')) {
                                return true;
                              }
                              return false;
                            })();
                          """);
                          if (isPaidDom == true) {
                            _checkPaymentStatus();
                          }
                        } catch (_) {}
                      },
                    ),
                  ),
                ],
              ),

              // ── 2. Celebratory Success Overlay ──
              if (_isSuccess)
                _CelebratorySuccessView(
                  surfaceColor: surfaceColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  accent: accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CelebratorySuccessView extends StatelessWidget {
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const _CelebratorySuccessView({
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            color: surfaceColor,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Spring bounce scale for the checkmark badge
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 750),
                      curve: Curves.elasticOut,
                      builder: (context, scale, _) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.16),
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 50,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    // "Alhamdulillah!" with fade-up
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - value) * 16),
                            child: Text(
                              Loc.tr('ui_28654608b2'),
                              style: ScholarlyFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                letterSpacing: -0.5,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // "Pembayaran Berhasil Diverifikasi"
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - value) * 14),
                            child: Text(
                              Loc.tr('ui_109055bfcd'),
                              style: ScholarlyFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Description
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, (1.0 - value) * 12),
                            child: Text(
                              Loc.tr('ui_1408872bee'),
                              textAlign: TextAlign.center,
                              style: ScholarlyFonts.outfit(
                                fontSize: 13,
                                color: textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // Unified AppLoader
                    AppLoader(color: accent, dotSize: 8, spacing: 4),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
