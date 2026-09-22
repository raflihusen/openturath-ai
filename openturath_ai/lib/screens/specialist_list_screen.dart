import '../core/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../core/app_copy.dart';
import '../core/arabic_utils.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../core/design/native_design.dart';
import '../widgets/native_components.dart';
import '../core/design/native_typography.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_motion.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../core/navigation_guard.dart';

import '../widgets/specialist_card.dart';
import '../widgets/scholars_coming_soon.dart';
import '../widgets/tahawwulat_flagship_card.dart';
import '../models/sub_agent_model.dart';
import 'native_library_page.dart';

import 'main_shell_screen.dart';

class SpecialistListScreen extends StatefulWidget {
  final FieldModel? field; // Nullable if opened as general Specialist tab

  const SpecialistListScreen({super.key, this.field});

  @override
  State<SpecialistListScreen> createState() => _SpecialistListScreenState();
}

class _SpecialistListScreenState extends State<SpecialistListScreen> {
  final AgentService _agentService = AgentService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<AgentModel> _allAgents = [];
  String? _selectedFieldId;
  String _searchQuery = '';
  bool _isLoading = true;
  CorpusKind _corpusKind = CorpusKind.discipline;

  @override
  void initState() {
    super.initState();
    _selectedFieldId = widget.field?.id;
    _loadAgents();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAgents() async {
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
          _allAgents = AgentModel.defaultAgents;
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

      return ArabicUtils.matches(agent.title, _searchQuery) ||
          ArabicUtils.matches(agent.titleArabic, _searchQuery) ||
          ArabicUtils.matches(agent.subtitleAcademic, _searchQuery) ||
          ArabicUtils.matches(agent.description, _searchQuery);
    }).toList();
  }

  void _openAgent(AgentModel agent) {
    OTMotion.light();
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        AppCopy.preparingModule(agent.title),
      );
      return;
    }

    final user = _authService.cachedCurrentUser;
    if (user == null || !user.hasAccessToAgent(agent.id)) {
      _openSubscriptionForAgent(agent, user: user);
      return;
    }

    AgentSessionManager.instance.openAgent(agent, user: user);
  }

  void _openTahawwulatSubAgent(AgentModel parentAgent, SubAgentModel subAgent) {
    OTMotion.light();
    final user = _authService.cachedCurrentUser;
    if (user == null || !user.hasAccessToAgent(parentAgent.id)) {
      _openSubscriptionForAgent(parentAgent, user: user);
      return;
    }

    final personaAgent = AgentModel(
      id: subAgent.id,
      title: 'Fikih Tahawwulat: ${subAgent.name}',
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

    AgentSessionManager.instance.openAgent(personaAgent, user: user);
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
  Widget build(BuildContext context) => NativeAssistantPage(
    field: widget.field, filtered: _computeFilteredAgents(), user: _authService.cachedCurrentUser,
    searchController: _searchCtrl, searchQuery: _searchQuery, corpusKind: _corpusKind,
    selectedFieldId: _selectedFieldId, isLoading: _isLoading,
    onSearch: _onSearchChanged, onOpen: _openAgent, onSubAgent: _openTahawwulatSubAgent,
    onKind: (value) => setState(() { _corpusKind = value; _selectedFieldId = null; }),
    onField: (value) => setState(() => _selectedFieldId = value),
  );
}

class NativeAssistantPage extends StatelessWidget {
  const NativeAssistantPage({super.key, this.field, required this.filtered, this.user,
    required this.searchController, required this.searchQuery, required this.corpusKind,
    this.selectedFieldId, this.isLoading = false, required this.onSearch, required this.onOpen,
    required this.onSubAgent, required this.onKind, required this.onField});
  final FieldModel? field;
  final List<AgentModel> filtered;
  final UserModel? user;
  final TextEditingController searchController;
  final String searchQuery;
  final CorpusKind corpusKind;
  final String? selectedFieldId;
  final bool isLoading;
  final ValueChanged<String> onSearch, onField;
  final ValueChanged<AgentModel> onOpen;
  final void Function(AgentModel, SubAgentModel) onSubAgent;
  final ValueChanged<CorpusKind> onKind;
@override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = NativeColors.canvas(isDark);


    final textPrimary = NativeColors.textPrimary(isDark);
    final textSecondary = NativeColors.textSecondary(isDark);

    final isGeneralTab = field == null;
    final title = isGeneralTab ? AppCopy.navStudies : field!.name;

    final shell = MainShellController.of(context);

    return PopScope(
      canPop: isGeneralTab && (shell == null || !Navigator.canPop(context)),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!isGeneralTab) {
          if (shell != null) {
            shell.switchTab(0);
          } else if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: canvas,
        appBar: AppBar(
          title: Text(
            Loc.text(title),
            style: NativeTypography.corpusTitle(color: textPrimary)
                .copyWith(fontSize: 28),
          ),
          centerTitle: false,
          backgroundColor: canvas,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: isGeneralTab
              ? null
              : IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                  onPressed: () {
                    final shell = MainShellController.of(context);
                    if (shell != null) {
                      shell.switchTab(0);
                    } else if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Search & Controls Container
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
                child: Column(
                  children: [
                    NativeSearch(
                        controller: searchController,
                        hint: NativeCopy.text('searchAssistants'),
                        onChanged: onSearch),

                  ],
                ),
              ),

              if (isGeneralTab) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: PopupMenuButton<CorpusKind>(
                    tooltip: NativeCopy.text('disciplines'),
                    initialValue: corpusKind,
                    onSelected: onKind,
                    itemBuilder: (_) => [
                      PopupMenuItem(value: CorpusKind.discipline, child: Text(NativeCopy.text('disciplines'))),
                      PopupMenuItem(value: CorpusKind.scholar, child: Text(NativeCopy.text('scholars'))),
                    ],
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(children: [Expanded(child: Text(NativeCopy.text(corpusKind == CorpusKind.discipline ? 'disciplines' : 'scholars'), style: NativeType.body(isDark, size: 14))), const Icon(Icons.expand_more, size: 18)])),
                  )),
                  if (corpusKind == CorpusKind.discipline) ...[
                    const SizedBox(width: 20),
                    Expanded(child: PopupMenuButton<String>(
                      tooltip: AppCopy.chooseField,
                      initialValue: selectedFieldId ?? 'all',
                      onSelected: onField,
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'all', child: Text(AppCopy.allCategories)),
                        for (final field in FieldModel.defaultFields) PopupMenuItem(value: field.id, child: Text(Loc.text(field.name))),
                      ],
                      child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(children: [
                          Expanded(child: Text(Loc.text(FieldModel.defaultFields.where((f) => f.id == selectedFieldId).firstOrNull?.name ?? AppCopy.allCategories), style: NativeType.body(isDark, size: 14).copyWith(color: NativeColors.accent(isDark)))),
                          Icon(Icons.expand_more, size: 18, color: NativeColors.accent(isDark)),
                        ])),
                    )),
                  ],
                ]),
              ),
              // Content List
              Expanded(
                child: corpusKind == CorpusKind.scholar
                    ? const ScholarsComingSoon()
                    : isLoading
                        ? const Center(child: NativeLoading())
                        : filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(OTSpacing.xl),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 40, color: textSecondary),
                                      const SizedBox(height: OTSpacing.sm),
                                      Text(
                                        searchQuery.isNotEmpty
                                            ? AppCopy.noAssistantsFound
                                            : AppCopy.noAssistantsFound,
                                        style: NativeTypography.body(
                                            color: textSecondary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Builder(
                                builder: (context) {
                                  final sorted =
                                      List<AgentModel>.from(filtered);
                                  if (searchQuery.isEmpty) {
                                    sorted.sort((a, b) {
                                      if (a.id == 'fiqh_tahawwulat') return -1;
                                      if (b.id == 'fiqh_tahawwulat') return 1;
                                      if (a.isActive && !b.isActive) return -1;
                                      if (!a.isActive && b.isActive) return 1;
                                      return 0;
                                    });
                                  }

                                  return ListView.separated(
                                    physics: const BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    padding: const EdgeInsets.fromLTRB(
                                        OTSpacing.lg,
                                        OTSpacing.xs,
                                        OTSpacing.lg,
                                        96),
                                    itemCount: sorted.length,
                                    separatorBuilder: (_, index) {
                                      final touchesFlagship =
                                          sorted[index].id ==
                                                  'fiqh_tahawwulat' ||
                                              sorted[index + 1].id ==
                                                  'fiqh_tahawwulat';
                                      return SizedBox(
                                        height:
                                            touchesFlagship ? OTSpacing.md : 0,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      final agent = sorted[index];
                                      if (agent.id == 'fiqh_tahawwulat') {
                                        
                                        final isSubscribed = user != null &&
                                            user!.hasAccessToAgent(agent.id);
                                        return TahawwulatFlagshipCard(
                                          agent: agent,
                                          isSubscribed: isSubscribed,
                                          onOpenMain: () => onOpen(agent),
                                          onOpenSubAgent: (sub) =>
                                              onSubAgent(
                                                  agent, sub),
                                          onOpenLibrary: agent.catalogId != null
                                              ? () => openNativeLibrary(context,
                                                  agent: agent)
                                              : null,
                                        );
                                      }
                                      return SpecialistCard(
                                        title: agent.title,
                                        titleArabic: agent.titleArabic,
                                        emoji: agent.emoji,
                                        scopeLabel: agent.subtitleAcademic,
                                        referenceLabel: agent.referenceBooks
                                            ?.take(2)
                                            .map((b) => b.titleArabic)
                                            .where((s) => s.isNotEmpty)
                                            .join(' · '),
                                        statusLabel: agent.isComingSoon
                                            ? AppCopy.comingSoon
                                            : null,
                                        onOpen: () => onOpen(agent),
                                        onOpenLibrary: agent.catalogId != null
                                            ? () => openNativeLibrary(context,
                                                agent: agent)
                                            : null,
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
