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

  /// 8 Bidang Keilmuan Utama Turats Islam
  static const List<FieldModel> defaultFields = [
    FieldModel(
      id: 'fiqh',
      name: 'Fikih',
      description: 'Hukum ibadah, muamalah, fatwa, dan perbandingan mazhab mu\'tabar.',
      icon: Icons.balance_rounded,
      specialistCount: 6,
      agentIds: [
        'fiqh_syafii',
        'fiqh_tahawwulat',
        'fiqh_hanafi',
        'fiqh_maliki',
        'fiqh_hanbali',
        'fiqh_muqaran',
      ],
    ),
    FieldModel(
      id: 'hadith',
      name: 'Hadits',
      description: 'Takhrij sanad, dirayah perawi, dan syarah Kutubus Sittah.',
      icon: Icons.auto_stories_rounded,
      specialistCount: 1,
      agentIds: [
        'hadits',
      ],
    ),
    FieldModel(
      id: 'tafsir',
      name: 'Tafsir',
      description: 'Asbabun nuzul, munasabah, dan khazanah tafsir bil-ma\'tsur wal-ra\'yi.',
      icon: Icons.menu_book_rounded,
      specialistCount: 1,
      agentIds: [
        'tafsir',
      ],
    ),
    FieldModel(
      id: 'aqidah',
      name: 'Aqidah',
      description: 'Kalam Asy\'ariyyah, Maturidiyyah, pembelaan ushuludin, dan dalil aqli-naqli.',
      icon: Icons.shield_outlined,
      specialistCount: 1,
      agentIds: [
        'aqidah',
      ],
    ),
    FieldModel(
      id: 'usul',
      name: 'Usul Fiqh',
      description: 'Kaidah istinbath hukum, dalil ijmali, maqashid syariah, dan qawaid fiqhiyyah.',
      icon: Icons.architecture_rounded,
      specialistCount: 1,
      agentIds: [
        'ushul_fiqh',
      ],
    ),
    FieldModel(
      id: 'lughah',
      name: 'Bahasa Arab',
      description: 'Nahwu, sharaf, balaghah, dan leksikografi kamus mu\'jam klasik.',
      icon: Icons.translate_rounded,
      specialistCount: 1,
      agentIds: [
        'nahwu_sharaf',
      ],
    ),
    FieldModel(
      id: 'tarikh',
      name: 'Sejarah & Sirah',
      description: 'Sirah Nabawiyyah, khulafaur rasyidin, thabaqat ulama, dan peradaban Islam.',
      icon: Icons.history_edu_rounded,
      specialistCount: 1,
      agentIds: [
        'tarikh',
      ],
    ),
    FieldModel(
      id: 'tasawwuf',
      name: 'Tasawuf & Akhlaq',
      description: 'Penyucian jiwa (tazkiyatun nafs), adab suluk, dan hikmah ulama salafush shalih.',
      icon: Icons.spa_rounded,
      specialistCount: 1,
      agentIds: [
        'habib_umar',
      ],
    ),
  ];

  static FieldModel getById(String id) {
    return defaultFields.firstWhere(
      (f) => f.id == id,
      orElse: () => defaultFields[0],
    );
  }
}
