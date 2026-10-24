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
  T("Lima cabang ilmu", "Five branches", "الفروع الخمسة"),
  T("Lima asisten", "Five assistants", "المساعدون الخمسة"),
]

SL = []
A = SL.append

# ───────────── Bab 0: Pembuka
A(S("title", bab=0, kicker=T("Mengenal", "Getting to know", "التعرّف على"), title=T("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات"),
    sub=T("Ilmu untuk memahami zaman yang terus berubah.", "A knowledge for understanding a changing age.", "علم لفهم زمان يتغيّر."),
    hint=T("Geser atau tekan tombol panah untuk melanjutkan.", "Swipe or press the arrow button to continue.", "اسحب أو اضغط زر السهم للمتابعة.")))
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
A(S("quote", bab=2, art="arch", arabic="وَالسَّاعَةُ مِنَ الدِّينِ",
    translation=T("“Dan hari kiamat termasuk agama.”", "“And the Hour is part of religion.”", "«علم الساعة من الدين.»"),
    source=T("Isyarat Imam Al-Bukhari dalam judul bab Hadis Jibril (Shahih al-Bukhari no. 50). Beliau menutupnya dengan sabda Nabi ﷺ “agama kalian”: فَجَعَلَ كُلَّ ذَلِكَ دِينًا. Dikutip At-Talid hlm. 25.", "Imam al-Bukhari's hint in his chapter heading on the Hadith of Jibril (Sahih al-Bukhari no. 50). He closes with the Prophet's ﷺ words “your religion”: فَجَعَلَ كُلَّ ذَلِكَ دِينًا. Cited in At-Talid, p. 25.", "إشارة الإمام البخاري في تبويب حديث جبريل (صحيح البخاري رقم 50)، ثم قوله: «فجعل كل ذلك دينًا». أورده «التليد والطارف» ص٢٥.")))
A(S("cards", bab=2, title=T("Setiap pertanyaan melahirkan satu ilmu.", "Each question gave birth to a science.", "كل سؤال أنشأ علمًا."),
    items=[{"t": T("Islam", "Islam", "الإسلام"), "d": T("melahirkan Fikih", "gave rise to Fiqh", "أنشأ الفقه")},
           {"t": T("Iman", "Iman", "الإيمان"), "d": T("melahirkan Akidah dan Tauhid", "gave rise to Creed and Tawhid", "أنشأ العقيدة والتوحيد")},
           {"t": T("Ihsan", "Ihsan", "الإحسان"), "d": T("melahirkan Tasawuf dan Akhlak", "gave rise to Tasawwuf and Ethics", "أنشأ التصوف والأخلاق")},
           {"t": T("Tanda-tanda zaman", "Signs of the times", "علامات الساعة"), "d": T("melahirkan Fikih Tahawwulat", "gave rise to Fiqh al-Tahawwulat", "أنشأ فقه التحولات"), "hl": True}]))
A(S("question", bab=2, q=T("Tiga ilmu pertama sudah kita kenal sejak lama. Mengapa yang keempat terasa asing?", "We have known the first three sciences for a long time. Why does the fourth feel unfamiliar?", "العلوم الثلاثة الأولى معروفة منذ زمن. فلماذا يبدو الرابع غريبًا؟")))
A(S("text", bab=2, title=T("Karena ia “disimpan”.", "Because it was “stored away”.", "لأنه كان «مدّخرًا»."),
    lines=[T("Para ulama menulis banyak tentang tiga rukun pertama. Rukun keempat umumnya dibahas terpisah, sebagai “tanda-tanda kiamat”, bukan sebagai bagian dari rukun agama.", "Scholars wrote at length on the first three pillars. The fourth was usually treated apart, as “signs of the Hour”, not as a pillar of religion.", "صنّف العلماء كثيرًا في الأركان الثلاثة الأولى، أما الرابع فتناولوه منفصلًا باسم «علامات الساعة»، لا ركنًا من أركان الدين."),
           T("Ketika tanda-tandanya mulai tampak, Al-Habib Abu Bakar Al-Masyhur menatanya menjadi satu ilmu yang bisa dipelajari: Fikih Tahawwulat.", "When its signs began to appear, Al-Habib Abu Bakar Al-Masyhur arranged it into one science that can be studied: Fiqh al-Tahawwulat.", "فلما بدت علاماته رتّبه الحبيب أبو بكر المشهور علمًا يُدرَس: فقه التحولات.")],
    note=T("At-Talid wath-Tharif, hlm. 25.", "At-Talid wath-Tharif, p. 25.", "التليد والطارف، ص٢٥.")))
A(S("quote", bab=2, art="arch", arabic="حَفِظْتُ مِنْ رَسُولِ اللَّهِ ﷺ وِعَاءَيْنِ: فَأَمَّا أَحَدُهُمَا فَبَثَثْتُهُ، وَأَمَّا الْآخَرُ فَلَوْ بَثَثْتُهُ لَقُطِعَ مِنِّي هَذَا الْبُلْعُومُ",
    translation=T("“Aku menghafal dua wadah ilmu dari Rasulullah ﷺ. Yang satu telah kusebarkan. Yang lain, seandainya kusebarkan, niscaya leherku ini dipotong.”", "“I memorized two vessels of knowledge from the Messenger of Allah ﷺ. One I have spread. The other, if I spread it, this throat would be cut.”", "«وعاءان: بثّ أحدهما، وكتم الآخر خشية الفتنة.»"),
    source=T("Abu Hurairah, Shahih al-Bukhari no. 120", "Abu Hurayrah, Sahih al-Bukhari no. 120", "أبو هريرة، صحيح البخاري رقم 120")))
A(S("text", bab=2, title=T("Mengapa sebagian ilmu itu disimpan?", "Why was part of this knowledge kept back?", "لماذا كُتم بعض هذا العلم؟"),
    lines=[T("Menurut At-Talid, para sahabat mengetahui ilmu ini dan menyimpannya dari orang awam, karena menyebarkannya saat itu bisa memicu fitnah yang luas.", "By At-Talid, the Companions knew this knowledge and kept it from the common people, since spreading it then could have caused wide fitna.", "كان الصحابة على علم واسع بهذا الركن ويكتمون سره عن العامة، لما يترتب على نشره في ذلك العصر من فتنة واسعة."),
           T("Tetapi ketika terus terpendam, generasi sesudahnya mudah keliru, dan orang yang tidak berilmu tampak seperti ulama.", "But as it stayed buried, later generations slipped easily, and the unlearned came to look like scholars.", "ولكن هذا العزل جعل الأجيال ترتكس في الخطأ، وأظهر السفهاء بمظهر العلماء.")],
    note=T("At-Talid wath-Tharif, hlm. 26–27.", "At-Talid wath-Tharif, pp. 26–27.", "التليد والطارف، ص٢٦–٢٧.")))
