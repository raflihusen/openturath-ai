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
import '../core/hijri_date_utils.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/specialist_card.dart';
import '../widgets/library_bottom_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';
import 'main_shell_screen.dart';

/// Beranda OpenTurath AI (Tactile Scholarly Research Desk)
/// Dilengkapi animasi Apple Interactive micro-compression, pantulan pegas halus,
/// penanggalan ganda Hijriah, pencarian naskah seketika, dan portal keilmuan interaktif.
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
        '${agent.title} sedang dalam tahap kurasi naskah kitab primer (Segera Hadir).',
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
    final surfaceSubtle = OTColors.surfaceSubtle(isDark);

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
        final syafiiAgent = _agents.firstWhere(
          (a) => a.id == 'fiqh_syafii',
          orElse: () => AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_syafii'),
        );
        final tahawwulatAgent = _agents.firstWhere(
          (a) => a.id == 'fiqh_tahawwulat',
          orElse: () => AgentModel.defaultAgents.firstWhere((a) => a.id == 'fiqh_tahawwulat'),
        );

        return Scaffold(
          backgroundColor: canvas,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: accent,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                              style: OTTypography.brandLogo(color: textPrimary).copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              HijriDateUtils.formatDualDate(),
                              style: OTTypography.caption(color: textSecondary).copyWith(
                                fontSize: 11.5,
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
                          pressedScale: 0.94,
                          hapticType: HapticFeedbackType.selection,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: border, width: 1.0),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: surfaceSubtle,
                              backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                              child: user.photoUrl.isEmpty
                                  ? Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                                      style: OTTypography.button(color: textPrimary).copyWith(fontSize: 13),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Banner pembaruan jika tersedia
                    const UpdateReadyBanner(),

                    // ── 2. Editorial Hero Welcome ──
                    Text(
                      'Apa yang ingin Anda telusuri?',
                      style: OTTypography.editorialHero(color: textPrimary).copyWith(fontSize: 23),
                    ),

                    const SizedBox(height: 14),

                    // ── 3. Ergonomic Realtime Search Bar ──
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
                                hintText: 'Kitab, istilah, hadits, atau persoalan...',
                                hintStyle: OTTypography.body(color: textSecondary).copyWith(fontSize: 13.5),
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

                    // ── 4. Jika User Sedang Mencari (Hasil Realtime) ──
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        'Hasil penelusuran',
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
                            final books = a.referenceBooks?.any((b) => b.title.toLowerCase().contains(q)) ?? false;
                            return title.contains(q) || arabic.contains(q) || subtitle.contains(q) || category.contains(q) || books;
                          }).toList();

                          if (matches.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: Text(
                                  'Tidak ditemukan naskah atau korpus yang sesuai.',
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
                                statusLabel: agent.isComingSoon ? 'Segera Hadir' : null,
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
                      // ── 5. Lanjutkan Penelitian (Unboxed Resume Session) ──
                      if (lastOpened != null) ...[
                        Text(
                          'Lanjutkan penelitian',
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

                      // ── 6. Ruang Riset Unggulan (Flagship Research Rooms) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ruang riset unggulan',
                            style: OTTypography.sectionHeading(color: textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Siap telaah',
                              style: OTTypography.caption(color: accent).copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OTSpacing.sm),

                      // Card Unggulan 1: Super AI Fikih Syafi'i
                      _buildFeaturedCard(
                        context: context,
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        accent: accent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        surfaceSubtle: surfaceSubtle,
                        title: 'Super AI Fikih Syafi\'i',
                        arabicTitle: 'الفقه الشافعي',
                        subtitle: 'Al-Muhaqqiq Fiqh Syafi\'i · Matan, Syarah & Hasyiyah Mu\'tabarah',
                        icon: Icons.menu_book_rounded,
                        primaryActionLabel: 'Masuk Ruang Riset',
                        onPrimaryAction: () => _openNotebook(syafiiAgent, user),
                        secondaryActionLabel: 'Katalog Pustaka (89 Kitab)',
                        onSecondaryAction: () => showResearchLibrary(context, agent: syafiiAgent),
                      ),

                      const SizedBox(height: 12),

                      // Card Unggulan 2: Fikih Tahawwulat & Eskatologi
                      _buildFeaturedCard(
                        context: context,
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        accent: accent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        surfaceSubtle: surfaceSubtle,
                        title: 'Fikih Tahawwulat & Eskatologi',
                        arabicTitle: 'فقه التحولات',
                        subtitle: 'Manhaj Fiqh Fitnah & Tanda Zaman • Rukun Keempat\n1.500+ Muhadharah · Naskah Lengkap · Takhrij Sanad',
                        icon: Icons.history_edu_rounded,
                        primaryActionLabel: 'Buka Korpus Tahawwulat',
                        onPrimaryAction: () => _openNotebook(tahawwulatAgent, user),
                      ),

                      const SizedBox(height: OTSpacing.xxl),

                      // ── 7. Disiplin Keilmuan (Discipline Navigation Portal) ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Disiplin keilmuan',
                            style: OTTypography.sectionHeading(color: textSecondary),
                          ),
                          AppleInteractiveWrapper(
                            onTap: () {
                              final shell = MainShellController.of(context);
                              shell?.switchTab(1);
                            },
                            pressedScale: 0.95,
                            hapticType: HapticFeedbackType.selection,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lihat Semua',
                                    style: OTTypography.button(color: accent).copyWith(fontSize: 12),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.arrow_forward_rounded, size: 13, color: accent),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OTSpacing.sm),

                      // 2-Column Grid Disiplin Keilmuan
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.1,
                        children: [
                          _buildDisciplinePortal(
                            context: context,
                            title: 'Fikih 4 Mazhab',
                            scope: 'Syafi\'i, Hanafi, Maliki, Hanbali',
                            icon: Icons.balance_rounded,
                            fieldId: 'fiqh',
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          _buildDisciplinePortal(
                            context: context,
                            title: 'Fikih Tahawwulat',
                            scope: 'Rukun Keempat & Eskatologi',
                            icon: Icons.history_edu_rounded,
                            fieldId: 'fiqh_tahawwulat',
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          _buildDisciplinePortal(
                            context: context,
                            title: 'Hadits & Syarah',
                            scope: 'Kutubus Sittah & Sanad',
                            icon: Icons.auto_stories_rounded,
                            fieldId: 'hadith',
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          _buildDisciplinePortal(
                            context: context,
                            title: 'Tafsir Al-Qur\'an',
                            scope: 'Kajian Ayat & Asbabun Nuzul',
                            icon: Icons.menu_book_rounded,
                            fieldId: 'tafsir',
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          _buildDisciplinePortal(
                            context: context,
                            title: 'Akidah & Kalam',
                            scope: 'Asy\'ariyyah & Ushuluddin',
                            icon: Icons.shield_outlined,
                            fieldId: 'aqidah',
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          _buildDisciplinePortal(
                            context: context,
                            title: 'Usul Fikih & Qawa\'id',
                            scope: 'Kaidah Istinbath & Maqashid',
                            icon: Icons.architecture_rounded,
                            fieldId: 'usul',
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ],
                      ),

                      const SizedBox(height: OTSpacing.xxl),

                      // ── 8. Akses Cepat Pustaka Rujukan Naskah ──
                      AppleInteractiveWrapper(
                        onTap: () => showResearchLibrary(context, agent: syafiiAgent),
                        pressedScale: 0.98,
                        hapticType: HapticFeedbackType.light,
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          color: surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: border, width: 0.8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: accent.withValues(alpha: 0.3), width: 0.8),
                                  ),
                                  child: Icon(Icons.library_books_rounded, size: 21, color: accent),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Katalog Pustaka Naskah Syafi\'i',
                                        style: OTTypography.cardTitle(color: textPrimary).copyWith(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '89 naskah primer kitab induk terverifikasi',
                                        style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildFeaturedCard({
    required BuildContext context,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color accent,
    required Color textPrimary,
    required Color textSecondary,
    required Color surfaceSubtle,
    required String title,
    required String arabicTitle,
    required String subtitle,
    required IconData icon,
    required String primaryActionLabel,
    required VoidCallback onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
  }) {
    return AppleInteractiveWrapper(
      onTap: onPrimaryAction,
      pressedScale: 0.985,
      hapticType: HapticFeedbackType.light,
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 0.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: accent.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: OTTypography.cardTitle(color: textPrimary).copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              arabicTitle,
                              textDirection: TextDirection.rtl,
                              style: OTTypography.arabicReading(
                                color: isDark ? const Color(0xFFD97706) : const Color(0xFFB45309),
                              ).copyWith(
                                fontSize: 15,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                    Expanded(
                      child: AppleInteractiveWrapper(
                        onTap: onSecondaryAction,
                        pressedScale: 0.95,
                        hapticType: HapticFeedbackType.selection,
                        child: OutlinedButton.icon(
                          onPressed: onSecondaryAction,
                          icon: Icon(Icons.menu_book_outlined, size: 14, color: textSecondary),
                          label: Text(
                            secondaryActionLabel,
                            style: OTTypography.button(color: textSecondary).copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            side: BorderSide(color: border, width: 0.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: AppleInteractiveWrapper(
                      onTap: onPrimaryAction,
                      pressedScale: 0.95,
                      hapticType: HapticFeedbackType.light,
                      child: FilledButton.icon(
                        onPressed: onPrimaryAction,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: Text(
                          primaryActionLabel,
                          style: OTTypography.button(color: Colors.white).copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplinePortal({
    required BuildContext context,
    required String title,
    required String scope,
    required IconData icon,
    required String fieldId,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return AppleInteractiveWrapper(
      onTap: () {
        final shell = MainShellController.of(context);
        shell?.switchTab(1, fieldId: fieldId);
      },
      pressedScale: 0.96,
      hapticType: HapticFeedbackType.selection,
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: OTTypography.cardTitle(color: textPrimary).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      scope,
                      style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 10.5),
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
    );
  }
}
