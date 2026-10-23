# Bahasa Desain OpenTurath

Versi 1.0 · 23 Oktober 2026 · Sumber kebenaran: website V7.x (`website/redesign-v7/site/assets/css/site.css`, `site.js`).
Dokumen ini merangkum seluruh bahasa desain website supaya dapat diterapkan ke materi lain: OpenTurath Academy, slide, poster, video, dan dokumen.

Nama tema: **Monochrome Editorial, The Quiet Islamic Scholar.** Tenang, bersih, berwibawa, dan tidak ramai. Terinspirasi struktur antigravity.google, dengan palet monokrom OpenTurath.

---

## 1. Prinsip

1. **Satu gagasan per layar.** Setiap bagian punya satu judul, satu kalimat pengantar, lalu isi. Tidak ada bagian yang menjelaskan dua hal.
2. **Monokrom murni.** Hitam, putih, dan abu netral. Tidak ada aksen warna (oranye, kuning, hijau, biru). Hirarki dibuat oleh ukuran, bobot, jarak, dan kontras terang-gelap, bukan warna.
3. **Sudut bulat besar, garis sedikit.** Bentuk lunak dan lapang. Kartu dibedakan oleh isi (fill), bukan bingkai tebal. Bingkai tebal hanya untuk satu hal: judul bagian (kicker).
4. **Tenang bergerak.** Gerak pelan, mengalun, dan bermakna. Tidak ada efek yang membuat pusing, berkedip, atau memaksa perhatian.
5. **Sumber di depan.** Teks Arab dan rujukan tampil sebagai bagian utama, bukan hiasan. Arab selalu pakai huruf naskh yang besar dan lapang.
6. **Fitur, bukan disclaimer.** Yang tampil menonjol adalah apa yang OpenTurath lakukan. Peringatan seperti "bukan pengganti guru" tinggal di halaman Pedoman dan Panduan, bukan di hero atau daftar keunggulan.
7. **Tiga bahasa setara.** Indonesia, Inggris, dan Arab (RTL) dirancang bersama, bukan terjemahan belakangan.

---

## 2. Warna

### 2.1 Token terang (default)

| Token | Nilai | Pemakaian |
|---|---|---|
| `--surface` | `#FFFFFF` | Latar halaman |
| `--container` | `#F8F9FC` | Kartu berisi |
| `--container-low` | `#EFF2F7` | Hover kartu, tombol tonal |
| `--container-high` | `#E6EAF0` | Hover tombol tonal |
| `--on-surface` | `#121317` | Teks utama, tombol utama, blok gelap |
| `--on-variant` | `#45474D` | Teks sekunder, paragraf pengantar |
| `--num` | `#595C61` | Nomor, ikon kecil |
| `--outline` | `rgba(33,34,38,.14)` | Garis tegas |
| `--outline-variant` | `rgba(33,34,38,.07)` | Garis halus, pembatas |

### 2.2 Token gelap (obsidian netral)

| Token | Nilai | Pemakaian |
|---|---|---|
| `--surface` | `#09090B` | Latar halaman |
| `--container` | `#18181B` | Kartu |
| `--container-low` | `#1F1F23` | Hover kartu |
| `--container-high` | `#27272A` | Elemen terangkat |
| `--container-highest` | `#3F3F46` | Garis kuat, nomor |
| `--on-surface` | `#FAFAFA` | Teks utama, tombol utama |
| `--on-variant` | `#A1A1AA` | Teks sekunder (kontras sekitar 6,6:1 pada kartu) |
| `--outline-variant` | `rgba(250,250,250,.10)` | Garis tipis pemisah kartu |

Mode gelap memakai hitam netral tanpa semburat biru. Kartu `#18181B` di atas `#09090B` nyaris menyatu, jadi **setiap kartu di mode gelap wajib diberi garis 1 px `rgba(250,250,250,.10)`**.

### 2.3 Aturan pakai

