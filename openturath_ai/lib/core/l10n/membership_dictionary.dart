// Membership, assistant directory, and payment copy. Prices remain unchanged.
const membershipDictionary = <String, Map<String, String>>{
  "membership.access_update_failed": {
    "id": "Status akses belum dapat diperbarui. Periksa koneksi Anda.",
    "en": "Access status could not be updated. Please check your connection.",
    "ar": "تعذّر تحديث حالة الوصول. يُرجى التحقق من اتصالك.",
  },
  "membership.directory_load_failed": {
    "id": "Direktori belum dapat dimuat. Periksa koneksi lalu coba kembali.",
    "en": "The directory could not be loaded. Check your connection and try again.",
    "ar": "تعذّر تحميل الدليل. تحقّق من اتصالك ثم حاول مجددًا.",
  },
  "membership.study_open_failed": {
    "id": "Ruang kajian belum dapat dibuka. Silakan coba lagi.",
    "en": "The study space could not be opened. Please try again.",
    "ar": "تعذّر فتح مساحة الدراسة. يُرجى المحاولة مجددًا.",
  },
  "membership.access_retry": {
    "id": "Status akses belum dapat diperbarui. Coba kembali.",
    "en": "Access status could not be updated. Please try again.",
    "ar": "تعذّر تحديث حالة الوصول. يُرجى المحاولة مجددًا.",
  },
  "membership.directory": {
    "id": "DIREKTORI KAJIAN",
    "en": "STUDY DIRECTORY",
    "ar": "دليل الدراسة",
  },
  "membership.assistants": {"id": "Rihlah Ilmiah", "en": "Classical Scholarly Halqah", "ar": "مجالس البحث في التراث"},
  "membership.choose_companion": {
    "id": "Pilih pendamping untuk menelusuri teks dan memperdalam kajian.",
    "en": "Choose a companion to explore texts and deepen your study.",
    "ar": "اختر مساعدًا لاستكشاف النصوص والتعمّق في الدراسة.",
  },
  "membership.home": {
    "id": "Kembali ke beranda",
    "en": "Back to home",
    "ar": "العودة إلى الرئيسية",
  },
  "membership.check_access": {
    "id": "Periksa akses",
    "en": "Check access",
    "ar": "التحقق من الوصول",
  },
  "membership.search_hint": {
    "id": "Cari asisten, ulama, atau topik…",
    "en": "Search assistants, scholars, or topics…",
    "ar": "ابحث عن مساعد أو عالم أو موضوع…",
  },
  "membership.discipline": {
    "id": "Bidang ilmu",
    "en": "Discipline",
    "ar": "التخصص العلمي",
  },
  "membership.all_disciplines": {
    "id": "Semua bidang",
    "en": "All disciplines",
    "ar": "جميع التخصصات",
  },
  "membership.directory_unavailable": {
    "id": "Direktori belum tersedia",
    "en": "Directory unavailable",
    "ar": "الدليل غير متاح حاليًا",
  },
  "membership.retry": {
    "id": "Coba lagi",
    "en": "Try again",
    "ar": "المحاولة مجددًا",
  },
  "membership.no_assistants": {
    "id": "Belum ada bidang atau kitab yang cocok. Coba kata kunci lain.",
    "en": "No matching discipline or book. Try another keyword.",
    "ar": "لا يوجد تخصص أو كتاب مطابق. جرّب كلمة بحث أخرى.",
  },
  "membership.try_search": {
    "id": "Coba kata kunci atau bidang ilmu lain.",
    "en": "Try another keyword or discipline.",
    "ar": "جرّب كلمة بحث أو تخصصًا آخر.",
  },
  "membership.reset_search": {
    "id": "Reset pencarian",
    "en": "Reset search",
    "ar": "إعادة تعيين البحث",
  },
  "membership.unavailable": {
    "id": "Belum tersedia",
    "en": "Not yet available",
    "ar": "غير متاح بعد",
  },
  "membership.preparing": {
    "id": "{title} sedang disiapkan.",
    "en": "{title} is being prepared.",
    "ar": "يجري إعداد {title}.",
  },
  "membership.persona_title": {
    "id": "Fikih Tahawwulat: {name}",
    "en": "Fiqh al-Tahawwulat: {name}",
    "ar": "فقه التحولات: {name}",
  },
  "membership.library_title": {
    "id": "Pustaka {title}",
    "en": "{title} library",
    "ar": "مكتبة {title}",
  },
  "membership.about_assistant": {
    "id": "Tentang asisten",
    "en": "About this assistant",
    "ar": "عن هذا المساعد",
  },
  "membership.main_collection": {
    "id": "KOLEKSI UTAMA",
    "en": "FEATURED COLLECTION",
    "ar": "المجموعة الرئيسة",
  },
  "membership.tahawwulat_scope": {
    "id": "Telaah perubahan zaman melalui karya Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur.",
    "en": "Study the transformations of our times through the works of al-Habib Abu Bakr al-Adni bin Ali al-Mashhur.",
    "ar": "ادرس تحولات الزمان من خلال مؤلفات الحبيب أبي بكر العدني بن علي المشهور.",
  },
  "membership.open_study": {"id": "Buka Majelis Kajian", "en": "Begin Scholarly Inquiry", "ar": "فتح مجلس المذاكرة"},
  "membership.view_access": {
    "id": "Lihat akses kajian",
    "en": "View study access",
    "ar": "عرض خيارات الوصول للدراسة",
  },
  "membership.discover_tahawwulat": {
    "id": "Mengenal Tahawwulat",
    "en": "Discover Tahawwulat",
    "ar": "التعرّف إلى فقه التحولات",
  },
  "membership.reference_library": {
    "id": "Pustaka rujukan",
    "en": "Reference library",
    "ar": "مكتبة المراجع",
  },
  "membership.specialist_count": {
    "id": "{count} peran spesialis",
    "en": "Specialist roles: {count}",
    "ar": "الأدوار المتخصصة: {count}",
  },
  "membership.tahawwulat_intro": {
    "id": "Mengenal Fikih Tahawwulat",
    "en": "An introduction to Fiqh al-Tahawwulat",
    "ar": "مدخل إلى فقه التحولات",
  },
  "membership.close_intro": {
    "id": "Tutup pengantar",
    "en": "Close introduction",
    "ar": "إغلاق المقدمة",
  },
  "membership.tahawwulat_definition": {
    "id": "Disiplin yang dikodifikasi Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur untuk memahami perubahan zaman, tanda akhir masa, dan dakwah dalam setiap fase kehidupan.",
    "en": "A discipline codified by al-Habib Abu Bakr al-Adni bin Ali al-Mashhur to understand the transformations of time, the signs of the end times, and religious outreach in every phase of life.",
    "ar": "علم دوّنه الحبيب أبو بكر العدني بن علي المشهور لفهم تحولات الزمان وعلامات آخر الزمان والدعوة في كل مرحلة من مراحل الحياة.",
  },
  "membership.study_direction": {
    "id": "Arah kajian",
    "en": "Study orientation",
    "ar": "اتجاه الدراسة",
  },
  "membership.tahawwulat_method": {
    "id": "Membaca perubahan dengan landasan syariat; memahami Sunnah Mawāqif dan Manhaj as-Salāmah; menjaga adab, keluarga, dan lingkaran terdekat melalui konsep Al-Khuwaiṣah.",
    "en": "Read transformations in light of the Sharia; understand Sunnat al-Mawaqif and Manhaj al-Salamah; and care for conduct, family, and those closest to you through the concept of al-Khuwaysah.",
    "ar": "قراءة التحولات في ضوء الشريعة؛ وفهم سنة المواقف ومنهج السلامة؛ ورعاية الأدب والأسرة والمحيط الأقرب من خلال مفهوم الخويصة.",
  },
  "membership.six_books": {
    "id": "Enam kitab kaidah · kurikulum berjenjang",
    "en": "Six foundational books · a progressive curriculum",
    "ar": "ستة كتب تأسيسية · منهج متدرّج",
  },
  "membership.choose_role": {
    "id": "Pilih peran pendamping",
    "en": "Choose a companion role",
    "ar": "اختر دور المساعد",
  },
  "membership.scholar_heritage": {
    "id": "Khazanah ulama",
    "en": "Scholarly heritage",
    "ar": "تراث العلماء",
  },
  "membership.access_sync_prompt": {
    "id": "Status akses belum dapat diperbarui. Periksa koneksi lalu pilih “Periksa akses”.",
    "en": "Access status could not be updated. Check your connection, then select “Check access”.",
    "ar": "تعذّر تحديث حالة الوصول. تحقّق من اتصالك ثم اختر «التحقق من الوصول».",
  },
  "membership.whatsapp_number": {
    "id": "Nomor WhatsApp",
    "en": "WhatsApp number",
    "ar": "رقم واتساب",
  },
  "membership.phone_explanation": {
    "id": "Masukkan nomor WhatsApp aktif untuk konfirmasi pembayaran dan aktivasi langganan.",
    "en": "Enter an active WhatsApp number for payment confirmation and subscription activation.",
    "ar": "أدخل رقم واتساب فعّالًا لتأكيد الدفع وتفعيل الاشتراك.",
  },
  "membership.phone_hint": {
    "id": "Nomor dengan kode negara, misalnya +62…",
    "en": "Number with country code, for example +62…",
    "ar": "الرقم مع رمز الدولة، مثل ‎+62…",
  },
  "membership.cancel": {
    "id": "Batal",
    "en": "Cancel",
    "ar": "إلغاء",
  },
  "membership.invalid_phone": {
    "id": "Masukkan nomor telepon yang valid.",
    "en": "Enter a valid phone number.",
    "ar": "أدخل رقم هاتف صحيحًا.",
  },
  "membership.continue_payment": {
    "id": "Lanjutkan pembayaran",
    "en": "Continue to payment",
    "ar": "متابعة الدفع",
  },
  "membership.login_purchase": {
    "id": "Masuk ke akun Anda sebelum melanjutkan pembelian.",
    "en": "Sign in to your account before continuing your purchase.",
    "ar": "سجّل الدخول إلى حسابك قبل متابعة الشراء.",
  },
  "membership.sync_failed": {
    "id": "Sinkronisasi belum berhasil. Coba kembali.",
    "en": "Sync was unsuccessful. Please try again.",
    "ar": "لم تنجح المزامنة. يُرجى المحاولة مجددًا.",
  },
  "membership.account_access_missing": {
    "id": "Data akses akun belum ditemukan. Silakan coba kembali.",
    "en": "Account access details were not found. Please try again.",
    "ar": "لم تُعثر على بيانات الوصول للحساب. يُرجى المحاولة مجددًا.",
  },
  "membership.access_updated": {
    "id": "Data akses diperbarui. Akses ke kajian yang dipilih tersedia di akun ini.",
    "en": "Access details updated. The selected study is available in this account.",
    "ar": "حُدّثت بيانات الوصول. الدراسة المختارة متاحة في هذا الحساب.",
  },
  "membership.sync_email_guidance": {
    "id": "Data akun telah diperbarui. Jika pembelian belum muncul, pastikan email GoAkal sama dengan email akun ini, lalu sinkronkan kembali.",
    "en": "Account details updated. If your purchase is missing, make sure your GoAkal email matches this account, then sync again.",
    "ar": "حُدّثت بيانات الحساب. إذا لم تظهر عملية الشراء، فتأكّد من تطابق بريد GoAkal مع بريد هذا الحساب، ثم أعد المزامنة.",
  },
  "membership.sync_connection_failed": {
    "id": "Status akses belum dapat diperiksa. Periksa koneksi lalu sinkronkan kembali.",
    "en": "Access status could not be checked. Check your connection, then sync again.",
    "ar": "تعذّر التحقق من حالة الوصول. تحقّق من اتصالك ثم أعد المزامنة.",
  },
  "membership.access_missing_retry": {
    "id": "Data akses akun belum ditemukan. Silakan periksa kembali.",
    "en": "Account access details were not found. Please check again.",
    "ar": "لم تُعثر على بيانات الوصول للحساب. يُرجى التحقق مجددًا.",
  },
  "membership.account_updated_directory": {
    "id": "Data akun diperbarui. Akses yang tersedia dapat dilihat di direktori asisten.",
    "en": "Account updated. View your available access in the assistant directory.",
    "ar": "حُدّث الحساب. يمكنك الاطّلاع على الوصول المتاح في دليل المساعدين.",
  },
  "membership.account_no_access": {
    "id": "Data akun diperbarui. Belum ada akses aktif yang terkonfirmasi.",
    "en": "Account updated. No active access has been confirmed.",
    "ar": "حُدّث الحساب. لم يُؤكّد أي وصول فعّال بعد.",
  },
  "membership.study_available": {
    "id": "Akses kajian tersedia. Anda dapat kembali ke direktori asisten.",
    "en": "Study access is available. You can return to the assistant directory.",
    "ar": "الوصول إلى الدراسة متاح. يمكنك العودة إلى دليل المساعدين.",
  },
  "membership.access_pending": {
    "id": "Akses kajian belum terkonfirmasi. Anda dapat memeriksanya kembali setelah pemrosesan selesai.",
    "en": "Study access is not yet confirmed. Check again when processing is complete.",
    "ar": "لم يُؤكّد الوصول إلى الدراسة بعد. يمكنك التحقق مجددًا بعد اكتمال المعالجة.",
  },
  "membership.access_connection_failed": {
    "id": "Tidak dapat memperbarui akses. Periksa koneksi lalu coba lagi.",
    "en": "Access could not be updated. Check your connection and try again.",
    "ar": "تعذّر تحديث الوصول. تحقّق من اتصالك وحاول مجددًا.",
  },
  "membership.goakal_closed": {
    "id": "Halaman GoAkal ditutup. Pembayaran dan akses belum terkonfirmasi di aplikasi. Jika Anda telah membayar, pilih “Sinkronkan GoAkal” untuk memeriksa akun.",
    "en": "The GoAkal page was closed. Payment and access are not yet confirmed in the app. If you have paid, select “Sync GoAkal” to check your account.",
    "ar": "أُغلقت صفحة GoAkal. لم يُؤكّد الدفع والوصول في التطبيق بعد. إذا أتممت الدفع، فاختر «مزامنة GoAkal» للتحقق من حسابك.",
  },
  "membership.payment_open_failed": {
    "id": "Halaman pembayaran belum dapat dibuka. Silakan coba kembali.",
    "en": "The payment page could not be opened. Please try again.",
    "ar": "تعذّر فتح صفحة الدفع. يُرجى المحاولة مجددًا.",
  },
  "membership.confirm_plan": {
    "id": "Konfirmasi ketersediaan paket",
    "en": "Confirm plan availability",
    "ar": "تأكيد توفّر الباقة",
  },
  "membership.manual_summary": {
    "id": "{title} · {duration}\nTotal {price}",
    "en": "{title} · {duration}\nTotal {price}",
    "ar": "{title} · {duration}\nالإجمالي {price}",
  },
  "membership.manual_explanation": {
    "id": "Tautan pembayaran langsung belum tersedia untuk pilihan ini. Hubungi tim untuk memastikan paket dan proses aktivasi.",
    "en": "A direct payment link is not yet available for this option. Contact the team to confirm the plan and activation process.",
    "ar": "لا يتوفّر رابط دفع مباشر لهذا الخيار بعد. تواصل مع الفريق للتأكد من الباقة وإجراءات التفعيل.",
  },
  "membership.contact_whatsapp": {
    "id": "Hubungi tim melalui WhatsApp",
    "en": "Contact the team on WhatsApp",
    "ar": "التواصل مع الفريق عبر واتساب",
  },
  "membership.activation_message": {
    "id": "Assalamu’alaikum. Mohon informasi aktivasi {title}, {duration}, total {price}.",
    "en": "Assalamu alaykum. Please provide activation details for {title}, {duration}, total {price}.",
    "ar": "السلام عليكم. أرجو تزويدي بمعلومات تفعيل {title}، لمدة {duration}، بإجمالي {price}.",
  },
  "membership.whatsapp_failed": {
    "id": "WhatsApp belum dapat dibuka.",
    "en": "WhatsApp could not be opened.",
    "ar": "تعذّر فتح واتساب.",
  },
  "membership.whatsapp_retry": {
    "id": "WhatsApp belum dapat dibuka. Silakan coba kembali.",
    "en": "WhatsApp could not be opened. Please try again.",
    "ar": "تعذّر فتح واتساب. يُرجى المحاولة مجددًا.",
  },
  "membership.back": {
    "id": "Kembali",
    "en": "Back",
    "ar": "رجوع",
  },
  "membership.user": {
    "id": "Pengguna",
    "en": "User",
    "ar": "مستخدم",
  },
  "membership.payment_access_confirmed": {
    "id": "Pembayaran terverifikasi. Akses kajian tersedia di akun Anda.",
    "en": "Payment verified. Study access is available in your account.",
    "ar": "تم التحقق من الدفع. الوصول إلى الدراسة متاح في حسابك.",
  },
  "membership.payment_access_pending": {
    "id": "Pembayaran terverifikasi. Akses belum aktif; periksa kembali setelah pemrosesan selesai.",
    "en": "Payment verified. Access is not yet active; check again when processing is complete.",
    "ar": "تم التحقق من الدفع. لم يُفعّل الوصول بعد؛ تحقّق مجددًا بعد اكتمال المعالجة.",
  },
  "membership.access_payment_pending": {
    "id": "Akses kajian tersedia di akun ini. Pembayaran sesi ini belum terkonfirmasi.",
    "en": "Study access is available in this account. Payment for this session is not yet confirmed.",
    "ar": "الوصول إلى الدراسة متاح في هذا الحساب. لم يُؤكّد دفع هذه الجلسة بعد.",
  },
  "membership.payment_access_unconfirmed": {
    "id": "Pembayaran belum terkonfirmasi. Akses kajian belum tersedia.",
    "en": "Payment is not yet confirmed. Study access is not yet available.",
    "ar": "لم يُؤكّد الدفع بعد. الوصول إلى الدراسة غير متاح بعد.",
  },
  "membership.payment_verified_check_access": {
    "id": "Pembayaran terverifikasi. Status akses belum dapat diperbarui; pilih “Periksa akses”.",
    "en": "Payment verified. Access status could not be updated; select “Check access”.",
    "ar": "تم التحقق من الدفع. تعذّر تحديث حالة الوصول؛ اختر «التحقق من الوصول».",
  },
  "membership.payment_access_check_again": {
    "id": "Pembayaran dan akses belum dapat dikonfirmasi. Silakan periksa kembali.",
    "en": "Payment and access could not yet be confirmed. Please check again.",
    "ar": "تعذّر تأكيد الدفع والوصول حتى الآن. يُرجى التحقق مجددًا.",
  },
  "membership.checkout_prepare_failed": {
    "id": "Sesi pembayaran belum dapat disiapkan. Periksa koneksi lalu coba kembali.",
    "en": "The payment session could not be prepared. Check your connection and try again.",
    "ar": "تعذّر إعداد جلسة الدفع. تحقّق من اتصالك ثم حاول مجددًا.",
  },
  "membership.access_period": {
    "id": "Masa akses",
    "en": "Access period",
    "ar": "مدة الوصول",
  },
  "membership.plan_unavailable": {
    "id": "Paket belum tersedia untuk {title}",
    "en": "No plans available for {title} yet",
    "ar": "لا تتوفّر باقات لـ {title} بعد",
  },
  "membership.five_roles": {
    "id": "Satu ruang kajian dengan lima peran spesialis dan pustaka rujukan.",
    "en": "One study space with five specialist roles and a reference library.",
    "ar": "مساحة دراسة واحدة بخمسة أدوار متخصصة ومكتبة مراجع.",
  },
  "membership.selected_access": {
    "id": "Akses asisten dan pustaka rujukan pada bidang yang dipilih.",
    "en": "Access to the assistant and reference library for your selected discipline.",
    "ar": "الوصول إلى المساعد ومكتبة المراجع في التخصص المختار.",
  },
  "membership.total": {
    "id": "Total {price}",
    "en": "Total {price}",
    "ar": "الإجمالي {price}",
  },
  "membership.period_access": {
    "id": "Untuk {duration} akses",
    "en": "Access for {duration}",
    "ar": "الوصول لمدة {duration}",
  },
  "membership.goakal_continue": {
    "id": "Lanjutkan di GoAkal",
    "en": "Continue on GoAkal",
    "ar": "المتابعة عبر GoAkal",
  },
  "membership.doku_pay": {
    "id": "Bayar melalui DOKU",
    "en": "Pay with DOKU",
    "ar": "الدفع عبر DOKU",
  },
  "membership.bundle_summary": {
    "id": "{subtitle}\nTotal {price} · {duration}",
    "en": "{subtitle}\nTotal {price} · {duration}",
    "ar": "{subtitle}\nالإجمالي {price} · {duration}",
  },
  "membership.plan_scope": {
    "id": "Cakupan paket",
    "en": "Plan coverage",
    "ar": "محتويات الباقة",
  },
  "membership.ask_availability": {
    "id": "Tanyakan ketersediaan",
    "en": "Ask about availability",
    "ar": "الاستفسار عن التوفّر",
  },
  "membership.title": {"id": "Khidmah Maktabah", "en": "Scholarly Library Access", "ar": "إتاحة الخزانة العلمية"},
  "membership.eyebrow": {
    "id": "KEANGGOTAAN",
    "en": "MEMBERSHIP",
    "ar": "العضوية",
  },
  "membership.subtitle": {
    "id": "Pilih cakupan kajian dan masa akses yang sesuai dengan perjalanan belajar Anda.",
    "en": "Choose the study coverage and access period that suit your learning journey.",
    "ar": "اختر نطاق الدراسة ومدة الوصول المناسبين لرحلتك العلمية.",
  },
  "membership.login_subscribe": {
    "id": "Masuk untuk berlangganan",
    "en": "Sign in to subscribe",
    "ar": "تسجيل الدخول للاشتراك",
  },
  "membership.sync_goakal": {
    "id": "Sinkronkan GoAkal",
    "en": "Sync GoAkal",
    "ar": "مزامنة GoAkal",
  },
  "membership.redeem_access": {
    "id": "Tukar kode akses",
    "en": "Redeem access code",
    "ar": "استبدال رمز الوصول",
  },
  "membership.membership_scope": {
    "id": "Cakupan keanggotaan",
    "en": "Membership coverage",
    "ar": "نطاق العضوية",
  },
  "membership.thematic": {
    "id": "Paket tematik",
    "en": "Thematic plans",
    "ar": "باقات موضوعية",
  },
  "membership.one_discipline": {
    "id": "Satu bidang kajian",
    "en": "One study discipline",
    "ar": "تخصص دراسي واحد",
  },
  "membership.other_disciplines": {
    "id": "Bidang lainnya",
    "en": "Other disciplines",
    "ar": "تخصصات أخرى",
  },
  "membership.choose_discipline": {
    "id": "Pilih bidang",
    "en": "Choose a discipline",
    "ar": "اختر تخصصًا",
  },
  "membership.manual_renewal": {
    "id": "Langganan tidak diperpanjang otomatis. Anda dapat memperpanjangnya saat masa akses berakhir.",
    "en": "Subscriptions do not renew automatically. You can renew when your access period ends.",
    "ar": "لا تتجدّد الاشتراكات تلقائيًا. يمكنك التجديد عند انتهاء مدة الوصول.",
  },
  "membership.price_explanation": {
    "id": "Harga di atas adalah total untuk masa akses yang dipilih. Rincian akhir pembayaran ditampilkan oleh penyedia pembayaran. Gunakan email yang sama dengan akun OpenTurath saat membayar di GoAkal.",
    "en": "Prices above are the totals for the selected access period. The payment provider displays final payment details. Use the email associated with your OpenTurath account when paying on GoAkal.",
    "ar": "الأسعار أعلاه هي الإجمالي لمدة الوصول المختارة. يعرض مزوّد الدفع التفاصيل النهائية للدفع. استخدم البريد الإلكتروني المرتبط بحساب OpenTurath عند الدفع عبر GoAkal.",
  },
  "membership.awaiting_payment": {
    "id": "Menunggu konfirmasi pembayaran.",
    "en": "Awaiting payment confirmation.",
    "ar": "بانتظار تأكيد الدفع.",
  },
  "membership.payment_link_invalid": {
    "id": "Tautan pembayaran belum dapat digunakan. Tutup halaman ini dan coba buat pembayaran kembali.",
    "en": "This payment link cannot be used. Close this page and try creating a new payment.",
    "ar": "تعذّر استخدام رابط الدفع. أغلق هذه الصفحة وحاول إنشاء عملية دفع جديدة.",
  },
  "membership.login_checkout": {
    "id": "Masuk ke akun Anda sebelum membuka pembayaran.",
    "en": "Sign in to your account before opening checkout.",
    "ar": "سجّل الدخول إلى حسابك قبل فتح صفحة الدفع.",
  },
  "membership.polling_paused": {
    "id": "Konfirmasi otomatis dijeda. Pilih “Periksa status” untuk mencoba lagi.",
    "en": "Automatic confirmation is paused. Select “Check status” to try again.",
    "ar": "أُوقف التأكيد التلقائي مؤقتًا. اختر «التحقق من الحالة» للمحاولة مجددًا.",
  },
  "membership.account_changed": {
    "id": "Akun telah berubah. Buka ulang pembayaran dari akun Anda.",
    "en": "The account has changed. Reopen checkout from your account.",
    "ar": "تغيّر الحساب. أعد فتح صفحة الدفع من حسابك.",
  },
  "membership.payment_failed": {
    "id": "Pembayaran belum berhasil atau sudah berakhir. Akses belum diaktifkan.",
    "en": "Payment was unsuccessful or has expired. Access has not been activated.",
    "ar": "لم ينجح الدفع أو انتهت صلاحيته. لم يُفعّل الوصول.",
  },
  "membership.status_connection_failed": {
    "id": "Status belum dapat diperiksa. Periksa koneksi lalu coba lagi.",
    "en": "Status could not be checked. Check your connection and try again.",
    "ar": "تعذّر التحقق من الحالة. تحقّق من اتصالك ثم حاول مجددًا.",
  },
  "membership.payment_unconfirmed": {
    "id": "Pembayaran belum terkonfirmasi. Anda dapat memeriksa kembali.",
    "en": "Payment is not yet confirmed. You can check again.",
    "ar": "لم يُؤكّد الدفع بعد. يمكنك التحقق مجددًا.",
  },
  "membership.status_retry": {
    "id": "Status belum dapat diperiksa. Coba lagi.",
    "en": "Status could not be checked. Please try again.",
    "ar": "تعذّر التحقق من الحالة. حاول مجددًا.",
  },
  "membership.close_checkout_question": {
    "id": "Tutup pembayaran?",
    "en": "Close checkout?",
    "ar": "إغلاق صفحة الدفع؟",
  },
  "membership.close_checkout_explanation": {
    "id": "Menutup halaman ini tidak membatalkan transaksi. Jika sudah membayar, status dapat diperiksa kembali dari halaman akses.",
    "en": "Closing this page does not cancel the transaction. If you have paid, you can check the status again from the access page.",
    "ar": "إغلاق هذه الصفحة لا يلغي المعاملة. إذا أتممت الدفع، فيمكنك التحقق من الحالة مجددًا من صفحة الوصول.",
  },
  "membership.continue": {
    "id": "Lanjutkan",
    "en": "Continue",
    "ar": "متابعة",
  },
  "membership.close": {
    "id": "Tutup",
    "en": "Close",
    "ar": "إغلاق",
  },
  "membership.unsupported_destination": {
    "id": "Tujuan pembayaran ini tidak didukung. Pilih metode transfer atau QRIS yang tersedia di halaman pembayaran.",
    "en": "This payment destination is not supported. Choose a bank transfer or QRIS method available on the payment page.",
    "ar": "وجهة الدفع هذه غير مدعومة. اختر التحويل البنكي أو QRIS من الطرق المتاحة في صفحة الدفع.",
  },
  "membership.payment": {
    "id": "Pembayaran",
    "en": "Payment",
    "ar": "الدفع",
  },
  "membership.close_payment": {
    "id": "Tutup pembayaran",
    "en": "Close checkout",
    "ar": "إغلاق صفحة الدفع",
  },
  "membership.page_unavailable": {
    "id": "Halaman belum tersedia",
    "en": "Page unavailable",
    "ar": "الصفحة غير متاحة",
  },
  "membership.reload": {
    "id": "Muat ulang",
    "en": "Reload",
    "ar": "إعادة التحميل",
  },
  "membership.payment_load_failed": {
    "id": "Halaman pembayaran belum dapat dimuat. Periksa koneksi lalu coba lagi.",
    "en": "The payment page could not be loaded. Check your connection and try again.",
    "ar": "تعذّر تحميل صفحة الدفع. تحقّق من اتصالك ثم حاول مجددًا.",
  },
  "membership.goakal_after_payment": {
    "id": "Setelah membayar, tutup halaman ini lalu sinkronkan pembelian GoAkal.",
    "en": "After paying, close this page and sync your GoAkal purchases.",
    "ar": "بعد الدفع، أغلق هذه الصفحة ثم زامن مشتريات GoAkal.",
  },
  "membership.check_status": {
    "id": "Periksa status",
    "en": "Check status",
    "ar": "التحقق من الحالة",
  },
  "membership.payment_verified": {
    "id": "Pembayaran terverifikasi",
    "en": "Payment verified",
    "ar": "تم التحقق من الدفع",
  },
  "membership.access_after_continue": {
    "id": "Status akses akan diperiksa dari akun Anda setelah melanjutkan.",
    "en": "Your account access status will be checked after you continue.",
    "ar": "سيُتحقق من حالة الوصول في حسابك بعد المتابعة.",
  },
  "membership.code_not_found": {
    "id": "Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda.",
    "en": "Voucher code not found. Check how you entered the code.",
    "ar": "لم يُعثر على رمز القسيمة. تحقّق من كتابة الرمز.",
  },
  "membership.code_used": {
    "id": "Kode ini sudah pernah ditukarkan sebelumnya.",
    "en": "This code has already been redeemed.",
    "ar": "سبق استبدال هذا الرمز.",
  },
  "membership.code_quota": {
    "id": "Kuota penukaran untuk kode voucher ini sudah habis.",
    "en": "This voucher code has reached its redemption limit.",
    "ar": "بلغ رمز القسيمة هذا الحد الأقصى لمرات الاستبدال.",
  },
  "membership.code_expired": {
    "id": "Masa berlaku kode voucher ini telah berakhir.",
    "en": "This voucher code has expired.",
    "ar": "انتهت صلاحية رمز القسيمة هذا.",
  },
  "membership.code_inactive": {
    "id": "Kode voucher ini sudah tidak aktif.",
    "en": "This voucher code is no longer active.",
    "ar": "رمز القسيمة هذا لم يعد فعّالًا.",
  },
  "membership.code_format": {
    "id": "Format penulisan kode voucher belum sesuai.",
    "en": "The voucher code format is invalid.",
    "ar": "صيغة رمز القسيمة غير صحيحة.",
  },
  "membership.code_hint": {
    "id": "Masukkan kode voucher",
    "en": "Enter voucher code",
    "ar": "أدخل رمز القسيمة",
  },
  "membership.code_invalid": {
    "id": "Kode tidak valid atau sudah kedaluwarsa",
    "en": "The code is invalid or has expired",
    "ar": "الرمز غير صالح أو انتهت صلاحيته",
  },
  "membership.code_success": {
    "id": "Voucher berhasil diaktifkan. Akses telaah telah dibuka.",
    "en": "Voucher activated successfully. Study access has been opened.",
    "ar": "فُعّلت القسيمة بنجاح. أُتيح الوصول إلى الدراسة.",
  },
  "membership.use_voucher": {
    "id": "Gunakan voucher",
    "en": "Redeem voucher",
    "ar": "استبدال القسيمة",
  },
  "membership.code_instructions": {
    "id": "Masukkan kode voucher yang Anda miliki.",
    "en": "Enter your voucher code.",
    "ar": "أدخل رمز القسيمة الذي لديك.",
  },
  "membership.code_device_error": {
    "id": "Kode ini belum dapat digunakan pada perangkat Anda. Hubungi tim bantuan.",
    "en": "This code cannot currently be used on your device. Contact support.",
    "ar": "لا يمكن استخدام هذا الرمز على جهازك حاليًا. تواصل مع فريق الدعم.",
  },
  "membership.code_error": {
    "id": "Kode belum dapat ditukarkan. Periksa kode dan koneksi lalu coba lagi.",
    "en": "The code could not be redeemed. Check the code and your connection, then try again.",
    "ar": "تعذّر استبدال الرمز. تحقّق من الرمز واتصالك ثم حاول مجددًا.",
  },
};
