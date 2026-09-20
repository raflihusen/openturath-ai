import '../core/l10n/app_dictionary.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../core/checkout_completion.dart';
import '../core/constants.dart';
import '../core/design/ot_colors.dart';
import '../core/payment_status.dart';
import '../services/subscription_service.dart';
import 'editorial.dart';

/// Checkout completion reports payment only. The caller must refresh the
/// authenticated server entitlement before presenting access as active.
class DokuCheckoutSheet extends StatefulWidget {
  final String paymentUrl;
  final String invoiceNumber;
  final String? trxId;
  final String? planTitle;
  final int? amount;
  const DokuCheckoutSheet({super.key, required this.paymentUrl,
    required this.invoiceNumber, this.trxId, this.planTitle, this.amount});

  static Future<bool?> show(BuildContext context, {required String paymentUrl,
    required String invoiceNumber, String? trxId, String? planTitle, int? amount}) =>
    showModalBottomSheet<bool>(context: context, isScrollControlled: true,
      backgroundColor: Colors.transparent, enableDrag: false, isDismissible: false,
      builder: (context) => DokuCheckoutSheet(paymentUrl: paymentUrl,
        invoiceNumber: invoiceNumber, trxId: trxId, planTitle: planTitle, amount: amount));

  @override
  State<DokuCheckoutSheet> createState() => _DokuCheckoutSheetState();
}

