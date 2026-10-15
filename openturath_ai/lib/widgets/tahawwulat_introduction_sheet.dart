import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_platform.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'adaptive_sheet.dart';

/// Pengantar Fikih Tahawwulat berbentuk slide, untuk orang yang baru pertama
/// kali mendengarnya.
///
/// Isinya diringkas dari jawaban AI Fikih Tahawwulat (Al-Muhaqqiq dan
/// Al-Bayan), lalu setiap klaim dicek ke kitab dan muhadharah Al-Habib Abu
/// Bakar al-'Adni bin Ali al-Masyhur di notebook 06 (OUTPUT_V9_2) pada
/// 15 Oktober 2026. Klaim yang tidak ada di sumber tidak dipakai.
class TahawwulatIntroductionSheet extends StatefulWidget {
  final AgentModel? agent;
  final void Function(SubAgentModel subAgent)? onSelectSubAgent;
  final VoidCallback? onOpenMain;

  /// Halaman penuh dengan AppBar; false = lembar bawah.
  final bool asPage;

  /// Slide yang dibuka pertama (0 = sampul).
  final int initialSection;

  const TahawwulatIntroductionSheet({
    super.key,
    this.agent,
    this.onSelectSubAgent,
    this.onOpenMain,
    this.asPage = true,
    this.initialSection = 0,
  });

  /// Desktop: halaman penuh. Ponsel: lembar bawah.
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
        asPage: false,
      ),
    );
  }

  @override
  State<TahawwulatIntroductionSheet> createState() =>
      _TahawwulatIntroductionSheetState();
}

// ── Isi slide ──────────────────────────────────────────────────────────────

enum _G {
  kompas,
  riuh,
  kata,
  pilar,
  timbang,
  wadah,
  retak,
  buih,
  tangga,
  rambu,
  rantai,
  sunnah,
  selamat,
  tengah,
  lingkaran,
  kebutuhan,
  rak,
  ai,
}

class _Slide {
  const _Slide(this.label, this.judul, this.inti, this.grafik,
      {this.poin = const [], this.arab = ''});
  final String label;
  final String judul;
  final String inti;
  final _G grafik;
  final List<String> poin;
  final String arab;
}

const _slide = [
  _Slide(
    'Pengantar',
    'Fikih Tahawwulat',
    'Cara memahami zaman yang terus berubah, dengan petunjuk Nabi saw.',
    _G.kompas,
    arab: 'فقه التحولات',
    poin: [
      "Dirintis Al-Habib Abu Bakar al-'Adni bin Ali al-Masyhur (w. 1443 H)",
      'Geser untuk lanjut. Cukup sekitar tiga menit.',
    ],
  ),
  _Slide(
    'Kenapa perlu',
    'Dunia berubah cepat sekali',
    'Berita datang tiap detik, teknologi terus berganti, orang mudah berdebat. Wajar kalau kita bingung.',
    _G.riuh,
    poin: [
      'Nabi saw. sudah mengabarkan banyak perubahan ini',
      'Ilmu ini membantu kita membacanya dengan tenang',
    ],
  ),
  _Slide(
    'Arti nama',
    'Dua kata, satu maksud',
    'Fikih artinya paham sampai ke dalam. Tahawwulat artinya perubahan-perubahan.',
    _G.kata,
    poin: [
      "Jadi: memahami perubahan zaman dengan cahaya Al-Qur'an dan Sunnah",
      'Rentangnya luas, sejak Nabi Adam sampai hari kebangkitan',
    ],
  ),
  _Slide(
    'Asal-usul',
    'Berawal dari hadis Jibril',
    'Jibril bertanya kepada Nabi saw. tentang Islam, iman, ihsan, lalu tentang tanda-tanda kiamat.',
    _G.pilar,
    arab: 'يُعَلِّمُكُمْ دِينَكُمْ',
    poin: [
      'Di akhir, Nabi saw. bersabda: "Dia Jibril, datang mengajarkan agama kalian."',
      'Jadi yang keempat pun bagian dari agama. Di situlah rumah ilmu ini.',
    ],
  ),
  _Slide(
    'Pembeda',
    'Ada yang tetap, ada yang berubah',
    'Akidah, salat, dan halal-haram tetap sampai kiamat. Yang berubah adalah zaman dan keadaannya.',
    _G.timbang,
    poin: [
      'Masalah yang berubah sering dijawab dengan cara untuk hal yang tetap',
      'Di celah inilah ilmu ini bekerja',
    ],
  ),
  _Slide(
    'Fungsinya',
    'Wadah yang menjaga isinya',
    'Islam, iman, dan ihsan adalah isinya. Ilmu tentang tanda-tanda zaman adalah wadahnya.',
    _G.wadah,
    poin: [
      'Wadah yang retak membuat isinya mudah tercemar',
      'Ilmu ini menjaga agama dari kepura-puraan dan dari dijadikan alat politik',
    ],
  ),
  _Slide(
    'Dua tanda',
    'Dua retakan besar',
    'Dari dua tanda dalam hadis Jibril, beliau membaca isyarat dua hal yang akan goyah.',
    _G.retak,
    poin: [
      '"Budak melahirkan tuannya": goyahnya ilmu dan akidah',
      '"Penggembala berlomba meninggikan bangunan": goyahnya kekuasaan dan ekonomi',
    ],
  ),
  _Slide(
    'Potret zaman',
    'Banyak, tapi seperti buih',
    'Nabi saw. mengabarkan umat yang jumlahnya besar, tetapi ringan seperti buih yang terbawa arus.',
    _G.buih,
    arab: 'غُثَاءٌ كَغُثَاءِ السَّيْلِ',
    poin: [
      'Penyakitnya bernama al-wahn',
      'Yaitu cinta dunia dan takut mati',
    ],
  ),
  _Slide(
    'Peta sejarah',
    'Lima babak zaman buih',
    'Beliau memetakan lima babak, sejak umat kehilangan kepemimpinannya di panggung dunia.',
    _G.tangga,
  ),
  _Slide(
    'Rambu',
    'Bukan untuk meramal',
    'Ilmu ini tidak menebak tanggal kiamat dan tidak menunjuk orang. Yang dibaca adalah polanya.',
    _G.rambu,
  ),
  _Slide(
    'Penyakit dari dalam',
    'Retak karena hal kecil',
    'Adu domba di antara umat tumbuh dari kebiasaan sehari-hari yang dianggap ringan.',
    _G.rantai,
    poin: ['Penawarnya: menjaga lisan dan berbaik sangka'],
  ),
  _Slide(
    'Teladan',
    'Dua cara meneladani Nabi saw.',
    'Ada sunnah yang menjadi petunjuk menghadapi hal baru, dan ada sunnah yang menjadi teladan sikap.',
    _G.sunnah,
    poin: [
      'Contoh teladan sikap: Sayyidina Hasan melepas kekuasaan demi menjaga darah kaum muslimin',
    ],
  ),
  _Slide(
    'Pegangan',
    'Selamat lisan, selamat tangan',
    'Pegangan paling sederhana ketika fitnah sedang ramai.',
    _G.selamat,
    arab:
        'سَالِمًا بِاللِّسَانِ مِنَ الذَّمِّ، وَسَالِمًا بِالْأَرْكَانِ مِنَ الدَّمِّ',
    poin: ['Jaga lisan dari mencela', 'Jaga tangan dari menumpahkan darah'],
  ),
  _Slide(
    'Posisi',
    'Berdiri di jalan tengah',
    'Sayyidina Ali berkata: sebaik-baik manusia adalah kelompok yang di tengah.',
    _G.tengah,
    arab: 'خَيْرُ النَّاسِ هَذَا النَّمَطُ الْأَوْسَطُ',
    poin: [
      'Yang tertinggal menyusul mereka',
      'Yang kebablasan kembali kepada mereka',
    ],
  ),
  _Slide(
    'Langkah nyata',
    'Mulai dari lingkaran terdekat',
    'Ketika fitnah merata, Nabi saw. berpesan: jagalah dirimu sendiri.',
    _G.lingkaran,
    arab: 'فَعَلَيْكَ بِخَاصَّةِ نَفْسِكَ',
    poin: [
      'Istilahnya al-khuwaishah',
      'Rawat diri, keluarga, dan majelis kecil yang menenangkan',
    ],
  ),
  _Slide(
    'Seberapa penting',
    'Lebih dari air dan roti',
    'Kata beliau, hari ini kita membutuhkan ilmu ini lebih dari air, makanan, dan obat.',
    _G.kebutuhan,
    poin: ['Ibarat salep: dicari obat yang tepat untuk luka yang tepat'],
  ),
  _Slide(
    'Mulai belajar',
    'Naik pelan-pelan',
    'Mulailah dari kitab yang paling ringkas, lalu naik setahap demi setahap.',
    _G.rak,
  ),
  _Slide(
    'Tanya langsung',
    'Belajar bersama lima AI',
    'Kelimanya membaca kitab dan muhadharah yang sama, dengan cara membantu yang berbeda.',
    _G.ai,
  ),
];

