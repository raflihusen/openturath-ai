import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../core/app_platform.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_motion.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';
import '../models/sub_agent_model.dart';
import 'adaptive_sheet.dart';

/// Pengantar Fikih Tahawwulat dalam bentuk slide animasi.
///
/// Animasi dirender dengan Remotion dari `openturath_motion/src/tahawwulat`.
/// Naskah yang sama diekspor ke `assets/data/pengantar_tahawwulat.json`
/// (waktu mulai tiap slide, bab, dan teks lengkap), sehingga:
/// - setiap slide bisa dilompati dan diputar ulang;
/// - teks slide tersedia untuk pembaca layar dan untuk dibaca tanpa video.
class TahawwulatIntroductionSheet extends StatefulWidget {
  final AgentModel? agent;
  final void Function(SubAgentModel subAgent)? onSelectSubAgent;
  final VoidCallback? onOpenMain;

  /// Halaman penuh dengan AppBar; false = lembar bawah.
  final bool asPage;

  /// Slide yang dibuka pertama.
  final int initialSection;

  /// Untuk tes: lewati pemutar video dan tampilkan transkrip saja.
  @visibleForTesting
  final bool videoEnabled;

  /// Untuk tes: naskah langsung, tanpa membaca aset.
  @visibleForTesting
  final PengantarNaskah? naskah;

