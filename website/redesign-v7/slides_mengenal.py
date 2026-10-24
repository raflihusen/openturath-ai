"""Slide "Mengenal Fikih Tahawwulat" untuk aplikasi (ID/EN/AR). Hasilnya: openturath_ai/assets/data/slides_mengenal.json."""
import json
from pathlib import Path

def T(i, e, a): return {"id": i, "en": e, "ar": a}
def S(type, **k): return {"type": type, **k}

BAB = [
  T("Pembuka", "Opening", "تمهيد"),
  T("Hadis Jibril", "The Hadith of Jibril", "حديث جبريل"),
  T("Kesatuan agama", "One religion, one whole", "وحدة الدين"),
  T("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"),
  T("Lima asisten", "Five assistants", "المساعدون الخمسة"),
]

SL = []
A = SL.append

# ───────────── Bab 0: Pembuka
A(S("title", bab=0, kicker=T("Mengenal", "Getting to know", "التعرّف على"), title=T("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"),
    sub=T("Ilmu untuk memahami zaman yang terus berubah.", "A knowledge for understanding a changing age.", "علم لفهم زمان يتغيّر."),
    hint=T("Geser atau ketuk untuk melanjutkan.", "Swipe or tap to continue.", "اسحب أو انقر للمتابعة.")))
A(S("lines", bab=0, lines=[T("Pernahkah Anda bertanya-tanya,", "Have you ever wondered,", "هل تساءلتَ يومًا،"),
    T("kenapa dunia terasa makin kacau?", "why the world feels more chaotic?", "لماذا يبدو العالم أكثر اضطرابًا؟"),
    T("Apakah semua ini sudah dikabarkan Nabi ﷺ?", "Did the Prophet ﷺ already tell us of all this?", "وهل أخبر النبي ﷺ بهذا كله؟"),
    T("Lalu, apa yang harus saya lakukan?", "And then, what should I do?", "وماذا عليّ أن أفعل؟")]))
A(S("text", bab=0, title=T("Jawabannya ada.", "The answer is there.", "الجواب موجود."),
    lines=[T("Dan ia berawal dari satu peristiwa di Madinah, ketika seorang asing datang menemui Rasulullah ﷺ.", "And it begins with one event in Madinah, when a stranger came to the Messenger ﷺ.", "وبدايته حادثة واحدة في المدينة، حين جاء غريب إلى رسول الله ﷺ.")]))

# ───────────── Bab 1: Hadis Jibril
A(S("title", bab=1, kicker=T("Bab 1", "Chapter 1", "الباب 1"), title=T("Hadis Jibril", "The Hadith of Jibril", "حديث جبريل"),
    sub=T("Satu hadis yang memuat seluruh agama.", "One hadith that holds the whole religion.", "حديث واحد يجمع الدين كله.")))
A(S("text", bab=1, kicker=T("Suatu hari", "One day", "ذات يوم"), title=T("Seorang asing datang.", "A stranger arrives.", "جاء رجل غريب."),
    lines=[T("Para sahabat sedang duduk bersama Rasulullah ﷺ. Tiba-tiba datang seorang laki-laki.", "The Companions were sitting with the Messenger ﷺ. Suddenly a man came.", "كان الصحابة جلوسًا مع رسول الله ﷺ، فإذا برجل يُقبل."),
           T("Pakaiannya sangat putih. Rambutnya sangat hitam. Tak tampak bekas perjalanan, dan tak seorang pun mengenalnya.", "His clothes were very white. His hair was very black. No sign of travel, and no one knew him.", "شديد بياض الثياب، شديد سواد الشعر، لا يظهر عليه أثر السفر، ولا يعرفه أحد.")]))
A(S("text", bab=1, title=T("Ia duduk di hadapan Nabi ﷺ.", "He sat before the Prophet ﷺ.", "جلس بين يدي النبي ﷺ."),
    lines=[T("Lututnya menyentuh lutut beliau, kedua tangannya di atas paha. Lalu ia mulai bertanya.", "His knees touched the Prophet's knees, his hands on his thighs. Then he began to ask.", "ألصق ركبتيه بركبتيه ووضع كفيه على فخذيه، ثم بدأ يسأل.")],
    note=T("Diriwayatkan Imam Muslim dari Umar bin Khattab, dan Imam Bukhari dari Abu Hurairah.", "Reported by Imam Muslim from 'Umar ibn al-Khattab, and by Imam al-Bukhari from Abu Hurayrah.", "رواه مسلم عن عمر بن الخطاب، والبخاري عن أبي هريرة.")))
A(S("dialog", bab=1, kicker=T("Pertanyaan pertama", "First question", "السؤال الأول"), asker=T("“Kabarkan kepadaku tentang Islam.”", "“Tell me about Islam.”", "«أخبرني عن الإسلام.»"),
    answer=T("Islam: bersaksi tiada tuhan selain Allah dan Muhammad utusan-Nya, mendirikan salat, menunaikan zakat, berpuasa Ramadan, dan berhaji bila mampu.", "Islam: to bear witness that there is no god but Allah and Muhammad is His messenger, to establish prayer, pay zakat, fast Ramadan, and perform hajj if able.", "الإسلام: أن تشهد أن لا إله إلا الله وأن محمدًا رسول الله، وتقيم الصلاة، وتؤتي الزكاة، وتصوم رمضان، وتحج البيت إن استطعت إليه سبيلًا."),
    note=T("Orang itu berkata, “Engkau benar.” Para sahabat heran: ia bertanya, lalu membenarkan.", "The man said, “You have spoken truly.” The Companions were amazed: he asks, then confirms.", "قال: «صدقت». فعجبوا: يسأله ويصدّقه.")))