class _Ruang {
  const _Ruang(this.id, this.nama, this.arab, this.untuk);
  final String id;
  final String nama;
  final String arab;
  final String untuk;
}

const _ruang = [
  _Ruang('fiqh_tahawwulat_bayan', 'Al-Bayan', 'البيان',
      'Untuk yang baru mulai. Bahasa sederhana dan perumpamaan.'),
  _Ruang('fiqh_tahawwulat_muhaqqiq', 'Al-Muhaqqiq', 'المحقق',
      'Untuk riset. Ibarah asli lengkap dengan kitab dan halaman.'),
  _Ruang('fiqh_tahawwulat_habib', 'Al-Habib', 'الحبيب',
      'Menelusuri muhadharah beliau sampai ke menitnya.'),
  _Ruang('fiqh_tahawwulat_mukhtabir', 'Al-Mukhtabir', 'المختبر',
      'Menguji pemahaman dengan soal dan pembahasan.'),
  _Ruang('fiqh_tahawwulat_khatib', 'Al-Khatib', 'الخطيب',
      'Membantu menyusun khutbah dan materi dakwah.'),
];

// ── Layar ──────────────────────────────────────────────────────────────────

class _TahawwulatIntroductionSheetState
    extends State<TahawwulatIntroductionSheet>
    with SingleTickerProviderStateMixin {
  late int _i = widget.initialSection.clamp(0, _slide.length - 1);
  late final PageController _page = PageController(initialPage: _i);
  late final AnimationController _gerak = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();
  final FocusNode _fokus = FocusNode();

  @override
  void dispose() {
    _page.dispose();
    _gerak.dispose();
    _fokus.dispose();
    super.dispose();
  }

  void _ke(int i) {
    if (i < 0 || i >= _slide.length) return;
    _page.animateToPage(i,
        duration: OTMotion.transition, curve: OTMotion.curve);
  }

  void _berganti(int i) {
    setState(() => _i = i);
    _gerak.forward(from: 0);
  }

  KeyEventResult _tombol(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
      _ke(_i + 1);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _ke(_i - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isi = Focus(
      focusNode: _fokus,
      autofocus: true,
      onKeyEvent: _tombol,
      child: Column(children: [
        _kemajuan(isDark),
        Expanded(
          child: PageView.builder(
            controller: _page,
            itemCount: _slide.length,
            onPageChanged: _berganti,
            itemBuilder: (ctx, i) => _halaman(ctx, i, isDark),
          ),
        ),
        _bawah(isDark),
      ]),
    );
    final badan = Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560), child: isi),
    );
    if (widget.asPage) {
      return Scaffold(
        backgroundColor: OTColors.canvas(isDark),
        appBar: AppBar(
          backgroundColor: OTColors.canvas(isDark),
          title: const Text('Mengenal Fikih Tahawwulat'),
        ),
        body: SafeArea(child: badan),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
          color: OTColors.canvas(isDark), borderRadius: OTRadius.sheetBorder),
      child: SafeArea(top: false, child: badan),
    );
  }

  /// Garis kemajuan bersegmen, seperti story.
  Widget _kemajuan(bool isDark) => Padding(
        padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xs),
        child: Row(children: [
          for (var k = 0; k < _slide.length; k++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _ke(k),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: OTSpacing.xxs, vertical: OTSpacing.sm),
                  child: ClipRRect(
                    borderRadius: OTRadius.xsBorder,
                    child: SizedBox(
                      height: 3,
                      child: k == _i
                          ? AnimatedBuilder(
                              animation: _gerak,
                              builder: (_, __) => LinearProgressIndicator(
                                value: _gerak.value,
                                minHeight: 3,
                                color: OTColors.tahawwulat,
                                backgroundColor: OTColors.border(isDark),
                              ),
                            )
                          : ColoredBox(
                              color: k < _i
                                  ? OTColors.textPrimary(isDark)
                                  : OTColors.border(isDark)),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );

  Widget _halaman(BuildContext context, int i, bool isDark) {
    final s = _slide[i];
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final sampul = s.grafik == _G.kompas;
    return LayoutBuilder(builder: (ctx, box) {
      final tinggiGrafik =
          s.grafik == _G.ai ? 0.0 : math.min(box.maxHeight * 0.44, 320.0);
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, OTSpacing.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text((i + 1).toString().padLeft(2, '0'),
                style: ScholarlyFonts.newsreader(
                    fontSize: OTFontSize.s14,
                    fontWeight: FontWeight.w600,
                    color: OTColors.tahawwulat)),
            const SizedBox(width: OTSpacing.sm),
            Container(width: OTSpacing.base, height: 1, color: muted),
            const SizedBox(width: OTSpacing.sm),
            Text(s.label.toUpperCase(),
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: muted)),
          ]),
          if (tinggiGrafik > 0) ...[
            const SizedBox(height: OTSpacing.sm),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => d.localPosition.dx < box.maxWidth / 3
                  ? _ke(_i - 1)
                  : _ke(_i + 1),
              child: SizedBox(
                height: tinggiGrafik,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _gerak,
                  builder: (_, __) => CustomPaint(
                    painter: _Lukisan(
                        s.grafik, i == _i ? _gerak.value : 1, _Tinta(isDark)),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: OTSpacing.base),
          if (s.arab.isNotEmpty && !sampul) ...[
            SizedBox(
              width: double.infinity,
              child: Text(s.arab,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.left,
                  style: ScholarlyFonts.scheherazadeNew(
                      fontSize: OTFontSize.s22, color: OTColors.tahawwulat)),
            ),
            const SizedBox(height: OTSpacing.xs),
          ],
          Text(s.judul,
              style: ScholarlyFonts.newsreader(
                  fontSize: sampul ? OTFontSize.s36 : OTFontSize.s26,
                  height: 1.15,
                  color: ink)),
          if (sampul) ...[
            const SizedBox(height: OTSpacing.xs),
            Text(s.arab,
                textDirection: TextDirection.rtl,
                style: ScholarlyFonts.scheherazadeNew(
                    fontSize: OTFontSize.s26, color: OTColors.tahawwulat)),
          ],
          const SizedBox(height: OTSpacing.md),
          Text(s.inti,
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s18, height: 1.5, color: ink)),
          if (s.poin.isNotEmpty) const SizedBox(height: OTSpacing.base),
          for (final p in s.poin)
            Padding(
              padding: const EdgeInsets.only(bottom: OTSpacing.sm),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: OTSpacing.sm),
                  child: Container(
                      width: OTSpacing.md,
                      height: 2,
                      color: OTColors.tahawwulat),
                ),
                const SizedBox(width: OTSpacing.md),
                Expanded(
                  child: Text(p,
                      style: ScholarlyFonts.outfit(
                          fontSize: OTFontSize.s14,
                          height: 1.55,
                          color: muted)),
                ),
              ]),
            ),
          if (s.grafik == _G.ai) ...[
            const SizedBox(height: OTSpacing.base),
            _limaAi(context, isDark),
          ],
        ]),
      );
    });
  }

  Widget _bawah(bool isDark) {
    final akhir = _i == _slide.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, OTSpacing.base),
      child: Row(children: [
        IconButton(
          tooltip: 'Sebelumnya',
          onPressed: _i == 0 ? null : () => _ke(_i - 1),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: OTSpacing.sm),
        Text('${_i + 1} / ${_slide.length}',
            style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s12,
                color: OTColors.textSecondary(isDark))),
        const Spacer(),
        FilledButton(
          onPressed: akhir
              ? () => Navigator.of(context).maybePop()
              : () => _ke(_i + 1),
          child: Text(akhir
              ? 'Selesai'
              : _i == 0
                  ? 'Mulai'
                  : 'Lanjut'),
        ),
      ]),
    );
  }

  Widget _limaAi(BuildContext context, bool isDark) {
    final subs = widget.agent?.subAgents ?? const <SubAgentModel>[];
    return Column(children: [
      for (final r in _ruang)
        Padding(
          padding: const EdgeInsets.only(bottom: OTSpacing.sm),
          child: Material(
            color: OTColors.surface(isDark),
            borderRadius: OTRadius.cardBorder,
            child: InkWell(
              borderRadius: OTRadius.cardBorder,
              onTap: widget.onSelectSubAgent == null
                  ? null
                  : () {
                      final sub = subs.firstWhere((s) => s.id == r.id,
                          orElse: () => SubAgentModel(
                              id: r.id,
                              name: r.nama,
                              nameArabic: r.arab,
                              description: r.untuk,
                              descriptionArabic: r.arab,
                              emoji: '📖',
                              badge: r.nama));
                      Navigator.of(context).pop();
                      widget.onSelectSubAgent!(sub);
                    },
              child: Padding(
                padding: const EdgeInsets.all(OTSpacing.base),
                child: Row(children: [
                  Container(
                    width: OTSpacing.huge,
                    height: OTSpacing.huge,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: OTColors.tahawwulat)),
                    child: Text(r.arab,
                        textDirection: TextDirection.rtl,
                        style: ScholarlyFonts.scheherazadeNew(
                            fontSize: OTFontSize.s12,
                            color: OTColors.textPrimary(isDark))),
                  ),
                  const SizedBox(width: OTSpacing.md),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Loc.isArabic ? r.arab : r.nama,
                              style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s16,
                                  fontWeight: FontWeight.w600,
                                  color: OTColors.textPrimary(isDark))),
                          const SizedBox(height: OTSpacing.xxs),
                          Text(r.untuk,
                              style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s12,
                                  height: 1.45,
                                  color: OTColors.textSecondary(isDark))),
                        ]),
                  ),
                  if (widget.onSelectSubAgent != null)
                    Icon(Icons.arrow_forward_rounded,
                        size: OTFontSize.s18,
                        color: OTColors.textPrimary(isDark)),
                ]),
              ),
            ),
          ),
        ),
      if (widget.onOpenMain != null) ...[
        const SizedBox(height: OTSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onOpenMain!();
            },
            child: const Text('Mulai bertanya'),
          ),
        ),
      ],
    ]);
  }
}