  const TahawwulatIntroductionSheet({
    super.key,
    this.agent,
    this.onSelectSubAgent,
    this.onOpenMain,
    this.asPage = true,
    this.initialSection = 0,
    this.videoEnabled = true,
    this.naskah,
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

// ── Naskah ────────────────────────────────────────────────────────────────

class PengantarBab {
  const PengantarBab(this.no, this.judul);
  final int no;
  final String judul;
}

class PengantarBaris {
  const PengantarBaris(this.nama, this.arab, this.ilmu);
  final String nama;
  final String arab;
  final String ilmu;
}

class PengantarKolom {
  const PengantarKolom(this.judul, this.arab, this.isi);
  final String judul;
  final String arab;
  final List<String> isi;
}

class PengantarSlide {
  const PengantarSlide({
    required this.id,
    required this.bab,
    required this.judul,
    required this.mulai,
    required this.durasi,
    this.sub,
    this.arab,
    this.nama,
    this.poin = const [],
    this.kolom = const [],
    this.daftar = const [],
    this.ibarah,
    this.makna,
    this.kunci,
    this.sumber,
  });

  final String id;
  final int bab;
  final String judul;
  final Duration mulai;
  final Duration durasi;
  final String? sub, arab, nama, ibarah, makna, kunci, sumber;
  final List<String> poin;
  final List<PengantarKolom> kolom;
  final List<PengantarBaris> daftar;

  Duration get akhir => mulai + durasi;

  factory PengantarSlide.fromJson(Map<String, dynamic> j) {
    PengantarKolom? kolom(Object? o) {
      if (o is! Map<String, dynamic>) return null;
      return PengantarKolom(o['judul'] as String, o['arab'] as String? ?? '',
          [for (final x in (o['isi'] as List? ?? const [])) x as String]);
    }

    return PengantarSlide(
      id: j['id'] as String,
      bab: j['bab'] as int,
      judul: j['judul'] as String,
      mulai: Duration(milliseconds: j['mulai_ms'] as int),
      durasi: Duration(milliseconds: j['durasi_ms'] as int),
      sub: j['sub'] as String?,
      arab: j['arab'] as String?,
      nama: j['nama'] as String?,
      poin: [for (final x in (j['poin'] as List? ?? const [])) x as String],
      kolom: [
        for (final k in [kolom(j['kiri']), kolom(j['kanan'])])
          if (k != null) k
      ],
      daftar: [
        for (final r in (j['rukun'] as List? ?? const []))
          PengantarBaris(
              r['nama'] as String, r['arab'] as String, r['ilmu'] as String)
      ],
      ibarah: j['ibarah'] as String?,
      makna: j['makna'] as String?,
      kunci: j['kunci'] as String?,
      sumber: j['sumber'] as String?,
    );
  }
}

class PengantarNaskah {
  const PengantarNaskah(
      {required this.video, required this.bab, required this.slide});
  final String video;
  final List<PengantarBab> bab;
  final List<PengantarSlide> slide;

  static const aset = 'assets/data/pengantar_tahawwulat.json';

  factory PengantarNaskah.fromJson(Map<String, dynamic> j) => PengantarNaskah(
        video: j['video'] as String,
        bab: [
          for (final b in j['bab'] as List)
            PengantarBab(b['no'] as int, b['judul'] as String)
        ],
        slide: [
          for (final s in j['slide'] as List)
            PengantarSlide.fromJson(s as Map<String, dynamic>)
        ],
      );

  static Future<PengantarNaskah> muat([AssetBundle? bundle]) async =>
      PengantarNaskah.fromJson(
          jsonDecode(await (bundle ?? rootBundle).loadString(aset))
              as Map<String, dynamic>);

  /// Indeks slide yang sedang tampil pada posisi [t].
  int indeksPada(Duration t) {
    for (var i = slide.length - 1; i >= 0; i--) {
      if (t >= slide[i].mulai) return i;
    }
    return 0;
  }

  /// Slide pertama di setiap bab, untuk menu bab.
  List<int> get awalBab => [
        for (final b in bab)
          if (slide.indexWhere((s) => s.bab == b.no) >= 0)
            slide.indexWhere((s) => s.bab == b.no)
      ];
}

// ── Layar ─────────────────────────────────────────────────────────────────

/// Rasio kanvas Remotion (1080 x 1350).
const double _rasio = 1080 / 1350;

class _TahawwulatIntroductionSheetState
    extends State<TahawwulatIntroductionSheet> {
  PengantarNaskah? _naskah;
  VideoPlayerController? _video;
  Object? _galat;
  int _i = 0;
  bool _transkrip = false;
  final FocusNode _fokus = FocusNode();
  final ScrollController _gulir = ScrollController();

  @override
  void initState() {
    super.initState();
    _siapkan();
  }

  Future<void> _siapkan() async {
    try {
      final naskah = widget.naskah ?? await PengantarNaskah.muat();
      if (!mounted) return;
      final awal = widget.initialSection.clamp(0, naskah.slide.length - 1);
      setState(() {
        _naskah = naskah;
        _i = awal;
        _transkrip = !widget.videoEnabled;
      });
      if (!widget.videoEnabled) return;
      final video = VideoPlayerController.asset(naskah.video);
      await video.initialize();
      if (!mounted) {
        await video.dispose();
        return;
      }
      await video.seekTo(naskah.slide[awal].mulai);
      if (!mounted) {
        await video.dispose();
        return;
      }
      video.addListener(_ikuti);
      setState(() => _video = video);
      // Gerak dikurangi: tampilkan bingkai akhir slide, tanpa putar otomatis.
      if (_gerakDikurangi) {
        await video.seekTo(
            naskah.slide[awal].akhir - const Duration(milliseconds: 40));
      } else {
        await video.play();
      }
    } catch (e) {
      if (mounted) setState(() => _galat = e);
    }
  }

  /// Sinkronkan indeks slide dengan posisi video.
  void _ikuti() {
    final v = _video, n = _naskah;
    if (v == null || n == null || !mounted) return;
    final i = n.indeksPada(v.value.position);
    if (i != _i) setState(() => _i = i);
    if (v.value.isCompleted || v.value.position >= n.slide.last.akhir) {
      if (v.value.isPlaying) v.pause();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _video?.removeListener(_ikuti);
    _video?.dispose();
    _fokus.dispose();
    _gulir.dispose();
    super.dispose();
  }

  bool get _gerakDikurangi => MediaQuery.disableAnimationsOf(context);

  Future<void> _ke(int i, {bool putar = true}) async {
    final n = _naskah;
    if (n == null || i < 0 || i >= n.slide.length) return;
    OTMotion.selection();
    setState(() => _i = i);
    final v = _video;
    if (v != null) {
      await v.seekTo(n.slide[i].mulai);
      if (putar && mounted && !_gerakDikurangi) await v.play();
    }
  }

  void _putarJeda() {
    final v = _video;
    if (v == null) return;
    OTMotion.light();
    if (v.value.isPlaying) {
      v.pause();
    } else {
      final n = _naskah!;
      if (v.value.position >=
          n.slide.last.akhir - const Duration(milliseconds: 100)) {
        _ke(0);
        return;
      }
      v.play();
    }
    setState(() {});
  }

  KeyEventResult _tombol(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowRight) {
      _ke(_i + 1);
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _ke(_i - 1);
    } else if (k == LogicalKeyboardKey.space) {
      _putarJeda();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isi = Focus(
      focusNode: _fokus,
      autofocus: true,
      onKeyEvent: _tombol,
      child: _isi(context, isDark),
    );
    // Materi berbahasa Indonesia tetap LTR di antarmuka Arab (DESIGN.md).
    final badan = Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120), child: isi),
      ),
    );
    if (widget.asPage) {
      return Scaffold(
        backgroundColor: OTColors.canvas(isDark),
        appBar: AppBar(
          backgroundColor: OTColors.canvas(isDark),
          title: const Text('Mengenal Fikih Tahawwulat'),
          actions: [
            if (_naskah != null && widget.videoEnabled)
              IconButton(
                tooltip: _transkrip ? 'Tampilkan animasi' : 'Baca teks slide',
                onPressed: () => setState(() => _transkrip = !_transkrip),
                icon: Icon(
                    _transkrip
                        ? Icons.play_circle_outline_rounded
                        : Icons.notes_rounded,
                    semanticLabel:
                        _transkrip ? 'Tampilkan animasi' : 'Baca teks slide'),
              ),
          ],
        ),
        body: SafeArea(child: badan),
      );
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
          color: OTColors.canvas(isDark), borderRadius: OTRadius.sheetBorder),
      child: SafeArea(top: false, child: badan),
    );
  }

  Widget _isi(BuildContext context, bool isDark) {
    final n = _naskah;
    if (n == null) {
      return Center(
        child: _galat == null
            ? const CircularProgressIndicator()
            : Text('Belum dapat memuat pengantar.',
                style:
                    OTTypography.body(color: OTColors.textSecondary(isDark))),
      );
    }
    return LayoutBuilder(builder: (context, box) {
      final lebar = box.maxWidth >= 880;
      final panggung = _transkrip || _galat != null || _video == null
          ? _teksSlide(n.slide[_i], isDark)
          : _layar(isDark);
      final kontrol = _kontrol(n, isDark);
      if (lebar) {
        return Padding(
          padding: const EdgeInsets.all(OTSpacing.xl),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              flex: 3,
              child: Column(children: [
                Expanded(child: Center(child: panggung)),
                const SizedBox(height: OTSpacing.base),
                kontrol,
              ]),
            ),
            const SizedBox(width: OTSpacing.xl),
            SizedBox(width: 320, child: _daftarBab(n, isDark)),
          ]),
        );
      }
      return Column(children: [
        if (!widget.asPage) _pegangan(isDark),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                OTSpacing.base, OTSpacing.sm, OTSpacing.base, 0),
            child: Center(child: panggung),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              OTSpacing.base, OTSpacing.md, OTSpacing.base, OTSpacing.md),
          child: kontrol,
        ),
      ]);
    });
  }

  Widget _pegangan(bool isDark) => Padding(
        padding: const EdgeInsets.only(top: OTSpacing.md),
        child: Row(children: [
          const SizedBox(width: OTSpacing.base),
          Expanded(
            child: Text('Mengenal Fikih Tahawwulat',
                style: OTTypography.cardTitle(
                    color: OTColors.textPrimary(isDark))),
          ),
          if (widget.videoEnabled)
            IconButton(
              tooltip: _transkrip ? 'Tampilkan animasi' : 'Baca teks slide',
              onPressed: () => setState(() => _transkrip = !_transkrip),
              icon: Icon(_transkrip
                  ? Icons.play_circle_outline_rounded
                  : Icons.notes_rounded),
            ),
          IconButton(
            tooltip: 'Tutup',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: OTSpacing.xs),
        ]),
      );

  /// Video slide, rasio tetap 4:5, sudut kartu.
  Widget _layar(bool isDark) {
    final v = _video!;
    final s = _naskah!.slide[_i];
    return AspectRatio(
      aspectRatio: _rasio,
      child: Semantics(
        label: 'Slide ${_i + 1}: ${s.judul}',
        hint: v.value.isPlaying ? 'Ketuk untuk jeda' : 'Ketuk untuk memutar',
        button: true,
        child: GestureDetector(
          onTap: _putarJeda,
          child: ClipRRect(
            borderRadius: OTRadius.cardBorder,
            child: Stack(fit: StackFit.expand, children: [
              ColoredBox(color: OTColors.surface(isDark)),
              VideoPlayer(v),
              AnimatedOpacity(
                opacity: v.value.isPlaying ? 0 : 1,
                duration: OTMotion.fast,
                child: Center(
                  child: Container(
                    width: OTSpacing.jumbo,
                    height: OTSpacing.jumbo,
                    decoration: BoxDecoration(
                        color: OTColors.shadow.withValues(alpha: 0.55),
                        borderRadius: OTRadius.chipBorder),
                    child: Icon(Icons.play_arrow_rounded,
                        size: OTFontSize.s36, color: OTColors.onAccent(false)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// Kemajuan per slide, tombol sebelumnya / putar / berikutnya.
  Widget _kontrol(PengantarNaskah n, bool isDark) {
    final v = _video;
    final s = n.slide[_i];
    final pos = v?.value.position ?? s.mulai;
    final dalam = s.durasi.inMilliseconds == 0
        ? 0.0
        : ((pos - s.mulai).inMilliseconds / s.durasi.inMilliseconds)
            .clamp(0.0, 1.0);
    final akhir = _i == n.slide.length - 1;
    final ink = OTColors.textPrimary(isDark);
    final bab = n.bab.firstWhere((b) => b.no == s.bab,
        orElse: () => PengantarBab(s.bab, ''));
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Bilah: satu ruas per slide; ruas aktif terisi sesuai waktu.
      Semantics(
        label: 'Slide ${_i + 1} dari ${n.slide.length}',
        child: SizedBox(
          height: OTSpacing.base,
          child: Row(children: [
            for (var k = 0; k < n.slide.length; k++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _ke(k),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ClipRRect(
                      borderRadius: OTRadius.xsBorder,
                      child: LinearProgressIndicator(
                        value: k < _i
                            ? 1
                            : (k == _i ? (v == null ? 1 : dalam) : 0),
                        minHeight: 3,
                        backgroundColor: OTColors.border(isDark),
                        color: ink,
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ),
      const SizedBox(height: OTSpacing.sm),
      Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              s.bab == 0
                  ? 'PENGANTAR'
                  : 'BAB ${s.bab.toString().padLeft(2, '0')} · ${bab.judul.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ScholarlyFonts.outfit(
                  fontSize: OTFontSize.s11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: OTColors.textSecondary(isDark)),
            ),
            const SizedBox(height: OTSpacing.xxs),
            Text('${_i + 1} / ${n.slide.length}',
                style: ScholarlyFonts.outfit(
                    textStyle: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()]),
                    fontSize: OTFontSize.s12,
                    color: OTColors.textSecondary(isDark))),
          ]),
        ),
        IconButton(
          tooltip: 'Slide sebelumnya',
          onPressed: _i == 0 ? null : () => _ke(_i - 1),
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        if (v != null && !_transkrip)
          IconButton(
            tooltip: v.value.isPlaying ? 'Jeda' : 'Putar',
            onPressed: _putarJeda,
            icon: Icon(v.value.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded),
          ),
        IconButton(
          tooltip: 'Ulangi slide ini',
          onPressed: () => _ke(_i),
          icon: const Icon(Icons.replay_rounded),
        ),
        IconButton(
          tooltip: 'Slide berikutnya',
          onPressed: akhir ? null : () => _ke(_i + 1),
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ]),
      // Aksi primer hanya di slide terakhir, satu baris penuh agar tidak berdesakan.
      if (akhir) ...[
        const SizedBox(height: OTSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onOpenMain == null
                ? () => Navigator.of(context).maybePop()
                : () {
                    Navigator.of(context).maybePop();
                    widget.onOpenMain!();
                  },
            child:
                Text(widget.onOpenMain == null ? 'Selesai' : 'Mulai bertanya'),
          ),
        ),
      ],
    ]);
  }

  /// Menu bab di desktop: daftar bab, slide aktif ditandai.
  Widget _daftarBab(PengantarNaskah n, bool isDark) {
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    return Container(
      decoration: BoxDecoration(
          color: OTColors.surface(isDark), borderRadius: OTRadius.cardBorder),
      child: ListView(
        controller: _gulir,
        padding: const EdgeInsets.symmetric(vertical: OTSpacing.md),
        children: [
          for (final b in n.bab) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xs),
              child: Text(
                  b.no == 0
                      ? 'PENGANTAR'
                      : 'BAB ${b.no.toString().padLeft(2, '0')} · ${b.judul.toUpperCase()}',
                  style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: muted)),
            ),
            for (var k = 0; k < n.slide.length; k++)
              if (n.slide[k].bab == b.no)
                Semantics(
                  selected: k == _i,
                  button: true,
                  child: InkWell(
                    onTap: () => _ke(k),
                    child: AnimatedContainer(
                      duration: OTMotion.fast,
                      margin:
                          const EdgeInsets.symmetric(horizontal: OTSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                          horizontal: OTSpacing.md, vertical: OTSpacing.sm),
                      decoration: BoxDecoration(
                          color: k == _i
                              ? OTColors.surfaceSubtle(isDark)
                              : Colors.transparent,
                          borderRadius: OTRadius.xsBorder),
                      child: Row(children: [
                        SizedBox(
                          width: OTSpacing.xxl,
                          child: Text((k + 1).toString().padLeft(2, '0'),
                              style: ScholarlyFonts.outfit(
                                  textStyle: const TextStyle(fontFeatures: [
                                    FontFeature.tabularFigures()
                                  ]),
                                  fontSize: OTFontSize.s12,
                                  fontWeight: FontWeight.w600,
                                  color: k == _i ? ink : muted)),
                        ),
                        Expanded(
                          child: Text(n.slide[k].judul,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
                                  fontWeight: k == _i
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: ink)),
                        ),
                      ]),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  /// Isi slide sebagai teks: untuk pembaca layar, mode baca, dan bila video gagal.
  Widget _teksSlide(PengantarSlide s, bool isDark) {
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final teks = OTTypography.body(color: ink);
    Widget arab(String t, {double ukuran = OTFontSize.s22}) => Align(
          alignment: Alignment.centerRight,
          child: Text(t,
              textDirection: TextDirection.rtl,
              style: ScholarlyFonts.scheherazadeNew(
                  fontSize: ukuran, height: 1.85, color: ink)),
        );
    Widget kartu(Widget child) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(OTSpacing.base),
          decoration: BoxDecoration(
              color: OTColors.surface(isDark),
              borderRadius: OTRadius.cardBorder),
          child: child,
        );
    return AnimatedSwitcher(
      duration: OTMotion.normal,
      child: SingleChildScrollView(
        key: ValueKey(s.id),
        padding: const EdgeInsets.symmetric(vertical: OTSpacing.base),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.judul, style: OTTypography.editorialHero(color: ink)),
          const SizedBox(height: OTSpacing.md),
          if (s.arab != null) ...[arab(s.arab!, ukuran: OTFontSize.s26)],
          if (s.nama != null)
            Text(s.nama!, style: OTTypography.bookTitle(color: ink)),
          if (s.sub != null) ...[
            const SizedBox(height: OTSpacing.sm),
            Text(s.sub!, style: OTTypography.body(color: muted)),
          ],
          for (final p in s.poin) ...[
            const SizedBox(height: OTSpacing.sm),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: OTSpacing.sm, right: OTSpacing.md),
                child: Icon(Icons.circle, size: OTSpacing.sm, color: ink),
              ),
              Expanded(child: Text(p, style: teks)),
            ]),
          ],
          for (final k in s.kolom) ...[
            const SizedBox(height: OTSpacing.md),
            kartu(
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (k.arab.isNotEmpty) arab(k.arab, ukuran: OTFontSize.s20),
              Text(k.judul, style: OTTypography.bodyMedium(color: ink)),
              for (final x in k.isi)
                Text(x, style: OTTypography.caption(color: muted)),
            ])),
          ],
          if (s.daftar.isNotEmpty) ...[
            const SizedBox(height: OTSpacing.md),
            kartu(Column(children: [
              for (var k = 0; k < s.daftar.length; k++) ...[
                if (k > 0)
                  Divider(
                      height: OTSpacing.base,
                      color: OTColors.borderSubtle(isDark)),
                Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${k + 1}. ${s.daftar[k].nama}',
                              style: OTTypography.bodyMedium(color: ink)),
                          Text(s.daftar[k].ilmu.replaceAll('|', ' → '),
                              style: OTTypography.caption(color: muted)),
                        ]),
                  ),
                  if (s.daftar[k].arab.isNotEmpty) ...[
                    const SizedBox(width: OTSpacing.md),
                    Flexible(
                      child: Text(s.daftar[k].arab,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: ScholarlyFonts.scheherazadeNew(
                              fontSize: OTFontSize.s18,
                              height: 1.85,
                              color: ink)),
                    )
                  ],
                ]),
              ],
            ])),
          ],
          if (s.ibarah != null) ...[
            const SizedBox(height: OTSpacing.md),
            kartu(Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  arab('«${s.ibarah}»'),
                  if (s.makna != null) ...[
                    Divider(
                        height: OTSpacing.base,
                        color: OTColors.borderSubtle(isDark)),
                    Text(s.makna!,
                        style: ScholarlyFonts.newsreader(
                            fontSize: OTFontSize.s16,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            color: ink)),
                  ],
                ])),
          ],
          if (s.kunci != null) ...[
            const SizedBox(height: OTSpacing.md),
            Text(s.kunci!,
                style: ScholarlyFonts.newsreader(
                    fontSize: OTFontSize.s18, height: 1.4, color: ink)),
          ],
          if (s.sumber != null) ...[
            const SizedBox(height: OTSpacing.sm),
            Text(s.sumber!, style: OTTypography.captionMedium(color: muted)),
          ],
          if (s.id == 'limaai' && widget.onSelectSubAgent != null) ...[
            const SizedBox(height: OTSpacing.md),
            _pilihAi(isDark),
          ],
        ]),
      ),
    );
  }

  /// Pada slide lima AI (mode teks): baris yang langsung membuka AI.
  Widget _pilihAi(bool isDark) {
    final subs = widget.agent?.subAgents ?? const <SubAgentModel>[];
    final daftar = _naskah!.slide[_i].daftar;
    return Column(children: [
      for (final r in daftar)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(r.nama),
          subtitle: Text(r.ilmu),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () {
            final id =
                'fiqh_tahawwulat_${r.nama.replaceFirst('Al-', '').toLowerCase()}';
            final sub = subs.where((s) => s.id == id).firstOrNull;
            if (sub == null) return;
            Navigator.of(context).maybePop();
            widget.onSelectSubAgent!(sub);
          },
        ),
    ]);
  }
}
