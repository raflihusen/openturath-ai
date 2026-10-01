import '../widgets/adaptive_sheet.dart';
import '../core/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/scholarly_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/routes.dart';
import '../core/app_config.dart';
import '../core/app_copy.dart';
import '../core/hijri_date_utils.dart';
import '../widgets/openturath_brand.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/user_model.dart';
import '../models/agent_model.dart';
import '../services/auth_service.dart';
import '../core/navigation_guard.dart';
import '../core/membership_pass_state.dart';
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
              child: Text(AppCopy.cancel,
                  style: OTTypography.button(color: textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive(isDark),
                shape:
                    RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.logoutButton,
                  style: OTTypography.button(color: OTColors.onAccent(isDark))),
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
              Icon(Icons.warning_amber_rounded,
                  color: OTColors.destructive(isDark), size: 24),
              const SizedBox(width: OTSpacing.sm),
              Expanded(
                child: Text(
                  AppCopy.deleteAccountTitle,
                  style: OTTypography.cardTitle(
                          color: OTColors.destructive(isDark))
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
              child: Text(AppCopy.cancel,
                  style: OTTypography.button(
                      color: OTColors.textSecondary(isDark))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OTColors.destructive(isDark),
                shape:
                    RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
              ),
              child: Text(AppCopy.deleteAccountButton,
                  style: OTTypography.button(color: OTColors.onAccent(isDark))),
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

  void _showAccessPortfolio(UserModel? user, MembershipPassSummary summary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final surface = OTColors.surface(isDark);
    final entries = (user?.entitlements.entries ??
            const <MapEntry<String, ModuleEntitlement>>[])
        .where((entry) => summary.agentIds.contains(entry.key))
        .toList();
    showAdaptiveSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                          color: textSecondary.withValues(alpha: .35),
                          borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 18),
              Text(Loc.tr('ui_6a2b35b4ca'),
                  style: OTTypography.cardTitle(color: textPrimary)
                      .copyWith(fontSize: 19)),
              const SizedBox(height: 5),
              Text(Loc.tr('ui_b92aed18d1'),
                  style: OTTypography.caption(color: textSecondary)),
              const SizedBox(height: 16),
              if (summary.agentIds.contains('all_access') ||
                  summary.agentIds.contains('all_ai'))
                _AccessPortfolioRow(
                    title: Loc.tr('ui_b236ca6182'),
                    subtitle: summary.supportingLabel,
                    color: textPrimary,
                    muted: textSecondary)
              else
                ...entries.map((entry) => _AccessPortfolioRow(
                      title: _entitlementTitle(entry.key),
                      subtitle: entry.value.expiry == null
                          ? Loc.tr('activeSubscription')
                          : Loc.tr('expiryDate',
                              [_formatAccessDate(entry.value.expiry!)]),
                      color: textPrimary,
                      muted: textSecondary,
                    )),
            ]),
      ),
    );
  }

  static String _formatAccessDate(DateTime value) =>
      HijriDateUtils.formatMasehiOnly(value.toLocal());

  static String _entitlementTitle(String key) => Loc.text(switch (key) {
        'fiqh_tahawwulat' => 'Fikih Tahawwulat',
        'fiqh_syafii' => "Fikih Syafi'i",
        'nahwu' => 'Bahasa Arab',
        'ushul_fiqh' => 'Usul Fikih',
        'tafsir' => 'Tafsir',
        'hadits' => 'Hadis',
        'aqidah' => 'Akidah',
        _ => AppCopy.navStudies,
      });

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
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
        centerTitle: false,
        title: Text(
          AppCopy.navSettings,
          style: ScholarlyFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: _authService.userStream,
          initialData: _authService.cachedCurrentUser,
          builder: (context, snapshot) {
            final userModel = snapshot.data ?? _authService.cachedCurrentUser;
            final fbUser = FirebaseAuth.instance.currentUser;

            final displayName = userModel?.name.isNotEmpty == true
                ? userModel!.name
                : (fbUser?.displayName ?? 'Pengguna');
            final email = userModel?.email.isNotEmpty == true
                ? userModel!.email
                : (fbUser?.email ?? '');
            final membership = resolveMembershipPass(userModel);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  physics: const BouncingScrollPhysics(),
                  children: [
                _MembershipPass(
                  holderName: displayName,
                  email: email,
                  summary: membership,
                  isDark: isDark,
                  onManage: () => _openSubscription(userModel),
                  onViewAccess:
                      membership.isOpen && membership.agentIds.isNotEmpty
                          ? () => _showAccessPortfolio(userModel, membership)
                          : null,
                ),

                const SizedBox(height: 18),

                // ── Card 2: Mode Tampilan 3 Pilihan & Bahasa ──
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
                                      style: ScholarlyFonts.outfit(
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
                                    color: OTColors.surfaceSubtle(isDark),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildThemeOption(
                                        title: AppCopy.modeSystem,
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
                                        title: AppCopy.modeLight,
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
                                        title: AppCopy.modeDark,
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
                        subtitle: Loc.languageNames[Loc.language]!,
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
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: AppCopy.aboutTitle,
                    subtitle: AppCopy.versionWithTagline(_appVersion),
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
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: (_isLoggingOut || _isDeletingAccount)
                          ? null
                          : _logout,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 15),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: OTColors.destructive(isDark),
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _isLoggingOut
                                  ? AppCopy.loggingOut
                                  : AppCopy.logoutButton,
                              style: ScholarlyFonts.outfit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: OTColors.destructive(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Quiet Google Play Compliance: Delete Account ──
                Center(
                  child: TextButton(
                    onPressed: (_isLoggingOut || _isDeletingAccount)
                        ? null
                        : _deleteAccount,
                    child: _isDeletingAccount
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: OTColors.destructive(isDark)),
                          )
                        : Text(
                            AppCopy.deleteAccountButton,
                            style: ScholarlyFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: OTColors.destructive(isDark),
                            ),
                          ),
                  ),
                ),
                ],
              ),
            ),
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
                AppCopy.versionWithTagline(_appVersion),
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
              const Center(child: OpenTurathMark(size: 64)),
              const SizedBox(height: 12),
              Text(Loc.tr('brandPhilosophyTitle'),
                  style: OTTypography.cardTitle(color: textPrimary)),
              const SizedBox(height: 8),
              Text(Loc.tr('brandPhilosophy'),
                  style: OTTypography.body(color: textSecondary)),
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
              foregroundColor: isDark ? const Color(0xFF191919) : Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: OTRadius.buttonBorder),
            ),
            child: Text(AppCopy.close, style: OTTypography.button()),
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
                Loc.text(title),
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
    showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(AppCopy.language),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                for (final entry in Loc.languageNames.entries)
                  ListTile(
                      title: Text(entry.value),
                      trailing: entry.key == Loc.language
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        try {
                          await AppConfig.setLocale(entry.key);
                        } catch (_) {
                          // The in-memory preference is still applied.
                        }
                      }),
              ]),
            ));
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
    final activeBg = isDark ? const Color(0xFF191919) : Colors.white;
    final activeFg = isDark ? Colors.white : const Color(0xFF191919);
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
                Loc.text(title),
                style: ScholarlyFonts.outfit(
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
  final MembershipPassSummary summary;
  final bool isDark;
  final VoidCallback onManage;
  final VoidCallback? onViewAccess;

  const _MembershipPass({
    required this.holderName,
    required this.email,
    required this.summary,
    required this.isDark,
    required this.onManage,
    this.onViewAccess,
  });

  String _expiryLabel() {
    if (summary.expiresAt == null) return '—';
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
    return '${summary.expiresAt!.day.toString().padLeft(2, '0')} ${shortMonths[summary.expiresAt!.month - 1]} ${summary.expiresAt!.year}';
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final cardColor = OTColors.primaryContainer(isDark);
    final foreground = OTColors.onPrimaryContainer(isDark);
    final muted = foreground.withValues(alpha: 0.78);
    final isOpen = summary.isOpen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label:
              'OpenTurath. ${summary.badge}. ${summary.accessLabel}',
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onViewAccess ?? onManage,
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'OpenTurath',
                                  style: ScholarlyFonts.newsreader(
                                    color: foreground,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: OTColors.surface(isDark).withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOpen
                                            ? Icons.workspace_premium_rounded
                                            : Icons.lock_outline_rounded,
                                        color: foreground,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        summary.badge,
                                        style: ScholarlyFonts.outfit(
                                          color: foreground,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            Text(
                              Loc.tr('membershipFor'),
                              style: ScholarlyFonts.outfit(
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
                              style: ScholarlyFonts.outfit(
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
                              style: ScholarlyFonts.outfit(
                                  color: muted, fontSize: 11.5),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _PassMeta(
                                    label: AppCopy.navStudies,
                                    value: summary.accessLabel,
                                    valueColor: foreground,
                                    labelColor: muted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _PassMeta(
                                    label: summary.expiryLabel.isEmpty
                                        ? AppCopy.validUntil
                                        : summary.expiryLabel,
                                    value: summary.expiresAt == null
                                        ? '—'
                                        : _expiryLabel(),
                                    valueColor: foreground,
                                    labelColor: muted,
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
        OutlinedButton.icon(
          onPressed: onManage,
          style: OutlinedButton.styleFrom(
            foregroundColor: OTColors.textPrimary(isDark),
            backgroundColor: OTColors.surface(isDark),
            side: BorderSide(color: OTColors.border(isDark)),
            minimumSize: const Size.fromHeight(44),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: Text(
            summary.ctaLabel,
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
  final Color labelColor;

  const _PassMeta({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ScholarlyFonts.outfit(
            color: labelColor,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ScholarlyFonts.outfit(
            color: valueColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AccessPortfolioRow extends StatelessWidget {
  const _AccessPortfolioRow({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.muted,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: muted.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(Loc.text(title),
                    style: OTTypography.bodyMedium(color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: OTTypography.caption(color: muted)),
              ])),
        ]),
      );
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
    Loc.watch(context);
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
          Loc.text(title),
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
