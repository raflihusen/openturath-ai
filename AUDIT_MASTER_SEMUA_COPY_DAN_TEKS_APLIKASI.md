# Master revisi teks aplikasi OpenTurath

Revisi redaksional berdasarkan seluruh 12 bagian dalam AUDIT_MASTER_SEMUA_COPY_DAN_TEKS_APLIKASI.md yang dilampirkan pengguna. Tanggal audit: 13 September 2026.

**Status:** teks pengganti sudah disusun di dokumen ini. Kode aplikasi dan tampilan aplikasi yang berjalan belum diubah atau diuji karena tidak disertakan dalam lampiran saat ini.

Gunakan bersama OPENTURATH_HASIL_AUDIT_COPY.md dan OPENTURATH_PETA_PENGGANTIAN_COPY.json. Baris bertanda perlu pemeriksaan di peta penggantian masih harus disesuaikan dengan perilaku atau data produk. Bagian kebijakan memuat draf yang belum siap tayang, termasuk isian dalam kurung siku. Jangan memasukkan catatan editorial dan isian tersebut ke antarmuka.

Nama konstanta, ID asisten, jalur berkas, judul bibliografis, dan teks sumber Arab dipertahankan. Perubahan label tampilan tidak mengubah nilai teknisnya. Angka katalog, harga, versi, platform, dan metadata kitab mengikuti dokumen asal dan belum diverifikasi terhadap aplikasi aktif.

---

## Daftar Isi

