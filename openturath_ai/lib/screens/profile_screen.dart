import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../core/app_config.dart';
import '../core/app_snackbar.dart';
import '../models/user_model.dart';
import '../models/agent_model.dart';
import '../services/auth_service.dart';

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
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun OpenTurath AI?',
            style: GoogleFonts.outfit(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: Text('Keluar', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hapus Akun & Data',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
          content: Text(
            'PERINGATAN: Tindakan ini permanen dan tidak dapat dibatalkan.\n\nSeluruh data profil, histori riset, bookmark kitab, dan lisensi akses di perangkat ini akan dihapus secara menyeluruh dari server.',
            style: GoogleFonts.outfit(fontSize: 13.5, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              child: Text('Hapus Akun Permanen', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _authService.deleteAccount();
      if (mounted) {
        AppSnackBar.success(context, 'Akun dan seluruh data Anda telah berhasil dihapus.');
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
        AppSnackBar.error(
          context,
          'Gagal menghapus akun: ${e.toString().contains('requires-recent-login') ? 'Sesi telah kedaluwarsa. Silakan masuk ulang terlebih dahulu.' : 'Terjadi gangguan jaringan.'}',
        );
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
    final canvas = isDark ? AppTheme.groupedCanvasDark : AppTheme.groupedCanvasLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Pengaturan & Akun',
            style: GoogleFonts.newsreader(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: _authService.userStream,
          builder: (context, snapshot) {
            final userModel = snapshot.data;
            final fbUser = FirebaseAuth.instance.currentUser;

            final displayName = userModel?.name.isNotEmpty == true
                ? userModel!.name
                : (fbUser?.displayName ?? 'Peneliti Turats');
            final email = userModel?.email.isNotEmpty == true
                ? userModel!.email
                : (fbUser?.email ?? 'peneliti@openturath.ai');
            final plan = userModel?.plan ?? 'trial';
            final isSubscribed =
                userModel?.isSubscriptionActive ?? (userModel?.isPremium ?? false);

            final exp = userModel?.subscriptionExpiry;
            final expStr = exp != null ? ' · s/d ${exp.day}/${exp.month}/${exp.year}' : '';
            final String subscriptionSubtitle;

            if (isSubscribed) {
              if (plan == 'sultan' || plan == 'all_access' || plan == 'all_ai_1m' || plan == 'all_ai') {
                subscriptionSubtitle = 'Paket Semua AI (Akses Penuh)$expStr';
              } else if (plan == 'field') {
                subscriptionSubtitle = 'Paket Rumpun Keilmuan$expStr';
              } else if (plan == 'single') {
                subscriptionSubtitle = 'Paket Spesialis Satuan$expStr';
              } else {
                subscriptionSubtitle = 'Langganan Aktif$expStr';
              }
            } else {
              subscriptionSubtitle = 'Belum Berlangganan · Aktifkan Akses Penuh';
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Apple ID Unified Profile Card ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                            backgroundImage: userModel?.photoUrl.isNotEmpty == true
                                ? NetworkImage(userModel!.photoUrl)
                                : null,
                            child: userModel?.photoUrl.isEmpty != false
                                ? Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.newsreader(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    color: textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : const Color(0xFF18181B),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              isSubscribed ? 'PRO' : 'TRIAL',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF18181B) : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isSubscribed) ...[
                        const SizedBox(height: 14),
                        Divider(height: 1, color: border),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tingkatkan ke OpenTurath Pro',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Akses korpus kitab tanpa batas kuota.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _openSubscription,
                              style: FilledButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                                foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: Text(
                                'Upgrade',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Section 1: Account & Billing (Apple Grouped Style) ──
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'AKUN & LISENSI',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: textSecondary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.credit_card_outlined,
                        title: 'Paket & Langganan',
                        subtitle: subscriptionSubtitle,
                        trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                        onTap: _openSubscription,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Section 2: Display & Appearance ──
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'TAMPILAN & PREFERENSI',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: textSecondary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppConfig.themeNotifier,
                        builder: (context, currentMode, _) {
                          final isCurrentDark = currentMode == ThemeMode.dark;
                          return _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Tema Tampilan',
                            subtitle: isCurrentDark ? 'Mode Gelap' : 'Mode Terang',
                            trailing: Switch.adaptive(
                              value: isCurrentDark,
                              activeTrackColor: accent,
                              activeThumbColor: Colors.white,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                AppConfig.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                              },
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: border, indent: AppTheme.dividerIndent, endIndent: 16),
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: 'Bahasa Aplikasi',
                        subtitle: 'Bahasa Indonesia (Utama)',
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

                const SizedBox(height: 20),

                // ── Section 3: Legal & About ──
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'TENTANG & KEBIJAKAN',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: textSecondary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.article_outlined,
                        title: 'Ketentuan Layanan',
                        subtitle: 'Syarat dan ketentuan riset OpenTurath',
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
                      Divider(height: 1, color: border, indent: AppTheme.dividerIndent, endIndent: 16),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Kebijakan Privasi',
                        subtitle: 'Perlindungan kerahasiaan data riset',
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
                      Divider(height: 1, color: border, indent: AppTheme.dividerIndent, endIndent: 16),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang OpenTurath',
                        subtitle: 'Versi $_appVersion · AI for Islamic Scholarship',
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

                const SizedBox(height: 20),

                // ── Section 4: Log Out Container ──
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'SESI MASUK',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: textSecondary,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: ListTile(
                    onTap: (_isLoggingOut || _isDeletingAccount) ? null : _logout,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    leading: _isLoggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.appleRed),
                          )
                        : const Icon(Icons.logout_rounded, size: 21, color: AppTheme.appleRed),
                    title: Text(
                      _isLoggingOut ? 'Sedang keluar...' : 'Keluar dari Akun',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.appleRed,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Delete Account Button (Google Play Requirement) ──
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: (_isLoggingOut || _isDeletingAccount) ? null : _deleteAccount,
                    icon: _isDeletingAccount
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)),
                          )
                        : const Icon(Icons.delete_forever_rounded, color: Color(0xFF9CA3AF), size: 18),
                    label: Text(
                      _isDeletingAccount ? 'Sedang menghapus akun...' : 'Hapus Akun & Data Riset',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1.0),
        ),
        title: Text(
          'Tentang OpenTurath',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi $_appVersion · AI for Islamic Scholarship',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'OpenTurath adalah asisten riset naskah primer keilmuan Islam yang menggabungkan ribuan halaman kitab kuning mu\'tabar dengan teknologi penelaahan cerdas.',
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                height: 1.5,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Prinsip Ilmiah: Berbasis sanad, penelusuran ibarah naskah asli, dan kehati-hatian dalam istinbath. Bukan pengganti proses talaqqi dengan masyayikh.',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                height: 1.45,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              'Tutup',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: border, width: 1.0),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ketentuan Layanan',
                  style: GoogleFonts.newsreader(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
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
                          'OpenTurath AI adalah platform penelaahan komputasi naskah primer keilmuan Islam (turats). Layanan ini dirancang khusus untuk mempermudah santri, akademisi, asatidz, dan peneliti dalam mencari ibarah, membandingkan matan dan syarah, serta melacak rujukan kitab muktamad.',
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
                  backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                  foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text('Saya Pahami & Setuju', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: border, width: 1.0),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kebijakan Privasi',
                  style: GoogleFonts.newsreader(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
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
                  backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                  foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Text('Tutup', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1.0),
        ),
        title: Text(
          'Bahasa Aplikasi',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antarmuka aplikasi saat ini dioptimalkan untuk Bahasa Indonesia dengan dukungan penuh teks Arab gundul/berharakat pada naskah kitab kuning primer.',
              style: GoogleFonts.outfit(fontSize: 13.5, height: 1.45, color: textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Dukungan antarmuka penuh Bahasa Arab (العربية) dan Inggris (English) sedang dalam proses finalisasi kurasi kebahasaan.',
              style: GoogleFonts.outfit(fontSize: 12.5, height: 1.4, color: textSecondary),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? Colors.white : const Color(0xFF18181B),
              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text('Mengerti', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
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
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            height: 1.5,
            color: textSecondary,
          ),
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
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;

    return ListTile(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(
        icon,
        size: 21,
        color: isDark ? Colors.white : const Color(0xFF18181B),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      trailing: trailing,
    );
  }
}