A(S("compare", bab=2, title=T("Tiga yang tetap, satu yang berubah", "Three that stay, one that changes", "ثلاثة ثوابت وركن متغيّر"),
    cols=(T("Tiga rukun pertama", "The first three pillars", "الأركان الثلاثة الأولى"), T("Rukun keempat", "The fourth pillar", "الركن الرابع")),
    rows=[(T("Sifatnya", "Its nature", "طبيعته"), T("Tetap: maknanya jelas dan tidak berganti", "Constant: its meaning is clear and does not shift", "ثابتة المدلول واضحة البيان"), T("Berubah: terkait peristiwa yang terus bergerak", "Changing: tied to events that keep moving", "متغيّر: يتعلق بالحوادث المتجددة")),
          (T("Isinya", "Its content", "مضمونه"), T("Akidah, syariat, dan tingkatan suluk", "Creed, law, and the stations of conduct", "شؤون العقيدة والشريعة ومراتب السلوك"), T("Peristiwa dan sebab-sebabnya, isyarat dan tanda dari Nabi ﷺ, serta keadaan orang-orang yang merusak agama", "Events and their causes, the Prophet's ﷺ signals and signs, and the state of those who corrupt religion", "الحوادث وأسبابها، والإشارات والعلامات النبوية، وأحوال المفسدين في الدين")),
          (T("Gunanya", "Its purpose", "وظيفته"), T("Membina generasi dan umat dalam ilmu yang wajib", "Raising generations and the Ummah in the knowledge that is obligatory", "تنشأ عليها الأجيال وتفهم الأمة علمها الفرضي الواجب"), T("Memahami perubahan, dan tahu sikap yang selamat di dalamnya", "Understanding the change, and knowing the safe stance within it", "فهم التحولات ومعرفة الموقف السليم فيها"))]))
A(S("stats", bab=2, title=T("Apakah rukun Islam, Iman, dan Ihsan berubah?", "Do the pillars of Islam, Iman, and Ihsan change?", "هل تتغيّر أركان الإسلام والإيمان والإحسان؟"),
    items=[{"n": 5, "t": T("Rukun Islam", "Pillars of Islam", "أركان الإسلام"), "d": T("tetap lima", "stay five", "خمسة لا تتغيّر")},
           {"n": 6, "t": T("Rukun Iman", "Pillars of Iman", "أركان الإيمان"), "d": T("tetap enam", "stay six", "ستة لا تتغيّر")},
           {"n": 2, "t": T("Rukun Ihsan", "Pillars of Ihsan", "أركان الإحسان"), "d": T("tetap dua", "stay two", "ركنان لا يتغيّران")}],
    lines=[T("Tidak. Rukun Islam tetap lima. Rukun Iman tetap enam. Rukun Ihsan tetap dua.", "No. The pillars of Islam stay five. The pillars of Iman stay six. The pillars of Ihsan stay two.", "لا. أركان الإسلام خمسة، وأركان الإيمان ستة، وللإحسان ركنان."),
           T("“Empat rukun agama” hanyalah cara mengelompokkan empat pertanyaan Jibril.", "“The four pillars of religion” is only a way to group Jibril's four questions.", "و«أركان الدين الأربعة» مجرد تصنيف لأسئلة جبريل الأربعة.")]))
A(S("question", bab=2, q=T("Bukankah kiamat hanya Allah yang tahu? Lalu mengapa kita membahas tandanya?", "Isn't it only Allah who knows the Hour? Then why discuss its signs?", "أليس الله وحده يعلم الساعة؟ فلماذا نبحث في علاماتها؟")))
A(S("compare", bab=2, title=T("Waktunya rahasia, tandanya diajarkan.", "The time is secret; the signs are taught.", "الوقت مكتوم، والعلامات مُعلَّمة."), cols=(T("Waktu kiamat", "The time of the Hour", "وقت الساعة"), T("Tanda-tandanya", "Its signs", "علاماتها")),
    rows=[(T("Siapa yang tahu", "Who knows", "من يعلم"), T("Hanya Allah", "Only Allah", "الله وحده"), T("Diajarkan Nabi ﷺ", "Taught by the Prophet ﷺ", "علّمها النبي ﷺ")),
          (T("Sikap kita", "Our stance", "موقفنا"), T("Dilarang menebak", "No guessing", "لا تخمين"), T("Dipelajari agar iman selamat", "Studied so faith stays safe", "تُدرس ليسلم الإيمان"))]))
A(S("text", bab=2, title=T("Pagar dan radar.", "A fence and a radar.", "سياج ورادار."),
    lines=[T("Fungsi rukun keempat: menjaga tiga rukun lainnya agar tidak rusak, dipalsukan, atau ditinggalkan ketika zaman berguncang.", "The fourth pillar's role: to guard the other three so they are not spoiled, falsified, or abandoned when the age shakes.", "وظيفة الركن الرابع: حفظ الثلاثة الأخرى كي لا تفسد أو تُزوَّر أو تُترك حين يضطرب الزمان.")]))
A(S("list", bab=2, title=T("Dua tugas utamanya", "Its two main tasks", "مهمتاه الرئيستان"),
    items=[{"t": T("Memperbarui cara dakwah", "Renewing the way of calling", "تجديد وسائل الدعوة"), "d": T("Dengan hikmah dan nasihat yang baik, menjaga lisan dari mencela dan tangan dari menumpahkan darah.", "With wisdom and good counsel, guarding the tongue from reviling and the hand from bloodshed.", "بالحكمة والموعظة الحسنة، مع حفظ اللسان من الذم واليد من الدم.")},
           {"t": T("Menjaga ilmu yang tetap", "Guarding the constant sciences", "صيانة علوم الثوابت"), "d": T("Dari tiga perusak: sikap berlebihan, kepalsuan, dan tafsir orang yang tidak berilmu.", "From three corruptors: excess, falsehood, and interpretation by the unlearned.", "من ثلاثة مفسدات: الغلو، والانتحال، وتأويل الجاهلين.")}]))
