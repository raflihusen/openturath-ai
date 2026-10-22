import 'dart:async';
import '../widgets/app_loader.dart';
import '../widgets/adaptive_sheet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../widgets/ot_motion_widgets.dart';
import '../core/design/ot_motion.dart';
import '../core/scholarly_fonts.dart';
import '../core/app_copy.dart';
import '../widgets/payment_success_dialog.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_expressive.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import '../services/agent_service.dart';
import '../services/subscription_service.dart';
import '../widgets/payment_checkout_sheet.dart';
import '../widgets/promo_price.dart';
import '../widgets/redeem_code_sheet.dart';
import '../core/app_platform.dart';
import '../services/auth_service.dart';
import '../services/telemetry_service.dart';
import '../services/open_turath_catalog_repository.dart';
import 'package:intl/intl.dart' show NumberFormat;

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
  int _tahawwulatIndex = 2;
  int _specialistIndex = 0;
  bool _processing = false;
  bool _initialized = false;
  String? _checkoutError;
  String? _checkoutAgentId;

  @override
  void initState() {
    super.initState();
    ProductPricingService.syncPricing(forceRefresh: true).then((_) {
      if (mounted) setState(() {});
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
    final color = OTColors.destructive(dark);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(OTRadius.input),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: OTTypography.caption(
                          color: ink ?? OTColors.textPrimary(dark))
                      .copyWith(height: 1.4)),
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
              AppCopy.ahlanDefault,
          email: user.email ?? '',
          phone: user.phoneNumber ?? '');
      if (!mounted) return;
      // An old backend or stale quote must never open a differently priced checkout.
      if (result['amount'] != offer.amount ||
          (result['pricingRevision'] != ProductPricing.revision &&
              result['pricingRevision'] != ProductPricing.defaultRevision)) {
        setState(() => _checkoutError = Loc.tr('priceChanged'));
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

  Widget _card({required Widget child, bool flagship = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = OTColors.border(dark);
    if (flagship) {
      final direction = Directionality.of(context);
      // Kartu utama selalu bertinta gelap dengan pola bintang delapan yang
      // memudar dari sudut atas, supaya terbaca sebagai koleksi istimewa.
      return ClipRRect(
        borderRadius: BorderRadius.circular(OTRadius.card),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [OTExpressive.ink, OTExpressive.black],
            ),
            borderRadius: BorderRadius.circular(OTRadius.card),
            border:
                Border.all(color: OTExpressive.white.withValues(alpha: 0.16)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rect) => const LinearGradient(
                        begin: AlignmentDirectional.topEnd,
                        end: AlignmentDirectional.bottomStart,
                        stops: [0, 0.55],
                        colors: [OTExpressive.white, OTExpressive.transparent],
                      ).createShader(rect, textDirection: direction),
                      child: CustomPaint(painter: _KhatamPatternPainter()),
                    ),
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(24), child: child),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: OTColors.surface(dark),
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  /// Kepala paket utama: panel gelap bergradasi dengan lencana eksklusif,
  /// agar terbaca sebagai koleksi istimewa, bukan sekadar kartu kedua.
  Widget _flagshipHeader(String label, String title, AgentModel agent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: OTExpressive.white.withValues(alpha: 0.08),
            borderRadius: OTRadius.chipBorder,
            border:
                Border.all(color: OTExpressive.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium_outlined,
                  size: 14, color: OTExpressive.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        OTTypography.captionMedium(color: OTExpressive.white)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(title,
            style: OTTypography.displayLarge(color: OTExpressive.white)),
      ],
    );
  }

  /// Peran tiap AI Fikih Tahawwulat; kembali ke deskripsi model bila
  /// naskahnya belum ada.
  String _roleOf(SubAgentModel sub) {
    final key = 'tahawwulatRole_${sub.id.split('_').last}';
    final copy = Loc.tr(key);
    if (copy != key) return copy;
    return Loc.isArabic ? sub.descriptionArabic : sub.description;
  }

  Widget _trustNote(Color color) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(Loc.tr('planTrustNote'),
                  textAlign: TextAlign.center,
                  style: OTTypography.caption(color: color)),
            ),
          ],
        ),
      );

  Widget _benefitRow(String text, Color textColor, {Color? checkColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_rounded,
              size: 16,
              color: checkColor ?? textColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: OTTypography.body(color: textColor).copyWith(
                fontSize: OTFontSize.s14,
                height: 1.45,
              ),
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
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Divider(height: 1, color: border),
                        ),
                        itemBuilder: (_, i) {
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
    final muted = OTColors.textSecondary(dark);
    final border = OTColors.border(dark);
    final flagship =
        AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final offer = ProductPricing.tahawwulat[_tahawwulatIndex];
    final specialists = _specialists;
    final selected = specialists.isNotEmpty
        ? specialists.firstWhere((a) => a.id == _selectedAgentId,
            orElse: () => specialists.first)
        : null;
    final hasSpecialists = specialists.isNotEmpty && selected != null;

    final single = ProductPricing.specialists[_specialistIndex];

    Widget cta(VoidCallback onPressed, SubscriptionOffer offer,
            {bool onInk = false}) =>
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _processing ? null : onPressed,
            style: onInk ? OTButtons.onInk() : null,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(Loc.tr('planStartTerm', [
                offer.title.toLowerCase(),
                ProductPricing.rupiah(offer.amount)
              ])),
            ),
          ),
        );

    // Dua kartu memakai urutan bagian yang sama agar sejajar saat
    // berdampingan: label, judul, keterangan, cakupan, masa akses, harga,
    // manfaat, tombol.
    List<Widget> planBody({
      required bool wide,
      required String label,
      required String title,
      required String description,
      required Widget scope,
      required Widget tiers,
      required SubscriptionOffer price,
      required List<String> benefits,
      required VoidCallback onCheckout,
      required String agentId,
    }) {
      final f = agentId == flagship.id;
      final cInk = f ? OTExpressive.white : ink;
      final cMuted = f ? OTExpressive.whiteMuted : muted;
      final cLine = f ? OTExpressive.white.withValues(alpha: 0.14) : border;
      return [
        if (agentId == flagship.id)
          _flagshipHeader(label, title, flagship)
        else
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(),
                style: OTTypography.sectionHeading(color: muted)),
            const SizedBox(height: 8),
            Text(title, style: OTTypography.editorialHero(color: ink)),
          ]),
        const SizedBox(height: 16),
        Text(description,
            style: OTTypography.body(color: cMuted).copyWith(height: 1.45)),
        const SizedBox(height: 20),
        scope,
        const SizedBox(height: 20),
        tiers,
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: OTMotion.normal,
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.12), end: Offset.zero)
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
            display: f,
            inlineSaving: true,
            foregroundColor: cInk,
            secondaryColor: cMuted,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: cLine, height: 1),
        const SizedBox(height: 16),
        for (final benefit in benefits)
          _benefitRow(benefit, cInk, checkColor: null),
        if (wide) const Spacer() else const SizedBox(height: 8),
        const SizedBox(height: 8),
        if (price.months > 1) ...[
          Text(
              Loc.tr('monthlyEquivalent', [
                ProductPricing.rupiah(
                    ((price.amount / price.months) / 1000).round() * 1000)
              ]),
              style: OTTypography.caption(color: cMuted)),
          const SizedBox(height: 12),
        ],
        cta(onCheckout, price, onInk: f),
        _trustNote(cMuted),
        _checkoutNotice(agentId, ink: cInk),
      ];
    }

    // Cakupan paket utama: lima asisten, sebagai teks.
    final subAgents = flagship.subAgents ?? const <SubAgentModel>[];
    final flagshipScope = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            Loc.tr('planFeaturedIncludes', ['${subAgents.length}'])
                .toUpperCase(),
            style: OTTypography.sectionHeading(color: OTExpressive.whiteMuted)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, sub) in subAgents.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Container(
                  width: 148,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OTExpressive.white.withValues(alpha: 0.05),
                    borderRadius: OTRadius.xsBorder,
                    border: Border.all(
                        color: OTExpressive.white.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Loc.isArabic ? sub.nameArabic : sub.name,
                          style: OTTypography.bodyMedium(
                              color: OTExpressive.white)),
                      const SizedBox(height: 4),
                      Text(_roleOf(sub),
                          style: OTTypography.caption(
                                  color: OTExpressive.whiteMuted)
                              .copyWith(height: 1.4)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    // Cakupan paket satu bidang: pemilih bidang.
    final fieldPicker = selected == null
        ? const SizedBox.shrink()
        : Material(
            color: OTColors.surfaceSubtle(dark),
            borderRadius: BorderRadius.circular(OTRadius.input),
            child: InkWell(
              onTap: (_processing || specialists.length <= 1)
                  ? null
                  : () => _showDisciplinePickerModal(context, specialists),
              borderRadius: BorderRadius.circular(OTRadius.input),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            specialists.length <= 1
                                ? Loc.tr('discipline')
                                : Loc.tr('chooseField'),
                            style: ScholarlyFonts.outfit(
                                fontSize: OTFontSize.s12, color: muted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Loc.text(selected.title),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OTTypography.bodyMedium(color: ink),
                          ),
                        ],
                      ),
                    ),
                    if (specialists.length > 1)
                      Icon(Icons.unfold_more_rounded, size: 20, color: muted),
                  ],
                ),
              ),
            ),
          );

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
              final wide = viewport.maxWidth >= 1000;

              Widget plan(
                      {required bool featured, required List<Widget> body}) =>
                  _card(
                    flagship: featured,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: body,
                    ),
                  );

              final featuredPlan = plan(
                featured: true,
                body: planBody(
                  wide: wide,
                  label: Loc.isArabic
                      ? 'حصري في OpenTurath · 5 AI'
                      : Loc.language == 'en'
                          ? 'Exclusive to OpenTurath · 5 AI'
                          : 'Eksklusif di OpenTurath · 5 AI',
                  title: AppCopy.planTahawwulat,
                  description: Loc.tr('planFeaturedDescription'),
                  scope: flagshipScope,
                  tiers: _TierSelector(
                    onInk: true,
                    offers: ProductPricing.tahawwulat,
                    selected: _tahawwulatIndex,
                    onSelect: _processing
                        ? null
                        : (i) => setState(() => _tahawwulatIndex = i),
                  ),
                  price: offer,
                  benefits: [
                    Loc.tr('planFeaturedBenefit1'),
                    Loc.tr('planFeaturedBenefit3'),
                    Loc.tr('planFeaturedBenefit4'),
                  ],
                  onCheckout: () => _checkout(flagship, offer),
                  agentId: flagship.id,
                ),
              );

              final singlePlan = hasSpecialists
                  ? plan(
                      featured: false,
                      body: planBody(
                        wide: wide,
                        label: Loc.tr('planSingleLabel'),
                        title: Loc.tr('specialistAccess'),
                        description: Loc.tr('planSingleDescription'),
                        scope: fieldPicker,
                        tiers: _TierSelector(
                          offers: ProductPricing.specialists,
                          selected: _specialistIndex,
                          onSelect: _processing
                              ? null
                              : (i) => setState(() => _specialistIndex = i),
                        ),
                        price: single,
                        benefits: [
                          Loc.tr(
                              'planSingleBenefit1', [Loc.text(selected.title)]),
                          Loc.tr('planSingleBenefit2'),
                          Loc.tr('planSingleBenefit3'),
                        ],
                        onCheckout: () => _checkout(selected, single),
                        agentId: selected.id,
                      ),
                    )
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: (wide && hasSpecialists) ? 1040 : 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(Loc.tr('launchOffer').toUpperCase(),
                            style: OTTypography.sectionHeading(color: muted)),
                        const SizedBox(height: 12),
                        Text(_headline(),
                            style: OTTypography.editorialHero(color: ink)),
                        const SizedBox(height: 8),
                        _LibraryProof(ink: ink, muted: muted),
                        const SizedBox(height: 20),
                        const _PromoCountdownBanner(),
                        const SizedBox(height: 20),
                        if (wide && hasSpecialists && singlePlan != null)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                    child:
                                        OTReveal(index: 0, child: featuredPlan)),
                                const SizedBox(width: 16),
                                Expanded(
                                    child:
                                        OTReveal(index: 1, child: singlePlan)),
                              ],
                            ),
                          )
                        else ...[
                          OTReveal(index: 0, child: featuredPlan),
                          if (hasSpecialists && singlePlan != null) ...[
                            const SizedBox(height: 16),
                            OTReveal(index: 1, child: singlePlan),
                          ],
                        ],
                        const SizedBox(height: 12),
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
                        title: Loc.language == 'ar'
                            ? 'جارٍ تهيئة عملية الدفع…'
                            : (Loc.language == 'en'
                                ? 'Preparing checkout…'
                                : 'Menyiapkan pembayaran…'),
                        subtitle: Loc.language == 'ar'
                            ? 'يرجى الانتظار لحظة'
                            : (Loc.language == 'en'
                                ? 'Please wait a moment'
                                : 'Mohon tunggu sebentar'),
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