// ── Ilustrasi: tinta monokrom + aksen Tahawwulat, digambar masuk saat slide
// dibuka (t: 0 → 1). ───────────────────────────────────────────────────────

class _Tinta {
  _Tinta(bool isDark)
      : ink = OTColors.textPrimary(isDark),
        muted = OTColors.textSecondary(isDark),
        faint = OTColors.border(isDark),
        surface = OTColors.surface(isDark),
        subtle = OTColors.surfaceSubtle(isDark);
  final Color ink;
  final Color muted;
  final Color faint;
  final Color surface;
  final Color subtle;
  Color get accent => OTColors.tahawwulat;
}

double _e(double t, double a, double b) =>
    Curves.easeOutCubic.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

const _sudut = Radius.circular(OTSpacing.xs);
const _sudutBesar = Radius.circular(OTSpacing.md);

class _Lukisan extends CustomPainter {
  _Lukisan(this.g, this.t, this.w);
  final _G g;
  final double t;
  final _Tinta w;

  Paint _garis(Color c, [double tebal = 1.5]) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = tebal
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint _isi(Color c) => Paint()..color = c;

  void _tulis(Canvas c, String s, Offset pusat,
      {double ukuran = OTFontSize.s12,
      Color? warna,
      bool arab = false,
      bool tebal = false,
      double lebar = 120,
      double alpha = 1}) {
    if (alpha <= 0) return;
    final col = (warna ?? w.ink).withValues(alpha: alpha.clamp(0.0, 1.0));
    final st = arab
        ? ScholarlyFonts.scheherazadeNew(fontSize: ukuran, color: col)
        : ScholarlyFonts.outfit(
            fontSize: ukuran,
            fontWeight: tebal ? FontWeight.w600 : FontWeight.w400,
            height: 1.25,
            color: col);
    final tp = TextPainter(
      text: TextSpan(text: s, style: st),
      textAlign: TextAlign.center,
      textDirection: arab ? TextDirection.rtl : TextDirection.ltr,
    )..layout(maxWidth: lebar);
    tp.paint(c, pusat - Offset(tp.width / 2, tp.height / 2));
  }

  /// Menggambar sebagian path sesuai kemajuan (0..1).
  void _jejak(Canvas c, Path p, Paint paint, double kemajuan) {
    if (kemajuan <= 0) return;
    for (final m in p.computeMetrics()) {
      c.drawPath(m.extractPath(0, m.length * kemajuan), paint);
    }
  }

