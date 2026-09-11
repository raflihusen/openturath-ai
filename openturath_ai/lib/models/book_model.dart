import 'dart:convert';

/// Legacy book reference model used in [AgentModel].
class BookModel {
  final String title;
  final String titleArabic;
  final String author;
  final String description;
  final String? url;

  BookModel({
    required this.title,
    required this.titleArabic,
    required this.author,
    required this.description,
    this.url,
  });
}

/// Raw imported canonical catalog entry from dataset (e.g. canonical_syafii.json).
/// Preserves raw bibliographical fields without premature editorial assumptions.
class CanonicalEntry {
  const CanonicalEntry({
    required this.legacyKey,
    required this.titleArabic,
    required this.shortTitleArabic,
    required this.authorArabic,
    required this.authorFull,
    required this.recordedDeathYearHijri,
    required this.eraCode,
    required this.textTypeCode,
    required this.recordedAuthorityRank,
    required this.recordedVolumes,
    required this.publisher,
    required this.muhaqqiq,
    required this.raw,
  });

  final String legacyKey;
  final String titleArabic, shortTitleArabic, authorArabic, authorFull;
  final int? recordedDeathYearHijri;
  final String? eraCode, textTypeCode;
  final int? recordedAuthorityRank, recordedVolumes;
  final String? publisher, muhaqqiq;
  final Map<String, dynamic> raw;

  factory CanonicalEntry.fromLegacy(
    String key,
    Map<String, dynamic> row,
  ) {
    String? text(String name) {
      final value = row[name];
      if (value == null) return null;
      if (value is! String) {
        throw FormatException('$key: $name harus berupa teks');
      }
      final clean = value.trim();
      return clean.isEmpty ? null : clean;
    }

    String requiredText(String name) {
      final value = text(name);
      if (value == null) throw FormatException('$key: $name kosong');
      return value;
    }

    int? integer(String name) {
      final value = row[name];
      if (value == null || value == '') return null;
      if (value is! int || value < 0) {
        throw FormatException('$key: $name harus integer nonnegatif');
      }
      return value;
    }

    return CanonicalEntry(
      legacyKey: key,
      titleArabic: requiredText('full_title'),
      shortTitleArabic: requiredText('canonical_short_title'),
      authorArabic: requiredText('author_canonical'),
      authorFull: requiredText('author_full'),
      recordedDeathYearHijri: integer('death_year_hijri'),
      eraCode: text('era'),
      textTypeCode: text('text_type'),
      recordedAuthorityRank: integer('authority_rank'),
      recordedVolumes: integer('volumes_count'),
      publisher: text('publisher'),
      muhaqqiq: text('muhaqqiq'),
      raw: Map<String, dynamic>.unmodifiable(row),
    );
  }
}

class CanonicalImport {
  const CanonicalImport(this.entries, this.issues);
  final List<CanonicalEntry> entries;
  final List<String> issues; // Internal validation log; bukan copy publik.
}

CanonicalImport parseCanonicalCatalog(String source) {
  final root = jsonDecode(source);
  if (root is! Map<String, dynamic>) {
    throw const FormatException('Root katalog harus object JSON');
  }
  final entries = <CanonicalEntry>[];
  final issues = <String>[];
  for (final item in root.entries) {
    try {
      final row = item.value;
      if (row is! Map<String, dynamic>) {
        throw FormatException('${item.key}: entri bukan object');
      }
      entries.add(CanonicalEntry.fromLegacy(item.key, row));
    } on FormatException catch (error) {
      issues.add(error.message.toString());
    }
  }
  return CanonicalImport(
    List<CanonicalEntry>.unmodifiable(entries),
    List<String>.unmodifiable(issues),
  );
}

/// Presentation model for catalog books reviewed for display.
/// Prevents UI widgets from turning unverified authority ranks into scientific claims.
class CanonicalBookPresentation {
  const CanonicalBookPresentation({
    required this.editionId,
    required this.titleArabic,
    required this.authorArabic,
    this.titleLatin,
    this.authorLatin,
    this.verifiedDeathYearHijri,
    this.reviewedTypeLabel,
    this.reviewedEraLabel,
    this.reviewedAuthorityLabel,
    this.authorityEvidence,
    this.publisher,
    this.muhaqqiq,
    this.volumesCount,
  });

  final String editionId, titleArabic, authorArabic;
  final String? titleLatin, authorLatin;
  final int? verifiedDeathYearHijri;
  final String? reviewedTypeLabel, reviewedEraLabel;
  final String? reviewedAuthorityLabel, authorityEvidence;
  final String? publisher, muhaqqiq;
  final int? volumesCount;

  List<String> get compactLabels => [
        if (reviewedTypeLabel != null) reviewedTypeLabel!,
        if (reviewedEraLabel != null) reviewedEraLabel!,
        if (volumesCount != null && volumesCount! > 1) '$volumesCount Jilid',
      ];

  bool get canShowAuthority =>
      reviewedAuthorityLabel?.isNotEmpty == true &&
      authorityEvidence?.isNotEmpty == true;

  factory CanonicalBookPresentation.fromEntry(CanonicalEntry entry) {
    String? typeLabel;
    if (entry.textTypeCode != null) {
      switch (entry.textTypeCode) {
        case 'asl_al_madhhab':
          typeLabel = 'Asal Mazhab';
          break;
        case 'matn':
          typeLabel = 'Matan';
          break;
        case 'sharh':
          typeLabel = 'Syarah';
          break;
        case 'hashiyah':
          typeLabel = 'Hasyiyah';
          break;
        case 'khilafiyyat':
          typeLabel = 'Khilafiyyah';
          break;
        case 'fatawa':
          typeLabel = 'Fatwa';
          break;
        case 'ajwibah':
          typeLabel = 'Ajwibah';
          break;
        case 'qawaid':
          typeLabel = 'Qawa\'id';
          break;
        default:
          typeLabel = entry.textTypeCode!.replaceAll('_', ' ');
      }
    }

    String? eraLabel;
    if (entry.eraCode != null) {
      switch (entry.eraCode) {
        case 'mutaqaddimin':
          eraLabel = 'Mutaqaddimin';
          break;
        case 'ashab_al_wujuh':
          eraLabel = 'Ashab Al-Wujuh';
          break;
        case 'mutaakhkhirin':
          eraLabel = 'Muta\'akhkhirin';
          break;
        default:
          eraLabel = entry.eraCode!.replaceAll('_', ' ');
      }
    }

    return CanonicalBookPresentation(
      editionId: entry.legacyKey,
      titleArabic: entry.titleArabic,
      authorArabic: entry.authorArabic,
      titleLatin: null,
      authorLatin: null,
      verifiedDeathYearHijri: entry.recordedDeathYearHijri,
      reviewedTypeLabel: typeLabel,
      reviewedEraLabel: eraLabel,
      reviewedAuthorityLabel: null, // Held until editorial consensus
      authorityEvidence: null,
      publisher: entry.publisher,
      muhaqqiq: entry.muhaqqiq,
      volumesCount: entry.recordedVolumes,
    );
  }
}