A(S("dialog", bab=1, kicker=T("Pertanyaan kedua", "Second question", "السؤال الثاني"), asker=T("“Kabarkan kepadaku tentang Iman.”", "“Tell me about Iman.”", "«أخبرني عن الإيمان.»"),
    answer=T("Iman: engkau percaya kepada Allah, malaikat-Nya, kitab-kitab-Nya, rasul-rasul-Nya, hari akhir, dan takdir yang baik maupun yang buruk.", "Iman: that you believe in Allah, His angels, His books, His messengers, the Last Day, and in divine decree, its good and its bad.", "الإيمان: أن تؤمن بالله وملائكته وكتبه ورسله واليوم الآخر، وتؤمن بالقدر خيره وشره.")))
A(S("dialog", bab=1, kicker=T("Pertanyaan ketiga", "Third question", "السؤال الثالث"), asker=T("“Kabarkan kepadaku tentang Ihsan.”", "“Tell me about Ihsan.”", "«أخبرني عن الإحسان.»"),
    answer=T("Ihsan: engkau beribadah kepada Allah seakan-akan melihat-Nya. Bila engkau tidak melihat-Nya, sesungguhnya Dia melihatmu.", "Ihsan: that you worship Allah as if you see Him; and if you do not see Him, He sees you.", "الإحسان: أن تعبد الله كأنك تراه، فإن لم تكن تراه فإنه يراك.")))
A(S("cards", bab=1, title=T("Tiga pertanyaan, tiga jawaban.", "Three questions, three answers.", "ثلاثة أسئلة وثلاثة أجوبة."),
    items=[{"t": T("Islam", "Islam", "الإسلام"), "d": T("Amal anggota tubuh", "The deeds of the limbs", "عمل الجوارح")},
           {"t": T("Iman", "Iman", "الإيمان"), "d": T("Keyakinan akal dan hati", "The conviction of mind and heart", "اعتقاد العقل والقلب")},
           {"t": T("Ihsan", "Ihsan", "الإحسان"), "d": T("Kesadaran dan kebersihan jiwa", "Awareness and purity of soul", "حضور القلب وصفاء النفس")}]))
A(S("question", bab=1, q=T("Apakah hadisnya berhenti di sini?", "Does the hadith stop here?", "هل ينتهي الحديث هنا؟"), hint=T("Pikirkan sejenak, lalu lanjut.", "Think for a moment, then continue.", "تأمّل لحظة ثم تابع.")))
A(S("text", bab=1, title=T("Belum.", "Not yet.", "لا بعد."), lines=[T("Orang asing itu masih punya satu pertanyaan lagi.", "The stranger still had one more question.", "كان لدى الغريب سؤال آخر.")]))
A(S("dialog", bab=1, kicker=T("Pertanyaan keempat", "Fourth question", "السؤال الرابع"), asker=T("“Kabarkan kepadaku tentang hari kiamat.”", "“Tell me about the Hour.”", "«أخبرني عن الساعة.»"),
    answer=T("“Yang ditanya tidak lebih tahu daripada yang bertanya.”", "“The one asked knows no more than the one asking.”", "«ما المسؤول عنها بأعلم من السائل.»"),
    note=T("Waktunya rahasia Allah. Nabi menutup pintu tebak-tebakan.", "Its time is God's secret. The Prophet closes the door on guessing.", "وقتها سرّ الله. فأغلق النبي ﷺ باب التخمين.")))
A(S("dialog", bab=1, kicker=T("Pertanyaan keempat, lanjutan", "Fourth question, continued", "تتمة السؤال الرابع"), asker=T("“Kalau begitu, kabarkan kepadaku tanda-tandanya.”", "“Then tell me its signs.”", "«فأخبرني عن أماراتها.»"),
    answer=T("“Budak perempuan melahirkan tuannya, dan engkau melihat orang-orang yang dahulu bertelanjang kaki, miskin, dan menggembala kambing, berlomba meninggikan bangunan.”", "“That the slave woman gives birth to her mistress, and that you see the barefoot, scantily clad, poor shepherds competing in raising tall buildings.”", "«أن تلد الأمة ربّتها، وأن ترى الحفاة العراة العالة رعاء الشاء يتطاولون في البنيان.»"),
    note=T("Untuk tanda-tanda, Nabi ﷺ menjawab dengan jelas.", "On the signs, the Prophet ﷺ answered clearly.", "أما العلامات فأجاب عنها النبي ﷺ بوضوح.")))
