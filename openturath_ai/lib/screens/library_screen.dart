import '../core/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import '../widgets/library_bottom_sheet.dart';

/// Full screen view for the research library.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, this.agent});

  final AgentModel? agent;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CanonicalLibraryService _service = CanonicalLibraryService.instance;
  Timer? _searchDebounce;

  List<CanonicalBookPresentation>? _allBooks;
  List<CanonicalBookPresentation>? _filteredBooks;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      if (_allBooks == null || !mounted) return;
      setState(() {
        _filteredBooks = _service.filterBooks(
          _allBooks!,
          _searchController.text,
        );
      });
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = widget.agent != null ? await _service.loadCatalogForAgent(widget.agent!) : await _service.loadSyafiiCatalog();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = Loc.tr('ui_3e2acc1d99');
        _isLoading = false;
      });
    }
  }

  void _showEditionDetails(CanonicalBookPresentation book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(OTSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Loc.tr('ui_0c9f252156'),
                        style: OTTypography.sectionHeading(color: textSecondary),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: OTSpacing.sm),
                  Text(
                    book.titleArabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: OTTypography.arabicReading(color: textPrimary).copyWith(
                      fontSize: 22,
                      height: 1.85,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: OTSpacing.xs),
                  Text(
                    book.authorArabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: OTTypography.arabicReading(color: textSecondary).copyWith(
                      fontSize: 16,
                      height: 1.85,
                    ),
                  ),
                  const SizedBox(height: OTSpacing.base),
                  Divider(color: border, height: 1),
                  const SizedBox(height: OTSpacing.base),
                  if (book.verifiedDeathYearHijri != null)
                    _detailRow(Loc.tr('ui_872fd06ff7'), '${book.verifiedDeathYearHijri} H', textPrimary, textSecondary),
                  if (book.reviewedTypeLabel != null)
                    _detailRow(Loc.tr('ui_47b35543e3'), book.reviewedTypeLabel!, textPrimary, textSecondary),
                  if (book.reviewedEraLabel != null)
                    _detailRow(Loc.tr('ui_85e181b57a'), book.reviewedEraLabel!, textPrimary, textSecondary),
                  if (book.volumesCount != null)
                    _detailRow(Loc.tr('ui_7e06fac12c'), '${book.volumesCount} Jilid', textPrimary, textSecondary),
                  if (book.publisher != null && book.publisher!.isNotEmpty)
                    _detailRow(Loc.tr('ui_291c152262'), book.publisher!, textPrimary, textSecondary),
                  if (book.muhaqqiq != null && book.muhaqqiq!.isNotEmpty)
                    _detailRow(Loc.tr('ui_e488d9f73e'), book.muhaqqiq!, textPrimary, textSecondary),
                  _detailRow(Loc.tr('ui_88bddfe74a'), book.editionId, textPrimary, textSecondary),
                  const SizedBox(height: OTSpacing.base),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              Loc.text(label),
              style: OTTypography.caption(color: textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: OTTypography.bodyMedium(color: textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    final title = widget.agent != null
        ? '${Loc.tr('ui_9f0b5b5d87')} · ${widget.agent!.title}'
        : Loc.tr('ui_9f0b5b5d87');

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Loc.text(title),
              style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
            ),
            if (_allBooks != null)
              Text(
                Loc.tr('bookCount', ['${_filteredBooks?.length ?? 0}']),
                style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(OTSpacing.lg),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: Loc.tr('ui_c8c23c3325'),
                hintStyle: OTTypography.caption(color: textSecondary),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: textSecondary),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: border, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: border, width: 0.8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book_outlined, size: 48, color: textSecondary),
                            const SizedBox(height: OTSpacing.md),
                            Text(_errorMessage!, style: OTTypography.body(color: textSecondary)),
                            const SizedBox(height: OTSpacing.base),
                            OutlinedButton(onPressed: _loadData, child: Text(Loc.tr('tryAgain'))),
                          ],
                        ),
                      )
                    : _filteredBooks == null || _filteredBooks!.isEmpty
                        ? Center(
                            child: Text(
                              Loc.tr('ui_6b42d45847'),
                              style: OTTypography.body(color: textSecondary),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.xs),
                            itemCount: _filteredBooks!.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (ctx, index) {
                              final item = _filteredBooks![index];
                              return CanonicalBookTile(
                                book: item,
                                onOpenEdition: () => _showEditionDetails(item),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
