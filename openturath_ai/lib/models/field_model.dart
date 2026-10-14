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
      description: 'Manhaj eskatologi Islam, rukun keempat, tanda-tanda zaman, dan sanad Al-Habib Abu Bakar Al-Masyhur.',
      icon: Icons.hourglass_bottom_rounded,
      specialistCount: 1,
      agentIds: [
        'fiqh_tahawwulat',
      ],
    ),
    FieldModel(
      id: 'fiqh',
      name: 'Fikih & Fatwa',
      description: 'Hukum ibadah, muamalah, fatwa kontemporer, dan perbandingan mazhab mu\'tabar.',
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
      description: 'Takhrij sanad, kritik rijalul hadis, dan syarah ensiklopedis Kutubus Sittah.',
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
      description: 'Asbabun nuzul, munasabah, ilmu tajwid, dan khazanah eksegesis Al-Qur\'an.',
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
      description: 'Kalam Asy\'ariyyah, Maturidiyyah, pembahasan ushuluddin, dan dalil aqli-naqli.',
      icon: Icons.shield_outlined,
      specialistCount: 1,
      agentIds: [
        'aqidah',
      ],
    ),
    FieldModel(
      id: 'usul',
      name: 'Usul Fikih & Kaidah',
      description: 'Kaidah istinbath hukum, dalil ijmali, maqashid syariah, dan qawaid fiqhiyyah.',
      icon: Icons.architecture_rounded,
      specialistCount: 1,
      agentIds: [
        'ushul_fiqh',
      ],
    ),
    FieldModel(
      id: 'lughah',
      name: 'Bahasa & Sastra Arab',
      description: 'Nahwu, sharaf, balaghah, dan leksikografi kamus mu\'jam klasik.',
      icon: Icons.translate_rounded,
      specialistCount: 1,
      agentIds: [
        'nahwu_sharaf',
      ],
    ),
    FieldModel(
      id: 'tarikh',
      name: 'Sejarah, Sirah & Rijal',
      description: 'Sirah Nabawiyyah, khulafaur rasyidin, thabaqat ulama, dan peradaban Islam.',
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
      description: 'Penyucian jiwa (tazkiyatun nafs), adab suluk, dan hikmah ulama salafush shalih.',
      icon: Icons.spa_rounded,
      specialistCount: 1,
      agentIds: [
        'tasawwuf',
      ],
    ),
    FieldModel(
      id: 'bibliografi',
      name: 'Bibliografi & Faharis',
      description: 'Indeks ensiklopedi, biografi manuskrip, dan katalog rujukan khazanah Turath Islam.',
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
          description: 'Pelajari berbagai bidang ilmu dari kitab-kitab rujukan.',
          icon: Icons.menu_book_rounded,
          specialistCount: 0,
          agentIds: [],
        );
  }
}
