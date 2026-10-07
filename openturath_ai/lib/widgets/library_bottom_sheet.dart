import 'adaptive_sheet.dart';
import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/navigation_guard.dart';
import '../core/routes.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import '../services/open_turath_catalog_repository.dart';
import '../screens/book_library_editorial_screen.dart';
import '../core/app_snackbar.dart';
import 'apple_interactive_wrapper.dart';
import '../core/localization.dart';

/// Opens the Canonical Research Library as a dedicated full-screen scholarly catalog route.
/// Eliminates sheet-on-sheet anti-pattern per Apple HIG.
Future<void> showResearchLibrary(
  BuildContext context, {
  AgentModel? agent,
}) async {
  final agentKey = agent?.id ?? 'fiqh_syafii';
  try {
    final repository = OpenTurathCatalogRepository.instance;
    final metadata = await repository.getMetadataForModule(agentKey);
    final books = await repository.loadBooksForModule(agentKey);
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
        OpenTurathBookLibraryPage(books: books,
            collectionName: Loc.text(agent?.title ?? metadata?.nama ?? AppCopy.libraryShort),
            metadata: metadata)));
  } catch (_) {
    if (context.mounted) AppSnackBar.error(context, Loc.tr('catalogFailure'));
  }

}

class ResearchLibrarySheet extends StatefulWidget {
  const ResearchLibrarySheet({super.key, this.agent});

  final AgentModel? agent;

  @override
  State<ResearchLibrarySheet> createState() => _ResearchLibrarySheetState();
}

class _ResearchLibrarySheetState extends State<ResearchLibrarySheet> {
  final TextEditingController _searchController = TextEditingController();
  final CanonicalLibraryService _service = CanonicalLibraryService.instance;

  List<CanonicalBookPresentation>? _allBooks;
  List<CanonicalBookPresentation>? _filteredBooks;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedEra;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_allBooks == null) return;
    setState(() {
      _filteredBooks = _service.filterBooks(
        _allBooks!,
        _searchController.text,
        eraFilter: _selectedEra,
      );
    });
  }

  Future<void> _loadData() async {
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
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppCopy.catalogLoadFailed;
        _isLoading = false;
      });
    }
  }

  void _showEditionDetails(CanonicalBookPresentation book) {
    NavigationGuard.safePushNamed(
      context,
      AppRoutes.bookDetail,
      arguments: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    final title = widget.agent != null
        ? 'Kitab rujukan ${widget.agent!.title}'
        : 'Kitab rujukan Mazhab Syafi\'i';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: canvas,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(OTRadius.sheet)),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Column(
            children: [
              // Drag handle
              const Center(child: SheetGrabber()),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: OTFontSize.s18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_allBooks != null)
                            Text(
                              '${_filteredBooks?.length ?? 0} dari ${_allBooks!.length} kitab rujukan',
                              style: OTTypography.caption(color: textSecondary),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: OTSpacing.lg, vertical: OTSpacing.sm),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Loc.tr('librarySearchHint'),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

              const SizedBox(height: OTSpacing.xs),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(OTSpacing.xl),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.menu_book_outlined, size: 48, color: textSecondary),
                                  const SizedBox(height: OTSpacing.md),
                                  Text(
                                    _errorMessage!,
                                    style: OTTypography.body(color: textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: OTSpacing.base),
                                  OutlinedButton(
                                    onPressed: _loadData,
                                    child: Text(Loc.tr('tryAgain')),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredBooks == null || _filteredBooks!.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(OTSpacing.xl),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 40,
                                        color: textSecondary,
                                      ),
                                      const SizedBox(height: OTSpacing.sm),
                                      Text(
                                        _searchController.text.isNotEmpty
                                            ? 'Tidak ada kitab yang cocok dengan pencarian'
                                            : 'Katalog naskah sedang disiapkan.',
                                        textAlign: TextAlign.center,
                                        style: OTTypography.body(color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: OTSpacing.lg,
                                  vertical: OTSpacing.sm,
                                ),
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
      },
    );
  }
}

/// Bibliographical book tile adhering strictly to Audit Specification 6.4.
class CanonicalBookTile extends StatelessWidget {
  const CanonicalBookTile({
    super.key,
    required this.book,
    required this.onOpenEdition,
  });

  final CanonicalBookPresentation book;
  final VoidCallback onOpenEdition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final accent = OTColors.accent(isDark);

    final latinAuthor = book.authorLatin;

    return Semantics(
      button: true,
      label: '${book.titleArabic}, ${book.authorArabic}',
      child: AppleInteractiveWrapper(
        onTap: onOpenEdition,
        pressedScale: 0.98,
        hapticType: HapticFeedbackType.light,
        borderRadius: BorderRadius.circular(OTRadius.card),
        child: Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OTRadius.card),
            side: BorderSide(color: border, width: 0.8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Arabic title
                Text(
                  book.titleArabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: OTTypography.arabicReading(color: textPrimary).copyWith(
                    fontSize: OTFontSize.s20,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (book.titleLatin != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.titleLatin!,
                    style: OTTypography.bodyMedium(color: textPrimary),
                  ),
                ],
                const SizedBox(height: 8),

                // Author
                Text(
                  latinAuthor ?? book.authorArabic,
                  textDirection: latinAuthor == null ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: latinAuthor == null ? TextAlign.right : TextAlign.left,
                  style: latinAuthor == null
                      ? OTTypography.arabicReading(color: textSecondary).copyWith(fontSize: OTFontSize.s16)
                      : OTTypography.caption(color: textSecondary),
                ),

                if (book.verifiedDeathYearHijri != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'w. ${book.verifiedDeathYearHijri} H',
                    style: OTTypography.caption(color: textSecondary),
                  ),
                ],

                if (book.compactLabels.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: book.compactLabels.map((lbl) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: OTColors.surfaceSubtle(isDark),
                          borderRadius: BorderRadius.circular(OTRadius.xs),
                          border: Border.all(color: border.withValues(alpha: 0.5), width: 0.6),
                        ),
                        child: Text(
                          lbl,
                          style: OTTypography.caption(color: textSecondary).copyWith(fontSize: OTFontSize.s11),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Keterangan kitab',
                      style: OTTypography.button(color: accent).copyWith(fontSize: OTFontSize.s12),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