/// Pilihan masa akses: satu lintasan dengan penanda yang bergeser ke masa
/// terpilih. Tiap segmen memuat masa dan harganya.
class _TierSelector extends StatelessWidget {
  const _TierSelector({
    required this.offers,
    required this.selected,
    required this.onSelect,
    this.onInk = false,
  });

  final List<SubscriptionOffer> offers;
  final int selected;
  final ValueChanged<int>? onSelect;
  final bool onInk;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = onInk ? OTExpressive.white : OTColors.textPrimary(dark);
    final muted =
        onInk ? OTExpressive.whiteMuted : OTColors.textSecondary(dark);
    final track = onInk
        ? OTExpressive.white.withValues(alpha: 0.06)
        : OTColors.surfaceSubtle(dark);
    final thumb = onInk
        ? OTExpressive.white.withValues(alpha: 0.12)
        : OTColors.surface(dark);
    final thumbLine = onInk ? OTExpressive.white : ink;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final n = offers.length;
    // Di layar sempit, tulis hemat tanpa "dari bulanan" agar tetap terbaca.
    final narrow = MediaQuery.sizeOf(context).width < 600;
    // Hemat dihitung terhadap membayar bulanan selama masa yang sama.
    final monthly = offers.first.amount;
    final savings = [
      for (final o in offers)
        o.months <= 1
            ? 0
            : ((monthly * o.months - o.amount) * 100 / (monthly * o.months))
                .round(),
    ];

