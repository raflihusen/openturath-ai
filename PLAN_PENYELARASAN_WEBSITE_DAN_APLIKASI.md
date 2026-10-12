# Rencana Pembaruan Master Website OpenTurath V4

Dokumen rencana komprehensif untuk menyelaraskan dan merombak tampilan antarmuka serta konten **Website OpenTurath V4** (`/Users/apple/Downloads/openturath-website 4`) agar presisi dengan preview desain, aplikasi OpenTurath AI, dan standar keilmuan Islam klasik.

---

## 1. Poin Kritis Masukan Pengguna

1. **Hero & Kaligrafi `تراث`:**
   - Kaligrafi emas `تراث` di belakang buku pada preview sangat megah dan hidup dengan foil emas, sedangkan di localhost saat ini datar dan salah posisi.
   - Hierarki teks 3 baris harus diperbaiki:
     - Baris 1 (H1): *"Ilmu. Lebih dekat."*
     - Baris 2 (H2): *"Khazanah para ulama. Dalam jangkauan Anda."*
     - Baris 3 (P): *"Menelaah ribuan karya klasik dan kontemporer dengan verifikasi teks Arab, jilid, dan halaman secara presisi."*
   - Teks `— AI for Islamic Scholarship —` harus dibuat proporsional dan jelas (tidak kekecilan) dengan garis emas halus di kiri-kanan.
2. **Khazanah Berformat Bento Grid Elegan & Kaya Metadata:**
   - Kotak-kotak khazanah saat ini kaku dan datar. Harus dirombak menjadi **Bento Grid yang elegan** dengan tata letak modern.
   - Bahasa konsisten per mode bahasa: Jika mode Bahasa Indonesia, maka bahasa Indonesia murni (tidak campur aduk), dengan kaligrafi Arab naskh sebagai mahkota identitas keilmuan.
   - Menampilkan **metadata riil lengkap**:
     Contoh pada Fikih Syafi'i:
     ```
     Fikih Syafi'i
     الفقه الشافعي المعتمد
     87 Kitab · 400+ Jilid · 170.391 Halaman · 71,6 Juta Kata · 150–1338 H
     ```
     agar setiap ilmu benar-benar menonjol dan berbobot.
3. **Penyederhanaan Bagian Harga:**
   - Sembunyikan 3 kartu harga kaku (Tholib 49rb, Tematik 149rb, Sultan 499rb).
   - Cukup tulis penawaran minimalis dan prestisius: *"Akses Keilmuan Mulai dari Rp 49.000 / bulan"* dengan tombol langsung ke aplikasi.
4. **Bantuan Berisi FAQ Riil:**
   - Ganti daftar accordion kosong dengan tanya-jawab riil yang menjawab kebingungan mendasar pengguna (adab talaqqi, akurasi halaman vs cetakan fisik, metode pembayaran DOKU, penyimpanan catatan lokal, dan status khazanah dalam persiapan).

---

## 2. Rincian Perubahan per Komponen

### A. Hero Dashboard & Kaligrafi Emas `تراث`
* **File:** `openturath-website 4/src/home.mjs`, `src/core.mjs`, `src/copy.mjs`
* **Eyebrow Header:** `— AI for Islamic Scholarship —` warna emas `#C5A059`, font size 13px, letter-spacing `0.18em`.
* **Hierarki Teks:**
  - H1: Newsreader Serif 76px–88px putih `#FFFFFF`.
  - H2: Newsreader Serif 24px–28px platinum `#E5E2DC`.
  - P: Outfit Sans 15px–16px abu keperakan `#A8A49C`, leading 1.8.
* **Kaligrafi Emas `تراث`:**
  - Diposisikan di belakang tumpukan buku dengan font Scheherazade New/Diwani kaligrafi bergradien emas foil (`linear-gradient(135deg, #DFBA73 0%, #C5A059 50%, #8E6E28 100%)`).
  - Efek kedalaman (*depth-of-field*) proporsional di belakang buku fanning-out.
* **Tombol Aksi:**
  - `[Jelajahi khazanah →]` (Pill putih kontras tinggi dengan teks hitam).
  - `[Pelajari metodenya →]` (Pill border transparan halus dengan teks putih).

---

