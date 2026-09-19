import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/open_turath_book.dart';

/// Data model metadata pelatihan modul AI OpenTurath
class AiLibraryMetadata {
  const AiLibraryMetadata({
    required this.keyName,
    required this.idModul,
    required this.kategori,
    required this.nama,
    required this.namaArab,
    required this.totalKitab,
    required this.totalJilid,
    required this.totalHalaman,
    required this.totalKata,
    required this.rentangMasa,
    this.badgeOtoritas = '',
    this.headlineAplikasi = '',
    this.totalDars,
    this.totalMuhadharah,
  });

  final String keyName;
  final String idModul;
  final String kategori;
  final String nama;
  final String namaArab;
  final int totalKitab;
  final String totalJilid;
  final int totalHalaman;
  final int totalKata;
  final String rentangMasa;
  final String badgeOtoritas;
  final String headlineAplikasi;
  final int? totalDars;
  final int? totalMuhadharah;

  factory AiLibraryMetadata.fromJson(
    String keyName,
    Map<String, dynamic> json,
  ) {
    return AiLibraryMetadata(
      keyName: keyName,
      idModul: _stringValue(json['id_modul']),
      kategori: _stringValue(json['kategori']),
      nama: _stringValue(json['nama_tampilan'] ?? json['nama']),
      namaArab: _stringValue(json['nama_arab']),
      totalKitab: _intValue(json['total_kitab']),
      totalJilid: _stringValue(json['total_jilid_fisik'] ?? json['total_jilid']),
      totalHalaman: _intValue(json['total_halaman_fisik'] ?? json['total_halaman']),
      totalKata: _intValue(json['total_kata_bersih'] ?? json['total_kata']),
      rentangMasa: _stringValue(json['rentang_masa']),
      badgeOtoritas: _stringValue(json['badge_otoritas']),
      headlineAplikasi: _stringValue(json['headline_aplikasi']),
      totalDars: json['total_dars'] == null ? null : _intValue(json['total_dars']),
      totalMuhadharah: json['total_muhadharah'] == null
          ? null
          : _intValue(json['total_muhadharah']),
    );
  }

  static String _stringValue(dynamic value) {
    return value == null ? '' : value.toString().trim();
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();

    final cleaned = value
            ?.toString()
            .replaceAll(RegExp(r'[^0-9]'), '') ??
        '';
    return int.tryParse(cleaned) ?? 0;
  }
}

/// Repositori terpusat untuk memuat katalog kitab turats dan metadata AI
class OpenTurathCatalogRepository {
  static final OpenTurathCatalogRepository instance =
      OpenTurathCatalogRepository._();
  OpenTurathCatalogRepository._();

