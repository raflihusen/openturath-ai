import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_copy.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import '../widgets/book_row_item.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// Halaman Katalog Naskah Penuh (Full-Screen Route).
/// Menggantikan modal bottom sheet sempit agar pengguna memiliki ruang baca yang lapang,
/// tenang, dan mudah ditelusuri sesuai standar Apple HIG.
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
  final TextEditingController _searchCtrl = TextEditingController();
  final CanonicalLibraryService _service = CanonicalLibraryService.instance;
  Timer? _debounce;

  List<CanonicalBookPresentation>? _allBooks;
  List<CanonicalBookPresentation>? _filteredBooks;
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedEra;
  String? _selectedType;
  String _searchQuery = '';

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
      final books = await _service.loadSyafiiCatalog();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
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
    _debounce = Timer(const Duration(milliseconds: 200), () {
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
      eraFilter: _selectedEra,
      typeFilter: _selectedType,
    );
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = '';
      _selectedEra = null;
      _selectedType = null;
      _applyFilters();
    });
  }

  void _openBookDetail(CanonicalBookPresentation book) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookDetail,
      arguments: book,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pustaka Kitab Kanonikal',
              style: OTTypography.screenTitle(color: textPrimary).copyWith(fontSize: 18),
            ),
            Text(
              '87 Kitab Mazhab Syafi\'i',
              style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_selectedEra != null || _selectedType != null || _searchQuery.isNotEmpty)
            TextButton(
              onPressed: _clearFilters,
              child: Text(
                'Reset',
                style: OTTypography.button(color: primaryAccent).copyWith(fontSize: 13),
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
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.outfit(fontSize: 13.5, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Cari judul Arab/Latin, pengarang, muhaqqiq...',
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
                        child: Icon(Icons.close_rounded, size: 18, color: textSecondary),
                      ),
                  ],
                ),
              ),
            ),

            // ── HORIZONTAL ERA & TYPE FILTER CHIPS ──
            SizedBox(
              height: 38,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg),
                children: [
                  _filterChip(
                    label: 'Semua Era',
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
                      label: era,
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    width: 1,
                    color: border,
                  ),
                  for (final type in _types)
                    _filterChip(
                      label: type,
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
              ),
            ),

            const SizedBox(height: OTSpacing.sm),

            // ── RESULTS COUNT HEADER ──
            if (!_isLoading && _filteredBooks != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OTSpacing.lg,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'Menampilkan ${_filteredBooks!.length} naskah rujukan',
                      style: OTTypography.caption(color: textSecondary).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedEra != null || _selectedType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: isDark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          [
                            if (_selectedEra != null) _selectedEra!,
                            if (_selectedType != null) _selectedType!,
                          ].join(' · '),
                          style: OTTypography.caption(color: primaryAccent).copyWith(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                'Tidak ditemukan kitab yang sesuai.',
                style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coba gunakan kata kunci Arab, nama pengarang, atau hapus filter era.',
                textAlign: TextAlign.center,
                style: OTTypography.caption(color: textSecondary),
              ),
              const SizedBox(height: 16),
              AppleInteractiveWrapper(
                onTap: _clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Hapus Semua Filter',
                    style: OTTypography.button(color: textPrimary).copyWith(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCatalog,
      color: primaryAccent,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
      padding: const EdgeInsets.only(right: 6),
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
            style: OTTypography.caption(color: isSelected ? activeFg : textSecondary).copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