A(S("question", bab=1, q=T("Bila bagian keempat bukan bagian dari agama, mengapa Nabi ﷺ menjawabnya?", "If the fourth part is not part of religion, why did the Prophet ﷺ answer it?", "إن لم يكن الجزء الرابع من الدين، فلماذا أجاب عنه النبي ﷺ؟")))
A(S("text", bab=1, title=T("Orang itu pun pergi.", "Then the man left.", "ثم انصرف الرجل."),
    lines=[T("Umar menunggu beberapa saat. Lalu Nabi ﷺ bertanya, “Wahai Umar, tahukah engkau siapa yang bertanya tadi?”", "'Umar waited a while. Then the Prophet ﷺ asked, “O 'Umar, do you know who the questioner was?”", "مكث عمر مليًّا، ثم قال له النبي ﷺ: «يا عمر، أتدري من السائل؟»"),
           T("“Allah dan Rasul-Nya lebih tahu,” jawab Umar.", "“Allah and His Messenger know best,” said 'Umar.", "قال: «الله ورسوله أعلم».")]))
A(S("question", bab=1, q=T("Apa kata Nabi ﷺ tentang seluruh pertanyaan tadi?", "What did the Prophet ﷺ say about all those questions?", "ماذا قال النبي ﷺ عن تلك الأسئلة كلها؟")))
A(S("quote", bab=1, arabic="هَذَا جِبْرِيلُ أَتَاكُمْ يُعَلِّمُكُمْ دِينَكُمْ",
    translation=T("“Itu Jibril. Ia datang kepada kalian untuk mengajarkan agama kalian.”", "“That was Jibril. He came to you to teach you your religion.”", "«هذا جبريل أتاكم يعلّمكم دينكم.»"),
    source=T("HR. Muslim", "Reported by Muslim", "رواه مسلم")))
A(S("question", bab=1, q=T("Apakah Nabi ﷺ berkata bahwa bagian keempat itu bukan bagian dari agama?", "Did the Prophet ﷺ say that the fourth part is not part of religion?", "هل قال النبي ﷺ إن الجزء الرابع ليس من الدين؟")))
A(S("cards", bab=1, title=T("Tidak. Beliau menyebut semuanya: “agama kalian”.", "No. He called all of it “your religion”.", "لا. بل سمّاها كلها «دينكم»."),
    items=[{"t": T("Islam", "Islam", "الإسلام")}, {"t": T("Iman", "Iman", "الإيمان")}, {"t": T("Ihsan", "Ihsan", "الإحسان")}, {"t": T("Tanda-tanda zaman", "Signs of the times", "علامات الساعة"), "hl": True}],
    note=T("Empat pertanyaan. Satu pelajaran. Satu sebutan dari Nabi ﷺ: agama kalian.", "Four questions. One lesson. One name from the Prophet ﷺ: your religion.", "أربعة أسئلة، ودرس واحد، وتسمية واحدة من النبي ﷺ: دينكم.")))

# ───────────── Bab 2: kesatuan
A(S("title", bab=2, kicker=T("Bab 2", "Chapter 2", "الباب 2"), title=T("Satu hadis, satu kesatuan.", "One hadith, one whole.", "حديث واحد، ووحدة واحدة."),
    sub=T("Mengapa empat pertanyaan itu tidak bisa dipisah-pisah.", "Why the four questions cannot be separated.", "لماذا لا يمكن فصل الأسئلة الأربعة؟")))
A(S("text", bab=2, title=T("“Ibu dari sunnah.”", "“The mother of the Sunnah.”", "«أمّ السنّة»."),
    lines=[T("Para ulama menyebut Hadis Jibril Ummus Sunnah, karena seluruh pokok agama terangkum dalam dialog singkat ini.", "Scholars call the Hadith of Jibril Umm as-Sunnah, because the whole core of religion is gathered in this short dialogue.", "يسمّي العلماء حديث جبريل «أمّ السنة» لأن أصول الدين كلها مجموعة في هذا الحوار الموجز.")]))
A(S("list", bab=2, title=T("Mengapa ia satu kesatuan?", "Why is it one whole?", "لماذا هو وحدة واحدة؟"),
    items=[{"t": T("Satu majelis", "One gathering", "مجلس واحد"), "d": T("Empat pertanyaan diajukan berurutan dalam satu pertemuan.", "Four questions asked one after another in a single meeting.", "أربعة أسئلة متتابعة في لقاء واحد.")},
           {"t": T("Satu guru", "One teacher", "معلّم واحد"), "d": T("Penanyanya Jibril, malaikat pembawa wahyu, yang datang untuk mengajar.", "The questioner is Jibril, the angel of revelation, who came to teach.", "السائل جبريل، ملَك الوحي، جاء ليعلّم.")},
           {"t": T("Satu penutup", "One conclusion", "خاتمة واحدة"), "d": T("Nabi ﷺ menyimpulkan semuanya sekaligus: “agama kalian”.", "The Prophet ﷺ sums it all up at once: “your religion”.", "ختمها النبي ﷺ بجملة واحدة: «دينكم».")}]))
