import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design/ot_colors.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';

/// Item pembantu untuk data 6 Kitab Qawa'id
class _QawaidBook {
  final String level;
  final String title;
  final String arabic;
  final String desc;

  const _QawaidBook({
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
/// Menampilkan teks penjelasan mendalam, komparasi peradaban, serta flowchart minimalis & elegan
/// yang ramah layar sentuh (The Quiet Scholar design system - strictly monokrom minimalis).
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
    "Hakikat & Pondasi",
    "Dua Pilar & Nawāqid",
    "Manhaj Dakwah & Sikap",
    "Al-Khuwaishah",
    "Kurikulum Pustaka",
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
                        color: isDark
                            ? const Color(0xFF222228)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF383842)
                              : const Color(0xFFE4E4E7),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        "DISIPLIN ILMU",
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: textPrimary,
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
                            "Navigasi Kenabian & Benteng Akhir Zaman",
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
                // ════════════════════════════════════════════════════════
                // TAB 1: HAKIKAT & PONDASI
                // ════════════════════════════════════════════════════════
                if (_selectedTabIndex == 0 || _selectedTabIndex == 1) ...[
                  _buildSectionHeader(
                    context,
                    tag: "MUKADIMAH",
                    title: "Kebutuhan akan GPS Navigasi Kenabian",
                    arabic: "الحَاجَةُ إِلَى بَوْصَلَةِ النُّبُوَّةِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Di era modern hari ini, tatanan peradaban berguncang hebat: banjir informasi melampaui kejernihan hakikat (fujā'at al-aḥdāṡ), "
                    "sesama Muslim mudah diadu domba dan saling mengafirkan (at-taḥrīsy wat-takfīr), konten ramalan kiamat serampangan melahirkan kecemasan jiwa (apocalyptic anxiety), "
                    "dan kemajuan kecerdasan buatan (AI) melompati etika moral manusia.\n\n"
                    "Di tengah kabut tebal zaman ini, umat membutuhkan kompas nubuwwah agar tidak gamang membaca peristiwa dunia. "
                    "Untuk menjawab krisis peradaban inilah, ulama besar abad ini asal Hadhramaut, Al-Musnid Al-`Allāmah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur (1366–1444 H / 1947–2022 M), "
                    "mengkodifikasi disiplin ilmu mandiri: Fikih Tahawwulat (فِقْهُ التَّحَوُّلَاتِ).",
                    isDark,
                  ),
                  const SizedBox(height: 14),

                  _buildSectionHeader(
                    context,
                    tag: "BAB 01",
                    title: "Hakikat & Definisi Syariat",
                    arabic: "حَقِيقَةُ فِقْهِ التَّحَوُّلَاتِ وَمَفْهُومُهُ الشَّرْعِيُّ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Secara bahasa, Al-Fiqh bermakna pemahaman mendalam yang menembus hakikat batin, sedangkan At-Tahawwulat adalah bentuk jamak dari tahawwul (fase pergeseran atau transformasi peradaban manusia).\n\n"
                    "Adapun secara istilah syariat, Fikih Tahawwulat didefinisikan sebagai:",
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildQuoteCard(
                    context,
                    quote:
                        "«الفَهْمُ الشَّرْعِيُّ لِمَا يَقْضِي اللهُ وَيُدَبِّرُهُ فِي العَالَمِ الأَزَلِيِّ، وَمَا جَرَى وَيَجْرِي مِنْ سُنَنِ التَّغَيُّرَاتِ فِي الكَوْنِ، وَفِقْهُ عَلَامَاتِ السَّاعَةِ وَمَرَاحِلِ الفِتَنِ وَفِقْهِ الدَّعْوَةِ فِي كُلِّ مَرْحَلَةٍ»",
                    source: "Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur",
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildBodyText(
                    "Ilmu ini memutus kebuntuan Krisis Cara Berpikir (Al-Azmah Al-Manhajiyyah) yang terbelah ke dalam dua kutub ekstrem: "
                    "Kutub Tekstualis Kaku (memaksakan teks hukum klasik untuk menghakimi krisis sosial tanpa paham konteks) dan Kutub Liberalisme Liar (menundukkan syariat demi tren modern). "
                    "Fikih Tahawwulat menjaga pondasi syariat tetap murni tanpa kompromi, seraya membimbing pembacaan zaman dengan kompas kenabian.",
                    isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildSectionHeader(
                    context,
                    tag: "BAB 02",
                    title: "Pondasi Dalil: Rukun Keempat Agama",
                    arabic: "الرُّكْنُ الرَّابِعُ: عِلْمُ عَلَامَاتِ السَّاعَةِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Pondasi disiplin ilmu ini bersumber langsung dari Hadis Jibril AS dalam Sahih Muslim yang digelari Umm as-Sunnah (Induk Segala Sunnah). "
                    "Di hadapan Rasulullah ﷺ dan para sahabat, Malaikat Jibril AS menanyakan empat rukun yang disatukan oleh Nabi ﷺ dalam sabda pamungkas: «فَإِنَّهُ جِبْرِيلُ أَتَاكُمْ يُعَلِّمُكُمْ دِينَكُمْ» (\"Sesungguhnya dia adalah Jibril yang datang mengajarkan AGAMA KALIAN\").",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFourPillarsFlowchart(context, isDark),
                  const SizedBox(height: 24),
                ],

                // ════════════════════════════════════════════════════════
                // TAB 2: DUA PILAR KERUNTUHAN & PISAU BEDAH NAWAQID
                // ════════════════════════════════════════════════════════
                if (_selectedTabIndex == 0 || _selectedTabIndex == 2) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 03",
                    title: "Dua Pilar Keruntuhan Otoritas Peradaban",
                    arabic: "رُكْنَا عِلْمِ السَّاعَةِ: نَقْضُ قَرَارِ العِلْمِ وَالحُكْمِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Ketika Nabi ﷺ ditanya tentang tanda kiamat, beliau tidak menyebutkan fenomena acak, melainkan mengisyaratkan Dua Keruntuhan Otoritas Terbesar dalam sejarah manusia:",
                    isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildTwoPillarsCollapseCard(context, isDark),
                  const SizedBox(height: 20),

                  _buildSectionHeader(
                    context,
                    tag: "BAB 04",
                    title: "Pisau Bedah: An-Nawāqid & An-Naqā'id",
                    arabic: "النَّوَاِقضُ وَالنَّقَائِضُ: تَفْكِيكُ الغَزْوِ الفِكْرِيِّ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Bagaimana tatanan Islam dirusak dari dalam? Fikih Tahawwulat menyediakan instrumen forensik pemikiran:\n\n"
                    "1. An-Nawāqid (النَّوَاقِض - Pembatal / Proses Peruntuhan):\n"
                    "Proses sistematis meruntuhkan pilar Islam dari dalam. Contoh paling nyata di era digital adalah Naqd Manhaj at-Talaqqi (peruntuhan tradisi adab berguru). "
                    "Generasi muda digiring merasa cukup belajar dari potongan video medsos atau mesin pencari tanpa bersimpuh menyerap akhlak guru bersanad.\n\n"
                    "2. An-Naqā'id (النَّقَائِض - Ideologi Tandingan / Pengganti):\n"
                    "Setelah nilai Islam runtuh lewat Nawāqid, ruang kosong itu diisi dengan paham tandingan buatan manusia seperti Materialisme, Sekularisme ekstrem, Konsumerisme, dan Hedonisme.",
                    isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildSectionHeader(
                    context,
                    tag: "BAB 05",
                    title: "Menyikapi Teknologi & Kecerdasan Buatan (AI)",
                    arabic: "المُسْتَجَدَّاتُ التِّقَنِيَّةُ وَقَاعِدَةُ الِاغْتِنَامِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Fikih Tahawwulat menempatkan seluruh lompatan teknologi modern ke dalam kelompok Al-Mustajaddāt dengan dua kaidah emas:\n\n"
                    "• Naskah Mendahului Sejarah (Al-Naṣṣ Asbaq min al-Ḥadaṡ):\n"
                    "Ketika teknologi mampu memviralkan kebohongan atau deepfake ke seluruh bumi dalam sekejap, santri teringat sabda Nabi ﷺ mengenai tanda akhir zaman: Tablyghul Kidzbah ilal Afāq (tersiarnya kedustaan ke segenap penjuru dalam sekejap).\n\n"
                    "• Kaidah Merebut untuk Kebaikan (Al-Ightinām):\n"
                    "Teknologi digital dan AI bersifat netral. Kita dilarang kuper (menolak membabi buta) dan dilarang lugu (terseret arus tanpa filter syar'i). Kita diperintahkan merebut (al-ightinām) kecanggihan teknologi ini untuk khidmat menyiarkan khazanah turats dan dakwah yang damai.",
                    isDark,
                  ),
                  const SizedBox(height: 24),
                ],

                // ════════════════════════════════════════════════════════
                // TAB 3: MANHAJ DAKWAH & SIKAP
                // ════════════════════════════════════════════════════════
                if (_selectedTabIndex == 0 || _selectedTabIndex == 3) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 06",
                    title: "Transformasi Bahasa Dakwah Kenabian",
                    arabic: "لُغَةُ الطِّبِّ وَالإِنْقَاذِ بَدَلَ التَّكْفِيرِ وَالتَّحْرِيشِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Sumbangsih monumental Fikih Tahawwulat adalah revolusi paradigma dakwah dari penghakiman menjadi penyelamatan:",
                    isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildDakwahTransformationCard(context, isDark),
                  const SizedBox(height: 20),

                  _buildSectionHeader(
                    context,
                    tag: "BAB 07",
                    title: "Sunnah Mawāqif & Manhaj as-Salāmah",
                    arabic: "سُنَّةُ المَوَاقِفِ وَمَنْهَجُ السَّلَامَةِ النَّبَوِيَّةِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Selain Sunnah Dalālah (petunjuk arah syariat atas hal-hal baru), Fikih Tahawwulat menekankan Sunnah Mawāqif (teladan ketetapan sikap saat terjadi fitnah sosial dan politik).\n\n"
                    "Puncak prinsip keselamatan terangkum dalam kaidah agung:",
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildQuoteCard(
                    context,
                    quote:
                        "«سَالِمًا بِاللِّسَانِ مِنَ الذَّمِّ، وَسَالِمًا بِالأَرْكَانِ مِنَ الدَّمِّ»",
                    source:
                        "Selamat lisan dari mencela, selamat tangan dari menumpahkan darah",
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Sebagaimana teladan Sayyidina Hasan bin Ali r.a. yang rela menanggalkan kekhalifahan demi menyatukan darah kaum Muslimin, serta Sayyidina Ali Zainal Abidin r.a. yang fokus mendidik adab jiwa pasca-Tragedi Karbala.\n\n"
                    "Fikih Tahawwulat melarang keras Al-Ittijār bid-Dīn (menjual ayat, hadis, dan mimbar masjid untuk kepentingan panggung politik partisan).",
                    isDark,
                  ),
                  const SizedBox(height: 24),
                ],

                // ════════════════════════════════════════════════════════
                // TAB 4: AL-KHUWAISHAH & KETENANGAN JIWA
                // ════════════════════════════════════════════════════════
                if (_selectedTabIndex == 0 || _selectedTabIndex == 4) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 08",
                    title: "Konsep Masterpiece: Al-Khuwaiṣah (الـخُوَيْصَة)",
                    arabic: "مَنْظُومَةُ الخُوَيْصَةِ: حِصْنُ النَّجَاةِ فِي طُوفَانِ الفِتَنِ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Al-Khuwaiṣah (bentuk tashghīr penuh kasih dari Al-Khāṣṣah) bermakna lingkaran privat terdekat. "
                    "Secara istilah, Al-Khuwaishah adalah strategi taktis penyelamatan diri, keluarga, dan komunitas terbatas ketika ruang publik (Al-`Āmmah) dilanda badai fitnah yang tidak bisa diubah seketika.\n\n"
                    "Analogi Shelter Badai Topan:\n"
                    "Ketika kota diterjang badai dahsyat, orang bijak tidak berdiri di lapangan memarahi angin, melainkan masuk ke dalam shelter aman, mengunci pintu, dan memastikan keluarganya hangat dan cukup bekal.",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildKhuwaishahLayersCard(context, isDark),
                  const SizedBox(height: 20),

                  _buildSectionHeader(
                    context,
                    tag: "BAB 09",
                    title: "Mengatasi Kecemasan Akhir Zaman",
                    arabic: "عِلَاجُ القَلَقِ النَّفْسِيِّ وَالسَّكِينَةُ الإِيمَانِيَّةُ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Fikih Tahawwulat menyembuhkan Apocalyptic Anxiety (kecemasan akibat ramalan viral kiamat) dengan:\n"
                    "1. Mengharamkan cocokologi serampangan (al-isqāṭ al-mubāsyir) dan mewajibkan sikap sabar mengamati (al-intiẓār wat-tarakqub).\n"
                    "2. Menanamkan ketenangan batin (sakīnah) bahwa seluruh perputaran sejarah berada dalam garis takdir azali Allah.\n"
                    "3. Melawan sikap putus asa: Sebagaimana sabda Nabi ﷺ, jika kiamat tiba dan di tanganmu ada bibit kurma, tetaplah menanamnya!",
                    isDark,
                  ),
                  const SizedBox(height: 20),

                  _buildSectionHeader(
                    context,
                    tag: "BAB 10",
                    title: "Komparasi: Sebelum vs Sesudah",
                    arabic: "مُقَارَنَةٌ شَامِلَةٌ بَيْنَ حَالَتَيْنِ",
                  ),
                  const SizedBox(height: 14),
                  _buildComparisonTable(context, isDark),
                  const SizedBox(height: 24),
                ],

                // ════════════════════════════════════════════════════════
                // TAB 5: KURIKULUM PUSTAKA
                // ════════════════════════════════════════════════════════
                if (_selectedTabIndex == 0 || _selectedTabIndex == 5) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 11",
                    title: "Struktur Kurikulum: Al-Qawā'id & At-Taṭbīqāt",
                    arabic: "هَيْكَلُ الكُتُبِ: القَوَاعِدُ التَّأْصِيلِيَّةُ وَالتَّطْبِيقَاتُ العَمَلِيَّةُ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Khazanah karya tulis Fikih Tahawwulat oleh Al-Habib Abu Bakar Al-Adni terbagi rapi ke dalam dua kategori besar: "
                    "6 Kitab Kaidah Pokok Berjenjang (Al-Qawā'id) serta Lebih dari 50 Kitab Terapan Lapangan & Ratusan Dīwān Sya'ir (At-Taṭbīqāt).",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildCurriculumFlowchart(context, isDark),
                  const SizedBox(height: 24),
                ],

                // ════════════════════════════════════════════════════════
                // TAB 6: 5 BILIK SUPER AI
                // ════════════════════════════════════════════════════════
                if (_selectedTabIndex == 0 || _selectedTabIndex == 6) ...[
                  _buildSectionHeader(
                    context,
                    tag: "BAB 12",
                    title: "Arsitektur 5 Bilik Super AI OpenTurath",
                    arabic: "الغُرَفُ الخَمْسُ لِلذَّكَاءِ الاصْطِنَاعِيِّ التَّخَصُّصِيِّ",
                  ),
                  const SizedBox(height: 12),
                  _buildBodyText(
                    "Karena disiplin ini sarat dengan peristilahan baru (al-muṣṭalaḥāt al-mubtakarah) serta ribuan jam transkrip lisan mualif, "
                    "OpenTurath AI menghadirkan 5 Bilik AI Spesialis Terpadu dalam satu ruang kajian:",
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFiveAiRoomsList(context, isDark),
                  const SizedBox(height: 24),
                ],

                // ── Closing Card ──
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
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

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
              Icon(Icons.account_tree_outlined, size: 16, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                "INTEGRASI 4 RUKUN AGAMA (HADIS JIBRIL AS)",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildPillarTile(
            number: "01",
            title: "Al-Islām (الإِسْلَام)",
            discipline: "Fikih Hukum & Syariat (Aṡ-Ṡawābit)",
            desc: "Ibadah lahiriah, rukun fi'li, halal-haram & muamalah baku sepanjang masa.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "02",
            title: "Al-Īmān (الإِيمَان)",
            discipline: "Akidah & Tauhid (Aṡ-Ṡawābit)",
            desc: "Pondasi keyakinan pada Allah, malaikat, kitab, rasul & takdir azali.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "03",
            title: "Al-Iḥsān (الإِحْسَان)",
            discipline: "Tasawuf & Akhlak (Aṡ-Ṡawābit)",
            desc: "Penyucian jiwa (tazkiyatun nufūs), muraqabah hati & keluhuran adab batin.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "04",
            title: "Fikih Tahawwulat (فِقْهُ التَّحَوُّلَاتِ)",
            discipline: "Tanda Kiamat & Navigasi Zaman (Al-Mutaghayyirāt)",
            desc: "Peta kompas nubuwwah yang memandu agar Islam, Iman, dan Ihsan tidak tersapu badai fitnah akhir zaman.",
            isDark: isDark,
            isHighlight: true,
          ),

          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141418) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(Icons.hub_outlined, size: 15, color: textPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Disatukan oleh Nabi ﷺ dalam satu kalimat: «يُعَلِّمُكُمْ دِينَكُمْ» (\"Mengajarkan Agama Kalian\").",
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
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
    final borderColor = isHighlight
        ? (isDark ? const Color(0xFF4A4A58) : const Color(0xFFC4C4C8))
        : OTColors.border(isDark);
    final bgColor = isHighlight
        ? (isDark ? const Color(0xFF1F1F26) : const Color(0xFFF4F4F6))
        : (isDark ? const Color(0xFF16161A) : Colors.white);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: isHighlight ? 1.2 : 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282832) : const Color(0xFFE4E4E8),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.newsreader(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    if (isHighlight)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Peta Navigasi",
                          style: GoogleFonts.outfit(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  discipline,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: textSecondary,
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

  // ──────────────────────────────────────────────────────────────────────────
  // DUA PILAR KERUNTUHAN OTORITAS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTwoPillarsCollapseCard(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

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
              Icon(Icons.domain_disabled_rounded, size: 16, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                "DUA ISYARAT KENABIAN ATAS KERUNTUHAN OTORITAS",
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pilar 1
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16161A) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "«أَنْ تَلِدَ الأَمَةُ رَبَّتَهَا»",
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "1. Keruntuhan Otoritas Ilmu & Akidah (Naqḍ Qarār al-`Ilm wal-I'tiqād)",
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Runtuhnya tradisi talaqqi dan adab berguru. Anak menindas orang tua, murid tidak menghormati ulama bersanad, dan ilmu dicari murni demi keuntungan duniawi.",
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Pilar 2
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16161A) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "«أَنْ تَرَى الحُفَاةَ العُرَاةَ يَتَطَاوَلُونَ فِي البُنْيَانِ»",
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "2. Keruntuhan Otoritas Kepemimpinan & Ekonomi (Naqḍ Qarār al-Ḥukm wal-Iqtiṣād)",
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Tatanan kepemimpinan dunia jatuh ke tangan orang yang tidak amanah, ekonomi global dikuasai sistem ribawi, dan kemuliaan diukur murni dari kemegahan material.",
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: textSecondary,
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

  // ──────────────────────────────────────────────────────────────────────────
  // TRANSFORMASI BAHASA DAKWAH
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildDakwahTransformationCard(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

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
              Icon(Icons.healing_outlined, size: 16, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                "REVOLUSI PARADIGMA BAHASA DAKWAH",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lughatut-Takfīr",
                        style: GoogleFonts.newsreader(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Menghakimi & mencaci\n• Menganggap masyarakat lawan\n• Mudah mengafirkan",
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          color: textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 16, color: textSecondary),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E222A) : const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF384050) : const Color(0xFFD0DCE5),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lughatut-Ṭibb",
                        style: GoogleFonts.newsreader(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Dokter penolong beradab\n• Memandang umat pasien\n• Inqāḏ mā yumkinu inqāḏuh",
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          color: textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4 LAPIS AL-KHUWAISHAH
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildKhuwaishahLayersCard(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    const layers = [
      (
        layer: "Lapis 1",
        title: "Benteng Diri (Khuwaiṣat an-Nafs)",
        arabic: "خُوَيْصَةُ النَّفْسِ",
        desc: "Menjaga hati dari dengki, lisan dari mencela, dan tangan dari kekerasan. Menjalankan puasa dari kebisingan perdebatan media (shiyām 'an al-wasā'il)."
      ),
      (
        layer: "Lapis 2",
        title: "Benteng Keluarga (Khuwaiṣat al-Usrah)",
        arabic: "خُوَيْصَةُ الأُسْرَةِ وَالبَيْتِ",
        desc: "Menjadikan rumah sebagai shelter peradaban kecil. Mendampingi gawai anak, menanamkan akidah di meja makan keluarga, dan memupuk kehangatan cinta."
      ),
      (
        layer: "Lapis 3",
        title: "Benteng Majelis & Zawiyah",
        arabic: "خُوَيْصَةُ الأَتْبَاعِ وَالمَجَالِسِ",
        desc: "Mendirikan zawiyah, pesantren (ribath), dan majelis taklim sebagai Zona Aman Spiritual (Manāṭiq Āminah) bagi siapa saja yang lelah oleh fitnah dunia."
      ),
      (
        layer: "Lapis 4",
        title: "Benteng Gawai & Alat (Khuwaiṣat al-Wasā'il)",
        arabic: "خُوَيْصَةُ الوَسَائِلِ",
        desc: "Menggunakan gawai dan kecerdasan buatan secara produktif untuk riset ilmu dan syiar dakwah damai, bukan untuk terseret arus polemik di kolom komentar."
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
              Icon(Icons.shield_outlined, size: 16, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                "EMPAT LAPIS PERTAHANAN MIKRO AL-KHUWAISHAH",
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Column(
            children: layers.map((l) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16161A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.title,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          l.arabic,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 15,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l.desc,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: textSecondary,
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
  // TABEL KOMPARASI SEBELUM VS SESUDAH
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildComparisonTable(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    const rows = [
      (
        aspect: "Nalar Ilmiah",
        before: "Kaku memaksakan teks hukum ibadah tetap untuk menghakimi krisis sosial modern.",
        after: "Menjaga teks syariat tetap murni seraya luwes membaca pergeseran peradaban zaman."
      ),
      (
        aspect: "Teknologi & AI",
        before: "Terbelah ekstrem: menolak total sebagai bid'ah atau menelan mentah-mentah hingga hilang adab.",
        after: "Kaidah Al-Ightinām: merebut teknologi dan AI untuk khidmat ilmu turats secara selamat."
      ),
      (
        aspect: "Gaya Dakwah",
        before: "Suka memvonis dan mencaci; menganggap masyarakat sebagai lawan yang harus dihantam.",
        after: "Dokter penolong yang merangkul; menyelamatkan korban sistem zaman yang rusak."
      ),
      (
        aspect: "Fitnah Politik",
        before: "Fanatik buta golongan dan mengeksploitasi ayat agama untuk politik praktis.",
        after: "Manhaj as-Salāmah: lisan bersih dari mencela, tangan bersih dari menumpahkan darah."
      ),
      (
        aspect: "Keluarga",
        before: "Sibuk berdebat di medsos hingga anak-istri di rumah terbengkalai.",
        after: "Al-Khuwaiṣah: membentengi rumah tangga dan majelis sebagai shelter rohani yang kokoh."
      ),
      (
        aspect: "Kondisi Batin",
        before: "Gampang panik dan stres (apocalyptic anxiety) akibat dicekoki ramalan kiamat viral.",
        after: "Hati tenang (sakīnah); yakin sejarah dalam takdir Allah dan optimis giat beramal shalih."
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows_rounded, size: 16, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                "KOMPARASI PERSPEKTIF KEHIDUPAN",
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Column(
            children: rows.map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16161A) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 0.7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.aspect,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("❌ ", style: TextStyle(fontSize: 10)),
                        Expanded(
                          child: Text(
                            r.before,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✓ ",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textPrimary)),
                        Expanded(
                          child: Text(
                            r.after,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
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
  // FLOWCHART 4: KURIKULUM 6 KITAB QAWAID & 50+ KITAB TATBIQAT
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCurriculumFlowchart(BuildContext context, bool isDark) {
    final borderColor = OTColors.border(isDark);
    final cardBg = OTColors.surfaceSubtle(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    const qawaidBooks = [
      _QawaidBook(
        level: "Tingkat 1 (Pemula)",
        title: "An-Nubżah aṣ-Ṣughrā",
        arabic: "النُّبْذَةُ الصُّغْرَى",
        desc: "Pintu gerbang pengenalan definisi, dalil Hadis Jibril, dan klasifikasi tanda kiamat.",
      ),
      _QawaidBook(
        level: "Tingkat 2 (Siklus Sejarah)",
        title: "Dawā'ir al-I'ādah",
        arabic: "دَوَائِرُ الإِعَادَةِ",
        desc: "Kaidah siklus pengulangan sejarah peradaban dalam lingkaran takdir azali.",
      ),
      _QawaidBook(
        level: "Tingkat 3 (Kunci Cabang)",
        title: "Al-Iqlīd",
        arabic: "الإِقْلِيدُ فِي فَتْحِ أَبْوَابِ العُلُومِ",
        desc: "Kaidah pengoperasian 5 cabang ilmu turunan Fikih Tahawwulat & antisipasi krisis.",
      ),
      _QawaidBook(
        level: "Tingkat 4 (Sikap Kenabian)",
        title: "At-Talīd wat-Ṭarīf",
        arabic: "التَّلِيدُ وَالطَّارِفُ",
        desc: "Syarah atas kaidah Sunnah al-Mawāqif dan Manhaj as-Salāmah para salafus shalih.",
      ),
      _QawaidBook(
        level: "Tingkat 5 (Ikhtisar Padat)",
        title: "Al-Mukhtaṣar al-Ḥabīk / Siyāḥatul Fikr",
        arabic: "المُخْتَصَرُ الحَبِيك",
        desc: "Peta konsep dakwah terpadat, kaidah gerakan, dan nalar kritis terhadap ideologi modern.",
      ),
      _QawaidBook(
        level: "Tingkat 6 (Puncak Induk)",
        title: "Al-Usūs wal-Munṭalaqāt",
        arabic: "الأُسُسُ وَالمُنْطَلَقَاتُ",
        desc: "Kitab ensiklopedis babon setebal ratusan halaman; rujukan tertinggi kaidah istinbath.",
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
              Icon(Icons.school_outlined, size: 16, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                "DUA KATEGORI KURIKULUM PUSTAKA",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kategori 1: Al-Qawa'id
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16161A) : Colors.white,
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
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black87,
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
                        "Al-Qawā'id (القواعد) — 6 Kitab Kaidah Pokok",
                        style: GoogleFonts.newsreader(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Column(
                  children: qawaidBooks.map((book) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F1F24)
                            : const Color(0xFFF7F7F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.black12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              book.level,
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
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
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  book.desc,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    color: textSecondary,
                                    height: 1.3,
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

          // Kategori 2: At-Tatbiqat
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16161A) : Colors.white,
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
                          horizontal: 7, vertical: 3),
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
                        "At-Taṭbīqāt (التطبيقات) — Terapan & Sastra",
                        style: GoogleFonts.newsreader(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
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
                      "Analisis krisis politik umat, biografi para imam mujaddid penyejuk zaman (Aimmatul Hudā), manajemen dakwah damai di era buih, dan risalah praktis pembinaan keluarga.",
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildTatbiqatFeature(
                  icon: Icons.music_note_rounded,
                  title: "Ratusan Karya Syair & Qashīdah (Dīwān Sya'ir)",
                  desc:
                      "Sastra sufi perangkum intisari Fikih Tahawwulat dengan bahasa rasa ruhani (aż-żawq). Meneteskan air mata keinsyafan, adab, dan kerinduan kenabian.",
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
        Icon(icon, size: 16, color: OTColors.textPrimary(isDark)),
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
  // FLOWCHART 5: 5 BILIK SUPER AI OPENTURATH
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFiveAiRoomsList(BuildContext context, bool isDark) {
    final subAgents = widget.agent?.subAgents ?? const <SubAgentModel>[];

    const rooms = [
      _AiRoomItem(
        number: "01",
        name: "Al-Muhaqqiq",
        arabic: "المُحَقِّق",
        role: "Penjaga Teks Matan & Ibarah",
        desc: "Verifikasi redaksi Arab asli mualif, mencocokkan kutipan matan, serta rujukan presisi ke nama kitab, jilid, dan nomor halaman.",
        subAgentId: "fiqh_tahawwulat_muhaqqiq",
      ),
      _AiRoomItem(
        number: "02",
        name: "Al-Bayan",
        arabic: "البَيَان",
        role: "Pensyarah Konsep & Istilah Baru",
        desc: "Mengurai istilah rumit (mustalahat mubtakarah) ke bahasa yang mudah dicerna pemula, analogi modern, serta peta pemikiran komprehensif.",
        subAgentId: "fiqh_tahawwulat_bayan",
      ),
      _AiRoomItem(
        number: "03",
        name: "Al-Mukhtabir",
        arabic: "المُخْتَبِر",
        role: "Ujian Nalar & Kaji Kasus Interaktif",
        desc: "Mitra diskusi dan penguji pemahaman ilmiah; menyajikan studi kasus fitnah zaman untuk memastikan nalar tetap lurus dan bebas dari cocokologi.",
        subAgentId: "fiqh_tahawwulat_mukhtabir",
      ),
      _AiRoomItem(
        number: "04",
        name: "Al-Habib",
        arabic: "الحَبِيب",
        role: "Arsip Muhadharah & Sentuhan Ruhani",
        desc: "Menghadirkan kehangatan nada lisan dari ribuan jam rekaman ceramah mualif, tausiyah penyejuk batin, serta bimbingan adab tazkiyatun nufus.",
        subAgentId: "fiqh_tahawwulat_habib",
      ),
      _AiRoomItem(
        number: "05",
        name: "Al-Khatib",
        arabic: "الخَطِيب",
        role: "Penyusun Materi Khutbah & Dakwah",
        desc: "Formulasi materi khutbah Jumat, panduan dakwah di era krisis, materi tabligh tematik, serta narasi penyejuk umat di tengah polarisasi.",
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
                      color: isDark ? const Color(0xFF282832) : const Color(0xFFE4E4E8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      room.number,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: OTColors.textPrimary(isDark),
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
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 15,
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
    final borderColor = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141416) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa_outlined, size: 16, color: textPrimary),
              const SizedBox(width: 8),
              Text(
                "HARAPAN LUHUR & DOA PENUTUP",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Kehadiran teknologi Super AI di OpenTurath AI ini lahir murni sebagai Khadim Khazanah (pelayan ilmu), "
            "meruntuhkan dinding kesulitan istilah dan kendala akses agar mutiara warisan kenabian ini dapat dipelajari dengan mudah, jernih, dan beradab.",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Semoga setiap huruf ibarah yang dikaji menjadi amal jariyah yang pahalanya mengalir tanpa putus ke haribaan mualif: "
            "Al-Musnid Al-`Allāmah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur, para guru beliau, dan seluruh kaum Muslimin hingga hari Kiamat. Āmīn.",
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              color: textPrimary,
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
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark ? const Color(0xFF383842) : const Color(0xFFE4E4E7),
              width: 0.7,
            ),
          ),
          child: Text(
            tag,
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          arabic,
          style: GoogleFonts.scheherazadeNew(
            fontSize: 16,
            color: textSecondary,
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
    final textPrimary = OTColors.textPrimary(isDark);
    final textTertiary = OTColors.textTertiary(isDark);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B1E) : const Color(0xFFF9F9F8),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: textPrimary, width: 2.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            quote,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.7,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "— $source",
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine(bool isDark) {
    return Center(
      child: Container(
        width: 1.5,
        height: 12,
        color: OTColors.border(isDark).withValues(alpha: 0.7),
      ),
    );
  }
}