  @override
  void paint(Canvas c, Size s) {
    switch (g) {
      case _G.kompas:
        _kompas(c, s);
      case _G.riuh:
        _riuh(c, s);
      case _G.kata:
        _kata(c, s);
      case _G.pilar:
        _pilar(c, s);
      case _G.timbang:
        _timbang(c, s);
      case _G.wadah:
        _wadah(c, s);
      case _G.retak:
        _retak(c, s);
      case _G.buih:
        _buih(c, s);
      case _G.tangga:
        _tangga(c, s);
      case _G.rambu:
        _rambu(c, s);
      case _G.rantai:
        _rantai(c, s);
      case _G.sunnah:
        _sunnah(c, s);
      case _G.selamat:
        _selamat(c, s);
      case _G.tengah:
        _tengah(c, s);
      case _G.lingkaran:
        _lingkaran(c, s);
      case _G.kebutuhan:
        _kebutuhan(c, s);
      case _G.rak:
        _rak(c, s);
      case _G.ai:
        break;
    }
  }

  // Kompas yang jarumnya berayun lalu menemukan arah.
  void _kompas(Canvas c, Size s) {
    final o = s.center(Offset.zero);
    final r = math.min(s.width, s.height) * 0.4;
    for (final k in [1.0, 0.74, 0.48]) {
      c.drawCircle(o, r * k * (0.9 + 0.1 * _e(t, 0, 0.5)), _garis(w.faint, 1));
    }
    for (var k = 0; k < 48; k++) {
      final a = k * math.pi * 2 / 48;
      final pj = k % 12 == 0 ? 14.0 : (k % 4 == 0 ? 8.0 : 4.0);
      final arah = Offset(math.cos(a), math.sin(a));
      c.drawLine(
          o + arah * r,
          o + arah * (r - pj),
          _garis(w.ink.withValues(alpha: _e(t, k / 96, 0.5 + k / 96)),
              k % 12 == 0 ? 2 : 1));
    }
    const mata = ['U', 'T', 'S', 'B'];
    for (var k = 0; k < 4; k++) {
      final a = -math.pi / 2 + k * math.pi / 2;
      _tulis(c, mata[k], o + Offset(math.cos(a), math.sin(a)) * (r + 14),
          ukuran: OTFontSize.s11, warna: w.muted, alpha: _e(t, 0.3, 0.7));
    }
    c.drawArc(Rect.fromCircle(center: o, radius: r * 0.74), -math.pi / 2,
        math.pi * 2 * _e(t, 0.1, 0.9), false, _garis(w.accent, 2));
    final sudut = (1 - Curves.elasticOut.transform(_e(t, 0.15, 1))) * 1.6 -
        math.pi / 2 +
        0.35;
    final u = Offset(math.cos(sudut), math.sin(sudut));
    final v = Offset(-u.dy, u.dx);
    Path jarum(double arah) => Path()
      ..moveTo(o.dx + u.dx * r * 0.62 * arah, o.dy + u.dy * r * 0.62 * arah)
      ..lineTo(o.dx + v.dx * 9, o.dy + v.dy * 9)
      ..lineTo(o.dx - v.dx * 9, o.dy - v.dy * 9)
      ..close();
    c.drawPath(jarum(-1), _isi(w.faint));
    c.drawPath(jarum(1), _isi(w.accent));
    c.drawCircle(o, 5, _isi(w.ink));
  }

  // Coretan riuh, lalu satu garis arah yang jernih.
  void _riuh(Canvas c, Size s) {
    final kiri = s.width * 0.52;
    for (var k = 0; k < 44; k++) {
      final x = (math.sin(k * 12.9898) * 0.5 + 0.5) * kiri;
      final y =
          (math.sin(k * 78.233) * 0.5 + 0.5) * s.height * 0.8 + s.height * 0.08;
      final a = math.sin(k * 3.7) * math.pi;
      final pj = (10 + (k % 5) * 6.0) * _e(t, k / 120, 0.25 + k / 120);
      c.drawLine(
          Offset(x, y),
          Offset(x, y) + Offset(math.cos(a), math.sin(a)) * pj,
          _garis(w.muted.withValues(alpha: 0.55), 1.4));
    }
    final y = s.height * 0.5;
    final ujung = Offset(s.width * 0.9, y - 6);
    final jalur = Path()
      ..moveTo(s.width * 0.12, y + 40)
      ..cubicTo(
          s.width * 0.35, y - 50, s.width * 0.55, y + 50, ujung.dx, ujung.dy);
    _jejak(c, jalur, _garis(w.accent, 3), _e(t, 0.35, 1));
    if (t > 0.9) {
      c.drawPath(
          Path()
            ..moveTo(ujung.dx - 12, ujung.dy - 9)
            ..lineTo(ujung.dx, ujung.dy)
            ..lineTo(ujung.dx - 12, ujung.dy + 9),
          _garis(w.accent, 3));
    }
    _tulis(c, 'riuh', Offset(kiri * 0.45, s.height - 8),
        warna: w.muted, alpha: _e(t, 0.2, 0.5));
    _tulis(c, 'arah', Offset(s.width * 0.86, y + 28),
        warna: w.accent, tebal: true, alpha: _e(t, 0.8, 1));
  }

  // فقه + التحولات = memahami perubahan zaman.
  void _kata(Canvas c, Size s) {
    final lebar = math.min(s.width * 0.4, 170.0);
    final tinggi = s.height * 0.36;
    final atas = s.height * 0.06;
    const kata = [
      ['فقه', 'paham sampai ke dalam'],
      ['التحولات', 'perubahan-perubahan'],
    ];
    for (var k = 0; k < 2; k++) {
      final m = _e(t, k * 0.15, 0.45 + k * 0.15);
      final x = k == 0 ? s.width / 2 - lebar - 18 : s.width / 2 + 18;
      final r = Rect.fromLTWH(x, atas + (1 - m) * 16, lebar, tinggi);
      c.drawRRect(RRect.fromRectAndRadius(r, _sudutBesar),
          _isi(w.subtle.withValues(alpha: m)));
      _tulis(c, kata[k][0], r.center - Offset(0, tinggi * 0.14),
          ukuran: OTFontSize.s36, arab: true, alpha: m, lebar: lebar);
      _tulis(c, kata[k][1], r.center + Offset(0, tinggi * 0.28),
          warna: w.muted, alpha: m, lebar: lebar - 16);
    }
    _tulis(c, '+', Offset(s.width / 2, atas + tinggi / 2),
        ukuran: OTFontSize.s26, warna: w.muted, alpha: _e(t, 0.3, 0.5));
    final m = _e(t, 0.55, 1);
    final hasil = Rect.fromLTWH(s.width / 2 - lebar - 18,
        s.height * 0.6 + (1 - m) * 16, lebar * 2 + 36, s.height * 0.3);
    _tulis(c, '=', Offset(s.width / 2, s.height * 0.51),
        ukuran: OTFontSize.s26, warna: w.muted, alpha: m);
    c.drawRRect(RRect.fromRectAndRadius(hasil, _sudutBesar),
        _garis(w.accent.withValues(alpha: m), 2));
    _tulis(c, 'Memahami perubahan zaman', hasil.center,
        ukuran: OTFontSize.s18, tebal: true, alpha: m, lebar: hasil.width);
  }

