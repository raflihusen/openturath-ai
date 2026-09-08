import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_snackbar.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/subscription_service.dart';
import '../widgets/doku_checkout_sheet.dart';

/// Halaman Langganan Ruang Riset OpenTurath AI
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
  String? _selectedPlan;

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

      // Pastikan data pengguna selalu terisi dari Firebase Auth aktif
      final fbUser = FirebaseAuth.instance.currentUser;
      if (_user == null && fbUser != null) {
        _user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ??
              (fbUser.email?.split('@').first ?? 'Peneliti'),
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('user_phone') ?? '';
      if (saved.isNotEmpty && saved.length >= 8) {
        return saved;
      }
    } catch (_) {}

    if (!mounted) return null;
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    final phone = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border, width: 1),
        ),
        title: Text(
          'Nomor WhatsApp / HP',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan nomor aktif untuk penerimaan bukti invoice pembayaran resmi dari sistem DOKU.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.phone,
              autofocus: true,
              style: GoogleFonts.outfit(fontSize: 15, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Contoh: 081234567890',
                prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text('Batal', style: GoogleFonts.outfit(color: textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              final val = textController.text.trim();
              if (val.length < 8) {
                AppSnackBar.warning(ctx, 'Masukkan nomor telepon yang valid.');
                return;
              }
              Navigator.pop(ctx, val);
            },
            child: Text('Lanjutkan', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (phone != null && phone.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', phone);
      } catch (_) {}
    }
    return phone;
  }

  Future<void> _handleSubscribe(
    String plan,
    String planTitle,
    int price, {
    AgentModel? targetAgent,
  }) async {
    // Validasi sesi pengguna
    final fbUser = FirebaseAuth.instance.currentUser;
    if (_user == null && fbUser != null) {
      _user = UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        name: fbUser.displayName ?? 'Peneliti',
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
      _selectedPlan = plan;
    });

    String? dokuUrl;
    String invoiceNumber = '';
    String trxId = '';

    try {
      final userName = _user!.name.trim().isNotEmpty
          ? _user!.name.trim()
          : (_user!.email.isNotEmpty ? _user!.email.split('@').first : 'Peneliti Turats');

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
        'Gagal membuat pembayaran DOKU: $err',
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
          'Alhamdulillah! Pembayaran berhasil. Akses ruang riset Anda telah aktif!',
          duration: const Duration(seconds: 4),
        );
        Navigator.pop(context); // Kembali ke dashboard/layar riset
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        'Terjadi kendala menampilkan sesi pembayaran: $e',
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildStaggeredItem(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 320 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, val, ch) {
        return Transform.translate(
          offset: Offset(0, 18 * (1.0 - val)),
          child: Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: ch,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    final singlePrice = _agent?.price1m ?? AppConstants.priceTholib1m;
    final annualPrice = _agent?.price1y ?? AppConstants.priceBahits1y;
    final activeList = _activeAgents;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Langganan Ruang Riset',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 108),
                children: [
                  _buildStaggeredItem(
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Paket Ruang Riset',
                          style: GoogleFonts.outfit(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Beli paket 1 AI satuan seharga Rp 50.000/bulan, atau pilih Paket Promo Semua AI seharga Rp 99.000/bulan.',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── AI Module Selector Box ──
                  _buildStaggeredItem(
                    1,
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tune_rounded, size: 18, color: accent),
                              const SizedBox(width: 8),
                              Text(
                                'Pilih AI Spesialis yang Ingin Dibeli:',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _agent?.id ?? 'fiqh_tahawwulat',
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF131C26)
                                  : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: border),
                              ),
                            ),
                            dropdownColor:
                                isDark ? const Color(0xFF131C26) : Colors.white,
                            items: activeList.map((a) {
                              return DropdownMenuItem<String>(
                                value: a.id,
                                child: Text(
                                  '${a.title}  ·  ${a.category}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: textPrimary,
                                  ),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Paket 1: Beli 1 AI Spesialis Terpilih (Rp 50.000 / bulan) ──
                  _buildStaggeredItem(
                    2,
                    _PricingCard(
                      badge: 'PAKET SATUAN (1 MODUL)',
                      title: '1 Bulan — ${_agent?.title ?? "AI Spesialis"}',
                      price: 'Rp ${_formatPrice(singlePrice)}',
                      period: '/ bulan',
                      description:
                          'Akses khusus ke ${_agent?.title ?? "modul ini"} tanpa batas pertanyaan harian.',
                      features: [
                        'Akses penuh korpus kitab ${_agent?.title ?? "modul terpilih"}',
                        'Tanya jawab tanpa batas pertanyaan harian',
                        'Sitasi ibarah kitab asli dan nomor halaman',
                        'Dukungan asistensi teknis santri',
                      ],
                      buttonLabel: 'Beli ${_agent?.title ?? "AI Ini"} (Rp 50.000)',
                      isDark: isDark,
                      isProcessing:
                          _isProcessing && _selectedPlan == AppConstants.planTholib1m,
                      onTap: () => _handleSubscribe(
                        AppConstants.planTholib1m,
                        '1 Bulan ${_agent?.title ?? "Modul AI"}',
                        singlePrice,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Paket 2: Paket Promo (Semua AI Sekaligus - Rp 99.000 / bulan) ──
                  _buildStaggeredItem(
                    3,
                    _PricingCard(
                      badge: 'PALING HEMAT & LENGKAP',
                      title: 'Paket Promo (Semua AI)',
                      price: 'Rp 99.000',
                      period: '/ bulan',
                      description:
                          'Akses tanpa batas ke seluruh modul riset AI OpenTurath sekaligus secara simultan.',
                      features: const [
                        'Akses ke seluruh modul AI OpenTurath sekaligus',
                        'Mencakup seluruh Spesialis Mazhab Fikih, Hadits, Tafsir, dan Bahasa Arab',
                        'Bebas batas kuota pertanyaan pada semua modul',
                        'Harga promo: Rp 99.000 untuk semua AI (lebih hemat dibanding satuan)',
                        'Prioritas penambahan kitab dan naskah riset baru',
                      ],
                      buttonLabel: 'Beli Paket Semua AI (Rp 99.000)',
                      isRecommended: true,
                      isDark: isDark,
                      isProcessing: _isProcessing && _selectedPlan == 'all_ai_1m',
                      onTap: () {
                        final allAiAgent = AgentModel(
                          id: 'all_ai',
                          title: 'Paket Promo Semua AI',
                          description: 'Akses ke seluruh modul AI OpenTurath',
                          emoji: '👑',
                          category: 'All Access',
                          status: 'active',
                          sortOrder: 0,
                        );
                        _handleSubscribe(
                          'all_ai_1m',
                          'Paket Promo Semua AI',
                          99000,
                          targetAgent: allAiAgent,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Paket 3: Akses 1 Tahun Modul Terpilih (Rp 450.000 / tahun) ──
                  _buildStaggeredItem(
                    4,
                    _PricingCard(
                      badge: 'PAKET TAHUNAN',
                      title: '1 Tahun — ${_agent?.title ?? "AI Spesialis"}',
                      price: 'Rp ${_formatPrice(annualPrice)}',
                      period: '/ tahun',
                      description:
                          'Pilihan hemat 1 tahun untuk pengajar, santri, dan peneliti.',
                      features: [
                        'Seluruh fitur akses penuh ${_agent?.title ?? "modul terpilih"}',
                        'Hemat dibanding membayar bulanan selama 12 bulan',
                        'Akses prioritas pembaruan kitab dan ibarah',
                        'Dukungan asistensi teknis berkelanjutan',
                      ],
                      buttonLabel: 'Beli 1 Tahun ${_agent?.title ?? "AI Ini"} (Rp 450.000)',
                      isDark: isDark,
                      isProcessing:
                          _isProcessing && _selectedPlan == AppConstants.planBahits1y,
                      onTap: () => _handleSubscribe(
                        AppConstants.planBahits1y,
                        '1 Tahun ${_agent?.title ?? "Modul AI"}',
                        annualPrice,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {
  final String title;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final VoidCallback onTap;
  final bool isRecommended;
  final bool isDark;
  final bool isProcessing;
  final String? badge;
  final String? buttonLabel;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.onTap,
    this.isRecommended = false,
    required this.isDark,
    required this.isProcessing,
    this.badge,
    this.buttonLabel,
  });

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = widget.isRecommended
        ? (isDark ? AppTheme.accentDark : AppTheme.accentLight)
        : (isDark ? AppTheme.borderDark : AppTheme.borderLight);
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isRecommended
                  ? (isDark ? Colors.white : const Color(0xFF18181B))
                  : border,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.badge != null || widget.isRecommended)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    widget.badge ?? 'PILIHAN UTAMA',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: textPrimary,
                    ),
                  ),
                ),
              Text(
                widget.title,
                style: GoogleFonts.newsreader(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.price,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.period,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: border, height: 1),
              const SizedBox(height: 14),
              for (final f in widget.features) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          color: textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: widget.isProcessing ? null : widget.onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.isRecommended
                        ? (isDark ? AppTheme.accentDark : AppTheme.accentLight)
                        : (isDark ? AppTheme.lmDarkPillAction : AppTheme.lmLightPillAction),
                    foregroundColor: widget.isRecommended
                        ? (isDark ? AppTheme.canvasDark : Colors.white)
                        : (isDark ? AppTheme.lmDarkCanvas : Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: widget.isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.buttonLabel ?? 'Pilih Paket Ini',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  final digits = price.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}
