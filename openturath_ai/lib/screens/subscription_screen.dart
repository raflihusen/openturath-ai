import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/design/native_design.dart';
import '../widgets/native_components.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/product_pricing.dart';
import '../models/agent_model.dart';
import '../services/subscription_service.dart';
import '../widgets/doku_checkout_sheet.dart';
import '../widgets/promo_price.dart';
import '../widgets/redeem_code_sheet.dart';

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
  bool _processing = false;
  bool _initialized = false;
  bool _isTahawwulat = true;

  List<AgentModel> get _specialists => AgentModel.defaultAgents.where((a) =>
    a.kind == CorpusKind.discipline && a.isActive && a.id != 'fiqh_tahawwulat').toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    final agent = args is Map ? args['agent'] : null;
    if (agent is AgentModel) _isTahawwulat = agent.id.startsWith('fiqh_tahawwulat');
    if (agent is AgentModel && _specialists.any((a) => a.id == agent.id)) {
      _selectedAgentId = agent.id;
    }
  }

  Future<void> _checkout(AgentModel agent, SubscriptionOffer offer) async {
    if (_processing) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      AppSnackBar.warning(context, Loc.tr('signInRequired'));
      return;
    }
    setState(() => _processing = true);
    try {
      final title = '${agent.title} · ${offer.title}';
      final result = await _service.createPayment(uid: user.uid, agentId: agent.id,
        plan: offer.plan, planTitle: title, amount: offer.amount,
        name: user.displayName ?? user.email?.split('@').first ?? AppCopy.ahlanDefault,
        email: user.email ?? '', phone: user.phoneNumber ?? '');
      if (!mounted) return;
      // An old backend or stale quote must never open a differently priced checkout.
      if (result['amount'] != offer.amount || result['pricingRevision'] != ProductPricing.revision) {
        AppSnackBar.warning(context, Loc.tr('priceChanged'));
        return;
      }
      final paymentUrl = result['redirectUrl'];
      final invoice = result['invoiceNumber'];
      if (paymentUrl is! String || Uri.tryParse(paymentUrl)?.scheme != 'https' ||
          invoice is! String || invoice.isEmpty) {
        throw const FormatException('Invalid checkout response');
      }
      final paid = await DokuCheckoutSheet.show(context,
        paymentUrl: paymentUrl, invoiceNumber: invoice, trxId: result['trxId'] as String?,
        planTitle: title, amount: offer.amount, regularAmount: offer.regularAmount,
        periodLabel: offer.period);
      if (mounted && paid == true) {
        AppSnackBar.success(context, Loc.tr('paymentConfirmed'));
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, Loc.tr('checkoutError'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }



  Widget _card({required Widget child, bool flagship = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = NativeColors.border(dark);
    return Container(
      decoration: BoxDecoration(
        color: NativeColors.surface(dark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.0),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  void _showDisciplinePickerModal(BuildContext context, List<AgentModel> specialists) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = NativeColors.textPrimary(dark);
    final muted = NativeColors.textSecondary(dark);
    final border = NativeColors.border(dark);
    final surface = NativeColors.surface(dark);

    showModalBottomSheet<void>(
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
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.92,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
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
                            onChanged: (val) => setModalState(() => query = val),
                            decoration: InputDecoration(
                              hintText: Loc.tr('searchBooks'),
                              prefixIcon: Icon(Icons.search_rounded, size: 20, color: muted),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? NativeColors.accent(dark).withValues(alpha: 0.1)
                                    : surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? NativeColors.accent(dark) : border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.title,
                                          style: OTTypography.bodyMedium(color: ink).copyWith(
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, color: NativeColors.accent(dark), size: 20),
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
    final specialists = _specialists;
    final flagship = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final selected = _isTahawwulat ? flagship : specialists.firstWhere((a) => a.id == _selectedAgentId, orElse: () => specialists.first);
    final offer = _isTahawwulat ? ProductPricing.tahawwulat[_tahawwulatIndex] : ProductPricing.specialist;
    return Scaffold(
      backgroundColor: NativeColors.canvas(dark),
      appBar: AppBar(title: Text(AppCopy.subscription)),
      body: SafeArea(child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text(NativeCopy.text('selectedAccess'), style: NativeType.title(dark, size: 30)),
          const SizedBox(height: 12),
          Text(AppCopy.manualRenewalNotice, style: NativeType.body(dark)),
          const SizedBox(height: 24),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(label: Text(AppCopy.planTahawwulat), selected: _isTahawwulat,
              onSelected: _processing ? null : (_) => setState(() => _isTahawwulat = true)),
            ChoiceChip(label: Text(Loc.tr('specialistAccess')), selected: !_isTahawwulat,
              onSelected: _processing ? null : (_) => setState(() => _isTahawwulat = false)),
          ]),
          const SizedBox(height: 20),
          NativeSection(collection: _isTahawwulat, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_isTahawwulat) ...[
              Text(NativeCopy.text('exclusive'), style: NativeType.meta(dark).copyWith(color: NativeColors.brass(dark))),
              const SizedBox(height: 12),
            ],
            Text(Loc.isArabic ? selected.titleArabic : selected.title, style: NativeType.title(dark)),
            const SizedBox(height: 10),
            Text(_isTahawwulat ? NativeCopy.text('allFive') : Loc.text(selected.subtitleAcademic), style: NativeType.body(dark)),
            const SizedBox(height: 20),
            if (_isTahawwulat)
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < ProductPricing.tahawwulat.length; i++)
                  ChoiceChip(label: Text(ProductPricing.tahawwulat[i].title), selected: _tahawwulatIndex == i,
                    onSelected: _processing ? null : (_) => setState(() => _tahawwulatIndex = i)),
              ])
            else
              OutlinedButton.icon(onPressed: _processing ? null : () => _showDisciplinePickerModal(context, specialists),
                icon: const Icon(Icons.unfold_more_rounded), label: Text(Loc.tr('chooseField'))),
            const SizedBox(height: 24),
            PromoPrice(amount: offer.amount, regularAmount: offer.regularAmount, period: offer.period),
            const SizedBox(height: 24),
            FilledButton(onPressed: _processing ? null : () => _checkout(selected, offer),
              child: Text(_processing ? NativeCopy.text('loading') : Loc.tr('continuePayment'))),
          ])),
          const SizedBox(height: 16),
          TextButton.icon(onPressed: _processing ? null : () => RedeemCodeSheet.show(context),
            icon: const Icon(Icons.confirmation_number_outlined), label: Text(Loc.tr('redeemAccess'))),
        ]),
      ))),
    );
  }
}
