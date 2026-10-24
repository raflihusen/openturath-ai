import 'localization.dart';

/// Teks pengenalan aplikasi (onboarding) dalam tiga bahasa. Sengaja berdiri
/// sendiri agar naskahnya mudah ditinjau tanpa membuka katalog salinan besar.
class OnboardingCopy {
  const OnboardingCopy._();

  static String _l(String id, String en, String ar) => switch (Loc.language) {
        'en' => en,
        'ar' => ar,
        _ => id,
      };

  static String get skip => _l('Lewati', 'Skip', 'تخطَّ');
  static String get next => _l('Lanjut', 'Next', 'التالي');
  static String get start => _l('Mulai', 'Get started', 'ابدأ');
  static String get close => _l('Tutup', 'Close', 'إغلاق');

  static String get replayTitle =>
      _l('Pengenalan aplikasi', 'App introduction', 'التعريف بالتطبيق');
  static String get replaySubtitle => _l('Lihat kembali empat slide pengenalan',
      'Watch the four intro slides again', 'شاهد شرائح التعريف الأربع من جديد');

  // ── Slide 1 ──
  static String get p1Kicker => 'OPENTURATH AI';
  static String get p1Title => _l(
      'AI untuk penuntut ilmu, bersumber dari kitab.',
      'AI for students of knowledge, grounded in the books.',
      'ذكاء اصطناعي لطلبة العلم، مستند إلى الكتب.');
  static String get p1Body => _l(
      'Anda bertanya. OpenTurath menjelaskan, lalu menunjukkan teks aslinya dari kitab.',
      'You ask. OpenTurath explains, then shows you the original text from the books.',
      'تسأل، فيشرح لك OpenTurath، ثم يعرض عليك النص الأصلي من الكتب.');

  // ── Slide 2 ──
  static String get p2Title => _l(
      'Apa bedanya dengan AI umum?',
      'How is it different from general AI?',
      'ما الفرق بينه وبين الذكاء الاصطناعي العام؟');
  static String get p2Left =>
      _l('AI umum', 'General AI', 'الذكاء الاصطناعي العام');
  static String get p2Right => 'OpenTurath';
  static List<(String, String)> get p2Rows => [
        (
          _l('Ulama dan mazhab tercampur', 'Scholars and schools get mixed',
              'اختلاط أقوال العلماء والمذاهب'),
          _l('Satu bidang, satu asisten', 'One field, one assistant',
              'لكل علم مساعد خاص'),
        ),
        (
          _l('Kitab dan halaman yang tidak ada',
              'Books and pages that do not exist', 'كتب وصفحات لا وجود لها'),
          _l(
              'Ibarah dan rujukan yang bisa diperiksa',
              'Passages and references you can check',
              'عبارات ومراجع يمكن التحقق منها'),
        ),
        (
          _l('Kalimat dipotong dari konteksnya',
              'Sentences cut from their context', 'جمل مقتطعة من سياقها'),
          _l(
              'Ibarah Arab diambil dari kitab, tidak dikarang',
              'Arabic passages come from the books, never invented',
              'العبارات العربية منقولة من الكتب، لا مختلَقة'),
        ),
      ];

  // ── Slide 3 ──
  static String get p3Title => _l('Satu bidang ilmu, satu asisten.',
      'One field of knowledge, one assistant.', 'لكل علم مساعد خاص.');
  static String get p3Body => _l(
      'Pustaka kitab dikelompokkan per bidang. Setiap bidang punya asistennya sendiri, dan akan terus bertambah.',
      'The library is grouped by field. Each field has its own assistant, and more are coming.',
      'تُصنَّف المكتبة بحسب العلوم، ولكل علم مساعده الخاص، وستُضاف علوم أخرى.');
  static List<String> get p3Fields => [
        _l("Fikih Syafi'i", "Shafi'i Fiqh", 'الفقه الشافعي'),
        _l('Fikih Tahawwulat', 'Fiqh al-Tahawwulat', 'فقه التحولات'),
        _l('Hadis', 'Hadith', 'الحديث'),
        _l('Tafsir', 'Tafsir', 'التفسير'),
        _l('Akidah', 'Creed', 'العقيدة'),
      ];
  static String get p3Exclusive => _l('Eksklusif di OpenTurath',
      'Exclusive to OpenTurath', 'حصري في OpenTurath');

  // ── Slide 4 ──
  static String get p4Title => _l('Tanyakan, lalu periksa sumbernya.',
      'Ask, then check the source.', 'اسأل، ثم تحقّق من المصدر.');
  static String get p4Body => _l(
      'Pilih bidang, ajukan pertanyaan, lalu bandingkan jawabannya dengan ibarah yang ditampilkan.',
      'Pick a field, ask a question, then compare the answer with the passage shown.',
      'اختر العلم، واطرح سؤالك، ثم قارن الجواب بالعبارة المعروضة.');
  static String get p4Note => _l(
      'OpenTurath adalah bahan belajar, bukan fatwa. Untuk urusan amalan, tanyakan kepada guru Anda.',
      'OpenTurath is a study aid, not a fatwa. For matters of practice, ask your teacher.',
      'OpenTurath مادة للدراسة وليس فتوى. وفي أمور العمل اسأل معلّمك.');
  static String get p4Question => _l('Apa saja rukun iman?',
      'What are the pillars of Iman?', 'ما أركان الإيمان؟');
  static String get p4Explain => _l('Penjelasan', 'Explanation', 'الشرح');
  static String get p4Passage =>
      _l('Ibarah asli', 'Original passage', 'العبارة الأصلية');
  static String get p4Reference => _l('Kitab · jilid · halaman',
      'Book · volume · page', 'الكتاب · الجزء · الصفحة');
}
