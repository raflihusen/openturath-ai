import os
import json

base_dir = '/Users/apple/Downloads/ramadhan'
output_path = os.path.join(base_dir, 'KUMPULAN_TEKS_MENGENAL_TAHAWWULAT.txt')

# 1. Load MENGENAL_FIKIH_TAHAWWULAT.md
with open(os.path.join(base_dir, 'MENGENAL_FIKIH_TAHAWWULAT.md'), 'r', encoding='utf-8') as f:
    mengenal_content = f.read()

# 2. Load DESAIN_KORPUS_KHUSUS_FIKIH_TAHAWWULAT.md
with open(os.path.join(base_dir, 'DESAIN_KORPUS_KHUSUS_FIKIH_TAHAWWULAT.md'), 'r', encoding='utf-8') as f:
    desain_content = f.read()

# 3. Load 06_KATALOG_FIKIH_TAHAWWULAT.json
with open(os.path.join(base_dir, 'openturath_ai/assets/data/06_KATALOG_FIKIH_TAHAWWULAT.json'), 'r', encoding='utf-8') as f:
    katalog_books = json.load(f)

# 4. Load canonical_tahawwulat.json
with open(os.path.join(base_dir, 'openturath_ai/assets/data/canonical_tahawwulat.json'), 'r', encoding='utf-8') as f:
    canonical_books = json.load(f)

