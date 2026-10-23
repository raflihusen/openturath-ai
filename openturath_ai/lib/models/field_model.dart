import 'package:flutter/material.dart';

class FieldModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int specialistCount;
  final List<String> agentIds;

  const FieldModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.specialistCount,
    required this.agentIds,
  });

  /// 10 Bidang Keilmuan Utama Turats Islam
  static const List<FieldModel> defaultFields = [
    FieldModel(
      id: 'fiqh_tahawwulat',
      name: 'Fikih Tahawwulat',
      description:
          'Rukun keempat dan tanda-tanda zaman dalam karya Al-Habib Abu Bakar Al-Masyhur.',
      icon: Icons.hourglass_bottom_rounded,
      specialistCount: 1,
      agentIds: [
        'fiqh_tahawwulat',
      ],
    ),
    FieldModel(
      id: 'fiqh',
      name: 'Fikih & Fatwa',
      description:
          'Hukum ibadah dan muamalah, fatwa masa kini, dan perbandingan mazhab.',
      icon: Icons.balance_rounded,
      specialistCount: 5,
      agentIds: [
        'fiqh_syafii',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ],
    ),
    FieldModel(
      id: 'hadith',
      name: 'Hadis & Ulumul Hadis',
      description:
          'Hadis, ilmu hadis, biografi perawi, dan syarah Kutubus Sittah.',
      icon: Icons.auto_stories_rounded,
      specialistCount: 3,
      agentIds: [
        'hadits',
        'syarah_hadits',
        'musthalah_hadits',
      ],
    ),
    FieldModel(
      id: 'tafsir',
      name: 'Tafsir & Qiraat',
      description: 'Tafsir, asbabun nuzul, tajwid, dan qira\'at Al-Qur\'an.',
      icon: Icons.menu_book_rounded,
      specialistCount: 2,
      agentIds: [
        'tafsir',
        'tajwid_qiraat',
      ],
    ),
    FieldModel(
      id: 'aqidah',
      name: 'Akidah & Ushuluddin',
      description:
          'Akidah Asy\'ariyyah dan Maturidiyyah, ilmu kalam, dan dalilnya.',
      icon: Icons.shield_outlined,
      specialistCount: 1,
      agentIds: [
        'aqidah',
      ],
    ),
    FieldModel(
      id: 'usul',
      name: 'Usul Fikih & Kaidah',
      description:
          'Cara menggali hukum dari dalil, maqashid syariah, dan kaidah fikih.',
      icon: Icons.architecture_rounded,
      specialistCount: 1,
      agentIds: [
        'ushul_fiqh',
      ],
    ),
    FieldModel(
      id: 'lughah',
      name: 'Bahasa & Sastra Arab',
      description: 'Nahwu, sharaf, balaghah, dan kamus bahasa Arab klasik.',
      icon: Icons.translate_rounded,
      specialistCount: 1,
      agentIds: [
        'nahwu_sharaf',
      ],
    ),
    FieldModel(
      id: 'tarikh',
      name: 'Sejarah, Sirah & Rijal',
      description:
          'Sirah Nabi, khulafaur rasyidin, riwayat hidup ulama, dan sejarah Islam.',
      icon: Icons.history_edu_rounded,
      specialistCount: 2,
      agentIds: [
        'tarikh',
        'thabaqat_rijal',
      ],
    ),
    FieldModel(
      id: 'tasawwuf',
      name: 'Tasawuf & Akhlak',
      description: 'Penyucian jiwa, adab, dan hikmah para ulama terdahulu.',
      icon: Icons.spa_rounded,
      specialistCount: 1,
      agentIds: [
        'tasawwuf',
      ],
    ),
    FieldModel(
      id: 'bibliografi',
      name: 'Bibliografi & Faharis',
      description:
          'Indeks ensiklopedi, biografi manuskrip, dan katalog rujukan khazanah Turath Islam.',
      icon: Icons.collections_bookmark_rounded,
      specialistCount: 1,
      agentIds: [
        'bibliografi_faharis',
      ],
    ),
  ];

  static FieldModel? findById(String id) {
    for (final f in defaultFields) {
      if (f.id == id) return f;
    }
    return null;
  }

  static FieldModel getById(String id) {
    return findById(id) ??
        const FieldModel(
          id: 'umum',
          name: 'Umum & Turats',
          description:
              'Pelajari berbagai bidang ilmu dari kitab-kitab rujukan.',
          icon: Icons.menu_book_rounded,
          specialistCount: 0,
          agentIds: [],
        );
  }
}