    Widget segment(int i) {
      final active = selected == i;
      return Semantics(
        button: true,
        selected: active,
        child: InkWell(
          onTap: onSelect == null ? null : () => onSelect!(i),
          borderRadius: OTRadius.chipBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(offers[i].title,
                    textAlign: TextAlign.center,
                    style: OTTypography.captionMedium(
                        color: active ? ink : muted)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(ProductPricing.rupiah(offers[i].amount),
                      style: OTTypography.caption(color: muted).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()])),
                ),
                if (savings[i] >= 5) ...[
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        Loc.tr(narrow ? 'saving' : 'termSavingVsMonthly',
                            ['${savings[i]}']),
                        style: OTTypography.metadataTag(
                            color: onInk ? OTExpressive.whiteMuted : ink)),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (MediaQuery.textScalerOf(context).scale(16) > 24) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < n; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: selected == i ? thumb : track,
              borderRadius: OTRadius.chipBorder,
              border: Border.all(
                  color: selected == i ? thumbLine : OTExpressive.transparent,
                  width: 1.5),
            ),
            child: segment(i),
          ),
        ],
      ]);
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration:
          BoxDecoration(color: track, borderRadius: OTRadius.chipBorder),
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
                    color: thumb,
                    borderRadius: OTRadius.chipBorder,
                    border: Border.all(color: thumbLine, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          Row(children: [
            for (var i = 0; i < n; i++) Expanded(child: segment(i)),
          ]),
        ],
      ),
    );
  }
}

