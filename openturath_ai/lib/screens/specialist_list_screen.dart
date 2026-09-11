import 'dart:async';
import 'package:flutter/material.dart';

import '../core/arabic_utils.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_motion.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../widgets/corpus_kind_control.dart';
import '../widgets/specialist_card.dart';
import '../widgets/library_bottom_sheet.dart';

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

  Future<void> _openAgent(AgentModel agent) async {
    OTMotion.light();
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        '${agent.title} belum tersedia (Segera Hadir). Modul ini sedang dalam tahap kurasi naskah kitab primer.',
      );
      return;
    }

    final user = await _authService.getCurrentUserModel();
    if (!mounted) return;

    if (user != null && !user.hasAccessToAgent(agent.id)) {
      _openSubscriptionForAgent(agent);
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.agentWebview,
      arguments: {'agent': agent, 'user': user},
    );
  }

  void _openSubscriptionForAgent(AgentModel agent) {
    _authService.getCurrentUserModel().then((user) {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.subscription,
        arguments: {'agent': agent, 'user': user},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    final isGeneralTab = widget.field == null;
    final title = isGeneralTab ? 'Keilmuan' : widget.field!.name;
    final filtered = _computeFilteredAgents();

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        title: Text(
          title,
          style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 20),
        ),
        centerTitle: false,
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: isGeneralTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Search & Controls Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    style: OTTypography.body(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari bidang atau ulama',
                      hintStyle: OTTypography.body(color: textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, size: 18, color: textSecondary),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: OTRadius.inputBorder,
                        borderSide: BorderSide(color: border, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: OTRadius.inputBorder,
                        borderSide: BorderSide(color: border, width: 0.8),
                      ),
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
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
                  children: [
                    _filterChip(
                      label: 'Semua Bidang',
                      isSelected: _selectedFieldId == null || _selectedFieldId == 'all',
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
                        padding: const EdgeInsets.only(right: 8),
                        child: _filterChip(
                          label: field.name,
                          isSelected: _selectedFieldId == field.id,
                          onTap: () => setState(() => _selectedFieldId = field.id),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(OTSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 40, color: textSecondary),
                                const SizedBox(height: OTSpacing.sm),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tidak ada hasil'
                                      : 'Belum ada ruang riset untuk bidang ini',
                                  style: OTTypography.body(color: textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(OTSpacing.lg, OTSpacing.xs, OTSpacing.lg, 96),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final agent = filtered[index];
                            return SpecialistCard(
                              title: agent.title,
                              titleArabic: agent.titleArabic,
                              scopeLabel: agent.subtitleAcademic.isNotEmpty
                                  ? agent.subtitleAcademic
                                  : agent.category,
                              emoji: agent.emoji,
                              statusLabel: agent.isComingSoon ? 'Belum tersedia' : null,
                              onOpen: agent.isActive ? () => _openAgent(agent) : null,
                              onOpenLibrary: agent.catalogId != null
                                  ? () => showResearchLibrary(context, agent: agent)
                                  : null,
                            );
                          },
                        ),
            ),
          ],
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
          label,
          style: OTTypography.caption(color: isSelected ? activeFg : textSecondary).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