A(S("signs", bab=2, title=T("Dua tanda, dua kendali", "Two signs, two controls", "علامتان وقراران"),
    cols=(T("Tanda dalam hadis", "The sign in the hadith", "العلامة في الحديث"), T("Yang bergeser", "What shifts", "ما يتحوّل")),
    items=[{"sign": T("Budak perempuan melahirkan tuannya", "The slave woman gives birth to her mistress", "أن تلد الأمة ربّتها"), "signAr": "أَنْ تَلِدَ الْأَمَةُ رَبَّتَهَا",
            "ar": "قرار العلم والاعتقاد", "tr": "Qararul ‘ilmi wal i‘tiqad", "name": T("Otoritas ilmu dan akidah", "Authority over knowledge and creed", "قرار العلم والاعتقاد"),
            "d": T("Urusan ilmu dipegang yang belum berhak", "Knowledge handed to those unfit", "يُسند أمر العلم لغير أهله")},
           {"sign": T("Berlomba meninggikan bangunan", "Competing to raise tall buildings", "التطاول في البنيان"), "signAr": "يَتَطَاوَلُونَ فِي الْبُنْيَانِ",
            "ar": "قرار الحكم والاقتصاد", "tr": "Qararul hukmi wal iqtisad", "name": T("Otoritas hukum dan ekonomi", "Legal and economic authority", "قرار الحكم والاقتصاد"),
            "d": T("Kekuasaan dan harta dipegang yang belum berhak", "Power and wealth handed to those unfit", "يُسند الحكم والمال لغير أهله")}]))

A(S("quote", bab=2, art="arch", arabic="لَتُنْقَضَنَّ عُرَى الْإِسْلَامِ عُرْوَةً عُرْوَةً، كُلَّمَا انْتَقَضَتْ عُرْوَةٌ تَمَسَّكَ النَّاسُ بِالَّتِي تَلِيهَا، أَوَّلُهُنَّ نَقْضًا الْحُكْمُ وَآخِرُهُنَّ الصَّلَاةُ",
    translation=T("“Ikatan-ikatan Islam akan terurai satu demi satu. Setiap kali satu terurai, orang berpegang pada yang berikutnya. Yang pertama terurai adalah hukum, dan yang terakhir adalah salat.”", "“The bonds of Islam will be undone one by one. Each time one is undone, people hold to the next. The first undone is rule, and the last is prayer.”", "«أول العُرى نقضًا الحكم، وآخرها الصلاة.»"),
    source=T("HR. Ahmad dari Abu Umamah; Al-Hakim menshahihkannya. Dikutip At-Talid hlm. 31 untuk menggambarkan jatuhnya otoritas hukum dan otoritas ilmu.", "Reported by Ahmad from Abu Umamah; al-Hakim graded it sound. Cited in At-Talid, p. 31, to describe the fall of the authority of rule and of knowledge.", "رواه أحمد عن أبي أمامة وصححه الحاكم. أورده «التليد والطارف» ص٣١ في سقوط قرار الحكم وقرار العلم.")))

# ───────────── Bab 3: Fikih Tahawwulat
A(S("title", bab=3, kicker=T("Bab 3", "Chapter 3", "الباب 3"), title=T("Apa itu Fikih Tahawwulat?", "What is Fiqh al-Tahawwulat?", "ما هو فقه التحولات؟"), sub=T("Dengan kata paling sederhana.", "In the simplest words.", "بأبسط عبارة.")))
A(S("lines", bab=3, lines=[T("Fikih: pemahaman yang dalam.", "Fiqh: deep understanding.", "الفقه: الفهم العميق."), T("Tahawwulat: perubahan-perubahan.", "Tahawwulat: the changes.", "التحولات: التغيّرات."),
    T("Fikih Tahawwulat: ilmu memahami perubahan zaman dengan petunjuk Al-Qur'an dan hadis, supaya kita tahu sikap yang paling selamat.", "Fiqh al-Tahawwulat: the knowledge of understanding the changes of the age by the guidance of the Qur'an and hadith, so we know the safest stance.", "فقه التحولات: علم فهم تغيّرات الزمان بهدي القرآن والحديث، لنعرف الموقف الأسلم.")]))
A(S("question", bab=3, q=T("Apakah “fikih” hanya berarti hukum halal dan haram?", "Does “fiqh” only mean rulings on the lawful and the forbidden?", "هل «الفقه» يعني أحكام الحلال والحرام فقط؟")))
A(S("text", bab=3, title=T("Itu makna yang paling dikenal sekarang, bukan satu-satunya.", "That is the best-known meaning today, not the only one.", "هذا أشهر معانيه اليوم، لكنه ليس الوحيد."),
    lines=[T("Hari ini, kata fikih biasanya langsung dipahami sebagai ilmu hukum amalan: salat, zakat, jual beli, nikah.", "Today the word fiqh is usually taken at once as the science of legal rulings: prayer, zakat, trade, marriage.", "اليوم يُفهم لفظ الفقه مباشرةً على أنه علم أحكام العبادات والمعاملات: الصلاة والزكاة والبيع والنكاح."),
           T("Padahal itu makna yang menyempit. Makna asal kata ini jauh lebih luas.", "Yet that is a narrowed meaning. The word's original sense is far wider.", "وهذا معنى مضيَّق، أما أصل الكلمة فأوسع بكثير.")]))
A(S("cards", bab=3, title=T("Apa arti fikih sebenarnya?", "What does fiqh really mean?", "ما معنى الفقه حقًّا؟"),
    items=[{"t": T("Dalam bahasa: paham", "In language: understanding", "في اللغة: الفهم"), "d": T("Fikih menurut bahasa adalah fahm, paham.", "Fiqh in the language is fahm: understanding.", "الفقه في اللغة: هو الفهم.")},
           {"t": T("Dalam istilah umum: menangkap maksud", "In the general sense: grasping the intended meaning", "في الاصطلاح العام: إدراك المقصود"), "d": T("Menangkap maksud sebuah ilmu, entah fikih, nahwu, hadis, tafsir, atau yang lain.", "Grasping the intended meaning of a science, whether jurisprudence, grammar, hadith, exegesis, or any other.", "إدراك المقصود المترتب على نوع العلم المقرر فقهًا أو نحوًا أو حديثًا أو تفسيرًا أو غير ذلك.")},
           {"t": T("Lebih luas dari semua ilmu", "Wider than all the sciences", "أوسع من العلوم كلها"), "d": T("Sampai kepada pendengar yang menangkap maksud sebuah ucapan atau perintah yang ditujukan kepadanya.", "Reaching even the listener who grasps the meaning of a statement or command addressed to him.", "بل يتعدى العلوم كلها إلى فهم السامع المقصود من الكلام أو الأمر المخاطَب به.")}],
    note=T("Rujukan: At-Talid wath-Tharif, hlm. 24.", "Source: At-Talid wath-Tharif, p. 24.", "المرجع: التليد والطارف، ص٢٤.")))