A(S("question", bab=2, q=T("Bayangkan seorang guru menyerahkan buku berisi empat bab dan berkata, “Ini pelajaran kalian.” Bolehkah murid berkata, “Bab keempat bukan pelajaran”?", "Imagine a teacher hands over a book of four chapters and says, “This is your lesson.” May a student say, “The fourth chapter is not part of the lesson”?", "تخيّل معلّمًا سلّم كتابًا من أربعة أبواب وقال: «هذا درسكم». هل يجوز للطالب أن يقول: «الباب الرابع ليس من الدرس»؟")))
A(S("list", bab=2, title=T("Empat bukti bahwa bagian keempat adalah agama", "Four proofs that the fourth part is religion", "أربعة أدلة على أن الجزء الرابع من الدين"),
    items=[{"t": T("1. Disebut “agama kalian”", "1. Called “your religion”", "1. سُمّي «دينكم»"), "d": T("Nabi ﷺ menyebut seluruh isi dialog, termasuk bagian keempat.", "The Prophet ﷺ named the whole dialogue, the fourth part included.", "سمّى النبي ﷺ الحوار كله ومنه الجزء الرابع.")},
           {"t": T("2. Dijawab, tidak ditolak", "2. Answered, not refused", "2. أُجيب ولم يُرفض"), "d": T("Waktu kiamat dirahasiakan, tetapi tanda-tandanya dijelaskan.", "The time of the Hour is kept secret, but its signs are explained.", "وقت الساعة مكتوم، أما علاماتها فمبيَّنة.")},
           {"t": T("3. Ditanyakan oleh Jibril", "3. Asked by Jibril", "3. سأل عنه جبريل"), "d": T("Malaikat pembawa wahyu datang khusus untuk mengajarkannya.", "The angel of revelation came especially to teach it.", "ملَك الوحي جاء ليعلّمه.")},
           {"t": T("4. Hadis yang merangkum agama", "4. A hadith that sums up religion", "4. حديث يجمع الدين"), "d": T("Bila satu bagian dibuang, “agama kalian” tidak lagi utuh.", "Remove one part and “your religion” is no longer whole.", "إن أُسقط جزء لم يبقَ «دينكم» كاملًا.")}]))
A(S("cards", bab=2, title=T("Setiap pertanyaan melahirkan satu ilmu.", "Each question gave birth to a science.", "كل سؤال أنشأ علمًا."),
    items=[{"t": T("Islam", "Islam", "الإسلام"), "d": T("melahirkan Fikih", "gave rise to Fiqh", "أنشأ الفقه")},
           {"t": T("Iman", "Iman", "الإيمان"), "d": T("melahirkan Akidah dan Tauhid", "gave rise to Creed and Tawhid", "أنشأ العقيدة والتوحيد")},
           {"t": T("Ihsan", "Ihsan", "الإحسان"), "d": T("melahirkan Tasawuf dan Akhlak", "gave rise to Tasawwuf and Ethics", "أنشأ التصوف والأخلاق")},
           {"t": T("Tanda-tanda zaman", "Signs of the times", "علامات الساعة"), "d": T("melahirkan Fikih Tahawwulat", "gave rise to Fiqh al-Tahawwulat", "أنشأ فقه التحولات"), "hl": True}]))
A(S("question", bab=2, q=T("Tiga ilmu pertama sudah kita kenal sejak lama. Mengapa yang keempat terasa asing?", "We have known the first three sciences for a long time. Why does the fourth feel unfamiliar?", "العلوم الثلاثة الأولى معروفة منذ زمن. فلماذا يبدو الرابع غريبًا؟")))
A(S("text", bab=2, title=T("Karena ia “disimpan”.", "Because it was “stored away”.", "لأنه كان «مدّخرًا»."),
    lines=[T("Dahulu bagian keempat tersimpan di bab-bab hadis tentang fitnah dan peristiwa besar. Ketika tanda-tandanya mulai tampak, Al-Habib Abu Bakar Al-Masyhur menatanya menjadi satu ilmu yang bisa dipelajari: Fikih Tahawwulat.", "The fourth part was kept in the hadith chapters on trials and great events. When its signs began to appear, Al-Habib Abu Bakar Al-Masyhur arranged it into one science that can be studied: Fiqh al-Tahawwulat.", "كان الجزء الرابع محفوظًا في أبواب الفتن والملاحم من كتب الحديث. فلما بدت علاماته رتّبه الحبيب أبو بكر المشهور علمًا يُدرَس: فقه التحولات.")]))
A(S("text", bab=2, title=T("Apakah rukun Islam dan Iman berubah?", "Do the pillars of Islam and Iman change?", "هل تتغيّر أركان الإسلام والإيمان؟"),
    lines=[T("Tidak. Rukun Islam tetap lima. Rukun Iman tetap enam.", "No. The pillars of Islam stay five. The pillars of Iman stay six.", "لا. أركان الإسلام خمسة، وأركان الإيمان ستة."),
           T("“Empat rukun agama” hanyalah cara mengelompokkan empat pertanyaan Jibril.", "“The four pillars of religion” is only a way to group Jibril's four questions.", "و«أركان الدين الأربعة» مجرد تصنيف لأسئلة جبريل الأربعة.")]))
A(S("question", bab=2, q=T("Bukankah kiamat hanya Allah yang tahu? Lalu mengapa kita membahas tandanya?", "Isn't it only Allah who knows the Hour? Then why discuss its signs?", "أليس الله وحده يعلم الساعة؟ فلماذا نبحث في علاماتها؟")))
A(S("compare", bab=2, cols=(T("Waktu kiamat", "The time of the Hour", "وقت الساعة"), T("Tanda-tandanya", "Its signs", "علاماتها")),
    rows=[(T("Siapa yang tahu", "Who knows", "من يعلم"), T("Hanya Allah", "Only Allah", "الله وحده"), T("Diajarkan Nabi ﷺ", "Taught by the Prophet ﷺ", "علّمها النبي ﷺ")),
          (T("Sikap kita", "Our stance", "موقفنا"), T("Dilarang menebak", "No guessing", "لا تخمين"), T("Dipelajari agar iman selamat", "Studied so faith stays safe", "تُدرس ليسلم الإيمان"))]))
