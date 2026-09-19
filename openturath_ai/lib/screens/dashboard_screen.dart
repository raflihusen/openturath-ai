import '../widgets/daily_gem_card.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/l10n/app_dictionary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_snackbar.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../models/field_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../widgets/editorial.dart';
import '../widgets/update_ready_banner.dart';
import 'main_shell_screen.dart';
import 'specialist_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AgentService _agentService = AgentService();
  late final Stream<UserModel?> _users;
  List<AgentModel> _agents = AgentModel.defaultAgents;
  String? _lastOpenedAgentId;
  String? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _users = _authService.userStream;
    _loadData();
    UpdateService().checkForUpdatesSilently();
  }

  Future<void> _loadData() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() { _loading = true; _loadError = null; });
    try {
      final agents = await _agentService.getAgents().timeout(const Duration(seconds: 12));
      final prefs = await SharedPreferences.getInstance();
      if (!mounted || _authService.currentUser?.uid != uid) return;
      setState(() {
        _agents = agents;
        _lastOpenedAgentId = prefs.getString('last_opened_notebook_$uid');
      });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'shell.catalog_error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDirectory({String? fieldId}) {
    final shell = MainShellController.of(context);
    if (shell != null) {
      shell.switchTab(1, fieldId: fieldId);
    } else {
      NavigationGuard.safeNavigate(context, () => Navigator.push(context,
        MaterialPageRoute<void>(builder: (_) => SpecialistListScreen(
          field: fieldId == null ? null : FieldModel.findById(fieldId)))));
    }
  }

  Future<void> _openNotebook(AgentModel agent, UserModel? user) async {
    if (agent.isComingSoon) {
      AppSnackBar.warning(context, context.tr('shell.assistant_preparing', args: {'name': context.tr(agent.title)}));
      return;
    }
    if (user == null || !user.hasAccessToAgent(agent.id)) {
      NavigationGuard.safePushNamed(context, AppRoutes.subscription,
        arguments: {'user': user, 'agent': agent});
      return;
    }
    final uid = _authService.currentUser?.uid;
    if (uid == null || user.uid != uid) return;
    try {
      await AgentSessionManager.instance.openAgent(agent, user: user);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('shell.session_error'));
      return;
    }
    if (!mounted || _authService.currentUser?.uid != uid) return;
    setState(() => _lastOpenedAgentId = agent.id);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_authService.currentUser?.uid == uid) {
        await prefs.setString('last_opened_notebook_$uid', agent.id);
      }
    } catch (_) { /* Session remains usable without local history. */ }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<UserModel?>(
    stream: _users,
    initialData: _authService.cachedCurrentUser,
    builder: (context, snapshot) {
      final uid = _authService.currentUser?.uid;
      final candidate = snapshot.data;
      final user = candidate?.uid == uid ? candidate : null;
      final name = user?.name.trim();
      return EditorialPage(
        eyebrow: name == null || name.isEmpty ? context.tr('shell.welcome') : context.tr('shell.welcome_name', args: {'name': name}),
        title: context.tr('shell.dashboard_title'),
        subtitle: context.tr('shell.tagline'),
        maxWidth: 980,
        children: [
          const UpdateReadyBanner(),
          const SizedBox(height: 16),
          ListenableBuilder(listenable: AgentSessionManager.instance, builder: (context, _) {
            final active = AgentSessionManager.instance.activeTab?.agent;
            AgentModel? previous;
            for (final agent in _agents) {
              if (agent.id == _lastOpenedAgentId) previous = agent;
            }
            final target = active ?? previous;
            return EditorialCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(target == null ? context.tr('shell.start_study') : context.tr('shell.resume_heading'), style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 12),
              Text(target == null ? context.tr('shell.find_assistant') : context.tr(target.title), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(target == null ? context.tr('shell.choose_discipline')
                : active != null ? context.tr('shell.session_open') : context.tr('shell.last_assistant'),
                style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              EditorialButton(label: target == null ? context.tr('shell.browse_assistants') : context.tr('shell.resume_study'),
                icon: Icons.arrow_forward_rounded,
                onPressed: () => target == null ? _openDirectory() : _openNotebook(target, user)),
            ]));
          }),
          const SizedBox(height: 40),
          const DailyGemCard(),
          const SizedBox(height: 40),
          EditorialSection(title: context.tr('shell.disciplines'),
            trailing: TextButton(onPressed: _openDirectory, child: Text(context.tr('shell.see_all'))),
            child: Column(children: [
              for (final field in FieldModel.defaultFields.where((field) =>
                  const ['fiqh', 'hadith', 'tafsir', 'aqidah', 'usul', 'lughah'].contains(field.id)))
                EditorialRow(title: context.tr(field.name), subtitle: context.tr(field.description),
                  leading: Icon(field.icon, size: 20),
                  trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
                  onTap: () => _openDirectory(fieldId: field.id)),
            ])),
          const SizedBox(height: 40),
          EditorialSection(title: context.tr('shell.tahawwulat'), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const EditorialArabicText('فقه التحولات', fontSize: 30),
            const SizedBox(height: 8),
            Text(context.tr('shell.tahawwulat_description')),
            const SizedBox(height: 16),
            EditorialButton(label: context.tr('shell.explore_field'), secondary: true,
              icon: Icons.arrow_forward_rounded, onPressed: () => _openDirectory(fieldId: 'fiqh_tahawwulat')),
          ])),
          const SizedBox(height: 32),
          if (_loadError != null)
            EditorialRow(title: context.tr(_loadError!),
              subtitle: context.tr('shell.catalog_fallback'),
              trailing: EditorialButton(label: context.tr('shell.retry'), secondary: true, onPressed: _loadData)),
          if (_loading) Semantics(label: context.tr('shell.loading_catalog'), child: const LinearProgressIndicator(minHeight: 1)),
        ],
      );
    },
  );
}