  // Empat pilar agama; yang keempat menyala.
  void _pilar(Canvas c, Size s) {
    final kiri = s.width * 0.08;
    final kanan = s.width * 0.92;
    final dasar = s.height * 0.78;
    final atap = s.height * 0.16;
    final lebarPilar = (kanan - kiri) / 4 * 0.5;
    const nama = ['Islam', 'Iman', 'Ihsan', 'Tanda\nzaman'];
    c.drawLine(Offset(kiri, dasar), Offset(kanan, dasar), _garis(w.ink, 2));
    c.drawLine(Offset(kiri + 8, dasar + 6), Offset(kanan - 8, dasar + 6),
        _garis(w.faint, 2));
    for (var k = 0; k < 4; k++) {
      final m = _e(t, k * 0.12, 0.45 + k * 0.12);
      final cx = kiri + (kanan - kiri) * (k + 0.5) / 4;
      final tinggi = (dasar - atap - 24) * m;
      final r = Rect.fromLTWH(
          cx - lebarPilar / 2, dasar - tinggi, lebarPilar, tinggi);
      final keempat = k == 3;
      c.drawRect(
          r, _isi(keempat ? w.accent.withValues(alpha: 0.22) : w.subtle));
      c.drawRect(r, _garis(keempat ? w.accent : w.ink, keempat ? 2 : 1.2));
      for (var j = 1; j < 3; j++) {
        final x = r.left + r.width * j / 3;
        c.drawLine(Offset(x, r.top + 6), Offset(x, r.bottom - 6),
            _garis((keempat ? w.accent : w.faint).withValues(alpha: 0.6), 1));
      }
      _tulis(c, nama[k], Offset(cx, dasar + 26),
          tebal: keempat, warna: keempat ? w.accent : w.ink, alpha: m);
    }
    final m = _e(t, 0.55, 1);
    final segitiga = Path()
      ..moveTo(kiri - 6, atap + 24)
      ..lineTo(s.width / 2, atap - 14)
      ..lineTo(kanan + 6, atap + 24)
      ..close();
    c.drawPath(segitiga, _isi(w.subtle.withValues(alpha: m)));
    c.drawPath(segitiga, _garis(w.ink.withValues(alpha: m), 1.5));
    _tulis(c, 'Agama', Offset(s.width / 2, atap + 10), tebal: true, alpha: m);
  }

  // Timbangan: yang tetap dan yang berubah.
  void _timbang(Canvas c, Size s) {
    final o = Offset(s.width / 2, s.height * 0.3);
    final miring = (1 - Curves.elasticOut.transform(_e(t, 0, 1))) * 0.35;
    final lengan = s.width * 0.34;
    final kiri = o + Offset(-math.cos(miring), math.sin(miring)) * lengan;
    final kanan = o + Offset(math.cos(miring), -math.sin(miring)) * lengan;
    final lantai = s.height * 0.86;
    c.drawPath(
        Path()
          ..moveTo(o.dx, o.dy)
          ..lineTo(o.dx - 26, lantai)
          ..lineTo(o.dx + 26, lantai)
          ..close(),
        _isi(w.subtle));
    c.drawLine(
        Offset(o.dx - 50, lantai), Offset(o.dx + 50, lantai), _garis(w.ink, 2));
    c.drawLine(kiri, kanan, _garis(w.ink, 2.4));
    c.drawCircle(o, 5, _isi(w.ink));
    for (final p in [kiri, kanan]) {
      c.drawLine(p, p + const Offset(-26, 44), _garis(w.faint, 1));
      c.drawLine(p, p + const Offset(26, 44), _garis(w.faint, 1));
      c.drawArc(
          Rect.fromCenter(
              center: p + const Offset(0, 44), width: 64, height: 22),
          0,
          math.pi,
          false,
          _garis(w.ink, 1.6));
    }
    c.drawRect(
        Rect.fromCenter(
            center: kiri + const Offset(0, 30), width: 34, height: 26),
        _isi(w.ink));
    final gel = Path();
    for (var k = 0; k <= 30; k++) {
      final p = kanan +
          Offset(
              -18 + k * 1.2, 30 + math.sin(k / 30 * math.pi * 3 + t * 6) * 5);
      k == 0 ? gel.moveTo(p.dx, p.dy) : gel.lineTo(p.dx, p.dy);
    }
    c.drawPath(gel, _garis(w.accent, 2.4));
    final m = _e(t, 0.4, 0.9);
    _tulis(c, 'Yang tetap', kiri + const Offset(0, 82),
        tebal: true, ukuran: OTFontSize.s14, alpha: m);
    _tulis(c, 'akidah · ibadah · halal-haram', kiri + const Offset(0, 104),
        warna: w.muted, alpha: m, ukuran: OTFontSize.s11, lebar: lengan);
    _tulis(c, 'Yang berubah', kanan + const Offset(0, 82),
        tebal: true, ukuran: OTFontSize.s14, warna: w.accent, alpha: m);
    _tulis(c, 'zaman · keadaan · sarana', kanan + const Offset(0, 104),
        warna: w.muted, alpha: m, ukuran: OTFontSize.s11, lebar: lengan);
  }

  // Wadah yang memantulkan kotoran dari luar.
  void _wadah(Canvas c, Size s) {
    final r = math.min(s.width * 0.34, s.height * 0.4);
    final o = Offset(s.width / 2, s.height * 0.4);
    _jejak(c, Path()..addArc(Rect.fromCircle(center: o, radius: r), 0, math.pi),
        _garis(w.accent, 4), _e(t, 0, 0.5));
    c.drawLine(o - Offset(r + 12, 0), o + Offset(r + 12, 0),
        _garis(w.accent.withValues(alpha: _e(t, 0.3, 0.5)), 4));
    const isi = ['Islam', 'Iman', 'Ihsan'];
    for (var k = 0; k < 3; k++) {
      final m = _e(t, 0.4 + k * 0.1, 0.7 + k * 0.1);
      final p = o + Offset((k - 1) * r * 0.58, r * 0.4 - (1 - m) * 40);
      c.drawCircle(p, r * 0.25, _isi(w.subtle.withValues(alpha: m)));
      c.drawCircle(p, r * 0.25, _garis(w.ink.withValues(alpha: m), 1.2));
      _tulis(c, isi[k], p, tebal: true, alpha: m);
    }
    for (var k = 0; k < 7; k++) {
      final a = math.pi + 0.3 + k * (math.pi - 0.6) / 6;
      final jauh = r * (1.7 - 0.5 * _e(t, 0.5, 0.75) + 0.35 * _e(t, 0.75, 1));
      c.drawCircle(o + Offset(math.cos(a), math.sin(a)) * jauh, 3,
          _isi(w.muted.withValues(alpha: 0.6)));
    }
    _tulis(c, 'Rukun keempat = wadahnya', o + Offset(0, r + 22),
        warna: w.accent, tebal: true, alpha: _e(t, 0.6, 1), lebar: s.width);
  }

