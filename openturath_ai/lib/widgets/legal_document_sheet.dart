library;

import 'package:flutter/material.dart';
import 'package:openturath_ai/core/design/ot_fonts.dart';

import '../core/design/ot_colors.dart';
import '../core/legal_copy.dart';
import '../core/l10n/app_dictionary.dart';

/// LegalDocumentSheet: Modal lembar kebijakan hukum dan identitas OpenTurath.
/// Mengadopsi prinsip desain "The Quiet Scholar" dengan keterbacaan tinggi,
/// tipografi terpadu, dan pembagian pasal yang lapang.
class LegalDocumentSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<LegalSection> sections;

  const LegalDocumentSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  /// Buka lembar Ketentuan Layanan
  static Future<void> showTermsOfService(BuildContext context) {
    return _show(
      context,
      title: LegalCopy.termsTitle,
      subtitle: 'legal.version.effective',
      sections: LegalCopy.termsSections,
    );
  }

  /// Buka lembar Kebijakan Privasi
  static Future<void> showPrivacyPolicy(BuildContext context) {
    return _show(
      context,
      title: LegalCopy.privacyTitle,
      subtitle: 'legal.version.privacy',
      sections: LegalCopy.privacySections,
    );
  }

  /// Buka lembar Pembayaran dan Pengembalian Dana
  static Future<void> showRefundPolicy(BuildContext context) {
    return _show(
      context,
      title: LegalCopy.refundTitle,
      subtitle: 'Ketentuan Pembayaran DOKU & Pengembalian Dana',
      sections: LegalCopy.refundSections,
    );
  }

  /// Buka lembar Panduan Penggunaan AI dan Rujukan
  static Future<void> showAiGuideline(BuildContext context) {
    return _show(
      context,
      title: LegalCopy.aiGuidelineTitle,
      subtitle: 'Etika Telaah, Pembacaan Konteks, dan Adab Keilmuan',
      sections: LegalCopy.aiGuidelineSections,
    );
  }

  /// Buka lembar Bantuan dan Kontak
  static Future<void> showContactSupport(BuildContext context) {
    return _show(
      context,
      title: LegalCopy.contactTitle,
      subtitle: 'Saluran Resmi dan Pengaduan Layanan',
      sections: LegalCopy.contactSections,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<LegalSection> sections,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LegalDocumentSheet(
        title: title,
        subtitle: subtitle,
        sections: sections,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: border, width: 0.8),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(title),
                      style: OTFonts.newsreader(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(subtitle, args: {
                        'version': LegalCopy.documentVersion,
                        'date': context.tr(LegalCopy.effectiveDate),
                      }),
                      style: OTFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('Tutup'),
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                splashRadius: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: border),
          const SizedBox(height: 16),

          // Scrollable Sections
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: sections.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: border.withValues(alpha: 0.6)),
              ),
              itemBuilder: (context, index) {
                final sec = sections[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(sec.title),
                      style: OTFonts.newsreader(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(sec.content),
                      style: OTFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        color: textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Close Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: canvas,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.tr('Tutup'),
                style: OTFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: canvas,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


