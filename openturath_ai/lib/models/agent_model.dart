import '../core/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sub_agent_model.dart';
import 'book_model.dart';

enum CorpusKind { discipline, scholar }

class AgentModel {
  final String id;
  final String _title;
  String get title {
    final label =
        Loc.isArabic && titleArabic.isNotEmpty ? titleArabic : Loc.text(_title);
    return label.startsWith('AI ') ? label : 'AI $label';
  }

  final String titleArabic;
  final String description;
  final String emoji;
  final String category;
  final String status; // 'active' or 'coming_soon'
  final int sortOrder;
  final String _subtitleAcademic;
  String get subtitleAcademic => Loc.text(_subtitleAcademic);
  final String fieldId;
  final List<String> suggestedPrompts;
  final List<SubAgentModel>? subAgents;
  final List<BookModel>? referenceBooks;
  final String? akalUrl1m;
  final String? akalUrl6m;
  final String? akalUrl1y;
  final int? price1m;
  final int? price6m;
  final int? price1y;
  final CorpusKind kind;
  final List<String> disciplineIds;
  final List<String> scholarIds;
  final String? catalogId;

  AgentModel({
    required this.id,
    required String title,
    this.titleArabic = '',
    required this.description,
    required this.emoji,
    required this.category,
    required this.status,
    required this.sortOrder,
    String subtitleAcademic = 'Matan · Syarah · Hasyiyah',
    this.fieldId = 'fiqh',
    this.suggestedPrompts = const [],
    this.subAgents,
    this.referenceBooks,
    this.akalUrl1m,
    this.akalUrl6m,
    this.akalUrl1y,
    this.price1m,
    this.price6m,
    this.price1y,
    this.kind = CorpusKind.discipline,
    this.disciplineIds = const [],
    this.scholarIds = const [],
    this.catalogId,
  })  : _title = title,
        _subtitleAcademic = subtitleAcademic;

  bool get isActive => status == 'active';
  bool get isComingSoon => status == 'coming_soon';

  factory AgentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgentModel(
      id: doc.id,
      title: data['title'] ?? '',
      titleArabic: data['title_arabic'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '📖',
      category: data['category'] ?? 'Fiqh',
      status: data['status'] ?? 'coming_soon',
      sortOrder: data['sort_order'] ?? 99,
      subtitleAcademic:
          data['subtitle_academic'] ?? 'Matan · Syarah · Hasyiyah',
      fieldId: data['field_id'] ?? 'fiqh',
      suggestedPrompts: List<String>.from(data['suggested_prompts'] ?? []),
      akalUrl1m: data['akal_url_1m'],
      akalUrl6m: data['akal_url_6m'],
      akalUrl1y: data['akal_url_1y'],
      price1m: data['price_1m'],
      price6m: data['price_6m'],
      price1y: data['price_1y'],
      kind: data['kind'] == 'scholar'
          ? CorpusKind.scholar
          : CorpusKind.discipline,
      disciplineIds: List<String>.from(data['discipline_ids'] ?? []),
      scholarIds: List<String>.from(data['scholar_ids'] ?? []),
      catalogId: data['catalog_id'],
    );
  }

