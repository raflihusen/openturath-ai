# MASTER PROMPT PERBAIKAN 12 DEFECT UI/UX & ALUR SISTEM OPENTURATH AI
### Target: Senior Flutter Engineer, UI/UX Systems Architect, & Web Integration Specialist
### Berkas Sumber Terkait: `lib/screens/`, `lib/core/`, `lib/widgets/`, `functions/src/`

---

## 1. LATAR BELAKANG & TUJUAN AUDIT PERBAIKAN

Berdasarkan pengujian nyata di perangkat Android (lihat lampiran 5 tangkapan layar pengujian), ditemukan 12 kecacatan visual, ergonomi, dan logika alur pengguna (*leaky abstractions*). Masalah utama berkisar pada:
1. Elemen UI bawaan Google NotebookLM yang bocor ke pandangan pengguna saat memuat atau berinteraksi.
2. Penanganan halaman penolakan akses (Google 403) yang tidak elegan ketika pengguna belum berlangganan.
3. Elemen redundan di Dashboard dan Layar Detail Kitab.
4. Istilah teknis (*coding language*) seperti `not_found` yang muncul ke pengguna awam.
5. Mekanisme penyimpanan otomatis saat jawaban disalin.

Tugas Anda adalah membedah dan menerapkan solusi definitif (*production-ready patches*) pada ke-12 poin berikut tanpa merusak arsitektur yang sudah berjalan.

---

## 2. DAFTAR 12 DEFECT & SPESIFIKASI TEKNIS PERBAIKAN

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    12 DEFECT UI/UX & ALUR PENGGUNA                      │
├─────────────────────────────────────────────────────────────────────────┤
│ [1] Hapus Kartu "Lanjutkan Sesi"    │ [7] Penamaan Spesialis "AI ..."   │
│ [2] Sembunyikan "Loading Notebook"  │ [8] Auto-Save Bookmark saat Copy  │
│ [3] Musnahkan Disclaimer Gemini     │ [9] Auto-Dismiss Dialog NotebookLM│
│ [4] Hapus Kartu Header AI di Chat   │ [10] Perbaiki Copy Loader WebView │
│ [5] Redaksi Humanis Error Voucher   │ [11] Native Paywall Pengganti 403 │
│ [6] Pill Tanggal Dual Terpusat      │ [12] Bersihkan Detail Kitab       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### [DEFECT 1] Hapus Bagian "Lanjutkan Sesi Terakhir" di Beranda
- **Lokasi Berkas**: `lib/screens/dashboard_screen.dart`
- **Gejala (Screenshot 1)**: Muncul kartu besar *"Lanjutkan Sesi Terakhir"* dengan badge *"Aktif Terbuka"* di bawah kolom pencarian yang memakan ruang vertikal dan tidak berguna.
- **Solusi**:
  - Hapus pemanggilan `_buildResumeSessionCard` dan seluruh widget terkait dari `dashboard_screen.dart`.
  - Pastikan setelah bilah pencarian langsung mengalir ke Catatan Riset Terbaru atau Pilih Bidang Ilmu secara bersih.

---

### [DEFECT 2] Eliminasi Kebocoran Loading Google NotebookLM & Header Tab
- **Lokasi Berkas**: `lib/core/notebook_ui_script.dart`, `lib/screens/agent_webview_screen.dart`
- **Gejala (Screenshot 2)**: Saat ruang kajian sedang dibuka, pengguna melihat tab Google *"Sources | Chat | Studio"*, tulisan *"Loading Notebook..."*, *"0 sources"*, dan animasi skeleton bawaan Google. Hal ini membocorkan bahwa aplikasi membungkus NotebookLM.
- **Solusi**:
  1. **CSS/JS DOM Scrubber**: Tambahkan selektor agresif pada `notebookUiScript` untuk menyembunyikan `.tab-bar`, `app-tab-bar`, `[aria-label*="Sources" i]`, `[aria-label*="Studio" i]`, dan kartu skeleton loading Google.
  2. **Overlay Pelindung Flutter**: Pertahankan layar loading native Flutter (*"Menghubungkan ke Ruang Telaah AI..."*) tetap di atas WebView sampai script `window.otNotebook.ready()` mengonfirmasi bahwa panel chat utama sudah selesai render 100%.

