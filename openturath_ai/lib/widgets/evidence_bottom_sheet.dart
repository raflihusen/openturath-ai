import 'adaptive_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/app_snackbar.dart';
import '../core/app_copy.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_colors.dart';
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
          AppSnackBar.error(context, Loc.tr('externalReferenceFailed', ['$url']));
        }
      }
    } catch (_) {}
  }

  void _copyIbarah(BuildContext context) {
    Clipboard.setData(ClipboardData(text: arabicExcerpt));
    AppSnackBar.success(context, Loc.tr('ibarahCopied'));
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
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppSnackBar.success(context, AppCopy.referenceCopied);
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
                color: OTColors.shadow.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag Handle ──
              const Center(child: SheetGrabber()),

              // ── Header Bar (Figma Screen 10) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 20, color: accent),
                        const SizedBox(width: 8),
                        Text(
                          'Ibarah & rujukan',
                          style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s16,
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
                        style: ScholarlyFonts.newsreader(
                          fontSize: OTFontSize.s20,
                          fontWeight: FontWeight.w600,
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceElevated : AppTheme.surfaceCardLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Loc.tr('authorLabel'), style: ScholarlyFonts.outfit(fontSize: OTFontSize.s12, color: textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ScholarlyFonts.outfit(fontSize: OTFontSize.s14, fontWeight: FontWeight.w600, color: textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 28, color: border, margin: const EdgeInsets.symmetric(horizontal: 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Loc.tr('pageLabel'), style: ScholarlyFonts.outfit(fontSize: OTFontSize.s12, color: textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    pageNumber,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ScholarlyFonts.outfit(fontSize: OTFontSize.s14, fontWeight: FontWeight.w600, color: textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 28, color: border, margin: const EdgeInsets.symmetric(horizontal: 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Loc.tr('disciplineLabel'), style: ScholarlyFonts.outfit(fontSize: OTFontSize.s12, color: textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ScholarlyFonts.outfit(fontSize: OTFontSize.s14, fontWeight: FontWeight.w600, color: accent),
                                  ),
                                ],
                              ),
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
                                style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
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
                              style: ScholarlyFonts.scheherazadeNew(
                                fontSize: OTFontSize.s20,
                                fontWeight: FontWeight.w700,
                                height: 1.8,
                                color: textPrimary,
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
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            explanation,
                            style: ScholarlyFonts.outfit(
                              fontSize: OTFontSize.s14,
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
                              label: Text(Loc.tr('copyIbarahAction')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accent,
                                side: BorderSide(color: accent.withValues(alpha: 0.6)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                textStyle: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
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
                              label: Text(Loc.tr('openInShamela')),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: isDark
                                    ? AppTheme.canvasDark
                                    : OTColors.surfaceLight,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                textStyle: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            onPressed: () => _shareEvidence(context),
                            icon: const Icon(Icons.share_outlined, size: 18),
                            tooltip: Loc.tr('copyScholarlyCitation'),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
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
