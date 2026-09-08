import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/arabic_utils.dart';
import '../core/theme.dart';
import '../core/routes.dart';
import '../core/app_snackbar.dart';
import '../models/field_model.dart';
import '../models/agent_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';

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
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
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
    final title = currentField?.name ?? 'Koleksi AI Spesialis';
    final subtitle = currentField != null
        ? '${filteredAgents.length} AI Spesialis Turats'
        : 'Pilih AI spesialis sesuai rujukan kitab primer';

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
                onPressed: () => Navigator.pop(context),
              ),
        title: Column(
          crossAxisAlignment:
              isRootTab ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
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
            tooltip: _showSearch ? 'Tutup Pencarian' : 'Cari Spesialis',
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
                    color: isDark ? const Color(0xFF1E1F20) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.outfit(fontSize: 13.5, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari spesialis, matan, atau syarah...',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiaryLight,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiaryLight,
                      ),
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
                height: 42,
                margin: const EdgeInsets.symmetric(vertical: 6),
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
                        setState(() {
                          _selectedFieldId = isAll ? 'all' : field?.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppTheme.surfaceElevated : const Color(0xFFE2E8F0))
                              : surface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isSelected ? accent : border,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isAll ? 'Semua Bidang' : field!.name,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? accent : textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // ── Slim Specialist List Rows ──
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
                                size: 48,
                                color: textSecondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada spesialis yang sesuai.',
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
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 108),
                          itemCount: filteredAgents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final agent = filteredAgents[index];
                            return TweenAnimationBuilder<double>(
                              key: ValueKey(agent.id),
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 240 + (index * 35)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 16 * (1 - value)),
                                  child: Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: _SlimSpecialistRow(
                                agent: agent,
                                isDark: isDark,
                                surface: surface,
                                border: border,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                accent: accent,
                                onTap: () => _openAgent(agent),
                                onOrder: () => _openSubscriptionForAgent(agent),
                              ),
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

class _SlimSpecialistRow extends StatefulWidget {
  final AgentModel agent;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onOrder;

  const _SlimSpecialistRow({
    required this.agent,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onTap,
    required this.onOrder,
  });

  @override
  State<_SlimSpecialistRow> createState() => _SlimSpecialistRowState();
}

class _SlimSpecialistRowState extends State<_SlimSpecialistRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isComingSoon = widget.agent.isComingSoon;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Material(
          color: widget.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            highlightColor: widget.isDark ? const Color(0xFF1E2D3D) : const Color(0xFFE2E8F0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.border, width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Typography-First Title & Metadata
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.agent.title,
                            style: GoogleFonts.outfit(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: widget.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? const Color(0xFF3B2818)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Segera',
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Elegant Action: Tombol 'Segera' (Coming Soon) atau Panah (Active)
                  if (isComingSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.isDark ? const Color(0xFF2B2012) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_clock_rounded,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Segera',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark ? const Color(0xFF1E2D3D) : const Color(0xFFEDF2F7),
                      ),
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        size: 16,
                        color: widget.accent,
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
}