A(S("text", bab=2, title=T("Pagar dan radar.", "A fence and a radar.", "سياج ورادار."),
    lines=[T("Fungsi rukun keempat: menjaga tiga rukun lainnya agar tidak rusak, dipalsukan, atau ditinggalkan ketika zaman berguncang.", "The fourth pillar's role: to guard the other three so they are not spoiled, falsified, or abandoned when the age shakes.", "وظيفة الركن الرابع: حفظ الثلاثة الأخرى كي لا تفسد أو تُزوَّر أو تُترك حين يضطرب الزمان.")]))
A(S("list", bab=2, title=T("Dua tugasnya", "Its two tasks", "مهمتاه"),
    items=[{"t": T("Memperbarui cara dakwah", "Renewing the way of calling", "تجديد وسائل الدعوة"), "d": T("Dengan hikmah dan nasihat yang baik, menjaga lisan dari mencela dan tangan dari menumpahkan darah.", "With wisdom and good counsel, guarding the tongue from reviling and the hand from bloodshed.", "بالحكمة والموعظة الحسنة، مع حفظ اللسان من الذم واليد من الدم.")},
           {"t": T("Menjaga ilmu yang tetap", "Guarding the constant sciences", "صيانة علوم الثوابت"), "d": T("Dari tiga perusak: sikap berlebihan, kepalsuan, dan tafsir orang yang tidak berilmu.", "From three corruptors: excess, falsehood, and interpretation by the unlearned.", "من ثلاثة مفسدات: الغلو، والانتحال، وتأويل الجاهلين.")}]))
A(S("compare", bab=2, title=T("Dua tanda, dua kendali", "Two signs, two controls", "علامتان وقراران"), cols=(T("Tanda dalam hadis", "The sign", "العلامة"), T("Yang bergeser", "What shifts", "ما يتحوّل")),
    rows=[(T("Budak perempuan melahirkan tuannya", "The slave woman gives birth to her mistress", "أن تلد الأمة ربّتها"), T("Kendali ilmu dan keyakinan", "Control of knowledge and belief", "قرار العلم والاعتقاد"), T("Urusan ilmu dipegang yang belum berhak", "Knowledge handed to those unfit", "يُسند أمر العلم لغير أهله")),
          (T("Berlomba meninggikan bangunan", "Competing to raise tall buildings", "التطاول في البنيان"), T("Kendali kekuasaan dan harta", "Control of power and wealth", "قرار الحكم والاقتصاد"), T("Kekuasaan dan harta dipegang yang belum berhak", "Power and wealth handed to those unfit", "يُسند الحكم والمال لغير أهله"))]))

# ───────────── Bab 3: Fikih Tahawwulat
A(S("title", bab=3, kicker=T("Bab 3", "Chapter 3", "الباب 3"), title=T("Apa itu Fikih Tahawwulat?", "What is Fiqh al-Tahawwulat?", "ما هو فقه التحولات؟"), sub=T("Dengan kata paling sederhana.", "In the simplest words.", "بأبسط عبارة.")))
A(S("lines", bab=3, lines=[T("Fikih: pemahaman yang dalam.", "Fiqh: deep understanding.", "الفقه: الفهم العميق."), T("Tahawwulat: perubahan-perubahan.", "Tahawwulat: the changes.", "التحولات: التغيّرات."),
    T("Fikih Tahawwulat: ilmu memahami perubahan zaman dengan petunjuk Al-Qur'an dan hadis, supaya kita tahu sikap yang paling selamat.", "Fiqh al-Tahawwulat: the knowledge of understanding the changes of the age by the guidance of the Qur'an and hadith, so we know the safest stance.", "فقه التحولات: علم فهم تغيّرات الزمان بهدي القرآن والحديث، لنعرف الموقف الأسلم.")]))
A(S("compare", bab=3, cols=(T("Fikih yang biasa menjawab", "Ordinary fiqh answers", "الفقه المعتاد يجيب"), T("Fikih Tahawwulat menjawab", "Fiqh al-Tahawwulat answers", "فقه التحولات يجيب")),
    rows=[(T("Pertanyaan", "The question", "السؤال"), T("“Bagaimana salat dan zakat saya sah?”", "“How are my prayer and zakat valid?”", "«كيف تصحّ صلاتي وزكاتي؟»"), T("“Bagaimana saya menjaga agama ketika zaman berubah dan penuh ujian?”", "“How do I protect my faith when the age changes and is full of trials?”", "«كيف أحفظ ديني حين يتغيّر الزمان وتكثر الابتلاءات؟»"))]))
