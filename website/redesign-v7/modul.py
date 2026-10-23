"""Modul "Mengenal Fikih Tahawwulat" untuk orang awam. Satu sumber untuk web dan aplikasi (build_app_json)."""

def T(i, e, a): return {"id": i, "en": e, "ar": a}

MODUL = {
"head": {
  "kicker": T("Mengenal Fikih Tahawwulat", "Getting to know Fiqh al-Tahawwulat", "التعرّف على فقه التحولات"),
  "title": T("Ilmu untuk memahami zaman yang terus berubah.", "A knowledge for understanding a changing age.", "علم لفهم زمان يتغيّر."),
  "lead": T("Panduan singkat untuk orang awam: ilmu apa ini, apa gunanya dalam hidup Anda, dan apa bedanya dengan pembahasan akhir zaman yang sering beredar.",
            "A short guide for everyone: what this knowledge is, what it is good for in your life, and how it differs from the end-times talk that circulates.",
            "دليل موجز لعامة القرّاء: ما هذا العلم، وما فائدته في حياتك، وبماذا يختلف عن حديث آخر الزمان المتداول."),
},

# 1. Pertanyaan yang sulit dijawab
"q": {
  "kicker": T("Mengapa ilmu ini ada", "Why this knowledge exists", "لماذا وُجد هذا العلم"),
  "title": T("Pertanyaan yang kini sulit mendapat jawaban.", "Questions that are hard to answer today.", "أسئلة يصعب أن نجد لها جوابًا اليوم."),
  "lead": T("Banyak orang membawa pertanyaan ini diam-diam. Fikih Tahawwulat hadir untuk menjawab pertanyaan seperti ini dengan petunjuk Al-Qur'an dan hadis. Di sini kami hanya menunjukkan pertanyaannya. Jawabannya ada di kitab dan bisa Anda tanyakan kepada OpenTurath AI.",
            "Many people carry these questions quietly. Fiqh al-Tahawwulat exists to answer questions like these by the guidance of the Qur'an and hadith. Here we only show the questions. The answers are in the books, and you can ask OpenTurath AI.",
            "يحمل كثيرون هذه الأسئلة في صمت. وقد وُجد فقه التحولات ليجيب عن مثلها بهدي القرآن والحديث. نعرض هنا الأسئلة فقط، أما الأجوبة ففي الكتب، ويمكنك أن تسأل OpenTurath AI."),
  "groups": [
    (T("Tentang hati dan berita", "About the heart and the news", "عن القلب والأخبار"), [
      T("Kenapa dunia terasa makin kacau? Apakah semua ini sudah dikabarkan Nabi?", "Why does the world feel more chaotic? Did the Prophet already tell us of this?", "لماذا يبدو العالم أكثر اضطرابًا؟ وهل أخبر النبي ﷺ بهذا؟"),
      T("Saya capek dengan berita buruk. Haruskah saya terus mengikuti semuanya?", "I am tired of bad news. Must I keep following all of it?", "تعبتُ من الأخبار السيئة. هل يلزمني متابعتها كلها؟"),
      T("Kenapa iman saya naik turun dan susah istikamah?", "Why does my faith rise and fall, and why is steadfastness so hard?", "لماذا يعلو إيماني ويهبط، ويصعب عليّ الثبات؟")]),
    (T("Tentang ilmu dan guru", "About knowledge and teachers", "عن العلم والمعلمين"), [
      T("Kenapa orang yang tidak berilmu justru paling didengar di media sosial?", "Why are people without knowledge the ones most heard on social media?", "لماذا يُسمع في وسائل التواصل من لا علم له أكثر من غيره؟"),
      T("Bagaimana membedakan ustaz yang tepercaya dari yang bukan?", "How do I tell a trustworthy teacher from one who is not?", "كيف أميّز المعلم الموثوق من غيره؟"),
      T("Apa yang harus saya lakukan dengan hoaks agama di grup keluarga?", "What should I do with religious hoaxes in the family group chat?", "ماذا أفعل بالأخبار الدينية المكذوبة في مجموعة الأسرة؟")]),
    (T("Tentang keluarga", "About the family", "عن الأسرة"), [
      T("Bagaimana menjaga iman anak di zaman layar?", "How do I protect my child's faith in the age of screens?", "كيف أحفظ إيمان ابني في زمن الشاشات؟"),
      T("Bagaimana bersikap bila keluarga berbeda pandangan soal politik dan fitnah?", "How should I act when family members differ on politics and trials?", "كيف أتصرف إذا اختلف أهلي في السياسة والفتن؟")]),
    (T("Tentang umat", "About the Ummah", "عن الأمة"), [
      T("Kenapa umat Islam banyak jumlahnya, tetapi terasa lemah?", "Why are Muslims so many, yet feel weak?", "لماذا المسلمون كثيرون ومع ذلك يشعرون بالضعف؟"),
      T("Bagaimana bersikap saat melihat perpecahan dan saling caci?", "How should I act when I see division and mutual cursing?", "كيف أتصرف حين أرى الفرقة والتسابّ؟")]),
    (T("Tentang zaman baru", "About the new age", "عن الزمان الجديد"), [
      T("Bagaimana agama menyikapi AI, internet, dan budaya baru?", "How does religion treat AI, the internet, and new cultures?", "كيف يتعامل الدين مع الذكاء الاصطناعي والإنترنت والثقافات الجديدة؟"),
      T("Bagaimana sikap kita terhadap bencana alam dan wabah?", "How should we respond to natural disasters and epidemics?", "كيف نتعامل مع الكوارث الطبيعية والأوبئة؟")]),
    (T("Tentang akhir zaman", "About the end of time", "عن آخر الزمان"), [
      T("Bolehkah menebak tahun kiamat?", "May we guess the year of the Hour?", "هل يجوز تخمين سنة قيام الساعة؟"),
      T("Apakah tokoh atau peristiwa tertentu itu tanda kiamat?", "Is this or that figure or event a sign of the Hour?", "هل هذا الشخص أو هذا الحدث من أشراط الساعة؟")]),
  ],
},

# 2. Apa itu
"what": {
  "kicker": T("Apa itu", "What it is", "ما هو"),
  "title": T("Fikih Tahawwulat, dengan kata paling sederhana.", "Fiqh al-Tahawwulat, in the simplest words.", "فقه التحولات بأبسط عبارة."),
  "lead": T("Fikih artinya paham yang dalam. Tahawwulat artinya perubahan-perubahan. Jadi Fikih Tahawwulat adalah ilmu untuk memahami perubahan zaman dengan petunjuk Al-Qur'an dan hadis, supaya kita tahu sikap yang paling selamat.",
            "Fiqh means deep understanding. Tahawwulat means changes. So Fiqh al-Tahawwulat is the knowledge of understanding the changes of the age by the guidance of the Qur'an and hadith, so we know the safest stance.",
            "الفقه هو الفهم العميق، والتحولات هي التغيّرات. فـ«فقه التحولات» علم فهم تغيّرات الزمان بهدي القرآن والحديث، لنعرف الموقف الأسلم."),
  "contrast": (T("Fikih yang biasa menjawab:", "Ordinary fiqh answers:", "الفقه المعتاد يجيب:"), T("“Bagaimana salat dan zakat saya sah?”", "“How are my prayer and zakat valid?”", "«كيف تصحّ صلاتي وزكاتي؟»"),
               T("Fikih Tahawwulat menjawab:", "Fiqh al-Tahawwulat answers:", "وفقه التحولات يجيب:"), T("“Bagaimana saya menjaga agama saya ketika zaman berubah dan penuh ujian?”", "“How do I protect my faith when the age changes and is full of trials?”", "«كيف أحفظ ديني حين يتغيّر الزمان وتكثر الابتلاءات؟»")),
  "points": [
    (T("Bukan ilmu baru yang dibuat-buat", "Not an invented science", "ليس علمًا مبتدعًا"), T("Dasarnya Hadis Jibril. Malaikat Jibril bertanya empat hal: Islam, Iman, Ihsan, dan tanda-tanda zaman. Fikih Tahawwulat adalah penjelasan tertata atas bagian keempat.", "Its basis is the Hadith of Jibril. The angel asked four things: Islam, Iman, Ihsan, and the signs of the times. Fiqh al-Tahawwulat is the organized explanation of the fourth.", "أصله حديث جبريل، وفيه أربعة أسئلة: الإسلام والإيمان والإحسان وعلامات الساعة. وفقه التحولات هو الشرح المنظّم للرابع.")),
    (T("Pagar bagi tiga ilmu lainnya", "A fence around the other three", "سياج للعلوم الثلاثة الأخرى"), T("Islam, Iman, dan Ihsan adalah yang tetap. Bagian keempat menjaganya agar tidak rusak atau ditinggalkan ketika zaman berguncang.", "Islam, Iman, and Ihsan are what stays. The fourth guards them so they are not spoiled or abandoned when the age shakes.", "الإسلام والإيمان والإحسان هي الثوابت، والرابع يحفظها كي لا تفسد أو تُترك حين يضطرب الزمان.")),
    (T("Disusun oleh Al-Habib Abu Bakar", "Composed by Al-Habib Abu Bakar", "صاغه الحبيب أبو بكر"), T("Ulama Hadramaut yang merapikan warisan para ulama terdahulu menjadi satu bidang ilmu yang mudah dipelajari.", "A Hadrami scholar who arranged the legacy of earlier scholars into one field that is easy to study.", "عالم حضرمي رتّب ميراث العلماء السابقين في علم واحد ميسَّر للدراسة.")),
  ],
},

# 3. Faedah nyata
"benefit": {
  "kicker": T("Faedahnya", "What it gives you", "فوائده"),
  "title": T("Manfaat nyata dalam hidup sehari-hari.", "Real benefits in everyday life.", "فوائد ملموسة في الحياة اليومية."),
  "lead": T("Ilmu ini bukan bahan hafalan. Inilah yang bisa terasa dalam keseharian Anda.", "This is not material to memorize. This is what you can feel in your daily life.", "هذا العلم ليس للحفظ فحسب. وهذا ما يمكن أن تشعر به في يومك."),
  "items": [
    (T("Hati lebih tenang saat membaca berita", "A calmer heart when reading the news", "قلب أهدأ عند قراءة الأخبار"), T("Anda tahu gambaran besar zaman, jadi tidak mudah panik. Anda juga tahu kapan cukup dan boleh berhenti mengikuti.", "You know the big picture of the age, so you do not panic easily. You also know when it is enough to stop following.", "تعرف الصورة العامة للزمان فلا تفزع بسهولة، وتعرف متى يكفي أن تتوقف عن المتابعة.")),
    (T("Tidak mudah tertipu ramalan dan hoaks", "Not easily fooled by predictions and hoaxes", "لا تنخدع بسهولة بالتنبؤات والأخبار المكذوبة"), T("Anda punya tiga rambu: tidak menebak tahun, tidak menunjuk orang atau kelompok, dan tidak memaksakan hadis pada politik harian.", "You hold three signposts: no guessing years, no pointing at people or groups, and no forcing hadith onto daily politics.", "لديك ثلاث علامات: لا تخمين للسنوات، ولا إشارة إلى أشخاص أو جماعات، ولا إسقاط للحديث على السياسة اليومية.")),
    (T("Tahu apa yang harus dikerjakan", "Knowing what to do", "معرفة ما يجب فعله"), T("Cemas diganti langkah: jaga salat, pastikan nafkah halal, tahan lisan, dan perbanyak kebaikan di lingkungan terdekat.", "Worry is replaced by steps: keep prayer, make income lawful, hold your tongue, and do more good close to you.", "يُستبدل القلق بخطوات: حافظ على الصلاة، وتحرَّ الحلال في الرزق، وأمسك لسانك، وأكثر الخير حولك.")),
    (T("Rumah lebih rukun saat beda pendapat", "A more peaceful home when views differ", "بيت أكثر سكينة عند الاختلاف"), T("Anda memegang prinsip: ikatan keluarga yang pasti lebih utama daripada debat yang belum pasti.", "You hold the principle: a sure family bond outranks an uncertain argument.", "تتمسّك بمبدأ: رابطة الأسرة القائمة أولى من جدال غير مؤكَّد.")),
    (T("Lebih jeli memilih guru dan sumber", "Sharper in choosing teachers and sources", "أدق في اختيار المعلم والمصدر"), T("Anda tahu ukurannya: sanad yang jelas, adab yang baik, dan tidak dijadikan alat politik sesaat.", "You know the measure: a clear chain of learning, good manners, and no use as a tool of passing politics.", "تعرف المعيار: سند واضح، وأدب حسن، وعدم اتخاذ العلم أداة لسياسة عابرة.")),
    (T("Bijak memakai media sosial dan teknologi", "Wise with social media and technology", "حكيم في وسائل التواصل والتقنية"), T("Anda punya saringan: ambil yang bermanfaat, tolak yang merusak, dan tidak menjadikan mesin sebagai pengganti guru.", "You have a filter: take what helps, reject what harms, and do not make a machine a replacement for a teacher.", "لديك مصفاة: خذ النافع وردّ الضار، ولا تجعل الآلة بديلًا عن المعلم.")),
    (T("Mendidik anak dengan hangat", "Raising children warmly", "تربية الأبناء بدفء"), T("Bukan hanya melarang. Anda belajar menjadikan rumah benteng kasih sayang dan teladan.", "Not only forbidding. You learn to make the home a fortress of love and example.", "ليس بالمنع وحده، بل بجعل البيت حصنًا من المحبة والقدوة.")),
    (T("Bisa menjelaskan zaman ini tanpa bertengkar", "Able to explain this age without a quarrel", "قدرة على شرح هذا الزمان دون خصام"), T("Anda punya bahasa yang sejuk untuk menasihati dan menjawab kegelisahan orang lain.", "You have a gentle language for advising and answering other people's unease.", "تملك لغة لطيفة للنصح والإجابة عن قلق الآخرين.")),
  ],
},

# 4. Cabang
"branch": {
  "kicker": T("Cabang ilmunya", "Its branches", "فروعه"),
  "title": T("Lima cabang, dan apa yang bisa dijawab.", "Five branches, and what each can answer.", "خمسة فروع وما تجيب عنه."),
  "lead": T("Fikih Tahawwulat bukan satu topik. Ia terdiri dari lima cabang, masing-masing menjawab jenis pertanyaan yang berbeda.", "Fiqh al-Tahawwulat is not a single topic. It has five branches, each answering a different kind of question.", "فقه التحولات ليس موضوعًا واحدًا، بل خمسة فروع، يجيب كل منها عن نوع من الأسئلة."),
  "items": [
    (T("Fitnah dan cara menjaga diri", "Fitna and how to stay safe", "الفتن وطرق الوقاية"), T("Mengenali hal yang merusak agama dan cara menyelamatkan diri darinya.", "Recognizing what harms religion and how to save yourself from it.", "معرفة ما يفسد الدين وكيف ينجو الإنسان منه."),
      [T("Kenapa sesama yang salat saling menyalahkan?", "Why do people who pray together blame each other?", "لماذا يلوم المصلّون بعضهم بعضًا؟"), T("Bagaimana agar tidak terseret fitnah?", "How do I avoid being dragged into fitna?", "كيف لا أنجرّ إلى الفتنة؟")]),
    (T("Isyarat, kabar gembira, peringatan, dan perlindungan", "Signals, glad tidings, warnings, and protection", "الإشارات والبشارات والنذارات والحصانات"), T("Pesan-pesan kasih sayang Nabi untuk umatnya, termasuk pentingnya guru yang bersanad.", "The loving messages of the Prophet to his Ummah, including the importance of a teacher with a chain of learning.", "رسائل الرحمة من النبي ﷺ لأمته، ومنها أهمية المعلم المسنَد."),
      [T("Apa yang melindungi iman kita sekarang?", "What protects our faith now?", "ما الذي يحمي إيماننا اليوم؟"), T("Adakah kabar gembira bagi umat ini?", "Are there glad tidings for this Ummah?", "هل من بشائر لهذه الأمة؟")]),
    (T("Sains, teknologi, dan budaya baru", "Science, technology, and new cultures", "العلوم والتقنية والثقافات الجديدة"), T("Cara menimbang penemuan dan tren baru dengan timbangan agama.", "How to weigh new discoveries and trends by the scale of religion.", "كيف نزن المكتشفات والاتجاهات الجديدة بميزان الدين."),
      [T("Bagaimana sikap kita pada AI?", "What is our stance on AI?", "ما موقفنا من الذكاء الاصطناعي؟"), T("Apa itu mukjizat ilmiah dan di mana batasnya?", "What is scientific miracle and where is its limit?", "ما الإعجاز العلمي وأين حدّه؟")]),
    (T("Tanda alam dan peristiwa besar", "Natural signs and great events", "الأشراط الكونية والأحداث الكبرى"), T("Tanda kecil, tengah, dan besar menjelang kiamat, dipahami tertib tanpa spekulasi.", "The minor, middle, and major signs before the Hour, understood in order and without speculation.", "الأشراط الصغرى والوسطى والكبرى قبل الساعة، تُفهم بترتيب ودون تخمين."),
      [T("Apa beda tanda kecil, tengah, dan besar?", "What is the difference between minor, middle, and major signs?", "ما الفرق بين الأشراط الصغرى والوسطى والكبرى؟"), T("Bagaimana menyikapi bencana?", "How should we respond to disasters?", "كيف نتعامل مع الكوارث؟")]),
    (T("Agama dan sejarah", "Religion and history", "الدين والتاريخ"), T("Membaca perjalanan umat dari masa Nabi sampai hari ini dengan kacamata wahyu.", "Reading the journey of the Ummah from the Prophet's time to today through the lens of revelation.", "قراءة مسيرة الأمة من عهد النبي ﷺ إلى اليوم بعين الوحي."),
      [T("Bagaimana perjalanan zaman umat ini?", "How has the Ummah's journey unfolded?", "كيف كانت مسيرة هذه الأمة؟"), T("Kenapa umat disebut seperti buih?", "Why is the Ummah likened to foam?", "لماذا شُبّهت الأمة بالغثاء؟")]),
  ],
},

# 5. Beda
"diff": {
  "kicker": T("Apa bedanya", "How it differs", "ما الفرق"),
  "title": T("Apakah sama dengan ilmu akhir zaman yang beredar?", "Is it the same as the end-times talk that circulates?", "هل هو نفسه حديث آخر الزمان المتداول؟"),
  "lead": T("Keduanya sama-sama membahas hadis tentang tanda kiamat, tetapi cara pandang dan tujuannya berbeda. Berikut perbandingannya.", "Both discuss hadith about the signs of the Hour, but their approach and aim differ. Here is the comparison.", "كلاهما يتناول أحاديث أشراط الساعة، لكن المنهج والغاية مختلفان. وهذه المقارنة."),
  "cols": (T("Pembahasan akhir zaman yang sering beredar", "End-times talk that often circulates", "حديث آخر الزمان الذي يكثر تداوله"), T("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات")),
  "rows": [
    (T("Tujuan", "Aim", "الغاية"), T("Menebak dan mencocokkan peristiwa", "Guessing and matching events", "التخمين ومطابقة الأحداث"), T("Membekali sikap yang selamat", "Equipping a safe stance", "تزويد الإنسان بالموقف الأسلم")),
    (T("Soal tahun", "Dates", "السنوات"), T("Sering mematok tahun", "Often fixes years", "كثيرًا ما تُحدَّد سنوات"), T("Melarang menebak tahun", "Forbids guessing years", "يمنع تخمين السنوات")),
    (T("Soal tokoh", "Figures", "الأشخاص"), T("Sering menunjuk orang atau kelompok", "Often points at people or groups", "كثيرًا ما يُشار إلى أشخاص وجماعات"), T("Melarang menunjuk orang atau kelompok", "Forbids pointing at people or groups", "يمنع الإشارة إلى أشخاص أو جماعات")),
    (T("Nada", "Tone", "النبرة"), T("Menakut-nakuti, memancing marah", "Frightening, stirring anger", "تخويف وإثارة غضب"), T("Tenang, memberi harapan dan langkah amal", "Calm, giving hope and steps to act", "هادئة، تمنح الرجاء وخطوات العمل")),
    (T("Sumber", "Sources", "المصادر"), T("Bercampur, sering tanpa diperiksa", "Mixed, often unchecked", "مختلطة وكثيرًا ما لا تُفحص"), T("Al-Qur'an dan hadis sahih, dibaca bersama kitab para ulama", "The Qur'an and authentic hadith, read with the books of scholars", "القرآن والحديث الصحيح، يُقرآن مع كتب العلماء")),
    (T("Akibat pada pendengar", "Effect on the listener", "الأثر في السامع"), T("Cemas dan saling curiga", "Anxiety and mutual suspicion", "قلق وارتياب متبادل"), T("Hati tenang dan amal nyata", "A calm heart and real deeds", "قلب مطمئن وعمل ملموس")),
  ],
  "unique_title": T("Yang khas dari Fikih Tahawwulat", "What is distinctive about it", "ما يميّز فقه التحولات"),
  "unique": [
    T("Ia bagian dari agama itu sendiri: rukun keempat dalam Hadis Jibril.", "It is part of religion itself: the fourth pillar in the Hadith of Jibril.", "هو جزء من الدين نفسه: الركن الرابع في حديث جبريل."),
    T("Ia bukan sekadar daftar tanda, tetapi fikih sikap: apa yang dilakukan seorang muslim, keluarga, dan ulama di tiap tahap.", "It is not just a list of signs but a fiqh of stances: what a Muslim, a family, and scholars should do at each stage.", "ليس مجرد قائمة علامات، بل فقه مواقف: ماذا يفعل المسلم والأسرة والعلماء في كل مرحلة."),
    T("Ia tersusun sebagai ilmu, dengan lima cabang dan kaidah yang bisa dipelajari bertahap.", "It is organized as a science, with five branches and rules that can be studied step by step.", "هو منظَّم علمًا، بخمسة فروع وقواعد تُدرس بالتدرج."),
    T("Ia berujung pada jalan selamat: hati, lisan, dan tangan terjaga.", "It ends in the safe way: heart, tongue, and hands guarded.", "ينتهي إلى منهج السلامة: سلامة القلب واللسان واليد."),
    T("Ia berbeda dari ramalan dan teori konspirasi: ramalan menebak nasib, teori konspirasi membuat musuh terasa maha kuasa, sedangkan ia mengajak memperbaiki diri lebih dulu.", "It differs from fortune-telling and conspiracy theories: fortune-telling guesses fate, conspiracy theories make the enemy seem all-powerful, while it invites you to mend yourself first.", "يختلف عن التنجيم ونظريات المؤامرة: فالتنجيم تخمين للمصير، والمؤامرة تجعل العدو قادرًا على كل شيء، أما هو فيدعو إلى إصلاح النفس أولًا."),
  ],
},

# 6. Mulai
"start": {
  "kicker": T("Mulai dari mana", "Where to start", "من أين أبدأ"),
  "title": T("Tiga langkah pertama.", "Your first three steps.", "خطواتك الثلاث الأولى."),
  "steps": [
    (T("Tonton video pengantarnya", "Watch the introduction", "شاهد الفيديو التمهيدي"), T("Sekitar dua belas menit, lima belas bab, tersedia di aplikasi.", "About twelve minutes, fifteen chapters, available in the app.", "نحو اثنتي عشرة دقيقة وخمسة عشر بابًا، متاح في التطبيق.")),
    (T("Tanyakan yang paling mengganjal", "Ask what troubles you most", "اسأل عما يشغلك أكثر"), T("Pilih satu pertanyaan dari daftar di atas dan tanyakan kepada Al-Bayan, yang menjelaskan dengan bahasa sederhana.", "Pick one question from the list above and ask Al-Bayan, who explains in simple language.", "اختر سؤالًا من القائمة أعلاه واسأل «البيان» الذي يشرح بلغة مبسّطة.")),
    (T("Periksa dan tanyakan kepada guru", "Check it and ask a teacher", "تحقّق واسأل معلمك"), T("Buka ibarah yang dikutip dan, untuk urusan amal, tanyakan kepada guru yang Anda percaya.", "Open the quoted passage and, for matters of practice, ask a teacher you trust.", "افتح العبارة المنقولة، وفي مسائل العمل اسأل معلمًا تثق به.")),
  ],
  "cta": T("Tanya OpenTurath AI", "Ask OpenTurath AI", "اسأل OpenTurath AI"),
  "cta2": T("Tentang ilmunya", "About the knowledge", "عن هذا العلم"),
},
}
