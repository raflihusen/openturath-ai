import '../widgets/adaptive_sheet.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  List<AgentModel> get _specialists => AgentModel.defaultAgents.where((a) =>
    a.kind == CorpusKind.discipline && a.isActive && a.id != 'fiqh_tahawwulat').toList();

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
    final border = OTColors.border(dark);
    if (flagship) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141418),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF383842),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: child,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: OTColors.surface(dark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.0),
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

  void _showDisciplinePickerModal(BuildContext context, List<AgentModel> specialists) {
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
                                    ? OTColors.accent(dark).withValues(alpha: 0.1)
                                    : surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? OTColors.accent(dark) : border,
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
                                    Icon(Icons.check_circle_rounded, color: OTColors.accent(dark), size: 20),
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
    final flagship = AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat');
    final offer = ProductPricing.tahawwulat[_tahawwulatIndex];
    final specialists = _specialists;
    final selected = specialists.firstWhere((a) => a.id == _selectedAgentId,
      orElse: () => specialists.first);

    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      appBar: AppBar(title: Text(AppCopy.subscription), backgroundColor: OTColors.canvas(dark)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(Loc.tr('launchOffer'), style: OTTypography.pageTitle(color: ink)),
                  const SizedBox(height: 8),
                  Text(AppCopy.manualRenewalNotice, style: OTTypography.body(color: muted)),
                  const SizedBox(height: 24),

                  // ── 1. KARTU HITAM ELEGAN: SUPER AI FIKIH TAHAWWULAT (FLAGSHIP) ──
                  _card(
                    flagship: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22222A),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF40404C),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.white),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'KORPUS UTAMA · 5 BILIK AI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.6),
                              ),
                              child: const Text(
                                'Eksklusif',
                                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(AppCopy.planTahawwulat, style: OTTypography.pageTitle(color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(
                          'Akses penuh ke 5 persona AI spesialis (Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, Al-Khatib) yang dilatih dari 50+ kitab otoritatif & ribuan jam transkrip muhadharah Al-Habib Abu Bakar Al-Adni.',
                          style: OTTypography.body(color: const Color(0xFFA1A1AA)).copyWith(fontSize: 13, height: 1.45),
                        ),
                        const SizedBox(height: 20),

                        // Tier Selector Cards
                        Row(
                          children: [
                            for (var i = 0; i < ProductPricing.tahawwulat.length; i++) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: _processing ? null : () => setState(() => _tahawwulatIndex = i),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: _tahawwulatIndex == i
                                          ? const Color(0xFF2A2A34)
                                          : Colors.white.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _tahawwulatIndex == i ? Colors.white : const Color(0xFF383842),
                                        width: _tahawwulatIndex == i ? 1.4 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          ProductPricing.tahawwulat[i].title,
                                          style: OTTypography.captionMedium(
                                            color: _tahawwulatIndex == i ? Colors.white : const Color(0xFFA1A1AA),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ProductPricing.rupiah(ProductPricing.tahawwulat[i].amount),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
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
                        PromoPrice(amount: offer.amount, regularAmount: offer.regularAmount, period: offer.period),
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
                        const SizedBox(height: 16),

                        // Daftar Benefit Fikih Tahawwulat
                        _benefitRow(
                          'Akses Eksklusif ke Super AI Fikih Tahawwulat yang Pertama Di Dunia',
                          Colors.white.withValues(alpha: 0.9),
                        ),
                        _benefitRow(
                          'Akses 5 Persona AI spesialis (Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, Al-Khatib)',
                          Colors.white.withValues(alpha: 0.9),
                        ),
                        _benefitRow(
                          'Uji Pemahaman Interaktif & Evaluasi Mandiri',
                          Colors.white.withValues(alpha: 0.9),
                        ),
                        _benefitRow(
                          'Akses Arsip Muhadharah & Transkrip Al-Habib Abu Bakar Al-Adni',
                          Colors.white.withValues(alpha: 0.9),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _processing ? null : () => _checkout(flagship, offer),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF141418),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Pilih Paket Fikih Tahawwulat (${offer.title})',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 2. KARTU SPESIALIS PER BIDANG LAINNYA ──
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Loc.tr('specialistAccess'), style: OTTypography.pageTitle(color: ink)),
                        const SizedBox(height: 6),
                        Text(
                          'Akses satu bidang keilmuan beserta kitab rujukannya 24/7.',
                          style: OTTypography.body(color: muted).copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 16),

                        // Interactive Tactile Discipline Card
                        InkWell(
                          onTap: _processing ? null : () => _showDisciplinePickerModal(context, specialists),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: dark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selected.title,
                                        style: OTTypography.bodyMedium(color: ink),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                        style: OTTypography.captionMedium(color: ink).copyWith(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.unfold_more_rounded, size: 16, color: muted),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Quick horizontal chips for top disciplines
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: specialists.length > 8 ? 8 : specialists.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (ctx, i) {
                              final spec = specialists[i];
                              final isSel = spec.id == selected.id;
                              return ChoiceChip(
                                label: Text(spec.title),
                                selected: isSel,
                                onSelected: _processing ? null : (_) => setState(() => _selectedAgentId = spec.id),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        PromoPrice(
                          amount: ProductPricing.specialist.amount,
                          regularAmount: ProductPricing.specialist.regularAmount,
                          period: ProductPricing.specialist.period,
                        ),
                        const SizedBox(height: 16),
                        Divider(color: border.withValues(alpha: 0.6), height: 1),
                        const SizedBox(height: 16),

                        // Daftar Benefit Spesialis Per Bidang
                        _benefitRow(
                          'Akses Penuh AI Spesialis ${selected.title} 24/7',
                          ink,
                        ),
                        _benefitRow(
                          'Temukan Ibarah & Konsep dalam waktu tersingkat',
                          ink,
                        ),
                        _benefitRow(
                          'Rujukan terperinci mencakup nama kitab, jilid dan halaman dengan akurasi tinggi',
                          ink,
                        ),
                        _benefitRow(
                          'Permudah pemahaman konsep melalui ibarah dan penjelasan yang disederhanakan dan tersusun',
                          ink,
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _processing ? null : () => _checkout(selected, ProductPricing.specialist),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(Loc.tr('continuePayment')),
                          ),
                        ),
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
                    onPressed: _processing ? null : () => RedeemCodeSheet.show(context),
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
