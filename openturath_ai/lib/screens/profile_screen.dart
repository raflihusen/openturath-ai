import 'package:flutter/material.dart';
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
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
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
        title: Text(
          'Profil & Akun',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
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
            final photoUrl = userModel?.photoUrl.isNotEmpty == true
                ? userModel!.photoUrl
                : fbUser?.photoURL;
            final isGuest = fbUser?.isAnonymous == true ||
                (userModel != null && userModel.uid.startsWith('guest_'));

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
              subscriptionSubtitle = 'Belum Berlangganan · Aktifkan Paket Riset';
            }

            String initials = 'RH';
            if (displayName.trim().isNotEmpty) {
              final parts = displayName.trim().split(RegExp(r'\s+'));
              if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
                initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
              } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
                initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
              }
            }

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 108),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ── User Identity Card ──
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor: isDark
                                ? AppTheme.surfaceHeaderDark
                                : AppTheme.surfaceHeaderLight,
                            backgroundImage:
                                photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                            onBackgroundImageError: photoUrl != null && photoUrl.isNotEmpty
                                ? (_, __) {}
                                : null,
                            child: photoUrl == null || photoUrl.isEmpty
                                ? Text(
                                    initials,
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: GoogleFonts.outfit(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: accent.withValues(alpha: 0.35),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      isSubscribed ? 'Pro' : (isGuest ? 'Tamu' : 'Gratis'),
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
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
                      ],
                    ),
                  ),

            const SizedBox(height: 24),

            // ── Section 1: Langganan & Pembayaran ──
            Text(
              'Langganan & Pembayaran',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
              ),
              child: _SettingsTile(
                icon: Icons.credit_card_rounded,
                title: 'Kelola Langganan & Paket',
                subtitle: subscriptionSubtitle,
                trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
                onTap: _openSubscription,
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 2: Pengaturan Tampilan ──
            Text(
              'Pengaturan Tampilan',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: AppConfig.themeNotifier,
                    builder: (context, currentMode, _) {
                      final isCurrentDark = currentMode == ThemeMode.dark;
                      return _SettingsTile(
                        icon: isCurrentDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title: 'Tema Tampilan',
                        subtitle: isCurrentDark ? 'Mode Gelap' : 'Mode Terang',
                        trailing: Switch.adaptive(
                          value: isCurrentDark,
                          activeTrackColor: accent,
                          activeThumbColor: isDark ? AppTheme.canvasDark : Colors.white,
                          onChanged: (val) {
                            AppConfig.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                          },
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  const _SettingsTile(
                    icon: Icons.language_rounded,
                    title: 'Bahasa Antarmuka',
                    subtitle: 'Bahasa Indonesia (Utama)',
                  ),
                ],
              ),
            ),



            const SizedBox(height: 24),

            // ── Section: Bantuan & Informasi ──
            Text(
              'Bantuan & Legalitas',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Panduan Peneliti Turats',
                    subtitle: 'Metodologi sitasi & riset berbasis AI',
                    trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: surface,
                          title: Text('Panduan OpenTurath', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          content: Text(
                            'OpenTurath AI menyajikan jawaban dengan rujukan langsung ke naskah kitab kuning mu\'tabarah. Anda dapat memverifikasi dalil dengan memeriksa nomor rujukan sitasi pada teks jawaban.',
                            style: GoogleFonts.outfit(fontSize: 13.5, height: 1.4),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang OpenTurath AI',
                    subtitle: 'Versi $_appVersion · Platform Riset Turats Islam Berbasis AI',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Logout Button ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: (_isLoggingOut || _isDeletingAccount) ? null : _logout,
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
                label: Text(
                  _isLoggingOut ? 'Sedang keluar...' : 'Keluar dari Akun',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x55EF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 12),

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
        ),
      );
    },
  ),
),
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
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF28292A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: accent),
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
