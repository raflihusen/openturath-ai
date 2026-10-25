import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../core/app_snackbar.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import 'adaptive_sheet.dart';

/// Tombol info tiap AI (korpus V9.2).
/// Semua angka dibaca dari `assets/data/info_ai.json`, yang dihasilkan dari register
/// pemetaan (04_PIPELINE_DAN_RUANG_KERJA/v9_2/31_aset_aplikasi.py). Tidak ada angka
/// pengganti: bagian yang belum diisi pemilik (tentang, catatan penyusun, contoh
/// tanya-jawab) tidak ditampilkan.
class AiInfoSheet extends StatelessWidget {
  const AiInfoSheet({super.key, required this.info});

  final Map<String, dynamic> info;

  // Kunci metadata pustaka -> id di info_ai.json.
  static const Map<String, String> _alias = {
    'bahasa_arab': 'nahwu_sharaf',
    'tarikh_sirah': 'tarikh',
    'thabaqat_rijal': 'thabaqat_tarajim',
  };

  static Map<String, Map<String, dynamic>>? _cache;

  static Future<Map<String, dynamic>?> load(String key) async {
    if (_cache == null) {
      final raw = await rootBundle.loadString('assets/data/info_ai.json');
      _cache = {
        for (final e in (jsonDecode(raw) as List).cast<Map<String, dynamic>>())
          e['id'] as String: e
      };
    }
    return _cache![key] ?? _cache![_alias[key]];
  }

