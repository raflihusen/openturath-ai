import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/routes.dart';
import '../core/app_config.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_spacing.dart';
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
            'Konfirmasi Keluar',
            style: OTTypography.cardTitle(color: textPrimary).copyWith(fontSize: 18),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun OpenTurath AI?',
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
              child: Text('Keluar', style: OTTypography.button(color: Colors.white)),
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
                  'Hapus Akun & Data',
                  style: OTTypography.cardTitle(color: OTColors.destructive).copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            'PERINGATAN: Tindakan ini permanen dan tidak dapat dibatalkan.\n\nSeluruh data profil, histori riset, bookmark kitab, dan lisensi akses di perangkat ini akan dihapus secara menyeluruh dari server.',
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
              child: Text('Hapus Akun Permanen', style: OTTypography.button(color: Colors.white)),
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

  void _showThemeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final currentMode = AppConfig.themeNotifier.value;
        final surface = OTColors.surface(isDark);
        final border = OTColors.border(isDark);
        final textPrimary = OTColors.textPrimary(isDark);
        final textSecondary = OTColors.textSecondary(isDark);
        final accent = OTColors.accent(isDark);

        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: OTRadius.sheetBorder,
            border: Border.all(color: border, width: 0.8),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.3),
                    borderRadius: OTRadius.chipBorder,
                  ),
                ),
              ),
              Text(
                'Tema Tampilan',
                style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
              ),
              const SizedBox(height: OTSpacing.md),
              _buildThemeChoiceTile(
                title: 'Ikuti Sistem',
                subtitle: 'Menyesuaikan tema perangkat Anda',
                icon: Icons.brightness_auto_rounded,
                isSelected: currentMode == ThemeMode.system,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accent: accent,
                onTap: () {
                  OTMotion.selection();
                  AppConfig.setThemeMode(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
              Divider(height: 1, color: border.withValues(alpha: 0.5)),
              _buildThemeChoiceTile(
                title: 'Terang',
                subtitle: 'Tampilan cerah yang nyaman di mata',
                icon: Icons.light_mode_outlined,
                isSelected: currentMode == ThemeMode.light,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accent: accent,
                onTap: () {
                  OTMotion.selection();
                  AppConfig.setThemeMode(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              Divider(height: 1, color: border.withValues(alpha: 0.5)),
              _buildThemeChoiceTile(
                title: 'Gelap',
                subtitle: 'Minim silau untuk riset malam hari',
                icon: Icons.dark_mode_outlined,
                isSelected: currentMode == ThemeMode.dark,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                accent: accent,
                onTap: () {
                  OTMotion.selection();
                  AppConfig.setThemeMode(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeChoiceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? accent : textSecondary),
            const SizedBox(width: OTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OTTypography.bodyMedium(
                      color: isSelected ? accent : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: OTTypography.caption(color: textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, size: 20, color: accent),
          ],
        ),
      ),
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
    final accent = OTColors.accent(isDark);

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
            'Pengaturan',
            style: OTTypography.corpusTitle(color: textPrimary).copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.fromLTRB(OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, 108),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Scholarly Profile Card ──
                Container(
                  padding: const EdgeInsets.all(OTSpacing.base),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(color: border, width: 0.8),
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
                                    style: OTTypography.screenTitle(color: textPrimary),
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
                                  style: OTTypography.cardTitle(color: textPrimary).copyWith(fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: OTTypography.caption(color: textSecondary),
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
                              color: isSubscribed ? accent : textPrimary,
                              borderRadius: OTRadius.chipBorder,
                            ),
                            child: Text(
                              isSubscribed ? 'PRO' : 'TRIAL',
                              style: OTTypography.captionMedium(
                                color: isSubscribed ? Colors.white : canvas,
                              ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      if (!isSubscribed) ...[
                        const SizedBox(height: OTSpacing.md),
                        Divider(height: 1, color: border.withValues(alpha: 0.5)),
                        const SizedBox(height: OTSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tingkatkan ke OpenTurath Pro',
                                    style: OTTypography.bodyMedium(color: textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Akses korpus kitab tanpa batas kuota.',
                                    style: OTTypography.caption(color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _openSubscription,
                              style: FilledButton.styleFrom(
                                backgroundColor: textPrimary,
                                foregroundColor: canvas,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
                              ),
                              child: Text('Upgrade', style: OTTypography.button(color: canvas).copyWith(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: OTSpacing.xl),

                // ── Section 1: Account & Billing ──
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'AKUN & LISENSI',
                    style: OTTypography.sectionHeading(color: textSecondary),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(color: border, width: 0.8),
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

                const SizedBox(height: OTSpacing.lg),

                // ── Section 2: Display & Appearance ──
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'TAMPILAN & PREFERENSI',
                    style: OTTypography.sectionHeading(color: textSecondary),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(color: border, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppConfig.themeNotifier,
                        builder: (context, currentMode, _) {
                          final String modeLabel;
                          if (currentMode == ThemeMode.system) {
                            modeLabel = 'Ikuti Sistem';
                          } else if (currentMode == ThemeMode.dark) {
                            modeLabel = 'Gelap';
                          } else {
                            modeLabel = 'Terang';
                          }

                          return _SettingsTile(
                            icon: Icons.palette_outlined,
                            title: 'Tema Tampilan',
                            subtitle: modeLabel,
                            trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                            onTap: () => _showThemeModal(context),
                          );
                        },
                      ),
                      Divider(height: 1, color: border.withValues(alpha: 0.5), indent: 48),
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

                const SizedBox(height: OTSpacing.lg),

                // ── Section 3: Legal & About ──
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'TENTANG & KEBIJAKAN',
                    style: OTTypography.sectionHeading(color: textSecondary),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(color: border, width: 0.8),
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
                      Divider(height: 1, color: border.withValues(alpha: 0.5), indent: 48),
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
                      Divider(height: 1, color: border.withValues(alpha: 0.5), indent: 48),
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

                const SizedBox(height: OTSpacing.xxl),

                // ── Quiet Text Actions (Logout & Delete Account) ──
                Center(
                  child: TextButton(
                    onPressed: (_isLoggingOut || _isDeletingAccount) ? null : _logout,
                    child: _isLoggingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: OTColors.destructive),
                          )
                        : Text(
                            'Keluar dari Akun',
                            style: OTTypography.bodyMedium(color: OTColors.destructive),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
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
                            'Hapus Akun & Data Riset',
                            style: OTTypography.caption(
                              color: textSecondary.withValues(alpha: 0.65),
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
          'Tentang OpenTurath',
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi $_appVersion · AI for Islamic Scholarship',
              style: OTTypography.captionMedium(color: textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              'OpenTurath adalah asisten riset naskah primer keilmuan Islam yang menggabungkan ribuan halaman kitab kuning mu\'tabar dengan teknologi penelaahan cerdas.',
              style: OTTypography.body(color: textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              'Prinsip Ilmiah: Berbasis sanad, penelusuran ibarah naskah asli, dan kehati-hatian dalam istinbath. Bukan pengganti proses talaqqi dengan masyayikh.',
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
              'Antarmuka aplikasi saat ini dioptimalkan untuk Bahasa Indonesia dengan dukungan penuh teks Arab gundul/berharakat pada naskah kitab kuning primer.',
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
            child: Text('Mengerti', style: OTTypography.button()),
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

    return ListTile(
      onTap: onTap != null
          ? () {
              OTMotion.light();
              onTap!();
            }
          : null,
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
    );
  }
}