  // Dua pilar yang retak.
  void _retak(Canvas c, Size s) {
    const atas = ['Ilmu & akidah', 'Kekuasaan & ekonomi'];
    for (var k = 0; k < 2; k++) {
      final cx = s.width * (k == 0 ? 0.28 : 0.72);
      final r = Rect.fromCenter(
          center: Offset(cx, s.height * 0.56),
          width: s.width * 0.18,
          height: s.height * 0.62);
      c.drawRect(r, _isi(w.subtle));
      c.drawRect(r, _garis(w.ink, 1.4));
      c.drawLine(r.topLeft - const Offset(10, 0),
          r.topRight + const Offset(10, 0), _garis(w.ink, 3));
      c.drawLine(r.bottomLeft - const Offset(10, 0),
          r.bottomRight + const Offset(10, 0), _garis(w.ink, 3));
      final retak = Path()..moveTo(r.left + r.width * 0.6, r.top);
      for (var j = 1; j <= 6; j++) {
        retak.lineTo(
            r.left + r.width * (j.isOdd ? 0.3 : 0.7), r.top + r.height * j / 6);
      }
      _jejak(
          c, retak, _garis(w.accent, 2.4), _e(t, 0.2 + k * 0.2, 0.8 + k * 0.2));
      _tulis(c, atas[k], Offset(cx, r.top - 24),
          tebal: true, lebar: s.width * 0.42, alpha: _e(t, 0, 0.4));
    }
  }

  // Buih yang naik dari arus.
  void _buih(Canvas c, Size s) {
    final air = s.height * 0.8;
    for (var g = 0; g < 3; g++) {
      final p = Path();
      for (var k = 0; k <= 60; k++) {
        final x = s.width * k / 60;
        final y = air + g * 9 + math.sin(k / 6 + g + t * 4) * 4;
        k == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
      }
      c.drawPath(p, _garis(w.faint, 1.4));
    }
    for (var k = 0; k < 36; k++) {
      final x = (math.sin(k * 12.9898) * 0.5 + 0.5) * s.width;
      final rad = 4 + (math.sin(k * 4.1) * 0.5 + 0.5) * 14;
      final mulai = (k % 9) / 14;
      final naik = _e(t, mulai, mulai + 0.55);
      final y = air - naik * (air - 20) * (0.35 + (k % 7) / 10);
      c.drawCircle(
          Offset(x, y),
          rad * (0.4 + 0.6 * naik),
          _garis(
              (k % 7 == 0 ? w.accent : w.muted).withValues(alpha: 0.75), 1.3));
    }
    _tulis(c, 'banyak, tapi ringan', Offset(s.width / 2, s.height - 8),
        warna: w.muted, alpha: _e(t, 0.6, 1), lebar: s.width);
  }

  // Lima babak, menurun seperti anak tangga.
  void _tangga(Canvas c, Size s) {
    const babak = [
      ['الاستكبار', 'Bangsa besar menguasai industri'],
      ['الاستعمار', 'Penjajahan membawa sekularisme'],
      ['الاستهتار', 'Hidup makin disekulerkan'],
      ['الاستثمار', 'Globalisasi'],
      ['الاستنفار', 'Puncak benturan: ash-shaylamah'],
    ];
    final baris = s.height / 5;
    final geser = s.width * 0.07;
    for (var k = 0; k < 5; k++) {
      final m = _e(t, k * 0.12, 0.4 + k * 0.12);
      final x = geser * k + 14;
      final y = baris * k + baris / 2;
      if (k < 4) {
        final ruas = Path()
          ..moveTo(x, y + 14)
          ..lineTo(x, y + baris / 2)
          ..lineTo(x + geser, y + baris / 2)
          ..lineTo(x + geser, y + baris - 14);
        _jejak(c, ruas, _garis(w.faint, 1.4),
            _e(t, 0.1 + k * 0.12, 0.45 + k * 0.12));
      }
      final akhir = k == 4;
      c.drawCircle(Offset(x, y), 14,
          _isi((akhir ? w.accent : w.ink).withValues(alpha: m)));
      _tulis(c, '${k + 1}', Offset(x, y),
          warna: w.surface, tebal: true, alpha: m);
      final ar = TextPainter(
        text: TextSpan(
            text: babak[k][0],
            style: ScholarlyFonts.scheherazadeNew(
                fontSize: OTFontSize.s18,
                color: (akhir ? w.accent : w.ink).withValues(alpha: m))),
        textDirection: TextDirection.rtl,
      )..layout();
      ar.paint(c, Offset(x + 24, y - ar.height / 2));
      final ket = TextPainter(
        text: TextSpan(
            text: babak[k][1],
            style: ScholarlyFonts.outfit(
                fontSize: OTFontSize.s12,
                height: 1.2,
                color: w.muted.withValues(alpha: m))),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: math.max(60.0, s.width - x - 40 - ar.width));
      ket.paint(c, Offset(x + 36 + ar.width, y - ket.height / 2));
    }
  }

  // Rambu: tanggal ✕, tokoh ✕, pola ✓.
  void _rambu(Canvas c, Size s) {
    const nama = ['Menebak tanggal', 'Menunjuk tokoh', 'Membaca pola'];
    final r = math.min(s.width / 7.5, s.height * 0.22);
    for (var k = 0; k < 3; k++) {
      final m = _e(t, k * 0.2, 0.5 + k * 0.2);
      final o = Offset(s.width * (k + 0.5) / 3, s.height * 0.42);
      final ya = k == 2;
      c.drawCircle(
          o, r, _isi(ya ? w.accent.withValues(alpha: 0.15) : w.subtle));
      c.drawCircle(o, r, _garis(ya ? w.accent : w.faint, 1.6));
      final ik = _garis(w.ink, 1.8);
      if (k == 0) {
        final kal = Rect.fromCenter(center: o, width: r, height: r * 0.86);
        c.drawRRect(RRect.fromRectAndRadius(kal, _sudut), ik);
        c.drawLine(Offset(kal.left, kal.top + r * 0.24),
            Offset(kal.right, kal.top + r * 0.24), ik);
      } else if (k == 1) {
        c.drawCircle(o - Offset(0, r * 0.22), r * 0.2, ik);
        c.drawArc(
            Rect.fromCenter(
                center: o + Offset(0, r * 0.42),
                width: r * 0.9,
                height: r * 0.7),
            math.pi,
            math.pi,
            false,
            ik);
      } else {
        final gel = Path();
        for (var j = 0; j <= 24; j++) {
          final x = o.dx - r * 0.55 + j * r * 1.1 / 24;
          final y = o.dy + math.sin(j / 24 * math.pi * 2) * r * 0.25;
          j == 0 ? gel.moveTo(x, y) : gel.lineTo(x, y);
        }
        c.drawPath(gel, _garis(w.accent, 2.4));
      }
      final tanda = o + Offset(r * 0.72, -r * 0.72);
      c.drawCircle(
          tanda, 12, _isi((ya ? w.accent : w.ink).withValues(alpha: m)));
      final tp = _garis(w.surface.withValues(alpha: m), 2.2);
      if (ya) {
        c.drawPath(
            Path()
              ..moveTo(tanda.dx - 5, tanda.dy)
              ..lineTo(tanda.dx - 1, tanda.dy + 4)
              ..lineTo(tanda.dx + 5, tanda.dy - 4),
            tp);
      } else {
        c.drawLine(tanda - const Offset(4, 4), tanda + const Offset(4, 4), tp);
        c.drawLine(
            tanda + const Offset(-4, 4), tanda + const Offset(4, -4), tp);
      }
      _tulis(c, nama[k], o + Offset(0, r + 22),
          tebal: ya,
          warna: ya ? w.accent : w.ink,
          alpha: m,
          lebar: s.width / 3);
    }
  }

