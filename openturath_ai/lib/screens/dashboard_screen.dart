import '../widgets/dual_calendar.dart';
import '../widgets/tahawwulat_hero.dart';
import '../widgets/tahawwulat_introduction_sheet.dart';
import '../widgets/desktop_shortcuts.dart';
import '../widgets/adaptive_sheet.dart';
import '../core/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/design/native_design.dart';
import '../core/scholarly_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_copy.dart';
import '../core/constants.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_spacing.dart';
import '../widgets/ot_motion_widgets.dart';
import '../core/design/ot_radius.dart';
import '../core/app_snackbar.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../core/navigation_guard.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/update_ready_dialog.dart';
import '../widgets/specialist_card.dart';
import '../widgets/library_bottom_sheet.dart';
import 'main_shell_screen.dart';
import '../services/bookmark_service.dart';
import '../models/bookmark_model.dart';
import '../widgets/assistant_grid_card.dart';
import '../services/open_turath_catalog_repository.dart';
import '../core/legal_copy.dart';
import '../widgets/legal_document_sheet.dart';
import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:intl/intl.dart' show NumberFormat;

/// Beranda OpenTurath AI (Tactile Scholarly Research Desk)
/// Dilengkapi animasi Apple Interactive micro-compression, pantulan pegas halus,
/// penanggalan ganda Hijriah, pencarian naskah seketika, dan portal keilmuan interaktif.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.searchFocusNode});
  final FocusNode? searchFocusNode;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final AgentService _agentService = AgentService();
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _searchFocusNode = widget.searchFocusNode ?? FocusNode();
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
    if (widget.searchFocusNode == null) _searchFocusNode.dispose();
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

  static const List<({String fieldId, String name, int specialistCount})>
      _curatedDisciplines = [
    (fieldId: 'fiqh', name: 'Fikih', specialistCount: 6),
    (fieldId: 'hadith', name: 'Hadis', specialistCount: 1),
    (fieldId: 'tafsir', name: 'Tafsir', specialistCount: 1),
    (fieldId: 'aqidah', name: 'Akidah', specialistCount: 1),
    (fieldId: 'usul', name: 'Usul Fikih', specialistCount: 1),
    (fieldId: 'lughah', name: 'Bahasa Arab', specialistCount: 1),
  ];

  @override
  Widget build(BuildContext context) => DesktopShortcuts(
        onFind: _searchFocusNode.requestFocus,
        onEscape: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
          _searchFocusNode.unfocus();
        },
        child: _buildDashboard(context),
      );

  Widget _buildDashboard(BuildContext context) {
    Loc.watch(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
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
              // Rata atas-awal: konten pendek tidak lagi melayang di tengah layar.
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner pembaruan jika tersedia
                        const UpdateReadyBanner(),
                        LayoutBuilder(builder: (context, box) {
                          final greeting = Text(AppCopy.ahlanWithName(user.name), style: OTTypography.pageTitle(color: textPrimary));
                          if (box.maxWidth < 720 || MediaQuery.textScalerOf(context).scale(16) > 24) {
                            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [greeting, const SizedBox(height: 16), const DualCalendar()]);
                          }
                          return Row(children: [Expanded(child: greeting), const SizedBox(width: 24), const SizedBox(width: 360, child: DualCalendar())]);
                        }),
                        const SizedBox(height: 24),
                        _TahawwulatSpotlight(onOpen: () {
                          final shell = MainShellController.of(context);
                          if (shell != null) {shell.switchTab(1, fieldId: 'fiqh_tahawwulat');}
                          else {NavigationGuard.safePushNamed(context, AppRoutes.specialistList, arguments: {'fieldId': 'fiqh_tahawwulat'});}
                        }),
                        const SizedBox(height: 24),

                        // ── 3. Ergonomic Search Bar (Stadium Pill) ──
                        ListenableBuilder(
                          listenable: _searchFocusNode,
                          builder: (context, _) {
                            final isFocused = _searchFocusNode.hasFocus;
                            return Container(
                              constraints: const BoxConstraints(minHeight: 56),
                              padding: const EdgeInsetsDirectional.only(
                                  start: 12, end: 4),
                              decoration: BoxDecoration(
                                color: OTColors.surfaceSubtle(isDark),
                                borderRadius: OTRadius.inputBorder,
                                border: Border.all(
                                    color: isFocused
                                        ? accent
                                        : OTColors.surfaceSubtle(isDark)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded,
                                      size: 20,
                                      color:
                                          isFocused ? accent : textSecondary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      onChanged: (val) => setState(
                                          () => _searchQuery = val.trim()),
                                      style: ScholarlyFonts.outfit(
                                          fontSize: OTFontSize.s14,
                                          color: textPrimary),
                                      decoration: InputDecoration(
                                        hintText: AppCopy.dashboardSearchHint,
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
                                    Tooltip(
                                      message: Loc.tr('clearSearch'),
                                      child: InkWell(
                                        onTap: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                        borderRadius: BorderRadius.circular(
                                            OTRadius.card),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(Icons.close_rounded,
                                              size: 18, color: textSecondary),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // ── 4. Jika Sedang Mencari (Hasil Realtime) ──
                        if (_searchQuery.isNotEmpty) ...[
                          Text(
                            AppCopy.searchResults,
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final q = _searchQuery.toLowerCase();
                              final matches = _agents.where((a) {
                                if (a.kind == CorpusKind.scholar) return false;
                                final title = a.title.toLowerCase();
                                final arabic = a.titleArabic;
                                final subtitle =
                                    a.subtitleAcademic.toLowerCase();
                                final category = a.category.toLowerCase();
                                final books = a.referenceBooks?.any((b) =>
                                        b.title.toLowerCase().contains(q)) ??
                                    false;
                                return title.contains(q) ||
                                    arabic.contains(q) ||
                                    subtitle.contains(q) ||
                                    category.contains(q) ||
                                    books;
                              }).toList();

                              if (matches.isEmpty) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      AppCopy.noAssistantsFound,
                                      style: ScholarlyFonts.outfit(
                                          fontSize: OTFontSize.s14,
                                          color: textSecondary),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: matches.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, idx) {
                                  final agent = matches[idx];
                                  return SpecialistCard(
                                    title: agent.title,
                                    titleArabic: agent.titleArabic,
                                    fieldId: agent.fieldId,
                                    scopeLabel: null,
                                    statusLabel: agent.isComingSoon
                                        ? AppCopy.comingSoon
                                        : null,
                                    onOpen: () => _openNotebook(agent, user),
                                    onOpenLibrary: agent.catalogId != null
                                        ? () => showResearchLibrary(context,
                                            agent: agent)
                                        : null,
                                  );
                                },
                              );
                            },
                          ),
                        ] else ...[
                          // ── Bidang kajian: pintu masuk utama ke studi ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppCopy.chooseField,
                                style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final shell = MainShellController.of(context);
                                  if (shell != null) {
                                    shell.switchTab(1);
                                  } else {
                                    NavigationGuard.safePushNamed(
                                        context, AppRoutes.specialistList);
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppCopy.seeAll,
                                      style: ScholarlyFonts.outfit(
                                        fontSize: OTFontSize.s12,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(Icons.chevron_right_rounded,
                                        size: 16, color: textPrimary),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Setiap bidang tampil sebagai kartu direktori keilmuan adaptif berkelas.
                          LayoutBuilder(
                              builder: (context, box) => GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          MediaQuery.textScalerOf(context)
                                                      .scale(14) >
                                                  18
                                              ? 1
                                              : box.maxWidth >= 700
                                                  ? 3
                                                  : box.maxWidth >= 340
                                                      ? 2
                                                      : 1,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      mainAxisExtent:
                                          MediaQuery.textScalerOf(context)
                                              .scale(124),
                                    ),
                                    itemCount: _curatedDisciplines.length,
                                    itemBuilder: (context, index) {
                                      final disc = _curatedDisciplines[index];
                                      // Jumlah dihitung dari daftar asisten, bukan angka tetap.
                                      final members = _agents
                                          .where((agent) =>
                                              agent.kind ==
                                                  CorpusKind.discipline &&
                                              agent.fieldId == disc.fieldId)
                                          .toList();
                                      return OTReveal(
                                        index: index + 2,
                                        child: OTBentoTile(
                                          semanticLabel: Loc.text(disc.name),
                                          onTap: () {
                                            final shell =
                                                MainShellController.of(context);
                                            if (shell != null) {
                                              shell.switchTab(1,
                                                  fieldId: disc.fieldId);
                                            } else {
                                              NavigationGuard.safePushNamed(
                                                context,
                                                AppRoutes.specialistList,
                                                arguments: {
                                                  'fieldId': disc.fieldId
                                                },
                                              );
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      Loc.text(disc.name),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: ScholarlyFonts
                                                          .outfit(
                                                        fontSize:
                                                            OTFontSize.s20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: -0.25,
                                                        color: textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              Text(
                                                AppCopy
                                                    .assistantsAvailableCount(
                                                        members.isEmpty
                                                            ? disc
                                                                .specialistCount
                                                            : members.length),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: ScholarlyFonts.outfit(
                                                  fontSize: OTFontSize.s14,
                                                  fontWeight: FontWeight.w600,
                                                  color: textPrimary,
                                                ),
                                              ),
                                              // Nama Arab bidang ilmu adalah wajah kartu;
                                              // di antarmuka Arab judulnya sudah Arab.
                                              if (!Loc.isArabic &&
                                                  NativeCopy.values[
                                                          'field_${disc.fieldId}'] !=
                                                      null)
                                                Align(alignment: Alignment.centerRight, child: Text(
                                                  NativeCopy.values[
                                                      'field_${disc.fieldId}']![2],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: ScholarlyFonts
                                                      .scheherazadeNew(
                                                    fontSize: OTFontSize.s16,
                                                    color: textSecondary,
                                                  ),
                                                ))
                                              else if (members.isNotEmpty)
                                                Text(
                                                  members
                                                      .map((agent) =>
                                                          Loc.text(agent.title))
                                                      .join(' · '),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: ScholarlyFonts.outfit(
                                                    fontSize: OTFontSize.s12,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                          const SizedBox(height: 12),
                        // Kartu ini hanya menampilkan keadaan yang benar-benar ada:
                        // sesi yang masih tersimpan, asisten terakhir, atau pintu mulai.
                        ListenableBuilder(
                          listenable: AgentSessionManager.instance,
                          builder: (context, _) {
                            final activeAgent =
                                AgentSessionManager.instance.activeTab?.agent;
                            final lastAgent = _lastOpenedAgentId == null
                                ? null
                                : _agents.cast<AgentModel?>().firstWhere(
                                      (agent) =>
                                          agent?.id == _lastOpenedAgentId,
                                      orElse: () => null,
                                    );
                            final target = activeAgent ?? lastAgent;
                            final hasLiveSession = activeAgent != null;
                            final hero = _StudyEntryCard(
                              name: user.name,
                              agent: target,
                              hasLiveSession: hasLiveSession,
                              isDark: isDark,
                              onPrimary: () {
                                if (target != null) {
                                  _openNotebook(target, user);
                                  return;
                                }
                                final shell = MainShellController.of(context);
                                if (shell != null) {
                                  shell.switchTab(1);
                                } else {
                                  NavigationGuard.safePushNamed(
                                      context, AppRoutes.specialistList);
                                }
                              },
                            );
                            return target == null ? const SizedBox.shrink() : hero;
                          },
                        ),
                        const SizedBox(height: 24),
                          const _RecentNoteTile(),
                          const SizedBox(height: 12),
                          LayoutBuilder(builder: (context, box) {
                            const totals = _LibraryNumbersTile();
                            const adab = _AdabOfDayTile();
                            if (box.maxWidth < 680) {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  totals,
                                  SizedBox(height: 12),
                                  adab,
                                ],
                              );
                            }
                            return const IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: totals),
                                  SizedBox(width: 12),
                                  Expanded(child: adab),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
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

/// Jumlah pustaka, entri kitab, dan halaman dari metadata katalog.
class _LibraryNumbersTile extends StatelessWidget {
  const _LibraryNumbersTile();

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    return OTBentoTile(
      padding: const EdgeInsets.all(OTSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Loc.tr('libraryInNumbers'),
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s12, color: muted)),
          const SizedBox(height: OTSpacing.md),
          FutureBuilder<Map<String, AiLibraryMetadata>>(
            future: OpenTurathCatalogRepository.instance.loadAllMetadata(),
            builder: (context, snapshot) {
              final all = snapshot.data ?? const <String, AiLibraryMetadata>{};
              if (snapshot.hasError) return Text(Loc.tr('catalogFailure'));
              if (all.isEmpty) return const SizedBox(height: 44);
              final number = NumberFormat.decimalPattern(Loc.language);
              final entries =
                  all.values.fold<int>(0, (sum, item) => sum + item.totalKitab);
              final pages = all.values
                  .fold<int>(0, (sum, item) => sum + item.totalHalaman);
              Widget stat(String value, String label) => Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(value,
                            style: ScholarlyFonts.outfit(
                                fontSize: OTFontSize.s20,
                                fontWeight: FontWeight.w600,
                                color: ink)),
                        Text(label,
                            maxLines: 2,
                            style: ScholarlyFonts.outfit(
                                fontSize: OTFontSize.s12, color: muted)),
                      ],
                    ),
                  );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  stat(number.format(all.length), Loc.tr('loginStatLibraries')),
                  stat(Loc.atLeast(number.format(entries ~/ 100 * 100)),
                      Loc.tr('loginStatEntries')),
                  stat(
                      Loc.atLeast(number.format(pages ~/ 100000 / 10),
                          Loc.tr('unitMillion')),
                      Loc.tr('loginStatPages')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Ringkasan delapan adab untuk bahasa selain Indonesia: (judul, satu kalimat).
/// Urutannya mengikuti "Adab 1-8" di [LegalCopy.aiGuidelineSections].
const Map<String, List<(String, String)>> _adabDigest = {
  'en': [
    (
      'AI is a study aid, not a teacher',
      'Use it to widen your reading and prepare questions for your teacher. It issues no fatwa and does not replace the study circle.'
    ),
    (
      'Check the text and its context',
      'Read what comes before and after a quotation to understand the full context, conditions, and exceptions in the original text.'
    ),
    (
      'Respect the schools and the specialists',
      'Legal rulings and hadith grading belong to qualified scholars; AI only presents reports and opinions.'
    ),
    (
      'Attribute honestly',
      'Cite only sources you have checked yourself, not a book you know through an AI summary.'
    ),
    (
      'Beware of confident but wrong answers',
      'Fluent, assured wording proves nothing. Weigh every answer against the Qur\'an, the Sunnah, and the scholars.'
    ),
    (
      'Keep the chain of transmission',
      'AI has no sanad, no probity, and no ijazah. Treat it as a library, not as a bearer of knowledge.'
    ),
    (
      'Guard your tongue and your hands',
      'Do not use AI to disparage scholars or fellow Muslims, or to stir up hostility.'
    ),
    (
      'Polite and scholarly corrections',
      'Report textual errors, misattributions, or inaccuracies respectfully through official channels so the heritage remains preserved.'
    ),
  ],
  'ar': [
    (
      'الذكاء الاصطناعي وسيلة لا شيخ',
      'استعن به لتوسيع المطالعة وإعداد الأسئلة لشيخك؛ فهو لا يفتي ولا يغني عن مجالس العلم.'
    ),
    (
      'تحقق من النص وسياقه',
      'اقرأ ما قبل الاقتباس وما بعده لفهم سياق المسألة وشروطها في النص الأصلي.'
    ),
    (
      'احترم المذاهب وأهل الاختصاص',
      'الحكم الشرعي وتصحيح الحديث لأهلهما، والذكاء الاصطناعي يعرض الروايات والأقوال فحسب.'
    ),
    (
      'الأمانة في العزو',
      'لا تعزُ إلا إلى مصدر راجعته بنفسك، لا إلى كتاب عرفته من تلخيص الآلة.'
    ),
    (
      'احذر الجواب الواثق الخاطئ',
      'فصاحة العبارة ليست دليلًا على الصواب؛ فاعرض كل جواب على الكتاب والسنة وكلام العلماء.'
    ),
    (
      'حافظ على السند',
      'الآلة لا سند لها ولا عدالة ولا إجازة؛ فعاملها معاملة المكتبة لا حامل العلم.'
    ),
    (
      'احفظ لسانك ويدك',
      'لا تستعملها في ذم العلماء أو المسلمين ولا في إثارة العداوة.'
    ),
    (
      'الأدب في التصحيح والتنبيه',
      'إذا وجدت خطأ في نص أو نسبة، فبلّغ عنه بأدب وعلمية عبر القنوات الرسمية حفظًا للتراث.'
    ),
  ],
};

/// Satu adab menggunakan AI per hari, diambil dari panduan.
class _AdabOfDayTile extends StatelessWidget {
  const _AdabOfDayTile();

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final today = DateTime.now();
    final day = today.difference(DateTime(today.year)).inDays;
    final String title;
    final String body;
    final digest = _adabDigest[Loc.language];
    if (digest != null) {
      (title, body) = digest[day % digest.length];
    } else {
      // Bahasa Indonesia: langsung dari naskah panduan.
      final adab = LegalCopy.aiGuidelineSections
          .where((section) => section.title.startsWith('Adab '))
          .toList();
      if (adab.isEmpty) return const SizedBox.shrink();
      final section = adab[day % adab.length];
      title = section.title.split(' · ').last;
      body = section.content.split('\n').first;
    }
    return OTBentoTile(
      onTap: () => LegalDocumentSheet.showAiGuideline(context),
      semanticLabel: '${Loc.tr('aiEtiquetteLabel')}: $title',
      padding: const EdgeInsets.all(OTSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(Loc.tr('aiEtiquetteLabel'),
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s12, color: muted)),
              ),
              Icon(Icons.arrow_forward_rounded, size: 16, color: muted),
            ],
          ),
          const SizedBox(height: OTSpacing.sm),
          Text(title,
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s16,
                  fontWeight: FontWeight.w600,
                  color: ink)),
          const SizedBox(height: 4),
          Text(body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14, height: 1.5, color: muted)),
        ],
      ),
    );
  }
}

/// Catatan terakhir sebagai jalan pintas; tidak tampil bila belum ada catatan.
class _RecentNoteTile extends StatefulWidget {
  const _RecentNoteTile();

  @override
  State<_RecentNoteTile> createState() => _RecentNoteTileState();
}

class _RecentNoteTileState extends State<_RecentNoteTile> {
  final BookmarkService _service = BookmarkService();
  BookmarkModel? _latest;

  @override
  void initState() {
    super.initState();
    _service.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _service.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final notes = await _service.getBookmarks();
      if (mounted) setState(() => _latest = notes.firstOrNull);
    } catch (_) {
      // Penyimpanan lokal belum siap; ubin cukup tidak ditampilkan.
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final note = _latest;
    if (note == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = OTColors.textSecondary(isDark);
    final title = note.title.trim().isNotEmpty
        ? note.title.trim()
        : note.fullAnswer.trim();
    return OTBentoTile(
      semanticLabel: '${Loc.tr('recentNote')}: $title',
      onTap: () => MainShellController.of(context)?.switchTab(2),
      child: Row(
        children: [
          Icon(Icons.edit_note_rounded, size: 22, color: secondary),
          const SizedBox(width: OTSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Loc.tr('recentNote'),
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s12, color: secondary)),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s16,
                    fontWeight: FontWeight.w600,
                    color: OTColors.textPrimary(isDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: OTSpacing.sm),
          Icon(Icons.arrow_forward_rounded, size: 18, color: secondary),
        ],
      ),
    );
  }
}

class _StudyEntryCard extends StatelessWidget {
  const _StudyEntryCard(
      {required this.name,
      required this.agent,
      required this.hasLiveSession,
      required this.isDark,
      required this.onPrimary});
  final String name;
  final AgentModel? agent;
  final bool hasLiveSession;
  final bool isDark;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);

    final hasHistory = agent != null;
    final title = hasHistory ? agent!.title : AppCopy.studyEntryDefaultTitle;
    final subtitle = hasLiveSession
        ? AppCopy.studyEntryResumeSubtitle
        : hasHistory
            ? AppCopy.studyEntryHistorySubtitle
            : AppCopy.studyEntryDefaultSubtitle;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    return OTBentoTile(
      padding: const EdgeInsets.all(OTSpacing.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(hasHistory ? AppCopy.continueStudy : AppCopy.navStudies,
            style: OTTypography.caption(color: muted)),
        const SizedBox(height: 14),
        Text(Loc.text(title),
            style: ScholarlyFonts.newsreader(
                fontSize: MediaQuery.sizeOf(context).width >= 768
                    ? OTFontSize.s26
                    : OTFontSize.s26,
                fontWeight: FontWeight.w400,
                letterSpacing: -.6,
                height: 1.18,
                color: ink)),
        const SizedBox(height: 10),
        ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(subtitle,
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14, height: 1.55, color: muted))),
        const SizedBox(height: 20),
        FilledButton.icon(
            onPressed: onPrimary,
            label:
                Text(hasHistory ? AppCopy.continueStudy : AppCopy.startStudy),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            iconAlignment: IconAlignment.end),
      ]),
    );
  }
}

/// Sorotan koleksi utama: angka pustaka Fikih Tahawwulat dari metadata.
class _TahawwulatSpotlight extends StatelessWidget {
  const _TahawwulatSpotlight({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, AiLibraryMetadata>>(
    future: OpenTurathCatalogRepository.instance.loadAllMetadata(),
    builder: (context, snapshot) => TahawwulatHero(
      onOpen: onOpen,
      onIntroduction: () => TahawwulatIntroductionSheet.show(context),
      facts: LibraryStat.from(OpenTurathCatalogRepository.exactMetadata(snapshot.data ?? const {}, 'fiqh_tahawwulat')).map((s) => '${s.value} ${s.unit}').toList(),
    ));
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
    showAdaptiveSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: widget.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(OTRadius.sheet)),
            border: Border.all(color: widget.border, width: 1.0),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: SheetGrabber(bottom: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(widget.isDark),
                  borderRadius: BorderRadius.circular(OTRadius.chip),
                  border: Border.all(
                    color: OTColors.border(widget.isDark),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  Loc.text(slide.badge),
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s11,
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
                  fontSize: OTFontSize.s22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: widget.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Loc.text(slide.detailedContent),
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
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
                  child: Text(
                    AppCopy.close,
                    style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14,
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
                  borderRadius: BorderRadius.circular(OTRadius.input),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.surface,
                      borderRadius: BorderRadius.circular(OTRadius.input),
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
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: OTColors.surfaceSubtle(widget.isDark),
                                borderRadius:
                                    BorderRadius.circular(OTRadius.chip),
                                border: Border.all(
                                  color: OTColors.border(widget.isDark),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                Loc.text(slide.badge),
                                style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s11,
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
                                    fontSize: OTFontSize.s11,
                                    fontWeight: FontWeight.w400,
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
                            fontSize: OTFontSize.s16,
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
                            fontSize: OTFontSize.s12,
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
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 18 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? OTColors.textPrimary(widget.isDark)
                    : widget.border,
                borderRadius: BorderRadius.circular(OTRadius.chip),
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

/// Tanggal hari ini: Hijriah sebagai judul, Masehi di sampingnya.
