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
import '../services/subscription_service.dart';
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
  String _selectedAgentId = 'fiqh_syafii';
  int _tahawwulatIndex = 0;
  int _specialistIndex = 0;
  bool _processing = false;
  bool _initialized = false;
  String? _checkoutError;
  String? _checkoutAgentId;

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

  Widget _checkoutNotice(String agentId) {
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
                  style: OTTypography.caption(color: OTColors.textPrimary(dark))
                      .copyWith(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  List<AgentModel> get _specialists => AgentModel.defaultAgents
      .where((a) =>
          a.kind == CorpusKind.discipline &&
          a.isActive &&
          a.id != 'fiqh_tahawwulat')
      .toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final agent = args is Map ? args['agent'] : null;
    if (agent is AgentModel && _specialists.any((a) => a.id == agent.id)) {
      _selectedAgentId = agent.id;
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
          result['pricingRevision'] != ProductPricing.revision) {
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
            plan: title, invoice: invoice, amount: offer.amount);
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
    final border = OTColors.surface(dark);
    if (flagship) {
      return Container(
        decoration: BoxDecoration(
          color: OTColors.surface(dark),
          borderRadius: BorderRadius.circular(OTRadius.card),
          border: Border.all(color: OTColors.surface(dark)),
        ),
        padding: const EdgeInsets.all(20),
        child: child,
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

  Widget _benefitRow(String text, Color textColor) {
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
              color: textColor.withValues(alpha: 0.8),
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
            final filtered = query.isEmpty
                ? specialists
                : specialists.where((a) {
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
    final selected = specialists.firstWhere((a) => a.id == _selectedAgentId,
        orElse: () => specialists.first);

    final single = ProductPricing.specialists[_specialistIndex];

    Widget cta(VoidCallback onPressed, int amount) => SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _processing ? null : onPressed,
            child: Text(Loc.tr('payAmount', [ProductPricing.rupiah(amount)])),
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
    }) =>
        [
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: agentId == flagship.id
                      ? OTExpressive.hero
                      : OTColors.surfaceSubtle(dark),
                  borderRadius: OTRadius.cardBorder),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: OTTypography.caption(
                            color: agentId == flagship.id
                                ? OTExpressive.white
                                : muted)),
                    const SizedBox(height: 8),
                    Text(title,
                        style: OTTypography.screenTitle(
                            color: agentId == flagship.id
                                ? OTExpressive.white
                                : ink)),
                  ])),
          const SizedBox(height: 12),
          Text(description, style: OTTypography.caption(color: muted)),
          const SizedBox(height: 16),
          scope,
          const SizedBox(height: 16),
          tiers,
          const SizedBox(height: 20),
          PromoPrice(
            amount: price.amount,
            regularAmount: price.regularAmount,
            period: price.period,
          ),
          const SizedBox(height: 16),
          Divider(color: border, height: 1),
          const SizedBox(height: 16),
          for (final benefit in benefits) _benefitRow(benefit, ink),
          if (wide) const Spacer() else const SizedBox(height: 8),
          const SizedBox(height: 8),
          if (price.months > 1) ...[
            Text(
                Loc.tr('monthlyEquivalent', [
                  ProductPricing.rupiah((price.amount / price.months).round())
                ]),
                style: OTTypography.caption(color: muted)),
            const SizedBox(height: 12),
          ],
          cta(onCheckout, price.amount),
          _checkoutNotice(agentId),
        ];

    // Cakupan paket utama: lima asisten, sebagai teks.
    final flagshipScope = Text(
        Loc.tr('flagshipExplore', ['${flagship.subAgents?.length ?? 0}']),
        style: OTTypography.captionMedium(color: ink));

    // Cakupan paket satu bidang: pemilih bidang.
    final fieldPicker = Material(
      color: OTColors.surfaceSubtle(dark),
      borderRadius: BorderRadius.circular(OTRadius.input),
      child: InkWell(
        onTap: _processing
            ? null
            : () => _showDisciplinePickerModal(context, specialists),
        borderRadius: BorderRadius.circular(OTRadius.input),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Loc.tr('chooseField'),
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s12, color: muted)),
                    const SizedBox(height: 1),
                    Text(
                      Loc.text(selected.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OTTypography.bodyMedium(color: ink),
                    ),
                  ],
                ),
              ),
              Icon(Icons.unfold_more_rounded, size: 18, color: muted),
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
        child: LayoutBuilder(builder: (context, viewport) {
          final wide = viewport.maxWidth >= 1000;

          Widget plan({required bool featured, required List<Widget> body}) =>
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

          final singlePlan = plan(
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
                Loc.tr('planSingleBenefit1', [Loc.text(selected.title)]),
                Loc.tr('planSingleBenefit2'),
                Loc.tr('planSingleBenefit3'),
              ],
              onCheckout: () => _checkout(selected, single),
              agentId: selected.id,
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 1040 : 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      Loc.tr('launchOffer'),
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(AppCopy.manualRenewalNotice,
                        style: OTTypography.body(color: muted)),
                    const SizedBox(height: 20),
                    if (wide)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: featuredPlan),
                            const SizedBox(width: 16),
                            Expanded(child: singlePlan),
                          ],
                        ),
                      )
                    else ...[
                      featuredPlan,
                      const SizedBox(height: 16),
                      singlePlan,
                    ],
                    const SizedBox(height: 12),
                    if (_processing)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: AppLoader(),
                        ),
                      ),
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
      ),
    );
  }
}

/// Pilihan masa akses satu paket: masa, harga, dan setara per bulan.
class _TierSelector extends StatelessWidget {
  const _TierSelector({
    required this.offers,
    required this.selected,
    required this.onSelect,
  });

  final List<SubscriptionOffer> offers;
  final int selected;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final stacked = MediaQuery.textScalerOf(context).scale(16) > 24;
    Widget option(int i) {
      final active = selected == i;
      final textColor = active ? OTColors.canvas(dark) : ink;
      final title = Text(offers[i].title,
          textAlign: TextAlign.center,
          style: OTTypography.captionMedium(color: textColor));
      return Semantics(
        button: true,
        selected: active,
        child: InkWell(
          onTap: onSelect == null ? null : () => onSelect!(i),
          borderRadius: BorderRadius.circular(OTRadius.input),
          child: AnimatedContainer(
            duration: OTMotion.fast,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: active ? ink : OTColors.surfaceSubtle(dark),
              borderRadius: BorderRadius.circular(OTRadius.input),
            ),
            child: Center(child: title),
          ),
        ),
      );
    }

    if (stacked) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (var i = 0; i < offers.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          option(i),
        ],
      ]);
    }
    return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < offers.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(child: option(i)),
      ],
    ]));
  }
}