A(S("dialog", bab=3, kicker=T("Contoh dari zaman Nabi ﷺ", "An example from the Prophet's ﷺ time", "مثال من زمن النبي ﷺ"),
    asker=T("Seorang lelaki meminta dibacakan Al-Qur'an. Nabi ﷺ membacakan Surah Az-Zalzalah, lalu hendak mengulang. Ia berkata, “Cukup. Satu ayat sudah mencukupiku.” Ayat itu: فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ / وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ شَرًّا يَرَهُ",
            "A man asked for the Qur'an to be recited. The Prophet ﷺ recited Surat az-Zalzalah, then meant to begin again. He said, “Enough. One verse has been enough for me.” The verse: فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ / وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ شَرًّا يَرَهُ",
            "طلب رجل أن يُقرأ عليه القرآن، فقرأ عليه النبي ﷺ سورة الزلزلة، ثم أراد أن يستأنف، فقال: «حسبك، لقد قرأتَ عليَّ آية كفتني». وهي: فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ / وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ شَرًّا يَرَهُ"),
    answer=T("«فَقِهَ الرَّجُلُ». Orang itu telah paham.", "«فَقِهَ الرَّجُلُ». The man has understood.", "«فقه الرجل»."),
    note=T("Ia menangkap maksud ayat itu. Itulah fikih. Dikutip At-Talid hlm. 24 dari Faidh al-Qadir karya Al-Munawi (5: 455).", "He grasped the meaning of the verse. That is fiqh. Cited in At-Talid, p. 24, from al-Munawi's Fayd al-Qadir (5: 455).", "أدرك مقصود الآية، وهذا هو الفقه. أورده «التليد والطارف» ص٢٤ عن «فيض القدير» للمناوي (5: 455).")))
A(S("quote", bab=3, art="arch", arabic="مَنْ يُرِدِ اللَّهُ بِهِ خَيْرًا يُفَقِّهْهُ فِي الدِّينِ",
    translation=T("“Barang siapa dikehendaki Allah kebaikan baginya, Dia pahamkan ia dalam agama.”", "“Whoever Allah wishes good for, He grants deep understanding of the religion.”", "«يرزقه الله الفهم العميق في الدين.»"),
    source=T("HR. Bukhari dan Muslim", "Reported by al-Bukhari and Muslim", "رواه البخاري ومسلم")))
A(S("question", bab=3, q=T("Apakah “paham dalam agama” di hadis ini hanya soal hukum salat dan jual beli?", "Does “understanding in religion” in this hadith only mean the rulings of prayer and trade?", "هل «الفقه في الدين» في هذا الحديث مقصور على أحكام الصلاة والبيع؟")))
A(S("text", bab=3, title=T("Tidak. Yang dipahamkan adalah agama, seluruhnya.", "No. What is granted is understanding of religion, all of it.", "لا. المقصود الفقه في الدين كله."),
    lines=[T("Menurut At-Talid, kata “agama” dalam hadis ini menunjukkan makna yang luas, mencakup seluruh ilmu keagamaan dan keberagamaan di bawah rukun-rukun agama.", "By At-Talid, the word “religion” in this hadith points to a wide meaning, covering all the sciences of religion and religiosity under the pillars of religion.", "تدل كلمة «الدين» في الحديث على سعة المعنى، ليشمل كافة علوم الديانة والتدين المنطوية تحت أركان الدين."),
           T("Dan agama, menurut Hadis Jibril, terdiri dari Islam, Iman, Ihsan, dan tanda-tanda zaman.", "And religion, by the Hadith of Jibril, is Islam, Iman, Ihsan, and the signs of the times.", "والدين في حديث جبريل: الإسلام والإيمان والإحسان وعلامات الساعة.")],
    note=T("At-Talid wath-Tharif, hlm. 24.", "At-Talid wath-Tharif, p. 24.", "التليد والطارف، ص٢٤.")))
A(S("quote", bab=3, art="arch", arabic="إِنَّ الدِّينَ عِندَ اللَّهِ الْإِسْلَامُ",
    translation=T("“Sesungguhnya agama di sisi Allah ialah Islam.”", "“Indeed, the religion in the sight of Allah is Islam.”", "«الإسلام هنا: كل ما جاءت به الرسالة المحمدية.»"),
    source=T("QS. Ali Imran: 19. Islam di sini lebih luas dari rukun Islam: ia mencakup semua yang dibawa risalah Nabi ﷺ (At-Talid hlm. 24).", "Qur'an, Al Imran: 19. Islam here is wider than the pillar of Islam: it covers all that the Prophet's ﷺ message brought (At-Talid, p. 24).", "آل عمران: 19. الإسلام هنا أوسع من ركن الإسلام، يشمل كل ما جاءت به الرسالة (التليد والطارف، ص٢٤).")))
A(S("text", bab=3, title=T("Fikih Tahawwulat kembali ke makna yang luas ini.", "Fiqh al-Tahawwulat returns to this wide meaning.", "وفقه التحولات يعود إلى هذا المعنى الواسع."),
    lines=[T("Memahami hukum-hukum perubahan dan peristiwa pada masa yang bergejolak, apa akibatnya berupa kebaikan atau kerusakan, dan seberapa cocok semua itu dengan nash Al-Qur'an dan sunnah.", "Understanding the laws of change and events in turbulent times, what follows from them of good or corruption, and how far they match the texts of the Qur'an and the Sunnah.", "فهم ما يجري من سنن التغيرات والحوادث في المراحل المتقلبة وما ترتب عليها من نقض وقبض وصلاح أو فساد، وما تطابق من هذه التحولات مع نصوص الكتاب أو السنة."),
           T("Karena “agama” itu luas, perubahan zaman pun pantas disebut fikih dan bagian dari agama.", "Because “religion” is wide, the changes of the age rightly count as fiqh and as part of religion.", "ولأن الدين واسع، يصح أن يُطلق على التحولات فقهًا ودينًا.")],
    note=T("At-Talid wath-Tharif, hlm. 24.", "At-Talid wath-Tharif, p. 24.", "التليد والطارف، ص٢٤.")))
A(S("question", bab=3, q=T("Apakah ini sama dengan ilmu akhir zaman yang sering beredar?", "Is this the same as the end-times talk that often circulates?", "هل هو نفسه حديث آخر الزمان المتداول؟")))
A(S("compare", bab=3, title=T("Dibandingkan dengan yang sering beredar", "Compared with what often circulates", "مقارنة بما يُتداول كثيرًا"), cols=(T("Yang sering beredar", "Often circulating", "المتداول كثيرًا"), T("Fikih Tahawwulat", "Fiqh al-Tahawwulat", "فقه التحولات")),
    rows=[(T("Tujuan", "Aim", "الغاية"), T("Menebak dan mencocokkan peristiwa", "Guessing and matching events", "التخمين ومطابقة الأحداث"), T("Membekali sikap yang selamat", "Equipping a safe stance", "تزويد الإنسان بالموقف الأسلم")),
          (T("Tahun dan tokoh", "Dates and figures", "السنوات والأشخاص"), T("Sering mematok tahun dan menunjuk orang", "Often fixes years and points at people", "كثيرًا ما تُحدَّد سنوات ويُشار إلى أشخاص"), T("Melarang keduanya", "Forbids both", "يمنع الأمرين")),
          (T("Nada", "Tone", "النبرة"), T("Menakut-nakuti, memancing marah", "Frightening, stirring anger", "تخويف وإثارة غضب"), T("Tenang, penuh harapan dan langkah amal", "Calm, hopeful, with steps to act", "هادئة، فيها رجاء وخطوات عمل")),
          (T("Akibatnya", "The effect", "الأثر"), T("Cemas dan saling curiga", "Anxiety and mutual suspicion", "قلق وارتياب"), T("Hati tenang dan amal nyata", "A calm heart and real deeds", "قلب مطمئن وعمل ملموس"))]))
