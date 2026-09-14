import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/constants.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/subscription_service.dart';
import '../widgets/doku_checkout_sheet.dart';
import '../widgets/redeem_code_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// Halaman Langganan OpenTurath (Quiet Scholar Adaptive)
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final SubscriptionService _subService = SubscriptionService();
  UserModel? _user;
  AgentModel? _agent;
  bool _isProcessing = false;
  int _selectedDurationIndex = 0; // 0: 1 Bulan, 1: 6 Bulan, 2: 1 Tahun

  List<AgentModel> get _activeAgents =>
      AgentModel.defaultAgents.where((a) => a.isActive).toList();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserModel) {
        _user = args;
      } else if (args is Map<String, dynamic>) {
        _user = args['user'] as UserModel?;
        _agent = args['agent'] as AgentModel?;
      }

      final fbUser = FirebaseAuth.instance.currentUser;
      if (_user == null && fbUser != null) {
        _user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ??
              (fbUser.email?.split('@').first ?? 'Santri Peneliti'),
          photoUrl: fbUser.photoURL ?? '',
          plan: 'trial',
          questionsUsed: 0,
        );
      }

      _agent ??= AgentModel.defaultAgents.firstWhere(
        (a) => a.id == 'fiqh_tahawwulat',
        orElse: () => AgentModel.defaultAgents.first,
      );
      if (_agent != null && _agent!.isComingSoon && _activeAgents.isNotEmpty) {
        _agent = _activeAgents.first;
      }
    }
  }

  Future<String?> _getOrPromptPhone() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final phoneKey = 'openturath_${uid}_user_phone';
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(phoneKey) ?? '';
      if (saved.isNotEmpty && saved.length >= 8) {
        return saved;
      }
    } catch (_) {}

    if (!mounted) return null;
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    String? phone;
    try {
      phone = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: OTRadius.dialogBorder,
            side: BorderSide(color: border, width: 0.8),
          ),
          title: Text(
            'Nomor WhatsApp',
            style: OTTypography.cardTitle(color: textPrimary).copyWith(fontSize: 17),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan nomor WhatsApp aktif untuk konfirmasi pembayaran dan aktivasi langganan.',
                style: OTTypography.body(color: textSecondary).copyWith(fontSize: 13),
              ),
              const SizedBox(height: OTSpacing.base),
              TextField(
                controller: textController,
                keyboardType: TextInputType.phone,
                autofocus: true,
                style: OTTypography.body(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contoh: 081234567890',
                  hintStyle: OTTypography.body(color: textSecondary),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: OTRadius.inputBorder,
                    borderSide: BorderSide(color: border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                OTMotion.light();
                Navigator.pop(ctx, null);
              },
              child: Text('Batal', style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                final val = textController.text.trim();
                if (val.length < 8) {
                  AppSnackBar.warning(ctx, 'Masukkan nomor telepon yang valid.');
                  return;
                }
                OTMotion.success();
                Navigator.pop(ctx, val);
              },
              style: FilledButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text('Lanjutkan pembayaran', style: OTTypography.button()),
            ),
          ],
        ),
      );
    } finally {
      textController.dispose();
    }

    if (phone != null && phone.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(phoneKey, phone);
      } catch (_) {}
    }
    return phone;
  }

  Future<void> _handleSubscribe({
    required String plan,
    required String planTitle,
    required int price,
    AgentModel? targetAgent,
  }) async {
    final fbUser = FirebaseAuth.instance.currentUser;
    if (_user == null && fbUser != null) {
      _user = UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        name: fbUser.displayName ?? 'Santri Peneliti',
        photoUrl: fbUser.photoURL ?? '',
        plan: 'trial',
        questionsUsed: 0,
      );
    }

    if (_user == null) {
      AppSnackBar.warning(
        context,
        'Silakan masuk akun terlebih dahulu untuk berlangganan.',
      );
      return;
    }

    final phone = await _getOrPromptPhone();
    if (phone == null || phone.isEmpty) return;

    final currentAgent = targetAgent ?? _agent;

    setState(() {
      _isProcessing = true;
    });

    String? dokuUrl;
    String invoiceNumber = '';
    String trxId = '';

    try {
      final userName = _user!.name.trim().isNotEmpty
          ? _user!.name.trim()
          : (_user!.email.isNotEmpty ? _user!.email.split('@').first : 'Santri Peneliti');

      final result = await _subService
          .createPayment(
            uid: _user!.uid,
            agentId: currentAgent?.id ?? 'all_ai',
            plan: plan,
            planTitle: planTitle,
            amount: price,
            name: userName,
            email: _user!.email,
            phone: phone,
          )
          .timeout(const Duration(seconds: 20));

      final redirectUrl = result['redirectUrl'] as String?;
      invoiceNumber = (result['invoiceNumber'] as String?) ?? '';
      trxId = (result['trxId'] as String?) ?? '';
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        dokuUrl = redirectUrl;
      } else {
        throw Exception('DOKU PG tidak mengembalikan URL pembayaran valid');
      }
    } catch (err) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'Terjadi kendala saat menyiapkan sesi pembayaran. Periksa koneksi internet Anda lalu coba kembali.',
      );
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    try {
      if (!mounted) return;
      final isPaid = await DokuCheckoutSheet.show(
        context,
        paymentUrl: dokuUrl,
        invoiceNumber: invoiceNumber,
        trxId: trxId,
        planTitle: planTitle,
        amount: price,
      );

      if (isPaid == true) {
        if (!mounted) return;
        AppSnackBar.success(
          context,
          'Pembayaran berhasil. Akses sudah aktif.',
          duration: const Duration(seconds: 4),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'Tidak dapat membuka sesi pembayaran saat ini. Silakan coba kembali.',
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    final activeList = _activeAgents;

    // Pricing tiers untuk AI Spesialis Terpilih
    final moduleTiers = [
      {'name': '1 Bulan', 'price': 49000, 'label': 'Rp 49.000', 'period': '/ bulan', 'planId': AppConstants.planTholib1m},
      {'name': '6 Bulan', 'price': 299000, 'label': 'Rp 299.000', 'period': '/ 6 bulan', 'planId': AppConstants.planTholib6m},
      {'name': '1 Tahun', 'price': 499000, 'label': 'Rp 499.000', 'period': '/ tahun', 'planId': AppConstants.planBahits1y},
    ];

    final currentTier = moduleTiers[_selectedDurationIndex];
    final tierPrice = currentTier['price'] as int;
    final tierLabel = currentTier['label'] as String;
    final tierPeriod = currentTier['period'] as String;
    final tierPlanId = currentTier['planId'] as String;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Langganan',
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isProcessing,
        child: Column(
          children: [
            if (_isProcessing)
              LinearProgressIndicator(
                minHeight: 2.5,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, 108),
                children: [
                  // Editorial Header
                  Text(
                    'Pilihan langganan',
                    style: OTTypography.editorialHero(color: textPrimary).copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih paket langganan untuk menelaah ibarah dan rujukan kitab turats.',
                    style: OTTypography.body(color: textSecondary).copyWith(fontSize: 13),
                  ),

                  const SizedBox(height: OTSpacing.sm),

                  // Pintu masuk redeem kode akses voucher
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppleInteractiveWrapper(
                      onTap: () => RedeemCodeSheet.show(context, onSuccess: () {
                        if (mounted) setState(() {});
                      }),
                      pressedScale: 0.96,
                      hapticType: HapticFeedbackType.selection,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_number_outlined, size: 16, color: accent),
                            const SizedBox(width: 6),
                            Text(
                              'Punya kode voucher? Masukkan di sini',
                              style: OTTypography.button(color: accent).copyWith(fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: OTSpacing.sm),

                  // ── Unified Module Package Card: Modul Spesialis Terpilih ──
                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(
                        color: textPrimary,
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.all(OTSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Paket per bidang',
                              style: OTTypography.sectionHeading(color: accent),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: surfaceSubtle,
                                borderRadius: OTRadius.chipBorder,
                              ),
                              child: Text(
                                '1 bidang',
                                style: OTTypography.captionMedium(color: textSecondary).copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        Text(
                          'Pilih bidang',
                          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Akses satu bidang beserta kitab rujukannya.',
                          style: OTTypography.body(color: textSecondary).copyWith(fontSize: 13),
                        ),

                        const SizedBox(height: OTSpacing.md),

                        DropdownButtonFormField<String>(
                          initialValue: _agent?.id ?? (activeList.isNotEmpty ? activeList.first.id : 'fiqh_tahawwulat'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            filled: true,
                            fillColor: surfaceSubtle,
                            border: OutlineInputBorder(
                              borderRadius: OTRadius.inputBorder,
                              borderSide: BorderSide(color: border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: OTRadius.inputBorder,
                              borderSide: BorderSide(color: border),
                            ),
                          ),
                          dropdownColor: surface,
                          items: activeList.map((a) {
                            return DropdownMenuItem<String>(
                              value: a.id,
                              child: Text(
                                a.title,
                                style: OTTypography.bodyMedium(color: textPrimary).copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _agent = activeList.firstWhere((a) => a.id == val);
                              });
                            }
                          },
                        ),

                        const SizedBox(height: OTSpacing.lg),

                        // Segmented Control Durasi
                        Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: surfaceSubtle,
                            borderRadius: OTRadius.chipBorder,
                            border: Border.all(color: border, width: 0.8),
                          ),
                          child: Row(
                            children: List.generate(moduleTiers.length, (idx) {
                              final tier = moduleTiers[idx];
                              final isSelected = _selectedDurationIndex == idx;
                              return Expanded(
                                child: AppleInteractiveWrapper(
                                  onTap: () {
                                    OTMotion.selection();
                                    setState(() => _selectedDurationIndex = idx);
                                  },
                                  pressedScale: 0.94,
                                  hapticType: HapticFeedbackType.selection,
                                  child: AnimatedContainer(
                                    duration: OTMotion.fast,
                                    curve: OTMotion.curve,
                                    decoration: BoxDecoration(
                                      color: isSelected ? textPrimary : Colors.transparent,
                                      borderRadius: OTRadius.chipBorder,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      tier['name'] as String,
                                      style: OTTypography.caption(
                                        color: isSelected ? canvas : textSecondary,
                                      ).copyWith(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: OTSpacing.lg),

                        // Price Display
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              tierLabel,
                              style: OTTypography.price(color: textPrimary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tierPeriod,
                              style: OTTypography.caption(color: textSecondary),
                            ),
                          ],
                        ),

                        const SizedBox(height: OTSpacing.base),
                        Divider(color: border.withValues(alpha: 0.6), height: 1),
                        const SizedBox(height: OTSpacing.base),

                        // Core Benefits (Quiet Scholar Natural Phrasing)
                        _benefitRow(
                          'Akses Asisten ${_agent?.title ?? "terpilih"}',
                          textPrimary,
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow(
                          'Telusuri ibarah dan penjelasan dari kitab rujukan',
                          textPrimary,
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow(
                          'Lihat kitab, jilid, dan halaman yang dirujuk',
                          textPrimary,
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow(
                          'Cocokkan ibarah dengan kitab cetak atau digital',
                          textPrimary,
                        ),

                        const SizedBox(height: OTSpacing.lg),

                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: AppleInteractiveWrapper(
                            onTap: _isProcessing
                                ? null
                                : () {
                                    _handleSubscribe(
                                      plan: tierPlanId,
                                      planTitle: '${currentTier['name']} ${_agent?.title ?? ""}'.trim(),
                                      price: tierPrice,
                                      targetAgent: _agent,
                                    );
                                  },
                            pressedScale: 0.97,
                            hapticType: HapticFeedbackType.light,
                            borderRadius: BorderRadius.circular(OTRadius.button),
                            child: FilledButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      _handleSubscribe(
                                        plan: tierPlanId,
                                        planTitle: '${currentTier['name']} ${_agent?.title ?? ""}'.trim(),
                                        price: tierPrice,
                                        targetAgent: _agent,
                                      );
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: textPrimary,
                                foregroundColor: canvas,
                                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                                elevation: 0,
                              ),
                              child: Text(
                                'Pilih paket ${_agent?.title ?? ""} ($tierLabel)',
                                style: OTTypography.button(color: canvas),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OTSpacing.lg),

                  // ── Bundling Card: Semua Bidang (Segera Hadir) ──
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(
                        color: border,
                        width: 0.8,
                      ),
                    ),
                    padding: const EdgeInsets.all(OTSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'Paket semua bidang',
                                style: OTTypography.sectionHeading(color: textSecondary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: OTRadius.chipBorder,
                                border: Border.all(color: border, width: 0.6),
                              ),
                              child: Text(
                                'Segera hadir',
                                style: OTTypography.captionMedium(color: textSecondary).copyWith(
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        Text(
                          'Akses semua bidang',
                          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Satu paket untuk mengakses seluruh bidang yang tersedia beserta kitab rujukannya.',
                          style: OTTypography.body(color: textSecondary).copyWith(fontSize: 12.5),
                        ),
                        const SizedBox(height: OTSpacing.base),
                        Divider(color: border.withValues(alpha: 0.5), height: 1),
                        const SizedBox(height: OTSpacing.base),
                        _benefitRow('Akses ke seluruh bidang yang tersedia', textSecondary),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow('Akses lintas bidang dalam satu langganan', textSecondary),
                        const SizedBox(height: OTSpacing.sm),
                        _benefitRow('Pembaruan berkala seluruh kitab rujukan', textSecondary),
                        const SizedBox(height: OTSpacing.md),
                        // Catatan Edukatif
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(OTSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF18181B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: border.withValues(alpha: 0.8),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Paket semua bidang sedang disiapkan.',
                                  style: OTTypography.body(color: textSecondary).copyWith(
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: OTSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton(
                            onPressed: null, // Dinonaktifkan sesuai arahan
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: border),
                              shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline_rounded, size: 16, color: textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Segera Hadir',
                                  style: OTTypography.button(color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: OTSpacing.lg),

                  // ── Catatan Transparansi Pembelian (Bab 4 & Bab 10.4) ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(OTSpacing.base),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppCopy.manualRenewalNotice,
                            style: OTTypography.caption(color: textSecondary).copyWith(
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_rounded,
            size: 15,
            color: textColor.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: OTTypography.body(color: textColor).copyWith(
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
