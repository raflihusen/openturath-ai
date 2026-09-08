import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';
import '../widgets/evidence_bottom_sheet.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<BookmarkModel> _allBookmarks = [];
  List<BookmarkModel> _filteredBookmarks = [];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = true;
  bool _showSearch = false;

  final List<String> _categories = [
    'Semua',
    'Fikih',
    'Hadis',
    'Tafsir',
    'Usul Fiqh',
    'Bahasa Arab',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final list = await _bookmarkService.getBookmarks();
    if (mounted) {
      setState(() {
        _allBookmarks = list;
        _filter();
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final q = _searchQuery.toLowerCase().trim();
    _filteredBookmarks = _allBookmarks.where((b) {
      final matchesCategory = _selectedCategory == 'Semua' ||
          b.fieldName.toLowerCase().contains(_selectedCategory.toLowerCase());
      if (!matchesCategory) return false;
      if (q.isEmpty) return true;
      return b.title.toLowerCase().contains(q) ||
          b.agentTitle.toLowerCase().contains(q) ||
          b.bookReference.toLowerCase().contains(q) ||
          b.arabicExcerpt.contains(q) ||
          b.fullAnswer.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _deleteBookmark(BookmarkModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Hapus Rujukan?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Rujukan "${item.title}" akan dihapus dari daftar tersimpan.',
            style: GoogleFonts.outfit(fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444)),
              child: Text('Hapus',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _bookmarkService.deleteBookmark(item.id);
    await _loadBookmarks();

    if (!mounted) return;
    AppSnackBar.info(
      context,
      'Rujukan "${item.title}" berhasil dihapus.',
      action: SnackBarAction(
        label: 'Urungkan',
        textColor: const Color(0xFFFBBF24),
        onPressed: () async {
          await _bookmarkService.addBookmark(item);
          await _loadBookmarks();
        },
      ),
    );
  }

  void _copyIbarah(String ibarah) {
    Clipboard.setData(ClipboardData(text: ibarah));
    AppSnackBar.success(context, 'Kutipan ibarah berhasil disalin ke clipboard.');
  }

  void _showEvidence(BookmarkModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EvidenceBottomSheet(
        citationNumber: 1,
        bookName: item.bookReference,
        author: item.agentTitle,
        pageNumber: item.pageNumber,
        category: item.fieldName,
        arabicExcerpt: item.arabicExcerpt,
        explanation: item.fullAnswer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final surface =
        isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    return Scaffold(
      backgroundColor: canvas,
      appBar: AppBar(
        backgroundColor: canvas,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bookmark',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            Text(
              'Koleksi kutipan ibarah dan referensi tersimpan',
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: textPrimary,
            ),
            tooltip: _showSearch ? 'Tutup Pencarian' : 'Cari Bookmark',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                  _filter();
                }
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Field (collapsible) ──
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1F20)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: border, width: 1),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _filter();
                      });
                    },
                    style: GoogleFonts.outfit(fontSize: 13, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari dalam kutipan, kitab, atau topik...',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: isDark
                            ? AppTheme.textTertiaryDark
                            : AppTheme.textTertiaryLight,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: isDark
                            ? AppTheme.textTertiaryDark
                            : AppTheme.textTertiaryLight,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded,
                                  size: 16, color: textSecondary),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filter();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

            // ── Horizontal Filter Pills ──
            Container(
              height: 38,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                        _filter();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF18181B))
                            : surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : border,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── List of Saved Bookmarks ──
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: accent,
                      ),
                    )
                  : _filteredBookmarks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.2),
                                    width: 1.2,
                                  ),
                                ),
                                child: Lottie.asset(
                                  isDark
                                      ? 'assets/animations/thinking_ux_icon_looping_darkmode.json'
                                      : 'assets/animations/thinking_ux_icon_looping.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Belum Ada Rujukan Tersimpan',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Tandai ibarah kitab dari ruang riset AI untuk menelaah dan menyimpannya di sini.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 108),
                          itemCount: _filteredBookmarks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = _filteredBookmarks[index];
                            return TweenAnimationBuilder<double>(
                              key: ValueKey(item.id),
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 240 + (index * 40)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 18 * (1 - value)),
                                  child: Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: _BookmarkCard(
                                item: item,
                                isDark: isDark,
                                surface: surface,
                                border: border,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                accent: accent,
                                onCopy: () => _copyIbarah(item.arabicExcerpt),
                                onOpen: () => _showEvidence(item),
                                onDelete: () => _deleteBookmark(item),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final BookmarkModel item;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.item,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onCopy,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Pill + Agent Title + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.fieldName,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.agentTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: textSecondary.withValues(alpha: 0.7),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            item.title,
            style: GoogleFonts.outfit(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              color: textPrimary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // Book Reference Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF28292A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border.withValues(alpha: 0.6), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 14, color: accent),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${item.bookReference} · ${item.pageNumber}',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Arabic Excerpt Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131314) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border.withValues(alpha: 0.4), width: 0.8),
            ),
            child: Text(
              item.arabicExcerpt,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                height: 1.6,
                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Salin Ibarah'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.menu_book, size: 14),
                label: const Text('Lihat Bukti'),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF28292A) : const Color(0xFFE2E8F0),
                  foregroundColor: textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