/// Pola bintang delapan (khatam): dua bujur sangkar bertumpuk per petak,
/// garis tipis putih yang dipudarkan oleh kartu pemanggilnya.
class _KhatamPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 36.0;
    const half = 9.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = OTExpressive.white.withValues(alpha: 0.10);
    for (var y = cell / 2; y < size.height + cell; y += cell) {
      for (var x = cell / 2; x < size.width + cell; x += cell) {
        final square = Rect.fromCenter(
            center: Offset(x, y), width: half * 2, height: half * 2);
        canvas.drawRect(square, paint);
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(0.7853981633974483);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: half * 2, height: half * 2),
            paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_KhatamPatternPainter oldDelegate) => false;
}

/// Angka pustaka yang sama dengan layar masuk: bidang ilmu, entri kitab,
/// dan perkiraan halaman. Tidak tampil bila katalog belum termuat.
class _LibraryProof extends StatelessWidget {
  const _LibraryProof({required this.ink, required this.muted});

  final Color ink;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, AiLibraryMetadata>>(
      future: OpenTurathCatalogRepository.instance.loadAllMetadata(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <String, AiLibraryMetadata>{};
        if (all.isEmpty) return const SizedBox.shrink();
        final number = NumberFormat.decimalPattern(Loc.language);
        final entries =
            all.values.fold<int>(0, (sum, item) => sum + item.totalKitab);
        final pages =
            all.values.fold<int>(0, (sum, item) => sum + item.totalHalaman);
        final strong = OTTypography.captionMedium(color: ink)
            .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
        final plain = OTTypography.caption(color: muted);
        return Text.rich(TextSpan(style: plain, children: [
          TextSpan(text: number.format(all.length), style: strong),
          TextSpan(text: ' ${Loc.tr('loginStatLibraries')}  ·  '),
          TextSpan(
              text: Loc.atLeast(number.format(entries ~/ 100 * 100)),
              style: strong),
          TextSpan(text: ' ${Loc.tr('loginStatEntries')}  ·  '),
          TextSpan(
              text: Loc.atLeast(
                  number.format(pages ~/ 100000 / 10), Loc.tr('unitMillion')),
              style: strong),
          TextSpan(text: ' ${Loc.tr('loginStatPages')}'),
        ]));
      },
    );
  }
}

