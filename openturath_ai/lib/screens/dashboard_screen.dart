import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';
import '../models/agent_model.dart';
import '../models/field_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../widgets/update_ready_banner.dart';
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
      if (recents.length >= 3) break;
      if (!recents.any((r) => r.id == a.id) && a.isActive) {
        recents.add(a);
      }
    }

    if (recents.isEmpty && _agents.isNotEmpty) {
      final activeAgents = _agents.where((a) => a.isActive).toList();
      recents.addAll(activeAgents.take(2));
    }

    return recents;
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

        final recentAgents = _getRecentAgents();
        final displayFields = FieldModel.defaultFields.take(6).toList();

        return Scaffold(
          backgroundColor: canvas,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 108),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Top Bar: OpenTurath Brand Mark ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: Image.asset(
                                isDark
                                    ? 'assets/images/arch_dark_transparent.png'
                                    : 'assets/images/arch_light_transparent.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OpenTurath',
                                  style: GoogleFonts.newsreader(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.4,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'AI for Islamic Scholarship',
                                  style: GoogleFonts.newsreader(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            final shell = MainShellController.of(context);
                            shell?.switchTab(3);
                          },
                          borderRadius: BorderRadius.circular(100),
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
                              radius: 17,
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

                    const SizedBox(height: 24),

                    // ── 2. Pembaruan Otomatis Siap Pasang (Jika Ada) ──
                    const UpdateReadyBanner(),

                    // ── 3. Academic Greeting ──
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? 'Ahlan, ${user.name}' : 'Ahlan, Peneliti',
                          style: GoogleFonts.newsreader(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.3,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kaji naskah primer turats dengan asisten riset cerdas.',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── 4. Minimalist Search Bar (Claude / Apple style) ──
                    InkWell(
                      onTap: () {
                        final shell = MainShellController.of(context);
                        if (shell != null) {
                          shell.switchTab(1);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.specialistList);
                        }
                      },
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: border,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 19,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cari spesialis, bab fikih, atau kitab...',
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

                    const SizedBox(height: 22),

                    // ── 4. Section: Pilih bidang ilmu untuk memulai ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Bidang Ilmu',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Eksplorasi modul spesialis berdasarkan rumpun',
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
                          child: Text(
                            'Lihat Semua',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 6 Grid Cards M3 Expressive with Stagger Cascade
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.25,
                      ),
                      itemCount: displayFields.length,
                      itemBuilder: (context, index) {
                        final field = displayFields[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 280 + (index * 50)),
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
                          child: Material(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                final shell = MainShellController.of(context);
                                if (shell != null) {
                                  shell.switchTab(1, fieldId: field.id);
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.specialistList,
                                    arguments: field,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        field.icon,
                                        size: 19,
                                        color: accent,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            field.name,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${field.specialistCount} spesialis',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              color: textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── 5. Section: Mulai Riset (Active research notebooks) ──
                    Text(
                      'Mulai Riset',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih modul spesialis untuk memulai kajian kitab',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: accent, strokeWidth: 2),
                        ),
                      )
                    else if (recentAgents.isEmpty)
                      Container(
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
                            'Belum ada riwayat sesi riset.',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentAgents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final agent = recentAgents[index];
                          final isFirst = index == 0;
                          final timeLabel = isFirst ? 'Modul Aktif' : 'Siap Dikaji';

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 320 + (index * 60)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(20 * (1 - value), 0),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 15.5,
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: accent.withValues(alpha: isFirst ? 0.14 : 0.08),
                                                    borderRadius: BorderRadius.circular(100),
                                                  ),
                                                  child: Text(
                                                    timeLabel,
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w600,
                                                      color: accent,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 18,
                                        color: accent,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
