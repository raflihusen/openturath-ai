import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
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
import '../core/goakal_catalog_registry.dart';

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
  bool _isSyncingGoAkal = false;

  // Durasi terpisah untuk masing-masing kartu
  int _selectedSegment =
      0; // 0: 6 Paket Tematik (Launch Promo), 1: AI Satuan Spesifik
  final Map<String, int> _bundleDurationIndices = {};
  int _tahawwulatDurationIndex = 0; // 0: 1 Bulan, 1: 6 Bulan, 2: 1 Tahun
  int _otherDurationIndex = 0; // 0: 1 Bulan, 1: 6 Bulan, 2: 1 Tahun
  AgentModel? _selectedOtherAgent;

  AgentModel get _tahawwulatAgent => AgentModel.defaultAgents.firstWhere(
        (a) => a.id == 'fiqh_tahawwulat',
        orElse: () => AgentModel.defaultAgents.first,
      );

  List<AgentModel> get _otherAgents => AgentModel.defaultAgents
      .where((a) => a.isActive && a.id != 'fiqh_tahawwulat')
      .toList();

  // Tier resmi GoAkal AI Fikih Tahawwulat (Direct Apply Links)
  static const List<Map<String, dynamic>> _tahawwulatTiers = [
    {
      'name': '1 Bulan',
      'price': 1000000,
      'label': 'Rp 1.000.000',
      'period': '/ bulan',
      'planId': 'tahawwulat_1m',
      'applyUrl':
          'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/1js2e/apply',
    },
    {
      'name': '6 Bulan',
      'price': 2995000,
      'label': 'Rp 2.995.000',
      'period': '/ 6 bulan',
      'planId': 'tahawwulat_6m',
      'applyUrl':
          'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/sp6zh/apply',
    },
    {
      'name': '1 Tahun',
      'price': 4995000,
      'label': 'Rp 4.995.000',
      'period': '/ tahun',
      'planId': 'tahawwulat_1y',
      'applyUrl':
          'https://goakal.com/openturath-ai/ai-fikih-tahawwulat/8yt9m/apply',
    },
  ];

  // Tier untuk disiplin ilmu lainnya berbasis GoAkal Registry Otomatis
  List<Map<String, dynamic>> _getOtherTiers(AgentModel? agent) {
    return GoAkalCatalogRegistry.getTiersForAgent(agent?.id);
  }

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

      final others = _otherAgents;
      if (_selectedOtherAgent == null && others.isNotEmpty) {
        if (_agent != null && _agent!.id != 'fiqh_tahawwulat') {
          _selectedOtherAgent = others.firstWhere(
            (a) => a.id == _agent!.id,
            orElse: () => others.first,
          );
        } else {
          _selectedOtherAgent = others.firstWhere(
            (a) => a.id == 'fiqh_syafii',
            orElse: () => others.first,
          );
        }
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
            style: OTTypography.cardTitle(color: textPrimary)
                .copyWith(fontSize: 17),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan nomor WhatsApp aktif untuk konfirmasi pembayaran dan aktivasi langganan.',
                style: OTTypography.body(color: textSecondary)
                    .copyWith(fontSize: 13),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              child: Text('Batal',
                  style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () {
                final val = textController.text.trim();
                if (val.length < 8) {
                  AppSnackBar.warning(
                      ctx, 'Masukkan nomor telepon yang valid.');
                  return;
                }
                OTMotion.success();
                Navigator.pop(ctx, val);
              },
              style: FilledButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor:
                    isDark ? const Color(0xFF18181B) : Colors.white,
                shape:
                    RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
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

  Future<void> _syncAkalPurchases({bool isSilent = false}) async {
    if (_isSyncingGoAkal) return;
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      if (!isSilent && mounted) {
        AppSnackBar.warning(
          context,
          'Silakan masuk akun terlebih dahulu untuk menyinkronkan data langganan.',
        );
      }
      return;
    }

    setState(() => _isSyncingGoAkal = true);
    if (!isSilent && mounted) {
      AppSnackBar.info(
        context,
        'Menyinkronkan transaksi GoAkal dengan akun Google Anda...',
      );
    }

    try {
      final res = await _subService.syncAkalPurchases();
      final success = res['success'] == true;
      final syncedList =
          (res['synced'] as List<dynamic>?)?.cast<String>() ?? [];
      final message = res['message'] as String? ?? '';

      if (!mounted) return;

      if (success && syncedList.isNotEmpty) {
        AppSnackBar.success(
          context,
          'Alhamdulillah! Akses aktif berhasil disinkronkan: ${syncedList.join(", ")}.',
          duration: const Duration(seconds: 4),
        );
        setState(() {});
      } else if (!isSilent) {
        AppSnackBar.info(
          context,
          message.isNotEmpty
              ? message
              : 'Belum ditemukan transaksi aktif baru di GoAkal untuk email ini.',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (_) {
      if (!isSilent && mounted) {
        AppSnackBar.error(
          context,
          'Kendala saat menghubungi server GoAkal. Periksa koneksi internet Anda.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncingGoAkal = false);
    }
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  Future<void> _showWhatsAppActivationSheet({
    required String title,
    required String subtitle,
    required String priceLabel,
    required String periodLabel,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Belum terdaftar';
    final name = (user?.displayName?.isNotEmpty == true)
        ? user!.displayName!
        : 'Thalibul Ilmi';

    final message = '''Assalamu'alaikum Khadim OpenTurath AI,
Saya ingin mengaktifkan rujukan paket berikut:
• Paket: $title
• Masa Akses: $subtitle ($priceLabel $periodLabel)
• Akun: $email ($name)

Mohon panduan aktivasi resmi khazanah turath. Terima kasih.''';

    final waUrl = Uri.parse(
        'https://wa.me/6281292979189?text=${Uri.encodeComponent(message)}');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final canvasColor =
            isDark ? const Color(0xFF181817) : const Color(0xFFFFFFFF);
        final textColor =
            isDark ? const Color(0xFFF4F4F0) : const Color(0xFF171717);
        final subTextColor =
            isDark ? const Color(0xFFB2B2AA) : const Color(0xFF656560);
        final borderColor =
            isDark ? const Color(0xFF30302E) : const Color(0xFFDDDDD8);

        return Container(
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF222220)
                          : const Color(0xFFEEEEEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.verified_outlined,
                        color: textColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktivasi Khazanah Turats',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Layanan Khusus Tim Khadim OpenTurath',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF111110)
                      : const Color(0xFFF6F6F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.newsreader(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$subtitle • $priceLabel $periodLabel',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                    const Divider(height: 20, thickness: 0.8),
                    Text(
                      'Email Akun: $email',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Paket ini diproses langsung melalui Khadim Resmi via WhatsApp untuk memastikan konfigurasi lisensi korpus dan verifikasi akses instan tanpa kendala.',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  height: 1.4,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(
                    'Hubungi Khadim via WhatsApp',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFFF4F4F0)
                        : const Color(0xFF171717),
                    foregroundColor: isDark
                        ? const Color(0xFF171717)
                        : const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final storeUri = Uri.parse(GoAkalCatalogRegistry.storeUrl);
                    if (await canLaunchUrl(storeUri)) {
                      await launchUrl(storeUri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    'Buka Katalog Web Resmi GoAkal',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: subTextColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBundleCheckout({
    required ThematicBundleMeta bundle,
    required int durationIndex,
  }) async {
    final tiers = bundle.tiers;
    if (tiers.isEmpty) return;
    final safeIdx = durationIndex < tiers.length ? durationIndex : 0;
    final tier = tiers[safeIdx];

    // Jika paket bundle belum live langsung di link GoAkal, arahkan via WhatsApp resmi
    if (!tier.isLiveOnGoAkal) {
      await _showWhatsAppActivationSheet(
        title: bundle.title,
        subtitle: tier.title,
        priceLabel: tier.priceLabel,
        periodLabel: tier.periodLabel,
      );
      return;
    }

    final planTitle = '${bundle.title} (${tier.title})';
    await DokuCheckoutSheet.show(
      context,
      paymentUrl: tier.applyUrl,
      invoiceNumber: '',
      planTitle: planTitle,
      amount: tier.amount,
    );

    if (mounted) {
      await _syncAkalPurchases(isSilent: false);
    }
  }

  Future<void> _handleTierCheckout({
    required Map<String, dynamic> tier,
    required AgentModel targetAgent,
  }) async {
    final rawApplyUrl = tier['applyUrl'] as String? ?? '';
    final planTitle = '${tier['name']} ${targetAgent.title}'.trim();
    final price = tier['price'] as int;

    // Jika URL apply tidak tersedia, arahkan ke WhatsApp resmi
    if (rawApplyUrl.isEmpty) {
      await _showWhatsAppActivationSheet(
        title: targetAgent.title,
        subtitle: (tier['name'] as String?) ?? '1 Bulan',
        priceLabel: (tier['label'] as String?) ?? 'Rp 49.000',
        periodLabel: (tier['period'] as String?) ?? '/ bulan',
      );
      return;
    }

    // Buka pop-up modal checkout in-app resmi GoAkal tanpa keluar aplikasi
    await DokuCheckoutSheet.show(
      context,
      paymentUrl: rawApplyUrl,
      invoiceNumber: '',
      planTitle: planTitle,
      amount: price,
    );

    // Otomatis sinkronkan status pembelian GoAkal begitu lembar transaksi ditutup
    if (mounted) {
      await _syncAkalPurchases(isSilent: false);
    }
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
          : (_user!.email.isNotEmpty
              ? _user!.email.split('@').first
              : 'Santri Peneliti');

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

    // Data kartu Fikih Tahawwulat (Flagship)
    final tahawwulatCurrentTier = _tahawwulatTiers[_tahawwulatDurationIndex];

    // Data kartu Disiplin Lainnya
    final otherList = _otherAgents;
    final otherTargetAgent = _selectedOtherAgent ??
        (otherList.isNotEmpty ? otherList.first : _tahawwulatAgent);
    final otherTiers = _getOtherTiers(otherTargetAgent);
    final safeOtherIndex =
        _otherDurationIndex < otherTiers.length ? _otherDurationIndex : 0;
    final otherCurrentTier = otherTiers[safeOtherIndex];

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
        actions: [
          IconButton(
            icon: _isSyncingGoAkal
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.sync_rounded, color: textPrimary),
            tooltip: 'Sinkronkan Pembelian GoAkal',
            onPressed: _isSyncingGoAkal
                ? null
                : () => _syncAkalPurchases(isSilent: false),
          ),
        ],
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
                padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, 108),
                children: [
                  // Editorial Header
                  Text(
                    'Pilihan langganan',
                    style: OTTypography.editorialHero(color: textPrimary)
                        .copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih paket langganan untuk menelaah ibarah dan rujukan kitab turats.',
                    style: OTTypography.body(color: textSecondary).copyWith(
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: OTSpacing.sm),

                  // Pintu masuk redeem kode akses voucher & sinkronisasi GoAkal
                  Row(
                    children: [
                      Expanded(
                        child: AppleInteractiveWrapper(
                          onTap: () =>
                              RedeemCodeSheet.show(context, onSuccess: () {
                            if (mounted) setState(() {});
                          }),
                          pressedScale: 0.96,
                          hapticType: HapticFeedbackType.selection,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: surfaceSubtle,
                              borderRadius: OTRadius.chipBorder,
                              border: Border.all(color: border, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.confirmation_number_outlined,
                                    size: 15, color: accent),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Punya voucher santri?',
                                    style: OTTypography.captionMedium(
                                            color: accent)
                                        .copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppleInteractiveWrapper(
                          onTap: _isSyncingGoAkal
                              ? null
                              : () => _syncAkalPurchases(isSilent: false),
                          pressedScale: 0.96,
                          hapticType: HapticFeedbackType.selection,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: surfaceSubtle,
                              borderRadius: OTRadius.chipBorder,
                              border: Border.all(color: border, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSyncingGoAkal)
                                  const SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 1.8),
                                  )
                                else
                                  Icon(Icons.sync_rounded,
                                      size: 15, color: textPrimary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _isSyncingGoAkal
                                        ? 'Sinkron...'
                                        : 'Cek akses GoAkal',
                                    style: OTTypography.captionMedium(
                                            color: textPrimary)
                                        .copyWith(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: OTSpacing.md),

                  // Catatan harga: informatif, tanpa nuansa promosi yang berisik.
                  Container(
                    margin: const EdgeInsets.only(bottom: OTSpacing.base),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(
                        color: border,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'HARGA PERDANA',
                              style:
                                  OTTypography.metadataTag(color: textPrimary),
                            ),
                            const Spacer(),
                            Text(
                              'hingga 50% lebih ringan',
                              style: OTTypography.caption(color: textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Harga perdana tersedia pada masa peluncuran. Setelah periode ini berakhir, harga dapat disesuaikan mengikuti pengembangan korpus dan layanan.',
                          style: OTTypography.caption(color: textSecondary)
                              .copyWith(fontSize: 12, height: 1.45),
                        ),
                      ],
                    ),
                  ),

                  // ── PILIHAN MODE: PAKET TEMATIK vs AI SATUAN ──
                  Container(
                    height: 44,
                    margin: const EdgeInsets.only(bottom: OTSpacing.lg),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: OTRadius.chipBorder,
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppleInteractiveWrapper(
                            onTap: () {
                              OTMotion.selection();
                              setState(() => _selectedSegment = 0);
                            },
                            pressedScale: 0.96,
                            child: AnimatedContainer(
                              duration: OTMotion.fast,
                              curve: OTMotion.curve,
                              decoration: BoxDecoration(
                                color: _selectedSegment == 0
                                    ? textPrimary
                                    : Colors.transparent,
                                borderRadius: OTRadius.chipBorder,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Paket tematik',
                                    style: OTTypography.caption(
                                      color: _selectedSegment == 0
                                          ? canvas
                                          : textPrimary,
                                    ).copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppleInteractiveWrapper(
                            onTap: () {
                              OTMotion.selection();
                              setState(() => _selectedSegment = 1);
                            },
                            pressedScale: 0.96,
                            child: AnimatedContainer(
                              duration: OTMotion.fast,
                              curve: OTMotion.curve,
                              decoration: BoxDecoration(
                                color: _selectedSegment == 1
                                    ? textPrimary
                                    : Colors.transparent,
                                borderRadius: OTRadius.chipBorder,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Asisten satuan',
                                style: OTTypography.caption(
                                  color: _selectedSegment == 1
                                      ? canvas
                                      : textSecondary,
                                ).copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_selectedSegment == 0) ...[
                    // ════════════════════════════════════════════════════════
                    // DAFTAR 6 PAKET TEMATIK (REKOMENDASI UTAMA SANTRI)
                    // ════════════════════════════════════════════════════════
                    ...GoAkalCatalogRegistry.thematicBundles.map((bundle) {
                      final currentDurationIdx =
                          _bundleDurationIndices[bundle.slug] ?? 0;
                      final tiers = bundle.tiers;
                      final safeTierIdx = currentDurationIdx < tiers.length
                          ? currentDurationIdx
                          : 0;
                      final activeTier =
                          tiers.isNotEmpty ? tiers[safeTierIdx] : null;

                      final isSultan = bundle.slug == 'paket-sultan-all-access';
                      final isFikih = bundle.slug == 'paket-fikih-pesantren';

                      return Container(
                        margin: const EdgeInsets.only(bottom: OTSpacing.lg),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF141418)
                              : const Color(0xFFFAF9F6),
                          borderRadius: OTRadius.cardBorder,
                          border: Border.all(
                            color: isSultan
                                ? (isDark
                                    ? const Color(0xFFEAB308)
                                    : const Color(0xFFCA8A04))
                                : (isFikih
                                    ? (isDark
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF059669))
                                    : (isDark
                                        ? const Color(0xFF383842)
                                        : const Color(0xFFD4D4D8))),
                            width: (isSultan || isFikih) ? 1.6 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.35 : 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(OTSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Badges
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: isSultan
                                        ? const Color(0xFFFEF3C7)
                                        : (isFikih
                                            ? const Color(0xFFD1FAE5)
                                            : (isDark
                                                ? const Color(0xFF22222A)
                                                : const Color(0xFFEEEEF0))),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    bundle.badgeText,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.9,
                                      color: isSultan
                                          ? const Color(0xFFB45309)
                                          : (isFikih
                                              ? const Color(0xFF047857)
                                              : textPrimary),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706)
                                        .withValues(alpha: 0.15),
                                    borderRadius: OTRadius.chipBorder,
                                    border: Border.all(
                                        color: const Color(0xFFD97706),
                                        width: 0.8),
                                  ),
                                  child: Text(
                                    '🏷️ HARGA KHUSUS LAUNCH',
                                    style: GoogleFonts.outfit(
                                      color: isDark
                                          ? const Color(0xFFFBBF24)
                                          : const Color(0xFFB45309),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: OTSpacing.sm),

                            // Judul & Subtitle
                            Text(
                              '${bundle.iconEmoji} ${bundle.title}',
                              style:
                                  OTTypography.corpusTitle(color: textPrimary)
                                      .copyWith(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              bundle.subtitle,
                              style: GoogleFonts.outfit(
                                color: textSecondary,
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                            const SizedBox(height: OTSpacing.base),

                            // Durasi Selector
                            if (tiers.isNotEmpty)
                              Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: surfaceSubtle,
                                  borderRadius: OTRadius.chipBorder,
                                  border: Border.all(color: border, width: 0.8),
                                ),
                                child: Row(
                                  children: List.generate(tiers.length, (idx) {
                                    final t = tiers[idx];
                                    final isSelected = safeTierIdx == idx;
                                    return Expanded(
                                      child: AppleInteractiveWrapper(
                                        onTap: () {
                                          OTMotion.selection();
                                          setState(() {
                                            _bundleDurationIndices[
                                                bundle.slug] = idx;
                                          });
                                        },
                                        pressedScale: 0.94,
                                        child: AnimatedContainer(
                                          duration: OTMotion.fast,
                                          curve: OTMotion.curve,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? textPrimary
                                                : Colors.transparent,
                                            borderRadius: OTRadius.chipBorder,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            t.durationKey == '1_month'
                                                ? '1 Bulan'
                                                : (t.durationKey == '6_months'
                                                    ? '6 Bulan'
                                                    : '1 Tahun'),
                                            style: OTTypography.caption(
                                              color: isSelected
                                                  ? canvas
                                                  : textSecondary,
                                            ).copyWith(
                                              fontSize: 11.5,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),

                            const SizedBox(height: OTSpacing.base),

                            // Harga Normal Coret & Harga Launching
                            if (activeTier != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    activeTier.priceLabel,
                                    style: GoogleFonts.outfit(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    activeTier.periodLabel,
                                    style: OTTypography.caption(
                                            color: textSecondary)
                                        .copyWith(fontSize: 13),
                                  ),
                                  const SizedBox(width: 10),
                                  if (safeTierIdx == 0) ...[
                                    Text(
                                      'Rp ${_formatRupiah(bundle.originalPrice1m)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary.withValues(
                                            alpha: 0.7),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                            const SizedBox(height: OTSpacing.base),
                            Divider(
                                color: border.withValues(alpha: 0.5),
                                height: 1),
                            const SizedBox(height: OTSpacing.base),

                            // Daftar AI yang didapat
                            ...bundle.includedItems.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _benefitRow(item, textSecondary),
                                )),

                            const SizedBox(height: OTSpacing.lg),

                            // Tombol Bayar Langsung GoAkal
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton(
                                onPressed: () => _handleBundleCheckout(
                                  bundle: bundle,
                                  durationIndex: safeTierIdx,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isSultan
                                      ? (isDark
                                          ? const Color(0xFFCA8A04)
                                          : const Color(0xFFD97706))
                                      : (isFikih
                                          ? (isDark
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF047857))
                                          : textPrimary),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: OTRadius.buttonBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ambil Akses ${bundle.title.split('(').first.trim()}',
                                      style: OTTypography.button(
                                              color: Colors.white)
                                          .copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    // ════════════════════════════════════════════════════════
                    // 1. KARTU MANDIRI MEWAH-MINIMALIS: FIKIH TAHAWWULAT
                    // ════════════════════════════════════════════════════════
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141418)
                            : const Color(0xFFFAF9F6),
                        borderRadius: OTRadius.cardBorder,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF383842)
                              : const Color(0xFFD4D4D8),
                          width: 1.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.35 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(OTSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF22222A)
                                      : const Color(0xFFEEEEF0),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF40404C)
                                        : const Color(0xFFD4D4D8),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.workspace_premium_rounded,
                                        size: 14, color: textPrimary),
                                    const SizedBox(width: 5),
                                    Text(
                                      'KORPUS UTAMA · 5 BILIK AI',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: surfaceSubtle,
                                  borderRadius: OTRadius.chipBorder,
                                  border: Border.all(color: border, width: 0.6),
                                ),
                                child: Text(
                                  'Eksklusif',
                                  style: OTTypography.captionMedium(
                                          color: textSecondary)
                                      .copyWith(fontSize: 10.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: OTSpacing.sm),
                          Text(
                            'Super AI Fikih Tahawwulat',
                            style: OTTypography.corpusTitle(color: textPrimary)
                                .copyWith(
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Akses penuh ke 5 persona AI spesialis (Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, Al-Khatib) yang dilatih dari 50+ kitab otoritatif & ribuan jam transkrip muhadharah Al-Habib Abu Bakar Al-Adni.',
                            style: OTTypography.body(color: textSecondary)
                                .copyWith(
                              fontSize: 12.8,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: OTSpacing.lg),

                          // Segmented Control Durasi Fikih Tahawwulat
                          Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: surfaceSubtle,
                              borderRadius: OTRadius.chipBorder,
                              border: Border.all(color: border, width: 0.8),
                            ),
                            child: Row(
                              children:
                                  List.generate(_tahawwulatTiers.length, (idx) {
                                final tier = _tahawwulatTiers[idx];
                                final isSelected =
                                    _tahawwulatDurationIndex == idx;
                                return Expanded(
                                  child: AppleInteractiveWrapper(
                                    onTap: () {
                                      OTMotion.selection();
                                      setState(
                                          () => _tahawwulatDurationIndex = idx);
                                    },
                                    pressedScale: 0.94,
                                    hapticType: HapticFeedbackType.selection,
                                    child: AnimatedContainer(
                                      duration: OTMotion.fast,
                                      curve: OTMotion.curve,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? textPrimary
                                            : Colors.transparent,
                                        borderRadius: OTRadius.chipBorder,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        tier['name'] as String,
                                        style: OTTypography.caption(
                                          color: isSelected
                                              ? canvas
                                              : textSecondary,
                                        ).copyWith(
                                          fontSize: 11.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: OTSpacing.lg),

                          // Price Display Tahawwulat
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                tahawwulatCurrentTier['label'] as String,
                                style: OTTypography.price(color: textPrimary)
                                    .copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                tahawwulatCurrentTier['period'] as String,
                                style:
                                    OTTypography.caption(color: textSecondary)
                                        .copyWith(fontSize: 13),
                              ),
                            ],
                          ),

                          const SizedBox(height: OTSpacing.base),
                          Divider(
                              color: border.withValues(alpha: 0.6), height: 1),
                          const SizedBox(height: OTSpacing.base),

                          _benefitRow(
                              '5 Bilik AI Spesialis Terpadu dalam Satu Ruang Kajian',
                              textPrimary),
                          const SizedBox(height: OTSpacing.sm),
                          _benefitRow(
                              'Verifikasi ibarah presisi ke kitab matan induk, jilid, & halaman',
                              textPrimary),
                          const SizedBox(height: OTSpacing.sm),
                          _benefitRow(
                              'Akses arsip ribuan jam muhadharah & transkrip lisan mualif',
                              textPrimary),
                          const SizedBox(height: OTSpacing.sm),
                          _benefitRow(
                              'Ujian nalar ilmiah interaktif & penyusun materi dakwah',
                              textPrimary),
                          const SizedBox(height: OTSpacing.sm),
                          _benefitRow(
                              'Terhubung langsung ke infrastruktur Google NotebookLM Pro',
                              textPrimary),

                          const SizedBox(height: OTSpacing.lg),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: AppleInteractiveWrapper(
                              onTap: _isProcessing
                                  ? null
                                  : () => _handleTierCheckout(
                                        tier: tahawwulatCurrentTier,
                                        targetAgent: _tahawwulatAgent,
                                      ),
                              pressedScale: 0.97,
                              hapticType: HapticFeedbackType.light,
                              borderRadius:
                                  BorderRadius.circular(OTRadius.button),
                              child: FilledButton(
                                onPressed: _isProcessing
                                    ? null
                                    : () => _handleTierCheckout(
                                          tier: tahawwulatCurrentTier,
                                          targetAgent: _tahawwulatAgent,
                                        ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: textPrimary,
                                  foregroundColor: canvas,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: OTRadius.buttonBorder),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Pilih Paket Fikih Tahawwulat (${tahawwulatCurrentTier['label']})',
                                      style: OTTypography.button(color: canvas)
                                          .copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 16, color: canvas),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: OTSpacing.sm),

                          Center(
                            child: TextButton.icon(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _handleSubscribe(
                                        plan: tahawwulatCurrentTier['planId']
                                            as String,
                                        planTitle:
                                            '${tahawwulatCurrentTier['name']} ${_tahawwulatAgent.title}'
                                                .trim(),
                                        price: tahawwulatCurrentTier['price']
                                            as int,
                                        targetAgent: _tahawwulatAgent,
                                      ),
                              icon: Icon(Icons.payment_rounded,
                                  size: 14, color: textSecondary),
                              label: Text(
                                'Atau bayar via DOKU Payment Gateway (QRIS / VA)',
                                style:
                                    OTTypography.caption(color: textSecondary)
                                        .copyWith(
                                  fontSize: 11.5,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      textSecondary.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: OTSpacing.xl),

                    // ════════════════════════════════════════════════════════
                    // 2. KARTU SPESIALIS PER BIDANG LAINNYA
                    // ════════════════════════════════════════════════════════
                    Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: OTRadius.cardBorder,
                        border: Border.all(
                          color: border,
                          width: 1.0,
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
                                style: OTTypography.sectionHeading(
                                    color: textSecondary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: surfaceSubtle,
                                  borderRadius: OTRadius.chipBorder,
                                ),
                                child: Text(
                                  '1 bidang',
                                  style: OTTypography.captionMedium(
                                          color: textSecondary)
                                      .copyWith(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: OTSpacing.sm),
                          Text(
                            'Pilih bidang',
                            style: OTTypography.corpusTitle(color: textPrimary)
                                .copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Akses satu bidang beserta kitab rujukannya.',
                            style: OTTypography.body(color: textSecondary)
                                .copyWith(
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: OTSpacing.md),

                          // Dropdown HANYA untuk disiplin lainnya (bukan Tahawwulat)
                          DropdownButtonFormField<String>(
                            initialValue: otherTargetAgent.id,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
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
                            items: otherList.map((a) {
                              return DropdownMenuItem<String>(
                                value: a.id,
                                child: Text(
                                  a.title,
                                  style: OTTypography.bodyMedium(
                                          color: textPrimary)
                                      .copyWith(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedOtherAgent =
                                      otherList.firstWhere((a) => a.id == val);
                                });
                              }
                            },
                          ),

                          const SizedBox(height: OTSpacing.lg),

                          // Segmented Control Durasi Bidang Lainnya
                          Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: surfaceSubtle,
                              borderRadius: OTRadius.chipBorder,
                              border: Border.all(color: border, width: 0.8),
                            ),
                            child: Row(
                              children: List.generate(otherTiers.length, (idx) {
                                final tier = otherTiers[idx];
                                final isSelected = safeOtherIndex == idx;
                                return Expanded(
                                  child: AppleInteractiveWrapper(
                                    onTap: () {
                                      OTMotion.selection();
                                      setState(() => _otherDurationIndex = idx);
                                    },
                                    pressedScale: 0.94,
                                    hapticType: HapticFeedbackType.selection,
                                    child: AnimatedContainer(
                                      duration: OTMotion.fast,
                                      curve: OTMotion.curve,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? textPrimary
                                            : Colors.transparent,
                                        borderRadius: OTRadius.chipBorder,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        tier['name'] as String,
                                        style: OTTypography.caption(
                                          color: isSelected
                                              ? canvas
                                              : textSecondary,
                                        ).copyWith(
                                          fontSize: 11,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: OTSpacing.lg),

                          // Price Display Bidang Lainnya
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                otherCurrentTier['label'] as String,
                                style: OTTypography.price(color: textPrimary),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                otherCurrentTier['period'] as String,
                                style:
                                    OTTypography.caption(color: textSecondary),
                              ),
                            ],
                          ),

                          const SizedBox(height: OTSpacing.base),
                          Divider(
                              color: border.withValues(alpha: 0.6), height: 1),
                          const SizedBox(height: OTSpacing.base),

                          _benefitRow(
                            'Akses Asisten ${otherTargetAgent.title}',
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

                          // CTA Button Bidang Lainnya
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: AppleInteractiveWrapper(
                              onTap: _isProcessing
                                  ? null
                                  : () => _handleTierCheckout(
                                        tier: otherCurrentTier,
                                        targetAgent: otherTargetAgent,
                                      ),
                              pressedScale: 0.97,
                              hapticType: HapticFeedbackType.light,
                              borderRadius:
                                  BorderRadius.circular(OTRadius.button),
                              child: FilledButton(
                                onPressed: _isProcessing
                                    ? null
                                    : () => _handleTierCheckout(
                                          tier: otherCurrentTier,
                                          targetAgent: otherTargetAgent,
                                        ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: textPrimary,
                                  foregroundColor: canvas,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: OTRadius.buttonBorder),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Pilih paket ${otherTargetAgent.title} (${otherCurrentTier['label']})',
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
                                  style: OTTypography.sectionHeading(
                                      color: textSecondary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: OTRadius.chipBorder,
                                  border: Border.all(color: border, width: 0.6),
                                ),
                                child: Text(
                                  'Segera hadir',
                                  style: OTTypography.captionMedium(
                                          color: textSecondary)
                                      .copyWith(
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
                            style: OTTypography.corpusTitle(color: textPrimary)
                                .copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Satu paket untuk mengakses seluruh bidang yang tersedia beserta kitab rujukannya.',
                            style: OTTypography.body(color: textSecondary)
                                .copyWith(
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: OTSpacing.base),
                          Divider(
                              color: border.withValues(alpha: 0.5), height: 1),
                          const SizedBox(height: OTSpacing.base),
                          _benefitRow('Akses ke seluruh bidang yang tersedia',
                              textSecondary),
                          const SizedBox(height: OTSpacing.sm),
                          _benefitRow(
                              'Akses lintas bidang dalam satu langganan',
                              textSecondary),
                          const SizedBox(height: OTSpacing.sm),
                          _benefitRow('Pembaruan berkala seluruh kitab rujukan',
                              textSecondary),
                          const SizedBox(height: OTSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: border),
                                shape: RoundedRectangleBorder(
                                    borderRadius: OTRadius.buttonBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline_rounded,
                                      size: 16, color: textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Segera Hadir',
                                    style: OTTypography.button(
                                        color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ], // Akhir _selectedSegment else

                  const SizedBox(height: OTSpacing.lg),

                  // ── Catatan Transparansi Pembelian ──
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
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppCopy.manualRenewalNotice,
                            style: OTTypography.caption(color: textSecondary)
                                .copyWith(
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
