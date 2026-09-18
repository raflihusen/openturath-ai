import 'dart:convert';

/// Model data kanonikal untuk representasi naskah/kitab dalam katalog OpenTurath.
class OpenTurathBook {
  const OpenTurathBook({
    required this.id,
    required this.deathYear,
    required this.section,
    required this.shortName,
    required this.title,
    required this.author,
    required this.editor,
    required this.publisher,
    required this.edition,
    required this.volumes,
    required this.sourceFolder,
    required this.pages,
  });

  final int id;
  final int? deathYear;
  final String section;
  final String shortName;
  final String title;
  final String author;
  final String editor;
  final String publisher;
  final String edition;
  final String volumes;
  final String sourceFolder;
  final String pages;

  factory OpenTurathBook.fromJson(Map<String, dynamic> json) {
    return OpenTurathBook(
      id: _intValue(json['id']),
      deathYear: _nullableInt(json['tahun_wafat']),
      section: _textValue(json['القسم'] ?? json['section'] ?? json['kategori']),
      shortName: _textValue(json['الاسم_المختصر'] ?? json['short_name']),
      title: _textValue(json['الكتاب'] ?? json['title'] ?? json['nama_kitab']),
      author: _textValue(json['المؤلف'] ?? json['author'] ?? json['pengarang']),
      editor: _textValue(json['المحقق_أو_المعتني'] ?? json['editor'] ?? json['tahqiq']),
      publisher: _textValue(json['الناشر'] ?? json['publisher'] ?? json['penerbit']),
      edition: _textValue(json['سنة_الطبع_والطبعة'] ?? json['edition'] ?? json['cetakan']),
      volumes: _textValue(json['عدد_الأجزاء'] ?? json['volumes'] ?? json['jilid']),
      sourceFolder: _textValue(json['folder_sumber'] ?? json['source_folder']),
      pages: _textValue(json['عدد_الصفحات'] ?? json['pages'] ?? json['halaman']),
    );
  }

  static List<OpenTurathBook> decodeList(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map(
            (item) => OpenTurathBook.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    final cleaned = value?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    return int.tryParse(cleaned) ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    final cleaned = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned);
  }

  static String _textValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String get volumeLabel {
    if (volumes.isEmpty || volumes == '-') return 'Jumlah jilid belum tersedia';
    return '$volumes jilid';
  }

  String get deathLabel {
    if (deathYear == null) return 'Tahun wafat belum tersedia';
    return 'W. $deathYear H';
  }

  String get pagesLabel {
    if (pages.isEmpty || pages == '-') return 'Jumlah halaman belum tercatat';
    return '$pages hlm.';
  }
}
