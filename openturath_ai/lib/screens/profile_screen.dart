import '../widgets/adaptive_sheet.dart';
import '../core/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/scholarly_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/routes.dart';
import '../core/app_config.dart';
import '../core/app_copy.dart';
import '../core/hijri_date_utils.dart';
import '../widgets/openturath_brand.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../widgets/ot_motion_widgets.dart';
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
            final fbUser = _authService.currentUser;

            final displayName = userModel?.name.isNotEmpty == true
                ? userModel!.name
                : (fbUser?.displayName ?? 'Pengguna');
            final email = userModel?.email.isNotEmpty == true
                ? userModel!.email
                : (fbUser?.email ?? '');
            final membership = resolveMembershipPass(userModel);

            return Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  physics: const BouncingScrollPhysics(),
                  children: [
                OTReveal(
                    child: _MembershipPass(
                  holderName: displayName,
                  email: email,
                  memberId: _memberIdFor(userModel?.uid ?? ''),
                  summary: membership,
                  isDark: isDark,
                  onManage: () => _openSubscription(userModel),
                  onViewAccess:
                      membership.isOpen && membership.agentIds.isNotEmpty
                          ? () => _showAccessPortfolio(userModel, membership)
                          : null,
                )),

                const SizedBox(height: 18),

                // ── Card 2: Mode Tampilan 3 Pilihan & Bahasa ──
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
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

                // ── Tentang & akun: satu kelompok baris ──
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
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
                      Divider(height: 1, color: border),
                      _AccountActionRow(
                        icon: Icons.logout_rounded,
                        label: _isLoggingOut
                            ? AppCopy.loggingOut
                            : AppCopy.logoutButton,
                        color: textPrimary,
                        onTap: (_isLoggingOut || _isDeletingAccount)
                            ? null
                            : _logout,
                      ),
                      Divider(height: 1, color: border),
                      _AccountActionRow(
                        icon: Icons.delete_outline_rounded,
                        label: AppCopy.deleteAccountButton,
                        color: textSecondary,
                        busy: _isDeletingAccount,
                        onTap: (_isLoggingOut || _isDeletingAccount)
                            ? null
                            : _deleteAccount,
                      ),
                    ],
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

  static String _memberIdFor(String uid) {
    final clean = uid.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (clean.length < 8 || uid.startsWith('guest_')) return '';
    return 'OT  ${clean.substring(0, 4)}  ${clean.substring(clean.length - 4)}';
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
    // Pilihan aktif harus lebih terang dari lintasannya di kedua mode.
    final activeBg = isDark ? OTColors.border(isDark) : OTColors.surface(isDark);
    final activeFg = textPrimary;
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
          padding: const EdgeInsets.symmetric(vertical: 9),
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
                  fontSize: 13,
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

  /// Nomor anggota yang diturunkan dari UID akun; bukan nomor kartu tiruan.
  final String memberId;

  const _MembershipPass({
    required this.holderName,
    required this.email,
    required this.summary,
    required this.isDark,
    required this.onManage,
    this.onViewAccess,
    this.memberId = '',
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

  Widget _back(Color cardColor, Color onCard, Color onCardMuted) {
    final names = AgentModel.defaultAgents
        .where((agent) => summary.agentIds.contains(agent.id))
        .map((agent) => Loc.text(agent.title))
        .toList();
    return Container(
      padding: const EdgeInsets.all(OTSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: onCard.withValues(alpha: isDark ? 0.14 : 0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppCopy.navStudies.toUpperCase(),
            style: ScholarlyFonts.outfit(
              color: onCardMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: OTSpacing.sm),
          Expanded(
            child: names.isEmpty
                ? Text(
                    summary.accessLabel,
                    style: ScholarlyFonts.outfit(
                        color: onCard, fontSize: 15, height: 1.4),
                  )
                : ClipRect(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final name in names)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: OTRadius.chipBorder,
                              border: Border.all(
                                  color: onCard.withValues(alpha: 0.28)),
                            ),
                            child: Text(
                              name,
                              style: ScholarlyFonts.outfit(
                                  color: onCard, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          Text(
            Loc.tr('cardFlipHint'),
            style: ScholarlyFonts.outfit(color: onCardMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final foreground = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final isOpen = summary.isOpen;
    // Kartu anggota: tinta gelap di kedua mode, tanpa emas dan tanpa nomor tiruan.
    final cardColor = OTColors.inverseSurface(isDark);
    const onCard = OTColors.onInverseSurface;
    final onCardMuted = onCard.withValues(alpha: 0.64);
    final expiry = summary.expiresAt == null ? '—' : _expiryLabel();

    final card = Semantics(
          label:
              'OpenTurath. ${summary.badge}. $holderName. ${summary.accessLabel}',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: AspectRatio(
                aspectRatio: 1.586,
                child: OTFlipCard(
                  semanticLabel: Loc.tr('cardFlipHint'),
                  back: _back(cardColor, onCard, onCardMuted),
                  front: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    // Kilau halus dari kiri-atas; tetap satu warna tinta.
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(cardColor, onCard, 0.09)!,
                        cardColor,
                        Color.lerp(cardColor, const Color(0xFF000000), 0.3)!,
                      ],
                      stops: const [0, 0.45, 1],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: onCard.withValues(alpha: 0.14)),
                  ),
                  child: Stack(
                    children: [
                      PositionedDirectional(
                        end: -36,
                        bottom: -44,
                        child: ExcludeSemantics(
                          child: OpenTurathMark(
                            size: 220,
                            color: onCard.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(OTSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const OpenTurathMark(size: 22, color: onCard),
                                const SizedBox(width: OTSpacing.sm),
                                Text(
                                  'OpenTurath',
                                  textDirection: TextDirection.ltr,
                                  style: ScholarlyFonts.newsreader(
                                    color: onCard,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: OTRadius.chipBorder,
                                    border: Border.all(
                                        color: onCard.withValues(alpha: 0.32)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isOpen) ...[
                                        Icon(Icons.lock_outline_rounded,
                                            color: onCardMuted, size: 13),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        summary.badge,
                                        style: ScholarlyFonts.outfit(
                                          color: onCard,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (memberId.isNotEmpty) ...[
                              Text(
                                memberId,
                                textDirection: TextDirection.ltr,
                                style: ScholarlyFonts.outfit(
                                  color: onCard.withValues(alpha: 0.86),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2.4,
                                ),
                              ),
                              const SizedBox(height: OTSpacing.md),
                            ],
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        holderName.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: ScholarlyFonts.outfit(
                                          color: onCard,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      if (email.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: ScholarlyFonts.outfit(
                                              color: onCardMuted, fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: OTSpacing.md),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      summary.expiryLabel.isEmpty
                                          ? AppCopy.validUntil
                                          : summary.expiryLabel,
                                      style: ScholarlyFonts.outfit(
                                          color: onCardMuted, fontSize: 11),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      expiry,
                                      style: ScholarlyFonts.outfit(
                                        color: onCard,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
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
        );

    Widget action(IconData icon, String label, VoidCallback? onTap) =>
        OTBentoTile(
          onTap: onTap,
          semanticLabel: label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: foreground),
                  const Spacer(),
                  Icon(otOutwardIcon(context), size: 18, color: muted),
                ],
              ),
              const SizedBox(height: OTSpacing.md),
              Text(label, style: OTTypography.bodyMedium(color: foreground)),
            ],
          ),
        );
    final actions = <Widget>[
      if (onViewAccess != null)
        action(Icons.auto_stories_outlined, Loc.tr('viewAccessList'),
            onViewAccess),
      action(Icons.tune_rounded, summary.ctaLabel, onManage),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      // Lebar: kartu di kiri, aksi sebagai ubin di kanan setinggi kartu.
      if (constraints.maxWidth >= 620) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ukuran alami kartu (rasio 1,586), bukan melebar mengikuti kolom.
              SizedBox(width: 340, child: card),
              const SizedBox(width: OTSpacing.md),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: OTColors.surface(isDark),
                    borderRadius: OTRadius.cardBorder,
                    border: Border.all(color: OTColors.border(isDark)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(OTSpacing.base),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Loc.tr('planLabel'),
                                style: ScholarlyFonts.outfit(
                                    fontSize: 12, color: muted)),
                            const SizedBox(height: 2),
                            Text(summary.accessLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ScholarlyFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: foreground)),
                            if (summary.supportingLabel.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(summary.supportingLabel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: ScholarlyFonts.outfit(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: muted)),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (onViewAccess != null) ...[
                            Divider(height: 1, color: OTColors.border(isDark)),
                            _AccountActionRow(
                              icon: Icons.auto_stories_outlined,
                              label: Loc.tr('viewAccessList'),
                              color: foreground,
                              onTap: onViewAccess,
                            ),
                          ],
                          Divider(height: 1, color: OTColors.border(isDark)),
                          _AccountActionRow(
                            icon: Icons.tune_rounded,
                            label: summary.ctaLabel,
                            color: foreground,
                            onTap: onManage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card,
          for (final tile in actions) ...[
            const SizedBox(height: OTSpacing.md),
            tile,
          ],
        ],
      );
    });
  }
}

class _AccountActionRow extends StatelessWidget {
  const _AccountActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.base, vertical: 14),
        child: Row(
          children: [
            if (busy)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: OTTypography.bodyMedium(color: color)),
            ),
          ],
        ),
      ),
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
