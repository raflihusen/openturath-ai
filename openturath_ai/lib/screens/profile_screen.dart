import 'dart:async';
import 'package:flutter/material.dart';
import '../core/l10n/app_dictionary.dart';
import '../widgets/language_switcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/app_config.dart';
import '../core/app_copy.dart';
import '../core/app_snackbar.dart';
import '../core/membership_pass_state.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/editorial.dart';
import '../widgets/legal_document_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late final Stream<UserModel?> _users;
  bool _busy = false;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _users = _authService.userStream;
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    } catch (_) { /* Do not display an invented version. */ }
  }

  Future<void> _accountAction({required bool delete}) async {
    if (_busy) return;
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(context.tr(delete ? AppCopy.deleteAccountTitle : AppCopy.logoutDialogTitle)),
      content: Text(context.tr(delete ? AppCopy.deleteAccountBody : AppCopy.logoutDialogBody)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('shell.cancel'))),
        FilledButton(onPressed: () => Navigator.pop(context, true),
          child: Text(context.tr(delete ? AppCopy.deleteAccountButton : AppCopy.logoutButton))),
      ],
    ));
    if (!mounted || confirm != true) return;
    setState(() => _busy = true);
    try {
      if (delete) { await _authService.deleteAccount(); } else { await _authService.signOut(); }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnackBar.error(context, error.toString().contains('requires-recent-login')
        ? context.tr(AppCopy.recentLoginRequired)
        : context.tr(delete ? 'shell.delete_failed' : 'shell.logout_failed'));
    }
  }

  void _openSubscription(UserModel? user) {
    NavigationGuard.safePushNamed(context, AppRoutes.subscription, arguments: {
      'user': user,
      'agent': AgentModel.defaultAgents.firstWhere((agent) => agent.id == 'fiqh_tahawwulat'),
    });
  }

  Future<void> _chooseAppearance() async {
    await showModalBottomSheet<void>(context: context, showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(child: SingleChildScrollView(child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24),
        child: ValueListenableBuilder<ThemeMode>(valueListenable: AppConfig.themeNotifier,
          builder: (context, selected, _) => Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.tr('shell.appearance'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            for (final option in const [
              (ThemeMode.system, 'shell.theme_system', Icons.brightness_auto_outlined),
              (ThemeMode.light, 'shell.theme_light', Icons.light_mode_outlined),
              (ThemeMode.dark, 'shell.theme_dark', Icons.dark_mode_outlined),
            ]) EditorialRow(title: context.tr(option.$2), leading: Icon(option.$3),
              selected: selected == option.$1,
              trailing: selected == option.$1 ? const Icon(Icons.check_rounded) : null,
              onTap: () async {
                try { await AppConfig.setThemeMode(option.$1); }
                catch (_) { if (mounted) AppSnackBar.error(this.context, this.context.tr('shell.preference_failed')); }
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              }),
          ])),
      ))));
  }

  void _showAccess(UserModel user, MembershipPassSummary summary) {
    showModalBottomSheet<void>(context: context, showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(child: SingleChildScrollView(child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.tr('shell.access_details'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          for (final id in summary.agentIds)
            EditorialRow(title: _agentTitle(id), subtitle:
              user.entitlements[id]?.expiry == null ? context.tr('shell.access_active') :
              context.tr('shell.expires', args: {'date': _date(user.entitlements[id]!.expiry!)})),
        ]),
      ))));
  }

  String _agentTitle(String id) {
    if (id == 'all_access' || id == 'all_ai') return context.tr('shell.all_assistants');
    for (final agent in AgentModel.defaultAgents) {
      if (agent.id == id) return context.tr(agent.title);
    }
    return id;
  }

  String _date(DateTime date) => MaterialLocalizations.of(context).formatMediumDate(date);

  @override
  Widget build(BuildContext context) => StreamBuilder<UserModel?>(
    stream: _users, initialData: _authService.cachedCurrentUser,
    builder: (context, snapshot) {
      final firebaseUser = _authService.currentUser;
      final user = snapshot.data?.uid == firebaseUser?.uid ? snapshot.data : null;
      final name = user?.name.isNotEmpty == true ? user!.name :
        firebaseUser?.isAnonymous == true ? context.tr('shell.guest') : firebaseUser?.displayName ?? context.tr('shell.your_account');
      final email = user?.email.isNotEmpty == true ? user!.email : firebaseUser?.email;
      final access = resolveMembershipPass(user);
      return EditorialPage(title: context.tr('shell.settings'), subtitle: context.tr('shell.settings_subtitle'), maxWidth: 760,
        children: [
          EditorialRow(title: name, subtitle: email?.isNotEmpty == true ? email : context.tr('shell.guest_mode'),
            leading: const Icon(Icons.person_outline_rounded, size: 28)),
          const SizedBox(height: 32),
          EditorialSection(title: context.tr('shell.study_access'), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (user == null && firebaseUser?.isAnonymous != true)
              Text(context.tr('shell.access_unavailable'))
            else ...[
              Text(context.tr(access.accessLabel), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(context.tr(access.supportingLabel)),
              if (access.expiresAt != null) Padding(padding: const EdgeInsets.only(top: 8),
                child: Text(context.tr('shell.valid_until', args: {'date': _date(access.expiresAt!)}), style: Theme.of(context).textTheme.bodySmall)),
            ],
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 12, children: [
              EditorialButton(label: user == null ? context.tr('shell.access_options') : context.tr(access.ctaLabel),
                secondary: true, onPressed: () => _openSubscription(user)),
              if (user != null && access.isOpen && access.agentIds.isNotEmpty)
                EditorialButton(label: context.tr('shell.access_details'), secondary: true, onPressed: () => _showAccess(user, access)),
            ]),
          ])),
          const SizedBox(height: 40),
          EditorialSection(title: context.tr('shell.preferences'), child: Column(children: [
            ValueListenableBuilder<ThemeMode>(valueListenable: AppConfig.themeNotifier,
              builder: (context, mode, _) => EditorialRow(title: context.tr('shell.appearance'),
                subtitle: switch (mode) { ThemeMode.system => context.tr('shell.theme_system'), ThemeMode.light => context.tr('shell.theme_light'), ThemeMode.dark => context.tr('shell.theme_dark') },
                leading: const Icon(Icons.contrast_rounded), trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _chooseAppearance)),
            EditorialRow(title: context.tr('shell.language'),
              subtitle: switch (context.languageCode) { 'en' => 'English', 'ar' => 'العربية', _ => 'Bahasa Indonesia' },
              leading: const Icon(Icons.translate_rounded), trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => LanguageSwitcher.show(context)),
          ])),
          const SizedBox(height: 40),
          EditorialSection(title: context.tr('shell.about'), child: Column(children: [
            EditorialRow(title: 'OpenTurath', subtitle: _appVersion == null ? context.tr(AppCopy.academicSlogan) : context.tr('shell.version', args: {'version': _appVersion!})),
            EditorialRow(title: context.tr(AppCopy.termsOfService), onTap: () => LegalDocumentSheet.showTermsOfService(context)),
            EditorialRow(title: context.tr(AppCopy.privacyPolicy), onTap: () => LegalDocumentSheet.showPrivacyPolicy(context)),
            EditorialRow(title: context.tr(AppCopy.paymentAndRefund), onTap: () => LegalDocumentSheet.showRefundPolicy(context)),
            EditorialRow(title: context.tr(AppCopy.aiGuideline), onTap: () => LegalDocumentSheet.showAiGuideline(context)),
            EditorialRow(title: context.tr(AppCopy.supportAndContact), onTap: () => LegalDocumentSheet.showContactSupport(context)),
          ])),
          const SizedBox(height: 40),
          EditorialRow(title: _busy ? context.tr('shell.processing') : context.tr('shell.logout'), leading: const Icon(Icons.logout_rounded),
            onTap: _busy ? null : () => _accountAction(delete: false)),
          EditorialRow(title: context.tr('shell.delete_account'), subtitle: context.tr('shell.delete_review'),
            leading: const Icon(Icons.delete_outline_rounded), onTap: _busy ? null : () => _accountAction(delete: true)),
        ]);
    },
  );
}