  static Future<void> show(BuildContext context, String key) async {
    final info = await load(key);
    if (info == null || !context.mounted) return;
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showAdaptiveSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OTColors.canvas(isDark),
      showDragHandle: true,
      builder: (_) => AiInfoSheet(info: info),
    );
  }

  static String number(num? n) {
    if (n == null) return '–';
    final s = n.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }

  static String words(num? n) {
    if (n == null || n == 0) return '–';
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1).replaceAll('.', ',')} juta';
    }
    return number(n);
  }

  static const _libraryNames = {
    'hazmi': 'Hazmi',
    'baru': 'Maktabah Baru',
    'shamela4': 'Shamela 4',
    'modul_06_kitab': 'Kitab',
    'youtube_tiga_kanal': 'Video YouTube',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final surface = OTColors.surfaceSubtle(isDark);
    final line = OTColors.border(isDark);

    final content = (info['isi'] ?? {}) as Map<String, dynamic>;
    final method = (info['cara_disusun'] ?? {}) as Map<String, dynamic>;
    final limits = ((info['batasan'] ?? []) as List).cast<String>();
    final examples = ((info['contoh_tanya_jawab'] ?? []) as List)
        .cast<Map<String, dynamic>>();
    final about = (info['tentang'] ?? '').toString();
    final questions = ((info['contoh_pertanyaan'] ?? []) as List)
        .cast<Map<String, dynamic>>();
    final note = (method['catatan_penyusun'] ?? '').toString();
    final range = content['rentang_wafat_pengarang'];
    final largest =
        ((content['kitab_induk'] ?? []) as List).cast<Map<String, dynamic>>();
    final branches = ((content['cabang_ilmu'] ?? []) as List)
        .cast<Map<String, dynamic>>()
        .where((c) => c['nama'] != null)
        .map((c) => c['nama'].toString())
        .toList();
    final origin = (content['perpustakaan_asal'] ?? {}) as Map<String, dynamic>;
    final lectures = content['jumlah_muhadharah'] as num?;

    Text label(String t) => Text(t,
        style: ScholarlyFonts.outfit(
            fontSize: OTFontSize.s16, fontWeight: FontWeight.w700, color: ink));
    Widget heading(String t) => Padding(
        padding: const EdgeInsets.only(top: OTSpacing.xl, bottom: OTSpacing.md),
        child: label(t));
    Widget row(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: OTSpacing.sm),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Text(k,
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14, color: muted))),
            const SizedBox(width: OTSpacing.md),
            Flexible(
                child: Text(v,
                    textAlign: TextAlign.end,
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14,
                        fontWeight: FontWeight.w600,
                        color: ink))),
          ]),
        );
    Widget point(String t) => Padding(
          padding: const EdgeInsets.only(bottom: OTSpacing.sm),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('•  ',
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s14, color: ink)),
            Expanded(
                child: Text(t,
                    style: ScholarlyFonts.outfit(
                        fontSize: OTFontSize.s14, height: 1.5, color: ink))),
          ]),
        );
    Widget stat(String v, String k) => Container(
          width: 112,
          padding: const EdgeInsets.all(OTSpacing.md),
          decoration: BoxDecoration(
              color: surface,
              borderRadius: OTRadius.xsBorder,
              border: Border.all(color: line)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v,
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s18,
                    fontWeight: FontWeight.w700,
                    color: ink)),
            const SizedBox(height: OTSpacing.xxs),
            Text(k,
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s12, color: muted)),
          ]),
        );

    final rangeText = range is Map && range['akhir'] != null
        ? '${(range['sebelum_hijrah'] ?? 0) > 0 ? 'Pra-Hijrah' : 'w. ${range['awal']} H'} – w. ${range['akhir']} H'
        : null;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              OTSpacing.xl, 0, OTSpacing.xl, OTSpacing.xxl),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(info['judul']?.toString() ?? '',
                style: ScholarlyFonts.outfit(
                    fontSize: OTFontSize.s20,
                    fontWeight: FontWeight.w700,
                    color: ink)),
            Text(info['nama_arab']?.toString() ?? '',
                textDirection: TextDirection.rtl,
                style: ScholarlyFonts.scheherazadeNew(
                    fontSize: OTFontSize.s18, color: muted)),
            if (about.isNotEmpty) ...[
              heading('Tentang'),
              Text(about,
                  style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14, height: 1.55, color: ink)),
            ],
            if (questions.isNotEmpty) ...[
              heading('Coba tanyakan'),
              for (final q in questions)
                Padding(
                  padding: const EdgeInsets.only(bottom: OTSpacing.sm),
                  child: InkWell(
                    borderRadius: OTRadius.xsBorder,
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: q['teks']?.toString() ?? ''));
                      AppSnackBar.show(context, message: 'Pertanyaan disalin');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(OTSpacing.md),
                      decoration: BoxDecoration(
                          color: surface, borderRadius: OTRadius.xsBorder),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q['jenis']?.toString() ?? '',
                                style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s12, color: muted)),
                            const SizedBox(height: OTSpacing.xxs),
                            Text(q['teks']?.toString() ?? '',
                                textDirection: RegExp(r'^[\u0600-\u06FF]')
                                        .hasMatch(q['teks']?.toString() ?? '')
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: RegExp(r'^[\u0600-\u06FF]')
                                        .hasMatch(q['teks']?.toString() ?? '')
                                    ? ScholarlyFonts.scheherazadeNew(
                                        fontSize: OTFontSize.s16, color: ink)
                                    : ScholarlyFonts.outfit(
                                        fontSize: OTFontSize.s14,
                                        height: 1.45,
                                        color: ink)),
                          ]),
                    ),
                  ),
                ),
            ],
            heading('Isi'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              stat(number(content['jumlah_kitab'] as num?), 'Kitab'),
              if (lectures != null) stat(number(lectures), 'Ceramah'),
              stat(words(content['jumlah_kata'] as num?), 'Kata teks'),
              stat(number(method['berkas_notebooklm'] as num?),
                  'Berkas terindeks'),
            ]),
            const SizedBox(height: OTSpacing.sm),
            if (rangeText != null) row('Rentang wafat pengarang', rangeText),
            if (origin.isNotEmpty)
              row(
                  'Cetakan terpilih dari',
                  origin.entries
                      .map((e) =>
                          '${_libraryNames[e.key] ?? e.key} ${number(e.value as num?)}')
                      .join(' · ')),
            if (branches.isNotEmpty) ...[
              const SizedBox(height: OTSpacing.md),
              Wrap(spacing: 6, runSpacing: 6, children: [
                for (final b in branches)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md, vertical: OTSpacing.xs),
                    decoration: BoxDecoration(
                        color: surface, borderRadius: OTRadius.chipBorder),
                    child: Text(b,
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s12, color: ink)),
                  ),
              ]),
            ],
            if (largest.isNotEmpty) ...[
              heading('Kitab terbesar'),
              for (final k in largest)
                Padding(
                  padding: const EdgeInsets.only(bottom: OTSpacing.sm),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                        '${k['judul']} — ${k['pengarang'] ?? ''}${k['wafat'] != null ? ' (ت ${k['wafat']} هـ)' : ''}',
                        style: ScholarlyFonts.scheherazadeNew(
                            fontSize: OTFontSize.s16, color: ink)),
                  ),
                ),
            ],
            if (lectures != null) ...[
              const SizedBox(height: OTSpacing.sm),
              OutlinedButton.icon(
                icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                label: Text('Daftar ${number(lectures)} ceramah'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const TahawwulatLectureListPage())),
              ),
            ],
            heading('Cara disusun'),
            row('Judul kitab disaring (semua ilmu)',
                number(method['rekaman_diperiksa_semua_ilmu'] as num?)),
            if (method['rekaman_digabung_ke_kitab_ini'] != null)
              row('Rekaman dan cetakan yang dibandingkan untuk AI ini',
                  number(method['rekaman_digabung_ke_kitab_ini'] as num?)),
            row('Karya yang tidak dipakai (semua ilmu)',
                number(method['karya_diblok_semua_ilmu'] as num?)),
            row('Karya yang ditahan sampai terverifikasi',
                number(method['karya_ditahan_semua_ilmu'] as num?)),
            row('Duplikat yang disaring',
                number(method['karya_termuat_semua_ilmu'] as num?)),
            const SizedBox(height: OTSpacing.sm),
            for (final u in ((method['uji'] ?? []) as List))
              point(u.toString()),
            if (note.isNotEmpty) ...[
              const SizedBox(height: OTSpacing.sm),
              Text(note,
                  style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14, height: 1.55, color: ink)),
            ],
            heading('Batasan'),
            for (final b in limits) point(b),
            if (examples.isNotEmpty) ...[
              heading('Contoh tanya-jawab'),
              for (final c in examples)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: OTSpacing.md),
                  padding: const EdgeInsets.all(OTSpacing.md),
                  decoration: BoxDecoration(
                      color: surface,
                      borderRadius: OTRadius.xsBorder,
                      border: Border.all(color: line)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['tanya']?.toString() ?? '',
                            style: ScholarlyFonts.outfit(
                                fontSize: OTFontSize.s14,
                                fontWeight: FontWeight.w600,
                                color: ink)),
                        const SizedBox(height: OTSpacing.sm),
                        Text(c['jawab']?.toString() ?? '',
                            style: ScholarlyFonts.outfit(
                                fontSize: OTFontSize.s14,
                                height: 1.5,
                                color: ink)),
                        if ((c['rujukan'] ?? '').toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: OTSpacing.sm),
                            child: Text(c['rujukan'].toString(),
                                style: ScholarlyFonts.outfit(
                                    fontSize: OTFontSize.s12, color: muted)),
                          ),
                      ]),
                ),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Daftar ceramah Fikih Tahawwulat: judul apa adanya dari sumber, kanal, durasi, tautan YouTube.
