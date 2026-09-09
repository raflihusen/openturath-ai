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
    final title = currentField?.name ?? 'Koleksi Spesialis';
    final subtitle = currentField != null
        ? '${filteredAgents.length} Spesialis Turats'
        : 'Pilih spesialis sesuai rujukan kitab primer';

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
                    color: surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    autofocus: true,
                    style: GoogleFonts.outfit(fontSize: 14, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari spesialis, kitab, atau bab...',
                      hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: textSecondary),
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
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedFieldId = isAll ? 'all' : field?.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : surface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? Colors.white : const Color(0xFF18181B))
                                : border,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isAll ? 'Semua Bidang' : field!.name,
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
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
                            if (agent.id == 'fiqh_tahawwulat') {
                              return _SovereignTahawwulatCard(
                                agent: agent,
                                isDark: isDark,
                                surface: surface,
                                border: border,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onTap: () => _openAgent(agent),
                                onOrder: () => _openSubscriptionForAgent(agent),
                              );
                            }
                            return _SlimSpecialistRow(
                              agent: agent,
                              isDark: isDark,
                              surface: surface,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              accent: accent,
                              onTap: () => _openAgent(agent),
                              onOrder: () => _openSubscriptionForAgent(agent),
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
                border: Border.all(color: widget.border, width: 1.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Typography-First Title & Metadata
                  Expanded(
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

                  const SizedBox(width: 14),

                  // Minimalist Claude Action: Label 'Segera' halus atau Panah Minimalis
                  if (isComingSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: widget.border,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'Segera',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: widget.textSecondary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: widget.textSecondary,
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

class _SovereignTahawwulatCard extends StatelessWidget {
  final AgentModel agent;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;
  final VoidCallback onOrder;

  const _SovereignTahawwulatCard({
    required this.agent,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD97706);

    return AppleInteractiveWrapper(
      onTap: onTap,
      hapticType: HapticFeedbackType.medium,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF191611) : const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: gold.withValues(alpha: isDark ? 0.45 : 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row: Crown Badge + Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: gold.withValues(alpha: 0.4), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text(
                        'SPESIALIS UTAMA • RUKUN KEEMPAT',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rp 300.000 / bln',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title & Arabic Calligraphy
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '1.500+ Muhadharah Suara & Kitab Lengkap Al-Habib Abu Bakar Al-Masyhur',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'فقه التحولات',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // CTA Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Buka Ruang Riset',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
