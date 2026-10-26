import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design/ot_buttons.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';
import '../models/hadith_takhrij_models.dart';
import '../services/harf_morphology_service.dart';
import '../services/universal_takhrij_engine.dart';
import '../widgets/hadith_isnad_dag_canvas.dart';
import '../widgets/hadith_takhrij_components.dart';
import '../widgets/ot_components.dart';
import '../widgets/ot_motion_widgets.dart';

/// Lima mode kerja di dalam Meja Telaah Hadis & Takhrij Universal.
enum HadithWorkspaceMode {
  takhrijAndMuqaranah,
  matnAndMujamma,
  tasyjirAndIlal,
  rijalAndMuhmal,
  manuscriptAutoTakhrij,
}

/// Sesi tab telaah hadis (maksimum 5 tab paralel sesuai Aturan Sakral #7 AGENTS.md).
class _HadithStudyTabSession {
  final String id;
  CanonicalHadithRecord activeHadith;
  HadithWorkspaceMode mode;
  TakhrijSortOrder sortOrder;
  bool includeNonCore33Books;
  String? selectedRawiId;

  _HadithStudyTabSession({
    required this.id,
    required this.activeHadith,
    this.mode = HadithWorkspaceMode.takhrijAndMuqaranah,
    this.sortOrder = TakhrijSortOrder.byCanonicalBookRank,
    this.includeNonCore33Books = true,
    this.selectedRawiId,
  });
}

/// Meja Telaah Hadis & Takhrij Ribuan Kitab (Rekonstruksi macOS untuk Jāmi‘ Khādim al-Ḥaramayn / Khademhrf).
///
/// Mematuhi 100% aturan `test/design_token_guard_test.dart`:
/// - Tanpa angka mentah `fontSize:`
/// - Tanpa angka mentah `circular(`
/// - Tanpa warna mentah `Color(0x...)` atau `Colors.*` (kecuali `Colors.transparent`)
/// - Tanpa `.styleFrom(` di dalam `lib/screens/`
/// - Hanya menggunakan konstanta `OTSpacing` dan `FontWeight.w400/w600/w700`.
class HadithTakhrijWorkspaceScreen extends StatefulWidget {
  const HadithTakhrijWorkspaceScreen({
    super.key,
    this.initialHadithUri,
  });

  final String? initialHadithUri;

  @override
  State<HadithTakhrijWorkspaceScreen> createState() =>
      _HadithTakhrijWorkspaceScreenState();
}