A(S("list", bab=3, title=T("Yang khas dari Fikih Tahawwulat", "What is distinctive", "ما يميّزه"),
    items=[{"t": T("Bagian dari agama itu sendiri", "Part of religion itself", "جزء من الدين نفسه"), "d": T("Rukun keempat dalam Hadis Jibril.", "The fourth pillar in the Hadith of Jibril.", "الركن الرابع في حديث جبريل.")},
           {"t": T("Fikih sikap, bukan sekadar daftar tanda", "A fiqh of stances, not just a list of signs", "فقه مواقف لا قائمة علامات"), "d": T("Apa yang dilakukan muslim, keluarga, dan ulama di tiap tahap.", "What a Muslim, a family, and scholars do at each stage.", "ماذا يفعل المسلم والأسرة والعلماء في كل مرحلة.")},
           {"t": T("Berbeda dari ramalan dan teori konspirasi", "Unlike fortune-telling and conspiracy theories", "يختلف عن التنجيم ونظريات المؤامرة"), "d": T("Ia mengajak memperbaiki diri lebih dulu, dan berujung pada jalan selamat: hati, lisan, dan tangan terjaga.", "It invites you to mend yourself first, and ends in the safe way: heart, tongue, and hands guarded.", "يدعو إلى إصلاح النفس أولًا، وينتهي إلى منهج السلامة: سلامة القلب واللسان واليد.")}]))

A(S("cards", bab=3, title=T("Dari mana ilmu ini bersumber?", "Where does this knowledge come from?", "من أين يستمد هذا العلم؟"),
    items=[{"t": T("Al-Qur'an", "The Qur'an", "القرآن العظيم"), "d": T("Sumber pertama. Banyak ayat dan sebagian surah membahas perubahan dan sejarah umat.", "The first source. Many verses and some surahs deal with change and the history of nations.", "المصدر الأول، ومعظم آياته وبعض سوره تعنى بالتحولات وتاريخ الأمم.")},
           {"t": T("Sunnah", "The Sunnah", "السنة الشريفة"), "d": T("Sumber kedua, memuat tanda, isyarat, dan sikap Nabi ﷺ.", "The second source, holding the Prophet's ﷺ signs, signals, and stances.", "المصدر الثاني، وفيه العلامات والإشارات والمواقف النبوية.")},
           {"t": T("Sejarah dan riwayat yang terpercaya", "Reliable history and reports", "السير والآثار والأخبار الموثّقة"), "d": T("Sirah, atsar, dan kabar yang dicatat para ulama dengan sanad yang dapat dipercaya.", "Sirah, athar, and reports recorded by scholars with trustworthy chains.", "ما وثّقه العلماء من السير والآثار والأخبار.")},
           {"t": T("Peristiwa masa kini", "Events of today", "مجريات الزمان الحاضر"), "d": T("Diukur dengan sumber-sumber tadi, supaya terlihat mana yang selamat dan mana yang menyimpang.", "Measured against those sources, so it shows what is sound and what strays.", "تُقابل بما ورد في الأصلين ليبرز موقعها من السلامة أو الفساد.")}],
    note=T("Surah Al-Kahf dianjurkan dibaca tiap Jumat. Menurut At-Talid, ia memuat banyak bab Fikih Tahawwulat. Hlm. 40–42.", "Surat al-Kahf is recommended every Friday. By At-Talid it holds many chapters of Fiqh al-Tahawwulat. Pp. 40–42.", "ندب الإسلام تكرار سورة الكهف كل جمعة، وهي تحتوي على فصول من فقه التحولات. التليد والطارف ص٤٠–٤٢.")))
A(S("quote", bab=3, art="arch", arabic="عَلَيْكُمْ بِسُنَّتِي وَسُنَّةِ الْخُلَفَاءِ الرَّاشِدِينَ الْمَهْدِيِّينَ مِنْ بَعْدِي، عَضُّوا عَلَيْهَا بِالنَّوَاجِذِ",
    translation=T("“Berpegang teguhlah pada sunahku dan sunah para khalifah yang lurus dan mendapat petunjuk sesudahku. Gigitlah ia dengan gigi geraham.”", "“Hold to my Sunnah and the Sunnah of the rightly guided caliphs after me. Bite onto it with your molars.”", "«تمسّكوا بها تمسّكًا شديدًا.»"),
    source=T("HR. At-Tirmidzi, Abu Dawud, Ibnu Majah, dan Ahmad, dari Al-‘Irbadh bin Sariyah. Dikutip At-Talid hlm. 27.", "Reported by at-Tirmidhi, Abu Dawud, Ibn Majah, and Ahmad, from al-'Irbad ibn Sariyah. Cited in At-Talid, p. 27.", "رواه الترمذي وأبو داود وابن ماجه وأحمد عن العرباض بن سارية. أورده «التليد والطارف» ص٢٧.")))
A(S("text", bab=3, title=T("Sunnah yang berupa sikap.", "A Sunnah of stances.", "سنّة المواقف."),
    lines=[T("Menurut At-Talid, “sunnah” dalam hadis ini mencakup sikap Nabi ﷺ dan para khalifah yang lurus dalam menghadapi perubahan dan fitnah. Inilah yang disebut sunnah al-mawaqif.", "By At-Talid, the “Sunnah” in this hadith covers the stances of the Prophet ﷺ and the rightly guided caliphs toward change and fitna. This is called sunnat al-mawaqif.", "السنة هنا، عند صاحب «التليد والطارف»، هي مواقف النبي ﷺ وخلفائه الراشدين المهديين تجاه التحولات والفتن، وهذا ما يُسمّى «سنة المواقف»."),
           T("Maka mempelajari Fikih Tahawwulat berarti belajar bersikap, bukan hanya mengetahui.", "So studying Fiqh al-Tahawwulat means learning how to stand, not only to know.", "فدراسة فقه التحولات تعلّمٌ للموقف، لا مجرد معرفة.")],
    note=T("At-Talid wath-Tharif, hlm. 27–28.", "At-Talid wath-Tharif, pp. 27–28.", "التليد والطارف، ص٢٧–٢٨.")))
