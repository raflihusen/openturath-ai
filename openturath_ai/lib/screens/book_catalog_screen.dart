import '../widgets/desktop_shortcuts.dart';
import '../widgets/adaptive_sheet.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../core/app_copy.dart';
import '../core/localization.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import '../widgets/book_row_item.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// Halaman Katalog Kitab (Full-Screen Route).
/// Mendukung 2.226 Kitab Induk lintas 6 disiplin ilmu kanonikal dengan pencarian Arab toleran harakat,
/// filter hierarki disiplin (القسم), abad keilmuan, dan kartu kitab minimalis bergaya turath.
class BookCatalogScreen extends StatefulWidget {
  final AgentModel? agent;
  final String? initialQuery;

  const BookCatalogScreen({
    super.key,
    this.agent,
    this.initialQuery,
  });

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchCtrl = TextEditingController();
  final CanonicalLibraryService _service = CanonicalLibraryService.instance;
  Timer? _debounce;

  List<CanonicalBookPresentation>? _allBooks;
  List<CanonicalBookPresentation>? _filteredBooks;
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedSection;
  String? _selectedEra;
  String? _selectedType;
  String? _selectedCentury;
  String _searchQuery = '';

  List<String> _availableSections = [];
  bool _hasEras = false;
  bool _hasTypes = false;

  final List<String> _eras = [
    'Mutaqaddimin',
    'Ashab Al-Wujuh',
    'Muta\'akhkhirin',
  ];

  final List<String> _types = [
    'Asal Mazhab',
    'Matan',
    'Syarah',
    'Hasyiyah',
  ];

