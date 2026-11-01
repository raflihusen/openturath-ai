// Naskah kanonik ID, EN, AR. Setiap entri wajib memiliki tiga terjemahan.
const copyCatalog = <String, List<String>>{
  "loadingProcess": ["Memuat…", "Loading…", "جارٍ التحميل…"],
  "appName": ["OpenTurath", "OpenTurath", "أوبن تراث"],
  "appTagline": [
    "AI for Islamic Scholarship",
    "AI for Islamic Scholarship",
    "الذكاء الاصطناعي للعلوم الإسلامية"
  ],
  "defaultFieldDesc": [
    "Pilih bidang untuk mulai menelusuri kitab.",
    "Choose a discipline to explore its books.",
    "اختر مجالًا للاطلاع على كتبه."
  ],
  "aboutTitle": ["Tentang OpenTurath", "About OpenTurath", "عن أوبن تراث"],
  "aboutDescription": [
    "OpenTurath membantu Anda menelusuri pembahasan dan rujukan dalam kitab-kitab Islam dengan bantuan AI. Pilih bidang yang ingin dipelajari, ajukan pertanyaan, lalu baca kutipan dan keterangan kitab yang tersedia. Simpan jawaban atau kutipan ke Catatan untuk dipelajari kembali.",
    "OpenTurath helps you find passages and references in classical Islamic works with the aid of AI. Choose a field, ask a question, then read the passages and book details that are available. Save answers or quotations to Notes to revisit them.",
    "يعينك أوبن تراث على تتبع العبارات والمراجع في كتب التراث بأدوات الذكاء الاصطناعي. اختر مجالًا واطرح مسألتك واقرأ النصوص المحالة إلى مصادرها، واحفظ ما تحتاج إليه في ملاحظاتك."
  ],
  "aboutScholarlyPrinciple": [
    "Kami ingin membuat proses mencari rujukan lebih mudah, sambil menjaga kebiasaan membaca sumber dengan teliti. Jawaban AI tetap perlu diperiksa pada kitab yang dirujuk, terutama sebelum digunakan untuk mengajar, menulis, atau mengambil kesimpulan. Pemahaman agama dan penetapan hukum tetap memerlukan bimbingan guru serta ulama yang berkompeten.",
    "Read every reference carefully and verify each answer against the cited edition. Religious understanding and legal judgment require guidance from qualified teachers and scholars.",
    "اقرأ المراجع بعناية وراجع كل جواب في الطبعة المحال إليها. وفهم الدين واستنباط الأحكام يحتاجان إلى إرشاد المعلمين والعلماء المؤهلين."
  ],
  "academicSlogan": [
    "Riset kitab turats",
    "Classical Islamic Textual Studies",
    "دراسة كتب التراث الإسلامي"
  ],
  "navHome": ["Beranda", "Home", "الرئيسية"],
  "navStudies": ["AI", "AI", "AI"],
  "assistantIntro": [
    "Pilih bidang, lalu lihat kitab rujukan setiap AI sebelum mulai bertanya.",
    "Choose a field, then review each AI's scope and sources before you begin.",
    "اختر مجالًا ثم اطّلع على اختصاص كل مساعد ومراجعه قبل بدء المطالعة."
  ],
  "assistantBrowse": ["Bidang ilmu", "Fields of study", "مجالات العلم"],
  "assistantBrowseHint": [
    "Pilih untuk menyaring",
    "Select to filter",
    "اختر للتصفية"
  ],
  "assistantFeatured": ["KOLEKSI KHUSUS", "SPECIAL COLLECTION", "مجموعة خاصة"],
  "assistantFeaturedDesc": [
    "Lima AI untuk matan, konsep, latihan, ceramah, dan dakwah.",
    "Five study paths for source texts, concepts, practice, lectures, and teaching.",
    "خمسة مسارات لمطالعة المتون والمفاهيم والتدريب والمحاضرات والدعوة."
  ],
  "assistantFeaturedAction": [
    "Lihat lima AI",
    "See five AIs",
    "عرض الذكاءات الاصطناعية الخمسة"
  ],
  "assistantSelected": ["AI terpilih", "Selected AI", "مسار المطالعة"],
  "assistantSelectedHint": [
    "Cakupan dan rujukan",
    "Scope and references",
    "الاختصاص والمراجع"
  ],
  "assistantMore": ["AI lainnya", "Other AIs", "ذكاءات اصطناعية أخرى"],
  "assistantAvailable": ["Tersedia", "Available", "متاح"],
  "assistantSearch": ["Cari AI", "Search AI", "ابحث عن مساعد ذكي"],
  "clearSearch": ["Hapus pencarian", "Clear search", "مسح البحث"],
  "assistantLibrary": ["Lihat pustaka", "View library", "عرض المكتبة"],
  "planFeaturedLabel": ["Paket utama", "Main collection", "المجموعة الرئيسية"],
  "planFeaturedIncludes": [
    "{0} AI dalam satu paket",
    "{0} AIs in one plan",
    "{0} ذكاءات اصطناعية في باقة واحدة"
  ],
  "tahawwulatRole_muhaqqiq": [
    "Matan dan ibarah langsung dari kitab",
    "Source texts and passages from the works",
    "المتون والعبارات من مصادرها"
  ],
  "tahawwulatRole_bayan": [
    "Konsep dan istilah, dijelaskan sederhana",
    "Concepts and terms, explained plainly",
    "المفاهيم والمصطلحات بشرح ميسّر"
  ],
  "tahawwulatRole_mukhtabir": [
    "Uji pemahaman lewat tanya jawab",
    "Tests your understanding by questions",
    "اختبار الفهم بالسؤال والجواب"
  ],
  "tahawwulatRole_habib": [
    "Arsip ceramah Habib Abu Bakar Al-Adni bin Ali Al-Masyhur",
    "Lecture archive of Habib Abu Bakr al-Adni bin Ali al-Mashhur",
    "أرشيف محاضرات الحبيب أبي بكر"
  ],
  "tahawwulatRole_khatib": [
    "Bahan dakwah dan khutbah",
    "Material for da'wah and sermons",
    "مادة الدعوة والخطب"
  ],
  "subHeadline": [
    "Pilih paket langganan",
    "Choose your subscription plan",
    "اختر باقة الاشتراك"
  ],
  "subHeadlineNamed": [
    "{0}, pilih paket langganan Anda",
    "{0}, choose your subscription plan",
    "{0}، اختر باقة اشتراكك"
  ],
  "termSavingVsMonthly": [
    "Hemat {0}% dari bulanan",
    "Save {0}% vs monthly",
    "وفّر {0}٪ مقارنة بالشهري"
  ],
  "planStartTerm": ["Mulai {0} · {1}", "Start {0} · {1}", "ابدأ {0} · {1}"],
  "planTrustNote": [
    "Sekali bayar · tanpa perpanjangan otomatis",
    "One-time payment · no automatic renewal",
    "دفعة واحدة · دون تجديد تلقائي"
  ],
  "flagshipExplore": [
    "Jelajahi {0} AI",
    "Explore {0} AIs",
    "استكشف {0} ذكاءات اصطناعية"
  ],
  "flagshipIntroduction": [
    "Mengenal Fikih Tahawwulat",
    "About Fiqh al-Tahawwulat",
    "التعرّف إلى فقه التحولات"
  ],
  "flagshipActive": ["AKTIF", "ACTIVE", "فعّال"],
  "flagshipPremium": ["PREMIUM", "PREMIUM", "مميّز"],
  "planExclusive": ["Eksklusif", "Exclusive", "حصري"],
  "planFeaturedDescription": [
    "Ilmu untuk memahami perubahan zaman, dengan kitab rujukan dan arsip ceramah.",
    "The science of understanding the changes of the age, with source books and a lecture archive.",
    "علم فهم تغيّر الزمان، مع الكتب المرجعية وأرشيف المحاضرات."
  ],
  "planSingleDescription": [
    "Akses satu bidang keilmuan beserta kitab rujukannya.",
    "Access one field of study and its reference works.",
    "الوصول إلى مجال علمي واحد وكتبه المرجعية."
  ],
  "planSingleBenefit1": [
    "Akses {0}",
    "Access the {0} study AI",
    "الوصول إلى مساعد دراسة {0}"
  ],
  "planSingleBenefit2": [
    "Telusuri ibarah dan konsep dalam kitab rujukan",
    "Explore passages and concepts in the reference works",
    "تتبّع العبارات والمفاهيم في الكتب المرجعية"
  ],
  "planSingleBenefit3": [
    "Baca rujukan kitab, jilid, dan halaman bila tersedia",
    "Read cited works, volumes, and pages when available",
    "اقرأ إحالات الكتب والأجزاء والصفحات عند توفرها"
  ],
  "planSingleBenefit4": [
    "Simpan jawaban AI untuk dibaca kembali",
    "Save your study results for later reading",
    "احفظ نتائج المطالعة للرجوع إليها"
  ],
  "planFeaturedInside": ["Isi paket", "In this plan", "محتوى الباقة"],
  "planFeaturedInsideValue": ["Lima AI", "Five AIs", "خمسة ذكاءات اصطناعية"],
  "planSingleFieldNote": [
    "Satu paket untuk satu bidang ilmu. Anda bisa berganti pilihan sebelum membayar, dan bidang lain akan segera hadir.",
    "One plan covers one field. You can change your choice before paying, and more fields are coming soon.",
    "الباقة الواحدة لعلم واحد. يمكنك تغيير اختيارك قبل الدفع، وستُضاف علوم أخرى قريبًا."
  ],
  "planBenefitGrowth": [
    "Kitab dan arsip ceramah baru ditambahkan berkala",
    "New books and lecture archives are added regularly",
    "تُضاف كتب وأرشيف محاضرات جديدة بصورة دورية"
  ],
  "planBenefitGrowthSingle": [
    "Kitab baru ditambahkan berkala",
    "New books are added regularly",
    "تُضاف كتب جديدة بصورة دورية"
  ],
  "planBenefitUpdates": [
    "Pembaruan aplikasi selama langganan aktif",
    "App updates while your subscription is active",
    "تحديثات التطبيق ما دام اشتراكك فعّالًا"
  ],
  "planSingleBenefit5": [
    "Salin percakapan untuk dibaca kembali di tempat lain",
    "Copy the conversation to read again elsewhere",
    "انسخ المحادثة لتقرأها مرة أخرى في مكان آخر"
  ],
  "planFeaturedBenefit1": [
    "Akses penuh ke AI Fikih Tahawwulat",
    "Full access to the Fiqh al-Tahawwulat AIs",
    "وصول كامل إلى ذكاءات فقه التحولات الاصطناعية"
  ],
  "planFeaturedBenefit2": [
    "Lima AI: Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, dan Al-Khatib",
    "Five AIs: Al-Muhaqqiq, Al-Bayan, Al-Mukhtabir, Al-Habib, and Al-Khatib",
    "خمسة ذكاءات اصطناعية: المحقق والبيان والمختبر والحبيب والخطيب"
  ],
  "planFeaturedBenefit3": [
    "Uji pemahaman lewat tanya jawab langsung",
    "Direct Q&A comprehension practice",
    "اختبار الفهم عبر السؤال والجواب المباشر"
  ],
  "planFeaturedBenefit4": [
    "Arsip ceramah dan transkrip sebagai rujukan tanya jawab",
    "Lecture archive and transcripts for study",
    "أرشيف المحاضرات ونصوصها للمطالعة"
  ],
  "planChoose": ["Pilih paket {0}", "Choose the {0} plan", "اختر خطة {0}"],
  "checkoutAuthExpired": [
    "Sesi akun berakhir. Masuk kembali lalu ulangi pembayaran.",
    "Your session expired. Sign in again, then retry payment.",
    "انتهت جلستك. سجّل الدخول مجددًا ثم أعد محاولة الدفع."
  ],
  "checkoutServiceUnavailable": [
    "Layanan pembayaran belum merespons. Periksa koneksi lalu coba lagi.",
    "The payment service is not responding. Check your connection and retry.",
    "خدمة الدفع لا تستجيب. تحقق من الاتصال ثم أعد المحاولة."
  ],
  "checkoutPlanUnavailable": [
    "Paket belum dapat diproses saat ini. Coba lagi beberapa saat lagi.",
    "This plan cannot be processed right now. Please try again shortly.",
    "تعذرت معالجة هذه الخطة الآن. حاول مجددًا بعد قليل."
  ],
  "checkoutAccountDenied": [
    "Akun ini belum dapat memulai pembayaran. Periksa status akun Anda.",
    "This account cannot start payment. Check your account status.",
    "لا يمكن لهذا الحساب بدء الدفع. تحقق من حالة حسابك."
  ],
  "checkoutSelectionInvalid": [
    "Pilihan paket perlu diperbarui. Buka kembali halaman ini lalu coba lagi.",
    "Your plan selection needs updating. Reopen this page and retry.",
    "يجب تحديث اختيار الخطة. افتح هذه الصفحة مجددًا ثم أعد المحاولة."
  ],
  "checkoutLinkUnavailable": [
    "Tautan pembayaran belum tersedia. Coba lagi.",
    "The payment link is unavailable. Please try again.",
    "رابط الدفع غير متاح حاليًا. أعد المحاولة."
  ],
  "navSaved": ["Catatan", "Notes", "الملاحظات"],
  "navSettings": ["Pengaturan", "Settings", "الإعدادات"],
  "membershipFor": ["Untuk", "For", "لصاحب الحساب"],
  "studySpace": ["Percakapan", "Conversation", "المحادثة"],
  "openStudy": ["Membuka AI…", "Opening AI…", "جارٍ فتح المساعد…"],
  "studyOptions": ["Tampilan bacaan", "Reading options", "خيارات القراءة"],
  "referenceBooks": ["Kitab rujukan", "Reference books", "الكتب المرجعية"],
  "savedCollection": ["Catatan", "Notes", "الملاحظات"],
  "bookDetails": ["Identitas kitab", "Book Record", "بطاقة الكتاب"],
  "chooseField": ["Pilih bidang", "Choose a discipline", "اختر مجال العلم"],
  "allCategories": ["Semua bidang", "All disciplines", "جميع المجالات"],
  "searchResults": ["Hasil pencarian", "Search results", "نتائج البحث"],
  "continueStudy": [
    "Lanjutkan percakapan",
    "Continue conversation",
    "متابعة المحادثة"
  ],
  "startStudy": ["Mulai bertanya", "Ask a question", "ابدأ السؤال"],
  "dashboardSearchHint": [
    "Cari AI atau bidang keilmuan…",
    "Search AIs or disciplines…",
    "ابحث عن المساعد أو المجال العلمي…"
  ],
  "ahlanDefault": ["Halo", "Welcome", "أهلًا وسهلًا"],
  "studyBookCategory": ["TANYA KITAB", "ASK THE BOOKS", "مطالعة الكتب"],
  "studyEntryDefaultTitle": [
    "Mulai dari satu pertanyaan",
    "Start with a question",
    "قراءة عبارات التراث وفهمها"
  ],
  "studyEntryResumeSubtitle": [
    "Sesi terakhir Anda masih terbuka.",
    "Your last session is still open.",
    "جلستك الأخيرة لا تزال مفتوحة."
  ],
  "studyEntryHistorySubtitle": [
    "Lanjutkan dari AI yang terakhir Anda buka.",
    "Pick up with the AI you opened last.",
    "عُد إلى مراجعك وملاحظاتك السابقة."
  ],
  "studyEntryDefaultSubtitle": [
    "Pilih AI, ajukan masalah, lalu periksa rujukannya di kitab.",
    "Pick an AI, ask your question, then check its references in the books.",
    "اطرح مسألة وتتبع مباحثها في كتب التراث المعتمدة."
  ],
  "loadingReferences": [
    "Menyiapkan AI…",
    "Preparing AI…",
    "جارٍ تهيئة المساعد…"
  ],
  "modulePreparing": [
    "Bagian ini sedang disiapkan",
    "This section is being prepared",
    "هذا القسم قيد الإعداد"
  ],
  "moduleUnavailable": [
    "AI ini belum tersedia. Coba lagi nanti.",
    "This AI is not yet available. Please try again later.",
    "هذا المساعد غير متاح حاليًا. حاول لاحقًا."
  ],
  "cannotLoad": [
    "Data belum bisa dimuat. Coba lagi.",
    "The content could not be loaded. Please try again.",
    "تعذر تحميل المحتوى. أعد المحاولة."
  ],
  "cannotLoadStudy": [
    "AI belum bisa dibuka",
    "The AI could not be opened",
    "تعذر فتح المساعد"
  ],
  "studyNotLoadedYet": [
    "Percakapan belum bisa dimuat. Coba lagi sebentar.",
    "Conversation has not loaded yet. Please try again shortly.",
    "لم يكتمل تحميل المحادثة. حاول بعد قليل."
  ],
  "subscriptionRequiredTitle": [
    "Berlangganan untuk melanjutkan",
    "Subscribe to continue",
    "يلزم الاشتراك للمتابعة"
  ],
  "subscriptionRequiredShort": [
    "Akses diperlukan",
    "Access required",
    "يلزم تفعيل الوصول"
  ],
  "catalogLoadFailed": [
    "Daftar kitab belum bisa dimuat.",
    "The book catalog could not be loaded.",
    "تعذر تحميل فهرس الكتب."
  ],
  "catalogPreparing": [
    "Katalog kitab sedang disiapkan.",
    "The book catalog is being prepared.",
    "فهرس الكتب قيد الإعداد."
  ],
  "inputQuestionHint": [
    "Tulis pertanyaan atau ibarah kitab di sini…",
    "Write a question or paste a passage here…",
    "اكتب المسألة أو العبارة التي تريد مطالعتها…"
  ],
  "viewSubscription": [
    "Lihat langganan",
    "View subscription",
    "عرض خيارات الاشتراك"
  ],
  "tryAgain": ["Coba lagi", "Try again", "إعادة المحاولة"],
  "sessionExpiredOrNoAccess": [
    "Sesi berakhir, atau akses ke AI ini belum aktif.",
    "Your session has ended or access to this AI is inactive.",
    "انتهت الجلسة أو لم يُفعّل وصولك إلى هذا الذكاء الاصطناعي."
  ],
  "agentLoadFailed": [
    "AI belum bisa dibuka. Coba lagi sebentar.",
    "The AI could not be loaded. Please try again shortly.",
    "تعذر تحميل الذكاء الاصطناعي. حاول بعد قليل."
  ],
  "backToHome": ["Kembali ke beranda", "Return home", "العودة إلى الرئيسية"],
  "noAssistantsFound": [
    "Belum ada bidang atau kitab yang cocok. Coba kata kunci lain.",
    "No matching discipline or book was found. Try another search term.",
    "لم يُعثر على مجال أو كتاب مطابق. جرّب عبارة أخرى."
  ],
  "comingSoon": ["Belum tersedia", "Not yet available", "غير متاح بعد"],
  "deviceNotSupportedTitle": [
    "Perangkat belum didukung",
    "Device not supported",
    "الجهاز غير مدعوم"
  ],
  "deviceNotSupportedMessage": [
    "OpenTurath saat ini mendukung Android, macOS, dan Windows. Perangkat ini belum didukung.",
    "OpenTurath currently supports Android, macOS, and Windows. This device is not supported.",
    "يدعم أوبن تراث حاليًا Android وmacOS وWindows. هذا الجهاز غير مدعوم."
  ],
  "cannotConnectTitle": [
    "Tidak dapat terhubung",
    "Unable to connect",
    "تعذر الاتصال"
  ],
  "cannotConnectMessage": [
    "OpenTurath belum bisa terhubung. Periksa koneksi internet, lalu coba lagi.",
    "Unable to connect to OpenTurath. Check your internet connection and try again.",
    "تعذر الاتصال بأوبن تراث. تحقق من اتصالك بالإنترنت وأعد المحاولة."
  ],
  "adabDialogTitle": [
    "Catatan sebelum bertanya",
    "Before beginning your study",
    "قبل الشروع في المطالعة"
  ],
  "adabAcknowledgeButton": ["Saya mengerti", "I understand", "فهمت"],
  "adabDialogLead": [
    "OpenTurath membantu mencari kutipan dan memahami ibarah dalam kitab. Cocokkan kembali rujukan dengan kitabnya, dan tetaplah bertalaqqi kepada guru yang berkompeten.",
    "OpenTurath helps you find quotations and study passages. Verify references in the source works and continue learning with qualified teachers and scholars.",
    "يساعدك أوبن تراث في تتبع النقول ومطالعة العبارات. راجع الإحالات في مصادرها وواصل التلقي عن المعلمين والمشايخ المؤهلين."
  ],
  "adabHeading1": [
    "Bantuan untuk menelusuri kitab",
    "Finding passages in the sources",
    "تتبع العبارات في المصادر"
  ],
  "adabBody1": [
    "Gunakan OpenTurath untuk mencari ibarah dan membaca penjelasan ulama dalam kitab. Verifikasi hasilnya langsung dengan naskah kitab rujukan.",
    "Use OpenTurath to find passages and read the scholars' explanations. Check the results against the source text.",
    "استعن بأوبن تراث لتتبع العبارات وشروح العلماء، وراجع النتائج في النص الأصلي."
  ],
  "adabHeading2": [
    "Talaqqi dan bimbingan guru",
    "Learning with teachers",
    "التلقي وإرشاد المعلمين"
  ],
  "adabBody2": [
    "Untuk memahami agama dengan baik dan benar, tetaplah bertalaqqi kepada guru dan ulama yang berkompeten.",
    "Sound religious understanding calls for continued study with qualified teachers and scholars.",
    "الفهم السليم للدين يستلزم مواصلة التلقي عن المعلمين والعلماء المؤهلين."
  ],
  "adabHeading3": [
    "Tahqiq dan periksa rujukan",
    "Verify the text and its references",
    "تحقيق النص ومراجعة الإحالات"
  ],
  "adabBody3": [
    "Periksa matan, syarah, serta nomor jilid dan halaman pada kitab rujukan sebelum menjadikannya dasar hukum.",
    "Check the text, commentary, volume, and page in the cited edition before drawing conclusions.",
    "راجع المتن والشرح ورقم الجزء والصفحة في الطبعة المعتمدة قبل الاستنباط."
  ],
  "noAnswerToCopy": [
    "Belum ada jawaban untuk disalin.",
    "There is no answer to copy yet.",
    "لا يوجد جواب لنسخه بعد."
  ],
  "noConversationToCopy": [
    "Belum ada percakapan untuk disalin.",
    "There are no study notes to copy yet.",
    "لا توجد ملاحظات مطالعة لنسخها بعد."
  ],
  "answerCopied": ["Jawaban disalin.", "Answer copied.", "نُسخ الجواب."],
  "conversationCopied": [
    "Percakapan disalin dan tersimpan ke Catatan.",
    "Study notes copied and saved.",
    "نُسخت ملاحظات المطالعة وحُفظت."
  ],
  "copyFailed": [
    "Jawaban belum bisa disalin. Coba lagi.",
    "The answer could not be copied. Please try again.",
    "تعذر نسخ الجواب. أعد المحاولة."
  ],
  "noAnswerToSave": [
    "Belum ada jawaban untuk disimpan.",
    "There is no answer to save yet.",
    "لا يوجد جواب لحفظه بعد."
  ],
  "savedSuccess": [
    "Tersimpan ke Catatan.",
    "Saved to Notes.",
    "حُفظ في الملاحظات."
  ],
  "saveFailed": [
    "Jawaban belum tersimpan. Coba lagi.",
    "The answer was not saved. Please try again.",
    "لم يُحفظ الجواب. أعد المحاولة."
  ],
  "referenceCopied": ["Rujukan disalin.", "Reference copied.", "نُسخ المرجع."],
  "ibarahCopied": ["Ibarah disalin.", "Passage copied.", "نُسخت العبارة."],
  "noteContentCopied": [
    "Isi catatan disalin.",
    "Note copied.",
    "نُسخت الملاحظة."
  ],
  "bookmarkDeleted": ["Catatan dihapus.", "Note deleted.", "حُذفت الملاحظة."],
  "bookmarkDeleteFailed": [
    "Catatan belum bisa dihapus. Coba lagi.",
    "The note could not be deleted. Please try again.",
    "تعذر حذف الملاحظة. أعد المحاولة."
  ],
  "cacheClearedSuccess": [
    "Data sementara dibersihkan.",
    "Temporary data cleared.",
    "مُسحت البيانات المؤقتة."
  ],
  "searchSavedHint": [
    "Cari catatan atau ibarah…",
    "Search notes or passages…",
    "ابحث في الملاحظات أو العبارات…"
  ],
  "searchSavedTooltip": ["Cari catatan", "Search notes", "البحث في الملاحظات"],
  "noSavedTitle": ["Belum ada catatan", "No notes yet", "لا توجد ملاحظات بعد"],
  "noSavedDescription": [
    "Simpan jawaban atau ibarah penting di sini agar mudah dibaca kembali.",
    "Save useful answers or passages here to read again.",
    "احفظ الأجوبة والعبارات المفيدة هنا للرجوع إليها."
  ],
  "copyIbarahAction": ["Salin ibarah", "Copy passage", "نسخ العبارة"],
  "viewReferenceAction": ["Lihat rujukan", "View reference", "عرض المرجع"],
  "shareReferenceTooltip": ["Bagikan catatan", "Share note", "مشاركة الملاحظة"],
  "copyAnswerAction": ["Salin jawaban", "Copy answer", "نسخ الجواب"],
  "copyConversationAction": [
    "Salin percakapan",
    "Copy study notes",
    "نسخ ملاحظات المطالعة"
  ],
  "saveAnswerMenu": [
    "Simpan ke Catatan",
    "Save to Notes",
    "الحفظ في الملاحظات"
  ],
  "copyContentTooltip": ["Salin isi", "Copy content", "نسخ المحتوى"],
  "editNote": ["Edit catatan", "Edit note", "تحرير الملاحظة"],
  "deleteNote": ["Hapus catatan", "Delete note", "حذف الملاحظة"],
  "deleteNoteTitle": ["Hapus catatan", "Delete note", "حذف الملاحظة"],
  "deleteNoteDesc": [
    "Catatan ini akan dihapus permanen.",
    "This note will be permanently deleted.",
    "ستُحذف هذه الملاحظة نهائيًا."
  ],
  "addNote": ["Tambah catatan", "Add note", "إضافة ملاحظة"],
  "closeSearch": ["Tutup pencarian", "Close search", "إغلاق البحث"],
  "undo": ["Urungkan", "Undo", "تراجع"],
  "bookReferenceLabel": ["Rujukan kitab", "Book reference", "مرجع الكتاب"],
  "googleSessionConnectTitle": [
    "Masuk ke akun Google",
    "Sign in to Google",
    "تسجيل الدخول إلى Google"
  ],
  "googleSessionConnectSubtitle": [
    "Siapkan akun untuk AI Anda",
    "Prepare your account for textual study",
    "هيّئ حسابك لمطالعة النصوص"
  ],
  "googleSessionConnectDesc": [
    "Setelah masuk, Anda langsung kembali ke AI.",
    "After signing in, you will return to AI automatically.",
    "ستعود إلى الذكاء الاصطناعي تلقائيًا بعد تسجيل الدخول."
  ],
  "googleSessionSignInHint": [
    "Gunakan akun Google yang sama supaya tidak perlu masuk ulang.",
    "Use the same Google account to resume your study without signing in again.",
    "استخدم حساب Google نفسه لمتابعة المطالعة دون تسجيل الدخول مجددًا."
  ],
  "googleSessionSignInSameAccountDesc": [
    "Gunakan akun Google yang sama agar akses AI terbuka tanpa masuk ulang.",
    "Use the same Google account to open AI without signing in again.",
    "استخدم حساب Google نفسه لفتح الذكاء الاصطناعي دون تسجيل الدخول مجددًا."
  ],
  "googleSessionConnected": [
    "Akun Google terhubung",
    "Google account connected",
    "تم ربط حساب Google"
  ],
  "googleSessionPreparing": [
    "Menyiapkan sesi AI…",
    "Preparing your AI session…",
    "جارٍ تهيئة جلسة الذكاء الاصطناعي…"
  ],
  "cancelSignIn": [
    "Batalkan proses masuk",
    "Cancel sign-in",
    "إلغاء تسجيل الدخول"
  ],
  "cancelSignInTitle": [
    "Batalkan proses masuk",
    "Cancel sign-in",
    "إلغاء تسجيل الدخول"
  ],
  "cancelGoogleConnectionTitle": [
    "Tunda koneksi AI?",
    "Connect AI later?",
    "تأجيل الاتصال بالذكاء الاصطناعي؟"
  ],
  "cancelGoogleConnectionDesc": [
    "Anda tetap masuk ke OpenTurath. Sesi Google dan tab yang sudah terbuka tetap disimpan. Anda dapat melanjutkan koneksi AI nanti.",
    "You will remain signed in to OpenTurath. Your Google session and open tabs will be kept. You can connect AI later.",
    "ستبقى مسجّل الدخول إلى OpenTurath، مع الاحتفاظ بجلسة Google وعلامات التبويب المفتوحة. يمكنك متابعة الاتصال بالذكاء الاصطناعي لاحقًا."
  ],
  "cancelGoogleConnectionAction": [
    "Tunda dulu",
    "Connect later",
    "التأجيل الآن"
  ],
  "continueGoogleConnection": [
    "Lanjutkan masuk",
    "Continue sign-in",
    "متابعة تسجيل الدخول"
  ],
  "googleSessionUnverified": [
    "Sesi Google belum dapat diverifikasi. Coba lagi atau tekan Lanjutkan setelah akun yang sama selesai masuk. Sesi Anda tidak dihapus.",
    "Your Google session could not be verified yet. Retry or continue after signing in with the same account. Your session has not been cleared.",
    "تعذّر التحقق من جلسة Google حتى الآن. أعد المحاولة أو تابع بعد إتمام تسجيل الدخول بالحساب نفسه. لم تُحذف جلستك."
  ],
  "googleSessionUnverifiedTitle": [
    "Koneksi AI belum terverifikasi",
    "AI connection not verified yet",
    "لم يتم التحقق من اتصال الذكاء الاصطناعي بعد"
  ],
  "connectingGoogleAccount": [
    "Menghubungkan akun Google…",
    "Connecting your Google account…",
    "جارٍ ربط حساب Google…"
  ],
  "sessionReconnectTitle": [
    "Masuk kembali ke akun Anda",
    "Sign in to your account again",
    "سجّل الدخول إلى حسابك مجددًا"
  ],
  "sessionReconnectBody": [
    "Sesi aplikasi belum terhubung. Masuk kembali untuk membuka AI dan mengelola akun. Catatan tersimpan tetap tersedia setelah masuk.",
    "Your app session is disconnected. Sign in again to open AI and manage your account. Saved notes remain available after signing in.",
    "جلسة التطبيق غير متصلة. سجّل الدخول مجددًا لفتح الذكاء الاصطناعي وإدارة حسابك. تبقى ملاحظاتك المحفوظة متاحة بعد تسجيل الدخول."
  ],
  "sessionReconnectAction": [
    "Masuk kembali",
    "Sign in again",
    "تسجيل الدخول مجددًا"
  ],
  "authPreviousLoginPending": [
    "Proses masuk sebelumnya masih diselesaikan. Tunggu sebentar lalu coba lagi. Jika tetap muncul, tutup dan buka kembali aplikasi.",
    "A previous sign-in is still finishing. Wait a moment and try again. If this continues, close and reopen the app.",
    "لا تزال عملية تسجيل الدخول السابقة قيد الإكمال. انتظر قليلًا ثم حاول مجددًا. إذا استمرت المشكلة، أغلق التطبيق وافتحه من جديد."
  ],
  "chatHistoryClearFailed": [
    "Riwayat belum dapat dipastikan terhapus. Periksa kembali obrolan dan coba lagi setelah halaman siap.",
    "Could not confirm that the history was deleted. Check the conversation and try again when the page is ready.",
    "تعذّر التأكد من حذف السجل. راجع المحادثة وأعد المحاولة بعد اكتمال تحميل الصفحة."
  ],
  "paymentCheckUnavailable": [
    "Status pembayaran belum dapat diperiksa. Ini bukan berarti pembayaran gagal; coba lagi sebentar lagi.",
    "Payment status could not be checked. This does not mean your payment failed; try again shortly.",
    "تعذر التحقق من حالة الدفع. لا يعني هذا فشل الدفع؛ أعد المحاولة بعد قليل."
  ],
  "paymentPending": [
    "Pembayaran masih menunggu penyelesaian. Jika sudah membayar, periksa lagi sebentar lagi.",
    "Payment is still pending. If you have paid, check again shortly.",
    "الدفع قيد الانتظار. إن كنت قد دفعت فتحقق مجددًا بعد قليل."
  ],
  "paymentExpired": [
    "Batas waktu pembayaran habis. Tutup halaman ini untuk menyiapkan pembayaran baru.",
    "This payment has expired. Close this page to start a new checkout.",
    "انتهت مهلة الدفع. أغلق هذه الصفحة لإعداد دفعة جديدة."
  ],
  "paymentDenied": [
    "Pembayaran ditolak oleh penyedia pembayaran. Tutup halaman ini untuk mencoba kembali.",
    "The payment provider declined this payment. Close this page to try again.",
    "رفض مزود الدفع هذه الدفعة. أغلق هذه الصفحة للمحاولة مجددًا."
  ],
  "paymentCancelled": [
    "Pembayaran ini dibatalkan. Tutup halaman ini untuk menyiapkan pembayaran baru.",
    "This payment was cancelled. Close this page to start a new checkout.",
    "أُلغيت هذه الدفعة. أغلق هذه الصفحة لإعداد دفعة جديدة."
  ],
  "paymentRefunded": [
    "Pengembalian pembayaran tercatat. Hubungi bantuan bila membutuhkan penjelasan.",
    "A payment refund was recorded. Contact support if you need help.",
    "سُجّل رد المبلغ. تواصل مع الدعم إن احتجت إلى توضيح."
  ],
  "paymentPartialRefund": [
    "Sebagian pembayaran telah dikembalikan. Hubungi bantuan untuk rincian.",
    "Part of this payment has been refunded. Contact support for details.",
    "رُدّ جزء من هذا المبلغ. تواصل مع الدعم لمعرفة التفاصيل."
  ],
  "priceChangedReview": [
    "Harga penawaran diperbarui. Periksa harga yang tampil, lalu tekan tombol bayar lagi jika setuju.",
    "The offer price has been refreshed. Review the displayed price and press the payment button again if you agree.",
    "حُدّث سعر العرض. راجع السعر المعروض ثم اضغط زر الدفع مجددًا إن وافقت."
  ],
  "priceRefreshUnavailable": [
    "Harga terbaru belum dapat dimuat. Periksa koneksi lalu tekan tombol bayar untuk mencoba memuatnya kembali.",
    "The latest price could not be loaded. Check your connection, then press the payment button to try loading it again.",
    "تعذر تحميل السعر الأحدث. تحقق من الاتصال ثم اضغط زر الدفع لإعادة محاولة تحميله."
  ],
  "googleSessionFailed": [
    "Gagal menghubungkan akun Google.",
    "Unable to connect your Google account.",
    "تعذر ربط حساب Google."
  ],
  "googleSessionActive": [
    "Sesi Google aktif",
    "Google session active",
    "جلسة Google نشطة"
  ],
  "googleAccountMismatchTitle": [
    "Akun Google tidak cocok",
    "Google Account Mismatch",
    "حساب Google غير متطابق"
  ],
  "googleAccountMismatchApp": [
    "Di aplikasi, Anda masuk dengan akun:",
    "You signed into the app with:",
    "سجلت الدخول في التطبيق باستخدام:"
  ],
  "googleAccountMismatchBrowser": [
    "Di browser, Anda masuk dengan akun:",
    "However in browser you signed in with:",
    "لكنك في المتصفح سجلت الدخول باستخدام:"
  ],
  "googleAccountMismatchMustMatch": [
    "Masuk dengan akun Google yang sama agar AI bisa dibuka.",
    "Must sign in with the same Google account to access AIs.",
    "يجب تسجيل الدخول بنفس حساب Google لفتح الوصول إلى الذكاءات اصطناعية."
  ],
  "verifyingSessionTitle": [
    "Menyelaraskan sesi akun Google…",
    "Aligning Google Account Session...",
    "جارٍ مواءمة جلسة حساب Google..."
  ],
  "verifyingSessionSubtitle": [
    "Memastikan kesesuaian akun sebelum membuka sesi AI.",
    "Verifying account match before opening AI session.",
    "التحقق من تطابق الحساب قبل فتح جلسة الذكاء الاصطناعي."
  ],
  "stepTwoOfTwo": ["LANGKAH 2 DARI 2", "STEP 2 OF 2", "الخطوة ٢ من ٢"],
  "confirmGoogleAccountTitle": [
    "Konfirmasi akun Google",
    "Confirm Google Account",
    "تأكيد حساب Google"
  ],
  "confirmGoogleAccountDesc": [
    "Pastikan Anda telah masuk ke Google dengan akun:",
    "Make sure you have signed in to Google with:",
    "تأكد من تسجيل الدخول إلى Google باستخدام:"
  ],
  "sameAccountFallback": ["Akun yang sama", "Same account", "الحساب نفسه"],
  "pleaseSignInSameAccount": [
    "Masuk ke Google dengan akun yang sama.",
    "Please sign in to Google using the same account.",
    "يرجى تسجيل الدخول إلى Google باستخدام الحساب نفسه."
  ],
  "pleaseFinishGoogleLogin": [
    "Selesaikan dulu proses masuk Google.",
    "Please complete Google sign-in first.",
    "يرجى إكمال تسجيل الدخول إلى Google أولاً."
  ],
  "checkAgain": ["Periksa lagi", "Check Again", "تحقق مجددًا"],
  "yesAlreadySignedIn": [
    "Ya, sudah masuk",
    "Yes, Signed In",
    "نعم، تم تسجيل الدخول"
  ],
  "continueWithGoogle": [
    "Lanjutkan dengan Google",
    "Continue with Google",
    "المتابعة باستخدام Google"
  ],
  "googleSignInFailed": [
    "Gagal masuk dengan Google. Coba lagi.",
    "Google sign-in failed. Please try again.",
    "تعذر تسجيل الدخول باستخدام Google. أعد المحاولة."
  ],
  "desktopKeychainError": [
    "macOS menolak penyimpanan sesi di Keychain. Periksa akses Keychain login di Mac ini, lalu coba lagi.",
    "macOS denied access to Keychain when saving your session. Check access to this Mac’s login Keychain, then try again.",
    "رفض macOS حفظ الجلسة في سلسلة المفاتيح. تحقق من الوصول إلى سلسلة مفاتيح تسجيل الدخول على هذا الجهاز، ثم أعد المحاولة."
  ],
  "desktopListenerError": [
    "Proses masuk belum bisa disiapkan di komputer ini.",
    "Sign-in could not be set up on this computer.",
    "تعذر تجهيز تسجيل الدخول على هذا الجهاز."
  ],
  "desktopBrowserError": [
    "Browser belum bisa dibuka untuk masuk.",
    "Unable to open web browser for sign-in.",
    "تعذر فتح متصفح الويب لتسجيل الدخول."
  ],
  "desktopTimeoutError": [
    "Waktu masuk habis. Coba lagi.",
    "Sign-in timed out. Please try again.",
    "انتهت مهلة تسجيل الدخول. يُرجى المحاولة مجددًا."
  ],
  "termsAgreementPrefix": [
    "Dengan masuk, Anda menyetujui",
    "By signing in, you agree to",
    "بتسجيل الدخول، توافق على"
  ],
  "profile": ["Profil", "Profile", "الملف الشخصي"],
  "subscription": ["Langganan", "Subscription", "الاشتراك"],
  "activeSubscription": [
    "Langganan aktif",
    "Active subscription",
    "اشتراك فعّال"
  ],
  "inactiveSubscription": [
    "Pilih paket atau gunakan voucher untuk mulai berlangganan.",
    "Choose a plan or redeem a voucher to begin.",
    "اختر باقة أو استخدم قسيمة لبدء الاشتراك."
  ],
  "appearance": ["Tampilan", "Appearance", "المظهر"],
  "modeDark": ["Gelap", "Dark", "داكن"],
  "modeLight": ["Terang", "Light", "فاتح"],
  "modeSystem": ["Ikuti perangkat", "Follow device", "تلقائي"],
  "language": ["Bahasa", "Language", "اللغة"],
  "languageIndonesian": [
    "Bahasa Indonesia",
    "Bahasa Indonesia",
    "Bahasa Indonesia"
  ],
  "languageDialogNotice": [
    "Pilih bahasa antarmuka.",
    "Choose your interface language.",
    "اختر لغة الواجهة."
  ],
  "languageDialogCurrent": [
    "Indonesia · English · العربية",
    "Indonesia · English · العربية",
    "Indonesia · English · العربية"
  ],
  "logoutDialogTitle": ["Keluar dari akun", "Sign out", "تسجيل الخروج"],
  "logoutDialogBody": [
    "Anda perlu masuk kembali untuk menggunakan akun ini.",
    "You will need to sign in again to use this account.",
    "ستحتاج إلى تسجيل الدخول مجددًا لاستخدام هذا الحساب."
  ],
  "logoutButton": ["Keluar", "Sign out", "تسجيل الخروج"],
  "loggingOut": ["Sedang keluar…", "Signing out…", "جارٍ تسجيل الخروج…"],
  "deleteAccountTitle": ["Hapus akun", "Delete account", "حذف الحساب"],
  "deleteAccountBody": [
    "Akun OpenTurath akan dihapus dan akses akun berakhir. Data yang masih perlu disimpan untuk kewajiban hukum mengikuti Kebijakan Privasi. Simpan catatan penting sebelum melanjutkan.",
    "Your OpenTurath account will be deleted and account access will end. Data that must be retained for legal obligations is handled under the Privacy Policy. Save important notes before continuing.",
    "سيُحذف حساب أوبن تراث وينتهي الوصول إليه. وتخضع البيانات التي يلزم الاحتفاظ بها للالتزامات القانونية لسياسة الخصوصية. احفظ ملاحظاتك المهمة قبل المتابعة."
  ],
  "deleteAccountButton": ["Hapus akun", "Delete account", "حذف الحساب"],
  "deleteAccountCancel": ["Batal", "Cancel", "إلغاء"],
  "deleteAccountSuccess": ["Akun dihapus.", "Account deleted.", "حُذف الحساب."],
  "recentLoginRequired": [
    "Masuk kembali untuk melanjutkan penghapusan akun.",
    "Sign in again to continue deleting your account.",
    "سجّل الدخول مجددًا لمتابعة حذف الحساب."
  ],
  "networkError": [
    "Periksa koneksi internet, lalu coba lagi.",
    "Check your internet connection and try again.",
    "تحقق من اتصالك بالإنترنت وأعد المحاولة."
  ],
  "accountSection": ["Akun", "Account", "الحساب"],
  "generalSettingsSection": [
    "Pengaturan umum",
    "General settings",
    "الإعدادات العامة"
  ],
  "supportAndPolicySection": [
    "Bantuan & kebijakan",
    "Support & policies",
    "المساعدة والسياسات"
  ],
  "clearCache": [
    "Bersihkan data sementara",
    "Clear temporary data",
    "مسح البيانات المؤقتة"
  ],
  "clearCacheSubtitle": [
    "Hapus unduhan sementara dari perangkat",
    "Remove temporary downloads from this device",
    "إزالة التنزيلات المؤقتة من الجهاز"
  ],
  "clearCacheDialogTitle": [
    "Bersihkan data sementara",
    "Clear temporary data",
    "مسح البيانات المؤقتة"
  ],
  "clearCacheDialogDesc": [
    "Data unduhan dan cache sesi lokal akan dibersihkan. Anda tetap berada dalam akun.",
    "Downloaded and locally cached session data will be cleared. You will remain signed in.",
    "ستُمسح التنزيلات وبيانات الجلسات المؤقتة من الجهاز، وسيبقى حسابك مسجلًا."
  ],
  "clearAction": ["Bersihkan", "Clear", "مسح"],
  "chooseAppearance": ["Pilih tampilan", "Choose appearance", "اختيار المظهر"],
  "accessStatus": ["Status akses", "Access status", "حالة الوصول"],
  "fullAccess": ["Akses penuh", "Full access", "وصول كامل"],
  "planSyafii": ["Fikih Syafi'i", "Shafi‘i Fiqh", "الفقه الشافعي"],
  "planTahawwulat": ["Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"],
  "trialAccess": ["Akses uji coba", "Trial access", "وصول تجريبي"],
  "activeUntil": ["Aktif hingga", "Active until", "فعّال حتى"],
  "allAssistantsAvailable": [
    "Akses semua AI",
    "Access to all AIs",
    "جميع الذكاءات اصطناعية متاحون"
  ],
  "accessExpiringSoon": [
    "Masa akses hampir berakhir",
    "Access expires soon",
    "توشك مدة الوصول على الانتهاء"
  ],
  "readyToUse": ["Siap digunakan", "Ready to use", "جاهز للاستخدام"],
  "validUntil": ["Berlaku hingga", "Valid until", "صالح حتى"],
  "renewPro": ["Perpanjang akses", "Renew access", "تجديد الوصول"],
  "manageSubscription": [
    "Kelola langganan",
    "Manage subscription",
    "إدارة الاشتراك"
  ],
  "preparingProAccess": [
    "Menyiapkan akses",
    "Preparing access",
    "جارٍ تهيئة الوصول"
  ],
  "paymentBeingVerified": [
    "Pembayaran sedang diperiksa",
    "Payment is being verified",
    "جارٍ التحقق من الدفع"
  ],
  "viewPaymentStatus": [
    "Lihat status pembayaran",
    "View payment status",
    "عرض حالة الدفع"
  ],
  "accessNotYetActive": [
    "Akses belum aktif",
    "Access is not active yet",
    "لم يُفعّل الوصول بعد"
  ],
  "paymentNotSuccessful": [
    "Pembayaran belum berhasil",
    "Payment was unsuccessful",
    "لم تكتمل عملية الدفع"
  ],
  "tryPaymentAgain": [
    "Coba pembayaran lagi",
    "Try payment again",
    "إعادة محاولة الدفع"
  ],
  "chooseAssistantAndPlan": [
    "Pilih bidang dan masa akses untuk mulai bertanya.",
    "Choose a discipline and access period to begin your study.",
    "اختر مجالًا ومدة وصول لبدء المطالعة."
  ],
  "chooseProPlan": [
    "Pilih masa akses",
    "Choose access period",
    "اختيار مدة الوصول"
  ],
  "permanentAccessLabel": [
    "Tanpa batas waktu",
    "No expiry date",
    "دون تاريخ انتهاء"
  ],
  "manageAccess": ["Kelola akses", "Manage access", "إدارة الوصول"],
  "close": ["Tutup", "Close", "إغلاق"],
  "cancel": ["Batal", "Cancel", "إلغاء"],
  "exit": ["Keluar", "Exit", "خروج"],
  "reload": ["Muat ulang", "Reload", "إعادة التحميل"],
  "delete": ["Hapus", "Delete", "حذف"],
  "seeAll": ["Lihat semua", "View all", "عرض الكل"],
  "openAction": ["Buka", "Open", "فتح"],
  "stayHere": ["Tetap di sini", "Stay here", "البقاء هنا"],
  "readMore": ["Baca selengkapnya", "Read more", "قراءة المزيد"],
  "today": ["Hari ini", "Today", "اليوم"],
  "hijriCalendar": ["Kalender Hijriah", "Hijri calendar", "التقويم الهجري"],
  "paymentSuccessTitle": [
    "Pembayaran berhasil",
    "Payment successful",
    "تم الدفع بنجاح"
  ],
  "paymentSuccessRedirect": [
    "Akses sudah aktif. Membuka OpenTurath…",
    "Access is active. Opening OpenTurath…",
    "فُعّل الوصول. جارٍ فتح أوبن تراث…"
  ],
  "packagePerField": ["Satu bidang ilmu", "One discipline", "مجال واحد"],
  "packageAllFields": ["Semua bidang ilmu", "All disciplines", "جميع المجالات"],
  "packageAllFieldsPreparing": [
    "Paket semua bidang sedang disiapkan.",
    "The all-disciplines plan is being prepared.",
    "اشتراك جميع المجالات قيد الإعداد."
  ],
  "chooseFieldPlan": ["Pilih bidang", "Choose a discipline", "اختيار المجال"],
  "accessAllFields": [
    "Akses semua bidang",
    "Access all disciplines",
    "الوصول إلى جميع المجالات"
  ],
  "accessSingleField": [
    "Akses satu bidang",
    "Access one discipline",
    "الوصول إلى مجال واحد"
  ],
  "notSubscribed": [
    "Belum ada akses aktif",
    "No active access",
    "لا يوجد وصول فعّال"
  ],
  "termsOfService": ["Ketentuan Layanan", "Terms of Service", "شروط الخدمة"],
  "privacyPolicy": ["Kebijakan Privasi", "Privacy Policy", "سياسة الخصوصية"],
  "paymentAndRefund": [
    "Pembayaran dan pengembalian dana",
    "Payment & Refunds",
    "الدفع والاسترداد"
  ],
  "aiGuideline": [
    "Panduan penggunaan AI dan rujukan",
    "AI Use & Reference Verification",
    "استخدام الذكاء الاصطناعي والتحقق من المراجع"
  ],
  "supportAndContact": [
    "Bantuan dan Kontak",
    "Support & Contact",
    "المساعدة والتواصل"
  ],
  "manualRenewalNotice": [
    "Langganan tidak diperpanjang otomatis. Perpanjang sendiri saat masa akses berakhir.",
    "Subscriptions do not renew automatically. You may renew when your access period ends.",
    "لا تتجدد الاشتراكات تلقائيًا. يمكنك التجديد عند انتهاء مدة الوصول."
  ],
  "splashTitle": [
    "Membaca kitab, menelusuri ibarah.",
    "Returning to the Sources. Tracing the Sacred Texts.",
    "الرجوع إلى الأصول، واستنطاق العبارات."
  ],
  "splashBody": [
    "Telusuri kitab para ulama dengan bantuan AI, lengkap dengan rujukannya.",
    "Classical Islamic scholarship anchored in authentic transmission, shielded by the jurisprudence of crisis, navigated with reverence and modern precision.",
    "تراث العلماء الأعلام، محروسًا بفقه التحولات، ومطالعًا بأدب العلم وأحدث أدوات العصر."
  ],
  "preparingModule": [
    "{0} sedang disiapkan.",
    "{0} is being prepared.",
    "{0} قيد الإعداد."
  ],
  "subscriptionRequiredFor": [
    "Berlangganan untuk membuka {0}.",
    "Subscribe to access {0}.",
    "اشترك للوصول إلى {0}."
  ],
  "accessUnavailableFor": [
    "Akses ke {0} belum aktif. Pilih paket atau gunakan voucher untuk melanjutkan.",
    "Access to {0} is inactive. Choose a plan or redeem a code to continue.",
    "لم يُفعّل الوصول إلى {0}. اختر اشتراكًا أو استخدم رمز وصول للمتابعة."
  ],
  "trialDaysLeft": [
    "Masa coba · {0} hari",
    "Trial access · {0} days",
    "وصول تجريبي · {0} يومًا"
  ],
  "assistantsAvailableCount": ["{0} AI", "{0} AIs", "المساعدون المتاحون: {0}"],
  "savedNotesCount": [
    "{0} catatan tersimpan",
    "{0} saved notes",
    "الملاحظات المحفوظة: {0}"
  ],
  "versionWithTagline": [
    "Versi {0} · {1}",
    "Version {0} · {1}",
    "الإصدار {0} · {1}"
  ],
  "ahlanWithName": ["Halo, {0}", "Welcome, {0}", "أهلًا، {0}"],
  "splashTagline": [
    "Menjaga warisan, membuka cakrawala.",
    "Rooted in heritage. Open to new horizons.",
    "ذكاء اصطناعي إسلامي قائم على التراث"
  ],
  "moduleClose": ["Tutup", "Close", "إغلاق"],
  "modulePrev": ["Sebelumnya", "Previous", "السابق"],
  "moduleNext": ["Berikutnya", "Next", "التالي"],
  "moduleStartHere": ["Mulai dari sini", "Start here", "ابدأ من هنا"],
  "moduleExample": ["Contoh pertanyaan", "Sample question", "سؤال توضيحي"],
  "moduleWatchVideo": [
    "Tonton video pengantar",
    "Watch the introduction video",
    "شاهد الفيديو التمهيدي"
  ],
  "moduleLoadFailed": [
    "Belum dapat memuat modul.",
    "The module could not be loaded.",
    "تعذّر تحميل الوحدة."
  ],
  "logoutSub": [
    "Anda bisa masuk kembali kapan saja",
    "You can sign back in at any time",
    "يمكنك الدخول مجددًا في أي وقت"
  ],
  "logoPhilosophyRow": [
    "Filosofi lambang",
    "Meaning of the mark",
    "فلسفة الشعار"
  ],
  "logoPhilosophyRowSub": [
    "Tiga ruang di bawah satu lengkung",
    "Three spaces under one arch",
    "ثلاثة فراغات تحت قوس واحد"
  ],
  "logoPhilosophyLead": [
    "Dalam hadis Jibril, Nabi menjawab empat pertanyaan. Tiga yang pertama adalah ilmu yang tetap. Yang keempat membahas yang berubah dan menjaga ketiganya. Itulah yang tergambar pada lambang OpenTurath.",
    "In the hadith of Jibril, the Prophet answered four questions. The first three are the constant sciences. The fourth deals with what changes and guards the other three. That is what the OpenTurath mark draws.",
    "في حديث جبريل أجاب النبي عن أربعة أسئلة. الثلاثة الأولى علوم الثوابت، والرابع يبحث في المتغيرات ويحفظ الثلاثة. وذلك ما يرسمه شعار OpenTurath."
  ],
  "logoPart1": ["Islam · Fikih", "Islam · Fiqh", "الإسلام · الفقه"],
  "logoPart1Sub": ["Rukun yang tetap", "A constant pillar", "من الثوابت"],
  "logoPart2": ["Iman · Akidah", "Iman · Creed", "الإيمان · العقيدة"],
  "logoPart2Sub": ["Rukun yang tetap", "A constant pillar", "من الثوابت"],
  "logoPart3": ["Ihsan · Tasawuf", "Ihsan · Tasawwuf", "الإحسان · التصوف"],
  "logoPart3Sub": ["Rukun yang tetap", "A constant pillar", "من الثوابت"],
  "logoPart4": [
    "Lengkung · Fikih Tahawwulat",
    "The arch · Fiqh al-Tahawwulat",
    "القوس · فقه التحولات"
  ],
  "logoPart4Sub": [
    "Membahas yang berubah dan menjaga tiga rukun di bawahnya",
    "Studies what changes and guards the three pillars beneath it",
    "يبحث في المتغيرات ويحفظ الأركان الثلاثة تحته"
  ],
  "brandPhilosophyTitle": [
    "Lambang OpenTurath",
    "The OpenTurath mark",
    "شعار OpenTurath"
  ],
  "brandPhilosophy": [
    "Tiga ruang di dalam lambang mewakili Islam, Iman, dan Ihsan. Lengkung di luarnya mewakili Fikih Tahawwulat, ilmu yang menjaga ketiganya. Bentuknya juga terbaca sebagai kitab yang terbuka.",
    "The three spaces inside the mark stand for Islam, Iman, and Ihsan. The arch around them stands for Fiqh al-Tahawwulat, the knowledge that guards all three. The shape also reads as an open book.",
    "تمثل الفراغات الثلاثة داخل الشعار الإسلام والإيمان والإحسان، ويمثل القوس المحيط بها فقه التحولات الذي يحفظها جميعًا، كما يبدو الشعار كتابًا مفتوحًا."
  ],
  "launchOffer": ["Harga perdana", "Launch offer", "عرض الافتتاح"],
  "saving": ["Hemat {0}%", "Save {0}%", "توفير {0}٪"],
  "normalPrice": ["Harga normal {0}", "Regular price {0}", "السعر المعتاد {0}"],
  "bestValue": ["Pilihan Terbaik", "Best value", "الخيار الأوفر"],
  "oneMonth": ["1 Bulan", "1 Month", "شهر واحد"],
  "sixMonths": ["6 Bulan", "6 Months", "ستة أشهر"],
  "oneYear": ["12 Bulan", "12 Months", "سنة كاملة"],
  "perMonth": ["/bulan", "/month", "/شهر"],
  "perSixMonths": ["/6 bulan", "/6 months", "/ستة أشهر"],
  "perYear": ["/tahun", "/year", "/سنة"],
  "tahawwulatHonor": ["Rukun Keempat", "The Fourth Pillar", "الركن الرابع"],
  "tahawwulatBenefit": [
    "Pelajari naskah dan tanda-tanda zaman dalam karya Al-Habib Abu Bakar Al-Adni Al-Masyhur.",
    "Study texts, transmitted accounts of the signs of the times, and the works of al-Habib Abu Bakr al-Adni al-Mashhur.",
    "مطالعة النصوص وأسانيد مباحث علامات الزمان ومؤلفات الحبيب أبي بكر العدني المشهور."
  ],
  "tahawwulatWelcome": [
    "Tanya jawab seputar karya Al-Habib Abu Bakar Al-Adni Al-Masyhur. Bacalah ibarah bersama rujukannya dan diskusikan dengan guru.",
    "A study room for the works of al-Habib Abu Bakr al-Adni al-Mashhur. Read each passage alongside its source and discuss your findings with a teacher.",
    "مطالعة مؤلفات الحبيب أبي بكر العدني المشهور مع الذكاء الاصطناعي. اقرأ العبارة مع مرجعها واعرض ثمرة المطالعة على معلمك."
  ],
  "specialistAccess": [
    "Akses 1 Bidang AI",
    "Single Field AI Access",
    "الوصول إلى ذكاء اصطناعي لمجال واحد"
  ],
  "discipline": ["Bidang ilmu", "Field of study", "المجال العلمي"],
  "scholarLibrary": ["Khazanah ulama", "خزانة العلماء", "خزانة العلماء"],
  "scholarPreparing": ["Segera hadir", "Coming soon", "قريبًا"],
  "scholarPreparingBody": [
    "Bagian ini sedang disiapkan.",
    "This section is being prepared",
    "هذا القسم قيد الإعداد"
  ],
  "digitalStudentCard": [
    "Kartu santri digital",
    "Digital Scholar Card",
    "بطاقة طالب العلم الرقمية"
  ],
  "activeResearcher": ["Pengguna aktif", "Active Researcher", "باحث فعّال"],
  "studentOfTurath": [
    "Penuntut ilmu",
    "Student of the Classics",
    "طالب التراث"
  ],
  "expirySoonest": [
    "Masa akses terdekat berakhir",
    "Next access expiry",
    "أقرب انتهاء للوصول"
  ],
  "hijriEstimate": [
    "Hijriah perkiraan",
    "Estimated Hijri date",
    "تاريخ هجري تقريبي"
  ],
  "daysRemaining": [
    "Sisa {0} hari",
    "{0} days remaining",
    "الأيام المتبقية: {0}"
  ],
  "back": ["Kembali", "Back", "رجوع"],
  "save": ["Simpan", "Save", "حفظ"],
  "bookCatalog": ["Katalog kitab", "Book catalog", "فهرس الكتب"],
  "catalogIntro": [
    "Telusuri naskah dan keterangan edisi dalam koleksi ini.",
    "Explore the texts and edition records in this collection.",
    "تصفح النصوص وبيانات الطبعات في هذه المجموعة."
  ],
  "openCatalog": [
    "Telusuri koleksi kitab",
    "Browse the collection",
    "تصفح مجموعة الكتب"
  ],
  "catalogError": [
    "Koleksi belum dapat dibuka. Coba lagi.",
    "The collection could not be opened. Please try again.",
    "تعذر فتح المجموعة. أعد المحاولة."
  ],
  "collection": ["Koleksi Kitab", "Book Collection", "مجموعة الكتب"],
  "searchBooks": [
    "Cari judul kitab, pengarang, atau bidang…",
    "Search titles, authors, or disciplines…",
    "ابحث عن عنوان أو مؤلف أو مجال…"
  ],
  "allBooks": ["Semua kitab", "All books", "جميع الكتب"],
  "matan": ["Matan", "Foundational Texts", "المتون"],
  "sharh": ["Syarah", "Authoritative Commentaries", "الشروح"],
  "hashiyah": ["Hasyiyah", "Hashiyah (glosses)", "الحواشي"],
  "unclassified": [
    "Belum diklasifikasikan",
    "Not yet classified",
    "غير مصنف بعد"
  ],
  "classificationNotice": [
    "Jenis naskah mengikuti keterangan katalog. Entri yang belum memiliki keterangan tetap ditampilkan tanpa dugaan.",
    "Text types follow catalog metadata. Unclassified entries remain visible without inferred labels.",
    "تتبع أنواع النصوص بيانات الفهرس. وتظل المواد غير المصنفة ظاهرة دون تصنيف تخميني."
  ],
  "authorBiography": ["Tarjamah al-Mu'allif", "Author Record", "ترجمة المؤلف"],
  "editionRecord": [
    "Data edisi dan tahqiq",
    "Edition & Textual Editing",
    "بيانات الطبعة والتحقيق"
  ],
  "verificationNotice": [
    "Keterangan edisi mengikuti data katalog. Nama muhaqqiq yang tercatat bukan penetapan bahwa naskah telah diperiksa oleh OpenTurath.",
    "Edition details follow the catalog. A recorded editor does not establish that OpenTurath has verified the text.",
    "تتبع بيانات الطبعة الفهرس. وذكر المحقق لا يعني أن أوبن تراث قد راجع النص."
  ],
  "unknownMetadata": ["Belum tercatat", "Not recorded", "غير مسجل"],
  "phone": ["Nomor WhatsApp", "WhatsApp number", "رقم واتساب"],
  "phoneHint": [
    "Contoh: 081234567890",
    "Example: +6281234567890",
    "مثال: ‎+6281234567890"
  ],
  "phoneNotice": [
    "Nomor aktif untuk konfirmasi pembayaran.",
    "An active number for payment confirmation.",
    "رقم فعّال لتأكيد الدفع."
  ],
  "phoneInvalid": [
    "Masukkan nomor telepon yang valid.",
    "Enter a valid phone number.",
    "أدخل رقم هاتف صحيحًا."
  ],
  "continuePayment": [
    "Lanjutkan pembayaran",
    "Continue to payment",
    "المتابعة إلى الدفع"
  ],
  "signInRequired": [
    "Masuk dulu sebelum berlangganan.",
    "Please sign in before subscribing.",
    "يرجى تسجيل الدخول قبل الاشتراك."
  ],
  "checkoutError": [
    "Pembayaran belum dapat disiapkan. Coba lagi.",
    "Payment could not be prepared. Please try again.",
    "تعذر إعداد الدفع. أعد المحاولة."
  ],
  "priceChanged": [
    "Harga paket ini baru saja berubah, jadi pembayaran belum dibuka. Muat ulang halaman lalu coba lagi.",
    "This plan's price has just changed, so checkout was not opened. Reload the page and try again.",
    "تغيّر سعر هذه الباقة للتو فلم يُفتح الدفع. أعد تحميل الصفحة وحاول مجددًا."
  ],
  "paymentConfirmed": [
    "Pembayaran berhasil. Akses sudah aktif.",
    "Payment successful. Your access is active.",
    "تم الدفع بنجاح. وصولك فعّال الآن."
  ],
  "choosePlan": [
    "Pilih masa akses",
    "Choose access period",
    "اختيار مدة الوصول"
  ],
  "syncPurchases": [
    "Pulihkan pembelian",
    "Restore purchases",
    "استعادة المشتريات"
  ],
  "syncDone": [
    "Data pembelian telah diperbarui.",
    "Purchase records have been refreshed.",
    "حُدثت بيانات المشتريات."
  ],
  "redeemAccess": [
    "Gunakan voucher",
    "Redeem access code",
    "استبدال رمز الوصول"
  ],
  "paymentReview": ["Ringkasan pembayaran", "Payment summary", "ملخص الدفع"],
  "featuredReferences": [
    "Rujukan pilihan",
    "Selected references",
    "مراجع مختارة"
  ],
  "ui_0fb589d0e6": [
    "Tautan belum bisa dibuka.",
    "The page could not be opened.",
    "تعذر فتح الصفحة."
  ],
  "ui_0ae09a2807": [
    "Cari judul kitab, pengarang, muhaqqiq, atau bidang…",
    "Search titles, authors, editors, or disciplines…",
    "ابحث عن عنوان أو مؤلف أو محقق أو مجال…"
  ],
  "ui_318276fc51": ["Semua Kitab", "All books", "جميع الكتب"],
  "ui_e2395c685d": ["Satu jilid", "Single volume", "جزء واحد"],
  "ui_a91f06ad05": ["Beberapa jilid", "Multiple volumes", "عدة أجزاء"],
  "ui_54db73b3af": [
    "Tidak ditemukan kitab yang sesuai",
    "No matching books found",
    "لم يُعثر على كتب مطابقة"
  ],
  "ui_f7c779cb7d": [
    "Coba cari dengan kata kunci judul atau nama pengarang lain",
    "Try another title or author",
    "جرّب عنوانًا أو اسم مؤلف آخر"
  ],
  "ui_225b7ddde1": [
    "Kitab rujukan disimpan ke Catatan",
    "Book reference saved to Notes",
    "حُفظ مرجع الكتاب في الملاحظات"
  ],
  "ui_e150b5de89": [
    "Rujukan disalin.",
    "Book citation copied",
    "نُسخ توثيق الكتاب"
  ],
  "ui_8529af5e96": ["Salin rujukan", "Copy citation", "نسخ التوثيق"],
  "ui_f8f8446f44": [
    "METADATA NASKAH RUJUKAN",
    "REFERENCE RECORD",
    "بيانات المرجع"
  ],
  "ui_ad39f1c3af": ["Muhaqqiq", "Editor", "المحقق أو المعتني"],
  "ui_dc4df1ba5f": ["Penerbit Naskah", "Publisher", "الناشر"],
  "ui_d28e8d3153": ["Tahun / Cetakan", "Year / Edition", "السنة والطبعة"],
  "ui_7e06fac12c": ["Jumlah Jilid", "Volumes", "عدد الأجزاء"],
  "ui_02c2d79961": ["Jumlah Halaman", "Pages", "عدد الصفحات"],
  "ui_119fdd76dd": ["Koleksi sumber", "Source collection", "مجموعة المصادر"],
  "ui_3f42b695cf": ["Salin rujukan", "Copy citation", "نسخ التوثيق الكامل"],
  "ui_55fddd168e": [
    "Cari AI atau ulama…",
    "Search study guides…",
    "ابحث عن خادم التراث…"
  ],
  "ui_3e2acc1d99": [
    "Katalog rujukan belum dapat dimuat saat ini.",
    "The reference catalog could not be loaded.",
    "تعذر تحميل فهرس المراجع حاليًا."
  ],
  "ui_0c9f252156": ["Detail edisi", "Edition record", "بيانات الطبعة"],
  "ui_872fd06ff7": ["Tahun Wafat", "Year of death", "سنة الوفاة"],
  "ui_47b35543e3": ["Jenis kitab", "Text type", "نوع النص"],
  "ui_85e181b57a": ["Periode", "Period", "العصر"],
  "ui_291c152262": ["Penerbit", "Publisher", "الناشر"],
  "ui_e488d9f73e": ["Tahqiq / Editor", "Textual editor", "المحقق أو المعتني"],
  "ui_88bddfe74a": ["ID edisi", "Edition ID", "معرّف الطبعة"],
  "ui_9f0b5b5d87": ["Pustaka Rujukan", "Reference Library", "مكتبة المراجع"],
  "ui_c8c23c3325": [
    "Cari judul kitab atau pengarang…",
    "Search titles or authors…",
    "ابحث عن عنوان أو مؤلف…"
  ],
  "ui_6b42d45847": [
    "Tidak ada kitab yang cocok dengan pencarian",
    "No books match this search",
    "لا توجد كتب مطابقة للبحث"
  ],
  "ui_6a2b35b4ca": ["Rincian akses", "Access details", "تفاصيل الوصول"],
  "ui_b92aed18d1": [
    "Akses yang aktif di akun ini.",
    "Active access on this account.",
    "الوصول الفعّال في هذا الحساب."
  ],
  "ui_b236ca6182": ["Semua AI", "All AIs", "جميع الذكاءات اصطناعية"],
  "ui_f2dfc4506e": ["AI", "Study guide", "خادم المطالعة"],
  "ui_c720f7612f": ["Pengguna", "Reader", "القارئ"],
  "ui_26894b3c65": [
    "Ganti ke tema terang",
    "Switch to light appearance",
    "التبديل إلى المظهر الفاتح"
  ],
  "ui_b16e7fe4e5": [
    "Ganti ke tema gelap",
    "Switch to dark appearance",
    "التبديل إلى المظهر الداكن"
  ],
  "ui_42c76592cd": ["Semua", "All", "الكل"],
  "ui_cfebd8cd1d": ["Kitab", "Books", "الكتب"],
  "ui_936a67f609": ["Hadis", "Hadith", "الحديث"],
  "ui_ac6c67f15f": ["Tafsir", "Qur’anic Exegesis", "التفسير"],
  "ui_401ffb3f2d": ["Fikih", "Fiqh", "الفقه"],
  "ui_2746f1c40e": ["Akidah", "Creed", "العقيدة"],
  "ui_cc60e0b5c5": ["Usul Fikih", "Principles of Jurisprudence", "أصول الفقه"],
  "ui_4f8ef2bc2a": ["Bahasa Arab", "Arabic Language", "اللغة العربية"],
  "ui_aac8eb7439": ["Baru saja", "Just now", "الآن"],
  "ui_67f956b4e0": ["Kemarin", "Yesterday", "أمس"],
  "ui_b601dbcd35": [
    "belum diidentifikasi",
    "not yet identified",
    "لم يُحدد بعد"
  ],
  "ui_5301648dcf": ["Edit", "Edit", "تحرير"],
  "ui_96556d16a8": ["Salin rujukan", "Copy reference", "نسخ المرجع"],
  "ui_25935f7ea7": ["Salin catatan", "Copy note", "نسخ الملاحظة"],
  "ui_0b05afdbfa": ["Lihat kitab", "View book", "عرض الكتاب"],
  "ui_bfbf5d1c00": [
    "Baca panduan rujukan selengkapnya",
    "Read the reference guide",
    "قراءة دليل المراجع"
  ],
  "ui_c6b269deaf": [
    "Sesuaikan ukuran huruf percakapan agar nyaman dibaca.",
    "Adjust the conversation text size for comfortable reading.",
    "اضبط حجم خط المحادثة لقراءة مريحة."
  ],
  "ui_9d04d267b4": ["Kecil (85%)", "Small (85%)", "صغير (85٪)"],
  "ui_b52b4d4d4e": ["Standar (100%)", "Standard (100%)", "عادي (100٪)"],
  "ui_5eac981a5e": ["Sedang (120%)", "Medium (120%)", "متوسط (120٪)"],
  "ui_e2824091ed": ["Besar (140%)", "Large (140%)", "كبير (140٪)"],
  "ui_49c3b2fbd2": [
    "Sangat besar (165%)",
    "Very large (165%)",
    "كبير جدًا (165٪)"
  ],
  "ui_a9dc11525b": ["Maksimal (200%)", "Largest (200%)", "الأكبر (200٪)"],
  "ui_fb007d4dc4": [
    "LANJUTKAN PERCAKAPAN",
    "CONTINUE YOUR CHAT",
    "متابعة المطالعة"
  ],
  "ui_76122c20a6": ["TENTANG OPENTURATH", "ABOUT OPENTURATH", "عن أوبن تراث"],
  "ui_b7d2c1dc2f": [
    "Mengenal OpenTurath",
    "Introducing OpenTurath",
    "التعريف بأوبن تراث"
  ],
  "ui_755dcc41d8": [
    "Membaca ibarah dan menelusuri rujukan langsung dari kitab.",
    "Read passages and trace their sources in the books.",
    "اقرأ العبارات وتتبع مراجعها في الكتب."
  ],
  "ui_d2765b003d": ["ADAB BELAJAR", "ETIQUETTE OF LEARNING", "آداب التعلم"],
  "ui_47963d644e": [
    "Tetap belajar bersama guru",
    "Continue Learning with a Teacher",
    "مواصلة التعلم مع المعلم"
  ],
  "ui_cff414308e": [
    "Bimbingan guru yang bersanad tetap diperlukan.",
    "Learn with teachers and scholars who hold a chain of transmission.",
    "تعلم بإرشاد المعلمين والعلماء المتصلين بأسانيد العلم."
  ],
  "ui_c70f1ad336": ["PERIKSA SUMBER", "VERIFY THE SOURCE", "مراجعة المصدر"],
  "ui_4ea99e4281": [
    "Cocokkan dengan kitab asal",
    "Compare with the Original Work",
    "المقابلة بالكتاب الأصلي"
  ],
  "ui_569c7ee460": [
    "Periksa kembali kutipan di Maktabah Syamilah atau kitab cetak.",
    "Check the quotation in al-Maktabah al-Shamilah or the printed edition.",
    "راجع النقل في المكتبة الشاملة أو الطبعة الورقية."
  ],
  "ui_b32d1c0f8c": [
    "Baca ibarah beserta konteksnya pada kitab cetak yang dirujuk sebelum menarik kesimpulan atau membagikan hasilnya.",
    "Read the passage in its context in the cited edition before drawing conclusions or sharing your findings.",
    "اقرأ العبارة في سياقها في الطبعة المحال إليها قبل الاستنتاج أو نشر نتائج المطالعة."
  ],
  "ui_2705ede796": ["AMANAH ILMIAH", "CITE YOUR SOURCES", "الأمانة العلمية"],
  "ui_09ea45b2e2": [
    "Cantumkan rujukan saat mengutip",
    "Cite Your Sources",
    "توثيق النقول"
  ],
  "ui_15cf04ae7e": [
    "Sertakan nama pengarang, judul kitab, bab, jilid, dan halaman.",
    "Include the author, title, chapter, volume, and page.",
    "اذكر المؤلف وعنوان الكتاب والباب والجزء والصفحة."
  ],
  "ui_14cfe21026": [
    "Saat mengutip, tuliskan nama pengarang, judul kitab, bab, jilid, dan halaman sesuai sumber yang digunakan agar rujukan mudah ditemukan.",
    "When quoting, record the author, title, chapter, volume, and page of the edition used so the passage can be found.",
    "عند النقل، دوّن المؤلف والعنوان والباب والجزء والصفحة بحسب الطبعة المستخدمة ليسهل الرجوع إلى النص."
  ],
  "ui_413f80555b": ["TELUSURI RUJUKAN", "TRACE REFERENCES", "تتبع المراجع"],
  "ui_b33d5c77a0": [
    "Lihat asal kutipan",
    "Find the Source Passage",
    "الرجوع إلى أصل النقل"
  ],
  "ui_4cdd20079a": [
    "Gunakan informasi kitab, jilid, dan halaman untuk memeriksa naskah.",
    "Use the title, volume, and page to check the text.",
    "استعن بعنوان الكتاب والجزء والصفحة لمراجعة النص."
  ],
  "ui_8f934ac8b3": [
    "Buka rujukan yang tersedia untuk menelusuri asal kutipan. Cocokkan teks, jilid, dan halaman dengan edisi kitab yang Anda gunakan.",
    "Open the reference to trace the quotation. Check its text, volume, and page against the edition you use.",
    "افتح المرجع لتتبع أصل النقل. وقابل النص والجزء والصفحة بالطبعة التي تعتمدها."
  ],
  "ui_5d17f9bd8a": ["Mutaqaddimin", "Early Scholars", "المتقدمون"],
  "ui_81fd968c9b": ["Ashab Al-Wujuh", "Ashab al-Wujuh", "أصحاب الوجوه"],
  "ui_923915fb65": ["Muta'akhkhirin", "Later Scholars", "المتأخرون"],
  "ui_a5205d829d": ["Asal Mazhab", "Foundational School Text", "أصل المذهب"],
  "ui_c8764945d0": ["Matan", "Base Text", "متن"],
  "ui_eee6a2e022": ["Syarah", "Commentary", "شرح"],
  "ui_081b825dd6": ["Hasyiyah", "Marginal Commentary", "حاشية"],
  "ui_3ba0e78ec2": [
    "Salaf (≤ 300 H)",
    "Early Generations (≤ 300 AH)",
    "السلف (حتى 300 هـ)"
  ],
  "ui_bd01f56649": [
    "Mutaqaddimin (301-600 H)",
    "Early Scholars (301–600 AH)",
    "المتقدمون (301–600 هـ)"
  ],
  "ui_8533bf8340": [
    "Muta'akhkhirin (601-1100 H)",
    "Later Scholars (601–1100 AH)",
    "المتأخرون (601–1100 هـ)"
  ],
  "ui_67af369dfd": [
    "Mu'ashir (> 1100 H)",
    "Recent Scholars (> 1100 AH)",
    "المعاصرون (بعد 1100 هـ)"
  ],
  "ui_f118d07faa": [
    "Kitab Mazhab Syafi'i",
    "Shafi'i school books",
    "كتب المذهب الشافعي"
  ],
  "ui_ae4f9663d7": ["Hapus filter", "Clear filters", "مسح المرشحات"],
  "ui_214d016291": [
    "Cari kitab, pengarang, atau muhaqqiq…",
    "Search books, authors, or editors…",
    "ابحث عن كتاب أو مؤلف أو محقق…"
  ],
  "ui_c0c96d1d9a": ["Filter aktif", "Active filters", "المرشحات المفعّلة"],
  "ui_d7decf1aa2": ["Filter", "Filter", "تصفية"],
  "ui_ac03e7c93b": ["Saring koleksi", "Filter collection", "تصفية المجموعة"],
  "ui_8b71077ed7": ["Bidang", "Discipline", "المجال"],
  "ui_f37a89cbd1": ["Era", "Period", "العصر"],
  "ui_a74cf8b9bd": [
    "Hapus semua filter",
    "Clear all filters",
    "مسح جميع المرشحات"
  ],
  "ui_6e02202968": ["Semua Bagian", "All sections", "جميع الأقسام"],
  "ui_3236d63ff7": ["Semua Era", "All periods", "جميع العصور"],
  "ui_022c202d54": [
    "Belum ada kitab yang cocok",
    "No matching books",
    "لا توجد كتب مطابقة"
  ],
  "ui_6e35db0b1e": [
    "Coba gunakan kata kunci lain, nama pengarang, atau muhaqqiq.",
    "Try another keyword, author, or editor.",
    "جرّب عبارة أخرى أو اسم مؤلف أو محقق."
  ],
  "ui_72250267ce": [
    "Kitab rujukan Mazhab Syafi'i",
    "Shafi‘i Reference Works",
    "مراجع المذهب الشافعي"
  ],
  "ui_5ed90ac17a": [
    "Cari judul, pengarang, penerbit, atau tahqiq…",
    "Search titles, authors, publishers, or editors…",
    "ابحث عن عنوان أو مؤلف أو ناشر أو محقق…"
  ],
  "ui_531856ca5c": [
    "Katalog naskah sedang disiapkan.",
    "The manuscript catalog is being prepared.",
    "فهرس النصوص قيد الإعداد."
  ],
  "ui_84d7c6b7ae": ["Keterangan kitab", "Book details", "بيانات الكتاب"],
  "ui_edf572027a": ["Bidang ilmu", "Disciplines", "مجالات العلم"],
  "ui_3a9ab0a6cd": ["Khazanah ulama", "Scholars’ Collection", "خزانة العلماء"],
  "ui_816f17cafd": ["Koneksi terputus", "Connection lost", "انقطع الاتصال"],
  "ui_e124a4b2f9": [
    "Data belum bisa dimuat. Periksa koneksi internet, lalu coba lagi.",
    "Unable to load data. Check your connection and try again.",
    "تعذر تحميل البيانات. تحقق من اتصالك وأعد المحاولة."
  ],
  "ui_644767241f": [
    "Data rujukan belum bisa dimuat. Periksa koneksi internet, lalu coba lagi.",
    "Unable to load references. Check your connection and try again.",
    "تعذر تحميل المراجع. تحقق من اتصالك وأعد المحاولة."
  ],
  "ui_b442950d9e": [
    "Langganan diperlukan",
    "Subscription required",
    "يلزم الاشتراك"
  ],
  "ui_806605b861": [
    "Sesi Anda telah berakhir atau akses ke AI ini belum aktif.",
    "Your session has ended or access to this guide is inactive.",
    "انتهت الجلسة أو لم يُفعّل الوصول إلى هذا الخادم."
  ],
  "ui_23cd63ee3f": ["Lihat langganan", "View subscription", "عرض الاشتراك"],
  "ui_8b45fa81f6": [
    "Rujukan tidak ditemukan",
    "Reference not found",
    "لم يُعثر على المرجع"
  ],
  "ui_22ec2ee167": [
    "Tidak ada kitab atau catatan yang sesuai dengan kata kunci atau saringan.",
    "No books or notes match the search or filters.",
    "لا توجد كتب أو ملاحظات توافق البحث أو المرشحات."
  ],
  "ui_daba3fc380": ["Atur ulang pencarian", "Reset search", "إعادة ضبط البحث"],
  "ui_a3fc8f2907": [
    "Ada gangguan teknis",
    "Something went wrong",
    "حدث خلل تقني"
  ],
  "ui_97331668a8": [
    "AI belum bisa dibuka. Coba lagi sebentar.",
    "The study guide could not be loaded. Try again shortly.",
    "تعذر تحميل خادم المطالعة. حاول بعد قليل."
  ],
  "ui_b1c0a06c2d": ["Jilid", "Volumes", "الأجزاء"],
  "ui_ffc1ce6e71": [
    "Selesai diunduh dan diperiksa. Siap dipasang.",
    "Open the latest desktop update.",
    "افتح تحديث سطح المكتب الأخير."
  ],
  "ui_9d5001b52a": [
    "Selesai diunduh di latar belakang. Ketuk pasang untuk menerapkan.",
    "Download complete. Select Install to apply the update.",
    "اكتمل التنزيل. اختر التثبيت لتطبيق التحديث."
  ],
  "ui_032324ae7a": ["Perbarui", "Update", "تحديث"],
  "ui_643682e0fa": ["Pasang", "Install", "تثبيت"],
  "ui_942752a765": [
    "Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda.",
    "Access code not found. Check the code and try again.",
    "لم يُعثر على رمز الوصول. راجع كتابته وأعد المحاولة."
  ],
  "ui_46806499b9": [
    "Kode ini sudah pernah ditukarkan sebelumnya.",
    "This code has already been redeemed.",
    "سبق استخدام هذا الرمز."
  ],
  "ui_4a945b8dda": [
    "Kuota penukaran untuk kode voucher ini sudah habis.",
    "This code has reached its redemption limit.",
    "بلغ هذا الرمز الحد الأقصى للاستخدام."
  ],
  "ui_2b0987dfb4": [
    "Masa berlaku kode voucher ini telah berakhir.",
    "This access code has expired.",
    "انتهت صلاحية رمز الوصول."
  ],
  "ui_bfa2564b0f": [
    "Kode voucher ini sudah tidak aktif.",
    "This access code is inactive.",
    "رمز الوصول غير فعّال."
  ],
  "ui_3841780fe2": [
    "Format penulisan kode voucher belum sesuai.",
    "The access code format is invalid.",
    "صيغة رمز الوصول غير صحيحة."
  ],
  "ui_259e2d8b2c": [
    "Masukkan kode voucher",
    "Enter your access code",
    "أدخل رمز الوصول"
  ],
  "ui_7db0b47a80": ["Akses aktif.", "Access activated", "فُعّل الوصول"],
  "ui_ba384f3c7f": [
    "Kode tidak valid atau sudah kedaluwarsa",
    "Code invalid or expired",
    "الرمز غير صحيح أو منتهي الصلاحية"
  ],
  "ui_76fa6fcef2": [
    "Voucher aktif. Akses tanya jawab sudah dibuka.",
    "Code redeemed. Your study access is open.",
    "استُخدم الرمز وفُتح الوصول إلى المطالعة."
  ],
  "ui_6f8fc6f8d5": [
    "Gunakan voucher",
    "Redeem access code",
    "استخدام رمز الوصول"
  ],
  "ui_75edf97617": [
    "Masukkan kode voucher yang Anda miliki.",
    "Enter your access code.",
    "أدخل رمز الوصول الذي لديك."
  ],
  "ui_56a2f9f730": [
    "Tutup halaman pembayaran?",
    "Close the payment page?",
    "إغلاق صفحة الدفع؟"
  ],
  "ui_85f60bf7af": [
    "Menutup halaman ini tidak otomatis membatalkan transaksi jika pembayaran telah diproses. Transaksi Anda tetap tercatat di sistem.",
    "Closing this page does not cancel a payment that has been processed. Your transaction remains on record.",
    "لا يؤدي إغلاق الصفحة إلى إلغاء دفعة تمت معالجتها. وتبقى معاملتك مسجلة."
  ],
  "ui_5bcbc797a7": ["Lanjutkan", "Continue", "متابعة"],
  "ui_f0874594eb": ["Pembayaran", "Payment", "الدفع"],
  "ui_9218f901c4": [
    "Koneksi terenkripsi",
    "Encrypted connection",
    "اتصال مشفر"
  ],
  "ui_1c93ce4af4": ["Muat ulang status", "Refresh status", "تحديث الحالة"],
  "ui_28654608b2": ["Alhamdulillah", "Alhamdulillah", "الحمد لله"],
  "ui_109055bfcd": [
    "Pembayaran berhasil",
    "Payment successful",
    "تم الدفع بنجاح"
  ],
  "ui_1408872bee": [
    "Akses modul telah aktif. Mengalihkan…",
    "Access is active. Returning to your study…",
    "فُعّل الوصول. جارٍ الرجوع إلى المطالعة…"
  ],
  "ui_4ccf3c2529": [
    "Isi judul atau tulis catatan terlebih dahulu.",
    "Enter a title or write a note first.",
    "أدخل عنوانًا أو اكتب ملاحظة أولًا."
  ],
  "ui_dc885de9d1": ["Catatan Pribadi", "Personal Note", "ملاحظة شخصية"],
  "ui_bdbc1bc83d": ["Catatan baru", "New note", "ملاحظة جديدة"],
  "ui_38329dceb2": ["Menyimpan draf…", "Saving draft…", "جارٍ حفظ المسودة…"],
  "ui_9e29bfcc3a": ["Draf dipulihkan", "Draft restored", "استُعيدت المسودة"],
  "ui_4d08ace78e": ["Draf tersimpan", "Draft saved", "حُفظت المسودة"],
  "ui_d1d150c064": ["Tulis", "Write", "كتابة"],
  "ui_b062be87ba": ["Pratinjau", "Preview", "معاينة"],
  "ui_0ad31d3dbc": ["Tebal", "Bold", "عريض"],
  "ui_2a56aa99d1": ["teks tebal", "bold text", "نص عريض"],
  "ui_fab1614b6f": ["Miring", "Italic", "مائل"],
  "ui_1fcc946c8f": ["teks miring", "italic text", "نص مائل"],
  "ui_e0d33b4f52": ["Daftar Poin", "Bullet list", "قائمة نقطية"],
  "ui_25a227602a": ["poin catatan", "note item", "بند الملاحظة"],
  "ui_31ac832098": ["Kutipan", "Quotation", "اقتباس"],
  "ui_8c150a373b": ["kutipan ibarah", "quoted passage", "عبارة مقتبسة"],
  "ui_ba0dab7b01": ["Kutipan Arab", "Arabic quotation", "اقتباس عربي"],
  "ui_63395fecb6": ["Judul Bab", "Chapter title", "عنوان الفصل"],
  "ui_67450a0c82": [
    "Kiri ke kanan (LTR)",
    "Left-to-right direction",
    "الاتجاه من اليسار إلى اليمين"
  ],
  "ui_7cb5acfec8": [
    "Kanan ke kiri (RTL)",
    "Right-to-left / Arabic direction",
    "الاتجاه من اليمين إلى اليسار"
  ],
  "ui_168ac11968": [
    "Belum ada isi catatan.",
    "This note is empty.",
    "هذه الملاحظة فارغة."
  ],
  "ui_74ed01cdfb": ["Judul catatan", "Note title", "عنوان الملاحظة"],
  "ui_d0b4373b9e": [
    "Tulis catatan atau tempel ibarah di sini…",
    "Write a note or paste a passage here…",
    "اكتب ملاحظة أو ألصق عبارة هنا…"
  ],
  "ui_0e03995bc9": ["Ibarah tersalin.", "Passage copied.", "نُسخت العبارة."],
  "ui_23bee09642": [
    "Taqrir & Syarah:",
    "Explanation & Commentary:",
    "التقرير والشرح:"
  ],
  "ui_254caa0612": [
    "Ibarah & rujukan",
    "Passage & reference",
    "العبارة والمرجع"
  ],
  "ui_47ad9fd917": ["Pengarang", "Author", "المؤلف"],
  "ui_0e380bd079": ["Halaman", "Page", "الصفحة"],
  "ui_2dc18d8d8b": ["Disiplin", "Discipline", "المجال"],
  "ui_57c258a29c": [
    "Naskah ibarah asli",
    "Original passage",
    "العبارة الأصلية"
  ],
  "ui_e486ebab2c": [
    "Intisari & penjelasan",
    "Summary & explanation",
    "الخلاصة والبيان"
  ],
  "ui_5502967ab3": [
    "Buka di Maktabah Syamilah",
    "Open in al-Maktabah al-Shamilah",
    "فتح في المكتبة الشاملة"
  ],
  "ui_9a30ee772c": ["Salin rujukan", "Copy reference", "نسخ الإحالة العلمية"],
  "ui_d67287e521": ["KOLEKSI UTAMA", "FEATURED COLLECTION", "المجموعة المميزة"],
  "ui_e84b97b822": ["AKTIF", "ACTIVE", "فعّال"],
  "ui_71c772586f": ["PREMIUM", "SPECIAL COLLECTION", "خزانة خاصة"],
  "ui_91abbb166e": [
    "Pembayaran dan pengembalian dana",
    "Payments and refunds",
    "الدفع واسترداد المبالغ"
  ],
  "ui_9f7ecdca34": [
    "Panduan penggunaan AI dan rujukan",
    "Guide to using AI and references",
    "دليل استعمال الذكاء الاصطناعي والمراجع"
  ],
  "ui_58062da3e8": [
    "Saluran resmi dan pengaduan",
    "Official Contacts & Service Complaints",
    "قنوات التواصل الرسمية وشكاوى الخدمة"
  ],
  "ui_73d11e46c9": ["Kembali ke beranda", "Return home", "العودة إلى الرئيسية"],
  "ui_2b3aa03422": ["Ukuran huruf", "Text size", "حجم الخط"],
  "ui_1781d557ab": [
    "Akun Google ini belum dapat membuka AI. Gunakan akun Google yang sudah dihubungkan dengan OpenTurath.",
    "This Google account cannot open the study guide. Use the account linked to OpenTurath.",
    "لا يمكن لهذا الحساب فتح خادم المطالعة. استخدم حساب Google المرتبط بأوبن تراث."
  ],
  "ui_5d804a44a9": [
    "Akses untuk AI ini memerlukan langganan aktif.",
    "This study guide requires an active subscription.",
    "يتطلب هذا الخادم اشتراكًا فعّالًا."
  ],
  "ui_438c4a2dca": [
    "Tautan AI tidak valid.",
    "The study guide link is invalid.",
    "رابط خادم المطالعة غير صحيح."
  ],
  "ui_8239d461f2": [
    "Akses AI ini memerlukan langganan aktif.",
    "This study guide requires an active subscription.",
    "يتطلب هذا الخادم اشتراكًا فعّالًا."
  ],
  "ui_c970e1b24e": [
    "AI belum bisa dihubungkan. Coba lagi.",
    "Unable to connect to the study guide. Try again.",
    "تعذر الاتصال بخادم المطالعة. أعد المحاولة."
  ],
  "ui_118b9118fe": [
    "Akses khusus diperlukan",
    "Special access required",
    "يلزم وصول خاص"
  ],
  "ui_b460951771": [
    "Akun Google belum memiliki izin",
    "Google account has no access yet",
    "لم يُمنح حساب Google الوصول بعد"
  ],
  "ui_49e0e13474": [
    "AI belum bisa dibuka",
    "The study guide could not be opened",
    "تعذر فتح خادم المطالعة"
  ],
  "ui_7108148c80": [
    "AI belum bisa dibuka",
    "The study guide could not be opened",
    "تعذر فتح خادم المطالعة"
  ],
  "ui_c65a8dd3c0": [
    "Buka akses langganan",
    "View subscription access",
    "عرض الوصول بالاشتراك"
  ],
  "ui_f9d6eb247c": [
    "Ganti akun Google",
    "Switch Google account",
    "تبديل حساب Google"
  ],
  "ui_f3eaad8539": ["Buka pustaka", "Open library", "فتح المكتبة"],
  "ui_906a4865fb": ["Fikih Hanafi", "Hanafi Fiqh", "الفقه الحنفي"],
  "ui_6d6b866be5": ["Fikih Maliki", "Maliki Fiqh", "الفقه المالكي"],
  "ui_9954541c39": ["Fikih Hanbali", "Hanbali Fiqh", "الفقه الحنبلي"],
  "ui_2b90583ab7": ["Perbandingan Mazhab", "Comparative Fiqh", "الفقه المقارن"],
  "ui_bb6b589ac6": ["Matan Hadis", "Matan Hadith", "متن الحديث"],
  "ui_34fc2f7f7b": ["Tafsir Al-Qur'an", "Qur’anic Exegesis", "تفسير القرآن"],
  "ui_703ae50c4d": [
    "Sejarah & Sirah",
    "History & Prophetic Biography",
    "التاريخ والسيرة النبوية"
  ],
  "ui_b63b74acc6": [
    "Tasawwuf & Adzkar",
    "Spirituality & Remembrance",
    "التصوف والأذكار"
  ],
  "ui_566e9666a0": ["Qawaid Fiqhiyyah", "Legal Maxims", "القواعد الفقهية"],
  "ui_966710e7a1": [
    "Fatawa & Masail Fiqhiyyah",
    "Fatwas & Legal Questions",
    "الفتاوى والمسائل الفقهية"
  ],
  "ui_32a669e14a": [
    "Tajwid & Qira'at",
    "Qur’anic Recitation & Readings",
    "التجويد والقراءات"
  ],
  "ui_589da3ee24": ["Musthalah Hadis", "Hadith Methodology", "مصطلح الحديث"],
  "ui_7314d2a449": ["Syarah Hadis", "Hadith Commentaries", "شروح الحديث"],
  "ui_2c2ccbaa7d": [
    "Thabaqat & Rijalul Hadis",
    "Biographical Classes & Hadith Transmitters",
    "الطبقات ورجال الحديث"
  ],
  "ui_c970ade947": [
    "Bibliografi & Faharis",
    "Bibliography & Indexes",
    "الببليوغرافيا والفهارس"
  ],
  "ui_07146c785a": [
    "Manhaj Abu Bakr al-Masyhur",
    "The Method of Abu Bakr al-Mashhur",
    "منهج أبي بكر المشهور"
  ],
  "ui_e9aed75027": [
    "Matan, syarah, dan hasyiyah",
    "Matn, sharh, and hashiyah",
    "المتون والشروح والحواشي"
  ],
  "ui_544fc16256": [
    "Zhahir Ar-Riwayah · Syuruh & Fatawa",
    "Zahir al-Riwayah · Commentaries & Fatwas",
    "ظاهر الرواية والشروح والفتاوى"
  ],
  "ui_9522214d6e": [
    "Al-Mudawwanah · Mukhtashar Khalil & Syarah",
    "Al-Mudawwanah · Mukhtasar Khalil & Commentaries",
    "المدونة ومختصر خليل وشروحه"
  ],
  "ui_7fa06164bc": [
    "Al-Mughni · Zad Al-Mustaqni' & Syuruh",
    "Al-Mughni · Zad al-Mustaqni‘ & Commentaries",
    "المغني وزاد المستقنع وشروحه"
  ],
  "ui_bc473de8a5": [
    "Perbandingan Mazhab Empat & Tarjih Dalil",
    "The Four Schools & Evaluation of Evidence",
    "مقارنة المذاهب الأربعة وترجيح الأدلة"
  ],
  "ui_ae3e519036": [
    "Kutubus Sittah · Takhrij & Rijal",
    "The Six Books · Source Tracing & Transmitters",
    "الكتب الستة والتخريج والرجال"
  ],
  "ui_8101c037c1": [
    "Tafsir Thabari, Ibnu Katsir & Qurtubi",
    "Al-Tabari, Ibn Kathir & Al-Qurtubi",
    "تفاسير الطبري وابن كثير والقرطبي"
  ],
  "ui_8a80cc1bb2": [
    "Kaidah Istinbath & Maqashid Syariah",
    "Principles of Inference & Objectives of the Law",
    "قواعد الاستنباط ومقاصد الشريعة"
  ],
  "ui_a143b4c40e": [
    "Alfiyah Ibnu Malik & Lisanul Arab",
    "Ibn Malik’s Alfiyyah & Lisan al-‘Arab",
    "ألفية ابن مالك ولسان العرب"
  ],
  "ui_1ce2c78441": [
    "Asy'ariyyah · Maturidiyyah · Dalil Aqli",
    "Ash‘ari & Maturidi Theology · Rational Arguments",
    "الأشعرية والماتريدية والأدلة العقلية"
  ],
  "ui_a59c40f1dd": [
    "Sirah Ibnu Hisyam & Tarikh Thabari",
    "Ibn Hisham’s Sirah & Al-Tabari’s History",
    "سيرة ابن هشام وتاريخ الطبري"
  ],
  "ui_d036360b96": [
    "Ihya Ulumiddin & Naskah Hujjatul Islam",
    "Ihya’ ‘Ulum al-Din & Al-Ghazali’s Works",
    "إحياء علوم الدين ومؤلفات حجة الإسلام"
  ],
  "ui_824262fcf2": [
    "Asybah wan-Nazhair & Kaidah Asasiyyah",
    "Al-Ashbah wa al-Naza’ir & Foundational Maxims",
    "الأشباه والنظائر والقواعد الأساسية"
  ],
  "ui_71adf46f84": [
    "Fatawa Kubra & Nawadzil Mu'ashirah",
    "Major Fatwa Collections & Contemporary Cases",
    "الفتاوى الكبرى والنوازل المعاصرة"
  ],
  "ui_73baa9c078": [
    "Al-Jazariyyah, Asy-Syathibiyyah & Qira'at Sab'ah",
    "Al-Jazariyyah, Al-Shatibiyyah & the Seven Readings",
    "الجزرية والشاطبية والقراءات السبع"
  ],
  "ui_57d1a189d8": [
    "Muqaddimah Ibnu Shalah & Nukhbatul Fikar",
    "Ibn al-Salah’s Introduction & Nukhbat al-Fikar",
    "مقدمة ابن الصلاح ونخبة الفكر"
  ],
  "ui_2a1f6bb073": [
    "Fathul Bari, An-Nawawi 'ala Muslim & Syuruh Sittah",
    "Fath al-Bari, Al-Nawawi on Muslim & Commentaries",
    "فتح الباري وشرح النووي على مسلم وشروح الكتب الستة"
  ],
  "ui_7ffe474ded": [
    "Tahdzibut Tahdzib, Siyar A'lam Nubala & Thabaqat",
    "Tahdhib al-Tahdhib, Siyar A‘lam al-Nubala’ & Biographies",
    "تهذيب التهذيب وسير أعلام النبلاء والطبقات"
  ],
  "ui_130ea65db6": [
    "Kasyfuzh Zhunun, Mu'jamul Mushannifin & Faharis",
    "Kashf al-Zunun, Author Dictionaries & Indexes",
    "كشف الظنون ومعاجم المصنفين والفهارس"
  ],
  "ui_85c784a27e": [
    "Matan · Syarah · Hasyiyah",
    "Texts · Commentaries · Marginalia",
    "المتون والشروح والحواشي"
  ],
  "ui_d3cc4c7772": [
    "Ihya Ulumiddin · Adab & Wirid",
    "Ihya’ ‘Ulum al-Din · Etiquette & Devotions",
    "إحياء علوم الدين والآداب والأوراد"
  ],
  "introTitle": [
    "Mengenal Fikih Tahawwulat",
    "Introducing Fiqh al-Tahawwulat",
    "التعريف بفقه التحولات"
  ],
  "introFoundation": [
    "Tsawabit dan tanda zaman",
    "The Constants and the Signs of the Times",
    "الثوابت وعلامات الزمان"
  ],
  "introFoundationBody": [
    "Dalam kerangka Al-Habib Abu Bakar Al-Adni Al-Masyhur, Fikih Tahawwulat membahas perubahan zaman untuk menjaga Islam, Iman, dan Ihsan. Sebutan Rukun Keempat dipahami dalam kerangka keilmuan tersebut.",
    "Within the framework of al-Habib Abu Bakr al-Adni al-Mashhur, Fiqh al-Tahawwulat studies changing times in order to safeguard Islam, Iman, and Ihsan. The designation Fourth Pillar belongs to this scholarly framework.",
    "يدرس فقه التحولات، في إطار الحبيب أبي بكر العدني المشهور، تغيرات الزمان لصيانة الإسلام والإيمان والإحسان. ويُفهم وصف الركن الرابع ضمن هذا الإطار العلمي."
  ],
  "introMethod": [
    "Adab dan cara bertanya",
    "Etiquette and method",
    "آداب المطالعة ومنهجها"
  ],
  "introMethodBody": [
    "Baca teks bersama konteksnya. Periksa kutipan, nama kitab, jilid, dan halaman. Pembacaan tanda zaman perlu kehati-hatian, bimbingan guru, serta penjagaan lisan dan tindakan.",
    "Read each passage in context. Check its wording, title, volume, and page. Studying the signs of the times calls for care, guidance from teachers, and restraint in speech and action.",
    "اقرأ النص في سياقه، وراجع ألفاظه واسم الكتاب والجزء والصفحة. ودراسة علامات الزمان تستلزم التثبت وإرشاد المعلمين وصيانة اللسان والعمل."
  ],
  "introRooms": ["Lima AI", "Five AI AIs", "خمسة نماذج ذكاء اصطناعي"],
  "introReferences": [
    "Menelusuri karya dan rujukan",
    "Following the Works and References",
    "تتبع المؤلفات والمراجع"
  ],
  "introReferencesBody": [
    "Koleksi mempertemukan karya tulis dan materi ceramah yang tercatat dalam katalog. Setiap jawaban tetap perlu dicocokkan dengan sumbernya.",
    "The collection brings together written works and lecture material recorded in the catalog. Each answer should still be checked against its source.",
    "تجمع المجموعة المؤلفات ومواد المحاضرات المسجلة في الفهرس. وتبقى مراجعة كل جواب في مصدره لازمة."
  ],
  "originalArticle": [
    "Baca naskah pengenalan lengkap (Indonesia)",
    "Read the complete introduction (Indonesian)",
    "قراءة النص التعريفي الكامل بالإندونيسية"
  ],
  "ui_8b4029fe50": [
    "Teks matan & ibarah",
    "Base Texts & Passages",
    "المتون والعبارات"
  ],
  "ui_87343cd230": [
    "Penyederhanaan Konsep",
    "Explaining Concepts",
    "تبسيط المفاهيم"
  ],
  "ui_9cabfc4bb1": [
    "Uji pemahaman tanya jawab",
    "Comprehension Q&A",
    "اختبار الفهم بالسؤال والجواب"
  ],
  "ui_4837b8e469": [
    "Arsip ceramah Habib Abu Bakar Al-Adni bin Ali Al-Masyhur",
    "Lectures of Habib Abu Bakr al-Adni bin Ali al-Mashhur",
    "محاضرات الحبيب أبي بكر"
  ],
  "ui_b8d36541c3": [
    "Materi dakwah & khutbah",
    "Sermon & Teaching Preparation",
    "إعداد مواد الدعوة والخطب"
  ],
  "ui_7004b5d8ff": ["Matan & Ibarah", "Texts & Passages", "المتون والعبارات"],
  "ui_87d9751aa5": [
    "Konsep & Istilah",
    "Concepts & Terms",
    "المفاهيم والمصطلحات"
  ],
  "ui_b75ba44465": ["Uji Pemahaman", "Understanding Check", "اختبار الفهم"],
  "ui_e5ad7cb376": ["Arsip Ceramah", "Lecture Archive", "أرشيف المحاضرات"],
  "ui_44aa1b83f5": ["Dakwah & Khutbah", "Teaching & Sermons", "الدعوة والخطب"],
  "booksShown": [
    "Menampilkan {0} dari {1} kitab",
    "Showing {0} of {1} books",
    "عرض {0} من {1} كتابًا"
  ],
  "bookCount": ["{0} kitab", "{0} books", "عدد الكتب: {0}"],
  "authorCredit": ["Karya {0}", "By {0}", "تأليف {0}"],
  "editorCredit": ["Tahqiq: {0}", "Edited by {0}", "تحقيق: {0}"],
  "deathYear": ["w. {0} H", "d. {0} AH", "ت. {0} هـ"],
  "volumeCount": ["{0} jilid", "{0} volumes", "عدد الأجزاء: {0}"],
  "pageCount": ["{0} hlm.", "{0} pp.", "عدد الصفحات: {0}"],
  "textSize": ["Ukuran teks ({0}%)", "Text size ({0}%)", "حجم النص ({0}٪)"],
  "updateAvailable": [
    "Pembaruan v{0} tersedia",
    "Update v{0} available",
    "التحديث v{0} متاح"
  ],
  "updateReady": [
    "Pembaruan v{0} siap dipasang",
    "Update v{0} ready to install",
    "التحديث v{0} جاهز للتثبيت"
  ],
  "openNamedStudy": ["Buka AI {0}", "Open {0} AI", "فتح الذكاء الاصطناعي {0}"],
  "policyOriginal": [
    "Naskah kebijakan resmi berbahasa Indonesia.",
    "The official policy text is in Indonesian.",
    "نص السياسة الرسمي باللغة الإندونيسية."
  ],
  "collectionPreparing": [
    "Koleksi kitab untuk {0} masih disiapkan.",
    "The collection for {0} is still being prepared.",
    "مجموعة كتب {0} لا تزال قيد الإعداد."
  ],
  "justNow": ["Baru saja", "Just now", "الآن"],
  "minutesAgo": ["{0} menit lalu", "{0} minutes ago", "قبل {0} دقيقة"],
  "hoursAgo": ["{0} jam lalu", "{0} hours ago", "قبل {0} ساعة"],
  "daysAgo": ["{0} hari lalu", "{0} days ago", "قبل {0} يوم"],
  "yesterday": ["Kemarin", "Yesterday", "أمس"],
  "expiryDate": ["Berakhir {0}", "Expires {0}", "ينتهي في {0}"],
  "externalReferenceError": [
    "Rujukan belum bisa dibuka.",
    "Unable to open the external reference.",
    "تعذر فتح المرجع الخارجي."
  ],
  "pageNumber": ["Hlm. {0}", "p. {0}", "ص. {0}"],
  "libraryOverview": ["Pustaka rujukan", "Reference library", "مكتبة المراجع"],
  "librarySummary": [
    "Jelajahi karya dalam koleksi ini dan periksa rincian tiap edisi sebelum mengutipnya.",
    "Explore the works in this collection and check each edition before citing it.",
    "تصفح مؤلفات هذه المجموعة وراجع بيانات كل طبعة قبل الاستشهاد بها."
  ],
  "libraryOpening": ["Membuka katalog…", "Opening catalog…", "جار فتح الفهرس…"],
  "libraryPeriod": ["Rentang masa", "Historical range", "المدى الزمني"],
  "libraryAuthority": ["Ruang lingkup", "Collection scope", "نطاق المجموعة"],
  "libraryWorks": ["Karya", "Works", "المؤلفات"],
  "libraryPages": ["Halaman", "Pages", "الصفحات"],
  "libraryWords": ["Kata", "Words", "الكلمات"],
  "libraryDataNote": [
    "Angka mengikuti catatan katalog; periksa edisi saat mengutip.",
    "Figures follow the catalog record; verify the edition when citing.",
    "الأرقام بحسب الفهرس؛ راجع الطبعة عند الاستشهاد."
  ],
  "libraryRecord": ["Rincian koleksi", "Collection details", "تفاصيل المجموعة"],
  "singleVolume": ["Satu jilid", "Single volume", "جزء واحد"],
  "multipleVolumes": ["Beberapa jilid", "Multiple volumes", "عدة أجزاء"],
  "bookRecordMetadata": ["Data edisi", "Edition details", "بيانات المرجع"],
  "bookPublisher": ["Penerbit", "Publisher", "الناشر"],
  "bookEdition": ["Cetakan", "Edition", "السنة والطبعة"],
  "bookVolumes": ["Jilid", "Volumes", "عدد الأجزاء"],
  "bookPages": ["Halaman", "Pages", "عدد الصفحات"],
  "bookSourceFolder": ["Koleksi sumber", "Source collection", "مجموعة المصادر"],
  "bookAuthorDeath": [
    "Pengarang dan tahun wafat",
    "Author and death year",
    "المؤلف والوفاة"
  ],
  "bookClassification": [
    "Klasifikasi naskah",
    "Text classification",
    "تصنيف النص"
  ],
  "bookScienceSection": ["Bidang ilmu", "Discipline", "القسم العلمي"],
  "bookTextType": ["Jenis naskah", "Text type", "نوع النص"],
  "bookAuthorEra": ["Periode pengarang", "Author's period", "عصر المؤلف"],
  "bookEditionData": ["Data edisi", "Edition details", "بيانات الطبعة"],
  "bookPrintYear": ["Tahun terbit", "Publication year", "سنة الطبع"],
  "bookSave": ["Simpan ke Catatan", "Save to Notes", "الحفظ في الملاحظات"],
  "bookRemove": [
    "Hapus dari Catatan",
    "Remove from Notes",
    "إزالة من الملاحظات"
  ],
  "bookCitationCopy": ["Salin rujukan", "Copy citation", "نسخ التوثيق"],
  "bookTypeWork": ["Karya", "Work", "مصنف علمي"],
  "bookTypeMatn": ["Matan", "Base text", "متن"],
  "bookTypeSharh": ["Syarah", "Commentary", "شرح"],
  "bookTypeHashiyah": ["Hasyiyah", "Marginal commentary", "حاشية"],
  "bookTypeSummary": ["Mukhtasar", "Abridgment", "مختصر"],
  "bookTypeEncyclopedia": ["Ensiklopedia", "Encyclopedia", "موسوعة"],
  "bookTypePoem": ["Manzhumah", "Didactic poem", "منظومة"],
  "bookEraHeritage": ["Khazanah Islam", "Islamic heritage", "التراث الإسلامي"],
  "bookEraEarly": ["Mutaqaddimin", "Early scholars", "المتقدمون"],
  "bookEraMiddle": ["Mutawassithin", "Middle period scholars", "المتوسطون"],
  "bookEraLate": ["Muta'akhkhirin", "Later scholars", "المتأخرون"],
  "bookEraModern": ["Mu'ashirin", "Contemporary scholars", "المعاصرون"],
  "catalogEraFaces": ["Ashab Al-Wujuh", "Early school jurists", "أصحاب الوجوه"],
  "catalogCenturySalaf": [
    "Salaf (≤ 300 H)",
    "Early period (to 300 AH)",
    "العصر الأول (حتى 300 هـ)"
  ],
  "catalogCenturyEarly": [
    "Mutaqaddimin (301-600 H)",
    "Early scholars (301–600 AH)",
    "المتقدمون (301–600 هـ)"
  ],
  "catalogCenturyLate": [
    "Muta'akhkhirin (601-1100 H)",
    "Later scholars (601–1100 AH)",
    "المتأخرون (601–1100 هـ)"
  ],
  "catalogCenturyModern": [
    "Mu'ashir (> 1100 H)",
    "Modern period (after 1100 AH)",
    "العصر الحديث (بعد 1100 هـ)"
  ],
  "desktopLoginIntro": [
    "Aplikasi penelusuran kitab turats berbasis AI.",
    "Classical turath literature research powered by AI.",
    "تطبيق لبحث كتب التراث بالذكاء الاصطناعي."
  ],
  "desktopLoginTitle": [
    "Masuk dengan akun Google",
    "Sign in with Google",
    "تسجيل الدخول عبر جوجل"
  ],
  "desktopLoginHelp": [
    "Gunakan akun Google Anda untuk membuka akses AI dan katalog turats.",
    "Use your Google account to access OpenTurath AI and the turath catalog.",
    "استخدم حساب جوجل للوصول إلى الذكاء الاصطناعي ومكتبة التراث."
  ],
  "desktopConnectingGoogle": [
    "Menghubungkan ke Google…",
    "Connecting to Google…",
    "جارٍ الاتصال بجوجل…"
  ],
  "desktopBrowserHelp": [
    "Google dibuka di browser untuk masuk. Setelah selesai, kembali ke OpenTurath.",
    "Sign in to Google in your browser, then return to OpenTurath.",
    "سجّل الدخول إلى جوجل في المتصفح، ثم عد إلى OpenTurath."
  ],
  "edit": ["Edit", "Edit", "تحرير"],
  "viewBook": ["Lihat kitab", "View book", "عرض الكتاب"],
  "stopGeneratingTitle": [
    "Hentikan jawaban?",
    "Stop generating?",
    "إيقاف الإنشاء؟"
  ],
  "stopGeneratingConfirm": ["Hentikan", "Stop", "إيقاف"],
  "stopGeneratingKeep": ["Lanjutkan", "Keep generating", "متابعة"],
  "outputLanguage": ["Bahasa jawaban", "Answer language", "لغة الجواب"],
  "outputLanguageHint": [
    "Jawaban akan ditulis dalam bahasa yang Anda pilih.",
    "Answers will be written in the language you choose.",
    "ستُكتب الإجابات باللغة التي تختارها."
  ],
  "outputLanguageChanged": [
    "Bahasa jawaban diganti ke {0}.",
    "Answer language changed to {0}.",
    "تم تغيير لغة الجواب إلى {0}."
  ],
  "outputLanguageFailed": [
    "Belum berhasil mengganti bahasa. Pilih bahasa di jendela yang terbuka.",
    "Could not change the language. Choose it in the window that opened.",
    "تعذّر تغيير اللغة. اخترها من النافذة المفتوحة."
  ],
  "clearChatHistory": [
    "Hapus riwayat percakapan",
    "Clear chat history",
    "مسح سجل المحادثة"
  ],
  "fontSizeLabel": ["Ukuran huruf", "Text size", "حجم الخط"],
  "openAssistantSessions": [
    "Sesi terbuka ({0})",
    "Open AI sessions ({0})",
    "جلسات الذكاءات اصطناعية المفتوحة ({0})"
  ],
  "closeSession": ["Tutup sesi", "Close session", "إغلاق الجلسة"],
  "openAnotherSpecialist": [
    "Buka bidang lain",
    "Open Another Specialist",
    "فتح تخصص آخر"
  ],
  "backToHomeTooltip": [
    "Kembali ke beranda",
    "Back to Home",
    "العودة إلى الرئيسية"
  ],
  "textCopied": ["Teks tersalin.", "Text copied.", "نُسخ النص."],
  "sourceReferences": ["Rujukan sumber", "Source references", "مراجع المصادر"],
  "askQuestionHint": [
    "Ajukan pertanyaan atau masalah…",
    "Ask a question or describe a case...",
    "اطرح سؤالًا أو مسألة..."
  ],
  "externalReferenceFailed": [
    "Rujukan belum bisa dibuka: {0}",
    "Could not open the external reference: {0}",
    "تعذر فتح المرجع الخارجي: {0}"
  ],
  "authorLabel": ["Pengarang", "Author", "المؤلف"],
  "pageLabel": ["Halaman", "Page", "الصفحة"],
  "disciplineLabel": ["Disiplin", "Discipline", "الفن"],
  "openInShamela": [
    "Buka di Maktabah Syamilah",
    "Open in al-Maktaba al-Shamela",
    "فتح في المكتبة الشاملة"
  ],
  "copyScholarlyCitation": [
    "Salin rujukan",
    "Copy reference",
    "نسخ التوثيق العلمي"
  ],
  "browserOpenFailed": [
    "Browser belum dapat dibuka.",
    "The browser could not be opened.",
    "تعذر فتح المتصفح."
  ],
  "continueInBrowser": [
    "Lanjutkan di browser",
    "Continue in browser",
    "المتابعة في المتصفح"
  ],
  "downloadWebView2": ["Unduh WebView2", "Download WebView2", "تنزيل WebView2"],
  "marjaBooks": ["Kitab rujukan", "Reference books", "الكتب المرجعية"],
  "reloadBookList": [
    "Muat ulang daftar kitab",
    "Reload book list",
    "إعادة تحميل قائمة الكتب"
  ],
  "bookNotFound": [
    "Kitab tidak ditemukan.",
    "No book found.",
    "لم يُعثر على كتاب."
  ],
  "librarySearchHint": [
    "Cari judul, pengarang, penerbit, atau tahqiq…",
    "Search title, author, publisher, or editor...",
    "ابحث بالعنوان أو المؤلف أو الناشر أو المحقق..."
  ],
  "assistantGoogleAccountSet": [
    "Akun Google AI diatur ke: {0}",
    "AI Google account set to: {0}",
    "حساب Google للمساعد: {0}"
  ],
  "noteSyncPending": ["Belum tersinkron", "Not synced yet", "لم تُزامَن بعد"],
  "notesSyncPendingBanner": [
    "{0} catatan tersimpan di perangkat dan menunggu koneksi.",
    "{0} notes are saved on this device and waiting for a connection.",
    "الملاحظات المحفوظة على الجهاز بانتظار الاتصال: {0}"
  ],
  "syncNow": ["Sinkronkan", "Sync now", "مزامنة"],
  "notesSyncing": ["Menyinkronkan…", "Syncing…", "جارٍ المزامنة…"],
  "notesSyncSuccess": [
    "Catatan berhasil disinkronkan ke cloud.",
    "Notes synced to cloud successfully.",
    "تمت مزامنة الملاحظات مع السحابة بنجاح."
  ],
  "notesSyncFailed": [
    "Belum dapat menyinkronkan catatan. Periksa koneksi internet.",
    "Unable to sync notes. Check internet connection.",
    "تعذرت مزامنة الملاحظات. تحقق من الاتصال بالإنترنت."
  ],
  "corpusDisciplineTab": ["Bidang ilmu", "Disciplines", "الفنون"],
  "corpusScholarTab": ["Khazanah ulama", "Scholars", "خزانة العلماء"],
  "loginTitle": [
    "Masuk ke OpenTurath",
    "Sign in to OpenTurath",
    "تسجيل الدخول إلى أوبن تراث"
  ],
  "loginSubtitle": [
    "Lanjutkan percakapan dengan akun Google Anda.",
    "Continue your study with your Google account.",
    "تابع مطالعتك بحساب Google."
  ],
  "loginAsideBody": [
    "Telusuri ibarah dan rujukan langsung dari kitab turats, dengan AI untuk tiap bidang ilmu.",
    "Trace passages and references straight from the classical texts, with an AI for each discipline.",
    "تتبّع العبارات والمراجع من كتب التراث مباشرة، مع مساعد لكل فنّ."
  ],
  "loginFeatureAssistants": [
    "AI per bidang ilmu",
    "An AI for each discipline",
    "مساعد لكل فنّ"
  ],
  "loginFeatureAssistantsBody": [
    "Fikih, hadis, tafsir, akidah, usul fikih, dan bahasa Arab.",
    "Fiqh, hadith, tafsir, creed, legal theory, and Arabic.",
    "الفقه والحديث والتفسير والعقيدة وأصول الفقه والعربية."
  ],
  "loginFeatureSources": [
    "Berpijak pada kitab rujukan",
    "Grounded in reference works",
    "مستند إلى الكتب المرجعية"
  ],
  "loginFeatureSourcesBody": [
    "Setiap AI punya pustaka kitab yang dapat Anda periksa.",
    "Every AI has a library of works you can inspect.",
    "لكل مساعد مكتبة يمكنك مراجعتها."
  ],
  "loginFeatureNotes": [
    "Catatan tersimpan",
    "Study notes, kept",
    "ملاحظات المطالعة محفوظة"
  ],
  "loginFeatureNotesBody": [
    "Simpan jawaban dan rujukan, tersinkron ke akun Anda.",
    "Save answers and references, synced to your account.",
    "احفظ الأجوبة والمراجع مع المزامنة إلى حسابك."
  ],
  "cardFlipHint": [
    "Ketuk kartu untuk membalik",
    "Tap the card to flip it",
    "اضغط على البطاقة لقلبها"
  ],
  "recentNote": ["Catatan terakhir", "Latest note", "آخر ملاحظة"],
  "viewAccessList": ["Daftar AI aktif", "Active AIs", "المساعدون المفعّلون"],
  "unitBooks": ["kitab", "works", "كتابًا"],
  "unitVolumes": ["jilid", "volumes", "مجلدًا"],
  "unitPages": ["halaman", "pages", "صفحة"],
  "unitLectures": ["arsip ceramah", "lecture archives", "أرشيف محاضرات"],
  "flagshipPositioning": [
    "AI yang dibangun khusus untuk Fikih Tahawwulat.",
    "An AI built specifically for Fiqh al-Tahawwulat.",
    "مساعد ذكي بُني خصيصًا لفقه التحولات."
  ],
  "authorDeathLabel": ["Wafat pengarang", "Author died", "وفاة المؤلف"],
  "searchFieldHint": ["Cari bidang…", "Search disciplines…", "ابحث عن فنّ…"],
  "authPageOk": ["Berhasil", "Done", "تم بنجاح"],
  "authPageFail": [
    "Tidak dapat melanjutkan",
    "Cannot continue",
    "تعذّرت المتابعة"
  ],
  "authPageBadState": [
    "Permintaan tidak dikenali. Tutup tab ini dan coba lagi dari aplikasi.",
    "Request not recognized. Close this tab and try again from the app.",
    "لم يُعرَف الطلب. أغلق هذا التبويب وأعد المحاولة من التطبيق."
  ],
  "authPageCancelled": [
    "Proses masuk dibatalkan. Anda dapat menutup tab ini dan mencoba lagi di aplikasi.",
    "Sign-in was cancelled. You can close this tab and try again in the app.",
    "أُلغيت عملية الدخول. يمكنك إغلاق هذا التبويب والمحاولة من جديد في التطبيق."
  ],
  "authPageNoCode": [
    "Google tidak mengirim kode otorisasi.",
    "Google did not send an authorization code.",
    "لم ترسل Google رمز التفويض."
  ],
  "authPageLinked": [
    "Akun berhasil dihubungkan. Anda dapat menutup tab ini dan kembali ke aplikasi OpenTurath AI.",
    "Account linked. You can close this tab and return to the OpenTurath AI app.",
    "تم ربط الحساب. يمكنك إغلاق هذا التبويب والعودة إلى تطبيق OpenTurath AI."
  ],
  "authPageError": [
    "Gagal menyelesaikan proses masuk. Kembali ke aplikasi dan coba lagi.",
    "Could not complete sign-in. Return to the app and try again.",
    "تعذّر إكمال الدخول. عد إلى التطبيق وأعد المحاولة."
  ],
  "libraryShort": ["Pustaka", "Library", "المكتبة"],
  "libRefTitle": [
    "Kitab rujukan {0}",
    "Reference books: {0}",
    "الكتب المرجعية: {0}"
  ],
  "libRefTitleShafii": [
    "Kitab rujukan Mazhab Syafi'i",
    "Shafi'i school reference books",
    "الكتب المرجعية للمذهب الشافعي"
  ],
  "libCount": [
    "{0} dari {1} kitab rujukan",
    "{0} of {1} reference books",
    "{0} من {1} كتابًا مرجعيًا"
  ],
  "libNoMatch": [
    "Tidak ada kitab yang cocok dengan pencarian",
    "No books match your search",
    "لا توجد كتب مطابقة للبحث"
  ],
  "libPreparing": [
    "Katalog naskah sedang disiapkan.",
    "The manuscript catalog is being prepared.",
    "فهرس المخطوطات قيد الإعداد."
  ],
  "libBookInfo": ["Keterangan kitab", "Book details", "بيانات الكتاب"],
  "loginStatLibraries": [
    "pustaka bidang ilmu",
    "discipline libraries",
    "مكتبات الفنون"
  ],
  "loginStatEntries": ["entri kitab", "catalogued works", "مدخل في الفهارس"],
  "loginStatPages": [
    "halaman (perkiraan)",
    "pages (estimated)",
    "صفحة (تقديرًا)"
  ],
  "unitMillion": ["juta", "million", "مليون"],
  "libraryInNumbers": [
    "Pustaka dalam angka",
    "The library in numbers",
    "المكتبة بالأرقام"
  ],
  "aiEtiquetteLabel": [
    "Panduan penggunaan AI",
    "Guide to using AI",
    "دليل استعمال الذكاء الاصطناعي"
  ],
  "planLabel": ["Paket", "Plan", "الباقة"],
  "planFreeBadge": ["GRATIS", "FREE", "مجاني"],
  "roomAuthTitle": [
    "Masuk dengan akun yang sama",
    "Sign in with the Same Account",
    "تسجيل الدخول بنفس الحساب"
  ],
  "roomAuthBody": [
    "Masuk ke Google sekali lagi dengan akun yang sama dengan akun OpenTurath Anda: {0}. Anda masuk langsung di halaman resmi Google; OpenTurath tidak melihat dan tidak menyimpan kata sandi Anda.",
    "Please sign in to Google once more using the same account as your OpenTurath account: {0}. You sign in directly on Google's official page; OpenTurath never sees or stores your password.",
    "يرجى تسجيل الدخول إلى Google مرة أخرى باستخدام الحساب نفسه المرتبط بأوبن تراث: {0}. يتم الدخول في صفحة Google الرسمية مباشرة؛ ولا يطّلع أوبن تراث على كلمة المرور ولا يحفظها."
  ],
  "roomOpenInBrowser": ["Buka di browser", "Open in browser", "فتح في المتصفح"],
  "roomPermissionTitle": [
    "Akun Google belum punya izin",
    "This Google account has no access",
    "حساب Google لا يملك الإذن"
  ],
  "roomPermissionBody": [
    "Akun Google yang aktif belum bisa membuka AI ini. Periksa akun yang dipakai, lalu coba lagi.",
    "The active Google account cannot open this AI. Check which account is in use, then try again.",
    "حساب Google الحالي لا يستطيع فتح هذا المساعد. تحقق من الحساب المستخدم ثم أعد المحاولة."
  ],
  "roomLoadFailTitle": [
    "AI belum bisa dibuka",
    "The AI could not be opened",
    "تعذّر فتح المساعد"
  ],
  "reportSend": ["Kirim laporan", "Send report", "إرسال تقرير"],
  "aiHelpTitle": ["AI bermasalah?", "AI not working?", "المساعد لا يعمل؟"],
  "aiHelpSubtitle": [
    "Solusi cepat jika AI berputar terus atau tidak merespons",
    "Quick fixes if the AI keeps spinning or does not respond",
    "حلول سريعة إذا ظل المساعد يدور أو لم يستجب"
  ],
  "aiSlowHint": [
    "Terlalu lama? Tutup AI ini lalu buka lagi. Biasanya langsung berhasil.",
    "Taking too long? Close this AI and open it again. It usually works right away.",
    "طال الانتظار؟ أغلق هذا المساعد ثم افتحه من جديد، وغالبًا ينجح فورًا."
  ],
  "aiRestartAction": [
    "Tutup & buka ulang",
    "Close & reopen",
    "إغلاق وإعادة الفتح"
  ],
  "aiHelpMore": ["Solusi lain", "More fixes", "حلول أخرى"],
  "aiHelpStep1": [
    "AI berputar terus atau tidak merespons: tutup AI, lalu buka lagi. Biasanya berhasil.",
    "The AI keeps spinning or does not respond: close it, then open it again. This usually works.",
    "إذا ظل المساعد يدور أو لا يستجيب: أغلقه ثم افتحه من جديد، وغالبًا ينجح ذلك."
  ],
  "aiHelpStep2": [
    "Masih gagal: hapus riwayat obrolan lewat menu titik tiga, tutup AI, lalu buka lagi.",
    "Still failing: clear the chat history from the three-dot menu, close the AI, then open it again.",
    "إن استمر الفشل: امسح سجل المحادثة من قائمة النقاط الثلاث، ثم أغلق المساعد وافتحه من جديد."
  ],
  "aiHelpStep3": [
    "Sudah bertanya tetapi jawaban lama, atau muncul pesan bahwa pesan tidak bisa diterima: tutup AI lalu buka lagi. Biasanya jawabannya sudah selesai.",
    "You asked but the answer is slow, or a message says it cannot receive your message: close the AI and open it again. The answer is usually already done.",
    "إذا سألت وتأخرت الإجابة، أو ظهرت رسالة تفيد بتعذر استقبال رسالتك: أغلق المساعد ثم افتحه من جديد، وغالبًا تكون الإجابة قد اكتملت."
  ],
  "aiHelpStep4": [
    "Tetap bermasalah: tekan Kirim laporan agar kami bisa memeriksanya.",
    "Still stuck: tap Send report so we can look into it.",
    "إن بقيت المشكلة: اضغط إرسال تقرير لنتحقق منها."
  ],
  "reportSending": [
    "Mengirim laporan…",
    "Sending report…",
    "جارٍ إرسال التقرير…"
  ],
  "reportSent": [
    "Laporan terkirim. Kode rujukan Anda: {0}. Sebutkan kode ini bila menghubungi kami.",
    "Report sent. Your reference code: {0}. Quote it if you contact us.",
    "تم إرسال التقرير. رمزك المرجعي: {0}. اذكره عند التواصل معنا."
  ],
  "reportFailed": [
    "Laporan belum terkirim. Periksa koneksi lalu coba lagi.",
    "The report could not be sent. Check your connection and try again.",
    "تعذّر إرسال التقرير. تحقق من الاتصال ثم أعد المحاولة."
  ],
  "dashSlideAboutBadge": [
    "TENTANG OPENTURATH",
    "ABOUT OPENTURATH",
    "عن أوبن تراث"
  ],
  "dashSlideAboutTitle": [
    "Mengenal OpenTurath",
    "Getting to know OpenTurath",
    "تعرّف على أوبن تراث"
  ],
  "dashSlideAboutSummary": [
    "Membaca ibarah dan menelusuri rujukan langsung dari kitab.",
    "Read passages and trace references directly from the books.",
    "اقرأ العبارات وتتبّع المراجع من الكتب مباشرة."
  ],
  "dashSlideAboutBody": [
    "Gunakan OpenTurath untuk mencari rujukan dan membandingkan matan dengan syarah. Periksa hasilnya pada kitab asal, lalu diskusikan dengan guru dan ulama yang berkompeten.",
    "Use OpenTurath to find references and compare base texts with their commentaries. Check the results in the original book, then discuss them with qualified teachers and scholars.",
    "استخدم أوبن تراث للبحث عن المراجع والمقارنة بين المتن والشرح. راجع النتائج في الكتاب الأصلي، ثم ناقشها مع المعلمين والعلماء المؤهلين."
  ],
  "dashSlideAdabBadge": ["ADAB BELAJAR", "ETIQUETTE OF LEARNING", "آداب الطلب"],
  "dashSlideAdabTitle": [
    "Tetap Belajar Bersama Guru",
    "Keep learning with a teacher",
    "واصل التعلّم مع معلّمك"
  ],
  "dashSlideAdabSummary": [
    "Bimbingan guru yang bersanad tetap diperlukan.",
    "Guidance from a teacher with a chain of transmission remains necessary.",
    "لا غنى عن إرشاد معلّم ذي سند."
  ],
  "dashSlideAdabBody": [
    "AI membantu mencari ibarah dan membandingkan penjelasan dalam kitab. Untuk memahami fikih dan fatwa, tetaplah belajar kepada guru dan ulama yang bersanad.",
    "AI helps you find passages and compare explanations in the books. To understand fiqh and fatwas, keep learning from teachers and scholars with a chain of transmission.",
    "يساعدك الذكاء الاصطناعي على تتبع العبارات والمقارنة بين الشروح في الكتب. أما فهم الفقه والفتوى فخذه عن المعلمين والعلماء ذوي السند."
  ],
  "dashSlideSourceBadge": ["PERIKSA SUMBER", "CHECK THE SOURCE", "راجع المصدر"],
  "dashSlideSourceTitle": [
    "Cocokkan dengan kitab asal",
    "Compare with the original book",
    "قابل النص بالكتاب الأصلي"
  ],
  "dashSlideSourceSummary": [
    "Periksa kembali kutipan di Maktabah Syamilah atau kitab cetak.",
    "Check the quotation again in Maktabah Shamela or the printed book.",
    "راجع الاقتباس في المكتبة الشاملة أو الكتاب المطبوع."
  ],
  "dashSlideSourceBody": [
    "Baca ibarah beserta konteksnya pada kitab cetak yang dirujuk sebelum menarik kesimpulan atau membagikan hasilnya.",
    "Read the passage in context in the cited printed book before drawing a conclusion or sharing the result.",
    "اقرأ العبارة في سياقها من الكتاب المطبوع المحال إليه قبل أن تستخلص نتيجة أو تنشرها."
  ],
  "dashSlideAmanahBadge": [
    "AMANAH ILMIAH",
    "SCHOLARLY INTEGRITY",
    "الأمانة العلمية"
  ],
  "dashSlideAmanahTitle": [
    "Cantumkan Rujukan Saat Mengutip",
    "Cite the reference when quoting",
    "اذكر المرجع عند الاقتباس"
  ],
  "dashSlideAmanahSummary": [
    "Sertakan nama pengarang, judul kitab, bab, jilid, dan halaman.",
    "Include the author, book title, chapter, volume, and page.",
    "اذكر المؤلف وعنوان الكتاب والباب والجزء والصفحة."
  ],
  "dashSlideAmanahBody": [
    "Saat mengutip, tuliskan nama pengarang, judul kitab, bab, jilid, dan halaman sesuai sumber yang digunakan agar rujukan mudah ditemukan.",
    "When quoting, write the author, book title, chapter, volume, and page of the source you used so the reference is easy to find.",
    "عند الاقتباس، اذكر المؤلف وعنوان الكتاب والباب والجزء والصفحة وفق المصدر المستخدم ليسهل الوصول إلى المرجع."
  ],
  "dashSlideTraceBadge": [
    "TELUSURI RUJUKAN",
    "TRACE THE REFERENCE",
    "تتبّع المرجع"
  ],
  "dashSlideTraceTitle": [
    "Lihat Asal Kutipan",
    "See where a quotation comes from",
    "اطّلع على أصل الاقتباس"
  ],
  "dashSlideTraceSummary": [
    "Gunakan informasi kitab, jilid, dan halaman untuk memeriksa naskah.",
    "Use the book, volume, and page details to check the text.",
    "استعن ببيانات الكتاب والجزء والصفحة لمراجعة النص."
  ],
  "dashSlideTraceBody": [
    "Buka rujukan yang tersedia untuk menelusuri asal kutipan. Cocokkan teks, jilid, dan halaman dengan edisi kitab yang Anda gunakan.",
    "Open the available reference to trace the quotation. Compare the text, volume, and page with the edition you are using.",
    "افتح المرجع المتاح لتتبع أصل الاقتباس، وقابل النص والجزء والصفحة بطبعة الكتاب التي بين يديك."
  ],
  "roomPreparing": [
    "Sesi AI sedang disiapkan. Coba lagi sebentar.",
    "The AI session is being prepared. Try again in a moment.",
    "تُجهَّز جلسة المساعد الآن. أعد المحاولة بعد قليل."
  ],
  "roomAuthDisconnected": [
    "Sesi masuk Anda belum terhubung. Muat ulang atau masuk kembali.",
    "Your sign-in session is not connected. Reload or sign in again.",
    "جلسة دخولك غير متصلة. أعد التحميل أو سجّل الدخول من جديد."
  ],
  "roomConnectFailed": [
    "AI belum bisa dihubungkan. Coba lagi.",
    "The AI could not be reached. Try again.",
    "تعذّر الاتصال بالمساعد. أعد المحاولة."
  ],
  "paymentOpenBrowserBody": [
    "Halaman ini tidak dapat dibuka di dalam aplikasi demi keamanan. Lanjutkan pembayaran lewat peramban.",
    "For security, this page cannot open inside the app. Continue the payment in your browser.",
    "لا يمكن فتح هذه الصفحة داخل التطبيق حفاظًا على الأمان. أكمل الدفع عبر المتصفح."
  ],
  "paymentOpenBrowser": [
    "Buka di peramban",
    "Open in browser",
    "افتح في المتصفح"
  ],
  "questionCopied": ["Pertanyaan disalin", "Question copied", "نُسخ السؤال"],
  "updateMeteredBody": [
    "Pembaruan tersedia. Unduh sekarang lewat data seluler, atau tunggu sampai tersambung ke Wi-Fi.",
    "An update is available. Download it now over mobile data, or wait for Wi-Fi.",
    "يتوفر تحديث. نزّله الآن عبر بيانات الجوال أو انتظر الاتصال بشبكة Wi-Fi."
  ],
  "updateDownloadNow": ["Unduh sekarang", "Download now", "نزّل الآن"],
  "errorSectionFailed": [
    "Bagian ini gagal ditampilkan. Tutup lalu buka kembali.",
    "This section could not be shown. Close it and open it again.",
    "تعذّر عرض هذا القسم. أغلقه ثم افتحه من جديد."
  ],
  "roomHttpFailure": [
    "AI belum bisa dibuka (kode {0}). Coba muat ulang sebentar lagi.",
    "The AI could not be opened (code {0}). Try reloading in a moment.",
    "تعذر فتح الأداة (الرمز {0}). حاول إعادة التحميل بعد قليل."
  ],
  "roomNotReadyBody": [
    "Percakapan belum siap. Muat ulang atau periksa akun Google Anda.",
    "The conversation is not ready. Reload or check your Google account.",
    "المحادثة غير جاهزة بعد. أعد التحميل أو افحص حساب Google."
  ],
  "roomLoadFailBody": [
    "Halaman AI gagal dimuat. Coba muat ulang; kegagalan ini dapat berasal dari halaman atau koneksi.",
    "The AI page failed to load. Check your internet connection and try again.",
    "تعذّر تحميل صفحة المساعد. تحقق من اتصالك بالإنترنت ثم أعد المحاولة."
  ],
  "roomPaywallTitle": [
    "AI ini memerlukan langganan",
    "This AI requires a subscription",
    "هذا المساعد يتطلب اشتراكًا"
  ],
  "roomSeePlans": ["Lihat paket", "See plans", "عرض الباقات"],
  "roomPaywallBody": [
    "Aktifkan langganan untuk bertanya bersama AI {0}.",
    "Activate a subscription to study with the {0} AI.",
    "فعّل الاشتراك للمطالعة مع مساعد {0}."
  ],
  "planSingleLabel": [
    "Satu bidang ilmu",
    "One field of study",
    "مجال علمي واحد"
  ],
  "noExpiryShort": ["TANPA BATAS", "NO EXPIRY", "بلا انتهاء"],
  "accessTermLabel": ["Masa akses", "Access term", "مدة الوصول"],
  "roomSignInGoogle": [
    "Masuk dengan Google",
    "Sign in with Google",
    "تسجيل الدخول عبر Google"
  ],
  "roomAuthSameAccount": [
    "akun Google yang sama",
    "the same Google account",
    "حساب Google نفسه"
  ],
  "roomAuthBarHint": [
    "Masuk dengan akun yang sama",
    "Sign in with the same account",
    "سجّل الدخول بالحساب نفسه"
  ],
  "googleAccountDialogTitle": [
    "Akun Google untuk AI",
    "Google Account for AI",
    "حساب Google للمساعد"
  ],
  "googleAccountDialogDesc": [
    "Pastikan email ini sesuai dengan akun Google yang memiliki akses ke AI Anda. Browser akan langsung memilih akun ini.",
    "Ensure this email matches the Google account with access to your turath study modules. The browser will select this account directly.",
    "تأكد من مطابقة هذا البريد الإلكتروني لحساب Google المصرّح له بالوصول إلى وحدات التراث. سيختار المتصفح هذا الحساب مباشرة."
  ],
  "usePrimaryAccount": [
    "Pakai akun utama",
    "Use Primary Account",
    "استخدام الحساب الرئيسي"
  ],
  "primaryLoginAccount": [
    "Akun utama",
    "Primary Sign-In Account",
    "حساب الدخول الرئيسي"
  ],
  "clearChatHistoryTitle": [
    "Hapus riwayat percakapan?",
    "Clear Chat History?",
    "مسح سجل المحادثة؟"
  ],
  "clearChatHistoryDesc": [
    "Seluruh percakapan pada sesi AI ini akan dibersihkan dari layar.",
    "All conversations in this AI session will be cleared from the screen.",
    "سيتم مسح جميع المحادثات في جلسة هذا المساعد من الشاشة."
  ],
  "chatHistoryCleared": [
    "Riwayat percakapan dibersihkan.",
    "Chat history has been cleared.",
    "تم مسح سجل المحادثة."
  ],
  "readingFontSizeHint": [
    "Sesuaikan ukuran huruf percakapan agar nyaman dibaca.",
    "Adjust conversation font size for comfortable reading.",
    "اضبط حجم خط المحادثة لقراءة مريحة."
  ],
  "sessionSwitcherTitle": [
    "Sesi AI yang terbuka",
    "Open AI Sessions",
    "جلسات المساعد المفتوحة"
  ],
  "selectSessionToSwitch": [
    "Pilih AI untuk berpindah sesi.",
    "Select an AI to switch active study sessions.",
    "اختر مساعدًا للتبديل إلى جلسة المطالعة النشطة."
  ],
  "updateDownloadFailed": [
    "Pembaruan belum selesai diunduh. Coba lagi.",
    "The update could not be downloaded. Try again.",
    "تعذر إكمال تنزيل التحديث. حاول مجددًا."
  ],
  "updatePackageChanged": [
    "Berkas pembaruan perlu diperiksa ulang. Unduh kembali untuk melanjutkan.",
    "The update file needs to be downloaded again for verification.",
    "يلزم تنزيل ملف التحديث مجددًا للتحقق منه."
  ],
  "updateInstallFailed": [
    "Pembaruan belum dapat dipasang. Paket tetap tersimpan; coba lagi dari aplikasi yang sudah terpasang.",
    "The update could not be installed. The package is saved; retry from the installed application.",
    "تعذر تثبيت التحديث. الحزمة محفوظة؛ حاول من التطبيق المثبّت."
  ],
  "updateDownloading": [
    "Mengunduh pembaruan…",
    "Downloading update…",
    "جارٍ تنزيل التحديث…"
  ],
  "updateInstalling": [
    "Menyiapkan pemasangan…",
    "Preparing installation…",
    "جارٍ تجهيز التثبيت…"
  ],
  "updateRetry": ["Coba lagi", "Try Again", "حاول مجددًا"],
  "updateReadyTitleDesktop": [
    "Pembaruan tersedia",
    "Update Available",
    "تحديث متاح"
  ],
  "updateReadyTitleMobile": ["Pembaruan siap", "Update Ready", "التحديث جاهز"],
  "updateReadyVersion": ["Versi {0}", "Version {0}", "الإصدار {0}"],
  "updateReadyDescDesktop": [
    "Pembaruan sudah diunduh dan diperiksa. Pasang untuk membuka ulang aplikasi dengan versi terbaru.",
    "The update has been downloaded and verified. Install it to restart with the new version.",
    "تم تنزيل التحديث والتحقق منه. ثبّته لإعادة تشغيل التطبيق بالإصدار الجديد."
  ],
  "updateReadyDescMobile": [
    "Pembaruan sudah diunduh. Ketuk Pasang, lalu ikuti konfirmasi Android.",
    "The update has been downloaded. Tap Install, then follow the Android confirmation.",
    "اكتمل تنزيل التحديث. اضغط تثبيت ثم اتبع تأكيد أندرويد."
  ],
  "updateReadyDefaultNotes": [
    "Perbaikan dan peningkatan kestabilan.",
    "Fixes and stability improvements.",
    "تحسينات لاستقرار المطالعة والمنظومة العلمية."
  ],
  "updateReadyActionDesktop": [
    "Pasang dan buka ulang",
    "Install and Restart",
    "تثبيت وإعادة تشغيل"
  ],
  "updateReadyActionMobile": [
    "Pasang pembaruan",
    "Install Update",
    "تثبيت التحديث"
  ],
  "updateReadyLater": ["Nanti saja", "Later", "لاحقًا"],
  "updateReadyOpenFailed": [
    "Pembaruan belum bisa dibuka. Coba lagi.",
    "Could not open update. Please try again.",
    "تعذر فتح التحديث. يُرجى المحاولة مرة أخرى."
  ],
  "updateBannerTitleDesktop": [
    "Pembaruan v{0} tersedia",
    "Update v{0} Available",
    "التحديث v{0} متاح"
  ],
  "updateBannerTitleMobile": [
    "Pembaruan v{0} siap dipasang",
    "Update v{0} Ready to Install",
    "التحديث v{0} جاهز للتثبيت"
  ],
  "updateBannerDescDesktop": [
    "Selesai diunduh dan diperiksa. Siap dipasang.",
    "Downloaded and verified. Ready to install.",
    "تم التنزيل والتحقق. التحديث جاهز للتثبيت."
  ],
  "updateBannerDescMobile": [
    "Selesai diunduh di latar belakang. Ketuk pasang untuk menerapkan.",
    "Downloaded in the background. Tap install to apply.",
    "اكتمل التنزيل في الخلفية. اضغط تثبيت للتطبيق."
  ],
  "updateBannerActionDesktop": ["Perbarui", "Update", "تحديث"],
  "updateBannerActionMobile": ["Pasang", "Install", "تثبيت"],
  "openAssistant": ["Buka AI", "Open AI", "افتح الذكاء الاصطناعي"],
  "openNamedAI": ["Buka {0}", "Open {0}", "افتح {0}"],
  "viewReferences": ["Lihat rujukan", "View references", "عرض المراجع"],
  "lifetimeAccess": ["Tanpa batas waktu", "No expiry", "بلا حد زمني"],
  "editionNote": ["Catatan edisi", "Edition note", "ملاحظة الطبعة"],
  "metadataReview": [
    "Data edisi ini perlu diperiksa pada sumber katalog.",
    "Check these edition details against the catalog source.",
    "تحتاج بيانات هذه الطبعة إلى مراجعة مصدر الفهرس."
  ],
  "editorNotRecorded": [
    "Nama muhaqqiq belum tercatat",
    "Editor name not recorded",
    "لم يُسجل اسم المحقق"
  ],
  "catalogFailure": [
    "Rujukan belum dapat dimuat. Coba lagi.",
    "References could not be loaded. Try again.",
    "تعذر تحميل المراجع. حاول مجددًا."
  ],
  "catalogSourceLabel": [
    "Data katalog · periksa edisi saat mengutip",
    "Catalog data · verify the edition when citing",
    "بيانات الفهرس · راجع الطبعة عند الاقتباس"
  ],
  "preparingAnswer": [
    "Menyusun jawaban…",
    "Preparing an answer…",
    "جار إعداد الجواب…"
  ],
  "payAmount": ["Bayar {0}", "Pay {0}", "ادفع {0}"],
  "perDayEquivalent": ["Sekitar {0}/hari", "About {0}/day", "نحو {0} في اليوم"],
  "monthlyEquivalent": [
    "Sekitar {0}/bulan · dibayar sekaligus",
    "About {0}/month · paid upfront",
    "نحو {0} شهريًا · يُدفع كاملًا"
  ],
  "chatPurpose": [
    "Penelusuran teks turats dan perbandingan pendapat berbasis AI.",
    "Turath text research and AI-powered comparative study.",
    "بحث نصوص التراث والمقارنة العلمية بالذكاء الاصطناعي."
  ],
  "sendQuestion": ["Kirim pertanyaan", "Send question", "أرسل السؤال"],
  "retryCatalog": ["Coba lagi", "Try again", "حاول مجددًا"],
  "roomSameAccountTitle": [
    "Masuk dengan akun yang sama",
    "Sign in with the same account",
    "سجّل الدخول بالحساب نفسه"
  ],
  "roomSameAccountBody": [
    "Masuk ke Google dengan akun yang sama: {0}",
    "Please sign in to Google with the same account: {0}",
    "يُرجى تسجيل الدخول إلى Google بالحساب نفسه: {0}"
  ],
  "roomSameAccountBodyPlain": [
    "Masuk ke Google dengan akun yang sama.",
    "Please sign in to Google with the same account.",
    "يُرجى تسجيل الدخول إلى Google بالحساب نفسه."
  ],
  "roomLoginNow": ["Masuk sekarang", "Sign in now", "سجّل الدخول الآن"],
  "roomGooglePermissionDetail": [
    "Akun Google yang aktif belum dapat membuka sesi AI ini. Periksa akun Google yang digunakan dan izin akses Anda.",
    "The active Google account cannot open this AI session yet. Check which Google account is in use and your access permissions.",
    "لا يستطيع حساب Google النشط فتح جلسة الذكاء الاصطناعي هذه بعد. تحقق من حساب Google المستخدم ومن إذن الوصول."
  ],
  "errSignInAgain": [
    "Masuk kembali ke akun Anda.",
    "Please sign in to your account again.",
    "يُرجى تسجيل الدخول إلى حسابك مرة أخرى."
  ],
  "errServiceUnavailable": [
    "Layanan belum dapat dihubungi.",
    "The service cannot be reached right now.",
    "تعذّر الوصول إلى الخدمة حاليًا."
  ],
  "errServerTimeout": [
    "Server belum merespons. Coba kembali.",
    "The server has not responded. Please try again.",
    "لم يستجب الخادم. حاول مرة أخرى."
  ],
  "errUnreadableResponse": [
    "Respons layanan tidak dapat dibaca.",
    "The service response could not be read.",
    "تعذّرت قراءة ردّ الخدمة."
  ],
  "errCheckConnection": [
    "Periksa koneksi internet Anda.",
    "Check your internet connection.",
    "تحقق من اتصالك بالإنترنت."
  ],
  "errGoogleSignInFirst": [
    "Masuk dengan akun Google Anda terlebih dahulu.",
    "Sign in with your Google account first.",
    "سجّل الدخول بحساب Google أولًا."
  ],
  "errAccountChanged": [
    "Akun berubah. Buka kembali percakapan untuk akun aktif.",
    "The account changed. Reopen the conversation for the active account.",
    "تغيّر الحساب. أعد فتح المحادثة للحساب النشط."
  ],
  "errQuestionInvalid": [
    "Pertanyaan kosong atau terlalu panjang.",
    "The question is empty or too long.",
    "السؤال فارغ أو طويل جدًا."
  ],
  "errChromeBridge": [
    "Sambungan ke Google Chrome belum aktif.",
    "The connection to Google Chrome is not active yet.",
    "الاتصال بمتصفح Chrome غير فعّال بعد."
  ],
  "errDesktopChromeRequired": [
    "Fitur ini memerlukan aplikasi desktop dan Google Chrome.",
    "This feature needs the desktop app and Google Chrome.",
    "تتطلب هذه الميزة تطبيق سطح المكتب ومتصفح Chrome."
  ],
  "errAnswerUnreadable": [
    "Jawaban AI belum dapat dibaca.",
    "The AI answer could not be read yet.",
    "تعذّرت قراءة جواب الذكاء الاصطناعي بعد."
  ],
  "redeemSignInFirst": [
    "Masuk ke akun Anda, lalu coba lagi.",
    "Please sign in to your account and try again.",
    "يُرجى تسجيل الدخول إلى حسابك ثم المحاولة مرة أخرى."
  ],
  "redeemNotForAccount": [
    "Kode voucher ini tidak dapat digunakan untuk akun Anda.",
    "This voucher code cannot be used with your account.",
    "لا يمكن استخدام رمز القسيمة هذا مع حسابك."
  ],
  "redeemServiceUnavailable": [
    "Layanan belum dapat dihubungi. Periksa koneksi lalu coba lagi.",
    "The service cannot be reached. Check your connection and try again.",
    "تعذّر الوصول إلى الخدمة. تحقق من الاتصال ثم حاول مرة أخرى."
  ],
  "redeemNotActivated": [
    "Kode voucher belum bisa diaktifkan. Periksa kembali kodenya.",
    "The voucher code could not be activated. Please check your code again.",
    "تعذّر تفعيل رمز القسيمة. يُرجى التحقق من الرمز مرة أخرى."
  ],
  "companionSameAccountHint": [
    "Gunakan akun Google yang sama dengan OpenTurath. Akses diperiksa saat pertanyaan dikirim.",
    "Use the same Google account as OpenTurath. Access is checked when a question is sent.",
    "استخدم حساب Google نفسه المستخدم في أوبن تراث. يُتحقق من صلاحية الوصول عند إرسال السؤال."
  ],
  "dashMatchSource": [
    "Cocokkan dengan kitab asal",
    "Check against the source text",
    "طابِق مع الكتاب الأصل"
  ],
  "workspaceHeadline": [
    "Akses AI OpenTurath.",
    "Access OpenTurath AI.",
    "الوصول إلى OpenTurath AI."
  ],
  "workspaceIntro": [
    "Masuk dengan Google di browser, lalu buka AI di browser dan profil yang sama. Login Google tidak dilakukan di dalam aplikasi.",
    "Sign in with Google in your browser, then open the AI in the same browser and profile. Google sign-in does not happen inside the app.",
    "سجّل الدخول بحساب Google في المتصفح، ثم افتح الأداة في المتصفح والملف الشخصي نفسيهما. لا يتم تسجيل دخول Google داخل التطبيق."
  ],
  "workspaceOpening": [
    "Membuka AI…",
    "Opening AI…",
    "جارٍ فتح الذكاء الاصطناعي…"
  ],
  "workspaceReopen": [
    "Buka AI kembali",
    "Open AI again",
    "افتح الذكاء الاصطناعي مرة أخرى"
  ],
  "workspaceOpen": [
    "Buka sesi AI",
    "Open AI session",
    "افتح جلسة الذكاء الاصطناعي"
  ],
  "workspaceOpened": [
    "Sesi AI telah dibuka di browser. Anda dapat menambahkan pintasannya ke layar utama.",
    "The AI session is open in your browser. You can add a shortcut to your home screen.",
    "فُتحت جلسة الذكاء الاصطناعي في المتصفح. يمكنك إضافة اختصار لها إلى الشاشة الرئيسية."
  ],
  "workspaceSessionNote": [
    "Sesi dipakai kembali per perangkat dan profil browser. Google tetap dapat meminta persetujuan atau verifikasi keamanan.",
    "The session is reused per device and browser profile. Google may still ask for consent or a security check.",
    "تُعاد استخدام الجلسة لكل جهاز وملف متصفح. وقد يطلب Google الموافقة أو التحقق الأمني."
  ],
  "promoUnitDays": ["hari", "days", "أيام"],
  "promoUnitHours": ["jam", "hours", "ساعات"],
  "promoUnitMins": ["menit", "minutes", "دقائق"],
  "promoUnitSecs": ["detik", "seconds", "ثوانٍ"],
  "promoHeadBefore": [
    "MENUJU PELUNCURAN PROMO 10 HARI",
    "10-DAY PROMO LAUNCH COUNTDOWN",
    "العد التنازلي لإطلاق عرض الـ 10 أيام"
  ],
  "promoCapBefore": [
    "Mulai Selasa, 27 Okt · 17:00 WIB (durasi promo 10 hari)",
    "Starts Tuesday, Oct 27 · 17:00 WIB (10-day promo window)",
    "يبدأ الثلاثاء، 27 أكتوبر · 17:00 بتوقيت جاكرتا (نافذة 10 أيام)"
  ],
  "promoHeadLive": [
    "PENAWARAN PERDANA TERBATAS (10 HARI)",
    "LIMITED 10-DAY LAUNCH OFFER",
    "عرض الإطلاق المحدود (10 أيام)"
  ],
  "promoCapLive": [
    "Aktif 10 hari · Berakhir Jumat, 6 Nov · 17:00 WIB",
    "Active for 10 days · Ends Friday, Nov 6 at 17:00 WIB",
    "متاح 10 أيام · ينتهي الجمعة، 6 نوفمبر 17:00 WIB"
  ],
  "promoHeadEnded": [
    "PENAWARAN PERDANA TELAH SELESAI",
    "LAUNCH OFFER ENDED",
    "انتهى العرض"
  ],
  "promoCapEnded": [
    "Masa penawaran perdana 10 hari telah ditutup",
    "The 10-day launch offer has ended",
    "انتهت فترة عرض الإطلاق لـ 10 أيام"
  ],
  "planContinue": [
    "Lanjut ke pembayaran",
    "Continue to payment",
    "المتابعة إلى الدفع"
  ],
  "planTotalLabel": ["Total", "Total", "الإجمالي"],
  "planConsent": [
    "Dengan melanjutkan, Anda menyetujui {0} dan {1}.",
    "By continuing, you agree to the {0} and the {1}.",
    "بالمتابعة فإنك توافق على {0} و{1}."
  ],
  "planConsentTerms": ["Ketentuan Layanan", "Terms of Service", "شروط الخدمة"],
  "planConsentRefund": [
    "Pembayaran dan Pengembalian Dana",
    "Payments and Refunds",
    "الدفع واسترداد المبالغ"
  ],
  "planIncludes": ["Mencakup", "Includes", "يشمل"],
  "planActive": ["Aktif", "Active", "فعّال"],
  "planRenew": ["Perpanjang akses", "Renew access", "تجديد الوصول"],
  "savingUpTo": ["Hemat hingga {0}%", "Save up to {0}%", "وفّر حتى {0}٪"],
  "planPeriodLabel": ["Masa akses", "Access period", "مدة الوصول"],
  "planSingleScope": [
    "Kitab rujukan bidang ini",
    "Reference books of this field",
    "الكتب المرجعية لهذا المجال"
  ],
  "planFeaturedScope": [
    "Kitab dan arsip ceramah",
    "Books and lecture archive",
    "الكتب وأرشيف المحاضرات"
  ],
  "planFeaturedBadge": [
    "Eksklusif di OpenTurath",
    "Exclusive to OpenTurath",
    "حصري في OpenTurath"
  ],
  "checkoutPreparing": [
    "Menyiapkan pembayaran…",
    "Preparing checkout…",
    "جارٍ تهيئة عملية الدفع…"
  ],
  "checkoutPleaseWait": [
    "Tunggu sebentar",
    "Please wait a moment",
    "يرجى الانتظار لحظة"
  ],
  "checkoutStillWaiting": [
    "Belum terdeteksi? Ketuk ikon segarkan untuk memeriksa pembayaran.",
    "Not detected yet? Tap refresh to check your payment.",
    "لم يُرصد بعد؟ اضغط على التحديث لفحص الدفع."
  ],
  "redeemEnterCode": [
    "Masukkan kode voucher",
    "Enter the voucher code",
    "أدخل رمز القسيمة"
  ],
  "redeemTrialActive": [
    "Masa coba untuk akses ini masih aktif. Kode coba baru dapat dipakai setelah berakhir.",
    "The trial for this access is still running. A new trial code can be used once it ends.",
    "ما زالت الفترة التجريبية لهذا الوصول سارية. يمكن استخدام رمز تجريبي جديد بعد انتهائها."
  ],
  "redeemNeedsGoogle": [
    "Masuk dengan akun Google terverifikasi untuk mengaktifkan masa coba.",
    "Sign in with a verified Google account to start the trial.",
    "سجّل الدخول بحساب جوجل موثّق لتفعيل الفترة التجريبية."
  ],
  "redeemTrialClaimed": [
    "Masa coba untuk akun Google ini sudah pernah diaktifkan.",
    "The trial for this Google account has already been used.",
    "سبق تفعيل الفترة التجريبية لهذا الحساب."
  ],
  "redeemMisconfigured": [
    "Kode ini belum diatur dengan benar. Hubungi admin OpenTurath.",
    "This code is not set up correctly. Please contact OpenTurath.",
    "لم يُعدّ هذا الرمز إعدادًا صحيحًا. تواصل مع OpenTurath."
  ],
  "redeemRateLimited": [
    "Terlalu banyak percobaan. Coba lagi beberapa menit lagi.",
    "Too many attempts. Please try again in a few minutes.",
    "محاولات كثيرة. حاول مرة أخرى بعد دقائق."
  ],
  "redeemPhysicalOnly": [
    "Kode ini hanya dapat diaktifkan dari ponsel fisik.",
    "This code can only be activated from a physical phone.",
    "لا يمكن تفعيل هذا الرمز إلا من هاتف حقيقي."
  ],
  "redeemDeviceUsed": [
    "Kode ini hanya dapat diklaim sekali per perangkat, dan perangkat ini sudah pernah memakainya.",
    "This code can be claimed once per device, and this device has already used it.",
    "يمكن استخدام هذا الرمز مرة واحدة لكل جهاز، وقد استُخدم على هذا الجهاز."
  ],
  "redeemDeviceIdentity": [
    "Identitas perangkat diperlukan untuk mengaktifkan kode ini.",
    "A device identity is required to activate this code.",
    "يلزم تعريف الجهاز لتفعيل هذا الرمز."
  ],
  "redeemFallbackTitle": [
    "Akses dari voucher",
    "Access from a voucher",
    "وصول عبر قسيمة"
  ],
  "redeemFailedGeneric": [
    "Kode belum bisa diaktifkan.",
    "The code could not be activated.",
    "تعذّر تفعيل الرمز."
  ],
  "redeemNotFound": [
    "Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda.",
    "Voucher code not found. Please check how you typed it.",
    "لم يُعثر على رمز القسيمة. تحقق من كتابته."
  ],
  "redeemUsed": [
    "Kode ini sudah pernah ditukarkan sebelumnya.",
    "This code has already been redeemed.",
    "سبق استبدال هذا الرمز."
  ],
  "redeemExpired": [
    "Masa berlaku kode voucher ini telah berakhir.",
    "This voucher code has expired.",
    "انتهت صلاحية رمز القسيمة هذا."
  ],
  "redeemInactive": [
    "Kode voucher ini sudah tidak aktif.",
    "This voucher code is no longer active.",
    "رمز القسيمة هذا لم يعد فعالًا."
  ],
  "redeemQuota": [
    "Kuota penukaran untuk kode voucher ini sudah habis.",
    "The redemption limit for this voucher code has been reached.",
    "استُنفدت حصة الاستبدال لهذا الرمز."
  ],
  "redeemBadFormat": [
    "Format penulisan kode voucher belum sesuai.",
    "The voucher code format is not valid.",
    "صيغة رمز القسيمة غير صحيحة."
  ],
};