A(S("cards", bab=3, title=T("Contoh sikap yang dikutip At-Talid", "Examples of stances cited by At-Talid", "نماذج من المواقف في «التليد والطارف»"),
    items=[{"t": T("Al-Hasan bin Ali berdamai", "Al-Hasan ibn Ali makes peace", "صلح الحسن بن علي"), "d": T("Memilih mencegah pertumpahan darah. Nabi ﷺ bersabda: «إِنَّ ابْنِي هَذَا سَيِّدٌ وَسَيُصْلِحُ اللَّهُ بِهِ بَيْنَ فِئَتَيْنِ مِنَ الْمُسْلِمِينَ». HR. Bukhari.", "Chose to prevent bloodshed. The Prophet ﷺ said: «إِنَّ ابْنِي هَذَا سَيِّدٌ وَسَيُصْلِحُ اللَّهُ بِهِ بَيْنَ فِئَتَيْنِ مِنَ الْمُسْلِمِينَ». Reported by al-Bukhari.", "اتخذ موقفًا يحقن الدماء، وقال النبي ﷺ: «إِنَّ ابْنِي هَذَا سَيِّدٌ وَسَيُصْلِحُ اللَّهُ بِهِ بَيْنَ فِئَتَيْنِ مِنَ الْمُسْلِمِينَ». رواه البخاري.")},
           {"t": T("Kembali kepada yang ahli", "Returning to those who know", "الرجوع إلى أهل الاختصاص"), "d": T("Para sahabat besar dalam ilmu ini kembali kepada orang yang dikenal menguasainya. Umar meminta pertimbangan Hudzaifah bin Al-Yaman.", "The senior Companions returned, in this knowledge, to whoever was known for it. 'Umar consulted Hudhayfah ibn al-Yaman.", "كان كبار الصحابة يعودون في هذا الفقه إلى من عُرف تخصصه فيه، وكان عمر يستشير حذيفة بن اليمان.")}],
    note=T("At-Talid wath-Tharif, hlm. 28.", "At-Talid wath-Tharif, p. 28.", "التليد والطارف، ص٢٨.")))

# ───────────── Bab 4: lima cabang ilmu
BR = [
 dict(name=T("Fikih Fitnah dan Penjagaan Diri", "Fiqh of Fitna and Self-Protection", "فقه النواقض والنقائض ومضلّات الفتن وسبل الوقاية منها"),
      short=T("Fitnah dan penjagaan diri", "Fitna and self-protection", "النواقض والنقائض"),
      desc=T("Mengenali hal-hal yang merusak agama, dan cara menyelamatkan diri darinya.", "Recognizing what harms religion, and how to keep yourself safe from it.", "معرفة ما يفسد الدين، وكيف ينجو الإنسان منه."),
      qs=[T("Iman saya naik turun. Apa yang merusaknya, dan bagaimana menjaganya?", "My faith rises and falls. What damages it, and how do I guard it?", "إيماني يعلو ويهبط. ما الذي يفسده وكيف أحفظه؟"),
          T("Bagaimana menyikapi hoaks agama di grup keluarga?", "How should I treat religious hoaxes in the family group chat?", "كيف أتعامل مع الأخبار الدينية المكذوبة في مجموعة الأسرة؟"),
          T("Saya lelah dengan berita buruk. Haruskah terus mengikutinya?", "I am tired of bad news. Must I keep following it?", "تعبتُ من الأخبار السيئة. هل يلزمني متابعتها؟")]),
 dict(name=T("Fikih Isyarat, Kabar Gembira, dan Perlindungan", "Fiqh of Signals, Glad Tidings, and Protection", "فقه الإشارات والبشارات والنذارات والحصانات والأسانيد"),
      short=T("Isyarat dan perlindungan", "Signals and protection", "الإشارات والبشارات"),
      desc=T("Mengenali pesan-pesan Nabi ﷺ tentang tempat, masa, kabar baik, dan peringatan bahaya, serta pentingnya belajar dari guru yang bersanad.", "Recognizing the Prophet's ﷺ messages about places, times, glad tidings, and warnings, and the importance of learning from a teacher with a chain.", "معرفة رسائل النبي ﷺ عن الأماكن والأزمنة والبشارات والنذارات، وأهمية التعلّم من معلّم مسنَد."),
      qs=[T("Bagaimana membedakan guru yang tepercaya dari yang bukan?", "How do I tell a trustworthy teacher from one who is not?", "كيف أميّز المعلم الموثوق من غيره؟"),
          T("Mengapa sanad penting dalam belajar agama?", "Why does a chain of transmission matter in learning religion?", "لماذا يهم السند في تعلّم الدين؟"),
          T("Kabar gembira apa yang disampaikan Nabi ﷺ untuk umatnya?", "What glad tidings did the Prophet ﷺ give his Ummah?", "ما البشارات التي بشّر بها النبي ﷺ أمّته؟")]),
 dict(name=T("Fikih Sains, Teknologi, dan Budaya Baru", "Fiqh of Science, Technology, and New Culture", "فقه مستجدات العلوم والثقافات والتقنيات"),
      short=T("Sains, teknologi, budaya baru", "Science, technology, new culture", "مستجدات العلوم والتقنيات"),
      desc=T("Menyikapi penemuan modern dan tren budaya baru dengan timbangan agama. Islam tidak memusuhi sains dan teknologi.", "Treating modern discoveries and new cultural trends by religion's scale. Islam is not hostile to science and technology.", "التعامل مع المستجدات والاتجاهات الثقافية بميزان الدين. فالإسلام لا يعادي العلم والتقنية."),
      qs=[T("Bagaimana agama menyikapi AI dan internet?", "How does religion treat AI and the internet?", "كيف يتعامل الدين مع الذكاء الاصطناعي والإنترنت؟"),
          T("Bagaimana menjaga iman anak di zaman layar?", "How do I protect my child's faith in the age of screens?", "كيف أحفظ إيمان ابني في زمن الشاشات؟"),
          T("Bagaimana menimbang budaya dan tren baru?", "How do I weigh new cultures and trends?", "كيف أزن الثقافات والاتجاهات الجديدة؟")]),
 dict(name=T("Fikih Tanda Alam dan Peristiwa Besar", "Fiqh of Natural Signs and Great Events", "فقه الأشراط الكونية والأحداث الكبرى"),
      short=T("Tanda alam dan peristiwa besar", "Signs and great events", "الأشراط والأحداث الكبرى"),
      desc=T("Memahami tanda kecil, tengah, dan besar secara tertib, tanpa spekulasi.", "Understanding the minor, middle, and major signs in order, without speculation.", "فهم الأشراط الصغرى والوسطى والكبرى بترتيب ودون تخمين."),
      qs=[T("Apa beda tanda kecil, tengah, dan besar?", "What separates the minor, middle, and major signs?", "ما الفرق بين الأشراط الصغرى والوسطى والكبرى؟"),
          T("Siapa Imam Mahdi, Dajjal, dan Nabi Isa menurut urutannya?", "Who are Imam al-Mahdi, the Dajjal, and Prophet Isa, in order?", "من المهدي والدجال وعيسى عليه السلام، وبأي ترتيب؟"),
          T("Bolehkah menebak tahun kiamat?", "May we guess the year of the Hour?", "هل يجوز تخمين سنة الساعة؟")],
      note=T("Di sinilah Imam Mahdi dan Dajjal dibahas, sebagai bagian dari tanda-tanda besar.", "This is where Imam al-Mahdi and the Dajjal are discussed, as part of the major signs.", "وهنا يُبحث المهدي والدجال، ضمن الأشراط الكبرى.")),
 dict(name=T("Fikih Menautkan Agama dan Sejarah", "Fiqh of Linking Religion and History", "فقه الربط بين الديانة والتاريخ"),
      short=T("Agama dan sejarah", "Religion and history", "الديانة والتاريخ"),
      desc=T("Membaca perjalanan umat dari masa ke masa dalam bingkai wahyu, agar kita tahu di mana kita berdiri.", "Reading the Ummah's journey through the ages in the frame of revelation, so we know where we stand.", "قراءة مسيرة الأمة عبر العصور في إطار الوحي، لنعرف أين نقف."),
      qs=[T("Bagaimana membaca sejarah umat dengan petunjuk wahyu?", "How do I read the Ummah's history by the guidance of revelation?", "كيف أقرأ تاريخ الأمة بهدي الوحي؟"),
          T("Mengapa umat Islam banyak, tetapi terasa lemah?", "Why are Muslims many, yet feel weak?", "لماذا المسلمون كثيرون ومع ذلك يشعرون بالضعف؟"),
          T("Apa hubungan perjalanan sejarah dengan sikap kita hari ini?", "How does the course of history relate to our stance today?", "ما صلة مسيرة التاريخ بموقفنا اليوم؟")]),
]
A(S("title", bab=4, kicker=T("Bab 4", "Chapter 4", "الباب 4"), title=T("Lima cabang ilmunya", "Its five branches", "فروعه الخمسة"),
    sub=T("Bukan hanya tentang Imam Mahdi dan Dajjal.", "Not only about Imam al-Mahdi and the Dajjal.", "ليس عن المهدي والدجال فقط."), art="radial"))
