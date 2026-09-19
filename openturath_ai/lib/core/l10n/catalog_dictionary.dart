// Domain labels translated at presentation time; source models and corpus text stay intact.
const catalogDictionary = <String, Map<String, String>>{
  "Matan · Syarah · Hasyiyah": {
    "id": "Matan · Syarah · Hasyiyah",
    "en": "Texts · Commentaries · Glosses",
    "ar": "متون · شروح · حواشٍ"
  },
  "Fiqh": {
    "id": "Fiqh",
    "en": "Jurisprudence",
    "ar": "الفقه"
  },
  "Fikih": {
    "id": "Fikih",
    "en": "Jurisprudence",
    "ar": "الفقه"
  },
  "Fikih Tahawwulat": {"id": "Fikih Tahawwulat", "en": "Fiqh of transformations", "ar": "فقه التحولات"},
  "Khazanah ilmu kenabian seputar tanda-tanda akhir zaman untuk memahami realitas dan menjaga diri dari fitnah.": {
    "id": "Khazanah ilmu kenabian seputar tanda-tanda akhir zaman untuk memahami realitas dan menjaga diri dari fitnah.",
    "en": "Prophetic teachings on the signs of the end times, understanding current realities and responding to tribulations.",
    "ar": "معارف نبوية في علامات آخر الزمان لفهم الواقع واتقاء الفتن."
  },
  "Manhaj Abu Bakr al-Masyhur": {
    "id": "Manhaj Abu Bakr al-Masyhur",
    "en": "The method of Abu Bakr al-Mashhur",
    "ar": "منهج أبي بكر المشهور"
  },
  "Bagaimana penjelasan al-ghutsā'iyyah dalam kitab?": {
    "id": "Bagaimana penjelasan al-ghutsā'iyyah dalam kitab?",
    "en": "How do the texts explain al-ghuthā’iyyah?",
    "ar": "كيف تشرح الكتب مفهوم الغثائية؟"
  },
  "Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?": {
    "id": "Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?",
    "en": "What does the Fourth Pillar mean in the fiqh of transformations?",
    "ar": "ما المقصود بالركن الرابع في فقه التحولات؟"
  },
  "Bagaimana para ulama menjelaskan sikap saat masa fitnah?": {
    "id": "Bagaimana para ulama menjelaskan sikap saat masa fitnah?",
    "en": "How do scholars describe the appropriate response to times of tribulation?",
    "ar": "كيف يبيّن العلماء الموقف في أزمنة الفتن؟"
  },
  "Teks Matan & Ibarah": {
    "id": "Teks Matan & Ibarah",
    "en": "Texts and passages",
    "ar": "المتون والعبارات"
  },
  "Matan & Ibarah": {
    "id": "Matan & Ibarah",
    "en": "Texts and passages",
    "ar": "المتون والعبارات"
  },
  "Penyederhanaan Konsep": {
    "id": "Penyederhanaan Konsep",
    "en": "Clarifying concepts",
    "ar": "توضيح المفاهيم"
  },
  "Konsep & Istilah": {
    "id": "Konsep & Istilah",
    "en": "Concepts and terminology",
    "ar": "المفاهيم والمصطلحات"
  },
  "Ujian Pemahaman Interaktif": {
    "id": "Ujian Pemahaman Interaktif",
    "en": "Interactive comprehension exercises",
    "ar": "تمارين تفاعلية لاختبار الفهم"
  },
  "Ujian Nalar": {
    "id": "Ujian Nalar",
    "en": "Reasoning exercises",
    "ar": "تمارين الاستدلال"
  },
  "Arsip Muhadharah Habib Abu Bakar": {
    "id": "Arsip Muhadharah Habib Abu Bakar",
    "en": "Habib Abu Bakr’s lecture archive",
    "ar": "أرشيف محاضرات الحبيب أبي بكر"
  },
  "Khazanah Lisan": {
    "id": "Khazanah Lisan",
    "en": "Oral sources",
    "ar": "المصادر الشفوية"
  },
  "Penyusun Materi Dakwah & Khutbah": {
    "id": "Penyusun Materi Dakwah & Khutbah",
    "en": "Preparing teaching and sermon material",
    "ar": "إعداد مواد الدعوة والخطب"
  },
  "Dakwah & Khutbah": {
    "id": "Dakwah & Khutbah",
    "en": "Teaching and sermons",
    "ar": "الدعوة والخطب"
  },
  "Kitab pengantar dasar metodologi Sunan Al-Khalaq, tanda akhir zaman, dan peta dakwah fikih tahawwulat.": {
    "id": "Kitab pengantar dasar metodologi Sunan Al-Khalaq, tanda akhir zaman, dan peta dakwah fikih tahawwulat.",
    "en": "An introduction to Sunan al-Khalaq, the signs of the end times and the teaching approach of the fiqh of transformations.",
    "ar": "مدخل إلى منهج سنن الخلق وعلامات آخر الزمان والمسار الدعوي لفقه التحولات."
  },
  "Panduan pengantar Fikih Tahawwulat untuk pelajar dan peneliti.": {
    "id": "Panduan pengantar Fikih Tahawwulat untuk pelajar dan peneliti.",
    "en": "An introduction to the fiqh of transformations for students and researchers.",
    "ar": "مدخل إلى فقه التحولات للطلاب والباحثين."
  },
  "Fikih Syafi'i": {"id": "Fikih Syafi'i", "en": "Shafi‘i jurisprudence", "ar": "الفقه الشافعي"},
  "Cari penjelasan dan rujukan dalam kitab-kitab mazhab Syafi'i.": {
    "id": "Cari penjelasan dan rujukan dalam kitab-kitab mazhab Syafi'i.",
    "en": "Find explanations and references in works of the Shafi‘i school.",
    "ar": "ابحث عن الشروح والمراجع في كتب المذهب الشافعي."
  },
  "Matan · Syarah · Hasyiyah Mu'tabarah": {
    "id": "Matan · Syarah · Hasyiyah Mu'tabarah",
    "en": "Texts · Commentaries · Authoritative glosses",
    "ar": "متون · شروح · حواشٍ معتمدة"
  },
  "Apa rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i?": {
    "id": "Apa rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i?",
    "en": "What are the integrals of ablution according to the relied-upon Shafi‘i position?",
    "ar": "ما أركان الوضوء على المعتمد في المذهب الشافعي؟"
  },
  "Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?": {
    "id": "Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?",
    "en": "What are the conditions for a valid congregational prayer in Minhāj al-Ṭālibīn?",
    "ar": "ما شروط صحة صلاة الجماعة في منهاج الطالبين؟"
  },
  "Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi?": {
    "id": "Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi?",
    "en": "How does Imam al-Nawawi explain zakat on trade goods?",
    "ar": "ما أحكام زكاة التجارة عند الإمام النووي؟"
  },
  "Membantu menemukan dalil, ibarah, dan rujukan dalam mazhab Syafi'i.": {
    "id": "Membantu menemukan dalil, ibarah, dan rujukan dalam mazhab Syafi'i.",
    "en": "Find evidence, passages and references in the Shafi‘i school.",
    "ar": "تتبّع الأدلة والعبارات والمراجع في المذهب الشافعي."
  },
  "Kitab induk Fikih Mazhab Syafi'i.": {
    "id": "Kitab induk Fikih Mazhab Syafi'i.",
    "en": "A foundational work of Shafi‘i jurisprudence.",
    "ar": "من أمهات كتب الفقه الشافعي."
  },
  "Rujukan fikih mazhab Syafi'i karya Imam An-Nawawi.": {
    "id": "Rujukan fikih mazhab Syafi'i karya Imam An-Nawawi.",
    "en": "A Shafi‘i legal reference by Imam al-Nawawi.",
    "ar": "مرجع في الفقه الشافعي للإمام النووي."
  },
  "Fikih Hanafi": {
    "id": "Fikih Hanafi",
    "en": "Hanafi jurisprudence",
    "ar": "الفقه الحنفي"
  },
  "Pelajari fikih mazhab Hanafi dengan rujukan Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani.": {
    "id": "Pelajari fikih mazhab Hanafi dengan rujukan Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani.",
    "en": "Study Hanafi jurisprudence through al-Mabsut, Radd al-Muhtar and al-Marghinani’s al-Hidayah.",
    "ar": "ادرس الفقه الحنفي من خلال المبسوط ورد المحتار والهداية للمرغيناني."
  },
  "Zhahir Ar-Riwayah · Syuruh & Fatawa": {
    "id": "Zhahir Ar-Riwayah · Syuruh & Fatawa",
    "en": "Zahir al-Riwayah · Commentaries and fatwas",
    "ar": "ظاهر الرواية · الشروح والفتاوى"
  },
  "Bagaimana kaidah istihsan dalam mazhab Hanafi?": {
    "id": "Bagaimana kaidah istihsan dalam mazhab Hanafi?",
    "en": "How is juristic preference applied in the Hanafi school?",
    "ar": "كيف يُعمل بالاستحسان في المذهب الحنفي؟"
  },
  "Apa pendapat mu'tamad mazhab Hanafi mengenai syarat shalat berjamaah?": {
    "id": "Apa pendapat mu'tamad mazhab Hanafi mengenai syarat shalat berjamaah?",
    "en": "What is the relied-upon Hanafi position on the conditions of congregational prayer?",
    "ar": "ما المعتمد في المذهب الحنفي في شروط صلاة الجماعة؟"
  },
  "Tunjukkan ibarah dalam Radd al-Muhtar tentang jual beli dan muamalah.": {
    "id": "Tunjukkan ibarah dalam Radd al-Muhtar tentang jual beli dan muamalah.",
    "en": "Find passages in Radd al-Muhtar on sales and transactions.",
    "ar": "اعرض عبارات من رد المحتار في البيوع والمعاملات."
  },
  "Riset Zhahir Ar-Riwayah dan fatwa mazhab Hanafi.": {
    "id": "Riset Zhahir Ar-Riwayah dan fatwa mazhab Hanafi.",
    "en": "Research Zahir al-Riwayah and Hanafi fatwas.",
    "ar": "دراسة ظاهر الرواية وفتاوى المذهب الحنفي."
  },
  "Kitab ensiklopedi induk fikih mazhab Hanafi.": {
    "id": "Kitab ensiklopedi induk fikih mazhab Hanafi.",
    "en": "A major encyclopaedic work of Hanafi jurisprudence.",
    "ar": "موسوعة من أمهات الفقه الحنفي."
  },
  "Rujukan fatwa mu'tamad muta'akhkhirin mazhab Hanafi.": {
    "id": "Rujukan fatwa mu'tamad muta'akhkhirin mazhab Hanafi.",
    "en": "A reference for the relied-upon fatwas of later Hanafi scholars.",
    "ar": "مرجع للفتوى المعتمدة عند متأخري الحنفية."
  },
  "Fikih Maliki": {
    "id": "Fikih Maliki",
    "en": "Maliki jurisprudence",
    "ar": "الفقه المالكي"
  },
  "Pelajari fikih mazhab Maliki dan 'Amal Ahlil Madinah dengan rujukan Al-Mudawwanah, Risalah Ibnu Abi Zaid, dan Mukhtashar Khalil.": {
    "id": "Pelajari fikih mazhab Maliki dan 'Amal Ahlil Madinah dengan rujukan Al-Mudawwanah, Risalah Ibnu Abi Zaid, dan Mukhtashar Khalil.",
    "en": "Study Maliki jurisprudence and Medinan practice through al-Mudawwanah, Ibn Abi Zayd’s Risalah and Mukhtasar Khalil.",
    "ar": "ادرس الفقه المالكي وعمل أهل المدينة من خلال المدونة ورسالة ابن أبي زيد ومختصر خليل."
  },
  "Al-Mudawwanah · Mukhtashar Khalil & Syarah": {
    "id": "Al-Mudawwanah · Mukhtashar Khalil & Syarah",
    "en": "Al-Mudawwanah · Mukhtasar Khalil and commentaries",
    "ar": "المدونة · مختصر خليل وشروحه"
  },
  "Bagaimana kedudukan 'Amal Ahlil Madinah dalam istinbath Maliki?": {
    "id": "Bagaimana kedudukan 'Amal Ahlil Madinah dalam istinbath Maliki?",
    "en": "What is the role of Medinan practice in Maliki legal reasoning?",
    "ar": "ما مكانة عمل أهل المدينة في الاستنباط المالكي؟"
  },
  "Apa saja syarat sah salat menurut Mukhtashar Khalil?": {
    "id": "Apa saja syarat sah salat menurut Mukhtashar Khalil?",
    "en": "What are the conditions for a valid prayer in Mukhtasar Khalil?",
    "ar": "ما شروط صحة الصلاة في مختصر خليل؟"
  },
  "Bagaimana Bidayatul Mujtahid menjelaskan perbedaan pendapat tentang thaharah?": {
    "id": "Bagaimana Bidayatul Mujtahid menjelaskan perbedaan pendapat tentang thaharah?",
    "en": "How does Bidayat al-Mujtahid explain disagreements on purification?",
    "ar": "كيف تشرح بداية المجتهد الخلاف في مسائل الطهارة؟"
  },
  "Riset Al-Mudawwanah dan Mukhtashar Khalil.": {
    "id": "Riset Al-Mudawwanah dan Mukhtashar Khalil.",
    "en": "Study al-Mudawwanah and Mukhtasar Khalil.",
    "ar": "دراسة المدونة ومختصر خليل."
  },
  "Fondasi riwayat fatwa dan hukum mazhab Maliki.": {
    "id": "Fondasi riwayat fatwa dan hukum mazhab Maliki.",
    "en": "A foundation for transmitted Maliki fatwas and rulings.",
    "ar": "أصل لروايات الفتاوى والأحكام في المذهب المالكي."
  },
  "Matan hukum paling padat dan mu'tamad di kalangan Malikiyyah.": {
    "id": "Matan hukum paling padat dan mu'tamad di kalangan Malikiyyah.",
    "en": "A concise, authoritative legal text in the Maliki school.",
    "ar": "متن فقهي موجز معتمد لدى المالكية."
  },
  "Fikih Hanbali": {
    "id": "Fikih Hanbali",
    "en": "Hanbali jurisprudence",
    "ar": "الفقه الحنبلي"
  },
  "Pelajari fikih mazhab Hanbali merujuk Al-Mughni Ibnu Qudamah, Kasysyaf Al-Qina', dan Zad Al-Mustaqni'.": {
    "id": "Pelajari fikih mazhab Hanbali merujuk Al-Mughni Ibnu Qudamah, Kasysyaf Al-Qina', dan Zad Al-Mustaqni'.",
    "en": "Study Hanbali jurisprudence through Ibn Qudamah’s al-Mughni, Kashshaf al-Qina‘ and Zad al-Mustaqni‘.",
    "ar": "ادرس الفقه الحنبلي من خلال المغني لابن قدامة وكشاف القناع وزاد المستقنع."
  },
  "Al-Mughni · Zad Al-Mustaqni' & Syuruh": {
    "id": "Al-Mughni · Zad Al-Mustaqni' & Syuruh",
    "en": "Al-Mughni · Zad al-Mustaqni‘ and commentaries",
    "ar": "المغني · زاد المستقنع وشروحه"
  },
  "Apa mu'tamad mazhab Hanbali mengenai pembatalan wudhu?": {
    "id": "Apa mu'tamad mazhab Hanbali mengenai pembatalan wudhu?",
    "en": "What is the relied-upon Hanbali position on what invalidates ablution?",
    "ar": "ما المعتمد في المذهب الحنبلي في نواقض الوضوء؟"
  },
  "Bagaimana penjelasan Al-Mughni tentang jual beli bersyarat?": {
    "id": "Bagaimana penjelasan Al-Mughni tentang jual beli bersyarat?",
    "en": "How does al-Mughni explain conditional sales?",
    "ar": "كيف يشرح المغني الشروط في البيع؟"
  },
  "Bagaimana perbedaan riwayat dari Imam Ahmad dalam masalah ibadah?": {
    "id": "Bagaimana perbedaan riwayat dari Imam Ahmad dalam masalah ibadah?",
    "en": "How do the reports from Imam Ahmad differ on worship?",
    "ar": "ما اختلاف الروايات عن الإمام أحمد في مسائل العبادات؟"
  },
  "Telaah Al-Mughni dan perbandingan riwayat Imam Ahmad.": {
    "id": "Telaah Al-Mughni dan perbandingan riwayat Imam Ahmad.",
    "en": "Study al-Mughni and compare reports from Imam Ahmad.",
    "ar": "دراسة المغني ومقارنة الروايات عن الإمام أحمد."
  },
  "Kitab fikih dalil mazhab Hanbali karya Ibnu Qudamah.": {
    "id": "Kitab fikih dalil mazhab Hanbali karya Ibnu Qudamah.",
    "en": "Ibn Qudamah’s work on Hanbali law and its evidence.",
    "ar": "كتاب ابن قدامة في الفقه الحنبلي وأدلته."
  },
  "Syarah mu'tamad pegangan fatwa ulama Hanbali.": {
    "id": "Syarah mu'tamad pegangan fatwa ulama Hanbali.",
    "en": "An authoritative commentary used in Hanbali fatwas.",
    "ar": "شرح معتمد في الفتوى عند الحنابلة."
  },
  "Perbandingan Mazhab": {
    "id": "Perbandingan Mazhab",
    "en": "Comparative jurisprudence",
    "ar": "الفقه المقارن"
  },
  "Bandingkan dalil dan pandangan mazhab Hanafi, Maliki, Syafi'i, dan Hanbali.": {
    "id": "Bandingkan dalil dan pandangan mazhab Hanafi, Maliki, Syafi'i, dan Hanbali.",
    "en": "Compare the evidence and positions of the Hanafi, Maliki, Shafi‘i and Hanbali schools.",
    "ar": "قارن أدلة وآراء المذاهب الحنفي والمالكي والشافعي والحنبلي."
  },
  "Perbandingan Mazhab Empat & Tarjih Dalil": {
    "id": "Perbandingan Mazhab Empat & Tarjih Dalil",
    "en": "The four schools and the evaluation of evidence",
    "ar": "مقارنة المذاهب الأربعة والترجيح بالأدلة"
  },
  "Bagaimana pandangan empat mazhab mengenai rukun nikah?": {
    "id": "Bagaimana pandangan empat mazhab mengenai rukun nikah?",
    "en": "How do the four schools define the integrals of marriage?",
    "ar": "ما آراء المذاهب الأربعة في أركان النكاح؟"
  },
  "Apa dalil perbedaan ulama tentang batas menyentuh bukan mahram?": {
    "id": "Apa dalil perbedaan ulama tentang batas menyentuh bukan mahram?",
    "en": "What evidence underlies scholarly disagreements on touching a non-mahram?",
    "ar": "ما أدلة اختلاف العلماء في أحكام لمس غير المحرم؟"
  },
  "Bagaimana perbandingan ulama mengenai zakat aset dan uang digital?": {
    "id": "Bagaimana perbandingan ulama mengenai zakat aset dan uang digital?",
    "en": "How do scholarly views compare on zakat for assets and digital money?",
    "ar": "ما أوجه اختلاف العلماء في زكاة الأصول والنقود الرقمية؟"
  },
  "Komparasi dalil mazhab Arba'ah dan tarjih.": {
    "id": "Komparasi dalil mazhab Arba'ah dan tarjih.",
    "en": "Compare the four schools’ evidence and methods of preference.",
    "ar": "مقارنة أدلة المذاهب الأربعة والترجيح."
  },
  "Fikih Muqaran": {
    "id": "Fikih Muqaran",
    "en": "Comparative jurisprudence",
    "ar": "الفقه المقارن"
  },
  "Kajian perbandingan mazhab empat beserta analisis dalil dan sebab perbedaan hukum.": {
    "id": "Kajian perbandingan mazhab empat beserta analisis dalil dan sebab perbedaan hukum.",
    "en": "A comparative study of the four schools, their evidence and the reasons for legal disagreement.",
    "ar": "دراسة مقارنة للمذاهب الأربعة وأدلتها وأسباب الخلاف الفقهي."
  },
  "Ensiklopedi perbandingan mazhab klasik & kontemporer.": {
    "id": "Ensiklopedi perbandingan mazhab klasik & kontemporer.",
    "en": "An encyclopaedia of classical and contemporary comparative jurisprudence.",
    "ar": "موسوعة في الفقه المقارن قديمًا وحديثًا."
  },
  "Hadis & Syarah": {
    "id": "Hadis & Syarah",
    "en": "Hadith and commentary",
    "ar": "الحديث وشروحه"
  },
  "Telusuri hadis, sanad, perawi, dan penjelasannya dalam kitab rujukan.": {
    "id": "Telusuri hadis, sanad, perawi, dan penjelasannya dalam kitab rujukan.",
    "en": "Explore hadith, transmission chains, narrators and commentaries in reference works.",
    "ar": "تتبّع الأحاديث والأسانيد والرواة والشروح في الكتب المرجعية."
  },
  "Hadis": {
    "id": "Hadis",
    "en": "Hadith",
    "ar": "الحديث"
  },
  "Kutubus Sittah · Takhrij & Rijal": {
    "id": "Kutubus Sittah · Takhrij & Rijal",
    "en": "The Six Books · Hadith sourcing and narrators",
    "ar": "الكتب الستة · التخريج والرجال"
  },
  "Bagaimana penjelasan hadis tentang niat dalam Fatḥ al-Bārī?": {
    "id": "Bagaimana penjelasan hadis tentang niat dalam Fatḥ al-Bārī?",
    "en": "How does Fath al-Bari explain the hadith on intentions?",
    "ar": "كيف يشرح فتح الباري حديث النيات؟"
  },
  "Bagaimana menilai sanad riwayat ini?": {
    "id": "Bagaimana menilai sanad riwayat ini?",
    "en": "How should this transmission chain be assessed?",
    "ar": "كيف يُقيّم إسناد هذه الرواية؟"
  },
  "Bagaimana status perawi hadis talqin dalam Kutubus Sittah?": {
    "id": "Bagaimana status perawi hadis talqin dalam Kutubus Sittah?",
    "en": "What is the standing of the narrators of the talqin hadith in the Six Books?",
    "ar": "ما حال رواة حديث التلقين في الكتب الستة؟"
  },
  "Membantu takhrij hadis, telaah rijalul hadis, dan derajat kesahihan sanad.": {
    "id": "Membantu takhrij hadis, telaah rijalul hadis, dan derajat kesahihan sanad.",
    "en": "Trace hadith sources, study narrators and assess transmission chains.",
    "ar": "تخريج الأحاديث ودراسة الرجال ودرجات صحة الأسانيد."
  },
  "Takhrij & Rijal": {
    "id": "Takhrij & Rijal",
    "en": "Hadith sourcing and narrators",
    "ar": "التخريج والرجال"
  },
  "Kitab hadis shahih rujukan induk umat Islam.": {
    "id": "Kitab hadis shahih rujukan induk umat Islam.",
    "en": "A principal reference collection of authentic hadith.",
    "ar": "مرجع أساسي في الحديث الصحيح."
  },
  "Kitab shahih kedua dengan sistematika sanad yang sangat rapi.": {
    "id": "Kitab shahih kedua dengan sistematika sanad yang sangat rapi.",
    "en": "The second Sahih collection, with carefully arranged transmission chains.",
    "ar": "ثاني الصحيحين، مع ترتيب دقيق للأسانيد."
  },
  "Tafsir Al-Qur'an": {
    "id": "Tafsir Al-Qur'an",
    "en": "Qur’anic exegesis",
    "ar": "تفسير القرآن"
  },
  "Telusuri makna ayat, sebab turunnya, hubungan antarayat, dan penjelasan para mufasir.": {
    "id": "Telusuri makna ayat, sebab turunnya, hubungan antarayat, dan penjelasan para mufasir.",
    "en": "Explore verse meanings, occasions of revelation, connections between verses and exegetical discussions.",
    "ar": "تتبّع معاني الآيات وأسباب النزول والمناسبات وأقوال المفسرين."
  },
  "Tafsir": {
    "id": "Tafsir",
    "en": "Exegesis",
    "ar": "التفسير"
  },
  "Tafsir Thabari, Ibnu Katsir & Qurtubi": {
    "id": "Tafsir Thabari, Ibnu Katsir & Qurtubi",
    "en": "Al-Tabari, Ibn Kathir and al-Qurtubi",
    "ar": "تفاسير الطبري وابن كثير والقرطبي"
  },
  "Apa asbabun nuzul surah Al-Baqarah ayat 183?": {
    "id": "Apa asbabun nuzul surah Al-Baqarah ayat 183?",
    "en": "What is the occasion of revelation of Qur’an 2:183?",
    "ar": "ما سبب نزول الآية ١٨٣ من سورة البقرة؟"
  },
  "Bagaimana tafsir ayat Muhkamat dan Mutasyabihat menurut Al-Qurtubi?": {
    "id": "Bagaimana tafsir ayat Muhkamat dan Mutasyabihat menurut Al-Qurtubi?",
    "en": "How does al-Qurtubi interpret the verses on the clear and ambiguous passages?",
    "ar": "كيف يفسر القرطبي آيات المحكم والمتشابه؟"
  },
  "Bagaimana para mufasir menjelaskan makna \"Ihdinas shiratal mustaqim\"?": {
    "id": "Bagaimana para mufasir menjelaskan makna \"Ihdinas shiratal mustaqim\"?",
    "en": "How do exegetes explain “Guide us to the straight path”?",
    "ar": "كيف يشرح المفسرون معنى «اهدنا الصراط المستقيم»؟"
  },
  "Kompilasi penafsiran mufassirin salaf dan asbabun nuzul.": {
    "id": "Kompilasi penafsiran mufassirin salaf dan asbabun nuzul.",
    "en": "A collection of early exegetical interpretations and occasions of revelation.",
    "ar": "جمع أقوال مفسري السلف وأسباب النزول."
  },
  "Riset Tafsir": {
    "id": "Riset Tafsir",
    "en": "Exegetical research",
    "ar": "البحث في التفسير"
  },
  "Rujukan tafsir bil-ma'tsur dengan penekanan pada riwayat shahih dan asbabun nuzul.": {
    "id": "Rujukan tafsir bil-ma'tsur dengan penekanan pada riwayat shahih dan asbabun nuzul.",
    "en": "A reference in transmitted exegesis, emphasizing sound reports and occasions of revelation.",
    "ar": "مرجع في التفسير بالمأثور يعتني بصحيح الروايات وأسباب النزول."
  },
  "Tafsir dengan fokus pada hukum-hukum fikih dalam Al-Qur'an.": {
    "id": "Tafsir dengan fokus pada hukum-hukum fikih dalam Al-Qur'an.",
    "en": "An exegesis focused on the legal rulings of the Qur’an.",
    "ar": "تفسير يركّز على الأحكام الفقهية في القرآن."
  },
  "Usul Fikih": {
    "id": "Usul Fikih",
    "en": "Principles of jurisprudence",
    "ar": "أصول الفقه"
  },
  "Pelajari kaidah penggalian hukum, dalil, dan maqashid syariah melalui kitab usul fikih.": {
    "id": "Pelajari kaidah penggalian hukum, dalil, dan maqashid syariah melalui kitab usul fikih.",
    "en": "Study legal reasoning, evidence and the objectives of Islamic law through works of legal theory.",
    "ar": "ادرس قواعد الاستنباط والأدلة ومقاصد الشريعة في كتب أصول الفقه."
  },
  "Kaidah Istinbath & Maqashid Syariah": {
    "id": "Kaidah Istinbath & Maqashid Syariah",
    "en": "Legal reasoning and the objectives of Islamic law",
    "ar": "قواعد الاستنباط ومقاصد الشريعة"
  },
  "Apa perbedaan Mafhum Mukhalafah dan Mafhum Muwafaqah?": {
    "id": "Apa perbedaan Mafhum Mukhalafah dan Mafhum Muwafaqah?",
    "en": "What is the difference between contrary and congruent implication?",
    "ar": "ما الفرق بين مفهوم المخالفة ومفهوم الموافقة؟"
  },
  "Bagaimana kaidah \"Al-Amru ba'dan-nahyi yufidul ibahah\"?": {
    "id": "Bagaimana kaidah \"Al-Amru ba'dan-nahyi yufidul ibahah\"?",
    "en": "How is the principle “a command after prohibition indicates permissibility” understood?",
    "ar": "كيف تُفهم قاعدة «الأمر بعد النهي يفيد الإباحة»؟"
  },
  "Bagaimana Al-Waraqat menjelaskan pembagian hukum taklifi?": {
    "id": "Bagaimana Al-Waraqat menjelaskan pembagian hukum taklifi?",
    "en": "How does al-Waraqat classify prescriptive rulings?",
    "ar": "كيف تشرح الورقات أقسام الحكم التكليفي؟"
  },
  "Membantu penelusuran kaidah usuliyyah dan metode istinbath dalil.": {
    "id": "Membantu penelusuran kaidah usuliyyah dan metode istinbath dalil.",
    "en": "Explore legal principles and methods of reasoning from evidence.",
    "ar": "تتبّع القواعد الأصولية وطرائق الاستنباط من الأدلة."
  },
  "Kaidah Usul": {
    "id": "Kaidah Usul",
    "en": "Legal principles",
    "ar": "القواعد الأصولية"
  },
  "Matan pondasi metodologi ushul fikih paling tersohor.": {
    "id": "Matan pondasi metodologi ushul fikih paling tersohor.",
    "en": "A widely studied introductory text on legal theory.",
    "ar": "متن مشهور في مبادئ أصول الفقه."
  },
  "Karya induk ushul fikih lintas mazhab karya Tajuddin As-Subki.": {
    "id": "Karya induk ushul fikih lintas mazhab karya Tajuddin As-Subki.",
    "en": "Taj al-Din al-Subki’s major work on legal theory across schools.",
    "ar": "من أمهات أصول الفقه المقارن لتاج الدين السبكي."
  },
  "Bahasa Arab": {
    "id": "Bahasa Arab",
    "en": "Arabic language",
    "ar": "اللغة العربية"
  },
  "Pelajari nahwu, sharaf, balaghah, dan makna kosakata dalam kamus Arab klasik.": {
    "id": "Pelajari nahwu, sharaf, balaghah, dan makna kosakata dalam kamus Arab klasik.",
    "en": "Study syntax, morphology, rhetoric and vocabulary through classical Arabic dictionaries.",
    "ar": "ادرس النحو والصرف والبلاغة ومعاني المفردات في المعاجم العربية القديمة."
  },
  "Alfiyah Ibnu Malik & Lisanul Arab": {
    "id": "Alfiyah Ibnu Malik & Lisanul Arab",
    "en": "Ibn Malik’s Alfiyyah and Lisan al-‘Arab",
    "ar": "ألفية ابن مالك ولسان العرب"
  },
  "Apa perbedaan faedah wazan Fa'ala dan Af'ala dalam ilmu sharaf?": {
    "id": "Apa perbedaan faedah wazan Fa'ala dan Af'ala dalam ilmu sharaf?",
    "en": "How do the meanings of the fa‘ala and af‘ala patterns differ in Arabic morphology?",
    "ar": "ما الفرق بين دلالتي وزني فَعَلَ وأَفْعَلَ في علم الصرف؟"
  },
  "Bagaimana kaidah Munada dalam bait Alfiyah Ibnu Malik?": {
    "id": "Bagaimana kaidah Munada dalam bait Alfiyah Ibnu Malik?",
    "en": "How do the verses of Ibn Malik’s Alfiyyah explain the vocative?",
    "ar": "كيف تبيّن أبيات ألفية ابن مالك أحكام المنادى؟"
  },
  "I'rab kata dan analisis sintaksis sesuai kaidah Alfiyah Ibnu Malik.": {
    "id": "I'rab kata dan analisis sintaksis sesuai kaidah Alfiyah Ibnu Malik.",
    "en": "Word parsing and syntactic analysis using Ibn Malik’s Alfiyyah.",
    "ar": "إعراب الكلمات والتحليل النحوي وفق قواعد ألفية ابن مالك."
  },
  "I'rab & nahwu": {
    "id": "I'rab & nahwu",
    "en": "Parsing and syntax",
    "ar": "الإعراب والنحو"
  },
  "Perubahan wazan, derivasi kata, dan morfologi bahasa Arab.": {
    "id": "Perubahan wazan, derivasi kata, dan morfologi bahasa Arab.",
    "en": "Word patterns, derivation and Arabic morphology.",
    "ar": "الأوزان والاشتقاق والصرف العربي."
  },
  "Tashrif & sharaf": {
    "id": "Tashrif & sharaf",
    "en": "Inflection and morphology",
    "ar": "التصريف والصرف"
  },
  "Nadhom tata bahasa Arab 1.000 bait karya Imam Ibnu Malik.": {
    "id": "Nadhom tata bahasa Arab 1.000 bait karya Imam Ibnu Malik.",
    "en": "Ibn Malik’s thousand-verse poem on Arabic grammar.",
    "ar": "منظومة ابن مالك في النحو في ألف بيت."
  },
  "Kitab penjelasan paling populer untuk bait-bait Alfiyah Ibnu Malik.": {
    "id": "Kitab penjelasan paling populer untuk bait-bait Alfiyah Ibnu Malik.",
    "en": "A widely studied commentary on Ibn Malik’s Alfiyyah.",
    "ar": "شرح متداول لأبيات ألفية ابن مالك."
  },
  "Akidah": {
    "id": "Akidah",
    "en": "Creed",
    "ar": "العقيدة"
  },
  "Pembahasan ushuluddin, tauhid sifat dua puluh, dan manhaj Ahlussunnah wal Jama'ah.": {
    "id": "Pembahasan ushuluddin, tauhid sifat dua puluh, dan manhaj Ahlussunnah wal Jama'ah.",
    "en": "Study theology, the twenty divine attributes and the Sunni tradition.",
    "ar": "دراسة أصول الدين والصفات العشرين ومنهج أهل السنة والجماعة."
  },
  "Asy'ariyyah · Maturidiyyah · Dalil Aqli": {
    "id": "Asy'ariyyah · Maturidiyyah · Dalil Aqli",
    "en": "Ash‘ari · Maturidi · Rational evidence",
    "ar": "الأشعرية · الماتريدية · الدليل العقلي"
  },
  "Jelaskan pembagian sifat Wajib, Mustahil, dan Jaiz bagi Allah!": {
    "id": "Jelaskan pembagian sifat Wajib, Mustahil, dan Jaiz bagi Allah!",
    "en": "Explain the necessary, impossible and possible attributes in theology.",
    "ar": "اشرح أقسام الواجب والمستحيل والجائز في حق الله."
  },
  "Bagaimana dalil aqli tentang keesaan Allah menurut Al-Sanusiyyah?": {
    "id": "Bagaimana dalil aqli tentang keesaan Allah menurut Al-Sanusiyyah?",
    "en": "What rational evidence for divine unity is presented in al-Sanusiyyah?",
    "ar": "ما الدليل العقلي على وحدانية الله في السنوسية؟"
  },
  "Apa perbedaan pemikiran Asy'ariyyah dan Mu'tazilah tentang kalamullah?": {
    "id": "Apa perbedaan pemikiran Asy'ariyyah dan Mu'tazilah tentang kalamullah?",
    "en": "How do Ash‘ari and Mu‘tazili views differ on divine speech?",
    "ar": "ما الفرق بين الأشاعرة والمعتزلة في مسألة كلام الله؟"
  },
  "Sejarah & Sirah": {
    "id": "Sejarah & Sirah",
    "en": "History and prophetic biography",
    "ar": "التاريخ والسيرة"
  },
  "Telusuri perjalanan hidup Nabi, Khulafaur Rasyidin, dan biografi ulama salaf.": {
    "id": "Telusuri perjalanan hidup Nabi, Khulafaur Rasyidin, dan biografi ulama salaf.",
    "en": "Explore the Prophet’s life, the Rightly Guided Caliphs and biographies of early scholars.",
    "ar": "تتبّع سيرة النبي والخلفاء الراشدين وتراجم علماء السلف."
  },
  "Sirah Ibnu Hisyam & Tarikh Thabari": {
    "id": "Sirah Ibnu Hisyam & Tarikh Thabari",
    "en": "Ibn Hisham’s Sirah and al-Tabari’s History",
    "ar": "سيرة ابن هشام وتاريخ الطبري"
  },
  "Bagaimana kronologi Perang Badar menurut Sirah Ibnu Hisyam?": {
    "id": "Bagaimana kronologi Perang Badar menurut Sirah Ibnu Hisyam?",
    "en": "What is the chronology of Badr in Ibn Hisham’s Sirah?",
    "ar": "ما تسلسل أحداث غزوة بدر في سيرة ابن هشام؟"
  },
  "Bagaimana riwayat musyawarah Tsaqifah Bani Sa'idah?": {
    "id": "Bagaimana riwayat musyawarah Tsaqifah Bani Sa'idah?",
    "en": "What reports describe the consultation at Saqifah Bani Sa‘idah?",
    "ar": "ما الروايات الواردة في مشاورات سقيفة بني ساعدة؟"
  },
  "Bagaimana biografi dan thabaqat Imam An-Nawawi?": {
    "id": "Bagaimana biografi dan thabaqat Imam An-Nawawi?",
    "en": "What do biographical works report about Imam al-Nawawi?",
    "ar": "ما ترجمة الإمام النووي في كتب الطبقات؟"
  },
  "Telusuri fatwa, khutbah, tulisan, dan nasihat dakwah Habib Umar bin Hafizh.": {
    "id": "Telusuri fatwa, khutbah, tulisan, dan nasihat dakwah Habib Umar bin Hafizh.",
    "en": "Explore the fatwas, sermons, writings and teaching of Habib Umar bin Hafiz.",
    "ar": "تتبّع فتاوى الحبيب عمر بن حفيظ وخطبه ومؤلفاته وإرشاداته الدعوية."
  },
  "Khazanah Ulama": {
    "id": "Khazanah Ulama",
    "en": "Scholars’ works",
    "ar": "تراث العلماء"
  },
  "Kitab & Ribuan Muhadharah Tarim": {
    "id": "Kitab & Ribuan Muhadharah Tarim",
    "en": "Works and lectures from Tarim",
    "ar": "كتب ومحاضرات من تريم"
  },
  "Nasihat Habib Umar mengenai adab menuntut ilmu di era fitnah digital.": {
    "id": "Nasihat Habib Umar mengenai adab menuntut ilmu di era fitnah digital.",
    "en": "Habib Umar’s guidance on the etiquette of study amid digital distractions.",
    "ar": "إرشادات الحبيب عمر في آداب طلب العلم في زمن الفتن الرقمية."
  },
  "Kutipan dari kitab Taujih Al-Nabih tentang penyucian hati.": {
    "id": "Kutipan dari kitab Taujih Al-Nabih tentang penyucian hati.",
    "en": "Passages from Tawjih al-Nabih on purifying the heart.",
    "ar": "عبارات من توجيه النبيه في تزكية القلب."
  },
  "Amalan wirid harian dan dzikir yang diajarkan di Darul Musthafa.": {
    "id": "Amalan wirid harian dan dzikir yang diajarkan di Darul Musthafa.",
    "en": "Daily litanies and remembrances taught at Dar al-Mustafa.",
    "ar": "الأوراد والأذكار اليومية المقررة في دار المصطفى."
  },
  "Pelajari tasawuf, akhlak, dan usul fikih dalam karya-karya Imam Al-Ghazali, termasuk Ihya Ulumiddin.": {
    "id": "Pelajari tasawuf, akhlak, dan usul fikih dalam karya-karya Imam Al-Ghazali, termasuk Ihya Ulumiddin.",
    "en": "Study spirituality, ethics and legal theory in al-Ghazali’s works, including Ihya’ ‘Ulum al-Din.",
    "ar": "ادرس التصوف والأخلاق وأصول الفقه في مؤلفات الغزالي، ومنها إحياء علوم الدين."
  },
  "Ihya Ulumiddin & Naskah Hujjatul Islam": {
    "id": "Ihya Ulumiddin & Naskah Hujjatul Islam",
    "en": "Ihya’ ‘Ulum al-Din and works of al-Ghazali",
    "ar": "إحياء علوم الدين ومؤلفات حجة الإسلام"
  },
  "Bagaimana pembagian ilmu terpuji dan tercela dalam Kitab Al-Ilm Ihya Ulumiddin?": {
    "id": "Bagaimana pembagian ilmu terpuji dan tercela dalam Kitab Al-Ilm Ihya Ulumiddin?",
    "en": "How does the Book of Knowledge in the Ihya’ classify praiseworthy and blameworthy knowledge?",
    "ar": "كيف يقسّم كتاب العلم في الإحياء العلوم المحمودة والمذمومة؟"
  },
  "Penjelasan konsep qalb dan ruh menurut Imam Al-Ghazali.": {
    "id": "Penjelasan konsep qalb dan ruh menurut Imam Al-Ghazali.",
    "en": "Explain the concepts of heart and spirit in al-Ghazali’s thought.",
    "ar": "شرح مفهومي القلب والروح عند الإمام الغزالي."
  },
  "Kaidah maslahah mursalah dan maqashid syariah dalam Al-Mustashfa.": {
    "id": "Kaidah maslahah mursalah dan maqashid syariah dalam Al-Mustashfa.",
    "en": "Unrestricted public interest and the objectives of law in al-Mustasfa.",
    "ar": "المصلحة المرسلة ومقاصد الشريعة في المستصفى."
  },
  "Qawaid Fiqhiyyah": {
    "id": "Qawaid Fiqhiyyah",
    "en": "Legal maxims",
    "ar": "القواعد الفقهية"
  },
  "Pendalaman kaidah-kaidah asasiyah fikih, kulliyyah, dan furu'iyyah lintas mazhab.": {
    "id": "Pendalaman kaidah-kaidah asasiyah fikih, kulliyyah, dan furu'iyyah lintas mazhab.",
    "en": "Study foundational, universal and subsidiary legal maxims across schools.",
    "ar": "دراسة القواعد الفقهية الأساسية والكلية والفرعية عبر المذاهب."
  },
  "Asybah wan-Nazhair & Kaidah Asasiyyah": {
    "id": "Asybah wan-Nazhair & Kaidah Asasiyyah",
    "en": "Al-Ashbah wa-l-Naza’ir and foundational maxims",
    "ar": "الأشباه والنظائر والقواعد الأساسية"
  },
  "Jelaskan 5 kaidah kubra dalam fikih Islam beserta contoh penerapannya!": {
    "id": "Jelaskan 5 kaidah kubra dalam fikih Islam beserta contoh penerapannya!",
    "en": "Explain the five major legal maxims with examples of their application.",
    "ar": "اشرح القواعد الفقهية الخمس الكبرى مع أمثلة تطبيقية."
  },
  "Bagaimana kaidah \"Al-Yaqinu la yazulu bisy-syakk\" diterapkan dalam shalat?": {
    "id": "Bagaimana kaidah \"Al-Yaqinu la yazulu bisy-syakk\" diterapkan dalam shalat?",
    "en": "How is “certainty is not removed by doubt” applied to prayer?",
    "ar": "كيف تُطبّق قاعدة «اليقين لا يزول بالشك» في الصلاة؟"
  },
  "Kutipan dari Al-Asybah wan-Nazhair Imam As-Suyuthi.": {
    "id": "Kutipan dari Al-Asybah wan-Nazhair Imam As-Suyuthi.",
    "en": "Passages from al-Suyuti’s al-Ashbah wa-l-Naza’ir.",
    "ar": "عبارات من الأشباه والنظائر للإمام السيوطي."
  },
  "Fatawa & Masail Fiqhiyyah": {
    "id": "Fatawa & Masail Fiqhiyyah",
    "en": "Fatwas and legal questions",
    "ar": "الفتاوى والمسائل الفقهية"
  },
  "Kompilasi fatwa ulama kibar dan pemecahan masail waqi'iyyah kekinian.": {
    "id": "Kompilasi fatwa ulama kibar dan pemecahan masail waqi'iyyah kekinian.",
    "en": "Collected scholarly fatwas and discussions of contemporary legal questions.",
    "ar": "مجموعة فتاوى كبار العلماء وبحوث النوازل المعاصرة."
  },
  "Fatawa Kubra & Nawadzil Mu'ashirah": {
    "id": "Fatawa Kubra & Nawadzil Mu'ashirah",
    "en": "Major fatwa collections and contemporary cases",
    "ar": "الفتاوى الكبرى والنوازل المعاصرة"
  },
  "Bagaimana fatwa ulama tentang hukum transaksi online dan e-wallet?": {
    "id": "Bagaimana fatwa ulama tentang hukum transaksi online dan e-wallet?",
    "en": "What do scholarly fatwas say about online transactions and digital wallets?",
    "ar": "ما فتاوى العلماء في المعاملات الإلكترونية والمحافظ الرقمية؟"
  },
  "Penjelasan fatwa kontemporer mengenai rekayasa genetika dan bioetika.": {
    "id": "Penjelasan fatwa kontemporer mengenai rekayasa genetika dan bioetika.",
    "en": "Explain contemporary fatwas on genetic engineering and bioethics.",
    "ar": "شرح الفتاوى المعاصرة في الهندسة الوراثية وأخلاقيات الطب الحيوي."
  },
  "Bagaimana kompilasi fatwa Fatawa Al-Kubra Ibnu Taimiyyah dan Ibnu Hajar?": {
    "id": "Bagaimana kompilasi fatwa Fatawa Al-Kubra Ibnu Taimiyyah dan Ibnu Hajar?",
    "en": "How are the major fatwa collections of Ibn Taymiyyah and Ibn Hajar arranged?",
    "ar": "كيف رُتّبت الفتاوى الكبرى لابن تيمية وابن حجر؟"
  },
  "Tajwid & Qiraat": {
    "id": "Tajwid & Qiraat",
    "en": "Recitation and Qur’anic readings",
    "ar": "التجويد والقراءات"
  },
  "Kaidah makhorijul huruf, shifat, tajwid, dan khazanah Qira'at Asyrah.": {
    "id": "Kaidah makhorijul huruf, shifat, tajwid, dan khazanah Qira'at Asyrah.",
    "en": "Articulation, letter qualities, recitation rules and the ten Qur’anic readings.",
    "ar": "مخارج الحروف وصفاتها وأحكام التجويد والقراءات العشر."
  },
  "Al-Jazariyyah, Asy-Syathibiyyah & Qira'at Sab'ah": {
    "id": "Al-Jazariyyah, Asy-Syathibiyyah & Qira'at Sab'ah",
    "en": "Al-Jazariyyah, al-Shatibiyyah and the seven readings",
    "ar": "الجزرية والشاطبية والقراءات السبع"
  },
  "Jelaskan makharijul huruf dan shifat lazimah menurut Matan Al-Jazariyyah!": {
    "id": "Jelaskan makharijul huruf dan shifat lazimah menurut Matan Al-Jazariyyah!",
    "en": "Explain articulation points and inherent letter qualities in al-Jazariyyah.",
    "ar": "اشرح مخارج الحروف وصفاتها اللازمة في متن الجزرية."
  },
  "Apa perbedaan bacaan Imam Hafsh dan Warsy dalam Surah Al-Fatihah?": {
    "id": "Apa perbedaan bacaan Imam Hafsh dan Warsy dalam Surah Al-Fatihah?",
    "en": "How do the readings of Hafs and Warsh differ in al-Fatihah?",
    "ar": "ما الفرق بين روايتي حفص وورش في سورة الفاتحة؟"
  },
  "Bagaimana kaidah hukum nun sukun dan tanwin dijelaskan para imam qiraat?": {
    "id": "Bagaimana kaidah hukum nun sukun dan tanwin dijelaskan para imam qiraat?",
    "en": "How do the recitation authorities explain the rules of silent nun and tanwin?",
    "ar": "كيف يشرح أئمة القراءات أحكام النون الساكنة والتنوين؟"
  },
  "Musthalah Hadis": {
    "id": "Musthalah Hadis",
    "en": "Hadith terminology",
    "ar": "مصطلح الحديث"
  },
  "Metodologi kritik sanad, derajat hadis (shahih, hasan, dha'if), dan ilmu Jarh wat Ta'dil.": {
    "id": "Metodologi kritik sanad, derajat hadis (shahih, hasan, dha'if), dan ilmu Jarh wat Ta'dil.",
    "en": "Methods of chain criticism, hadith grades and narrator evaluation.",
    "ar": "مناهج نقد الأسانيد ودرجات الحديث وعلم الجرح والتعديل."
  },
  "Muqaddimah Ibnu Shalah & Nukhbatul Fikar": {
    "id": "Muqaddimah Ibnu Shalah & Nukhbatul Fikar",
    "en": "Ibn al-Salah’s Introduction and Nukhbat al-Fikar",
    "ar": "مقدمة ابن الصلاح ونخبة الفكر"
  },
  "Apa syarat diterimanya hadis shahih menurut Muqaddimah Ibnu Shalah?": {
    "id": "Apa syarat diterimanya hadis shahih menurut Muqaddimah Ibnu Shalah?",
    "en": "What are the conditions of authentic hadith in Ibn al-Salah’s Introduction?",
    "ar": "ما شروط الحديث الصحيح في مقدمة ابن الصلاح؟"
  },
  "Bagaimana pembagian tingkatan lafazh Jarh wat Ta'dil?": {
    "id": "Bagaimana pembagian tingkatan lafazh Jarh wat Ta'dil?",
    "en": "How are the expressions of narrator criticism and approval graded?",
    "ar": "كيف تُقسّم مراتب ألفاظ الجرح والتعديل؟"
  },
  "Apa perbedaan hadis mu'allaq, munqathi', mu'dhal, dan mudallas?": {
    "id": "Apa perbedaan hadis mu'allaq, munqathi', mu'dhal, dan mudallas?",
    "en": "How do mu‘allaq, munqati‘, mu‘dal and mudallas reports differ?",
    "ar": "ما الفرق بين الحديث المعلّق والمنقطع والمعضل والمدلّس؟"
  },
  "Syarah Hadis": {
    "id": "Syarah Hadis",
    "en": "Hadith commentary",
    "ar": "شروح الحديث"
  },
  "Ensiklopedia syarah hadis Nabawi (Fathul Bari, Syarah Shahih Muslim, Umdatul Qari).": {
    "id": "Ensiklopedia syarah hadis Nabawi (Fathul Bari, Syarah Shahih Muslim, Umdatul Qari).",
    "en": "Hadith commentaries including Fath al-Bari, the commentary on Sahih Muslim and ‘Umdat al-Qari.",
    "ar": "شروح الحديث النبوي، ومنها فتح الباري وشرح صحيح مسلم وعمدة القاري."
  },
  "Fathul Bari, An-Nawawi 'ala Muslim & Syuruh Sittah": {
    "id": "Fathul Bari, An-Nawawi 'ala Muslim & Syuruh Sittah",
    "en": "Fath al-Bari, al-Nawawi on Muslim and commentaries on the Six Books",
    "ar": "فتح الباري وشرح النووي على مسلم وشروح الكتب الستة"
  },
  "Bagaimana Ibnu Hajar mensyarah hadis niat dalam pembukaan Fathul Bari?": {
    "id": "Bagaimana Ibnu Hajar mensyarah hadis niat dalam pembukaan Fathul Bari?",
    "en": "How does Ibn Hajar explain the hadith on intentions at the start of Fath al-Bari?",
    "ar": "كيف يشرح ابن حجر حديث النيات في افتتاح فتح الباري؟"
  },
  "Penjelasan Imam An-Nawawi tentang hadis Islam, Iman, dan Ihsan.": {
    "id": "Penjelasan Imam An-Nawawi tentang hadis Islam, Iman, dan Ihsan.",
    "en": "Imam al-Nawawi’s commentary on the hadith of Islam, faith and spiritual excellence.",
    "ar": "شرح الإمام النووي لحديث الإسلام والإيمان والإحسان."
  },
  "Analisis perbandingan syarah hadis tentang kepemimpinan dan umara.": {
    "id": "Analisis perbandingan syarah hadis tentang kepemimpinan dan umara.",
    "en": "Compare hadith commentaries on leadership and rulers.",
    "ar": "دراسة مقارنة لشروح أحاديث الإمارة والأمراء."
  },
  "Thabaqat & Rijalul Hadis": {
    "id": "Thabaqat & Rijalul Hadis",
    "en": "Biographical layers and hadith narrators",
    "ar": "الطبقات ورجال الحديث"
  },
  "Biografi perawi, silsilah sanad, dan thabaqat ulama hadis dan fikih.": {
    "id": "Biografi perawi, silsilah sanad, dan thabaqat ulama hadis dan fikih.",
    "en": "Narrator biographies, chains of transmission and generations of hadith and legal scholars.",
    "ar": "تراجم الرواة وسلاسل الأسانيد وطبقات علماء الحديث والفقه."
  },
  "Tahdzibut Tahdzib, Siyar A'lam Nubala & Thabaqat": {
    "id": "Tahdzibut Tahdzib, Siyar A'lam Nubala & Thabaqat",
    "en": "Tahdhib al-Tahdhib, Siyar A‘lam al-Nubala’ and biographical works",
    "ar": "تهذيب التهذيب وسير أعلام النبلاء وكتب الطبقات"
  },
  "Bagaimana biografi dan kredibilitas perawi Sufyan Ats-Tsauri?": {
    "id": "Bagaimana biografi dan kredibilitas perawi Sufyan Ats-Tsauri?",
    "en": "What do the sources say about Sufyan al-Thawri’s life and reliability?",
    "ar": "ما ترجمة سفيان الثوري وما درجته في الرواية؟"
  },
  "Kutipan dari Siyar A'lam An-Nubala karya Imam Adz-Dzahabi.": {
    "id": "Kutipan dari Siyar A'lam An-Nubala karya Imam Adz-Dzahabi.",
    "en": "Passages from al-Dhahabi’s Siyar A‘lam al-Nubala’.",
    "ar": "عبارات من سير أعلام النبلاء للإمام الذهبي."
  },
  "Telusuri perawi riwayat ini dalam Tahdzib At-Tahdzib Ibnu Hajar.": {
    "id": "Telusuri perawi riwayat ini dalam Tahdzib At-Tahdzib Ibnu Hajar.",
    "en": "Find this report’s narrators in Ibn Hajar’s Tahdhib al-Tahdhib.",
    "ar": "تتبّع رواة هذا الحديث في تهذيب التهذيب لابن حجر."
  },
  "Bibliografi & Faharis": {
    "id": "Bibliografi & Faharis",
    "en": "Bibliography and indexes",
    "ar": "الببليوغرافيا والفهارس"
  },
  "Katalog induk kitab, manuskrip turath, indeks tema, dan biografi pengarang.": {
    "id": "Katalog induk kitab, manuskrip turath, indeks tema, dan biografi pengarang.",
    "en": "Catalogues of works and manuscripts, subject indexes and author biographies.",
    "ar": "فهارس الكتب والمخطوطات وكشافات الموضوعات وتراجم المؤلفين."
  },
  "Bibliografi": {
    "id": "Bibliografi",
    "en": "Bibliography",
    "ar": "الببليوغرافيا"
  },
  "Kasyfuzh Zhunun, Mu'jamul Mushannifin & Faharis": {
    "id": "Kasyfuzh Zhunun, Mu'jamul Mushannifin & Faharis",
    "en": "Kashf al-Zunun, author dictionaries and indexes",
    "ar": "كشف الظنون ومعاجم المصنفين والفهارس"
  },
  "Apa saja kitab rujukan utama dalam mazhab Syafi'i menurut Kasyfuzh Zhunun?": {
    "id": "Apa saja kitab rujukan utama dalam mazhab Syafi'i menurut Kasyfuzh Zhunun?",
    "en": "Which principal Shafi‘i references are listed in Kashf al-Zunun?",
    "ar": "ما أهم مراجع المذهب الشافعي المذكورة في كشف الظنون؟"
  },
  "Telusuri edisi cetak dan manuskrip terbaik untuk kitab Al-Umm.": {
    "id": "Telusuri edisi cetak dan manuskrip terbaik untuk kitab Al-Umm.",
    "en": "Explore printed editions and manuscripts of al-Umm.",
    "ar": "تتبّع الطبعات والمخطوطات المحققة لكتاب الأم."
  },
  "Katalogisasi karya-karya Imam As-Suyuthi di bidang hadis dan tafsir.": {
    "id": "Katalogisasi karya-karya Imam As-Suyuthi di bidang hadis dan tafsir.",
    "en": "Catalogue al-Suyuti’s works on hadith and exegesis.",
    "ar": "فهرسة مؤلفات الإمام السيوطي في الحديث والتفسير."
  },
  "Manhaj eskatologi Islam, rukun keempat, tanda-tanda zaman, dan sanad Al-Habib Abu Bakar Al-Masyhur.": {
    "id": "Manhaj eskatologi Islam, rukun keempat, tanda-tanda zaman, dan sanad Al-Habib Abu Bakar Al-Masyhur.",
    "en": "Islamic eschatology, the Fourth Pillar, the signs of the times and the transmission of Habib Abu Bakr al-Mashhur.",
    "ar": "منهج النظر في آخر الزمان والركن الرابع وعلامات الساعة وسند الحبيب أبي بكر المشهور."
  },
  "Fikih & Fatwa": {
    "id": "Fikih & Fatwa",
    "en": "Jurisprudence and fatwas",
    "ar": "الفقه والفتوى"
  },
  "Hukum ibadah, muamalah, fatwa kontemporer, dan perbandingan mazhab mu'tabar.": {
    "id": "Hukum ibadah, muamalah, fatwa kontemporer, dan perbandingan mazhab mu'tabar.",
    "en": "Worship, transactions, contemporary fatwas and comparisons of recognized legal schools.",
    "ar": "أحكام العبادات والمعاملات والفتاوى المعاصرة ومقارنة المذاهب المعتبرة."
  },
  "Hadis & Ulumul Hadis": {
    "id": "Hadis & Ulumul Hadis",
    "en": "Hadith and hadith sciences",
    "ar": "الحديث وعلومه"
  },
  "Takhrij sanad, kritik rijalul hadis, dan syarah ensiklopedis Kutubus Sittah.": {
    "id": "Takhrij sanad, kritik rijalul hadis, dan syarah ensiklopedis Kutubus Sittah.",
    "en": "Hadith sourcing, narrator criticism and extensive commentaries on the Six Books.",
    "ar": "تخريج الأسانيد ونقد الرجال والشروح الموسعة للكتب الستة."
  },
  "Tafsir & Qiraat": {
    "id": "Tafsir & Qiraat",
    "en": "Exegesis and Qur’anic readings",
    "ar": "التفسير والقراءات"
  },
  "Asbabun nuzul, munasabah, ilmu tajwid, dan khazanah eksegesis Al-Qur'an.": {
    "id": "Asbabun nuzul, munasabah, ilmu tajwid, dan khazanah eksegesis Al-Qur'an.",
    "en": "Occasions of revelation, textual connections, recitation and Qur’anic exegesis.",
    "ar": "أسباب النزول والمناسبات والتجويد وتراث تفسير القرآن."
  },
  "Akidah & Ushuluddin": {
    "id": "Akidah & Ushuluddin",
    "en": "Creed and theology",
    "ar": "العقيدة وأصول الدين"
  },
  "Kalam Asy'ariyyah, Maturidiyyah, pembahasan ushuluddin, dan dalil aqli-naqli.": {
    "id": "Kalam Asy'ariyyah, Maturidiyyah, pembahasan ushuluddin, dan dalil aqli-naqli.",
    "en": "Ash‘ari and Maturidi theology, foundations of belief and rational and transmitted evidence.",
    "ar": "علم الكلام الأشعري والماتريدي وأصول الدين والأدلة العقلية والنقلية."
  },
  "Usul Fikih & Kaidah": {
    "id": "Usul Fikih & Kaidah",
    "en": "Legal theory and maxims",
    "ar": "أصول الفقه والقواعد"
  },
  "Kaidah istinbath hukum, dalil ijmali, maqashid syariah, dan qawaid fiqhiyyah.": {
    "id": "Kaidah istinbath hukum, dalil ijmali, maqashid syariah, dan qawaid fiqhiyyah.",
    "en": "Legal reasoning, general evidence, objectives of Islamic law and legal maxims.",
    "ar": "قواعد الاستنباط والأدلة الإجمالية ومقاصد الشريعة والقواعد الفقهية."
  },
  "Bahasa & Sastra Arab": {
    "id": "Bahasa & Sastra Arab",
    "en": "Arabic language and literature",
    "ar": "اللغة العربية وآدابها"
  },
  "Nahwu, sharaf, balaghah, dan leksikografi kamus mu'jam klasik.": {
    "id": "Nahwu, sharaf, balaghah, dan leksikografi kamus mu'jam klasik.",
    "en": "Syntax, morphology, rhetoric and classical Arabic lexicography.",
    "ar": "النحو والصرف والبلاغة وصناعة المعاجم العربية القديمة."
  },
  "Sejarah, Sirah & Rijal": {
    "id": "Sejarah, Sirah & Rijal",
    "en": "History, biography and narrators",
    "ar": "التاريخ والسيرة والرجال"
  },
  "Sirah Nabawiyyah, khulafaur rasyidin, thabaqat ulama, dan peradaban Islam.": {
    "id": "Sirah Nabawiyyah, khulafaur rasyidin, thabaqat ulama, dan peradaban Islam.",
    "en": "Prophetic biography, the Rightly Guided Caliphs, scholarly generations and Islamic civilization.",
    "ar": "السيرة النبوية والخلفاء الراشدون وطبقات العلماء والحضارة الإسلامية."
  },
  "Tasawuf & Akhlak": {
    "id": "Tasawuf & Akhlak",
    "en": "Spirituality and ethics",
    "ar": "التصوف والأخلاق"
  },
  "Penyucian jiwa (tazkiyatun nafs), adab suluk, dan hikmah ulama salafush shalih.": {
    "id": "Penyucian jiwa (tazkiyatun nafs), adab suluk, dan hikmah ulama salafush shalih.",
    "en": "Purification of the soul, spiritual conduct and the wisdom of early scholars.",
    "ar": "تزكية النفس وآداب السلوك وحكم علماء السلف الصالح."
  },
  "Indeks ensiklopedi, biografi manuskrip, dan katalog rujukan khazanah Turath Islam.": {
    "id": "Indeks ensiklopedi, biografi manuskrip, dan katalog rujukan khazanah Turath Islam.",
    "en": "Encyclopaedic indexes, manuscript records and reference catalogues of Islamic heritage.",
    "ar": "كشافات الموسوعات وبيانات المخطوطات وفهارس مراجع التراث الإسلامي."
  },
  "Umum & Turats": {
    "id": "Umum & Turats",
    "en": "General studies and heritage",
    "ar": "دراسات عامة وتراث"
  },
  "Pelajari berbagai bidang ilmu dari kitab-kitab rujukan.": {
    "id": "Pelajari berbagai bidang ilmu dari kitab-kitab rujukan.",
    "en": "Explore scholarly disciplines through reference works.",
    "ar": "ادرس مجالات العلم المختلفة في الكتب المرجعية."
  },
  "Riset Mendalam": {
    "id": "Riset Mendalam",
    "en": "Detailed research",
    "ar": "بحث مفصّل"
  },
  "Penjelasan Luas": {
    "id": "Penjelasan Luas",
    "en": "Extended explanation",
    "ar": "شرح موسّع"
  },
  "1 Bulan": {
    "id": "1 Bulan",
    "en": "1 month",
    "ar": "شهر واحد"
  },
  "6 Bulan": {
    "id": "6 Bulan",
    "en": "6 months",
    "ar": "٦ أشهر"
  },
  "12 Bulan": {
    "id": "12 Bulan",
    "en": "12 months",
    "ar": "١٢ شهرًا"
  },
  "1 Tahun": {
    "id": "1 Tahun",
    "en": "1 year",
    "ar": "سنة واحدة"
  },
  "/ bulan": {
    "id": "/ bulan",
    "en": "/ month",
    "ar": "/ شهر"
  },
  "/ 6 bulan": {
    "id": "/ 6 bulan",
    "en": "/ 6 months",
    "ar": "/ ٦ أشهر"
  },
  "/ tahun": {
    "id": "/ tahun",
    "en": "/ year",
    "ar": "/ سنة"
  },
  "6 Bulan (1 Semester)": {
    "id": "6 Bulan (1 Semester)",
    "en": "6 months (1 semester)",
    "ar": "٦ أشهر (فصل دراسي)"
  },
  "12 Bulan (1 Tahun)": {
    "id": "12 Bulan (1 Tahun)",
    "en": "12 months (1 year)",
    "ar": "١٢ شهرًا (سنة واحدة)"
  },
  "1 Bulan (All-Access 24 AI)": {
    "id": "1 Bulan (24 ruang kajian)",
    "en": "1 month (all 24 study rooms)",
    "ar": "شهر واحد (جميع غرف الدراسة الأربع والعشرين)"
  },
  "12 Bulan (1 Tahun Penuh)": {
    "id": "12 Bulan (1 Tahun Penuh)",
    "en": "12 months (1 full year)",
    "ar": "١٢ شهرًا (سنة كاملة)"
  },
  "1 Bulan (Harga Khusus Launch)": {
    "id": "1 Bulan (Harga Khusus Launch)",
    "en": "1 month (introductory price)",
    "ar": "شهر واحد (سعر افتتاحي)"
  },
  "Paket Fikih Pesantren & Santri Salaf": {
    "id": "Paket Fikih Pesantren & Santri Salaf",
    "en": "Traditional seminary jurisprudence collection",
    "ar": "مجموعة الفقه للمعاهد الشرعية"
  },
  "Kajian Syafi'iyyah dan bahtsul masail": {
    "id": "Kajian Syafi'iyyah dan bahtsul masail",
    "en": "Shafi‘i studies and legal discussions",
    "ar": "دراسات شافعية وبحث المسائل"
  },
  "Pilihan kajian fikih": {
    "id": "Pilihan kajian fikih",
    "en": "Jurisprudence selection",
    "ar": "مختارات فقهية"
  },
  "Fikih Syafi'i (Al-Umm, Minhaj, Fathul Mu'in)": {
    "id": "Fikih Syafi'i (Al-Umm, Minhaj, Fathul Mu'in)",
    "en": "Shafi‘i jurisprudence (al-Umm, al-Minhaj, Fath al-Mu‘in)",
    "ar": "الفقه الشافعي (الأم والمنهاج وفتح المعين)"
  },
  "Ushul fikih (kaidah dalil dan metodologi istinbath)": {
    "id": "Ushul fikih (kaidah dalil dan metodologi istinbath)",
    "en": "Legal theory (evidence and methods of reasoning)",
    "ar": "أصول الفقه (قواعد الأدلة ومناهج الاستنباط)"
  },
  "Qawaid fiqhiyyah (kaidah asasiyyah dan furu')": {
    "id": "Qawaid fiqhiyyah (kaidah asasiyyah dan furu')",
    "en": "Legal maxims (foundations and applications)",
    "ar": "القواعد الفقهية (القواعد الأساسية والفروع)"
  },
  "Fatawa dan masail (Nawawi, Ibnu Hajar, Ba'alawi)": {
    "id": "Fatawa dan masail (Nawawi, Ibnu Hajar, Ba'alawi)",
    "en": "Fatwas and questions (al-Nawawi, Ibn Hajar, Ba ‘Alawi)",
    "ar": "الفتاوى والمسائل (النووي وابن حجر وباعلوي)"
  },
  "Tasawwuf dan adzkar (adab syar'i)": {
    "id": "Tasawwuf dan adzkar (adab syar'i)",
    "en": "Spirituality and remembrance (religious etiquette)",
    "ar": "التصوف والأذكار (الآداب الشرعية)"
  },
  "Paket Samudra Hadits & Sirah Nabawiyyah": {
    "id": "Paket Samudra Hadits & Sirah Nabawiyyah",
    "en": "Hadith and prophetic biography collection",
    "ar": "مجموعة الحديث والسيرة النبوية"
  },
  "Telaah hadis, syarah, dan sirah": {
    "id": "Telaah hadis, syarah, dan sirah",
    "en": "Hadith, commentary and biography studies",
    "ar": "دراسة الحديث وشروحه والسيرة"
  },
  "Kajian hadis dan sirah": {
    "id": "Kajian hadis dan sirah",
    "en": "Hadith and biography studies",
    "ar": "دراسات الحديث والسيرة"
  },
  "Hadis Nabawi (Kutubus Sittah dan Kutubut Tis'ah)": {
    "id": "Hadis Nabawi (Kutubus Sittah dan Kutubut Tis'ah)",
    "en": "Prophetic hadith (the Six and Nine Books)",
    "ar": "الحديث النبوي (الكتب الستة والتسعة)"
  },
  "Syarah hadis (Fathul Bari, Syarah Nawawi, Umdah)": {
    "id": "Syarah hadis (Fathul Bari, Syarah Nawawi, Umdah)",
    "en": "Hadith commentary (Fath al-Bari, al-Nawawi, ‘Umdah)",
    "ar": "شروح الحديث (فتح الباري وشرح النووي والعمدة)"
  },
  "Musthalah dan ulumul hadis (takhrij dan 'ilal)": {
    "id": "Musthalah dan ulumul hadis (takhrij dan 'ilal)",
    "en": "Hadith terminology and sciences (sourcing and defects)",
    "ar": "مصطلح الحديث وعلومه (التخريج والعلل)"
  },
  "Thabaqat dan tarajim rijal": {
    "id": "Thabaqat dan tarajim rijal",
    "en": "Biographical layers and narrator biographies",
    "ar": "الطبقات وتراجم الرجال"
  },
  "Tarikh dan sirah Nabawiyyah": {
    "id": "Tarikh dan sirah Nabawiyyah",
    "en": "History and prophetic biography",
    "ar": "التاريخ والسيرة النبوية"
  },
  "Paket Mufassir & Khazanah Bahasa Arab": {
    "id": "Paket Mufassir & Khazanah Bahasa Arab",
    "en": "Exegesis and Arabic language collection",
    "ar": "مجموعة التفسير واللغة العربية"
  },
  "Tafsir, qira'at, dan khazanah bahasa Arab": {
    "id": "Tafsir, qira'at, dan khazanah bahasa Arab",
    "en": "Exegesis, Qur’anic readings and Arabic language",
    "ar": "التفسير والقراءات وتراث اللغة العربية"
  },
  "Tafsir dan bahasa Arab": {
    "id": "Tafsir dan bahasa Arab",
    "en": "Exegesis and Arabic language",
    "ar": "التفسير واللغة العربية"
  },
  "Super AI Tafsir & Ulumul Qur'an (Thabari, Ibnu Katsir, Razi)": {
    "id": "Tafsir & Ulumul Qur'an (Thabari, Ibnu Katsir, Razi)",
    "en": "Qur’anic exegesis and sciences (al-Tabari, Ibn Kathir, al-Razi)",
    "ar": "التفسير وعلوم القرآن (الطبري وابن كثير والرازي)"
  },
  "Super AI Tajwid & Qira'at (Kaidah Bacaan 10 Imam Mutawatir)": {
    "id": "Tajwid & Qira'at (Kaidah Bacaan 10 Imam Mutawatir)",
    "en": "Recitation and readings (the ten canonical readings)",
    "ar": "التجويد والقراءات (القراءات العشر المتواترة)"
  },
  "Super AI Bahasa, Balaghah & Kamus (Lisanul Arab, Alfiyyah)": {
    "id": "Bahasa, Balaghah & Kamus (Lisanul Arab, Alfiyyah)",
    "en": "Language, rhetoric and dictionaries (Lisan al-‘Arab, al-Alfiyyah)",
    "ar": "اللغة والبلاغة والمعاجم (لسان العرب والألفية)"
  },
  "Super AI Bibliografi & Faharis (Peta Manuskrip & Penulis Kitab)": {
    "id": "Bibliografi & Faharis (Peta Manuskrip & Penulis Kitab)",
    "en": "Bibliography and indexes (manuscripts and authors)",
    "ar": "الببليوغرافيا والفهارس (المخطوطات والمؤلفون)"
  },
  "Paket Mufti, Mazhab Akbar & Pemikiran": {
    "id": "Paket Mufti, Mazhab Akbar & Pemikiran",
    "en": "Legal schools and Islamic thought collection",
    "ar": "مجموعة المذاهب والفكر الإسلامي"
  },
  "Telaah mazhab dan pemikiran Islam": {
    "id": "Telaah mazhab dan pemikiran Islam",
    "en": "Studies in legal schools and Islamic thought",
    "ar": "دراسة المذاهب والفكر الإسلامي"
  },
  "Mazhab dan pemikiran": {
    "id": "Mazhab dan pemikiran",
    "en": "Legal schools and thought",
    "ar": "المذاهب والفكر"
  },
  "Super AI Fikih Hanafi (Kutubul Mu'tamadah Mazhab Hanafi)": {
    "id": "Fikih Hanafi (Kutubul Mu'tamadah Mazhab Hanafi)",
    "en": "Hanafi jurisprudence (authoritative works)",
    "ar": "الفقه الحنفي (الكتب المعتمدة)"
  },
  "Super AI Fikih Maliki (Mudawwanah, Mukhtashar Khalil)": {
    "id": "Fikih Maliki (Mudawwanah, Mukhtashar Khalil)",
    "en": "Maliki jurisprudence (al-Mudawwanah, Mukhtasar Khalil)",
    "ar": "الفقه المالكي (المدونة ومختصر خليل)"
  },
  "Super AI Fikih Hanbali (Al-Mughni, Zadul Mustaqni')": {
    "id": "Fikih Hanbali (Al-Mughni, Zadul Mustaqni')",
    "en": "Hanbali jurisprudence (al-Mughni, Zad al-Mustaqni‘)",
    "ar": "الفقه الحنبلي (المغني وزاد المستقنع)"
  },
  "Super AI Fikih Muqaran & Siyasah (Tata Negara & Politik Islam)": {
    "id": "Fikih Muqaran & Siyasah (Tata Negara & Politik Islam)",
    "en": "Comparative jurisprudence and governance",
    "ar": "الفقه المقارن والسياسة الشرعية"
  },
  "Super AI Aqidah & Ushuluddin (Kalam, Asy'ariyah-Maturidiyah)": {
    "id": "Aqidah & Ushuluddin (Kalam, Asy'ariyah-Maturidiyah)",
    "en": "Creed and theology (Ash‘ari and Maturidi thought)",
    "ar": "العقيدة وأصول الدين (الكلام الأشعري والماتريدي)"
  },
  "Super AI Fatawa Akbar Lintas Mazhab": {
    "id": "Fatawa Akbar Lintas Mazhab",
    "en": "Major fatwa collections across schools",
    "ar": "مجاميع الفتاوى الكبرى عبر المذاهب"
  },
  "Paket Khusus Fikih Tahawwulat": {
    "id": "Paket Khusus Fikih Tahawwulat",
    "en": "Fiqh of transformations collection",
    "ar": "مجموعة فقه التحولات"
  },
  "Telaah perubahan zaman dan tanda akhir masa": {
    "id": "Telaah perubahan zaman dan tanda akhir masa",
    "en": "Studies in historical change and the signs of the end times",
    "ar": "دراسة تحولات الزمان وعلامات آخره"
  },
  "Koleksi khusus": {
    "id": "Koleksi khusus",
    "en": "Special collection",
    "ar": "مجموعة خاصة"
  },
  "Persona Al-Muhaqqiq (Bedah Konsep & Dalil Ushul)": {
    "id": "Al-Muhaqqiq (Bedah Konsep & Dalil Ushul)",
    "en": "Al-Muhaqqiq (concepts and foundational evidence)",
    "ar": "المحقق (المفاهيم والأدلة الأصولية)"
  },
  "Persona Al-Bayan (Panduan Sikap Dakwah & Solusi Zaman)": {
    "id": "Al-Bayan (Panduan Sikap Dakwah & Solusi Zaman)",
    "en": "Al-Bayan (teaching guidance and contemporary questions)",
    "ar": "البيان (التوجيه الدعوي وقضايا العصر)"
  },
  "Persona Al-Mukhtabir (Uji Komparasi Realitas & Tanda Zaman)": {
    "id": "Al-Mukhtabir (Uji Komparasi Realitas & Tanda Zaman)",
    "en": "Al-Mukhtabir (examining events and the signs of the times)",
    "ar": "المختبر (دراسة الواقع وعلامات الزمان)"
  },
  "Persona Al-Habib (Bimbingan Jiwa & Keselamatan Iman)": {
    "id": "Al-Habib (Bimbingan Jiwa & Keselamatan Iman)",
    "en": "Al-Habib (spiritual guidance and care for faith)",
    "ar": "الحبيب (الإرشاد الروحي وحفظ الإيمان)"
  },
  "Persona Al-Khatib (Penyusun Teks Khutbah & Retorika Da'i)": {
    "id": "Al-Khatib (Penyusun Teks Khutbah & Retorika Da'i)",
    "en": "Al-Khatib (sermon writing and public speaking)",
    "ar": "الخطيب (صياغة الخطب وفنون الإلقاء)"
  },
  "Paket lengkap seluruh bidang": {
    "id": "Paket lengkap seluruh bidang",
    "en": "Complete subject collection",
    "ar": "مجموعة جميع التخصصات"
  },
  "Akses ke seluruh ruang kajian OpenTurath": {
    "id": "Akses ke seluruh ruang kajian OpenTurath",
    "en": "Access to all OpenTurath study rooms",
    "ar": "الوصول إلى جميع غرف الدراسة في OpenTurath"
  },
  "Akses seluruh bidang": {
    "id": "Akses seluruh bidang",
    "en": "Access to all subjects",
    "ar": "الوصول إلى جميع التخصصات"
  },
  "Akses Lengkap Seluruh 20 Modul Turats Lokal": {
    "id": "Akses Lengkap Seluruh 20 Modul Turats Lokal",
    "en": "Access to all 20 heritage modules",
    "ar": "الوصول إلى وحدات التراث العشرين"
  },
  "Akses Seluruh 5 Persona Fikih Tahawwulat": {
    "id": "Akses Seluruh 5 Fikih Tahawwulat",
    "en": "Access to all five fiqh of transformations roles",
    "ar": "الوصول إلى الأدوار الخمسة في فقه التحولات"
  },
  "Akses Pemrosesan Komputasi Optimal": {
    "id": "Akses fitur pemrosesan telaah",
    "en": "Access to study processing features",
    "ar": "الوصول إلى إمكانات معالجة الدراسة"
  },
  "Pembaruan Korpus Naskah Digital Berkala": {
    "id": "Pembaruan Korpus Naskah Digital Berkala",
    "en": "Regular digital corpus updates",
    "ar": "تحديثات دورية لمجموعة النصوص الرقمية"
  },
  "Layanan Khadim Ilmiah Langsung dari Tim Peneliti OpenTurath": {
    "id": "Dukungan kajian dari tim peneliti OpenTurath",
    "en": "Research support from the OpenTurath team",
    "ar": "دعم بحثي من فريق OpenTurath"
  },
  "GRATIS": {
    "id": "GRATIS",
    "en": "FREE",
    "ar": "مجاني"
  },
  "PRO": {
    "id": "PRO",
    "en": "PRO",
    "ar": "PRO"
  },
  "Akses sesuai paket {plan}": {
    "id": "Akses sesuai paket {plan}",
    "en": "Access under the {plan} plan",
    "ar": "الوصول وفق خطة {plan}"
  },
  "Masa coba · {days} hari": {
    "id": "Masa coba · {days} hari",
    "en": "Trial · {days} days",
    "ar": "فترة تجريبية · {days} أيام"
  },
  "{count} asisten tersedia": {
    "id": "{count} asisten tersedia",
    "en": "{count} study rooms available",
    "ar": "غرف الدراسة المتاحة: {count}"
  },
  "Al-Muhaqqiq": {
    "id": "Al-Muhaqqiq",
    "en": "Al-Muhaqqiq",
    "ar": "المحقق"
  },
  "Al-Bayan": {
    "id": "Al-Bayan",
    "en": "Al-Bayan",
    "ar": "البيان"
  },
  "Al-Mukhtabir": {
    "id": "Al-Mukhtabir",
    "en": "Al-Mukhtabir",
    "ar": "المختبر"
  },
  "Al-Habib": {
    "id": "Al-Habib",
    "en": "Al-Habib",
    "ar": "الحبيب"
  },
  "Al-Khatib": {
    "id": "Al-Khatib",
    "en": "Al-Khatib",
    "ar": "الخطيب"
  },
  "Nubdzah Al-Bayan fi Ma'rifati Sunan Al-Khalaq": {
    "id": "Nubdzah Al-Bayan fi Ma'rifati Sunan Al-Khalaq",
    "en": "Nubdzah Al-Bayan fi Ma'rifati Sunan Al-Khalaq",
    "ar": "نبذة البيان في معرفة سنن الخلق والبيان"
  },
  "Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat": {
    "id": "Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat",
    "en": "Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat",
    "ar": "الفقه المنهجي في فقه التحولات"
  },
  "Al-Umm": {
    "id": "Al-Umm",
    "en": "Al-Umm",
    "ar": "الأم"
  },
  "Al-Majmu' Syarah Al-Muhadzdzab": {
    "id": "Al-Majmu' Syarah Al-Muhadzdzab",
    "en": "Al-Majmu' Syarah Al-Muhadzdzab",
    "ar": "المجموع شرح المهذب"
  },
  "Al-Mabsuth": {
    "id": "Al-Mabsuth",
    "en": "Al-Mabsuth",
    "ar": "المبسوط"
  },
  "Radd Al-Muhtar 'ala Ad-Durr Al-Mukhtar (Hasyiyah Ibnu Abidin)": {
    "id": "Radd Al-Muhtar 'ala Ad-Durr Al-Mukhtar (Hasyiyah Ibnu Abidin)",
    "en": "Radd Al-Muhtar 'ala Ad-Durr Al-Mukhtar (Hasyiyah Ibnu Abidin)",
    "ar": "رد المحتار على الدر المختار"
  },
  "Al-Mudawwanah Al-Kubra": {
    "id": "Al-Mudawwanah Al-Kubra",
    "en": "Al-Mudawwanah Al-Kubra",
    "ar": "المدونة الكبرى"
  },
  "Mukhtashar Khalil": {
    "id": "Mukhtashar Khalil",
    "en": "Mukhtashar Khalil",
    "ar": "مختصر خليل"
  },
  "Al-Mughni": {
    "id": "Al-Mughni",
    "en": "Al-Mughni",
    "ar": "المغني"
  },
  "Kasysyaf Al-Qina' 'an Matn Al-Iqna'": {
    "id": "Kasysyaf Al-Qina' 'an Matn Al-Iqna'",
    "en": "Kasysyaf Al-Qina' 'an Matn Al-Iqna'",
    "ar": "كشاف القناع عن متن الإقناع"
  },
  "Bidayatul Mujtahid wa Nihayatul Muqtashid": {
    "id": "Bidayatul Mujtahid wa Nihayatul Muqtashid",
    "en": "Bidayatul Mujtahid wa Nihayatul Muqtashid",
    "ar": "بداية المجتهد ونهاية المقتصد"
  },
  "Al-Fiqh Al-Islami wa Adillatuh": {
    "id": "Al-Fiqh Al-Islami wa Adillatuh",
    "en": "Al-Fiqh Al-Islami wa Adillatuh",
    "ar": "الفقه الإسلامي وأدلته"
  },
  "Shahih Al-Bukhari": {
    "id": "Shahih Al-Bukhari",
    "en": "Shahih Al-Bukhari",
    "ar": "صحيح البخاري"
  },
  "Shahih Muslim": {
    "id": "Shahih Muslim",
    "en": "Shahih Muslim",
    "ar": "صحيح مسلم"
  },
  "Tafsir Al-Qur'an Al-'Azhim": {
    "id": "Tafsir Al-Qur'an Al-'Azhim",
    "en": "Tafsir Al-Qur'an Al-'Azhim",
    "ar": "تفسير ابن كثير"
  },
  "Al-Jami' li Ahkam Al-Qur'an": {
    "id": "Al-Jami' li Ahkam Al-Qur'an",
    "en": "Al-Jami' li Ahkam Al-Qur'an",
    "ar": "تفسير القرطبي"
  },
  "Matan Al-Waraqat": {
    "id": "Matan Al-Waraqat",
    "en": "Matan Al-Waraqat",
    "ar": "متن الورقات"
  },
  "Jam'ul Jawami'": {
    "id": "Jam'ul Jawami'",
    "en": "Jam'ul Jawami'",
    "ar": "جمع الجوامع"
  },
  "Al-Mu'rib": {
    "id": "Al-Mu'rib",
    "en": "Al-Mu'rib",
    "ar": "المعرب"
  },
  "At-Tashrif": {
    "id": "At-Tashrif",
    "en": "At-Tashrif",
    "ar": "المصرف"
  },
  "Alfiyah Ibnu Malik": {
    "id": "Alfiyah Ibnu Malik",
    "en": "Alfiyah Ibnu Malik",
    "ar": "ألفية ابن مالك"
  },
  "Syarah Ibnu Aqil": {
    "id": "Syarah Ibnu Aqil",
    "en": "Syarah Ibnu Aqil",
    "ar": "شرح ابن عقيل"
  },
  "Habib Umar bin Hafizh": {
    "id": "Habib Umar bin Hafizh",
    "en": "Habib Umar bin Hafizh",
    "ar": "الحبيب عمر بن حفيظ"
  },
  "Imam Al-Ghazali": {
    "id": "Imam Al-Ghazali",
    "en": "Imam Al-Ghazali",
    "ar": "حجة الإسلام الغزالي"
  },
  "Rp 1.349.000": {
    "id": "Rp 1.349.000",
    "en": "IDR 1,349,000",
    "ar": "١٬٣٤٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 2.490.000": {
    "id": "Rp 2.490.000",
    "en": "IDR 2,490,000",
    "ar": "٢٬٤٩٠٬٠٠٠ روبية إندونيسية"
  },
  "Rp 179.000": {
    "id": "Rp 179.000",
    "en": "IDR 179,000",
    "ar": "١٧٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 1.590.000": {
    "id": "Rp 1.590.000",
    "en": "IDR 1,590,000",
    "ar": "١٬٥٩٠٬٠٠٠ روبية إندونيسية"
  },
  "Rp 1.190.000": {
    "id": "Rp 1.190.000",
    "en": "IDR 1,190,000",
    "ar": "١٬١٩٠٬٠٠٠ روبية إندونيسية"
  },
  "Rp 890.000": {
    "id": "Rp 890.000",
    "en": "IDR 890,000",
    "ar": "٨٩٠٬٠٠٠ روبية إندونيسية"
  },
  "Rp 499.000": {
    "id": "Rp 499.000",
    "en": "IDR 499,000",
    "ar": "٤٩٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 149.000": {
    "id": "Rp 149.000",
    "en": "IDR 149,000",
    "ar": "١٤٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 1.499.000": {
    "id": "Rp 1.499.000",
    "en": "IDR 1,499,000",
    "ar": "١٬٤٩٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 749.000": {
    "id": "Rp 749.000",
    "en": "IDR 749,000",
    "ar": "٧٤٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 4.490.000": {
    "id": "Rp 4.490.000",
    "en": "IDR 4,490,000",
    "ar": "٤٬٤٩٠٬٠٠٠ روبية إندونيسية"
  },
  "Rp 99.000": {
    "id": "Rp 99.000",
    "en": "IDR 99,000",
    "ar": "٩٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 129.000": {
    "id": "Rp 129.000",
    "en": "IDR 129,000",
    "ar": "١٢٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 2.995.000": {
    "id": "Rp 2.995.000",
    "en": "IDR 2,995,000",
    "ar": "٢٬٩٩٥٬٠٠٠ روبية إندونيسية"
  },
  "Rp 1.999.000": {
    "id": "Rp 1.999.000",
    "en": "IDR 1,999,000",
    "ar": "١٬٩٩٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 4.995.000": {
    "id": "Rp 4.995.000",
    "en": "IDR 4,995,000",
    "ar": "٤٬٩٩٥٬٠٠٠ روبية إندونيسية"
  },
  "Rp 1.000.000": {
    "id": "Rp 1.000.000",
    "en": "IDR 1,000,000",
    "ar": "١٬٠٠٠٬٠٠٠ روبية إندونيسية"
  },
  "Rp 899.000": {
    "id": "Rp 899.000",
    "en": "IDR 899,000",
    "ar": "٨٩٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 299.000": {
    "id": "Rp 299.000",
    "en": "IDR 299,000",
    "ar": "٢٩٩٬٠٠٠ روبية إندونيسية"
  },
  "Rp 649.000": {
    "id": "Rp 649.000",
    "en": "IDR 649,000",
    "ar": "٦٤٩٬٠٠٠ روبية إندونيسية"
  },
  "Habib Abu Bakar Al-Masyhur": {
    "id": "Habib Abu Bakar Al-Masyhur",
    "en": "Habib Abu Bakar Al-Masyhur",
    "ar": "Habib Abu Bakar Al-Masyhur"
  },
  "Imam Asy-Syafi'i": {
    "id": "Imam Asy-Syafi'i",
    "en": "Imam Asy-Syafi'i",
    "ar": "Imam Asy-Syafi'i"
  },
  "Imam An-Nawawi": {
    "id": "Imam An-Nawawi",
    "en": "Imam An-Nawawi",
    "ar": "Imam An-Nawawi"
  },
  "Imam As-Sarakhsi": {
    "id": "Imam As-Sarakhsi",
    "en": "Imam As-Sarakhsi",
    "ar": "Imam As-Sarakhsi"
  },
  "Ibnu 'Abidin": {
    "id": "Ibnu 'Abidin",
    "en": "Ibnu 'Abidin",
    "ar": "Ibnu 'Abidin"
  },
  "Imam Sahnun (dari Imam Malik)": {
    "id": "Imam Sahnun (dari Imam Malik)",
    "en": "Imam Sahnun (dari Imam Malik)",
    "ar": "Imam Sahnun (dari Imam Malik)"
  },
  "Syaikh Khalil bin Ishaq": {
    "id": "Syaikh Khalil bin Ishaq",
    "en": "Syaikh Khalil bin Ishaq",
    "ar": "Syaikh Khalil bin Ishaq"
  },
  "Ibnu Qudamah Al-Maqdisi": {
    "id": "Ibnu Qudamah Al-Maqdisi",
    "en": "Ibnu Qudamah Al-Maqdisi",
    "ar": "Ibnu Qudamah Al-Maqdisi"
  },
  "Manshur bin Yunus Al-Buhuti": {
    "id": "Manshur bin Yunus Al-Buhuti",
    "en": "Manshur bin Yunus Al-Buhuti",
    "ar": "Manshur bin Yunus Al-Buhuti"
  },
  "Ibnu Rusyd Al-Hafid": {
    "id": "Ibnu Rusyd Al-Hafid",
    "en": "Ibnu Rusyd Al-Hafid",
    "ar": "Ibnu Rusyd Al-Hafid"
  },
  "Prof. Dr. Wahbah Az-Zuhaili": {
    "id": "Prof. Dr. Wahbah Az-Zuhaili",
    "en": "Prof. Dr. Wahbah Az-Zuhaili",
    "ar": "Prof. Dr. Wahbah Az-Zuhaili"
  },
  "Imam Al-Bukhari": {
    "id": "Imam Al-Bukhari",
    "en": "Imam Al-Bukhari",
    "ar": "Imam Al-Bukhari"
  },
  "Imam Muslim": {
    "id": "Imam Muslim",
    "en": "Imam Muslim",
    "ar": "Imam Muslim"
  },
  "Al-Hafizh Ibnu Katsir": {
    "id": "Al-Hafizh Ibnu Katsir",
    "en": "Al-Hafizh Ibnu Katsir",
    "ar": "Al-Hafizh Ibnu Katsir"
  },
  "Imam Al-Qurtubi": {
    "id": "Imam Al-Qurtubi",
    "en": "Imam Al-Qurtubi",
    "ar": "Imam Al-Qurtubi"
  },
  "Imam Al-Haramain Al-Juwaini": {
    "id": "Imam Al-Haramain Al-Juwaini",
    "en": "Imam Al-Haramain Al-Juwaini",
    "ar": "Imam Al-Haramain Al-Juwaini"
  },
  "Tajuddin As-Subki": {
    "id": "Tajuddin As-Subki",
    "en": "Tajuddin As-Subki",
    "ar": "Tajuddin As-Subki"
  },
  "Ibnu Malik": {
    "id": "Ibnu Malik",
    "en": "Ibnu Malik",
    "ar": "Ibnu Malik"
  },
  "Ibnu Aqil": {
    "id": "Ibnu Aqil",
    "en": "Ibnu Aqil",
    "ar": "Ibnu Aqil"
  }
};
