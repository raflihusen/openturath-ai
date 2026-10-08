// Website information; the original app v1.0 document remains a historical record.
export const articles = {
  "how-it-works": {
    "key": "how",
    "intro": [
      "Dari pertanyaan menuju rujukan.",
      "From question to source.",
      "من السؤال إلى المصدر."
    ],
    "blocks": [
      {
        "heading": [
          "Ajukan pertanyaan",
          "Ask a question",
          "اطرح السؤال"
        ],
        "body": [
          "Pilih khadim sesuai disiplin ilmu, lalu uraikan masalah dan konteks yang ingin Anda dalami.",
          "Choose the assistant for your discipline and describe the question and its context.",
          "اختر المساعد المختص، ثم بيّن المسألة وسياقها الذي تريد دراسته."
        ]
      },
      {
        "heading": [
          "Telusuri teks primer",
          "Locate primary texts",
          "تتبّع النص الأصلي"
        ],
        "body": [
          "Telusuri ibarah Arab dalam kitab rujukan. Baca kutipan beserta pembahasan yang mengitarinya.",
          "Trace the Arabic passage in the reference works. Read the quotation alongside its surrounding discussion.",
          "تتبّع العبارة العربية في كتب المصادر، واقرأ النص مع سياقه وما يتصل به."
        ]
      },
      {
        "heading": [
          "Kenali koordinat cetakan",
          "Locate the printed edition",
          "حدّد موضع النص في الطبعة"
        ],
        "body": [
          "Judul kitab, edisi, jilid, dan halaman menjadi panduan untuk mencocokkan ibarah dengan naskah sumber.",
          "Title, edition, volume, and page guide you to match the passage against its source.",
          "يهديك عنوان الكتاب وبيانات الطبعة والجزء والصفحة إلى مقابلة العبارة بالمصدر."
        ]
      },
      {
        "heading": [
          "Telaah bersama guru",
          "Study with a teacher",
          "دارس النص مع أهل العلم"
        ],
        "body": [
          "Bawa ibarah beserta rujukannya ke majelis ilmu. Perdalam makna, timbang konteks, dan susun kesimpulan dengan bimbingan guru.",
          "Bring the passage and its reference to your teacher. Explore its meaning, weigh the context, and develop your conclusions together.",
          "اعرض العبارة ومرجعها على أهل العلم، وتعمّق في معناها وسياقها، وابنِ النتائج بإرشادهم."
        ]
      },
      {
        "heading": [
          "Mengapa halaman rujukan bisa berbeda dengan kitab cetakan saya?",
          "Why might a reference differ from the page in my printed book?",
          "لماذا قد يختلف رقم الصفحة عن نسختي المطبوعة؟"
        ],
        "body": [
          "Tiap penerbit dan edisi dapat memakai tata letak serta pembagian jilid yang berbeda. Cocokkan nama penerbit, tahun cetak, dan nomor jilid terlebih dahulu, lalu telusuri bab atau awal ibarahnya. Nomor halaman cetak juga dapat berbeda dari penghitung halaman PDF.",
          "Publishers and editions can use different layouts and volume divisions. First compare the publisher, publication year, and volume, then find the chapter or opening words of the passage. Printed page numbers may also differ from a PDF viewer’s page counter.",
          "تختلف الطبعات في تنسيق الصفحات وتقسيم المجلدات. قابل اسم الناشر وسنة الطبع والجزء أولًا، ثم تتبّع الباب أو مطلع العبارة. وقد يختلف رقم الصفحة المطبوعة عن عدّاد صفحات PDF."
        ]
      },
      {
        "heading": [
          "Mendokumentasikan hasil telaah",
          "Documenting your review",
          "توثيق نتائج المطالعة"
        ],
        "body": [
          "Catat teks, edisi, penelaah, dan tanggal pencocokan sebelum menandai rujukan sebagai terverifikasi. Jejak pemeriksaan inilah yang membuat hasil telaah dapat ditelusuri ulang.",
          "Record the text, edition, reviewer, and review date before marking a reference as verified. This record makes your findings reproducible.",
          "دوّن النص والطبعة واسم المراجع وتاريخ المقابلة قبل إثبات التحقّق من الإحالة. بهذا السجل يمكن إعادة تتبّع نتائج البحث."
        ]
      },
      {
        "heading": [
          "Layanan dan batasnya",
          "Services and their limits",
          "الخدمات وحدودها"
        ],
        "body": [
          "Percakapan aplikasi menggunakan NotebookLM, sedangkan OpenTurath menyediakan pemilihan disiplin, katalog, dan alur telaah. Pencarian judul Arab pada katalog berbeda dari penelusuran seluruh teks kitab. Rujukan dari jawaban belum dianggap terverifikasi sebelum dibandingkan dengan edisi sumber.",
          "App conversations use NotebookLM, while OpenTurath provides discipline selection, catalogues, and study workflows. Arabic title search differs from full-text book retrieval. Answer references are not treated as verified until compared with source editions.",
          "تستخدم محادثات التطبيق NotebookLM، ويقدّم OpenTurath اختيار المجالات والفهارس ومسارات المطالعة. يختلف البحث في العناوين عن استرجاع النص الكامل. ولا تُعد إحالات الإجابة متحقّقًا منها قبل مقابلة المصادر."
        ]
      }
    ]
  },
  "about": {
    "key": "about",
    "intro": [
      "Infrastruktur riset turats, dengan sumber diutamakan.",
      "Research infrastructure for classical texts, with sources first.",
      "بنية بحثية للتراث تُقدّم المصدر."
    ],
    "blocks": [
      {
        "heading": [
          "Mengapa OpenTurath dibangun",
          "Why OpenTurath is being built",
          "لماذا يُطوَّر OpenTurath"
        ],
        "body": [
          "Penelitian turats menghubungkan ibarah, konteks, dan pendapat ulama dengan kitab serta edisinya. OpenTurath dikembangkan untuk membantu pekerjaan ini melalui katalog disiplin ilmu, asisten kajian, dan pencatatan rujukan.",
          "Research connects Arabic passages, context, and scholarly positions with books and editions. OpenTurath is being developed to support this work through discipline catalogues, study assistants, and reference records.",
          "يربط البحث التراثي العبارات والسياق وأقوال العلماء بالكتب وطبعاتها. يُطوَّر OpenTurath لخدمة هذا العمل بفهرسة المجالات ومساعدي المطالعة وتسجيل الإحالات."
        ]
      },
      {
        "heading": [
          "Mengapa sumber perlu diperiksa",
          "Why sources need review",
          "لماذا تُراجع المصادر"
        ],
        "body": [
          "AI dapat menghasilkan teks yang fasih sekaligus salah menisbahkan pendapat atau menyebut halaman yang tidak cocok. Karena itu, rujukan perlu diperiksa pada edisi sumber dan dipahami bersama konteksnya. Katalog dan jawaban AI membantu telaah, bukan menetapkan otoritas ilmiah.",
          "AI can produce fluent text while misattributing opinions or citing a mismatched page. References need review against source editions and their context. Catalogues and AI answers support study; they do not establish scholarly authority.",
          "قد يصوغ الذكاء الاصطناعي نصًّا بليغًا مع خطأ في العزو أو الصفحة. لذلك تُراجع الإحالة في طبعتها وسياقها. وتعين الفهارس والإجابات على المطالعة دون أن تُثبت حجية علمية."
        ]
      },
      {
        "heading": [
          "Yang tersedia dan yang masih dikembangkan",
          "Available work and ongoing development",
          "العمل المتاح وما يجري تطويره"
        ],
        "body": [
          "Kode aplikasi memuat katalog 20 bidang, ruang Fikih Tahawwulat dengan lima pilihan asisten, catatan, bookmark, dan pengelolaan akses. Website menampilkan katalog dan arsip perbandingan Q001. Distribusi publik aplikasi serta pemeriksaan lengkap sumber dalam arsip belum tersedia di situs ini.",
          "The app code includes 20 study fields, a Fiqh Tahawwulat space with five assistants, notes, bookmarks, and access management. This website presents the catalogue and Q001 comparison archive. Public app distribution and completed source reviews are not yet available on this site.",
          "يتضمن كود التطبيق ٢٠ مجالًا ومساحة لفقه التحولات بخمسة مساعدين وملاحظات وعلامات وإدارة وصول. يعرض الموقع الفهرس وأرشيف Q001؛ ولا تتوفر فيه بعد تنزيلات عامة أو مراجعة مكتملة لمصادر الأرشيف."
        ]
      },
      {
        "heading": [
          "Claude dalam pengembangan",
          "Claude in development",
          "Claude في التطوير"
        ],
        "body": [
          "Pengelola melaporkan penggunaan Claude Code dalam pekerjaan pengembangan dan riset OpenTurath. Bukti penggunaan ini perlu dipisahkan dari integrasi API pada layanan percakapan. Pemrosesan corpus, evaluasi kutipan, dan kapasitas API menjadi arah pengembangan yang perlu didokumentasikan melalui contoh kerja serta ukuran beban yang jelas.",
          "The operator reports using Claude Code in OpenTurath development and research. This use should be distinguished from API integration in the conversation service. Corpus processing, quotation evaluation, and API capacity are development directions requiring documented examples and workload measurements.",
          "تذكر الجهة المشغّلة استخدام Claude Code في تطوير OpenTurath والبحث. ويختلف ذلك عن دمج API في خدمة المحادثة. تحتاج معالجة المجموعة وتقييم النصوص وتوسعة API إلى أمثلة موثّقة وقياسات لحجم العمل."
        ]
      },
      {
        "heading": [
          "Pemeriksaan ilmiah",
          "Scholarly review",
          "المراجعة العلمية"
        ],
        "body": [
          "Arsip Q001 mencatat satu pertanyaan, enam jawaban, dan sepuluh kutipan yang belum diperiksa terhadap edisi sumber. Belum tersedia catatan publik mengenai peserta pengujian ahli, tugas, atau hasil penilaiannya. Koreksi dapat dikirim melalui email dengan identitas kitab, edisi, dan halaman; status pemeriksaan diperbarui setelah bukti ditelaah.",
          "Q001 records one question, six answers, and ten quotations awaiting source-edition review. Public records of expert participants, tasks, or assessment results are not yet available. Corrections can be emailed with the book, edition, and page; review status is updated after evidence is examined.",
          "يسجّل Q001 سؤالًا وست إجابات وعشرة نصوص تنتظر مقابلة المصادر. لم تتوفر بعد سجلات عامة للمراجعين ومهامهم ونتائجهم. تُرسل التصحيحات بالبريد مع الكتاب والطبعة والصفحة، وتُحدّث الحالة بعد فحص الأدلة."
        ]
      },
      {
        "heading": [
          "Pengelola, Tata Kelola & Bantuan",
          "Operator, Governance and Support",
          "الجهة المشغلة والحوكمة والدعم"
        ],
        "body": [
          "Pengelola OpenTurath, Indonesia. Dikelola dengan komitmen menjaga integritas ilmiah, adab transmisi keilmuan, dan keterbukaan metodologis. Kontak resmi: openturath@gmail.com. Jam layanan Senin sampai Jumat, 09.00 sampai 17.00 WIB (UTC+7). Tanggapan awal diupayakan dalam 2 hari kerja.",
          "Pengelola OpenTurath, Indonesia. Governed by a steadfast commitment to scholarly integrity, the adab of knowledge transmission, and methodological transparency. Official contact: openturath@gmail.com. Service hours: Monday to Friday, 09:00 to 17:00 WIB (UTC+7). Initial response is targeted within 2 business days.",
          "الجهة المشغلة: Pengelola OpenTurath، إندونيسيا. تُدار المنصة بالتزام راسخ بصيانة الأمانة العلمية، وآداب حمل العلم، والشفافية المنهجية. للتواصل الرسمي: openturath@gmail.com. ساعات الخدمة: من الاثنين إلى الجمعة، ٠٩:٠٠ إلى ١٧:٠٠ بتوقيت جاكرتا (UTC+7). ويُستهدف الرد الأولي خلال يومي عمل."
        ]
      }
    ]
  },
  "terms": {
    "key": "terms",
    "intro": [
      "Ketentuan Layanan",
      "Terms of Service",
      "شروط الخدمة"
    ],
    "blocks": [
      {
        "heading": [
          "1. Pengelola dan Cakupan Ketentuan",
          "1. Operator and Scope of Terms",
          "١. المشغّل ونطاق الشروط"
        ],
        "body": [
          "OpenTurath dikelola oleh Pengelola OpenTurath, beralamat di Indonesia, selanjutnya disebut \"kami\". Pengguna aplikasi disebut \"Anda\". Kontak layanan tersedia melalui openturath@gmail.com.\n\nKetentuan ini mengatur penggunaan akun, asisten AI, katalog rujukan, Catatan, dan fitur berbayar yang disediakan melalui OpenTurath. Informasi paket yang ditampilkan sebelum pembelian, Kebijakan Pembayaran dan Pengembalian Dana, serta Panduan Penggunaan AI dan Pemeriksaan Rujukan menjadi bagian dari ketentuan penggunaan yang relevan.",
          "OpenTurath is operated by Pengelola OpenTurath, located in Indonesia, hereinafter referred to as \"we\" or \"us\". Users of the application are referred to as \"you\". Service contact is available via openturath@gmail.com.\n\nThese terms govern the use of accounts, AI assistants, reference catalogs, Notes, and paid features provided through OpenTurath. Plan details displayed prior to purchase, the Payment and Refund Policy, and the AI Guidelines and Reference Verification Guide form part of the applicable terms of use.",
          "تُدار منصة OpenTurath بواسطة Pengelola OpenTurath، ومقرها في إندونيسيا، ويُشار إليها لاحقًا بـ \"نحن\". ويُشار إلى مستخدمي التطبيق بـ \"أنت\". يتوفر التواصل عبر openturath@gmail.com.\n\nتنظم هذه الشروط استخدام الحسابات، ومساعدي الذكاء الاصطناعي، وفهرس المراجع، وميزة الملاحظات، والخدمات المدفوعة المقدمة عبر OpenTurath. وتُعد تفاصيل الباقات المعروضة قبل الشراء، وسياسة الدفع واسترداد الأموال، ودليل استخدام الذكاء الاصطناعي ومراجعة النقول جزءًا لا يتجزأ من هذه الشروط."
        ]
      },
      {
        "heading": [
          "2. Persetujuan dan Persyaratan Pengguna",
          "2. Agreement and User Eligibility",
          "٢. الموافقة وأهلية المستخدم"
        ],
        "body": [
          "Sebelum membuat akun atau membeli paket, Anda diberi kesempatan membaca ketentuan yang berlaku. Penggunaan mandiri OpenTurath ditujukan bagi pengguna berusia sekurang-kurangnya 18 tahun. Anda juga harus memiliki kecakapan atau kewenangan yang diperlukan untuk membuat perjanjian dan melakukan pembayaran.\n\nAkses bagi pengguna di bawah 18 tahun belum dibuka melalui pendaftaran mandiri. Jika bertindak untuk lembaga, Anda harus berwenang mewakilinya. Pembelian individu tidak otomatis memberikan hak penggunaan bersama untuk seluruh anggota lembaga.",
          "Before creating an account or purchasing a plan, you are given the opportunity to review the applicable terms. Independent use of OpenTurath is intended for users who are at least 18 years of age. You must also possess the legal capacity or authority required to enter into agreements and make payments.\n\nAccess for users under 18 years of age is not currently available through self-registration. If acting on behalf of an institution, you must be authorized to represent it. An individual purchase does not automatically grant shared usage rights for all members of that institution.",
          "قبل إنشاء الحساب أو شراء أي باقة، يُتاح لك الاطلاع على الشروط المعمول بها. الاستخدام الذاتي لمنصة OpenTurath مخصص لمن أتم ثمانية عشر (١٨) عامًا على الأقل، مع توافر الأهلية القانونية أو الصلاحية اللازمة للتعاقد وإتمام المدفوعات.\n\nالوصول لمن هم دون سن ١٨ عامًا غير متاح حاليًا عبر التسجيل الذاتي. وإذا كنت تتصرف نيابة عن مؤسسة، فيجب أن تكون مفوضًا رسميًا بتمثيلها. الشراء الفردي لا يمنح تلقائيًا حقوق استخدام مشترك لجميع أفراد المؤسسة."
        ]
      },
      {
        "heading": [
          "3. Akun dan Keamanan Akses",
          "3. Account and Access Security",
          "٣. الحساب وأمن الوصول"
        ],
        "body": [
          "Gunakan informasi akun yang benar dan akses masuk yang menjadi hak Anda. Akun bersifat pribadi, kecuali suatu paket secara tertulis menyediakan penggunaan untuk beberapa orang.\n\nJaga perangkat dan akses masuk Anda. Jangan memberikan kata sandi atau kode sekali pakai kepada pihak lain. Laporkan dugaan penggunaan tanpa izin melalui openturath@gmail.com. Laporan pengambilalihan akun akan diperiksa berdasarkan keadaan dan bukti yang tersedia.",
          "Provide accurate account information and use credentials that you are authorized to use. Accounts are personal, unless a specific plan expressly provides for multi-user access in writing.\n\nSafeguard your device and login credentials. Do not share your password or one-time codes with others. Report any suspected unauthorized access to openturath@gmail.com. Account takeover reports will be investigated based on the circumstances and available evidence.",
          "يجب استخدام بيانات صحيحة وبيانات دخول مخولة لك قانونًا. الحساب شخصي وخاص، ما لم تنص باقة معينة صراحةً على استخدام متعدد. حافظ على جهازك وبيانات دخولك، ولا تشارك كلمة المرور أو رموز التحقق لمرة واحدة مع أي طرف. أبلغ عن أي اشتباه في استخدام غير مصرح به عبر openturath@gmail.com، وستتم مراجعة البلاغات بناءً على الوقائع والأدلة المتاحة."
        ]
      },
      {
        "heading": [
          "4. Fungsi Layanan dan Batas Jawaban AI",
          "4. Service Purpose and Limits of AI Outputs",
          "٤. وظيفة الخدمة وحدود مخرجات الذكاء الاصطناعي"
        ],
        "body": [
          "OpenTurath membantu penelusuran literatur, pembacaan kutipan, dan penyusunan bahan belajar. Jawaban dapat mengandung kesalahan pada penjelasan, atribusi, terjemahan, atau keterangan rujukan.\n\nPeriksa kutipan pada kitab dan edisi yang digunakan sebelum menjadikannya dasar tulisan, pengajaran, keputusan, atau penyampaian hukum kepada orang lain. Nomor halaman pada satu edisi tidak selalu sama dengan edisi lain.\n\nJawaban AI bukan merupakan fatwa resmi, penetapan hukum yang mengikat, atau pengganti bimbingan guru dan ulama yang berkompeten. Tidak ditemukannya rujukan dalam hasil pencarian berarti layanan belum menemukannya pada penelusuran tersebut, bukan bukti bahwa pembahasannya tidak ada.",
          "OpenTurath assists in literary research, passage reading, and study preparation. Responses may contain errors in explanation, attribution, translation, or reference details.\n\nVerify citations against the original book and specific edition before using them as a basis for writing, teaching, decisions, or conveying legal rulings to others. Page numbers in one edition may not correspond to those in another.\n\nAI outputs do not constitute official fatwas, binding legal determinations, or substitutes for guidance from qualified teachers and scholars. The absence of a citation in search results indicates only that the service did not locate it in that query, not that the discussion does not exist.",
          "تساعد منصة OpenTurath في البحث الأدبي ومطالعة النقول وإعداد المواد الدراسية. قد تتضمن الإجابات أخطاء في الشرح أو نسبة الأقوال أو الترجمة أو بيانات المراجع.\n\nتحقق من النقول في طبعة الكتاب المعتمدة قبل جعلها أساسًا لكتابة أو تدريس أو فتوى أو تقرير حكم للغير؛ فاختلاف الطبعات يتبعه اختلاف أرقام الصفحات.\n\nمخرجات الذكاء الاصطناعي ليست فتاوى شرعية ولا أحكامًا ملزمة ولا بديلًا عن التلقي من العلماء المعتبرين. وعدم العثور على مسألة في نتائج البحث يعني عدم الوصول إليها في ذلك البحث فقط، ولا يعد دليلًا على عدم وجودها في المصادر."
        ]
      },
      {
        "heading": [
          "5. Paket, Pembayaran, dan Masa Akses",
          "5. Plans, Payment, and Access Period",
          "٥. الباقات والدفع ومدة الوصول"
        ],
        "body": [
          "Harga, cakupan asisten, masa akses, batas penggunaan, kebutuhan akun pihak ketiga, serta biaya yang berlaku ditampilkan sebelum Anda membayar.\n\nLangganan diperpanjang secara manual. Kami tidak melakukan penagihan berulang otomatis (auto-debit) dari pembelian paket ini.\n\nMasa akses dimulai ketika aktivasi berhasil dan tanggal berakhir ditampilkan pada akun. Pembayaran diproses melalui Midtrans menurut metode yang tersedia pada saat transaksi. Keberhasilan pembayaran dan aktivasi akses adalah dua status yang berbeda. Jika dana telah dibayarkan namun langganan belum aktif, hubungi bantuan dengan nomor transaksi.",
          "Prices, assistant scope, access duration, usage limits, third-party account requirements, and applicable fees are clearly displayed before you pay.\n\nSubscriptions are renewed manually. We do not perform recurring automatic billing (auto-debit) for purchases of these plans.\n\nThe access period begins upon successful activation, and the expiration date is displayed in your account. Payments are processed through Midtrans using methods available at transaction time. Payment success and access activation are two distinct statuses. If funds have been deducted but access remains inactive, contact support with your transaction number.",
          "تُعرض الأسعار ونطاق المساعدين ومدة الوصول وحدود الاستخدام ومتطلبات حسابات الأطراف الثالثة والرسوم بوضوح قبل إتمام الدفع.\n\nتُجدد الاشتراكات يدويًا دون أي خصم تلقائي متكرر (auto-debit).\n\nتبدأ مدة الوصول فور اكتمال التفعيل ويظهر تاريخ الانتهاء في حسابك. تعالج المدفوعات عبر Midtrans وفق الوسائل المتاحة وقت المعاملة. نجاح الدفع وتفعيل الوصول مرحلتان منفصلتان؛ فإذا خُصم المبلغ ولم يُفعّل الاشتراك، فتواصل مع الدعم برقم المعاملة."
        ]
      },
      {
        "heading": [
          "6. Layanan Pihak Ketiga (Infrastruktur Pemrosesan)",
          "6. Third-Party Services (Processing Infrastructure)",
          "٦. خدمات الأطراف الثالثة (البنية التحتية للمعالجة)"
        ],
        "body": [
          "Percakapan dalam aplikasi menggunakan sesi Google NotebookLM melalui WebView atau jalur bridge. Teks pertanyaan, jawaban, dan konteks dokumen dapat diproses oleh layanan tersebut. Kebijakan serta pengaturan akun penyedia berlaku; penggunaan Claude Code dalam pengembangan tidak berarti percakapan pengguna diproses oleh Claude. OpenTurath tidak menggunakan materi pengguna untuk melatih model publik. Jangan memasukkan informasi rahasia ke percakapan.",
          "App conversations use Google NotebookLM sessions through a WebView or bridge path. Questions, answers, and document context may be processed by that service. Provider policies and account settings apply; Claude Code use in development does not mean user conversations are processed by Claude. OpenTurath does not use user material to train public models. Do not submit confidential information.",
          "تستخدم محادثات التطبيق جلسات Google NotebookLM عبر WebView أو bridge، وقد تعالج الخدمة الأسئلة والإجابات وسياق المستندات. تسري سياسات المزوّد وإعدادات الحساب؛ واستخدام Claude Code للتطوير لا يعني معالجة محادثات المستخدمين به. لا يستخدم OpenTurath مواد المستخدم لتدريب نماذج عامة. تجنّب المعلومات السرية."
        ]
      },
      {
        "heading": [
          "7. Penggunaan yang Diperbolehkan dan Dilarang",
          "7. Permitted and Prohibited Conduct",
          "٧. الاستخدام المسموح والمحظور"
        ],
        "body": [
          "Anda dapat menggunakan layanan untuk belajar, menyiapkan pengajaran, dan melakukan penelusuran sesuai paket yang dimiliki. Penggunaan hasilnya tetap harus memperhatikan hak cipta, ketepatan atribusi, serta adab keilmuan.\n\nDilarang menggunakan OpenTurath untuk mengambil alih akun, menghindari pembatasan akses secara tidak sah, menyebarkan perangkat lunak berbahaya, atau menjual kembali akses berbayar kepada pihak lain.\n\nDilarang membuat atau menyebarkan kutipan yang sengaja dipalsukan dan diatasnamakan kepada ulama atau sumber tertentu. Pembahasan ilmiah yang sah, termasuk perbedaan pendapat dan kritik terhadap suatu penafsiran, tidak dengan sendirinya merupakan pelanggaran.",
          "You may use the service for study, lesson preparation, and research within your plan's scope. Use of outputs must respect copyright, citation accuracy, and scholarly ethics.\n\nYou may not use OpenTurath to take over accounts, bypass access controls without authorization, distribute malware, or resell paid access to third parties.\n\nYou may not create or distribute deliberately fabricated quotations attributed to scholars or specific sources. Legitimate scholarly discussion, including differences of opinion and critical analysis of interpretations, does not in itself constitute a violation.",
          "يجوز استخدام الخدمة للدراسة وإعداد الدروس والبحث العلمي في حدود باقتك، مع مراعاة حقوق النشر ودقة العزو وأدب العلم.\n\nيُحظر استخدام المنصة لمحاولة الاستيلاء على الحسابات، أو تجاوز ضوابط الوصول دون إذن، أو نشر البرمجيات الخبيثة، أو إعادة بيع الوصول المدفوع.\n\nيُحظر تلفيق نقول أو نسبتها زورًا إلى العلماء أو المصادر التراثية. ولا يُعد النقاش العلمي النزيه، بما فيه بيان الخلاف ونقد التفسيرات، مخالفة لهذه الشروط."
        ]
      },
      {
        "heading": [
          "8. Catatan dan Materi Pengguna",
          "8. User Notes and Materials",
          "٨. ملاحظات المستخدم ومواده الخاصة"
        ],
        "body": [
          "Research Notes disimpan lokal di perangkat. Bookmark dan jawaban yang disimpan dapat disinkronkan ke Firestore ketika Anda login, termasuk kutipan dan rujukannya. Periksa jenis penyimpanan sebelum memasukkan materi pribadi.",
          "Research Notes are stored locally. Saved bookmarks and answers can sync to Firestore when you sign in, including quotations and references. Check the storage type before entering private material.",
          "تُحفظ Research Notes محليًّا. ويمكن مزامنة العلامات والإجابات المحفوظة مع Firestore عند تسجيل الدخول، بما فيها النصوص والإحالات. راجع نوع التخزين قبل إدخال مواد خاصة."
        ]
      },
      {
        "heading": [
          "9. Hak atas Aplikasi dan Kitab",
          "9. App Rights and Manuscript Heritage",
          "٩. حقوق الملكية الفكرية للتطبيق والمصنفات"
        ],
        "body": [
          "Hak atas perangkat lunak, tampilan, dan merek OpenTurath tetap berada pada pemegang haknya. Materi kitab, terjemahan, dan tahkik mengikuti status hak masing-masing.\n\nAkses berbayar tidak memindahkan hak cipta atas kitab atau memberi izin umum untuk menyebarluaskan seluruh isi kitab secara komersial. Penggunaan kutipan harus memperhatikan batas penggunaan wajar dan kewajiban atribusi.",
          "Rights in OpenTurath software, user interfaces, and trademarks remain with their respective holders. Manuscript texts, translations, and scholarly editions follow their respective copyright statuses.\n\nPaid access does not transfer copyright in books or grant a general license to distribute full texts commercially. Quotations must observe fair-use standards and mandatory scholarly attribution.",
          "تظل حقوق برمجيات OpenTurath وتصميماتها وعلاماتها محفوظة لأصحابها. وتتبع نصوص الكتب والترجمات والتحقيقات حقوق حائزيها.\n\nالوصول المدفوع لا ينقل ملكية الكتب الفكرية ولا يمنح ترخيصًا بنشر الكتب كاملة تجاريًا. ويجب في الاقتباس مراعاة الاستخدام العادل وواجب العزو العلمي."
        ]
      },
      {
        "heading": [
          "10. Ketersediaan dan Perubahan Fitur",
          "10. Feature Changes and Maintenance",
          "١٠. توفر الخدمة وتعديل الميزات"
        ],
        "body": [
          "Layanan dapat mengalami pemeliharaan berkala atau pembaruan teknis. Kami berupaya memberi pemberitahuan mengenai pemeliharaan terencana.\n\nPerubahan yang secara material mengurangi manfaat paket berbayar akan disertai pilihan penyelesaian yang wajar. Kami tidak menggunakan perubahan ketentuan untuk menghapus hak yang sudah timbul dari pembelian Anda.",
          "The service may undergo periodic maintenance or technical updates. We endeavor to provide advance notice for planned maintenance.\n\nChanges that materially reduce the benefits of a paid plan will be accompanied by reasonable remedy options. We do not use terms modifications to retroactively eliminate rights accrued from your purchases.",
          "قد تخضع الخدمة لصيانة دورية أو تحديثات فنية، ونسعى للإشعار المسبق بالصيانة المجدولة.\n\nالتعديلات التي تنقص من منافع الباقة المدفوعة نقصًا جوهريًا ستصحبها حلول تعويضية معقولة، ولن تُستغل التعديلات لإسقاط حقوق نشأت بالفعل من شرائك."
        ]
      },
      {
        "heading": [
          "11. Pembatasan dan Penutupan Akun",
          "11. Account Restrictions and Termination",
          "١١. تعليق الحساب وإغلاقه"
        ],
        "body": [
          "Kami dapat membatasi akses jika terdapat dasar yang wajar mengenai pelanggaran serius, risiko keamanan, atau penggunaan tanpa hak. Tindakan disesuaikan dengan tingkat masalah, mulai dari peringatan, penghentian sementara, hingga penutupan akun.\n\nJika keadaan memungkinkan, kami menyampaikan alasan dan memberi kesempatan klarifikasi melalui openturath@gmail.com.",
          "We may restrict access if there are reasonable grounds regarding serious violations, security risks, or unauthorized usage. Actions are proportionate to the severity, ranging from notices and temporary suspension to account termination.\n\nWhere practicable, we communicate the reasons and provide an opportunity for clarification via openturath@gmail.com.",
          "يجوز تقييد الوصول عند وجود أسباب وجيهة لمخالفة جسيمة أو خطر أمني أو استخدام غير مشروع. وتتدرج الإجراءات تناسبًا من الإنذار والتعليق المؤقت إلى الإغلاق التام.\n\nومتى أمكن، نوضح الأسباب ونمنح فرصة لتقديم الإيضاحات عبر openturath@gmail.com."
        ]
      },
      {
        "heading": [
          "12. Tanggung Jawab dan Hak Pengguna",
          "12. Liability and Consumer Rights",
          "١٢. المسؤولية وحقوق المستهلك"
        ],
        "body": [
          "Kami bertanggung jawab menyediakan layanan sesuai perjanjian dan hukum yang berlaku. Penjelasan mengenai keterbatasan AI tidak menghapus kewajiban kami untuk memberikan informasi yang benar, menangani keluhan, atau menyelesaikan layanan berbayar.\n\nAnda bertanggung jawab menilai kesesuaian hasil untuk tujuan penggunaannya dan memeriksa sumber sebelum mengambil kesimpulan. Tidak ada ketentuan yang meniadakan hak konsumen yang dilindungi undang-undang.",
          "We are responsible for providing services in accordance with our agreement and governing law. Disclaimers regarding AI limitations do not negate our duty to provide truthful information, handle complaints, or deliver paid services.\n\nYou are responsible for evaluating the suitability of outputs for your intended purpose and checking sources before drawing conclusions. Nothing in these terms excludes statutory consumer rights.",
          "نلتزم بتقديم الخدمة وفق الاتفاق والقوانين السارية. وبيان حدود الذكاء الاصطناعي لا يعفينا من واجب تحري الصدق ومعالجة الشكاوى وإتمام الخدمات المدفوعة.\n\nيتحمل المستخدم مسؤولية تقييم المخرجات لغرضه ومراجعة الأصول قبل الاستنتاج. ولا يلغي أي بند من هذه الشروط حقوق المستهلك المكفولة قانونًا."
        ]
      },
      {
        "heading": [
          "13. Pengaduan dan Musyawarah",
          "13. Complaints and Dispute Resolution",
          "١٣. الشكاوى وتسوية النزاعات"
        ],
        "body": [
          "Hubungi openturath@gmail.com dengan penjelasan masalah dan informasi yang relevan. Kami akan mencatat pengaduan, menyampaikan perkembangan penanganan dalam 2 (dua) hari kerja, dan mengupayakan penyelesaian secara musyawarah.\n\nKetentuan ini tunduk pada hukum Republik Indonesia.",
          "Contact openturath@gmail.com with a clear description of the issue and relevant information. We will log your complaint, provide an initial update within 2 (two) business days, and seek amicable resolution.\n\nThese terms are governed by the laws of the Republic of Indonesia.",
          "تواصل عبر openturath@gmail.com مع بيان المشكلة والبيانات المتعلقة بها. سنقيد الشكوى ونقدم تحديثًا أوليًا خلال يومي (٢) عمل، مع السعي للحل الودي.\n\nتخضع هذه الشروط لقوانين جمهورية إندونيسيا."
        ]
      },
      {
        "heading": [
          "14. Perubahan Ketentuan dan Kontak",
          "14. Policy Amendments and Official Contacts",
          "١٤. تعديل الشروط وبيانات التواصل"
        ],
        "body": [
          "Informasi website diperbarui 8 Oktober 2026. Naskah aplikasi v1.0 bertanggal 13 September 2026 tersedia sebagai dokumen sebelumnya. Untuk pertanyaan tentang layanan, pemrosesan data, atau hak privasi: openturath@gmail.com. Pengelola OpenTurath, Indonesia.",
          "Website information updated 8 October 2026. The app v1.0 text dated 13 September 2026 is available as an earlier document. For questions about services, data processing, or privacy rights: openturath@gmail.com. Pengelola OpenTurath, Indonesia.",
          "حُدّثت معلومات الموقع في ٨ أكتوبر ٢٠٢٦. يتوفر نص التطبيق v1.0 المؤرّخ في ١٣ سبتمبر ٢٠٢٦ كوثيقة سابقة. للاستفسار عن الخدمات والبيانات وحقوق الخصوصية: openturath@gmail.com. الجهة المشغّلة في إندونيسيا."
        ]
      }
    ],
    "policy": true
  },
  "privacy": {
    "key": "privacy",
    "intro": [
      "Kebijakan Privasi",
      "Privacy Policy",
      "سياسة الخصوصية"
    ],
    "blocks": [
      {
        "heading": [
          "1. Pengelola Data dan Ruang Lingkup",
          "1. Data Controller and Scope",
          "١. مسؤول معالجة البيانات ونطاق السياسة"
        ],
        "body": [
          "Kebijakan Privasi ini menjelaskan pemrosesan data pribadi saat Anda menggunakan aplikasi OpenTurath, pembayaran, dan bantuan layanan. Pengelola OpenTurath (Indonesia) bertanggung jawab atas pemrosesan data yang tujuan dan caranya ditentukan oleh OpenTurath, sesuai UU Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi.\n\nUntuk pertanyaan privasi, hubungi openturath@gmail.com.",
          "This Privacy Policy explains personal data processing when you use OpenTurath applications, payments, and customer support. Pengelola OpenTurath (Indonesia) is the data controller responsible for determining purposes and means of processing, pursuant to Law No. 27 of 2022 on Personal Data Protection (UU PDP).\n\nFor privacy inquiries, contact openturath@gmail.com.",
          "توضح سياسة الخصوصية هذه معالجة البيانات الشخصية عند استخدام تطبيقات OpenTurath وخدمات الدفع والدعم. وتعد Pengelola OpenTurath في إندونيسيا هي الجهة المسؤولة عن تحديد أغراض المعالجة ووسائلها وفق قانون حماية البيانات الشخصية الإندونيسي (القانون رقم ٢٧ لسنة ٢٠٢٢).\n\nللاستفسارات المتعلقة بالخصوصية: openturath@gmail.com."
        ]
      },
      {
        "heading": [
          "2. Data yang Diproses",
          "2. Categories of Processed Data",
          "٢. البيانات التي تتم معالجتها"
        ],
        "body": [
          "Kami memproses data sesuai fitur yang Anda gunakan:\n• Akun: Nama, alamat email, dan identitas profil dari akun autentikasi untuk verifikasi dan personalisasi.\n• Langganan: Paket yang dipilih, status, masa aktif, dan penggunaan voucher.\n• Pembayaran: Nomor transaksi, jumlah pembayaran, metode, waktu, dan status dari penyedia Midtrans.\n• Kontak Transaksi: Nomor WhatsApp/telepon yang Anda berikan saat pembayaran untuk pengiriman informasi aktivasi.\n• Percakapan: Pertanyaan, jawaban, dan konteks telaah yang diproses melalui sesi komputasi riset terisolasi.\n• Catatan: Catatan, kutipan, dan rujukan yang Anda simpan pada penyimpanan lokal perangkat.\n• Bantuan: Alamat kontak, isi pengaduan, nomor transaksi, dan lampiran tangkapan layar untuk penanganan masalah.\n• Sesi Teknis: Token sesi autentikasi yang aman untuk mempertahankan login di perangkat.\nResearch Notes disimpan lokal di perangkat. Bookmark dan jawaban yang disimpan dapat disinkronkan ke Firestore ketika Anda login, termasuk kutipan dan rujukannya. Periksa jenis penyimpanan sebelum memasukkan materi pribadi.",
          "We process data based on features you use:\n• Account: Name, email address, and profile identifier from the authentication account for verification and personalization.\n• Subscription: Selected plan, status, validity dates, and voucher usage.\n• Payment: Transaction ID, payment amount, method, timestamp, and status from provider Midtrans.\n• Transaction Contact: WhatsApp/phone number provided during checkout for activation notices.\n• Conversations: Prompts, responses, and study context processed via isolated research compute sessions.\n• Notes: Notes, quotations, and locators stored in device local storage.\n• Support: Contact address, inquiry details, transaction ID, and screenshots for troubleshooting.\n• Technical Sessions: Secure authentication session tokens to maintain login on your device.\nResearch Notes are stored locally. Saved bookmarks and answers can sync to Firestore when you sign in, including quotations and references. Check the storage type before entering private material.",
          "نعالج البيانات بحسب الميزات المستخدمة:\n• الحساب: الاسم والبريد الإلكتروني والصورة العامة من حساب المصادقة للتحقق والتخصيص.\n• الاشتراك: الباقة المختارة، وحالتها، وفترة الصلاحية، واستخدام القسائم.\n• المدفوعات: رقم المعاملة والمبلغ والوسيلة والوقت والحالة من مزود الدفع Midtrans.\n• بيانات التواصل للمعاملات: رقم الهاتف/واتساب المدخل عند الدفع لإشعار التفعيل.\n• المحادثات: الأسئلة والأجوبة وسياق المطالعة المعالج عبر جلسات حوسبة بحثية معزولة.\n• الملاحظات: الملاحظات والنقول والمراجع المحفوظة محليًا على جهازك.\n• الدعم الفني: وسيلة الاتصال وفحوى البلاغ ورقم المعاملة والصور المرفقة.\n• الجلسات الفنية: رموز الجلسات الآمنة للحفاظ على تسجيل الدخول.\nتُحفظ Research Notes محليًّا. ويمكن مزامنة العلامات والإجابات المحفوظة مع Firestore عند تسجيل الدخول، بما فيها النصوص والإحالات. راجع نوع التخزين قبل إدخال مواد خاصة."
        ]
      },
      {
        "heading": [
          "3. Tujuan dan Dasar Pemrosesan",
          "3. Purposes and Legal Basis of Processing",
          "٣. أغراض المعالجة وأساسها القانوني"
        ],
        "body": [
          "Data akun dan transaksi diproses untuk menyediakan layanan yang Anda minta, mengelola langganan, dan melaksanakan perjanjian. Pencatatan transaksi juga diperlukan untuk memenuhi kewajiban hukum administrasi perpajakan dan transaksi keuangan.\n\nKami tidak menjual data pribadi Anda kepada pihak ketiga manapun, dan tidak menggunakan percakapan Anda untuk iklan bertarget.",
          "Account and transaction data are processed to provide requested services, manage subscriptions, and perform contracts. Transaction records are also required to comply with statutory taxation and financial transaction obligations.\n\nWe do not sell your personal data to any third party, nor do we use your conversation contents for targeted advertising.",
          "تُعالج بيانات الحساب والمعاملات لتقديم الخدمات المطلوبة وإدارة الاشتراكات وتنفيذ الاتفاقيات، وتُحفظ سجلات الدفع للوفاء بالالتزامات المالية والضريبية المقررة قانونًا.\n\nنحن لا نبيع بياناتك الشخصية لأي طرف ثالث، ولا نستخدم محتوى محادثاتك في الإعلانات الموجهة."
        ]
      },
      {
        "heading": [
          "4. Percakapan AI dan Infrastruktur Komputasi",
          "4. AI Conversations and Computing Infrastructure",
          "٤. محادثات الذكاء الاصطناعي والبنية التحتية الحاسوبية"
        ],
        "body": [
          "Percakapan dalam aplikasi menggunakan sesi Google NotebookLM melalui WebView atau jalur bridge. Teks pertanyaan, jawaban, dan konteks dokumen dapat diproses oleh layanan tersebut. Kebijakan serta pengaturan akun penyedia berlaku; penggunaan Claude Code dalam pengembangan tidak berarti percakapan pengguna diproses oleh Claude. OpenTurath tidak menggunakan materi pengguna untuk melatih model publik. Jangan memasukkan informasi rahasia ke percakapan.",
          "App conversations use Google NotebookLM sessions through a WebView or bridge path. Questions, answers, and document context may be processed by that service. Provider policies and account settings apply; Claude Code use in development does not mean user conversations are processed by Claude. OpenTurath does not use user material to train public models. Do not submit confidential information.",
          "تستخدم محادثات التطبيق جلسات Google NotebookLM عبر WebView أو bridge، وقد تعالج الخدمة الأسئلة والإجابات وسياق المستندات. تسري سياسات المزوّد وإعدادات الحساب؛ واستخدام Claude Code للتطوير لا يعني معالجة محادثات المستخدمين به. لا يستخدم OpenTurath مواد المستخدم لتدريب نماذج عامة. تجنّب المعلومات السرية."
        ]
      },
      {
        "heading": [
          "5. Catatan lokal dan bookmark cloud",
          "5. Local notes and cloud bookmarks",
          "٥. الملاحظات المحلية والعلامات السحابية"
        ],
        "body": [
          "Research Notes disimpan lokal di perangkat. Bookmark dan jawaban yang disimpan dapat disinkronkan ke Firestore ketika Anda login, termasuk kutipan dan rujukannya. Periksa jenis penyimpanan sebelum memasukkan materi pribadi.",
          "Research Notes are stored locally. Saved bookmarks and answers can sync to Firestore when you sign in, including quotations and references. Check the storage type before entering private material.",
          "تُحفظ Research Notes محليًّا. ويمكن مزامنة العلامات والإجابات المحفوظة مع Firestore عند تسجيل الدخول، بما فيها النصوص والإحالات. راجع نوع التخزين قبل إدخال مواد خاصة."
        ]
      },
      {
        "heading": [
          "6. Penerima dan Penyedia Layanan",
          "6. Service Providers and Data Recipients",
          "٦. مزودو الخدمات والجهات المستلمة للبيانات"
        ],
        "body": [
          "Google/Firebase: autentikasi, akun, transaksi, hak akses, dan sinkronisasi bookmark yang dipilih pengguna. Google NotebookLM: sesi percakapan dan pemrosesan konteks dokumen. Midtrans: pembayaran. Hosting/CDN, termasuk Cloudflare pada domain publik: penyajian website dan data teknis koneksi; beacon performa dapat aktif pada konfigurasi CDN. Website tidak memuat percakapan aplikasi.",
          "Google/Firebase: authentication, accounts, transactions, entitlements, and user-selected bookmark sync. Google NotebookLM: conversations and document context processing. Midtrans: payments. Hosting/CDN, including Cloudflare on the public domain: site delivery and technical connection data; performance beacons may be enabled by CDN configuration. This site does not host app conversations.",
          "Google/Firebase للمصادقة والحسابات والمعاملات والصلاحيات ومزامنة العلامات المختارة. Google NotebookLM للمحادثات وسياق المستندات. Midtrans للدفع. الاستضافة وCDN ومنها Cloudflare لتقديم الموقع وبيانات الاتصال؛ وقد تُفعّل قياسات الأداء في CDN. لا يستضيف الموقع محادثات التطبيق."
        ]
      },
      {
        "heading": [
          "7. Kebijakan Iklan, Analitik, dan Promosi",
          "7. Advertising, Analytics, and Promotion Policy",
          "٧. سياسة الإعلانات والتحليلات والترويج"
        ],
        "body": [
          "Website tidak menampilkan iklan pihak ketiga. OpenTurath tidak menjual data pribadi. Domain publik menggunakan Cloudflare; pengukuran performa website dapat berjalan melalui beacon CDN, terpisah dari isi percakapan aplikasi. Pengelola perlu menjaga konfigurasi CDN selaras dengan informasi ini.",
          "The website does not show third-party advertisements. OpenTurath does not sell personal data. The public domain uses Cloudflare; CDN beacons may measure site performance, separately from app conversation content. The operator must keep CDN settings aligned with this information.",
          "لا يعرض الموقع إعلانات من أطراف ثالثة ولا يبيع OpenTurath البيانات الشخصية. يستخدم النطاق العام Cloudflare، وقد يقيس beacon أداء الموقع بمعزل عن محادثات التطبيق. تُراعى مطابقة إعدادات CDN لهذه المعلومات."
        ]
      },
      {
        "heading": [
          "8. Pemrosesan Data Lintas Wilayah",
          "8. Cross-Border Data Processing",
          "٨. المعالجة الدولية للبيانات"
        ],
        "body": [
          "Data akun, transaksi, dan bookmark tersinkron diproses melalui layanan Google/Firebase. Sesi NotebookLM mengikuti layanan dan pengaturan akun Google. Lokasi pemrosesan serta retensi mengikuti ketentuan penyedia masing-masing; tanyakan pengelola bila Anda membutuhkan informasi sebelum memakai layanan.",
          "Accounts, transactions, and synced bookmarks are processed through Google/Firebase. NotebookLM sessions follow Google services and account settings. Processing locations and retention follow each provider’s terms; ask the operator for information before using a service.",
          "تُعالج الحسابات والمعاملات والعلامات المتزامنة عبر Google/Firebase. وتتبع جلسات NotebookLM خدمات Google وإعدادات الحساب. تخضع مواقع المعالجة ومدد الاحتفاظ لشروط كل مزوّد؛ استفسر قبل استخدام الخدمة."
        ]
      },
      {
        "heading": [
          "9. Masa Penyimpanan Data (Retensi)",
          "9. Data Retention Periods",
          "٩. فترات الاحتفاظ بالبيانات"
        ],
        "body": [
          "• Data Akun: Disimpan selama akun aktif, dan dihapus setelah permohonan penutupan akun disetujui.\n• Data Transaksi: Disimpan selama batas waktu yang diwajibkan oleh ketentuan perpajakan dan hukum transaksi keuangan Republik Indonesia.\n• Catatan Pengguna: Disimpan di perangkat Anda hingga Anda menghapusnya sendiri atau mencopot aplikasi.\n• Pengaduan Bantuan: Disimpan selama proses penyelesaian masalah dan pengarsipan layanan.\nBookmark tersinkron disimpan pada akun cloud sampai dihapus melalui fitur yang tersedia. Pertanyaan tentang penghapusan atau retensi layanan pihak ketiga dapat diajukan ke pengelola.",
          "• Account Data: Retained while the account is active, and deleted upon approved account closure requests.\n• Transaction Data: Retained for periods required by statutory taxation and financial regulations of Indonesia.\n• User Notes: Retained on your device until deleted by you or the app is uninstalled.\n• Support Inquiries: Retained during problem resolution and customer service archiving.\nSynced bookmarks remain in the cloud account until deleted using available features. Ask the operator about deletion or third-party retention.",
          "• بيانات الحساب: تُحفظ طوال مدة نشاط الحساب، وتُحذف فور قبول طلب إغلاق الحساب.\n• بيانات المعاملات: تُحفظ للمدة التي توجبها القوانين الضريبية والمالية في إندونيسيا.\n• ملاحظات المستخدم: تبقى في جهازك إلى أن تحذفها يدويًا أو تلغي تثبيت التطبيق.\n• بلاغات الدعم: تُحفظ خلال مدة معالجة المشكلة والتوثيق الخدمي.\nتبقى العلامات المتزامنة في الحساب السحابي حتى حذفها بالميزات المتاحة. استفسر عن الحذف أو احتفاظ خدمات الطرف الثالث لدى الجهة المشغّلة."
        ]
      },
      {
        "heading": [
          "10. Keamanan dan Perlindungan Data",
          "10. Security and Safeguards",
          "١٠. أمن البيانات وحمايتها"
        ],
        "body": [
          "Kami menerapkan langkah-langkah pengamanan teknis, termasuk komunikasi terenkripsi SSL/TLS, pembatasan akses data, dan perlindungan token sesi. Kata sandi akun Google Anda tidak pernah disimpan di server OpenTurath.",
          "We apply technical security measures, including SSL/TLS encrypted communication, restricted data access, and session token protection. Your Google account password is never stored on OpenTurath servers.",
          "نطبق تدابير أمنية فنية تشمل تشفير الاتصالات عبر SSL/TLS وتقييد الوصول وحماية رموز الجلسات. ولا يتم تخزين كلمة مرور حساب Google الخاص بك في خوادم OpenTurath مطلقًا."
        ]
      },
      {
        "heading": [
          "11. Hak Subjek Data Pengguna",
          "11. User Data Subject Rights",
          "١١. حقوق أصحاب البيانات"
        ],
        "body": [
          "Sesuai UU Perlindungan Data Pribadi, Anda berhak:\n• Mengakses dan memperoleh informasi mengenai data pribadi yang diproses.\n• Memperbarui atau memperbaiki data profil yang keliru.\n• Meminta penghapusan akun dan data pribadi Anda kapan saja melalui aplikasi.\n• Menyampaikan keberatan atau pertanyaan seputar privasi ke openturath@gmail.com.",
          "Pursuant to the Personal Data Protection Law, you have the right to:\n• Access and obtain information regarding your processed personal data.\n• Update or correct inaccurate profile data.\n• Request deletion of your account and personal data at any time via the application.\n• Submit objections or privacy questions to openturath@gmail.com.",
          "وفقًا لقانون حماية البيانات الشخصية، يحق لك:\n• الاطلاع على بياناتك الشخصية المعالجة والحصول على معلومات عنها.\n• تحديث البيانات غير الدقيقة أو تصحيحها.\n• طلب حذف حسابك وبياناتك الشخصية في أي وقت من خلال التطبيق.\n• تقديم أي استفسار أو اعتراض عبر openturath@gmail.com."
        ]
      },
      {
        "heading": [
          "12. Pengguna di Bawah Umur",
          "12. Underage Users",
          "١٢. المستخدمون القاصرون"
        ],
        "body": [
          "Pendaftaran akun mandiri ditujukan bagi pengguna berusia 18 tahun ke atas. Jika Anda orang tua atau wali dan mendapati akun dibuka tanpa izin yang diperlukan, hubungi openturath@gmail.com untuk penanganan dan penghapusan data.",
          "Self-registration is intended for users who are 18 years of age or older. If you are a parent or guardian and discover that an account was created without necessary authorization, contact openturath@gmail.com for prompt resolution and data deletion.",
          "التسجيل الذاتي مخصص لمن أتم ثمانية عشر (١٨) عامًا فما فوق. وإذا كنت ولي أمر أو وصيًا واكتشفت إنشاء حساب دون إذن، فتواصل معنا عبر openturath@gmail.com للتعامل مع الحالة وحذف البيانات فورًا."
        ]
      },
      {
        "heading": [
          "13. Kontak dan Pembaruan Kebijakan",
          "13. Contact and Policy Updates",
          "١٣. التواصل وتحديثات السياسة"
        ],
        "body": [
          "Informasi website diperbarui 8 Oktober 2026. Naskah aplikasi v1.0 bertanggal 13 September 2026 tersedia sebagai dokumen sebelumnya. Untuk pertanyaan tentang layanan, pemrosesan data, atau hak privasi: openturath@gmail.com. Pengelola OpenTurath, Indonesia.",
          "Website information updated 8 October 2026. The app v1.0 text dated 13 September 2026 is available as an earlier document. For questions about services, data processing, or privacy rights: openturath@gmail.com. Pengelola OpenTurath, Indonesia.",
          "حُدّثت معلومات الموقع في ٨ أكتوبر ٢٠٢٦. يتوفر نص التطبيق v1.0 المؤرّخ في ١٣ سبتمبر ٢٠٢٦ كوثيقة سابقة. للاستفسار عن الخدمات والبيانات وحقوق الخصوصية: openturath@gmail.com. الجهة المشغّلة في إندونيسيا."
        ]
      }
    ],
    "policy": true
  },
  "billing": {
    "key": "billing",
    "intro": [
      "Pembayaran dan Pengembalian Dana",
      "Payments and Refunds",
      "الدفع والاسترداد"
    ],
    "blocks": [
      {
        "heading": [
          "1. Informasi Sebelum Pembelian",
          "1. Pre-Purchase Information",
          "١. معلومات ما قبل الشراء"
        ],
        "body": [
          "Sebelum melakukan pembayaran, rincian harga total, cakupan modul asisten, durasi masa akses, dan metode pembayaran ditampilkan secara jelas pada halaman langganan.\n\nDurasi paket 30 hari dihitung sebagai 30 hari kalender penuh sejak aktivasi berhasil. Perubahan harga di masa mendatang tidak akan memengaruhi paket yang sedang berjalan.",
          "Prior to payment, the total price, module assistant scope, access duration, and payment methods are clearly shown on the subscription page.\n\nA 30-day plan duration is calculated as 30 full calendar days from successful activation. Future price changes will not affect an active subscription period.",
          "قبل إتمام الدفع، تُعرض تفاصيل السعر الإجمالي ونطاق المساعدين ومدة الوصول ووسائل الدفع بوضوح في صفحة الاشتراك.\n\nتُحسب مدة الباقة البالغة ٣٠ يومًا بثلاثين يومًا تقويميًا كاملًا من وقت التفعيل، ولن تؤثر أي تغييرات مستقبلية في الأسعار على الاشتراكات السارية."
        ]
      },
      {
        "heading": [
          "2. Pembayaran dan Aktivasi Akses",
          "2. Payment and Access Activation",
          "٢. الدفع وتفعيل الوصول"
        ],
        "body": [
          "Pembayaran diproses melalui gerbang pembayaran resmi Midtrans dengan metode QRIS, transfer bank (virtual account), maupun dompet digital.\n\nBukti pembayaran resmi dikirimkan melalui notifikasi Midtrans dan email akun Anda. Masa akses aktif seketika transaksi dinyatakan berhasil dan tersinkronisasi. Jika dana telah terpotong namun status belum aktif, jangan melakukan pembayaran ulang; hubungi openturath@gmail.com dengan menyertakan nomor transaksi.",
          "Payments are processed through the official Midtrans gateway using QRIS, bank transfer (virtual account), or digital wallets.\n\nOfficial payment receipts are delivered via Midtrans notifications and your account email. Access activates immediately once the transaction is confirmed successful and synced. If funds were deducted but access is not activated, do not repay; contact openturath@gmail.com with your transaction ID.",
          "تتم معالجة المدفوعات عبر بوابة Midtrans الرسمية بواسطة QRIS أو التحويل البنكي (الحساب الافتراضي) أو المحافظ الإلكترونية.\n\nيُرسل إيصال الدفع عبر إشعارات Midtrans وبريد حسابك. يُفعّل الوصول فور تأكيد نجاح المعاملة، وإذا خُصم المبلغ دون تفعيل فامتنع عن إعادة الدفع وتواصل مع openturath@gmail.com برقم المعاملة."
        ]
      },
      {
        "heading": [
          "3. Perpanjangan Manual (Tanpa Auto-Debit)",
          "3. Manual Renewal (No Auto-Debit)",
          "٣. التجديد اليدوي (دون خصم تلقائي)"
        ],
        "body": [
          "Seluruh paket langganan OpenTurath diperpanjang secara manual tanpa penagihan berulang otomatis (tanpa auto-debit). Setelah masa aktif berakhir, akses berbayar akan berhenti dengan sendirinya kecuali Anda memilih untuk memperpanjang secara sadar.",
          "All OpenTurath subscriptions renew manually without recurring automatic debit (no auto-debit). Once the active period concludes, paid access ceases automatically unless you consciously choose to renew.",
          "تُجدد كافة باقات OpenTurath يدويًا دون أي خصم تلقائي متكرر. وعند انتهاء فترة الصلاحية يتوقف الوصول تلقائيًا ما لم تقرر التجديد بنفسك."
        ]
      },
      {
        "heading": [
          "4. Ketentuan Voucher",
          "4. Voucher Terms",
          "٤. شروط القسائم"
        ],
        "body": [
          "Voucher promosi atau mitra mengikuti masa berlaku, cakupan asisten, dan batas penukaran yang tercantum saat diterbitkan. Voucher tidak dapat diuangkan dan berlaku untuk satu kali penukaran pada akun yang berhak.",
          "Promotional or partner vouchers follow the validity period, assistant scope, and redemption limits specified upon issuance. Vouchers cannot be redeemed for cash and are valid for a single redemption on eligible accounts.",
          "تخضع قسائم الترويج والشراكات لفترة الصلاحية ونطاق المساعدين وحدود الاستخدام المحددة عند إصدارها. ولا يمكن استبدالها نقدًا، وتسري لمرة واحدة لكل حساب مؤهل."
        ]
      },
      {
        "heading": [
          "5. Dasar Pengajuan Pengembalian Dana (Refund)",
          "5. Grounds for Refund",
          "٥. أسباب استرداد الأموال"
        ],
        "body": [
          "Anda berhak mengajukan pemeriksaan dan pengembalian dana apabila terjadi:\n• Pembayaran ganda akibat kendala teknis pada sistem transaksi.\n• Dana telah terpotong namun hak akses tidak aktif setelah dilakukan verifikasi.\n• Gangguan teknis berkepanjangan pada layanan inti berbayar yang tidak dapat dipulihkan.\n\nPenyelesaian dapat berupa pemulihan akses, penyesuaian masa aktif yang Anda setujui, atau pengembalian dana penuh.",
          "You are entitled to request an investigation and refund in the event of:\n• Duplicate payment resulting from technical system anomalies.\n• Funds deducted but access rights remaining inactive after verification.\n• Prolonged unrecoverable technical downtime of core paid services.\n\nRemedies may include access restoration, mutually agreed validity extensions, or a full refund.",
          "يحق لك طلب التحقق واسترداد الأموال في الحالات التالية:\n• الدفع المزدوج الناتج عن خلل فني في المعاملة.\n• خصم المبلغ مع عدم تفعيل الصلاحيات بعد التحقق.\n• انقطاع فني طويل وغير قابل للإصلاح في الخدمات الأساسية المدفوعة.\n\nوتشمل الحلول استعادة الوصول، أو تمديد الصلاحية بالتراضي، أو الاسترداد الكامل للمبلغ."
        ]
      },
      {
        "heading": [
          "6. Alur dan Waktu Penanganan Refund",
          "6. Refund Process and SLA",
          "٦. إجراءات الاسترداد والمدد الزمنية"
        ],
        "body": [
          "Kirim permohonan ke openturath@gmail.com dengan menyertakan:\n1. Alamat email akun OpenTurath.\n2. Nomor transaksi / invoice pembayaran.\n3. Bukti pembayaran resmi dari bank/e-wallet.\n4. Penjelasan kendala yang dialami.\n\nKonfirmasi penerimaan dikirimkan maksimal dalam 2 (dua) hari kerja. Pemeriksaan dan keputusan pengembalian dana diselesaikan dalam 7 (tujuh) hari kerja. Jika disetujui, pengembalian dana diproses ke rekening atau dompet asal sesuai ketentuan perbankan (7 (tujuh) hari kerja).",
          "Submit your request to openturath@gmail.com with:\n1. OpenTurath account email address.\n2. Transaction / invoice reference number.\n3. Official receipt from bank or digital wallet.\n4. Description of the issue encountered.\n\nReceipt confirmation is sent within 2 (two) business days. Investigation and refund determinations are completed within 7 (seven) business days. If approved, refunds are credited to the source account or wallet subject to banking processing timeframes (7 (seven) business days).",
          "أرسل الطلب إلى openturath@gmail.com متضمنًا:\n١. بريد حساب OpenTurath.\n٢. رقم المعاملة أو الفاتورة.\n٣. إيصال الدفع البنكي أو المحفظة الإلكترونية.\n٤. بيان الخلل الحاصل.\n\nيُؤكد استلام الطلب خلال يومي (٢) عمل، وتُستكمل المراجعة والبت في القرار خلال سبعة (٧) أيام عمل. وفي حال الموافقة يُعاد المبلغ إلى الحساب أو المحفظة الأصلية وفق الإجراءات المصرفية (٧ أيام عمل)."
        ]
      },
      {
        "heading": [
          "7. Saluran Bantuan Transaksi",
          "7. Transaction Support Channels",
          "٧. قنوات دعم المعاملات"
        ],
        "body": [
          "Kendala pembayaran dan transaksi dipantau setiap hari kerja (Senin – Jumat, 09.00 – 17.00 WIB).\nEmail layanan transaksi: openturath@gmail.com",
          "Payment and transaction issues are monitored during business hours (Monday – Friday, 09:00 – 17:00 WIB).\nTransaction support email: openturath@gmail.com",
          "تتم متابعة مشكلات الدفع والمعاملات خلال أيام العمل (من الاثنين إلى الجمعة، ٠٩:٠٠ – ١٧:٠٠ بتوقيت جاكرتا).\nبريد دعم المعاملات: openturath@gmail.com"
        ]
      }
    ],
    "policy": true
  },
  "ai-guidelines": {
    "key": "aiGuidelines",
    "intro": [
      "Ilmu yang luas. Adab yang mendalam.",
      "Deeper knowledge. Thoughtful scholarship.",
      "علم واسع. وأدب راسخ."
    ],
    "blocks": [
      {
        "heading": [
          "Gunakan alatnya. Rawat hubungan dengan guru.",
          "Use the tool. Keep learning with teachers.",
          "استعن بالأداة، والزم أهل العلم."
        ],
        "body": [
          "OpenTurath membantu Anda menemukan ibarah, menata bacaan, dan menyiapkan pertanyaan. Bawalah hasil telaah itu kepada guru agar istilah, konteks, dan kesimpulannya dipahami dengan tepat. Talaqqi juga menumbuhkan adab dan kebijaksanaan yang menyertai ilmu.",
          "Use OpenTurath to find passages, organise reading, and prepare questions. Bring that work to your teacher to explore its terms, context, and conclusions. Talaqqi also nurtures the conduct and judgement that accompany knowledge.",
          "يساعدك OpenTurath على الوصول إلى العبارات وتنظيم القراءة وإعداد الأسئلة. اعرض ما تتوصل إليه على معلمك لضبط المصطلحات وفهم السياق والنتائج. فالتلقّي ينمّي الأدب والحكمة المصاحبة للعلم."
        ]
      },
      {
        "heading": [
          "Telusuri sumbernya. Baca konteksnya.",
          "Trace the source. Read the context.",
          "تتبّع المصدر، واقرأ السياق."
        ],
        "body": [
          "Mulailah dari teks Arab, lalu periksa pembahasan sebelum dan sesudahnya. Cocokkan judul kitab, edisi, jilid, dan halaman. Tandai dengan jelas mana ibarah asli, terjemahan, dan ringkasan AI agar catatan Anda mudah ditelaah kembali.",
          "Start with the Arabic text and read the discussion around it. Check the title, edition, volume, and page. Clearly distinguish original passages, translations, and AI summaries so your notes remain easy to review.",
          "ابدأ بالنص العربي، واقرأ ما قبله وما بعده. قابل عنوان الكتاب والطبعة والجزء والصفحة، وميّز في ملاحظاتك بين العبارة الأصلية والترجمة وتلخيص الذكاء الاصطناعي، ليسهل الرجوع إليها."
        ]
      },
      {
        "heading": [
          "Hormati mazhab dan keluasan ikhtilaf.",
          "Respect schools and scholarly differences.",
          "احترم المذاهب وسعة الخلاف العلمي."
        ],
        "body": [
          "Setiap disiplin memiliki istilah, urutan rujukan, dan cara menimbang pendapat. Pelajari perbedaan untuk memperdalam pemahaman. Untuk fatwa atau penerapan hukum pada keadaan tertentu, mintalah penjelasan ulama yang memahami persoalannya.",
          "Each discipline has its terminology, reference hierarchy, and methods for weighing opinions. Study differences to deepen understanding. For a fatwa or the application of a ruling to a particular situation, consult a qualified scholar familiar with the circumstances.",
          "لكل فن مصطلحاته ومراتب مصادره ومناهجه في الترجيح. ادرس الخلاف لتوسيع الفهم، وارجع في الفتوى وتنزيل الأحكام على الوقائع إلى عالم مؤهل يدرك ملابسات المسألة."
        ]
      },
      {
        "heading": [
          "Jaga amanah dalam menukil.",
          "Keep attribution honest.",
          "احفظ أمانة النقل."
        ],
        "body": [
          "Nisbahkan pendapat kepada pemiliknya dan cantumkan sumber yang sudah Anda periksa. Jika baru membaca ringkasan, jelaskan sebatas itu. Saat menemukan kesalahan, sertakan ibarah dan rujukan yang membantu koreksi, lalu sampaikan dengan santun.",
          "Attribute opinions to their authors and cite sources you have checked. Be clear when you have only read a summary. When you find an error, share the passage and reference that support a correction, and do so courteously.",
          "انسب الأقوال إلى أصحابها، واذكر المصادر التي راجعتها. وإن اكتفيت بملخص فبيّن ذلك. وإذا وجدت خطأً، فاذكر العبارة ومرجعها بما يعين على تصحيحه، والتزم حسن الخطاب."
        ]
      },
      {
        "heading": [
          "Timbang jawabannya, bukan kefasihannya.",
          "Weigh the evidence behind the answer.",
          "زِن الجواب بدليله."
        ],
        "body": [
          "Jawaban yang lancar tetap perlu ditimbang dengan dalil dan konteks. Periksa alasan yang digunakan, kenali bagian yang belum jelas, dan simpan pertanyaan lanjutan. Sikap teliti membuat bantuan teknologi lebih bermanfaat bagi telaah Anda.",
          "A fluent answer still needs evidence and context. Examine its reasoning, identify what remains unclear, and keep follow-up questions. Careful judgement makes technology a more useful part of your study.",
          "يبقى الجواب الفصيح محتاجًا إلى الدليل والسياق. افحص وجه الاستدلال، وحدّد ما لم يتضح لك، ودوّن أسئلتك التالية. بهذه العناية تكون التقنية أعون لك على البحث."
        ]
      },
      {
        "heading": [
          "Sambungkan bacaan dengan tradisi ilmu.",
          "Connect reading with living scholarship.",
          "صِل القراءة بتقاليد العلم."
        ],
        "body": [
          "Jadikan kemudahan akses sebagai bekal menghadiri majelis, membaca kitab secara bertahap, dan mengenal para ulama beserta jalur keilmuannya. Sanad dan pendampingan guru membantu menempatkan pengetahuan dalam tradisi yang hidup.",
          "Let easier access support attending lessons, reading books progressively, and learning about scholars and their intellectual lineages. Sanad and a teacher’s guidance place knowledge within a living tradition.",
          "اجعل تيسير الوصول إلى المصادر زادًا لحضور المجالس والتدرّج في قراءة الكتب ومعرفة العلماء وطرق تلقيهم. فالسند وصحبة المعلم يصلان المعرفة بتقليد علمي حي."
        ]
      },
      {
        "heading": [
          "Arahkan ilmu untuk membawa manfaat.",
          "Let knowledge serve others.",
          "اجعل العلم سبيلًا إلى النفع."
        ],
        "body": [
          "Gunakan hasil telaah untuk menjernihkan persoalan, membantu sesama, dan menjaga kehormatan manusia. Hindari penyebaran tuduhan atau kutipan yang melepaskan ucapan dari konteksnya. Semangat manhaj salamah mengajak kita menempuh jalan ilmu dengan tenang, bertanggung jawab, dan membawa kedamaian.",
          "Use your study to clarify questions, help others, and preserve human dignity. Avoid spreading accusations or quotations stripped of context. The spirit of manhaj salamah calls for a calm, responsible pursuit of knowledge that contributes to peace.",
          "اجعل ثمرة البحث إيضاح المسائل ونفع الناس وصون كرامتهم. واجتنب نشر الاتهامات أو اقتطاع الأقوال من سياقها. وتدعونا روح منهج السلامة إلى طلب العلم بسكينة ومسؤولية وإصلاح."
        ]
      },
      {
        "heading": [
          "Tentang panduan ini",
          "About this guide",
          "عن هذا الدليل"
        ],
        "body": [
          "Panduan ini merupakan rumusan editorial OpenTurath dari bahan adab yang disampaikan kepada tim, terinspirasi oleh gagasan Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur tentang pembaruan sarana dengan menjaga landasan keilmuan. Rumusan tentang AI di halaman ini adalah penerapan prinsip tersebut oleh OpenTurath; bukan kutipan langsung atau fatwa beliau mengenai AI.",
          "This OpenTurath editorial guide draws on the adab material supplied to the team, inspired by Al-Habib Abu Bakr Al-Adni bin Ali Al-Mashhur’s approach to renewing tools while preserving scholarly foundations. Its application to AI is OpenTurath’s synthesis, rather than a direct quotation or an AI ruling attributed to him.",
          "هذا الدليل صياغة تحريرية من OpenTurath للمادة المقدّمة إلى الفريق، مستلهمة من منهج الحبيب أبي بكر العدني بن علي المشهور في تحديث الوسائل مع حفظ أصول العلم. وتطبيق هذه المبادئ على الذكاء الاصطناعي اجتهاد تحريري من OpenTurath، وليس نقلًا مباشرًا عنه أو فتوى منسوبة إليه في شأنه."
        ]
      }
    ],
    "policy": true
  },
  "tahawwulat": {
    "key": "tahawwulat",
    "intro": [
      "AI Fikih Tahawwulat",
      "Fiqh Tahawwulat AI",
      "الذكاء الاصطناعي لفقه التحولات"
    ],
    "blocks": [
      {
        "heading": [
          "Ruang kajian khusus",
          "A dedicated study space",
          "مساحة متخصصة للمطالعة"
        ],
        "body": [
          "Lima pilihan asisten dan susunan kitab mengikuti pengantar dalam aplikasi OpenTurath.",
          "Five assistant choices and the book sequence follow the OpenTurath app introduction.",
          "يتبع اختيار المساعدين الخمسة وتسلسل الكتب المدخل في تطبيق OpenTurath."
        ]
      }
    ]
  },
  "research/methodology": {
    "key": "methods",
    "intro": [
      "Metode pemeriksaan dan batas arsip.",
      "Review method and archive boundaries.",
      "منهج المراجعة وحدود الأرشيف."
    ],
    "blocks": [
      {
        "heading": [
          "Tujuh dimensi pemeriksaan",
          "Seven review dimensions",
          "سبعة جوانب للمراجعة"
        ],
        "body": [
          "Pemeriksaan membedakan: kecocokan kutipan, ketepatan bibliografi, dukungan terhadap klaim, ketepatan pemahaman, kelengkapan, kesesuaian cakupan, dan ketahanan. Nilai tiap dimensi belum tersedia untuk enam jawaban Q001. Kecocokan teks tidak otomatis membuktikan ketepatan pemahaman atau hukum.",
          "Review distinguishes quotation match, bibliographic accuracy, support for claims, interpretive accuracy, completeness, scope alignment, and robustness. Assessments are not yet available for the six Q001 answers. A textual match does not by itself establish interpretive or legal accuracy.",
          "تُميّز المراجعة بين مطابقة النص ودقة الإحالة وإسناد الادعاء ودقة الفهم والاكتمال وموافقة النطاق والمتانة. لم تتوفر تقييمات إجابات Q001 الست؛ ولا تثبت مطابقة النص وحدها صحة الفهم أو الحكم."
        ]
      },
      {
        "heading": [
          "Integritas arsip dan verifikasi sumber",
          "Archive integrity and source verification",
          "سلامة الأرشيف والتحقّق من المصدر"
        ],
        "body": [
          "Hash SHA-256 menjaga agar teks jawaban yang diarsipkan tidak berubah. Hash tidak membuktikan bahwa kutipan cocok dengan kitab. Semua sepuluh kutipan Q001 masih menunggu identitas edisi, teks pembanding, penelaah, serta tanggal pemeriksaan. Model, tanggal uji, paket, dan kondisi pengujian belum tercatat lengkap; arsip ini bukan benchmark terkontrol.",
          "SHA-256 hashes protect archived answer text from change. A hash does not prove a quotation matches a book. All ten Q001 quotations await edition identity, comparison text, reviewer, and review date. Model, test date, plan, and conditions are not fully recorded; this archive is not a controlled benchmark.",
          "تحمي بصمات SHA-256 نصوص الإجابات من التغيير، ولا تثبت مطابقة النص للكتاب. تنتظر النصوص العشرة الطبعة والنص المقابل والمراجع والتاريخ. لم تُسجّل ظروف الاختبار كاملة؛ فليس الأرشيف اختبار أداء مضبوطًا."
        ]
      },
      {
        "heading": [
          "Mengirim koreksi",
          "Sending corrections",
          "إرسال التصحيحات"
        ],
        "body": [
          "Kirim koreksi ke openturath@gmail.com dengan kitab, penerbit, edisi, jilid, halaman, dan catatan pembanding. Formulir website hanya membantu membuat salinan laporan; unduhan file tidak mengirim laporan. Teks jawaban asli dipertahankan terpisah dari catatan penelaah.",
          "Email corrections to openturath@gmail.com with the book, publisher, edition, volume, page, and comparison notes. The website form prepares a report copy; downloading that file does not submit it. Original answers remain separate from reviewer notes.",
          "أرسل التصحيح إلى openturath@gmail.com مع الكتاب والناشر والطبعة والجزء والصفحة والملاحظات. يُعدّ نموذج الموقع نسخة للبلاغ؛ وتنزيلها لا يرسله. تبقى الإجابة الأصلية منفصلة عن ملاحظات المراجع."
        ]
      }
    ]
  },
  "help/install": {
    "key": "help",
    "intro": [
      "Memasang aplikasi.",
      "Install the app.",
      "تثبيت التطبيق."
    ],
    "blocks": [
      {
        "heading": [
          "Saluran resmi",
          "Official channels",
          "القنوات الرسمية"
        ],
        "body": [
          "Buka halaman Unduh aplikasi dan pilih platform yang tersedia. Platform dalam persiapan belum memiliki tombol unduh aktif. Persyaratan versi tercantum pada tiap kartu.",
          "Open Downloads and choose an available platform. Platforms in preparation have no active download button. Version requirements are listed on each card.",
          "افتح صفحة التنزيل واختر منصة متاحة. لا يوجد زر تنزيل نشط للمنصات قيد الإعداد. تُعرض متطلبات الإصدار في كل بطاقة."
        ]
      },
      {
        "heading": [
          "Integritas berkas",
          "File integrity",
          "سلامة الملف"
        ],
        "body": [
          "Cocokkan SHA-256 berkas Android dengan nilai pada halaman unduhan. Jangan menonaktifkan perlindungan perangkat secara menyeluruh. Hubungi bantuan jika berkas tidak tersedia atau tanda tangan pemasangan berbeda.",
          "Compare the Android file’s SHA-256 with the download page. Do not disable device protection globally. Contact support if the file is unavailable or its installation signature differs.",
          "قارن SHA-256 لملف Android بالقيمة المنشورة. لا تعطّل حماية الجهاز بصورة شاملة. تواصل مع الدعم إذا تعذر الملف أو اختلف توقيع التثبيت."
        ]
      }
    ]
  },
  "help/references": {
    "key": "help",
    "intro": [
      "Memeriksa rujukan.",
      "Check a reference.",
      "فحص الإحالة."
    ],
    "blocks": [
      {
        "heading": [
          "02 · Teks primer",
          "02 · Primary text",
          "٠٢ · النص الأصلي"
        ],
        "body": [
          "Telusuri ibarah dalam korpus rujukan. Bedakan kutipan asli, terjemahan, dan penjelasan AI. Tidak ditemukannya teks bukan bukti bahwa pembahasannya tidak ada.",
          "Find passages in the reference corpus. Distinguish original quotations, translations, and AI explanations. A missing search result does not prove that a discussion does not exist.",
          "تتبّع العبارة في المصادر. ميّز النص الأصلي والترجمة وشرح الذكاء الاصطناعي. عدم العثور على نص لا يثبت عدم وجود المسألة."
        ]
      },
      {
        "heading": [
          "03 · Koordinat edisi",
          "03 · Edition coordinates",
          "٠٣ · بيانات الطبعة"
        ],
        "body": [
          "Cocokkan judul, pengarang, penerbit, edisi, jilid, dan halaman cetak. Nomor halaman PDF dapat berbeda. Jangan menganggap koordinat yang disebut AI telah dicocokkan dengan naskah fisik.",
          "Match title, author, publisher, edition, volume, and printed page. PDF pagination may differ. Coordinates supplied by AI do not by themselves prove a match to a physical edition.",
          "قابل العنوان والمؤلف والناشر والطبعة والجزء والصفحة المطبوعة. قد يختلف ترقيم PDF. ذكر الإحداثيات لا يثبت مقابلتها بالنسخة المادية."
        ]
      },
      {
        "heading": [
          "04 · Pemeriksaan sebelum kesimpulan",
          "04 · Review before concluding",
          "٠٤ · المراجعة قبل الاستنتاج"
        ],
        "body": [
          "Baca konteks dan minta bimbingan guru. Tandai rujukan sebagai telah dicocokkan hanya setelah teks sumber, edisi, penelaah, dan tanggal pemeriksaan tercatat. Sistem ini tidak menjanjikan nol halusinasi.",
          "Read the context and seek a teacher’s guidance. Mark a reference as matched only after recording the source text, edition, reviewer, and review date. This system does not promise zero hallucinations.",
          "اقرأ السياق واستعن بأهل العلم. لا تُثبت المقابلة إلا بعد توثيق النص والطبعة والمراجع وتاريخ المراجعة. لا يضمن النظام انعدام الأخطاء."
        ]
      }
    ]
  },
  "help/account": {
    "key": "help",
    "intro": [
      "Akun dan Catatan.",
      "Accounts and Notes.",
      "الحسابات والملاحظات."
    ],
    "blocks": [
      {
        "heading": [
          "Akses akun",
          "Account access",
          "الوصول إلى الحساب"
        ],
        "body": [
          "Gunakan akun Google yang sama dengan akun pembelian. Jangan membagikan kode masuk. Jika akses tidak sesuai, sertakan nomor transaksi saat menghubungi bantuan.",
          "Use the same Google account used for purchase. Do not share sign-in codes. If access is incorrect, include your transaction number when contacting support.",
          "استخدم حساب Google نفسه المستخدم للشراء. لا تشارك رموز الدخول. إذا اختلف الوصول، أرفق رقم المعاملة عند التواصل مع الدعم."
        ]
      },
      {
        "heading": [
          "Cadangkan Catatan",
          "Back up Notes",
          "نسخ الملاحظات احتياطيًا"
        ],
        "body": [
          "Catatan disimpan lokal, bukan sinkronisasi cloud lintas perangkat. Salin atau bagikan materi penting sebelum menghapus data atau mencopot aplikasi.",
          "Notes are stored locally, not synchronized through the cloud across devices. Copy or share important material before clearing data or uninstalling.",
          "تُحفظ الملاحظات محليًا ولا تتزامن سحابيًا بين الأجهزة. انسخ المواد المهمة أو شاركها قبل حذف البيانات أو إزالة التطبيق."
        ]
      }
    ]
  },
  "help/access": {
    "key": "help",
    "intro": [
      "Mengelola keanggotaan.",
      "Manage membership.",
      "إدارة العضوية."
    ],
    "blocks": [
      {
        "heading": [
          "Penawaran dan durasi",
          "Offers and duration",
          "العروض والمدة"
        ],
        "body": [
          "Penawaran resmi adalah Paket Tholib Rp 50.000 untuk 1 bulan, Paket Tholib Rp 299.000 untuk 6 bulan, dan Paket Bahits Rp 499.000 untuk 1 tahun. Khusus rumpun Fikih Tahawwulat Sovereign tersedia paket 1 bulan Rp 300.000, 6 bulan Rp 1.499.000, dan 1 tahun Rp 1.999.000. Pastikan cakupan, durasi kalender, jumlah akhir, dan tanggal berakhir yang sama ditampilkan pada aplikasi sebelum membayar. Jangan melanjutkan jika penawarannya berbeda.",
          "Official offers are Tholib Plan at IDR 50,000 for 1 month, Tholib Plan at IDR 299,000 for 6 months, and Bahits Plan at IDR 499,000 for 1 year. The dedicated Fiqh Tahawwulat Sovereign tier offers 1 month at IDR 300,000, 6 months at IDR 1,499,000, and 1 year at IDR 1,999,000. Confirm the same scope, calendar duration, final total, and expiry in the app before paying. Do not proceed if the offer differs.",
          "العروض الرسمية: باقة الطالب بسعر ٥٠٬٠٠٠ روبية لشهر، وباقة الطالب بسعر ٢٩٩٬٠٠٠ لستة أشهر، وباقة الباحث بسعر ٤٩٩٬٠٠٠ لسنة كاملة. ولباقة فقه التحولات السيادية الخاصة: شهر بسعر ٣٠٠٬٠٠٠، و٦ أشهر بسعر ١٬٤٩٩٬٠٠٠، وسنة بسعر ١٬٩٩٩٬٠٠٠. تأكّد من مطابقة النطاق والمدة التقويمية والمبلغ النهائي في التطبيق قبل الدفع."
        ]
      },
      {
        "heading": [
          "Midtrans dan aktivasi",
          "Midtrans and activation",
          "Midtrans والتفعيل"
        ],
        "body": [
          "Pembayaran memakai Midtrans melalui QRIS, Virtual Account, atau E-Wallet yang tersedia pada checkout. Status dibayar dan status akses aktif perlu dikonfirmasi terpisah. Jika dana terpotong tetapi akses belum aktif, hubungi bantuan dengan nomor transaksi sebelum membayar ulang.",
          "Payments use available Midtrans methods such as QRIS, Virtual Account, or E-Wallet. Payment status and active access must be confirmed separately. If funds are deducted but access is inactive, contact support with the transaction number before paying again.",
          "تتم المدفوعات عبر وسائل Midtrans المتاحة مثل QRIS والحساب الافتراضي والمحفظة الإلكترونية. تُراجع حالة الدفع وتفعيل الوصول كلٌّ على حدة. إذا خُصم المبلغ دون تفعيل، تواصل مع الدعم برقم المعاملة قبل إعادة الدفع."
        ]
      },
      {
        "heading": [
          "Perpanjangan dan voucher",
          "Renewal and vouchers",
          "التجديد والقسائم"
        ],
        "body": [
          "Semua perpanjangan dilakukan manual tanpa auto-debit. Akses berakhir sesuai tanggal pada akun. Voucher mengikuti cakupan, masa berlaku, dan batas penukaran yang diterbitkan. Voucher tidak dapat diuangkan.",
          "All renewals are manual with no automatic debit. Access expires on the date shown in your account. Vouchers follow their published scope, validity, and redemption limits. Vouchers cannot be exchanged for cash.",
          "كل تجديد يدوي دون خصم تلقائي. ينتهي الوصول في التاريخ المبيّن في الحساب. تتبع القسائم نطاقها وصلاحيتها وحدود استخدامها المنشورة، ولا تُستبدل نقدًا."
        ]
      }
    ]
  },
  "sources-and-rights": {
    "key": "rights",
    "intro": [
      "Sumber dan hak penggunaan.",
      "Sources and usage rights.",
      "المصادر وحقوق الاستخدام."
    ],
    "blocks": [
      {
        "heading": [
          "Hak setiap edisi",
          "Rights in each edition",
          "حقوق كل طبعة"
        ],
        "body": [
          "Karya klasik tidak otomatis membuat semua tahkik, terjemahan, atau reproduksi modern bebas hak cipta. Akses aplikasi tidak memberikan izin umum untuk menyalin atau menjual isi kitab.",
          "A classical work does not automatically place modern editions, translations, or reproductions in the public domain. App access does not grant blanket permission to copy or sell book contents.",
          "لا يجعل قِدم المؤلف كل تحقيق أو ترجمة أو تصوير حديث مباح الحقوق. ولا يمنح الوصول إلى التطبيق إذنًا عامًا بنسخ الكتب أو بيعها."
        ]
      },
      {
        "heading": [
          "Atribusi dan permohonan koreksi",
          "Attribution and correction requests",
          "النسبة وطلبات التصحيح"
        ],
        "body": [
          "Cantumkan karya, pengarang, dan edisi yang digunakan. Pemegang hak dapat menghubungi openturath@gmail.com dengan identitas karya, lokasi materi, bukti hak, dan permintaan yang jelas.",
          "Credit the work, author, and edition used. Rights holders can contact openturath@gmail.com with the work’s identity, material location, rights evidence, and a clear request.",
          "اذكر العمل والمؤلف والطبعة المستخدمة. يمكن لأصحاب الحقوق التواصل عبر openturath@gmail.com مع هوية العمل وموقع المادة وإثبات الحق وطلب واضح."
        ]
      }
    ]
  },
  "accessibility": {
    "key": "accessibility",
    "intro": [
      "Dapat dibaca, dapat digunakan.",
      "Readable and usable.",
      "قابل للقراءة والاستخدام."
    ],
    "blocks": [
      {
        "heading": [
          "Navigasi dan preferensi",
          "Navigation and preferences",
          "التنقل والتفضيلات"
        ],
        "body": [
          "Gunakan tautan lewati ke isi, navigasi papan ketik, dan kontrol ukuran teks pada arsip telaah. Dialog dapat ditutup dengan Escape. Tema dan bahasa disimpan pada perangkat jika penyimpanan diizinkan.",
          "Use the skip link, keyboard navigation, and reading-size controls in the study archive. Close dialogs with Escape. Theme and language preferences are stored on your device when storage is allowed.",
          "استخدم رابط تجاوز التنقل ولوحة المفاتيح وضوابط حجم النص في الأرشيف. أغلق الحوارات بزر Escape. تُحفظ تفضيلات المظهر واللغة على الجهاز عند السماح بالتخزين."
        ]
      },
      {
        "heading": [
          "Arab dan pengurangan gerak",
          "Arabic and reduced motion",
          "العربية وتقليل الحركة"
        ],
        "body": [
          "Halaman Arab menggunakan RTL dan font Arab lokal. Efek paralaks mengikuti preferensi pengurangan gerak. Konten utama tetap tersedia tanpa JavaScript. Laporkan hambatan akses melalui halaman kontak.",
          "Arabic pages use RTL and locally served Arabic fonts. Parallax respects reduced-motion preferences. Core content remains available without JavaScript. Report accessibility barriers through Contact.",
          "تستخدم الصفحات العربية اتجاه RTL وخطوطًا عربية محلية. تراعي الحركة تفضيل تقليلها. يبقى المحتوى الأساسي متاحًا دون JavaScript. أبلغ عن عوائق الاستخدام عبر التواصل."
        ]
      }
    ]
  },
  "account-deletion": {
    "key": "deletion",
    "intro": [
      "Penghapusan akun dan data.",
      "Delete your account and data.",
      "حذف الحساب والبيانات."
    ],
    "blocks": [
      {
        "heading": [
          "Mengajukan permohonan",
          "Make a request",
          "تقديم طلب"
        ],
        "body": [
          "Gunakan fitur penghapusan akun dalam aplikasi atau hubungi openturath@gmail.com dari email akun. Pengelola dapat meminta verifikasi kepemilikan yang proporsional. Jangan mengirim kata sandi atau OTP.",
          "Use account deletion in the app or contact openturath@gmail.com from your account email. The operator may request proportionate ownership verification. Never send a password or OTP.",
          "استخدم حذف الحساب داخل التطبيق أو راسل openturath@gmail.com من بريد الحساب. قد يُطلب تحقّق متناسب من الملكية. لا ترسل كلمة مرور أو رمز تحقّق."
        ]
      },
      {
        "heading": [
          "Data yang berbeda tempat penyimpanan",
          "Data stored in different places",
          "البيانات في مواضع مختلفة"
        ],
        "body": [
          "Cadangkan Catatan lokal sebelum menghapus data aplikasi. Penghapusan akun OpenTurath tidak otomatis menghapus data pada akun atau sesi pihak ketiga eksternal. Data transaksi yang wajib disimpan secara hukum dapat dikecualikan dari penghapusan langsung.",
          "Back up local Notes before deleting app data. Deleting OpenTurath does not automatically delete data in external third-party accounts or sessions. Transaction records legally required for retention may be exempt from immediate deletion.",
          "انسخ الملاحظات المحلية قبل حذف بيانات التطبيق. لا يحذف حذف حساب OpenTurath البيانات في الحسابات أو الجلسات الخارجية للأطراف الثالثة تلقائيًا. وقد تُستثنى سجلات المعاملات الواجب حفظها قانونًا من الحذف الفوري."
        ]
      }
    ],
    "policy": true
  },
  "security": {
    "key": "security",
    "intro": [
      "Keamanan dan pelaporan.",
      "Security and reporting.",
      "الأمن والإبلاغ."
    ],
    "blocks": [
      {
        "heading": [
          "Melindungi akses",
          "Protecting access",
          "حماية الوصول"
        ],
        "body": [
          "Jangan membagikan kata sandi, kode sekali pakai, atau tautan akun pribadi. Gunakan perangkat yang tepercaya dan periksa alamat resmi sebelum masuk atau membayar.",
          "Do not share passwords, one-time codes, or private account links. Use trusted devices and check official addresses before signing in or paying.",
          "لا تشارك كلمات المرور أو الرموز المؤقتة أو روابط الحساب الخاصة. استخدم أجهزة موثوقة وتحقّق من العنوان الرسمي قبل الدخول أو الدفع."
        ]
      },
      {
        "heading": [
          "Laporan kerentanan",
          "Vulnerability reports",
          "بلاغات الثغرات"
        ],
        "body": [
          "Kirim deskripsi kerentanan dan langkah reproduksi minimum ke openturath@gmail.com. Hindari mengambil data pengguna lain atau mengganggu layanan. Pengamanan operasional, cadangan, dan pemantauan tetap menjadi tanggung jawab pengelola deployment.",
          "Send a vulnerability description and minimal reproduction steps to openturath@gmail.com. Avoid accessing other users’ data or disrupting service. Operational security, backups, and monitoring remain the deployment operator’s responsibility.",
          "أرسل وصف الثغرة وخطوات إعادة إنتاج محدودة إلى openturath@gmail.com. تجنّب الوصول إلى بيانات الآخرين أو تعطيل الخدمة. تبقى الحماية التشغيلية والنسخ الاحتياطية والمراقبة مسؤولية مشغّل النشر."
        ]
      }
    ]
  }
};