---

### [DEFECT 3] Hapus Teks Disclaimer Bawaan ("Gemini Notebook can be inaccurate")
- **Lokasi Berkas**: `lib/core/notebook_ui_script.dart`, `lib/screens/agent_webview_screen.dart`
- **Gejala (Screenshot 2)**: Di bagian paling bawah input chat terlihat tulisan abu-abu: *"Gemini Notebook can be inaccurate; please double check its responses."*
- **Solusi**:
  - Injeksi CSS global `display: none !important;` pada seluruh elemen footer disclaimer:
    `div[class*="disclaimer"]`, `span[class*="disclaimer"]`, `.chat-disclaimer`, `.input-footer`, serta pembersih DOM regex pada teks yang mengandung *"can be inaccurate"*, *"can make mistakes"*, atau *"double check"*.

---

### [DEFECT 4] Hapus Kartu Kotak Judul AI di Awal Chat
- **Lokasi Berkas**: `lib/core/notebook_ui_script.dart`
- **Gejala (Screenshot 2 & 4)**: Di bagian atas percakapan muncul kartu kotak bawaan Google yang memuat judul notebook, tanggal pembuatan, thumbnail icon, dan deskripsi default.
- **Solusi**:
  - Hapus elemen kotak tersebut via CSS dan MutationObserver:
    `.notebook-overview`, `.notebook-cover`, `.title-card`, `mat-card.title-card`, `.notebook-title-card`, `app-notebook-header`.
  - Pastikan area chat langsung dimulai bersih dari pertanyaan atau riwayat tanya jawab pengguna.

---

### [DEFECT 5] Redaksi Pesan Kesalahan Voucher Humanis (Ganti `not_found`)
- **Lokasi Berkas**: `lib/widgets/redeem_code_sheet.dart`, `functions/src/index.ts`
- **Gejala**: Ketika pengguna memasukkan kode voucher yang salah atau belum terdaftar, aplikasi menampilkan pesan teknis mentah: `not_found` / `VOUCHER_NOT_FOUND`.
- **Solusi**:
  - Tangkap seluruh respon error dan terjemahkan ke bahasa Indonesia yang sopan dan natural:
    - `not_found` / `INVALID_CODE` -> *"Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda."*
    - `already_used` / `ALREADY_REDEEMED` -> *"Anda sudah pernah menggunakan kode voucher ini."*
    - `quota_exceeded` / `EXHAUSTED` -> *"Kuota penukaran untuk kode ini sudah habis."*
    - `expired` -> *"Masa berlaku kode voucher ini telah berakhir."*

---

### [DEFECT 6] Tanggal Dashboard: Pill Rounded di Tengah (Masehi Kiri, Titik Tengah, Hijriyah Kanan)
- **Lokasi Berkas**: `lib/screens/dashboard_screen.dart`, `lib/core/hijri_date_utils.dart`
- **Gejala (Screenshot 1)**: Tanggal ditampilkan rata kiri tanpa kontainer yang rapi.
- **Solusi**:
  - Bungkus tanggal dalam kontainer pill memanjang dengan `borderRadius: BorderRadius.circular(100)` dan padding simetris.
  - Posisikan tepat di tengah (*center aligned*).
  - Susunan teks: **[ Tanggal Masehi ] • [ Tanggal Hijriyah ]**
    - Sebelah Kiri: Tanggal Masehi (misal: `12 September 2026 M`)
    - Tengah: Tanda titik pemisah bulat (`•`)
    - Sebelah Kanan: Tanggal Hijriyah (misal: `29 Rabi'ul Awwal 1448 H`)