class TahawwulatLectureListPage extends StatefulWidget {
  const TahawwulatLectureListPage({super.key});

  @override
  State<TahawwulatLectureListPage> createState() =>
      _TahawwulatLectureListPageState();
}

class _TahawwulatLectureListPageState extends State<TahawwulatLectureListPage> {
  List<Map<String, dynamic>> _all = const [];
  String _query = '';
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    rootBundle
        .loadString('assets/data/06_KATALOG_MUHADHARAH_TAHAWWULAT.json')
        .then((raw) {
      if (!mounted) return;
      setState(() {
        _all = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(isDark);
    final muted = OTColors.textSecondary(isDark);
    final visible = _query.isEmpty
        ? _all
        : _all
            .where((v) =>
                '${v['عنوان_المحاضرة']} ${v['القناة']} ${v['السلسلة']}'
                    .contains(_query))
            .toList();
    return Scaffold(
      backgroundColor: OTColors.canvas(isDark),
      appBar: AppBar(
          backgroundColor: OTColors.canvas(isDark),
          title: const Text('Ceramah Fikih Tahawwulat')),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    OTSpacing.base, OTSpacing.sm, OTSpacing.base, OTSpacing.sm),
                child: TextField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Cari judul ceramah'),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      OTSpacing.base, 0, OTSpacing.base, OTSpacing.xl),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: OTColors.border(isDark)),
                  itemBuilder: (context, i) {
                    final v = visible[i];
                    final url = Uri.tryParse(v['الرابط']?.toString() ?? '');
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: OTSpacing.xs),
                      title: Text(v['عنوان_المحاضرة']?.toString() ?? '',
                          textDirection: TextDirection.rtl,
                          style: ScholarlyFonts.scheherazadeNew(
                              fontSize: OTFontSize.s16, color: ink)),
                      subtitle: Text('${v['القناة']} · ${v['المدة']}',
                          textDirection: TextDirection.rtl,
                          style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s12, color: muted)),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: url == null
                          ? null
                          : () => launchUrl(url,
                              mode: LaunchMode.externalApplication),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}
