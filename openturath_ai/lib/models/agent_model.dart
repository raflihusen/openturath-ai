import 'package:cloud_firestore/cloud_firestore.dart';
import 'sub_agent_model.dart';
import 'book_model.dart';

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
    );
  }

  // ── Hardcoded fallback terstruktur berbasis 8 Bidang Keilmuan ──
  static List<AgentModel> get defaultAgents => [
        // ── 1. FIKIH (6 SPESIALIS) ────────────────────────────
        AgentModel(
          id: 'fiqh_tahawwulat',
          title: 'AI Fikih Tahawwulat',
          titleArabic: 'فقه التحولات',
          description:
              'AI khusus karya Habib Abu Bakar Al-Masyhur. Ribuan muhadoroh + kitab lengkap dengan ibarah asli.',
          emoji: '⚖️',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Manhaj Fiqh Fitnah & Tanda Zaman',
          suggestedPrompts: [
            'Jelaskan konsep Rukun Keempat dalam Fikih Tahawwulat!',
            'Bagaimana ibarah tentang tanda zaman kubra dan sughra?',
            'Apa perbedaan fitnah dhuhaima dan fitnah sarra\'?',
          ],
          status: 'active',
          sortOrder: 1,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_tahawwulat_muhaqqiq',
              name: 'Al-Muhaqqiq (Riset Dalil)',
              nameArabic: 'المحقق',
              description:
                  'Spesialis riset mendalam. Menyajikan dalil, ibarah lengkap, dan rujukan presisi dari kitab/ceramah.',
              descriptionArabic: 'البحث والتحقيق وعزو النصوص إلى مصادرها',
              emoji: '🔍',
              badge: 'Riset Mendalam',
            ),
            SubAgentModel(
              id: 'fiqh_tahawwulat_bayan',
              name: 'Al-Bayan (Penjelasan Luas)',
              nameArabic: 'البيان',
              description:
                  'Spesialis penjelasan. Menjabarkan konsep dengan bahasa yang mudah dipahami, disertai intisari.',
              descriptionArabic: 'الشرح والبيان والتبسيط المنهجي',
              emoji: '💡',
              badge: 'Penjelasan Luas',
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
                  'Panduan kurikulum fikih tahawwulat sistematik untuk tingkat madrasah dan perguruan tinggi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_syafii',
          title: 'AI Fikih Syafi\'i',
          titleArabic: 'الفقه الشافعي',
          description:
              'Asisten AI khusus Fikih Mazhab Syafi\'i lengkap dengan kutipan kitab-kitab mu\'tabarah.',
          emoji: '📜',
          category: 'Fiqih',
          fieldId: 'fiqh',
          subtitleAcademic: 'Matan · Syarah · Hasyiyah Mu\'tabarah',
          suggestedPrompts: [
            'Bagaimana hukum shalat di atas kapal menurut Al-Majmu\'?',
            'Apa qaul mu\'tamad tentang batas basuhan wudhu?',
            'Bawakan ibarah Fathul Mu\'in tentang jual beli khiyar!',
          ],
          status: 'active',
          sortOrder: 2,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
          subAgents: [
            SubAgentModel(
              id: 'fiqh_syafii_muhaqqiq',
              name: 'Al-Muhaqqiq Fikih Syafi\'i',
              nameArabic: 'المحقق',
              description:
                  'Spesialis riset hukum Fikih Syafi\'i, perbandingan qaul dan mu\'tamad madzhab.',
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
                  'Rujukan fikih mazhab Syafi\'i yang komprehensif karya Imam An-Nawawi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_hanafi',
          title: 'AI Fikih Hanafi',
          titleArabic: 'الفقه الحنفي',
          description:
              'Literatur Fikih Mazhab Hanafi berbasis kitab induk Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani.',
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
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
              description: 'Rujukan fatwa pamungkas mazhab Hanafi.',
            ),
          ],
        ),
        AgentModel(
          id: 'fiqh_maliki',
          title: 'AI Fikih Maliki',
          titleArabic: 'الفقه المالكي',
          description:
              'Kajian Fikih Mazhab Maliki dan \'Amal Ahlil Madinah berbasis Al-Mudawwanah, Risalah Ibnu Abi Zaid, dan Mukhtashar Khalil.',
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
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
              description: 'Kitab fikih dalil komprehensif mazhab Hanbali karya Ibnu Qudamah.',
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
          title: 'AI Fikih Muqaran',
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
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
              description: 'Karya agung perbandingan mazhab beserta analisis sebab perbedaan hukum.',
            ),
            BookModel(
              title: 'Al-Fiqh Al-Islami wa Adillatuh',
              titleArabic: 'الفقه الإسلامي وأدلته',
              author: 'Prof. Dr. Wahbah Az-Zuhaili',
              description: 'Ensiklopedi perbandingan komprehensif mazhab klasik & kontemporer.',
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
            'Takhrij hadis "Innamal a\'malu bin-niyyat" beserta syarahnya!',
            'Bagaimana status perawi hadis talqin mayit dalam Kutubus Sittah?',
            'Bawakan syarah Fathul Bari mengenai bab permulaan wahyu!',
          ],
          status: 'active',
          sortOrder: 7,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
              description: 'Kitab hadits paling shahih rujukan utama umat Islam.',
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
              'Khazanah tafsir Al-Qur\'an komprehensif berbasis korpus kitab tafsir mu\'tabarah.',
          emoji: '🌟',
          category: 'Tafsir',
          fieldId: 'tafsir',
          subtitleAcademic: 'Tafsir Thabari, Ibnu Katsir & Qurtubi',
          suggestedPrompts: [
            'Apa asbabun nuzul surah Al-Baqarah ayat 183?',
            'Bagaimana tafsir ayat Muhkamat dan Mutasyabihat menurut Al-Qurtubi?',
            'Kompilasi pandangan mufassirin tentang tafsir "Ihdinas shiratal mustaqim"!',
          ],
          status: 'active',
          sortOrder: 8,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
              description: 'Tafsir bil ma\'tsur paling muktamad dan masyhur di dunia Islam.',
            ),
            BookModel(
              title: 'Al-Jami\' li Ahkam Al-Qur\'an',
              titleArabic: 'تفسير القرطبي',
              author: 'Imam Al-Qurtubi',
              description: 'Tafsir komprehensif fokus pada hukum-hukum fikih dalam Al-Qur\'an.',
            ),
          ],
        ),

        // ── 4. USUL FIQH ──────────────────────────────────────
        AgentModel(
          id: 'ushul_fiqh',
          title: 'AI Ushul Fiqih',
          titleArabic: 'أصول الفقه',
          description:
              'Metodologi istinbath hukum Islam dan kaidah ushuliyyah berbasis kitab-kitab ushul mu\'tabarah.',
          emoji: '📐',
          category: 'Ushul Fiqih',
          fieldId: 'usul',
          subtitleAcademic: 'Kaidah Istinbath & Maqashid Syariah',
          suggestedPrompts: [
            'Jelaskan perbedaan Mafhum Mukhalafah dan Mafhum Muwafaqah!',
            'Bagaimana kaidah "Al-Amru ba\'dan-nahyi yufidul ibahah"?',
            'Bawakan ibarah Al-Waraqat tentang pembagian hukum taklifi!',
          ],
          status: 'active',
          sortOrder: 9,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
              'Kaidah tata bahasa Arab (Nahwu, Sharaf, Balaghah, dan Mu\'jam) berbasis literatur kitab rujukan utama.',
          emoji: '🔤',
          category: 'Bahasa Arab',
          fieldId: 'lughah',
          subtitleAcademic: 'Alfiyah Ibnu Malik & Lisanul Arab',
          suggestedPrompts: [
            'I\'rab kalimat: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ" secara mendalam!',
            'Jelaskan faidah wazan Fa\'ala dan Af\'ala dalam ilmu sharaf!',
            'Bawakan kaidah Munada dalam bait Alfiyah Ibnu Malik!',
          ],
          status: 'active',
          sortOrder: 10,
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
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
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
        ),

        // ── 7. SEJARAH & SIRAH ────────────────────────────────
        AgentModel(
          id: 'tarikh',
          title: 'AI Sejarah & Sirah Nabawiyyah',
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
          price1m: 50000,
          price6m: 250000,
          price1y: 450000,
        ),

        // ── 8. TASAWUF & ULAMA ────────────────────────────────
        AgentModel(
          id: 'habib_umar',
          title: 'AI Habib Umar bin Hafiz',
          titleArabic: 'الحبيب عمر بن حفيظ',
          description:
              'Kitab dan rekaman muhadharah Habib Umar bin Hafiz dengan rujukan terpercaya.',
          emoji: '🕌',
          category: 'Ulama',
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
      ];
}