/// Banner hitung mundur penawaran perdana 10 hari yang dimulai pada
/// Jumat pukul 12:00 WIB siang (23 Oktober 2026 12:00 WIB / 05:00 UTC).
///
/// Desain solid red 100% opacity (tanpa pengurangan transparansi) dengan
/// tipografi putih bersih dan tata letak ultra-minimalis, selaras dengan
/// bahasa desain scholarly.
class PromoCountdownBanner extends StatefulWidget {
  const PromoCountdownBanner({super.key});

  @override
  State<PromoCountdownBanner> createState() => _PromoCountdownBannerState();
}

typedef _PromoCountdownBanner = PromoCountdownBanner;

class _PromoCountdownBannerState extends State<_PromoCountdownBanner> {
  Timer? _timer;

  // Jadwal Peluncuran: Jumat, 23 Oktober 2026, 12:00 WIB (UTC+7) = 05:00:00 UTC
  static final DateTime promoStartUtc = DateTime.utc(2026, 10, 23, 5, 0, 0);

  // Batas Akhir Penawaran 10 Hari: Senin, 2 November 2026, 12:00 WIB (UTC+7) = 05:00:00 UTC
  static final DateTime promoEndUtc = DateTime.utc(2026, 11, 2, 5, 0, 0);

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
    final nowUtc = DateTime.now().toUtc();
    final isBeforeStart = nowUtc.isBefore(promoStartUtc);
    final isEnded = nowUtc.isAfter(promoEndUtc);

    // Hitung mundur:
    // Sebelum mulai -> countdown menuju Jumat 12:00 WIB
    // Selama berlangsung -> countdown 10 hari hingga batas akhir Senin 12:00 WIB
    // Setelah selesai -> 0
    final Duration remaining = isBeforeStart
        ? promoStartUtc.difference(nowUtc)
        : (isEnded ? Duration.zero : promoEndUtc.difference(nowUtc));

    final int days = remaining.inDays;
    final int hours = remaining.inHours % 24;
    final int minutes = remaining.inMinutes % 60;
    final int seconds = remaining.inSeconds % 60;

    // Lokalisasi teks terjemahan
    final lang = Loc.language;
    final String headerTitle;
    final String bottomCaption;
    final String unitDays;
    final String unitHours;
    final String unitMins;
    final String unitSecs;

