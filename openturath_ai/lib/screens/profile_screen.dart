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

import 'package:openturath_ai/core/design/ot_buttons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;
  String _appVersion = '—';

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
                .copyWith(fontSize: OTFontSize.s18),
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
              style: OTButtons.destructive(isDark),
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
                      .copyWith(fontSize: OTFontSize.s18),
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
              style: OTButtons.destructive(isDark),
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
    final allAccess = summary.agentIds.contains('all_access') ||
        summary.agentIds.contains('all_ai');
    // Akses penuh: tampilkan nama asisten yang benar-benar terbuka.
    final rows = allAccess
        ? [
            for (final agent in AgentModel.defaultAgents)
              if (!agent.isComingSoon) (Loc.text(agent.title), ''),
          ]
        : [
            for (final entry in entries)
              (
                _entitlementTitle(entry.key),
                entry.value.expiry == null
                    ? Loc.tr('activeSubscription')
                    : Loc.tr(
                        'expiryDate', [_formatAccessDate(entry.value.expiry!)]),
              ),
          ];
    showAdaptiveSheet<void>(
      context: context,
      isScrollControlled: rows.length > 6,
      backgroundColor: surface,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 12, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: SheetGrabber(bottom: 12)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Loc.tr('ui_6a2b35b4ca'),
                          style: OTTypography.cardTitle(color: textPrimary)
                              .copyWith(fontSize: OTFontSize.s18)),
                      const SizedBox(height: 4),
                      Text(
                        allAccess
                            ? '${Loc.tr('ui_b236ca6182')} · ${summary.supportingLabel}'
                            : Loc.tr('ui_b92aed18d1'),
                        style: OTTypography.caption(color: textSecondary)
                            .copyWith(fontSize: OTFontSize.s14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      MaterialLocalizations.of(sheetContext).closeButtonTooltip,
                  icon:
                      Icon(Icons.close_rounded, size: 20, color: textSecondary),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: OTColors.border(isDark)),
                  itemBuilder: (_, index) => _AccessPortfolioRow(
                    title: rows[index].$1,
                    subtitle: rows[index].$2,
                    color: textPrimary,
                    muted: textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
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
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
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
                      onViewAccess: membership.isOpen &&
                              membership.agentIds.isNotEmpty
                          ? () => _showAccessPortfolio(userModel, membership)
                          : null,
                    )),

                    const SizedBox(height: 18),

                    // ── Card 2: Mode Tampilan 3 Pilihan & Bahasa ──
                    Container(
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: OTRadius.cardBorder,
                        border: Border.all(color: surface),
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
                                            fontSize: OTFontSize.s14,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: OTColors.surfaceSubtle(isDark),
                                        borderRadius: BorderRadius.circular(
                                            OTRadius.input),
                                      ),
                                      child: LayoutBuilder(
                                          builder: (context, box) {
                                        final stacked = box.maxWidth < 440 &&
                                            MediaQuery.textScalerOf(context)
                                                    .scale(14) >
                                                18;
                                        final choices = <Widget>[
                                          _buildThemeOption(
                                            stacked: stacked,
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
                                            stacked: stacked,
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
                                            stacked: stacked,
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
                                        ];
                                        return stacked
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: choices)
                                            : Row(children: choices);
                                      }),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: border),
                          Padding(padding: const EdgeInsets.all(24), child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [Icon(Icons.translate_rounded, color: textSecondary),
                              const SizedBox(width: 12), Text(AppCopy.language, style: OTTypography.bodyMedium(color: textPrimary))]),
                            const SizedBox(height: 16),
                            Directionality(textDirection: TextDirection.ltr, child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: OTColors.surfaceSubtle(isDark), borderRadius: OTRadius.inputBorder),
                              child: Row(children: [for (final code in const ['id', 'en', 'ar'])
                                _buildThemeOption(title: code.toUpperCase(),
                                  isSelected: Loc.language == code, isDark: isDark,
                                  textPrimary: textPrimary, textSecondary: textSecondary,
                                  onTap: () async { try { await AppConfig.setLocale(code); } catch (_) {} }),
                              ]))),
                          ])),
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
                        border: Border.all(color: surface),
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
                            color: OTColors.textPrimary(isDark),
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
              .copyWith(fontSize: OTFontSize.s20),
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
      borderRadius: BorderRadius.circular(OTRadius.xs),
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

  static String _memberIdFor(String uid) {
    final clean = uid.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (clean.length < 8 || uid.startsWith('guest_')) return '';
    return 'OT  ${clean.substring(0, 4)}  ${clean.substring(clean.length - 4)}';
  }

  Widget _buildThemeOption({
    required String title,
    IconData? icon,
    required bool isSelected,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
    bool stacked = false,
  }) {
    final color = isSelected ? textPrimary : textSecondary;
    final option = Semantics(
        button: true,
        selected: isSelected,
        child: Material(
            color: isSelected ? OTColors.surface(isDark) : Colors.transparent,
            borderRadius: BorderRadius.circular(OTRadius.input),
            child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
                borderRadius: BorderRadius.circular(OTRadius.input),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (icon != null) ...[Icon(icon, size: 16, color: color),
                              const SizedBox(width: 4)],
                              Flexible(
                                  child: Text(Loc.text(title),
                                      textAlign: TextAlign.center,
                                      style: OTTypography.bodyMedium(
                                          color: color))),
                            ]))))));
    return stacked ? option : Expanded(child: option);
  }
}

