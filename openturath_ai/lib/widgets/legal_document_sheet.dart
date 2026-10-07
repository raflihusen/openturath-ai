library;

import '../widgets/adaptive_sheet.dart';

import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/localized_legal.dart';
import '../core/localization.dart';
import '../core/adab_icons.dart';
import '../core/scholarly_fonts.dart';

import 'package:openturath_ai/core/design/ot_typography.dart';
import 'package:openturath_ai/core/design/ot_radius.dart';

/// LegalDocumentSheet: Modal lembar kebijakan hukum dan identitas OpenTurath.
/// Mengadopsi prinsip desain "The Quiet Scholar" dengan keterbacaan tinggi,
/// tipografi terpadu, dan pembagian pasal yang lapang.
class LegalDocumentSheet extends StatelessWidget {
  final LegalDocumentId documentId;
  const LegalDocumentSheet({super.key, required this.documentId});
  static Future<void> showTermsOfService(BuildContext context) =>
      _show(context, LegalDocumentId.terms);
  static Future<void> showPrivacyPolicy(BuildContext context) =>
      _show(context, LegalDocumentId.privacy);
  static Future<void> showRefundPolicy(BuildContext context) =>
      _show(context, LegalDocumentId.refund);
  static Future<void> showAiGuideline(BuildContext context) =>
      _show(context, LegalDocumentId.guideline);
  static Future<void> showContactSupport(BuildContext context) =>
      _show(context, LegalDocumentId.contact);
  static Future<void> _show(BuildContext context, LegalDocumentId id) =>
      showAdaptiveSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => LegalDocumentSheet(documentId: id));

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final document = LocalizedLegal.resolve(documentId);
    final title = document.title, subtitle = document.subtitle;
    final sections = document.sections;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final border = OTColors.border(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);

    return Directionality(
        textDirection: Loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(OTRadius.sheet)),
            border: Border.all(color: border, width: 0.8),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              const Center(child: SheetGrabber(bottom: 16)),

              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s22,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded,
                        size: 20, color: textSecondary),
                    splashRadius: 20,
                    tooltip: Loc.tr('close'),
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sec = sections[index];
                    final icon = AdabIcons.forSection(sec.id);
                    final heading = Text(sec.title,
                        style: ScholarlyFonts.outfit(
                            fontSize: OTFontSize.s16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary));
                    final content = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null)
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ExcludeSemantics(
                                      child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: OTColors.surface(isDark),
                                              borderRadius:
                                                  OTRadius.cardBorder),
                                          child: Icon(icon,
                                              size: 22, color: textPrimary))),
                                  const SizedBox(width: 12),
                                  Expanded(child: heading),
                                ])
                          else
                            heading,
                          const SizedBox(height: 12),
                          Text(LocalizedLegal.displayBody(sec.content),
                              semanticsLabel: sec.content,
                              style: ScholarlyFonts.outfit(
                                  fontSize: OTFontSize.s14,
                                  height: 1.65,
                                  color: textSecondary)),
                        ]);
                    return icon == null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: content)
                        : Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: OTColors.surfaceSubtle(isDark),
                                borderRadius: OTRadius.cardBorder),
                            child: content);
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
                  ),
                  child: Text(
                    Loc.tr('close'),
                    style: ScholarlyFonts.outfit(
                      fontSize: OTFontSize.s14,
                      fontWeight: FontWeight.w600,
                      color: canvas,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