- **Satu blok terbalik per bagian.** Blok hitam di mode terang (putih di mode gelap) dipakai sebagai satu titik fokus kontras tinggi, misalnya "Cara OpenTurath menjawabnya", kartu angka besar, atau pernyataan penutup. Jangan menaruh dua blok terbalik bersebelahan.
- Teks di blok terbalik memakai `--inverse-on` untuk judul dan `--inverse-variant` untuk paragraf.
- Dilarang: warna aksen, gradien berwarna, bayangan berwarna, emoji berwarna.
- Kontras minimum teks: 4,5:1 (isi) dan 3:1 (teks besar). Semua pasangan di atas sudah memenuhi.

---

## 3. Tipografi

| Peran | Huruf | Catatan |
|---|---|---|
| UI dan isi (Indonesia, Inggris) | **Google Sans Flex** (400 hingga 600, sumbu lebar 100) | Berkas `googlesansflex.woff2` |
| Arab kitab (ibarah, nama ilmu, judul Arab) | **Scheherazade New** (400, 700), diberi nama `OT Naskh` | `line-height: 1.9`, `direction: rtl` |
| UI berbahasa Arab | **Cairo** (400, 600, 700) | `letter-spacing: 0` |
| Angka dan kode | Monospace sistem | Untuk nomor kecil |

### 3.1 Skala

| Elemen | Ukuran | Bobot | Letter-spacing | Tinggi baris |
|---|---|---|---|---|
| Judul hero (H1) | `clamp(28px, 8.6vw, 92px)` | 450 | `-0.045em` | 1.02 |
| Judul bagian (H2) | `clamp(34px, 4.6vw, 56px)` | 450 | `-0.035em` | 1.08 |
| Judul kartu (H3) | `clamp(21px, 1.9vw, 25px)` | 500 | `-0.01em` | 1.22 |
| Paragraf pengantar (lead) | `clamp(18px, 1.5vw, 20px)` | 400 | normal | 1.58 |
| Isi | 17.5px | 400 | `0.01em` | 1.5 |
| Teks kecil | 14px | 400 | normal | 1.5 |
| Kicker (label bagian) | 12.5px, huruf kapital | 600 | `0.16em` | 1.2 |
| Angka besar (kartu angka) | `clamp(46px, 5.6vw, 88px)` | 500 | `-0.05em` | 1 |

Aturan:

- Judul besar selalu **rapat** (letter-spacing negatif) dan **seimbang** (`text-wrap: balance`).
- Paragraf memakai `text-wrap: pretty`, lebar maksimum sekitar 62 karakter.
- Kicker berhuruf kapital hanya untuk Latin. Untuk Arab: tanpa kapital dan `letter-spacing: 0.02em`.
- Arab tidak pernah dipaksa miring atau diberi bayangan. Ukuran Arab ibarah 21 sampai 30px, jauh lebih besar dari Latin agar terbaca.

---

## 4. Bentuk, jarak, dan bayangan

### 4.1 Radius

| Token | Nilai | Dipakai untuk |
|---|---|---|
| `--corner-sm` | 8px | Fokus, elemen kecil |
| `--corner-md` | 16px | Ikon dalam kotak, input |
| `--corner-lg` | 24px | Kartu kecil, kotak isi dalam blok |
| `--corner-xl` | 36px | **Kartu utama** |
| `--corner-2xl` | 48px | Blok besar terbalik |
| `--pill` | 9999px | Tombol, kicker, chip, tombol header |

Semua sudut bulat berukuran besar. Tidak ada sudut tajam.

### 4.2 Jarak dan grid

- Lebar maksimum isi 1600px, margin sisi `72px` (desktop), `40px` (tablet), `16px` (ponsel).
- Jarak antarbagian vertikal besar (sekitar 96 hingga 144px). Bagian selalu dipisah garis tipis `--outline-variant`, bukan warna latar yang berbeda, kecuali blok terbalik.
- Jarak antarkartu: `16px` atau `20px`.
- Kartu berpadding `clamp(26px, 3vw, 40px)`.

### 4.3 Bayangan

Hanya satu bayangan berlapis, lembut dan netral:
`0 1px 2px rgba(18,19,23,.05), 0 12px 28px -6px rgba(18,19,23,.10), 0 40px 80px -24px rgba(18,19,23,.14)`
Dipakai pada ikon dalam kotak, kartu yang terangkat, dan panel detail. Di mode gelap memakai hitam pekat dengan opasitas lebih tinggi.