---

### [DEFECT 7] Penamaan Modul & Menu: Tambahkan Kata "AI" Secara Eksplisit
- **Lokasi Berkas**: `lib/models/agent_model.dart`, `lib/core/app_routes.dart`, `lib/screens/specialist_list_screen.dart`
- **Gejala**: Beberapa judul modul hanya tertulis *"Fikih Syafi'i"*, *"Hadits"*, atau *"Kajian"* sehingga membingungkan antara naskah manual dan asisten AI.
- **Solusi**:
  - Ganti seluruh judul spesialis agar tegas menyandang identitas AI:
    - *"AI Fikih Syafi'i"*
    - *"AI Ushul Fiqih"*
    - *"AI Hadits"*
    - *"AI Tafsir"*
    - *"AI Bahasa Arab"*
    - *"AI Fikih Tahawwulat"*
  - Sesuaikan nama tab dan header agar selaras dengan konsep ruang telaah cerdas.

---

### [DEFECT 8] Fitur Tersimpan: Otomatis Simpan saat Tombol Salin Ditekan & Rapikan Menu Opsi
- **Lokasi Berkas**: `lib/screens/agent_webview_screen.dart`, `lib/services/bookmark_service.dart`
- **Gejala (Screenshot 4)**: 
  - Lembar bawah menampilkan *"Opsi kajian"* dengan menu redundan *"Simpan jawaban"*.
  - Saat pengguna menekan ikon copy pada jawaban atau tombol *"Salin jawaban"*, teks hanya tersalin ke clipboard dan tidak tersimpan ke menu Tersimpan.
- **Solusi**:
  1. **Auto-Save on Copy**: Modifikasi handler tombol copy (baik tombol copy bawaan di WebView maupun menu salin): Setiap kali teks jawaban berhasil disalin ke clipboard, otomatis panggil `BookmarkService.instance.addBookmark(...)` untuk menyimpannya ke menu Tersimpan secara instan disertai feedback tenang: *"Jawaban tersalin dan disimpan."*
  2. **Pembersihan Bottom Sheet**:
     - Ubah judul lembar dari *"Opsi kajian"* menjadi *"Pengaturan Tampilan"* atau *"Opsi Baca"*.
     - Hapus item *"Simpan jawaban"* karena sudah terotomatisasi saat disalin.

---

### [DEFECT 9] Tutup Paksa Pop-up Pengumuman Google Gemini Notebook
- **Lokasi Berkas**: `lib/core/notebook_ui_script.dart`
- **Gejala (Screenshot 4)**: Muncul dialog modal pop-up dari Google:
  *"We're giving you more flexibility and control over how you use Gemini Notebook. Limits refresh every 5 hours..."*
- **Solusi**:
  - Tambahkan pengawas DOM otomatis (MutationObserver) di `notebookUiScript` yang mendeteksi elemen dialog Google (`mat-dialog-container`, `div[role="dialog"]`, `.cdk-overlay-container`).
  - Jika elemen tersebut muncul, lakukan aksi ganda:
    1. Otomatis klik tombol konfirmasi / tutup (`button:has-text("Got it")`, `button:has-text("Dismiss")`, `button.close`).
    2. Jika tidak ada tombol klik, paksa hapus elemen dan overlay-nya dari DOM: `el.remove()` dan hilangkan `.cdk-overlay-backdrop`.

---

### [DEFECT 10] Redaksi Loader WebView: Ganti "Memuat kitab rujukan"
- **Lokasi Berkas**: `lib/screens/agent_webview_screen.dart`, `lib/core/app_copy.dart`
- **Gejala**: Pesan pemuatan ruang kajian menampilkan teks *"Memuat kitab rujukan..."*, padahal sistem sedang menghubungkan ke kecerdasan buatan.
- **Solusi**:
  - Ganti dengan redaksi yang tepat dan berwibawa:
    *"Menghubungkan ke Ruang Telaah AI..."* atau *"Membuka Ruang AI..."*.