  // Rantai kebiasaan kecil yang berujung retak.
  void _rantai(Canvas c, Size s) {
    const nama = [
      'Menggunjing',
      'Membawa omongan',
      'Dusta',
      'Buruk sangka',
      'Umat retak',
    ];
    final titik = [
      for (var k = 0; k < 5; k++)
        Offset(s.width * (0.12 + k * 0.19),
            s.height * (0.34 + (k.isOdd ? 0.28 : 0)))
    ];
    for (var k = 0; k < 4; k++) {
      _jejak(
          c,
          Path()
            ..moveTo(titik[k].dx, titik[k].dy)
            ..lineTo(titik[k + 1].dx, titik[k + 1].dy),
          _garis(w.faint, 2),
          _e(t, k * 0.18, 0.2 + k * 0.18));
    }
    for (var k = 0; k < 5; k++) {
      final m = _e(t, k * 0.18, 0.2 + k * 0.18);
      final akhir = k == 4;
      final r = (akhir ? 22.0 : 14.0) * m;
      c.drawCircle(titik[k], r, _isi(akhir ? w.accent : w.subtle));
      c.drawCircle(titik[k], r, _garis(akhir ? w.accent : w.ink, 1.4));
      if (akhir && m > 0.9) {
        c.drawPath(
            Path()
              ..moveTo(titik[k].dx - 3, titik[k].dy - r)
              ..lineTo(titik[k].dx + 4, titik[k].dy - 4)
              ..lineTo(titik[k].dx - 4, titik[k].dy + 4)
              ..lineTo(titik[k].dx + 2, titik[k].dy + r),
            _garis(w.surface, 2));
      }
      _tulis(c, nama[k],
          titik[k] + Offset(0, (k.isOdd ? 1 : -1) * ((akhir ? 22 : 14) + 18)),
          tebal: akhir,
          warna: akhir ? w.accent : w.ink,
          alpha: m,
          lebar: s.width * 0.24);
    }
  }

  // Dua kartu sunnah.
  void _sunnah(Canvas c, Size s) {
    const isi = [
      ['سنة الدلالة', 'Petunjuk', 'menghadapi hal baru: alat, media, cara'],
      ['سنة المواقف', 'Teladan sikap', 'akhlak ketika berselisih'],
    ];
    final lebar = (s.width - 16) / 2;
    for (var k = 0; k < 2; k++) {
      final m = _e(t, k * 0.2, 0.6 + k * 0.2);
      final a = w.accent.withValues(alpha: m);
      final r = Rect.fromLTWH(k * (lebar + 16), s.height * 0.06 + (1 - m) * 20,
          lebar, s.height * 0.88);
      c.drawRRect(RRect.fromRectAndRadius(r, _sudutBesar),
          _isi(w.subtle.withValues(alpha: m)));
      final ikon = Offset(r.center.dx, r.top + r.height * 0.22);
      c.drawCircle(ikon, 26, _garis(a, 2));
      if (k == 0) {
        c.drawPath(
            Path()
              ..moveTo(ikon.dx - 10, ikon.dy + 10)
              ..lineTo(ikon.dx + 10, ikon.dy - 10)
              ..moveTo(ikon.dx, ikon.dy - 10)
              ..lineTo(ikon.dx + 10, ikon.dy - 10)
              ..lineTo(ikon.dx + 10, ikon.dy),
            _garis(a, 2.2));
      } else {
        c.drawCircle(ikon - const Offset(7, 0), 10, _garis(a, 2));
        c.drawCircle(ikon + const Offset(7, 0), 10, _garis(a, 2));
      }
      _tulis(c, isi[k][0], Offset(r.center.dx, r.top + r.height * 0.48),
          arab: true, ukuran: OTFontSize.s22, alpha: m, lebar: lebar);
      _tulis(c, isi[k][1], Offset(r.center.dx, r.top + r.height * 0.66),
          tebal: true, ukuran: OTFontSize.s14, alpha: m, lebar: lebar - 16);
      _tulis(c, isi[k][2], Offset(r.center.dx, r.top + r.height * 0.82),
          warna: w.muted, alpha: m, lebar: lebar - 24);
    }
  }

