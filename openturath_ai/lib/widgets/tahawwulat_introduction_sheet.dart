import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design/ot_colors.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';

/// Item pembantu untuk data Sunanul Khalaq
class _SunanItem {
  final String number;
  final String title;
  final String arabic;
  final String desc;

  const _SunanItem({
    required this.number,
    required this.title,
    required this.arabic,
    required this.desc,
  });
}

/// Item pembantu untuk data Al-Khuwaishah
class _KhuwaishahLayer {
  final String layer;
  final String title;
  final String arabic;
  final String desc;

  const _KhuwaishahLayer({
    required this.layer,
    required this.title,
    required this.arabic,
    required this.desc,
  });
}

/// Item pembantu untuk data kitab kurikulum
class _BookLevel {
  final String level;
  final String title;
  final String arabic;
  final String desc;

  const _BookLevel({
    required this.level,
    required this.title,
    required this.arabic,
    required this.desc,
  });
}

/// Item pembantu untuk 5 bilik Super AI
class _AiRoomItem {
  final String number;
  final String name;
  final String arabic;
  final String role;
  final String desc;
  final String subAgentId;

  const _AiRoomItem({
    required this.number,
    required this.name,
    required this.arabic,
    required this.role,
    required this.desc,
    required this.subAgentId,
  });
}

/// Modal interaktif komprehensif untuk mengenal disiplin ilmu Fikih Tahawwulat.
/// Menampilkan teks penjelasan terstruktur, komparasi, serta flowchart minimalis & elegan
/// yang ramah layar sentuh (The Quiet Scholar design system).
class TahawwulatIntroductionSheet extends StatefulWidget {
  final AgentModel? agent;
  final void Function(SubAgentModel subAgent)? onSelectSubAgent;
  final VoidCallback? onOpenMain;

  const TahawwulatIntroductionSheet({
    super.key,
    this.agent,
    this.onSelectSubAgent,
    this.onOpenMain,
  });

  /// Tampilkan lembar modal Fikih Tahawwulat
  static Future<void> show(
    BuildContext context, {
    AgentModel? agent,
    void Function(SubAgentModel subAgent)? onSelectSubAgent,
    VoidCallback? onOpenMain,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) => TahawwulatIntroductionSheet(
        agent: agent,
        onSelectSubAgent: onSelectSubAgent,
        onOpenMain: onOpenMain,
      ),
    );
  }

  @override
  State<TahawwulatIntroductionSheet> createState() =>
      _TahawwulatIntroductionSheetState();
}

