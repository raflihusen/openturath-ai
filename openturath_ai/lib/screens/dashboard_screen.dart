import '../core/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/scholarly_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_copy.dart';
import '../core/constants.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_layout.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/app_snackbar.dart';
import '../core/hijri_date_utils.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../core/navigation_guard.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/update_ready_dialog.dart';
import '../widgets/ot_mobile_primitives.dart';
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
  late final UpdateService _updateService;
  bool _hasShownUpdateDialog = false;

  UserModel? _initialUser;
  List<AgentModel> _agents = AgentModel.defaultAgents;
  String _searchQuery = '';
  String? _lastOpenedAgentId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLastOpenedAgent();
    _updateService = UpdateService();
    _updateService.addListener(_onUpdateServiceChanged);
    _updateService.checkForUpdatesSilently();
  }

  void _onUpdateServiceChanged() {
    if (!mounted) return;
    if (_updateService.isUpdateReady && !_hasShownUpdateDialog) {
      _hasShownUpdateDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          UpdateReadyDialog.show(context, _updateService);
        }
      });
    }
  }

  Future<void> _loadLastOpenedAgent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() =>
            _lastOpenedAgentId = prefs.getString('last_opened_notebook_id'));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _updateService.removeListener(_onUpdateServiceChanged);
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

      final results = await Future.wait([
        _authService.getCurrentUserModel(),
        _agentService.getAgents(),
      ]).timeout(
        const Duration(seconds: 4),
        onTimeout: () => [null, AgentModel.defaultAgents],
      );

      if (!mounted) return;
      setState(() {
        _initialUser = results[0] as UserModel?;
        _agents = results[1] as List<AgentModel>;
      });
    } catch (_) {}
  }

  void _openNotebook(AgentModel agent, UserModel? user) {
    if (agent.kind == CorpusKind.scholar) {
      AppSnackBar.warning(context, Loc.tr('scholarPreparingBody'));
      return;
    }
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        Loc.tr('collectionPreparing', [agent.title]),
      );
      return;
    }

    // Rekam riwayat pembukaan terakhir secara asynchronous di background
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_opened_notebook_id', agent.id);
      if (mounted) setState(() => _lastOpenedAgentId = agent.id);
    }).catchError((_) {});

    // Cek akses pengguna ke agent (paywall)
    if (user == null || !user.hasAccessToAgent(agent.id)) {
      NavigationGuard.safePushNamed(
        context,
        AppRoutes.subscription,
        arguments: {'user': user, 'agent': agent},
      );
      return;
    }

    // Buka ruang kajian multi-tab secara seketika (0ms delay)
    AgentSessionManager.instance.openAgent(agent, user: user);
  }

  static const List<
          ({String fieldId, String name, String arabic, int specialistCount})>
      _curatedDisciplines = [
    (fieldId: 'fiqh', name: 'Fikih', arabic: 'الفقه', specialistCount: 6),
    (fieldId: 'hadith', name: 'Hadis', arabic: 'الحديث', specialistCount: 1),
    (fieldId: 'tafsir', name: 'Tafsir', arabic: 'التفسير', specialistCount: 1),
    (fieldId: 'aqidah', name: 'Akidah', arabic: 'العقيدة', specialistCount: 1),
    (fieldId: 'usul', name: 'Usul Fikih', arabic: 'الأصول', specialistCount: 1),
    (
      fieldId: 'lughah',
      name: 'Bahasa Arab',
      arabic: 'العربية',
      specialistCount: 1
    ),
  ];

  void _openField(String fieldId) {
    final shell = MainShellController.of(context);
    if (shell != null) {
      shell.switchTab(1, fieldId: fieldId);
      return;
    }
    NavigationGuard.safePushNamed(
      context,
      AppRoutes.specialistList,
      arguments: {'fieldId': fieldId},
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
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
                  : AppCopy.ahlanDefault,
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
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: OTConstrainedContent(
                  maxWidth: OTLayout.readableWidth,
                  padding: EdgeInsets.fromLTRB(
                    OTLayout.pageInset(context),
                    OTSpacing.base,
                    OTLayout.pageInset(context),
                    104,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OpenTurath',
                        style: OTTypography.brandLogo(color: textPrimary),
                      ),
                      const SizedBox(height: OTSpacing.lg),
                      const UpdateReadyBanner(),
                      ListenableBuilder(
                        listenable: AgentSessionManager.instance,
                        builder: (context, _) {
                          final activeAgent =
                              AgentSessionManager.instance.activeTab?.agent;
                          final lastAgent = _lastOpenedAgentId == null
                              ? null
                              : _agents.cast<AgentModel?>().firstWhere(
                                    (agent) => agent?.id == _lastOpenedAgentId,
                                    orElse: () => null,
                                  );
                          final target = activeAgent ?? lastAgent;
                          return Column(
                            children: [
                              _StudyEntryCard(
                                name: user.name,
                                agent: target,
                                hasLiveSession: activeAgent != null,
                                isDark: isDark,
                                onPrimary: () {
                                  if (target != null) {
                                    _openNotebook(target, user);
                                  } else {
                                    _openField('fiqh');
                                  }
                                },
                              ),
                              const SizedBox(height: OTSpacing.sm),
                              _ScholarlyDatePanel(
                                masehiDate: HijriDateUtils.formatMasehiOnly(),
                                hijriDate: HijriDateUtils.formatHijriOnly(),
                                isDark: isDark,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: OTSpacing.xl),
                      OTSearchField(
                        controller: _searchController,
                        hintText: 'Cari asisten atau bidang kajian',
                        onChanged: (value) =>
                            setState(() => _searchQuery = value.trim()),
                      ),
                      const SizedBox(height: OTSpacing.xl),
                      if (_searchQuery.isNotEmpty)
                        _DashboardSearchResults(
                          query: _searchQuery,
                          agents: _agents,
                          user: user,
                          onOpen: _openNotebook,
                        )
                      else ...[
                        OTSectionHeader(
                          title: 'Pilih bidang kajian',
                          description:
                              'Mulai dari bidang yang ingin Anda telaah.',
                          actionLabel: AppCopy.seeAll,
                          onAction: () {
                            final shell = MainShellController.of(context);
                            if (shell != null) {
                              shell.switchTab(1);
                            } else {
                              NavigationGuard.safePushNamed(
                                  context, AppRoutes.specialistList);
                            }
                          },
                        ),
                        const SizedBox(height: OTSpacing.sm),
                        OTGroupedSection(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.base,
                          ),
                          child: Column(
                            children: [
                              for (var index = 0;
                                  index < _curatedDisciplines.length;
                                  index++)
                                OTEditorialRow(
                                  title: _curatedDisciplines[index].name,
                                  subtitle: AppCopy.assistantsAvailableCount(
                                      _curatedDisciplines[index]
                                          .specialistCount),
                                  leading: SizedBox(
                                    width: 54,
                                    child: Text(
                                      _curatedDisciplines[index].arabic,
                                      textDirection: TextDirection.rtl,
                                      style: OTTypography.arabicReading(
                                        color: OTColors.textSecondary(isDark),
                                      ).copyWith(fontSize: 17),
                                    ),
                                  ),
                                  onTap: () => _openField(
                                      _curatedDisciplines[index].fieldId),
                                  showDivider:
                                      index != _curatedDisciplines.length - 1,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardSearchResults extends StatelessWidget {
  const _DashboardSearchResults({
    required this.query,
    required this.agents,
    required this.user,
    required this.onOpen,
  });

  final String query;
  final List<AgentModel> agents;
  final UserModel user;
  final void Function(AgentModel agent, UserModel user) onOpen;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final normalizedQuery = query.toLowerCase();
    final matches = agents.where((agent) {
      if (agent.kind == CorpusKind.scholar) return false;
      final books = agent.referenceBooks?.any(
            (book) => book.title.toLowerCase().contains(normalizedQuery),
          ) ??
          false;
      return agent.title.toLowerCase().contains(normalizedQuery) ||
          agent.titleArabic.contains(query) ||
          agent.subtitleAcademic.toLowerCase().contains(normalizedQuery) ||
          agent.category.toLowerCase().contains(normalizedQuery) ||
          books;
    }).toList();

    if (matches.isEmpty) {
      return const OTEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Belum menemukan hasil',
        message: 'Coba nama bidang, asisten, atau judul kitab yang lain.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OTSectionHeader(
          title: 'Hasil pencarian',
          description: '${matches.length} asisten ditemukan',
        ),
        const SizedBox(height: OTSpacing.sm),
        OTGroupedSection(
          padding: const EdgeInsets.symmetric(horizontal: OTSpacing.base),
          child: Column(
            children: [
              for (var index = 0; index < matches.length; index++)
                OTEditorialRow(
                  title: matches[index].title,
                  subtitle: matches[index].subtitleAcademic,
                  leading: Text(
                    matches[index].titleArabic,
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicReading(
                      color: OTColors.textSecondary(dark),
                    ).copyWith(fontSize: 16),
                  ),
                  trailing: matches[index].isComingSoon
                      ? const OTStatusPill(label: 'Segera')
                      : Icon(Icons.arrow_forward_rounded,
                          size: 19, color: OTColors.textTertiary(dark)),
                  onTap: () => onOpen(matches[index], user),
                  showDivider: index != matches.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudyEntryCard extends StatelessWidget {
  final String name;
  final AgentModel? agent;
  final bool hasLiveSession;
  final bool isDark;
  final VoidCallback onPrimary;

  const _StudyEntryCard({
    required this.name,
    required this.agent,
    required this.hasLiveSession,
    required this.isDark,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final displayName = name.isEmpty || name == 'Ahlan' ? null : name;
    final hasHistory = agent != null;
    final title = hasLiveSession || hasHistory
        ? agent!.title
        : AppCopy.studyEntryDefaultTitle;
    final subtitle = hasLiveSession
        ? AppCopy.studyEntryResumeSubtitle
        : (hasHistory
            ? AppCopy.studyEntryHistorySubtitle
            : AppCopy.studyEntryDefaultSubtitle);
    final primaryLabel = hasLiveSession || hasHistory
        ? AppCopy.continueStudy
        : AppCopy.startStudy;

    final surface = isDark ? OTColors.surface(isDark) : OTColors.accent(isDark);
    final textPrimary =
        isDark ? OTColors.textPrimary(isDark) : OTColors.onAccent(isDark);
    final textSecondary = textPrimary.withValues(alpha: 0.68);

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        borderRadius: OTRadius.featureBorder,
        child: InkWell(
          onTap: onPrimary,
          borderRadius: OTRadius.featureBorder,
          child: Ink(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: OTRadius.featureBorder,
              boxShadow: isDark
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 28,
                        offset: Offset(0, 12),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(OTSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName == null
                              ? AppCopy.ahlanDefault
                              : AppCopy.ahlanWithName(displayName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OTTypography.bodyMedium(color: textSecondary),
                        ),
                      ),
                      Text(
                        hasLiveSession
                            ? 'SEDANG DIBUKA'
                            : hasHistory
                                ? 'TERAKHIR DIBUKA'
                                : 'MULAI DI SINI',
                        style: OTTypography.metadataTag(color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: OTSpacing.lg),
                  Text(
                    Loc.text(title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OTTypography.editorialHero(color: textPrimary),
                  ),
                  const SizedBox(height: OTSpacing.sm),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OTTypography.body(color: textSecondary),
                  ),
                  const SizedBox(height: OTSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: onPrimary,
                      style: FilledButton.styleFrom(
                        backgroundColor: textPrimary,
                        foregroundColor: surface,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                      label: Text(primaryLabel),
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

class _ScholarlyDatePanel extends StatelessWidget {
  const _ScholarlyDatePanel({
    required this.masehiDate,
    required this.hijriDate,
    required this.isDark,
  });

  final String masehiDate;
  final String hijriDate;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.base,
        vertical: OTSpacing.md,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: OTRadius.cardBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppCopy.today,
                        style: ScholarlyFonts.outfit(
                          color: textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        masehiDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                          color: textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: border,
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.nightlight_outlined,
                  size: 14,
                  color: textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppCopy.hijriCalendar,
                        style: ScholarlyFonts.outfit(
                          color: textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        hijriDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ScholarlyFonts.outfit(
                          color: textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAnnouncementCarousel extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const _DashboardAnnouncementCarousel({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  State<_DashboardAnnouncementCarousel> createState() =>
      _DashboardAnnouncementCarouselState();
}

class _DashboardAnnouncementCarouselState
    extends State<_DashboardAnnouncementCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  static const List<_AnnouncementSlide> _slides = [
    _AnnouncementSlide(
      badge: 'TENTANG OPENTURATH',
      title: 'Mengenal OpenTurath',
      summary: 'Membaca ibarah dan menelusuri rujukan langsung dari kitab.',
      detailedContent:
          'Gunakan OpenTurath untuk mencari rujukan dan membandingkan matan dengan syarah. Periksa hasilnya pada kitab asal, lalu diskusikan dengan guru dan ulama yang berkompeten.',
    ),
    _AnnouncementSlide(
      badge: 'ADAB BELAJAR',
      title: 'Tetap Belajar Bersama Guru',
      summary: 'Belajarlah dengan bimbingan guru dan ulama yang bersanad.',
      detailedContent:
          'AI membantu mencari ibarah dan membandingkan penjelasan dalam kitab. Untuk memahami fikih dan fatwa, tetaplah belajar kepada guru dan ulama yang bersanad.',
    ),
    _AnnouncementSlide(
      badge: 'PERIKSA SUMBER',
      title: 'Cocokkan dengan Kitab Asal',
      summary: 'Periksa kembali kutipan di Maktabah Syamilah atau kitab cetak.',
      detailedContent:
          'Baca ibarah beserta konteksnya pada kitab cetak yang dirujuk sebelum menarik kesimpulan atau membagikan hasil kajian.',
    ),
    _AnnouncementSlide(
      badge: 'AMANAH ILMIAH',
      title: 'Cantumkan Rujukan Saat Mengutip',
      summary: 'Sertakan nama pengarang, judul kitab, bab, jilid, dan halaman.',
      detailedContent:
          'Saat mengutip, tuliskan nama pengarang, judul kitab, bab, jilid, dan halaman sesuai sumber yang digunakan agar rujukan mudah ditemukan.',
    ),
    _AnnouncementSlide(
      badge: 'TELUSURI RUJUKAN',
      title: 'Lihat Asal Kutipan',
      summary:
          'Gunakan informasi kitab, jilid, dan halaman untuk memeriksa naskah.',
      detailedContent:
          'Buka rujukan yang tersedia untuk menelusuri asal kutipan. Cocokkan teks, jilid, dan halaman dengan edisi kitab yang Anda gunakan.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.93);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showDetailModal(_AnnouncementSlide slide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: widget.border, width: 1.0),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: widget.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(widget.isDark),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: OTColors.border(widget.isDark),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  Loc.text(slide.badge),
                  style: ScholarlyFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: widget.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Loc.text(slide.title),
                style: ScholarlyFonts.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: widget.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Loc.text(slide.detailedContent),
                style: ScholarlyFonts.outfit(
                  fontSize: 14,
                  height: 1.55,
                  color: widget.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: OTColors.textPrimary(widget.isDark),
                    foregroundColor: OTColors.surface(widget.isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    AppCopy.close,
                    style: ScholarlyFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    return Column(
      children: [
        SizedBox(
          height: 146,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _autoPlayTimer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startAutoPlay();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return InkWell(
                  onTap: () => _showDetailModal(slide),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.border,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: OTColors.surfaceSubtle(widget.isDark),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: OTColors.border(widget.isDark),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                Loc.text(slide.badge),
                                style: ScholarlyFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: widget.textSecondary,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppCopy.readMore,
                                  style: ScholarlyFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: widget.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: widget.textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          Loc.text(slide.title),
                          style: ScholarlyFonts.newsreader(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: widget.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          slide.summary,
                          style: ScholarlyFonts.outfit(
                            fontSize: 12,
                            color: widget.textSecondary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 18 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? OTColors.textPrimary(widget.isDark)
                    : widget.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementSlide {
  final String badge;
  final String title;
  final String summary;
  final String detailedContent;

  const _AnnouncementSlide({
    required this.badge,
    required this.title,
    required this.summary,
    required this.detailedContent,
  });
}
