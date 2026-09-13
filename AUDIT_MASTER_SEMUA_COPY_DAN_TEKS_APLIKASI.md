# Dokumen Audit Komprehensif: Seluruh Teks, Narasi, dan Copywriting Aplikasi OpenTurath AI

Dokumen ini memuat seluruh kompilasi teks, copywriting, judul, label tombol, dialog konfirmasi, placeholder form, pesan kesalahan (*error message*), notifikasi (*snackbar*), serta materi literatur ilmiah dan disclaimer yang ada di dalam aplikasi **OpenTurath AI**. 

Dokumen ini disusun dalam satu berkas terpadu untuk mempermudah peninjauan menyeluruh (*audit copywriting*), penyesuaian nada bahasa (*tone of voice*), serta penyelarasan istilah keilmuan Islam (*turats*).

---

## Daftar Isi
1. [Kamus Teks Kanonikal Terpusat (AppCopy)](#1-kamus-teks-kanonikal-terpusat-appcopy)
2. [Data Master Asisten AI, Disiplin Ilmu & Literatur (Models)](#2-data-master-asisten-ai-disiplin-ilmu--literatur-models)
3. [Layar Masuk & Autentikasi (Login & Session Auth)](#3-layar-masuk--autentikasi-login--session-auth)
4. [Layar Beranda / Dashboard Utama](#4-layar-beranda--dashboard-utama)
5. [Layar Eksplorasi Spesialis AI (Specialist List)](#5-layar-eksplorasi-spesialis-ai-specialist-list)
6. [Layar Ruang Percakapan AI / Webview & Multi-Tab](#6-layar-ruang-percakapan-ai--webview--multi-tab)
7. [Katalog Naskah Kanonikal 2.226 Kitab (Katalog & Detail Kitab)](#7-katalog-naskah-kanonikal-2226-kitab-katalog--detail-kitab)
8. [Layar Catatan Riset, Simpanan & Editor Catatan (Bookmark & Notes)](#8-layar-catatan-riset-simpanan--editor-catatan-bookmark--notes)
9. [Layar Langganan, Paket Riset & Checkout DOKU](#9-layar-langganan-paket-riset--checkout-doku)
10. [Lembar Klaim Voucher Akses (Redeem Code Sheet)](#10-lembar-klaim-voucher-akses-redeem-code-sheet)
11. [Layar Profil, Pengaturan Akun & Dokumen Legal (Terms, Privacy, Adab)](#11-layar-profil-pengaturan-akun--dokumen-legal-terms-privacy-adab)
12. [Komponen Pendukung: Bukti Ibarah, Banner Update & Pesan Sistem](#12-komponen-pendukung-bukti-ibarah-banner-update--pesan-sistem)

---

## 1. Kamus Teks Kanonikal Terpusat (AppCopy)

Sumber berkas: `openturath_ai/lib/core/app_copy.dart`  
Fungsi: Sumber kebenaran tunggal (*single source of truth*) untuk istilah berulang, navigasi, dialog adab talaqqi, dan umpan balik sistem.

| Kategori | Konstanta | Teks Asli Aplikasi | Konteks & Catatan Penggunaan |
|:---|:---|:---|:---|
| **Identitas & Merek** | `appName` | `OpenTurath` | Nama resmi aplikasi |
| | `appTagline` | `Membaca kitab, menelusuri ibarah.` | Tagline utama pada profil & splash |
| | `defaultFieldDesc` | `Beragam kajian dari kitab-kitab Islam.` | Deskripsi bidang umum |
| | `aboutTitle` | `Tentang OpenTurath` | Judul modal informasi aplikasi |
| | `aboutDescription` | `OpenTurath membantu Anda membaca, mencari, dan membandingkan keterangan dari kitab-kitab rujukan.` | Deskripsi ringkas visi aplikasi |
| | `aboutScholarlyPrinciple` | `Gunakan jawaban sebagai pintu masuk untuk menelusuri ibarah. Untuk memahami dan menetapkan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.` | Prinsip adab riset ilmiah |
| **Navigasi Utama** | `navHome` | `Beranda` | Tab navigasi 1 di Bottom Bar |
| | `navStudies` | `Asisten AI` | Tab navigasi 2 di Bottom Bar |
| | `navSaved` | `Catatan` | Tab navigasi 3 di Bottom Bar |
| | `navSettings` | `Pengaturan` | Tab navigasi 4 di Bottom Bar |
| **Istilah Ruang & Kajian** | `studySpace` | `Percakapan AI` | Istilah resmi ruang interaksi |
| | `openStudy` | `Membuka AI` | Status memuat sesi percakapan |
| | `studyOptions` | `Pengaturan Tampilan & Baca` | Menu modal reader / font size |
| | `referenceBooks` | `Kitab rujukan` | Label daftar kitab rujukan |
| | `savedCollection` | `Catatan` | Label koleksi riset |
| | `bookDetails` | `Keterangan kitab` | Header AppBar detail naskah |
| **Loading & Akses** | `loadingReferences` | `Menghubungkan AI dan Maktabah` | Subtitle loading saat inisialisasi AI |
| | `modulePreparing` | `sedang disiapkan.` | Status modul coming soon |
| | `moduleUnavailable` | `Modul ini belum dapat dibuka. Coba lagi nanti.` | Pesan modul belum aktif |
| | `cannotLoad` | `Tidak dapat dimuat. Periksa koneksi, lalu coba lagi.` | Pesan kegagalan umum |
| | `cannotLoadStudy` | `AI belum dapat dibuka` | Pesan kegagalan buka AI |
| | `studyNotLoadedYet` | `Kajian belum bisa dimuat. Coba lagi sebentar.` | Pesan penundaan sesi |
| | `subscriptionRequiredTitle`| `Langganan diperlukan` | Dialog pengingat langganan |
| | `catalogLoadFailed` | `Daftar kitab belum bisa dimuat.` | Pesan error muat katalog |
| | `inputQuestionHint` | `Tanyakan sesuatu tentang kitab ini...` | Placeholder input teks |
| | `viewSubscription` | `Lihat langganan` | Tombol CTA langganan |
| | `tryAgain` | `Coba lagi` | Tombol retry |
| **Platform & Perangkat** | `deviceNotSupportedTitle` | `Perangkat belum didukung` | Error platform guard |
| | `deviceNotSupportedMessage`| `OpenTurath saat ini mendukung Android, macOS, dan Windows. Perangkat ini belum didukung.` | Penjelasan kompatibilitas platform |
| | `cannotConnectTitle` | `Tidak dapat terhubung` | Header dialog offline |
| | `cannotConnectMessage` | `Tidak dapat terhubung ke layanan OpenTurath. Periksa koneksi, lalu coba lagi.` | Pesan offline |
| **Dialog Adab Talaqqi** | `adabDialogTitle` | `Catatan sebelum mulai` | Judul dialog pengingat adab |
| | `adabAcknowledgeButton` | `Saya mengerti` | Tombol persetujuan dialog adab |
| | `adabHeading1` | `Perkakas Telaah & Komparasi Naskah` | Poin adab 1 |
| | `adabBody1` | `OpenTurath membantu mencari ibarah dan membandingkan keterangan dalam kitab. Setiap kutipan dan ibarah perlu dicocokkan dengan sumber aslinya di Maktabah Syamilah atau naskah cetak fisik.` | Uraian poin adab 1 |
| | `adabHeading2` | `Belajar tetap perlu bimbingan` | Poin adab 2 |
| | `adabBody2` | `Untuk memahami agama dengan baik, belajarlah kepada guru dan ulama yang berkompeten.` | Uraian poin adab 2 |
| | `adabHeading3` | `Periksa kembali rujukan` | Poin adab 3 |
| | `adabBody3` | `Periksa kembali dalil dan ibarah pada kitab rujukan sebelum menjadikannya pegangan.` | Uraian poin adab 3 |
| **Umpan Balik (Feedback)** | `noAnswerToCopy` | `Belum ada jawaban untuk disalin.` | SnackBar validasi salin |
| | `answerCopied` | `Jawaban disalin dan disimpan ke Catatan Riset.` | SnackBar salin sukses |
| | `copyFailed` | `Gagal menyalin. Coba lagi.` | SnackBar salin gagal |
| | `noAnswerToSave` | `Belum ada jawaban untuk disimpan.` | SnackBar simpan kosong |
| | `savedSuccess` | `Tersimpan ke Catatan.` | SnackBar simpan sukses |
| | `saveFailed` | `Gagal menyimpan. Coba lagi.` | SnackBar simpan gagal |
| **Catatan Riset** | `searchSavedHint` | `Cari catatan, topik, atau kutipan...` | Placeholder search box catatan |
| | `searchSavedTooltip` | `Cari catatan` | Tooltip icon search |
| | `noSavedTitle` | `Belum ada catatan` | Judul empty state catatan |
| | `noSavedDescription` | `Simpan telaah atau ibarah ke dalam catatan riset Anda.` | Deskripsi empty state catatan |
| | `copyIbarahAction` | `Salin ibarah` | Tombol aksi salin kutipan |
| | `viewReferenceAction` | `Lihat rujukan` | Tombol buka rujukan kitab |
| | `shareReferenceTooltip` | `Bagikan catatan` | Tooltip aksi share |
| | `saveAnswerMenu` | `Simpan ke Catatan` | Menu context save |
| **Akun & Pengaturan** | `profile` | `Profil` | Header menu profil |
| | `subscription` | `Langganan` | Label item langganan |
| | `activeSubscription` | `Langganan aktif` | Status akun aktif |
| | `inactiveSubscription` | `Belum berlangganan. Akses dibuka dengan voucher atau paket.` | Status akun belum bayar |
| | `appearance` | `Tampilan` | Label preferensi tema |
| | `modeDark` | `Gelap` | Pilihan tema dark |
| | `modeLight` | `Terang` | Pilihan tema light |
| | `modeSystem` | `Sistem` | Pilihan tema auto/system |
| | `language` | `Bahasa` | Label pengaturan bahasa |
| | `languageIndonesian` | `Bahasa Indonesia` | Bahasa aktif saat ini |
| | `logoutDialogTitle` | `Keluar dari akun?` | Judul konfirmasi keluar |
| | `logoutDialogBody` | `Anda akan keluar dari akun ini.` | Pesan konfirmasi keluar |
| | `logoutButton` | `Keluar` | Tombol konfirmasi logout |
| | `deleteAccountTitle` | `Hapus akun?` | Judul konfirmasi hapus akun |
| | `deleteAccountBody` | `Tindakan ini tidak dapat dibatalkan. Profil, simpanan, dan data akun Anda akan dihapus dari server.` | Pesan peringatan hapus akun |
| | `deleteAccountButton` | `Hapus akun` | Tombol aksi destruktif |
| | `deleteAccountSuccess` | `Akun Anda sudah dihapus.` | SnackBar notifikasi akun terhapus |
| | `recentLoginRequired` | `Untuk menghapus akun, masuk ulang terlebih dahulu.` | Pesan keamanan re-auth |
| | `networkError` | `Koneksi bermasalah. Coba lagi.` | Pesan kendala jaringan |

---

## 2. Data Master Asisten AI, Disiplin Ilmu & Literatur (Models)

Sumber berkas: `openturath_ai/lib/models/agent_model.dart` & `openturath_ai/lib/models/field_model.dart`

### A. Daftar 6 Disiplin Keilmuan Utama (FieldModel)
1. **Fikih Tahawwulat** (`fiqh_tahawwulat`)  
   *Deskripsi:* "Manhaj eskatologi Islam, rukun keempat, tanda-tanda zaman, dan sanad Al-Habib Abu Bakar Al-Masyhur."
2. **Fikih** (`fiqh`)  
   *Deskripsi:* "Hukum ibadah, muamalah, fatwa, dan perbandingan mazhab mu'tabar."
3. **Hadits** (`hadith`)  
   *Deskripsi:* "Takhrij sanad, dirayah perawi, dan syarah Kutubus Sittah."
4. **Tafsir** (`tafsir`)  
   *Deskripsi:* "Asbabun nuzul, munasabah, dan khazanah tafsir bil-ma'tsur wal-ra'yi."
5. **Aqidah** (`aqidah`)  
   *Deskripsi:* "Kalam Asy'ariyyah, Maturidiyyah, pembelaan ushuludin, dan dalil aqli-naqli."
6. **Usul Fiqh** (`usul`)  
   *Deskripsi:* "Kaidah istinbath hukum, dalil ijmali, maqashid syariah, dan qawaid fiqhiyyah."
7. **Bahasa Arab** (`lughah`)  
   *Deskripsi:* "Nahwu, sharaf, balaghah, dan leksikografi kamus mu'jam klasik."
8. **Sejarah & Sirah** (`tarikh`)  
   *Deskripsi:* "Sirah Nabawiyyah, khulafaur rasyidin, thabaqat ulama, dan peradaban Islam."
9. **Tasawuf & Akhlaq** (`tasawwuf`)  
   *Deskripsi:* "Penyucian jiwa (tazkiyatun nafs), adab suluk, dan hikmah ulama salafush shalih."

---

### B. Profil & Copy Asisten AI (AgentModel)

#### 1. AI Fikih Tahawwulat (`fiqh_tahawwulat`) — Status: Aktif
- **Judul:** AI Fikih Tahawwulat
- **Judul Arab:** فقه التحولات
- **Subtitle Akademik:** Manhaj Abu Bakr al-Masyhur
- **Deskripsi:** "Membantu menelusuri pembahasan Fikih Tahawwulat dari kitab dan muhadharah Habib Abu Bakar al-Masyhur."
- **Contoh Pertanyaan (Suggested Prompts):**
  1. *Bagaimana penjelasan al-ghutsā'iyyah dalam kitab?*
  2. *Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?*
  3. *Bagaimana para ulama menjelaskan sikap saat masa fitnah?*
- **Sub-Agen Spesialis:**
  - **Al-Muhaqqiq (المحقق):** "Membantu menemukan dalil, ibarah, dan rujukan yang relevan." (البحث والتحقيق وعزو النصوص إلى مصادرها)
  - **Al-Bayan (البيان):** "Menjelaskan pokok bahasan dengan bahasa yang lebih ringkas." (الشرح والبيان والتبسيط المنهجي)
- **Kitab Rujukan Utama:**
  - *Nubdzah Al-Bayan fi Ma'rifati Sunan Al-Khalaq* (نبذة البيان في معرفة سنن الخلق والبيان)
  - *Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat* (الفقه المنهجي في فقه التحولات)
- **Paket Harga:** 1 Bulan: Rp 49.000 \| 6 Bulan: Rp 299.000 \| 1 Tahun: Rp 499.000

#### 2. AI Fikih Syafi'i (`fiqh_syafii`) — Status: Aktif
- **Judul:** AI Fikih Syafi'i
- **Judul Arab:** الفقه الشافعي
- **Subtitle Akademik:** Matan · Syarah · Hasyiyah Mu'tabarah
- **Deskripsi:** "Bantuan untuk mencari keterangan dalam kitab-kitab mazhab Syafi'i."
- **Contoh Pertanyaan (Suggested Prompts):**
  1. *Apa rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i?*
  2. *Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?*
  3. *Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi?*
- **Sub-Agen Spesialis:**
  - **Al-Muhaqqiq Fikih Syafi'i (المحقق):** "Membantu menemukan dalil, ibarah, dan rujukan dalam mazhab Syafi'i." (تحقيق المعتمد في المذهب الشافعي)
- **Kitab Rujukan Utama:**
  - *Al-Umm* (الأم) — Imam Asy-Syafi'i
  - *Al-Majmu' Syarah Al-Muhadzdzab* (المجموع شرح المهذب) — Imam An-Nawawi
- **Paket Harga:** 1 Bulan: Rp 49.000 \| 6 Bulan: Rp 299.000 \| 1 Tahun: Rp 499.000

#### 3. AI Hadits & Syarah Sunnah (`hadits`) — Status: Aktif
- **Judul:** AI Hadits & Syarah Sunnah
- **Judul Arab:** الحديث الشريف وشروحه
- **Subtitle Akademik:** Kutub Sittah · Takhrij · Syarah
- **Deskripsi:** "Membantu menelusuri sanad, matan, derajat hadits, dan syarah para ulama ahli hadits."
- **Contoh Pertanyaan (Suggested Prompts):**
  1. *Bagaimana takhrij hadits innamal a'malu bin niyyat dalam Kutubus Sittah?*
  2. *Bagaimana syarah Ibnu Hajar terhadap hadits niat dalam Fathul Bari?*
  3. *Apa saja hadits mutawatir tentang larangan berdusta atas nama Rasulullah?*
- **Sub-Agen Spesialis:**
  - **Al-Muhaqqiq Hadits (المحقق):** "Spesialis penelusuran riwayat, takhrij sanad, dan syarah hadits." (تخريج الأحاديث وبيان عللها وشروحها)
- **Paket Harga:** 1 Bulan: Rp 49.000 \| 6 Bulan: Rp 299.000 \| 1 Tahun: Rp 499.000

#### 4. AI Tafsir Al-Qur'an (`tafsir`) — Status: Aktif
- **Judul:** AI Tafsir Al-Qur'an
- **Judul Arab:** التفسير وعلوم القرآن
- **Subtitle Akademik:** Tafsir bil Ma'tsur & bil Ra'yi
- **Deskripsi:** "Membantu menelaah tafsir ayat Al-Qur'an, asbabun nuzul, qira'at, dan kaidah tafsir."
- **Contoh Pertanyaan (Suggested Prompts):**
  1. *Apa asbabun nuzul surah Al-Baqarah ayat 183 tentang kewajiban puasa?*
  2. *Bagaimana penjelasan Thabari dan Ibnu Katsir mengenai ayat kursi?*
  3. *Apa penafsiran ulama tentang makna lafadz hikmah dalam Al-Qur'an?*
- **Sub-Agen Spesialis:**
  - **Al-Mufassir (المفسر):** "Penelaah ayat Al-Qur'an berbasis rujukan tafsir mu'tabar." (استنباط المعاني والبيان القرآني)
- **Paket Harga:** 1 Bulan: Rp 49.000 \| 6 Bulan: Rp 299.000 \| 1 Tahun: Rp 499.000

#### 5. AI Ushul Fiqih (`ushul_fiqh`) — Status: Aktif
- **Judul:** AI Ushul Fiqih
- **Judul Arab:** أصول الفقه والقواعد
- **Subtitle Akademik:** Risalah · Jam'ul Jawami' · Mustashfa
- **Deskripsi:** "Menelaah kaidah istinbath, dalil ijmali, qawaid fiqhiyyah, dan metodologi ushuliyyah."
- **Contoh Pertanyaan (Suggested Prompts):**
  1. *Apa perbedaan muthlaq dan 'amm serta implikasinya dalam istinbath hukum?*
  2. *Bagaimana kaidah al-ashlu fil amri lil wujub menurut ulama ushul?*
  3. *Apa saja rukun qiyas dan contoh penerapannya dalam kasus kontemporer?*
- **Sub-Agen Spesialis:**
  - **Al-Ushuli (الأصولي):** "Spesialis metodologi dalil, kaidah ushuliyyah, dan qawa'id fiqhiyyah." (تحرير المسائل الأصولية والقواعد الفقهية)
- **Paket Harga:** 1 Bulan: Rp 49.000 \| 6 Bulan: Rp 299.000 \| 1 Tahun: Rp 499.000

#### 6. AI Bahasa Arab & Balaghah (`nahwu_sharaf`) — Status: Aktif
- **Judul:** AI Bahasa Arab & Balaghah
- **Judul Arab:** علوم اللغة العربية
- **Subtitle Akademik:** Nahwu · Sharaf · Balaghah · Ma'ajim
- **Deskripsi:** "Bantuan menelaah sintaksis (i'rab), morfologi (sharaf), balaghah, dan leksikon bahasa Arab turats."
- **Contoh Pertanyaan (Suggested Prompts):**
  1. *Jelaskan i'rab bismillahirrahmanirrahim secara terperinci!*
  2. *Apa wazan dan makna fa'ala, taf'il, dan istif'al dalam kaidah sharaf?*
  3. *Apa rahasia balaghah taqdim dan ta'khir dalam surah Al-Fatihah?*
- **Sub-Agen Spesialis:**
  - **Al-Lughawi (اللغوي):** "Spesialis i'rab kalimat, timbangan sharaf, dan uslub balaghah." (إعراب التراكيب وتحليل الأساليب البيانية)
- **Paket Harga:** 1 Bulan: Rp 49.000 \| 6 Bulan: Rp 299.000 \| 1 Tahun: Rp 499.000

#### 7. Modul Segera Hadir (Coming Soon)
- **AI Fikih Hanafi (`fiqh_hanafi`):** "Fikih Mazhab Hanafi dengan rujukan Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani."
- **AI Fikih Maliki (`fiqh_maliki`):** "Fikih Mazhab Maliki berbasis naskah Al-Mudawwanah, Mukhtashar Khalil, dan Al-Qawanin Al-Fiqhiyyah."
- **AI Fikih Hanbali (`fiqh_hanbali`):** "Fikih Mazhab Hanbali merujuk Al-Mughni, Al-Inshaf, dan Zad Al-Mustaqni'."
- **AI Perbandingan Mazhab (`fiqh_muqaran`):** "Komparasi dalil dan pandangan 4 mazhab mu'tabar (Hanafi, Maliki, Syafi'i, Hanbali)."
- **AI Aqidah & Ilmu Kalam (`aqidah`):** "Kajian teologi Islam Asy'ariyyah, Maturidiyyah, dalil aqli-naqli, dan bantahan syubhat."
- **AI Sejarah & Sirah (`tarikh`):** "Sirah Nabawiyyah, khulafaur rasyidin, tarikh daulah Islam, dan thabaqat ulama."
- **AI Habib Umar bin Hafizh (`habib_umar`):** "Kumpulan fatwa, khutbah, risalah, dan arahan dakwah Al-Habib Umar bin Hafizh."
- **AI Hujjatul Islam Al-Ghazali (`imam_ghazali`):** "Khazanah pemikiran tasawuf, akhlaq, ushul, dan karya agung Ihya Ulumiddin."

---

## 3. Layar Masuk & Autentikasi (Login & Session Auth)

Sumber berkas: `openturath_ai/lib/screens/login_screen.dart` & `google_session_auth_screen.dart`

### A. Tampilan Layar Masuk (LoginScreen)
- **Simbol & Identitas:**
  - Logo: Arch Artwork (*Gerbang Turats*)
  - Nama Brand: `OpenTurath`
  - Slogan Editorial: `AI for Islamic Scholarship`
- **Tombol Masuk Google:**
  - Teks Tombol: `Lanjutkan dengan Google`
  - Status Memuat: Indikator spinner melingkar (*Progress Indicator*)
- **Persetujuan Ketentuan Legal:**
  - Teks Pengantar: `Dengan masuk, Anda menyetujui`
  - Tautan 1: `Ketentuan Layanan` (mengarah ke `https://openturath.ai/terms`)
  - Penghubung: ` & `
  - Tautan 2: `Kebijakan Privasi` (mengarah ke `https://openturath.ai/privacy`)
  - Penutup: `.`
- **Pesan Kesalahan & SnackBar:**
  - Kegagalan Buka Tautan: `Tidak dapat membuka tautan halaman.`
  - Kendala Jaringan: `Koneksi internet bermasalah. Periksa jaringan Anda.`
  - Kegagalan Masuk: `Gagal masuk akun Google. Silakan coba kembali.`

### B. Layar Sinkronisasi Sesi Google (GoogleSessionAuthScreen)
- **Header:** `Menyiapkan Sesi Riset`
- **Subtitle:** `Menghubungkan akun Google Anda dengan ekosistem NotebookLM OpenTurath.`
- **Status Loading:** `Memverifikasi kredensial Google Cloud...`
- **Tombol Lanjut:** `Buka Ruang Riset`
- **Tombol Batal:** `Kembali ke Masuk`

---

## 4. Layar Beranda / Dashboard Utama

Sumber berkas: `openturath_ai/lib/screens/dashboard_screen.dart`

### A. Bilah Status Atas & Sapaan Pengguna
- **Judul Aplikasi di Header:** `OpenTurath`
- **Format Sapaan:** `Ahlan, [Nama Pengguna]`  
  *Fallback jika nama kosong:* `Ahlan, Peneliti Turats`
- **Penanggalan Ganda:**
  - Kalender Masehi: Format lokal Indonesia (misal: *Minggu, 13 September 2026*)
  - Kalender Hijriyah: Format Arab-Hijriyah (misal: *29 Rabiul Awal 1448 H*)

### B. Kotak Penelusuran (Search Box)
- **Placeholder Input:** `Cari spesialis, bab fikih, atau kitab...`
- **Header Hasil Penelusuran:** `Hasil Penelusuran`
- **Pesan Hasil Kosong:** `Tidak ditemukan naskah atau spesialis yang sesuai.`

### C. Seksi Bidang Keilmuan Terpilih (Curated Disciplines)
- **Judul Seksi:** `Pilih Bidang Ilmu`
- **Aksi Cepat:** `Lihat Semua` (menuju ke tab Daftar Asisten AI)
- **Kartu Bidang yang Tampil:**
  1. `Fikih` — 6 spesialis
  2. `Hadits` — 1 spesialis
  3. `Tafsir` — 1 spesialis
  4. `Aqidah` — 1 spesialis
  5. `Usul Fiqh` — 1 spesialis
  6. `Bahasa Arab` — 1 spesialis

### D. Carousel Edukasi & Pengingat Ilmiah (5 Slide)
1. **Slide 1: Pengenalan**
   - *Badge:* `TENTANG OPENTURATH`
   - *Judul:* `Mengenal OpenTurath AI`
   - *Ringkasan:* `Penelaahan ibarat dan rujukan langsung dari naskah primer turats.`
   - *Penjelasan Lengkap (Modal):* `Gunakan OpenTurath untuk mencari rujukan dan membandingkan matan dengan syarah. Periksa hasilnya pada kitab asal, lalu diskusikan dengan guru dan ulama yang berkompeten.`
2. **Slide 2: Adab Talaqqi**
   - *Badge:* `ADAB TALAQQI`
   - *Judul:* `Wasilah Bantu, Bukan Pengganti Guru`
   - *Ringkasan:* `Kajian agama hakiki wajib melalui bimbingan guru dan ulama bersanad.`
   - *Penjelasan Lengkap (Modal):* `PENTING DIPAHAMI:

Kecerdasan buatan hanyalah perkakas indeksasi dan komparasi literatur ilmiah untuk mempercepat pencarian teks dan matan. Pemahaman fikih dan fatwa tetap membutuhkan bimbingan guru dan ulama yang bersanad.`
3. **Slide 3: Ihtiyath (Kehati-hatian)**
   - *Badge:* `IHTIYATH`
   - *Judul:* `Verifikasi Naskah Primer`
   - *Ringkasan:* `Selalu luangkan waktu memeriksa naskah Maktabah Syamilah atau cetak fisik.`
   - *Penjelasan Lengkap (Modal):* `Sikap wara' dan kehati-hatian (ihtiyath) menuntut peneliti untuk meninjau langsung naskah fisik primer sebelum menyimpulkan dan menyebarluaskan hasil kajian ke khalayak.`
4. **Slide 4: Amanah Ilmiah**
   - *Badge:* `AMANAH ILMIAH`
   - *Judul:* `Ketepatan Sitasi Turats`
   - *Ringkasan:* `Sertakan nama muallif, kitab, bab, dan nomor halaman dalam menukil ibarah.`
   - *Penjelasan Lengkap (Modal):* `Dalam tradisi keilmuan Islam, amanah ilmiah dijaga dengan menyertakan rujukan yang sahih: judul kitab asli, nama pengarang, bab pembahasan, serta nomor jilid dan halaman.`
5. **Slide 5: Sanad & Takhrij**
   - *Badge:* `SANAD & TAKHRIJ`
   - *Judul:* `Penelusuran Rujukan Ilmiah`
   - *Ringkasan:* `Dilengkapi kutipan ibarat teks asli dan penomoran jilid dari kitab muktamad.`
   - *Penjelasan Lengkap (Modal):* `Setiap rujukan yang ditampilkan mengacu langsung ke naskah turats, memudahkan santri dan peneliti meninjau matan dan syarah secara tertib dan presisi.`

- **Tombol Modal Slide:**
  - Teks Aksi: `Baca Selengkapnya`
  - Tombol Tutup Modal: `Mengerti & Tutup`

---

## 5. Layar Eksplorasi Spesialis AI (Specialist List)

Sumber berkas: `openturath_ai/lib/screens/specialist_list_screen.dart`

- **Header Layar:** `Asisten AI`
- **Subtitle Header:** `Khazanah asisten riset naskah primer turats`
- **Kontrol Segmentasi (Corpus Kind Control):**
  - Opsi 1: `Berdasarkan Disiplin Ilmu`
  - Opsi 2: `Berdasarkan Tokoh Ulama`
- **Filter Chips Disiplin:**
  - `Semua Bidang`, `Fikih`, `Fikih Tahawwulat`, `Hadits`, `Tafsir`, `Aqidah`, `Usul Fiqh`, `Bahasa Arab`
- **Pesan Status Asisten:**
  - Badge Aktif: `Aktif` / `Buka AI`
  - Badge Segera Hadir: `Segera Hadir`
  - SnackBar Saat Klik Coming Soon: `${agent.title} sedang dalam tahap kurasi naskah kitab primer (Segera Hadir).`
- **Empty State:** `Belum ada spesialis pada kategori ini.`

---

## 6. Layar Ruang Percakapan AI / Webview & Multi-Tab

Sumber berkas: `openturath_ai/lib/screens/agent_webview_screen.dart` & `widgets/agent_multi_tab_room.dart`

### A. Bilah Tab Multi-Room (Multi-Tab Bar)
- **Indikator Tab:** Menampilkan judul asisten yang sedang dibuka (misal: *AI Fikih Syafi'i*, *AI Hadits*)
- **Tombol Tambah Tab:** Tooltip `Buka AI Lain`
- **Tombol Tutup Tab:** Icon silang (*close*) pada tab
- **Dialog Konfirmasi Tutup Tab Terakhir:**
  - Judul: `Tutup Percakapan AI?`
  - Pesan: `Sesi percakapan akan diakhiri. Catatan yang belum disimpan ke catatan riset akan tertutup.`
  - Tombol Batal: `Batal`
  - Tombol Setuju: `Tutup Percakapan`

### B. Bilah Tindakan Header (Action Bar)
- **Tombol Buku Rujukan (Maktabah):** Tooltip `Katalog Kitab Rujukan`
- **Tombol Pengaturan Tampilan & Baca:** Tooltip `Pengaturan Tampilan & Baca`
- **Status Sesi:** `Menghubungkan AI dan Maktabah...`

### C. Menu Pengaturan Tampilan & Baca (Study Options Sheet)
- **Judul Sheet:** `Pengaturan Tampilan & Baca`
- **Pilihan Ukuran Huruf:**
  - `Kecil (85%)`, `Standar (100%)`, `Besar (115%)`, `Ekstra Besar (130%)`
- **Pilihan Perataan Teks Arab:**
  - `Kanan ke Kiri (RTL)`, `Justified / Rata Kanan-Kiri`
- **Tombol Simpan:** `Terapkan Pengaturan`

### D. Umpan Balik & SnackBar Ruang AI
- Salin Berhasil: `Jawaban disalin dan disimpan ke Catatan Riset.`
- Salin Gagal: `Jawaban belum tersimpan. Coba salin lagi.`
- Blokir Redirect Eksternal: `Navigasi ke situs eksternal dibatasi demi keamanan sesi riset.`

---

## 7. Katalog Naskah Kanonikal 2.226 Kitab (Katalog & Detail Kitab)

Sumber berkas: `openturath_ai/lib/screens/book_catalog_screen.dart` & `book_detail_screen.dart`

### A. Layar Katalog Lengkap (BookCatalogScreen)
- **Header AppBar:** `Daftar Kitab Rujukan`
- **Subtitle Dinamis (Contoh Realistis):**
  - Fikih Syafi'i: `87 Kitab Mazhab Syafi'i`
  - Hadits & Syarah: `1.173 Kitab AI Hadits & Syarah Sunnah`
  - Ushul Fiqih: `241 Kitab AI Ushul Fiqih`
  - Bahasa & Sastra Arab: `449 Kitab AI Bahasa Arab & Balaghah`
  - Tafsir & Ulumul Qur'an: `218 Kitab AI Tafsir Al-Qur'an`
  - Fikih Tahawwulat: `58 Kitab AI Fikih Tahawwulat`
- **Kolom Pencarian:**
  - Placeholder: `Cari judul Arab/Latin, pengarang, muhaqqiq...`
  - Tombol Bersihkan: Icon close
- **Bilah Filter Dinamis (Filter Chips Bar):**
  - *Mode 1 (Tafsir & Bahasa Arab — Multipel Sub-Bagian):*
    - `Semua Bagian`, `النحو والصرف`, `البلاغة`, `الغريب والمعاجم`, `كتب اللغة`, `Tafsir bi al-Ma'tsur`, `Tafsir bi al-Ra'y`, `Ahkam al-Qur'an`, dll.
  - *Mode 2 (Fikih Syafi'i — Era & Tipe):*
    - Era: `Semua Era`, `Mutaqaddimin`, `Ashab Al-Wujuh`, `Muta'akhkhirin`
    - Tipe: `Asal Mazhab`, `Matan`, `Syarah`, `Hasyiyah`
  - *Mode 3 (Hadits, Ushul & Tahawwulat — Abad Kronologis):*
    - `Semua Era`, `Salaf (≤ 300 H)`, `Mutaqaddimin (301-600 H)`, `Muta'akhkhirin (601-1100 H)`, `Mu'ashir (> 1100 H)`
- **Header Jumlah Temuan:**
  - `Menampilkan X dari Y naskah`
- **Tombol Reset Filter:** `Reset`
- **Empty State:**
  - Judul: `Tidak ditemukan kitab yang sesuai.`
  - Subtitle: `Coba gunakan kata kunci judul Arab, nama pengarang, atau muhaqqiq.`
  - Tombol Aksi: `Hapus Semua Filter`
- **Error State:**
  - Pesan: `Daftar kitab belum bisa dimuat.`
  - Tombol Aksi: `Coba lagi`

### B. Layar Detail Edisi Kitab (BookDetailScreen)
- **Header AppBar:** `Keterangan kitab`
- **Tombol Aksi Header:**
  - Bookmark: Tooltip `Simpan Rujukan` / `Hapus Rujukan`
  - Share/Sitasi: Tooltip `Salin Sitasi Standar`
- **Kartu 1: Identitas Kitab (Hero Card)**
  - Badge: `[Nama Bagian/Disiplin]` (misal: *كتب السنة* atau *Naskah Kanonikal · Syafi'i*)
  - Nomor Identitas Naskah: `#[ID Edisi]` (misal: *#1*, *#kitab_al_umm_shafii*)
  - Judul Arab Lengkap: Format RTL tipografi besar
  - Nama Ringkas (*al-Ism al-Mukhtashar*): `المختصر: [Nama Pendek]`
  - Transliterasi Latin: Nama Latin miring (italic)
- **Kartu 2: Muallif / Pengarang**
  - Header Seksi: `MUALLIF / PENGARANG`
  - Nama Pengarang Arab: Teks tebal
  - Nama Pengarang Latin: Teks sekunder
  - Badge Wafat Hijriyah: `Wafat: [Tahun] Hijriyah` atau `Wafat: Dalam verifikasi sanad`
- **Kartu 3: Klasifikasi Ilmiah**
  - Header Seksi: `KLASIFIKASI ILMIAH`
  - Baris 1: Label `Tipe Naskah` — Nilai: *Kitab Referensi Mazhab / Matan / Syarah*
  - Baris 2: Label `Era Keilmuan` — Nilai: *Mutaqaddimin / Salaf / Abad ke-X H*
  - Baris 3: Label `Jumlah Jilid` — Nilai: *[X] Jilid / Naskah Tunggal*
  - Baris 4 (Opsional): Label `Derajat Mu'tabar` — Nilai: *Mu'tamad Mazhab*
- **Kartu 4: Data Edisi & Tahqiq**
  - Header Seksi: `DATA EDISI & TAHQIQ`
  - Baris 1: Label `Penerbit Rujukan` — Nilai: *[Nama Penerbit] / Informasi penerbit belum tersedia*
  - Baris 2: Label `Pentahqiq / Muhaqqiq` — Nilai: *[Nama Muhaqqiq] / Cetakan klasik / belum tercatat*
  - Baris 3 (Opsional): Label `Tahun / Edisi Cetak` — Nilai: *[Tahun Cetak]*
- **Format Salinan Sitasi Ilmiah:**
  - `[Pengarang] (w. [Tahun] H). [Judul Kitab], [Jumlah Jilid] Jilid, [Muhaqqiq], Penerbit: [Penerbit], Th. [Tahun Cetak]. OpenTurath AI Canonical Corpus.`
  - Pesan Sukses: `Sitasi standar ilmiah tersalin ke papan klip.`
  - Pesan Simpan Rujukan: `Kitab disimpan ke Catatan Riset.`
  - Pesan Hapus Rujukan: `Rujukan dihapus dari Catatan Riset.`

---

## 8. Layar Catatan Riset, Simpanan & Editor Catatan (Bookmark & Notes)

Sumber berkas: `openturath_ai/lib/screens/bookmark_screen.dart` & `widgets/note_editor_sheet.dart`

### A. Layar Catatan Riset (BookmarkScreen)
- **Header Layar:** `Catatan Riset`
- **Tombol Aksi:**
  - Tambah Catatan: Tooltip `Tambah Catatan Baru`
  - Cari Catatan: Tooltip `Cari catatan` / `Tutup pencarian`
- **Kotak Pencarian:** Placeholder `Cari catatan, topik, atau kutipan...`
- **Filter Tab Kategori:**
  - `Semua`, `Catatan Riset`, `Kutipan Ibarah`, `Rujukan Kitab`
- **Filter Chips Disiplin:**
  - `Semua`, `Fikih`, `Hadis`, `Tafsir`, `Akidah`, `Usul Fiqih`
- **Kartu Catatan:**
  - Badge Asisten: Menampilkan asisten perujuk
  - Tombol Aksi per Kartu: `Edit`, `Salin ibarah`, `Kitab`
  - Tooltip Hapus: `Hapus Catatan`
  - Tooltip Bagikan: `Bagikan catatan`
- **Empty State:**
  - Judul: `Belum ada catatan`
  - Penjelasan: `Simpan telaah atau ibarah ke dalam catatan riset Anda.`
  - Tombol CTA: `Buka kajian`
- **Dialog Hapus Catatan:**
  - Judul: `Hapus Catatan Riset?`
  - Pesan: `Catatan ini akan dihapus secara permanen dari penyimpanan perangkat Anda.`
  - Tombol Batal: `Batal`
  - Tombol Hapus: `Hapus`
  - SnackBar: `Catatan riset telah dihapus.`

### B. Editor Catatan Riset (NoteEditorSheet)
- **Header Modal:** `Edit Catatan` / `Catatan Baru`
- **Input Judul:** Placeholder `Judul Catatan...`
- **Input Isi/Ibarah:** Placeholder `Tulis atau edit telaah, ibarat naskah, dan catatan riset...`
- **Toolbar Format Teks:**
  - Tooltips: `Tebal`, `Miring`, `Daftar Poin`, `Kutipan`, `Kutipan Arab`, `Judul Bab`, `Sub-bab`
- **Input Rujukan:**
  - Label: `Rujukan Kitab`
  - Input Kitab: Placeholder `Nama kitab rujukan...`
  - Input Halaman/Jilid: Placeholder `Jilid/Hal...`
- **Tombol Aksi:**
  - Batal: `Batal`
  - Simpan: `Simpan Perubahan` / `Simpan Catatan`
- **Pesan SnackBar:**
  - Validasi: `Judul atau isi catatan tidak boleh kosong.`
  - Berhasil: `Catatan riset berhasil disimpan.`

---

## 9. Layar Langganan, Paket Riset & Checkout DOKU

Sumber berkas: `openturath_ai/lib/screens/subscription_screen.dart` & `widgets/doku_checkout_sheet.dart`

### A. Layar Langganan (SubscriptionScreen)
- **Header AppBar:** `Langganan & Akses AI`
- **Tombol Tukar Voucher di Header:** `Klaim Voucher`
- **Status Langganan Pengguna:**
  - *Jika Aktif:* `Langganan Aktif` — `Berlaku hingga [Tanggal]`
  - *Jika Belum/Kedaluwarsa:* `Belum Berlangganan` — `Akses penuh dibuka dengan paket atau voucher.`
- **Pilihan Paket:**
  1. **Paket 1 Bulan:**
     - Harga: `Rp 49.000` / bulan
     - Deskripsi: `Akses riset intensif modul terpilih selama 30 hari penuh.`
  2. **Paket 6 Bulan:**
     - Harga: `Rp 299.000` / 6 bulan
     - Badge: `HEMAT 15%`
     - Deskripsi: `Pilihan ideal untuk santri dan peneliti tugas akhir.`
  3. **Paket 1 Tahun (Full Year):**
     - Harga: `Rp 499.000` / tahun
     - Badge: `PALING HEMAT`
     - Deskripsi: `Akses tanpa batas setahun penuh untuk seluruh khazanah naskah.`
- **Daftar Keunggulan Paket:**
  - `Akses tanpa batas ke ribuan naskah turats kanonikal.`
  - `Pencarian ibarah presisi dengan kutipan jilid dan halaman asli.`
  - `Multi-Room: Buka banyak asisten sekaligus tanpa memuat ulang.`
  - `Penyimpanan Catatan Riset tak terbatas langsung di perangkat.`
- **Dialog Input WhatsApp Konfirmasi:**
  - Judul: `Nomor WhatsApp Konfirmasi`
  - Penjelasan: `Masukkan nomor WhatsApp aktif untuk pengiriman bukti aktivasi langganan dan rincian transaksi riset Anda.`
  - Placeholder: `Contoh: 081234567890`
  - Tombol Batal: `Batal`
  - Tombol Lanjut: `Lanjutkan Pembayaran`
  - Validasi Error: `Masukkan nomor telepon yang valid.`

### B. Lembar Pembayaran DOKU (DokuCheckoutSheet)
- **Header:** `Pembayaran Aman DOKU`
- **Subtitle:** `Transaksi terenkripsi dan diverifikasi secara instan.`
- **Metode Pembayaran yang Didukung:**
  - `QRIS (GoPay, OVO, Dana, ShopeePay, BCA, dll.)`
  - `Virtual Account (BCA, Mandiri, BNI, BRI, Permata)`
  - `Gerai Retail / Minimarket`
- **Tombol Status:**
  - Tooltip: `Periksa Status Pembayaran & Muat Ulang`
  - Tooltip Tutup: `Tutup`
- **Dialog Konfirmasi Batalkan Pembayaran:**
  - Judul: `Tutup Laman Pembayaran?`
  - Pesan: `Apakah Anda ingin menutup sesi pembayaran? Transaksi Anda tetap tercatat di sistem.`
  - Tombol 1: `Lanjutkan Bayar`
  - Tombol 2: `Ya, Tutup`
- **Pesan Status Transaksi:**
  - Berhasil: `Pembayaran berhasil dikonfirmasi! Akses langganan telah aktif.`
  - Menunggu: `Menunggu konfirmasi pembayaran dari DOKU.`
  - Gagal/Batal: `Sesi pembayaran telah berakhir atau dibatalkan.`

---

## 10. Lembar Klaim Voucher Akses (Redeem Code Sheet)

Sumber berkas: `openturath_ai/lib/widgets/redeem_code_sheet.dart`

- **Header Lembar:** `Tukar Kode Voucher`
- **Deskripsi:** `Masukkan kode akses atau voucher khusus untuk mengaktifkan langganan modul riset OpenTurath.`
- **Form Input:**
  - Placeholder: `Masukkan kode akses`
  - Format Teks: Huruf kapital otomatis (*Auto-capitalized*)
- **Tombol Aksi:**
  - Teks Tombol: `Klaim Akses Sekarang`
  - Status Loading: Spinner animasi melingkar
- **Kamus Pesan Validasi & Kesalahan:**
  - Input Kosong: `Silakan masukkan kode akses terlebih dahulu.`
  - Kode Salah: `Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda.`
  - Sudah Digunakan: `Anda sudah pernah menukarkan kode voucher ini.`
  - Kuota Habis: `Kuota penukaran untuk kode voucher ini sudah habis.`
  - Kedaluwarsa: `Masa berlaku kode voucher ini telah berakhir.`
  - Sukses Penukaran: `Voucher berhasil ditukarkan! Akses modul telah diaktifkan.`

---

## 11. Layar Profil, Pengaturan Akun & Dokumen Legal (Terms, Privacy, Adab)

Sumber berkas: `openturath_ai/lib/screens/profile_screen.dart`

### A. Informasi Akun Pengguna
- **Header Layar:** `Pengaturan`
- **Badge Tipe Akun:** `Pengguna OpenTurath` / `Santri Peneliti`
- **Detail Akun:** Menampilkan Nama Lengkap, Alamat Email Google, serta ID Pengguna
- **Status Langganan:**
  - `Akses Penuh Seluruh Modul AI · Aktif sampai [Tanggal]`
  - `Belum berlangganan. Akses dibuka dengan voucher atau paket.`

### B. Menu Preferensi & Tampilan
- **Seksi:** `Tampilan & Kebahasaan`
- **Pengaturan Tema:**
  - Judul: `Tampilan`
  - Pilihan: `Ikuti Sistem`, `Terang`, `Gelap`
- **Pengaturan Bahasa:**
  - Judul: `Bahasa`
  - Nilai: `Bahasa Indonesia`

### C. Dokumen Kebijakan & Legalitas (Modal Dialogs)
1. **Tentang OpenTurath (About OpenTurath)**
   - Judul: `Tentang OpenTurath`
   - Versi: `Versi 1.0.9 · Membaca kitab, menelusuri ibarah.`
   - Isi: `OpenTurath adalah platform kecerdasan buatan terapan untuk literatur dan turats Islam klasik. Dibangun untuk mempermudah santri, asatidz, akademisi, dan peneliti dalam menelusuri matan, syarah, takhrij, dan ibarah mu'tabarah secara terstruktur.`
   - Tombol: `Tutup`
2. **Ketentuan Layanan (Terms of Service)**
   - Judul: `Ketentuan Layanan OpenTurath`
   - Butir 1: `1. Ruang Lingkup & Tujuan Riset` — Digunakan untuk riset akademis dan literatur keislaman.
   - Butir 2: `2. Verifikasi Sumber Asli & Batasan Penggunaan` — Kecerdasan buatan bukan pemberi fatwa mutlak. Pengguna wajib mencocokkan kutipan dengan naskah fisik.
   - Butir 3: `3. Akun Pengguna & Hak Akses` — Akun bersifat personal dan tidak boleh disalahgunakan.
   - Butir 4: `4. Ketentuan Pembayaran & Berlangganan` — Pembayaran resmi diproses melalui gateway pembayaran terlisensi.
   - Tombol Persetujuan: `Saya Pahami & Setuju`
3. **Kebijakan Privasi (Privacy Policy)**
   - Judul: `Kebijakan Privasi Pengguna`
   - Butir 1: `1. Pengumpulan & Penggunaan Data` — Mengumpulkan data email dan profil Google dasar demi kelancaran otentikasi.
   - Butir 2: `2. Kerahasiaan Sesi & Catatan Riset` — Catatan riset dan bookmark disimpan secara aman dan terenkripsi.
   - Butir 3: `3. Keamanan Sesi Google & NotebookLM` — Mematuhi protokol otentikasi resmi Google OAuth.
   - Butir 4: `4. Hak Penghapusan Data Pengguna` — Pengguna berhak menghapus akun dan seluruh datanya kapan saja.
   - Tombol Tutup: `Tutup`
4. **Metodologi Riset & Verifikasi Naskah**
   - Judul: `Metodologi Naskah & Sanad Rujukan`
   - Isi: `Setiap asisten AI di OpenTurath terhubung dengan korpus naskah primer yang telah diverifikasi kelengkapan jilid, nama muallif, dan tahun wafat hijriyahnya berstandar Maktabah Syamilah.`
   - Tombol: `Tutup`

### D. Manajemen Sesi & Keamanan Akun
- **Tombol Keluar (Logout):**
  - Label: `Keluar dari Akun`
  - Dialog Konfirmasi: `Keluar dari akun?` — `Anda akan keluar dari akun ini.`
  - Tombol: `Batal` \| `Keluar`
- **Tombol Hapus Akun (Destructive Action):**
  - Label: `Hapus Akun & Data Riset`
  - Dialog Peringatan: `Hapus akun?`
  - Pesan Bahaya: `Tindakan ini tidak dapat dibatalkan. Profil, simpanan, dan data akun Anda akan dihapus dari server.`
  - Tombol: `Batal` \| `Hapus akun`
  - Pesan Berhasil: `Akun Anda sudah dihapus.`
  - Pesan Keamanan Re-Login: `Untuk menghapus akun, masuk ulang terlebih dahulu.`

---

## 12. Komponen Pendukung: Bukti Ibarah, Banner Update & Pesan Sistem

### A. Lembar Bukti Ibarah (EvidenceBottomSheet)
Sumber berkas: `openturath_ai/lib/widgets/evidence_bottom_sheet.dart`
- **Header Sheet:** `Kutipan Ibarah Asli`
- **Metadata Kutipan:**
  - Label Penulis: `Penulis`
  - Label Halaman: `Halaman` / `Jilid`
  - Label Kategori: `Kategori`
- **Teks Arab:** Teks asli matan/ibarah berharakat
- **Tombol Aksi:**
  - `Salin Teks` (Pesan: *Teks disalin*)
  - `Cari di Syamilah`
  - Tooltip: `Salin sitasi` (Pesan: *Sitasi disalin*)

### B. Banner Pembaruan Aplikasi (UpdateReadyBanner)
Sumber berkas: `openturath_ai/lib/widgets/update_ready_banner.dart`
- **Badge:** `PEMBARUAN TERSEDIA`
- **Judul Banner:** `Versi Baru OpenTurath Siap Dipasang`
- **Penjelasan:** `Pembaruan sistem membawa perbaikan stabilitas dan penambahan naskah kitab rujukan.`
- **Tombol Pasang:** `Perbarui Sekarang`
- **Tombol Nanti:** `Nanti Saja`

### C. Status Gangguan & Error Global (AppErrorState)
Sumber berkas: `openturath_ai/lib/widgets/app_error_state.dart`
- **Judul:** `Gagal Memuat Data`
- **Deskripsi:** `Terjadi kendala saat menghubungkan ke server naskah. Periksa sambungan internet Anda.`
- **Tombol:** `Muat Ulang Halaman`

---
*Dokumen ini digenerasi secara otomatis dari audit kode sumber aktif OpenTurath AI.*