  // ── Hardcoded fallback terstruktur berbasis 8 Bidang Keilmuan ──
  static List<AgentModel> get defaultAgents => [
        // ── 1. FIKIH TAHAWWULAT (SOVEREIGN FLAGSHIP) ─────────
        AgentModel(
          id: 'fiqh_tahawwulat',
          title: 'Fikih Tahawwulat',
          titleArabic: 'فقه التحولات',
          description:
              'Khazanah ilmu kenabian seputar tanda-tanda akhir zaman untuk memahami realitas dan menjaga diri dari fitnah.',
          emoji: '📜',
          category: 'Fikih Tahawwulat',
          kind: CorpusKind.discipline,
          disciplineIds: const ['fiqh_tahawwulat'],
          scholarIds: const ['habib_abu_bakar'],
          fieldId: 'fiqh_tahawwulat',
          subtitleAcademic: 'Manhaj Abu Bakr al-Masyhur',
          suggestedPrompts: [
            'Bagaimana penjelasan al-ghutsā\'iyyah dalam kitab?',
            'Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?',
            'Bagaimana para ulama menjelaskan sikap saat masa fitnah?',
          ],
          catalogId: 'canonical_tahawwulat',
          status: 'active',
          sortOrder: 1,
          price1m: 300000,
          price6m: 1499000,
          price1y: 1999000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_tahawwulat_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description: 'Teks Matan & Ibarah',
              descriptionArabic: 'البحث والتحقيق وعزو النصوص إلى مصادرها',
              emoji: '📖',
              badge: 'Matan & Ibarah',
            ),
            SubAgentModel(
              id: 'fiqh_tahawwulat_bayan',
              name: 'Al-Bayan',
              nameArabic: 'البيان',
              description: 'Penyederhanaan Konsep',
              descriptionArabic: 'الشرح والبيان والتبسيط المنهجي',
              emoji: '💡',
              badge: 'Konsep & Istilah',
            ),
            SubAgentModel(
              id: 'fiqh_tahawwulat_mukhtabir',
              name: 'Al-Mukhtabir',
              nameArabic: 'المختبر',
              description: 'Ujian Pemahaman Interaktif',
              descriptionArabic: 'تقييم الفهم واختبار النوازل المعاصرة',
              emoji: '🎓',
              badge: 'Ujian Nalar',
            ),
            SubAgentModel(
              id: 'fiqh_tahawwulat_habib',
              name: 'Al-Habib',
              nameArabic: 'الحبيب',
              description: 'Arsip Muhadharah Habib Abu Bakar',
              descriptionArabic: 'مستودع المحاضرات والتسجيلات الشفهية',
              emoji: '🎙️',
              badge: 'Khazanah Lisan',
            ),
            SubAgentModel(
              id: 'fiqh_tahawwulat_khatib',
              name: 'Al-Khatib',
              nameArabic: 'الخطيب',
              description: 'Penyusun Materi Dakwah & Khutbah',
              descriptionArabic: 'إعداد الخطب والمواعظ وتوجيه النوازل الدعوية',
              emoji: '🕌',
              badge: 'Dakwah & Khutbah',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Nubdzah Al-Bayan fi Ma\'rifati Sunan Al-Khalaq',
              titleArabic: 'نبذة البيان في معرفة سنن الخلق والبيان',
              author: 'Habib Abu Bakar Al-Masyhur',
              description:
                  'Kitab pengantar dasar metodologi Sunan Al-Khalaq, tanda akhir zaman, dan peta dakwah fikih tahawwulat.',
            ),
            BookModel(
              title: 'Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat',
              titleArabic: 'الفقه المنهجي في فقه التحولات',
              author: 'Habib Abu Bakar Al-Masyhur',
              description:
                  'Panduan pengantar Fikih Tahawwulat untuk pelajar dan peneliti.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_syafii',
          title: 'Fikih Syafi\'i',
          titleArabic: 'الفقه الشافعي',
          description:
              'Cari penjelasan dan rujukan dalam kitab-kitab mazhab Syafi\'i.',
          emoji: '📜',
          category: 'Fikih',
          kind: CorpusKind.discipline,
          disciplineIds: const ['fiqh'],
          catalogId: 'canonical_syafii',
          fieldId: 'fiqh',
          subtitleAcademic: 'Matan · Syarah · Hasyiyah Mu\'tabarah',
          suggestedPrompts: [
            'Apa rukun wudu menurut pendapat mu\'tamad dalam mazhab Syafi\'i?',
            'Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?',
            'Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi?',
          ],
          status: 'active',
          sortOrder: 2,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_syafii_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description:
                  'Membantu menemukan dalil, ibarah, dan rujukan dalam mazhab Syafi\'i.',
              descriptionArabic: 'تحقيق المعتمد في المذهب الشافعي',
              emoji: '⚖️',
              badge: 'Fikih Syafi\'i',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Umm',
              titleArabic: 'الأم',
              author: 'Imam Asy-Syafi\'i',
              description: 'Kitab induk Fikih Mazhab Syafi\'i.',
            ),
            BookModel(
              title: 'Al-Majmu\' Syarah Al-Muhadzdzab',
              titleArabic: 'المجموع شرح المهذب',
              author: 'Imam An-Nawawi',
              description:
                  'Rujukan fikih mazhab Syafi\'i karya Imam An-Nawawi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_hanafi',
          title: 'Fikih Hanafi',
          titleArabic: 'الفقه الحنفي',
          description:
              'Pelajari fikih mazhab Hanafi dengan rujukan Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani.',
          emoji: '⚖️',
          category: 'Fikih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Zhahir Ar-Riwayah · Syuruh & Fatawa',
          suggestedPrompts: [
            'Bagaimana kaidah istihsan dalam mazhab Hanafi?',
            'Apa pendapat mu\'tamad mazhab Hanafi mengenai syarat shalat berjamaah?',
            'Tunjukkan ibarah dalam Radd al-Muhtar tentang jual beli dan muamalah.',
          ],
          catalogId: 'canonical_hanafi',
          status: 'active',
          sortOrder: 3,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_hanafi_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description: 'Riset Zhahir Ar-Riwayah dan fatwa mazhab Hanafi.',
              descriptionArabic: 'تحقيق المعتمد في المذهب الحنفي',
              emoji: '⚖️',
              badge: 'Fikih Hanafi',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Mabsuth',
              titleArabic: 'المبسوط',
              author: 'Imam As-Sarakhsi',
              description: 'Kitab ensiklopedi induk fikih mazhab Hanafi.',
            ),
            BookModel(
              title:
                  'Radd Al-Muhtar \'ala Ad-Durr Al-Mukhtar (Hasyiyah Ibnu Abidin)',
              titleArabic: 'رد المحتار على الدر المختار',
              author: 'Ibnu \'Abidin',
              description:
                  'Rujukan fatwa mu\'tamad muta\'akhkhirin mazhab Hanafi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_maliki',
          title: 'Fikih Maliki',
          titleArabic: 'الفقه المالكي',
          description:
              'Pelajari fikih mazhab Maliki dan \'Amal Ahlil Madinah dengan rujukan Al-Mudawwanah, Risalah Ibnu Abi Zaid, dan Mukhtashar Khalil.',
          emoji: '⚖️',
          category: 'Fikih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Al-Mudawwanah · Mukhtashar Khalil & Syarah',
          suggestedPrompts: [
            'Bagaimana kedudukan \'Amal Ahlil Madinah dalam istinbath Maliki?',
            'Apa saja syarat sah salat menurut Mukhtashar Khalil?',
            'Bagaimana Bidayatul Mujtahid menjelaskan perbedaan pendapat tentang thaharah?',
          ],
          catalogId: 'canonical_maliki',
          status: 'active',
          sortOrder: 4,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_maliki_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description: 'Riset Al-Mudawwanah dan Mukhtashar Khalil.',
              descriptionArabic: 'تحقيق المعتمد في المذهب المالكي',
              emoji: '⚖️',
              badge: 'Fikih Maliki',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Mudawwanah Al-Kubra',
              titleArabic: 'المدونة الكبرى',
              author: 'Imam Sahnun (dari Imam Malik)',
              description: 'Fondasi riwayat fatwa dan hukum mazhab Maliki.',
            ),
            BookModel(
              title: 'Mukhtashar Khalil',
              titleArabic: 'مختصر خليل',
              author: 'Syaikh Khalil bin Ishaq',
              description:
                  'Matan hukum paling padat dan mu\'tamad di kalangan Malikiyyah.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_hanbali',
          title: 'Fikih Hanbali',
          titleArabic: 'الفقه الحنبلي',
          description:
              'Pelajari fikih mazhab Hanbali merujuk Al-Mughni Ibnu Qudamah, Kasysyaf Al-Qina\', dan Zad Al-Mustaqni\'.',
          emoji: '⚖️',
          category: 'Fikih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Al-Mughni · Zad Al-Mustaqni\' & Syuruh',
          suggestedPrompts: [
            'Apa mu\'tamad mazhab Hanbali mengenai pembatalan wudhu?',
            'Bagaimana penjelasan Al-Mughni tentang jual beli bersyarat?',
            'Bagaimana perbedaan riwayat dari Imam Ahmad dalam masalah ibadah?',
          ],
          catalogId: 'canonical_hanbali',
          status: 'active',
          sortOrder: 5,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_hanbali_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description:
                  'Telaah Al-Mughni dan perbandingan riwayat Imam Ahmad.',
              descriptionArabic: 'تحقيق المعتمد في المذهب الحنبلي',
              emoji: '⚖️',
              badge: 'Fikih Hanbali',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Al-Mughni',
              titleArabic: 'المغني',
              author: 'Ibnu Qudamah Al-Maqdisi',
              description:
                  'Kitab fikih dalil mazhab Hanbali karya Ibnu Qudamah.',
            ),
            BookModel(
              title: 'Kasysyaf Al-Qina\' \'an Matn Al-Iqna\'',
              titleArabic: 'كشاف القناع عن متن الإقناع',
              author: 'Manshur bin Yunus Al-Buhuti',
              description: 'Syarah mu\'tamad pegangan fatwa ulama Hanbali.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_muqaran',
          title: 'Perbandingan Mazhab',
          titleArabic: 'الفقه المقارن',
          description:
              'Bandingkan dalil dan pandangan mazhab Hanafi, Maliki, Syafi\'i, dan Hanbali.',
          emoji: '⚖️',
          category: 'Fikih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Perbandingan Mazhab Empat & Tarjih Dalil',
          suggestedPrompts: [
            'Bagaimana pandangan empat mazhab mengenai rukun nikah?',
            'Apa dalil perbedaan ulama tentang batas menyentuh bukan mahram?',
            'Bagaimana perbandingan ulama mengenai zakat aset dan uang digital?',
          ],
          catalogId: 'canonical_fiqh_muqaran',
          status: 'active',
          sortOrder: 6,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_muqaran_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description: 'Komparasi dalil mazhab Arba\'ah dan tarjih.',
              descriptionArabic: 'المقارنة بين المذاهب والترجيح بالدليل',
              emoji: '⚖️',
              badge: 'Fikih Muqaran',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Bidayatul Mujtahid wa Nihayatul Muqtashid',
              titleArabic: 'بداية المجتهد ونهاية المقتصد',
              author: 'Ibnu Rusyd Al-Hafid',
              description:
                  'Kajian perbandingan mazhab empat beserta analisis dalil dan sebab perbedaan hukum.',
            ),
            BookModel(
              title: 'Al-Fiqh Al-Islami wa Adillatuh',
              titleArabic: 'الفقه الإسلامي وأدلته',
              author: 'Prof. Dr. Wahbah Az-Zuhaili',
              description:
                  'Ensiklopedi perbandingan mazhab klasik & kontemporer.',
            ),
          ],
        ),

        // ── 2. HADIS ──────────────────────────────────────────
        AgentModel(
          id: 'hadits',
          title: 'Matan Hadits',
          titleArabic: 'الحديث الشريف',
          description:
              'Telusuri hadis, sanad, perawi, dan penjelasannya dalam kitab rujukan.',
          emoji: '📖',
          category: 'Hadis',
          fieldId: 'hadith',
          subtitleAcademic: 'Kutubus Sittah · Takhrij & Rijal',
          suggestedPrompts: [
            'Bagaimana penjelasan hadis tentang niat dalam Fatḥ al-Bārī?',
            'Bagaimana menilai sanad riwayat ini?',
            'Bagaimana status perawi hadis talqin dalam Kutubus Sittah?',
          ],
          catalogId: 'canonical_hadits',
          status: 'active',
          sortOrder: 7,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'hadits_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description:
                  'Membantu takhrij hadis, telaah rijalul hadis, dan derajat kesahihan sanad.',
              descriptionArabic: 'تخريج الحديث ودراسة الأسانيد والرجال',
              emoji: '🔍',
              badge: 'Takhrij & Rijal',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Shahih Al-Bukhari',
              titleArabic: 'صحيح البخاري',
              author: 'Imam Al-Bukhari',
              description: 'Kitab hadis shahih rujukan induk umat Islam.',
            ),
            BookModel(
              title: 'Shahih Muslim',
              titleArabic: 'صحيح مسلم',
              author: 'Imam Muslim',
              description:
                  'Kitab shahih kedua dengan sistematika sanad yang sangat rapi.',
            ),
          ],
        ),

        // ── 3. TAFSIR ─────────────────────────────────────────
        AgentModel(
          id: 'tafsir',
          title: 'Tafsir Al-Qur\'an',
          titleArabic: 'تفسير القرآن',
          description:
              'Telusuri makna ayat, sebab turunnya, hubungan antarayat, dan penjelasan para mufasir.',
          emoji: '🌟',
          category: 'Tafsir',
          fieldId: 'tafsir',
          subtitleAcademic: 'Tafsir Thabari, Ibnu Katsir & Qurtubi',
          suggestedPrompts: [
            'Apa asbabun nuzul surah Al-Baqarah ayat 183?',
            'Bagaimana tafsir ayat Muhkamat dan Mutasyabihat menurut Al-Qurtubi?',
            'Bagaimana para mufasir menjelaskan makna "Ihdinas shiratal mustaqim"?',
          ],
          catalogId: 'canonical_tafsir',
          status: 'active',
          sortOrder: 8,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'tafsir_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description:
                  'Kompilasi penafsiran mufassirin salaf dan asbabun nuzul.',
              descriptionArabic: 'تحقيق الروايات وأسباب النزول',
              emoji: '🔍',
              badge: 'Riset Tafsir',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Tafsir Al-Qur\'an Al-\'Azhim',
              titleArabic: 'تفسير ابن كثير',
              author: 'Al-Hafizh Ibnu Katsir',
              description:
                  'Rujukan tafsir bil-ma\'tsur dengan penekanan pada riwayat shahih dan asbabun nuzul.',
            ),
            BookModel(
              title: 'Al-Jami\' li Ahkam Al-Qur\'an',
              titleArabic: 'تفسير القرطبي',
              author: 'Imam Al-Qurtubi',
              description:
                  'Tafsir dengan fokus pada hukum-hukum fikih dalam Al-Qur\'an.',
            ),
          ],
        ),

        // ── 4. USUL FIQH ──────────────────────────────────────
        AgentModel(
          id: 'ushul_fiqh',
          title: 'Usul Fikih',
          titleArabic: 'أصول الفقه',
          description:
              'Pelajari kaidah penggalian hukum, dalil, dan maqashid syariah melalui kitab usul fikih.',
          emoji: '📐',
          category: 'Usul Fikih',
          fieldId: 'usul',
          subtitleAcademic: 'Kaidah Istinbath & Maqashid Syariah',
          suggestedPrompts: [
            'Apa perbedaan Mafhum Mukhalafah dan Mafhum Muwafaqah?',
            'Bagaimana kaidah "Al-Amru ba\'dan-nahyi yufidul ibahah"?',
            'Bagaimana Al-Waraqat menjelaskan pembagian hukum taklifi?',
          ],
          catalogId: 'canonical_ushul_fikih',
          status: 'active',
          sortOrder: 9,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'ushul_muhaqqiq',
              name: 'Al-Muhaqqiq',
              nameArabic: 'المحقق',
              description:
                  'Membantu penelusuran kaidah usuliyyah dan metode istinbath dalil.',
              descriptionArabic: 'تحقيق القواعد الأصولية والاستنباط',
              emoji: '📐',
              badge: 'Kaidah Usul',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Matan Al-Waraqat',
              titleArabic: 'متن الورقات',
              author: 'Imam Al-Haramain Al-Juwaini',
              description:
                  'Matan pondasi metodologi ushul fikih paling tersohor.',
            ),
            BookModel(
              title: 'Jam\'ul Jawami\'',
              titleArabic: 'جمع الجوامع',
              author: 'Tajuddin As-Subki',
              description:
                  'Karya induk ushul fikih lintas mazhab karya Tajuddin As-Subki.',
            ),
          ],
        ),

        // ── 5. BAHASA ARAB ────────────────────────────────────
        AgentModel(
          id: 'nahwu_sharaf',
          title: 'Bahasa Arab',
          titleArabic: 'علوم العربية',
          description:
              'Pelajari nahwu, sharaf, balaghah, dan makna kosakata dalam kamus Arab klasik.',
          emoji: '🔤',
          category: 'Bahasa Arab',
          fieldId: 'lughah',
          subtitleAcademic: 'Alfiyah Ibnu Malik & Lisanul Arab',
          suggestedPrompts: [
            'Bagaimana i\'rab kalimat: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ"?',
            'Apa perbedaan faedah wazan Fa\'ala dan Af\'ala dalam ilmu sharaf?',
            'Bagaimana kaidah Munada dalam bait Alfiyah Ibnu Malik?',
          ],
          catalogId: 'canonical_bahasa_arab',
          status: 'active',
          sortOrder: 10,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'nahwu_sharaf_muerib',
              name: 'Al-Mu\'rib',
              nameArabic: 'المعرب',
              description:
                  'I\'rab kata dan analisis sintaksis sesuai kaidah Alfiyah Ibnu Malik.',
              descriptionArabic: 'إعراب الكلمات والتحليل النحوي',
              emoji: '🔍',
              badge: 'I\'rab & nahwu',
            ),
            SubAgentModel(
              id: 'nahwu_sharaf_tashrif',
              name: 'At-Tashrif',
              nameArabic: 'المصرف',
              description:
                  'Perubahan wazan, derivasi kata, dan morfologi bahasa Arab.',
              descriptionArabic: 'تحليل الأوزان والاشتقاق الصرفي',
              emoji: '🔄',
              badge: 'Tashrif & sharaf',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Alfiyah Ibnu Malik',
              titleArabic: 'ألفية ابن مالك',
              author: 'Ibnu Malik',
              description:
                  'Nadhom tata bahasa Arab 1.000 bait karya Imam Ibnu Malik.',
            ),
            BookModel(
              title: 'Syarah Ibnu Aqil',
              titleArabic: 'شرح ابن عقيل',
              author: 'Ibnu Aqil',
              description:
                  'Kitab penjelasan paling populer untuk bait-bait Alfiyah Ibnu Malik.',
            ),
          ],
        ),

        // ── 6. AQIDAH ─────────────────────────────────────────
        AgentModel(
          id: 'aqidah',
          title: 'Akidah',
          titleArabic: 'العقيدة والتوحيد',
          description:
              'Pembahasan ushuluddin, tauhid sifat dua puluh, dan manhaj Ahlussunnah wal Jama\'ah.',
          emoji: '🛡️',
          category: 'Akidah',
          fieldId: 'aqidah',
          subtitleAcademic: 'Asy\'ariyyah · Maturidiyyah · Dalil Aqli',
          suggestedPrompts: [
            'Bagaimana pembagian sifat wajib, mustahil, dan jaiz bagi Allah menurut kitab tauhid?',
            'Bagaimana dalil aqli tentang keesaan Allah menurut Al-Sanusiyyah?',
            'Apa perbedaan pemikiran Asy\'ariyyah dan Mu\'tazilah tentang kalamullah?',
          ],
          catalogId: 'canonical_akidah',
          status: 'active',
          sortOrder: 11,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),

        // ── 7. SEJARAH & SIRAH ────────────────────────────────
        AgentModel(
          id: 'tarikh',
          title: 'Sejarah & Sirah',
          titleArabic: 'السيرة والتاريخ',
          description:
              'Telusuri perjalanan hidup Nabi, Khulafaur Rasyidin, dan biografi ulama salaf.',
          emoji: '📜',
          category: 'Sejarah & Sirah',
          fieldId: 'tarikh',
          subtitleAcademic: 'Sirah Ibnu Hisyam & Tarikh Thabari',
          suggestedPrompts: [
            'Bagaimana kronologi Perang Badar menurut Sirah Ibnu Hisyam?',
            'Bagaimana riwayat musyawarah Tsaqifah Bani Sa\'idah?',
            'Bagaimana biografi dan thabaqat Imam An-Nawawi?',
          ],
          catalogId: 'canonical_tarikh',
          status: 'active',
          sortOrder: 12,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),

        AgentModel(
          id: 'tasawwuf',
          title: 'Tasawwuf & Adzkar',
          titleArabic: 'التصوف والأذكار',
          description:
              'Telaah adab, tazkiyatun nafs, dan wirid dalam kitab rujukan.',
          emoji: '📖',
          category: 'Tasawwuf',
          fieldId: 'tasawwuf',
          subtitleAcademic: 'Ihya Ulumiddin · Adab & Wirid',
          catalogId: 'canonical_tasawuf',
          status: 'active',
          sortOrder: 13,
          price1m: 50000,
        ),

        // ── 8. TASAWUF & ULAMA ────────────────────────────────
        AgentModel(
          id: 'habib_umar',
          title: 'Habib Umar bin Hafizh',
          titleArabic: 'الحبيب عمر بن حفيظ',
          description:
              'Telusuri fatwa, khutbah, tulisan, dan nasihat dakwah Habib Umar bin Hafizh.',
          emoji: '🕌',
          category: 'Khazanah Ulama',
          kind: CorpusKind.scholar,
          scholarIds: const ['habib_umar'],
          disciplineIds: const ['tasawwuf'],
          fieldId: 'tasawwuf',
          subtitleAcademic: 'Kitab & Ribuan Muhadharah Tarim',
          suggestedPrompts: [
            'Nasihat Habib Umar mengenai adab menuntut ilmu di era fitnah digital.',
            'Kutipan dari kitab Taujih Al-Nabih tentang penyucian hati.',
            'Amalan wirid harian dan dzikir yang diajarkan di Darul Musthafa.',
          ],
          catalogId: 'canonical_tasawuf',
          status: 'active',
          sortOrder: 13,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
        AgentModel(
          id: 'imam_ghazali',
          title: 'Imam Al-Ghazali',
          titleArabic: 'حجة الإسلام الغزالي',
          description:
              'Pelajari tasawuf, akhlak, dan usul fikih dalam karya-karya Imam Al-Ghazali, termasuk Ihya Ulumiddin.',
          emoji: '🕯️',
          category: 'Khazanah Ulama',
          kind: CorpusKind.scholar,
          scholarIds: const ['imam_ghazali'],
          disciplineIds: const ['tasawwuf', 'usul', 'aqidah'],
          fieldId: 'tasawwuf',
          subtitleAcademic: 'Ihya Ulumiddin & Naskah Hujjatul Islam',
          suggestedPrompts: [
            'Bagaimana pembagian ilmu terpuji dan tercela dalam Kitab Al-Ilm Ihya Ulumiddin?',
            'Penjelasan konsep qalb dan ruh menurut Imam Al-Ghazali.',
            'Kaidah maslahah mursalah dan maqashid syariah dalam Al-Mustashfa.',
          ],
          catalogId: 'canonical_tasawuf',
          status: 'active',
          sortOrder: 14,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),

        // ── 9. SPESIALIS TAMBAHAN KATALOG MASTER ───────────────
        AgentModel(
          id: 'qawaid_fiqhiyyah',
          title: 'Qawaid Fiqhiyyah',
          titleArabic: 'القواعد الفقهية',
          description:
              'Pendalaman kaidah-kaidah asasiyah fikih, kulliyyah, dan furu\'iyyah lintas mazhab.',
          emoji: '⚖️',
          category: 'Usul Fikih',
          fieldId: 'usul',
          subtitleAcademic: 'Asybah wan-Nazhair & Kaidah Asasiyyah',
          suggestedPrompts: [
            'Bagaimana lima kaidah asasiyah (al-qawa\'id al-kubra) dalam fikih beserta contoh penerapannya?',
            'Bagaimana kaidah "Al-Yaqinu la yazulu bisy-syakk" diterapkan dalam shalat?',
            'Kutipan dari Al-Asybah wan-Nazhair Imam As-Suyuthi.',
          ],
          catalogId: 'canonical_qawaid_fiqhiyyah',
          status: 'active',
          sortOrder: 15,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
        AgentModel(
          id: 'fatawa_masail',
          title: 'Fatawa & Masail Fiqhiyyah',
          titleArabic: 'الفتاوى والمسائل الفقهية',
          description:
              'Kompilasi fatwa ulama kibar dan pemecahan masail waqi\'iyyah kekinian.',
          emoji: '📜',
          category: 'Fikih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Fatawa Kubra & Nawadzil Mu\'ashirah',
          suggestedPrompts: [
            'Bagaimana fatwa ulama tentang hukum transaksi online dan e-wallet?',
            'Penjelasan fatwa kontemporer mengenai rekayasa genetika dan bioetika.',
            'Bagaimana kompilasi fatwa Fatawa Al-Kubra Ibnu Taimiyyah dan Ibnu Hajar?',
          ],
          catalogId: 'canonical_fatawa_masail',
          status: 'active',
          sortOrder: 16,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
        AgentModel(
          id: 'tajwid_qiraat',
          title: 'Tajwid & Qiraat',
          titleArabic: 'التجويد والقراءات',
          description:
              'Kaidah makhorijul huruf, shifat, tajwid, dan khazanah Qira\'at Asyrah.',
          emoji: '📖',
          category: 'Tafsir',
          fieldId: 'tafsir',
          subtitleAcademic:
              'Al-Jazariyyah, Asy-Syathibiyyah & Qira\'at Sab\'ah',
          suggestedPrompts: [
            'Bagaimana makharijul huruf dan sifat lazimah menurut Matan Al-Jazariyyah?',
            'Apa perbedaan bacaan Imam Hafsh dan Warsy dalam Surah Al-Fatihah?',
            'Bagaimana kaidah hukum nun sukun dan tanwin dijelaskan para imam qiraat?',
          ],
          catalogId: 'canonical_ulumul_quran',
          status: 'active',
          sortOrder: 17,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
        AgentModel(
          id: 'musthalah_hadits',
          title: 'Musthalah Hadis',
          titleArabic: 'مصطلح الحديث',
          description:
              'Metodologi kritik sanad, derajat hadis (shahih, hasan, dha\'if), dan ilmu Jarh wat Ta\'dil.',
          emoji: '🔍',
          category: 'Hadis',
          fieldId: 'hadith',
          subtitleAcademic: 'Muqaddimah Ibnu Shalah & Nukhbatul Fikar',
          suggestedPrompts: [
            'Apa syarat diterimanya hadis shahih menurut Muqaddimah Ibnu Shalah?',
            'Bagaimana pembagian tingkatan lafazh Jarh wat Ta\'dil?',
            'Apa perbedaan hadis mu\'allaq, munqathi\', mu\'dhal, dan mudallas?',
          ],
          catalogId: 'canonical_musthalah_hadits',
          status: 'active',
          sortOrder: 18,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
        AgentModel(
          id: 'syarah_hadits',
          title: 'Syarah Hadis',
          titleArabic: 'شروح الحديث النبوي',
          description:
              'Ensiklopedia syarah hadis Nabawi (Fathul Bari, Syarah Shahih Muslim, Umdatul Qari).',
          emoji: '📚',
          category: 'Hadis',
          fieldId: 'hadith',
          subtitleAcademic:
              'Fathul Bari, An-Nawawi \'ala Muslim & Syuruh Sittah',
          suggestedPrompts: [
            'Bagaimana Ibnu Hajar mensyarah hadis niat dalam pembukaan Fathul Bari?',
            'Penjelasan Imam An-Nawawi tentang hadis Islam, Iman, dan Ihsan.',
            'Analisis perbandingan syarah hadis tentang kepemimpinan dan umara.',
          ],
          catalogId: 'canonical_syarah_hadits',
          status: 'active',
          sortOrder: 19,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
        AgentModel(
          id: 'thabaqat_rijal',
          title: 'Thabaqat & Rijalul Hadis',
          titleArabic: 'طبقات المحدثين ورجال الأسانيد',
          description:
              'Biografi perawi, silsilah sanad, dan thabaqat ulama hadis dan fikih.',
          emoji: '🏛️',
          category: 'Sejarah & Sirah',
          fieldId: 'tarikh',
          subtitleAcademic: 'Tahdzibut Tahdzib, Siyar A\'lam Nubala & Thabaqat',
          suggestedPrompts: [
            'Bagaimana biografi dan kredibilitas perawi Sufyan Ats-Tsauri?',
            'Kutipan dari Siyar A\'lam An-Nubala karya Imam Adz-Dzahabi.',
            'Telusuri perawi riwayat ini dalam Tahdzib At-Tahdzib Ibnu Hajar.',
          ],
          catalogId: 'canonical_thabaqat_tarajim',
          status: 'active',
          sortOrder: 20,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
        AgentModel(
          id: 'bibliografi_faharis',
          title: 'Bibliografi & Faharis',
          titleArabic: 'فهارس التراث والببليوغرافيا',
          description:
              'Katalog induk kitab, manuskrip turath, indeks tema, dan biografi pengarang.',
          emoji: '📑',
          category: 'Bibliografi',
          fieldId: 'bibliografi',
          subtitleAcademic: 'Kasyfuzh Zhunun, Mu\'jamul Mushannifin & Faharis',
          suggestedPrompts: [
            'Apa saja kitab rujukan utama dalam mazhab Syafi\'i menurut Kasyfuzh Zhunun?',
            'Telusuri edisi cetak dan manuskrip terbaik untuk kitab Al-Umm.',
            'Katalogisasi karya-karya Imam As-Suyuthi di bidang hadis dan tafsir.',
          ],
          catalogId: 'canonical_bibliografi',
          status: 'active',
          sortOrder: 21,
          price1m: 50000,
          price6m: 299000,
          price1y: 499000,
        ),
      ];
}