A(S("question", bab=4, q=T("Apakah Fikih Tahawwulat hanya membahas Imam Mahdi dan Dajjal?", "Does Fiqh al-Tahawwulat only discuss Imam al-Mahdi and the Dajjal?", "هل يقتصر فقه التحولات على الحديث عن المهدي والدجال؟"), art="radial"))
A(S("text", bab=4, title=T("Tidak. Itu hanya sebagian kecil dari satu cabang.", "No. That is a small part of one branch.", "لا. هذا جزء يسير من فرع واحد."),
    lines=[T("Kisah Imam Mahdi dan Dajjal termasuk tanda-tanda besar. Dan tanda-tanda besar hanyalah satu bagian dari satu cabang.", "The accounts of Imam al-Mahdi and the Dajjal belong to the major signs. And the major signs are only one part of one branch.", "خبر المهدي والدجال من الأشراط الكبرى، والأشراط الكبرى جزء واحد من فرع واحد."),
           T("Ilmu ini punya lima cabang. Masing-masing menjawab jenis pertanyaan yang berbeda.", "This science has five branches. Each answers a different kind of question.", "لهذا العلم خمسة فروع، ولكل فرع نوع مختلف من الأسئلة.")], art="radial", hl=3))
A(S("branchmap", bab=4, title=T("Lima cabang, satu peta", "Five branches, one map", "خمسة فروع، وخريطة واحدة"),
    items=[{"n": i + 1, "t": b["name"], "s": b["short"]} for i, b in enumerate(BR)],
    note=T("Ketuk atau geser untuk melihat tiap cabang.", "Swipe on to see each branch.", "اسحب لترى كل فرع."), art="radial"))
for i, b in enumerate(BR):
    A(S("branch", bab=4, n=i + 1, name=b["name"], desc=b["desc"], qs=b["qs"], note=b.get("note"), art="radial", hl=i))
A(S("text", bab=4, title=T("Lima cabang, satu tujuan.", "Five branches, one aim.", "خمسة فروع، وغاية واحدة."),
    lines=[T("Semuanya bermuara pada satu hal: sikap yang paling selamat di tengah perubahan zaman.", "All of them lead to one thing: the safest stance amid the changes of the age.", "كلها تصبّ في أمر واحد: الموقف الأسلم في خضمّ تغيّر الزمان."),
           T("Itulah mengapa ia bukan sekadar ilmu tentang akhir zaman. Ia ilmu untuk hidup hari ini.", "That is why it is not merely a science of the end of time. It is a science for living today.", "ولهذا ليس مجرد علم عن آخر الزمان؛ بل علم للحياة اليوم.")], art="radial", hl=-1))

A(S("list", bab=4, title=T("Ringkasannya", "In short", "الخلاصة"),
    items=[{"t": T("Agama itu utuh", "Religion is whole", "الدين وحدة كاملة"), "d": T("Islam, Iman, Ihsan, dan tanda-tanda zaman, dalam satu Hadis Jibril.", "Islam, Iman, Ihsan, and the signs of the times, in one Hadith of Jibril.", "الإسلام والإيمان والإحسان وعلامات الساعة في حديث جبريل.")},
           {"t": T("Fikih itu paham yang dalam", "Fiqh is deep understanding", "الفقه فهم عميق"), "d": T("Bukan hanya hukum halal dan haram.", "Not only rulings on the lawful and the forbidden.", "لا أحكام الحلال والحرام وحدها.")},
           {"t": T("Tahawwulat itu perubahan zaman", "Tahawwulat is the change of the age", "التحولات تغيّر الزمان"), "d": T("Dipahami dengan petunjuk Al-Qur'an dan hadis.", "Understood by the guidance of the Qur'an and hadith.", "تُفهم بهدي القرآن والحديث.")},
           {"t": T("Lima cabang, bukan hanya Mahdi dan Dajjal", "Five branches, not only al-Mahdi and the Dajjal", "خمسة فروع، لا المهدي والدجال فقط"), "d": T("Fitnah, isyarat dan perlindungan, sains dan teknologi, tanda alam, serta sejarah.", "Fitna, signals and protection, science and technology, natural signs, and history.", "الفتن، والإشارات والحصانات، والعلوم والتقنيات، والأشراط الكونية، والتاريخ.")},
           {"t": T("Hasilnya sikap yang selamat", "The result is a safe stance", "الثمرة موقف سليم"), "d": T("Bukan ramalan, bukan tebakan tahun, bukan menunjuk tokoh.", "Not prediction, not guessing years, not pointing at people.", "لا تنبؤ، ولا تخمين سنوات، ولا إشارة إلى أشخاص.")}]))

