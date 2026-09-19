import '../legal_copy.dart';

/// Complete translations of the canonical policy text. Contact values remain
/// configuration references so installer changes reach every translation.
/// Known defaults are translated with constant conditionals; custom values
/// pass through verbatim, including operator names, addresses, and timings.
const legalDictionary = <String, Map<String, String>>{
  "1. Pengelola dan Cakupan Ketentuan": {
    "id": "1. Pengelola dan Cakupan Ketentuan",
    "en": "1. Operator and Scope",
    "ar": "١. الجهة المشغلة ونطاق الشروط",
  },
  "OpenTurath dikelola oleh ${LegalCopy.managerName}, beralamat di ${LegalCopy.managerAddress}, selanjutnya disebut \"kami\". Pengguna aplikasi disebut \"Anda\". Kontak layanan tersedia melalui ${LegalCopy.contactSupportEmail}.\n\nKetentuan ini mengatur penggunaan akun, asisten AI, katalog rujukan, Catatan, dan fitur berbayar yang disediakan melalui OpenTurath. Informasi paket yang ditampilkan sebelum pembelian, Kebijakan Pembayaran dan Pengembalian Dana, serta Panduan Penggunaan AI dan Pemeriksaan Rujukan menjadi bagian dari ketentuan penggunaan yang relevan.": {
    "id": "OpenTurath dikelola oleh ${LegalCopy.managerName}, beralamat di ${LegalCopy.managerAddress}, selanjutnya disebut \"kami\". Pengguna aplikasi disebut \"Anda\". Kontak layanan tersedia melalui ${LegalCopy.contactSupportEmail}.\n\nKetentuan ini mengatur penggunaan akun, asisten AI, katalog rujukan, Catatan, dan fitur berbayar yang disediakan melalui OpenTurath. Informasi paket yang ditampilkan sebelum pembelian, Kebijakan Pembayaran dan Pengembalian Dana, serta Panduan Penggunaan AI dan Pemeriksaan Rujukan menjadi bagian dari ketentuan penggunaan yang relevan.",
    "en": "OpenTurath is operated by ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'OpenTurath operator' : LegalCopy.managerName}, based in ${LegalCopy.managerAddress}, referred to as “we”. Users of the app are referred to as “you”. You can contact support at ${LegalCopy.contactSupportEmail}.\n\nThese terms govern accounts, AI assistants, the reference catalogue, Notes, and paid features provided through OpenTurath. Plan information displayed before purchase, the Payments and Refunds Policy, and the AI and Reference Verification Guide form part of the applicable terms of use.",
    "ar": "تتولى ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'الجهة المشغلة لـOpenTurath' : LegalCopy.managerName} إدارة OpenTurath، ومقرها ${LegalCopy.managerAddress == 'Indonesia' ? 'إندونيسيا' : LegalCopy.managerAddress}، ويُشار إليها بلفظ «نحن». ويُشار إلى مستخدم التطبيق بلفظ «أنت». يمكن التواصل مع الدعم عبر ${LegalCopy.contactSupportEmail}.\n\nتنظم هذه الشروط استخدام الحسابات ومساعدي الذكاء الاصطناعي وفهرس المراجع والملاحظات والميزات المدفوعة التي يوفرها OpenTurath. وتُعد معلومات الباقات المعروضة قبل الشراء، وسياسة الدفع واسترداد الأموال، ودليل استخدام الذكاء الاصطناعي والتحقق من المراجع، جزءًا من شروط الاستخدام ذات الصلة.",
  },
  "2. Persetujuan dan Persyaratan Pengguna": {
    "id": "2. Persetujuan dan Persyaratan Pengguna",
    "en": "2. Consent and User Eligibility",
    "ar": "٢. الموافقة وأهلية المستخدم",
  },
  "Sebelum membuat akun atau membeli paket, Anda diberi kesempatan membaca ketentuan yang berlaku. Penggunaan mandiri OpenTurath ditujukan bagi pengguna berusia sekurang-kurangnya 18 tahun. Anda juga harus memiliki kecakapan atau kewenangan yang diperlukan untuk membuat perjanjian dan melakukan pembayaran.\n\nAkses bagi pengguna di bawah 18 tahun belum dibuka melalui pendaftaran mandiri. Jika bertindak untuk lembaga, Anda harus berwenang mewakilinya. Pembelian individu tidak otomatis memberikan hak penggunaan bersama untuk seluruh anggota lembaga.": {
    "id": "Sebelum membuat akun atau membeli paket, Anda diberi kesempatan membaca ketentuan yang berlaku. Penggunaan mandiri OpenTurath ditujukan bagi pengguna berusia sekurang-kurangnya 18 tahun. Anda juga harus memiliki kecakapan atau kewenangan yang diperlukan untuk membuat perjanjian dan melakukan pembayaran.\n\nAkses bagi pengguna di bawah 18 tahun belum dibuka melalui pendaftaran mandiri. Jika bertindak untuk lembaga, Anda harus berwenang mewakilinya. Pembelian individu tidak otomatis memberikan hak penggunaan bersama untuk seluruh anggota lembaga.",
    "en": "Before creating an account or purchasing a plan, you are given an opportunity to read the applicable terms. Independent use of OpenTurath is intended for users aged 18 or older. You must also have the legal capacity or authority required to enter into an agreement and make payments.\n\nSelf-registration is not available to users under 18. If acting for an institution, you must be authorised to represent it. An individual purchase does not automatically grant shared use to all members of an institution.",
    "ar": "تتاح لك فرصة قراءة الشروط السارية قبل إنشاء حساب أو شراء باقة. يُتاح الاستخدام المستقل لـOpenTurath لمن بلغوا 18 عامًا على الأقل. ويلزم أيضًا توافر الأهلية أو الصلاحية اللازمة لإبرام الاتفاقات وإجراء المدفوعات.\n\nلا يتاح التسجيل الذاتي لمن هم دون 18 عامًا. وإذا كنت تتصرف نيابة عن مؤسسة، فيجب أن تكون مخوّلًا بتمثيلها. ولا يمنح الشراء الفردي تلقائيًا حق الاستخدام المشترك لجميع أعضاء المؤسسة.",
  },
  "3. Akun dan Keamanan Akses": {
    "id": "3. Akun dan Keamanan Akses",
    "en": "3. Accounts and Access Security",
    "ar": "٣. الحسابات وأمن الوصول",
  },
  "Gunakan informasi akun yang benar dan akses masuk yang menjadi hak Anda. Akun bersifat pribadi, kecuali suatu paket secara tertulis menyediakan penggunaan untuk beberapa orang.\n\nJaga perangkat dan akses masuk Anda. Jangan memberikan kata sandi atau kode sekali pakai kepada pihak lain. Laporkan dugaan penggunaan tanpa izin melalui ${LegalCopy.contactSupportEmail}. Laporan pengambilalihan akun akan diperiksa berdasarkan keadaan dan bukti yang tersedia.": {
    "id": "Gunakan informasi akun yang benar dan akses masuk yang menjadi hak Anda. Akun bersifat pribadi, kecuali suatu paket secara tertulis menyediakan penggunaan untuk beberapa orang.\n\nJaga perangkat dan akses masuk Anda. Jangan memberikan kata sandi atau kode sekali pakai kepada pihak lain. Laporkan dugaan penggunaan tanpa izin melalui ${LegalCopy.contactSupportEmail}. Laporan pengambilalihan akun akan diperiksa berdasarkan keadaan dan bukti yang tersedia.",
    "en": "Use accurate account information and sign-in credentials you are entitled to use. Accounts are personal unless a plan expressly permits use by several people in writing.\n\nKeep your device and sign-in access secure. Do not give passwords or one-time codes to anyone else. Report suspected unauthorised use to ${LegalCopy.contactSupportEmail}. Reports of account takeover will be reviewed based on the circumstances and available evidence.",
    "ar": "استخدم بيانات حساب صحيحة ووسائل دخول يحق لك استخدامها. الحسابات شخصية، ما لم تنص باقة كتابةً على إتاحة الاستخدام لعدة أشخاص.\n\nحافظ على أمان جهازك ووسائل الدخول. لا تعطِ كلمات المرور أو الرموز المستخدمة لمرة واحدة للآخرين. أبلغ عن الاشتباه في استخدام غير مصرّح به عبر ${LegalCopy.contactSupportEmail}. تُراجع بلاغات الاستيلاء على الحساب وفق الظروف والأدلة المتاحة.",
  },
  "4. Fungsi Layanan dan Batas Jawaban AI": {
    "id": "4. Fungsi Layanan dan Batas Jawaban AI",
    "en": "4. Service Purpose and Limits of AI Answers",
    "ar": "٤. وظيفة الخدمة وحدود إجابات الذكاء الاصطناعي",
  },
  "OpenTurath membantu penelusuran literatur, pembacaan kutipan, dan penyusunan bahan belajar. Jawaban dapat mengandung kesalahan pada penjelasan, atribusi, terjemahan, atau keterangan rujukan.\n\nPeriksa kutipan pada kitab dan edisi yang digunakan sebelum menjadikannya dasar tulisan, pengajaran, keputusan, atau penyampaian hukum kepada orang lain. Nomor halaman pada satu edisi tidak selalu sama dengan edisi lain.\n\nJawaban AI bukan merupakan fatwa resmi, penetapan hukum yang mengikat, atau pengganti bimbingan guru dan ulama yang berkompeten. Tidak ditemukannya rujukan dalam hasil pencarian berarti layanan belum menemukannya pada penelusuran tersebut, bukan bukti bahwa pembahasannya tidak ada.": {
    "id": "OpenTurath membantu penelusuran literatur, pembacaan kutipan, dan penyusunan bahan belajar. Jawaban dapat mengandung kesalahan pada penjelasan, atribusi, terjemahan, atau keterangan rujukan.\n\nPeriksa kutipan pada kitab dan edisi yang digunakan sebelum menjadikannya dasar tulisan, pengajaran, keputusan, atau penyampaian hukum kepada orang lain. Nomor halaman pada satu edisi tidak selalu sama dengan edisi lain.\n\nJawaban AI bukan merupakan fatwa resmi, penetapan hukum yang mengikat, atau pengganti bimbingan guru dan ulama yang berkompeten. Tidak ditemukannya rujukan dalam hasil pencarian berarti layanan belum menemukannya pada penelusuran tersebut, bukan bukti bahwa pembahasannya tidak ada.",
    "en": "OpenTurath assists with exploring literature, reading quotations, and preparing study materials. Answers may contain errors in explanations, attribution, translation, or reference details.\n\nCheck quotations against the book and edition used before relying on them in writing, teaching, decisions, or conveying rulings to others. Page numbers may differ between editions.\n\nAI answers are not official fatwas, binding rulings, or a substitute for guidance from qualified teachers and scholars. An absent search result means the service did not find the reference in that search; it does not prove that the discussion does not exist.",
    "ar": "يساعد OpenTurath على البحث في المؤلفات وقراءة النقول وإعداد مواد الدراسة. وقد تتضمن الإجابات أخطاء في الشرح أو العزو أو الترجمة أو بيانات المراجع.\n\nتحقق من النقول في الكتاب والطبعة المستخدمة قبل الاعتماد عليها في الكتابة أو التدريس أو اتخاذ القرارات أو نقل الأحكام للآخرين. وقد تختلف أرقام الصفحات بين الطبعات.\n\nإجابات الذكاء الاصطناعي ليست فتاوى رسمية ولا أحكامًا ملزمة ولا بديلًا عن إرشاد المعلمين والعلماء المؤهلين. وعدم ظهور مرجع في نتائج البحث يعني أن الخدمة لم تعثر عليه في ذلك البحث، ولا يثبت عدم وجود المسألة في المصادر.",
  },
  "5. Paket, Pembayaran, dan Masa Akses": {
    "id": "5. Paket, Pembayaran, dan Masa Akses",
    "en": "5. Plans, Payments, and Access Periods",
    "ar": "٥. الباقات والدفع ومدة الوصول",
  },
  "Harga, cakupan asisten, masa akses, batas penggunaan, kebutuhan akun pihak ketiga, serta biaya yang berlaku ditampilkan sebelum Anda membayar.\n\nLangganan diperpanjang secara manual. Kami tidak melakukan penagihan berulang otomatis (auto-debit) dari pembelian paket ini.\n\nMasa akses dimulai ketika aktivasi berhasil dan tanggal berakhir ditampilkan pada akun. Pembayaran diproses melalui DOKU menurut metode yang tersedia pada saat transaksi. Keberhasilan pembayaran dan aktivasi akses adalah dua status yang berbeda. Jika dana telah dibayarkan namun langganan belum aktif, hubungi bantuan dengan nomor transaksi.": {
    "id": "Harga, cakupan asisten, masa akses, batas penggunaan, kebutuhan akun pihak ketiga, serta biaya yang berlaku ditampilkan sebelum Anda membayar.\n\nLangganan diperpanjang secara manual. Kami tidak melakukan penagihan berulang otomatis (auto-debit) dari pembelian paket ini.\n\nMasa akses dimulai ketika aktivasi berhasil dan tanggal berakhir ditampilkan pada akun. Pembayaran diproses melalui DOKU menurut metode yang tersedia pada saat transaksi. Keberhasilan pembayaran dan aktivasi akses adalah dua status yang berbeda. Jika dana telah dibayarkan namun langganan belum aktif, hubungi bantuan dengan nomor transaksi.",
    "en": "Prices, assistant coverage, access periods, usage limits, third-party account requirements, and applicable fees are shown before payment.\n\nSubscriptions renew manually. We do not make automatic recurring charges or direct debits arising from this plan purchase.\n\nAccess starts when activation succeeds, and the expiry date is displayed in your account. Payments are processed through DOKU using the methods available at the time of the transaction. Successful payment and access activation are separate statuses. If you have paid but your subscription is not active, contact support with your transaction number.",
    "ar": "تُعرض الأسعار ونطاق المساعدين ومدة الوصول وحدود الاستخدام ومتطلبات حسابات الجهات الخارجية والرسوم السارية قبل الدفع.\n\nتُجدّد الاشتراكات يدويًا. ولا نجري خصمًا دوريًا تلقائيًا نتيجة شراء هذه الباقة.\n\nتبدأ مدة الوصول عند نجاح التفعيل، ويظهر تاريخ انتهائها في الحساب. تُعالج المدفوعات عبر DOKU بالوسائل المتاحة وقت المعاملة. نجاح الدفع وتفعيل الوصول حالتان منفصلتان. إذا دفعت ولم يُفعّل اشتراكك، فتواصل مع الدعم مع ذكر رقم المعاملة.",
  },
  "6. Layanan Pihak Ketiga (Google NotebookLM)": {
    "id": "6. Layanan Pihak Ketiga (Google NotebookLM)",
    "en": "6. Third-Party Services (Google NotebookLM)",
    "ar": "٦. خدمات الجهات الخارجية (Google NotebookLM)",
  },
  "Fitur percakapan menggunakan NotebookLM dari Google. Aksesnya dapat bergantung pada akun, wilayah, batas penggunaan, dan ketentuan penyedia yang berlaku untuk Anda. Pembelian OpenTurath tidak dengan sendirinya mengubah jenis langganan atau hak akses akun Google Anda.\n\nJika perubahan layanan pihak ketiga menyebabkan fitur berbayar tidak dapat diberikan sesuai yang ditawarkan, kami akan menilai pemulihan akses, penggantian layanan yang Anda setujui, atau pengembalian dana sesuai hak Anda.": {
    "id": "Fitur percakapan menggunakan NotebookLM dari Google. Aksesnya dapat bergantung pada akun, wilayah, batas penggunaan, dan ketentuan penyedia yang berlaku untuk Anda. Pembelian OpenTurath tidak dengan sendirinya mengubah jenis langganan atau hak akses akun Google Anda.\n\nJika perubahan layanan pihak ketiga menyebabkan fitur berbayar tidak dapat diberikan sesuai yang ditawarkan, kami akan menilai pemulihan akses, penggantian layanan yang Anda setujui, atau pengembalian dana sesuai hak Anda.",
    "en": "The conversation feature uses Google NotebookLM. Access may depend on your account, region, usage limits, and the provider’s terms applicable to you. Purchasing OpenTurath does not itself change the subscription type or access rights of your Google account.\n\nIf changes to a third-party service prevent us from providing a paid feature as offered, we will assess restoration of access, a replacement service you agree to, or a refund in accordance with your rights.",
    "ar": "تستخدم ميزة المحادثة خدمة Google NotebookLM. وقد يعتمد الوصول عليها على الحساب والمنطقة وحدود الاستخدام وشروط المزوّد السارية عليك. شراء OpenTurath لا يغيّر بذاته نوع اشتراك حساب Google أو حقوق الوصول فيه.\n\nإذا حالت تغييرات في خدمة جهة خارجية دون توفير ميزة مدفوعة كما عُرضت، فسننظر في استعادة الوصول أو تقديم خدمة بديلة توافق عليها أو رد الأموال وفق حقوقك.",
  },
  "7. Penggunaan yang Diperbolehkan dan Dilarang": {
    "id": "7. Penggunaan yang Diperbolehkan dan Dilarang",
    "en": "7. Permitted and Prohibited Use",
    "ar": "٧. الاستخدام المسموح والمحظور",
  },
  "Anda dapat menggunakan layanan untuk belajar, menyiapkan pengajaran, dan melakukan penelusuran sesuai paket yang dimiliki. Penggunaan hasilnya tetap harus memperhatikan hak cipta, ketepatan atribusi, serta adab keilmuan.\n\nDilarang menggunakan OpenTurath untuk mengambil alih akun, menghindari pembatasan akses secara tidak sah, menyebarkan perangkat lunak berbahaya, atau menjual kembali akses berbayar kepada pihak lain.\n\nDilarang membuat atau menyebarkan kutipan yang sengaja dipalsukan dan diatasnamakan kepada ulama atau sumber tertentu. Pembahasan ilmiah yang sah, termasuk perbedaan pendapat dan kritik terhadap suatu penafsiran, tidak dengan sendirinya merupakan pelanggaran.": {
    "id": "Anda dapat menggunakan layanan untuk belajar, menyiapkan pengajaran, dan melakukan penelusuran sesuai paket yang dimiliki. Penggunaan hasilnya tetap harus memperhatikan hak cipta, ketepatan atribusi, serta adab keilmuan.\n\nDilarang menggunakan OpenTurath untuk mengambil alih akun, menghindari pembatasan akses secara tidak sah, menyebarkan perangkat lunak berbahaya, atau menjual kembali akses berbayar kepada pihak lain.\n\nDilarang membuat atau menyebarkan kutipan yang sengaja dipalsukan dan diatasnamakan kepada ulama atau sumber tertentu. Pembahasan ilmiah yang sah, termasuk perbedaan pendapat dan kritik terhadap suatu penafsiran, tidak dengan sendirinya merupakan pelanggaran.",
    "en": "You may use the service to study, prepare teaching materials, and conduct research within your plan. Use of its results must respect copyright, accurate attribution, and scholarly conduct.\n\nYou must not use OpenTurath to take over accounts, unlawfully bypass access restrictions, distribute malicious software, or resell paid access to others.\n\nCreating or distributing deliberately fabricated quotations attributed to scholars or particular sources is prohibited. Legitimate scholarly discussion, including disagreement and criticism of an interpretation, is not in itself a violation.",
    "ar": "يجوز استخدام الخدمة للدراسة وإعداد التدريس والبحث ضمن الباقة التي تملكها. ويجب مراعاة حقوق النشر وصحة العزو وآداب العلم عند استخدام النتائج.\n\nيُحظر استخدام OpenTurath للاستيلاء على الحسابات أو تجاوز قيود الوصول بغير حق أو نشر البرمجيات الضارة أو إعادة بيع الوصول المدفوع للآخرين.\n\nيُحظر إنشاء نقول مختلقة عمدًا أو نشرها ونسبتها إلى العلماء أو إلى مصادر معينة. ولا يُعد النقاش العلمي المشروع، بما فيه الاختلاف ونقد التأويل، مخالفة بحد ذاته.",
  },
  "8. Catatan dan Materi Pengguna": {
    "id": "8. Catatan dan Materi Pengguna",
    "en": "8. Notes and User Materials",
    "ar": "٨. الملاحظات ومواد المستخدم",
  },
  "Hak atas tulisan atau catatan yang Anda buat tetap berada pada Anda. Anda memberi izin terbatas kepada kami untuk memproses dan menyimpan materi tersebut semata-mata untuk menjalankan fitur yang Anda pilih. Izin ini tidak memindahkan kepemilikan dan kami tidak menjual atau menerbitkan catatan pribadi Anda.\n\nCatatan disimpan pada perangkat. Catatan dan penanda rujukan yang terhubung ke akun juga disinkronkan melalui Firebase saat layanan tersedia. Gunakan fitur salin atau berbagi untuk mencadangkan materi penting.": {
    "id": "Hak atas tulisan atau catatan yang Anda buat tetap berada pada Anda. Anda memberi izin terbatas kepada kami untuk memproses dan menyimpan materi tersebut semata-mata untuk menjalankan fitur yang Anda pilih. Izin ini tidak memindahkan kepemilikan dan kami tidak menjual atau menerbitkan catatan pribadi Anda.\n\nCatatan disimpan pada perangkat. Catatan dan penanda rujukan yang terhubung ke akun juga disinkronkan melalui Firebase saat layanan tersedia. Gunakan fitur salin atau berbagi untuk mencadangkan materi penting.",
    "en": "You retain the rights to the writing and notes you create. You grant us limited permission to process and store these materials solely to operate the features you choose. This permission does not transfer ownership, and we do not sell or publish your private notes.\n\nNotes are stored on your device. Account-linked notes and reference markers also sync through Firebase when the service is available. Use copy or share to back up important materials.",
    "ar": "تظل حقوق الكتابات والملاحظات التي تنشئها لك. وتمنحنا إذنًا محدودًا بمعالجة هذه المواد وتخزينها لتشغيل الميزات التي تختارها فحسب. ولا ينقل هذا الإذن الملكية، ولا نبيع ملاحظاتك الخاصة أو ننشرها.\n\nتُحفظ الملاحظات على جهازك. وتُزامن الملاحظات وعلامات المراجع المرتبطة بالحساب أيضًا عبر Firebase عند توافر الخدمة. استخدم النسخ أو المشاركة للاحتفاظ بنسخة احتياطية من المواد المهمة.",
  },
  "9. Hak atas Aplikasi dan Kitab": {
    "id": "9. Hak atas Aplikasi dan Kitab",
    "en": "9. Rights in the App and Books",
    "ar": "٩. حقوق التطبيق والكتب",
  },
  "Hak atas perangkat lunak, tampilan, dan merek OpenTurath tetap berada pada pemegang haknya. Materi kitab, terjemahan, dan tahkik mengikuti status hak masing-masing.\n\nAkses berbayar tidak memindahkan hak cipta atas kitab atau memberi izin umum untuk menyebarluaskan seluruh isi kitab secara komersial. Penggunaan kutipan harus memperhatikan batas penggunaan wajar dan kewajiban atribusi.": {
    "id": "Hak atas perangkat lunak, tampilan, dan merek OpenTurath tetap berada pada pemegang haknya. Materi kitab, terjemahan, dan tahkik mengikuti status hak masing-masing.\n\nAkses berbayar tidak memindahkan hak cipta atas kitab atau memberi izin umum untuk menyebarluaskan seluruh isi kitab secara komersial. Penggunaan kutipan harus memperhatikan batas penggunaan wajar dan kewajiban atribusi.",
    "en": "Rights in OpenTurath software, design, and branding remain with their respective holders. Books, translations, and critical editions retain their own rights status.\n\nPaid access does not transfer copyright in books or grant general permission to commercially redistribute their entire contents. Quotations must respect applicable fair-use limits and attribution requirements.",
    "ar": "تبقى حقوق برمجيات OpenTurath وتصميمه وعلامته لدى أصحابها. وتخضع الكتب والترجمات والتحقيقات لحالة الحقوق الخاصة بكل منها.\n\nلا ينقل الوصول المدفوع حقوق نشر الكتب ولا يمنح إذنًا عامًا بإعادة نشر محتواها كاملًا لأغراض تجارية. ويجب مراعاة حدود الاستخدام العادل ومتطلبات العزو عند الاقتباس.",
  },
  "10. Ketersediaan dan Perubahan Fitur": {
    "id": "10. Ketersediaan dan Perubahan Fitur",
    "en": "10. Availability and Feature Changes",
    "ar": "١٠. توافر الخدمة وتغييرات الميزات",
  },
  "Layanan dapat mengalami pemeliharaan berkala atau pembaruan teknis. Kami berupaya memberi pemberitahuan mengenai pemeliharaan terencana.\n\nPerubahan yang secara material mengurangi manfaat paket berbayar akan disertai pilihan penyelesaian yang wajar. Kami tidak menggunakan perubahan ketentuan untuk menghapus hak yang sudah timbul dari pembelian Anda.": {
    "id": "Layanan dapat mengalami pemeliharaan berkala atau pembaruan teknis. Kami berupaya memberi pemberitahuan mengenai pemeliharaan terencana.\n\nPerubahan yang secara material mengurangi manfaat paket berbayar akan disertai pilihan penyelesaian yang wajar. Kami tidak menggunakan perubahan ketentuan untuk menghapus hak yang sudah timbul dari pembelian Anda.",
    "en": "The service may undergo periodic maintenance or technical updates. We endeavour to give notice of planned maintenance.\n\nChanges that materially reduce the benefits of a paid plan will be accompanied by reasonable options for resolution. We do not use changes to these terms to remove rights that have already arisen from your purchase.",
    "ar": "قد تخضع الخدمة لصيانة دورية أو تحديثات تقنية. ونسعى إلى الإشعار بالصيانة المقررة مسبقًا.\n\nتُرفق التغييرات التي تُنقص منافع الباقة المدفوعة بصورة جوهرية بخيارات تسوية معقولة. ولا نستخدم تعديل الشروط لإسقاط حقوق نشأت بالفعل عن شرائك.",
  },
  "11. Pembatasan dan Penutupan Akun": {
    "id": "11. Pembatasan dan Penutupan Akun",
    "en": "11. Account Restrictions and Closure",
    "ar": "١١. تقييد الحساب وإغلاقه",
  },
  "Kami dapat membatasi akses jika terdapat dasar yang wajar mengenai pelanggaran serius, risiko keamanan, atau penggunaan tanpa hak. Tindakan disesuaikan dengan tingkat masalah, mulai dari peringatan, penghentian sementara, hingga penutupan akun.\n\nJika keadaan memungkinkan, kami menyampaikan alasan dan memberi kesempatan klarifikasi melalui ${LegalCopy.contactSupportEmail}.": {
    "id": "Kami dapat membatasi akses jika terdapat dasar yang wajar mengenai pelanggaran serius, risiko keamanan, atau penggunaan tanpa hak. Tindakan disesuaikan dengan tingkat masalah, mulai dari peringatan, penghentian sementara, hingga penutupan akun.\n\nJika keadaan memungkinkan, kami menyampaikan alasan dan memberi kesempatan klarifikasi melalui ${LegalCopy.contactSupportEmail}.",
    "en": "We may restrict access where there are reasonable grounds concerning a serious violation, a security risk, or unauthorised use. Measures are proportionate to the issue, ranging from a warning to temporary suspension or account closure.\n\nWhere circumstances allow, we provide reasons and an opportunity to clarify the matter through ${LegalCopy.contactSupportEmail}.",
    "ar": "يجوز لنا تقييد الوصول عند وجود أساس معقول يتعلق بمخالفة جسيمة أو خطر أمني أو استخدام بغير حق. وتتناسب الإجراءات مع حجم المشكلة، من التنبيه إلى التعليق المؤقت أو إغلاق الحساب.\n\nمتى سمحت الظروف، نبيّن الأسباب ونتيح فرصة لتوضيح الأمر عبر ${LegalCopy.contactSupportEmail}.",
  },
  "12. Tanggung Jawab dan Hak Pengguna": {
    "id": "12. Tanggung Jawab dan Hak Pengguna",
    "en": "12. Responsibilities and User Rights",
    "ar": "١٢. المسؤوليات وحقوق المستخدم",
  },
  "Kami bertanggung jawab menyediakan layanan sesuai perjanjian dan hukum yang berlaku. Penjelasan mengenai keterbatasan AI tidak menghapus kewajiban kami untuk memberikan informasi yang benar, menangani keluhan, atau menyelesaikan layanan berbayar.\n\nAnda bertanggung jawab menilai kesesuaian hasil untuk tujuan penggunaannya dan memeriksa sumber sebelum mengambil kesimpulan. Tidak ada ketentuan yang meniadakan hak konsumen yang dilindungi undang-undang.": {
    "id": "Kami bertanggung jawab menyediakan layanan sesuai perjanjian dan hukum yang berlaku. Penjelasan mengenai keterbatasan AI tidak menghapus kewajiban kami untuk memberikan informasi yang benar, menangani keluhan, atau menyelesaikan layanan berbayar.\n\nAnda bertanggung jawab menilai kesesuaian hasil untuk tujuan penggunaannya dan memeriksa sumber sebelum mengambil kesimpulan. Tidak ada ketentuan yang meniadakan hak konsumen yang dilindungi undang-undang.",
    "en": "We are responsible for providing the service in accordance with the agreement and applicable law. Explaining AI limitations does not remove our obligations to provide accurate information, address complaints, or resolve issues with paid services.\n\nYou are responsible for assessing whether results suit your intended use and checking sources before drawing conclusions. No provision removes consumer rights protected by law.",
    "ar": "نحن مسؤولون عن توفير الخدمة وفق الاتفاق والقانون الساري. ولا يسقط بيان حدود الذكاء الاصطناعي التزامنا بتقديم معلومات صحيحة أو معالجة الشكاوى أو تسوية مشكلات الخدمات المدفوعة.\n\nأنت مسؤول عن تقييم ملاءمة النتائج لغرض استخدامها ومراجعة المصادر قبل استخلاص النتائج. ولا يلغي أي شرط حقوق المستهلك التي يحميها القانون.",
  },
  "13. Pengaduan dan Musyawarah": {
    "id": "13. Pengaduan dan Musyawarah",
    "en": "13. Complaints and Amicable Resolution",
    "ar": "١٣. الشكاوى والتسوية بالتشاور",
  },
  "Hubungi ${LegalCopy.contactSupportEmail} dengan penjelasan masalah dan informasi yang relevan. Kami akan mencatat pengaduan, menyampaikan perkembangan penanganan dalam ${LegalCopy.supportSla}, dan mengupayakan penyelesaian secara musyawarah.\n\nKetentuan ini tunduk pada hukum Republik Indonesia.": {
    "id": "Hubungi ${LegalCopy.contactSupportEmail} dengan penjelasan masalah dan informasi yang relevan. Kami akan mencatat pengaduan, menyampaikan perkembangan penanganan dalam ${LegalCopy.supportSla}, dan mengupayakan penyelesaian secara musyawarah.\n\nKetentuan ini tunduk pada hukum Republik Indonesia.",
    "en": "Contact ${LegalCopy.contactSupportEmail} with a description of the problem and relevant information. We will record the complaint, provide a progress update within ${LegalCopy.supportSla == '2 (dua) hari kerja' ? '2 (two) working days' : LegalCopy.supportSla}, and seek an amicable resolution.\n\nThese terms are governed by the laws of the Republic of Indonesia.",
    "ar": "تواصل عبر ${LegalCopy.contactSupportEmail} مع شرح المشكلة والمعلومات ذات الصلة. سنسجّل الشكوى، ونطلعك على تقدم معالجتها خلال ${LegalCopy.supportSla == '2 (dua) hari kerja' ? 'يومي عمل (2)' : LegalCopy.supportSla}، ونسعى إلى تسويتها بالتشاور.\n\nتخضع هذه الشروط لقوانين جمهورية إندونيسيا.",
  },
  "14. Perubahan Ketentuan dan Kontak": {
    "id": "14. Perubahan Ketentuan dan Kontak",
    "en": "14. Changes to Terms and Contact Details",
    "ar": "١٤. تعديل الشروط وبيانات التواصل",
  },
  "Versi dokumen: ${LegalCopy.documentVersion} (Berlaku sejak ${LegalCopy.effectiveDate}).\n\nPerubahan penting akan diberitahukan sebelum berlaku dan tidak berlaku surut untuk menghilangkan hak yang telah timbul.\n\nPengelola: ${LegalCopy.managerName}\nAlamat: ${LegalCopy.managerAddress}\nBantuan: ${LegalCopy.contactSupportEmail}\nPrivasi: ${LegalCopy.contactPrivacyEmail}\nHak Cipta: ${LegalCopy.contactCopyrightEmail}": {
    "id": "Versi dokumen: ${LegalCopy.documentVersion} (Berlaku sejak ${LegalCopy.effectiveDate}).\n\nPerubahan penting akan diberitahukan sebelum berlaku dan tidak berlaku surut untuk menghilangkan hak yang telah timbul.\n\nPengelola: ${LegalCopy.managerName}\nAlamat: ${LegalCopy.managerAddress}\nBantuan: ${LegalCopy.contactSupportEmail}\nPrivasi: ${LegalCopy.contactPrivacyEmail}\nHak Cipta: ${LegalCopy.contactCopyrightEmail}",
    "en": "Document version: ${LegalCopy.documentVersion} (Effective ${LegalCopy.effectiveDate}).\n\nSignificant changes will be communicated before they take effect and will not apply retrospectively to remove rights that have already arisen.\n\nOperator: ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'OpenTurath operator' : LegalCopy.managerName}\nAddress: ${LegalCopy.managerAddress}\nSupport: ${LegalCopy.contactSupportEmail}\nPrivacy: ${LegalCopy.contactPrivacyEmail}\nCopyright: ${LegalCopy.contactCopyrightEmail}",
    "ar": "إصدار الوثيقة: ${LegalCopy.documentVersion} (سارية منذ ${LegalCopy.effectiveDate == '13 September 2026' ? '13 سبتمبر 2026' : LegalCopy.effectiveDate}).\n\nسيُبلّغ عن التغييرات المهمة قبل سريانها، ولن تُطبّق بأثر رجعي لإسقاط حقوق نشأت بالفعل.\n\nالجهة المشغلة: ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'الجهة المشغلة لـOpenTurath' : LegalCopy.managerName}\nالعنوان: ${LegalCopy.managerAddress == 'Indonesia' ? 'إندونيسيا' : LegalCopy.managerAddress}\nالدعم: ${LegalCopy.contactSupportEmail}\nالخصوصية: ${LegalCopy.contactPrivacyEmail}\nحقوق النشر: ${LegalCopy.contactCopyrightEmail}",
  },
  "1. Pengelola Data dan Ruang Lingkup": {
    "id": "1. Pengelola Data dan Ruang Lingkup",
    "en": "1. Data Controller and Scope",
    "ar": "١. الجهة المسؤولة عن البيانات ونطاق السياسة",
  },
  "Kebijakan Privasi ini menjelaskan pemrosesan data pribadi saat Anda menggunakan aplikasi OpenTurath, pembayaran, dan bantuan layanan. ${LegalCopy.managerName} (${LegalCopy.managerAddress}) bertanggung jawab atas pemrosesan data yang tujuan dan caranya ditentukan oleh OpenTurath, sesuai UU Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi.\n\nUntuk pertanyaan privasi, hubungi ${LegalCopy.contactPrivacyEmail}.": {
    "id": "Kebijakan Privasi ini menjelaskan pemrosesan data pribadi saat Anda menggunakan aplikasi OpenTurath, pembayaran, dan bantuan layanan. ${LegalCopy.managerName} (${LegalCopy.managerAddress}) bertanggung jawab atas pemrosesan data yang tujuan dan caranya ditentukan oleh OpenTurath, sesuai UU Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi.\n\nUntuk pertanyaan privasi, hubungi ${LegalCopy.contactPrivacyEmail}.",
    "en": "This Privacy Policy explains how personal data is processed when you use the OpenTurath app, payments, and support. ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'OpenTurath operator' : LegalCopy.managerName} (${LegalCopy.managerAddress}) is responsible for processing whose purposes and means are determined by OpenTurath, in accordance with Law No. 27 of 2022 on Personal Data Protection.\n\nFor privacy questions, contact ${LegalCopy.contactPrivacyEmail}.",
    "ar": "توضح سياسة الخصوصية هذه معالجة البيانات الشخصية عند استخدام تطبيق OpenTurath والدفع وخدمات الدعم. تتولى ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'الجهة المشغلة لـOpenTurath' : LegalCopy.managerName} (${LegalCopy.managerAddress == 'Indonesia' ? 'إندونيسيا' : LegalCopy.managerAddress}) مسؤولية المعالجة التي يحدد OpenTurath أغراضها ووسائلها، وفق القانون رقم 27 لسنة 2022 بشأن حماية البيانات الشخصية.\n\nلاستفسارات الخصوصية، تواصل عبر ${LegalCopy.contactPrivacyEmail}.",
  },
  "2. Data yang Diproses": {
    "id": "2. Data yang Diproses",
    "en": "2. Data We Process",
    "ar": "٢. البيانات التي نعالجها",
  },
  "Kami memproses data sesuai fitur yang Anda gunakan:\n• Akun: Nama, alamat email, dan identitas profil publik dari akun Google untuk autentikasi dan personalisasi.\n• Langganan: Paket yang dipilih, status, masa aktif, dan penggunaan voucher.\n• Pembayaran: Nomor transaksi, jumlah pembayaran, metode, waktu, dan status dari penyedia DOKU.\n• Kontak Transaksi: Nomor WhatsApp/telepon yang Anda berikan saat pembayaran untuk pengiriman informasi aktivasi.\n• Percakapan: Pertanyaan, jawaban, dan konteks percakapan yang diproses melalui sesi Google NotebookLM.\n• Catatan: Isi catatan, kutipan, dan rujukan pada perangkat serta salinan yang disinkronkan melalui Firebase untuk akun yang masuk.\n• Bantuan: Alamat kontak, isi pengaduan, nomor transaksi, dan lampiran tangkapan layar untuk penanganan masalah.\n• Sesi Teknis: Token dan cookie untuk mempertahankan sesi autentikasi.\n• Identitas Instalasi: Pengenal acak yang disimpan pada aplikasi, merek dan model perangkat, serta hasil pemeriksaan perangkat jika tersedia. Pengenal ini bukan bukti identitas perangkat keras.\n• Diagnostik: Jenis kesalahan, konteks fitur, waktu, platform, dan jejak kejadian terbatas yang dikirim ke Firebase. Nilai rahasia dan alamat email disamarkan.": {
    "id": "Kami memproses data sesuai fitur yang Anda gunakan:\n• Akun: Nama, alamat email, dan identitas profil publik dari akun Google untuk autentikasi dan personalisasi.\n• Langganan: Paket yang dipilih, status, masa aktif, dan penggunaan voucher.\n• Pembayaran: Nomor transaksi, jumlah pembayaran, metode, waktu, dan status dari penyedia DOKU.\n• Kontak Transaksi: Nomor WhatsApp/telepon yang Anda berikan saat pembayaran untuk pengiriman informasi aktivasi.\n• Percakapan: Pertanyaan, jawaban, dan konteks percakapan yang diproses melalui sesi Google NotebookLM.\n• Catatan: Isi catatan, kutipan, dan rujukan pada perangkat serta salinan yang disinkronkan melalui Firebase untuk akun yang masuk.\n• Bantuan: Alamat kontak, isi pengaduan, nomor transaksi, dan lampiran tangkapan layar untuk penanganan masalah.\n• Sesi Teknis: Token dan cookie untuk mempertahankan sesi autentikasi.\n• Identitas Instalasi: Pengenal acak yang disimpan pada aplikasi, merek dan model perangkat, serta hasil pemeriksaan perangkat jika tersedia. Pengenal ini bukan bukti identitas perangkat keras.\n• Diagnostik: Jenis kesalahan, konteks fitur, waktu, platform, dan jejak kejadian terbatas yang dikirim ke Firebase. Nilai rahasia dan alamat email disamarkan.",
    "en": "We process data according to the features you use:\n• Account: Name, email address, and public profile identity from your Google account for authentication and personalisation.\n• Subscription: Selected plan, status, access period, and voucher use.\n• Payment: Transaction number, amount, method, time, and status from DOKU.\n• Transaction contact: The WhatsApp/phone number you provide at payment for activation information.\n• Conversations: Questions, answers, and conversation context processed through your Google NotebookLM session.\n• Notes: Notes, quotations, and references on your device, and copies synced through Firebase for signed-in accounts.\n• Support: Contact details, complaint content, transaction numbers, and screenshot attachments for resolving issues.\n• Technical session: Tokens and cookies that maintain authentication sessions.\n• Installation identity: A random identifier stored in the app, device make and model, and device check results where available. This identifier is not proof of hardware identity.\n• Diagnostics: Error types, feature context, time, platform, and limited event traces sent to Firebase. Secret values and email addresses are masked.",
    "ar": "نعالج البيانات بحسب الميزات التي تستخدمها:\n• الحساب: الاسم وعنوان البريد الإلكتروني وبيانات الملف العام من حساب Google، للتحقق من الهوية وتخصيص الاستخدام.\n• الاشتراك: الباقة المختارة والحالة ومدة الوصول واستخدام القسائم.\n• الدفع: رقم المعاملة والمبلغ والطريقة والوقت والحالة الواردة من DOKU.\n• بيانات التواصل للمعاملة: رقم WhatsApp أو الهاتف الذي تقدمه عند الدفع لإرسال معلومات التفعيل.\n• المحادثات: الأسئلة والإجابات وسياق المحادثة التي تُعالج عبر جلسة Google NotebookLM.\n• الملاحظات: محتوى الملاحظات والنقول والمراجع على الجهاز، والنسخ المزامنة عبر Firebase للحسابات المسجّل دخولها.\n• الدعم: بيانات التواصل ومحتوى الشكوى وأرقام المعاملات ولقطات الشاشة المرفقة لمعالجة المشكلة.\n• الجلسة التقنية: الرموز وملفات تعريف الارتباط اللازمة لاستمرار جلسة التحقق من الهوية.\n• معرّف التثبيت: معرّف عشوائي محفوظ في التطبيق، وعلامة الجهاز وطرازه، ونتائج فحص الجهاز إن توفرت. ولا يُعد هذا المعرّف دليلًا على هوية العتاد.\n• التشخيص: أنواع الأخطاء وسياق الميزة والوقت والمنصة وسجل محدود للأحداث يُرسل إلى Firebase. تُحجب القيم السرية وعناوين البريد الإلكتروني.",
  },
  "3. Tujuan dan Dasar Pemrosesan": {
    "id": "3. Tujuan dan Dasar Pemrosesan",
    "en": "3. Purposes and Grounds for Processing",
    "ar": "٣. أغراض المعالجة وأسسها",
  },
  "Data akun dan transaksi diproses untuk menyediakan layanan yang Anda minta, mengelola langganan, dan melaksanakan perjanjian. Pencatatan transaksi juga diperlukan untuk memenuhi kewajiban hukum administrasi perpajakan dan transaksi keuangan.\n\nKami tidak menjual data pribadi Anda kepada pihak ketiga manapun, dan tidak menggunakan percakapan Anda untuk iklan bertarget.": {
    "id": "Data akun dan transaksi diproses untuk menyediakan layanan yang Anda minta, mengelola langganan, dan melaksanakan perjanjian. Pencatatan transaksi juga diperlukan untuk memenuhi kewajiban hukum administrasi perpajakan dan transaksi keuangan.\n\nKami tidak menjual data pribadi Anda kepada pihak ketiga manapun, dan tidak menggunakan percakapan Anda untuk iklan bertarget.",
    "en": "Account and transaction data are processed to provide the service you request, manage subscriptions, and perform the agreement. Transaction records are also required to meet legal obligations concerning tax administration and financial transactions.\n\nWe do not sell your personal data to any third party or use your conversations for targeted advertising.",
    "ar": "تُعالج بيانات الحساب والمعاملات لتقديم الخدمة التي تطلبها وإدارة الاشتراكات وتنفيذ الاتفاق. ويلزم أيضًا تسجيل المعاملات للوفاء بالالتزامات القانونية المتعلقة بالإدارة الضريبية والمعاملات المالية.\n\nلا نبيع بياناتك الشخصية لأي جهة خارجية، ولا نستخدم محادثاتك للإعلانات الموجّهة.",
  },
  "4. Percakapan AI dan Peran Google": {
    "id": "4. Percakapan AI dan Peran Google",
    "en": "4. AI Conversations and Google’s Role",
    "ar": "٤. محادثات الذكاء الاصطناعي ودور Google",
  },
  "Ketika Anda mengirim pertanyaan melalui fitur percakapan, teks dan konteks diproses melalui layanan Google NotebookLM. Kebijakan pemrosesan Google mengikuti Kebijakan Privasi Google dan ketentuan NotebookLM.\n\nAplikasi OpenTurath tidak menggunakan isi percakapan atau catatan pribadi pengguna untuk melatih model kecerdasan buatan publik. Hindari memasukkan informasi pribadi sensitif atau rahasia ke dalam percakapan.": {
    "id": "Ketika Anda mengirim pertanyaan melalui fitur percakapan, teks dan konteks diproses melalui layanan Google NotebookLM. Kebijakan pemrosesan Google mengikuti Kebijakan Privasi Google dan ketentuan NotebookLM.\n\nAplikasi OpenTurath tidak menggunakan isi percakapan atau catatan pribadi pengguna untuk melatih model kecerdasan buatan publik. Hindari memasukkan informasi pribadi sensitif atau rahasia ke dalam percakapan.",
    "en": "When you send a question through the conversation feature, the text and context are processed through Google NotebookLM. Google’s processing is subject to the Google Privacy Policy and NotebookLM terms.\n\nThe OpenTurath app does not use users’ conversations or private notes to train public AI models. Avoid entering sensitive personal or confidential information in conversations.",
    "ar": "عندما ترسل سؤالًا عبر ميزة المحادثة، يُعالج النص والسياق عبر Google NotebookLM. وتخضع معالجة Google لسياسة خصوصية Google وشروط NotebookLM.\n\nلا يستخدم تطبيق OpenTurath محتوى محادثات المستخدمين أو ملاحظاتهم الخاصة لتدريب نماذج ذكاء اصطناعي عامة. تجنّب إدخال معلومات شخصية حساسة أو سرية في المحادثات.",
  },
  "5. Catatan, Penyimpanan, dan Sinkronisasi": {
    "id": "5. Catatan, Penyimpanan, dan Sinkronisasi",
    "en": "5. Notes, Storage, and Sync",
    "ar": "٥. الملاحظات والتخزين والمزامنة",
  },
  "Catatan, kutipan ibarah, dan penanda rujukan disimpan pada perangkat. Catatan yang terhubung ke akun juga disinkronkan ke Firebase dan dapat dimuat pada perangkat lain yang masuk dengan akun tersebut. Sinkronisasi memerlukan koneksi dan dapat tertunda. Sebagian catatan lokal tidak memiliki salinan cloud.\n\nMenghapus data aplikasi atau mencopot aplikasi dapat menghapus salinan lokal, tetapi tidak otomatis menghapus salinan cloud. Penghapusan catatan melalui aplikasi diteruskan saat sinkronisasi tersedia; penanda penghapusan dapat tetap disimpan untuk mencegah catatan lama muncul kembali. Cadangkan catatan penting dengan fitur salin atau bagikan.": {
    "id": "Catatan, kutipan ibarah, dan penanda rujukan disimpan pada perangkat. Catatan yang terhubung ke akun juga disinkronkan ke Firebase dan dapat dimuat pada perangkat lain yang masuk dengan akun tersebut. Sinkronisasi memerlukan koneksi dan dapat tertunda. Sebagian catatan lokal tidak memiliki salinan cloud.\n\nMenghapus data aplikasi atau mencopot aplikasi dapat menghapus salinan lokal, tetapi tidak otomatis menghapus salinan cloud. Penghapusan catatan melalui aplikasi diteruskan saat sinkronisasi tersedia; penanda penghapusan dapat tetap disimpan untuk mencegah catatan lama muncul kembali. Cadangkan catatan penting dengan fitur salin atau bagikan.",
    "en": "Notes, quoted passages, and reference markers are stored on your device. Account-linked notes also sync to Firebase and can be loaded on other devices signed in to that account. Sync requires a connection and may be delayed. Some local notes have no cloud copy.\n\nClearing app data or uninstalling the app may remove local copies but does not automatically remove cloud copies. Deletions made through the app are sent when sync is available; deletion markers may be retained to prevent old notes from reappearing. Back up important notes using copy or share.",
    "ar": "تُحفظ الملاحظات والنقول وعلامات المراجع على جهازك. وتُزامن الملاحظات المرتبطة بالحساب أيضًا مع Firebase، ويمكن تحميلها على أجهزة أخرى مسجّل دخولها بالحساب نفسه. تتطلب المزامنة اتصالًا وقد تتأخر. وبعض الملاحظات المحلية ليست لها نسخة سحابية.\n\nقد يؤدي مسح بيانات التطبيق أو إزالته إلى حذف النسخ المحلية، لكنه لا يحذف النسخ السحابية تلقائيًا. تُرسل عمليات حذف الملاحظات من التطبيق عند توافر المزامنة؛ وقد تُحفظ علامات الحذف لمنع ظهور الملاحظات القديمة مجددًا. احتفظ بنسخة احتياطية من الملاحظات المهمة باستخدام النسخ أو المشاركة.",
  },
  "6. Penerima dan Penyedia Layanan": {
    "id": "6. Penerima dan Penyedia Layanan",
    "en": "6. Recipients and Service Providers",
    "ar": "٦. الجهات المتلقية ومزودو الخدمات",
  },
  "Data dibagikan hanya sebatas yang diperlukan untuk menjalankan layanan:\n• Google: Untuk proses masuk autentikasi dan pemrosesan sesi percakapan NotebookLM.\n• DOKU: Lembaga pembayaran resmi untuk memproses transaksi perbankan, dompet digital, atau QRIS.\n• Firebase / Google Cloud: Autentikasi, data akun dan hak akses, data transaksi, sinkronisasi catatan, dan laporan diagnostik.\n\nPemrosesan oleh masing-masing penyedia mengikuti layanan yang digunakan dan ketentuan penyedia tersebut.": {
    "id": "Data dibagikan hanya sebatas yang diperlukan untuk menjalankan layanan:\n• Google: Untuk proses masuk autentikasi dan pemrosesan sesi percakapan NotebookLM.\n• DOKU: Lembaga pembayaran resmi untuk memproses transaksi perbankan, dompet digital, atau QRIS.\n• Firebase / Google Cloud: Autentikasi, data akun dan hak akses, data transaksi, sinkronisasi catatan, dan laporan diagnostik.\n\nPemrosesan oleh masing-masing penyedia mengikuti layanan yang digunakan dan ketentuan penyedia tersebut.",
    "en": "Data is shared only as needed to operate the service:\n• Google: Sign-in authentication and NotebookLM conversation sessions.\n• DOKU: The official payment provider for banking transactions, digital wallets, and QRIS.\n• Firebase / Google Cloud: Authentication, account and access data, transaction data, note sync, and diagnostic reports.\n\nEach provider’s processing follows the service used and that provider’s terms.",
    "ar": "تُشارك البيانات بالقدر اللازم لتشغيل الخدمة فقط:\n• Google: التحقق من الهوية عند تسجيل الدخول ومعالجة جلسات محادثة NotebookLM.\n• DOKU: مزوّد الدفع الرسمي لمعالجة المعاملات المصرفية والمحافظ الرقمية وQRIS.\n• Firebase / Google Cloud: التحقق من الهوية وبيانات الحساب وحقوق الوصول وبيانات المعاملات ومزامنة الملاحظات والتقارير التشخيصية.\n\nتخضع معالجة كل مزوّد للخدمة المستخدمة وشروط ذلك المزوّد.",
  },
  "7. Kebijakan Iklan, Analitik, dan Promosi": {
    "id": "7. Kebijakan Iklan, Analitik, dan Promosi",
    "en": "7. Advertising, Analytics, and Promotions",
    "ar": "٧. الإعلانات والتحليلات والترويج",
  },
  "Laporan diagnostik digunakan untuk menelusuri gangguan aplikasi. Laporan produksi memuat jenis kesalahan, bukan teks lengkap kesalahan atau alamat email akun. Pemberitahuan transaksi dan pembaruan layanan berkaitan dengan pengoperasian akun Anda.": {
    "id": "Laporan diagnostik digunakan untuk menelusuri gangguan aplikasi. Laporan produksi memuat jenis kesalahan, bukan teks lengkap kesalahan atau alamat email akun. Pemberitahuan transaksi dan pembaruan layanan berkaitan dengan pengoperasian akun Anda.",
    "en": "Diagnostic reports are used to investigate app issues. Production reports contain error types, rather than full error text or account email addresses. Transaction notifications and service updates relate to the operation of your account.",
    "ar": "تُستخدم التقارير التشخيصية لتتبّع مشكلات التطبيق. وتحتوي تقارير بيئة التشغيل الفعلية على أنواع الأخطاء، دون النص الكامل للخطأ أو عناوين البريد الإلكتروني للحسابات. وتتعلق إشعارات المعاملات وتحديثات الخدمة بتشغيل حسابك.",
  },
  "8. Pemrosesan Data Lintas Wilayah": {
    "id": "8. Pemrosesan Data Lintas Wilayah",
    "en": "8. Cross-Region Data Processing",
    "ar": "٨. معالجة البيانات عبر المناطق",
  },
  "Layanan Google, Firebase, dan penyedia pembayaran dapat memproses data di luar perangkat Anda. Lokasi pemrosesan mengikuti konfigurasi layanan dan ketentuan penyedia; lokasi penyimpanan setiap jenis data belum dirinci dalam dokumen ini.": {
    "id": "Layanan Google, Firebase, dan penyedia pembayaran dapat memproses data di luar perangkat Anda. Lokasi pemrosesan mengikuti konfigurasi layanan dan ketentuan penyedia; lokasi penyimpanan setiap jenis data belum dirinci dalam dokumen ini.",
    "en": "Google, Firebase, and payment providers may process data outside your device. Processing locations depend on service configuration and provider terms; this document does not specify the storage location of each type of data.",
    "ar": "قد تعالج Google وFirebase ومزودو الدفع البيانات خارج جهازك. وتتبع مواقع المعالجة إعدادات الخدمة وشروط المزوّد؛ ولا تفصّل هذه الوثيقة موقع تخزين كل نوع من البيانات.",
  },
  "9. Masa Penyimpanan Data (Retensi)": {
    "id": "9. Masa Penyimpanan Data (Retensi)",
    "en": "9. Data Retention",
    "ar": "٩. مدة الاحتفاظ بالبيانات",
  },
  "Catatan lokal tersimpan sampai Anda menghapusnya atau membersihkan data aplikasi. Salinan cloud dan penanda penghapusan memiliki siklus penyimpanan tersendiri. Jangka waktu retensi data akun, transaksi, diagnostik, bantuan, serta salinan cloud belum dirinci dalam dokumen ini. Hubungi pengelola untuk informasi retensi dan cakupan penghapusan data; penghapusan akun tidak dengan sendirinya membuktikan penghapusan seluruh salinan pada penyedia layanan.": {
    "id": "Catatan lokal tersimpan sampai Anda menghapusnya atau membersihkan data aplikasi. Salinan cloud dan penanda penghapusan memiliki siklus penyimpanan tersendiri. Jangka waktu retensi data akun, transaksi, diagnostik, bantuan, serta salinan cloud belum dirinci dalam dokumen ini. Hubungi pengelola untuk informasi retensi dan cakupan penghapusan data; penghapusan akun tidak dengan sendirinya membuktikan penghapusan seluruh salinan pada penyedia layanan.",
    "en": "Local notes remain until you delete them or clear app data. Cloud copies and deletion markers have separate retention cycles. This document does not specify retention periods for account, transaction, diagnostic, and support data or cloud copies. Contact the operator for information about retention and the scope of deletion; deleting an account does not itself establish that all copies held by service providers have been deleted.",
    "ar": "تبقى الملاحظات المحلية حتى تحذفها أو تمسح بيانات التطبيق. وللنسخ السحابية وعلامات الحذف دورات احتفاظ مستقلة. ولا تفصّل هذه الوثيقة مدد الاحتفاظ ببيانات الحساب والمعاملات والتشخيص والدعم والنسخ السحابية. تواصل مع الجهة المشغلة لمعرفة مدد الاحتفاظ ونطاق حذف البيانات؛ فحذف الحساب لا يثبت بذاته حذف جميع النسخ لدى مزودي الخدمات.",
  },
  "10. Keamanan dan Perlindungan Data": {
    "id": "10. Keamanan dan Perlindungan Data",
    "en": "10. Security and Data Protection",
    "ar": "١٠. أمن البيانات وحمايتها",
  },
  "Aplikasi menggunakan autentikasi Google dan koneksi layanan melalui HTTPS. Anda memasukkan kata sandi pada halaman Google, bukan formulir kata sandi OpenTurath. Jangan membagikan token sesi, kode verifikasi, atau data rahasia. Keamanan layanan cloud juga bergantung pada pengaturan akses dan pengoperasian layanan tersebut.": {
    "id": "Aplikasi menggunakan autentikasi Google dan koneksi layanan melalui HTTPS. Anda memasukkan kata sandi pada halaman Google, bukan formulir kata sandi OpenTurath. Jangan membagikan token sesi, kode verifikasi, atau data rahasia. Keamanan layanan cloud juga bergantung pada pengaturan akses dan pengoperasian layanan tersebut.",
    "en": "The app uses Google authentication and HTTPS service connections. You enter your password on Google’s page, not an OpenTurath password form. Do not share session tokens, verification codes, or confidential data. Cloud service security also depends on access settings and service operation.",
    "ar": "يستخدم التطبيق التحقق من الهوية عبر Google واتصالات الخدمات عبر HTTPS. تُدخل كلمة المرور في صفحة Google، لا في نموذج كلمات مرور تابع لـOpenTurath. لا تشارك رموز الجلسة أو رموز التحقق أو البيانات السرية. ويعتمد أمن الخدمات السحابية أيضًا على إعدادات الوصول وكيفية تشغيلها.",
  },
  "11. Hak Subjek Data Pengguna": {
    "id": "11. Hak Subjek Data Pengguna",
    "en": "11. Your Data Rights",
    "ar": "١١. حقوقك المتعلقة بالبيانات",
  },
  "Sesuai UU Perlindungan Data Pribadi, Anda berhak:\n• Mengakses dan memperoleh informasi mengenai data pribadi yang diproses.\n• Memperbarui atau memperbaiki data profil yang keliru.\n• Meminta penghapusan akun dan data pribadi Anda kapan saja melalui aplikasi.\n• Menyampaikan keberatan atau pertanyaan seputar privasi ke ${LegalCopy.contactPrivacyEmail}.": {
    "id": "Sesuai UU Perlindungan Data Pribadi, Anda berhak:\n• Mengakses dan memperoleh informasi mengenai data pribadi yang diproses.\n• Memperbarui atau memperbaiki data profil yang keliru.\n• Meminta penghapusan akun dan data pribadi Anda kapan saja melalui aplikasi.\n• Menyampaikan keberatan atau pertanyaan seputar privasi ke ${LegalCopy.contactPrivacyEmail}.",
    "en": "Under the Personal Data Protection Law, you have the right to:\n• Access and obtain information about the personal data being processed.\n• Update or correct inaccurate profile data.\n• Request deletion of your account and personal data at any time through the app.\n• Send privacy objections or questions to ${LegalCopy.contactPrivacyEmail}.",
    "ar": "بموجب قانون حماية البيانات الشخصية، يحق لك:\n• الوصول إلى البيانات الشخصية التي تُعالج والحصول على معلومات عنها.\n• تحديث بيانات الملف الشخصي غير الصحيحة أو تصحيحها.\n• طلب حذف حسابك وبياناتك الشخصية في أي وقت عبر التطبيق.\n• إرسال الاعتراضات أو الاستفسارات المتعلقة بالخصوصية إلى ${LegalCopy.contactPrivacyEmail}.",
  },
  "12. Pengguna di Bawah Umur": {
    "id": "12. Pengguna di Bawah Umur",
    "en": "12. Users Under 18",
    "ar": "١٢. المستخدمون دون سن الرشد",
  },
  "Pendaftaran akun mandiri ditujukan bagi pengguna berusia 18 tahun ke atas. Jika Anda orang tua atau wali dan mendapati akun dibuka tanpa izin yang diperlukan, hubungi ${LegalCopy.contactPrivacyEmail} untuk penanganan dan penghapusan data.": {
    "id": "Pendaftaran akun mandiri ditujukan bagi pengguna berusia 18 tahun ke atas. Jika Anda orang tua atau wali dan mendapati akun dibuka tanpa izin yang diperlukan, hubungi ${LegalCopy.contactPrivacyEmail} untuk penanganan dan penghapusan data.",
    "en": "Self-registration is intended for users aged 18 or older. If you are a parent or guardian and find that an account was opened without the required permission, contact ${LegalCopy.contactPrivacyEmail} for assistance and data deletion.",
    "ar": "التسجيل الذاتي مخصص لمن بلغوا 18 عامًا أو أكثر. إذا كنت وليًا أو وصيًا وتبين لك أن حسابًا فُتح دون الإذن اللازم، فتواصل عبر ${LegalCopy.contactPrivacyEmail} لمعالجة الأمر وحذف البيانات.",
  },
  "13. Kontak dan Pembaruan Kebijakan": {
    "id": "13. Kontak dan Pembaruan Kebijakan",
    "en": "13. Contact and Policy Updates",
    "ar": "١٣. التواصل وتحديثات السياسة",
  },
  "Versi dokumen: ${LegalCopy.documentVersion} (Berlaku sejak ${LegalCopy.effectiveDate}).\n\nUntuk pertanyaan atau permohonan hak privasi, hubungi:\nEmail: ${LegalCopy.contactPrivacyEmail}\nPengelola: ${LegalCopy.managerName} (${LegalCopy.managerAddress})": {
    "id": "Versi dokumen: ${LegalCopy.documentVersion} (Berlaku sejak ${LegalCopy.effectiveDate}).\n\nUntuk pertanyaan atau permohonan hak privasi, hubungi:\nEmail: ${LegalCopy.contactPrivacyEmail}\nPengelola: ${LegalCopy.managerName} (${LegalCopy.managerAddress})",
    "en": "Document version: ${LegalCopy.documentVersion} (Effective ${LegalCopy.effectiveDate}).\n\nFor questions or requests to exercise privacy rights, contact:\nEmail: ${LegalCopy.contactPrivacyEmail}\nOperator: ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'OpenTurath operator' : LegalCopy.managerName} (${LegalCopy.managerAddress})",
    "ar": "إصدار الوثيقة: ${LegalCopy.documentVersion} (سارية منذ ${LegalCopy.effectiveDate == '13 September 2026' ? '13 سبتمبر 2026' : LegalCopy.effectiveDate}).\n\nللاستفسار أو طلب ممارسة حقوق الخصوصية، تواصل عبر:\nالبريد الإلكتروني: ${LegalCopy.contactPrivacyEmail}\nالجهة المشغلة: ${LegalCopy.managerName == 'Pengelola OpenTurath' ? 'الجهة المشغلة لـOpenTurath' : LegalCopy.managerName} (${LegalCopy.managerAddress == 'Indonesia' ? 'إندونيسيا' : LegalCopy.managerAddress})",
  },
  "1. Informasi Sebelum Pembelian": {
    "id": "1. Informasi Sebelum Pembelian",
    "en": "1. Information Before Purchase",
    "ar": "١. المعلومات قبل الشراء",
  },
  "Sebelum melakukan pembayaran, rincian harga total, cakupan modul asisten, durasi masa akses, dan metode pembayaran ditampilkan secara jelas pada halaman langganan.\n\nDurasi paket 30 hari dihitung sebagai 30 hari kalender penuh sejak aktivasi berhasil. Perubahan harga di masa mendatang tidak akan memengaruhi paket yang sedang berjalan.": {
    "id": "Sebelum melakukan pembayaran, rincian harga total, cakupan modul asisten, durasi masa akses, dan metode pembayaran ditampilkan secara jelas pada halaman langganan.\n\nDurasi paket 30 hari dihitung sebagai 30 hari kalender penuh sejak aktivasi berhasil. Perubahan harga di masa mendatang tidak akan memengaruhi paket yang sedang berjalan.",
    "en": "Before payment, the subscription page clearly displays the total price, assistant module coverage, access duration, and payment methods.\n\nA 30-day plan lasts 30 full calendar days from successful activation. Future price changes will not affect a plan already in progress.",
    "ar": "تعرض صفحة الاشتراك بوضوح قبل الدفع السعر الإجمالي ونطاق وحدات المساعدين ومدة الوصول ووسائل الدفع.\n\nتُحسب الباقة ذات الثلاثين يومًا على أساس 30 يومًا تقويميًا كاملًا من نجاح التفعيل. ولا تؤثر تغييرات الأسعار المستقبلية في الباقة السارية.",
  },
  "2. Pembayaran dan Aktivasi Akses": {
    "id": "2. Pembayaran dan Aktivasi Akses",
    "en": "2. Payment and Access Activation",
    "ar": "٢. الدفع وتفعيل الوصول",
  },
  "Pembayaran diproses melalui gerbang pembayaran resmi DOKU dengan metode QRIS, transfer bank (virtual account), maupun dompet digital.\n\nBukti pembayaran resmi dikirimkan melalui notifikasi DOKU dan email akun Anda. Masa akses aktif seketika transaksi dinyatakan berhasil dan tersinkronisasi. Jika dana telah terpotong namun status belum aktif, jangan melakukan pembayaran ulang; hubungi ${LegalCopy.contactSupportEmail} dengan menyertakan nomor transaksi.": {
    "id": "Pembayaran diproses melalui gerbang pembayaran resmi DOKU dengan metode QRIS, transfer bank (virtual account), maupun dompet digital.\n\nBukti pembayaran resmi dikirimkan melalui notifikasi DOKU dan email akun Anda. Masa akses aktif seketika transaksi dinyatakan berhasil dan tersinkronisasi. Jika dana telah terpotong namun status belum aktif, jangan melakukan pembayaran ulang; hubungi ${LegalCopy.contactSupportEmail} dengan menyertakan nomor transaksi.",
    "en": "Payments are processed through the official DOKU payment gateway using QRIS, bank transfers (virtual accounts), or digital wallets.\n\nOfficial payment confirmation is sent through DOKU notifications and your account email. Access becomes active once the transaction is confirmed successful and synced. If funds have been deducted but access is not active, do not pay again; contact ${LegalCopy.contactSupportEmail} with your transaction number.",
    "ar": "تُعالج المدفوعات عبر بوابة الدفع الرسمية DOKU باستخدام QRIS أو التحويل المصرفي (الحساب الافتراضي) أو المحافظ الرقمية.\n\nيُرسل إثبات الدفع الرسمي عبر إشعارات DOKU والبريد الإلكتروني لحسابك. يُفعّل الوصول بمجرد تأكيد نجاح المعاملة ومزامنتها. إذا خُصم المبلغ ولم يُفعّل الوصول، فلا تدفع مرة أخرى؛ تواصل عبر ${LegalCopy.contactSupportEmail} مع ذكر رقم المعاملة.",
  },
  "3. Perpanjangan Manual (Tanpa Auto-Debit)": {
    "id": "3. Perpanjangan Manual (Tanpa Auto-Debit)",
    "en": "3. Manual Renewal (No Automatic Debit)",
    "ar": "٣. التجديد اليدوي (دون خصم تلقائي)",
  },
  "Seluruh paket langganan OpenTurath diperpanjang secara manual tanpa penagihan berulang otomatis (tanpa auto-debit). Setelah masa aktif berakhir, akses berbayar akan berhenti dengan sendirinya kecuali Anda memilih untuk memperpanjang secara sadar.": {
    "id": "Seluruh paket langganan OpenTurath diperpanjang secara manual tanpa penagihan berulang otomatis (tanpa auto-debit). Setelah masa aktif berakhir, akses berbayar akan berhenti dengan sendirinya kecuali Anda memilih untuk memperpanjang secara sadar.",
    "en": "All OpenTurath subscriptions renew manually, with no automatic recurring billing or direct debit. Paid access ends when its period expires unless you actively choose to renew.",
    "ar": "تُجدّد جميع باقات OpenTurath يدويًا، دون فواتير دورية تلقائية أو خصم تلقائي. ينتهي الوصول المدفوع بانتهاء مدته، ما لم تختر التجديد صراحةً.",
  },
  "4. Ketentuan Voucher": {
    "id": "4. Ketentuan Voucher",
    "en": "4. Voucher Terms",
    "ar": "٤. شروط القسائم",
  },
  "Voucher promosi atau mitra mengikuti masa berlaku, cakupan asisten, dan batas penukaran yang tercantum saat diterbitkan. Voucher tidak dapat diuangkan dan berlaku untuk satu kali penukaran pada akun yang berhak.": {
    "id": "Voucher promosi atau mitra mengikuti masa berlaku, cakupan asisten, dan batas penukaran yang tercantum saat diterbitkan. Voucher tidak dapat diuangkan dan berlaku untuk satu kali penukaran pada akun yang berhak.",
    "en": "Promotional and partner vouchers follow the validity period, assistant coverage, and redemption limits stated when issued. Vouchers cannot be exchanged for cash and may be redeemed once by an eligible account.",
    "ar": "تخضع القسائم الترويجية وقسائم الشركاء لمدة الصلاحية ونطاق المساعدين وحدود الاسترداد المحددة عند إصدارها. ولا يمكن تحويل القسيمة إلى نقد، ويُسمح باستردادها مرة واحدة للحساب المؤهل.",
  },
  "5. Dasar Pengajuan Pengembalian Dana (Refund)": {
    "id": "5. Dasar Pengajuan Pengembalian Dana (Refund)",
    "en": "5. Grounds for Requesting a Refund",
    "ar": "٥. أسباب طلب استرداد الأموال",
  },
  "Anda berhak mengajukan pemeriksaan dan pengembalian dana apabila terjadi:\n• Pembayaran ganda akibat kendala teknis pada sistem transaksi.\n• Dana telah terpotong namun hak akses tidak aktif setelah dilakukan verifikasi.\n• Gangguan teknis berkepanjangan pada layanan inti berbayar yang tidak dapat dipulihkan.\n\nPenyelesaian dapat berupa pemulihan akses, penyesuaian masa aktif yang Anda setujui, atau pengembalian dana penuh.": {
    "id": "Anda berhak mengajukan pemeriksaan dan pengembalian dana apabila terjadi:\n• Pembayaran ganda akibat kendala teknis pada sistem transaksi.\n• Dana telah terpotong namun hak akses tidak aktif setelah dilakukan verifikasi.\n• Gangguan teknis berkepanjangan pada layanan inti berbayar yang tidak dapat dipulihkan.\n\nPenyelesaian dapat berupa pemulihan akses, penyesuaian masa aktif yang Anda setujui, atau pengembalian dana penuh.",
    "en": "You may request a review and refund in cases of:\n• Duplicate payment caused by a technical problem in the transaction system.\n• Funds deducted but access still inactive after verification.\n• Prolonged technical disruption to a core paid service that cannot be restored.\n\nResolution may take the form of restored access, an access-period adjustment you agree to, or a full refund.",
    "ar": "يحق لك طلب المراجعة واسترداد الأموال في الحالات الآتية:\n• دفع مكرر ناتج عن مشكلة تقنية في نظام المعاملات.\n• خصم المبلغ مع استمرار عدم تفعيل الوصول بعد التحقق.\n• عطل تقني طويل في خدمة مدفوعة أساسية يتعذر إصلاحه.\n\nقد تكون التسوية باستعادة الوصول أو تعديل مدة الوصول بموافقتك أو رد المبلغ كاملًا.",
  },
  "6. Alur dan Waktu Penanganan Refund": {
    "id": "6. Alur dan Waktu Penanganan Refund",
    "en": "6. Refund Process and Timelines",
    "ar": "٦. إجراءات الاسترداد ومدد المعالجة",
  },
  "Kirim permohonan ke ${LegalCopy.contactSupportEmail} dengan menyertakan:\n1. Alamat email akun OpenTurath.\n2. Nomor transaksi / invoice pembayaran.\n3. Bukti pembayaran resmi dari bank/e-wallet.\n4. Penjelasan kendala yang dialami.\n\nKonfirmasi penerimaan dikirimkan maksimal dalam ${LegalCopy.supportSla}. Pemeriksaan dan keputusan pengembalian dana diselesaikan dalam ${LegalCopy.refundSla}. Jika disetujui, pengembalian dana diproses ke rekening atau dompet asal sesuai ketentuan perbankan (${LegalCopy.refundSla}).": {
    "id": "Kirim permohonan ke ${LegalCopy.contactSupportEmail} dengan menyertakan:\n1. Alamat email akun OpenTurath.\n2. Nomor transaksi / invoice pembayaran.\n3. Bukti pembayaran resmi dari bank/e-wallet.\n4. Penjelasan kendala yang dialami.\n\nKonfirmasi penerimaan dikirimkan maksimal dalam ${LegalCopy.supportSla}. Pemeriksaan dan keputusan pengembalian dana diselesaikan dalam ${LegalCopy.refundSla}. Jika disetujui, pengembalian dana diproses ke rekening atau dompet asal sesuai ketentuan perbankan (${LegalCopy.refundSla}).",
    "en": "Send your request to ${LegalCopy.contactSupportEmail} and include:\n1. Your OpenTurath account email address.\n2. The transaction or payment invoice number.\n3. Official payment evidence from your bank or digital wallet.\n4. A description of the problem.\n\nReceipt will be acknowledged within ${LegalCopy.supportSla == '2 (dua) hari kerja' ? '2 (two) working days' : LegalCopy.supportSla}. The review and refund decision will be completed within ${LegalCopy.refundSla == '7 (tujuh) hari kerja' ? '7 (seven) working days' : LegalCopy.refundSla}. If approved, the refund is processed to the original account or wallet according to banking requirements (${LegalCopy.refundSla == '7 (tujuh) hari kerja' ? '7 (seven) working days' : LegalCopy.refundSla}).",
    "ar": "أرسل طلبك إلى ${LegalCopy.contactSupportEmail} وأرفق:\n1. عنوان البريد الإلكتروني لحساب OpenTurath.\n2. رقم المعاملة أو فاتورة الدفع.\n3. إثبات الدفع الرسمي من البنك أو المحفظة الرقمية.\n4. شرح المشكلة.\n\nيُرسل تأكيد استلام الطلب خلال ${LegalCopy.supportSla == '2 (dua) hari kerja' ? 'يومي عمل (2)' : LegalCopy.supportSla} كحد أقصى. وتكتمل المراجعة وقرار الاسترداد خلال ${LegalCopy.refundSla == '7 (tujuh) hari kerja' ? 'سبعة أيام عمل (7)' : LegalCopy.refundSla}. وعند الموافقة، يُعالج رد المبلغ إلى الحساب أو المحفظة الأصلية وفق المتطلبات المصرفية (${LegalCopy.refundSla == '7 (tujuh) hari kerja' ? 'سبعة أيام عمل (7)' : LegalCopy.refundSla}).",
  },
  "7. Saluran Bantuan Transaksi": {
    "id": "7. Saluran Bantuan Transaksi",
    "en": "7. Transaction Support",
    "ar": "٧. دعم المعاملات",
  },
  "Kendala pembayaran dan transaksi dipantau setiap hari kerja (${LegalCopy.serviceHours}).\nEmail layanan transaksi: ${LegalCopy.contactSupportEmail}": {
    "id": "Kendala pembayaran dan transaksi dipantau setiap hari kerja (${LegalCopy.serviceHours}).\nEmail layanan transaksi: ${LegalCopy.contactSupportEmail}",
    "en": "Payment and transaction issues are monitored on working days (${LegalCopy.serviceHours == 'Senin – Jumat, 09.00 – 17.00 WIB' ? 'Monday–Friday, 09:00–17:00 Western Indonesia Time, UTC+7' : LegalCopy.serviceHours}).\nTransaction support email: ${LegalCopy.contactSupportEmail}",
    "ar": "تُتابع مشكلات الدفع والمعاملات في أيام العمل (${LegalCopy.serviceHours == 'Senin – Jumat, 09.00 – 17.00 WIB' ? 'الاثنين–الجمعة، 09:00–17:00 بتوقيت غرب إندونيسيا، UTC+7' : LegalCopy.serviceHours}).\nالبريد الإلكتروني لدعم المعاملات: ${LegalCopy.contactSupportEmail}",
  },
  "1. Peran OpenTurath dalam Belajar": {
    "id": "1. Peran OpenTurath dalam Belajar",
    "en": "1. OpenTurath’s Role in Learning",
    "ar": "١. دور OpenTurath في التعلّم",
  },
  "OpenTurath membantu menelusuri pembahasan dalam kitab dan menyusun penjelasan awal berdasarkan sumber yang tersedia. Gunakan hasilnya untuk memperluas pembacaan, menyiapkan pertanyaan kepada guru, atau menemukan rujukan yang perlu diperiksa.\n\nJawaban AI dapat keliru meskipun disampaikan dengan kalimat yang meyakinkan. Kehadiran judul kitab atau nomor halaman belum membuktikan bahwa seluruh isi jawaban bebas dari kekeliruan.": {
    "id": "OpenTurath membantu menelusuri pembahasan dalam kitab dan menyusun penjelasan awal berdasarkan sumber yang tersedia. Gunakan hasilnya untuk memperluas pembacaan, menyiapkan pertanyaan kepada guru, atau menemukan rujukan yang perlu diperiksa.\n\nJawaban AI dapat keliru meskipun disampaikan dengan kalimat yang meyakinkan. Kehadiran judul kitab atau nomor halaman belum membuktikan bahwa seluruh isi jawaban bebas dari kekeliruan.",
    "en": "OpenTurath helps you explore discussions in books and prepare preliminary explanations based on available sources. Use its results to broaden your reading, prepare questions for a teacher, or find references to check.\n\nAI answers can be wrong even when confidently worded. The presence of a book title or page number does not establish that the entire answer is free of errors.",
    "ar": "يساعدك OpenTurath على تتبع المباحث في الكتب وإعداد شروح أولية بناءً على المصادر المتاحة. استخدم النتائج لتوسيع القراءة أو إعداد أسئلة لمعلمك أو العثور على مراجع تحتاج إلى التحقق.\n\nقد تخطئ إجابات الذكاء الاصطناعي ولو صيغت بعبارات مقنعة. ووجود عنوان كتاب أو رقم صفحة لا يثبت خلو الإجابة كلها من الخطأ.",
  },
  "2. Membaca Kutipan Bersama Konteks": {
    "id": "2. Membaca Kutipan Bersama Konteks",
    "en": "2. Reading Quotations in Context",
    "ar": "٢. قراءة النقول في سياقها",
  },
  "Periksa judul kitab, nama pengarang, edisi, jilid, dan halaman yang dirujuk. Baca bagian sebelum dan sesudah kutipan untuk memahami hubungan pembahasan secara utuh. Syarat, pengecualian, dan konteks pembahasan sangat memengaruhi maksud ibarah hukum.\n\nJika penomoran halaman berbeda, cocokkan dengan cetakan atau edisi yang Anda gunakan.": {
    "id": "Periksa judul kitab, nama pengarang, edisi, jilid, dan halaman yang dirujuk. Baca bagian sebelum dan sesudah kutipan untuk memahami hubungan pembahasan secara utuh. Syarat, pengecualian, dan konteks pembahasan sangat memengaruhi maksud ibarah hukum.\n\nJika penomoran halaman berbeda, cocokkan dengan cetakan atau edisi yang Anda gunakan.",
    "en": "Check the cited book title, author, edition, volume, and page. Read the text before and after a quotation to understand how the discussion connects. Conditions, exceptions, and context strongly affect the meaning of legal passages.\n\nIf page numbering differs, check against the printing or edition you use.",
    "ar": "تحقق من عنوان الكتاب واسم المؤلف والطبعة والجزء والصفحة المحال إليها. واقرأ ما قبل النقل وما بعده لفهم ترابط المبحث كاملًا. فالشروط والاستثناءات وسياق البحث تؤثر كثيرًا في مراد العبارة الفقهية.\n\nإذا اختلف ترقيم الصفحات، فطابق النقل مع الطبعة أو الإصدار الذي تستخدمه.",
  },
  "3. Menjaga Adab Perbedaan Pendapat": {
    "id": "3. Menjaga Adab Perbedaan Pendapat",
    "en": "3. Scholarly Conduct in Disagreement",
    "ar": "٣. أدب الاختلاف العلمي",
  },
  "Penjelasan tentang mazhab atau kedudukan suatu pendapat perlu dibaca sesuai bidang dan rujukannya. Ringkasan perbandingan tidak otomatis mencakup seluruh pandangan ulama.\n\nIstilah khusus seperti mu'tamad, sanad, dan derajat hadis memiliki metodologi ilmiah yang ketat. Untuk pemahaman agama yang mendalam dan penetapan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.": {
    "id": "Penjelasan tentang mazhab atau kedudukan suatu pendapat perlu dibaca sesuai bidang dan rujukannya. Ringkasan perbandingan tidak otomatis mencakup seluruh pandangan ulama.\n\nIstilah khusus seperti mu'tamad, sanad, dan derajat hadis memiliki metodologi ilmiah yang ketat. Untuk pemahaman agama yang mendalam dan penetapan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.",
    "en": "Read explanations of a school of law or the standing of an opinion in light of the relevant field and sources. A comparative summary does not necessarily cover all scholarly views.\n\nTechnical terms such as mu‘tamad, sanad, and hadith grading follow rigorous scholarly methods. For a deep understanding of religion and the determination of rulings, continue to consult qualified teachers and scholars.",
    "ar": "ينبغي قراءة بيان المذهب أو منزلة القول بحسب مجاله ومراجعه. ولا يلزم أن يشمل الملخص المقارن جميع أقوال العلماء.\n\nللمصطلحات المتخصصة، مثل المعتمد والسند ودرجات الحديث، مناهج علمية دقيقة. وللفهم العميق للدين وتقرير الأحكام، واصل الرجوع إلى المعلمين والعلماء المؤهلين.",
  },
  "4. Mengutip dan Membagikan Hasil": {
    "id": "4. Mengutip dan Membagikan Hasil",
    "en": "4. Quoting and Sharing Results",
    "ar": "٤. الاقتباس ومشاركة النتائج",
  },
  "Bedakan dengan jujur antara naskah kitab asli, kutipan terjemahan, dan sintesis penjelasan AI. Cantumkan sumber yang benar-benar Anda periksa pada naskah aslinya. Jangan memberi kesan telah membaca kitab secara utuh apabila penelusuran baru dilakukan melalui ringkasan AI.": {
    "id": "Bedakan dengan jujur antara naskah kitab asli, kutipan terjemahan, dan sintesis penjelasan AI. Cantumkan sumber yang benar-benar Anda periksa pada naskah aslinya. Jangan memberi kesan telah membaca kitab secara utuh apabila penelusuran baru dilakukan melalui ringkasan AI.",
    "en": "Clearly distinguish the original book text, translated quotations, and AI-generated explanations. Cite sources you have actually checked in their original texts. Do not imply that you have read an entire book when your research has only involved an AI summary.",
    "ar": "ميّز بأمانة بين نص الكتاب الأصلي والنقول المترجمة والشرح الذي يصوغه الذكاء الاصطناعي. واذكر المصادر التي تحققت منها بالفعل في نصوصها الأصلية. ولا توهم بأنك قرأت الكتاب كاملًا إذا اقتصر بحثك على ملخص بالذكاء الاصطناعي.",
  },
  "5. Melaporkan Kesalahan Teks atau Rujukan": {
    "id": "5. Melaporkan Kesalahan Teks atau Rujukan",
    "en": "5. Reporting Text or Reference Errors",
    "ar": "٥. الإبلاغ عن أخطاء النصوص أو المراجع",
  },
  "Apabila Anda menemukan kekeliruan kutipan teks Arab, salah atribusi pengarang, atau kesalahan jilid dan halaman, kirimkan laporan ke ${LegalCopy.contactSupportEmail} dengan menyertakan nama kitab, pertanyaan, dan usulan koreksi yang benar.": {
    "id": "Apabila Anda menemukan kekeliruan kutipan teks Arab, salah atribusi pengarang, atau kesalahan jilid dan halaman, kirimkan laporan ke ${LegalCopy.contactSupportEmail} dengan menyertakan nama kitab, pertanyaan, dan usulan koreksi yang benar.",
    "en": "If you find an incorrect Arabic quotation, mistaken author attribution, or an incorrect volume or page, send a report to ${LegalCopy.contactSupportEmail} with the book title, question, and proposed correction.",
    "ar": "إذا وجدت خطأ في نقل النص العربي أو في نسبة الكتاب إلى مؤلفه أو في رقم الجزء أو الصفحة، فأرسل بلاغًا إلى ${LegalCopy.contactSupportEmail} يتضمن اسم الكتاب والسؤال والتصحيح المقترح.",
  },
  "1. Layanan Bantuan dan Pengaduan": {
    "id": "1. Layanan Bantuan dan Pengaduan",
    "en": "1. Help and Complaints",
    "ar": "١. المساعدة والشكاوى",
  },
  "Tim OpenTurath siap membantu kendala akun, aktivasi langganan, pembayaran, penggunaan Catatan, serta laporan koreksi naskah kitab rujukan.": {
    "id": "Tim OpenTurath siap membantu kendala akun, aktivasi langganan, pembayaran, penggunaan Catatan, serta laporan koreksi naskah kitab rujukan.",
    "en": "The OpenTurath team can help with account issues, subscription activation, payments, Notes, and reports correcting source texts.",
    "ar": "يساعد فريق OpenTurath في مشكلات الحساب وتفعيل الاشتراك والدفع واستخدام الملاحظات، ويتلقى بلاغات تصحيح نصوص الكتب المرجعية.",
  },
  "2. Saluran Komunikasi Resmi": {
    "id": "2. Saluran Komunikasi Resmi",
    "en": "2. Official Contact Channels",
    "ar": "٢. قنوات التواصل الرسمية",
  },
  "• Bantuan & Transaksi: ${LegalCopy.contactSupportEmail}\n• Permintaan Privasi & Data: ${LegalCopy.contactPrivacyEmail}\n• Laporan Hak Cipta: ${LegalCopy.contactCopyrightEmail}\n• Alamat Usaha: ${LegalCopy.managerAddress}\n• Waktu Operasional: ${LegalCopy.serviceHours}\n• Target Tanggapan: Maksimal ${LegalCopy.supportSla}": {
    "id": "• Bantuan & Transaksi: ${LegalCopy.contactSupportEmail}\n• Permintaan Privasi & Data: ${LegalCopy.contactPrivacyEmail}\n• Laporan Hak Cipta: ${LegalCopy.contactCopyrightEmail}\n• Alamat Usaha: ${LegalCopy.managerAddress}\n• Waktu Operasional: ${LegalCopy.serviceHours}\n• Target Tanggapan: Maksimal ${LegalCopy.supportSla}",
    "en": "• Support & transactions: ${LegalCopy.contactSupportEmail}\n• Privacy & data requests: ${LegalCopy.contactPrivacyEmail}\n• Copyright reports: ${LegalCopy.contactCopyrightEmail}\n• Business address: ${LegalCopy.managerAddress}\n• Service hours: ${LegalCopy.serviceHours == 'Senin – Jumat, 09.00 – 17.00 WIB' ? 'Monday–Friday, 09:00–17:00 Western Indonesia Time, UTC+7' : LegalCopy.serviceHours}\n• Response target: Within ${LegalCopy.supportSla == '2 (dua) hari kerja' ? '2 (two) working days' : LegalCopy.supportSla}",
    "ar": "• الدعم والمعاملات: ${LegalCopy.contactSupportEmail}\n• طلبات الخصوصية والبيانات: ${LegalCopy.contactPrivacyEmail}\n• بلاغات حقوق النشر: ${LegalCopy.contactCopyrightEmail}\n• عنوان النشاط: ${LegalCopy.managerAddress == 'Indonesia' ? 'إندونيسيا' : LegalCopy.managerAddress}\n• ساعات العمل: ${LegalCopy.serviceHours == 'Senin – Jumat, 09.00 – 17.00 WIB' ? 'الاثنين–الجمعة، 09:00–17:00 بتوقيت غرب إندونيسيا، UTC+7' : LegalCopy.serviceHours}\n• المدة المستهدفة للرد: ${LegalCopy.supportSla == '2 (dua) hari kerja' ? 'يومان من أيام العمل (2)' : LegalCopy.supportSla} كحد أقصى",
  },
  "3. Keamanan Informasi": {
    "id": "3. Keamanan Informasi",
    "en": "3. Information Security",
    "ar": "٣. أمن المعلومات",
  },
  "Jangan pernah mengirimkan kata sandi, kode OTP, atau informasi kartu pembayaran rahasia kepada siapapun, termasuk pihak yang mengaku sebagai tim OpenTurath. Gunakan hanya saluran email resmi yang tercantum di atas.": {
    "id": "Jangan pernah mengirimkan kata sandi, kode OTP, atau informasi kartu pembayaran rahasia kepada siapapun, termasuk pihak yang mengaku sebagai tim OpenTurath. Gunakan hanya saluran email resmi yang tercantum di atas.",
    "en": "Never send passwords, one-time codes, or confidential payment-card information to anyone, including those claiming to be the OpenTurath team. Use only the official email channels listed above.",
    "ar": "لا ترسل كلمات المرور أو رموز التحقق لمرة واحدة أو معلومات بطاقات الدفع السرية لأي شخص، بما في ذلك من يدّعي أنه من فريق OpenTurath. استخدم قنوات البريد الإلكتروني الرسمية المذكورة أعلاه فقط.",
  },
  "Tentang OpenTurath": {
    "id": "Tentang OpenTurath",
    "en": "About OpenTurath",
    "ar": "عن OpenTurath",
  },
  "Membaca kitab, menelusuri ibarah.": {"id": "Membaca kitab, menelusuri ibarah.", "en": "Read the texts, trace the passages.", "ar": "قراءة الكتب وتتبّع العبارات."},
  "OpenTurath membantu Anda menelusuri pembahasan dan rujukan dalam kitab-kitab Islam dengan bantuan AI. Pilih bidang yang ingin dipelajari, ajukan pertanyaan, lalu baca kutipan dan keterangan kitab yang tersedia. Simpan jawaban atau kutipan ke Catatan untuk dipelajari kembali.": {
    "id": "OpenTurath membantu Anda menelusuri pembahasan dan rujukan dalam kitab-kitab Islam dengan bantuan AI. Pilih bidang yang ingin dipelajari, ajukan pertanyaan, lalu baca kutipan dan keterangan kitab yang tersedia. Simpan jawaban atau kutipan ke Catatan untuk dipelajari kembali.",
    "en": "OpenTurath helps you explore discussions and references in Islamic books with AI assistance. Choose a field, ask a question, and read the available quotations and source details. Save answers or passages to Notes for further study.",
    "ar": "يساعدك OpenTurath على البحث في مباحث الكتب الإسلامية ومراجعها بمساعدة الذكاء الاصطناعي. اختر مجالًا للدراسة، واطرح سؤالك، ثم اقرأ النقول وبيانات الكتب المتاحة. احفظ الإجابات أو النقول في الملاحظات للرجوع إليها.",
  },
  "Kami ingin membuat proses mencari rujukan lebih mudah, sambil menjaga kebiasaan membaca sumber dengan teliti. Jawaban AI tetap perlu diperiksa pada kitab yang dirujuk, terutama sebelum digunakan untuk mengajar, menulis, atau mengambil kesimpulan. Pemahaman agama dan penetapan hukum tetap memerlukan bimbingan guru serta ulama yang berkompeten.": {
    "id": "Kami ingin membuat proses mencari rujukan lebih mudah, sambil menjaga kebiasaan membaca sumber dengan teliti. Jawaban AI tetap perlu diperiksa pada kitab yang dirujuk, terutama sebelum digunakan untuk mengajar, menulis, atau mengambil kesimpulan. Pemahaman agama dan penetapan hukum tetap memerlukan bimbingan guru serta ulama yang berkompeten.",
    "en": "We aim to make finding references easier while encouraging careful reading of the sources. Check AI answers against the cited books, especially before using them in teaching, writing, or drawing conclusions. Understanding religion and determining rulings still require guidance from qualified teachers and scholars.",
    "ar": "نسعى إلى تيسير الوصول إلى المراجع مع العناية بقراءة المصادر قراءة دقيقة. ينبغي التحقق من إجابات الذكاء الاصطناعي في الكتب المحال إليها، ولا سيما قبل استخدامها في التعليم أو الكتابة أو استخلاص النتائج. ويبقى فهم الدين وتقرير الأحكام محتاجًا إلى توجيه المعلمين والعلماء المؤهلين.",
  },
  "Ketentuan Layanan": {
    "id": "Ketentuan Layanan",
    "en": "Terms of Service",
    "ar": "شروط الخدمة",
  },
  "Kebijakan Privasi": {
    "id": "Kebijakan Privasi",
    "en": "Privacy Policy",
    "ar": "سياسة الخصوصية",
  },
  "Pembayaran dan Pengembalian Dana": {
    "id": "Pembayaran dan Pengembalian Dana",
    "en": "Payments and Refunds",
    "ar": "الدفع واسترداد الأموال",
  },
  "Panduan Penggunaan AI & Rujukan": {
    "id": "Panduan Penggunaan AI & Rujukan",
    "en": "AI and Reference Guide",
    "ar": "دليل استخدام الذكاء الاصطناعي والمراجع",
  },
  "Bantuan dan Kontak": {
    "id": "Bantuan dan Kontak",
    "en": "Help and Contact",
    "ar": "المساعدة والتواصل",
  },
  "Akun OpenTurath akan dihapus dan akses akun berakhir. ": {
    "id": "Akun OpenTurath akan dihapus dan akses akun berakhir. ",
    "en": "Your OpenTurath account will be deleted and account access will end. Local copies associated with the account will be cleared. Deletion of cloud copies and data held by service providers follows the operator’s process; deleting the account does not guarantee that all copies are removed immediately. Save important notes before continuing.",
    "ar": "سيُحذف حسابك في OpenTurath وينتهي الوصول إليه. ستُمسح النسخ المحلية المرتبطة بالحساب. يخضع حذف النسخ السحابية وبيانات مزودي الخدمات لإجراءات الجهة المشغلة؛ ولا يضمن حذف الحساب إزالة جميع النسخ فورًا. احفظ الملاحظات المهمة قبل المتابعة.",
  },
  "Batal": {
    "id": "Batal",
    "en": "Cancel",
    "ar": "إلغاء",
  },
  "Hapus akun": {
    "id": "Hapus akun",
    "en": "Delete account",
    "ar": "حذف الحساب",
  },
  "13 September 2026": {
    "id": "13 September 2026",
    "en": "13 September 2026",
    "ar": "13 سبتمبر 2026",
  },
  "Pengelola OpenTurath": {
    "id": "Pengelola OpenTurath",
    "en": "OpenTurath operator",
    "ar": "الجهة المشغلة لـOpenTurath",
  },
  "Indonesia": {
    "id": "Indonesia",
    "en": "Indonesia",
    "ar": "إندونيسيا",
  },
  "Senin – Jumat, 09.00 – 17.00 WIB": {
    "id": "Senin – Jumat, 09.00 – 17.00 WIB",
    "en": "Monday–Friday, 09:00–17:00 Western Indonesia Time (UTC+7)",
    "ar": "الاثنين–الجمعة، 09:00–17:00 بتوقيت غرب إندونيسيا (UTC+7)",
  },
  "2 (dua) hari kerja": {
    "id": "2 (dua) hari kerja",
    "en": "2 (two) working days",
    "ar": "يومان من أيام العمل (2)",
  },
  "7 (tujuh) hari kerja": {
    "id": "7 (tujuh) hari kerja",
    "en": "7 (seven) working days",
    "ar": "سبعة أيام عمل (7)",
  },
  "legal.version.effective": {
    "id": "Versi {version} · Berlaku mulai {date}",
    "en": "Version {version} · Effective {date}",
    "ar": "الإصدار {version} · سارٍ منذ {date}",
  },
  "legal.version.privacy": {
    "id": "Versi {version} · Sesuai UU No. 27 Tahun 2022",
    "en": "Version {version} · Under Law No. 27 of 2022",
    "ar": "الإصدار {version} · وفق القانون رقم 27 لسنة 2022",
  },
  "Ketentuan Pembayaran DOKU & Pengembalian Dana": {
    "id": "Ketentuan Pembayaran DOKU & Pengembalian Dana",
    "en": "DOKU Payment and Refund Terms",
    "ar": "شروط الدفع عبر DOKU واسترداد الأموال",
  },
  "Etika Telaah, Pembacaan Konteks, dan Adab Keilmuan": {
    "id": "Etika Telaah, Pembacaan Konteks, dan Adab Keilmuan",
    "en": "Study Ethics, Context, and Scholarly Conduct",
    "ar": "آداب الدراسة وقراءة السياق وأخلاق البحث العلمي",
  },
  "Saluran Resmi dan Pengaduan Layanan": {
    "id": "Saluran Resmi dan Pengaduan Layanan",
    "en": "Official Channels and Service Complaints",
    "ar": "القنوات الرسمية وشكاوى الخدمة",
  },
};
