import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/app_snackbar.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/corpus_kind_control.dart';
import '../widgets/specialist_card.dart';
import '../widgets/library_bottom_sheet.dart';

/// Beranda OpenTurath AI (Quiet Scholar Adaptive)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AgentService _agentService = AgentService();
  final TextEditingController _searchController = TextEditingController();

  UserModel? _initialUser;
  List<AgentModel> _agents = AgentModel.defaultAgents;
  String? _lastOpenedAgentId;
  String _searchQuery = '';
  CorpusKind _selectedKind = CorpusKind.discipline;

  @override
  void initState() {
    super.initState();
    _loadData();
    UpdateService().checkForUpdatesSilently();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      });
    } catch (_) {}
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

  AgentModel? _getLastOpenedAgent() {
    if (_lastOpenedAgentId == null || _lastOpenedAgentId!.isEmpty) return null;
    final match = _agents.where((a) => a.id == _lastOpenedAgentId && a.isActive);
    return match.isNotEmpty ? match.first : null;
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
    final accent = OTColors.accent(isDark);

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

        final lastOpened = _getLastOpenedAgent();

        return Scaffold(
          backgroundColor: canvas,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: canvas,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 56,
            title: Text(
              'OpenTurath',
              style: OTTypography.brandLogo(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner pembaruan jika tersedia
                    const UpdateReadyBanner(),

                    // Search Bar dengan label jujur
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(OTRadius.input),
                        border: Border.all(color: border, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 20, color: textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val.trim()),
                              style: OTTypography.body(color: textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Cari bidang atau ulama',
                                hintStyle: OTTypography.body(color: textSecondary),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: OTSpacing.lg),

                    // Jika user sedang mencari
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        'Hasil Penelusuran',
                        style: OTTypography.sectionHeading(color: textSecondary),
                      ),
                      const SizedBox(height: OTSpacing.sm),
                      Builder(
                        builder: (context) {
                          final q = _searchQuery.toLowerCase();
                          final matches = _agents.where((a) {
                            final title = a.title.toLowerCase();
                            final arabic = a.titleArabic;
                            final subtitle = a.subtitleAcademic.toLowerCase();
                            final category = a.category.toLowerCase();
                            return title.contains(q) || arabic.contains(q) || subtitle.contains(q) || category.contains(q);
                          }).toList();

                          if (matches.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: Text(
                                  'Tidak ditemukan bidang atau ulama yang cocok',
                                  style: OTTypography.body(color: textSecondary),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: matches.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final agent = matches[idx];
                              return SpecialistCard(
                                title: agent.title,
                                titleArabic: agent.titleArabic,
                                scopeLabel: agent.subtitleAcademic.isNotEmpty ? agent.subtitleAcademic : agent.category,
                                emoji: agent.emoji,
                                statusLabel: agent.isComingSoon ? 'Belum tersedia' : null,
                                onOpen: agent.isActive ? () => _openNotebook(agent, user) : null,
                                onOpenLibrary: agent.catalogId != null
                                    ? () => showResearchLibrary(context, agent: agent)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ] else ...[
                      // ── 1. Terakhir Dibuka (HANYA jika ada riwayat nyata) ──
                      if (lastOpened != null) ...[
                        Text(
                          'Terakhir dibuka',
                          style: OTTypography.sectionHeading(color: textSecondary),
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        SpecialistCard(
                          title: lastOpened.title,
                          titleArabic: lastOpened.titleArabic,
                          scopeLabel: '${lastOpened.subtitleAcademic.isNotEmpty ? lastOpened.subtitleAcademic : lastOpened.category} · Sesi Terakhir',
                          emoji: lastOpened.emoji,
                          onOpen: () => _openNotebook(lastOpened, user),
                          onOpenLibrary: lastOpened.catalogId != null
                              ? () => showResearchLibrary(context, agent: lastOpened)
                              : null,
                        ),
                        const SizedBox(height: OTSpacing.xl),
                      ],

                      // ── 2. Kontrol Dua Jalur: Bidang Ilmu vs Korpus Ulama ──
                      CorpusKindControl(
                        value: _selectedKind,
                        onChanged: (kind) => setState(() => _selectedKind = kind),
                      ),

                      const SizedBox(height: OTSpacing.lg),

                      // ── 3. Daftar Kartu Spesialis Sesuai Jalur ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedKind == CorpusKind.discipline ? 'Bidang Ilmu' : 'Korpus Ulama',
                            style: OTTypography.sectionHeading(color: textSecondary),
                          ),
                          Text(
                            _selectedKind == CorpusKind.discipline
                                ? '${_agents.where((a) => a.kind == CorpusKind.discipline).length} Bidang'
                                : '${_agents.where((a) => a.kind == CorpusKind.scholar).length} Ulama',
                            style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
                          ),
                        ],
                      ),

                      const SizedBox(height: OTSpacing.sm),

                      Builder(
                        builder: (context) {
                          final displayedAgents = _agents.where((a) => a.kind == _selectedKind).toList();

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedAgents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              final agent = displayedAgents[idx];
                              return SpecialistCard(
                                title: agent.title,
                                titleArabic: agent.titleArabic,
                                scopeLabel: agent.subtitleAcademic.isNotEmpty ? agent.subtitleAcademic : agent.category,
                                emoji: agent.emoji,
                                statusLabel: agent.isComingSoon ? 'Belum tersedia' : null,
                                onOpen: agent.isActive ? () => _openNotebook(agent, user) : null,
                                onOpenLibrary: agent.catalogId != null
                                    ? () => showResearchLibrary(context, agent: agent)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ],
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