1. [Kamus teks utama (AppCopy)](#1-kamus-teks-utama-appcopy)
2. [Data Master Asisten AI, Disiplin Ilmu & Literatur (Models)](#2-data-master-asisten-ai-disiplin-ilmu--literatur-models)
3. [Layar Masuk & Autentikasi (Login & Session Auth)](#3-layar-masuk--autentikasi-login--session-auth)
4. [Layar Beranda / Dashboard Utama](#4-layar-beranda--dashboard-utama)
5. [Layar Eksplorasi Spesialis AI (Specialist List)](#5-layar-eksplorasi-spesialis-ai-specialist-list)
6. [Layar Ruang Percakapan AI / Webview & Multi-Tab](#6-layar-ruang-percakapan-ai--webview--multi-tab)
7. [Katalog 2.226 Kitab Rujukan (Katalog & Detail Kitab)](#7-katalog-2226-kitab-rujukan-katalog--detail-kitab)
8. [Layar Catatan, Simpanan & Editor Catatan (Bookmark & Notes)](#8-layar-catatan-simpanan--editor-catatan-bookmark--notes)
9. [Layar Langganan, Paket Riset & Checkout DOKU](#9-layar-langganan-paket-riset--checkout-doku)
10. [Lembar Klaim Voucher Akses (Redeem Code Sheet)](#10-lembar-klaim-voucher-akses-redeem-code-sheet)
11. [Layar Profil, Pengaturan Akun & Dokumen Legal (Terms, Privacy, Adab)](#11-layar-profil-pengaturan-akun--dokumen-legal-terms-privacy-adab)
12. [Komponen Pendukung: Bukti Ibarah, Banner Update & Pesan Sistem](#12-komponen-pendukung-bukti-ibarah-banner-update--pesan-sistem)

---

## 1. Kamus teks utama (AppCopy)

Sumber berkas: `openturath_ai/lib/core/app_copy.dart`  
Fungsi: Acuan utama untuk istilah berulang, navigasi, dialog adab talaqqi, dan umpan balik sistem.

| Kategori | Konstanta | Teks Revisi | Konteks & Catatan Penggunaan |
|:---|:---|:---|:---|
| **Identitas & Merek** | `appName` | `OpenTurath` | Nama resmi aplikasi |
| | `appTagline` | `Membaca kitab, menelusuri ibarah.` | Tagline utama pada profil & splash |
| | `defaultFieldDesc` | `Pelajari berbagai bidang ilmu melalui kitab-kitab Islam.` | Deskripsi bidang umum |
| | `aboutTitle` | `Tentang OpenTurath` | Judul modal informasi aplikasi |
| | `aboutDescription` | `OpenTurath membantu Anda membaca, mencari, dan membandingkan keterangan dari kitab-kitab rujukan.` | Deskripsi ringkas visi aplikasi |
| | `aboutScholarlyPrinciple` | `Gunakan jawaban AI untuk membantu menelusuri rujukan. Periksa kutipannya pada kitab asal dan mintalah bimbingan guru atau ulama saat mempelajari persoalan agama.` | Prinsip adab riset ilmiah |
| **Navigasi Utama** | `navHome` | `Beranda` | Tab navigasi 1 di Bottom Bar |
| | `navStudies` | `Asisten AI` | Tab navigasi 2 di Bottom Bar |
| | `navSaved` | `Catatan` | Tab navigasi 3 di Bottom Bar |
| | `navSettings` | `Pengaturan` | Tab navigasi 4 di Bottom Bar |
| **Istilah Ruang & Kajian** | `studySpace` | `Percakapan` | Istilah resmi ruang interaksi |
| | `openStudy` | `Membuka percakapan…` | Status memuat sesi percakapan |
| | `studyOptions` | `Tampilan bacaan` | Menu modal reader / font size |
| | `referenceBooks` | `Kitab rujukan` | Label daftar kitab rujukan |
| | `savedCollection` | `Catatan` | Label koleksi riset |
| | `bookDetails` | `Detail kitab` | Header AppBar detail naskah |
| **Loading & Akses** | `loadingReferences` | `Menyiapkan percakapan…` | Subtitle loading saat inisialisasi AI |
| | `modulePreparing` | `sedang disiapkan.` | Status modul coming soon |
| | `moduleUnavailable` | `Asisten ini belum tersedia. Coba lagi nanti.` | Pesan modul belum aktif |
| | `cannotLoad` | `Konten belum bisa dimuat. Coba lagi.` | Pesan kegagalan umum |
| | `cannotLoadStudy` | `Percakapan belum bisa dibuka` | Pesan kegagalan buka AI |
| | `studyNotLoadedYet` | `Percakapan belum bisa dimuat. Coba lagi sebentar.` | Pesan penundaan sesi |
| | `subscriptionRequiredTitle`| `Pilih paket untuk melanjutkan` | Dialog pengingat langganan |
| | `catalogLoadFailed` | `Daftar kitab belum bisa dimuat.` | Pesan error muat katalog |
| | `inputQuestionHint` | `Tulis pertanyaan tentang kitab ini` | Placeholder input teks |
| | `viewSubscription` | `Lihat paket` | Tombol CTA langganan |
| | `tryAgain` | `Coba lagi` | Tombol retry |
| **Platform & Perangkat** | `deviceNotSupportedTitle` | `Perangkat belum didukung` | Error platform guard |
| | `deviceNotSupportedMessage`| `OpenTurath saat ini mendukung Android, macOS, dan Windows. Perangkat ini belum didukung.` | Penjelasan kompatibilitas platform |
| | `cannotConnectTitle` | `Belum bisa terhubung` | Header dialog offline |
| | `cannotConnectMessage` | `OpenTurath belum bisa terhubung. Periksa koneksi internet, lalu coba lagi.` | Pesan offline |
| **Dialog Adab Talaqqi** | `adabDialogTitle` | `Catatan sebelum mulai` | Judul dialog pengingat adab |
| | `adabAcknowledgeButton` | `Mengerti` | Tombol persetujuan dialog adab |
| | `adabHeading1` | `Bantuan untuk membaca kitab` | Poin adab 1 |
| | `adabBody1` | `OpenTurath membantu mencari ibarah, yaitu kutipan teks dari kitab, dan membandingkan penjelasannya. Jawaban AI bisa keliru. Cocokkan kutipan dengan kitab asal di Maktabah Syamilah atau edisi cetaknya.` | Uraian poin adab 1 |
| | `adabHeading2` | `Belajar tetap perlu bimbingan` | Poin adab 2 |
| | `adabBody2` | `Pelajari persoalan agama bersama guru atau ulama yang memahami bidangnya.` | Uraian poin adab 2 |
| | `adabHeading3` | `Periksa kembali rujukan` | Poin adab 3 |
| | `adabBody3` | `Baca konteks pembahasan dalam kitab sebelum menggunakan atau membagikan jawaban.` | Uraian poin adab 3 |
| **Umpan Balik (Feedback)** | `noAnswerToCopy` | `Belum ada jawaban untuk disalin.` | SnackBar validasi salin |
| | `answerCopied` | `Jawaban disalin dan disimpan di Catatan.` | SnackBar salin sukses |
| | `copyFailed` | `Belum bisa menyalin. Coba lagi.` | SnackBar salin gagal |
| | `noAnswerToSave` | `Belum ada jawaban untuk disimpan.` | SnackBar simpan kosong |
| | `savedSuccess` | `Tersimpan di Catatan.` | SnackBar simpan sukses |
| | `saveFailed` | `Belum bisa menyimpan. Coba lagi.` | SnackBar simpan gagal |
| **Catatan** | `searchSavedHint` | `Cari catatan, topik, atau kutipan` | Placeholder search box catatan |
| | `searchSavedTooltip` | `Cari catatan` | Tooltip icon search |
| | `noSavedTitle` | `Belum ada catatan` | Judul empty state catatan |
| | `noSavedDescription` | `Simpan jawaban, kutipan, atau rujukan kitab di sini.` | Deskripsi empty state catatan |
| | `copyIbarahAction` | `Salin ibarah` | Tombol aksi salin kutipan |
| | `viewReferenceAction` | `Lihat rujukan` | Tombol buka rujukan kitab |
| | `shareReferenceTooltip` | `Bagikan catatan` | Tooltip aksi share |
| | `saveAnswerMenu` | `Simpan ke Catatan` | Menu context save |
| **Akun & Pengaturan** | `profile` | `Profil` | Header menu profil |
| | `subscription` | `Langganan` | Label item langganan |
| | `activeSubscription` | `Langganan aktif` | Status akun aktif |
| | `inactiveSubscription` | `Pilih paket atau gunakan voucher untuk mengakses asisten AI.` | Status akun belum bayar |
| | `appearance` | `Tampilan` | Label preferensi tema |
| | `modeDark` | `Gelap` | Pilihan tema dark |
| | `modeLight` | `Terang` | Pilihan tema light |
| | `modeSystem` | `Ikuti perangkat` | Pilihan tema auto/system |
| | `language` | `Bahasa` | Label pengaturan bahasa |
| | `languageIndonesian` | `Bahasa Indonesia` | Bahasa aktif saat ini |
| | `logoutDialogTitle` | `Keluar dari akun` | Judul konfirmasi keluar |
| | `logoutDialogBody` | `Anda akan keluar dari akun ini.` | Pesan konfirmasi keluar |
| | `logoutButton` | `Keluar` | Tombol konfirmasi logout |
| | `deleteAccountTitle` | `Hapus akun` | Judul konfirmasi hapus akun |
| | `deleteAccountBody` | `Akun Anda akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.` | Pesan peringatan hapus akun |
| | `deleteAccountButton` | `Hapus akun` | Tombol aksi destruktif |
| | `deleteAccountSuccess` | `Akun Anda sudah dihapus.` | SnackBar notifikasi akun terhapus |
| | `recentLoginRequired` | `Masuk kembali untuk melanjutkan penghapusan akun.` | Pesan keamanan re-auth |
| | `networkError` | `Koneksi internet bermasalah. Coba lagi.` | Pesan kendala jaringan |

---

## 2. Data Master Asisten AI, Disiplin Ilmu & Literatur (Models)

Sumber berkas: `openturath_ai/lib/models/agent_model.dart` & `openturath_ai/lib/models/field_model.dart`

### A. Daftar 9 Bidang Ilmu (FieldModel)
1. **Fikih Tahawwulat** (`fiqh_tahawwulat`)  
   *Deskripsi:* "Pembahasan perubahan zaman dan tanda-tanda akhir zaman dalam pemikiran Habib Abu Bakar al-Masyhur."
2. **Fikih** (`fiqh`)  
   *Deskripsi:* "Pelajari hukum ibadah, muamalah, fatwa, dan perbedaan pendapat antarmazhab."
3. **Hadis** (`hadith`)  
   *Deskripsi:* "Telusuri sumber hadis, keterangan tentang perawi, dan penjelasan ulama dalam Kutubus Sittah."
4. **Tafsir** (`tafsir`)  
   *Deskripsi:* "Pelajari penafsiran Al-Qur'an, sebab turunnya ayat, dan hubungan antarayat."
5. **Akidah** (`aqidah`)  
   *Deskripsi:* "Pelajari akidah Asy'ariyyah dan Maturidiyyah beserta dalil dan penjelasannya."
6. **Usul Fikih** (`usul`)  
   *Deskripsi:* "Pelajari cara ulama menggali hukum, memahami dalil, serta membahas tujuan syariat dan kaidah fikih."
7. **Bahasa Arab** (`lughah`)  
   *Deskripsi:* "Pelajari nahwu, saraf, balagah, dan kosakata dalam kamus Arab klasik."
8. **Sejarah dan Sirah** (`tarikh`)  
   *Deskripsi:* "Telusuri kehidupan Nabi, Khulafaur Rasyidin, biografi ulama, dan sejarah peradaban Islam."
9. **Tasawuf dan Akhlak** (`tasawwuf`)  
   *Deskripsi:* "Pelajari penyucian jiwa, adab, akhlak, dan nasihat para ulama."

---

### B. Profil & Copy Asisten AI (AgentModel)

#### 1. AI Fikih Tahawwulat (`fiqh_tahawwulat`) : Status: Aktif
- **Judul:** AI Fikih Tahawwulat
- **Judul Arab:** فقه التحولات
- **Subtitle Akademik:** Pemikiran Habib Abu Bakar al-Masyhur
- **Deskripsi:** "Telusuri pembahasan Fikih Tahawwulat dalam kitab dan ceramah Habib Abu Bakar al-Masyhur."
- **Contoh permintaan:**
  1. *Jelaskan makna al-ghutsā'iyyah berdasarkan kitab rujukan.*
  2. *Jelaskan istilah Rukun Keempat dalam Fikih Tahawwulat menurut Habib Abu Bakar al-Masyhur.*
  3. *Telusuri penjelasan ulama tentang sikap menghadapi masa fitnah.*
- **Sub-Agen Spesialis:**
  - **Al-Muhaqqiq (المحقق):** "Telusuri dalil, ibarah, dan sumber rujukannya." (البحث والتحقيق وعزو النصوص إلى مصادرها)
  - **Al-Bayan (البيان):** "Membantu memahami pokok bahasan melalui penjelasan yang lebih sederhana." (الشرح والبيان والتبسيط المنهجي)
- **Kitab Rujukan Utama:**
  - *Nubdzah Al-Bayan fi Ma'rifati Sunan Al-Khalaq* (نبذة البيان في معرفة سنن الخلق والبيان)
  - *Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat* (الفقه المنهجي في فقه التحولات)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 2. AI Fikih Syafi'i (`fiqh_syafii`) : Status: Aktif
- **Judul:** AI Fikih Syafi'i
- **Judul Arab:** الفقه الشافعي
- **Subtitle Akademik:** Matan · Syarah · Hasyiyah
- **Deskripsi:** "Temukan penjelasan fikih dalam kitab-kitab mazhab Syafi'i."
- **Contoh permintaan:**
  1. *Jelaskan rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i dan sertakan rujukannya.*
  2. *Jelaskan syarat sah salat berjamaah dalam Minhāj al-Ṭālibīn.*
  3. *Telusuri ketentuan zakat perdagangan menurut Imam al-Nawawi.*
- **Sub-Agen Spesialis:**
  - **Al-Muhaqqiq Fikih Syafi'i (المحقق):** "Telusuri dalil, ibarah, dan rujukan dalam mazhab Syafi'i." (تحقيق المعتمد في المذهب الشافعي)
- **Kitab Rujukan Utama:**
  - *Al-Umm* (الأم) : Imam Asy-Syafi'i
  - *Al-Majmu' Syarah Al-Muhadzdzab* (المجموع شرح المهذب) : Imam An-Nawawi
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 3. AI Hadis dan Syarah (`hadits`) : Status: Aktif
- **Judul:** AI Hadis dan Syarah
- **Judul Arab:** الحديث الشريف وشروحه
- **Subtitle Akademik:** Kutub Sittah · Takhrij · Syarah
- **Deskripsi:** "Telusuri teks hadis, sanad, penilaian derajat hadis, dan penjelasan para ulama."
- **Contoh permintaan:**
  1. *Telusuri sumber hadis innamal a'malu bin niyyat dalam Kutubus Sittah.*
  2. *Jelaskan uraian Ibnu Hajar tentang hadis niat dalam Fathul Bari.*
  3. *Telusuri hadis tentang larangan berdusta atas nama Rasulullah dan penilaian ulama terhadap riwayatnya.*
- **Sub-Agen Spesialis:**
  - **Al-Muhaqqiq Hadis (المحقق):** "Membantu menelusuri sumber riwayat dan penjelasan ulama tentang hadis." (تخريج الأحاديث وبيان عللها وشروحها)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 4. AI Tafsir Al-Qur'an (`tafsir`) : Status: Aktif
- **Judul:** AI Tafsir Al-Qur'an
- **Judul Arab:** التفسير وعلوم القرآن
- **Subtitle Akademik:** Tafsir ayat dan ilmu tafsir
- **Deskripsi:** "Pelajari tafsir ayat Al-Qur'an, sebab turunnya ayat, ragam bacaan, dan kaidah tafsir."
- **Contoh permintaan:**
  1. *Telusuri keterangan tentang sebab turunnya Surah Al-Baqarah ayat 183. Jika tidak ditemukan riwayat yang mendukung, sampaikan keterbatasannya.*
  2. *Bandingkan penjelasan Thabari dan Ibnu Katsir tentang Ayat Kursi.*
  3. *Jelaskan penafsiran ulama tentang kata hikmah dalam Al-Qur'an, disertai ayat dan rujukannya.*
- **Sub-Agen Spesialis:**
  - **Al-Mufassir (المفسر):** "Membantu memahami penjelasan ayat Al-Qur'an dalam kitab tafsir." (استنباط المعاني والبيان القرآني)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 5. AI Usul Fikih (`ushul_fiqh`) : Status: Aktif
- **Judul:** AI Usul Fikih
- **Judul Arab:** أصول الفقه والقواعد
- **Subtitle Akademik:** Dalil · Kaidah · Metode penetapan hukum
- **Deskripsi:** "Pelajari cara ulama memahami dalil dan menggali hukum, beserta kaidah usul fikih dan kaidah fikih."
- **Contoh permintaan:**
  1. *Jelaskan perbedaan muthlaq dan 'amm beserta pengaruhnya dalam penetapan hukum.*
  2. *Jelaskan kaidah al-ashlu fil amri lil wujub menurut ulama usul fikih.*
  3. *Uraikan rukun qiyas dan contoh penerapannya dalam persoalan masa kini berdasarkan rujukan.*
- **Sub-Agen Spesialis:**
  - **Al-Ushuli (الأصولي):** "Membantu mempelajari dalil, kaidah usul fikih, dan kaidah fikih." (تحرير المسائل الأصولية والقواعد الفقهية)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 6. AI Bahasa Arab dan Balagah (`nahwu_sharaf`) : Status: Aktif
- **Judul:** AI Bahasa Arab dan Balagah
- **Judul Arab:** علوم اللغة العربية
- **Subtitle Akademik:** Nahwu · Saraf · Balagah · Kamus
- **Deskripsi:** "Pelajari susunan kalimat, perubahan bentuk kata, gaya bahasa, dan kosakata dalam kitab berbahasa Arab."
- **Contoh permintaan:**
  1. *Jelaskan i'rab bismillahirrahmanirrahim kata demi kata.*
  2. *Bandingkan bentuk dan makna fa'ala, taf'il, dan istif'al berdasarkan kaidah saraf.*
  3. *Jelaskan taqdim dan ta'khir beserta contoh yang didukung rujukan dalam Surah Al-Fatihah.*
- **Sub-Agen Spesialis:**
  - **Al-Lughawi (اللغوي):** "Membantu memahami susunan kalimat, pola perubahan kata, dan gaya bahasa Arab." (إعراب التراكيب وتحليل الأساليب البيانية)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 7. Modul Segera Hadir (Coming Soon)
- **AI Fikih Hanafi (`fiqh_hanafi`):** "Pelajari fikih mazhab Hanafi melalui Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani."
- **AI Fikih Maliki (`fiqh_maliki`):** "Pelajari fikih mazhab Maliki melalui Al-Mudawwanah, Mukhtashar Khalil, dan Al-Qawanin Al-Fiqhiyyah."
- **AI Fikih Hanbali (`fiqh_hanbali`):** "Pelajari fikih mazhab Hanbali melalui Al-Mughni, Al-Inshaf, dan Zad Al-Mustaqni'."
- **AI Perbandingan Mazhab (`fiqh_muqaran`):** "Bandingkan pendapat dan dalil dalam mazhab Hanafi, Maliki, Syafi'i, dan Hanbali."
- **AI Akidah dan Ilmu Kalam (`aqidah`):** "Pelajari akidah Asy'ariyyah dan Maturidiyyah, beserta dalil dan penjelasan atas persoalan yang dibahas."
- **AI Sejarah dan Sirah (`tarikh`):** "Telusuri kehidupan Nabi, Khulafaur Rasyidin, sejarah pemerintahan Islam, dan biografi ulama."
- **AI Kajian Habib Umar bin Hafizh (`habib_umar`):** "Telusuri fatwa, khutbah, tulisan, dan nasihat dakwah Habib Umar bin Hafizh."
- **AI Kajian Imam al-Ghazali (`imam_ghazali`):** "Pelajari pemikiran Imam al-Ghazali tentang tasawuf, akhlak, dan usul fikih, termasuk dalam Ihya Ulumiddin."

---

## 3. Layar Masuk & Autentikasi (Login & Session Auth)

Sumber berkas: `openturath_ai/lib/screens/login_screen.dart` & `google_session_auth_screen.dart`

### A. Tampilan Layar Masuk (LoginScreen)
- **Simbol & Identitas:**
  - Logo: Arch Artwork (*Gerbang Turats*)
  - Nama Brand: `OpenTurath`
  - Slogan Editorial: `Asisten AI untuk membaca dan mempelajari kitab.`
- **Tombol Masuk Google:**
  - Teks Tombol: `Lanjutkan dengan Google`
  - Status Memuat: Indikator spinner melingkar (*Progress Indicator*)
- **Persetujuan Ketentuan Legal:**
  - Teks Pengantar: `Dengan masuk, Anda menyetujui`
  - Tautan 1: `Ketentuan Layanan` (mengarah ke `https://openturath.ai/terms`)
  - Penghubung: ` dan `
  - Tautan 2: `Kebijakan Privasi` (mengarah ke `https://openturath.ai/privacy`)
  - Penutup: `.`
- **Pesan Kesalahan & SnackBar:**
  - Kegagalan Buka Tautan: `Tautan belum bisa dibuka. Coba lagi.`
  - Kendala Jaringan: `Koneksi internet bermasalah. Periksa koneksi, lalu coba lagi.`
  - Kegagalan Masuk: `Belum bisa masuk dengan Google. Coba lagi.`

### B. Layar Sinkronisasi Sesi Google (GoogleSessionAuthScreen)
- **Header:** `Menyiapkan percakapan`
- **Subtitle:** `Gunakan akun Google untuk melanjutkan ke percakapan di NotebookLM.`
- **Status Loading:** `Memeriksa akun Google…`
- **Tombol Lanjut:** `Buka percakapan`
- **Tombol Batal:** `Kembali`

---

## 4. Layar Beranda / Dashboard Utama

Sumber berkas: `openturath_ai/lib/screens/dashboard_screen.dart`

### A. Bilah Status Atas & Sapaan Pengguna
- **Judul Aplikasi di Header:** `OpenTurath`
- **Format Sapaan:** `Ahlan, [Nama Pengguna]`  
  *Fallback jika nama kosong:* `Ahlan`
- **Penanggalan Ganda:**
  - Kalender Masehi: Format lokal Indonesia (misal: *Minggu, 13 September 2026*)
  - Kalender Hijriyah: Format Arab-Hijriyah (misal: *29 Rabiul Awal 1448 H*)

### B. Kotak Penelusuran (Search Box)
- **Placeholder Input:** `Cari asisten atau kitab`
- **Header Hasil Penelusuran:** `Hasil pencarian`
- **Pesan Hasil Kosong:** `Asisten atau kitab belum ditemukan. Coba kata kunci lain.`

### C. Seksi Bidang Keilmuan Terpilih (Curated Disciplines)
- **Judul Seksi:** `Pilih bidang ilmu`
- **Aksi Cepat:** `Lihat semua` (menuju ke tab Daftar Asisten AI)
- **Kartu Bidang yang Tampil:**
  1. `Fikih` : 6 asisten
  2. `Hadis` : 1 asisten
  3. `Tafsir` : 1 asisten
  4. `Akidah` : 1 asisten
  5. `Usul Fikih` : 1 asisten
  6. `Bahasa Arab` : 1 asisten

### D. Carousel Edukasi & Pengingat Ilmiah (5 Slide)
1. **Slide 1: Pengenalan**
   - *Badge:* `Tentang OpenTurath`
   - *Judul:* `Mengenal OpenTurath`
   - *Ringkasan:* `Temukan penjelasan dan rujukan untuk membantu membaca kitab.`
   - *Penjelasan Lengkap (Modal):* `Gunakan OpenTurath untuk mencari rujukan dan membandingkan penjelasan dalam kitab. Cocokkan hasilnya dengan sumber asal, lalu pelajari bagian yang belum jelas bersama guru.`
2. **Slide 2: Adab Talaqqi**
   - *Badge:* `Adab belajar`
   - *Judul:* `Tetap belajar bersama guru`
   - *Ringkasan:* `Bimbingan guru membantu Anda memahami konteks dan maksud pembahasan.`
   - *Penjelasan Lengkap (Modal):* `OpenTurath membantu mencari teks dan membandingkan penjelasan dalam kitab. Untuk memahami persoalan agama dan pembahasan fatwa, tetaplah belajar bersama guru atau ulama yang memahami bidangnya.`
3. **Slide 3: Ihtiyath (Kehati-hatian)**
   - *Badge:* `Periksa sumber`
   - *Judul:* `Cocokkan dengan kitab asal`
   - *Ringkasan:* `Periksa kutipan pada kitab asal di Maktabah Syamilah atau edisi cetaknya.`
   - *Penjelasan Lengkap (Modal):* `AI bisa keliru mengutip atau memahami teks. Baca bagian sebelum dan sesudah kutipan pada kitab asal sebelum menyimpulkan atau membagikannya.`
4. **Slide 4: Amanah Ilmiah**
   - *Badge:* `Amanah ilmiah`
   - *Judul:* `Cantumkan rujukan dengan jelas`
   - *Ringkasan:* `Saat mengutip, sertakan nama pengarang, judul kitab, serta jilid dan halaman jika tersedia.`
   - *Penjelasan Lengkap (Modal):* `Cantumkan pengarang, judul kitab, edisi, serta jilid dan halaman sesuai sumber yang digunakan. Jika ada data yang belum tersedia, lengkapi dari kitab asal sebelum memakai kutipan untuk keperluan akademik.`
5. **Slide 5: Sanad & Takhrij**
   - *Badge:* `Telusuri rujukan`
   - *Judul:* `Lihat sumber kutipan`
   - *Ringkasan:* `Gunakan informasi rujukan yang tersedia untuk menelusuri asal kutipan.`
   - *Penjelasan Lengkap (Modal):* `Buka informasi rujukan untuk melihat asal kutipan. Cocokkan judul, edisi, jilid, dan halaman dengan kitab yang Anda gunakan.`

- **Tombol Modal Slide:**
  - Teks Aksi: `Baca selengkapnya`
  - Tombol Tutup Modal: `Tutup`

---

## 5. Layar Eksplorasi Spesialis AI (Specialist List)

Sumber berkas: `openturath_ai/lib/screens/specialist_list_screen.dart`

- **Header Layar:** `Asisten AI`
- **Subtitle Header:** `Pilih asisten sesuai bidang ilmu atau karya ulama yang ingin Anda pelajari.`
- **Kontrol Segmentasi (Corpus Kind Control):**
  - Opsi 1: `Bidang ilmu`
  - Opsi 2: `Tokoh ulama`
- **Filter Chips Disiplin:**
  - `Semua bidang`, `Fikih`, `Fikih Tahawwulat`, `Hadis`, `Tafsir`, `Akidah`, `Usul Fikih`, `Bahasa Arab`
- **Pesan Status Asisten:**
  - Badge ketersediaan: `Tersedia` / tombol `Buka asisten`
  - Badge Segera Hadir: `Dalam persiapan`
  - SnackBar Saat Klik Coming Soon: `${agent.title} sedang disiapkan dan belum bisa dibuka.`
- **Empty State:** `Belum ada asisten dalam kategori ini.`

---

## 6. Layar Ruang Percakapan AI / Webview & Multi-Tab

Sumber berkas: `openturath_ai/lib/screens/agent_webview_screen.dart` & `widgets/agent_multi_tab_room.dart`

### A. Bilah Tab Multi-Room (Multi-Tab Bar)
- **Indikator Tab:** Menampilkan judul asisten yang sedang dibuka (misal: *AI Fikih Syafi'i*, *AI Hadis*)
- **Tombol Tambah Tab:** Tooltip `Buka asisten lain`
- **Tombol Tutup Tab:** Icon silang (*close*) pada tab
- **Dialog Konfirmasi Tutup Tab Terakhir:**
  - Judul: `Tutup percakapan`
  - Pesan: `Percakapan ini akan ditutup. Simpan bagian yang ingin Anda baca kembali ke Catatan sebelum melanjutkan.`
  - Tombol Batal: `Batal`
  - Tombol Setuju: `Tutup percakapan`

### B. Bilah Tindakan Header (Action Bar)
- **Tombol Buku Rujukan (Maktabah):** Tooltip `Kitab rujukan`
- **Tombol Pengaturan Tampilan & Baca:** Tooltip `Tampilan bacaan`
- **Status Sesi:** `Menyiapkan percakapan…`

### C. Menu Pengaturan Tampilan & Baca (Study Options Sheet)
- **Judul Sheet:** `Tampilan bacaan`
- **Pilihan Ukuran Huruf:**
  - `Kecil (85%)`, `Standar (100%)`, `Besar (115%)`, `Sangat besar (130%)`
- **Arah teks Arab:** `Kanan ke kiri`
- **Perataan teks:** `Rata kanan-kiri`
  *Catatan penerapan: pisahkan arah tulisan dari perataan. Penyesuaian kontrol perlu dilakukan pada kode, bukan hanya mengganti label.*
- **Tombol Simpan:** `Terapkan`

### D. Umpan Balik & SnackBar Ruang AI
- Salin Berhasil: `Jawaban disalin dan disimpan di Catatan.`
- Salin Gagal: `Jawaban belum bisa disalin. Coba lagi.`
- Blokir Redirect Eksternal: `Tautan ini tidak bisa dibuka dari percakapan.`

---

## 7. Katalog 2.226 Kitab Rujukan (Katalog & Detail Kitab)

Sumber berkas: `openturath_ai/lib/screens/book_catalog_screen.dart` & `book_detail_screen.dart`

### A. Layar Katalog Lengkap (BookCatalogScreen)
- **Header AppBar:** `Kitab rujukan`
- **Subtitle Dinamis (Contoh Realistis):**
  - Fikih Syafi'i: `87 kitab fikih Syafi'i`
  - Hadis & Syarah: `1.173 kitab hadis dan syarah`
  - Ushul Fiqih: `241 kitab usul fikih`
  - Bahasa & Sastra Arab: `449 kitab bahasa Arab dan balagah`
  - Tafsir & Ulumul Qur'an: `218 kitab tafsir Al-Qur'an`
  - Fikih Tahawwulat: `58 kitab Fikih Tahawwulat`
- **Kolom Pencarian:**
  - Placeholder: `Cari judul kitab, pengarang, atau penahkik`
  - Tombol Bersihkan: Icon close
- **Bilah Filter Dinamis (Filter Chips Bar):**
  - *Mode 1 (Tafsir & Bahasa Arab : Multipel Sub-Bagian):*
    - `Semua kategori`, `Nahwu dan saraf · النحو والصرف`, `Balagah · البلاغة`, `Kosakata sulit dan kamus · الغريب والمعاجم`, `Ilmu bahasa · كتب اللغة`, `Tafsir bi al-Ma'tsur`, `Tafsir bi al-Ra'y`, `Ahkam al-Qur'an`, dll.
  - *Mode 2 (Fikih Syafi'i : Era & Tipe):*
    - Era: `Semua periode`, `Mutaqaddimin`, `Ashab al-Wujuh`, `Muta'akhkhirin`
    - Tipe: `Rujukan dasar mazhab`, `Matan`, `Syarah`, `Hasyiyah`
  - *Mode 3 (Hadis, Ushul & Tahawwulat : Abad Kronologis):*
    - `Semua periode`, `Hingga 300 H`, `301–600 H`, `601–1100 H`, `Setelah 1100 H`
- **Header Jumlah Temuan:**
  - `Menampilkan X dari Y kitab`
- **Tombol Reset Filter:** `Hapus filter`
- **Empty State:**
  - Judul: `Kitab belum ditemukan`
  - Subtitle: `Coba judul dalam huruf Arab atau Latin, nama pengarang, atau penahkik.`
  - Tombol Aksi: `Hapus filter`
- **Error State:**
  - Pesan: `Daftar kitab belum bisa dimuat.`
  - Tombol Aksi: `Coba lagi`

### B. Layar Detail Edisi Kitab (BookDetailScreen)
- **Header AppBar:** `Detail kitab`
- **Tombol Aksi Header:**
  - Bookmark: Tooltip `Simpan rujukan` / `Hapus dari Catatan`
  - Share/Sitasi: Tooltip `Salin rujukan`
- **Kartu 1: Identitas Kitab (Hero Card)**
  - Badge: `[Nama Bagian/Disiplin]` (misal: *كتب السنة* atau *Kitab rujukan · Syafi'i*)
  - Nomor Identitas Naskah: `#[ID Edisi]` (misal: *#1*, *#kitab_al_umm_shafii*)
  - Judul Arab Lengkap: Format RTL tipografi besar
  - Nama Ringkas (*al-Ism al-Mukhtashar*): `Judul singkat: [Nama Pendek]`
  - Transliterasi Latin: Nama Latin miring (italic)
- **Kartu 2: Muallif / Pengarang**
  - Header Seksi: `Pengarang`
  - Nama Pengarang Arab: Teks tebal
  - Nama Pengarang Latin: Teks sekunder
  - Badge Wafat Hijriyah: `Wafat: [Tahun] H` atau `Tahun wafat belum tersedia`
- **Kartu 3: Klasifikasi Ilmiah**
  - Header Seksi: `Jenis dan periode kitab`
  - Baris 1: Label `Jenis kitab` : Nilai: *Rujukan mazhab / Matan / Syarah*
  - Baris 2: Label `Periode` : Nilai: *Mutaqaddimin / Salaf / Abad ke-X H*
  - Baris 3: Label `Jumlah jilid` : Nilai: *[X] jilid / Jumlah jilid belum tersedia*
  - Baris 4 (Opsional): Label `Kedudukan dalam mazhab` : Nilai: *Mu'tamad Mazhab*
- **Kartu 4: Data Edisi & Tahqiq**
  - Header Seksi: `Edisi dan tahkik`
  - Baris 1: Label `Penerbit` : Nilai: *[Nama Penerbit] / Informasi penerbit belum tersedia*
  - Baris 2: Label `Penahkik` : Nilai: *[Nama Muhaqqiq] / Penahkik belum tercatat*
  - Baris 3 (Opsional): Label `Tahun atau edisi cetak` : Nilai: *[Tahun Cetak]*
- **Format Salinan Sitasi Ilmiah:**
  - `[Pengarang]. [Judul Kitab]. Tahkik: [Muhaqqiq]. [Penerbit], [Tahun Cetak]. [Jumlah Jilid] jilid.`
  - Pesan Sukses: `Rujukan disalin.`
  - Pesan Simpan Rujukan: `Rujukan kitab disimpan di Catatan.`
  - Pesan Hapus Rujukan: `Rujukan dihapus dari Catatan.`

---

## 8. Layar Catatan, Simpanan & Editor Catatan (Bookmark & Notes)

Sumber berkas: `openturath_ai/lib/screens/bookmark_screen.dart` & `widgets/note_editor_sheet.dart`

### A. Layar Catatan (BookmarkScreen)
- **Header Layar:** `Catatan`
- **Tombol Aksi:**
  - Tambah Catatan: Tooltip `Buat catatan`
  - Cari Catatan: Tooltip `Cari catatan` / `Tutup pencarian`
- **Kotak Pencarian:** Placeholder `Cari catatan, topik, atau kutipan`
- **Filter Tab Kategori:**
  - `Semua`, `Catatan`, `Ibarah`, `Rujukan kitab`
- **Filter Chips Disiplin:**
  - `Semua`, `Fikih`, `Hadis`, `Tafsir`, `Akidah`, `Usul Fikih`
- **Kartu Catatan:**
  - Badge Asisten: Menampilkan asisten perujuk
  - Tombol Aksi per Kartu: `Ubah`, `Salin ibarah`, `Lihat rujukan`
  - Tooltip Hapus: `Hapus catatan`
  - Tooltip Bagikan: `Bagikan catatan`
- **Empty State:**
  - Judul: `Belum ada catatan`
  - Penjelasan: `Simpan jawaban, kutipan, atau rujukan kitab di sini.`
  - Tombol CTA: `Pilih asisten`
- **Dialog Hapus Catatan:**
  - Judul: `Hapus catatan`
  - Pesan: `Catatan ini akan dihapus dari perangkat ini dan tidak dapat dipulihkan.`
  - Tombol Batal: `Batal`
  - Tombol Hapus: `Hapus catatan`
  - SnackBar: `Catatan dihapus.`

### B. Editor Catatan (NoteEditorSheet)
- **Header Modal:** `Ubah catatan` / `Catatan baru`
- **Input Judul:** Placeholder `Judul catatan`
- **Input Isi/Ibarah:** Placeholder `Tulis catatan atau tempel kutipan di sini`
- **Toolbar Format Teks:**
  - Tooltips: `Tebal`, `Miring`, `Daftar poin`, `Kutipan`, `Kutipan Arab`, `Judul bagian`, `Subjudul`
- **Input Rujukan:**
  - Label: `Rujukan kitab`
  - Input Kitab: Placeholder `Judul kitab`
  - Input Halaman/Jilid: Placeholder `Contoh: jilid 2, halaman 45`
- **Tombol Aksi:**
  - Batal: `Batal`
  - Simpan: `Simpan perubahan` / `Simpan catatan`
- **Pesan SnackBar:**
  - Validasi: `Isi judul atau tulis catatan terlebih dahulu.`
  - Berhasil: `Catatan disimpan.`

---

## 9. Layar Langganan, Paket Riset & Checkout DOKU

Sumber berkas: `openturath_ai/lib/screens/subscription_screen.dart` & `widgets/doku_checkout_sheet.dart`

### A. Layar Langganan (SubscriptionScreen)
- **Header AppBar:** `Langganan`
- **Tombol Tukar Voucher di Header:** `Gunakan voucher`
- **Status Langganan Pengguna:**
  - *Jika Aktif:* `Langganan aktif` : `Berlaku hingga [Tanggal]`
  - *Jika Belum/Kedaluwarsa:* `Belum berlangganan` : `Pilih paket atau gunakan voucher untuk mengakses asisten AI.`
- **Pilihan Paket:**
  1. **Paket 1 Bulan:**
     - Harga: `Rp49.000` / bulan
     - Deskripsi: `Akses asisten yang dipilih selama 30 hari.`
  2. **Paket 6 Bulan:**
     - Harga: `Rp299.000` / 6 bulan
     - Badge: `6 bulan`
     - Deskripsi: `Pilih durasi 6 bulan untuk melanjutkan belajar secara rutin.`
  3. **Paket 1 Tahun (Full Year):**
     - Harga: `Rp499.000` / tahun
     - Badge: `1 tahun`
     - Deskripsi: `Pilih durasi 1 tahun untuk belajar secara berkelanjutan.`
- **Daftar Keunggulan Paket:**
  - `Telusuri rujukan kitab sesuai cakupan paket.`
  - `Cari ibarah dan periksa informasi rujukan yang tersedia.`
  - `Buka beberapa asisten dalam tab terpisah.`
  - `Simpan catatan dan kutipan di perangkat Anda.`
- **Dialog Input WhatsApp Konfirmasi:**
  - Judul: `Nomor WhatsApp`
  - Penjelasan: `Masukkan nomor WhatsApp aktif untuk menerima konfirmasi langganan dan rincian pembayaran.`
  - Placeholder: `Contoh: 081234567890`
  - Tombol Batal: `Batal`
  - Tombol Lanjut: `Lanjut ke pembayaran`
  - Validasi Error: `Masukkan nomor WhatsApp lengkap, misalnya 081234567890.`

### B. Lembar Pembayaran DOKU (DokuCheckoutSheet)
- **Header:** `Pembayaran melalui DOKU`
- **Subtitle:** `Pilih metode pembayaran yang tersedia di DOKU.`
- **Metode Pembayaran yang Didukung:**
  - `QRIS`
  - `Virtual account`
  - `Gerai retail atau minimarket`
- **Tombol Status:**
  - Tooltip: `Periksa status pembayaran`
  - Tooltip Tutup: `Tutup`
- **Dialog konfirmasi menutup pembayaran:**
  - Judul: `Tutup pembayaran`
  - Pesan: `Halaman pembayaran akan ditutup.`
  - Tombol 1: `Lanjutkan pembayaran`
  - Tombol 2: `Tutup`
- **Pesan Status Transaksi:**
  - Berhasil: `Pembayaran berhasil. Langganan Anda sudah aktif.`
  - Menunggu: `Menunggu konfirmasi pembayaran.`
  - Gagal/Batal: `Pembayaran belum selesai. Periksa status pembayaran untuk melihat detailnya.`

---

## 10. Lembar Klaim Voucher Akses (Redeem Code Sheet)

Sumber berkas: `openturath_ai/lib/widgets/redeem_code_sheet.dart`

- **Header Lembar:** `Gunakan voucher`
- **Deskripsi:** `Masukkan kode voucher untuk mengaktifkan akses sesuai ketentuannya.`
- **Form Input:**
  - Placeholder: `Kode voucher`
  - Format Teks: Huruf kapital otomatis (*Auto-capitalized*)
- **Tombol Aksi:**
  - Teks Tombol: `Gunakan voucher`
  - Status Loading: Spinner animasi melingkar
- **Kamus Pesan Validasi & Kesalahan:**
  - Input Kosong: `Masukkan kode voucher terlebih dahulu.`
  - Kode Salah: `Kode voucher tidak ditemukan. Periksa penulisannya, lalu coba lagi.`
  - Sudah Digunakan: `Anda sudah menggunakan voucher ini.`
  - Kuota Habis: `Voucher ini sudah mencapai batas penggunaan.`
  - Kedaluwarsa: `Voucher ini sudah kedaluwarsa.`
  - Sukses Penukaran: `Voucher berhasil digunakan. Akses Anda sudah aktif.`

---

## 11. Layar Profil, Pengaturan Akun & Dokumen Legal (Terms, Privacy, Adab)

Sumber berkas: `openturath_ai/lib/screens/profile_screen.dart`

### A. Informasi Akun Pengguna
- **Header Layar:** `Pengaturan`
- **Badge Tipe Akun:** `Pengguna OpenTurath`
- **Detail Akun:** Menampilkan Nama Lengkap, Alamat Email Google, serta ID Pengguna
- **Status Langganan:**
  - `Langganan aktif hingga [Tanggal]`
  - `Pilih paket atau gunakan voucher untuk mengakses asisten AI.`

### B. Menu Preferensi & Tampilan
- **Seksi:** `Tampilan dan bahasa`
- **Pengaturan Tema:**
  - Judul: `Tampilan`
  - Pilihan: `Ikuti perangkat`, `Terang`, `Gelap`
- **Pengaturan Bahasa:**
  - Judul: `Bahasa`
  - Nilai: `Bahasa Indonesia`

### C. Dokumen Kebijakan & Legalitas (Modal Dialogs)

**Catatan editorial:** butir Ketentuan Layanan dan Kebijakan Privasi di bawah ini merupakan draf dari ringkasan. Bagian ini belum siap ditayangkan. Lengkapi informasi faktual dan isi kurung siku sebelum penerapan.

1. **Tentang OpenTurath (About OpenTurath)**
   - Judul: `Tentang OpenTurath`
   - Versi: `Versi 1.0.9 · Membaca kitab, menelusuri ibarah.`
   - Isi: `OpenTurath membantu Anda membaca dan mempelajari kitab-kitab Islam dengan bantuan AI. Telusuri penjelasan dan rujukan, bandingkan pembahasan, lalu simpan bagian penting ke Catatan.`
   - Tombol: `Tutup`
2. **Ketentuan Layanan (Terms of Service)**
   - Judul: `Ketentuan Layanan OpenTurath`
   - Butir 1: `1. Kegunaan OpenTurath` : OpenTurath digunakan untuk membantu mempelajari dan menelusuri rujukan dalam kitab-kitab Islam.
   - Butir 2: `2. Ketepatan jawaban dan pemeriksaan sumber` : Jawaban AI merupakan bantuan untuk mempelajari sumber dan tidak berfungsi sebagai fatwa. Periksa kutipan pada kitab asal dan pelajari persoalan agama bersama guru atau ulama.
   - Butir 3: `3. Akun dan akses` : Gunakan akun pribadi Anda dan patuhi ketentuan akses OpenTurath.
   - Butir 4: `4. Pembayaran dan langganan` : Pembayaran langganan diproses melalui DOKU. Periksa harga, durasi, dan cakupan akses sebelum membayar.
   - Tombol Persetujuan: `Setuju`
3. **Kebijakan Privasi (Privacy Policy)**
   - Judul: `Kebijakan Privasi`
   - Butir 1: `1. Data yang digunakan` : Alamat email dan informasi profil Google digunakan untuk membantu proses masuk ke akun.
   - Butir 2: `2. Penyimpanan percakapan dan catatan` : Catatan dan rujukan disimpan di [lokasi penyimpanan yang telah diperiksa]. [Jelaskan cara perlindungan data yang benar-benar diterapkan].
   - Butir 3: `3. Penggunaan Google dan NotebookLM` : Percakapan menggunakan NotebookLM. [Jelaskan data yang diteruskan ke Google, cara sesi dikelola, dan kebijakan yang berlaku].
   - Butir 4: `4. Penghapusan akun dan data` : Anda dapat meminta penghapusan akun melalui Pengaturan. [Jelaskan data yang dihapus, data yang disimpan sementara, alasannya, dan jangka waktunya].
   - Tombol Tutup: `Tutup`
4. **Metodologi Riset & Verifikasi Naskah**
   - Judul: `Tentang sumber rujukan`
   - Isi: `Setiap asisten memiliki daftar kitab rujukan sesuai bidangnya. Buka detail kitab untuk melihat informasi pengarang dan edisi yang tersedia. Cocokkan kutipan AI dengan kitab asal sebelum menggunakannya.`
   - Tombol: `Tutup`

### D. Manajemen Sesi & Keamanan Akun
- **Tombol Keluar (Logout):**
  - Label: `Keluar dari akun`
  - Dialog Konfirmasi: `Keluar dari akun` : `Anda akan keluar dari akun ini.`
  - Tombol: `Batal` \| `Keluar`
- **Tombol Hapus Akun (Destructive Action):**
  - Label: `Hapus akun`
  - Dialog Peringatan: `Hapus akun`
  - Pesan Bahaya: `Akun Anda akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.`
  - Tombol: `Batal` \| `Hapus akun`
  - Pesan Berhasil: `Akun Anda sudah dihapus.`
  - Pesan Keamanan Re-Login: `Masuk kembali untuk melanjutkan penghapusan akun.`

---

## 12. Komponen Pendukung: Bukti Ibarah, Banner Update & Pesan Sistem

### A. Lembar Bukti Ibarah (EvidenceBottomSheet)
Sumber berkas: `openturath_ai/lib/widgets/evidence_bottom_sheet.dart`
- **Header Sheet:** `Ibarah dan rujukan`
- **Metadata Kutipan:**
  - Label Penulis: `Pengarang`
  - Label Halaman: `Halaman` / `Jilid`
  - Label Kategori: `Kategori`
- **Teks Arab:** Teks asli matan/ibarah berharakat
- **Tombol Aksi:**
  - `Salin teks` (Pesan: *Teks disalin.*)
  - `Cari di Maktabah Syamilah`
  - Tooltip: `Salin rujukan` (Pesan: *Rujukan disalin.*)

### B. Banner Pembaruan Aplikasi (UpdateReadyBanner)
Sumber berkas: `openturath_ai/lib/widgets/update_ready_banner.dart`
- **Badge:** `Pembaruan tersedia`
- **Judul Banner:** `Versi baru OpenTurath tersedia`
- **Penjelasan:** `Perbarui OpenTurath untuk menggunakan versi terbaru.`
- **Tombol Pasang:** `Perbarui sekarang`
- **Tombol Nanti:** `Nanti`

### C. Status Gangguan & Error Global (AppErrorState)
Sumber berkas: `openturath_ai/lib/widgets/app_error_state.dart`
- **Judul:** `Data belum bisa dimuat`
- **Deskripsi:** `Coba lagi dalam beberapa saat.`
- **Tombol:** `Coba lagi`

---
*Revisi ini disusun melalui audit editorial atas inventaris teks yang dilampirkan. Pemeriksaan kode sumber dan perilaku aplikasi belum dilakukan.*
