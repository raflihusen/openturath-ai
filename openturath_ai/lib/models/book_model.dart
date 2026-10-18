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

/// Raw imported canonical catalog entry from dataset (e.g. 01_KATALOG_FIKIH_SYAFII.json).
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

List<CanonicalBookPresentation> parseSyamilahCatalog(String source) {
  final dynamic root = jsonDecode(source);
  final dynamic list = root is List
      ? root
      : (root is Map<String, dynamic>
          ? (root['kitab'] ?? root['books'])
          : null);
  if (list is List) {
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => CanonicalBookPresentation.fromSyamilahCard(item))
        .toList();
  } else if (root is Map<String, dynamic>) {
    final legacy = parseCanonicalCatalog(source);
    return legacy.entries
        .map((e) => CanonicalBookPresentation.fromEntry(e))
        .toList();
  }
  return [];
}

/// Presentation model for catalog books reviewed for display.
/// Prevents UI widgets from turning unverified authority ranks into scientific claims.
class CanonicalBookPresentation {
  const CanonicalBookPresentation({
    required this.editionId,
    required this.titleArabic,
    required this.authorArabic,
    this.shortTitleArabic,
    this.sectionArabic,
    this.titleLatin,
    this.authorLatin,
    this.verifiedDeathYearHijri,
    this.reviewedTypeLabel,
    this.reviewedEraLabel,
    this.reviewedAuthorityLabel,
    this.authorityEvidence,
    this.publisher,
    this.muhaqqiq,
    this.printYear,
    this.volumesDescription,
    this.volumesCount,
    this.pagesDescription,
  });

  final String editionId, titleArabic, authorArabic;
  final String? shortTitleArabic;
  final String? sectionArabic;
  final String? titleLatin, authorLatin;
  final int? verifiedDeathYearHijri;
  final String? reviewedTypeLabel, reviewedEraLabel;
  final String? reviewedAuthorityLabel, authorityEvidence;
  final String? publisher, muhaqqiq;
  final String? printYear;
  final String? volumesDescription;
  final int? volumesCount;
  final String? pagesDescription;

  List<String> get compactLabels => [
        if (sectionArabic != null && sectionArabic!.isNotEmpty) sectionArabic!,
        if (volumesDescription != null && volumesDescription!.isNotEmpty)
          (volumesDescription!.contains('جزء') ||
                  volumesDescription!.contains('مجلد') ||
                  volumesDescription!.contains('Jilid')
              ? volumesDescription!
              : '$volumesDescription Jilid')
        else if (volumesCount != null && volumesCount! > 1)
          '$volumesCount Jilid',
        if (pagesDescription != null &&
            pagesDescription!.isNotEmpty &&
            pagesDescription != '-')
          '$pagesDescription Hlm',
        if (verifiedDeathYearHijri != null && verifiedDeathYearHijri! > 0)
          'ت $verifiedDeathYearHijri هـ',
        if (reviewedTypeLabel != null) reviewedTypeLabel!,
        if (reviewedEraLabel != null) reviewedEraLabel!,
      ].where((l) => l.isNotEmpty).toList();

  bool get canShowAuthority =>
      reviewedAuthorityLabel?.isNotEmpty == true &&
      authorityEvidence?.isNotEmpty == true;

  factory CanonicalBookPresentation.fromSyamilahCard(
      Map<String, dynamic> json) {
    final rawDeath = json['tahun_wafat'];
    int? deathYear;
    if (rawDeath is int) {
      deathYear = rawDeath;
    } else if (rawDeath is String) {
      deathYear = int.tryParse(rawDeath);
    }

    String? clean(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return (s.isEmpty || s == '-') ? null : s;
    }

    final rawVolumes = clean(json['عدد_الأجزاء']);
    int? volCount;
    if (rawVolumes != null) {
      final match = RegExp(r'^\d+').firstMatch(rawVolumes);
      if (match != null) {
        volCount = int.tryParse(match.group(0)!);
      }
    }

    final rawPages = clean(json['عدد_الصفحات']);
    final fullTitle =
        (json['الكتاب'] ?? json['full_title'] ?? '').toString().trim();
    final shortTitle =
        clean(json['الاسم_المختصر'] ?? json['canonical_short_title']);
    final author = (json['المؤلف'] ??
            json['author_canonical'] ??
            json['author_full'] ??
            '')
        .toString()
        .trim();
    final section = clean(json['القسم']);
    final publisher = clean(json['الناشر'] ?? json['publisher']);
    final muhaqqiq = clean(json['المحقق_أو_المعتني'] ?? json['muhaqqiq']);
    final printYear = clean(json['سنة_الطبع_والطبعة'] ?? json['سنة_الطبع']);
    final id = json['id']?.toString() ?? json['edition_id']?.toString() ?? '1';

    return CanonicalBookPresentation(
      editionId: id,
      titleArabic:
          fullTitle.isNotEmpty ? fullTitle : (shortTitle ?? 'بدون عنوان'),
      shortTitleArabic: shortTitle,
      authorArabic: author.isNotEmpty ? author : 'غير معروف',
      sectionArabic: section,
      verifiedDeathYearHijri: deathYear,
      publisher: publisher,
      muhaqqiq: muhaqqiq,
      printYear: printYear,
      volumesDescription: rawVolumes,
      volumesCount: volCount,
      pagesDescription: rawPages,
    );
  }

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
    } else if (entry.recordedDeathYearHijri != null) {
      final y = entry.recordedDeathYearHijri!;
      if (y <= 505) {
        eraLabel = 'Mutaqaddimin';
      } else {
        eraLabel = 'Muta\'akhkhirin';
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
