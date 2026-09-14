import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../core/navigation_guard.dart';
import '../widgets/apple_interactive_wrapper.dart';
import '../widgets/legal_document_sheet.dart';

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
            style: OTTypography.cardTitle(color: textPrimary)
                .copyWith(fontSize: 18),
          ),
          content: Text(
            AppCopy.logoutDialogBody,
            style: OTTypography.body(color: textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal',
                  style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape:
                    RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.logoutButton,
                  style: OTTypography.button(color: Colors.white)),
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
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (r) => false);
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
              const Icon(Icons.warning_amber_rounded,
                  color: OTColors.destructive, size: 24),
              const SizedBox(width: OTSpacing.sm),
              Expanded(
                child: Text(
                  AppCopy.deleteAccountTitle,
                  style: OTTypography.cardTitle(color: OTColors.destructive)
                      .copyWith(fontSize: 18),
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
              child: Text('Batal',
                  style: OTTypography.button(
                      color: OTColors.textSecondary(isDark))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive,
                shape:
                    RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.deleteAccountButton,
                  style: OTTypography.button(color: Colors.white)),
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
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (r) => false);
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

  void _openSubscription([UserModel? userModel]) {
    final user = userModel ?? _authService.cachedCurrentUser;
    NavigationGuard.safePushNamed(
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

  List<ModuleEntitlement> _activeEntitlements(UserModel? user) {
    if (user == null) return const [];
    return user.entitlements.values
        .where((entitlement) => entitlement.isActive && entitlement.isPremium)
        .toList();
  }

  bool _hasActiveSubscription(UserModel? user) {
    return (user?.isSubscriptionActive ?? false) ||
        _activeEntitlements(user).isNotEmpty;
  }

  String _accessLabel(UserModel? user) {
    if (user == null || !_hasActiveSubscription(user)) {
      return 'Belum ada akses AI aktif';
    }

    final hasAllAccess = user.isSubscriptionActive &&
        user.plan != 'single' &&
        !(user.entitlements['all_access']?.status == 'revoked');
    final allEntitlement =
        user.entitlements['all_access'] ?? user.entitlements['all_ai'];
    if (hasAllAccess || (allEntitlement?.isActive ?? false)) {
      return 'Seluruh asisten OpenTurath';
    }

    final entitledKeys = user.entitlements.entries
        .where((entry) => entry.value.isActive && entry.value.isPremium)
        .map((entry) => entry.key)
        .toSet();
    final titles = AgentModel.defaultAgents
        .where((agent) => entitledKeys.contains(agent.id))
        .map((agent) => agent.title)
        .toList();

    if (titles.isEmpty) return 'Asisten pilihan Anda';
    if (titles.length == 1) return titles.first;
    if (titles.length == 2) return '${titles.first} & ${titles.last}';
    return '${titles.first} +${titles.length - 1} asisten';
  }

  DateTime? _accessExpiry(UserModel? user) {
    if (user?.subscriptionExpiry != null) return user!.subscriptionExpiry;
    final expiries = _activeEntitlements(user)
        .map((entitlement) => entitlement.expiry)
        .whereType<DateTime>()
        .toList()
      ..sort();
    return expiries.isEmpty ? null : expiries.first;
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
            final isSubscribed = _hasActiveSubscription(userModel);
            final accessExpiry = _accessExpiry(userModel);
            final accessLabel = _accessLabel(userModel);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 108),
              physics: const BouncingScrollPhysics(),
              children: [
                _MembershipPass(
                  holderName: displayName,
                  email: email,
                  accessLabel: accessLabel,
                  expiresAt: accessExpiry,
                  isActive: isSubscribed,
                  isDark: isDark,
                  onManage: () => _openSubscription(userModel),
                ),

                const SizedBox(height: 16),

                // ── Card 2: Mode Tampilan 3 Pilihan & Bahasa ──
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
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.palette_outlined,
                                        size: 20, color: textSecondary),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppCopy.appearance,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF27272A)
                                        : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildThemeOption(
                                        title: 'Ikuti Sistem',
                                        icon: Icons.brightness_auto_rounded,
                                        isSelected:
                                            currentMode == ThemeMode.system,
                                        isDark: isDark,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => AppConfig.setThemeMode(
                                            ThemeMode.system),
                                      ),
                                      _buildThemeOption(
                                        title: 'Terang',
                                        icon: Icons.light_mode_rounded,
                                        isSelected:
                                            currentMode == ThemeMode.light,
                                        isDark: isDark,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => AppConfig.setThemeMode(
                                            ThemeMode.light),
                                      ),
                                      _buildThemeOption(
                                        title: 'Gelap',
                                        icon: Icons.dark_mode_rounded,
                                        isSelected:
                                            currentMode == ThemeMode.dark,
                                        isDark: isDark,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        onTap: () => AppConfig.setThemeMode(
                                            ThemeMode.dark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: border),
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: AppCopy.language,
                        subtitle: AppCopy.languageIndonesian,
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: textSecondary, size: 20),
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

                // ── Card 4: Tentang OpenTurath ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: AppCopy.aboutTitle,
                    subtitle: 'Versi $_appVersion · ${AppCopy.appTagline}',
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: textSecondary, size: 20),
                    onTap: () => _showAboutModal(
                      context,
                      isDark,
                      textPrimary,
                      textSecondary,
                      surface,
                      border,
                    ),
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
                      onTap: (_isLoggingOut || _isDeletingAccount)
                          ? null
                          : _logout,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 15),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFF87171),
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _isLoggingOut
                                  ? 'Sedang keluar...'
                                  : AppCopy.logoutButton,
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
                    onPressed: (_isLoggingOut || _isDeletingAccount)
                        ? null
                        : _deleteAccount,
                    child: _isDeletingAccount
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: OTColors.destructive),
                          )
                        : Text(
                            AppCopy.deleteAccountButton,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626),
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
          style: OTTypography.corpusTitle(color: textPrimary)
              .copyWith(fontSize: 20),
        ),
        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
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
              const SizedBox(height: 16),
              Divider(height: 1, color: border),
              const SizedBox(height: 8),
              _buildAboutDocTile(
                icon: Icons.article_outlined,
                title: AppCopy.termsOfService,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () {
                  Navigator.pop(ctx);
                  LegalDocumentSheet.showTermsOfService(context);
                },
              ),
              _buildAboutDocTile(
                icon: Icons.security_outlined,
                title: AppCopy.privacyPolicy,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () {
                  Navigator.pop(ctx);
                  LegalDocumentSheet.showPrivacyPolicy(context);
                },
              ),
              _buildAboutDocTile(
                icon: Icons.payment_outlined,
                title: AppCopy.paymentAndRefund,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () {
                  Navigator.pop(ctx);
                  LegalDocumentSheet.showRefundPolicy(context);
                },
              ),
              _buildAboutDocTile(
                icon: Icons.menu_book_outlined,
                title: AppCopy.aiGuideline,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () {
                  Navigator.pop(ctx);
                  LegalDocumentSheet.showAiGuideline(context);
                },
              ),
              _buildAboutDocTile(
                icon: Icons.headset_mic_outlined,
                title: AppCopy.supportAndContact,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () {
                  Navigator.pop(ctx);
                  LegalDocumentSheet.showContactSupport(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: textPrimary,
              foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
            ),
            child: Text('Tutup', style: OTTypography.button()),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutDocTile({
    required IconData icon,
    required String title,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: OTTypography.captionMedium(color: textPrimary),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: textSecondary),
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
          'Bahasa',
          style: OTTypography.corpusTitle(color: textPrimary)
              .copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antarmuka saat ini tersedia dalam Bahasa Indonesia.',
              style: OTTypography.body(color: textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Bahasa Arab dan Inggris sedang disiapkan.',
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
              shape:
                  RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
            ),
            child: Text('Tutup', style: OTTypography.button()),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final activeFg = isDark ? Colors.white : const Color(0xFF18181B);
    final inactiveFg = textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? activeFg : inactiveFg),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeFg : inactiveFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu akses anggota: merangkum identitas, status, dan ruang AI yang dapat
/// dipakai tanpa menyamarkan halaman pengaturan sebagai layar perbankan.
class _MembershipPass extends StatelessWidget {
  final String holderName;
  final String email;
  final String accessLabel;
  final DateTime? expiresAt;
  final bool isActive;
  final bool isDark;
  final VoidCallback onManage;

  const _MembershipPass({
    required this.holderName,
    required this.email,
    required this.accessLabel,
    required this.expiresAt,
    required this.isActive,
    required this.isDark,
    required this.onManage,
  });

  String _expiryLabel() {
    if (expiresAt == null) return '—';
    const shortMonths = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGU',
      'SEP',
      'OKT',
      'NOV',
      'DES',
    ];
    return '${expiresAt!.day.toString().padLeft(2, '0')} ${shortMonths[expiresAt!.month - 1]} ${expiresAt!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cardStart =
        isDark ? const Color(0xFF303036) : const Color(0xFF25252A);
    final cardEnd = isDark ? const Color(0xFF17171A) : const Color(0xFF111114);
    const foreground = Color(0xFFF8F8F8);
    const muted = Color(0xFFC7C7CC);
    final statusLabel = isActive ? 'AKSES AKTIF' : 'BELUM AKTIF';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label: 'Kartu akses OpenTurath. $statusLabel. $accessLabel',
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onManage,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                height: 206,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cardStart, cardEnd],
                  ),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.26 : 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Stack(
                    children: [
                      // Ornamen geometris halus: memberi karakter tanpa
                      // menyamai visual kartu bank atau mengganggu teks.
                      Positioned(
                        right: -52,
                        top: -76,
                        child: Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: 30,
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -36,
                        bottom: -56,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.035),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'OPEN',
                                  style: GoogleFonts.newsreader(
                                    color: foreground,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 19,
                                    letterSpacing: -0.35,
                                  ),
                                ),
                                Text(
                                  'TURATH',
                                  style: GoogleFonts.outfit(
                                    color: foreground,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white.withValues(alpha: 0.16)
                                        : Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.14)),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: GoogleFonts.outfit(
                                      color: foreground,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'PEMEGANG AKSES',
                              style: GoogleFonts.outfit(
                                color: muted,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              holderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: foreground,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                  color: muted, fontSize: 11.5),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _PassMeta(
                                    label: 'AI YANG DIAKSES',
                                    value: accessLabel,
                                    valueColor: foreground,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _PassMeta(
                                    label: 'BERLAKU HINGGA',
                                    value: _expiryLabel(),
                                    valueColor: foreground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onManage,
          style: FilledButton.styleFrom(
            backgroundColor: OTColors.accent(isDark),
            foregroundColor: isDark ? const Color(0xFF18181B) : Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: Text(
            isActive ? 'Kelola langganan' : 'Lihat pilihan langganan',
            style: OTTypography.button(),
          ),
        ),
      ],
    );
  }
}

class _PassMeta extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _PassMeta({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            color: const Color(0xFFC7C7CC),
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.65,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
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
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.985,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(10),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: OTSpacing.base, vertical: 2),
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
