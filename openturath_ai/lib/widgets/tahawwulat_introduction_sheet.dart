import '../core/localization.dart';
import '../core/design/ot_expressive.dart';
import '../widgets/adaptive_sheet.dart';
import 'package:flutter/material.dart';

import '../core/app_platform.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'apple_interactive_wrapper.dart';
import 'tahawwulat_diagram.dart';
import 'tahawwulat_hero.dart';
import '../core/scholarly_fonts.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';
import 'ot_components.dart';

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

  /// Halaman baca penuh (desktop): daftar isi di sisi, kolom baca 680.
  final bool asPage;

  /// Bagian yang dibuka pertama; 0 menampilkan semuanya.
  final int initialSection;

  const TahawwulatIntroductionSheet({
    super.key,
    this.agent,
    this.onSelectSubAgent,
    this.onOpenMain,
    this.asPage = true,
    this.initialSection = 0,
  });

  /// Desktop: halaman baca penuh. Ponsel: lembar bawah.
  static Future<void> show(
    BuildContext context, {
    AgentModel? agent,
    void Function(SubAgentModel subAgent)? onSelectSubAgent,
    VoidCallback? onOpenMain,
  }) {
    if (AppPlatform.isDesktop) {
      return Navigator.of(context).push<void>(PageRouteBuilder<void>(
        transitionDuration: OTMotion.normal,
        reverseTransitionDuration: OTMotion.fast,
        pageBuilder: (ctx, _, __) => TahawwulatIntroductionSheet(
          agent: agent,
          onSelectSubAgent: onSelectSubAgent,
          onOpenMain: onOpenMain,
          asPage: true,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: OTMotion.curve),
          child: child,
        ),
      ));
    }
    return showAdaptiveSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) => TahawwulatIntroductionSheet(
        agent: agent,
        onSelectSubAgent: onSelectSubAgent,
        onOpenMain: onOpenMain,
        asPage: true,
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

  /// Bab pada halaman majalah: (label, judul) berurutan, dan jangkar gulirnya.
  final List<(String, String)> _chapters = [];
  final Map<String, GlobalKey> _chapterKeys = {};
  late int _selectedTabIndex =
      widget.asPage ? 0 : widget.initialSection.clamp(0, _tabs.length - 1);

  static const List<String> _tabs = [
    "Semua",
    "Pengertian & dalil",
    "Dua keruntuhan",
    "Dakwah & sikap",
    "Al-Khuwaishah",
    "Susunan kitab",
    "Lima asisten",
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

    final page = widget.asPage;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mengenal Fikih Tahawwulat",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ScholarlyFonts.newsreader(
            fontSize: page ? OTFontSize.s22 : OTFontSize.s18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Ilmu membaca perubahan zaman dengan petunjuk Nabi ﷺ",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ScholarlyFonts.outfit(
            fontSize: page ? OTFontSize.s14 : OTFontSize.s12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
        ),
      ],
    );

    void select(int idx) {
      setState(() => _selectedTabIndex = idx);
      _scrollToTop();
    }

    // Ponsel dan jendela sempit: bagian sebagai baris chip.
    final chips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(_tabs.length, (idx) {
          final isSelected = _selectedTabIndex == idx;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: OTChip(
              label: _tabs[idx],
              selected: isSelected,
              onSelected: () => select(idx),
            ),
          );
        }),
      ),
    );

    final reader = LayoutBuilder(
      builder: (context, box) {
        final gutter = page
            ? ((box.maxWidth - 680) / 2).clamp(24.0, double.infinity)
            : 20.0;
        return ListView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(gutter, page ? 8 : 4, gutter, 56),
          children: _sections(context, isDark),
        );
      },
    );

    if (page) {
      // Halaman majalah: sampul, daftar isi bernomor, lalu bab demi bab
      // dalam satu gulungan. Tanpa panel samping.
      _chapters.clear();
      final sections = _sections(context, isDark);
      final viewport = MediaQuery.sizeOf(context);
      final roomy = viewport.width >= 760;
      const onCover = OTColors.onInverseSurface;

      final cover = Padding(
          padding:
              EdgeInsets.fromLTRB(roomy ? 32 : 16, 64, roomy ? 32 : 16, 24),
          child: Container(
            padding: EdgeInsets.all(roomy ? 32 : 24),
            decoration: BoxDecoration(
                color: OTExpressive.hero,
                borderRadius: BorderRadius.circular(roomy
                    ? OTExpressive.heroRadius
                    : OTExpressive.compactHeroRadius)),
            child: LayoutBuilder(builder: (context, box) {
              final heading = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        reviewCopy('Mengenal Fikih Tahawwulat',
                            'تعرّف على فقه التحولات', 'About Fiqh Tahawwulat'),
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s36,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            color: onCover)),
                    const SizedBox(height: 20),
                    Text(
                        reviewCopy(
                            'Ilmu membaca perubahan zaman dengan petunjuk Nabi ﷺ, disusun Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.',
                            'علم قراءة تحولات الزمان بهدي النبي ﷺ، للإمام الحبيب أبي بكر العدني بن علي المشهور.',
                            'Reading changing times through Prophetic guidance, by Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.'),
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s16,
                            height: 1.6,
                            color: OTExpressive.whiteMuted)),
                    const SizedBox(height: 24),
                    FilledButton(
                        onPressed: () {
                          final target = _chapters.isEmpty
                              ? null
                              : _chapterKeys[_chapters.first.$1]
                                  ?.currentContext;
                          if (target != null) {
                            Scrollable.ensureVisible(target,
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : OTMotion.transition);
                          }
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: OTExpressive.white,
                            foregroundColor: OTExpressive.black),
                        child: Text(reviewCopy(
                            'Mulai membaca', 'ابدأ القراءة', 'Start reading'))),
                  ]);
              if (box.maxWidth >= 720 &&
                  MediaQuery.textScalerOf(context).scale(16) <= 24) {
                return Row(children: [
                  Expanded(flex: 3, child: heading),
                  const SizedBox(width: 32),
                  const Expanded(
                      flex: 2, child: TahawwulatDiagram(inverse: true))
                ]);
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heading,
                    const SizedBox(height: 20),
                    const Center(
                        child: SizedBox(
                            width: 260,
                            child: TahawwulatDiagram(inverse: true)))
                  ]);
            }),
          ));

      Widget contentsEntry(int index) {
        final chapter = _chapters[index];
        return InkWell(
          onTap: () {
            final target = _chapterKeys[chapter.$1]?.currentContext;
            if (target == null) return;
            Scrollable.ensureVisible(
              target,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 420),
              curve: OTMotion.curve,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: ScholarlyFonts.newsreader(
                        fontSize: OTFontSize.s18, color: textTertiary),
                  ),
                ),
                Expanded(
                  child: Text(
                    chapter.$2,
                    style: ScholarlyFonts.newsreader(
                      fontSize: OTFontSize.s18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                      height: 1.25,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final half = (_chapters.length / 2).ceil();
      Widget contentsColumn(int from, int to) => Column(
            children: [
              for (var i = from; i < to; i++) ...[
                contentsEntry(i),
                Divider(height: 1, color: borderColor),
              ],
            ],
          );

      return Scaffold(
        backgroundColor: surfaceColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cover,
                  Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(children: [
                                const TahawwulatDiagram(interactive: true),
                                const SizedBox(height: 16),
                                Text(
                                    reviewCopy(
                                        'Diagram editorial dari kerangka pembahasan Fikih Tahawwulat Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.',
                                        'رسم توضيحي لإطار فقه التحولات عند الحبيب أبي بكر العدني بن علي المشهور.',
                                        'Editorial diagram of the Fiqh Tahawwulat framework of Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.'),
                                    textAlign: TextAlign.center,
                                    style: OTTypography.caption(
                                        color: textSecondary)),
                              ])))),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            roomy ? 64 : 24, 56, roomy ? 64 : 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daftar isi",
                              style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
                                  color: textTertiary),
                            ),
                            const SizedBox(height: 10),
                            Divider(height: 1, color: borderColor),
                            if (roomy)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: contentsColumn(0, half)),
                                  const SizedBox(width: 48),
                                  Expanded(
                                      child: contentsColumn(
                                          half, _chapters.length)),
                                ],
                              )
                            else
                              contentsColumn(0, _chapters.length),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 728),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: sections,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Garis kemajuan baca di tepi atas.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, _) {
                  final position = _scrollController.hasClients &&
                          _scrollController.position.hasContentDimensions
                      ? _scrollController.position
                      : null;
                  final progress =
                      position == null || position.maxScrollExtent <= 0
                          ? 0.0
                          : (position.pixels / position.maxScrollExtent)
                              .clamp(0.0, 1.0);
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(height: 2, color: textPrimary),
                    ),
                  );
                },
              ),
            ),
            // Tombol kembali mengambang di atas sampul.
            PositionedDirectional(
              top: 16,
              start: 16,
              child: SafeArea(
                child: Material(
                  color: surfaceColor,
                  shape: CircleBorder(side: BorderSide(color: borderColor)),
                  child: IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    icon: Icon(Icons.arrow_back_rounded,
                        size: 20, color: textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(OTRadius.sheet)),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 12, 8),
            child: Column(
              children: [
                const Center(child: SheetGrabber()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: title),
                    IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                      icon: Icon(Icons.close_rounded,
                          size: 20, color: textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          chips,
          Divider(height: 1, thickness: 1, color: borderColor),
          Expanded(child: reader),
        ],
      ),
    );
  }

  /// Isi naskah sesuai bagian yang dipilih.
  List<Widget> _sections(BuildContext context, bool isDark) {
    return [
      // ════════════════════════════════════════════════════════
      // TAB 1: HAKIKAT & PONDASI
      // ════════════════════════════════════════════════════════
      if (_selectedTabIndex == 0 || _selectedTabIndex == 1) ...[
        _buildSectionHeader(
          context,
          tag: "Mukadimah",
          title: "Mengapa ilmu ini diperlukan",
          arabic: "الحَاجَةُ إِلَى بَوْصَلَةِ النُّبُوَّةِ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Arus informasi hari ini lebih cepat daripada kemampuan orang memahaminya. Sesama muslim mudah diadu domba dan saling mengafirkan (at-taḥrīsy wat-takfīr), ramalan kiamat yang beredar sembarangan menimbulkan kecemasan, dan teknologi baru seperti kecerdasan buatan berkembang lebih cepat daripada adab memakainya.\n\nUntuk membaca keadaan seperti ini, umat memerlukan petunjuk dari sunnah. Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur (1366–1444 H / 1947–2022 M), ulama Hadhramaut, menyusunnya menjadi satu disiplin ilmu tersendiri: Fikih Tahawwulat (فِقْهُ التَّحَوُّلَاتِ).",
          isDark,
        ),
        const SizedBox(height: 14),
        _buildSectionHeader(
          context,
          tag: "Bab 1",
          title: "Pengertian",
          arabic: "حَقِيقَةُ فِقْهِ التَّحَوُّلَاتِ وَمَفْهُومُهُ الشَّرْعِيُّ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Secara bahasa, al-fiqh berarti pemahaman yang mendalam, sedangkan at-tahawwulat adalah bentuk jamak dari tahawwul: perubahan atau peralihan keadaan.\n\nSecara istilah, Fikih Tahawwulat didefinisikan sebagai:",
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
          "Ilmu ini menjawab dua cara berpikir yang sama-sama keliru (al-azmah al-manhajiyyah). Yang pertama memaksakan teks hukum klasik untuk menghakimi persoalan sosial tanpa memahami konteksnya. Yang kedua menundukkan syariat pada tren zaman. Fikih Tahawwulat menjaga syariat tetap utuh sambil menuntun cara membaca perubahan zaman dengan petunjuk Nabi ﷺ.",
          isDark,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader(
          context,
          tag: "Bab 2",
          title: "Dasar dalil: rukun keempat agama",
          arabic: "الرُّكْنُ الرَّابِعُ: عِلْمُ عَلَامَاتِ السَّاعَةِ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Dasar ilmu ini adalah Hadis Jibril dalam Sahih Muslim, yang dijuluki Umm as-Sunnah (induk sunnah). Di hadapan Rasulullah ﷺ dan para sahabat, Jibril menanyakan empat perkara, lalu Nabi ﷺ menutupnya dengan sabda: «فَإِنَّهُ جِبْرِيلُ أَتَاكُمْ يُعَلِّمُكُمْ دِينَكُمْ» (\"Dia adalah Jibril, datang untuk mengajarkan agama kalian\").",
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
          tag: "Bab 3",
          title: "Dua keruntuhan otoritas",
          arabic:
              "رُكْنَا عِلْمِ السَّاعَةِ: نَقْضُ قَرَارِ العِلْمِ وَالحُكْمِ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Ketika ditanya tentang tanda kiamat, Nabi ﷺ menyebut dua hal yang menunjukkan runtuhnya dua otoritas:",
          isDark,
        ),
        const SizedBox(height: 14),
        _buildTwoPillarsCollapseCard(context, isDark),
        const SizedBox(height: 20),
        _buildSectionHeader(
          context,
          tag: "Bab 4",
          title: "An-Nawāqid dan An-Naqā'id",
          arabic: "النَّوَاِقضُ وَالنَّقَائِضُ: تَفْكِيكُ الغَزْوِ الفِكْرِيِّ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Bagaimana tatanan Islam dirusak dari dalam? Fikih Tahawwulat menjelaskannya dengan dua istilah:\n\n1. An-Nawāqid (النَّوَاقِض), pembatal:\nProses yang meruntuhkan pilar Islam dari dalam. Contoh yang dekat dengan kita adalah naqd manhaj at-talaqqi, runtuhnya tradisi berguru: orang merasa cukup belajar dari potongan video atau mesin pencari, tanpa duduk di hadapan guru yang bersanad.\n\n2. An-Naqā'id (النَّقَائِض), tandingan:\nSetelah nilai Islam runtuh, tempatnya diisi paham buatan manusia seperti materialisme, sekularisme ekstrem, konsumerisme, dan hedonisme.",
          isDark,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader(
          context,
          tag: "Bab 5",
          title: "Menyikapi teknologi dan AI",
          arabic: "المُسْتَجَدَّاتُ التِّقَنِيَّةُ وَقَاعِدَةُ الِاغْتِنَامِ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Fikih Tahawwulat memasukkan teknologi modern ke dalam kelompok al-mustajaddāt (hal-hal baru), dengan dua kaidah:\n\n• Nas mendahului peristiwa (an-naṣṣ asbaq min al-ḥadaṡ):\nKetika kebohongan atau deepfake dapat tersebar ke seluruh dunia dalam sekejap, kita teringat sabda Nabi ﷺ tentang tanda akhir zaman: Tablyghul Kidzbah ilal Afāq (tersebarnya dusta ke segala penjuru).\n\n• Memanfaatkan untuk kebaikan (al-ightinām):\nTeknologi digital dan AI bersifat netral. Kita tidak menolaknya secara membabi buta, dan tidak pula hanyut tanpa saringan syariat. Kita memanfaatkannya untuk melayani ilmu turats dan dakwah yang damai.",
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
          tag: "Bab 6",
          title: "Dakwah: dari menghakimi ke menyelamatkan",
          arabic:
              "لُغَةُ الطِّبِّ وَالإِنْقَاذِ بَدَلَ التَّكْفِيرِ وَالتَّحْرِيشِ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Fikih Tahawwulat mengubah cara berdakwah: dari menghakimi menjadi menyelamatkan.",
          isDark,
        ),
        const SizedBox(height: 14),
        _buildDakwahTransformationCard(context, isDark),
        const SizedBox(height: 20),
        _buildSectionHeader(
          context,
          tag: "Bab 7",
          title: "Sunnah Mawāqif & Manhaj as-Salāmah",
          arabic: "سُنَّةُ المَوَاقِفِ وَمَنْهَجُ السَّلَامَةِ النَّبَوِيَّةِ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Selain sunnah dalālah (petunjuk syariat atas hal-hal baru), Fikih Tahawwulat menekankan sunnah mawāqif: teladan sikap ketika terjadi fitnah sosial dan politik.\n\nPrinsip keselamatannya terangkum dalam kaidah berikut:",
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
          "Teladannya adalah Sayyidina Hasan bin Ali r.a., yang melepaskan kekhalifahan demi mencegah pertumpahan darah kaum muslimin, dan Sayyidina Ali Zainal Abidin r.a., yang memusatkan diri pada pendidikan jiwa setelah tragedi Karbala.\n\nFikih Tahawwulat melarang al-ittijār bid-dīn: memperdagangkan ayat, hadis, dan mimbar untuk kepentingan politik partisan.",
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
          tag: "Bab 8",
          title: "Al-Khuwaiṣah (الـخُوَيْصَة)",
          arabic:
              "مَنْظُومَةُ الخُوَيْصَةِ: حِصْنُ النَّجَاةِ فِي طُوفَانِ الفِتَنِ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Al-Khuwaiṣah adalah bentuk tashghīr dari al-khāṣṣah, artinya lingkaran terdekat. Sebagai istilah, ia berarti langkah menyelamatkan diri, keluarga, dan komunitas kecil ketika ruang publik (al-`āmmah) dilanda fitnah yang tidak dapat diubah seketika.\n\nPerumpamaannya:\nKetika badai datang, orang yang bijak tidak berdiri di lapangan memarahi angin. Ia masuk ke tempat berlindung, menutup pintu, dan memastikan keluarganya aman dan berbekal cukup.",
          isDark,
        ),
        const SizedBox(height: 16),
        _buildKhuwaishahLayersCard(context, isDark),
        const SizedBox(height: 20),
        _buildSectionHeader(
          context,
          tag: "Bab 9",
          title: "Meredakan kecemasan akhir zaman",
          arabic:
              "عِلَاجُ القَلَقِ النَّفْسِيِّ وَالسَّكِينَةُ الإِيمَانِيَّةُ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Fikih Tahawwulat meredakan kecemasan akibat ramalan kiamat yang beredar dengan tiga cara:\n1. Melarang mencocok-cocokkan peristiwa dengan nas secara sembarangan (al-isqāṭ al-mubāsyir) dan mengajarkan sikap sabar mengamati (al-intiẓār wat-tarakqub).\n2. Menanamkan ketenangan (sakīnah): seluruh perjalanan sejarah berada dalam takdir Allah.\n3. Menolak putus asa: Nabi ﷺ bersabda, jika kiamat tiba sedangkan di tanganmu ada bibit kurma, tanamlah.",
          isDark,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader(
          context,
          tag: "Bab 10",
          title: "Perbandingan cara pandang",
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
          tag: "Bab 11",
          title: "Susunan kitab: Al-Qawā'id dan At-Taṭbīqāt",
          arabic:
              "هَيْكَلُ الكُتُبِ: القَوَاعِدُ التَّأْصِيلِيَّةُ وَالتَّطْبِيقَاتُ العَمَلِيَّةُ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Karya tulis Al-Habib Abu Bakar Al-Adni tentang Fikih Tahawwulat terbagi dua: enam kitab kaidah pokok yang berjenjang (al-qawā'id), serta lebih dari 50 kitab terapan dan ratusan dīwān syair (at-taṭbīqāt).",
          isDark,
        ),
        const SizedBox(height: 16),
        _buildCurriculumFlowchart(context, isDark),
        const SizedBox(height: 24),
      ],

      // ════════════════════════════════════════════════════════
      // TAB 6: 5 ASISTEN SPESIALIS
      // ════════════════════════════════════════════════════════
      if (_selectedTabIndex == 0 || _selectedTabIndex == 6) ...[
        _buildSectionHeader(
          context,
          tag: "Bab 12",
          title: "Lima asisten OpenTurath",
          arabic:
              "الغُرَفُ الخَمْسُ لِلذَّكَاءِ الاصْطِنَاعِيِّ التَّخَصُّصِيِّ",
        ),
        const SizedBox(height: 12),
        _buildBodyText(
          "Disiplin ini memiliki banyak istilah baru (al-muṣṭalaḥāt al-mubtakarah) dan ribuan jam rekaman ceramah penyusunnya. Karena itu OpenTurath menyediakan lima asisten dalam satu ruang kajian:",
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFiveAiRoomsList(context, isDark),
        const SizedBox(height: 24),
      ],

      // ── Closing Card ──
      _buildClosingCard(context, isDark),
    ];
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
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Empat rukun agama dalam Hadis Jibril",
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
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
            desc:
                "Ibadah lahiriah, rukun fi'li, halal-haram & muamalah baku sepanjang masa.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "02",
            title: "Al-Īmān (الإِيمَان)",
            discipline: "Akidah & Tauhid (Aṡ-Ṡawābit)",
            desc:
                "Pondasi keyakinan pada Allah, malaikat, kitab, rasul & takdir azali.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "03",
            title: "Al-Iḥsān (الإِحْسَان)",
            discipline: "Tasawuf & Akhlak (Aṡ-Ṡawābit)",
            desc:
                "Penyucian jiwa (tazkiyatun nufūs), muraqabah hati & keluhuran adab batin.",
            isDark: isDark,
            isHighlight: false,
          ),
          _buildConnectorLine(isDark),
          _buildPillarTile(
            number: "04",
            title: "Fikih Tahawwulat (فِقْهُ التَّحَوُّلَاتِ)",
            discipline: "Tanda Kiamat & Navigasi Zaman (Al-Mutaghayyirāt)",
            desc:
                "Petunjuk membaca zaman, agar Islam, Iman, dan Ihsan tetap terjaga di tengah fitnah akhir zaman.",
            isDark: isDark,
            isHighlight: true,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
              borderRadius: BorderRadius.circular(OTRadius.xs),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Row(
              children: [
                Icon(Icons.hub_outlined, size: 15, color: textPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Disatukan oleh Nabi ﷺ dalam satu kalimat: «يُعَلِّمُكُمْ دِينَكُمْ» (\"Mengajarkan Agama Kalian\").",
                    style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14,
                      fontWeight: FontWeight.w400,
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
        ? (isDark ? OTColors.borderDark : OTColors.borderLight)
        : OTColors.border(isDark);
    final bgColor = isHighlight
        ? (isDark ? OTColors.surfaceSubtleDark : OTColors.textPrimaryDark)
        : (isDark ? OTColors.surfaceDark : OTColors.surfaceLight);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(OTRadius.input),
        border: Border.all(color: borderColor, width: isHighlight ? 1.2 : 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDark
                  ? OTColors.borderSubtleDark
                  : OTColors.borderSubtleLight,
              borderRadius: BorderRadius.circular(OTRadius.xs),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: ScholarlyFonts.jetBrainsMono(
                fontSize: OTFontSize.s12,
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
                      style: ScholarlyFonts.newsreader(
                        fontSize: OTFontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  discipline,
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s12,
                    color: textSecondary,
                    height: 1.5,
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
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Dua tanda runtuhnya otoritas",
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
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
              color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
              borderRadius: BorderRadius.circular(OTRadius.input),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "«أَنْ تَلِدَ الأَمَةُ رَبَّتَهَا»",
                  style: ScholarlyFonts.scheherazadeNew(
                    fontSize: OTFontSize.s16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "1. Keruntuhan Otoritas Ilmu & Akidah (Naqḍ Qarār al-`Ilm wal-I'tiqād)",
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Runtuhnya tradisi talaqqi dan adab berguru. Anak menindas orang tua, murid tidak menghormati ulama bersanad, dan ilmu dicari murni demi keuntungan duniawi.",
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
                    color: textSecondary,
                    height: 1.5,
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
              color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
              borderRadius: BorderRadius.circular(OTRadius.input),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "«أَنْ تَرَى الحُفَاةَ العُرَاةَ يَتَطَاوَلُونَ فِي البُنْيَانِ»",
                  style: ScholarlyFonts.scheherazadeNew(
                    fontSize: OTFontSize.s16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "2. Keruntuhan Otoritas Kepemimpinan & Ekonomi (Naqḍ Qarār al-Ḥukm wal-Iqtiṣād)",
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Tatanan kepemimpinan dunia jatuh ke tangan orang yang tidak amanah, ekonomi global dikuasai sistem ribawi, dan kemuliaan diukur murni dari kemegahan material.",
                  style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14,
                    color: textSecondary,
                    height: 1.5,
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
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Perubahan bahasa dakwah",
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
                    borderRadius: BorderRadius.circular(OTRadius.input),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lughatut-Takfīr",
                        style: ScholarlyFonts.newsreader(
                          fontSize: OTFontSize.s14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Menghakimi & mencaci\n• Menganggap masyarakat lawan\n• Mudah mengafirkan",
                        style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12,
                          color: textSecondary,
                          height: 1.5,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? OTColors.surfaceSubtleDark
                        : OTColors.surfaceSubtleLight,
                    borderRadius: BorderRadius.circular(OTRadius.input),
                    border: Border.all(
                      color:
                          isDark ? OTColors.borderDark : OTColors.borderLight,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lughatut-Ṭibb",
                        style: ScholarlyFonts.newsreader(
                          fontSize: OTFontSize.s14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Dokter penolong beradab\n• Memandang umat pasien\n• Inqāḏ mā yumkinu inqāḏuh",
                        style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12,
                          color: textSecondary,
                          height: 1.5,
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
        desc:
            "Menjaga hati dari dengki, lisan dari mencela, dan tangan dari kekerasan. Menjalankan puasa dari kebisingan perdebatan media (shiyām 'an al-wasā'il)."
      ),
      (
        layer: "Lapis 2",
        title: "Benteng Keluarga (Khuwaiṣat al-Usrah)",
        arabic: "خُوَيْصَةُ الأُسْرَةِ وَالبَيْتِ",
        desc:
            "Menjadikan rumah sebagai tempat berlindung. Mendampingi anak memakai gawai, menanamkan akidah di meja makan, dan menjaga kehangatan keluarga."
      ),
      (
        layer: "Lapis 3",
        title: "Benteng Majelis & Zawiyah",
        arabic: "خُوَيْصَةُ الأَتْبَاعِ وَالمَجَالِسِ",
        desc:
            "Mendirikan zawiyah, pesantren (ribath), dan majelis taklim sebagai tempat aman (manāṭiq āminah) bagi siapa saja yang lelah oleh fitnah dunia."
      ),
      (
        layer: "Lapis 4",
        title: "Benteng Gawai & Alat (Khuwaiṣat al-Wasā'il)",
        arabic: "خُوَيْصَةُ الوَسَائِلِ",
        desc:
            "Memakai gawai dan AI untuk menuntut ilmu dan dakwah yang damai, bukan untuk ikut hanyut dalam polemik di kolom komentar."
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Empat lapis penjagaan diri (al-khuwaishah)",
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
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
                  color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
                  borderRadius: BorderRadius.circular(OTRadius.input),
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
                          style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s12,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          l.arabic,
                          style: ScholarlyFonts.scheherazadeNew(
                            fontSize: OTFontSize.s16,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l.desc,
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s12,
                        color: textSecondary,
                        height: 1.5,
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
        before:
            "Kaku memaksakan teks hukum ibadah tetap untuk menghakimi krisis sosial modern.",
        after:
            "Menjaga teks syariat tetap murni seraya luwes membaca pergeseran peradaban zaman."
      ),
      (
        aspect: "Teknologi & AI",
        before:
            "Terbelah ekstrem: menolak total sebagai bid'ah atau menelan mentah-mentah hingga hilang adab.",
        after:
            "Kaidah Al-Ightinām: merebut teknologi dan AI untuk khidmat ilmu turats secara selamat."
      ),
      (
        aspect: "Gaya Dakwah",
        before:
            "Suka memvonis dan mencaci; menganggap masyarakat sebagai lawan yang harus dihantam.",
        after:
            "Dokter penolong yang merangkul; menyelamatkan korban sistem zaman yang rusak."
      ),
      (
        aspect: "Fitnah Politik",
        before:
            "Fanatik buta golongan dan mengeksploitasi ayat agama untuk politik praktis.",
        after:
            "Manhaj as-Salāmah: lisan bersih dari mencela, tangan bersih dari menumpahkan darah."
      ),
      (
        aspect: "Keluarga",
        before:
            "Sibuk berdebat di medsos hingga anak-istri di rumah terbengkalai.",
        after:
            "Al-Khuwaiṣah: menjaga rumah tangga dan majelis sebagai tempat berlindung."
      ),
      (
        aspect: "Kondisi Batin",
        before: "Mudah panik dan cemas karena ramalan kiamat yang viral.",
        after:
            "Hati tenang (sakīnah); yakin sejarah dalam takdir Allah dan optimis giat beramal shalih."
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Perbandingan cara pandang",
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
                  borderRadius: BorderRadius.circular(OTRadius.xs),
                  border: Border.all(color: borderColor, width: 0.7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.aspect,
                      style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("❌ ",
                            style: TextStyle(fontSize: OTFontSize.s11)),
                        Expanded(
                          child: Text(
                            r.before,
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s12,
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
                                fontSize: OTFontSize.s12,
                                fontWeight: FontWeight.w700,
                                color: textPrimary)),
                        Expanded(
                          child: Text(
                            r.after,
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s12,
                              fontWeight: FontWeight.w400,
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
        desc:
            "Pintu gerbang pengenalan definisi, dalil Hadis Jibril, dan klasifikasi tanda kiamat.",
      ),
      _QawaidBook(
        level: "Tingkat 2 (Siklus Sejarah)",
        title: "Dawā'ir al-I'ādah",
        arabic: "دَوَائِرُ الإِعَادَةِ",
        desc:
            "Kaidah siklus pengulangan sejarah peradaban dalam lingkaran takdir azali.",
      ),
      _QawaidBook(
        level: "Tingkat 3 (Kunci Cabang)",
        title: "Al-Iqlīd",
        arabic: "الإِقْلِيدُ فِي فَتْحِ أَبْوَابِ العُلُومِ",
        desc:
            "Kaidah pengoperasian 5 cabang ilmu turunan Fikih Tahawwulat & antisipasi krisis.",
      ),
      _QawaidBook(
        level: "Tingkat 4 (Sikap Kenabian)",
        title: "At-Talīd wat-Ṭarīf",
        arabic: "التَّلِيدُ وَالطَّارِفُ",
        desc:
            "Syarah atas kaidah Sunnah al-Mawāqif dan Manhaj as-Salāmah para salafus shalih.",
      ),
      _QawaidBook(
        level: "Tingkat 5 (Ikhtisar Padat)",
        title: "Al-Mukhtaṣar al-Ḥabīk / Siyāḥatul Fikr",
        arabic: "المُخْتَصَرُ الحَبِيك",
        desc:
            "Ringkasan konsep dakwah, kaidah gerakan, dan telaah kritis atas ideologi modern.",
      ),
      _QawaidBook(
        level: "Tingkat 6 (Puncak Induk)",
        title: "Al-Usūs wal-Munṭalaqāt",
        arabic: "الأُسُسُ وَالمُنْطَلَقَاتُ",
        desc:
            "Kitab paling lengkap, setebal ratusan halaman; rujukan utama kaidah istinbath.",
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(OTRadius.card),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Dua kelompok kitab",
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
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
              color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
              borderRadius: BorderRadius.circular(OTRadius.input),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? OTColors.surfaceLight.withValues(alpha: 0.24)
                            : OTColors.shadow.withValues(alpha: 0.87),
                        borderRadius: BorderRadius.circular(OTRadius.xs),
                      ),
                      child: Text(
                        "KATEGORI I",
                        style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12,
                          fontWeight: FontWeight.w700,
                          color: OTColors.surfaceLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Al-Qawā'id (القواعد) — 6 Kitab Kaidah Pokok",
                        style: ScholarlyFonts.newsreader(
                          fontSize: OTFontSize.s14,
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
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? OTColors.surfaceSubtleDark
                            : OTColors.surfaceSubtleLight,
                        borderRadius: BorderRadius.circular(OTRadius.xs),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? OTColors.surfaceLight
                                      .withValues(alpha: 0.12)
                                  : OTColors.shadow.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(OTRadius.xs),
                            ),
                            child: Text(
                              book.level,
                              style: ScholarlyFonts.outfit(
                                fontSize: OTFontSize.s12,
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
                                  style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  book.desc,
                                  style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s12,
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
              color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
              borderRadius: BorderRadius.circular(OTRadius.input),
              border: Border.all(color: borderColor, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? OTColors.surfaceLight.withValues(alpha: 0.24)
                            : OTColors.shadow.withValues(alpha: 0.87),
                        borderRadius: BorderRadius.circular(OTRadius.xs),
                      ),
                      child: Text(
                        "KATEGORI II",
                        style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s12,
                          fontWeight: FontWeight.w700,
                          color: OTColors.surfaceLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "At-Taṭbīqāt (التطبيقات) — Terapan & Sastra",
                        style: ScholarlyFonts.newsreader(
                          fontSize: OTFontSize.s14,
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
                      "Syair yang merangkum inti Fikih Tahawwulat dengan bahasa rasa (aż-żawq): tentang keinsafan, adab, dan kerinduan kepada Nabi ﷺ.",
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
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: OTColors.textPrimary(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s12,
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
        desc:
            "Verifikasi redaksi Arab asli mualif, mencocokkan kutipan matan, serta rujukan presisi ke nama kitab, jilid, dan nomor halaman.",
        subAgentId: "fiqh_tahawwulat_muhaqqiq",
      ),
      _AiRoomItem(
        number: "02",
        name: "Al-Bayan",
        arabic: "البَيَان",
        role: "Pensyarah Konsep & Istilah Baru",
        desc:
            "Menjelaskan istilah yang rumit (mustalahat mubtakarah) dengan bahasa yang mudah, perumpamaan, dan peta konsep.",
        subAgentId: "fiqh_tahawwulat_bayan",
      ),
      _AiRoomItem(
        number: "03",
        name: "Al-Mukhtabir",
        arabic: "المُخْتَبِر",
        role: "Ujian Nalar & Kaji Kasus Interaktif",
        desc:
            "Teman diskusi dan penguji pemahaman; menyajikan studi kasus agar nalar tetap lurus dan tidak mencocok-cocokkan.",
        subAgentId: "fiqh_tahawwulat_mukhtabir",
      ),
      _AiRoomItem(
        number: "04",
        name: "Al-Habib",
        arabic: "الحَبِيب",
        role: "Arsip Muhadharah & Sentuhan Ruhani",
        desc:
            "Menyajikan isi ribuan jam ceramah penyusun: nasihat yang menenangkan dan bimbingan adab tazkiyatun nufus.",
        subAgentId: "fiqh_tahawwulat_habib",
      ),
      _AiRoomItem(
        number: "05",
        name: "Al-Khatib",
        arabic: "الخَطِيب",
        role: "Penyusun Materi Khutbah & Dakwah",
        desc:
            "Menyusun bahan khutbah Jumat, panduan dakwah di masa krisis, dan materi tabligh tematik yang menyejukkan.",
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: OTColors.surfaceSubtle(isDark),
                  foregroundColor: OTColors.textPrimary(isDark),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: widget.onSelectSubAgent == null ? null : () {
                  Navigator.of(context).pop();
                  widget.onSelectSubAgent!(matchingSub);
                },
                child: Text(Loc.isArabic ? room.arabic : room.name,
                  style: ScholarlyFonts.outfit(fontSize: OTFontSize.s18)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: Loc.isArabic ? 'عن المساعد' : 'Tentang asisten',
              onPressed: () => showDialog<void>(context: context,
                builder: (context) => AlertDialog(
                  title: Text(room.role), content: Text(room.desc),
                  actions: [TextButton(onPressed: () => Navigator.pop(context),
                    child: Text(Loc.isArabic ? 'إغلاق' : 'Tutup'))],
                )),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ]),
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
        color: isDark ? OTColors.surfaceDark : OTColors.surfaceLight,
        borderRadius: BorderRadius.circular(OTRadius.input),
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
              Text(
                "Harapan dan doa penutup",
                style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Teknologi di OpenTurath hadir sebagai khadim, pelayan ilmu: memudahkan istilah yang sulit dan membuka akses, agar warisan ini dapat dipelajari dengan mudah, jernih, dan beradab.",
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s14,
              fontWeight: FontWeight.w400,
              color: textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Semoga setiap huruf ibarah yang dikaji menjadi amal jariyah yang pahalanya mengalir tanpa putus ke haribaan mualif: "
            "Al-Musnid Al-`Allāmah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur, para guru beliau, dan seluruh kaum Muslimin hingga hari Kiamat. Āmīn.",
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s14,
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

    if (widget.asPage) {
      _chapters.add((tag, title));
      final number = _chapters.length.toString().padLeft(2, '0');
      return Padding(
        key: _chapterKeys.putIfAbsent(tag, GlobalKey.new),
        padding: const EdgeInsets.only(top: 72, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1, color: OTColors.border(isDark)),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  number,
                  style: ScholarlyFonts.newsreader(
                    fontSize: OTFontSize.s36,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -2,
                    height: 1,
                    color: OTColors.textTertiary(isDark),
                  ),
                ),
                const SizedBox(width: 14),
                // "Bab N" tidak diulang: nomor besar sudah menjadi urutannya.
                if (!tag.startsWith('Bab'))
                  Text(
                    tag,
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14,
                        color: OTColors.textTertiary(isDark)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: ScholarlyFonts.newsreader(
                fontSize: OTFontSize.s36,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.9,
                height: 1.12,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              arabic,
              textDirection: TextDirection.rtl,
              style: ScholarlyFonts.scheherazadeNew(
                fontSize: OTFontSize.s22,
                height: 1.6,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    // Jarak di atas tiap bab agar pergantian bab terasa.
    return Padding(
      padding: EdgeInsets.only(top: widget.asPage ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s12,
              fontWeight: FontWeight.w400,
              color: OTColors.textTertiary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: ScholarlyFonts.newsreader(
              fontSize: widget.asPage ? OTFontSize.s26 : OTFontSize.s22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              height: 1.2,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            style: ScholarlyFonts.scheherazadeNew(
              fontSize: widget.asPage ? OTFontSize.s18 : OTFontSize.s16,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyText(String text, bool isDark) {
    return Text(
      text,
      style: ScholarlyFonts.outfit(
        fontSize: widget.asPage ? OTFontSize.s16 : OTFontSize.s14,
        fontWeight: FontWeight.w400,
        height: widget.asPage ? 1.75 : 1.6,
        color: OTColors.textPrimary(isDark).withValues(alpha: 0.84),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? OTColors.surfaceDark : OTColors.canvasLight,
        borderRadius: BorderRadius.circular(OTRadius.input),
        // Garis di sisi kanan: sisi awal teks Arab.
        border: Border(
          right: BorderSide(color: textPrimary, width: 2.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            quote,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: ScholarlyFonts.scheherazadeNew(
              fontSize: widget.asPage ? OTFontSize.s22 : OTFontSize.s18,
              fontWeight: FontWeight.w600,
              height: 1.8,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "— $source",
            style: ScholarlyFonts.outfit(
              fontSize: OTFontSize.s12,
              fontWeight: FontWeight.w400,
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
