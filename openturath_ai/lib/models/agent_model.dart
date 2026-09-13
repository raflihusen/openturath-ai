import 'package:cloud_firestore/cloud_firestore.dart';
import 'sub_agent_model.dart';
import 'book_model.dart';

enum CorpusKind { discipline, scholar }

class AgentModel {
  final String id;
  final String title;
  final String titleArabic;
  final String description;
  final String emoji;
  final String category;
  final String status; // 'active' or 'coming_soon'
  final int sortOrder;
  final String subtitleAcademic;
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
    required this.title,
    this.titleArabic = '',
    required this.description,
    required this.emoji,
    required this.category,
    required this.status,
    required this.sortOrder,
    this.subtitleAcademic = 'Matan · Syarah · Hasyiyah',
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
  });

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
      subtitleAcademic: data['subtitle_academic'] ?? 'Matan · Syarah · Hasyiyah',
      fieldId: data['field_id'] ?? 'fiqh',
      suggestedPrompts: List<String>.from(data['suggested_prompts'] ?? []),
      akalUrl1m: data['akal_url_1m'],
      akalUrl6m: data['akal_url_6m'],
      akalUrl1y: data['akal_url_1y'],
      price1m: data['price_1m'],
      price6m: data['price_6m'],
      price1y: data['price_1y'],
      kind: data['kind'] == 'scholar' ? CorpusKind.scholar : CorpusKind.discipline,
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
          title: 'AI Fikih Tahawwulat',
          titleArabic: 'فقه التحولات',
          description:
              'Membantu menelusuri pembahasan Fikih Tahawwulat dari kitab dan muhadharah Habib Abu Bakar al-Masyhur.',
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
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_tahawwulat_muhaqqiq',
              name: 'Al-Muhaqqiq (Riset Dalil)',
              nameArabic: 'المحقق',
              description:
                  'Membantu menemukan dalil, ibarah, dan rujukan yang relevan.',
              descriptionArabic: 'البحث والتحقيق وعزو النصوص إلى مصادرها',
              emoji: '🔍',
              badge: 'Riset Dalil',
            ),
            SubAgentModel(
              id: 'fiqh_tahawwulat_bayan',
              name: 'Al-Bayan (Penjelasan Luas)',
              nameArabic: 'البيان',
              description:
                  'Menjelaskan pokok bahasan dengan bahasa yang lebih ringkas.',
              descriptionArabic: 'الشرح والبيان والتبسيط المنهجي',
              emoji: '💡',
              badge: 'Penjelasan',
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
          title: 'AI Fikih Syafi\'i',
          titleArabic: 'الفقه الشافعي',
          description:
              'Bantuan untuk mencari keterangan dalam kitab-kitab mazhab Syafi\'i.',
          emoji: '📜',
          category: 'Fiqih',
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
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_syafii_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Syafi\'i',
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
          title: 'AI Fikih Hanafi',
          titleArabic: 'الفقه الحنفي',
          description:
              'Fikih Mazhab Hanafi dengan rujukan Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Zhahir Ar-Riwayah · Syuruh & Fatawa',
          suggestedPrompts: [
            'Bagaimana kaidah istihsan dalam mazhab Hanafi?',
            'Apa pendapat mu\'tamad mazhab Hanafi mengenai syarat shalat berjamaah?',
            'Bawakan ibarah Radd Al-Muhtar tentang bab muamalat dan tijarah!',
          ],
          status: 'coming_soon',
          sortOrder: 3,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_hanafi_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Hanafi',
              nameArabic: 'المحقق',
              description: 'Spesialis riset Zhahir Ar-Riwayah dan fatwa mazhab Hanafi.',
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
              title: 'Radd Al-Muhtar \'ala Ad-Durr Al-Mukhtar (Hasyiyah Ibnu Abidin)',
              titleArabic: 'رد المحتار على الدر المختار',
              author: 'Ibnu \'Abidin',
              description: 'Rujukan fatwa mu\'tamad muta\'akhkhirin mazhab Hanafi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_maliki',
          title: 'AI Fikih Maliki',
          titleArabic: 'الفقه المالكي',
          description:
              'Fikih Mazhab Maliki dan \'Amal Ahlil Madinah dengan rujukan Al-Mudawwanah, Risalah Ibnu Abi Zaid, dan Mukhtashar Khalil.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Al-Mudawwanah · Mukhtashar Khalil & Syarah',
          suggestedPrompts: [
            'Bagaimana kedudukan \'Amal Ahlil Madinah dalam istinbath Maliki?',
            'Rincikan syarat sah shalat menurut Mukhtashar Khalil!',
            'Bawakan ibarah Bidayatul Mujtahid mengenai perbedaan pendapat dalam thaharah!',
          ],
          status: 'coming_soon',
          sortOrder: 4,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_maliki_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Maliki',
              nameArabic: 'المحقق',
              description: 'Spesialis riset Al-Mudawwanah dan Mukhtashar Khalil.',
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
              description: 'Matan hukum paling padat dan mu\'tamad di kalangan Malikiyyah.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_hanbali',
          title: 'AI Fikih Hanbali',
          titleArabic: 'الفقه الحنبلي',
          description:
              'Khazanah Fikih Mazhab Hanbali merujuk Al-Mughni Ibnu Qudamah, Kasysyaf Al-Qina\', dan Zad Al-Mustaqni\'.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Al-Mughni · Zad Al-Mustaqni\' & Syuruh',
          suggestedPrompts: [
            'Apa mu\'tamad mazhab Hanbali mengenai pembatalan wudhu?',
            'Bawakan ibarah Al-Mughni tentang hukum jual beli bersyarat!',
            'Bagaimana perbedaan riwayat dari Imam Ahmad dalam masalah ibadah?',
          ],
          status: 'coming_soon',
          sortOrder: 5,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_hanbali_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Hanbali',
              nameArabic: 'المحقق',
              description: 'Spesialis telaah Al-Mughni dan perbandingan riwayat Imam Ahmad.',
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
              description: 'Kitab fikih dalil mazhab Hanbali karya Ibnu Qudamah.',
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
          title: 'AI Perbandingan Mazhab',
          titleArabic: 'الفقه المقارن',
          description:
              'Komparasi hukum lintas mazhab empat (Arba\'ah), analisis wajh al-dilalah, dan tarjih dalil mu\'tabar.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Perbandingan Mazhab Empat & Tarjih Dalil',
          suggestedPrompts: [
            'Bandingkan pandangan 4 mazhab mengenai rukun nikah!',
            'Apa dalil perbedaan ulama tentang batas menyentuh bukan mahram?',
            'Kompilasi fatwa kontemporer vs klasik mengenai zakat saham dan uang digital!',
          ],
          status: 'coming_soon',
          sortOrder: 6,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_muqaran_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Muqaran',
              nameArabic: 'المحقق',
              description: 'Spesialis komparasi dalil mazhab Arba\'ah dan tarjih.',
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
              description: 'Kajian perbandingan mazhab empat beserta analisis dalil dan sebab perbedaan hukum.',
            ),
            BookModel(
              title: 'Al-Fiqh Al-Islami wa Adillatuh',
              titleArabic: 'الفقه الإسلامي وأدلته',
              author: 'Prof. Dr. Wahbah Az-Zuhaili',
              description: 'Ensiklopedi perbandingan mazhab klasik & kontemporer.',
            ),
          ],
        ),

        // ── 2. HADIS ──────────────────────────────────────────
        AgentModel(
          id: 'hadits',
          title: 'AI Hadits & Syarah Sunnah',
          titleArabic: 'الحديث الشريف',
          description:
              'Kajian matan hadits, perawi, dan syarah dari induk kitab-kitab As-Sunnah (Kutubus Sittah & syuruhnya).',
          emoji: '📖',
          category: 'Hadits',
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
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'hadits_muhaqqiq',
              name: 'Al-Muhaqqiq (Takhrij Hadits)',
              nameArabic: 'المحقق',
              description:
                  'Spesialis takhrij hadits, telaah rijalul hadits, dan derajat kesahihan sanad.',
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
              description: 'Kitab shahih kedua dengan sistematika sanad yang sangat rapi.',
            ),
          ],
        ),

        // ── 3. TAFSIR ─────────────────────────────────────────
        AgentModel(
          id: 'tafsir',
          title: 'AI Tafsir Al-Qur\'an',
          titleArabic: 'تفسير القرآن',
          description:
              'Penelusuran makna ayat, asbabun nuzul, dan istinbath hukum dari kitab-kitab tafsir mu\'tabarah.',
          emoji: '🌟',
          category: 'Tafsir',
          fieldId: 'tafsir',
          subtitleAcademic: 'Tafsir Thabari, Ibnu Katsir & Qurtubi',
          suggestedPrompts: [
            'Apa asbabun nuzul surah Al-Baqarah ayat 183?',
            'Bagaimana tafsir ayat Muhkamat dan Mutasyabihat menurut Al-Qurtubi?',
            'Kompilasi pandangan mufassirin tentang tafsir "Ihdinas shiratal mustaqim"!',
          ],
          catalogId: 'canonical_tafsir',
          status: 'active',
          sortOrder: 8,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'tafsir_muhaqqiq',
              name: 'Al-Muhaqqiq (Tafsir Riwayat)',
              nameArabic: 'المحقق',
              description:
                  'Spesialis kompilasi penafsiran mufassirin salaf dan asbabun nuzul.',
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
              description: 'Rujukan tafsir bil-ma\'tsur dengan penekanan pada riwayat shahih dan asbabun nuzul.',
            ),
            BookModel(
              title: 'Al-Jami\' li Ahkam Al-Qur\'an',
              titleArabic: 'تفسير القرطبي',
              author: 'Imam Al-Qurtubi',
              description: 'Tafsir dengan fokus pada hukum-hukum fikih dalam Al-Qur\'an.',
            ),
          ],
        ),

        // ── 4. USUL FIQH ──────────────────────────────────────
        AgentModel(
          id: 'ushul_fiqh',
          title: 'AI Ushul Fiqih',
          titleArabic: 'أصول الفقه',
          description:
              'Metode istinbath hukum dan kaidah usul fikih dari kitab rujukan yang diakui.',
          emoji: '📐',
          category: 'Ushul Fiqih',
          fieldId: 'usul',
          subtitleAcademic: 'Kaidah Istinbath & Maqashid Syariah',
          suggestedPrompts: [
            'Jelaskan perbedaan Mafhum Mukhalafah dan Mafhum Muwafaqah!',
            'Bagaimana kaidah "Al-Amru ba\'dan-nahyi yufidul ibahah"?',
            'Bawakan ibarah Al-Waraqat tentang pembagian hukum taklifi!',
          ],
          catalogId: 'canonical_ushul_fikih',
          status: 'active',
          sortOrder: 9,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'ushul_muhaqqiq',
              name: 'Al-Muhaqqiq (Kaidah Ushul)',
              nameArabic: 'المحقق',
              description:
                  'Spesialis penelusuran kaidah ushuliyyah dan metode istinbath dalil.',
              descriptionArabic: 'تحقيق القواعد الأصولية والاستنباط',
              emoji: '📐',
              badge: 'Kaidah Ushul',
            ),
          ],
          referenceBooks: [
            BookModel(
              title: 'Matan Al-Waraqat',
              titleArabic: 'متن الورقات',
              author: 'Imam Al-Haramain Al-Juwaini',
              description: 'Matan pondasi metodologi ushul fikih paling tersohor.',
            ),
            BookModel(
              title: 'Jam\'ul Jawami\'',
              titleArabic: 'جمع الجوامع',
              author: 'Tajuddin As-Subki',
              description: 'Karya induk ushul fikih lintas mazhab karya Tajuddin As-Subki.',
            ),
          ],
        ),

        // ── 5. BAHASA ARAB ────────────────────────────────────
        AgentModel(
          id: 'nahwu_sharaf',
          title: 'AI Bahasa Arab & Balaghah',
          titleArabic: 'النحو والصرف',
          description:
              'Nahwu, sharaf, balaghah, dan mu\'jam dengan rujukan kitab bahasa Arab.',
          emoji: '🔤',
          category: 'Bahasa Arab',
          fieldId: 'lughah',
          subtitleAcademic: 'Alfiyah Ibnu Malik & Lisanul Arab',
          suggestedPrompts: [
            'I\'rab kalimat: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ" secara mendalam!',
            'Jelaskan faidah wazan Fa\'ala dan Af\'ala dalam ilmu sharaf!',
            'Bawakan kaidah Munada dalam bait Alfiyah Ibnu Malik!',
          ],
          catalogId: 'canonical_bahasa_arab',
          status: 'active',
          sortOrder: 10,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
          subAgents: [
            SubAgentModel(
              id: 'nahwu_sharaf_muerib',
              name: 'Al-Mu\'rib (Kaidah Sintaksis)',
              nameArabic: 'المعرب',
              description:
                  'Spesialis i\'rab kata dan analisis sintaksis (nahwu) sesuai kaidah Alfiyah Ibnu Malik.',
              descriptionArabic: 'إعراب الكلمات والتحليل النحوي',
              emoji: '🔍',
              badge: 'Analisis Nahwu',
            ),
            SubAgentModel(
              id: 'nahwu_sharaf_tashrif',
              name: 'Al-Tashrif (Kaidah Morfologi)',
              nameArabic: 'المصرف',
              description:
                  'Spesialis perubahan wazan, derivasi kata (sharaf), dan morfologi bahasa Arab klasik.',
              descriptionArabic: 'تحليل الأوزان والاشتقاق الصرفي',
              emoji: '🔄',
              badge: 'Analisis Sharaf',
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
          title: 'AI Aqidah & Ilmu Kalam',
          titleArabic: 'العقيدة والتوحيد',
          description:
              'Pembahasan ushuluddin, tauhid sifat dua puluh, dan manhaj Ahlussunnah wal Jama\'ah.',
          emoji: '🛡️',
          category: 'Aqidah',
          fieldId: 'aqidah',
          subtitleAcademic: 'Asy\'ariyyah · Maturidiyyah · Dalil Aqli',
          suggestedPrompts: [
            'Jelaskan pembagian sifat Wajib, Mustahil, dan Jaiz bagi Allah!',
            'Bagaimana dalil aqli tentang keesaan Allah menurut Al-Sanusiyyah?',
            'Apa perbedaan pemikiran Asy\'ariyyah dan Mu\'tazilah tentang kalamullah?',
          ],
          status: 'coming_soon',
          sortOrder: 11,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
        ),

        // ── 7. SEJARAH & SIRAH ────────────────────────────────
        AgentModel(
          id: 'tarikh',
          title: 'AI Sejarah & Sirah',
          titleArabic: 'السيرة والتاريخ',
          description:
              'Rekam jejak Sirah Nabawiyyah, Khulafaur Rasyidin, dan thabaqat ulama salaf.',
          emoji: '📜',
          category: 'Sejarah',
          fieldId: 'tarikh',
          subtitleAcademic: 'Sirah Ibnu Hisyam & Tarikh Thabari',
          suggestedPrompts: [
            'Rincikan kronologi Perang Badar dari Sirah Ibnu Hisyam!',
            'Bagaimana riwayat musyawarah Tsaqifah Bani Sa\'idah?',
            'Biografi singkat dan thabaqat Imam An-Nawawi!',
          ],
          status: 'coming_soon',
          sortOrder: 12,
          price1m: 49000,
          price6m: 299000,
          price1y: 499000,
        ),

        // ── 8. TASAWUF & ULAMA ────────────────────────────────
        AgentModel(
          id: 'habib_umar',
          title: 'AI Habib Umar bin Hafizh',
          titleArabic: 'الحبيب عمر بن حفيظ',
          description:
              'Kitab dan rekaman muhadharah Habib Umar bin Hafizh dengan rujukan terpercaya.',
          emoji: '🕌',
          category: 'Kajian Ulama',
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
          status: 'coming_soon',
          sortOrder: 13,
        ),
        AgentModel(
          id: 'imam_ghazali',
          title: 'AI Hujjatul Islam Al-Ghazali',
          titleArabic: 'حجة الإسلام الغزالي',
          description:
              'Kajian kitab Ihya Ulumuddin, Al-Mustashfa, Tahafut al-Falasifah, dan karya-karya Imam Al-Ghazali.',
          emoji: '🕯️',
          category: 'Kajian Ulama',
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
          status: 'coming_soon',
          sortOrder: 14,
        ),
      ];
}
