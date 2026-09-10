import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/arabic_utils.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
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
  bool _showSearch = false;

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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = val.trim();
        });
      }
    });
  }

  List<AgentModel> _computeFilteredAgents() {
    return _allAgents.where((agent) {
      final matchesField = _selectedFieldId == null ||
          _selectedFieldId == 'all' ||
          agent.fieldId == _selectedFieldId;

      if (!matchesField) return false;
      if (_searchQuery.isEmpty) return true;

      return ArabicUtils.matches(agent.title, _searchQuery) ||
          ArabicUtils.matches(agent.titleArabic, _searchQuery) ||
          ArabicUtils.matches(agent.subtitleAcademic, _searchQuery) ||
          ArabicUtils.matches(agent.description, _searchQuery);
    }).toList();
  }

  Future<void> _openAgent(AgentModel agent) async {
    HapticFeedback.mediumImpact();
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

  Future<void> _openSubscriptionForAgent(AgentModel agent) async {
    final user = await _authService.getCurrentUserModel();
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.subscription,
      arguments: {
        'user': user,
        'agent': agent,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? AppTheme.groupedCanvasDark : AppTheme.groupedCanvasLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    final currentField = widget.field ??
        (_selectedFieldId != null && _selectedFieldId != 'all'
            ? FieldModel.getById(_selectedFieldId!)
            : null);

    final filteredAgents = _computeFilteredAgents();
    final title = currentField?.name ?? 'Keilmuan';
    final subtitle = currentField != null
        ? '${filteredAgents.length} rujukan korpus'
        : 'Direktori korpus dan tradisi naskah primer';

    final isRootTab = widget.field == null;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        leading: isRootTab
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    final shell = MainShellController.of(context);
                    shell?.switchTab(0);
                  }
                },
              ),
        title: Column(
          crossAxisAlignment:
              isRootTab ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: textPrimary,
            ),
            tooltip: _showSearch ? 'Tutup Pencarian' : 'Cari Keilmuan',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: !isRootTab,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Field (collapsible) ──
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    autofocus: true,
                    style: GoogleFonts.outfit(fontSize: 14, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari spesialis, kitab, atau bab...',
                      hintStyle: GoogleFonts.outfit(fontSize: 13, color: textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, size: 18, color: textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ),

            // ── Discipline Category Filter Tabs (If in general specialist mode) ──
            if (isRootTab)
              Container(
                height: 38,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: FieldModel.defaultFields.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final field = isAll ? null : FieldModel.defaultFields[index - 1];
                    final isSelected = isAll
                        ? (_selectedFieldId == null || _selectedFieldId == 'all')
                        : _selectedFieldId == field?.id;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedFieldId = isAll ? 'all' : field?.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7)),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        ),
                        child: Center(
                          child: Text(
                            isAll ? 'Semua' : field!.name,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                  : textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 4),

            // ── Continuous Scholarly List Separated by Hairlines ──
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: accent,
                      ),
                    )
                  : filteredAgents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 44,
                                color: textSecondary.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada rujukan yang sesuai.',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 108),
                          itemCount: filteredAgents.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            thickness: 0.6,
                            color: border.withValues(alpha: 0.5),
                          ),
                          itemBuilder: (context, index) {
                            final agent = filteredAgents[index];
                            if (agent.id == 'fiqh_tahawwulat') {
                              return _DignifiedTahawwulatRow(
                                agent: agent,
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                accent: accent,
                                onTap: () => _openAgent(agent),
                              );
                            }
                            return _UnboxedSpecialistRow(
                              agent: agent,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              accent: accent,
                              onTap: () => _openAgent(agent),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnboxedSpecialistRow extends StatelessWidget {
  final AgentModel agent;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onTap;

  const _UnboxedSpecialistRow({
    required this.agent,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComingSoon = agent.isComingSoon;
    final booksList = agent.referenceBooks;
    final referenceText = (booksList != null && booksList.isNotEmpty)
        ? booksList.map((b) => b.title).take(2).join(' · ')
        : agent.subtitleAcademic.isNotEmpty
            ? agent.subtitleAcademic
            : agent.description;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    agent.title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (referenceText.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      referenceText,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            if (isComingSoon)
              Text(
                'Kurasi Naskah',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textSecondary.withValues(alpha: 0.65),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: textSecondary.withValues(alpha: 0.7),
              ),
          ],
        ),
      ),
    );
  }
}

class _DignifiedTahawwulatRow extends StatelessWidget {
  final AgentModel agent;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onTap;

  const _DignifiedTahawwulatRow({
    required this.agent,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Korpus Khusus',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agent.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'فقه التحولات',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textSecondary.withValues(alpha: 0.6),
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '1.500+ muhadharah · naskah lengkap · takhrij sanad al-habib abu bakar al-masyhur',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Masuk ke Ruang Riset',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
