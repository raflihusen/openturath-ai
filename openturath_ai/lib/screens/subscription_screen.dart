import '../widgets/adaptive_sheet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';
import '../models/agent_model.dart';
import '../services/subscription_service.dart';
import '../widgets/doku_checkout_sheet.dart';
import '../widgets/promo_price.dart';
import '../widgets/redeem_code_sheet.dart';
import '../core/app_platform.dart';
import '../services/auth_service.dart';

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
          borderRadius: BorderRadius.circular(12),
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
                          color: OTColors.textPrimary(dark))
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
      final paid = await DokuCheckoutSheet.show(context,
          paymentUrl: paymentUrl,
          invoiceNumber: invoice,
          trxId: result['trxId'] as String?,
          planTitle: title,
          amount: offer.amount,
          regularAmount: offer.regularAmount,
          periodLabel: offer.period);
      if (mounted && paid == true) {
        AppSnackBar.success(context, Loc.tr('paymentConfirmed'));
      }
    } on FirebaseFunctionsException catch (error) {
      if (mounted) {
        setState(() => _checkoutError = _checkoutErrorMessage(error));
      }
    } on FormatException {
      if (mounted) {
        setState(() => _checkoutError = Loc.tr('checkoutLinkUnavailable'));
      }
    } catch (_) {
      if (mounted) setState(() => _checkoutError = Loc.tr('checkoutError'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Widget _card({required Widget child, bool flagship = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = OTColors.border(dark);
    if (flagship) {
      return Container(
        decoration: BoxDecoration(
          color: OTColors.surface(dark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OTColors.borderStrong(dark), width: 1.2),
        ),
        padding: const EdgeInsets.all(20),
        child: child,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: OTColors.surface(dark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.8),
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
                fontSize: 13,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
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
                                  horizontal: 14, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final a = filtered[i];
                          final isSelected = a.id == _selectedAgentId;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedAgentId = a.id);
                              Navigator.pop(modalCtx);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? OTColors.accent(dark)
                                        .withValues(alpha: 0.1)
                                    : surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? OTColors.accent(dark)
                                      : border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.title,
                                          style: OTTypography.bodyMedium(
                                                  color: ink)
                                              .copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded,
                                        color: OTColors.accent(dark), size: 20),
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
    final featuredInk = OTColors.onPrimaryContainer(dark);
    final flagship =
        AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final offer = ProductPricing.tahawwulat[_tahawwulatIndex];
    final specialists = _specialists;
    final selected = specialists.firstWhere((a) => a.id == _selectedAgentId,
        orElse: () => specialists.first);

    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(
          title: Text(AppCopy.subscription),
          backgroundColor: OTColors.canvas(dark)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          // Rata awal, sejajar dengan judul halaman.
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(Loc.tr('launchOffer'),
                      style: OTTypography.sectionTitle(color: ink)
                          .copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(AppCopy.manualRenewalNotice,
                      style: OTTypography.body(color: muted)),
                  const SizedBox(height: 20),

                  // ── 1. KARTU HITAM ELEGAN: SUPER AI FIKIH TAHAWWULAT (FLAGSHIP) ──
                  _card(
                    flagship: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: OTColors.surfaceSubtle(dark),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded,
                                      size: 14, color: featuredInk),
                                  const SizedBox(width: 5),
                                  Text(
                                    Loc.tr('planFeaturedLabel'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: featuredInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: OTColors.surfaceSubtle(dark),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                Loc.tr('planExclusive'),
                                style: TextStyle(
                                    color: featuredInk,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(AppCopy.planTahawwulat,
                            style: OTTypography.pageTitle(color: featuredInk)
                                .copyWith(fontSize: 22)),
                        const SizedBox(height: 6),
                        Text(
                          Loc.tr('planFeaturedDescription'),
                          style:
                              OTTypography.body(color: featuredInk)
                                  .copyWith(fontSize: 13, height: 1.45),
                        ),
                        const SizedBox(height: 18),

                        // Tier Selector Cards
                        Row(
                          children: [
                            for (var i = 0;
                                i < ProductPricing.tahawwulat.length;
                                i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: _processing
                                      ? null
                                      : () =>
                                          setState(() => _tahawwulatIndex = i),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    constraints: const BoxConstraints(minHeight: 72),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: OTColors.surface(dark),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _tahawwulatIndex == i
                                            ? OTColors.accent(dark)
                                            : OTColors.border(dark),
                                        width: _tahawwulatIndex == i ? 1.6 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          ProductPricing.tahawwulat[i].title,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: OTTypography.captionMedium(
                                            color: _tahawwulatIndex == i ? ink : muted,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ProductPricing.rupiah(ProductPricing
                                              .tahawwulat[i].amount),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: _tahawwulatIndex == i
                                                ? ink : featuredInk,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 18),
                        PromoPrice(
                            amount: offer.amount,
                            regularAmount: offer.regularAmount,
                            period: offer.period,
                            foregroundColor: featuredInk,
                            secondaryColor: featuredInk),
                        const SizedBox(height: 16),
                        Divider(color: OTColors.border(dark), height: 1),
                        const SizedBox(height: 16),

                        // Daftar Benefit Fikih Tahawwulat
                        _benefitRow(
                          Loc.tr('planFeaturedBenefit1'),
                          featuredInk,
                        ),
                        _benefitRow(
                          Loc.tr('planFeaturedBenefit2'),
                          featuredInk,
                        ),
                        _benefitRow(
                          Loc.tr('planFeaturedBenefit3'),
                          featuredInk,
                        ),
                        _benefitRow(
                          Loc.tr('planFeaturedBenefit4'),
                          featuredInk,
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _processing
                                ? null
                                : () => _checkout(flagship, offer),
                            style: FilledButton.styleFrom(
                              backgroundColor: OTColors.accent(dark),
                              foregroundColor: OTColors.onAccent(dark),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              Loc.tr('planChoose', [offer.title]),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        _checkoutNotice(flagship.id),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 2. KARTU SPESIALIS PER BIDANG LAINNYA ──
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Loc.tr('specialistAccess'),
                            style: OTTypography.pageTitle(color: ink)
                                .copyWith(fontSize: 22)),
                        const SizedBox(height: 6),
                        Text(
                          Loc.tr('planSingleDescription'),
                          style: OTTypography.body(color: muted)
                              .copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 16),

                        // Interactive Tactile Discipline Card
                        InkWell(
                          onTap: _processing
                              ? null
                              : () => _showDisciplinePickerModal(
                                  context, specialists),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selected.title,
                                        style:
                                            OTTypography.bodyMedium(color: ink),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: OTColors.surfaceSubtle(dark),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        Loc.tr('chooseField'),
                                        style: OTTypography.captionMedium(
                                                color: ink)
                                            .copyWith(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.unfold_more_rounded,
                                          size: 16, color: muted),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tier Selector Cards Spesialis Per Bidang
                        Row(
                          children: [
                            for (var i = 0;
                                i < ProductPricing.specialists.length;
                                i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: _processing
                                      ? null
                                      : () =>
                                          setState(() => _specialistIndex = i),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    constraints: const BoxConstraints(minHeight: 72),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: OTColors.surface(dark),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _specialistIndex == i
                                            ? OTColors.accent(dark)
                                            : border,
                                        width: _specialistIndex == i ? 1.6 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          ProductPricing.specialists[i].title,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: OTTypography.captionMedium(
                                            color: _specialistIndex == i ? ink : muted,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ProductPricing.rupiah(ProductPricing
                                              .specialists[i].amount),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),

                        PromoPrice(
                          amount: ProductPricing
                              .specialists[_specialistIndex].amount,
                          regularAmount: ProductPricing
                              .specialists[_specialistIndex].regularAmount,
                          period: ProductPricing
                              .specialists[_specialistIndex].period,
                        ),
                        const SizedBox(height: 16),
                        Divider(
                            color: border.withValues(alpha: 0.6), height: 1),
                        const SizedBox(height: 16),

                        // Daftar Benefit Spesialis Per Bidang
                        _benefitRow(
                          Loc.tr('planSingleBenefit1', [selected.title]),
                          ink,
                        ),
                        _benefitRow(
                          Loc.tr('planSingleBenefit2'),
                          ink,
                        ),
                        _benefitRow(
                          Loc.tr('planSingleBenefit3'),
                          ink,
                        ),
                        _benefitRow(
                          Loc.tr('planSingleBenefit4'),
                          ink,
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _processing
                                ? null
                                : () => _checkout(
                                    selected,
                                    ProductPricing
                                        .specialists[_specialistIndex]),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(Loc.tr('continuePayment')),
                          ),
                        ),
                        _checkoutNotice(selected.id),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_processing)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: _processing
                        ? null
                        : () => RedeemCodeSheet.show(context),
                    icon: const Icon(Icons.confirmation_number_outlined),
                    label: Text(Loc.tr('redeemAccess')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