  static const Map<String, String> _moduleToCatalogFile = {
    'fiqh_syafii': 'assets/data/01_KATALOG_FIKIH_SYAFII.json',
    'fiqh_syafii_muhaqqiq': 'assets/data/01_KATALOG_FIKIH_SYAFII.json',
    'hadits': 'assets/data/02_KATALOG_HADITS_DAN_SYARAH.json',
    'hadits_nabawi': 'assets/data/02_KATALOG_HADITS_DAN_SYARAH.json',
    'ushul_fiqh': 'assets/data/03_KATALOG_USHUL_FIKIH.json',
    'bahasa_arab': 'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'lughah_balaghah': 'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'nahwu_sharaf': 'assets/data/04_KATALOG_BAHASA_DAN_SASTRA_ARAB.json',
    'tafsir': 'assets/data/05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json',
    'tafsir_ulumul_quran': 'assets/data/05_KATALOG_TAFSIR_DAN_ULUMUL_QURAN.json',
    'fiqh_tahawwulat': 'assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json',
    'tarikh': 'assets/data/07_KATALOG_TARIKH_DAN_SIRAH_NABAWIYYAH.json',
    'tarikh_sirah': 'assets/data/07_KATALOG_TARIKH_DAN_SIRAH_NABAWIYYAH.json',
    'fiqh_muqaran': 'assets/data/08_KATALOG_FIKIH_MUQARAN_DAN_UMUM.json',
    'fatawa_masail': 'assets/data/09_KATALOG_FATAWA_DAN_MASAIL_FIQHIYYAH.json',
    'syarah_hadits': 'assets/data/10_KATALOG_SYARAH_HADITS.json',
    'fiqh_hanafi': 'assets/data/11_KATALOG_FIKIH_HANAFI.json',
    'fiqh_maliki': 'assets/data/12_KATALOG_FIKIH_MALIKI.json',
    'fiqh_hanbali': 'assets/data/13_KATALOG_FIKIH_HANBALI.json',
    'tasawwuf': 'assets/data/14_KATALOG_TASAWWUF_DAN_ADZKAR.json',
    'habib_umar': 'assets/data/14_KATALOG_TASAWWUF_DAN_ADZKAR.json',
    'imam_ghazali': 'assets/data/14_KATALOG_TASAWWUF_DAN_ADZKAR.json',
    'tajwid_qiraat': 'assets/data/15_KATALOG_TAJWID_DAN_QIRAAT.json',
    'qawaid_fiqhiyyah': 'assets/data/16_KATALOG_QAWAID_FIQHIYYAH.json',
    'musthalah_hadits': 'assets/data/17_KATALOG_MUSTHALAH_DAN_ULUMUL_HADITS.json',
    'aqidah': 'assets/data/18_KATALOG_AQIDAH_DAN_USHULUDDIN.json',
    'thabaqat_tarajim': 'assets/data/19_KATALOG_THABAQAT_DAN_TARAJIM.json',
    'thabaqat_rijal': 'assets/data/19_KATALOG_THABAQAT_DAN_TARAJIM.json',
    'adab_balaghah': 'assets/data/21_KATALOG_ADAB_DAN_BALAGHAH.json',
    'bibliografi_faharis': 'assets/data/26_KATALOG_BIBLIOGRAFI_DAN_FAHARIS.json',
  };

  Map<String, AiLibraryMetadata>? _metadataCache;
  final Map<String, List<OpenTurathBook>> _booksCache = {};

  /// Memuat seluruh metadata modul AI dari assets/data/metadata_training_seluruh_ai.json
  Future<Map<String, AiLibraryMetadata>> loadAllMetadata() async {
    if (_metadataCache != null) return _metadataCache!;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/metadata_training_seluruh_ai.json',
      );
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        final result = <String, AiLibraryMetadata>{};
        decoded.forEach((key, val) {
          if (val is Map<String, dynamic>) {
            result[key] = AiLibraryMetadata.fromJson(key, val);
          }
        });
        _metadataCache = result;
        return result;
      }
    } catch (_) {}

    return const {};
  }

  /// Mengambil metadata untuk modul atau asisten tertentu
  Future<AiLibraryMetadata?> getMetadataForModule(String key) async {
    final all = await loadAllMetadata();
    if (all.containsKey(key)) return all[key];

    // Fallback key cleaning
    final cleanKey = key.replaceAll('-', '_').toLowerCase();
    for (final entry in all.entries) {
      if (entry.key == cleanKey ||
          entry.value.idModul.toLowerCase().contains(cleanKey) ||
          cleanKey.contains(entry.key)) {
        return entry.value;
      }
    }

    return all['fiqh_syafii'];
  }

  /// Memuat daftar kitab untuk modul atau asisten tertentu dari katalog JSON
  Future<List<OpenTurathBook>> loadBooksForModule(String moduleKey) async {
    final cleanKey = moduleKey.replaceAll('-', '_').toLowerCase();
    final catalogPath = _moduleToCatalogFile[cleanKey] ??
        _moduleToCatalogFile['fiqh_syafii']!;

    if (_booksCache.containsKey(catalogPath)) {
      return _booksCache[catalogPath]!;
    }

    try {
      final jsonString = await rootBundle.loadString(catalogPath);
      final books = OpenTurathBook.decodeList(jsonString);
      _booksCache[catalogPath] = books;
      return books;
    } catch (_) {
      return const [];
    }
  }
}