A(S("lines", bab=3, kicker=T("Pertanyaan yang kini sulit dijawab", "Questions that are hard to answer today", "أسئلة يصعب أن نجد لها جوابًا اليوم"),
    lines=[T("Saya capek dengan berita buruk. Haruskah saya terus mengikutinya?", "I am tired of bad news. Must I keep following it?", "تعبتُ من الأخبار السيئة. هل يلزمني متابعتها؟"),
           T("Kenapa iman saya naik turun dan susah istikamah?", "Why does my faith rise and fall?", "لماذا يعلو إيماني ويهبط؟"),
           T("Bagaimana membedakan ustaz yang tepercaya dari yang bukan?", "How do I tell a trustworthy teacher from one who is not?", "كيف أميّز المعلم الموثوق من غيره؟"),
           T("Apa yang harus saya lakukan dengan hoaks agama di grup keluarga?", "What should I do with religious hoaxes in the family group chat?", "ماذا أفعل بالأخبار الدينية المكذوبة في مجموعة الأسرة؟")]))
A(S("lines", bab=3, kicker=T("Pertanyaan yang kini sulit dijawab", "Questions that are hard to answer today", "أسئلة يصعب أن نجد لها جوابًا اليوم"),
    lines=[T("Bagaimana menjaga iman anak di zaman layar?", "How do I protect my child's faith in the age of screens?", "كيف أحفظ إيمان ابني في زمن الشاشات؟"),
           T("Kenapa umat Islam banyak, tetapi terasa lemah?", "Why are Muslims many, yet feel weak?", "لماذا المسلمون كثيرون ومع ذلك يشعرون بالضعف؟"),
           T("Bagaimana agama menyikapi AI, internet, dan budaya baru?", "How does religion treat AI, the internet, and new cultures?", "كيف يتعامل الدين مع الذكاء الاصطناعي والإنترنت والثقافات الجديدة؟"),
           T("Bolehkah menebak tahun kiamat? Apakah tokoh tertentu itu tanda kiamat?", "May we guess the year of the Hour? Is a certain figure a sign of it?", "هل يجوز تخمين سنة الساعة؟ وهل شخص معيّن من أشراطها؟")],
    note=T("Pertanyaan-pertanyaan ini sengaja tidak dijawab di sini. Jawabannya ada di kitab, dan bisa Anda tanyakan di OpenTurath AI.", "These questions are left unanswered here on purpose. The answers are in the books, and you can ask OpenTurath AI.", "تُركت هذه الأسئلة دون جواب هنا عمدًا. فأجوبتها في الكتب، ويمكنك أن تسأل OpenTurath AI.")))
A(S("cards", bab=3, title=T("Faedahnya dalam hidup sehari-hari", "What it gives you day to day", "فوائده في الحياة اليومية"),
    items=[{"t": T("Hati lebih tenang", "A calmer heart", "قلب أهدأ"), "d": T("Tahu gambaran besar zaman, dan tahu kapan cukup mengikuti berita.", "You know the big picture, and when it is enough to follow the news.", "تعرف الصورة العامة ومتى يكفي أن تتابع الأخبار.")},
           {"t": T("Tidak mudah tertipu", "Not easily fooled", "لا تنخدع بسهولة"), "d": T("Tiga rambu: tidak menebak tahun, tidak menunjuk orang, tidak memaksakan hadis pada politik harian.", "Three signposts: no guessing years, no pointing at people, no forcing hadith onto daily politics.", "ثلاث علامات: لا تخمين للسنوات، ولا إشارة إلى أشخاص، ولا إسقاط الحديث على السياسة اليومية.")},
           {"t": T("Tahu apa yang dikerjakan", "Knowing what to do", "تعرف ما تفعل"), "d": T("Cemas diganti langkah: salat, nafkah halal, lisan terjaga, kebaikan terdekat.", "Worry becomes steps: prayer, lawful income, a guarded tongue, nearby good.", "يتحوّل القلق إلى خطوات: الصلاة، والرزق الحلال، وحفظ اللسان، والخير القريب.")},
           {"t": T("Rumah lebih rukun", "A more peaceful home", "بيت أكثر سكينة"), "d": T("Ikatan keluarga yang pasti lebih utama daripada debat yang belum pasti.", "A sure family bond outranks an uncertain argument.", "رابطة الأسرة أولى من جدال غير مؤكد.")}]))
A(S("cards", bab=3, title=T("Faedahnya, lanjutan", "What it gives you, continued", "فوائده، تتمة"),
    items=[{"t": T("Jeli memilih guru", "Sharp in choosing teachers", "أدق في اختيار المعلم"), "d": T("Sanad jelas, adab baik, tidak jadi alat politik sesaat.", "A clear chain, good manners, not a tool of passing politics.", "سند واضح وأدب حسن، لا أداة لسياسة عابرة.")},
           {"t": T("Bijak bermedia dan berteknologi", "Wise with media and technology", "حكيم مع الإعلام والتقنية"), "d": T("Ambil yang bermanfaat, tolak yang merusak.", "Take what helps, reject what harms.", "خذ النافع وردّ الضار.")},
           {"t": T("Mendidik anak dengan hangat", "Raising children warmly", "تربية الأبناء بدفء"), "d": T("Rumah menjadi benteng kasih sayang dan teladan.", "The home becomes a fortress of love and example.", "يصير البيت حصنًا من المحبة والقدوة.")},
           {"t": T("Menjelaskan tanpa bertengkar", "Explaining without a quarrel", "تشرح دون خصام"), "d": T("Punya bahasa yang sejuk untuk menasihati.", "A gentle language for advising.", "لغة لطيفة للنصح.")}]))