class _HadithTakhrijWorkspaceScreenState
    extends State<HadithTakhrijWorkspaceScreen> {
  static const int _maxTabs = 5;

  final UniversalTakhrijEngine _engine = UniversalTakhrijEngine.instance;
  final HarfMorphologyService _morph = HarfMorphologyService.instance;

  final List<_HadithStudyTabSession> _tabs = [];
  int _activeTabIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _muhmalController =
      TextEditingController(text: 'سفيان');
  final TextEditingController _manuscriptController = TextEditingController(
    text:
        'قال رسول الله صلى الله عليه وسلم: «إنما الأعمال بالنيات وإنما لكل امرئ ما نوى».\n'
        'وفي الحديث الآخر: «المسلم من سلم المسلمون من لسانه ويده».',
  );

  String _searchQuery = '';
  String _selectedTeacherId = 'rawi_yahya_said';
  String _selectedStudentId = 'rawi_humaidi';
  RawiBiographyRecord? _disambiguatedRawi;
  List<ManuscriptHadithDetection> _manuscriptDetections = const [];
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _initDefaultTabs();
    _runMuhmalDisambiguation();
    _runManuscriptScanner();
  }

  void _initDefaultTabs() {
    final all = _engine.corpusHadiths;
    if (all.isEmpty) return;

    CanonicalHadithRecord initial = all.first;
    if (widget.initialHadithUri != null) {
      for (final h in all) {
        if (h.uri == widget.initialHadithUri) {
          initial = h;
          break;
        }
      }
    }

    _tabs.add(
      _HadithStudyTabSession(
        id: 'tab_1',
        activeHadith: initial,
        selectedRawiId: initial.sanadChain.isNotEmpty
            ? initial.sanadChain.first.resolvedRawiId
            : initial.rawiAlaId,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _muhmalController.dispose();
    _manuscriptController.dispose();
    super.dispose();
  }

  _HadithStudyTabSession get _activeTab => _tabs[_activeTabIndex];

  String _shortHadithLabel(CanonicalHadithRecord record) {
    final words = record.rawMatn.split(RegExp(r'\s+'));
    final preview = words.take(4).join(' ');
    return '$preview (${record.bookTitleArabic})';
  }

  List<CanonicalHadithRecord> _filteredCorpus(bool includeNonCore33) {
    final baseList = _engine.corpusHadiths.where((h) {
      if (includeNonCore33) return true;
      final book = _engine.getBookById(h.bookId);
      return book?.isCore33 ?? false;
    }).toList();

    final q = _searchQuery.trim();
    if (q.isEmpty) return baseList;

    final normQuery = _morph.normalizeArabicWord(q);
    final queryTokens = _morph.tokenizeMeaningfulMatn(q);
    final queryRoots = queryTokens.map((t) => t.root).toSet();

    return baseList.where((h) {
      if (h.bookTitleArabic.contains(q) ||
          h.rawiAlaArabicName.contains(q) ||
          h.rawMatn.contains(q)) {
        return true;
      }
      final normMatn = _morph.normalizeArabicWord(h.effectiveMatnForIndexing);
      if (normQuery.isNotEmpty && normMatn.contains(normQuery)) {
        return true;
      }
      if (queryRoots.isNotEmpty) {
        final recRoots = _morph
            .tokenizeMeaningfulMatn(h.effectiveMatnForIndexing)
            .map((t) => t.root)
            .toSet();
        return queryRoots.any(recRoots.contains);
      }
      return false;
    }).toList();
  }

  void _openHadith(CanonicalHadithRecord record, {bool inNewTab = false}) {
    setState(() {
      _statusMessage = null;
      if (!inNewTab) {
        _activeTab.activeHadith = record;
        _activeTab.selectedRawiId = record.sanadChain.isNotEmpty
            ? record.sanadChain.first.resolvedRawiId
            : record.rawiAlaId;
        return;
      }

      if (_tabs.length >= _maxTabs) {
        _statusMessage =
            'Batas maksimal 5 tab aktif tercapai untuk menjaga fokus telaah.';
        return;
      }

      _tabs.add(
        _HadithStudyTabSession(
          id: 'tab_${DateTime.now().millisecondsSinceEpoch}',
          activeHadith: record,
          selectedRawiId: record.sanadChain.isNotEmpty
              ? record.sanadChain.first.resolvedRawiId
              : record.rawiAlaId,
        ),
      );
      _activeTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    if (_tabs.length <= 1) return;
    setState(() {
      _tabs.removeAt(index);
      if (_activeTabIndex >= _tabs.length) {
        _activeTabIndex = _tabs.length - 1;
      }
    });
  }

  void _runMuhmalDisambiguation() {
    final resolved = _engine.disambiguateMuhmalRawi(
      rawNameMention: _muhmalController.text.trim(),
      teacherRawiId: _selectedTeacherId,
      studentRawiId: _selectedStudentId,
    );
    setState(() {
      _disambiguatedRawi = resolved;
    });
  }

  void _runManuscriptScanner() {
    final results =
        _engine.scanAndTakhrijManuscript(_manuscriptController.text);
    setState(() {
      _manuscriptDetections = results;
    });
  }

  void _copyToClipboard(String text, String notice) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _statusMessage = notice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = _activeTab;
    final clusterResult = _engine.performTakhrijOnHadith(
      session.activeHadith,
      includeNonCore33Books: session.includeNonCore33Books,
      sortOrder: session.sortOrder,
    );
    final filteredHadiths = _filteredCorpus(session.includeNonCore33Books);

    return Scaffold(
      backgroundColor: OTColors.canvas(isDark),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopWorkspaceHeader(context, isDark, session),
            _buildMultiTabStrip(context, isDark),
            if (_statusMessage != null) _buildStatusNoticeBar(context, isDark),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideDesktop = constraints.maxWidth >= 1040;
                  if (!isWideDesktop) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildModeSelectorBar(
                          context,
                          isDark,
                          session,
                          clusterResult,
                        ),
                        Expanded(
                          child: _buildCenterWorkspaceContent(
                            context,
                            isDark,
                            session,
                            clusterResult,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Panel Kiri: Korpus Riwayat & Pencarian Morfologis (HarfMMMP)
                      SizedBox(
                        width: 310,
                        child: _buildLeftCorpusSidebar(
                          context,
                          isDark,
                          session,
                          filteredHadiths,
                        ),
                      ),
                      Container(
                        width: 1,
                        color: OTColors.borderSubtle(isDark),
                      ),
                      // Panel Tengah: Meja Telaah Utama (5 Mode Kajian)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildModeSelectorBar(
                              context,
                              isDark,
                              session,
                              clusterResult,
                            ),
                            Expanded(
                              child: OTActiveFade(
                                active: true,
                                child: _buildCenterWorkspaceContent(
                                  context,
                                  isDark,
                                  session,
                                  clusterResult,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        color: OTColors.borderSubtle(isDark),
                      ),
                      // Panel Kanan: Inspektor Biografi Perawi & Matriks 27 Kaidah
                      SizedBox(
                        width: 350,
                        child: _buildRightScholarlyInspector(
                          context,
                          isDark,
                          session,
                          clusterResult,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWorkspaceHeader(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
  ) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final totalBooks = _engine.registeredBooks.length;
    final coreBooks =
        _engine.registeredBooks.where((b) => b.isCore33).length;

    return Container(
      padding: OTSpacing.row,
      decoration: BoxDecoration(
        color: OTColors.surface(isDark),
        border: Border(
          bottom: BorderSide(color: OTColors.borderSubtle(isDark)),
        ),
      ),
      child: Wrap(
        spacing: OTSpacing.base,
        runSpacing: OTSpacing.sm,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Navigator.of(context).canPop()) ...[
                OutlinedButton(
                  style: OTButtons.compactOutlined(isDark),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('← Beranda'),
                ),
                OTSpacing.gapMd,
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meja Telaah Hadis & Takhrij Ribuan Kitab',
                    style: OTTypography.screenTitle(color: textPrimary),
                  ),
                  OTSpacing.gapXs,
                  Text(
                    'Rekonstruksi Jāmi‘ Khādim al-Ḥaramayn (27 Kaidah Muqāranat al-Mutūn · Tasyjīr Sanad · Al-Matn al-Mujamma‘)',
                    style: OTTypography.caption(color: textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: OTSpacing.sm,
            runSpacing: OTSpacing.xs,
            children: [
              OTChip(
                label: '33 Kitab Inti Khademhrf ($coreBooks Sampel)',
                selected: !session.includeNonCore33Books,
                onSelected: () {
                  setState(() {
                    session.includeNonCore33Books = false;
                  });
                },
              ),
              OTChip(
                label:
                    'Ekspansi Ribuan Kitab ($totalBooks Kitab: Mustakhraj · Zawā’id · Ajzā’)',
                selected: session.includeNonCore33Books,
                onSelected: () {
                  setState(() {
                    session.includeNonCore33Books = true;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiTabStrip(BuildContext context, bool isDark) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.base,
        vertical: OTSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: OTColors.surfaceSubtle(isDark),
        border: Border(
          bottom: BorderSide(color: OTColors.borderSubtle(isDark)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final selected = index == _activeTabIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: OTSpacing.sm),
                    child: OTBentoTile(
                      inverse: selected,
                      padding: const EdgeInsets.symmetric(
                        horizontal: OTSpacing.md,
                        vertical: OTSpacing.sm,
                      ),
                      onTap: () {
                        setState(() {
                          _activeTabIndex = index;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${index + 1}. ',
                            style: OTTypography.captionMedium(
                              color: selected
                                  ? OTColors.onInverseSurface
                                  : textSecondary,
                            ),
                          ),
                          Text(
                            _shortHadithLabel(tab.activeHadith),
                            textDirection: TextDirection.rtl,
                            style: OTTypography.captionMedium(
                              color: selected
                                  ? OTColors.onInverseSurface
                                  : textPrimary,
                            ),
                          ),
                          if (_tabs.length > 1) ...[
                            OTSpacing.gapSm,
                            GestureDetector(
                              onTap: () => _closeTab(index),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: selected
                                    ? OTColors.onInverseSurface
                                    : textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Text(
            'Tab Aktif: ${_tabs.length}/$_maxTabs',
            style: OTTypography.captionMedium(color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusNoticeBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.base,
        vertical: OTSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: OTColors.surface(isDark),
        border: Border(
          bottom: BorderSide(color: OTColors.borderStrong(isDark)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: OTColors.textPrimary(isDark),
          ),
          OTSpacing.gapSm,
          Expanded(
            child: Text(
              _statusMessage ?? '',
              style: OTTypography.captionMedium(
                color: OTColors.textPrimary(isDark),
              ),
            ),
          ),
          TextButton(
            style: OTButtons.quiet(isDark),
            onPressed: () => setState(() => _statusMessage = null),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftCorpusSidebar(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
    List<CanonicalHadithRecord> filteredHadiths,
  ) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      color: OTColors.surface(isDark),
      padding: OTSpacing.cardCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'KORPUS RIWAYAT & INDEKS AKAR KATA',
            style: OTTypography.sectionHeading(color: textSecondary),
          ),
          OTSpacing.gapSm,
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: OTTypography.body(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari matan, akar (نوي / سلم), atau sahabat...',
              hintStyle: OTTypography.caption(color: textSecondary),
              prefixIcon: Icon(
                Icons.search,
                size: 18,
                color: textSecondary,
              ),
              isDense: true,
              contentPadding: OTSpacing.cardCompact,
            ),
          ),
          OTSpacing.gapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Riwayat (${filteredHadiths.length})',
                style: OTTypography.captionMedium(color: textSecondary),
              ),
              Text(
                'Klik: Buka · +: Tab Baru',
                style: OTTypography.caption(color: textSecondary),
              ),
            ],
          ),
          OTSpacing.gapSm,
          Expanded(
            child: ListView.separated(
              itemCount: filteredHadiths.length,
              separatorBuilder: (_, __) => OTSpacing.gapSm,
              itemBuilder: (context, index) {
                final item = filteredHadiths[index];
                final book = _engine.getBookById(item.bookId);
                final isSelected = item.uri == session.activeHadith.uri;

                return OTBentoTile(
                  inverse: isSelected,
                  padding: OTSpacing.cardCompact,
                  onTap: () => _openHadith(item, inNewTab: false),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (book?.isCore33 ?? false)
                                ? '33 Kitab Inti'
                                : 'Ekspansi Ribuan Kitab',
                            style: OTTypography.metadataTag(
                              color: isSelected
                                  ? OTColors.onInverseSurface
                                  : textSecondary,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.formattedCitation,
                                textDirection: TextDirection.rtl,
                                style: OTTypography.caption(
                                  color: isSelected
                                      ? OTColors.onInverseSurface
                                      : textSecondary,
                                ),
                              ),
                              OTSpacing.gapXs,
                              GestureDetector(
                                onTap: () => _openHadith(item, inNewTab: true),
                                child: Icon(
                                  Icons.add_box_outlined,
                                  size: 16,
                                  color: isSelected
                                      ? OTColors.onInverseSurface
                                      : textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      OTSpacing.gapXs,
                      Text(
                        item.bookTitleArabic,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.cardTitle(
                          color: isSelected
                              ? OTColors.onInverseSurface
                              : textPrimary,
                        ),
                      ),
                      OTSpacing.gapXs,
                      Text(
                        item.rawMatn,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.arabicReading(
                          color: isSelected
                              ? OTColors.onInverseSurface
                              : textPrimary,
                        ),
                      ),
                      OTSpacing.gapXs,
                      Text(
                        'الراوي الأعلى: ${item.rawiAlaArabicName}',
                        textDirection: TextDirection.rtl,
                        style: OTTypography.caption(
                          color: isSelected
                              ? OTColors.onInverseSurface
                              : textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelectorBar(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
    TakhrijClusterResult clusterResult,
  ) {
    final totalComparisons = clusterResult.takhrijOutcomes.length +
        clusterResult.syawahidOutcomes.length;

    final modes = <(HadithWorkspaceMode, String)>[
      (
        HadithWorkspaceMode.takhrijAndMuqaranah,
        'Takhrij & 27 Kaidah Lafaz ($totalComparisons)',
      ),
      (
        HadithWorkspaceMode.matnAndMujamma,
        'Matan, Sanad & Al-Matn al-Mujamma‘',
      ),
      (
        HadithWorkspaceMode.tasyjirAndIlal,
        'Tasyjīr Sanad & Laporan ‘Ilal',
      ),
      (
        HadithWorkspaceMode.rijalAndMuhmal,
        'Disambiguasi Rijal Muhmal',
      ),
      (
        HadithWorkspaceMode.manuscriptAutoTakhrij,
        'Takhrij Otomatis Makalah',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OTSpacing.base,
        vertical: OTSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: OTColors.surface(isDark),
        border: Border(
          bottom: BorderSide(color: OTColors.borderSubtle(isDark)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: modes.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(right: OTSpacing.sm),
              child: OTChip(
                label: entry.$2,
                selected: session.mode == entry.$1,
                onSelected: () {
                  setState(() {
                    session.mode = entry.$1;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCenterWorkspaceContent(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
    TakhrijClusterResult clusterResult,
  ) {
    switch (session.mode) {
      case HadithWorkspaceMode.takhrijAndMuqaranah:
        return _buildTakhrijAndMuqaranahView(
          context,
          isDark,
          session,
          clusterResult,
        );
      case HadithWorkspaceMode.matnAndMujamma:
        return _buildMatnAndMujammaView(
          context,
          isDark,
          session,
          clusterResult,
        );
      case HadithWorkspaceMode.tasyjirAndIlal:
        return _buildTasyjirAndIlalView(
          context,
          isDark,
          session,
          clusterResult,
        );
      case HadithWorkspaceMode.rijalAndMuhmal:
        return _buildRijalAndMuhmalView(context, isDark, session);
      case HadithWorkspaceMode.manuscriptAutoTakhrij:
        return _buildManuscriptAutoTakhrijView(context, isDark);
    }
  }

  /// Mode 1: Takhrij & 27 Kaidah Muqaranat al-Mutun
  Widget _buildTakhrijAndMuqaranahView(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
    TakhrijClusterResult clusterResult,
  ) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return ListView(
      padding: const EdgeInsets.all(OTSpacing.lg),
      children: [
        // Naskah Takhrij Klasik Otomatis
        OTBentoTile(
          padding: const EdgeInsets.all(OTSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NASKAH TAKHRIJ KLASIK OTOMATIS (TAKHREEGXSL ENGINE)',
                    style: OTTypography.sectionHeading(color: textSecondary),
                  ),
                  OutlinedButton(
                    style: OTButtons.compactOutlined(isDark),
                    onPressed: () => _copyToClipboard(
                      clusterResult.formattedFullTakhrijArabicParagraph,
                      'Naskah takhrij klasik berhasil disalin ke papan klip.',
                    ),
                    child: const Text('Salin Naskah Takhrij'),
                  ),
                ],
              ),
              OTSpacing.gapMd,
              SelectableText(
                clusterResult.formattedFullTakhrijArabicParagraph,
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(color: textPrimary),
              ),
              OTSpacing.gapMd,
              Wrap(
                spacing: OTSpacing.sm,
                runSpacing: OTSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Urutan Takhrij:',
                    style: OTTypography.captionMedium(color: textSecondary),
                  ),
                  for (final order in TakhrijSortOrder.values)
                    OTChip(
                      label: '${order.indonesianLabel} (${order.arabicLabel})',
                      selected: session.sortOrder == order,
                      onSelected: () {
                        setState(() {
                          session.sortOrder = order;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        OTSpacing.gapLg,

        // Bagian 1: Takhrij & Mutaba'at (Sahabat yang sama)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '١. التخريج والمتابعات (الراوي الأعلى: ${session.activeHadith.rawiAlaArabicName})',
              textDirection: TextDirection.rtl,
              style: OTTypography.bookTitle(color: textPrimary),
            ),
            Text(
              '${clusterResult.takhrijOutcomes.length} Riwayat',
              style: OTTypography.captionMedium(color: textSecondary),
            ),
          ],
        ),
        OTSpacing.gapMd,
        if (clusterResult.takhrijOutcomes.isEmpty)
          Text(
            'Tidak ditemukan jalur mutaba‘at lain pada cakupan korpus yang dipilih.',
            style: OTTypography.body(color: textSecondary),
          )
        else
          for (final outcome in clusterResult.takhrijOutcomes) ...[
            MatnComparisonOutcomeCard(
              outcome: outcome,
              onTapBook: () =>
                  _openHadith(outcome.targetHadith, inNewTab: true),
            ),
            OTSpacing.gapMd,
          ],

        OTSpacing.gapLg,

        // Bagian 2: Syawahid Lintas Sahabat (Jami' al-Matn)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '٢. الشواهد الحديثية (من رواية صحابة آخرين)',
              textDirection: TextDirection.rtl,
              style: OTTypography.bookTitle(color: textPrimary),
            ),
            Text(
              '${clusterResult.syawahidOutcomes.length} Syahid',
              style: OTTypography.captionMedium(color: textSecondary),
            ),
          ],
        ),
        OTSpacing.gapMd,
        if (clusterResult.syawahidOutcomes.isEmpty)
          Text(
            'Tidak ditemukan syawahid lintas sahabat pada cakupan korpus ini.',
            style: OTTypography.body(color: textSecondary),
          )
        else
          for (final outcome in clusterResult.syawahidOutcomes) ...[
            MatnComparisonOutcomeCard(
              outcome: outcome,
              onTapBook: () =>
                  _openHadith(outcome.targetHadith, inNewTab: true),
            ),
            OTSpacing.gapMd,
          ],
      ],
    );
  }

  /// Mode 2: Matan Asli, Rantai Sanad Interaktif, Al-Matn al-Mujamma', & Kitab Khadami
  Widget _buildMatnAndMujammaView(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
    TakhrijClusterResult clusterResult,
  ) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final hadith = session.activeHadith;

    return ListView(
      padding: const EdgeInsets.all(OTSpacing.lg),
      children: [
        OTBentoTile(
          padding: const EdgeInsets.all(OTSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${hadith.bookTitleArabic} · ${hadith.formattedCitation}',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.bookTitle(color: textPrimary),
                  ),
                  Text(
                    hadith.elevationStatus.arabicLabel,
                    textDirection: TextDirection.rtl,
                    style: OTTypography.captionMedium(color: textSecondary),
                  ),
                ],
              ),
              OTSpacing.gapXs,
              Text(
                '${hadith.sectionTitle} — ${hadith.chapterTitle}',
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(color: textSecondary),
              ),
              OTSpacing.gapMd,
              Text(
                'سلسلة الإسناد (اضغط على الراوي لعرض ترجمته في اللوحة اليمنى):',
                textDirection: TextDirection.rtl,
                style: OTTypography.captionMedium(color: textSecondary),
              ),
              OTSpacing.gapSm,
              Directionality(
                textDirection: TextDirection.rtl,
                child: Wrap(
                  spacing: OTSpacing.sm,
                  runSpacing: OTSpacing.xs,
                  children: [
                    for (final hop in hadith.sanadChain)
                      OTChip(
                        label:
                            '${hop.transmissionPhrase} ${hop.resolvedArabicName}',
                        selected: session.selectedRawiId == hop.resolvedRawiId,
                        onSelected: () {
                          if (hop.resolvedRawiId != null) {
                            setState(() {
                              session.selectedRawiId = hop.resolvedRawiId;
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
              OTSpacing.gapLg,
              Container(
                padding: const EdgeInsets.all(OTSpacing.lg),
                decoration: BoxDecoration(
                  color: OTColors.surfaceSubtle(isDark),
                  borderRadius: OTRadius.cardBorder,
                  border: Border.all(color: OTColors.borderStrong(isDark)),
                ),
                child: SelectableText(
                  '« ${hadith.rawMatn} »',
                  textDirection: TextDirection.rtl,
                  style: OTTypography.arabicIbarah(color: textPrimary),
                ),
              ),
              if (hadith.hiddenMatnFromIhalah != null) ...[
                OTSpacing.gapMd,
                Text(
                  'المتن المخفي المسترجع من الإحالة (<متن_مخفي>): ${hadith.hiddenMatnFromIhalah}',
                  textDirection: TextDirection.rtl,
                  style: OTTypography.arabicReading(color: textSecondary),
                ),
              ],
            ],
          ),
        ),
        OTSpacing.gapLg,
        MujammaMatnCard(
          compositeMatn: clusterResult.mujammaMatn,
          onSaveToMejaTelaah: () => _copyToClipboard(
            clusterResult.mujammaMatn.segments
                .map((s) => s.arabicText)
                .join(' '),
            'Matan komposit (Al-Matn al-Mujamma‘) disalin ke papan klip.',
          ),
        ),
        if (clusterResult.serviceReferences.isNotEmpty) ...[
          OTSpacing.gapLg,
          Text(
            'الكتب الخدمية المرتبطة (الشروح · غريب الحديث · العلل)',
            textDirection: TextDirection.rtl,
            style: OTTypography.bookTitle(color: textPrimary),
          ),
          OTSpacing.gapMd,
          for (final ref in clusterResult.serviceReferences) ...[
            OTBentoTile(
              padding: const EdgeInsets.all(OTSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${ref.bookTitleArabic} — ${ref.authorArabic} (${ref.partNumber}/${ref.pageNumber})',
                        textDirection: TextDirection.rtl,
                        style: OTTypography.cardTitle(color: textPrimary),
                      ),
                      Text(
                        ref.categoryLabel,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.captionMedium(color: textSecondary),
                      ),
                    ],
                  ),
                  OTSpacing.gapSm,
                  Text(
                    ref.excerptArabic,
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicReading(color: textPrimary),
                  ),
                ],
              ),
            ),
            OTSpacing.gapMd,
          ],
        ],
      ],
    );
  }

  /// Mode 3: Tasyjir al-Asanid & Deteksi 'Ilal / Madar
  Widget _buildTasyjirAndIlalView(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
    TakhrijClusterResult clusterResult,
  ) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return ListView(
      padding: const EdgeInsets.all(OTSpacing.lg),
      children: [
        HadithIsnadDagCanvas(
          report: clusterResult.madarReport,
          onSelectRawi: (rawiId) {
            setState(() {
              session.selectedRawiId = rawiId;
            });
          },
        ),
        if (clusterResult.madarReport.scholarJudgments.isNotEmpty) ...[
          OTSpacing.gapLg,
          Text(
            'أحكام الأئمة والحفاظ على الحديث (HadithScientestsJudge)',
            textDirection: TextDirection.rtl,
            style: OTTypography.bookTitle(color: textPrimary),
          ),
          OTSpacing.gapMd,
          for (final j in clusterResult.madarReport.scholarJudgments) ...[
            OTBentoTile(
              padding: const EdgeInsets.all(OTSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${j.scholarArabicName} (ت ${j.scholarDeathYearHijri} هـ)',
                        textDirection: TextDirection.rtl,
                        style: OTTypography.cardTitle(color: textPrimary),
                      ),
                      Text(
                        j.sourceBookArabic,
                        textDirection: TextDirection.rtl,
                        style: OTTypography.captionMedium(color: textSecondary),
                      ),
                    ],
                  ),
                  OTSpacing.gapXs,
                  Text(
                    '« ${j.judgmentArabicText} »',
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicReading(color: textPrimary),
                  ),
                ],
              ),
            ),
            OTSpacing.gapMd,
          ],
        ],
      ],
    );
  }

  /// Mode 4: Disambiguasi Perawi Muhmal (Tarajim al-Ruwat)
  Widget _buildRijalAndMuhmalView(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
  ) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final allRawis = _engine.registeredRawis;

    return ListView(
      padding: const EdgeInsets.all(OTSpacing.lg),
      children: [
        OTBentoTile(
          padding: const EdgeInsets.all(OTSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'DISAMBIGUASI PERAWI MUHMAL OTOMATIS (TARĀJIM AL-RUWĀT)',
                style: OTTypography.sectionHeading(color: textSecondary),
              ),
              OTSpacing.gapSm,
              Text(
                'Menentukan identitas perawi muhmal (seperti "حدثنا سفيان" atau "عن حماد") secara algoritmik pada ribuan kitab baru melalui irisan graf Guru (Syuyūkh) dan Murid (Talāmīdz).',
                style: OTTypography.body(color: textSecondary),
              ),
              OTSpacing.gapMd,
              Wrap(
                spacing: OTSpacing.md,
                runSpacing: OTSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _muhmalController,
                      style: OTTypography.arabicReading(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Nama Muhmal di Sanad',
                        labelStyle: OTTypography.caption(color: textSecondary),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<String>(
                      value: _selectedTeacherId,
                      dropdownColor: OTColors.surface(isDark),
                      style: OTTypography.captionMedium(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Guru (Syaikh) di Atasnya',
                        labelStyle: OTTypography.caption(color: textSecondary),
                        isDense: true,
                      ),
                      items: allRawis.map((r) {
                        return DropdownMenuItem<String>(
                          value: r.id,
                          child: Text(r.esmShuhra),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTeacherId = val);
                          _runMuhmalDisambiguation();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: DropdownButtonFormField<String>(
                      value: _selectedStudentId,
                      dropdownColor: OTColors.surface(isDark),
                      style: OTTypography.captionMedium(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Murid (Tilmīdz) di Bawahnya',
                        labelStyle: OTTypography.caption(color: textSecondary),
                        isDense: true,
                      ),
                      items: allRawis.map((r) {
                        return DropdownMenuItem<String>(
                          value: r.id,
                          child: Text(r.esmShuhra),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedStudentId = val);
                          _runMuhmalDisambiguation();
                        }
                      },
                    ),
                  ),
                  FilledButton(
                    style: OTButtons.compactTonal(isDark),
                    onPressed: _runMuhmalDisambiguation,
                    child: const Text('Uji Disambiguasi'),
                  ),
                ],
              ),
              if (_disambiguatedRawi != null) ...[
                OTSpacing.gapLg,
                RawiBiographyInspectorCard(
                  rawi: _disambiguatedRawi!,
                ),
              ],
            ],
          ),
        ),
        OTSpacing.gapLg,
        Text(
          'Katalog Perawi Terdaftar (${allRawis.length} Perawi Inti)',
          style: OTTypography.sectionTitle(color: textPrimary),
        ),
        OTSpacing.gapMd,
        for (final rawi in allRawis) ...[
          RawiBiographyInspectorCard(
            rawi: rawi,
          ),
          OTSpacing.gapMd,
        ],
      ],
    );
  }

  /// Mode 5: Takhrij Otomatis Naskah Makalah (`DocXSL.xsl` Revival)
  Widget _buildManuscriptAutoTakhrijView(BuildContext context, bool isDark) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return ListView(
      padding: const EdgeInsets.all(OTSpacing.lg),
      children: [
        OTBentoTile(
          padding: const EdgeInsets.all(OTSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAKHRIJ OTOMATIS NASKAH MAKALAH & KITAB (DOCXSL REVIVAL)',
                          style: OTTypography.sectionHeading(
                            color: textSecondary,
                          ),
                        ),
                        OTSpacing.gapXs,
                        Text(
                          'Tempelkan naskah makalah atau bab kitab untuk mendeteksi kutipan hadis secara otomatis dan menyusun catatan kaki takhrij sesuai 27 kaidah Harf.',
                          style: OTTypography.body(color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    style: OTButtons.compactTonal(isDark),
                    onPressed: _runManuscriptScanner,
                    child: const Text('Pindai & Takhrij Makalah'),
                  ),
                ],
              ),
              OTSpacing.gapMd,
              TextField(
                controller: _manuscriptController,
                maxLines: 5,
                textDirection: TextDirection.rtl,
                style: OTTypography.arabicReading(color: textPrimary),
                decoration: const InputDecoration(
                  contentPadding: OTSpacing.card,
                ),
              ),
            ],
          ),
        ),
        OTSpacing.gapLg,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hasil Deteksi Kutipan & Catatan Kaki (${_manuscriptDetections.length})',
              style: OTTypography.sectionTitle(color: textPrimary),
            ),
            if (_manuscriptDetections.isNotEmpty)
              OutlinedButton(
                style: OTButtons.compactOutlined(isDark),
                onPressed: () {
                  final allFootnotes = _manuscriptDetections
                      .map(
                        (d) =>
                            '(${d.indexInManuscript}) ${d.generatedFootnoteArabic}',
                      )
                      .join('\n');
                  _copyToClipboard(
                    allFootnotes,
                    'Seluruh catatan kaki takhrij berhasil disalin.',
                  );
                },
                child: const Text('Salin Semua Catatan Kaki'),
              ),
          ],
        ),
        OTSpacing.gapMd,
        for (final det in _manuscriptDetections) ...[
          OTBentoTile(
            padding: const EdgeInsets.all(OTSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kutipan #${det.indexInManuscript}',
                      style: OTTypography.captionMedium(color: textSecondary),
                    ),
                    if (det.matchedCluster != null)
                      OutlinedButton(
                        style: OTButtons.compactOutlined(isDark),
                        onPressed: () {
                          _openHadith(
                            det.matchedCluster!.originHadith,
                            inNewTab: false,
                          );
                          setState(() {
                            _activeTab.mode =
                                HadithWorkspaceMode.takhrijAndMuqaranah;
                          });
                        },
                        child: const Text('Buka di Meja Telaah'),
                      ),
                  ],
                ),
                OTSpacing.gapSm,
                Text(
                  'النص المقتبس: «${det.detectedQuoteArabic}»',
                  textDirection: TextDirection.rtl,
                  style: OTTypography.arabicReading(color: textPrimary),
                ),
                OTSpacing.gapSm,
                Container(
                  padding: OTSpacing.cardCompact,
                  decoration: BoxDecoration(
                    color: OTColors.surfaceSubtle(isDark),
                    borderRadius: OTRadius.xsBorder,
                    border: Border.all(color: OTColors.border(isDark)),
                  ),
                  child: SelectableText(
                    det.generatedFootnoteArabic,
                    textDirection: TextDirection.rtl,
                    style: OTTypography.arabicReading(color: textPrimary),
                  ),
                ),
              ],
            ),
          ),
          OTSpacing.gapMd,
        ],
      ],
    );
  }

  Widget _buildRightScholarlyInspector(
    BuildContext context,
    bool isDark,
    _HadithStudyTabSession session,
    TakhrijClusterResult clusterResult,
  ) {
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final selectedRawi = session.selectedRawiId != null
        ? _engine.getRawiById(session.selectedRawiId!)
        : null;

    return Container(
      color: OTColors.surface(isDark),
      padding: OTSpacing.cardCompact,
      child: ListView(
        children: [
          Text(
            'INSPEKTOR RIJAL & METODOLOGI HARF',
            style: OTTypography.sectionHeading(color: textSecondary),
          ),
          OTSpacing.gapSm,
          if (selectedRawi != null)
            RawiBiographyInspectorCard(
              rawi: selectedRawi,
            )
          else
            OTBentoTile(
              padding: OTSpacing.cardCompact,
              child: Text(
                'Klik salah satu perawi pada sanad atau kanvas Tasyjīr untuk menampilkan biografi lengkap serta kutipan al-Jarḥ wa al-Ta‘dīl.',
                style: OTTypography.caption(color: textSecondary),
              ),
            ),
          OTSpacing.gapMd,
          OTBentoTile(
            padding: OTSpacing.cardCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINGKASAN 27 KAIDAH MUQĀRANAT AL-MUTŪN',
                  style: OTTypography.sectionHeading(color: textSecondary),
                ),
                OTSpacing.gapSm,
                Text(
                  '• Kaidah 1–7 (بلفظه): 100% kecocokan akar kata & wazan morfologis.\n'
                  '• Kaidah 8–16 (بمثله): Kecocokan ≥ 90% satu sisi, ≥ 65% sisi lain, sekuens ≥ 50%.\n'
                  '• Kaidah 17–23 (بنحوه): Kecocokan di bawah بمثله dengan sekuens ≥ 40%.\n'
                  '• Kaidah 24–27 (بمعناه): Kecocokan makna ≥ 20% dan sekuens ≥ 30%.\n'
                  '• Pengelompokan 2 Tahap: Ambang otomatis 80% (Tahap 1) + penggabungan riwayat ringkas ≥ 50% (Tahap 3).',
                  style: OTTypography.caption(color: textPrimary),
                ),
              ],
            ),
          ),
          OTSpacing.gapMd,
          OTBentoTile(
            padding: OTSpacing.cardCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESOLUSI KITAB #26 & 12 PERAWI ZAWĀ’ID',
                  style: OTTypography.sectionHeading(color: textSecondary),
                ),
                OTSpacing.gapSm,
                Text(
                  '• Mengganti hardcode @BookID=26 (al-Maṭālib al-‘Āliyah) di TakhreegXSL.xsl dengan taksonomi otomatis: kitab kompilasi sekunder menggunakan «أورده», sedangkan kitab musnad/mustakhraj menggunakan «أخرجه».\n'
                  '• Mendukung atribusi otomatis 12 perawi Zawā’id (seperti ‘Abdullāh bin Aḥmad dan Abu al-Ḥasan al-Qaṭṭān).',
                  style: OTTypography.caption(color: textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