  // Lisan dan tangan, masing-masing dilingkari pelindung.
  void _selamat(Canvas c, Size s) {
    final r = math.min(s.width * 0.18, s.height * 0.3);
    const nama = ['Lisan', 'Tangan'];
    for (var k = 0; k < 2; k++) {
      final o = Offset(s.width * (k == 0 ? 0.28 : 0.72), s.height * 0.42);
      c.drawCircle(o, r, _isi(w.subtle));
      _jejak(
          c,
          Path()
            ..addArc(Rect.fromCircle(center: o, radius: r + 8), -math.pi / 2,
                math.pi * 1.999),
          _garis(w.accent, 3),
          _e(t, 0.2 + k * 0.2, 0.8 + k * 0.2));
      final ik = _garis(w.ink, 2);
      if (k == 0) {
        final balon = RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: o - Offset(0, r * 0.08),
                width: r * 1.0,
                height: r * 0.7),
            Radius.circular(r * 0.2));
        c.drawRRect(balon, ik);
        c.drawPath(
            Path()
              ..moveTo(o.dx - r * 0.2, balon.bottom)
              ..lineTo(o.dx - r * 0.3, balon.bottom + r * 0.22)
              ..lineTo(o.dx, balon.bottom),
            ik);
      } else {
        final telapak = RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: o + Offset(0, r * 0.2),
                width: r * 0.7,
                height: r * 0.55),
            Radius.circular(r * 0.16));
        c.drawRRect(telapak, ik);
        for (var j = 0; j < 4; j++) {
          final x = telapak.left + r * 0.1 + j * r * 0.165;
          final pj = j == 0 || j == 3 ? 0.32 : 0.42;
          c.drawLine(
              Offset(x, telapak.top), Offset(x, telapak.top - r * pj), ik);
        }
      }
      _tulis(c, nama[k], o + Offset(0, r + 28),
          tebal: true, ukuran: OTFontSize.s14, alpha: _e(t, 0.5, 1));
    }
  }

  // Jalan tiga lajur; yang di pinggir kembali ke tengah.
  void _tengah(Canvas c, Size s) {
    final hilang = Offset(s.width / 2, s.height * 0.06);
    final bawah = s.height * 0.84;
    final lebar = s.width * 0.9;
    final xs = [
      for (var k = 0; k <= 3; k++) s.width / 2 - lebar / 2 + lebar * k / 3
    ];
    c.drawPath(
        Path()
          ..moveTo(hilang.dx - 2, hilang.dy)
          ..lineTo(hilang.dx + 2, hilang.dy)
          ..lineTo(xs[2], bawah)
          ..lineTo(xs[1], bawah)
          ..close(),
        _isi(w.accent.withValues(alpha: 0.18 * _e(t, 0.2, 0.6))));
    for (var k = 0; k <= 3; k++) {
      final tepi = k == 0 || k == 3;
      c.drawLine(hilang, Offset(xs[k], bawah),
          _garis(tepi ? w.ink : w.faint, tepi ? 2 : 1.4));
    }
    final m = _e(t, 0.4, 1);
    for (final kiri in [true, false]) {
      final mulai = Offset(
          kiri ? xs[0] + lebar * 0.14 : xs[3] - lebar * 0.14, bawah - 14);
      _jejak(
          c,
          Path()
            ..moveTo(mulai.dx, mulai.dy)
            ..quadraticBezierTo(
                mulai.dx, s.height * 0.45, s.width / 2, s.height * 0.36),
          _garis(w.accent, 2.6),
          m);
    }
    _tulis(c, 'kebablasan', Offset(xs[0] + lebar * 0.14, bawah + 14),
        warna: w.muted, alpha: m);
    _tulis(c, 'tertinggal', Offset(xs[3] - lebar * 0.14, bawah + 14),
        warna: w.muted, alpha: m);
    _tulis(c, 'tengah', Offset(s.width / 2, bawah + 14),
        warna: w.accent, tebal: true, alpha: m);
  }

  // Lingkaran terdekat di tengah riuhnya fitnah.
  void _lingkaran(Canvas c, Size s) {
    final o = Offset(s.width / 2, s.height * 0.5);
    final r = math.min(s.width, s.height) * 0.44;
    for (var k = 0; k < 70; k++) {
      final a = k * 2.399;
      final jarak = r * (1.08 + (math.sin(k * 7.1) * 0.5 + 0.5) * 0.6);
      c.drawCircle(
          o + Offset(math.cos(a) * jarak * 1.3, math.sin(a) * jarak * 0.8),
          1.6,
          _isi(w.muted.withValues(alpha: 0.5)));
    }
    const nama = ['Diri', 'Keluarga', 'Majelis kecil'];
    for (var k = 2; k >= 0; k--) {
      final m = _e(t, (2 - k) * 0.2, 0.5 + (2 - k) * 0.2);
      final rr = r * (0.34 + k * 0.33) * m;
      c.drawCircle(o, rr, _isi(k == 0 ? w.accent : w.subtle));
      c.drawCircle(o, rr, _garis(k == 0 ? w.accent : w.faint, 1.4));
      _tulis(c, nama[k], k == 0 ? o : o - Offset(0, rr - 13),
          tebal: k == 0, warna: k == 0 ? w.surface : w.ink, alpha: m);
    }
    _tulis(c, 'riuh di luar', Offset(s.width * 0.86, s.height * 0.06),
        warna: w.muted, ukuran: OTFontSize.s11, alpha: _e(t, 0.6, 1));
  }

  // Air, makanan, obat, dan ilmu ini lebih dibutuhkan.
  void _kebutuhan(Canvas c, Size s) {
    const nama = ['Air', 'Makanan', 'Obat'];
    final y = s.height * 0.7;
    for (var k = 0; k < 3; k++) {
      final m = _e(t, k * 0.12, 0.4 + k * 0.12);
      final o = Offset(s.width * (0.18 + k * 0.32), y);
      c.drawCircle(o, 24, _isi(w.subtle.withValues(alpha: m)));
      c.drawCircle(o, 24, _garis(w.faint, 1.2));
      final ik = _garis(w.muted.withValues(alpha: m), 1.8);
      if (k == 0) {
        c.drawPath(
            Path()
              ..moveTo(o.dx, o.dy - 11)
              ..quadraticBezierTo(o.dx + 10, o.dy + 2, o.dx, o.dy + 10)
              ..quadraticBezierTo(o.dx - 10, o.dy + 2, o.dx, o.dy - 11),
            ik);
      } else if (k == 1) {
        c.drawArc(Rect.fromCenter(center: o, width: 24, height: 20), 0, math.pi,
            false, ik);
        c.drawLine(o - const Offset(13, 0), o + const Offset(13, 0), ik);
      } else {
        c.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: o, width: 24, height: 11), _sudut),
            ik);
        c.drawLine(o - const Offset(0, 5), o + const Offset(0, 5), ik);
      }
      _tulis(c, nama[k], o + const Offset(0, 38), warna: w.muted, alpha: m);
    }
    final m = _e(t, 0.45, 1);
    final o = Offset(s.width / 2, s.height * 0.26);
    final r = 30 + 18 * m;
    c.drawCircle(o, r, _isi(w.accent.withValues(alpha: 0.2 * m)));
    c.drawCircle(o, r, _garis(w.accent, 2.4));
    _tulis(c, 'Ilmu ini', o, tebal: true, ukuran: OTFontSize.s14, alpha: m);
    _tulis(c, 'lebih dibutuhkan', o + Offset(0, r + 14),
        warna: w.accent, alpha: m);
  }

  // Rak kitab yang makin tinggi.
  void _rak(Canvas c, Size s) {
    const kitab = [
      'النبذة الصغرى',
      'الأسس والمنطلقات',
      'الإقليد',
      'المرصد النبوي',
    ];
    const ket = ['ringkas', 'definisi & peta', 'lima cabang', 'luas, 4 juz'];
    final dasar = s.height * 0.58;
    final lebar = s.width / 4;
    c.drawLine(Offset(0, dasar), Offset(s.width, dasar), _garis(w.ink, 2));
    for (var k = 0; k < 4; k++) {
      final m = _e(t, k * 0.15, 0.5 + k * 0.15);
      final tinggi = (s.height * 0.16 + k * s.height * 0.12) * m;
      final r = Rect.fromLTWH(
          k * lebar + lebar * 0.24, dasar - tinggi, lebar * 0.52, tinggi);
      final pertama = k == 0;
      final rr = RRect.fromRectAndRadius(r, _sudut);
      c.drawRRect(rr, _isi(pertama ? w.accent : w.subtle));
      c.drawRRect(rr, _garis(pertama ? w.accent : w.ink, 1.2));
      if (tinggi > 16) {
        c.drawLine(
            Offset(r.left + 4, r.top + 10),
            Offset(r.right - 4, r.top + 10),
            _garis(pertama ? w.surface : w.faint, 1.2));
      }
      _tulis(c, '${k + 1}', Offset(r.center.dx, r.top - 12),
          tebal: true, warna: pertama ? w.accent : w.muted, alpha: m);
      _tulis(c, kitab[k], Offset(k * lebar + lebar / 2, dasar + 34),
          arab: true, ukuran: OTFontSize.s14, alpha: m, lebar: lebar - 4);
      _tulis(c, ket[k], Offset(k * lebar + lebar / 2, dasar + 78),
          warna: w.muted, ukuran: OTFontSize.s11, alpha: m, lebar: lebar - 4);
    }
  }

  @override
  bool shouldRepaint(_Lukisan old) => old.t != t || old.g != g;
}
