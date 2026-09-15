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
import '../services/agent_service.dart';
import '../services/agent_session_manager.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../core/navigation_guard.dart';
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
  String _searchQuery = '';
  String? _lastOpenedAgentId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLastOpenedAgent();
    UpdateService().checkForUpdatesSilently();
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
    if (agent.isComingSoon) {
      AppSnackBar.warning(
        context,
        'Koleksi kitab untuk ${agent.title} masih disiapkan.',
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
                  : 'Ahlan',
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
                                  (agent) => agent?.id == _lastOpenedAgentId,
                                  orElse: () => null,
                                );
                        final target = activeAgent ?? lastAgent;
                        final hasLiveSession = activeAgent != null;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                user.name.isEmpty || user.name == 'Ahlan'
                                    ? 'Ahlan wa Sahlan'
                                    : 'Ahlan, ${user.name}',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            _StudyEntryCard(
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
                            ),
                            const SizedBox(height: 12),
                            _ScholarlyDatePanel(
                              masehiDate: HijriDateUtils.formatMasehiOnly(),
                              hijriDate: HijriDateUtils.formatHijriOnly(),
                              surface: surface,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              accent: accent,
                            ),
                          ],
                        );
                      },
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
                          Icon(Icons.search_rounded,
                              size: 20, color: textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val.trim()),
                              style: GoogleFonts.outfit(
                                  fontSize: 13.5, color: textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Cari asisten atau topik kajian…',
                                hintStyle: GoogleFonts.outfit(
                                    fontSize: 13.5, color: textSecondary),
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
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: textSecondary),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── 4. Jika Sedang Mencari (Hasil Realtime) ──
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        'Hasil pencarian',
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
                            final books = a.referenceBooks?.any(
                                    (b) => b.title.toLowerCase().contains(q)) ??
                                false;
                            return title.contains(q) ||
                                arabic.contains(q) ||
                                subtitle.contains(q) ||
                                category.contains(q) ||
                                books;
                          }).toList();

                          if (matches.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              child: Center(
                                child: Text(
                                  'Belum ada asisten atau kitab yang cocok. Coba kata kunci lain.',
                                  style: GoogleFonts.outfit(
                                      fontSize: 13.5, color: textSecondary),
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
                                statusLabel:
                                    agent.isComingSoon ? 'Segera hadir' : null,
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
                            'Pilih bidang kajian',
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
                                NavigationGuard.safePushNamed(
                                    context, AppRoutes.specialistList);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lihat semua',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
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

                      // Setiap bidang tampil sebagai indeks katalog, bukan kartu kosong.
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.28,
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
                                NavigationGuard.safePushNamed(
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (index + 1)
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.1,
                                            color: textSecondary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.north_east_rounded,
                                          size: 17,
                                          color: textSecondary.withValues(
                                              alpha: 0.72),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      disc.name,
                                      style: GoogleFonts.newsreader(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.25,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${disc.specialistCount} asisten tersedia',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11.5,
                                        color: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 2,
                                      width: 32 + (index % 3) * 12,
                                      decoration: BoxDecoration(
                                        color:
                                            textPrimary.withValues(alpha: 0.72),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

class _StudyEntryCard extends StatelessWidget {
  final AgentModel? agent;
  final bool hasLiveSession;
  final bool isDark;
  final VoidCallback onPrimary;

  const _StudyEntryCard({
    required this.agent,
    required this.hasLiveSession,
    required this.isDark,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final hasHistory = agent != null;
    final title = hasLiveSession || hasHistory
        ? agent!.title
        : 'Telaah Turats';
    final subtitle = hasLiveSession
        ? 'Sesi kajian siap dibuka kembali.'
        : (hasHistory
            ? 'Buka kembali rujukan dan catatan sebelumnya.'
            : 'Ajukan pertanyaan dan telusuri teks kitab kuning.');
    final primaryLabel = hasLiveSession || hasHistory
        ? 'Lanjutkan Kajian'
        : 'Mulai Kajian';

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232730), Color(0xFF14171D)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D323D), Color(0xFF1B1E26)],
          );

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onPrimary,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: bgGradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.16),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StudyDeskFolioPainter(isDark: isDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (agent != null ? agent!.category : 'Kajian Turats')
                              .toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFC7C7CC),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.newsreader(
                            color: const Color(0xFFF8F8F8),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFC7C7CC),
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    primaryLabel,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF141418),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: Color(0xFF141418),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

/// Ornamen batas folio naskah klasik dan geometris meja kajian turats
class _StudyDeskFolioPainter extends CustomPainter {
  final bool isDark;
  const _StudyDeskFolioPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final folioBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.08 : 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final subtleRulePaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.04 : 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Bingkai margin naskah folio turats
    const inset = 10.0;
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(16),
    );
    canvas.drawRRect(outerRect, folioBorderPaint);

    // Aksen sudut geometris khas naskah
    const cornerLength = 14.0;
    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.14 : 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Top-left
    canvas.drawLine(
      const Offset(inset + 4, inset + 4),
      const Offset(inset + 4 + cornerLength, inset + 4),
      cornerPaint,
    );
    canvas.drawLine(
      const Offset(inset + 4, inset + 4),
      const Offset(inset + 4, inset + 4 + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - inset - 4, inset + 4),
      Offset(size.width - inset - 4 - cornerLength, inset + 4),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset - 4, inset + 4),
      Offset(size.width - inset - 4, inset + 4 + cornerLength),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - inset - 4, size.height - inset - 4),
      Offset(size.width - inset - 4 - cornerLength, size.height - inset - 4),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - inset - 4, size.height - inset - 4),
      Offset(size.width - inset - 4, size.height - inset - 4 - cornerLength),
      cornerPaint,
    );

    // Garis lengkung geometris halus di sudut latar belakang
    final cx = size.width * 0.88;
    final cy = size.height * 0.38;
    for (int i = 1; i <= 3; i++) {
      final r = 32.0 * i;
      final path = Path();
      path.moveTo(cx - r, size.height + 10);
      path.quadraticBezierTo(cx, cy - r * 0.5, cx + r, size.height + 10);
      canvas.drawPath(path, subtleRulePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StudyDeskFolioPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _ScholarlyDatePanel extends StatelessWidget {
  const _ScholarlyDatePanel({
    required this.masehiDate,
    required this.hijriDate,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  final String masehiDate;
  final String hijriDate;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: accent.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hari ini',
                        style: GoogleFonts.outfit(
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
                        style: GoogleFonts.outfit(
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
                  color: accent.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kalender Hijriah',
                        style: GoogleFonts.outfit(
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
                        style: GoogleFonts.outfit(
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
                  color: widget.isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: widget.isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFE4E4E7),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  slide.badge,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: widget.textSecondary,
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
                    backgroundColor:
                        widget.isDark ? Colors.white : const Color(0xFF18181B),
                    foregroundColor:
                        widget.isDark ? const Color(0xFF18181B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    'Tutup',
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? const Color(0xFF27272A)
                                    : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: widget.isDark
                                      ? const Color(0xFF3F3F46)
                                      : const Color(0xFFE4E4E7),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                slide.badge,
                                style: GoogleFonts.outfit(
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