---

## 5. Komponen

### 5.1 Tombol

Selalu berbentuk pil.
- **Utama:** latar `--on-surface`, teks `--surface`, tinggi 52px, padding sisi 26px, 16.5px bobot 550. Hover: bayangan tipis.
- **Tonal:** latar `--container-low`, teks `--on-surface`.
- **Kecil:** tinggi 40px.
- **Di blok terbalik:** utama berlatar `--inverse-on`. Kontur memakai garis 1.5px `--inverse-variant`.
- Ikon 20px di kiri teks. Panah di kanan bergeser 3px saat hover.
- Saat ditekan: `scale(.97)`.

### 5.2 Kicker (judul bagian berbingkai)

Label kecil di atas judul bagian: huruf kapital, 12.5px, bobot 600, `letter-spacing .16em`, **dibingkai pil dengan garis 2px `currentColor`**, padding `7px 18px`. Ini satu-satunya tempat bingkai tebal dipakai.

### 5.3 Kartu

- **Kartu isi:** latar `--container`, radius `--corner-xl`, tanpa garis (mode terang), garis 1px `--outline-variant` (mode gelap).
- Isi kartu: ikon atau nomor kecil di atas, judul, paragraf `--on-variant`.
- Hover: naik 3px dan latar beralih ke `--container-low`. Sorot lembut mengikuti kursor (gradien radial netral).
- Jangan memberi bingkai tebal pada kartu.

### 5.4 Blok terbalik

Latar `--inverse-surface` (hitam di terang, putih di gelap), radius 36 sampai 48px, padding `clamp(34px, 5vw, 64px)`. Dua kolom: judul besar dan paragraf di kiri, daftar kotak kecil (`--corner-lg`, latar transparan 9% terhadap teks) di kanan. Dipakai untuk "Cara OpenTurath menjawabnya", pernyataan penutup, dan bagian unduh.

### 5.5 Kartu angka

Kisi 3 kolom. Satu kartu besar terbalik (angka sangat besar di kiri bawah, ikon di kiri atas, latar siluet rak kitab garis tipis di kanan), empat kartu kecil berisi. Tiap kartu: ikon dalam kotak 48px, angka, label. Angka memakai tanda `+` dan dibulatkan ke bawah (5.300+, 28.000+). Di lebar sempit, rak kitab menempel di sisi kanan dan memudar ke kiri.

### 5.6 Ikon

- Garis tipis 1.6px, `stroke-linecap: round`, `stroke-linejoin: round`, 24px, tanpa isi.
- Selalu dalam kotak berradius 16px (atau 18px) berlatar `--surface` dengan bayangan, atau terbalik (latar putih transparan 14%) di blok gelap.
- Dilarang: ikon berkilau, ikon dekoratif, ilustrasi vektor ramai, dan ikon berwarna.

### 5.7 Chip dan status

- **Chip:** tinggi 32px, pil, latar `--surface`, garis 1px, 12.5px bobot 600.
- **Status:** tinggi 28px, pil, garis 1px `currentColor`, kapital 11.5px (misalnya "Rilis", "Dibangun", "Tahap uji", "Rencana").

### 5.8 FAQ

Daftar `<details>`: garis atas 1px, ringkasan tinggi minimal 70px, tanda plus yang berputar menjadi minus (animasi pegas), isi 16.5px `--on-variant`.

### 5.9 Header

Tinggi 56px, melekat di atas, latar `--surface` 82% dengan buram latar. Kiri: tulisan "OpenTurath" (tanpa logo). Kanan: tombol bahasa, tombol tema, tombol unduh (pil gelap), dan menu. Tombol bahasa, tema, dan menu **semuanya pil 40px bergaris 1px**, ukuran sama agar simetris. Di bawah lebar 1120px, navigasi menjadi menu lipat.

### 5.9.1 Pil pengumuman

Di atas header: pil `--container` dengan garis halus, berisi ikon, teks 14.5px, dan panah.

### 5.10 Hero

Urutan tetap: label kecil huruf kapital ("AI for Islamic Scholarship"), logo dalam kotak 92px berradius 26px, judul dua baris, paragraf pengantar, dua tombol (utama dan tonal), tiga penanda fitur dengan ikon centang. Di latar: medan titik (lihat 7).