class _TahawwulatIntroductionSheetState
    extends State<TahawwulatIntroductionSheet> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  static const List<String> _tabs = [
    "Semua",
    "Hakikat",
    "Rukun ke-4",
    "Sunanul Khalaq",
    "Khuwaishah",
    "Kurikulum",
    "5 Bilik AI",
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = OTColors.surface(isDark);
    final borderColor = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final textTertiary = OTColors.textTertiary(isDark);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── 1. Top Bar & Drag Handle ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: OTColors.sovereignAmberBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: OTColors.sovereignAmber.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        "DISIPLIN ILMU",
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: OTColors.sovereignAmber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mengenal Fikih Tahawwulat",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.newsreader(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            "Hakikat, Landasan, Kurikulum & 5 Bilik AI",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: textSecondary,
                      ),
                      splashRadius: 20,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 2. Filter Pills ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: List.generate(_tabs.length, (idx) {
                final isSelected = _selectedTabIndex == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppleInteractiveWrapper(
                    onTap: () {
                      setState(() => _selectedTabIndex = idx);
                      _scrollToTop();
                    },
                    pressedScale: 0.96,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black)
                            : OTColors.surfaceSubtle(isDark),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : borderColor,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _tabs[idx],
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const Divider(height: 1, thickness: 0.8),

          // ── 3. Scrollable Content ──
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                if (_selectedTabIndex == 0 || _selectedTabIndex == 1) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 01",
                    title: "Hakikat & Landasan Syariat",
                    arabic: "حَقِيقَةُ فِقْهِ التَّحَوُّلَاتِ وَمَفْهُومُهُ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Fikih Tahawwulat (فِقْهُ التَّحَوُّلَاتِ) merupakan disiplin ilmu syariat komprehensif yang dirumuskan oleh Al-Musnid Al-`Allāmah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur. "
                    "Secara terminologi syariat, ilmu ini didefinisikan sebagai pemahaman mendalam terhadap ketetapan takdir Allah di alam azali, sunatullah atas perubahan zaman, "
                    "serta kaidah membaca tanda-tanda akhir zaman (kebangkitan, krisis, dan fitnah) berdasarkan timbangan Al-Qur'an dan As-Sunnah.",
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildQuoteCard(
                    context,
                    quote:
                        "«الفَهْمُ الشَّرْعِيُّ لِمَا يَقْضِي اللهُ وَيُدَبِّرُهُ فِي العَالَمِ الأَزَلِيِّ، وَمَا جَرَى وَيَجْرِي مِنْ سُنَنِ التَّغَيُّرَاتِ فِي الكَوْنِ، وَفِقْهُ عَلَامَاتِ السَّاعَةِ وَمَرَاحِلِ الفِتَنِ وَفِقْهِ الدَّعْوَةِ فِي كُلِّ مَرْحَلَةٍ»",
                    source: "Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur",
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                ],

                if (_selectedTabIndex == 0 || _selectedTabIndex == 2) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 02",
                    title: "Rukun Keempat Agama (Hadis Jibril AS)",
                    arabic: "الرُّكْنُ الرَّابِعُ مِنْ أَرْكَانِ الدِّينِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Landasan primer Fikih Tahawwulat bersumber langsung dari Hadis Jibril AS yang masyhur (HR. Muslim). "
                    "Di akhir dialog agung tersebut, Malaikat Jibril mengajukan 4 pertanyaan inti kepada Baginda Nabi ﷺ: "
                    "tentang Islam, Iman, Ihsan, dan Tanda-Tanda Hari Kiamat (Asyrat As-Sa'ah). "
                    "Sebagaimana tiga rukun terdahulu melahirkan disiplin ilmu Fikih Hukum, Ilmu Tauhid/Akidah, dan Ilmu Tasawuf/Suluk, maka rukun keempat ini melahirkan disiplin ilmu Fikih Tahawwulat.",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFourPillarsFlowchart(context, isDark),
                  const SizedBox(height: 24),
                ],

                if (_selectedTabIndex == 0 || _selectedTabIndex == 3) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 03",
                    title: "Arsitektur Sunanul Khalaq (Hukum Penciptaan)",
                    arabic: "سُنَنُ الخَلْقِ الإِلَهِيَّةِ وَنَوَامِيسُ الكَوْنِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Alam semesta dan kehidupan manusia diatur oleh 5 hukum penciptaan ketuhanan (Sunanul Khalaq). "
                    "Fikih Tahawwulat bertindak sebagai instrumen syar'i untuk memahami hukum kelima: Sunan at-Taghayyurat (hukum pergeseran dan transformasi zaman) "
                    "agar umat tidak kaget atau terseret arus kegelapan akhir zaman.",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildSunanulKhalaqFlowchart(context, isDark),
                  const SizedBox(height: 24),
                ],

                if (_selectedTabIndex == 0 || _selectedTabIndex == 4) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 04",
                    title: "Konsep Al-Khuwaishah (Penyelamatan Komunitas)",
                    arabic: "مَنْظُومَةُ الخُوَيْصَةِ: النَّجَاةُ الذَّاتِيَّةُ وَالأُسْرِيَّةُ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Al-Khuwaishah (الـخُوَيْصَة) — bentuk pengecilan (tashghir) dari Al-Khashshah (lingkaran privat) — "
                    "adalah strategi taktis kenabian untuk menyelamatkan diri, keluarga, dan majelis ilmu di saat ruang publik "
                    "(Al-`Ammah) dilanda badai fitnah, ujaran kebencian, dan adu domba.",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildKhuwaishahFlowchart(context, isDark),
                  const SizedBox(height: 24),
                ],

                if (_selectedTabIndex == 0 || _selectedTabIndex == 5) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 05",
                    title: "Kurikulum Pustaka: Qawa'id & Tatbiqat",
                    arabic: "مَنْهَجِيَّةُ التَّأْلِيفِ: القَوَاعِدُ وَالتَّطْبِيقَاتُ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Karya tulis Fikih Tahawwulat oleh Al-Habib Abu Bakar Al-Adni terbagi secara tegas ke dalam dua kategori: "
                    "Al-Qawa'id (6 kitab kaidah usul pokok berjenjang) dan At-Tatbiqat (lebih dari 50 kitab terapan sejarah & ratusan diwan karya syair).",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildCurriculumFlowchart(context, isDark),
                  const SizedBox(height: 24),
                ],

                if (_selectedTabIndex == 0 || _selectedTabIndex == 6) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 06",
                    title: "Super AI 5 Bilik Keilmuan OpenTurath",
                    arabic: "الغُرَفُ الخَمْسُ لِلذَّكَاءِ الاصْطِنَاعِيِّ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Karena Fikih Tahawwulat sarat dengan diksi-diksi baru (al-mustalahat al-mubtakarah) serta ribuan jam transkrip rekaman lisan mualif, "
                    "OpenTurath AI menghadirkan 5 Bilik Super AI spesialis untuk mendampingi penelaahan Anda:",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFourAiRoomsFlowchart(context, isDark),
                  const SizedBox(height: 24),
                ],

                // ── Closing & Prayer ──
                _buildClosingCard(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FLOWCHART 1: INTEGRASI 4 RUKUN AGAMA (HADIS JIBRIL AS)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFourPillarsFlowchart(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                size: 16,
                color: OTColors.sovereignAmber,
              ),
              const SizedBox(width: 8),
              Text(
                "STRUKTUR 4 RUKUN AGAMA",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: OTColors.sovereignAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Pillar Tiles
          _buildPillarTile(
            number: "01",
            title: "Al-Islam (الإِسْلَام)",
            discipline: "Fikih Hukum & Syariat",
            desc: "Ibadah praktis, halal-haram, muamalah & hukum lahiriah.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "02",
            title: "Al-Iman (الإِيمَان)",
            discipline: "Fikih Akidah & Tauhid",
            desc: "Keimanan pada Allah, malaikat, kitab, rasul & takdir azali.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "03",
            title: "Al-Ihsan (الإِحْسَان)",
            discipline: "Fikih Suluk & Tasawuf",
            desc: "Penyucian jiwa (tazkiyah), muraqabah & keindahan akhlak.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "04",
            title: "Fikih Tahawwulat (فِقْهُ التَّحَوُّلَاتِ)",
            discipline: "Tanda Kiamat & Navigasi Zaman",
            desc:
                "Membaca perubahan zaman, siklus peradaban, fitnah & sunnah mawaqif.",
            isDark: isDark,
            isHighlight: true,
          ),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.6),
                width: 0.6,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: OTColors.sovereignAmber,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Disatukan dalam Hadis Jibril AS sebagai satu kesatuan rukun yang saling mengunci.",
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: OTColors.textSecondary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarTile({
    required String number,
    required String title,
    required String discipline,
    required String desc,
    required bool isDark,
    required bool isHighlight,
  }) {
    final surface = isDark ? const Color(0xFF1F1F23) : Colors.white;
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight
              ? OTColors.sovereignAmber.withValues(alpha: 0.6)
              : OTColors.border(isDark),
          width: isHighlight ? 1.2 : 0.8,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isHighlight
                  ? OTColors.sovereignAmberBg
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isHighlight ? OTColors.sovereignAmber : textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.newsreader(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isHighlight ? OTColors.sovereignAmber : textPrimary,
                        ),
                      ),
                    ),
                    if (isHighlight)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: OTColors.sovereignAmber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "RUKUN KE-4",
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  discipline,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textSecondary.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine(bool isDark) {
    return Center(
      child: Container(
        width: 1.2,
        height: 10,
        color: OTColors.border(isDark).withValues(alpha: 0.8),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FLOWCHART 2: 5 RANAH SUNANUL KHALAQ
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSunanulKhalaqFlowchart(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);

    const sunanItems = [
      _SunanItem(
        number: "1",
        title: "Sunan I'tiqadiyah",
        arabic: "سُنَنٌ اعْتِقَادِيَّةٌ",
        desc: "Pilar Keyakinan & Rukun Iman Azali",
      ),
      _SunanItem(
        number: "2",
        title: "Sunan 'Ilmiyyah",
        arabic: "سُنَنٌ عِلْمِيَّةٌ",
        desc: "Hukum Alam, Kosmologi & Sains Eksakta",
      ),
      _SunanItem(
        number: "3",
        title: "Sunan Sulukiyah",
        arabic: "سُنَنٌ سُلُوكِيَّةٌ",
        desc: "Hukum Etika, Moralitas & Relasi Manusia",
      ),
      _SunanItem(
        number: "4",
        title: "Sunan Diniyyah",
        arabic: "سُنَنٌ دِينِيَّةٌ",
        desc: "Syariat, Ibadah, Muamalah & Panduan Hidup",
      ),
      _SunanItem(
        number: "5",
        title: "Sunan at-Taghayyurat",
        arabic: "سُنَنُ التَّغَيُّرَاتِ",
        desc: "Siklus Transformasi Sejarah & Tanda Kiamat",
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_outlined, size: 16, color: OTColors.sovereignAmber),
              const SizedBox(width: 8),
              Text(
                "5 RANAH HUKUM SUNANUL KHALAQ",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: OTColors.sovereignAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: sunanItems.map((item) {
              final isTarget = item.number == "5";
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isTarget
                        ? OTColors.sovereignAmber.withValues(alpha: 0.6)
                        : borderColor,
                    width: isTarget ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isTarget
                            ? OTColors.sovereignAmberBg
                            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        item.number,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isTarget
                              ? OTColors.sovereignAmber
                              : OTColors.textSecondary(isDark),
                        ),
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
                                item.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isTarget
                                      ? OTColors.sovereignAmber
                                      : OTColors.textPrimary(isDark),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item.arabic,
                                style: GoogleFonts.amiri(
                                  fontSize: 13,
                                  color: OTColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item.desc,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: OTColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FLOWCHART 3: BENTENG AL-KHUWAISHAH (4 LAPIS PERLINDUNGAN)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildKhuwaishahFlowchart(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);

    const layers = [
      _KhuwaishahLayer(
        layer: "Lapis 1 (Inti)",
        title: "Khuwaishat an-Nafs",
        arabic: "خُوَيْصَةُ النَّفْسِ",
        desc: "Benteng jiwa pribadi: zikir, pembersihan hati, serta puasa dari kebisingan media & perdebatan.",
      ),
      _KhuwaishahLayer(
        layer: "Lapis 2",
        title: "Khuwaishat al-Usrah",
        arabic: "خُوَيْصَةُ الأُسْرَةِ",
        desc: "Benteng rumah tangga: surga sakinah, pendampingan gawai anak & ruang dialog hangat berakidah.",
      ),
      _KhuwaishahLayer(
        layer: "Lapis 3",
        title: "Khuwaishat al-Majalis",
        arabic: "خُوَيْصَةُ المَجَالِسِ",
        desc: "Benteng majelis & zawiyah: zona aman spiritual, adab talaqqi, dan transmisi sanad keilmuan.",
      ),
      _KhuwaishahLayer(
        layer: "Lapis 4",
        title: "Khuwaishat al-Wasail",
        arabic: "خُوَيْصَةُ الوَسَائِلِ",
        desc: "Benteng media digital: kuasai AI & medsos sebagai alat dakwah, tolak terseret arus perdebatan.",
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: OTColors.sovereignAmber),
              const SizedBox(width: 8),
              Text(
                "4 LAPIS BENTENG AL-KHUWAISHAH",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: OTColors.sovereignAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: layers.map((layer) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: OTColors.sovereignAmberBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            layer.layer,
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: OTColors.sovereignAmber,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${layer.title} (${layer.arabic})",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.newsreader(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: OTColors.textPrimary(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      layer.desc,
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: OTColors.textSecondary(isDark),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FLOWCHART 4: STRUKTUR KURIKULUM PUSTAKA (QAWA'ID & TATBIQAT)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCurriculumFlowchart(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);

    const qawaidBooks = [
      _BookLevel(
        level: "Tk. 1",
        title: "An-Nubzah ash-Shughra",
        arabic: "النُّبْذَةُ الصُّغْرَى",
        desc: "Kitab Saku Dasar & Pengenalan Istilah Kunci",
      ),
      _BookLevel(
        level: "Tk. 2",
        title: "Dawa'ir al-I'adah",
        arabic: "دَوَائِرُ الإِعَادَةِ",
        desc: "Kaidah Siklus Sejarah & Keterpaduan 4 Rukun",
      ),
      _BookLevel(
        level: "Tk. 3",
        title: "Al-Iqlid fi Fath Abwab",
        arabic: "الإِقْلِيدُ",
        desc: "Kunci Pengoperasian 5 Cabang Ilmu Turunan",
      ),
      _BookLevel(
        level: "Tk. 4",
        title: "At-Talid wat-Tharif",
        arabic: "التَّلِيدُ وَالطَّارِفُ",
        desc: "Syarah Sunnah al-Mawaqif & Manhaj as-Salamah",
      ),
      _BookLevel(
        level: "Tk. 5",
        title: "Al-Mukhtasar al-Habik",
        arabic: "المُخْتَصَرُ الحَبِيك",
        desc: "Ikhtisar Metodologis Terpadat & Peta Dakwah",
      ),
      _BookLevel(
        level: "Tk. 6",
        title: "Al-Usus wal-Muntalaqat",
        arabic: "الأُسُسُ وَالمُنْطَلَقَاتُ",
        desc: "Puncak Mahakarya Kaidah Induk Ensiklopedis",
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined, size: 16, color: OTColors.sovereignAmber),
              const SizedBox(width: 8),
              Text(
                "DUA KATEGORI BESAR PUSTAKA",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: OTColors.sovereignAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Kategori 1: Al-Qawa'id ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: OTColors.sovereignAmber.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: OTColors.sovereignAmber,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "KATEGORI I",
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Al-Qawa'id (القواعد) — 6 Kitab Pokok",
                        style: GoogleFonts.newsreader(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: OTColors.textPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Tangga berjenjang (tadarruj) penguasaan dalil syar'i, teori usul, dan aksioma metodologi:",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: OTColors.textSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: qawaidBooks.map((book) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              book.level,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: OTColors.sovereignAmber,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${book.title} (${book.arabic})",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: OTColors.textPrimary(isDark),
                                  ),
                                ),
                                Text(
                                  book.desc,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    color: OTColors.textSecondary(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Kategori 2: At-Tatbiqat ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black87,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "KATEGORI II",
                        style: GoogleFonts.outfit(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "At-Tatbiqat (التطبيقات) — Aplikasi & Sastra",
                        style: GoogleFonts.newsreader(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: OTColors.textPrimary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTatbiqatFeature(
                  icon: Icons.menu_book_rounded,
                  title: "50+ Kitab Studi Kasus & Terapan Lapangan",
                  desc:
                      "Analisis krisis politik Khulafa' Rasyidin s.d. era modern, biografi para imam mujaddid (Aimmatul Huda), serta manajemen dakwah damai.",
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildTatbiqatFeature(
                  icon: Icons.music_note_rounded,
                  title: "Ratusan Karya Syair & Qashidah (Diwan Sya'ir)",
                  desc:
                      "Sastra sufi bernilai tinggi perangkum intisari Fikih Tahawwulat dengan bahasa rasa ruhani (dzawq) dan keindahan rima.",
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTatbiqatFeature({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: OTColors.sovereignAmber),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: OTColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: OTColors.textSecondary(isDark),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FLOWCHART 5: 4 BILIK SUPER AI OPENTURATH
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFourAiRoomsFlowchart(BuildContext context, bool isDark) {
    final subAgents = widget.agent?.subAgents ?? const <SubAgentModel>[];

    const rooms = [
      _AiRoomItem(
        number: "01",
        name: "Al-Muhaqqiq",
        arabic: "المُحَقِّق",
        role: "Penjaga Matan & Ibarah",
        desc: "Verifikasi teks Arab asli, sanad, kutipan matan, serta rujukan jilid & nomor halaman kitab.",
        subAgentId: "fiqh_tahawwulat_muhaqqiq",
      ),
      _AiRoomItem(
        number: "02",
        name: "Al-Bayan",
        arabic: "البَيَان",
        role: "Pensyarah Konsep & Istilah",
        desc: "Mengurai istilah baru (mustalahat mubtakarah) ke bahasa yang mudah dicerna serta peta konsep.",
        subAgentId: "fiqh_tahawwulat_bayan",
      ),
      _AiRoomItem(
        number: "03",
        name: "Al-Mukhtabir",
        arabic: "المُخْتَبِر",
        role: "Penguji Nalar & Studi Kasus",
        desc: "Kuis pemahaman interaktif, studi kasus fitnah zaman, dan evaluasi pemikiran objektif.",
        subAgentId: "fiqh_tahawwulat_mukhtabir",
      ),
      _AiRoomItem(
        number: "04",
        name: "Al-Habib",
        arabic: "الحَبِيب",
        role: "Arsip Ceramah & Ruhani",
        desc: "Transkrip ribuan jam muhadharah lisan, tausiyah penyejuk batin, adab dakwah & sentuhan hati.",
        subAgentId: "fiqh_tahawwulat_habib",
      ),
      _AiRoomItem(
        number: "05",
        name: "Al-Khatib",
        arabic: "الخَطِيب",
        role: "Penyusun Materi Dakwah & Khutbah",
        desc: "Spesialis formulasi khutbah Jumat, materi tabligh tematik, panduan da'i di era fitnah, dan narasi dakwah bil hikmah.",
        subAgentId: "fiqh_tahawwulat_khatib",
      ),
    ];

    return Column(
      children: rooms.map((room) {
        final matchingSub = subAgents.firstWhere(
          (s) => s.id == room.subAgentId,
          orElse: () => SubAgentModel(
            id: room.subAgentId,
            name: room.name,
            nameArabic: room.arabic,
            description: room.desc,
            descriptionArabic: room.arabic,
            emoji: '📖',
            badge: room.role,
          ),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: OTColors.surfaceSubtle(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OTColors.border(isDark), width: 0.8),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: OTColors.sovereignAmberBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      room.number,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: OTColors.sovereignAmber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    room.name,
                    style: GoogleFonts.newsreader(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: OTColors.textPrimary(isDark),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "(${room.arabic})",
                    style: GoogleFonts.amiri(
                      fontSize: 14,
                      color: OTColors.textSecondary(isDark),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      room.role,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: OTColors.textSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                room.desc,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: OTColors.textSecondary(isDark),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: AppleInteractiveWrapper(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (widget.onSelectSubAgent != null) {
                      widget.onSelectSubAgent!(matchingSub);
                    }
                  },
                  pressedScale: 0.96,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Buka Bilik ${room.name}",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CLOSING CARD
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildClosingCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141416) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: OTColors.sovereignAmber.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_outlined, size: 16, color: OTColors.sovereignAmber),
              const SizedBox(width: 8),
              Text(
                "HARAPAN LUHUR & DOA PENUTUP",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: OTColors.sovereignAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Kehadiran teknologi Super AI di OpenTurath AI ini lahir murni sebagai Khadim Khazanah (pelayan ilmu), "
            "meruntuhkan dinding kesulitan istilah agar mutiara warisan kenabian ini dapat dipelajari dengan mudah, jernih, dan beradab.",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: OTColors.textSecondary(isDark),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Semoga setiap huruf ibarah yang dikaji menjadi amal jariyah yang pahalanya mengalir tanpa putus ke haribaan mualif: "
            "Al-Musnid Al-`Allāmah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur, para guru beliau, dan seluruh kaum Muslimin.",
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              color: OTColors.sovereignAmber,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ──
  Widget _buildSectionHeader(
    BuildContext context, {
    required String tag,
    required String title,
    required String arabic,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: OTColors.sovereignAmberBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tag,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: OTColors.sovereignAmber,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: OTColors.textPrimary(isDark),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          arabic,
          style: GoogleFonts.amiri(
            fontSize: 15,
            color: OTColors.textSecondary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyText(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: OTColors.textSecondary(isDark),
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context, {
    required String quote,
    required String source,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B1E) : const Color(0xFFF9F9F8),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: OTColors.sovereignAmber, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            quote,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: OTColors.textPrimary(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "— $source",
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: OTColors.textTertiary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