  final List<String> _centuries = [
    'Salaf (≤ 300 H)',
    'Mutaqaddimin (301-600 H)',
    'Muta\'akhkhirin (601-1100 H)',
    'Mu\'ashir (> 1100 H)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
    _loadCatalog();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<CanonicalBookPresentation> books;
      if (widget.agent != null) {
        books = await _service.loadCatalogForAgent(widget.agent!);
      } else {
        books = await _service.loadSyafiiCatalog();
      }

      final Set<String> rawSections = {};
      bool hasEras = false;
      bool hasTypes = false;

      for (final b in books) {
        if (b.sectionArabic != null && b.sectionArabic!.trim().isNotEmpty) {
          rawSections.add(b.sectionArabic!.trim());
        }
        if (b.reviewedEraLabel != null && b.reviewedEraLabel!.isNotEmpty) {
          hasEras = true;
        }
        if (b.reviewedTypeLabel != null && b.reviewedTypeLabel!.isNotEmpty) {
          hasTypes = true;
        }
      }

      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _availableSections = rawSections.toList()..sort();
        _hasEras = hasEras;
        _hasTypes = hasTypes;
        _isLoading = false;
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = AppCopy.catalogLoadFailed;
      });
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() {
          _searchQuery = val.trim();
          _applyFilters();
        });
      }
    });
  }

  void _applyFilters() {
    if (_allBooks == null) return;
    _filteredBooks = _service.filterBooks(
      _allBooks!,
      _searchQuery,
      sectionFilter: _selectedSection,
      eraFilter: _selectedEra,
      typeFilter: _selectedType,
      centuryFilter: _selectedCentury,
    );
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = '';
      _selectedSection = null;
      _selectedEra = null;
      _selectedType = null;
      _selectedCentury = null;
      _applyFilters();
    });
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedSection != null ||
      _selectedEra != null ||
      _selectedType != null ||
      _selectedCentury != null;

  void _openBookDetail(CanonicalBookPresentation book) {
    NavigationGuard.safePushNamed(
      context,
      AppRoutes.bookDetail,
      arguments: book,
    );
  }

  String _formatNumber(int number) {
    return NumberFormat.decimalPattern(Loc.language).format(number);
  }

  String _cleanSectionLabel(String full) {
    final match = RegExp(r'\((.*?)\)').firstMatch(full);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    return full;
  }

  String _resolveSubtitle() {
    final count = _allBooks?.length;
    final label = count == null
        ? Loc.tr('bookCatalog')
        : Loc.tr('bookCount', [_formatNumber(count)]);
    return widget.agent == null ? label : '$label · ${widget.agent!.title}';
  }

  @override
  Widget build(BuildContext context) => DesktopShortcuts(
        onFind: _searchFocusNode.requestFocus,
        onEscape: () {
          _searchCtrl.clear();
          _onSearchChanged('');
          _searchFocusNode.unfocus();
        },
        child: _buildScreen(context),
      );

  Widget _buildScreen(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final background = OTColors.canvas(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final primaryAccent = OTColors.accent(isDark);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          tooltip: Loc.tr('back'),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppCopy.referenceBooks,
              style: OTTypography.screenTitle(color: textPrimary)
                  .copyWith(fontSize: 18),
            ),
            Text(
              _resolveSubtitle(),
              style: OTTypography.caption(color: textSecondary)
                  .copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: Text(
                Loc.tr('ui_ae4f9663d7'),
                style: OTTypography.button(color: primaryAccent)
                    .copyWith(fontSize: 13),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── SEARCH CONTAINER ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OTSpacing.lg,
                vertical: OTSpacing.sm,
              ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocusNode,
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.outfit(
                            fontSize: 13.5, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: Loc.tr('ui_214d016291'),
                          hintStyle: GoogleFonts.outfit(
                            fontSize: 13.5,
                            color: textSecondary.withValues(alpha: 0.7),
                          ),
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
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                        child: Icon(Icons.close_rounded,
                            size: 18, color: textSecondary),
                      ),
                  ],
                ),
              ),
            ),

            // ── DYNAMIC HORIZONTAL FILTER CHIPS ──
            _buildFilterChipsBar(
              isDark: isDark,
              surface: surface,
              border: border,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              primaryAccent: primaryAccent,
            ),

            const SizedBox(height: OTSpacing.sm),

            // ── RESULTS COUNT HEADER ──
            if (!_isLoading && _filteredBooks != null && _allBooks != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.lg,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      Loc.tr('booksShown', [
                        _formatNumber(_filteredBooks!.length),
                        _formatNumber(_allBooks!.length),
                      ]),
                      style:
                          OTTypography.caption(color: textSecondary).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedSection != null ||
                        _selectedEra != null ||
                        _selectedType != null ||
                        _selectedCentury != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(
                              alpha: isDark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          [
                            if (_selectedSection != null)
                              _cleanSectionLabel(_selectedSection!),
                            if (_selectedEra != null) Loc.text(_selectedEra!),
                            if (_selectedType != null) Loc.text(_selectedType!),
                            if (_selectedCentury != null) _selectedCentury!,
                          ].join(' · '),
                          style: OTTypography.caption(color: primaryAccent)
                              .copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // ── MAIN CONTENT LIST / EMPTY / ERROR / LOADING ──
            Expanded(
              child: _buildContent(
                isDark: isDark,
                surface: surface,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryAccent: primaryAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipsBar({
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryAccent,
  }) {
    final hasFilters = _hasActiveFilters;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
      child: Row(
        children: [
          _filterChip(
            label: hasFilters
                ? Loc.tr('ui_c0c96d1d9a')
                : Loc.tr('allBooks'),
            isSelected: !hasFilters,
            onTap: hasFilters ? _clearFilters : () {},
            isDark: isDark,
            border: border,
            surface: surface,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => _showFilterSheet(
                isDark, surface, border, textPrimary, textSecondary),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: Text(Loc.tr('ui_d7decf1aa2')),
            style: OutlinedButton.styleFrom(
              foregroundColor: textPrimary,
              side: BorderSide(color: border),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterSheet(bool isDark, Color surface, Color border,
      Color textPrimary, Color textSecondary) {
    final isSyafii = widget.agent == null ||
        widget.agent!.id == 'fiqh_syafii' ||
        widget.agent!.catalogId == 'canonical_syafii' ||
        widget.agent!.fieldId == 'fiqh';
    final eraChoices = isSyafii && _hasEras ? _eras : _centuries;
    return showAdaptiveSheet<void>(
      context: context,
      backgroundColor: surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: StatefulBuilder(
          builder: (_, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(
                OTSpacing.lg, 0, OTSpacing.lg, OTSpacing.lg),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(Loc.tr('ui_ac03e7c93b'),
                    style: OTTypography.screenTitle(color: textPrimary)),
                const SizedBox(height: 16),
                if (_availableSections.length > 1) ...[
                  Text(Loc.tr('ui_8b71077ed7'),
                      style: OTTypography.captionMedium(color: textSecondary)),
                  Wrap(
                      spacing: 8,
                      children: _availableSections
                          .map((section) => ChoiceChip(
                              label: Text(_cleanSectionLabel(section)),
                              selected: _selectedSection == section,
                              onSelected: (_) {
                                setState(() {
                                  _selectedSection = _selectedSection == section
                                      ? null
                                      : section;
                                  _applyFilters();
                                });
                                setSheetState(() {});
                              }))
                          .toList()),
                  const SizedBox(height: 16),
                ],
                Text(Loc.tr('ui_f37a89cbd1'),
                    style: OTTypography.captionMedium(color: textSecondary)),
                Wrap(
                    spacing: 8,
                    children: eraChoices
                        .map((era) => ChoiceChip(
                            label: Text(Loc.text(era)),
                            selected:
                                _selectedCentury == era || _selectedEra == era,
                            onSelected: (_) {
                              setState(() {
                                if (isSyafii && _hasEras) {
                                  _selectedEra =
                                      _selectedEra == era ? null : era;
                                  _selectedCentury = null;
                                } else {
                                  _selectedCentury =
                                      _selectedCentury == era ? null : era;
                                  _selectedEra = null;
                                }
                                _applyFilters();
                              });
                              setSheetState(() {});
                            }))
                        .toList()),
                if (_hasTypes) ...[
                  const SizedBox(height: 16),
                  Text(Loc.tr('ui_47b35543e3'),
                      style: OTTypography.captionMedium(color: textSecondary)),
                  Wrap(
                      spacing: 8,
                      children: _types
                          .map((type) => ChoiceChip(
                              label: Text(Loc.text(type)),
                              selected: _selectedType == type,
                              onSelected: (_) {
                                setState(() {
                                  _selectedType =
                                      _selectedType == type ? null : type;
                                  _applyFilters();
                                });
                                setSheetState(() {});
                              }))
                          .toList()),
                ],
                const SizedBox(height: 20),
                TextButton(
                    onPressed: () {
                      _clearFilters();
                      Navigator.pop(sheetContext);
                    },
                    child: Text(Loc.tr('ui_a74cf8b9bd'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Retained as a fallback while the compact filter sheet is rolled out.
  // ignore: unused_element
  Widget _buildLegacyFilterChipsBar({
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryAccent,
  }) {
    // Mode 1: Multipel Sub-Bagian (seperti Tafsir & Sastra Arab)
    if (_availableSections.length > 1) {
      return SizedBox(
        height: 38,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
          children: [
            _filterChip(
              label: Loc.tr('ui_6e02202968'),
              isSelected: _selectedSection == null,
              onTap: () {
                setState(() {
                  _selectedSection = null;
                  _applyFilters();
                });
              },
              isDark: isDark,
              border: border,
              surface: surface,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            for (final section in _availableSections)
              _filterChip(
                label: _cleanSectionLabel(section),
                isSelected: _selectedSection == section,
                onTap: () {
                  setState(() {
                    _selectedSection =
                        _selectedSection == section ? null : section;
                    _applyFilters();
                  });
                },
                isDark: isDark,
                border: border,
                surface: surface,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
          ],
        ),
      );
    }

    // Mode 2: Mazhab Syafi'i (Era & Tipe Matan/Syarah)
    final isSyafii = widget.agent == null ||
        widget.agent!.id == 'fiqh_syafii' ||
        widget.agent!.catalogId == 'canonical_syafii' ||
        widget.agent!.fieldId == 'fiqh';
    if (isSyafii && (_hasEras || _hasTypes)) {
      return SizedBox(
        height: 38,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
          children: [
            _filterChip(
              label: Loc.tr('ui_3236d63ff7'),
              isSelected: _selectedEra == null,
              onTap: () {
                setState(() {
                  _selectedEra = null;
                  _applyFilters();
                });
              },
              isDark: isDark,
              border: border,
              surface: surface,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            for (final era in _eras)
              _filterChip(
                label: Loc.text(era),
                isSelected: _selectedEra == era,
                onTap: () {
                  setState(() {
                    _selectedEra = _selectedEra == era ? null : era;
                    _applyFilters();
                  });
                },
                isDark: isDark,
                border: border,
                surface: surface,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            if (_types.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                width: 1,
                color: border,
              ),
              for (final type in _types)
                _filterChip(
                  label: Loc.text(type),
                  isSelected: _selectedType == type,
                  onTap: () {
                    setState(() {
                      _selectedType = _selectedType == type ? null : type;
                      _applyFilters();
                    });
                  },
                  isDark: isDark,
                  border: border,
                  surface: surface,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
            ],
          ],
        ),
      );
    }

    // Mode 3: Hadits, Ushul Fikih, & Tahawwulat (Abad Kronologis Turath)
    return SizedBox(
      height: 38,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
        children: [
          _filterChip(
            label: Loc.tr('ui_3236d63ff7'),
            isSelected: _selectedCentury == null,
            onTap: () {
              setState(() {
                _selectedCentury = null;
                _applyFilters();
              });
            },
            isDark: isDark,
            border: border,
            surface: surface,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          for (final century in _centuries)
            _filterChip(
                label: Loc.text(century),
              isSelected: _selectedCentury == century,
              onTap: () {
                setState(() {
                  _selectedCentury =
                      _selectedCentury == century ? null : century;
                  _applyFilters();
                });
              },
              isDark: isDark,
              border: border,
              surface: surface,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryAccent,
  }) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(OTSpacing.lg),
        itemCount: 8,
        itemBuilder: (ctx, i) => _buildSkeletonItem(surface, border),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(OTSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: textSecondary),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: OTTypography.body(color: textPrimary),
              ),
              const SizedBox(height: 16),
              AppleInteractiveWrapper(
                onTap: _loadCatalog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppCopy.tryAgain,
                    style: OTTypography.button(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredBooks == null || _filteredBooks!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(OTSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: textSecondary),
              const SizedBox(height: 12),
              Text(
                Loc.tr('ui_022c202d54'),
                style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Loc.tr('ui_6e35db0b1e'),
                textAlign: TextAlign.center,
                style: OTTypography.caption(color: textSecondary),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 16),
                AppleInteractiveWrapper(
                  onTap: _clearFilters,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Loc.tr('ui_ae4f9663d7'),
                      style: OTTypography.button(color: textPrimary)
                          .copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCatalog,
      color: primaryAccent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(
          horizontal: OTSpacing.lg,
          vertical: OTSpacing.sm,
        ),
        itemCount: _filteredBooks!.length,
        itemBuilder: (context, index) {
          final book = _filteredBooks![index];
          return BookRowItem(
            book: book,
            searchQuery: _searchQuery,
            onTap: () => _openBookDetail(book),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonItem(Color surface, Color border) {
    return Container(
      margin: const EdgeInsets.only(bottom: OTSpacing.sm),
      height: 72,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.8),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color border,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final activeBg = textPrimary;
    final activeFg = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: AppleInteractiveWrapper(
        onTap: onTap,
        pressedScale: 0.94,
        hapticType: HapticFeedbackType.selection,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? activeBg : border,
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: OTTypography.caption(
                    color: isSelected ? activeFg : textSecondary)
                .copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