### 5.11 Kotak penjelasan dua sisi

Dua kotak sejajar (tugas, anggapan vs jawaban): jarak 20px, satu isi dan satu terbalik, atau dua isi. Tanpa ikon, tanpa nomor, tanpa penanda di tengah.

### 5.12 Kutipan Arab

Teks naskh 22 sampai 30px, `direction: rtl`, tanda kutip « », sumber di bawah dengan teks kecil dan `opacity .7`. Rujukan ditulis lengkap: judul kitab, juz, dan halaman. Nomor halaman memakai angka Latin untuk teks Indonesia dan Inggris, angka Arab pada halaman berbahasa Arab.

---

## 6. Pola tata letak

### 6.1 Ritme halaman beranda

1. Hero (titik, logo, tagline).
2. Masalah (tiga kartu isi) lalu jawaban (satu blok terbalik).
3. Contoh nyata (dua kotak: pertanyaan dan jawaban ringkas, daftar rujukan yang dapat dibuka).
4. Pembaca (tiga kartu).
5. Angka (kartu besar dan empat kartu).
6. Bidang ilmu (tab dan penjelajah).
7. Bagian tematik (misalnya Fikih Tahawwulat) pada blok terbalik.
8. Cara kami menjaga mutu (empat pilar) dan pernyataan.
9. Ekosistem.
10. Pendiri (kutipan dan chip).
11. Unduh (blok terbalik dengan satu tombol).
12. FAQ.
13. Footer (logo, tautan, baris tautan hukum, hak cipta).

Aturan ritme: **terang, terbalik, terang, terbalik** secara bergantian. Tidak lebih dari satu blok terbalik berdampingan.

### 6.2 Pola bagian

`kicker` lalu `H2` lalu `lead` lalu isi. Tidak ada bagian tanpa kicker dan judul. Judul berupa pernyataan pendek atau pertanyaan, bukan label datar.

### 6.3 Halaman bercerita

Untuk materi penjelasan (Fikih Tahawwulat): rantai pertanyaan. Tiap bagian menjawab satu pertanyaan yang lahir dari bagian sebelumnya. Satu perumpamaan induk dipakai berulang. Kutipan sumber di setiap bagian.

---

## 7. Gerak dan interaksi

- **Kurva:** `--ease: cubic-bezier(.2,.8,.2,1)`, `--spring: cubic-bezier(.34,1.36,.64,1)`, `--quart: cubic-bezier(.165,.84,.44,1)`.
- **Masuk (reveal):** elemen muncul sambil naik sedikit saat terlihat. Maksimal sekali per elemen.
- **Hover:** naik 3px, latar bergeser satu tingkat, sorot lembut mengikuti kursor.
- **Tab:** transisi isi 250 sampai 350ms.
- **Hero titik:** cincin konsentris titik dari logo dengan gelombang pelan ke luar. Kursor hanya memberi dua efek tenang: sorot cahaya lembut di sekitar kursor dan paralaks kedalaman (hamparan bergeser maksimal 22px berlawanan arah kursor, cincin luar lebih jauh). **Dilarang** efek riak, tolak, atau getaran yang membuat pusing.
- **Transisi halaman:** `@view-transition` lembut.
- **Gulir:** garis kemajuan tipis 2px di puncak halaman.
- **Gerak berkurang:** bila perangkat meminta `prefers-reduced-motion`, semua animasi dimatikan dan titik tampil statis.

---

## 8. Bahasa tulisan

### 8.1 Suara

Tenang, jujur, dan hangat. Seperti santri yang menjelaskan kepada teman, bukan iklan. Kalimat pendek. Tanpa seruan. Tanpa superlatif ("terbaik", "pertama di dunia") kecuali berasal dari dokumen resmi.

### 8.2 Aturan