### B. Khazanah Keilmuan: Bento Grid Elegan & Kaya Metadata
* **File:** `openturath-website 4/src/home.mjs`, `content/catalog.json`
* **Bento Grid Layout:**
  - Kartu bervariasi ritmis (Featured 2-kolom untuk pilar akbar seperti Fikih Syafi'i & Hadits; Standard 1-kolom untuk cabang keilmuan lainnya; Sovereign untuk Fikih Tahawwulat).
* **Metadata Riil Lengkap:**
  Diambil langsung dari `metadata_training_seluruh_ai.json`:
  - **Fikih Syafi'i:** 87 Kitab · 400+ Jilid · 170.391 Halaman · 71,6 Juta Kata · 150–1338 H.
  - **Kutubus Sunnah & Hadits:** 1.173 Kitab · 1.500+ Jilid · 532.640 Hadits · 105,7 Juta Kata · Abad 2–10 H.
  - **Ushul Fikih 4 Mazhab:** 136 Kitab · 320+ Jilid · 115.000 Halaman · 36,5 Juta Kata · Abad 2–14 H.
  - **Bahasa Arab & Sastra:** 866 Kitab · 1.981 Jilid · 610.000 Halaman · 148,3 Juta Kata · Jahiliyyah s.d. Abad 20 M.
  - **Tafsir & Ulumul Qur'an:** 123 Kitab · 450+ Jilid · 140.000 Halaman · 78,8 Juta Kata · Abad 2–14 H.
  - **Fikih Tahawwulat:** 58 Kitab · 1.099 Muhadharah · 12.500 Halaman · 5,6 Juta Kata · Era Kontemporer.
  - **Tarikh & Sirah:** 345 Kitab · 1.374 Jilid · 480.000 Halaman · 136,5 Juta Kata · Pra-Hijrah s.d. Abad 14 H.
  - Seluruh disiplin lainnya dilengkapi metrik riil masing-masing.

---

### C. Bagian Harga: Minimalis & Sembunyikan Paket Kaku
* **File:** `openturath-website 4/src/home.mjs`, `src/membership.mjs`
* **Perubahan:**
  - Menghapus 3 kartu kaku (Tholib 49rb, Tematik 149rb, Sultan 499rb).
  - Mengganti dengan banner keanggotaan prestisius:
    - Judul: *"Akses Penuh Khazanah Keilmuan"*
    - Tagline Harga: *"Mulai dari Rp 49.000 / bulan"*
    - Deskripsi: *"Pilih khadim spesialis disiplin ilmu yang ingin Anda telaah. Akses dan aktivasi diproses secara resmi di dalam aplikasi melalui gerbang DOKU (QRIS, Virtual Account, E-Wallet) tanpa perpanjangan otomatis."*
    - Tombol CTA: `[Buka Akses di Aplikasi →]`.

---

### D. Bagian Bantuan: FAQ Riil & Solutif
* **File:** `openturath-website 4/src/home.mjs`, `src/articles.mjs`
* **Daftar FAQ Riil:**
  1. **Apakah OpenTurath menggantikan peran guru atau ulama?**
     - *Sama sekali tidak. OpenTurath dirancang sebagai khadim (alat bantu telaah) untuk mempercepat penelusuran ibarah dan pengecekan rujukan marja'. Pemahaman hukum yang mendalam dan fatwa tetap mutlak memerlukan bimbingan guru yang berkompeten dan bertalaqqi.*
  2. **Bagaimana cara kerja verifikasi teks dan rujukan kitab?**
     - *Setiap jawaban mengacu pada korpus kitab mu'tamad yang telah dipartisi. Pengguna disajikan kutipan teks Arab asli, nama kitab, nomor jilid, dan halaman agar dapat langsung dicocokkan dengan kitab fisik.*
  3. **Mengapa nomor jilid atau halaman bisa berbeda dengan kitab cetakan saya?**
     - *Penomoran halaman merujuk pada edisi cetakan mu'tamad yang menjadi basis digital. Karena adanya variasi penerbitan (seperti Darul Kutub Ilmiyyah, Darul Minhaj, atau cetakan Al-Haramain), nomor halaman fisik Anda bisa berbeda dengan teks digital.*
  4. **Berapa biaya langganan dan metode pembayaran apa saja yang tersedia?**
     - *Akses khadim spesialis dapat dimulai dari Rp 49.000 / bulan. Pembayaran diproses secara aman melalui DOKU di dalam aplikasi, mendukung QRIS (GoPay, OVO, Dana, ShopeePay), Virtual Account seluruh bank nasional, dan transfer tanpa auto-debit.*
  5. **Di mana catatan telaah saya disimpan?**
     - *Seluruh catatan telaah dan kutipan tersimpan secara lokal di perangkat Anda demi menjamin kerahasiaan dan kepemilikan pribadi atas hasil riset Anda.*
  6. **Mengapa ada profil ulama yang berstatus "Dalam Persiapan"?**
     - *OpenTurath menerapkan standar kurasi ketat terhadap sanad naskah sebelum dirilis. Koleksi seperti Khazanah Habib Umar dan Imam Ghazali sedang dalam tahap penataan sanad dan anotasi komprehensif sebelum dibuka untuk umum.*

---

## 3. Rencana Eksekusi & Validasi

1. **Implementasi Kode:** Memperbarui file konfigurasi, template JS/MJS, dan stylesheet CSS.
2. **Re-Build Static:** Menjalankan `node scripts/build.mjs` untuk me-render ulang seluruh file di `dist/id/`, `dist/en/`, dan `dist/ar/`.
3. **Verifikasi:** Menjalankan unit test `node --test tests/*.test.mjs` dan memastikan tampilan visual di browser presisi dengan preview.
