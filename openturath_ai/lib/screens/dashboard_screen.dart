import 'dart:async';
import 'package:flutter/material.dart';
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
import 'specialist_list_screen.dart';

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
                                fontSize: 11.5,
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

                    // ── 3. Academic Greeting ──
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? 'Ahlan, ${user.name}' : 'Ahlan, Peneliti Turats',
                          style: GoogleFonts.newsreader(
                            fontSize: 24,
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

                    // ── 4. Refined Pro Subscription Card (Minimalist & Enticing) ──
                    AppleInteractiveWrapper(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.subscription);
                      },
                      hapticType: HapticFeedbackType.light,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF14171F) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF263042) : const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF1E283A) : const Color(0xFFEEF4FF),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 17,
                                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'OpenTurath Pro',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                            width: 0.6,
                                          ),
                                        ),
                                        child: Text(
                                          'AKSES PENUH',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.4,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2.5),
                                  Text(
                                    'Akses korpus kitab primer tanpa batas telaah.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── 4. Carousel Banner Pengumuman & Adab Riset ──
                    _DashboardAnnouncementCarousel(
                      isDark: isDark,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accent: accent,
                    ),

                    const SizedBox(height: 20),

                    // ── 5. Minimalist Search Bar (Claude / Apple style) ──
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat Semua',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
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

                    const SizedBox(height: 14),

                    // 6 Grid Cards M3 Expressive with Stagger Cascade
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.65,
                      ),
                      itemCount: displayFields.length,
                      itemBuilder: (context, index) {
                        final field = displayFields[index];
                        final fieldAgents = AgentModel.defaultAgents.where((a) => a.fieldId == field.id).toList();

                        return AppleInteractiveWrapper(
                          onTap: () {
                            if (fieldAgents.length == 1) {
                              Navigator.of(context, rootNavigator: true).pushNamed(
                                AppRoutes.agentWebview,
                                arguments: fieldAgents.first,
                              );
                            } else {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => SpecialistListScreen(field: field),
                                ),
                              );
                            }
                          },
                          hapticType: HapticFeedbackType.light,
                          child: Material(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: border,
                                  width: 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    field.name,
                                    style: GoogleFonts.newsreader(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    field.specialistCount == 1 ? '1 Spesialis AI' : '${field.specialistCount} spesialis',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      color: textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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

/// Carousel Pengumuman & Adab Riset OpenTurath
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
          'Asisten riset keilmuan Islam berbasis korpus naskah primer mu\'tabar untuk mempermudah penelaahan turats.',
      detailedContent:
          'OpenTurath dirancang sebagai ruang telaah digital bagi para santri, asatidz, dan akademisi. Sistem ini mengintegrasikan ribuan halaman naskah primer kitab kuning (turats) dengan kemampuan pemrosesan bahasa alami untuk mencari referensi, memahami konteks ibarah, dan melacak perbandingan lintas matan dan syarah secara presisi.',
    ),
    _AnnouncementSlide(
      badge: 'KEUNGGULAN RISET',
      title: 'Riset Berbasis Sanad & Takhrij',
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
                      fontSize: 13.5,
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
          height: 132,
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
                                fontSize: 9.5,
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
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: widget.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        slide.title,
                        style: GoogleFonts.newsreader(
                          fontSize: 16.5,
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
                          fontSize: 11.5,
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
      const SizedBox(height: 10),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final isSelected = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 18 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isSelected
                    ? (widget.isDark ? Colors.white : const Color(0xFF18181B))
                    : widget.border,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
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