1. Tulis **fitur dan manfaat**, bukan peringatan. Peringatan ada di Pedoman.
2. Jangan pisahkan penjelasan menjadi poin yang tampak seperti keburukan produk sendiri. Masalah AI umum dan jawaban OpenTurath berada di kotak yang berbeda.
3. Pakai bahasa yang alami: "menemani", "menunjukkan ibarah dan rujukannya", "kami mulai dari kitabnya, bukan dari tebakan". Hindari frasa yang terdengar mesin: "memanfaatkan", "mengoptimalkan", "solusi".
4. Istilah Arab dijelaskan dulu dalam bahasa biasa, baru istilahnya.
5. Satu kalimat inti per layar, maksimal sekitar 20 kata.
6. Jangan menyebut nama produk AI atau model lain. Boleh "teknologi Google", dengan penegasan bahwa OpenTurath layanan mandiri (di halaman kebijakan, bukan footer).
7. Jangan pakai angka pasti kecuali dari data. Pakai "5.300+" bukan "5.383".

### 8.3 Kata yang dihindari

| Hindari | Gunakan |
|---|---|
| telaah, ruang kajian | baca, pelajari |
| korpus | koleksi kitab |
| kurasi, dikurasi | dipilih, dipilih dengan manhaj wasathiyyah syar'iyyah |
| cara kerja (untuk metodologi ilmu) | manhaj dan kaidah |
| "gurunya tetap guru", "bukan pengganti guru" di area fitur | letakkan sebagai pedoman, bukan keunggulan |
| nama pribadi pendiri di halaman publik | sang perintis |
| tagline berbahasa Arab | tidak dipakai |

### 8.4 Tagline

**Menjaga warisan, membuka cakrawala.** (EN: Rooted in heritage. Open to new horizons.) Dua baris: "Menjaga warisan," dan "membuka cakrawala." Selalu bersama nama OpenTurath. Tidak diubah, dipotong, atau diterjemahkan ke Arab.

---

## 9. Tiga bahasa dan RTL

- Gunakan **properti logis CSS** (`margin-inline`, `padding-inline`, `inset-inline-start`) agar RTL otomatis.
- Arab: `dir="rtl"`, font Cairo untuk UI, Scheherazade untuk kitab, `letter-spacing: 0`, tanpa huruf kapital.
- Gambar arah (panah, siluet rak kitab) dicerminkan pada RTL.
- Tombol pemilih bahasa memakai ikon globe dan kode (ID, EN, AR). Deteksi awal: pilihan manual, lalu zona waktu Arab ke AR, selain itu Indonesia.
- Teks Arab ditinjau penutur ahli sebelum rilis.

---

## 10. Responsif dan aksesibilitas

- Titik henti: 1120px (navigasi lipat), 980px dan 900px (kisi menjadi dua atau satu kolom), 760px (hero dan titik lebih kecil), 480px, 400px dan 380px (padding, tombol membungkus).
- Diuji tanpa gulir horizontal pada 320px untuk seluruh halaman dan tiga bahasa.
- Tombol boleh membungkus teks (`white-space: normal`) di layar sempit, dengan tinggi menyesuaikan.
- Fokus: garis 2px `--on-surface` berjarak 3px.
- Tautan lompat ke isi, atribut `aria-*` pada panel dan tab, `lang` dan `dir` pada setiap halaman.
- Kontras memenuhi WCAG AA.
- Tanpa skrip sebaris (kebijakan keamanan ketat). Semua skrip eksternal dan `self`.

---

## 11. Yang dilarang

1. Warna aksen apa pun.
2. Bingkai tebal pada kartu, tombol, atau foto (hanya kicker).
3. Efek riak, getar, atau tolakan kursor di latar.
4. Ikon berkilau atau ilustrasi bergaya stok.
5. Logo di tengah header, atau tagline Arab.
6. Dua blok terbalik berdampingan.
7. Teks disclaimer sebagai poin keunggulan.
8. Sudut tajam dan bayangan hitam pekat berat di mode terang.
9. Mengubah logika siklus WebView aplikasi (lihat `AGENTS.md`).

---

## 12. Penerapan ke OpenTurath Academy dan materi lain

Bahasa desain ini dibuat untuk dibawa ke media lain. Pedoman ringkas:

### 12.1 Slide dan modul belajar

