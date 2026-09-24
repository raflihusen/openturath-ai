import '../core/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/scholarly_fonts.dart';

import '../core/app_copy.dart';
import '../core/arabic_utils.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
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
import '../widgets/assistant_dossier_card.dart';
import '../widgets/scholars_coming_soon.dart';
import '../widgets/tahawwulat_flagship_card.dart';
import '../models/sub_agent_model.dart';
import '../widgets/library_bottom_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';
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
  String? _selectedAgentId = 'fiqh_syafii';

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

  void _selectAgent(AgentModel agent) {
    setState(() => _selectedAgentId = agent.id);
    OTMotion.light();
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
          child: Column(
            children: [
              // Search & Controls Container
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
                child: Column(
                  children: [
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: border, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded,
                              size: 20, color: textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: _onSearchChanged,
                              style: ScholarlyFonts.outfit(
                                  fontSize: 13.5, color: textPrimary),
                              decoration: InputDecoration(
                                hintText: Loc.tr('assistantSearch'),
                                hintStyle: ScholarlyFonts.outfit(
                                    fontSize: 13.5, color: textSecondary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: textSecondary),
                            ),
                        ],
                      ),
                    ),
                    if (isGeneralTab) ...[
                      const SizedBox(height: OTSpacing.md),
                      // Dual Taxonomy Switcher
                      CorpusKindControl(
                        value: _corpusKind,
                        onChanged: (k) {
                          setState(() {
                            _corpusKind = k;
                            _selectedFieldId = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // Discipline Filter Chips (only in discipline mode)
              if (isGeneralTab && _corpusKind == CorpusKind.discipline) ...[
                SizedBox(
                  height: Loc.isArabic ? 60 : 48,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
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
                      const SizedBox(width: 8),
                      ...FieldModel.defaultFields.map((field) {
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
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

              // Content List
              Expanded(
                child: _corpusKind == CorpusKind.scholar
                    ? const ScholarsComingSoon()
                    : _isLoading
                    ? const Center(child: CircularProgressIndicator())
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
                                    _searchQuery.isNotEmpty
                                        ? AppCopy.noAssistantsFound
                                        : AppCopy.noAssistantsFound,
                                    style:
                                        OTTypography.body(color: textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Builder(
                            builder: (context) {
                              final sorted = List<AgentModel>.from(filtered);
                              if (_searchQuery.isEmpty) {
                                sorted.sort((a, b) {
                                  if (a.id == 'fiqh_tahawwulat') return -1;
                                  if (b.id == 'fiqh_tahawwulat') return 1;
                                  if (a.isActive && !b.isActive) return -1;
                                  if (!a.isActive && b.isActive) return 1;
                                  return 0;
                                });
                              }

                              final selected = sorted.where(
                                (agent) => agent.id == _selectedAgentId,
                              ).firstOrNull ?? sorted.first;
                              final others = sorted.where(
                                (agent) => agent.id != selected.id,
                              ).toList();
                              final flagship = _allAgents.where(
                                (agent) => agent.id == 'fiqh_tahawwulat',
                              ).firstOrNull;

                              return ListView(
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                padding: const EdgeInsets.fromLTRB(
                                    OTSpacing.lg, OTSpacing.xs, OTSpacing.lg, 28),
                                children: [
                                  if (isGeneralTab && _searchQuery.isEmpty) ...[
                                    Text(
                                      Loc.tr('assistantIntro'),
                                      style: ScholarlyFonts.outfit(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                  ],
                                  if (flagship != null && isGeneralTab &&
                                      _searchQuery.isEmpty &&
                                      (_selectedFieldId == null ||
                                          _selectedFieldId == 'all' ||
                                          _selectedFieldId == flagship.fieldId)) ...[
                                    Material(
                                      color: OTColors.primaryContainer(isDark),
                                      borderRadius: BorderRadius.circular(28),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(28),
                                        onTap: () => _selectAgent(flagship),
                                        child: Padding(
                                          padding: const EdgeInsets.all(21),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Loc.tr('assistantFeatured'),
                                                style: ScholarlyFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: OTColors.onPrimaryContainer(isDark),
                                                ),
                                              ),
                                              const SizedBox(height: 11),
                                              Text(
                                                flagship.title,
                                                style: ScholarlyFonts.newsreader(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w600,
                                                  color: OTColors.onPrimaryContainer(isDark),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                Loc.tr('assistantFeaturedDesc'),
                                                style: ScholarlyFonts.outfit(
                                                  fontSize: 13,
                                                  height: 1.5,
                                                  color: OTColors.onPrimaryContainer(isDark),
                                                ),
                                              ),
                                              const SizedBox(height: 11),
                                              Text(
                                                Loc.tr('assistantFeaturedAction'),
                                                style: ScholarlyFonts.outfit(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: OTColors.onPrimaryContainer(isDark),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                  ],
                                  _sectionLabel(
                                    Loc.tr('assistantSelected'),
                                    Loc.tr('assistantSelectedHint'),
                                    textPrimary,
                                    textSecondary,
                                  ),
                                  const SizedBox(height: 10),
                                  if (selected.id == 'fiqh_tahawwulat')
                                    TahawwulatFlagshipCard(
                                      agent: selected,
                                      isSubscribed: _authService.cachedCurrentUser
                                              ?.hasAccessToAgent(selected.id) ?? false,
                                      onOpenMain: () => _openAgent(selected),
                                      onOpenSubAgent: (sub) =>
                                          _openTahawwulatSubAgent(selected, sub),
                                      onOpenLibrary: selected.catalogId != null
                                          ? () => showResearchLibrary(context,
                                              agent: selected)
                                          : null,
                                    )
                                  else
                                    AssistantDossierCard(
                                      agent: selected,
                                      position: sorted.indexOf(selected) + 1,
                                      total: sorted.length,
                                      onOpen: () => _openAgent(selected),
                                      onOpenLibrary: selected.catalogId != null
                                          ? () => showResearchLibrary(context,
                                              agent: selected)
                                          : null,
                                    ),
                                  if (others.isNotEmpty) ...[
                                    const SizedBox(height: 26),
                                    _sectionLabel(Loc.tr('assistantMore'), '',
                                        textPrimary, textSecondary),
                                    const SizedBox(height: 10),
                                    ...others.map((agent) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: SpecialistCard(
                                        title: agent.title,
                                        titleArabic: agent.titleArabic,
                                        fieldId: agent.fieldId,
                                        emoji: agent.emoji,
                                        scopeLabel: agent.subtitleAcademic,
                                        statusLabel: agent.isComingSoon
                                            ? AppCopy.comingSoon : null,
                                        onOpen: () => _selectAgent(agent),
                                        onOpenLibrary: agent.catalogId != null
                                            ? () => showResearchLibrary(context,
                                                agent: agent)
                                            : null,
                                      ),
                                    )),
                                  ],
                                ],
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

  Widget _sectionLabel(String title, String hint, Color ink, Color muted) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: ScholarlyFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w600, color: ink,
          )),
        ),
        if (hint.isNotEmpty)
          Text(hint, style: ScholarlyFonts.outfit(
            fontSize: 11, color: muted,
          )),
      ],
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
    final activeBg = OTColors.primaryContainer(isDark);
    final activeFg = OTColors.onPrimaryContainer(isDark);

    return AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.94,
      hapticType: HapticFeedbackType.selection,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : surface,
        borderRadius: BorderRadius.circular(16),
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
