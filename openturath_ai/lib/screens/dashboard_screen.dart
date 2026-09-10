import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';
import '../core/hijri_date_utils.dart';
import '../models/agent_model.dart';
import '../models/field_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/apple_interactive_wrapper.dart';
import 'main_shell_screen.dart';

/// Beranda OpenTurath AI (Figma Screen 6)
/// Menampilkan salam, kutipan ibadah thalabul ilmi, 6 grid rumpun bidang ilmu,
/// dan daftar agen riset yang baru dibuka (Lanjutkan).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AgentService _agentService = AgentService();

  UserModel? _initialUser;
  List<AgentModel> _agents = AgentModel.defaultAgents;
  String? _lastOpenedAgentId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    UpdateService().checkForUpdatesSilently();
  }

  Future<void> _loadData() async {
    try {
      if (_authService.currentUser == null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_opened_notebook_id');

      final results = await Future.wait([
        _authService.getCurrentUserModel(),
        _agentService.getAgents(),
      ]).timeout(
        const Duration(seconds: 4),
        onTimeout: () => [null, AgentModel.defaultAgents],
      );

      if (!mounted) return;
      setState(() {
        _lastOpenedAgentId = lastId;
        _initialUser = results[0] as UserModel?;
        _agents = results[1] as List<AgentModel>;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openNotebook(AgentModel agent, UserModel? user) async {
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        '${agent.title} belum tersedia (Segera Hadir). Modul ini sedang dalam tahap kurasi naskah kitab primer.',
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_opened_notebook_id', agent.id);
      if (mounted) {
        setState(() => _lastOpenedAgentId = agent.id);
      }
    } catch (_) {}

    // Cek akses pengguna ke agent (paywall)
    if (user != null && !user.hasAccessToAgent(agent.id)) {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.subscription,
        arguments: {'user': user, 'agent': agent},
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.agentWebview,
      arguments: {'agent': agent, 'user': user},
    );
  }

  String? _selectedFieldId;

  List<AgentModel> _getRecentAgents() {
    final List<AgentModel> recents = [];

    // Prioritize last opened agent if present and strictly active
    if (_lastOpenedAgentId != null && _lastOpenedAgentId!.isNotEmpty) {
      final match = _agents.where((a) => a.id == _lastOpenedAgentId && a.isActive);
      if (match.isNotEmpty) {
        recents.add(match.first);
      }
    }

    // Default core active agents
    for (final a in _agents) {
      if (recents.length >= 4) break;
      if (!recents.any((r) => r.id == a.id) && a.isActive) {
        recents.add(a);
      }
    }

    if (recents.isEmpty && _agents.isNotEmpty) {
      final activeAgents = _agents.where((a) => a.isActive).toList();
      recents.addAll(activeAgents.take(3));
    }

    return recents;
  }

  List<AgentModel> _getDisplayAgents() {
    if (_selectedFieldId != null) {
      final fieldAgents = _agents.where((a) => a.fieldId == _selectedFieldId).toList();
      if (fieldAgents.isNotEmpty) return fieldAgents;
      return AgentModel.defaultAgents.where((a) => a.fieldId == _selectedFieldId).toList();
    }
    return _getRecentAgents();
  }

  Widget _buildDisciplinePill({
    required String label,
    required bool isSelected,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? Colors.white : const Color(0xFF18181B);
    final activeFg = isDark ? const Color(0xFF18181B) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? activeBg : border,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: -0.1,
            color: isSelected ? activeFg : textSecondary,
          ),
        ),
      ),
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

    return StreamBuilder<UserModel?>(
      stream: _authService.userStream,
      builder: (context, snapshot) {
        final curFirebaseUser = _authService.currentUser;
        final user = snapshot.data ??
            _initialUser ??
            UserModel(
              uid: curFirebaseUser?.uid ?? 'user',
              name: curFirebaseUser?.displayName?.isNotEmpty == true
                  ? curFirebaseUser!.displayName!
                  : 'Santri Peneliti',
              email: curFirebaseUser?.email ?? '',
              photoUrl: curFirebaseUser?.photoURL ?? '',
              plan: AppConstants.planTrial,
              questionsUsed: 0,
            );

        return Scaffold(
          backgroundColor: canvas,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Top Bar: OpenTurath Brand & Dual Calendar ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OpenTurath',
                              style: GoogleFonts.newsreader(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              HijriDateUtils.formatDualDate(),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textSecondary,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                        AppleInteractiveWrapper(
                          onTap: () {
                            final shell = MainShellController.of(context);
                            shell?.switchTab(3);
                          },
                          hapticType: HapticFeedbackType.selection,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: border,
                                width: 1.0,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: surface,
                              backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                              child: user.photoUrl.isEmpty
                                  ? Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: textPrimary,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── 2. Pembaruan Otomatis Siap Pasang (Jika Ada) ──
                    const UpdateReadyBanner(),
                    const SizedBox(height: 20),

                    // ── 3. Research Command Surface ──
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apa yang ingin Anda teliti hari ini?',
                          style: GoogleFonts.newsreader(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Telusuri korpus naskah primer, istilah, hadits, dan fatwa mu\'tabar.',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Ergonomic Search Bar
                    InkWell(
                      onTap: () {
                        final shell = MainShellController.of(context);
                        if (shell != null) {
                          shell.switchTab(1);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.specialistList);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: border,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Telusuri kitab, istilah, hadits, atau persoalan...',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.5,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── 4. Lanjutkan Penelitian (Resume active research session) ──
                    Builder(
                      builder: (context) {
                        final recents = _getRecentAgents();
                        final lastActiveAgent = recents.isNotEmpty ? recents.first : null;
                        if (lastActiveAgent == null) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Text(
                                  'LANJUTKAN PENELITIAN',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Sesi Terakhir',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    color: textSecondary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Material(
                              color: surface,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _openNotebook(lastActiveAgent, user),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: border,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF242731) : const Color(0xFFEFF4FF),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF2E3547) : const Color(0xFFDBEAFE),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.history_edu_rounded,
                                          size: 20,
                                          color: accent,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              lastActiveAgent.title,
                                              style: GoogleFonts.newsreader(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.2,
                                                color: textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              lastActiveAgent.subtitleAcademic.isNotEmpty
                                                  ? lastActiveAgent.subtitleAcademic
                                                  : lastActiveAgent.description,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Buka',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 14,
                                              color: textPrimary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // ── 5. Ruang Riset Unggulan (Fikih Tahawwulat Signature Card) ──
                    Builder(
                      builder: (context) {
                        final tahawwulatAgent = _agents.firstWhere(
                          (a) => a.id == 'fiqh_tahawwulat',
                          orElse: () => AgentModel.defaultAgents.first,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Text(
                                  'KORPUS KHUSUS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'UNGGULAN',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Material(
                              color: surface,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _openNotebook(tahawwulatAgent, user),
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF333846) : const Color(0xFFE2E8F0),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: accent.withValues(alpha: 0.3),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.auto_stories_outlined,
                                              size: 22,
                                              color: accent,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Fikih Tahawwulat & Eskatologi',
                                                  style: GoogleFonts.newsreader(
                                                    fontSize: 17.5,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: -0.3,
                                                    color: textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  'Koleksi Naskah Lengkap & 1.500+ Rekaman Muhadharah Al-Habib Abu Bakar Al-Adni Al-Masyhur',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12.5,
                                                    color: textSecondary,
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Audio & Naskah',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Takhrij Mandiri',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Masuk Ruang Riset',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: accent,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 14,
                                                color: accent,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── 6. Unified Exploration & Research Hub ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Khazanah Keilmuan',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pilih rumpun kajian naskah primer turats',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            final shell = MainShellController.of(context);
                            if (shell != null) {
                              shell.switchTab(1);
                            } else {
                              Navigator.pushNamed(context, AppRoutes.specialistList);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat Semua',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Horizontal Discipline Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildDisciplinePill(
                            label: 'Semua',
                            isSelected: _selectedFieldId == null,
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedFieldId = null);
                            },
                          ),
                          ...FieldModel.defaultFields.take(6).map((field) {
                            final isSelected = _selectedFieldId == field.id;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _buildDisciplinePill(
                                label: field.name,
                                isSelected: isSelected,
                                isDark: isDark,
                                surface: surface,
                                border: border,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedFieldId = isSelected ? null : field.id;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Curated Research Modules List
                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: accent, strokeWidth: 2),
                        ),
                      )
                    else ...[
                      Builder(
                        builder: (context) {
                          final displayAgents = _getDisplayAgents();
                          if (displayAgents.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: border.withValues(alpha: isDark ? 0.8 : 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Belum ada modul pada rumpun ini.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayAgents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final agent = displayAgents[index];
                              final isComingSoon = agent.isComingSoon;

                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 280 + (index * 40)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(16 * (1 - value), 0),
                                    child: Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Material(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _openNotebook(agent, user),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: border,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        agent.title,
                                                        style: GoogleFonts.newsreader(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: -0.2,
                                                          color: textPrimary,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: accent.withValues(alpha: 0.08),
                                                        borderRadius: BorderRadius.circular(100),
                                                      ),
                                                      child: Text(
                                                        agent.category.toUpperCase(),
                                                        style: GoogleFonts.outfit(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                          letterSpacing: 0.3,
                                                          color: accent,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  agent.description,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          if (isComingSoon)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                                                borderRadius: BorderRadius.circular(100),
                                                border: Border.all(
                                                  color: border,
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                'Segera',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            )
                                          else
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              size: 20,
                                              color: textSecondary,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