    if (lang == 'ar') {
      unitDays = 'أيام';
      unitHours = 'ساعات';
      unitMins = 'دقائق';
      unitSecs = 'ثوانٍ';
      if (isBeforeStart) {
        headerTitle = 'العد التنازلي لإطلاق عرض الـ 10 أيام';
        bottomCaption =
            'يبدأ الجمعة، 23 أكتوبر · 12:00 بتوقيت جاكرتا (نافذة 10 أيام)';
      } else if (isEnded) {
        headerTitle = 'انتهى العرض';
        bottomCaption = 'انتهت فترة عرض الإطلاق لـ 10 أيام';
      } else {
        headerTitle = 'عرض الإطلاق المحدود (10 أيام)';
        bottomCaption =
            'العرض متاح لمدة 10 أيام · ينتهي الإثنين، 2 نوفمبر 12:00 WIB';
      }
    } else if (lang == 'en') {
      unitDays = 'DAYS';
      unitHours = 'HOURS';
      unitMins = 'MINUTES';
      unitSecs = 'SECONDS';
      if (isBeforeStart) {
        headerTitle = '10-DAY PROMO LAUNCH COUNTDOWN';
        bottomCaption =
            'Starts Friday, Oct 23 · 12:00 WIB (10-day promo window)';
      } else if (isEnded) {
        headerTitle = 'LAUNCH OFFER ENDED';
        bottomCaption = 'The 10-day launch offer has ended';
      } else {
        headerTitle = 'LIMITED 10-DAY LAUNCH OFFER';
        bottomCaption =
            'Offer active for 10 days · Ends Monday, Nov 2 at 12:00 WIB';
      }
    } else {
      // Default: Bahasa Indonesia
      unitDays = 'HARI';
      unitHours = 'JAM';
      unitMins = 'MENIT';
      unitSecs = 'DETIK';
      if (isBeforeStart) {
        headerTitle = 'MENUJU PELUNCURAN PROMO 10 HARI';
        bottomCaption =
            'Mulai Jumat, 23 Okt · 12:00 WIB (durasi promo 10 hari)';
      } else if (isEnded) {
        headerTitle = 'PENAWARAN PERDANA TELAH SELESAI';
        bottomCaption = 'Masa penawaran perdana 10 hari telah ditutup';
      } else {
        headerTitle = 'PENAWARAN PERDANA TERBATAS (10 HARI)';
        bottomCaption =
            'Penawaran aktif selama 10 hari · Berakhir Senin, 2 Nov · 12:00 WIB';
      }
    }

    // Warna merah solid 100% opacity (Crimson Red murni tanpa transparansi)
    const solidRedBg = OTColors.errorLight;

    return Container(
      decoration: BoxDecoration(
        color: solidRedBg,
        borderRadius: BorderRadius.circular(OTRadius.card),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header teks minimalis kapital
          Text(
            headerTitle,
            textAlign: TextAlign.center,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: OTExpressive.white,
            ),
          ),
          const SizedBox(height: 14),

          // Angka hitung mundur tabular bersih langsung di atas bidang merah solid
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDigitColumn(
                  value: days.toString().padLeft(2, '0'),
                  label: unitDays,
                ),
                _buildSeparator(),
                _buildDigitColumn(
                  value: hours.toString().padLeft(2, '0'),
                  label: unitHours,
                ),
                _buildSeparator(),
                _buildDigitColumn(
                  value: minutes.toString().padLeft(2, '0'),
                  label: unitMins,
                ),
                _buildSeparator(),
                _buildDigitColumn(
                  value: seconds.toString().padLeft(2, '0'),
                  label: unitSecs,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Baris keterangan jadwal
          Text(
            bottomCaption,
            textAlign: TextAlign.center,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s11,
              fontWeight: FontWeight.w400,
              color: OTExpressive.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitColumn({
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: ScholarlyFonts.outfit(
            textStyle: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            fontSize: OTFontSize.calendarDay,
            fontWeight: FontWeight.w700,
            color: OTExpressive.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: ScholarlyFonts.outfit(
            fontSize: OTFontSize.s11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
            color: OTExpressive.white.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 16),
      child: Text(
        ':',
        style: ScholarlyFonts.outfit(
          fontSize: OTFontSize.s22,
          fontWeight: FontWeight.w600,
          color: OTExpressive.white.withValues(alpha: 0.5),
          height: 1.0,
        ),
      ),
    );
  }
}
