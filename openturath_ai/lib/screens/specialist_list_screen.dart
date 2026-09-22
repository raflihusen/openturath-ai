import '../core/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../core/app_copy.dart';
import '../core/arabic_utils.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_layout.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_motion.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../core/navigation_guard.dart';
import '../widgets/corpus_kind_control.dart';
import '../widgets/specialist_card.dart';
import '../widgets/scholars_coming_soon.dart';
import '../widgets/tahawwulat_flagship_card.dart';
import '../models/sub_agent_model.dart';
import '../widgets/library_bottom_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';
import '../widgets/app_loader.dart';
import '../widgets/ot_mobile_primitives.dart';
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
  Widget build(BuildContext context) {
    Loc.watch(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final isGeneralTab = widget.field == null;
    final title = isGeneralTab ? AppCopy.navStudies : widget.field!.name;
    final filtered = _computeFilteredAgents();
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
            style: OTTypography.corpusTitle(color: textPrimary)
                .copyWith(fontSize: 20),
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
          child: OTConstrainedContent(
            maxWidth: OTLayout.catalogueWidth,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: OTSpacing.sm),
                  child: Column(
                    children: [
                      OTSearchField(
                        controller: _searchCtrl,
                        hintText: 'Cari asisten atau bidang kajian',
                        onChanged: _onSearchChanged,
                      ),
                      if (isGeneralTab) ...[
                        const SizedBox(height: OTSpacing.md),
                        CorpusKindControl(
                          value: _corpusKind,
                          onChanged: (kind) {
                            setState(() {
                              _corpusKind = kind;
                              _selectedFieldId = null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                if (isGeneralTab && _corpusKind == CorpusKind.discipline) ...[
                  SizedBox(
                    height: Loc.isArabic ? 60 : 48,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterChip(
                          label: AppCopy.allCategories,
                          isSelected: _selectedFieldId == null ||
                              _selectedFieldId == 'all',
                          onTap: () => setState(() => _selectedFieldId = 'all'),
                          isDark: isDark,
                          border: border,
                          surface: surface,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(width: OTSpacing.sm),
                        ...FieldModel.defaultFields.map((field) {
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(
                              end: OTSpacing.sm,
                            ),
                            child: _filterChip(
                              label: field.name,
                              isSelected: _selectedFieldId == field.id,
                              onTap: () =>
                                  setState(() => _selectedFieldId = field.id),
                              isDark: isDark,
                              border: border,
                              surface: surface,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: OTSpacing.sm),
                ],
                Expanded(
                  child: _corpusKind == CorpusKind.scholar
                      ? const ScholarsComingSoon()
                      : _isLoading
                          ? const Center(
                              child: AppLoader(title: 'Menyiapkan asisten…'),
                            )
                          : filtered.isEmpty
                              ? const OTEmptyState(
                                  icon: Icons.search_off_rounded,
                                  title: 'Asisten tidak ditemukan',
                                  message:
                                      'Coba kata kunci lain atau pilih bidang kajian yang berbeda.',
                                )
                              : _AssistantDirectory(
                                  agents: filtered,
                                  searchIsEmpty: _searchQuery.isEmpty,
                                  currentUser: _authService.cachedCurrentUser,
                                  onOpenAgent: _openAgent,
                                  onOpenSubAgent: _openTahawwulatSubAgent,
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color border,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final activeBg = textPrimary;
    final activeFg = isDark ? Colors.black : Colors.white;

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.94,
      hapticType: HapticFeedbackType.selection,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeBg : border,
            width: 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          Loc.text(label),
          style:
              OTTypography.caption(color: isSelected ? activeFg : textSecondary)
                  .copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _AssistantDirectory extends StatelessWidget {
  const _AssistantDirectory({
    required this.agents,
    required this.searchIsEmpty,
    required this.currentUser,
    required this.onOpenAgent,
    required this.onOpenSubAgent,
  });

  final List<AgentModel> agents;
  final bool searchIsEmpty;
  final UserModel? currentUser;
  final ValueChanged<AgentModel> onOpenAgent;
  final void Function(AgentModel agent, SubAgentModel subAgent) onOpenSubAgent;

  @override
  Widget build(BuildContext context) {
    final sorted = List<AgentModel>.from(agents);
    if (searchIsEmpty) {
      sorted.sort((a, b) {
        if (a.id == 'fiqh_tahawwulat') return -1;
        if (b.id == 'fiqh_tahawwulat') return 1;
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(top: OTSpacing.xs, bottom: 96),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: OTSpacing.md),
      itemBuilder: (context, index) {
        final agent = sorted[index];
        final openLibrary = agent.catalogId == null
            ? null
            : () => showResearchLibrary(context, agent: agent);

        if (agent.id == 'fiqh_tahawwulat') {
          return TahawwulatFlagshipCard(
            agent: agent,
            isSubscribed: currentUser?.hasAccessToAgent(agent.id) ?? false,
            onOpenMain: () => onOpenAgent(agent),
            onOpenSubAgent: (subAgent) => onOpenSubAgent(agent, subAgent),
            onOpenLibrary: openLibrary,
          );
        }

        return SpecialistCard(
          title: agent.title,
          titleArabic: agent.titleArabic,
          emoji: agent.emoji,
          scopeLabel: agent.subtitleAcademic,
          referenceLabel: agent.referenceBooks
              ?.take(2)
              .map((book) => book.titleArabic)
              .where((title) => title.isNotEmpty)
              .join(' · '),
          statusLabel: agent.isComingSoon ? AppCopy.comingSoon : null,
          onOpen: () => onOpenAgent(agent),
          onOpenLibrary: openLibrary,
        );
      },
    );
  }
}