A(S("cards", bab=3, title=T("Lima cabang ilmunya", "Its five branches", "فروعه الخمسة"),
    items=[{"t": T("Fikih Fitnah dan Penjagaan Diri", "Fiqh of Fitna and Self-Protection", "فقه النواقض والنقائض ومضلّات الفتن وسبل الوقاية منها"), "d": T("Mengenali yang merusak agama dan cara selamat darinya.", "Recognizing what harms religion and how to stay safe.", "معرفة ما يفسد الدين وكيف ننجو منه.")},
           {"t": T("Fikih Isyarat, Kabar Gembira, dan Perlindungan", "Fiqh of Signals, Glad Tidings, and Protection", "فقه الإشارات والبشارات والنذارات والحصانات والأسانيد"), "d": T("Pesan kasih sayang Nabi ﷺ, termasuk pentingnya guru bersanad.", "The Prophet's loving messages, including the importance of a teacher with a chain.", "رسائل الرحمة النبوية ومنها أهمية المعلم المسنَد.")},
           {"t": T("Fikih Sains, Teknologi, dan Budaya Baru", "Fiqh of Science, Technology, and New Culture", "فقه مستجدات العلوم والثقافات والتقنيات"), "d": T("Menimbang penemuan dan tren baru dengan timbangan agama.", "Weighing new discoveries and trends by religion's scale.", "وزن المستجدات والاتجاهات بميزان الدين.")},
           {"t": T("Fikih Tanda Alam dan Peristiwa Besar", "Fiqh of Natural Signs and Great Events", "فقه الأشراط الكونية والأحداث الكبرى"), "d": T("Tanda kecil, tengah, dan besar, tanpa spekulasi.", "Minor, middle, and major signs, without speculation.", "الأشراط الصغرى والوسطى والكبرى دون تخمين.")},
           {"t": T("Fikih Menautkan Agama dan Sejarah", "Fiqh of Linking Religion and History", "فقه الربط بين الديانة والتاريخ"), "d": T("Membaca perjalanan umat dengan kacamata wahyu.", "Reading the Ummah's journey through revelation.", "قراءة مسيرة الأمة بعين الوحي.")}]))
A(S("question", bab=3, q=T("Apakah ini sama dengan ilmu akhir zaman yang sering beredar?", "Is this the same as the end-times talk that often circulates?", "هل هو نفسه حديث آخر الزمان المتداول؟")))
A(S("compare", bab=3, cols=(T("Yang sering beredar", "Often circulating", "المتداول كثيرًا"), T("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات")),
    rows=[(T("Tujuan", "Aim", "الغاية"), T("Menebak dan mencocokkan peristiwa", "Guessing and matching events", "التخمين ومطابقة الأحداث"), T("Membekali sikap yang selamat", "Equipping a safe stance", "تزويد الإنسان بالموقف الأسلم")),
          (T("Tahun dan tokoh", "Dates and figures", "السنوات والأشخاص"), T("Sering mematok tahun dan menunjuk orang", "Often fixes years and points at people", "كثيرًا ما تُحدَّد سنوات ويُشار إلى أشخاص"), T("Melarang keduanya", "Forbids both", "يمنع الأمرين")),
          (T("Nada", "Tone", "النبرة"), T("Menakut-nakuti, memancing marah", "Frightening, stirring anger", "تخويف وإثارة غضب"), T("Tenang, penuh harapan dan langkah amal", "Calm, hopeful, with steps to act", "هادئة، فيها رجاء وخطوات عمل")),
          (T("Akibatnya", "The effect", "الأثر"), T("Cemas dan saling curiga", "Anxiety and mutual suspicion", "قلق وارتياب"), T("Hati tenang dan amal nyata", "A calm heart and real deeds", "قلب مطمئن وعمل ملموس"))]))
A(S("list", bab=3, title=T("Yang khas dari Fikih Tahawwulat", "What is distinctive", "ما يميّزه"),
    items=[{"t": T("Bagian dari agama itu sendiri", "Part of religion itself", "جزء من الدين نفسه"), "d": T("Rukun keempat dalam Hadis Jibril.", "The fourth pillar in the Hadith of Jibril.", "الركن الرابع في حديث جبريل.")},
           {"t": T("Fikih sikap, bukan sekadar daftar tanda", "A fiqh of stances, not just a list of signs", "فقه مواقف لا قائمة علامات"), "d": T("Apa yang dilakukan muslim, keluarga, dan ulama di tiap tahap.", "What a Muslim, a family, and scholars do at each stage.", "ماذا يفعل المسلم والأسرة والعلماء في كل مرحلة.")},
           {"t": T("Berbeda dari ramalan dan teori konspirasi", "Unlike fortune-telling and conspiracy theories", "يختلف عن التنجيم ونظريات المؤامرة"), "d": T("Ia mengajak memperbaiki diri lebih dulu, dan berujung pada jalan selamat: hati, lisan, dan tangan terjaga.", "It invites you to mend yourself first, and ends in the safe way: heart, tongue, and hands guarded.", "يدعو إلى إصلاح النفس أولًا، وينتهي إلى منهج السلامة: سلامة القلب واللسان واليد.")}]))