with open(output_path, 'w', encoding='utf-8') as out:
    out.write('=' * 84 + '\n')
    out.write('OPENTURATH AI — ENSIKLOPEDIA & KUMPULAN LENGKAP TEKS MENGENAL FIKIH TAHAWWULAT\n')
    out.write('Single Source of Truth: Teks Pengantar, Kurikulum, Konsep, dan Katalog Kanonikal\n')
    out.write('Berdasarkan Kodifikasi Al-Allamah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur\n')
    out.write('=' * 84 + '\n\n')

    out.write('PENGANTAR PENYUSUNAN:\n')
    out.write('Berkas ini mengompilasi seluruh materi teks tentang Fikih Tahawwulat yang ada di\n')
    out.write('dalam aplikasi OpenTurath AI, mencakup:\n')
    out.write('1. Buku Panduan Utama Mengenal Fikih Tahawwulat (10 Bab Lengkap & Mukadimah)\n')
    out.write('2. Seluruh Teks Antarmuka Modal Interaktif (TahawwulatIntroductionSheet di Aplikasi)\n')
    out.write('3. Blueprint Desain, Spesifikasi Korpus Mahkota & 5 Bilik AI Spesialis\n')
    out.write('4. Katalog Kanonikal 58 Kitab Karya Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur\n')
    out.write('\n' + '=' * 84 + '\n\n')

    # ── BAGIAN I ──
    out.write('=' * 84 + '\n')
    out.write('BAGIAN I: BUKU PANDUAN UTAMA — MENGENAL FIKIH TAHAWWULAT\n')
    out.write('(Hakikat, Sistem Navigasi Kenabian, dan Benteng Keselamatan Akhir Zaman)\n')
    out.write('=' * 84 + '\n\n')
    out.write(mengenal_content.strip() + '\n\n')

    # ── BAGIAN II ──
    out.write('=' * 84 + '\n')
    out.write('BAGIAN II: TEKS ANTARMUKA INTERAKTIF DALAM APLIKASI (IN-APP MODAL COPY)\n')
    out.write('(Transkrip Lengkap Seluruh Lembar Panduan TahawwulatIntroductionSheet)\n')
    out.write('=' * 84 + '\n\n')

    in_app_text = """[MUKADIMAH MODAL APLIKASI]
Judul Utama: Mengenal Fikih Tahawwulat (فقه التحولات)
Sub-Judul: Navigasi Kenabian & Benteng Keselamatan Akhir Zaman
Penggagas Disiplin: Al-Musnid Al-`Allāmah Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur (1366–1444 H / 1947–2022 M)
Klasifikasi: Rukun Keempat Agama (Ar-Rukn Ar-Rābi') — 'Ilm 'Alāmāt as-Sā'ah

Teks Pengantar:
"Di era modern hari ini, tatanan peradaban berguncang hebat: banjir informasi melampaui kejernihan hakikat (fujā'at al-aḥdāṡ), sesama Muslim mudah diadu domba dan saling mengafirkan (at-taḥrīsy wat-takfīr), konten ramalan kiamat serampangan melahirkan kecemasan jiwa (apocalyptic anxiety), dan kemajuan kecerdasan buatan (AI) melompati etika moral manusia. Di tengah kabut tebal zaman ini, umat membutuhkan kompas nubuwwah agar tidak gamang membaca peristiwa dunia."

--------------------------------------------------------------------------------
[TAB 1: HAKIKAT & PONDASI DALIL]
Definisi Istilah:
«الفَهْمُ الشَّرْعِيُّ لِمَا يَقْضِي اللهُ وَيُدَبِّرُهُ فِي العَالَمِ الأَزَلِيِّ، وَمَا جَرَى وَيَجْرِي مِنْ سُنَنِ التَّغَيُّرَاتِ فِي الكَوْنِ، وَفِقْهُ عَلَامَاتِ السَّاعَةِ وَمَرَاحِلِ الفِتَنِ وَفِقْهِ الدَّعْوَةِ فِي كُلِّ مَرْحَلَةٍ»
Artinya:
"Pemahaman syar'i tentang apa yang telah ditetapkan dan diatur oleh Allah sejak alam azali, hukum-hukum pergeseran yang terjadi dan akan terjadi di alam semesta, fikih tanda-tanda hari kiamat dan fase-fase fitnah, serta fikih dakwah yang tepat pada setiap fasenya."

Pondasi Umm as-Sunnah (Hadis Jibril AS dalam Sahih Muslim):
Rasulullah ﷺ menyatukan empat rukun ke dalam sabda: «فَإِنَّهُ جِبْرِيلُ أَتَاكُمْ يُعَلِّمُكُمْ دِينَكُمْ» ("Sesungguhnya dia adalah Jibril yang datang mengajarkan AGAMA KALIAN").
1. Al-Islām (الإِسْلَام): Fikih Hukum & Syariat (Aṡ-Ṡawābit) — Ibadah lahiriah, rukun fi'li, halal-haram & muamalah baku.
2. Al-Īmān (الإِيمَان): Akidah & Tauhid (Aṡ-Ṡawābit) — Pondasi keyakinan pada Allah, malaikat, kitab, rasul & takdir azali.
3. Al-Iḥsān (الإِحْسَان): Tasawuf & Akhlak (Aṡ-Ṡawābit) — Penyucian jiwa (tazkiyatun nufūs), muraqabah hati & keluhuran adab batin.
4. Fikih Tahawwulat (فِقْهُ التَّحَوُّلَاتِ): Tanda Kiamat & Navigasi Zaman (Al-Mutaghayyirāt) — Peta kompas nubuwwah yang memandu agar Islam, Iman, dan Ihsan tidak tersapu badai fitnah akhir zaman.

--------------------------------------------------------------------------------
[TAB 2: DUA PILAR KERUNTUHAN & PISAU BEDAH NAWAQID]
Dua Isyarat Kenabian dalam Hadis Jibril (Ruknā 'Ilm as-Sā'ah):
Pilar 1: «أَنْ تَلِدَ الأَمَةُ رَبَّتَهَا» ("Jika hamba sahaya wanita melahirkan tuannya")
=> Simbol Naqḍ Qarār al-`Ilm wal-I'tiqād (Keruntuhan Otoritas Ilmu & Keyakinan).
Karakter: Lahirnya generasi yang tidak beradab pada orang tua dan gurunya; meruntuhkan tradisi talaqqi bersanad; mengerdilkan ulama mu'tabar.

Pilar 2: «وَأَنْ تَرَى الحُفَاةَ العُرَاةَ العَالَةَ رِعَاءَ الشَّاءِ يَتَطَاوَلُونَ فِي البُنْيَانِ» ("Dan jika engkau melihat orang tak beralas kaki, telanjang, miskin penggembala kambing saling berlomba meninggikan bangunan")
=> Simbol Naqḍ Qarār al-Ḥukm wal-Iqtiṣād (Keruntuhan Otoritas Hukum/Politik & Ekonomi).
Karakter: Pergeseran kekuasaan kepada yang bukan ahlinya; sistem ekonomi riba global yang memiskinkan mayoritas dan memanjakan segelintir elit materialistis.

Konsep Pisau Bedah Pemikiran:
1. An-Nawāqid (النَّوَاقِض - Proses Peruntuhan):
   Proses sistematis melucuti nilai-nilai Islam dari dalam, seperti Naqd Manhaj at-Talaqqi (meruntuhkan adab berguru).
2. An-Naqā'id (النَّقَائِض - Ideologi Tandingan):
   Paham tandingan yang menggantikan pilar syariat, seperti Sekularisme ekstrem, Materialisme, dan Hedonisme.

Kaidah Menghadapi Teknologi & AI (Al-Ightinām):
- Naskah Mendahului Sejarah (Al-Naṣṣ Asbaq min al-Ḥadaṡ): Segala fenomena era siber telah diisyaratkan nabi.
- Kaidah Al-Ightinām: Merebut teknologi canggih dan AI untuk khidmat menyiarkan khazanah turats, bukan untuk fitnah.

--------------------------------------------------------------------------------
[TAB 3: MANHAJ DAKWAH & SIKAP KENABIAN]
Transformasi Bahasa Dakwah (Dari Vonis Menuju Penyelamatan):
- Dari Bahasa Hakim (Takfir/Tabdi') => Menjadi Bahasa Dokter (Penyembuh/Tibbul Qulub).
- Dari Sikap Memusuhi Korban Zaman => Menjadi Merangkul dan Menyelamatkan Umat.
- Dari Provokasi Politik Partisan => Menjadi Dakwah Berbasis Ilmu & Keteladanan.

Kaidah Emas Sunnah Mawāqif (Manhaj as-Salāmah):
«سَالِمًا بِاللِّسَانِ مِنَ الذَّمِّ، وَسَالِمًا بِالأَرْكَانِ مِنَ الدَّمِّ»
"Selamat lisan dari mencela, selamat anggota tubuh dan tangan dari menumpahkan darah."
Melarang keras Al-Ittijār bid-Dīn (menjualbelikan ayat dan agama demi panggung politik kekuasaan).

--------------------------------------------------------------------------------
[TAB 4: AL-KHUWAISHAH & KETENANGAN BATIN]
Konsep Al-Khuwaiṣah (الـخُوَيْصَة):
Bentuk kasih sayang (tashghir) dari Al-Khashshah, yaitu strategi shelter perlindungan diri dan keluarga:
- Lapisan 1: Diri Sendiri (Hifzh an-Nafs) — Menjaga hati dari kebencian dan menjaga ibadah pribadi.
- Lapisan 2: Rumah Tangga (Hifzh al-Usrah) — Membangun madrasah keluarga yang hangat dan berpegang pada sunnah.
- Lapisan 3: Majelis & Sahabat Sejati (Ashhab ash-Shidq) — Komunitas talaqqi yang menjaga adab dan sanad.
- Lapisan 4: Sikap terhadap Publik (Al-'Ammah) — Menahan diri dari perdebatan liar dan fitnah medsos.

Obat Apocalyptic Anxiety (Kecemasan Kiamat):
1. Mengharamkan cocokologi (al-isqath al-mubasyir) yang menebak-nebak tanggal kiamat.
2. Mewajibkan sikap sabar mengamati (al-intizhar wat-tarakqub).
3. Menanamkan optimisme amal: Tetap menanam bibit kebajikan meski kiamat terjadi di depan mata.

--------------------------------------------------------------------------------
[TABEL KOMPARASI: SEBELUM VS SESUDAH MEMAHAMI FIKIH TAHAWWULAT]
1. Nalar Ilmiah:
   - Sebelum: Kaku memaksakan teks hukum ibadah untuk menghakimi realitas sosial yang rumit.
   - Sesudah: Menjaga teks syariat tetap murni seraya luwes membaca pergeseran peradaban zaman.
2. Teknologi & AI:
   - Sebelum: Terbelah ekstrem antara menolak total atau menelan mentah-mentah hingga hilang adab.
   - Sesudah: Kaidah Al-Ightinam: merebut teknologi dan AI untuk khidmat ilmu turats secara selamat.
3. Gaya Dakwah:
   - Sebelum: Suka memvonis dan mencaci; menganggap masyarakat sebagai lawan yang harus dihantam.
   - Sesudah: Dokter penolong yang merangkul; menyelamatkan korban sistem zaman yang rusak.
4. Fitnah Politik:
   - Sebelum: Fanatik buta golongan dan mengeksploitasi ayat agama untuk politik praktis.
   - Sesudah: Manhaj as-Salamah: lisan bersih dari mencela, tangan bersih dari menumpahkan darah.
5. Keluarga:
   - Sebelum: Sibuk berdebat di media sosial hingga anak-istri di rumah terbengkalai.
   - Sesudah: Al-Khuwaishah: membentengi rumah tangga dan majelis sebagai shelter rohani yang kokoh.
6. Kondisi Batin:
   - Sebelum: Gampang panik dan stres (apocalyptic anxiety) akibat dicekoki ramalan kiamat viral.
   - Sesudah: Hati tenang (sakinah); yakin sejarah dalam takdir Allah dan optimis giat beramal saleh.

--------------------------------------------------------------------------------
[KURIKULUM 6 KITAB QAWA'ID POKOK]
1. Tingkat 1 (Pemula): An-Nubżah aṣ-Ṣughrā (النُّبْذَةُ الصُّغْرَى)
   Gerbang awal pemahaman definisi, dalil Hadis Jibril, dan klasifikasi tanda kiamat.
2. Tingkat 2 (Siklus Sejarah): Dawā'ir al-I'ādah (دَوَائِرُ الإِعَادَةِ)
   Kaidah siklus pengulangan sejarah peradaban manusia dalam lingkaran takdir azali.
3. Tingkat 3 (Kunci Cabang): Al-Iqlīd (الإِقْلِيدُ فِي فَتْحِ أَبْوَابِ العُلُومِ)
   Kaidah operasional 5 cabang ilmu turunan Fikih Tahawwulat & antisipasi krisis.
4. Tingkat 4 (Sikap Kenabian): At-Talīd wat-Ṭarīf (التَّلِيدُ وَالطَّارِفُ)
   Syarah atas kaidah Sunnah al-Mawaqif dan Manhaj as-Salamah para salafus shalih.
5. Tingkat 5 (Ikhtisar Padat): Al-Mukhtaṣar al-Ḥabīk / Siyāḥatul Fikr (المُخْتَصَرُ الحَبِيك)
   Peta konsep dakwah terpadat, kaidah pergerakan, dan nalar kritis terhadap ideologi modern.
6. Tingkat 6 (Puncak Induk): Al-Usūs wal-Munṭalaqāt (الأُسُسُ وَالمُنْطَلَقَاتُ)
   Kitab ensiklopedis babon setebal ratusan halaman; rujukan tertinggi kaidah istinbath.

--------------------------------------------------------------------------------
[5 BILIK SUPER AI OPENTURATH - SPESIALIS FIKIH TAHAWWULAT]
1. Al-Muhaqqiq (المحقق) — Penjaga Teks Matan & Ibarah
   Fungsi: Verifikasi redaksi Arab asli mualif, mencocokkan kutipan matan, serta rujukan presisi ke nama kitab, jilid, dan nomor halaman.
2. Al-Bayan (البيان) — Pensyarah Konsep & Istilah Baru
   Fungsi: Mengurai istilah rumit (mustalahat mubtakarah) ke bahasa yang mudah dicerna, analogi modern, dan peta pemikiran komprehensif.
3. Al-Mukhtabir (المختبر) — Ujian Nalar & Kaji Kasus Interaktif
   Fungsi: Mitra diskusi dan penguji pemahaman ilmiah; menyajikan studi kasus fitnah zaman untuk memastikan nalar tetap lurus dan bebas cocokologi.
4. Al-Habib (الحبيب) — Arsip Muhadharah & Sentuhan Ruhani
   Fungsi: Menghadirkan kehangatan nada lisan dari ribuan jam rekaman ceramah mualif, tausiyah penyejuk batin, serta bimbingan adab tazkiyatun nufus.
5. Al-Khatib (الخطيب) — Penyusun Materi Khutbah & Dakwah
   Fungsi: Formulasi materi khutbah Jumat, panduan dakwah di era krisis, materi tabligh tematik, serta narasi penyejuk umat di tengah polarisasi.
"""
    out.write(in_app_text.strip() + '\n\n')

    # ── BAGIAN III ──
    out.write('=' * 84 + '\n')
    out.write('BAGIAN III: BLUEPRINT DESAIN, SPESIFIKASI KORPUS MAHKOTA & 5 BILIK SUPER AI\n')
    out.write('=' * 84 + '\n\n')
    out.write(desain_content.strip() + '\n\n')

    # ── BAGIAN IV ──
    out.write('=' * 84 + '\n')
    out.write('BAGIAN IV: KATALOG KANONIKAL 58 KITAB FIKIH TAHAWWULAT RESMI\n')
    out.write('Koleksi Terpadu Karya Al-Habib Abu Bakar Al-Adni bin Ali Al-Masyhur di OpenTurath AI\n')
    out.write('=' * 84 + '\n\n')

    for idx, b in enumerate(katalog_books, 1):
        kitab_arab = b.get('الكتاب', b.get('الاسم_المختصر', '-'))
        penulis = b.get('المؤلف', 'الحبيب أبو بكر العدني بن علي المشهور')
        muhaqqiq = b.get('المحقق_أو_المعتني', '-')
        penerbit = b.get('الناشر', '-')
        tahun = b.get('سنة_الطبع', '-')
        jilid = b.get('عدد_الأجزاء', '1')
        halaman = b.get('عدد_الصفحات', '-')
        kategori = b.get('القسم', 'فقه التحولات')

        can = next((c for c in canonical_books if c.get('id') == b.get('id') or c.get('title') == kitab_arab), {})
        full_title = can.get('title', kitab_arab)

        out.write(f'--- [KITAB {idx:02d} DARI 58] ---\n')
        out.write(f'Judul Kitab (Arab)  : {kitab_arab}\n')
        if full_title and full_title != kitab_arab:
            out.write(f'Nama Lengkap        : {full_title}\n')
        out.write(f'Pengarang           : {penulis}\n')
        out.write(f'Muhaqqiq / Pentahqiq: {muhaqqiq}\n')
        out.write(f'Kategori / Bidang   : {kategori}\n')
        out.write(f'Penerbit            : {penerbit}\n')
        out.write(f'Tahun / Cetakan     : {tahun}\n')
        out.write(f'Jumlah Jilid        : {jilid} Jilid\n')
        out.write(f'Jumlah Halaman      : {halaman} Halaman\n')
        out.write('\n')

size_kb = os.path.getsize(output_path) / 1024
print(f'Successfully generated {output_path} ({size_kb:.1f} KB)')
