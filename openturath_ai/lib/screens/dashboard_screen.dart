import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/app_snackbar.dart';
import '../core/hijri_date_utils.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';
import '../models/bookmark_model.dart';
import '../models/book_model.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../services/canonical_library_service.dart';
import '../services/update_service.dart';
import '../widgets/update_ready_banner.dart';
import '../widgets/specialist_card.dart';
import '../widgets/library_bottom_sheet.dart';
import '../widgets/apple_interactive_wrapper.dart';
import '../widgets/evidence_bottom_sheet.dart';
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
  List<BookmarkModel> _recentNotes = [];
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
    setState(() => _isLoading = true);
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
        BookmarkService().getBookmarks(),
      ]).timeout(
        const Duration(seconds: 4),
        onTimeout: () => [null, AgentModel.defaultAgents, <BookmarkModel>[]],
      );

      if (!mounted) return;
      setState(() {
        _lastOpenedAgentId = lastId;
        _initialUser = results[0] as UserModel?;
        _agents = results[1] as List<AgentModel>;
        final notes = results[2] as List<BookmarkModel>;
        _recentNotes = notes.take(3).toList();
      });
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  Future<void> _openBookmarkItem(BookmarkModel item) async {
    if (item.id.startsWith('book_')) {
      final editionId = item.id.replaceFirst('book_', '');
      var books = CanonicalLibraryService.instance.cachedSyafiiBooks;
      if (books == null) {
        try {
          books = await CanonicalLibraryService.instance.loadSyafiiCatalog();
        } catch (_) {}
      }
      final matchedBook = books?.firstWhere(
        (b) => b.editionId == editionId,
        orElse: () => CanonicalBookPresentation(
          editionId: editionId,
          titleArabic: item.title,
          authorArabic: item.author ?? '',
        ),
      );

      if (matchedBook != null && mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.bookDetail,
          arguments: matchedBook,
        );
        return;
      }
    }

    _showEvidence(item);
  }

  void _showEvidence(BookmarkModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EvidenceBottomSheet(
        citationNumber: 1,
        bookName: item.bookReference.isNotEmpty ? item.bookReference : 'Rujukan Naskah',
        author: item.author ?? '',
        pageNumber: item.pageNumber,
        category: item.fieldName,
        arabicExcerpt: item.arabicExcerpt,
        explanation: item.fullAnswer,
      ),
    );
  }

  bool _isLoading = false;

  List<AgentModel> _getRecentAgents() {
    final List<AgentModel> recents = [];
    if (_lastOpenedAgentId != null && _lastOpenedAgentId!.isNotEmpty) {
      final match = _agents.where((a) => a.id == _lastOpenedAgentId && a.isActive);
      if (match.isNotEmpty) {
        recents.add(match.first);
      }
    }
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

  static const List<({String fieldId, String name, int specialistCount})> _curatedDisciplines = [
    (fieldId: 'fiqh', name: 'Fikih', specialistCount: 6),
    (fieldId: 'hadith', name: 'Hadits', specialistCount: 1),
    (fieldId: 'tafsir', name: 'Tafsir', specialistCount: 1),
    (fieldId: 'aqidah', name: 'Aqidah', specialistCount: 1),
    (fieldId: 'usul', name: 'Usul Fiqh', specialistCount: 1),
    (fieldId: 'lughah', name: 'Bahasa Arab', specialistCount: 1),
  ];

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

        final recentAgents = _getRecentAgents();
        final activeLastAgent = (_lastOpenedAgentId != null && _lastOpenedAgentId!.isNotEmpty)
            ? _agents.where((a) => a.id == _lastOpenedAgentId && a.isActive).firstOrNull
            : null;

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
                    // ── 1. Header Centered: OpenTurath ──
                    Center(
                      child: Text(
                        'OpenTurath',
                        style: GoogleFonts.newsreader(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Banner pembaruan jika tersedia
                    const UpdateReadyBanner(),

                    // ── 2. Editorial Desk Header: Dual Date & Scholarly Greeting ──
                    Text(
                      HijriDateUtils.formatDualDate(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name.isNotEmpty ? 'Ahlan, ${user.name}' : 'Ahlan, Peneliti Turats',
                      style: GoogleFonts.newsreader(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── 3. Ergonomic Search Bar (Stadium Pill) ──
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: border, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 20, color: textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val.trim()),
                              style: GoogleFonts.outfit(fontSize: 13.5, color: textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Cari spesialis, bab fikih, atau kitab...',
                                hintStyle: GoogleFonts.outfit(fontSize: 13.5, color: textSecondary),
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

                    const SizedBox(height: 22),

                    // ── 4. Jika Sedang Mencari (Hasil Realtime) ──
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        'Hasil Penelusuran',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
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
                                  'Tidak ditemukan naskah atau spesialis yang sesuai.',
                                  style: GoogleFonts.outfit(fontSize: 13.5, color: textSecondary),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: matches.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final agent = matches[idx];
                              return SpecialistCard(
                                title: agent.title,
                                statusLabel: agent.isComingSoon ? 'Segera Hadir' : null,
                                onOpen: () => _openNotebook(agent, user),
                                onOpenLibrary: agent.catalogId != null
                                    ? () => showResearchLibrary(context, agent: agent)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ] else ...[
                      // ── 5. Lanjutkan Sesi Terakhir ──
                      if (activeLastAgent != null) ...[
                        _buildResumeSessionCard(
                          context: context,
                          agent: activeLastAgent,
                          user: user,
                          isDark: isDark,
                          surface: surface,
                          border: border,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          accent: accent,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── 6. Catatan Riset Terbaru ──
                      _buildRecentNotesSection(
                        context: context,
                        notes: _recentNotes,
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accent: accent,
                      ),

                      const SizedBox(height: 28),

                      // ── 8. Section: Pilih Bidang Ilmu ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.chevron_right_rounded, size: 16, color: textPrimary),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 2-Column Minimalist Purism Grid (6 Cards, Aspect Ratio 1.45)
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.45,
                        ),
                        itemCount: _curatedDisciplines.length,
                        itemBuilder: (context, index) {
                          final disc = _curatedDisciplines[index];
                          return AppleInteractiveWrapper(
                            onTap: () {
                              final shell = MainShellController.of(context);
                              if (shell != null) {
                                shell.switchTab(1, fieldId: disc.fieldId);
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.specialistList,
                                  arguments: {'fieldId': disc.fieldId},
                                );
                              }
                            },
                            pressedScale: 0.96,
                            hapticType: HapticFeedbackType.light,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: border, width: 1.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    disc.name,
                                    style: GoogleFonts.newsreader(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${disc.specialistCount} spesialis',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.5,
                                      color: textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── 9. Section: Modul Riset (Specialist Modules) ──
                      Text(
                        'Modul Riset',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (_isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: CircularProgressIndicator(color: textPrimary, strokeWidth: 2),
                          ),
                        )
                      else if (recentAgents.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border, width: 1.0),
                          ),
                          child: Center(
                            child: Text(
                              'Belum ada riwayat sesi riset.',
                              style: GoogleFonts.outfit(fontSize: 13, color: textSecondary),
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

                            return AppleInteractiveWrapper(
                              onTap: () => _openNotebook(agent, user),
                              pressedScale: 0.98,
                              hapticType: HapticFeedbackType.selection,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: border, width: 1.0),
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
                                                    fontSize: 15,
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
                                                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                child: Text(
                                                  timeLabel,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: textSecondary,
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
                                      color: textPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 28),

                      // ── 10. Adab & Prinsip Peneliti Turats ──
                      _buildScholarlyAdabCard(
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      const SizedBox(height: 28),

                      // ── 11. Announcement Carousel (Diposisikan tenang di bawah) ──
                      _DashboardAnnouncementCarousel(
                        isDark: isDark,
                        surface: surface,
                        border: border,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accent: accent,
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

  Widget _buildResumeSessionCard({
    required BuildContext context,
    required AgentModel agent,
    required UserModel user,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
  }) {
    return AppleInteractiveWrapper(
      onTap: () => _openNotebook(agent, user),
      pressedScale: 0.98,
      hapticType: HapticFeedbackType.selection,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 16, color: accent),
                const SizedBox(width: 6),
                Text(
                  'Lanjutkan Sesi Terakhir',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Aktif Terbuka',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: textPrimary,
                        ),
                      ),
                      if (agent.titleArabic.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          agent.titleArabic,
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        agent.subtitleAcademic,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          color: textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : const Color(0xFF18181B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFF18181B) : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecentNotesSection({
    required BuildContext context,
    required List<BookmarkModel> notes,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Catatan Riset Terbaru',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                final shell = MainShellController.of(context);
                if (shell != null) {
                  shell.switchTab(2);
                } else {
                  Navigator.pushNamed(context, AppRoutes.bookmark);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semua',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 16, color: textPrimary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (notes.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.0),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_outline_rounded, size: 22, color: textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Belum ada catatan atau kutipan ibarah tersimpan. Simpan catatan naskah saat menelaah.',
                    style: GoogleFonts.outfit(fontSize: 12.5, color: textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final note = notes[idx];
              final isBookRef = note.id.startsWith('book_');
              final subtitle = note.bookReference.isNotEmpty
                  ? '${note.bookReference}${note.pageNumber.isNotEmpty ? ' (Hal. ${note.pageNumber})' : ''}'
                  : (note.author != null && note.author!.isNotEmpty
                      ? '${note.author} · ${note.agentTitle}'
                      : note.agentTitle);

              return AppleInteractiveWrapper(
                onTap: () => _openBookmarkItem(note),
                pressedScale: 0.985,
                hapticType: HapticFeedbackType.selection,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          isBookRef ? Icons.menu_book_rounded : Icons.bookmark_added_rounded,
                          size: 16,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
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
                              subtitle,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, size: 16, color: textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildScholarlyAdabCard({
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 17, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                'Adab & Prinsip Peneliti Turats',
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAdabItem(
            number: '1',
            title: 'Talaqqi Bersanad',
            desc: 'AI adalah sarana komparasi dan indeksasi naskah; bukan mufti dan bukan pengganti bimbingan guru.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildAdabItem(
            number: '2',
            title: 'Ihtiyath & Verifikasi Naskah',
            desc: 'Selalu luangkan waktu untuk membuka dan memeriksa naskah fisik primer sebelum menyimpulkan.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildAdabItem(
            number: '3',
            title: 'Amanah Ilmiah',
            desc: 'Sertakan judul kitab, nama muallif, bab, dan nomor halaman dalam menukil ibarah.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAdabItem({
    required String number,
    required String title,
    required String desc,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(fontSize: 12, height: 1.4, color: textSecondary),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardAnnouncementCarousel extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const _DashboardAnnouncementCarousel({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
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
      title: 'Mengenal OpenTurath AI',
      summary:
          'Membaca kitab dan menelusuri ibarah dari naskah rujukan.',
      detailedContent:
          'Gunakan OpenTurath untuk mencari rujukan dan membandingkan matan dengan syarah. Periksa hasilnya pada kitab asal, lalu diskusikan dengan guru.',
    ),
    _AnnouncementSlide(
      badge: 'KEUNGGULAN RISET',
      title: 'Menelusuri Sanad dan Takhrij',
      summary:
          'Dilengkapi kutipan ibarah teks asli, nomor halaman kitab muktamad, serta komparasi silang antar-mazhab.',
      detailedContent:
          'Setiap jawaban dan analisis yang dihasilkan OpenTurath selalu disertai rujukan langsung ke naskah primer. Peneliti dapat meninjau teks Arab asli, nama kitab, bab pembahasan, hingga nama pensyarah guna menjaga akurasi transmisi keilmuan Islam yang berakar kuat pada tradisi sanad.',
    ),
    _AnnouncementSlide(
      badge: 'ADAB & DISCLAIMER',
      title: 'Wasilah Bantu, Bukan Pengganti Guru',
      summary:
          'Kajian agama hakiki wajib melalui talaqqi dengan masyayikh bersanad. AI hanyalah sarana penunjang riset.',
      detailedContent:
          'PENTING DIPAHAMI:\n\nTeknologi kecerdasan buatan hanyalah perkakas indeksasi dan komparasi literatur, bukan mufti dan bukan pengganti otoritas guru (masyayikh). Pemahaman fikih, fatwa hukum, dan kedalaman spiritual tetap wajib dikonfirmasi langsung melalui proses talaqqi dan bimbingan ulama yang kompeten.',
    ),
    _AnnouncementSlide(
      badge: 'PANDUAN RISET',
      title: 'Gunakan dengan Sikap Wara\' & Bijak',
      summary:
          'Verifikasi setiap kutipan dalil ke naskah fisik primer sebelum dijadikan landasan kajian atau karya ilmiah.',
      detailedContent:
          'Sebagai seorang peneliti turats, sikap wara\' dan kehati-hatian (ihtiyath) adalah adab utama. Selalu luangkan waktu untuk membuka dan mengonfirmasi naskah cetak fisik kitab primer sebelum mengutip atau menyebarluaskan hasil telaah ke khalayak luas.',
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  slide.badge,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: widget.accent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.title,
                style: GoogleFonts.newsreader(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: widget.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.detailedContent,
                style: GoogleFonts.outfit(
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
                    backgroundColor: widget.isDark ? Colors.white : const Color(0xFF18181B),
                    foregroundColor: widget.isDark ? const Color(0xFF18181B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Mengerti & Tutup',
                    style: GoogleFonts.outfit(
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: widget.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                slide.badge,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: widget.accent,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Baca Selengkapnya',
                                  style: GoogleFonts.outfit(
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
                          slide.title,
                          style: GoogleFonts.newsreader(
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
                          style: GoogleFonts.outfit(
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
                    ? (widget.isDark ? Colors.white : const Color(0xFF18181B))
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
