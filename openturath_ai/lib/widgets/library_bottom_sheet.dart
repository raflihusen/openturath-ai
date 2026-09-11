import 'package:flutter/material.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../models/agent_model.dart';
import '../models/book_model.dart';
import '../services/canonical_library_service.dart';
import 'apple_interactive_wrapper.dart';

/// Opens the Canonical Research Library as a bottom sheet.
/// Uses [useRootNavigator: true] so it overlays cleanly over WebViews without tearing down session state.
Future<void> showResearchLibrary(
  BuildContext context, {
  AgentModel? agent,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ResearchLibrarySheet(agent: agent),
  );
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
      final books = await _service.loadSyafiiCatalog();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Katalog rujukan belum dapat dimuat saat ini.';
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
                        'Rincian Edisi Naskah',
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
                      height: 1.5,
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
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: OTSpacing.base),
                  Divider(color: border, height: 1),
                  const SizedBox(height: OTSpacing.base),
                  if (book.verifiedDeathYearHijri != null)
                    _detailRow('Tahun Wafat', '${book.verifiedDeathYearHijri} H', textPrimary, textSecondary),
                  if (book.reviewedTypeLabel != null)
                    _detailRow('Kategori Teks', book.reviewedTypeLabel!, textPrimary, textSecondary),
                  if (book.reviewedEraLabel != null)
                    _detailRow('Masa Penulisan', book.reviewedEraLabel!, textPrimary, textSecondary),
                  if (book.volumesCount != null)
                    _detailRow('Jumlah Jilid', '${book.volumesCount} Jilid', textPrimary, textSecondary),
                  if (book.publisher != null && book.publisher!.isNotEmpty)
                    _detailRow('Penerbit', book.publisher!, textPrimary, textSecondary),
                  if (book.muhaqqiq != null && book.muhaqqiq!.isNotEmpty)
                    _detailRow('Tahqiq / Editor', book.muhaqqiq!, textPrimary, textSecondary),
                  _detailRow('Pengidentifikasi Edisi', book.editionId, textPrimary, textSecondary),
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
              label,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final border = OTColors.border(isDark);

    final title = widget.agent != null
        ? 'Pustaka Rujukan ${widget.agent!.title}'
        : 'Pustaka Rujukan Madzhab Syafi\'i';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: canvas,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: border, width: 0.8),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

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
                            style: OTTypography.corpusTitle(color: textPrimary).copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_allBooks != null)
                            Text(
                              '${_filteredBooks?.length ?? 0} dari ${_allBooks!.length} naskah primer terkatalogisasi',
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
                    hintText: 'Cari judul, pengarang, penerbit, atau tahqiq...',
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
                                    child: const Text('Coba Lagi'),
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
                                      Icon(Icons.search_off_rounded, size: 40, color: textSecondary),
                                      const SizedBox(height: OTSpacing.sm),
                                      Text(
                                        'Tidak ada naskah yang cocok dengan pencarian',
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
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                    fontSize: 20,
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
                      ? OTTypography.arabicReading(color: textSecondary).copyWith(fontSize: 15)
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: OTColors.surfaceSubtle(isDark),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: border.withValues(alpha: 0.5), width: 0.6),
                        ),
                        child: Text(
                          lbl,
                          style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 11),
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
                      'Rincian edisi',
                      style: OTTypography.button(color: accent).copyWith(fontSize: 12),
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