---

### [DEFECT 11] Cegah Layar Google 403: Tampilkan Halaman Native Belum Langganan
- **Lokasi Berkas**: `lib/screens/dashboard_screen.dart`, `lib/screens/agent_webview_screen.dart`, `lib/widgets/subscription_prompt_sheet.dart`
- **Gejala (Screenshot 3)**: Pengguna yang belum berlangganan atau belum menukar voucher dibiarkan masuk ke WebView hingga melihat halaman error mentah Google: *"Anda memerlukan akses - Minta akses, atau beralih ke akun yang memiliki akses."*
- **Solusi**:
  1. **Pre-Navigation Guard**: Sebelum membuka WebView di `dashboard_screen.dart`, periksa `user.isAgentSubscriptionActive(agent.id)`. Jika `false`, JANGAN PERNAH buka WebView. Langsung tampilkan bottom sheet / halaman langganan native:
     - Judul: *"Akses Ruang AI Memerlukan Langganan"*
     - Penjelasan: *"Ruang kajian ini memerlukan paket telaah aktif atau kode voucher santri."*
     - Tombol 1: *"Pilih Paket Langganan"* (mengarahkan ke `subscription_screen.dart`).
     - Tombol 2: *"Tukar Kode Akses / Voucher"* (membuka `redeem_code_sheet.dart`).
  2. **In-WebView Fallback**: Jika WebView mendeteksi URL atau konten penolakan izin Google (`denied`, `request-access`, atau teks *"Anda memerlukan akses"*), segera sembunyikan WebView dan tampilkan banner/layar native serupa dengan tombol langganan langsung.

---

### [DEFECT 12] Bersihkan Detail Kitab & Pisahkan Katalog yang Belum Tersedia
- **Lokasi Berkas**: `lib/screens/book_detail_screen.dart`, `lib/services/canonical_library_service.dart`
- **Gejala (Screenshot 5)**:
  - Pada layar *Keterangan kitab*, terdapat bagian bawah *"AKSI & TELAAH RISET"* yang memuat tombol *"Buka Ruang Kajian"* dan *"Simpan ke Catatan Riset"*. Bagian ini terasa canggung dan rusak fungsinya.
  - Database kitab kanonikal saat ini baru mencakup **Fikih Syafi'i (87 kitab)**, namun disiplin lain ikut menampilkan naskah Syafi'i atau terhubung ke modul yang keliru.
- **Solusi**:
  1. **Hapus Bagian Aksi di Detail Kitab**:
     - Hapus Card 4 (*"AKSI & TELAAH RISET"*) beserta kedua tombolnya dari `book_detail_screen.dart`.
     - Jadikan layar Keterangan Kitab murni sebagai lembar informasi bibliografi ilmiah (*Muallif, Klasifikasi Ilmiah, Data Edisi & Tahqiq*).
  2. **Isolasi Katalog Kitab Berdasarkan Disiplin Nyata**:
     - Pastikan katalog 87 kitab Syafi'i hanya terasosiasi dengan bidang Fikih Syafi'i.
     - Untuk bidang ilmu lain (Tafsir, Hadits, Aqidah, Lughah) yang naskah kanonikalnya belum diunggah, tampilkan status informatif: *"Naskah rujukan induk sedang dalam tahap kurasi dan kodifikasi ilmiah."* Jangan menampilkan kitab Fikih Syafi'i di dalamnya.

---

## 3. FORMAT HASIL PENGERJAAN YANG DIHARAPKAN
1. Tunjukkan perubahan kode baris demi baris pada setiap file yang terdampak.
2. Pastikan seluruh pengujian unit (`flutter test`) lulus 100% tanpa regresi.
3. Berikan ringkasan perbandingan tampilan sebelum dan sesudah perbaikan.
