import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/routes.dart';
import '../core/app_config.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/user_model.dart';
import '../models/agent_model.dart';
import '../services/auth_service.dart';
import '../widgets/apple_interactive_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  String _appVersion = '1.0.9';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = '${info.version}+${info.buildNumber}');
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Text(
            AppCopy.logoutDialogTitle,
            style: OTTypography.cardTitle(color: textPrimary).copyWith(fontSize: 18),
          ),
          content: Text(
            AppCopy.logoutDialogBody,
            style: OTTypography.body(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.logoutButton, style: OTTypography.button(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) return;

    setState(() => _isLoggingOut = true);
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _deleteAccount() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: OTRadius.dialogBorder),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: OTColors.destructive, size: 24),
              const SizedBox(width: OTSpacing.sm),
              Expanded(
                child: Text(
                  AppCopy.deleteAccountTitle,
                  style: OTTypography.cardTitle(color: OTColors.destructive).copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            AppCopy.deleteAccountBody,
            style: OTTypography.body(color: OTColors.textSecondary(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: OTTypography.button(color: OTColors.textSecondary(isDark))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.deleteAccountButton, style: OTTypography.button(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _authService.deleteAccount();
      if (mounted) {
        AppSnackBar.success(context, AppCopy.deleteAccountSuccess);
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
        final errText = e.toString().contains('requires-recent-login')
            ? AppCopy.recentLoginRequired
            : AppCopy.networkError;
        AppSnackBar.error(context, errText);
      }
    }
  }

  Future<void> _openSubscription() async {
    final user = await _authService.getCurrentUserModel();
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.subscription,
      arguments: {
        'user': user,
        'agent': AgentModel.defaultAgents.firstWhere(
          (a) => a.id == 'fiqh_tahawwulat',
          orElse: () => AgentModel.defaultAgents.first,
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          AppCopy.navSettings,
          style: GoogleFonts.newsreader(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: textPrimary),
            onPressed: () => _showAboutModal(
              context,
              isDark,
              textPrimary,
              textSecondary,
              surface,
              border,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: _authService.userStream,
          builder: (context, snapshot) {
            final userModel = snapshot.data;
            final fbUser = FirebaseAuth.instance.currentUser;

            final displayName = userModel?.name.isNotEmpty == true
                ? userModel!.name
                : (fbUser?.displayName ?? 'Pengguna');
            final email = userModel?.email.isNotEmpty == true
                ? userModel!.email
                : (fbUser?.email ?? 'pengguna@openturath.id');
            final plan = userModel?.plan ?? 'trial';
            final isSubscribed =
                userModel?.isSubscriptionActive ?? (userModel?.isPremium ?? false);

            final exp = userModel?.subscriptionExpiry;
            final expStr = exp != null ? ' · Aktif sampai ${exp.day}/${exp.month}/${exp.year}' : '';
            final String subscriptionSubtitle;

            if (isSubscribed) {
              if (plan == 'sultan' || plan == 'all_access' || plan == 'all_ai_1m' || plan == 'all_ai') {
                subscriptionSubtitle = 'Semua Kajian$expStr';
              } else if (plan == 'field') {
                subscriptionSubtitle = 'Rumpun Kajian$expStr';
              } else if (plan == 'single') {
                subscriptionSubtitle = 'Kajian Satuan$expStr';
              } else {
                subscriptionSubtitle = '${AppCopy.activeSubscription}$expStr';
              }
            } else {
              subscriptionSubtitle = AppCopy.inactiveSubscription;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 108),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Card 1: User Email & Pro Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          email,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          isSubscribed ? 'Aktif' : 'Gratis',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF18181B) : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card 2: Profile & Subscription ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: AppCopy.profile,
                        subtitle: displayName,
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.credit_card_outlined,
                        title: AppCopy.subscription,
                        subtitle: subscriptionSubtitle,
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: _openSubscription,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card 3: Color Mode & Language ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppConfig.themeNotifier,
                        builder: (context, currentMode, _) {
                          final isCurrentDark = currentMode == ThemeMode.dark ||
                              (currentMode == ThemeMode.system && isDark);
                          return _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            title: AppCopy.appearance,
                            subtitle: isCurrentDark ? AppCopy.modeDark : AppCopy.modeLight,
                            trailing: Switch.adaptive(
                              value: isCurrentDark,
                              activeTrackColor: isDark ? Colors.white : const Color(0xFF18181B),
                              activeThumbColor: isDark ? const Color(0xFF18181B) : Colors.white,
                              onChanged: (val) {
                                AppConfig.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                              },
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: AppCopy.language,
                        subtitle: AppCopy.languageIndonesian,
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showLanguageModal(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card 4: Legal & About ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.article_outlined,
                        title: 'Ketentuan Layanan',
                        subtitle: 'Syarat dan ketentuan OpenTurath',
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showTermsOfService(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.security_outlined,
                        title: 'Kebijakan Privasi',
                        subtitle: 'Perlindungan kerahasiaan data pengguna',
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showPrivacyPolicy(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: AppCopy.aboutTitle,
                        subtitle: 'Versi $_appVersion · ${AppCopy.appTagline}',
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: () => _showAboutModal(
                          context,
                          isDark,
                          textPrimary,
                          textSecondary,
                          surface,
                          border,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Card 5: Log out ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: (_isLoggingOut || _isDeletingAccount) ? null : _logout,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFF87171),
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _isLoggingOut ? 'Sedang keluar...' : AppCopy.logoutButton,
                              style: GoogleFonts.outfit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF87171),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Quiet Google Play Compliance: Delete Account ──
                Center(
                  child: TextButton(
                    onPressed: (_isLoggingOut || _isDeletingAccount) ? null : _deleteAccount,
                    child: _isDeletingAccount
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: OTColors.destructive),
                          )
                        : Text(
                            AppCopy.deleteAccountButton,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAboutModal(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: OTRadius.dialogBorder,
          side: BorderSide(color: border, width: 0.8),
        ),
        title: Text(
          AppCopy.aboutTitle,
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi $_appVersion · ${AppCopy.appTagline}',
              style: OTTypography.captionMedium(color: textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              AppCopy.aboutDescription,
              style: OTTypography.body(color: textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              AppCopy.aboutScholarlyPrinciple,
              style: OTTypography.caption(color: textSecondary),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: textPrimary,
              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
            ),
            child: Text('Tutup', style: OTTypography.button()),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.8,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.sheetBorder,
          border: Border.all(color: border, width: 0.8),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: OTRadius.chipBorder,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ketentuan Layanan',
                  style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegalSection(
                      title: '1. Ruang Lingkup & Tujuan Riset',
                      content:
                          'OpenTurath membantu pembaca mencari ibarah, membandingkan matan dan syarah, serta menelusuri rujukan kitab. Hasilnya perlu diperiksa kembali pada naskah asli.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '2. Batasan Tanggung Jawab & Penafian Fatwa',
                      content:
                          'Hasil analisis, transkripsi, dan kutipan teks yang disajikan oleh sistem kecerdasan buatan bersifat sebagai referensi riset awal. OpenTurath BUKAN mufti dan tidak berwenang mengeluarkan fatwa syar\'i mandiri. Pengguna diwajibkan untuk mengonfirmasi hasil telaah dengan ulama dan guru yang bersanad (talaqqi) serta merujuk ke naskah fisik kitab primer.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '3. Akun Pengguna & Hak Akses',
                      content:
                          'Pengguna bertanggung jawab menjaga keamanan kredensial akun Google yang digunakan. Setiap paket langganan (Akses Penuh maupun Modul Spesialis) bersifat personal dan tidak diperkenankan untuk diperjualbelikan kembali atau dieksploitasi melalui bot otomatis tanpa izin tertulis.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '4. Ketentuan Pembayaran & Berlangganan',
                      content:
                          'Seluruh transaksi langganan diproses secara resmi melalui payment gateway terverifikasi (DOKU). Pengguna berhak mengakses ruang riset sesuai paket dan durasi yang dipilih.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: textPrimary,
                  foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                ),
                child: Text('Saya Pahami & Setuju', style: OTTypography.button()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.8,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: OTRadius.sheetBorder,
          border: Border.all(color: border, width: 0.8),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: OTRadius.chipBorder,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kebijakan Privasi',
                  style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegalSection(
                      title: '1. Pengumpulan & Penggunaan Data',
                      content:
                          'OpenTurath hanya mengumpulkan data profil dasar (nama, alamat email, dan foto profil publik) yang diotorisasi saat Anda masuk menggunakan Akun Google. Data ini digunakan secara eksklusif untuk otentikasi sesi riset dan personalisasi akun.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '2. Kerahasiaan Sesi & Catatan Riset',
                      content:
                          'Pertanyaan kajian, kutipan ibarah, dan riwayat bookmark naskah kitab yang Anda telusuri dienkripsi dengan standar keamanan industri. OpenTurath tidak membagikan, mempublikasikan, ataupun memperjualbelikan data riset Anda kepada pihak ketiga manapun.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '3. Keamanan Sesi Google & NotebookLM',
                      content:
                          'Koneksi sesi telaah dengan Google NotebookLM berjalan di lingkungan aman melalui enkripsi SSL/TLS. Kredensial kata sandi Anda tidak pernah disimpan di server OpenTurath.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 14),
                    _buildLegalSection(
                      title: '4. Hak Penghapusan Data Pengguna',
                      content:
                          'Anda memiliki hak mutlak untuk menghapus akun Anda beserta seluruh riwayat telaah dan bookmark kapan saja melalui menu Pengaturan > Hapus Akun & Data.',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: textPrimary,
                  foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                ),
                child: Text('Tutup', style: OTTypography.button()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageModal(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surface,
    Color border,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: OTRadius.dialogBorder,
          side: BorderSide(color: border, width: 0.8),
        ),
        title: Text(
          'Bahasa Aplikasi',
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu tersedia dalam bahasa Indonesia. Teks Arab dapat dibaca dengan atau tanpa harakat.',
              style: OTTypography.body(color: textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Dukungan antarmuka penuh Bahasa Arab (العربية) dan Inggris (English) sedang dalam proses finalisasi kurasi kebahasaan.',
              style: OTTypography.caption(color: textSecondary),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: textPrimary,
              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
            ),
            child: Text('Tutup', style: OTTypography.button()),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection({
    required String title,
    required String content,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: OTTypography.bodyMedium(color: textPrimary).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: OTTypography.caption(color: textSecondary).copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.985,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: OTSpacing.base, vertical: 2),
        leading: Icon(
          icon,
          size: 21,
          color: textPrimary,
        ),
        title: Text(
          title,
          style: OTTypography.bodyMedium(color: textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: OTTypography.caption(color: textSecondary),
        ),
        trailing: trailing,
      ),
    );
  }
}