class _DokuCheckoutSheetState extends State<DokuCheckoutSheet> with WidgetsBindingObserver {
  final SubscriptionService _service = SubscriptionService();
  final CheckoutCompletion _completion = CheckoutCompletion();
  InAppWebViewController? _webController;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _transactions;
  StreamSubscription<User?>? _authChanges;
  Timer? _pollTimer;
  late final String? _ownerUid;
  late final bool _validInitialUrl;
  bool _ownerInvalid = false;
  bool _checking = false;
  bool _paid = false;
  bool _popped = false;
  bool _showingConfirmation = false;
  bool _foreground = true;
  int _automaticAttempts = 0;
  int _webGeneration = 0;
  double _progress = 0;
  String? _pageError;
  String _statusMessage = 'membership.awaiting_payment';
  BuildContext? _confirmationContext;
  bool get _ownsCheckout => !_ownerInvalid && _ownerUid != null &&
      FirebaseAuth.instance.currentUser?.uid == _ownerUid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownerUid = FirebaseAuth.instance.currentUser?.uid;
    _validInitialUrl = isAllowedPaymentUrl(widget.paymentUrl, initial: true);
    if (!_validInitialUrl) _pageError = 'membership.payment_link_invalid';
    if (_ownerUid == null) {
      _ownerInvalid = true;
      _pageError = 'membership.login_checkout';
      return;
    }
    _authChanges = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user?.uid != _ownerUid) _invalidateOwner();
    });
    if (!_validInitialUrl || widget.invoiceNumber.trim().isEmpty) return;
    _transactions = FirebaseFirestore.instance.collection(AppConstants.colTransactions)
      .where('uid', isEqualTo: _ownerUid)
      .where('invoice_number', isEqualTo: widget.invoiceNumber.trim()).limit(1)
      .snapshots(includeMetadataChanges: true).listen((snapshot) {
        if (!_ownsCheckout || !mounted || snapshot.metadata.isFromCache || snapshot.docs.isEmpty) return;
        final data = snapshot.docs.first.data();
        if (data['uid'] != _ownerUid || data['invoice_number'] != widget.invoiceNumber.trim()) return;
        if (isConfirmedPayment(data)) _confirmPayment();
      }, onError: (_) { /* Server inquiry remains available. */ });
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!_ownsCheckout || !_validInitialUrl || !_foreground || _paid ||
        widget.invoiceNumber.trim().isEmpty || _automaticAttempts >= 60) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_checking) return;
      if (_automaticAttempts >= 60) {
        _pollTimer?.cancel();
        if (mounted) setState(() => _statusMessage = 'membership.polling_paused');
        return;
      }
      _automaticAttempts++;
      _checkStatus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) { _startPolling(); } else { _pollTimer?.cancel(); }
  }

  Future<void> _invalidateOwner() async {
    if (_ownerInvalid || !mounted) return;
    _pollTimer?.cancel();
    _transactions?.cancel();
    final controller = _webController;
    _webController = null;
    setState(() { _ownerInvalid = true; _pageError = 'membership.account_changed'; });
    try { await controller?.stopLoading(); } catch (_) {}
    await _finish(false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _transactions?.cancel();
    _authChanges?.cancel();
    _stopWebLoading();
    _webController = null;
    super.dispose();
  }

  Future<void> _stopWebLoading() async {
    try { await _webController?.stopLoading(); } catch (_) {}
  }

  void _confirmPayment() {
    if (!_ownsCheckout || _paid || _popped || !mounted) return;
    _pollTimer?.cancel();
    _transactions?.cancel();
    _stopWebLoading();
    setState(() { _paid = true; _checking = false; });
    final dialog = _confirmationContext;
    if (dialog != null && dialog.mounted && ModalRoute.of(dialog)?.isCurrent == true) {
      Navigator.of(dialog).pop(false);
    }
  }

  Future<void> _checkStatus() async {
    if (_checking || _paid || _popped || !mounted || !_ownsCheckout ||
        widget.invoiceNumber.trim().isEmpty) return;
    setState(() => _checking = true);
    try {
      final response = await _service.verifyPaymentStatus(
        invoiceNumber: widget.invoiceNumber, trxId: widget.trxId);
      if (!mounted || !_ownsCheckout || _popped) return;
      if (isConfirmedPayment(response)) {
        _confirmPayment();
      } else {
        setState(() => _statusMessage = isFailedPayment(response)
          ? 'membership.payment_failed'
          : paymentStatus(response['status']) == 'ERROR'
            ? 'membership.status_connection_failed'
            : 'membership.payment_unconfirmed');
      }
    } catch (_) {
      if (mounted && _ownsCheckout) setState(() => _statusMessage = 'membership.status_retry');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _finish(bool result) => _completion.finish(
    dismissConfirmation: () {
      final dialog = _confirmationContext;
      if (dialog != null && dialog.mounted && ModalRoute.of(dialog)?.isCurrent == true) Navigator.of(dialog).pop(false);
    },
    closeCheckout: () {
      if (mounted && !_popped && ModalRoute.of(context)?.isCurrent == true) {
        _popped = true;
        Navigator.of(context).pop(result && _paid && _ownsCheckout);
      }
    },
  );

  Future<void> _requestClose() async {
    if (_popped || _showingConfirmation) return;
    if (_paid) { await _finish(true); return; }
    if (!_ownsCheckout || !_validInitialUrl) { await _finish(false); return; }
    _showingConfirmation = true;
    final done = Completer<void>();
    _completion.confirmation = done.future;
    bool close = false;
    try {
      close = await showDialog<bool>(context: context, builder: (context) {
        _confirmationContext = context;
        return AlertDialog(title: Text(context.tr('membership.close_checkout_question')),
          content: Text(context.tr('membership.close_checkout_explanation')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('membership.continue'))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(context.tr('membership.close'))),
          ]);
      }) ?? false;
    } finally {
      _confirmationContext = null;
      _showingConfirmation = false;
      done.complete();
      _completion.confirmation = null;
    }
    if (close && mounted && !_paid) await _finish(false);
  }

  void _blockDestination() {
    if (!mounted) return;
    setState(() => _statusMessage = 'membership.unsupported_destination');
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(canPop: false,
      onPopInvokedWithResult: (didPop, result) { if (!didPop) _requestClose(); },
      child: Container(height: MediaQuery.sizeOf(context).height * .92,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: OTColors.canvas(dark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: SafeArea(top: false, child: _paid ? _paidView() : Column(children: [
          Padding(padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 8, 12), child: Row(children: [
            const Icon(Icons.lock_outline_rounded, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.planTitle?.isNotEmpty == true ? widget.planTitle! : context.tr('membership.payment'),
                style: Theme.of(context).textTheme.titleMedium),
              if (widget.invoiceNumber.isNotEmpty) Text(widget.invoiceNumber, textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.bodySmall),
            ])),
            IconButton(tooltip: context.tr('membership.close_payment'), onPressed: _requestClose,
              icon: const Icon(Icons.close_rounded)),
          ])),
          const Divider(height: 1),
          if (_progress < 1 && _pageError == null)
            LinearProgressIndicator(value: _progress, minHeight: 1),
          Expanded(child: _pageError != null || !_ownsCheckout
            ? SingleChildScrollView(child: EditorialEmptyState(title: context.tr('membership.page_unavailable'),
                description: _pageError == null ? null : context.tr(_pageError!),
                action: _validInitialUrl && _ownsCheckout ? EditorialButton(label: context.tr('membership.reload'), secondary: true,
                  onPressed: () => setState(() { _pageError = null; _progress = 0; _webGeneration++; })) : null))
            : InAppWebView(key: ValueKey(_webGeneration),
                initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
                initialSettings: InAppWebViewSettings(javaScriptEnabled: true, domStorageEnabled: true,
                  incognito: true, cacheEnabled: false, sharedCookiesEnabled: false,
                  useShouldOverrideUrlLoading: true, mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
                  allowFileAccess: false, allowContentAccess: false,
                  javaScriptCanOpenWindowsAutomatically: false, supportMultipleWindows: false,
                  supportZoom: true, builtInZoomControls: true, displayZoomControls: false),
                onWebViewCreated: (controller) => _webController = controller,
                onCreateWindow: (controller, request) async => false,
                onProgressChanged: (controller, progress) {
                  if (mounted && _ownsCheckout) setState(() => _progress = progress / 100);
                },
                shouldOverrideUrlLoading: (controller, action) async {
                  final url = action.request.url?.toString();
                  if (!_ownsCheckout || url == null || !isAllowedPaymentUrl(url)) {
                    _blockDestination();
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStart: (controller, url) async {
                  if (!_ownsCheckout || url == null || !isAllowedPaymentUrl(url.toString())) {
                    await controller.stopLoading();
                    _blockDestination();
                  }
                },
                onLoadStop: (controller, url) {
                  if (mounted && _ownsCheckout) {
                    setState(() => _progress = 1);
                    if (url != null && isAllowedPaymentUrl(url.toString()) &&
                        const {
                          'openturath.ai', 'www.openturath.ai',
                          'openturath.id', 'www.openturath.id',
                          'openturath-ai.web.app', 'openturath.web.app',
                        }.contains(url.host)) {
                      _checkStatus();
                    }
                  }
                },
                onReceivedError: (controller, request, error) {
                  if (mounted && request.isForMainFrame == true) {
                    setState(() => _pageError = 'membership.payment_load_failed');
                  }
                },
              )),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Semantics(liveRegion: true, child: Text(widget.invoiceNumber.trim().isEmpty
              ? context.tr('membership.goakal_after_payment') : context.tr(_statusMessage),
              style: Theme.of(context).textTheme.bodySmall)),
            if (widget.invoiceNumber.trim().isNotEmpty && _ownsCheckout && _validInitialUrl) ...[
              const SizedBox(height: 12),
              EditorialButton(label: context.tr('membership.check_status'), secondary: true, busy: _checking, onPressed: _checkStatus),
            ],
          ])),
        ])),
      ),
    );
  }

  Widget _paidView() => Center(child: SingleChildScrollView(padding: const EdgeInsets.all(32),
    child: EditorialReveal(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle_outline_rounded, size: 44),
      const SizedBox(height: 24),
      Text(context.tr('membership.payment_verified'), textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      Text(context.tr('membership.access_after_continue'), textAlign: TextAlign.center),
      const SizedBox(height: 28),
      EditorialButton(label: context.tr('membership.continue'), onPressed: () => _finish(true)),
    ])),
  ));
}