- Kanvas 16:9, margin 6% dari sisi. Latar `#FFFFFF` (terang) atau `#09090B` (gelap), selang-seling per bab.
- **Satu slide, satu gagasan.** Kicker berbingkai pil di kiri atas (nama bab), judul H2 besar rapat, lalu satu paragraf pengantar atau satu kartu.
- Judul 64 sampai 96pt (Google Sans Flex 450), isi 24 sampai 32pt, kicker 16pt kapital.
- Blok terbalik penuh untuk slide kunci (definisi, kesimpulan, perumpamaan induk).
- Kutipan Arab di tengah: naskh 40 sampai 56pt, sumber 18pt `opacity .7`.
- Diagram: garis 2px, kotak berradius besar, tanpa warna. Penekanan dengan satu kotak terbalik.

### 12.2 Video dan animasi (Remotion)

- Latar `#09090B` atau `#FFFFFF`, teks kontras penuh.
- Elemen masuk dengan naik 24px dan memudar 400 sampai 600ms dengan kurva `ease` di atas. Tidak ada putar, pantul berlebihan, atau efek pelacak kamera cepat.
- Titik konsentris dari logo boleh dipakai sebagai latar pembuka dan penutup, dengan gelombang pelan.
- Teks Arab muncul utuh bersamaan dengan terjemahannya, tidak kata per kata.
- Satu perumpamaan induk dipakai berulang agar penonton mengenali benang cerita.
- Logo OpenTurath di penutup, di tengah, dengan tagline di bawahnya.

### 12.3 Poster dan media sosial

- Rasio 4:5 atau 1:1. Latar hitam obsidian atau putih. Satu kalimat inti, satu kicker pil, logo kecil di sudut, alamat openturath.id di bawah.
- Tidak lebih dari tiga elemen: kicker, kalimat, logo.

### 12.4 Dokumen dan PDF

- Sampul: latar hitam atau putih, logo, nama dokumen besar rapat, tagline.
- Isi: Google Sans Flex, judul H2 rapat, paragraf `--on-variant`, kutipan Arab naskh besar.
- Tabel: garis 1px `--outline-variant`, sudut bulat 16px, tanpa warna zebra.
- Pil "Dibuat oleh pelajar, untuk para pelajar." sebagai penanda kecil di sampul.

### 12.5 Materi Academy (empat tahap)

Berikan identitas yang sama pada keempat tahap (percakapan AI, gambar dan video dakwah, membuat aplikasi, membuat AI agent). Pakai kicker bernomor ("Tahap 01"), kartu isi untuk tiap latihan, blok terbalik untuk tantangan akhir tiap bab, dan satu kotak "Hasil yang diharapkan".

### 12.6 Daftar periksa sebelum menerbitkan materi

- [ ] Hanya hitam, putih, dan abu netral?
- [ ] Satu gagasan per layar atau halaman?
- [ ] Judul rapat dan seimbang, kicker berbingkai pil?
- [ ] Arab dalam naskh besar dengan sumber lengkap?
- [ ] Teks natural, tanpa disclaimer sebagai keunggulan, tanpa kata yang dihindari?
- [ ] Tagline utuh dan tidak diterjemahkan ke Arab?
- [ ] Terbaca di terang dan gelap, kontras minimal 4,5:1?
- [ ] Tidak ada nama produk AI lain dan tidak ada nama pribadi pendiri?

---

## 13. Berkas rujukan

| Berkas | Isi |
|---|---|
| `website/redesign-v7/site/assets/css/site.css` | Seluruh token, komponen, dan gaya |
| `website/redesign-v7/site/assets/js/site.js` | Interaksi: tema, menu, tab, penjelajah, hero titik |
| `website/redesign-v7/build.py` | Generator halaman tiga bahasa dan seluruh teks |
| `website/redesign-v7/BLUEPRINT_UX.md` | Alur dan struktur halaman |
| `DOKUMEN_FILOSOFI_DAN_URGENSI_OPENTURATH/OpenTurath_Buku_Identitas.pdf` | Logo, filosofi, dan aturan identitas |
| `AGENTS.md` (aturan 9) | Hak paten desain hitam-putih monokrom |

Perubahan desain dilakukan lebih dulu di `site.css`, lalu dokumen ini diperbarui.
