import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';

class EvidenceBottomSheet extends StatelessWidget {
  final int citationNumber;
  final String bookName;
  final String author;
  final String pageNumber;
  final String category;
  final String arabicExcerpt;
  final String explanation;
  final String? externalUrl;

  const EvidenceBottomSheet({
    super.key,
    required this.citationNumber,
    required this.bookName,
    required this.author,
    required this.pageNumber,
    required this.category,
    required this.arabicExcerpt,
    required this.explanation,
    this.externalUrl,
  });

  Future<void> _launchExternal(BuildContext context) async {
    final query = Uri.encodeComponent(bookName);
    final url = externalUrl != null && externalUrl!.isNotEmpty
        ? Uri.parse(externalUrl!)
        : Uri.parse('https://shamela.ws/search?q=$query');

    try {
      final canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          AppSnackBar.error(context, 'Tidak dapat membuka rujukan eksternal: $url');
        }
      }
    } catch (_) {}
  }

  void _copyIbarah(BuildContext context) {
    Clipboard.setData(ClipboardData(text: arabicExcerpt));
    AppSnackBar.success(context, 'Ibarah tersalin.');
  }

  void _shareEvidence(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('📖 *Rujukan Ilmiah: $bookName*');
    buffer.writeln('Pengarang: $author');
    buffer.writeln('Disiplin: $category | Halaman: $pageNumber');
    buffer.writeln();
    if (arabicExcerpt.isNotEmpty) {
      buffer.writeln('نص العبارة:');
      buffer.writeln('« $arabicExcerpt »');
      buffer.writeln();
    }
    if (explanation.isNotEmpty) {
      buffer.writeln('Taqrir & Syarah:');
      buffer.writeln(explanation);
      buffer.writeln();
    }
    buffer.writeln('—');
    buffer.writeln('Disimpan melalui *OpenTurath*');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppSnackBar.success(context, 'Sitasi rujukan tersalin.');
  }

  Widget _stagger(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 260 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, animChild) {
        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: animChild,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final textPrimary = isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary = isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag Handle ──
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
              ),

              // ── Header Bar (Figma Screen 10) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 20, color: accent),
                        const SizedBox(width: 8),
                        Text(
                          'Ibarah & rujukan',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary, size: 22),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Scrollable Body with Stagger Reveal ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    // 1. Book Name (Arabic / Latin)
                    _stagger(
                      0,
                      Text(
                        bookName,
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Metadata Grid (Penulis, Halaman, Kategori)
                    _stagger(
                      1,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceCardDark : AppTheme.groupedCanvasLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(color: border, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pengarang', style: GoogleFonts.outfit(fontSize: 12, color: textSecondary)),
                                Flexible(
                                  child: Text(
                                    author,
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: border),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Halaman', style: GoogleFonts.outfit(fontSize: 12, color: textSecondary)),
                                Text(
                                  pageNumber,
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: border),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Disiplin', style: GoogleFonts.outfit(fontSize: 12, color: textSecondary)),
                                Text(
                                  category,
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: accent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Section: Teks Asli Kitab (Ibarah) with subtle border glow
                    _stagger(
                      2,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_quote_rounded, size: 18, color: accent),
                              const SizedBox(width: 6),
                              Text(
                                'Naskah ibarah asli',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceElevated : AppTheme.citationBgLight,
                              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                              border: Border.all(
                                color: accent.withValues(alpha: isDark ? 0.35 : 0.25),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: isDark ? 0.08 : 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SelectableText(
                              arabicExcerpt,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.scheherazadeNew(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                height: 1.7,
                                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. Section: Intisari & Penjelasan Kontekstual
                    _stagger(
                      3,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Intisari & penjelasan',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            explanation,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 5. Action Buttons
                    _stagger(
                      4,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _copyIbarah(context),
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text('Salin ibarah'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accent,
                                side: BorderSide(color: accent.withValues(alpha: 0.6)),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                ),
                                textStyle: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _launchExternal(context),
                              icon: const Icon(Icons.open_in_new_rounded, size: 16),
                              label: const Text('Buka di Maktabah Syamilah'),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: isDark
                                    ? AppTheme.canvasDark
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                ),
                                textStyle: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () => _shareEvidence(context),
                            icon: const Icon(Icons.share_outlined, size: 18),
                            tooltip: 'Salin rujukan ilmiah',
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