# ───────────── Bab 4: lima asisten
A(S("title", bab=4, kicker=T("Bab 4", "Chapter 4", "الباب 4"), title=T("Lima asisten untuk mempelajarinya", "Five assistants to study it", "خمسة مساعدين لدراسته"),
    sub=T("Kitab dan ceramah yang sama, lima cara belajar.", "The same books and lectures, five ways to learn.", "الكتب والمحاضرات نفسها، وخمس طرق للتعلّم.")))
A(S("assistant", bab=4, ar="المحقق", name="Al-Muhaqqiq", role=T("Peneliti teks", "The text researcher", "باحث النصوص"),
    desc=T("Mencari matan dan ibarah asli beserta sumbernya, lalu memeriksanya dengan teliti.", "Finds the original text and passage with its source, then checks it carefully.", "يبحث عن المتن والعبارة الأصلية مع مصدرها ثم يدققها."),
    ask=T("“Di mana Al-Habib menyebut dua keruntuhan peradaban? Tampilkan ibarahnya.”", "“Where does Al-Habib mention the two collapses of civilization? Show me the passage.”", "«أين يذكر الحبيب الانهيارين الحضاريين؟ أرني العبارة.»")))
A(S("assistant", bab=4, ar="البيان", name="Al-Bayan", role=T("Penjelas yang sederhana", "The simple explainer", "الشارح المبسِّط"),
    desc=T("Menjelaskan dengan bahasa yang mudah dipahami. Cocok untuk pemula, dan tempat terbaik untuk mulai.", "Explains in easy language. Suited to beginners, and the best place to start.", "يشرح بلغة سهلة. مناسب للمبتدئين، وهو أفضل مكان للبداية."),
    ask=T("“Jelaskan al-ghutsa'iyyah dengan bahasa sederhana.”", "“Explain al-ghuthaiyya in simple words.”", "«اشرح الغثائية بعبارة مبسّطة.»"), start=True))
A(S("assistant", bab=4, ar="المختبر", name="Al-Mukhtabir", role=T("Penguji pemahaman", "The understanding tester", "مختبِر الفهم"),
    desc=T("AI bertanya, Anda menjawab, lalu ia menilai di mana jawaban Anda sudah baik, di mana lemah, dan memberi jawaban idealnya.", "The AI asks, you answer, then it judges where your answer is strong and where weak, and gives the ideal answer.", "يسألك الذكاء الاصطناعي فتجيب، ثم يقيّم جوابك: مواطن الإحسان ومواطن الضعف، ويعطيك الجواب المثالي."),
    ask=T("“Uji saya: apa itu al-ghutsa'iyyah?”", "“Test me: what is al-ghuthaiyya?”", "«اختبرني: ما الغثائية؟»")))
A(S("assistant", bab=4, ar="الحبيب", name="Al-Habib", role=T("Ceramah Al-Habib", "Al-Habib's lectures", "محاضرات الحبيب"),
    desc=T("Berisi ceramah Al-Habib Abu Bakar, dan menjawab dengan diksi beliau sendiri.", "Holds the lectures of Al-Habib Abu Bakar, and answers in his own wording.", "فيه محاضرات الحبيب أبي بكر، ويجيب بألفاظه هو."),
    ask=T("“Bagaimana Al-Habib menjelaskan sikap saat masa fitnah?”", "“How does Al-Habib explain conduct in times of trial?”", "«كيف يشرح الحبيب الموقف زمن الفتن؟»")))
A(S("assistant", bab=4, ar="الخطيب", name="Al-Khatib", role=T("Penyusun khutbah", "The sermon writer", "معدّ الخطب"),
    desc=T("Menyusun khutbah, bahan ceramah, dan materi dakwah lainnya.", "Drafts sermons, talk material, and other da'wa content.", "يُعدّ الخطب والمواد الوعظية وسائر المواد الدعوية."),
    ask=T("“Susun kerangka khutbah tentang sikap saat masa fitnah.”", "“Outline a sermon on conduct in times of trial.”", "«ضع هيكل خطبة عن الموقف زمن الفتن.»")))
A(S("end", bab=4, title=T("Mulai dari mana?", "Where to start?", "من أين أبدأ؟"),
    items=[{"t": T("Pilih satu pertanyaan yang paling mengganjal", "Pick the question that troubles you most", "اختر السؤال الذي يشغلك أكثر"), "d": T("Dari daftar tadi.", "From the list you just saw.", "من القائمة التي رأيتها.")},
           {"t": T("Tanyakan kepada Al-Bayan", "Ask Al-Bayan", "اسأل «البيان»"), "d": T("Bahasanya paling sederhana.", "His language is the simplest.", "لغته أبسط ما يكون.")},
           {"t": T("Periksa ibarahnya, tanyakan kepada guru", "Check the passage, ask a teacher", "تحقّق من العبارة واسأل معلمك"), "d": T("Terutama untuk urusan amal.", "Especially for matters of practice.", "خاصة في مسائل العمل.")}],
    cta=T("Mulai bertanya", "Start asking", "ابدأ بالسؤال"), cta2=T("Baca sebagai teks", "Read as text", "اقرأ نصًّا")))

out = {"bab": BAB, "slides": SL}
if __name__ == "__main__":
    p = Path(__file__).resolve().parents[2] / "openturath_ai" / "assets" / "data" / "slides_mengenal.json"
    p.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf8")
    print(len(SL), "slide ->", p)
