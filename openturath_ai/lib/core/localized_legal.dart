import 'legal_copy.dart';
import 'legal_copy_en.dart';
import 'legal_copy_ar.dart';
import 'localization.dart';

enum LegalDocumentId { terms, privacy, refund, guideline, contact }

class LegalDocumentContent {
  const LegalDocumentContent(this.title, this.subtitle, this.sections);
  final String title, subtitle;
  final List<LegalSection> sections;
}

abstract final class LocalizedLegal {
  /// Isolates UI-only Latin identifiers; canonical text remains untouched.
  static String displayBody(String source, {String? locale}) {
    if ((locale ?? Loc.language) != 'ar') return source;
    return source.replaceAllMapped(
      RegExp(r'https?://[^\s]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|[0-9]+/[0-9]+'),
      (match) => Loc.ltr(match.group(0)!));
  }

  static List<LegalSection> canonical(LegalDocumentId id) => switch (id) {
        LegalDocumentId.terms => LegalCopy.termsSections,
        LegalDocumentId.privacy => LegalCopy.privacySections,
        LegalDocumentId.refund => LegalCopy.refundSections,
        LegalDocumentId.guideline => LegalCopy.aiGuidelineSections,
        LegalDocumentId.contact => LegalCopy.contactSections,
      };
  static LegalDocumentContent resolve(LegalDocumentId id, {String? locale}) {
    final code = locale ?? Loc.language;
    final source = canonical(id);
    final names = switch (id) {
      LegalDocumentId.terms => [
          LegalCopy.termsTitle,
          'Terms of Service',
          'شروط الخدمة'
        ],
      LegalDocumentId.privacy => [
          LegalCopy.privacyTitle,
          'Privacy Policy',
          'سياسة الخصوصية'
        ],
      LegalDocumentId.refund => [
          LegalCopy.refundTitle,
          'Payment and Refunds',
          'الدفع والاسترداد'
        ],
      LegalDocumentId.guideline => [
          LegalCopy.aiGuidelineTitle,
          'AI Use and Reference Guide',
          'دليل استخدام الذكاء الاصطناعي والمراجع'
        ],
      LegalDocumentId.contact => [
          LegalCopy.contactTitle,
          'Support and Contact',
          'الدعم والتواصل'
        ],
    };
    final i = code == 'ar'
        ? 2
        : code == 'en'
            ? 1
            : 0;
    final translated =
        i == 0 ? null : (i == 2 ? legalArabic : legalEnglish)[id.name];
    if (i != 0 && (translated == null || translated.length != source.length)) {
      throw StateError('Incomplete legal translation: ${id.name}/$code');
    }
    return LegalDocumentContent(
        names[i],
        [
          'Versi ${LegalCopy.documentVersion} · Berlaku mulai ${LegalCopy.effectiveDate}',
          'Version ${LegalCopy.documentVersion} · Effective 13 September 2026',
          'الإصدار ${LegalCopy.documentVersion} · نافذ منذ 13 سبتمبر 2026',
        ][i],
        i == 0
            ? source
            : [
                for (var n = 0; n < source.length; n++)
                  LegalSection(
                      id: source[n].id,
                      title: translated![n].$1,
                      content: translated[n].$2)
              ]);
  }
}
