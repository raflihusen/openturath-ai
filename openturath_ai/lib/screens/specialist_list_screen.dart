import '../core/l10n/app_dictionary.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../core/arabic_utils.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../core/navigation_guard.dart';
import '../widgets/corpus_kind_control.dart';
import '../widgets/specialist_card.dart';
import '../widgets/tahawwulat_flagship_card.dart';
import '../models/sub_agent_model.dart';
import '../widgets/library_bottom_sheet.dart';
import 'main_shell_screen.dart';
import '../widgets/editorial.dart';

class SpecialistListScreen extends StatefulWidget {
  final FieldModel? field; // Nullable if opened as general Specialist tab
  final CorpusKind initialKind;

  const SpecialistListScreen({super.key, this.field, this.initialKind = CorpusKind.discipline});

  @override
  State<SpecialistListScreen> createState() => _SpecialistListScreenState();
}

class _SpecialistListScreenState extends State<SpecialistListScreen> {
  final AgentService _agentService = AgentService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  StreamSubscription<UserModel?>? _userChanges;
  String? _loadError;
  String? _accessError;
  bool _openingAgent = false;

  List<AgentModel> _allAgents = [];
  String? _selectedFieldId;
  String _searchQuery = '';
  bool _isLoading = true;
  CorpusKind _corpusKind = CorpusKind.discipline;

  @override
  void initState() {
    super.initState();
    _selectedFieldId = widget.field?.id;
    _corpusKind = widget.initialKind;
    _loadAgents();
    _userChanges = _authService.userStream.listen((_) {
      if (mounted) setState(() => _accessError = null);
    }, onError: (Object error, StackTrace stack) {
      if (mounted) setState(() => _accessError = 'membership.access_update_failed');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _userChanges?.cancel();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    setState(() { _isLoading = true; _loadError = null; });
    try {
      final agents = await _agentService.getAgents();
      if (mounted) {
        setState(() {
          _allAgents = agents;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'membership.directory_load_failed';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _searchQuery = val.trim();
        });
      }
    });
  }

  List<AgentModel> _computeFilteredAgents() {
    return _allAgents.where((agent) {
      // 1. Filter by CorpusKind
      if (agent.kind != _corpusKind) return false;

      // 2. Filter by discipline field if in discipline mode
      if (_corpusKind == CorpusKind.discipline) {
        final matchesField = _selectedFieldId == null ||
            _selectedFieldId == 'all' ||
            agent.fieldId == _selectedFieldId;
        if (!matchesField) return false;
      }

      // 3. Filter by search query
      if (_searchQuery.isEmpty) return true;

      return ArabicUtils.matches(context.tr(agent.title), _searchQuery) ||
          ArabicUtils.matches(context.tr(agent.subtitleAcademic), _searchQuery) ||
          ArabicUtils.matches(context.tr(agent.description), _searchQuery) ||
          ArabicUtils.matches(agent.title, _searchQuery) ||
          ArabicUtils.matches(agent.titleArabic, _searchQuery) ||
          ArabicUtils.matches(agent.subtitleAcademic, _searchQuery) ||
          ArabicUtils.matches(agent.description, _searchQuery);
    }).toList();
  }

  void _openAgent(AgentModel agent) {
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        context.tr('membership.preparing', args: {'title': context.tr(agent.title)}),
      );
      return;
    }

    final user = _authService.cachedCurrentUser;
    if (user == null || !user.hasAccessToAgent(agent.id)) {
      _openSubscriptionForAgent(agent, user: user);
      return;
    }