# ───────────── Bab 5: lima asisten
A(S("title", bab=5, kicker=T("Bab 5", "Chapter 5", "الباب 5"), title=T("Lima asisten untuk mempelajarinya", "Five assistants to study it", "خمسة مساعدين لدراسته"),
    sub=T("Kitab dan ceramah yang sama, lima cara belajar.", "The same books and lectures, five ways to learn.", "الكتب والمحاضرات نفسها، وخمس طرق للتعلّم.")))
A(S("assistant", bab=5, ar="المحقق", name="Al-Muhaqqiq", role=T("Peneliti teks", "The text researcher", "باحث النصوص"),
    desc=T("Mencari matan dan ibarah asli beserta sumbernya, lalu memeriksanya dengan teliti.", "Finds the original text and passage with its source, then checks it carefully.", "يبحث عن المتن والعبارة الأصلية مع مصدرها ثم يدققها."),
    ask=T("“Di mana Al-Habib menyebut dua keruntuhan peradaban? Tampilkan ibarahnya.”", "“Where does Al-Habib mention the two collapses of civilization? Show me the passage.”", "«أين يذكر الحبيب الانهيارين الحضاريين؟ أرني العبارة.»")))
A(S("assistant", bab=5, ar="البيان", name="Al-Bayan", role=T("Penjelas yang sederhana", "The simple explainer", "الشارح المبسِّط"),
    desc=T("Menjelaskan dengan bahasa yang mudah dipahami. Cocok untuk pemula, dan tempat terbaik untuk mulai.", "Explains in easy language. Suited to beginners, and the best place to start.", "يشرح بلغة سهلة. مناسب للمبتدئين، وهو أفضل مكان للبداية."),
    ask=T("“Jelaskan al-ghutsa'iyyah dengan bahasa sederhana.”", "“Explain al-ghuthaiyya in simple words.”", "«اشرح الغثائية بعبارة مبسّطة.»"), start=True))
A(S("assistant", bab=5, ar="المختبر", name="Al-Mukhtabir", role=T("Penguji pemahaman", "The understanding tester", "مختبِر الفهم"),
    desc=T("AI bertanya, Anda menjawab, lalu ia menilai di mana jawaban Anda sudah baik, di mana lemah, dan memberi jawaban idealnya.", "The AI asks, you answer, then it judges where your answer is strong and where weak, and gives the ideal answer.", "يسألك الذكاء الاصطناعي فتجيب، ثم يقيّم جوابك: مواطن الإحسان ومواطن الضعف، ويعطيك الجواب المثالي."),
    ask=T("“Uji saya: apa itu al-ghutsa'iyyah?”", "“Test me: what is al-ghuthaiyya?”", "«اختبرني: ما الغثائية؟»")))
A(S("assistant", bab=5, ar="الحبيب", name="Al-Habib", role=T("Ceramah Al-Habib", "Al-Habib's lectures", "محاضرات الحبيب"),
    desc=T("Berisi ceramah Al-Habib Abu Bakar, dan menjawab dengan diksi beliau sendiri.", "Holds the lectures of Al-Habib Abu Bakar, and answers in his own wording.", "فيه محاضرات الحبيب أبي بكر، ويجيب بألفاظه هو."),
    ask=T("“Bagaimana Al-Habib menjelaskan sikap saat masa fitnah?”", "“How does Al-Habib explain conduct in times of trial?”", "«كيف يشرح الحبيب الموقف زمن الفتن؟»")))
A(S("assistant", bab=5, ar="الخطيب", name="Al-Khatib", role=T("Penyusun khutbah", "The sermon writer", "معدّ الخطب"),
    desc=T("Menyusun khutbah, bahan ceramah, dan materi dakwah lainnya.", "Drafts sermons, talk material, and other da'wa content.", "يُعدّ الخطب والمواد الوعظية وسائر المواد الدعوية."),
    ask=T("“Susun kerangka khutbah tentang sikap saat masa fitnah.”", "“Outline a sermon on conduct in times of trial.”", "«ضع هيكل خطبة عن الموقف زمن الفتن.»")))
A(S("end", bab=5, title=T("Mulai dari mana?", "Where to start?", "من أين أبدأ؟"),
    items=[{"t": T("Pilih satu pertanyaan yang paling mengganjal", "Pick the question that troubles you most", "اختر السؤال الذي يشغلك أكثر"), "d": T("Dari daftar tadi.", "From the list you just saw.", "من القائمة التي رأيتها.")},
           {"t": T("Tanyakan kepada Al-Bayan", "Ask Al-Bayan", "اسأل «البيان»"), "d": T("Bahasanya paling sederhana.", "His language is the simplest.", "لغته أبسط ما يكون.")},
           {"t": T("Periksa ibarahnya, tanyakan kepada guru", "Check the passage, ask a teacher", "تحقّق من العبارة واسأل معلمك"), "d": T("Terutama untuk urusan amal.", "Especially for matters of practice.", "خاصة في مسائل العمل.")}],
    cta=T("Mulai bertanya", "Start asking", "ابدأ بالسؤال"), cta2=T("Baca sebagai teks", "Read as text", "اقرأ نصًّا")))

PIL = [T("Islam", "Islam", "الإسلام"), T("Iman", "Iman", "الإيمان"), T("Ihsan", "Ihsan", "الإحسان"), T("Tanda zaman", "Signs", "الأشراط")]
_k = 0
_as = 0
for _s in SL:
    if _s["bab"] == 1 and _s["type"] == "dialog":
        _s["art"] = "pillars"; _s["hl"] = min(_k, 3); _s["labels"] = PIL; _k += 1
    if _s["bab"] == 1 and _s["type"] == "cards" and len(_s["items"]) == 4:
        _s["art"] = "pillars"; _s["hl"] = 3; _s["labels"] = PIL
    if _s["bab"] == 2 and _s["type"] in ("cards", "list", "text", "question"):
        _s["art"] = "pillars"; _s["hl"] = 3; _s["labels"] = PIL
    if _s["type"] == "assistant":
        _s["art"] = "radial"; _s["hl"] = _as; _as += 1
        _s["labels"] = [T(x, x, x) for x in ("المحقق", "البيان", "المختبر", "الحبيب", "الخطيب")]
out = {"bab": BAB, "slides": SL}
if __name__ == "__main__":
    p = Path(__file__).resolve().parents[2] / "openturath_ai" / "assets" / "data" / "slides_mengenal.json"
    p.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf8")
    print(len(SL), "slide ->", p)
