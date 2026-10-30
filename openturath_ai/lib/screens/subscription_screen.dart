import 'dart:async';
import '../widgets/app_loader.dart';
import '../widgets/adaptive_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../widgets/ot_motion_widgets.dart';
import '../core/design/ot_motion.dart';
import '../core/scholarly_fonts.dart';
import '../core/app_copy.dart';
import '../widgets/payment_success_dialog.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_expressive.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/subscription_service.dart';
import '../widgets/legal_document_sheet.dart';
import '../widgets/payment_checkout_sheet.dart';
import '../widgets/promo_price.dart';
import '../widgets/redeem_code_sheet.dart';
import '../core/app_platform.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';

import 'package:openturath_ai/core/design/ot_radius.dart';
import 'package:openturath_ai/core/design/ot_buttons.dart';

/// Penawaran perdana. Hak akses tetap diputuskan oleh backend yang terverifikasi.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _service = SubscriptionService();
  final _agentService = AgentService();
  List<AgentModel>? _loadedAgents;
  String _selectedAgentId = 'fiqh_syafii';
  // Mulai dari 1 bulan: harga terendah dulu, supaya tidak terasa menekan.
  int _periodIndex = 0;
  bool _pricingReady = false;
  bool _processing = false;
  bool _initialized = false;
  String? _checkoutError;
  String? _checkoutAgentId;
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => LegalDocumentSheet.showTermsOfService(context);
  late final TapGestureRecognizer _refundTap = TapGestureRecognizer()
    ..onTap = () => LegalDocumentSheet.showRefundPolicy(context);

  @override
  void dispose() {
    _termsTap.dispose();
    _refundTap.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Harga tidak ditampilkan sebelum sinkronisasi selesai, supaya angka
    // bawaan tidak sempat berganti di depan pengguna.
    ProductPricingService.syncPricing(forceRefresh: true).whenComplete(() {
      if (mounted) setState(() => _pricingReady = true);
    });
    _agentService.getAgents().then((agents) {
      if (mounted) setState(() => _loadedAgents = agents);
    }).catchError((_) {});
  }

  String _checkoutErrorMessage(FirebaseFunctionsException error) {
    switch (error.code.toLowerCase()) {
      case 'unauthenticated':
        return Loc.tr('checkoutAuthExpired');
      case 'deadline-exceeded':
      case 'unavailable':
        return Loc.tr('checkoutServiceUnavailable');
      case 'failed-precondition':
        return Loc.tr('checkoutPlanUnavailable');
      case 'permission-denied':
        return Loc.tr('checkoutAccountDenied');
      case 'invalid-argument':
        return Loc.tr('checkoutSelectionInvalid');
      default:
        return Loc.tr('checkoutError');
    }
  }

  Widget _checkoutNotice(String agentId, {Color? ink}) {
    final message = _checkoutAgentId == agentId ? _checkoutError : null;
    if (message == null) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = ink ?? OTColors.textPrimary(dark);
    return Padding(
      padding: const EdgeInsets.only(top: OTSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(OTSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(OTRadius.input),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: color),
            const SizedBox(width: OTSpacing.md),
            Expanded(
              child: Text(message,
                  style:
                      OTTypography.caption(color: color).copyWith(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  /// Kalimat pembuka yang menyebut hasil, dengan nama depan pengguna bila ada.
  String _headline() {
    var name = '';
    try {
      name = (AuthService().cachedCurrentUser?.name ??
              AuthService().currentUser?.displayName ??
              '')
          .trim();
    } catch (_) {
      // Tanpa sesi (atau di pratinjau), judul tetap tampil tanpa nama.
    }
    final first = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
    return first.isEmpty
        ? Loc.tr('subHeadline')
        : Loc.tr('subHeadlineNamed', [first]);
  }

  /// Pengguna saat ini bila ada; tanpa sesi (atau di pratinjau) kosong.
  bool _hasAccess(String agentId) {
    try {
      return AuthService().cachedCurrentUser?.hasAccessToAgent(agentId) ??
          false;
    } catch (_) {
      return false;
    }
  }

  List<AgentModel> get _specialists {
    final list = _loadedAgents ?? AgentService.getActiveAgentsSync();
    return list
        .where((a) =>
            a.kind == CorpusKind.discipline &&
            a.isActive &&
            !a.isComingSoon &&
            a.id != 'fiqh_tahawwulat')
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final agent = args is Map ? args['agent'] : null;
    if (agent is AgentModel && _specialists.any((a) => a.id == agent.id)) {
      _selectedAgentId = agent.id;
    } else if (_specialists.isNotEmpty) {
      _selectedAgentId = _specialists.first.id;
    }
  }

  Future<void> _checkout(AgentModel agent, SubscriptionOffer offer) async {
    if (_processing) return;
    final user = AuthService().currentUser;
    if (user == null || user.isAnonymous) {
      setState(() {
        _checkoutAgentId = agent.id;
        _checkoutError = Loc.tr('signInRequired');
      });
      return;
    }
    setState(() {
      _processing = true;
      _checkoutError = null;
      _checkoutAgentId = agent.id;
    });
    try {
      final title = '${agent.title} · ${offer.title}';
      final result = await _service.createPayment(
          uid: user.uid,
          agentId: agent.id,
          plan: offer.plan,
          planTitle: title,
          amount: offer.amount,
          name: user.displayName ??
              user.email?.split('@').first ??
              'Pengguna OpenTurath',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '');
      if (!mounted) return;
      // An old backend or stale quote must never open a differently priced checkout.
      if (result['amount'] != offer.amount ||
          (result['pricingRevision'] != ProductPricing.revision &&
              result['pricingRevision'] != ProductPricing.defaultRevision)) {
        await ProductPricingService.refreshCheckoutOffer(
          agentId: agent.id,
          plan: offer.plan,
          details: {...result, 'reason': 'price_changed', 'agentId': agent.id, 'plan': offer.plan},
        );
        if (mounted) setState(() => _checkoutError = Loc.tr('priceChangedReview'));
        return;
      }
      final paymentUrl = result['redirectUrl'];
      final invoice = result['invoiceNumber'];
      if (paymentUrl is! String ||
          Uri.tryParse(paymentUrl)?.scheme != 'https' ||
          invoice is! String ||
          invoice.isEmpty) {
        throw const FormatException('Invalid checkout response');
      }
      final paid = await PaymentCheckoutSheet.show(context,
          paymentUrl: paymentUrl,
          invoiceNumber: invoice,
          trxId: result['trxId'] as String?,
          planTitle: title,
          amount: offer.amount,
          regularAmount: offer.regularAmount,
          periodLabel: offer.period);
      if (mounted && paid == true) {
        await PaymentSuccessDialog.show(context,
            plan: title, invoice: invoice, amount: offer.amount, agent: agent);
      }
    } on FirebaseFunctionsException catch (error, stack) {
      TelemetryService.instance.reportError(error, stack, context: 'checkout');
      final details = error.details;
      if (details is Map && details['reason'] == 'price_changed') {
        await ProductPricingService.refreshCheckoutOffer(
          agentId: agent.id, plan: offer.plan, details: details,
        );
        if (mounted) setState(() => _checkoutError = Loc.tr('priceChangedReview'));
        return;
      }
      if (mounted) {
        setState(() => _checkoutError = _checkoutErrorMessage(error));
      }
    } on FormatException {
      if (mounted) {
        setState(() => _checkoutError = Loc.tr('checkoutLinkUnavailable'));
      }
    } catch (error, stack) {
      TelemetryService.instance.reportError(error, stack, context: 'checkout');
      if (mounted) setState(() => _checkoutError = Loc.tr('checkoutError'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  /// Kartu paket: satu susunan untuk kedua paket supaya sejajar.
  /// Paket utama berupa blok terbalik rata (tanpa pola dan gradasi), paket
  /// satu bidang berupa kartu bergaris tipis, seperti di web.
  Widget _planCard({
    required bool inverse,
    required bool wide,
    required String label,
    required String title,
    required String description,
    Widget? field,
    required SubscriptionOffer price,
    required List<SubscriptionOffer> offers,
    required List<String> benefits,
    required VoidCallback onCheckout,
    required String agentId,
    bool active = false,
    bool exclusive = false,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Paket utama: terbalik (hitam di atas terang) di mode terang. Di mode
    // gelap tetap hitam, tidak putih yang menyilaukan; ia dibedakan oleh
    // garis tepi terang dan kilau lembut dari sudut kiri atas.
    final darkFeatured = inverse && dark;
    final fg = darkFeatured
        ? OTColors.textPrimary(dark)
        : inverse
            ? OTColors.onInverted(dark)
            : OTColors.textPrimary(dark);
    final sub = darkFeatured
        ? OTColors.textSecondary(dark)
        : inverse
            ? OTColors.onInvertedMuted(dark)
            : OTColors.textSecondary(dark);
    final line = inverse ? fg.withValues(alpha: 0.18) : OTColors.border(dark);
    final pad = wide ? OTSpacing.xxl : OTSpacing.xl;
    final ar = Loc.isArabic;
    final titleStyle = (ar
            ? OTTypography.arabicDisplay(color: fg)
            : OTTypography.editorialHero(color: fg))
        .copyWith(fontSize: wide ? OTFontSize.s36 : OTFontSize.s26);

    final monthly = offers.first.amount;
    final saving = price.months <= 1
        ? 0
        : ((monthly * price.months - price.amount) *
                100 /
                (monthly * price.months))
            .round();
    final perMonth = price.months > 1
        ? Loc.tr('monthlyEquivalent', [
            ProductPricing.rupiah(
                ((price.amount / price.months) / 1000).round() * 1000)
          ])
        : '';
    // Harga efektif per hari: 12 bulan dihitung 365 hari, selebihnya 30 hari
    // per bulan, dibulatkan ke ratusan terdekat. Ditampilkan sebagai "sekitar".
    final days = price.months >= 12 ? 365 : price.months * 30;
    final perDay = Loc.tr('perDayEquivalent',
        [ProductPricing.rupiah(((price.amount / days) / 100).round() * 100)]);

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: darkFeatured
            ? OTColors.canvas(dark)
            : inverse
                ? OTColors.inverted(dark)
                : OTColors.surface(dark),
        gradient: darkFeatured
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fg.withValues(alpha: 0.12), fg.withValues(alpha: 0)],
                stops: const [0, 0.55],
              )
            : null,
        borderRadius: BorderRadius.circular(OTRadius.hero),
        border: darkFeatured
            ? Border.all(color: fg.withValues(alpha: 0.85), width: 1.5)
            : inverse
                ? null
                : Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: OTSpacing.sm,
            runSpacing: OTSpacing.sm,
            children: [
              _pill(label, fg, filled: exclusive, icon: exclusive),
              if (active) _pill(Loc.tr('planActive'), fg, filled: true),
            ],
          ),
          const SizedBox(height: OTSpacing.lg),
          Text(title, style: titleStyle),
          const SizedBox(height: OTSpacing.md),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: wide ? 48 : 0),
            child: Text(description,
                style: OTTypography.body(color: sub).copyWith(height: 1.5)),
          ),
          if (field != null) ...[
            const SizedBox(height: OTSpacing.xl),
            field,
          ],
          // Berdampingan: harga, manfaat, dan tombol kedua kartu sejajar di
          // bawah, berapa pun tinggi bagian atas.
          if (wide) const Spacer() else const SizedBox(height: OTSpacing.xl),
          if (wide) const SizedBox(height: OTSpacing.xl),
          if (!_pricingReady)
            _priceSkeleton(sub)
          else
            AnimatedSwitcher(
              duration: OTMotion.normal,
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                      .animate(animation),
                  child: child,
                ),
              ),
              layoutBuilder: (current, previous) => Stack(
                alignment: AlignmentDirectional.topStart,
                children: [...previous, if (current != null) current],
              ),
              child: PromoPrice(
                key: ValueKey('$agentId-${price.amount}'),
                amount: price.amount,
                regularAmount: price.regularAmount,
                period: price.period,
                display: true,
                inlineSaving: true,
                foregroundColor: fg,
                secondaryColor: sub,
              ),
            ),
          const SizedBox(height: OTSpacing.sm),
          if (_pricingReady)
            Wrap(
              spacing: OTSpacing.sm,
              runSpacing: OTSpacing.xs,
              children: [
                Text(perDay, style: OTTypography.captionMedium(color: fg)),
                if (perMonth.isNotEmpty)
                  Text(perMonth, style: OTTypography.caption(color: sub)),
                if (saving >= 5)
                  Text(Loc.tr('saving', ['$saving']),
                      style: OTTypography.captionMedium(color: fg)),
              ],
            ),
          const SizedBox(height: OTSpacing.base),
          Divider(color: line, height: 1),
          const SizedBox(height: OTSpacing.lg),
          for (final benefit in benefits) _benefitRow(benefit, fg),
          const SizedBox(height: OTSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: (_processing || !_pricingReady) ? null : onCheckout,
              style: inverse && !dark ? OTButtons.onInverse(dark) : null,
              child: Text(Loc.tr(active ? 'planRenew' : 'planContinue')),
            ),
          ),
          // Jaminan tepat di bawah tombol, tempat keraguan biasanya muncul.
          Padding(
            padding: const EdgeInsets.only(top: OTSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: sub),
                const SizedBox(width: OTSpacing.xs),
                Flexible(
                  child: Text(Loc.tr('planTrustNote'),
                      textAlign: TextAlign.center,
                      style: OTTypography.caption(color: sub)),
                ),
              ],
            ),
          ),
          _checkoutNotice(agentId, ink: fg),
        ],
      ),
    );
  }

  /// Pengganti harga selama sinkronisasi: dua batang tenang.
  Widget _priceSkeleton(Color color) {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: OTRadius.chipBorder,
          ),
        );
    return Semantics(
      label: Loc.tr('checkoutPleaseWait'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(96, 12),
          const SizedBox(height: OTSpacing.md),
          bar(220, 36),
        ],
      ),
    );
  }

  /// Kapsul label, sama dengan label bagian di web. [filled] untuk penanda
  /// yang lebih tegas (eksklusif, aktif).
  Widget _pill(String text, Color color,
          {bool filled = false, bool icon = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.base, vertical: OTSpacing.xs),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.14) : null,
          borderRadius: OTRadius.chipBorder,
          border:
              Border.all(color: color.withValues(alpha: filled ? 0.0 : 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon) ...[
              Icon(Icons.workspace_premium_outlined, size: 14, color: color),
              const SizedBox(width: OTSpacing.xs),
            ],
            Flexible(
              child: Text(text.toUpperCase(),
                  style: OTTypography.metadataTag(color: color)),
            ),
          ],
        ),
      );

  /// Bidang ilmu: baris kapsul. Dapat diketuk bila ada lebih dari satu bidang.
  Widget _fieldRow({
    required String label,
    required String name,
    required bool inverse,
    VoidCallback? onTap,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final onFeaturedDark = inverse && dark;
    final fg = inverse && !onFeaturedDark
        ? OTColors.onInverted(dark)
        : OTColors.textPrimary(dark);
    final sub = inverse && !onFeaturedDark
        ? OTColors.onInvertedMuted(dark)
        : OTColors.textSecondary(dark);
    return Material(
      color: inverse ? fg.withValues(alpha: 0.1) : OTColors.surfaceSubtle(dark),
      borderRadius: BorderRadius.circular(OTRadius.input),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OTRadius.input),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
              OTSpacing.base, OTSpacing.md, OTSpacing.md, OTSpacing.md),
          child: Builder(builder: (context) {
            // Satu baris bila muat; menumpuk di kolom sempit atau huruf besar.
            final scale = MediaQuery.textScalerOf(context).scale(1);
            final stacked =
                MediaQuery.sizeOf(context).width < 400 || scale > 1.3;
            final nameText = Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: stacked ? TextAlign.start : TextAlign.end,
                style: OTTypography.bodyMedium(color: fg));
            final chevron = onTap != null
                ? Icon(Icons.unfold_more_rounded, size: 20, color: sub)
                : null;
            if (stacked) {
              return Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: OTTypography.caption(color: sub)),
                      nameText,
                    ],
                  ),
                ),
                if (chevron != null) chevron,
              ]);
            }
            return Row(children: [
              Text(label, style: OTTypography.caption(color: sub)),
              const SizedBox(width: OTSpacing.md),
              Expanded(child: nameText),
              if (chevron != null) ...[
                const SizedBox(width: OTSpacing.xs),
                chevron,
              ],
            ]);
          }),
        ),
      ),
    );
  }

  /// Persetujuan sebelum membayar: tautan ke Ketentuan Layanan dan kebijakan
  /// pembayaran, supaya pengguna tahu syaratnya sebelum menekan tombol.
  Widget _consentNote(Color color) {
    final base = OTTypography.caption(color: color).copyWith(height: 1.5);
    final link = base.copyWith(
        decoration: TextDecoration.underline,
        color: color.withValues(alpha: 1));
    final parts = Loc.tr('planConsent').split(RegExp(r'(\{0\}|\{1\})'));
    final firstIsTerms = Loc.tr('planConsent').indexOf('{0}') <
        Loc.tr('planConsent').indexOf('{1}');
    final termsSpan = TextSpan(
        text: Loc.tr('planConsentTerms'), style: link, recognizer: _termsTap);
    final refundSpan = TextSpan(
        text: Loc.tr('planConsentRefund'), style: link, recognizer: _refundTap);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text.rich(
        TextSpan(style: base, children: [
          TextSpan(text: parts[0]),
          if (firstIsTerms) termsSpan else refundSpan,
          TextSpan(text: parts.length > 1 ? parts[1] : ''),
          if (firstIsTerms) refundSpan else termsSpan,
          TextSpan(text: parts.length > 2 ? parts[2] : ''),
        ]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _benefitRow(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OTSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height:
                MediaQuery.textScalerOf(context).scale(OTFontSize.s16) * 1.45,
            child: Center(
              child: Icon(Icons.check_rounded, size: 18, color: textColor),
            ),
          ),
          const SizedBox(width: OTSpacing.md),
          Expanded(
            child: Text(
              text,
              style: OTTypography.body(color: textColor)
                  .copyWith(fontSize: OTFontSize.s16, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisciplinePickerModal(
      BuildContext context, List<AgentModel> specialists) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final surface = OTColors.surface(dark);

    showAdaptiveSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(OTRadius.dialog)),
      ),
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final soon = query.isNotEmpty
                ? const <AgentModel>[]
                : (_loadedAgents ?? AgentService.getActiveAgentsSync())
                    .where((a) =>
                        a.kind == CorpusKind.discipline &&
                        a.isComingSoon &&
                        a.id != 'fiqh_tahawwulat')
                    .toList();
            final activeSpecialists = specialists
                .where((a) => a.isActive && !a.isComingSoon)
                .toList();
            final filtered = query.isEmpty
                ? activeSpecialists
                : activeSpecialists.where((a) {
                    final q = query.toLowerCase();
                    return a.title.toLowerCase().contains(q) ||
                        a.titleArabic.contains(q) ||
                        (a.referenceBooks?.any((b) =>
                                b.title.toLowerCase().contains(q) ||
                                b.titleArabic.contains(q)) ??
                            false);
                  }).toList();

            return DraggableScrollableSheet(
              // Di desktop lembar ini berada di dalam dialog: isi penuh, tanpa ruang kosong.
              initialChildSize: AppPlatform.isDesktop ? 1 : 0.75,
              minChildSize: AppPlatform.isDesktop ? 1 : 0.5,
              maxChildSize: AppPlatform.isDesktop ? 1 : 0.92,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    if (AppPlatform.isDesktop)
                      const SizedBox(height: 8)
                    else
                      const SheetGrabber(top: 10, bottom: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Loc.tr('chooseField'),
                                style: OTTypography.cardTitle(color: ink),
                              ),
                              IconButton(
                                icon: Icon(Icons.close_rounded, color: muted),
                                onPressed: () => Navigator.pop(modalCtx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            autofocus: false,
                            onChanged: (val) =>
                                setModalState(() => query = val),
                            decoration: InputDecoration(
                              hintText: Loc.tr('searchFieldHint'),
                              prefixIcon: Icon(Icons.search_rounded,
                                  size: 20, color: muted),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        itemCount: filtered.length + soon.length,
                        separatorBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(height: 1, color: border),
                        ),
                        itemBuilder: (_, i) {
                          if (i >= filtered.length) {
                            final a = soon[i - filtered.length];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(children: [
                                Expanded(
                                  child: Text(Loc.text(a.title),
                                      style: OTTypography.bodyMedium(
                                          color: OTColors.textTertiary(dark))),
                                ),
                                Text(Loc.tr('comingSoon'),
                                    style: OTTypography.caption(
                                        color: OTColors.textTertiary(dark))),
                              ]),
                            );
                          }
                          final a = filtered[i];
                          final isSelected = a.id == _selectedAgentId;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedAgentId = a.id);
                              Navigator.pop(modalCtx);
                            },
                            borderRadius: BorderRadius.circular(OTRadius.input),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      Loc.text(a.title),
                                      style: OTTypography.bodyMedium(color: ink)
                                          .copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_rounded,
                                        color: ink, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final flagship =
        AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final specialists = _specialists;
    final selected = specialists.isNotEmpty
        ? specialists.firstWhere((a) => a.id == _selectedAgentId,
            orElse: () => specialists.first)
        : null;
    final hasSpecialists = specialists.isNotEmpty && selected != null;
    final flagshipOffers = ProductPricing.tahawwulat;
    final singleOffers = ProductPricing.specialists;
    final fi = _periodIndex.clamp(0, flagshipOffers.length - 1);
    final si = _periodIndex.clamp(0, singleOffers.length - 1);
    final flagshipOffer = flagshipOffers[fi];
    final flagshipActive = _hasAccess(flagship.id);
    final singleOffer = singleOffers[si];

    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(
        titleSpacing: otTitleSpacing(context),
        title: Text(AppCopy.subscription),
        backgroundColor: OTColors.canvas(dark),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(builder: (context, viewport) {
              final wide = viewport.maxWidth >= 820;
              final twoUp = wide && hasSpecialists;

              final featuredPlan = _planCard(
                inverse: true,
                wide: twoUp,
                label: Loc.tr('planFeaturedBadge'),
                exclusive: true,
                active: flagshipActive,
                title: AppCopy.planTahawwulat,
                description: Loc.tr('planFeaturedDescription'),
                field: _fieldRow(
                  label: Loc.tr('planFeaturedInside'),
                  name: Loc.tr('planFeaturedInsideValue'),
                  inverse: true,
                ),
                price: flagshipOffer,
                offers: flagshipOffers,
                benefits: [
                  Loc.tr('planFeaturedBenefit1'),
                  Loc.tr('planFeaturedBenefit3'),
                  Loc.tr('planFeaturedBenefit4'),
                  Loc.tr('planBenefitGrowth'),
                  Loc.tr('planBenefitUpdates'),
                ],
                onCheckout: () => _checkout(flagship, flagshipOffer),
                agentId: flagship.id,
              );

              final singlePlan = hasSpecialists
                  ? _planCard(
                      inverse: false,
                      wide: twoUp,
                      label: Loc.tr('planSingleLabel'),
                      active: _hasAccess(selected.id),
                      title: Loc.text(selected.title),
                      description: Loc.tr('planSingleDescription'),
                      field: _fieldRow(
                        label: Loc.tr('chooseField'),
                        name: Loc.text(selected.title),
                        inverse: false,
                        onTap: _processing
                            ? null
                            : () => _showDisciplinePickerModal(
                                context, specialists),
                      ),
                      price: singleOffer,
                      offers: singleOffers,
                      benefits: [
                        Loc.tr(
                            'planSingleBenefit1', [Loc.text(selected.title)]),
                        Loc.tr('planSingleBenefit2'),
                        Loc.tr('planBenefitGrowthSingle'),
                        Loc.tr('planBenefitUpdates'),
                      ],
                      onCheckout: () => _checkout(selected, singleOffer),
                      agentId: selected.id,
                    )
                  : null;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    wide ? OTSpacing.xxl : OTSpacing.lg,
                    OTSpacing.sm,
                    wide ? OTSpacing.xxl : OTSpacing.lg,
                    OTSpacing.jumbo),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: twoUp ? 1040 : 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_headline(),
                            style: (Loc.isArabic
                                    ? OTTypography.arabicDisplay(color: ink)
                                    : OTTypography.editorialHero(color: ink))
                                .copyWith(
                                    fontSize: wide
                                        ? OTFontSize.s36
                                        : OTFontSize.s26)),
                        const SizedBox(height: OTSpacing.xl),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: _pill(Loc.tr('launchOffer'), ink),
                            ),
                          ),
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        const _PromoCountdownBanner(),
                        const SizedBox(height: OTSpacing.xl),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: _PeriodSwitch(
                              label: Loc.tr('planPeriodLabel'),
                              titles: [for (final o in flagshipOffers) o.title],
                              notes: [for (final _ in flagshipOffers) ''],
                              selected: fi,
                              onSelect: _processing
                                  ? null
                                  : (i) => setState(() => _periodIndex = i),
                            ),
                          ),
                        ),
                        const SizedBox(height: OTSpacing.xl),
                        if (twoUp && singlePlan != null)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                    child: OTReveal(
                                        index: 0, child: featuredPlan)),
                                const SizedBox(width: OTSpacing.base),
                                Expanded(
                                    child:
                                        OTReveal(index: 1, child: singlePlan)),
                              ],
                            ),
                          )
                        else ...[
                          OTReveal(index: 0, child: featuredPlan),
                          if (singlePlan != null) ...[
                            const SizedBox(height: OTSpacing.base),
                            OTReveal(index: 1, child: singlePlan),
                          ],
                        ],
                        const SizedBox(height: OTSpacing.xl),
                        _consentNote(OTColors.textSecondary(dark)),
                        const SizedBox(height: OTSpacing.base),
                        Center(
                          child: TextButton.icon(
                            onPressed: _processing
                                ? null
                                : () => RedeemCodeSheet.show(context),
                            style: OTButtons.quiet(dark),
                            icon: const Icon(Icons.confirmation_number_outlined,
                                size: 18),
                            label: Text(Loc.tr('redeemAccess')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_processing)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: OTColors.canvas(dark).withValues(alpha: 0.88),
                    child: Center(
                      child: AppLoader.fullscreen(
                        title: Loc.tr('checkoutPreparing'),
                        subtitle: Loc.tr('checkoutPleaseWait'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pilihan masa akses untuk kedua paket sekaligus: satu kapsul, penanda hitam
/// yang bergeser ke masa terpilih. Segmen boleh membawa catatan hemat.
class _PeriodSwitch extends StatelessWidget {
  const _PeriodSwitch({
    required this.label,
    required this.titles,
    required this.notes,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final List<String> titles, notes;
  final int selected;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final onInk = OTColors.onInverted(dark);
    final muted = OTColors.textSecondary(dark);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final n = titles.length;
    final hasNotes = notes.any((e) => e.isNotEmpty);
    return Semantics(
      container: true,
      label: label,
      child: Container(
        padding: const EdgeInsets.all(OTSpacing.xs),
        decoration: BoxDecoration(
          color: OTColors.surfaceSubtle(dark),
          borderRadius: OTRadius.chipBorder,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedAlign(
                duration: reduced ? Duration.zero : OTMotion.normal,
                curve: Curves.easeOutCubic,
                alignment: AlignmentDirectional(
                    n == 1 ? 0 : -1 + 2 * selected / (n - 1), 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ink,
                      borderRadius: OTRadius.chipBorder,
                    ),
                  ),
                ),
              ),
            ),
            Row(children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected == i,
                    child: InkWell(
                      onTap: onSelect == null ? null : () => onSelect!(i),
                      borderRadius: OTRadius.chipBorder,
                      focusColor: ink.withValues(alpha: 0.12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: OTSpacing.md, horizontal: OTSpacing.sm),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(titles[i],
                                  style: OTTypography.bodyMedium(
                                      color: selected == i ? onInk : muted)),
                            ),
                            if (hasNotes)
                              SizedBox(
                                height: OTSpacing.base,
                                child: notes[i].isEmpty
                                    ? null
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(notes[i],
                                            style: OTTypography.metadataTag(
                                                color: selected == i
                                                    ? OTColors.onInvertedMuted(
                                                        dark)
                                                    : muted)),
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Banner hitung mundur penawaran perdana 10 hari: hanya angka, selebar pil
/// pilihan periode. Hitungan mulai berjalan Selasa, 27 Oktober 2026 pukul
/// 17:00 WIB (10:00 UTC) dan berakhir tepat 10 hari kemudian. Sebelum mulai,
/// angka diam di 10 hari penuh; setelah berakhir, semuanya nol.
class PromoCountdownBanner extends StatefulWidget {
  const PromoCountdownBanner({super.key, this.clock});

  /// Jam acuan; hanya diganti pada pengujian agar hasilnya tidak bergantung
  /// pada waktu sebenarnya.
  final DateTime Function()? clock;

  @override
  State<PromoCountdownBanner> createState() => _PromoCountdownBannerState();
}

typedef _PromoCountdownBanner = PromoCountdownBanner;

class _PromoCountdownBannerState extends State<_PromoCountdownBanner> {
  Timer? _timer;

  // Mulai (diundur): Selasa, 27 Oktober 2026, 17:00 WIB (UTC+7) = 10:00:00 UTC
  static final DateTime promoStartUtc = DateTime.utc(2026, 10, 27, 10, 0, 0);

  // Berakhir (10 hari kemudian): Jumat, 6 November 2026, 17:00 WIB = 10:00:00 UTC
  static final DateTime promoEndUtc = DateTime.utc(2026, 11, 6, 10, 0, 0);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nowUtc = (widget.clock?.call() ?? DateTime.now()).toUtc();
    final Duration remaining = nowUtc.isBefore(promoStartUtc)
        ? promoEndUtc.difference(promoStartUtc)
        : (nowUtc.isAfter(promoEndUtc)
            ? Duration.zero
            : promoEndUtc.difference(nowUtc));

    String two(int v) => v.toString().padLeft(2, '0');
    final text = '${two(remaining.inDays)} : ${two(remaining.inHours % 24)} : '
        '${two(remaining.inMinutes % 60)} : ${two(remaining.inSeconds % 60)}';

    // Selebar pil 1/6/12 Bulan (maks 440), di tengah.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Semantics(
          container: true,
          label: text,
          child: ExcludeSemantics(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.base, vertical: OTSpacing.md),
              decoration: BoxDecoration(
                // Merah solid tanpa transparansi, sesuai keputusan desain peluncuran.
                color: OTColors.errorLight,
                borderRadius: OTRadius.chipBorder,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  style: ScholarlyFonts.outfit(
                    textStyle: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()]),
                    fontSize: OTFontSize.s22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: OTExpressive.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