    unawaited(_launchAgent(agent, user));
  }

  void _openTahawwulatSubAgent(AgentModel parentAgent, SubAgentModel subAgent) {
    final user = _authService.cachedCurrentUser;
    if (user == null || !user.hasAccessToAgent(parentAgent.id)) {
      _openSubscriptionForAgent(parentAgent, user: user);
      return;
    }

    final personaAgent = AgentModel(
      id: subAgent.id,
      title: context.tr('membership.persona_title', args: {'name': context.tr(subAgent.name)}),
      titleArabic: subAgent.nameArabic,
      description: subAgent.description,
      emoji: subAgent.emoji,
      category: parentAgent.category,
      status: 'active',
      sortOrder: parentAgent.sortOrder,
      fieldId: parentAgent.fieldId,
      subtitleAcademic: subAgent.description,
      suggestedPrompts: parentAgent.suggestedPrompts,
      referenceBooks: parentAgent.referenceBooks,
      catalogId: parentAgent.catalogId,
      kind: parentAgent.kind,
      disciplineIds: parentAgent.disciplineIds,
      scholarIds: parentAgent.scholarIds,
    );

    unawaited(_launchAgent(personaAgent, user));
  }

  Future<void> _launchAgent(AgentModel agent, UserModel user) async {
    if (_openingAgent) return;
    _openingAgent = true;
    try {
      await AgentSessionManager.instance.openAgent(agent, user: user);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('membership.study_open_failed'));
    } finally { _openingAgent = false; }
  }

  Future<void> _refreshAccess() async {
    try {
      await _authService.getFreshCurrentUserModel();
      if (mounted) setState(() => _accessError = null);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.tr('membership.access_retry'));
    }
  }

  void _openSubscriptionForAgent(AgentModel agent, {UserModel? user}) {
    final targetUser = user ?? _authService.cachedCurrentUser;
    NavigationGuard.safePushNamed(
      context,
      AppRoutes.subscription,
      arguments: {'agent': agent, 'user': targetUser},
    );
  }

  @override
  Widget build(BuildContext context) {
    final general = widget.field == null;
    final shell = MainShellController.of(context);
    final filtered = _computeFilteredAgents()
      ..sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    return PopScope(
      canPop: general || shell == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !general) shell?.switchTab(0);
      },
      child: EditorialPage(
        eyebrow: context.tr('membership.directory'),
        title: general ? context.tr('membership.assistants') : context.tr(widget.field!.name),
        subtitle: context.tr('membership.choose_companion'),
        trailing: general ? null : IconButton(
          tooltip: context.tr('membership.home'),
          onPressed: () {
            if (shell != null) { shell.switchTab(0); }
            else { Navigator.maybePop(context); }
          }, icon: const BackButtonIcon()),
        children: [
          if (_accessError != null) ...[
            Text(context.tr(_accessError!)),
            const SizedBox(height: 12),
            EditorialButton(label: context.tr('membership.check_access'), secondary: true, onPressed: _refreshAccess),
            const SizedBox(height: 20),
          ],
          EditorialSearchField(controller: _searchCtrl,
            onChanged: _onSearchChanged, hintText: context.tr('membership.search_hint')),
          const SizedBox(height: 20),
          if (general) ...[
            CorpusKindControl(value: _corpusKind, onChanged: (kind) {
              setState(() { _corpusKind = kind; _selectedFieldId = null; });
            }),
            const SizedBox(height: 20),
          ],
          if (general && _corpusKind == CorpusKind.discipline)
            Padding(padding: const EdgeInsets.only(bottom: 24),
              child: DropdownButtonFormField<String>(
                key: ValueKey(_selectedFieldId ?? 'all'),
                initialValue: _selectedFieldId ?? 'all',
                isExpanded: true,
                decoration: InputDecoration(labelText: context.tr('membership.discipline')),
                items: [
                  DropdownMenuItem(value: 'all', child: Text(context.tr('membership.all_disciplines'))),
                  for (final field in FieldModel.defaultFields)
                    DropdownMenuItem(value: field.id, child: Text(context.tr(field.name))),
                ],
                onChanged: (value) => setState(() => _selectedFieldId = value),
              )),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
          else if (_loadError != null)
            EditorialEmptyState(title: context.tr('membership.directory_unavailable'), description: _loadError == null ? null : context.tr(_loadError!),
              action: EditorialButton(label: context.tr('membership.retry'), onPressed: _loadAgents))
          else if (filtered.isEmpty)
            EditorialEmptyState(title: context.tr('membership.no_assistants'),
              description: context.tr('membership.try_search'),
              action: EditorialButton(label: context.tr('membership.reset_search'), secondary: true, onPressed: () {
                _debounce?.cancel();
                _searchCtrl.clear();
                setState(() { _searchQuery = ''; _selectedFieldId = null; });
              }))
          else ...[
            for (final agent in filtered)
              if (agent.id == 'fiqh_tahawwulat')
                Padding(padding: const EdgeInsets.only(bottom: 24),
                  child: TahawwulatFlagshipCard(
                    agent: agent,
                    isSubscribed: _authService.cachedCurrentUser?.hasAccessToAgent(agent.id) ?? false,
                    onOpenMain: () => _openAgent(agent),
                    onOpenSubAgent: (role) => _openTahawwulatSubAgent(agent, role),
                    onOpenLibrary: agent.catalogId == null ? null : () => showResearchLibrary(context, agent: agent),
                  ))
              else SpecialistCard(
                title: context.tr(agent.title),
                titleArabic: agent.titleArabic,
                scopeLabel: context.tr(agent.description),
                statusLabel: agent.isComingSoon ? context.tr('membership.unavailable') : context.tr(agent.subtitleAcademic),
                onOpen: () => _openAgent(agent),
                onOpenLibrary: agent.catalogId == null ? null : () => showResearchLibrary(context, agent: agent),
              ),
          ],
        ],
      ),
    );
  }
}
