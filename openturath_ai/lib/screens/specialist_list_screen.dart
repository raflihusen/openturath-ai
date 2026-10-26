import '../core/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/telemetry_service.dart';
import '../core/scholarly_fonts.dart';

import '../core/app_copy.dart';
import '../core/app_config.dart';
import '../core/arabic_utils.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_motion.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/feature_flags.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../core/navigation_guard.dart';
import '../widgets/corpus_kind_control.dart';
import '../widgets/scholars_coming_soon.dart';
import '../widgets/tahawwulat_flagship_card.dart';
import '../models/sub_agent_model.dart';
import '../widgets/library_bottom_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';
import 'main_shell_screen.dart';
import '../widgets/ot_motion_widgets.dart';
import '../widgets/assistant_grid_card.dart';
import '../widgets/tahqiq_khazanah_dialog.dart';
import '../services/open_turath_catalog_repository.dart';

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
  final ScrollController _listScrollCtrl = ScrollController();
  Timer? _debounce;

  List<AgentModel> _allAgents = [];
  String? _selectedFieldId;
  String _searchQuery = '';
  bool _isLoading = true;
  CorpusKind _corpusKind = CorpusKind.discipline;
  Map<String, AiLibraryMetadata> _libraryStats = const {};

  @override
  void initState() {
    super.initState();
    _selectedFieldId = widget.field?.id;
    _loadAgents();
    OpenTurathCatalogRepository.instance.loadAllMetadata().then((all) {
      if (mounted) setState(() => _libraryStats = all);
    }).catchError((Object error, StackTrace stack) {
      TelemetryService.instance
          .reportError(error, stack, context: 'library_metadata');
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _listScrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    // Saklar fitur disegarkan bersama daftar agen; kegagalannya tidak menahan layar.
    unawaited(FeatureFlagsService.sync());
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
    if (!AppConfig.isGuruEdition && agent.isComingSoon) {
      TahqiqKhazanahDialog.show(context, agent: agent);
      return;
    }

    final user = _authService.cachedCurrentUser;
    if (!AppConfig.isGuruEdition &&
        (user == null || !user.hasAccessToAgent(agent.id))) {
      _openSubscriptionForAgent(agent, user: user);
      return;
    }

    AgentSessionManager.instance.openAgent(agent, user: user);
  }

  void _openTahawwulatSubAgent(AgentModel parentAgent, SubAgentModel subAgent) {
    OTMotion.light();
    // Sub-AI yang ditandai "segera hadir" dari jauh tidak dibuka siapa pun,
    // termasuk pelanggan dan Edisi Guru; aplikasi hanya menjelaskannya.
    if (gateSubAgent(subAgent.id, FeatureFlagsService.current) ==
        SubAgentGate.comingSoon) {
      TahqiqKhazanahDialog.show(context,
          agent: parentAgent.copyWith(
              title: 'Fikih Tahawwulat: ${subAgent.name}',
              titleArabic:
                  '${parentAgent.titleArabic}: ${subAgent.nameArabic}'));
      return;
    }
    final user = _authService.cachedCurrentUser;
    if (!AppConfig.isGuruEdition &&
        (user == null || !user.hasAccessToAgent(parentAgent.id))) {
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
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                children: [
                  // Search & Controls Container
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
                    child: Column(
                      children: [
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: OTRadius.inputBorder,
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
                                      fontSize: OTFontSize.s14,
                                      color: textPrimary),
                                  decoration: InputDecoration(
                                    hintText: Loc.tr('assistantSearch'),
                                    hintStyle: ScholarlyFonts.outfit(
                                        fontSize: OTFontSize.s14,
                                        color: textSecondary),
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
                      height: Loc.isArabic ? 52 : 40,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.lg),
                        children: [
                          _filterChip(
                            label: AppCopy.allCategories,
                            isSelected: _selectedFieldId == null ||
                                _selectedFieldId == 'all',
                            onTap: () =>
                                setState(() => _selectedFieldId = 'all'),
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
                            ? const OTSkeletonList()
                            : filtered.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(OTSpacing.xl),
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
                                            style: OTTypography.body(
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
                                      if (_searchQuery.isEmpty) {
                                        sorted.sort((a, b) {
                                          if (a.id == 'fiqh_tahawwulat') {
                                            return -1;
                                          }
                                          if (b.id == 'fiqh_tahawwulat') {
                                            return 1;
                                          }
                                          if (a.isActive && !b.isActive) {
                                            return -1;
                                          }
                                          if (!a.isActive && b.isActive) {
                                            return 1;
                                          }
                                          return 0;
                                        });
                                      }

                                      final flagship = sorted
                                          .where((agent) =>
                                              agent.id == 'fiqh_tahawwulat')
                                          .firstOrNull;
                                      final others = sorted
                                          .where((agent) =>
                                              agent.id != flagship?.id)
                                          .toList();
                                      AiLibraryMetadata? statsOf(
                                              AgentModel agent) =>
                                          OpenTurathCatalogRepository
                                              .exactMetadata(
                                                  _libraryStats, agent.id);

                                      return ListView(
                                        controller: _listScrollCtrl,
                                        physics: const BouncingScrollPhysics(
                                            parent:
                                                AlwaysScrollableScrollPhysics()),
                                        padding: const EdgeInsets.fromLTRB(
                                            OTSpacing.lg,
                                            OTSpacing.md,
                                            OTSpacing.lg,
                                            24),
                                        children: [
                                          if (flagship != null) ...[
                                            OTReveal(
                                              child: TahawwulatFlagshipCard(
                                                agent: flagship,
                                                metadata: statsOf(flagship),
                                                isSubscribed: _authService
                                                        .cachedCurrentUser
                                                        ?.hasAccessToAgent(
                                                            flagship.id) ??
                                                    false,
                                                onOpenMain: () =>
                                                    _openAgent(flagship),
                                                onOpenSubAgent: (sub) =>
                                                    _openTahawwulatSubAgent(
                                                        flagship, sub),
                                                onOpenLibrary: (!flagship
                                                            .isComingSoon &&
                                                        flagship.catalogId !=
                                                            null)
                                                    ? () => showResearchLibrary(
                                                        context,
                                                        agent: flagship)
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: OTSpacing.md),
                                          ],
                                          if (_selectedFieldId == null ||
                                              _selectedFieldId == 'all' ||
                                              _selectedFieldId == 'hadith') ...[
                                            OTReveal(
                                              child: OTBentoTile(
                                                padding: const EdgeInsets.all(
                                                    OTSpacing.lg),
                                                onTap: () => NavigationGuard
                                                    .safePushNamed(
                                                  context,
                                                  AppRoutes
                                                      .hadithTakhrijWorkspace,
                                                ),
                                                semanticLabel:
                                                    'Meja Telaah Hadis & Takhrij Ribuan Kitab',
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'TAKHRIJ UNIVERSAL · 27 KAIDAH HARF',
                                                            style: OTTypography
                                                                .sectionHeading(
                                                              color:
                                                                  textSecondary,
                                                            ),
                                                          ),
                                                          OTSpacing.gapXs,
                                                          Text(
                                                            'Meja Telaah Hadis & Tasyjīr Sanad (Ribuan Kitab)',
                                                            style: OTTypography
                                                                .cardTitle(
                                                              color:
                                                                  textPrimary,
                                                            ),
                                                          ),
                                                          OTSpacing.gapXs,
                                                          Text(
                                                            'Muqāranat al-Mutūn (27 Kaidah), Al-Matn al-Mujamma‘, Diagram Pohon Sanad, Disambiguasi Rijal, & Takhrij Makalah.',
                                                            style: OTTypography
                                                                .caption(
                                                              color:
                                                                  textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .account_tree_outlined,
                                                      size: 22,
                                                      color: textPrimary,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                height: OTSpacing.md),
                                          ],
                                          // Grid seragam: satu ketukan langsung membuka asisten.
                                          LayoutBuilder(
                                              builder: (context, box) {
                                            final columns = box.maxWidth >= 900
                                                ? 3
                                                : box.maxWidth >= 560
                                                    ? 2
                                                    : 1;
                                            Widget card(int index) {
                                              final agent = others[index];
                                              return OTReveal(
                                                index: index % 6 + 1,
                                                child: AssistantGridCard(
                                                  agent: agent,
                                                  metadata: statsOf(agent),
                                                  onOpen: () =>
                                                      _openAgent(agent),
                                                  onOpenLibrary: (!agent
                                                              .isComingSoon &&
                                                          agent.catalogId !=
                                                              null)
                                                      ? () =>
                                                          showResearchLibrary(
                                                              context,
                                                              agent: agent)
                                                      : null,
                                                ),
                                              );
                                            }

                                            return Column(
                                              children: [
                                                for (var start = 0;
                                                    start < others.length;
                                                    start += columns) ...[
                                                  if (start > 0)
                                                    const SizedBox(
                                                        height: OTSpacing.md),
                                                  if (columns == 1)
                                                    card(start)
                                                  else
                                                    IntrinsicHeight(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          for (var c = 0;
                                                              c < columns;
                                                              c++) ...[
                                                            if (c > 0)
                                                              const SizedBox(
                                                                  width:
                                                                      OTSpacing
                                                                          .md),
                                                            Expanded(
                                                              child: start + c <
                                                                      others
                                                                          .length
                                                                  ? card(
                                                                      start + c)
                                                                  : const SizedBox
                                                                      .shrink(),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ],
                                            );
                                          }),
                                        ],
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
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
    // Horizontal ListView meregangkan anak setinggi daftar; Center menjaga tinggi alami chip.
    return Center(
        child: AppleInteractiveWrapper(
      onTap: onTap,
      pressedScale: 0.97,
      hapticType: HapticFeedbackType.selection,
      borderRadius: OTRadius.chipBorder,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? OTColors.accent(isDark) : Colors.transparent,
          borderRadius: OTRadius.chipBorder,
          border: Border.all(
            color: isSelected ? OTColors.accent(isDark) : border,
            width: 1,
          ),
        ),
        child: Text(
          Loc.text(label),
          style: OTTypography.caption(
                  color: isSelected ? OTColors.onAccent(isDark) : textSecondary)
              .copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: OTFontSize.s14,
          ),
        ),
      ),
    ));
  }
}
