// Seluruh naskah landing page, tiga bahasa: [id, en, ar].
// Pedoman suara: openturath_ai/DESIGN.md (tenang, tanpa tanda seru, istilah baku).
export const LOCALES = ['id', 'en', 'ar'];
export const t = (entry, l) => entry[LOCALES.indexOf(l)];

export const copy = {
  langName: ['Bahasa Indonesia', 'English', 'العربية'],
  tagline: ['Membaca kitab, menelusuri ibarah.', 'Read the books. Trace the passage.', 'اقرأ الكتاب، وتتبّع العبارة.'],
  eyebrow: ['AI for Islamic Scholarship', 'AI for Islamic Scholarship', 'الذكاء الاصطناعي للعلوم الإسلامية'],
  skip: ['Lompat ke isi', 'Skip to content', 'انتقل إلى المحتوى'],
  menu: ['Menu', 'Menu', 'القائمة'],
  theme: ['Ganti tema terang atau gelap', 'Switch light or dark theme', 'تبديل المظهر الفاتح أو الداكن'],
  language: ['Bahasa', 'Language', 'اللغة'],

  nav: {
    how: ['Cara kerja', 'How it works', 'طريقة العمل'],
    fields: ['Bidang ilmu', 'Disciplines', 'المجالات العلمية'],
    access: ['Akses', 'Access', 'الاشتراك'],
    download: ['Unduh', 'Download', 'التنزيل'],
  },

  hero: {
    lead: [
      'Ajukan pertanyaan, lalu baca jawabannya bersama ibarah Arab dan letaknya di kitab: judul, jilid, dan halaman.',
      'Ask a question, then read the answer alongside the Arabic passage and where it sits in the book: title, volume, and page.',
      'اطرح سؤالك، ثم اقرأ الجواب مع العبارة العربية وموضعها في الكتاب: العنوان والجزء والصفحة.',
    ],
    secondary: ['Lihat cara kerjanya', 'See how it works', 'تعرّف على طريقة العمل'],
    audience: [
      'Untuk santri, mahasiswa, pengajar, dan peneliti.',
      'For students, teachers, and researchers.',
      'لطلاب العلم والمعلمين والباحثين.',
    ],
  },

  download: {
    title: ['Unduh OpenTurath', 'Download OpenTurath', 'تنزيل أوبن تراث'],
    intro: [
      'Pilih perangkat Anda. Berkas diunduh dari halaman rilis resmi, dan sidik SHA-256 tercantum untuk dicocokkan.',
      'Choose your device. Files come from the official release page, with a SHA-256 checksum you can verify.',
      'اختر جهازك. تُنزَّل الملفات من صفحة الإصدارات الرسمية، ويظهر معها رمز SHA-256 للتحقق.',
    ],
    cta: ['Unduh untuk {0}', 'Download for {0}', 'تنزيل لنظام {0}'],
    soon: ['Segera tersedia', 'Available soon', 'قريبًا'],
    soonLong: [
      'Unduhan untuk {0} segera tersedia.',
      'The {0} download will be available soon.',
      'سيتوفر تنزيل {0} قريبًا.',
    ],
    all: ['Semua unduhan', 'All downloads', 'جميع التنزيلات'],
    version: ['Versi {0}', 'Version {0}', 'الإصدار {0}'],
    requires: ['Sistem minimum', 'Requires', 'الحد الأدنى للنظام'],
    size: ['Ukuran', 'Size', 'الحجم'],
    released: ['Tanggal rilis', 'Released', 'تاريخ الإصدار'],
    checksum: ['Sidik SHA-256', 'SHA-256 checksum', 'رمز SHA-256'],
    ios: [
      'iPhone dan iPad belum tersedia.',
      'iPhone and iPad are not available yet.',
      'لا يتوفر التطبيق لآيفون وآيباد حاليًا.',
    ],
    installTitle: ['Cara memasang', 'How to install', 'طريقة التثبيت'],
    install: {
      android: [
        'Buka berkas APK, lalu izinkan pemasangan dari sumber ini bila diminta.',
        'Open the APK file and allow installation from this source when asked.',
        'افتح ملف APK واسمح بالتثبيت من هذا المصدر عند الطلب.',
      ],
      macos: [
        'Buka berkas DMG dan seret OpenTurath ke folder Aplikasi. Bila macOS menahan, buka lewat klik kanan lalu Buka.',
        'Open the DMG and drag OpenTurath to Applications. If macOS blocks it, right-click the app and choose Open.',
        'افتح ملف DMG واسحب OpenTurath إلى مجلد التطبيقات. إن منعه النظام فانقر بالزر الأيمن ثم اختر «فتح».',
      ],
      windows: [
        'Jalankan penginstal. Bila SmartScreen muncul, pilih Info selengkapnya lalu Tetap jalankan.',
        'Run the installer. If SmartScreen appears, choose More info, then Run anyway.',
        'شغّل ملف التثبيت. إن ظهر SmartScreen فاختر «مزيد من المعلومات» ثم «تشغيل على أي حال».',
      ],
    },
  },

  proof: {
    title: ['Setiap jawaban menunjuk ke sumbernya.', 'Every answer points to its source.', 'كل جواب يدلّك على مصدره.'],
    body: [
      'Satu contoh dari telaah fikih Syafi’i. Jawaban datang bersama ibarah asli dan letaknya di kitab, supaya Anda dapat membukanya sendiri.',
      'One example from a Shafi’i fiqh question. The answer arrives with the original passage and its place in the book, so you can open it yourself.',
      'مثال من مسألة في الفقه الشافعي. يأتي الجواب مع العبارة الأصلية وموضعها في الكتاب، لتراجعها بنفسك.',
    ],
    question: ['Pertanyaan', 'Question', 'السؤال'],
    answer: ['Ringkasan jawaban', 'Answer in brief', 'خلاصة الجواب'],
    passage: ['Ibarah', 'Passage', 'العبارة'],
    reference: ['Rujukan', 'Reference', 'المرجع'],
    locator: ['{0}, jilid {1}, halaman {2}', '{0}, vol. {1}, p. {2}', '{0}، ج{1}، ص{2}'],
    note: [
      'Contoh telaah. Cocokkan selalu dengan kitabnya.',
      'A sample. Always check it against the book.',
      'مثال للتوضيح. راجع الكتاب دائمًا.',
    ],
  },

  how: {
    title: ['Tiga langkah, dari pertanyaan ke kitab.', 'Three steps, from question to book.', 'ثلاث خطوات من السؤال إلى الكتاب.'],
    steps: [
      {
        title: ['Pilih bidang ilmu', 'Choose a discipline', 'اختر المجال العلمي'],
        body: [
          'Tiap bidang punya asisten dengan kitab rujukannya sendiri.',
          'Each discipline has an assistant with its own reference works.',
          'لكل مجال مساعد له كتبه المرجعية.',
        ],
      },
      {
        title: ['Ajukan pertanyaan', 'Ask your question', 'اطرح سؤالك'],
        body: [
          'Tulis masalahnya dengan bahasa Anda: Indonesia, Arab, atau Inggris.',
          'Write the question in your own words, in Indonesian, Arabic, or English.',
          'اكتب مسألتك بلغتك: العربية أو الإندونيسية أو الإنجليزية.',
        ],
      },
      {
        title: ['Baca ibarah, lalu simpan', 'Read the passage, then save it', 'اقرأ العبارة ثم احفظها'],
        body: [
          'Jawaban datang bersama kutipan Arab dan rujukannya. Simpan ke Catatan untuk dibaca lagi.',
          'The answer comes with the Arabic quotation and its reference. Save it to Notes to read again.',
          'يأتي الجواب مع النص العربي ومرجعه. احفظه في الملاحظات للعودة إليه.',
        ],
      },
    ],
  },

  fields: {
    title: ['{0} bidang ilmu.', '{0} disciplines.', '{0} مجالًا علميًّا.'],
    body: [
      'Dari fikih empat mazhab sampai hadis, tafsir, dan bahasa Arab.',
      'From the four schools of fiqh to hadith, tafsir, and Arabic.',
      'من فقه المذاهب الأربعة إلى الحديث والتفسير واللغة العربية.',
    ],
    books: ['{0} kitab', '{0} works', 'الكتب: {0}'],
  },

  numbers: {
    books: ['Kitab', 'Works', 'كتابًا'],
    volumes: ['Jilid', 'Volumes', 'مجلدًا'],
    pages: ['Halaman', 'Pages', 'صفحة'],
    fields: ['Bidang ilmu', 'Disciplines', 'مجالًا'],
    note: [
      'Dihitung dari metadata katalog aplikasi.',
      'Counted from the app’s catalogue metadata.',
      'محسوبة من بيانات فهرس التطبيق.',
    ],
  },

  adab: {
    title: ['Alat bantu, bukan pengganti guru.', 'A study aid, not a substitute for a teacher.', 'أداة مساعدة، لا بديل عن المعلّم.'],
    body: [
      'Jawaban AI bisa keliru. Periksa pada kitab yang dirujuk, dan bawa hasil telaah kepada guru sebelum dipakai untuk mengajar, menulis, atau mengambil kesimpulan.',
      'AI answers can be wrong. Check them against the cited book, and take your findings to a teacher before you teach, write, or draw conclusions from them.',
      'قد يخطئ الذكاء الاصطناعي. راجع الكتاب المُحال إليه، واعرض ما توصلت إليه على معلّمك قبل التدريس أو الكتابة أو استخلاص الأحكام.',
    ],
    link: ['Baca panduan penggunaan AI', 'Read the AI usage guide', 'اقرأ دليل استخدام الذكاء الاصطناعي'],
  },

  access: {
    title: ['Pilih akses sesuai kebutuhan.', 'Choose the access you need.', 'اختر الاشتراك المناسب.'],
    pageTitle: ['Akses dan harga', 'Access and pricing', 'الاشتراك والأسعار'],
    one: {
      name: ['Satu asisten', 'One assistant', 'مساعد واحد'],
      body: [
        'Satu bidang ilmu pilihan Anda beserta kitab rujukannya.',
        'One discipline of your choice with its reference works.',
        'مجال علمي واحد تختاره مع كتبه المرجعية.',
      ],
    },
    tahawwulat: {
      name: ['Fikih Tahawwulat', 'Fiqh Tahawwulat', 'فقه التحولات'],
      body: [
        'Lima asisten untuk menelaah Fikih Tahawwulat, dengan kitab rujukan dan arsip muhadharah.',
        'Five assistants for studying Fiqh Tahawwulat, with reference works and lecture archives.',
        'خمسة مساعدين لدراسة فقه التحولات، مع الكتب المرجعية وأرشيف المحاضرات.',
      ],
    },
    months: ['{0} bulan', '{0} months', '{0} أشهر'],
    month1: ['1 bulan', '1 month', 'شهر واحد'],
    month12: ['12 bulan', '12 months', '١٢ شهرًا'],
    perMonth: ['≈ {0} per bulan', '≈ {0} per month', '≈ {0} شهريًّا'],
    intro: ['Harga perdana', 'Introductory price', 'سعر تعريفي'],
    terms: [
      'Pembayaran dilakukan di dalam aplikasi. Akses berakhir pada tanggal yang tertera dan tidak diperpanjang otomatis.',
      'Payment is made inside the app. Access ends on the date shown and never renews automatically.',
      'يتم الدفع داخل التطبيق. ينتهي الاشتراك في التاريخ المبيّن ولا يتجدد تلقائيًّا.',
    ],
    details: ['Rincian pembayaran dan pengembalian dana', 'Payment and refund details', 'تفاصيل الدفع والاسترداد'],
    more: ['Lihat akses dan harga', 'See access and pricing', 'عرض الاشتراك والأسعار'],
  },

  faq: {
    title: ['Pertanyaan yang sering diajukan', 'Frequently asked questions', 'أسئلة متكررة'],
    items: [
      {
        q: ['Apakah OpenTurath menggantikan guru?', 'Does OpenTurath replace a teacher?', 'هل يغني أوبن تراث عن المعلّم؟'],
        a: [
          'Tidak. OpenTurath membantu menemukan ibarah dan menyiapkan pertanyaan. Pemahaman agama dan penetapan hukum tetap memerlukan bimbingan guru.',
          'No. OpenTurath helps you find passages and prepare questions. Understanding the religion and deriving rulings still require a teacher.',
          'لا. يساعدك أوبن تراث على الوصول إلى العبارات وإعداد أسئلتك، أما فهم الدين واستنباط الأحكام فيحتاجان إلى معلّم.',
        ],
      },
      {
        q: ['Dari mana jawabannya berasal?', 'Where do the answers come from?', 'من أين تأتي الأجوبة؟'],
        a: [
          'Dari kitab-kitab yang dihimpun untuk tiap bidang ilmu. Jawaban menyertakan ibarah dan rujukannya agar dapat Anda periksa.',
          'From the works collected for each discipline. Answers include the passage and its reference so you can check them.',
          'من الكتب المجموعة لكل مجال علمي. ويتضمن الجواب العبارة ومرجعها لتتحقق منها.',
        ],
      },
      {
        q: ['Apakah jawabannya selalu benar?', 'Are the answers always correct?', 'هل الأجوبة صحيحة دائمًا؟'],
        a: [
          'Tidak selalu. AI bisa salah mengutip atau salah memahami. Karena itu setiap jawaban menunjuk ke kitabnya, dan Anda perlu memeriksanya di sana.',
          'Not always. AI can misquote or misread. That is why each answer points to its book, and why you should check it there.',
          'ليس دائمًا. قد يخطئ الذكاء الاصطناعي في النقل أو الفهم، ولذلك يحيلك كل جواب إلى كتابه لتراجعه هناك.',
        ],
      },
      {
        q: ['Perangkat apa yang didukung?', 'Which devices are supported?', 'ما الأجهزة المدعومة؟'],
        a: [
          'Android, macOS, dan Windows. iPhone dan iPad belum tersedia.',
          'Android, macOS, and Windows. iPhone and iPad are not available yet.',
          'أندرويد وماك وويندوز. ولا يتوفر التطبيق لآيفون وآيباد حاليًا.',
        ],
      },
      {
        q: ['Bagaimana cara membayar?', 'How do I pay?', 'كيف أدفع؟'],
        a: [
          'Di dalam aplikasi. Pilih masa akses 1, 6, atau 12 bulan. Akses tidak diperpanjang otomatis.',
          'Inside the app. Choose 1, 6, or 12 months of access. It never renews automatically.',
          'داخل التطبيق. اختر مدة شهر أو ٦ أشهر أو ١٢ شهرًا. ولا يتجدد الاشتراك تلقائيًّا.',
        ],
      },
      {
        q: ['Bagaimana cara menghapus akun?', 'How do I delete my account?', 'كيف أحذف حسابي؟'],
        a: [
          'Dari menu Pengaturan di aplikasi. Rinciannya ada di halaman Penghapusan akun.',
          'From Settings in the app. The Account deletion page has the details.',
          'من الإعدادات داخل التطبيق. والتفاصيل في صفحة حذف الحساب.',
        ],
      },
    ],
  },

  contact: {
    title: ['Kontak', 'Contact', 'اتصل بنا'],
    body: [
      'Untuk bantuan, laporan kekeliruan kutipan, atau pertanyaan tentang akses, kirim email ke alamat berikut.',
      'For help, to report a citation error, or to ask about access, email us at this address.',
      'للمساعدة أو للإبلاغ عن خطأ في نقل أو للسؤال عن الاشتراك، راسلنا على هذا العنوان.',
    ],
    hint: [
      'Sertakan nama asisten, pertanyaan Anda, dan rujukan yang dipersoalkan agar dapat kami periksa.',
      'Include the assistant name, your question, and the reference in doubt so we can check it.',
      'اذكر اسم المساعد وسؤالك والمرجع المشكوك فيه لنتمكن من مراجعته.',
    ],
    copy: ['Salin alamat', 'Copy address', 'نسخ العنوان'],
    copied: ['Alamat disalin.', 'Address copied.', 'تم نسخ العنوان.'],
  },

  legal: {
    terms: ['Ketentuan Layanan', 'Terms of Service', 'شروط الخدمة'],
    privacy: ['Kebijakan Privasi', 'Privacy Policy', 'سياسة الخصوصية'],
    billing: ['Pembayaran dan pengembalian dana', 'Payment and refunds', 'الدفع والاسترداد'],
    'account-deletion': ['Penghapusan akun', 'Account deletion', 'حذف الحساب'],
    'ai-guidelines': ['Panduan penggunaan AI', 'AI usage guide', 'دليل استخدام الذكاء الاصطناعي'],
    effective: ['Berlaku sejak {0} · versi {1}', 'Effective {0} · version {1}', 'سارية منذ {0} · الإصدار {1}'],
    full: ['Naskah lengkap kebijakan aplikasi', 'Full application policy text', 'النص الكامل لسياسة التطبيق'],
  },

  footer: {
    product: ['Produk', 'Product', 'المنتج'],
    policies: ['Kebijakan', 'Policies', 'السياسات'],
    help: ['Bantuan', 'Help', 'المساعدة'],
    home: ['Beranda', 'Home', 'الرئيسية'],
    rights: ['Jawaban AI perlu diperiksa pada kitab rujukan.', 'AI answers should be checked against the cited works.', 'ينبغي مراجعة أجوبة الذكاء الاصطناعي في الكتب المُحال إليها.'],
  },

  notFound: {
    title: ['Halaman tidak ditemukan', 'Page not found', 'الصفحة غير موجودة'],
    body: ['Alamat ini tidak ada. Kembali ke beranda untuk melanjutkan.', 'This address does not exist. Go back to the home page to continue.', 'هذا العنوان غير موجود. عُد إلى الرئيسية للمتابعة.'],
  },
};