/// Kartu akses anggota: merangkum identitas, status, dan ruang AI yang dapat
/// dipakai tanpa menyamarkan halaman pengaturan sebagai layar perbankan.
class _MembershipPass extends StatelessWidget {
  const _MembershipPass(
      {required this.holderName,
      required this.email,
      required this.summary,
      required this.isDark,
      required this.onManage,
      this.onViewAccess,
      this.memberId = ''});
  final String holderName;
  final String email;
  final String memberId;
  final MembershipPassSummary summary;
  final bool isDark;
  final VoidCallback onManage;
  final VoidCallback? onViewAccess;

  @override
  Widget build(BuildContext context) {
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final unlimited = summary.isOpen &&
        (summary.expiresAt == null || summary.expiresAt!.year >= 2090);
    final expiry = unlimited
        ? Loc.tr('lifetimeAccess')
        : summary.expiresAt == null
            ? null
            : HijriDateUtils.formatMasehiOnly(summary.expiresAt!.toLocal());
    return Container(
      padding: const EdgeInsets.all(OTSpacing.lg),
      decoration: BoxDecoration(
          color: OTColors.surface(isDark), borderRadius: OTRadius.cardBorder),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(OTSpacing.md),
                decoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(isDark),
                    borderRadius: OTRadius.inputBorder),
                child: SizedBox.square(
                    dimension: 48,
                    child: Center(
                        child: Text(
                            holderName.trim().isEmpty
                                ? 'O'
                                : holderName
                                    .trim()
                                    .characters
                                    .first
                                    .toUpperCase(),
                            style: OTTypography.pageTitle(color: ink))))),
            const SizedBox(width: OTSpacing.md),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(holderName, style: OTTypography.screenTitle(color: ink)),
                  if (email.isNotEmpty)
                    Text(email,
                        textDirection: TextDirection.ltr,
                        style: OTTypography.caption(color: muted)),
                ])),
          ]),
          const SizedBox(height: OTSpacing.lg),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(isDark),
                  borderRadius: OTRadius.cardBorder),
              child: Row(children: [
                Icon(summary.isOpen ? Icons.verified_rounded : Icons.lock_outline_rounded, color: ink, size: 24),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(summary.accessLabel, style: OTTypography.bodyMedium(color: ink)),
                  if (expiry != null) ...[
                    const SizedBox(height: 6),
                    Text(unlimited ? expiry : '${AppCopy.validUntil} $expiry', style: OTTypography.caption(color: muted)),
                  ],
                ])),
              ])),
          const SizedBox(height: OTSpacing.lg),
          Wrap(spacing: OTSpacing.sm, runSpacing: OTSpacing.sm, children: [
            if (onViewAccess != null)
              OutlinedButton.icon(
                  onPressed: onViewAccess,
                  icon: const Icon(Icons.auto_stories_outlined, size: 18),
                  label: Text(Loc.tr('viewAccessList'))),
            FilledButton.icon(
                onPressed: onManage,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text(summary.ctaLabel)),
          ]),
        ]),

    );
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
            horizontal: OTSpacing.base, vertical: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(Icons.check_rounded, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: OTTypography.bodyMedium(color: color)),
          ),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: OTTypography.caption(color: muted)),
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
      borderRadius: BorderRadius.circular(OTRadius.input),
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
