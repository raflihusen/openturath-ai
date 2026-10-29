# Audit UI/UX — Takhrij Hadits (`/Users/apple/Downloads/khademhrf`)

Tanggal: 29 Oktober 2026. Pemeriksa: Claude (Sonnet 5.5), atas permintaan Pemilik.

## 0. Batas audit (baca dulu)

Yang saya periksa: kode layar utama (`khadem_shell_screen`, `khadem_overview_screen`, `hadith_takhrij_workspace_screen`, `khadem_library_screen` sebagian, label `khadem_rijal_mawsuah_screen`, `usage_guide`, `localization`), `progres.md`, README, dan satu screenshot layar Meja Takhrij dari Pemilik.

Yang **tidak** saya lakukan: menjalankan aplikasi, mengklik alurnya, menguji VoiceOver, mengukur performa. Temuan yang bersumber dari screenshot atau dari membaca kode ditandai. Hal yang perlu dicek langsung di aplikasi diberi tanda **[uji]**.

Basis data dan mesin takhrij tidak diaudit di sini. `progres.md` mencatat verifikasi ilmiahnya; audit ini hanya soal antarmuka dan alur.

## 1. Diagnosis inti (satu paragraf)

Aplikasinya **kuat secara isi, tetapi disusun menurut struktur data, bukan menurut tugas pengguna**. Ada 245 kitab, 100 tabel, 27 kaidah, 5 mode kajian, dan 7 destinasi; semuanya tampil sejak awal, dengan istilah ahli yang tidak dijelaskan (muhmal, madar, syawahid, mujamma'). Pengguna baru tidak tahu harus mulai dari mana, dan pengguna ahli tidak punya satu jalur yang rapi dari "saya ingat sebagian lafaz" sampai "naskah takhrij siap salin". Kesan mengintimidasi datang dari tiga hal: terlalu banyak pintu masuk sekaligus, kosakata yang tidak konsisten, dan tampilan teks Arab yang padat dengan tiga gaya huruf yang bersaing.

## 2. Peta aplikasi saat ini

Sidebar (6 + 1): Beranda · Kitab & Syarah · Takhrij & Sanad · Rijal · Indeks · Catatan · (bawah) Pengaturan. Tersembunyi: Panduan (tombol teks di Beranda), Cmd-K.

Alur inti yang dimaksud pembuat (dari `usage_guide.dart`): Beranda → cari lafaz → Meja Takhrij → pilih riwayat → periksa sumber → (opsional 5 mode) → Susun naskah takhrij → salin/simpan ke Catatan.

Di dalam Meja Takhrij, satu layar memuat: panel pencarian 320 px, bilah tab kajian (maks. 5), tiga baris teks langkah, 5 chip mode, lalu isi mode (dengan sub-chip tambahan di mode Takhrij: Lokasi sumber / Bukti perbandingan).

## 3. Temuan

Tingkat: **T** = tinggi (menghambat tugas utama atau membuat pengguna tersesat), **S** = sedang, **R** = rendah (kerapian).

### 3.1 Struktur dan navigasi

| # | Tk | Temuan | Bukti | Akibat |
|---|----|--------|-------|--------|
| N1 | T | **Dua makna "Indeks".** Di sidebar "Indeks" berarti fihris tematik (Tema, Koleksi & Ulum). Di panel pencarian "indeks" berarti indeks teks lengkap yang disiapkan (progres, jeda, lanjut). | `shell:183-186`, `workspace:1003-1028` | Pengguna membaca "Indeks belum siap" lalu mencari menu Indeks di sidebar. |
| N2 | T | **Nama destinasi yang sama berbeda di tiap tempat**: "Meja Takhrij" (judul), "Takhrij & Sanad" (menu), "Telaah Takhrij" (tombol di pembaca), "Buka meja penelitian" (Beranda), "kajian", "studi", "مكتب البحث". | `workspace:842`, `localization:22`, `library:607`, `overview:204` | Pengguna tidak yakin semuanya tempat yang sama. |
| N3 | T | **Rijal & Indeks tumpang tindih.** Layar Rijal punya mode Perawi / Tema / Ensiklopedia, sementara sidebar sudah punya Indeks (Tema / Koleksi). "Ensiklopedia" (id) = "Collections" (en) = "الموسوعات" (ar) = "Koleksi & Ulum" (sidebar). | `rijal:337-345`, `shell:145-153` | Satu isi, dua pintu, empat nama. |
| N4 | S | **Beranda punya tujuh jalan ke tiga tujuan**: 3 chip cakupan + kolom cari + ikon panah + tombol besar + 3 tombol outline + tombol panduan. Tombol "Cari perawi" muncul dua kali (chip dan outline). | `overview:127-219` | Tidak ada satu aksi utama yang jelas. |
| N5 | S | Cmd-K **memindahkan** pengguna ke Beranda, bukan membuka pencarian di tempat. Pengguna yang sedang membaca kehilangan konteksnya. Hanya macOS. | `shell:78-83` | Terasa seperti tersesat, bukan jalan pintas. |
| N6 | S | Panduan hanya satu tombol teks kecil di dasar Beranda. Tidak ada tur pertama, tidak ada "?" yang tersedia di layar lain. | `overview:214-219` | Bantuan tidak ada di tempat orang bingung (Meja Takhrij). |
| N7 | R | Logo di sidebar masih logo OpenTurath (lengkung + kitab), nama "Takhrij Hadits" hanya tampil saat sidebar lebar. | `shell:211-216` | Identitas produk belum terpisah. |

### 3.2 Meja Takhrij (layar yang paling membingungkan)

| # | Tk | Temuan | Bukti | Akibat |
|---|----|--------|-------|--------|
| W1 | T | **Tiga langkah dijelaskan dengan tiga teks kecil terpisah** ("1 · Cari → 2 · Pilih riwayat" di panel kiri, "3 · Periksa riwayat dan sumber" di area kanan), bukan satu penunjuk langkah yang tetap. | `workspace:954-959`, `1154-1159` | Pengguna tidak tahu sedang di langkah berapa dan berapa lagi. |
| W2 | T | **Lima mode dengan nama ahli sebagai chip sejajar**: Takhrij · Sanad · Matan & Syarah · Muhmal · Makalah. Muhmal (perawi bernama sama yang belum jelas) dan Makalah (pemindai teks makalah) adalah alat khusus, bukan tampilan hasil; letaknya sejajar dengan tampilan inti. | `workspace:1197-1205` | Pengguna mengira semua chip sama-sama "hasil" dan mengkliknya tanpa tahu fungsinya. |
| W3 | T | **Label Arab "Makalah" = `البحث`**, sama persis dengan tombol "Pencarian" di atasnya. | `workspace:849`, `1204` | Di UI berbahasa Arab ada dua tombol "البحث" dengan fungsi berbeda. |
| W4 | T | Panel pencarian **tetap terbuka** (320 px) setelah hasil dipilih, sehingga area kajian sempit, sementara tombol "Pencarian" harus ditekan lagi untuk menutupnya. Pada lebar < 1000 px panel jadi 280 px tinggi di atas. | `workspace:928-943` | Ruang baca terpotong tepat saat pengguna ingin membaca. |
| W5 | S | Header berisi 3 tombol sejajar (Pencarian, Masukan manual, Susun naskah takhrij). "Susun naskah takhrij" adalah **tujuan akhir** tapi diperlakukan seperti tombol biasa di baris atas, dan hanya muncul pada mode Takhrij. | `workspace:845-860` | Pengguna di mode Sanad tidak melihat jalan menuju tujuannya. |
| W6 | S | Baris keterangan "Pendalaman: sanad dan perawi · variasi matan dan syarah · …" adalah paragraf kecil yang mengulang nama chip tepat di atasnya. | `workspace:1183-1188` | Teks tambahan yang menambah bising tanpa menjelaskan. |
| W7 | S | Pada mode Sanad dan Matan & Syarah, pengguna harus menekan "Muat rincian sumber" dulu; pada Sanad harus "Muat 25 sumber berikutnya". | `workspace:1141-1147`, `1243` | Terasa seperti kerja ekstra. Mengapa tidak otomatis dimuat setelah klik mode? |
| W8 | S | Tab kajian dibatasi lima tanpa pesan. **[uji]** apa yang terjadi saat tab keenam dibuka. | `progres.md:166` | Aksi gagal tanpa penjelasan, bila memang begitu. |
| W9 | S | Hasil pencarian ditampilkan sebagai **potongan 3 baris + "…"** di kolom 320 px. Untuk memilih riwayat yang benar, pengguna hampir selalu harus membuka dulu. | `workspace:1059-1075`, screenshot | Memilih riwayat memerlukan klik, baca, kembali. |
| W10 | S | Tombol "+" (buka tab baru) tanpa label hanya ikon; fungsi dijelaskan di teks kosong-keadaan, bukan di tempatnya. | `workspace:1079-1087`, `1121` | Tidak bisa ditemukan. |
| W11 | R | Satu halaman memakai kata "kajian", "studi", "telaah", "riwayat", "rekaman" untuk hal yang sama (satu hadis yang sedang dipelajari). | `workspace` banyak | Kosakata tidak konsisten. |

### 3.3 Pembaca (Kitab & Syarah)

| # | Tk | Temuan | Akibat |
|---|----|--------|--------|
| L1 | S | Judul layar + 5 tombol (Daftar kitab, Daftar isi, Edisi & bibliografi, Sumber terkait, Telaah Takhrij) berjajar sebagai bilah aksi. Dua tombol terakhir **muncul dan hilang** menurut isi yang dipilih, sehingga letak tombol bergeser. | Tidak stabil; pengguna harus mencari ulang. |
| L2 | S | Tiga kolom (daftar kitab 280 px, daftar isi, pembaca, ditambah panel inspektor) pada jendela 13 inci menyisakan area baca sempit. Pengaturan tutup/buka ada, tetapi tidak diingat per sesi **[uji]**. | Pembaca teks Arab panjang mendapat kolom sempit. |
| L3 | S | "Hadis Saja" / "Bab & Hadis" dan field "No. Hadis / Juz / Hlm" tanpa penjelasan hubungan ketiganya. | Pengguna tidak tahu nomor mana yang dimaksud (nomor edisi tertentu). |

### 3.4 Tampilan teks Arab (lihat juga saran font sebelumnya)

| # | Tk | Temuan | Akibat |
|---|----|--------|--------|
| T1 | T | **Tiga gaya Arab bersaing** di satu layar: Cairo untuk UI, Naskh tipis untuk kartu hasil dan blok konteks, Naskh tebal untuk blok متن المجمع. Tebal dipakai untuk matan, sehingga tebal tidak lagi bermakna "sorotan". | Mata tidak tahu mana yang utama. |
| T2 | S | Teks yang di-*justify* menghasilkan celah lebar di tengah baris; spasi di sekitar `،` dan `.` terlalu longgar; kotak "وفي رواية" dan `[وآلِه]` memotong baris di tengah matan. | Bacaan putus-putus. |
| T3 | S | Label sumber ("المستدرك على الصحيحين · 8535") memakai bobot dan ukuran yang hampir sama dengan matan. | Keterangan tidak terbedakan dari isi. |

### 3.5 Pertama kali dipakai dan keadaan khusus

| # | Tk | Temuan | Bukti | Akibat |
|---|----|--------|-------|--------|
| F1 | T | **Tidak ada onboarding.** Pengguna pertama langsung ke Beranda dengan tiga chip dan satu kolom cari. | grep `onboard` kosong | Tidak tahu bahwa ini alat takhrij ilmiah, bukan mesin pencari hadis. |
| F2 | T | **Indeks teks lengkap dibangun pada pencarian pertama** (satu pengukuran 254 detik di mesin pengembang; belum tentu sama di Mac pemilik). Progres tampil di dalam panel pencarian Meja Takhrij, bukan di tempat global. Pengguna yang mencari dari Beranda tidak melihat apa pun sampai pindah layar. | `progres.md:117`, `workspace:1003-1022` | Terlihat seperti aplikasi macet. |
| F3 | S | Basis data 1,38 GB + 579 MB dikemas dalam DMG 937 MB. Tidak ada layar yang menjelaskan ukuran, lokasi, atau apa yang terjadi bila basis data hilang selain pesan galat singkat. **[uji]** | README | Skenario pemindahan/perbaikan tidak dijelaskan ke pengguna. |
| F4 | S | Hasil nol ditangani dengan baik pada pesan ("Tidak ada hasil pada cakupan ini"), tetapi tidak menawarkan **tindakan** (coba tanpa harakat, hapus filter, cari per kata, cari di semua kitab). | `workspace:1050-1058` | Jalan buntu. |
| F5 | S | Tiga status asal data (dari sumber / masukan peneliti / saran algoritmik) dijaga dengan baik di kode, tetapi tampil sebagai kalimat kecil di beberapa tempat, bukan sebagai penanda visual yang konsisten. | `workspace:1175-1181` | Integritas ilmiah yang bagus tidak terlihat oleh pengguna. |

## 4. Jalur UI/UX yang diusulkan

### 4.1 Prinsip

1. **Satu tugas utama, satu jalan utama.** Tugas utamanya: *dari ingatan sebagian lafaz sampai naskah takhrij yang siap dipakai.* Jalan itu harus terlihat sebagai satu garis, bukan tujuh pintu.
2. **Ungkap bertahap.** Alat khusus (muhmal, makalah, 27 kaidah) ada, tetapi tidak sejajar dengan hasil inti. Pemula melihat tiga langkah; ahli membuka "Alat lanjutan".
3. **Satu nama untuk satu hal.** Ditetapkan: **Kajian** (satu hadis yang sedang diteliti), **Pustaka** (kitab dan syarah), **Fihris** (daftar tematik), **Indeks pencarian** (hanya untuk status teknis).
4. **Asal data selalu terlihat**, dengan tiga penanda tetap (lihat 4.5).
5. **Tidak ada jalan buntu**: setiap kosong/galat menawarkan langkah berikutnya.

### 4.2 Struktur navigasi

Dari 6 + 1 menjadi **4 + 1**, dengan Kajian sebagai pusat:

```
Sidebar
  Cari          ← Beranda + pencarian (default). Ini jalan masuk Kajian.
  Pustaka       ← Kitab & Syarah + Fihris tematik (tab di dalamnya)
  Perawi        ← Rijal (pencarian dan profil)
  Catatan       ← Catatan, naskah tersimpan, backup
  ─────────
  Pengaturan    ← termasuk Bantuan dan Tentang
  (?)           ← ikon bantuan selalu ada di bilah atas, kontekstual per layar
```

Kajian bukan lagi destinasi sidebar; ia **muncul sebagai halaman penuh** saat pengguna memilih riwayat, dengan tombol kembali ke hasil. Kajian yang sedang dikerjakan (maks. 5) tetap bisa dilanjutkan dari kartu "Lanjutkan kajian" di Cari dan dari bilah tab di atas isi.

### 4.3 Layar Cari (Beranda) yang ramping

```
┌──────────────────────────────────────────────────────────┐
│                                              (?)  ⌘K     │
│                                                          │
│        Telusuri hadis. Periksa sumbernya.                │
│                                                          │
│   [ Hadis | Kitab | Perawi ]      ← segmen satu baris    │
│   ┌────────────────────────────────────────────┐ [Cari]  │
│   │ 🔍 Ketik sebagian lafaz, mis. الأحلاس      │         │
│   └────────────────────────────────────────────┘         │
│   Contoh:  إنما الأعمال بالنيات   ·  الأحلاس   ·  …       │
│                                                          │
│   Lanjutkan kajian                                       │
│   ┌──────────────┐ ┌──────────────┐                      │
│   │ المستدرك 8535│ │ مسند أحمد …  │   ← kartu kecil      │
│   └──────────────┘ └──────────────┘                      │
│                                                          │
│   ● Basis data siap · 245 kitab · indeks pencarian 100%  │
└──────────────────────────────────────────────────────────┘
```

Yang dibuang dari Beranda: tombol besar ganda, tiga tombol outline, tombol panduan teks. Yang dipertahankan: tiga cakupan, kolom cari, catatan "hasil algoritmik perlu telaah" (pindah ke bawah kolom sebagai teks kecil).

### 4.4 Layar Kajian

Satu **penunjuk langkah tetap** di atas, bukan tiga teks terpisah:

```
 ①Cari  ──  ②Pilih riwayat  ──  ③Periksa sumber  ──  ④Susun naskah
```

Setelah riwayat dipilih, panel hasil **menyusut menjadi lajur sempit** yang bisa dibuka lagi, dan area utama:

```
┌ Kajian: المستدرك 8535 ▾  (tab ke-2 dari 3)            [Susun naskah ▸]
│
│  ┌ Ringkasan ┬ Sumber ┬ Sanad ┬ Matan & Syarah ┬ Alat lanjutan ▾ ┐
│  │
│  │   Matan (teks utama, font Naskh, tidak tebal)
│  │   ┌──────────────────────────────────────────────┐
│  │   │ كُنَّا عِنْدَ رَسُولِ اللَّهِ …              │
│  │   └──────────────────────────────────────────────┘
│  │   [Dari sumber]  المستدرك 4/466 · رقم 8535 · ط. …
│  │
│  │   Ditemukan di 7 kitab · 12 lokasi · 3 jalur sanad
│  │   ▸ المستدرك  ▸ مسند أحمد  ▸ سنن أبي داود  …   (daftar kitab)
│  └
└ Tombol tetap di dasar:  [ Salin ]  [ Simpan ke Catatan ]  [ Susun naskah ▸ ]
```

Perubahan konkret:

1. **Ringkasan** jadi tab pertama dan default. Ia menjawab pertanyaan awal: *"hadis ini ada di mana saja dan dalam berapa jalur?"* Sekarang pengguna langsung dilempar ke "Lokasi sumber" yang panjang.
2. **Alat lanjutan** (Muhmal, Makalah) dipindah ke satu menu, dengan satu kalimat penjelas tiap alat ("Perawi bernama sama? Cari yang paling mungkin.", "Tempel makalah Anda; kami periksa takhrij di dalamnya.").
3. **Sumber dan Sanad dimuat otomatis** setelah tab dipilih (dengan progres dan tombol batal), bukan menunggu klik "Muat rincian".
4. **Aksi akhir** ("Susun naskah") tetap di dasar di semua tab, bukan hanya di mode Takhrij.
5. **Judul kajian** menampilkan kitab + nomor, tab kajian lain ditaruh di atas dengan batas lima yang dijelaskan ("Maksimal 5 kajian terbuka. Tutup satu untuk membuka yang baru.").

### 4.5 Penanda asal data (selalu sama)

| Penanda | Arti | Tampilan |
|---------|------|----------|
| **Dari sumber** | Teks dan metadata dari basis data kitab | Chip abu netral |
| **Masukan peneliti** | Diketik/ditempel pengguna; belum diverifikasi | Chip bergaris putus |
| **Saran algoritmik** | Hasil mesin yang perlu ditelaah | Chip dengan ikon ⚠︎ dan tooltip "Perlu telaah" |

Tetap monokrom, sesuai bahasa desain OpenTurath (tanpa warna aksen).

### 4.6 Istilah dan bantuan

- **Glosarium bertooltip** pada istilah ahli (madar, syawahid, mujamma', muhmal, thabaqat). Sentuh atau arahkan kursor menampilkan satu kalimat Indonesia + Arab + Inggris. Bukan modal panjang.
- **Perbaiki label**: "Makalah" → "Periksa makalah" (Arab: `فحص البحث`, bukan `البحث`); "Muhmal" → "Perawi samar (مهمل)"; "Indeks" di panel pencarian → "Indeks pencarian"; "Ensiklopedia/Koleksi & Ulum" → satu nama, "Koleksi".
- **Bantuan kontekstual**: ikon "?" di bilah atas membuka panel ringkas **khusus layar itu** (3 langkah + 1 catatan), bukan seluruh panduan. Panduan lengkap tetap ada di Pengaturan.

### 4.7 Tampilan teks Arab

- Dua peran saja: **UI = Noto Sans Arabic**, **teks ilmiah = Amiri** (matan, syarah, isnad). Ukuran 24–26 / 20 / 14–15 px; tinggi baris Arab ±2,1.
- Matan tidak tebal. Tebal hanya untuk kata yang dicari.
- Latar putih dengan garis tipis sisi kanan sebagai penanda blok; hapus latar abu.
- Perbedaan riwayat (`وفي رواية`) jadi baris di bawah blok atau chip UI, bukan kotak di tengah baris.
- Matikan *justify* untuk Arab; rapatkan spasi di sekitar tanda baca.

## 5. Skenario: sudah/belum tertangani

Kolom "Status" berdasarkan pembacaan kode; **[uji]** = perlu dicoba di aplikasi.

### 5.1 Pertama kali dan pemeliharaan

| # | Skenario | Status | Yang diusulkan |
|---|----------|--------|----------------|
| S1 | Pertama kali dibuka, tidak tahu harus apa | Tidak tertangani | Tur 3 kartu + contoh pencarian di Cari |
| S2 | Mencari pertama kali, indeks belum ada | Ada progres di panel Meja Takhrij, tidak di Beranda | Chip status global; perkiraan waktu; boleh membaca kitab sambil menunggu |
| S3 | Indeks dijeda lalu aplikasi ditutup | Ada resume **[uji]** | Pesan jelas saat dibuka lagi |
| S4 | Basis data hilang atau korup | Pesan galat singkat | Layar pemulihan: lokasi yang dicek, cara memperbaiki, tombol "Cek ulang" |
| S5 | Disk hampir penuh saat membangun indeks (±1,7 GB) | Tidak terlihat dalam kode | Cek ruang sebelum mulai |
| S6 | Pembaruan basis data / versi aplikasi | Tidak terlihat | Info versi + cara memperbarui di Pengaturan |
| S7 | Pindah bahasa (id/en/ar) di tengah kajian | Ada animasi; isi tetap **[uji]** | Pastikan tidak mereset kajian dan arah tata letak benar |

### 5.2 Mencari dan memilih

| # | Skenario | Status | Yang diusulkan |
|---|----------|--------|----------------|
| S8 | Ingat sebagian lafaz tanpa harakat | Tertangani (normalisasi) | — |
| S9 | Salah eja / variasi lafaz | Hasil nol, tanpa saran | Saran: coba kata tunggal, hapus awalan, "Cari mirip" |
| S10 | Hasil terlalu banyak (>45) | Paginasi 45 | Filter kitab/jenis, pengurutan |
| S11 | Mencari berdasarkan nomor hadis atau kitab | Ada "Lompat" di Pustaka **[uji]** | Ikat ke satu kolom cari ("Bukhari 1", "No. 8535") |
| S12 | Mencari nama perawi | Ada di Rijal | Dari hasil Kajian: klik perawi → profil, kembali tetap di kajian |
| S13 | Perawi bernama sama (mis. سفيان) | Ada mode Muhmal | Muncul otomatis sebagai peringatan di sanad, bukan hanya menu |
| S14 | Satu hadis punya banyak riwayat | Daftar hasil per rekaman | Kelompokkan per hadis, tampilkan matan penuh ringkas |
| S15 | Pengguna ingin hukum hadis (sahih/dhaif) | App menampilkan kutipan hukum ulama, tidak memberi vonis | Pesan eksplisit di Ringkasan: "Aplikasi ini mengumpulkan rujukan; ia tidak menetapkan derajat hadis." |

### 5.3 Mengkaji

| # | Skenario | Status | Yang diusulkan |
|---|----------|--------|----------------|
| S16 | Membuka hadis dari pembaca ke Kajian | Ada (`onOpenInTakhrijWorkspace`) | Tombol kembali ke kitab dan halaman yang sama |
| S17 | Membuka 6 kajian | Dibatasi 5; pesan **[uji]** | Pesan jelas + pilihan menutup yang paling lama |
| S18 | Memuat sumber ratusan lokasi (255 lokasi, 318 sanad) | Ada pemuatan bertahap | Otomatis, dengan progres dan batal |
| S19 | Membatalkan pemuatan di tengah | Ada tombol Batal | Pastikan state tidak rusak |
| S20 | Hadis tanpa sanad atau tanpa sumber lain | Sebagian | Pesan "Tidak ditemukan riwayat lain" + alasan yang mungkin |
| S21 | Masukan manual (hadis tidak ada di korpus) | Ada, ditandai masukan peneliti | Masuk sebagai kajian dengan penanda jelas |
| S22 | Jendela diperkecil (<1000, <900 px) | Layout berubah, panel 280 px di atas | **[uji]** pada MacBook 13", jendela setengah layar |
| S23 | Mengganti tema saat memuat | Animasi circular reveal | **[uji]** tidak memotong pekerjaan |

### 5.4 Menyusun, menyimpan, dan kehilangan

| # | Skenario | Status | Yang diusulkan |
|---|----------|--------|----------------|
| S24 | Menyusun naskah takhrij (ringkas/sedang/terperinci) | Ada, dengan pratinjau | Satu tombol di dasar semua tab |
| S25 | Format sitasi (gaya Indonesia vs Arab; edisi mana) | Satu formatter bersama | Pilihan gaya dan edisi di Pengaturan, tampil di pratinjau |
| S26 | Mengekspor ke Word/PDF | Salin teks dan simpan ke Catatan | Ekspor `.docx` dengan RTL benar |
| S27 | Catatan dan backup/restore | Ada; simpan native perlu konfirmasi manual (progres.md) | Selesaikan konfirmasi ini; "Simpan terakhir" dengan cap waktu |
| S28 | Aplikasi tertutup mendadak | Kajian terbuka tidak tampak dipulihkan | Pulihkan kajian terakhir setelah crash |
| S29 | Dua jendela/sesi memakai database yang sama | Ada kunci indeks | Pesan "Indeks dibangun sesi lain" (sudah ada) |

### 5.5 Aksesibilitas dan perangkat

| # | Skenario | Status | Yang diusulkan |
|---|----------|--------|----------------|
| S30 | Pengguna hanya papan ketik | Cmd-K ada; selebihnya **[uji]** | Urutan Tab, tombol Esc menutup panel, panah antar tab |
| S31 | VoiceOver | Hanya `Semantics(selected)` di sidebar | Label pada tombol ikon (+ , ✕), judul bagian |
| S32 | Teks Arab diperbesar | Tidak ada kontrol ukuran huruf | Ukuran teks Arab sendiri (S/M/L) di Pengaturan |
| S33 | Kontras mode gelap | **[uji]** | Periksa abu-abu pada teks sekunder |
| S34 | Windows atau Linux | Cmd-K hanya Mac | Ctrl-K sebagai alternatif bila nanti dirilis lintas platform |

## 6. Rencana bertahap

| Tahap | Isi | Risiko | Perkiraan |
|-------|-----|--------|-----------|
| **A. Kosakata dan label** (tanpa ubah struktur) | N1, N2, N3, W3, W11; satu glosarium; perbaiki label Arab | Sangat rendah | 0,5 hari |
| **B. Tipografi Arab** | T1–T3: Noto Sans Arabic + Amiri, peran, ukuran, hapus latar abu, riwayat sebagai baris | Rendah; cek bundel font dan lisensi | 1 hari |
| **C. Layar Cari** | N4, N5, N6, F1: ramping, contoh pencarian, kartu "Lanjutkan kajian", tur pertama, status global indeks | Rendah | 1–1,5 hari |
| **D. Kajian** | W1, W2, W4–W10: penunjuk langkah, tab Ringkasan, Alat lanjutan, muat otomatis, aksi di dasar, panel hasil menyusut | **Sedang**: menyentuh layar 1.546 baris | 3–4 hari |
| **E. Struktur navigasi** | 6+1 → 4+1; Pustaka menyatukan Kitab dan Indeks; Kajian jadi halaman penuh | Sedang | 2–3 hari |
| **F. Keadaan khusus dan aksesibilitas** | S4, S5, S9, S17, S28, S30–S32; pemulihan kajian | Sedang | 2–3 hari |

Urutan yang disarankan: **A → B → C**, lalu putuskan D/E setelah Pemilik melihat hasil A–C di aplikasi nyata. Tahap A–C bisa dikerjakan tanpa mengubah satu pun logika basis data atau mesin takhrij.

## 7. Yang perlu dikonfirmasi Pemilik

1. **Pengguna sasaran utama.** Penuntut ilmu pemula, atau peneliti/dosen yang sudah paham takhrij? Ini menentukan seberapa banyak istilah ahli yang boleh tampil di permukaan. Rekomendasi: rancang untuk peneliti yang tidak hafal nama alat, bukan untuk pemula yang tidak tahu apa itu takhrij.
2. **Apakah Kajian sebaiknya menjadi halaman penuh** (usulan 4.2), atau tetap destinasi sidebar seperti sekarang.
3. **Apakah aplikasi boleh menyatakan "derajat hadis"** dari kutipan hukum ulama (S15), atau hanya mengumpulkan rujukan. Kode sekarang sengaja menghindari vonis; saya mengusulkan itu dipertahankan dan dinyatakan terang-terangan.
4. **Mac apa yang menjadi sasaran** (13" atau 16"): menentukan layout tiga kolom.

## 8. Ringkasan yang bisa dikerjakan sekarang

Tanpa menyentuh logika: samakan istilah (A), pisahkan peran huruf (B), ramping Beranda (C). Dari 10 temuan tingkat Tinggi (N1, N2, N3, W1, W2, W3, W4, T1, F1, F2), tahap A–C menutup tujuh (N1, N2, N3, W3, T1, F1, F2). Tiga sisanya (W1, W2, W4) ada di layar Kajian dan baru tertangani pada tahap D.
