import '../core/l10n/app_dictionary.dart';
import '../core/l10n/library_dictionary.dart';
import 'dart:async';
import 'package:flutter/material.dart';

import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import '../widgets/book_row_item.dart';
import '../widgets/editorial.dart';

/// Searchable catalogue backed by the canonical library repository.
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
        _errorMessage = 'library.load_failed';
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
    _debounce?.cancel();
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
    // Search result quantities are UI counts, so honor the numeral preference.
    return context.uiNumber(number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}${context.languageCode == 'id' ? '.' : ','}',
        ));
  }

  String _cleanSectionLabel(String full) {
    final match = RegExp(r'\((.*?)\)').firstMatch(full);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    return full;
  }

  Future<void> _showFilters() async {
    final useEras = _hasEras;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: .8,
          child: StatefulBuilder(builder: (_, refresh) {
            Widget choices(String title, List<String> values, String? selected,
                void Function(String?) select, {bool arabic = false}) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: values.map((value) => ChoiceChip(
                    label: arabic ? EditorialArabicText(_cleanSectionLabel(value), fontSize: 20) : Text(libraryDataLabel(value, context.languageCode)),
                    selected: selected == value,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onSelected: (_) {
                      setState(() {
                        select(selected == value ? null : value);
                        _applyFilters();
                      });
                      refresh(() {});
                    },
                  )).toList()),
                ]),
              );
            }
            return ListView(padding: const EdgeInsets.all(24), children: [
              Text(context.tr('library.filter'), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              if (_availableSections.length > 1)
                choices(context.tr('library.field'), _availableSections, _selectedSection,
                  (value) => _selectedSection = value, arabic: true),
              choices(context.tr('library.period'), useEras ? _eras : _centuries,
                useEras ? _selectedEra : _selectedCentury, (value) {
                  if (useEras) { _selectedEra = value; _selectedCentury = null; }
                  else { _selectedCentury = value; _selectedEra = null; }
                }),
              if (_hasTypes)
                choices(context.tr('library.type'), _types, _selectedType, (value) => _selectedType = value),
              EditorialButton(label: context.tr('library.results'), onPressed: () => Navigator.pop(sheetContext)),
            ]);
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final books = _filteredBooks ?? const <CanonicalBookPresentation>[];
    return Scaffold(
      backgroundColor: OTColors.canvas(dark),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
                sliver: SliverToBoxAdapter(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EditorialHeader(title: context.tr('library.catalog'), eyebrow: context.tr('library.eyebrow'), showBack: true,
                      subtitle: widget.agent == null ? context.tr('library.syafii') : context.agentTitle(widget.agent!)),
                    const SizedBox(height: 24),
                    EditorialSearchField(controller: _searchCtrl, onChanged: _onSearchChanged,
                      hintText: context.tr('library.search')),
                    const SizedBox(height: 12),
                    Wrap(spacing: 12, runSpacing: 8, children: [
                      EditorialButton(label: context.tr('library.filter'), icon: Icons.tune_outlined,
                        secondary: true, onPressed: _isLoading ? null : _showFilters),
                      if (_hasActiveFilters)
                        EditorialButton(label: context.tr('library.clear'), secondary: true, onPressed: _clearFilters),
                    ]),
                    const SizedBox(height: 24),
                    if (!_isLoading && _errorMessage == null)
                      Text(context.tr('library.count', args: {'count': libraryBidi(_formatNumber(books.length), context.languageCode), 'total': libraryBidi(_formatNumber(_allBooks?.length ?? 0), context.languageCode)}),
                        style: OTTypography.caption(color: OTColors.textSecondary(dark))),
                    const SizedBox(height: 16),
                  ],
                )),
              ),
              if (_isLoading)
                const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator())))
              else if (_errorMessage != null)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24),
                  child: EditorialEmptyState(title: context.tr('library.load_title'), description: context.tr(_errorMessage!),
                    action: EditorialButton(label: context.tr('library.retry'), onPressed: _loadCatalog))))
              else if (books.isEmpty)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(24),
                  child: EditorialEmptyState(
                    title: _hasActiveFilters ? context.tr('library.no_match') : context.tr('library.unavailable'),
                    description: _hasActiveFilters ? context.tr('library.search_again') : context.tr('library.no_catalog'),
                    action: EditorialButton(label: _hasActiveFilters ? context.tr('library.clear') : context.tr('library.reload'),
                      onPressed: _hasActiveFilters ? _clearFilters : _loadCatalog))))
              else
                SliverPadding(padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 40),
                  sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                    final book = books[index];
                    return Padding(padding: const EdgeInsets.only(bottom: 12),
                      child: BookRowItem(book: book, searchQuery: _searchQuery,
                        onTap: () => _openBookDetail(book)));
                  }, childCount: books.length))),
            ]),
          ),
        ),
      ),
    );
  }
}
