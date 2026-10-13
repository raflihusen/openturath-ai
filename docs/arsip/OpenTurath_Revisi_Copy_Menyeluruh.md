# OpenTurath: revisi menyeluruh bahasa aplikasi

Usulan redaksi berdasarkan `AUDIT_MASTER_SEMUA_COPY_DAN_TEKS_APLIKASI.md` yang dikirim pada sesi ini. Cakupan mencakup seluruh 12 bagian inventaris. Ini merupakan peninjauan dokumen teks, bukan pemeriksaan ulang kode atau bukti bahwa semua fitur telah bekerja sesuai deskripsi.

Bahasa yang dituju adalah bahasa Indonesia yang tenang, langsung, dan akrab bagi pembaca kitab. Istilah keilmuan tetap digunakan ketika diperlukan. Label, tombol, dan pesan sistem menjelaskan hal yang bisa dilakukan atau yang sedang terjadi.

Nama menu versi terbaru dipertahankan: **Beranda, Asisten AI, Catatan, Pengaturan**. Asisten adalah alat yang digunakan. Percakapan adalah sesi dengan asisten. Catatan adalah tempat menyimpan tulisan, jawaban, kutipan, dan rujukan. Kata “kajian” dipakai untuk kegiatan belajar, bukan sebagai pengganti semua objek tersebut.

Teks dalam tanda kode pada bagian layar merupakan usulan tampilan. Baris **Catatan editor** dan seluruh lampiran ditujukan kepada tim produk, bukan untuk ditampilkan di aplikasi. Konstanta, ID internal, judul Arab, nama kitab, nama pengarang, serta harga dipertahankan. Ejaan nama bidang di antarmuka diseragamkan menjadi Hadis, Akidah, Usul Fikih, dan Akhlak.

## Isi dokumen

1. Teks bersama dan navigasi (AppCopy)
2. Bidang ilmu dan asisten AI
3. Masuk dan menghubungkan akun
4. Beranda
5. Daftar asisten AI
6. Percakapan dan tab
7. Kitab rujukan dan detail kitab
8. Catatan dan editor
9. Langganan dan pembayaran
10. Voucher
11. Pengaturan dan dokumen kebijakan
12. Kutipan, pembaruan, dan pesan sistem

Lampiran A memuat pilihan istilah. Lampiran B memuat bagian yang memerlukan kepastian fungsi atau data. Lampiran C memuat pesan tambahan untuk status yang belum dibedakan dalam inventaris.

## 1. Teks bersama dan navigasi (AppCopy)

Sumber berkas: `openturath_ai/lib/core/app_copy.dart`  
Fungsi: Menyimpan teks yang digunakan berulang agar istilah, navigasi, dan pesan sistem tetap konsisten.

| Kategori | Konstanta | Teks usulan | Konteks & Catatan Penggunaan |
|:---|:---|:---|:---|
| **Identitas & Merek** | `appName` | `OpenTurath` | Nama resmi aplikasi |
| | `appTagline` | `Membaca kitab, menelusuri ibarah.` | Tagline utama pada profil & splash |
| | `defaultFieldDesc` | `Pelajari berbagai bidang ilmu dari kitab rujukan.` | Deskripsi bidang umum |
| | `aboutTitle` | `Tentang OpenTurath` | Judul modal informasi aplikasi |
| | `aboutDescription` | `OpenTurath membantu Anda mencari rujukan, membaca kutipan, dan membandingkan penjelasan dalam kitab.` | Deskripsi ringkas visi aplikasi |
| | `aboutScholarlyPrinciple` | `Gunakan jawaban AI untuk membantu menelusuri rujukan. Periksa kutipan pada kitab asal. Untuk memahami agama dan menetapkan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.` | Prinsip adab riset ilmiah |
| **Navigasi Utama** | `navHome` | `Beranda` | Tab navigasi 1 di Bottom Bar |
| | `navStudies` | `Asisten AI` | Tab navigasi 2 di Bottom Bar |
| | `navSaved` | `Catatan` | Tab navigasi 3 di Bottom Bar |
| | `navSettings` | `Pengaturan` | Tab navigasi 4 di Bottom Bar |
| **Istilah Ruang & Kajian** | `studySpace` | `Percakapan` | Istilah resmi ruang interaksi |
| | `openStudy` | `Membuka percakapan…` | Status memuat sesi percakapan |
| | `studyOptions` | `Tampilan bacaan` | Menu modal reader / font size |
| | `referenceBooks` | `Kitab rujukan` | Label daftar kitab rujukan |
| | `savedCollection` | `Catatan` | Label koleksi riset |
| | `bookDetails` | `Tentang kitab` | Header AppBar detail naskah |
| **Loading & Akses** | `loadingReferences` | `Menyiapkan percakapan…` | Subtitle loading saat inisialisasi AI |
| | `modulePreparing` | `sedang disiapkan.` | Status modul coming soon |
| | `moduleUnavailable` | `Asisten ini belum tersedia.` | Pesan modul belum aktif |
| | `cannotLoad` | `Data belum bisa dimuat. Coba lagi.` | Pesan kegagalan umum |
| | `cannotLoadStudy` | `Percakapan belum bisa dibuka` | Pesan kegagalan buka AI |
| | `studyNotLoadedYet` | `Percakapan belum bisa dimuat. Coba lagi.` | Pesan penundaan sesi |
| | `subscriptionRequiredTitle`| `Berlangganan untuk melanjutkan` | Dialog pengingat langganan |
| | `catalogLoadFailed` | `Daftar kitab belum bisa dimuat.` | Pesan error muat katalog |
| | `inputQuestionHint` | `Tulis pertanyaan tentang kitab ini` | Placeholder input teks |
| | `viewSubscription` | `Lihat langganan` | Tombol CTA langganan |
| | `tryAgain` | `Coba lagi` | Tombol retry |
| **Platform & Perangkat** | `deviceNotSupportedTitle` | `Belum tersedia di perangkat ini` | Error platform guard |
| | `deviceNotSupportedMessage`| `OpenTurath belum tersedia di perangkat ini. Gunakan Android, macOS, atau Windows.` | Penjelasan kompatibilitas platform |
| | `cannotConnectTitle` | `Belum bisa terhubung` | Header dialog offline |
| | `cannotConnectMessage` | `OpenTurath belum bisa terhubung. Periksa koneksi internet, lalu coba lagi.` | Pesan offline |
| **Dialog Adab Talaqqi** | `adabDialogTitle` | `Catatan sebelum mulai` | Judul dialog pengingat adab |
| | `adabAcknowledgeButton` | `Saya mengerti` | Tombol persetujuan dialog adab |
| | `adabHeading1` | `Bantuan untuk menelusuri kitab` | Poin adab 1 |
| | `adabBody1` | `Gunakan OpenTurath untuk mencari kutipan dan membandingkan penjelasan dalam kitab. Cocokkan hasilnya dengan sumber di Maktabah Syamilah atau kitab cetak.` | Uraian poin adab 1 |
| | `adabHeading2` | `Belajar tetap perlu bimbingan` | Poin adab 2 |
| | `adabBody2` | `Untuk memahami agama dengan baik, belajarlah kepada guru dan ulama yang berkompeten.` | Uraian poin adab 2 |
| | `adabHeading3` | `Periksa kembali rujukan` | Poin adab 3 |
| | `adabBody3` | `Periksa dalil dan kutipan pada kitab rujukan sebelum menjadikannya pegangan.` | Uraian poin adab 3 |
| **Umpan Balik (Feedback)** | `noAnswerToCopy` | `Belum ada jawaban untuk disalin.` | SnackBar validasi salin |
| | `answerCopied` | `Jawaban disalin dan disimpan ke Catatan.` | Tampil setelah salin dan simpan sama-sama berhasil |
| | `copyFailed` | `Jawaban belum bisa disalin. Coba lagi.` | SnackBar salin gagal |
| | `noAnswerToSave` | `Belum ada jawaban untuk disimpan.` | SnackBar simpan kosong |
| | `savedSuccess` | `Tersimpan ke Catatan.` | SnackBar simpan sukses |
| | `saveFailed` | `Jawaban belum tersimpan. Coba lagi.` | SnackBar simpan gagal |
| **Catatan** | `searchSavedHint` | `Cari catatan atau kutipan` | Placeholder search box catatan |
| | `searchSavedTooltip` | `Cari catatan` | Tooltip icon search |
| | `noSavedTitle` | `Belum ada catatan` | Judul empty state catatan |
| | `noSavedDescription` | `Simpan jawaban atau kutipan agar mudah dibuka kembali.` | Deskripsi empty state catatan |
| | `copyIbarahAction` | `Salin kutipan` | Tombol aksi salin kutipan |
| | `viewReferenceAction` | `Lihat rujukan` | Tombol buka rujukan kitab |
| | `shareReferenceTooltip` | `Bagikan catatan` | Tooltip aksi share |
| | `saveAnswerMenu` | `Simpan ke Catatan` | Menu context save |
| **Akun & Pengaturan** | `profile` | `Profil` | Header menu profil |
| | `subscription` | `Langganan` | Label item langganan |
| | `activeSubscription` | `Langganan aktif` | Status akun aktif |
| | `inactiveSubscription` | `Pilih paket atau gunakan voucher untuk mulai berlangganan.` | Status akun belum bayar |
| | `appearance` | `Tampilan` | Label preferensi tema |
| | `modeDark` | `Gelap` | Pilihan tema dark |
| | `modeLight` | `Terang` | Pilihan tema light |
| | `modeSystem` | `Ikuti perangkat` | Pilihan tema auto/system |
| | `language` | `Bahasa` | Label pengaturan bahasa |
| | `languageIndonesian` | `Bahasa Indonesia` | Bahasa aktif saat ini |
| | `logoutDialogTitle` | `Keluar dari akun` | Judul konfirmasi keluar |
| | `logoutDialogBody` | `Anda perlu masuk kembali untuk menggunakan akun ini.` | Pesan konfirmasi keluar |
| | `logoutButton` | `Keluar` | Tombol konfirmasi logout |
| | `deleteAccountTitle` | `Hapus akun` | Judul konfirmasi hapus akun |
| | `deleteAccountBody` | `Profil, catatan tersimpan, dan data akun Anda di server akan dihapus. Tindakan ini tidak dapat dibatalkan.` | Draf mengikuti cakupan server dalam sumber. Pastikan dampak terhadap catatan lokal |
| | `deleteAccountButton` | `Hapus akun` | Tombol aksi destruktif |
| | `deleteAccountSuccess` | `Akun dihapus.` | SnackBar notifikasi akun terhapus |
| | `recentLoginRequired` | `Masuk kembali untuk melanjutkan penghapusan akun.` | Pesan keamanan re-auth |
| | `networkError` | `Periksa koneksi internet, lalu coba lagi.` | Pesan kendala jaringan |

---

## 2. Bidang ilmu dan asisten AI

Sumber berkas: `openturath_ai/lib/models/agent_model.dart` dan `openturath_ai/lib/models/field_model.dart`

### A. Bidang ilmu (FieldModel)

1. **Fikih Tahawwulat** (`fiqh_tahawwulat`)  
   *Deskripsi:* "Pelajari Fikih Tahawwulat, termasuk Rukun Keempat, tanda-tanda zaman, dan sanad keilmuan Al-Habib Abu Bakar Al-Masyhur."
2. **Fikih** (`fiqh`)  
   *Deskripsi:* "Pelajari hukum ibadah dan muamalah, telusuri fatwa, serta bandingkan pandangan mazhab mu'tabar."
3. **Hadis** (`hadith`)  
   *Deskripsi:* "Telusuri riwayat hadis, keterangan tentang perawi, dan penjelasan ulama dalam syarah Kutubus Sittah."
4. **Tafsir** (`tafsir`)  
   *Deskripsi:* "Pelajari sebab turunnya ayat, hubungan antar ayat, serta tafsir bil ma'tsur dan bil ra'yi."
5. **Akidah** (`aqidah`)  
   *Deskripsi:* "Pelajari akidah Asy'ariyyah dan Maturidiyyah, pembahasan usuluddin, serta dalil aqli dan naqli."
6. **Usul Fikih** (`usul`)  
   *Deskripsi:* "Pelajari cara ulama menggali hukum, dalil ijmali, maqashid syariah, dan kaidah fikih."
7. **Bahasa Arab** (`lughah`)  
   *Deskripsi:* "Pelajari nahwu, sharaf, dan balaghah, serta cari makna kata dalam kamus Arab klasik."
8. **Sejarah dan Sirah** (`tarikh`)  
   *Deskripsi:* "Pelajari perjalanan hidup Nabi, sejarah Khulafaur Rasyidin, biografi ulama, dan peradaban Islam."
9. **Tasawuf dan Akhlak** (`tasawwuf`)  
   *Deskripsi:* "Pelajari penyucian jiwa, adab suluk, dan nasihat ulama salaf saleh."

---

### B. Profil asisten AI (AgentModel)

#### 1. AI Fikih Tahawwulat (`fiqh_tahawwulat`). Status: Aktif

- **Judul:** AI Fikih Tahawwulat
- **Judul Arab:** فقه التحولات
- **Keterangan singkat:** Manhaj Abu Bakr al-Masyhur
- **Deskripsi:** "Telusuri Fikih Tahawwulat melalui kitab dan ceramah Habib Abu Bakar al-Masyhur."
- **Contoh permintaan:**
  1. *Jelaskan al-ghutsā'iyyah dan sertakan rujukan kitabnya.*
  2. *Jelaskan Rukun Keempat dalam Fikih Tahawwulat.*
  3. *Jelaskan nasihat ulama tentang sikap saat menghadapi fitnah.*
- **Asisten pendamping:**
  - **Al-Muhaqqiq (المحقق):** "Membantu mencari dalil dan kutipan beserta rujukannya." (البحث والتحقيق وعزو النصوص إلى مصادرها)
  - **Al-Bayan (البيان):** "Membantu menjelaskan inti pembahasan dengan bahasa sederhana." (الشرح والبيان والتبسيط المنهجي)
- **Kitab Rujukan Utama:**
  - *Nubdzah Al-Bayan fi Ma'rifati Sunan Al-Khalaq* (نبذة البيان في معرفة سنن الخلق والبيان)
  - *Al-Fiqh Al-Manhaji fi Fiqh Al-Tahawwulat* (الفقه المنهجي في فقه التحولات)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 2. AI Fikih Syafi'i (`fiqh_syafii`). Status: Aktif

- **Judul:** AI Fikih Syafi'i
- **Judul Arab:** الفقه الشافعي
- **Keterangan singkat:** Matan · Syarah · Hasyiyah Mu'tabarah
- **Deskripsi:** "Cari penjelasan dan rujukan dalam kitab mazhab Syafi'i."
- **Contoh permintaan:**
  1. *Jelaskan rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i.*
  2. *Jelaskan syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn.*
  3. *Jelaskan ketentuan zakat perdagangan menurut Imam al-Nawawi.*
- **Asisten pendamping:**
  - **Al-Muhaqqiq Fikih Syafi'i (المحقق):** "Membantu mencari dalil dan kutipan dari kitab mazhab Syafi'i." (تحقيق المعتمد في المذهب الشافعي)
- **Kitab Rujukan Utama:**
  - *Al-Umm* (الأم). Imam Asy-Syafi'i
  - *Al-Majmu' Syarah Al-Muhadzdzab* (المجموع شرح المهذب). Imam An-Nawawi
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 3. AI Hadis dan Syarah (`hadits`). Status: Aktif

- **Judul:** AI Hadis dan Syarah
- **Judul Arab:** الحديث الشريف وشروحه
- **Keterangan singkat:** Kutub Sittah · Takhrij · Syarah
- **Deskripsi:** "Telusuri sanad dan teks hadis, serta penjelasan ulama tentang makna dan derajatnya."
- **Contoh permintaan:**
  1. *Telusuri takhrij hadis innamal a'malu bin niyyat dalam Kutubus Sittah.*
  2. *Jelaskan pembahasan Ibnu Hajar tentang hadis niat dalam Fathul Bari.*
  3. *Telusuri hadis mutawatir tentang larangan berdusta atas nama Rasulullah dan sertakan rujukannya.*
- **Asisten pendamping:**
  - **Al-Muhaqqiq Hadis (المحقق):** "Membantu mencari riwayat, takhrij, dan penjelasan hadis." (تخريج الأحاديث وبيان عللها وشروحها)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 4. AI Tafsir Al-Qur'an (`tafsir`). Status: Aktif

- **Judul:** AI Tafsir Al-Qur'an
- **Judul Arab:** التفسير وعلوم القرآن
- **Keterangan singkat:** Tafsir bil Ma'tsur dan bil Ra'yi
- **Deskripsi:** "Pelajari tafsir ayat Al-Qur'an, asbabun nuzul, qira'at, dan kaidah tafsir."
- **Contoh permintaan:**
  1. *Telusuri riwayat asbabun nuzul surah Al-Baqarah ayat 183 tentang kewajiban puasa, jika tersedia.*
  2. *Bandingkan penjelasan Thabari dan Ibnu Katsir tentang Ayat Kursi.*
  3. *Jelaskan penafsiran ulama tentang kata hikmah dalam Al-Qur'an.*
- **Asisten pendamping:**
  - **Al-Mufassir (المفسر):** "Membantu mencari penjelasan ayat dalam kitab tafsir mu'tabar." (استنباط المعاني والبيان القرآني)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 5. AI Usul Fikih (`ushul_fiqh`). Status: Aktif

- **Judul:** AI Usul Fikih
- **Judul Arab:** أصول الفقه والقواعد
- **Keterangan singkat:** Risalah · Jam'ul Jawami' · Mustashfa
- **Deskripsi:** "Pelajari cara ulama menggali hukum, dalil ijmali, serta kaidah usul fikih dan kaidah fikih."
- **Contoh permintaan:**
  1. *Jelaskan perbedaan muthlaq dan 'amm serta pengaruhnya dalam penggalian hukum.*
  2. *Jelaskan kaidah al-ashlu fil amri lil wujub menurut ulama usul fikih.*
  3. *Jelaskan rukun qiyas dan contoh penerapannya pada persoalan masa kini.*
- **Asisten pendamping:**
  - **Al-Ushuli (الأصولي):** "Membantu menelusuri pembahasan dalil, kaidah usul fikih, dan kaidah fikih." (تحرير المسائل الأصولية والقواعد الفقهية)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 6. AI Bahasa Arab dan Balaghah (`nahwu_sharaf`). Status: Aktif

- **Judul:** AI Bahasa Arab dan Balaghah
- **Judul Arab:** علوم اللغة العربية
- **Keterangan singkat:** Nahwu · Sharaf · Balaghah · Kamus
- **Deskripsi:** "Pelajari susunan kalimat, perubahan bentuk kata, balaghah, dan makna kata dalam kitab berbahasa Arab."
- **Contoh permintaan:**
  1. *Jelaskan i'rab bismillahirrahmanirrahim kata demi kata.*
  2. *Jelaskan wazan fa'ala, taf'il, dan istif'al beserta maknanya dalam ilmu sharaf.*
  3. *Jelaskan taqdim dan ta'khir dalam surah Al-Fatihah dari sisi balaghah.*
- **Asisten pendamping:**
  - **Al-Lughawi (اللغوي):** "Membantu menjelaskan i'rab, wazan, dan gaya bahasa Arab." (إعراب التراكيب وتحليل الأساليب البيانية)
- **Paket Harga:** 1 Bulan: Rp49.000 \| 6 Bulan: Rp299.000 \| 1 Tahun: Rp499.000

#### 7. Asisten yang sedang disiapkan

- **AI Fikih Hanafi (`fiqh_hanafi`):** "Pelajari fikih Hanafi melalui Al-Mabsuth, Radd Al-Muhtar, dan Hidayah Al-Marghinani."
- **AI Fikih Maliki (`fiqh_maliki`):** "Pelajari fikih Maliki melalui Al-Mudawwanah, Mukhtashar Khalil, dan Al-Qawanin Al-Fiqhiyyah."
- **AI Fikih Hanbali (`fiqh_hanbali`):** "Pelajari fikih Hanbali melalui Al-Mughni, Al-Inshaf, dan Zad Al-Mustaqni'."
- **AI Perbandingan Mazhab (`fiqh_muqaran`):** "Bandingkan dalil dan pandangan mazhab Hanafi, Maliki, Syafi'i, dan Hanbali."
- **AI Akidah dan Ilmu Kalam (`aqidah`):** "Pelajari akidah Asy'ariyyah dan Maturidiyyah, dalil aqli dan naqli, serta penjelasan ulama dalam menjawab keraguan tentang akidah."
- **AI Sejarah dan Sirah (`tarikh`):** "Telusuri perjalanan hidup Nabi, Khulafaur Rasyidin, sejarah pemerintahan Islam, dan biografi ulama."
- **AI Habib Umar bin Hafizh (`habib_umar`):** "Telusuri fatwa, khutbah, tulisan, dan nasihat dakwah Al-Habib Umar bin Hafizh."
- **AI Hujjatul Islam Al-Ghazali (`imam_ghazali`):** "Pelajari tasawuf, akhlak, dan usul fikih dalam karya Al-Ghazali, termasuk Ihya Ulumiddin."

---

## 3. Masuk dan menghubungkan akun

Sumber berkas: `openturath_ai/lib/screens/login_screen.dart` dan `google_session_auth_screen.dart`

### A. Tampilan Layar Masuk (LoginScreen)

- **Simbol & Identitas:**
  - Logo: Arch Artwork (*Gerbang Turats*)
  - Nama Brand: `OpenTurath`
  - Slogan Editorial: `Asisten AI untuk menelusuri kitab`
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
  - Kendala Jaringan: `Periksa koneksi internet, lalu coba lagi.`
  - Kegagalan Masuk: `Belum berhasil masuk dengan Google. Coba lagi.`

### B. Menghubungkan akun Google (GoogleSessionAuthScreen)

Catatan editor: nama NotebookLM dipertahankan karena membantu menjelaskan tujuan penghubungan akun. Sesuaikan pesan memuat dengan tahapan yang benar-benar terjadi.

- **Header:** `Menyiapkan percakapan`
- **Subtitle:** `Hubungkan akun Google untuk membuka percakapan melalui NotebookLM.`
- **Status Loading:** `Memeriksa akses akun Google…`
- **Tombol Lanjut:** `Buka percakapan`
- **Tombol Batal:** `Kembali`

---

## 4. Beranda

Sumber berkas: `openturath_ai/lib/screens/dashboard_screen.dart`

### A. Bilah Status Atas & Sapaan Pengguna

- **Judul Aplikasi di Header:** `OpenTurath`
- **Format Sapaan:** `Ahlan, [Nama Pengguna]`  
  *Fallback jika nama kosong:* `Ahlan`
- **Penanggalan Ganda:**
  - Kalender Masehi: Format lokal Indonesia (misal: *Minggu, 13 September 2026*)
  - Kalender Hijriah: *[Tanggal Hijriah] H*, sesuai kalender yang digunakan aplikasi.
  - Catatan editor: contoh Hijriah dalam inventaris adalah 29 Rabiul Awal 1448 H. Kecocokannya dengan contoh tanggal Masehi belum diverifikasi.

### B. Kotak Penelusuran (Search Box)

- **Placeholder Input:** `Cari asisten, kitab, atau bab`
- **Header Hasil pencarian:** `Hasil pencarian`
- **Pesan Hasil Kosong:** `Belum ada hasil yang cocok. Coba kata kunci lain.`

### C. Pilihan bidang ilmu

- **Judul Seksi:** `Pilih bidang ilmu`
- **Aksi Cepat:** `Lihat semua` (menuju ke tab Daftar Asisten AI)
- **Kartu Bidang yang Tampil:**
  1. `Fikih`. 6 asisten
  2. `Hadis`. 1 asisten
  3. `Tafsir`. 1 asisten
  4. `Akidah`. 1 asisten
  5. `Usul Fikih`. 1 asisten
  6. `Bahasa Arab`. 1 asisten

### D. Kartu pengenalan dan pengingat

1. **Kartu 1: Pengenalan**
   - *Badge:* `Tentang OpenTurath`
   - *Judul:* `Mulai menelusuri kitab`
   - *Ringkasan:* `Cari kutipan dan temukan rujukan untuk pembahasan Anda.`
   - *Penjelasan Lengkap (Modal):* `Cari rujukan dan bandingkan matan dengan penjelasannya dalam syarah. Periksa hasilnya pada kitab asal, lalu diskusikan dengan guru atau ulama yang berkompeten.`
2. **Kartu 2: Adab belajar**
   - *Badge:* `Adab belajar`
   - *Judul:* `Tetap belajar bersama guru`
   - *Ringkasan:* `Belajarlah dengan bimbingan guru dan ulama yang bersanad.`
   - *Penjelasan Lengkap (Modal):* `AI membantu mencari kutipan dan membandingkan penjelasan dalam kitab. Untuk memahami fikih dan fatwa, tetaplah belajar kepada guru dan ulama yang bersanad.`
3. **Kartu 3: Memeriksa sumber**
   - *Badge:* `Periksa sumber`
   - *Judul:* `Cocokkan dengan kitab asal`
   - *Ringkasan:* `Periksa kutipan di Maktabah Syamilah atau kitab cetak.`
   - *Penjelasan Lengkap (Modal):* `Baca kutipan beserta konteksnya pada kitab cetak yang dirujuk sebelum menarik kesimpulan atau membagikan hasil kajian.`
4. **Kartu 4: Amanah ilmiah**
   - *Badge:* `Amanah ilmiah`
   - *Judul:* `Cantumkan rujukan saat mengutip`
   - *Ringkasan:* `Sertakan pengarang, judul kitab, bab, jilid, dan halaman.`
   - *Penjelasan Lengkap (Modal):* `Saat mengutip, tuliskan pengarang, judul kitab, bab, jilid, dan halaman sesuai sumber yang digunakan. Lengkapi dengan informasi edisi agar rujukan mudah ditemukan.`
5. **Kartu 5: Menelusuri rujukan**
   - *Badge:* `Telusuri rujukan`
   - *Judul:* `Lihat asal kutipan`
   - *Ringkasan:* `Gunakan informasi kitab, jilid, dan halaman untuk memeriksa kutipan.`
   - *Penjelasan Lengkap (Modal):* `Buka rujukan yang tersedia untuk menelusuri asal kutipan. Cocokkan teks, jilid, dan halaman dengan edisi kitab yang digunakan.`

- **Tombol Modal Slide:**
  - Teks Aksi: `Baca selengkapnya`
  - Tombol Tutup Modal: `Tutup`

---

## 5. Daftar asisten AI

Sumber berkas: `openturath_ai/lib/screens/specialist_list_screen.dart`

- **Header Layar:** `Asisten AI`
- **Subtitle Header:** `Pilih bidang ilmu atau karya ulama yang ingin Anda telusuri.`
- **Pilihan pengelompokan:**
  - Opsi 1: `Bidang ilmu`
  - Opsi 2: `Ulama`
- **Filter Chips Disiplin:**
  - `Semua bidang`, `Fikih`, `Fikih Tahawwulat`, `Hadis`, `Tafsir`, `Akidah`, `Usul Fikih`, `Bahasa Arab`
- **Pesan Status Asisten:**
  - Status tersedia: `Tersedia`
  - Tombol untuk membuka asisten: `Buka percakapan`
  - Badge Segera hadir: `Segera hadir`
  - SnackBar Saat Klik Coming Soon: `${agent.title} sedang disiapkan.`
- **Empty State:** `Belum ada asisten di kategori ini.`

---

## 6. Percakapan dan tab

Sumber berkas: `openturath_ai/lib/screens/agent_webview_screen.dart` dan `widgets/agent_multi_tab_room.dart`

### A. Tab percakapan

- **Indikator Tab:** Menampilkan judul asisten yang sedang dibuka (misal: *AI Fikih Syafi'i*, *AI Hadis dan Syarah*)
- **Tombol Tambah Tab:** Tooltip `Buka asisten lain`
- **Tombol Tutup Tab:** Ikon silang dengan label aksesibilitas `Tutup percakapan [Nama asisten]`.
- **Dialog Konfirmasi Tutup Tab Terakhir:**
  - Judul: `Tutup percakapan`
  - Pesan: `Percakapan ini akan ditutup. Simpan jawaban yang ingin Anda baca kembali ke Catatan.`
  - Tombol Batal: `Batal`
  - Tombol Setuju: `Tutup percakapan`

### B. Tindakan percakapan

- **Tombol Buku Rujukan (Maktabah):** Tooltip `Kitab rujukan`
- **Tombol Tampilan bacaan:** Tooltip `Tampilan bacaan`
- **Status Sesi:** `Menyiapkan percakapan…`

### C. Tampilan bacaan

Catatan editor: label ukuran tetap menggunakan skala 85%, 100%, 115%, dan 130% pada implementasi. Persentase tidak perlu tampil. Rata kanan dan rata kanan-kiri mengatur perataan. Arah tulisan Arab tetap kanan ke kiri. Jika kontrol lama benar-benar mengubah arah tulisan, gunakan label terpisah “Arah tulisan” dengan nilai “Kanan ke kiri”, bukan menggantinya dengan “Rata kanan”.

- **Judul Sheet:** `Tampilan bacaan`
- **Pilihan Ukuran Huruf:**
  - `Kecil`, `Standar`, `Besar`, `Sangat besar`
- **Pilihan Perataan Teks Arab:**
  - `Rata kanan`, `Rata kanan-kiri`
- **Tombol Simpan:** `Terapkan`

### D. Pesan salin dan simpan

Catatan editor: tampilkan hasil salin dan simpan sesuai operasi yang berhasil. Gunakan rincian status di Lampiran C untuk kegagalan sebagian.

- Salin Berhasil: `Jawaban disalin dan disimpan ke Catatan.`
- Salin Gagal: `Jawaban belum bisa disalin. Coba lagi.`
- Blokir Redirect Eksternal: `Tautan ini tidak bisa dibuka dari percakapan.`

---

## 7. Kitab rujukan dan detail kitab

Sumber berkas: `openturath_ai/lib/screens/book_catalog_screen.dart` dan `book_detail_screen.dart`

### A. Kitab rujukan (BookCatalogScreen)

Catatan editor: angka dalam daftar merupakan contoh dari inventaris. Total enam kelompok adalah 2.226. Ambil jumlah dan hasil pencarian dari data yang benar-benar ditampilkan.

- **Header AppBar:** `Kitab rujukan`
- **Subtitle Dinamis (Contoh Realistis):**
  - Fikih Syafi'i: `87 kitab fikih Syafi'i`
  - Hadis dan syarah: `1.173 kitab hadis dan syarah`
  - Usul fikih: `241 kitab usul fikih`
  - Bahasa dan sastra Arab: `449 kitab bahasa Arab dan balaghah`
  - Tafsir dan ilmu Al-Qur'an: `218 kitab tafsir dan ilmu Al-Qur'an`
  - Fikih Tahawwulat: `58 kitab Fikih Tahawwulat`
- **Kolom Pencarian:**
  - Label bantuan: `Bisa mencari dengan huruf Arab atau Latin.`
  - Placeholder: `Cari kitab, pengarang, atau penyunting`
  - Tombol Bersihkan: Ikon silang dengan label `Hapus pencarian`.
- **Bilah Filter Dinamis (Filter Chips Bar):**
  - *Tafsir dan bahasa Arab, berdasarkan kategori:*
    - `Semua kategori`, `Nahwu dan sharaf`, `Balaghah`, `Gharib dan kamus`, `Bahasa Arab`, `Tafsir bi al-Ma'tsur`, `Tafsir bi al-Ra'y`, `Ahkam al-Qur'an`, dll.
  - *Fikih Syafi'i, berdasarkan pengelompokan ulama dan jenis kitab:*
    - Kelompok: `Semua kelompok`, `Mutaqaddimin`, `Ashab Al-Wujuh`, `Muta'akhkhirin`
    - Jenis: `Asal mazhab`, `Matan`, `Syarah`, `Hasyiyah`
  - *Hadis, usul fikih, dan Fikih Tahawwulat, berdasarkan rentang tahun:*
    - `Semua periode`, `Hingga 300 H`, `301–600 H`, `601–1100 H`, `Setelah 1100 H`
- **Header Jumlah Temuan:**
  - `X dari Y kitab`
- **Tombol Reset Filter:** `Hapus filter`
- **Empty State:**
  - Judul: `Belum ada kitab yang cocok`
  - Subtitle: `Coba judul dalam huruf Arab atau Latin, nama pengarang, atau nama penyunting.`
  - Tombol Aksi: `Hapus filter`
- **Error State:**
  - Pesan: `Daftar kitab belum bisa dimuat.`
  - Tombol Aksi: `Coba lagi`

### B. Tentang kitab (BookDetailScreen)

Catatan editor: label “Penyunting (tahkik)” merujuk pada muhaqqiq yang meneliti dan menyiapkan teks kitab. Tambahkan bantuan “Penyunting ilmiah yang meneliti dan menyiapkan teks kitab” bila diperlukan. Pertahankan nama orang, judul, teks Arab, serta data edisi sesuai sumber. Jangan menampilkan “1 jilid” ketika jumlah jilid belum diketahui.

- **Header AppBar:** `Tentang kitab`
- **Tombol Aksi Header:**
  - Bookmark: Tooltip `Simpan kitab` / `Hapus dari Catatan`
  - Share/Sitasi: Tooltip `Salin rujukan`
- **Kartu 1: Identitas Kitab (Hero Card)**
  - Badge: `[Nama Bagian/Disiplin]` (misal: *كتب السنة* atau *Fikih Syafi'i*)
  - ID edisi tetap disimpan untuk kebutuhan sistem. Jika diperlukan dalam detail lanjutan, gunakan label `ID edisi: [ID Edisi]`.
  - Judul Arab Lengkap: Format RTL tipografi besar
  - Nama Ringkas (*al-Ism al-Mukhtashar*): `Judul singkat: [Nama Pendek]`
  - Transliterasi Latin: Nama Latin miring (italic)
- **Kartu 2: Pengarang**
  - Header Seksi: `Pengarang`
  - Nama Pengarang Arab: Teks tebal
  - Nama Pengarang Latin: Teks sekunder
  - Badge Wafat Hijriyah: `Wafat [Tahun] H` atau `Tahun wafat belum tercatat`
- **Kartu 3: Tentang isi kitab**
  - Header Seksi: `Isi dan jenis kitab`
  - Baris 1: Label `Jenis kitab`. Nilai: *Rujukan mazhab / Matan / Syarah*
  - Baris 2: Label `Periode` untuk data tahun atau abad. Jika nilainya berupa kategori ulama, gunakan `Kelompok ulama` dengan nilai dari sumber, seperti *Mutaqaddimin* atau *Salaf*.
  - Baris 3: Label `Jumlah jilid`. Nilai: *[X] jilid*
  - Baris 4 (Opsional): Label `Kedudukan dalam mazhab`. Nilai: *Mu'tamad dalam mazhab*
- **Kartu 4: Edisi dan penerbit**
  - Header Seksi: `Edisi dan penerbit`
  - Baris 1: Label `Penerbit`. Nilai: *[Nama Penerbit] / Informasi penerbit belum tersedia*
  - Baris 2: Label `Penyunting (tahkik)`. Nilai: *[Nama Muhaqqiq] / Belum tercatat*
  - Baris 3 (Opsional): Label `Tahun terbit`. Nilai: *[Tahun Cetak]*
  - Jika nomor edisi tersedia, gunakan baris terpisah dengan label `Edisi`.
- **Format rujukan tersalin:**
  - `[Pengarang]. [Judul Kitab]. Tahkik: [Muhaqqiq]. [Penerbit], [Tahun Cetak]. [Jumlah Jilid] jilid.`
  - Pesan Sukses: `Rujukan disalin.`
  - Pesan Simpan kitab: `Kitab disimpan ke Catatan.`
  - Pesan Hapus dari Catatan: `Kitab dihapus dari Catatan.`

---

## 8. Catatan dan editor

Sumber berkas: `openturath_ai/lib/screens/bookmark_screen.dart` dan `widgets/note_editor_sheet.dart`

### A. Catatan (BookmarkScreen)

- **Header Layar:** `Catatan`
- **Tombol Aksi:**
  - Tambah Catatan: Tooltip `Buat catatan`
  - Cari Catatan: Tooltip `Cari catatan` / `Tutup pencarian`
- **Kotak Pencarian:** Placeholder `Cari catatan atau kutipan`
- **Filter Tab Kategori:**
  - `Semua`, `Catatan`, `Kutipan`, `Kitab`
- **Filter Chips Disiplin:**
  - `Semua`, `Fikih`, `Hadis`, `Tafsir`, `Akidah`, `Usul Fikih`
- **Kartu catatan:**
  - Badge asisten: menampilkan nama asisten asal jawaban.
  - Tombol Aksi per Kartu: `Ubah`, `Salin kutipan`, `Lihat rujukan`
  - Tooltip Hapus: `Hapus catatan`
  - Tooltip Bagikan: `Bagikan catatan`
- **Empty State:**
  - Judul: `Belum ada catatan`
  - Penjelasan: `Simpan jawaban atau kutipan agar mudah dibuka kembali.`
  - Tombol CTA: `Buka asisten AI`
- **Dialog Hapus catatan:**
  - Judul: `Hapus catatan`
  - Pesan: `Catatan ini akan dihapus dari perangkat dan tidak bisa dikembalikan.`
  - Tombol Batal: `Batal`
  - Tombol Hapus: `Hapus`
  - SnackBar: `Catatan dihapus.`

### B. Editor catatan (NoteEditorSheet)

Catatan editor: pesan “Lengkapi judul dan isi catatan” berlaku jika keduanya wajib. Jika cukup salah satu, gunakan “Isi judul atau tulis catatan terlebih dahulu”. Pesan asli belum menjelaskan aturan validasinya.

- **Header Modal:** `Ubah catatan` / `Catatan baru`
- **Input Judul:** Placeholder `Judul catatan`
- **Input Isi/Ibarah:** Placeholder `Tulis catatan atau tempel kutipan di sini`
- **Toolbar Format Teks:**
  - Tooltips: `Tebal`, `Miring`, `Daftar berpoin`, `Kutipan`, `Kutipan Arab`, `Judul bagian`, `Subjudul`
- **Input Rujukan:**
  - Label: `Rujukan`
  - Input Kitab: Placeholder `Judul kitab`
  - Input Halaman/Jilid: Placeholder `Jilid dan halaman`
- **Tombol Aksi:**
  - Batal: `Batal`
  - Simpan: `Simpan perubahan` / `Simpan catatan`
- **Pesan SnackBar:**
  - Validasi: `Lengkapi judul dan isi catatan.`
  - Berhasil: `Catatan disimpan.`

---

## 9. Langganan dan pembayaran

Sumber berkas: `openturath_ai/lib/screens/subscription_screen.dart` dan `widgets/doku_checkout_sheet.dart`

### A. Langganan (SubscriptionScreen)

Catatan editor: harga dipertahankan. Cakupan paket dan lama akses perlu dipastikan sebelum teks diterapkan. “1 bulan” dan “30 hari” belum tentu sama. Hindari menyebut “semua asisten” atau “tanpa batas” sebelum hak akses dan batas penggunaan terkonfirmasi.

- **Header AppBar:** `Langganan`
- **Tombol Tukar Voucher di Header:** `Gunakan voucher`
- **Status Langganan Pengguna:**
  - *Jika Aktif:* `Langganan aktif`. `Aktif hingga [Tanggal]`
  - *Jika belum pernah berlangganan:* `Belum berlangganan`. `Pilih paket atau gunakan voucher untuk mulai berlangganan.`
  - *Jika masa aktif berakhir:* `Langganan berakhir`. `Perpanjang langganan atau gunakan voucher untuk melanjutkan.`
- **Pilihan Paket:**
  1. **Paket 1 Bulan:**
     - Harga: `Rp49.000` / bulan
     - Deskripsi: `Gunakan asisten pilihan Anda selama 30 hari.`
  2. **Paket 6 Bulan:**
     - Harga: `Rp299.000` / 6 bulan
     - Catatan editor: badge diskon dihapus karena tidak sesuai perbandingan harga.
     - Deskripsi: `Lanjutkan belajar selama 6 bulan.`
  3. **Paket 1 Tahun (Full Year):**
     - Harga: `Rp499.000` / tahun
     - Catatan editor: badge penghematan menunggu kesamaan cakupan paket dikonfirmasi.
     - Deskripsi: `Lanjutkan belajar selama 1 tahun.`
- **Daftar Keunggulan Paket:**
  - `Telusuri kitab rujukan yang tersedia dalam paket Anda.`
  - `Cari kutipan beserta informasi kitab, jilid, dan halaman yang tersedia.`
  - `Buka beberapa asisten dalam tab terpisah.`
  - `Simpan catatan di perangkat.`
- **Dialog Input WhatsApp Konfirmasi:**
  - Judul: `Nomor WhatsApp`
  - Penjelasan: `Bukti aktivasi langganan dan rincian pembayaran akan dikirim ke nomor ini.`
  - Placeholder: `Contoh: 081234567890`
  - Tombol Batal: `Batal`
  - Tombol Lanjut: `Lanjut ke pembayaran`
  - Validasi Error: `Periksa kembali nomor WhatsApp Anda.`

### B. Pembayaran (DokuCheckoutSheet)

Catatan editor: tampilkan hanya metode yang tersedia untuk transaksi ini. Pesan menutup halaman bergantung pada transaksi yang tetap berlaku setelah halaman ditutup. Pisahkan pembayaran berhasil dari aktivasi langganan, seperti pada Lampiran C.

- **Header:** `Pembayaran`
- **Subtitle:** `Pembayaran diproses melalui DOKU.`
- **Metode Pembayaran yang Didukung:**
  - `QRIS`
  - `Transfer bank (Virtual Account)`
  - `Gerai dan minimarket`
  - Catatan editor: rincian aplikasi, bank, dan gerai mengikuti metode yang tersedia. Inventaris menyebut GoPay, OVO, Dana, ShopeePay, BCA, Mandiri, BNI, BRI, dan Permata. Nama tersebut tidak perlu diulang dalam label utama.
- **Tombol Status:**
  - Tooltip: `Periksa pembayaran`
  - Tooltip Tutup: `Tutup`
- **Dialog konfirmasi tutup pembayaran:**
  - Judul: `Tutup pembayaran`
  - Pesan: `Halaman pembayaran akan ditutup. Menutup halaman ini tidak membatalkan transaksi yang sudah dibuat.`
  - Tombol 1: `Lanjutkan pembayaran`
  - Tombol 2: `Tutup`
- **Pesan Status Transaksi:**
  - Pembayaran berhasil dan akses aktif: `Pembayaran berhasil. Langganan Anda aktif.`
  - Pembayaran diterima, aktivasi masih berjalan: `Pembayaran diterima. Langganan sedang diaktifkan.`
  - Menunggu: `Menunggu konfirmasi pembayaran.`
  - Gagal, jika dikonfirmasi penyedia: `Pembayaran belum berhasil. Coba lagi atau pilih metode lain.`
  - Dibatalkan: `Pembayaran dibatalkan.`
  - Kedaluwarsa: `Batas waktu pembayaran sudah lewat. Buat pembayaran baru untuk melanjutkan.`
  - Status belum diketahui: `Status pembayaran belum bisa diperiksa. Coba lagi.`

---

## 10. Voucher

Sumber berkas: `openturath_ai/lib/widgets/redeem_code_sheet.dart`

- **Header Lembar:** `Gunakan voucher`
- **Deskripsi:** `Masukkan kode voucher untuk mengaktifkan langganan.`
- **Form Input:**
  - Placeholder: `Kode voucher`
  - Format teks: huruf kapital otomatis, mengikuti aturan kode yang berlaku.
  - Catatan editor: pastikan kode tidak membedakan huruf besar dan kecil sebelum mengubahnya otomatis.
- **Tombol Aksi:**
  - Teks Tombol: `Gunakan voucher`
  - Status Loading: Spinner animasi melingkar
- **Kamus Pesan Validasi & Kesalahan:**
  - Input Kosong: `Masukkan kode voucher.`
  - Kode Salah: `Kode voucher tidak ditemukan. Periksa kembali kodenya.`
  - Sudah Digunakan: `Anda sudah menggunakan voucher ini.`
  - Kuota Habis: `Batas penggunaan voucher ini sudah tercapai.`
  - Kedaluwarsa: `Voucher ini sudah kedaluwarsa.`
  - Voucher diterima dan akses aktif: `Voucher berhasil digunakan. Langganan Anda aktif.`
  - Voucher diterima, aktivasi masih berjalan: `Voucher diterima. Langganan sedang diaktifkan.`

---

## 11. Pengaturan dan dokumen kebijakan

Sumber berkas: `openturath_ai/lib/screens/profile_screen.dart`

### A. Informasi Akun Pengguna

- **Header Layar:** `Pengaturan`
- **Badge Tipe Akun:** `Akun OpenTurath`
- **Detail Akun:** Menampilkan Nama Lengkap, Alamat Email Google, serta ID Pengguna
- **Status Langganan:**
  - `Langganan aktif hingga [Tanggal]`
  - `Pilih paket atau gunakan voucher untuk mulai berlangganan.`

### B. Menu Preferensi & Tampilan

- **Seksi:** `Tampilan dan bahasa`
- **Pengaturan Tema:**
  - Judul: `Tampilan`
  - Pilihan: `Ikuti perangkat`, `Terang`, `Gelap`
- **Pengaturan Bahasa:**
  - Judul: `Bahasa`
  - Nilai: `Bahasa Indonesia`

### C. Ringkasan dokumen kebijakan

**Draf untuk ditinjau, belum menjadi pengganti dokumen kebijakan lengkap.** Lampiran sumber hanya berisi ringkasan. Klaim enkripsi, penggunaan Google OAuth, lisensi pembayaran, serta cakupan penghapusan data dipertahankan maknanya sebagai draf dan harus dicocokkan dengan implementasi. Jangan menayangkan klaim tersebut hanya karena tercantum dalam inventaris.

1. **Tentang OpenTurath (About OpenTurath)**
   - Judul: `Tentang OpenTurath`
   - Versi: `Versi [Nomor versi] · Membaca kitab, menelusuri ibarah.`
   - Catatan editor: inventaris menyebut versi 1.0.9. Tampilkan nomor versi dari aplikasi.
   - Isi: `OpenTurath membantu santri, pengajar, dan peneliti menelusuri kitab dengan bantuan AI. Cari kutipan, baca penjelasan, dan bandingkan rujukan sesuai bidang yang Anda pelajari.`
   - Tombol: `Tutup`
2. **Ketentuan Layanan (Terms of Service)**
   - Judul: `Ketentuan Layanan`
   - Butir 1: `1. Penggunaan OpenTurath`. OpenTurath digunakan untuk penelitian akademis dan penelusuran literatur Islam.
   - Butir 2: `2. Pemeriksaan sumber dan batas penggunaan`. Jawaban AI tidak menggantikan fatwa ulama. Pengguna wajib mencocokkan kutipan dengan kitab cetak yang dirujuk.
   - Butir 3: `3. Akun dan akses`. Akun digunakan secara pribadi dan tidak boleh disalahgunakan.
   - Butir 4: `4. Pembayaran dan langganan`. Pembayaran diproses melalui penyedia layanan pembayaran berlisensi.
   - Tombol Persetujuan: `Saya setuju`
3. **Kebijakan Privasi (Privacy Policy)**
   - Judul: `Kebijakan Privasi`
   - Butir 1: `1. Data yang dikumpulkan dan digunakan`. Kami mengumpulkan alamat email dan informasi dasar profil Google untuk proses masuk.
   - Butir 2: `2. Penyimpanan catatan`. Catatan dan rujukan tersimpan dilindungi dengan enkripsi.
   - Butir 3: `3. Akses Google dan NotebookLM`. Proses masuk menggunakan Google OAuth.
   - Butir 4: `4. Penghapusan akun dan data`. Anda berhak menghapus akun dan seluruh data Anda kapan saja.
   - Tombol Tutup: `Tutup`
4. **Tentang sumber rujukan**
   - Judul: `Tentang sumber rujukan`
   - Isi: `Setiap asisten menggunakan kumpulan kitab sesuai bidangnya. Informasi kitab memuat pengarang, jilid, dan edisi yang tersedia. Cocokkan kutipan dengan sumber di Maktabah Syamilah atau kitab cetak yang digunakan.`
   - Tombol: `Tutup`

### D. Keluar dan menghapus akun

Catatan editor: teks hapus akun mengikuti cakupan server dalam sumber. Karena catatan juga disebut tersimpan di perangkat, pastikan apakah penghapusan akun menghapus keduanya. Gunakan pesan yang sesuai cakupan aktual.

- **Tombol Keluar (Logout):**
  - Label: `Keluar dari akun`
  - Dialog Konfirmasi: `Keluar dari akun`. `Anda perlu masuk kembali untuk menggunakan akun ini.`
  - Tombol: `Batal` \| `Keluar`
- **Tombol Hapus Akun (Destructive Action):**
  - Label: `Hapus akun`
  - Dialog Peringatan: `Hapus akun`
  - Pesan Bahaya: `Profil, catatan tersimpan, dan data akun Anda di server akan dihapus. Tindakan ini tidak dapat dibatalkan.`
  - Tombol: `Batal` \| `Hapus akun`
  - Pesan Berhasil: `Akun dihapus.`
  - Pesan Keamanan Re-Login: `Masuk kembali untuk melanjutkan penghapusan akun.`

---

## 12. Kutipan, pembaruan, dan pesan sistem

### A. Kutipan dan rujukan (EvidenceBottomSheet)

Sumber berkas: `openturath_ai/lib/widgets/evidence_bottom_sheet.dart`

- **Header Sheet:** `Kutipan dan rujukan`
- **Metadata Kutipan:**
  - Label pengarang: `Pengarang`
  - Label Halaman: `Halaman` / `Jilid`
  - Label Kategori: `Kategori`
- **Teks Arab:** Tampilkan kutipan sesuai teks sumber. Jangan menambahkan harakat atau menandainya sebagai teks asli terverifikasi tanpa pemeriksaan sumber.
- **Tombol Aksi:**
  - `Salin kutipan` (Pesan: *Kutipan disalin.*)
  - `Cari di Maktabah Syamilah`
  - Tooltip: `Salin rujukan` (Pesan: *Rujukan disalin.*)

### B. Pembaruan aplikasi (UpdateReadyBanner)

Catatan editor: “siap dipasang” hanya dipakai setelah berkas pembaruan selesai diunduh. Jika baru tersedia, gunakan “Versi baru tersedia”. Isi perubahan harus mengikuti catatan rilis.
Sumber berkas: `openturath_ai/lib/widgets/update_ready_banner.dart`

- **Badge:** `Pembaruan tersedia`
- **Judul Banner:** `Versi baru siap dipasang`
- **Penjelasan:** `Perbarui OpenTurath untuk menggunakan versi terbaru.`
- **Tombol Pasang:** `Perbarui sekarang`
- **Tombol Nanti:** `Nanti`

### C. Pesan kesalahan umum (AppErrorState)

Sumber berkas: `openturath_ai/lib/widgets/app_error_state.dart`

- **Judul:** `Data belum bisa dimuat`
- **Deskripsi:** `OpenTurath belum bisa memuat data. Coba lagi.`
- **Tombol:** `Coba lagi`

---


## Lampiran A. Pilihan istilah dan gaya bahasa

### Pilihan utama dan alternatif

| Istilah lama | Pilihan utama | Alternatif yang sesuai konteks |
| --- | --- | --- |
| Korpus | Kumpulan kitab | Koleksi kitab untuk kelompok yang dikurasi |
| Korpus ulama | Ulama | Karya ulama jika isi tab memang hanya karya mereka |
| Naskah kanonikal | Kitab rujukan | Koleksi kitab untuk nama kumpulan |
| Khazanah asisten riset naskah primer turats | Pilih bidang ilmu atau karya ulama yang ingin Anda telusuri. | Telusuri kitab bersama asisten AI. |
| Perkakas telaah dan komparasi naskah | Bantuan untuk menelusuri kitab | Cari dan bandingkan rujukan |
| Spesialis | Asisten | Asisten AI pada pengenalan pertama |
| Membuka AI | Membuka percakapan… | Menyiapkan asisten… jika sesi belum dibuat |
| Ruang riset | Percakapan | Ruang belajar hanya jika memang nama fitur yang lebih luas |
| Pengaturan Tampilan & Baca | Tampilan bacaan | Atur bacaan untuk tombol tindakan |
| Keterangan kitab | Tentang kitab | Detail kitab jika ingin gaya lebih ringkas |
| Muallif | Pengarang | Penulis untuk konten umum di luar katalog kitab |
| Muhaqqiq | Penyunting (tahkik) | Pentahkik untuk pembaca yang terbiasa dengan istilah tersebut |
| Tipe naskah | Jenis kitab | Bentuk karya bila klasifikasinya memang berdasarkan bentuk |
| Era keilmuan | Periode | Tahun atau rentang tahun untuk filter kronologis |
| Derajat mu'tabar | Kedudukan dalam mazhab | Sembunyikan jika belum ada keterangan yang bersumber |
| Sitasi | Rujukan | Format rujukan pada pengaturan ekspor |
| Kutipan ibarah | Kutipan | Ibarah di pembahasan yang memerlukan istilah tersebut |
| Klaim akses sekarang | Gunakan voucher | Aktifkan langganan jika tindakan utamanya aktivasi |
| Catatan riset | Catatan | Catatan kajian dalam kalimat penjelasan bila diperlukan |
| Tampilan dan kebahasaan | Tampilan dan bahasa | Preferensi hanya untuk pengelompokan yang lebih luas |

“Korpus ulama” tidak lagi muncul sebagai label tab pada inventaris terbaru. Tab tersebut sudah menjadi “Berdasarkan Tokoh Ulama”. Usulan “Ulama” mempersingkat label terbaru. Kata “korpus” masih muncul dalam penjelasan sumber rujukan, sehingga bagian itu juga diperbaiki.

### Aturan penulisan

1. Gunakan kalimat langsung: “Simpan catatan”, “Buka percakapan”, dan “Periksa pembayaran”.
2. Gunakan kapital pada awal label, nama diri, serta nama fitur yang dirujuk. Contoh: “Simpan perubahan” dan “Simpan ke Catatan”.
3. Sebut objek yang benar secara konsisten. Jangan berganti antara asisten, spesialis, modul, dan AI untuk objek yang sama.
4. Gunakan satu istilah untuk satu tindakan. Untuk voucher, gunakan “Gunakan voucher” pada pintu masuk, judul, dan tombol.
5. Hindari “silakan”, “terlebih dahulu”, “berhasil”, dan “Anda” jika tidak menambah makna. Pertahankan ketika membantu nada atau memperjelas hasil.
6. Pisahkan tindakan dan status. “Buka percakapan” adalah tombol. “Membuka percakapan…” adalah status memuat. “Tersedia” adalah status ketersediaan asisten.
7. Jangan menyatakan penyebab kesalahan yang belum diketahui. Sebut gangguan internet hanya bila ada dasar dari status koneksi atau kegagalan jaringan.
8. Gunakan “Belum tercatat” untuk data kosong. “Sedang diperiksa” hanya digunakan bila memang ada proses pemeriksaan.
9. Gunakan Hadis, Akidah, Usul Fikih, dan Akhlak secara konsisten untuk nama bidang. Jangan mengubah ejaan judul kitab, nama orang, transliterasi kutipan, ID, atau teks Arab dengan penggantian global.
10. Pertahankan istilah yang membawa makna khusus, termasuk matan, syarah, hasyiyah, sanad, takhrij, mu'tamad, qira'at, dan nama mazhab. Beri bantuan singkat saat pembaca memerlukannya.
11. Gunakan “kutipan” pada tombol umum. Ibarah tetap dapat digunakan di isi kajian dan identitas merek “Membaca kitab, menelusuri ibarah.”
12. Gunakan tanggal yang mudah dibaca seperti “Aktif hingga 10 Oktober 2027”. Contoh tanggal bukan data akun aktual. Tampilkan nomor versi dari aplikasi, bukan angka tetap dari dokumen ini.
13. Jangan menaruh pesan penting hanya pada placeholder. Kolom voucher, judul catatan, dan WhatsApp tetap memerlukan label yang terbaca setelah pengguna mengetik.
14. Untuk ikon, gunakan label aksesibilitas yang menyebut tindakan dan objek, seperti “Tutup percakapan Fikih Syafi'i” dan “Hapus pencarian kitab”.
15. Tidak perlu mengubah kata yang sudah jelas, seperti Beranda, Catatan, Pengaturan, Profil, Bahasa, Simpan, Batal, Tutup, dan Coba lagi.

### Contoh blok yang sudah utuh

**Daftar asisten**

- Judul: `Asisten AI`
- Penjelasan: `Pilih bidang ilmu atau karya ulama yang ingin Anda telusuri.`
- Pengelompokan: `Bidang ilmu` dan `Ulama`
- Status kategori kosong: `Belum ada asisten di kategori ini.`

**Sebelum mulai**

- Judul: `Catatan sebelum mulai`
- Isi: `OpenTurath membantu mencari kutipan dan membandingkan penjelasan dalam kitab. Periksa hasilnya pada sumber yang dirujuk. Untuk memahami agama dan menetapkan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.`
- Tombol: `Saya mengerti`

**Catatan kosong**

- Judul: `Belum ada catatan`
- Isi: `Simpan jawaban atau kutipan agar mudah dibuka kembali.`
- Tombol: `Buka asisten AI`
- Alternatif tindakan, bila diarahkan ke editor: `Buat catatan`

## Lampiran B. Bagian yang perlu dipastikan sebelum diterapkan

| Bagian | Temuan dalam inventaris | Keputusan atau langkah penerapan |
| --- | --- | --- |
| Jumlah bidang | Judul menyebut 6 bidang, daftar memuat 9. | Judul dokumen diubah menjadi “Bidang ilmu”. Jumlah di aplikasi harus mengikuti data yang ditampilkan. |
| Harga 6 bulan | Rp49.000 × 6 = Rp294.000, sedangkan paket 6 bulan Rp299.000. | Lepas badge “HEMAT 15%”. Harga dipertahankan. Selisih Rp5.000 perlu ditinjau oleh pemilik produk. |
| Harga tahunan | Rp49.000 × 12 = Rp588.000. Paket tahunan Rp499.000, selisih Rp89.000. | Penghematan sekitar 15,1% hanya berlaku jika cakupan, biaya, dan hak akses setara. Jangan memindahkan badge diskon otomatis. |
| Lama akses bulanan | Judul “1 bulan”, deskripsi “30 hari”. | Jika akses tepat 30 hari, gunakan “30 hari” di seluruh alur. Jika bulan kalender, gunakan “1 bulan”. Pilihan mengikuti mekanisme langganan. |
| Cakupan langganan | Paket bulanan menyebut asisten terpilih, paket tahunan dan profil menyebut semua asisten. | Tampilkan cakupan dari hak akses aktual. Usulan netral menghapus janji “semua” dan “tanpa batas”, bukan memutuskan cakupan baru. |
| Klaim ketepatan | Ada “presisi”, “asli”, “mu'tamad”, “kanonikal”, dan “telah diverifikasi” pada klaim umum. | Ganti dengan informasi yang bisa diperiksa. Kedudukan mu'tamad tetap dapat ditampilkan jika ada rujukan dan cakupan penilaiannya jelas. |
| Klaim keamanan | Ada klaim enkripsi, OAuth resmi, penyedia berlisensi, dan verifikasi instan. | Jangan menganggap inventaris sebagai bukti. Klaim legal ditandai draf. Copy pembayaran umum disederhanakan menjadi “Pembayaran diproses melalui DOKU”. |
| Identitas asisten ulama | Nama asisten menyerupai nama ulama. | Gunakan alternatif “Karya Habib Umar bin Hafizh” atau “Karya Al-Ghazali” jika sesuai isi. Keterangan harus menjelaskan bahwa asisten menelusuri karya dan tidak mewakili jawaban langsung ulama tersebut. Nama dalam data master belum diubah. |
| Istilah perataan | “Kanan ke Kiri (RTL)” dan “Rata Kanan-Kiri” mencampur arah dan perataan. | Pisahkan arah tulisan dan perataan. Pergantian label saja tidak menyelesaikan perbedaan fungsi. |
| Filter periode | Istilah kronologis dicampur dengan kategori seperti Ashab Al-Wujuh. | Label rentang tahun boleh dipersingkat. Jangan menganggap semua klasifikasi sebagai periode. Pastikan jenis filter sesuai datanya dan pertahankan istilah ilmiah yang berbeda makna. |
| Edisi dan jumlah jilid | “Naskah Tunggal” muncul sebagai alternatif jumlah jilid. | Gunakan “1 jilid” hanya bila data menyatakannya. Untuk data kosong, gunakan “Belum tercatat” atau sembunyikan baris. |
| Format rujukan | Format lama menambahkan tahun wafat dan nama produk sebagai bagian rujukan. | Rujukan kitab memakai pengarang, judul, tahkik, penerbit, tahun, dan jumlah jilid yang tersedia. Untuk kutipan tertentu, tambahkan jilid dan halaman kutipan. Jangan mengarang data yang hilang. |
| Validasi catatan | “Judul atau isi catatan tidak boleh kosong” ambigu. | Teks harus mengikuti aturan apakah keduanya wajib atau cukup salah satu. Pilihan keduanya wajib ditandai pada editor. |
| Salin sekaligus simpan | Salin berhasil juga diklaim menyimpan ke Catatan. | Pertahankan perilaku tersebut bila memang ada. Tampilkan pesan gabungan hanya setelah kedua operasi sukses. |
| Hapus akun | Data disebut dihapus dari server, catatan juga disebut lokal. | Pastikan cakupan penghapusan dan tulis dampaknya. Jangan menjanjikan semua catatan terhapus jika hanya akun di server yang dihapus. |
| Tutup percakapan | Teks lama tidak jelas apakah percakapan hilang atau hanya tab ditutup. | Usulan meminta pengguna menyimpan jawaban tanpa menjanjikan pemulihan. Jika riwayat benar-benar hilang, sebut kehilangan itu secara eksplisit. |
| Tutup pembayaran | Judul internal menyebut pembatalan, isi menyebut penutupan. | Menutup halaman dan membatalkan transaksi membutuhkan pesan berbeda. Cocokkan dengan status penyedia pembayaran. |
| Voucher berhasil | Aktivasi akses disatukan dengan penerimaan voucher. | Pisahkan pesan jika validasi voucher berhasil tetapi aktivasi masih berjalan. |
| Nomor WhatsApp | Dijanjikan pengiriman bukti aktivasi dan rincian transaksi. | Pertahankan janji hanya jika kedua pesan benar-benar dikirim. Tampilkan kolom hanya bila dibutuhkan dalam alur. |
| Metode pembayaran | Daftar metode disebut lengkap secara tetap. | Gunakan metode yang tersedia pada transaksi dan akun penyedia saat itu. Daftar dalam dokumen ini bukan hasil verifikasi layanan DOKU. |
| Bahasa sumber | Nama ulama dan judul kitab memakai beberapa bentuk transliterasi. | Samakan berdasarkan metadata otoritatif, bukan tebakan copywriter. Nama, teks Arab, dan ID tidak dinormalisasi otomatis. |
| Pencarian | Placeholder beranda menjanjikan pencarian asisten, kitab, dan bab. | Tampilkan hanya objek yang benar-benar bisa dicari. Pencarian catatan dan kitab memiliki konteks berbeda. |
| Platform | Inventaris menyebut Android, macOS, dan Windows. | Redaksi mempertahankan daftar tersebut sebagai data sumber. Cocokkan dengan dukungan versi rilis sebelum diterapkan. |
| Banner pembaruan | “Siap dipasang” bisa tampil sebelum unduhan selesai. | Bedakan versi tersedia, sedang diunduh, dan siap dipasang. Klaim kitab baru harus berasal dari catatan rilis. |
| Bahasa persetujuan | Dialog kebijakan dan tombol persetujuan tercampur. | Gunakan “Saya setuju” jika tindakan mencatat persetujuan. Gunakan “Tutup” jika hanya membaca dokumen. Ketentuan dan Privasi tetap memakai nama yang sama di semua layar. |

## Lampiran C. Pesan untuk status yang perlu dibedakan

Bagian ini berisi usulan tambahan, bukan teks yang sudah terbukti ada dalam aplikasi. Terapkan hanya pada kondisi yang bisa dibedakan oleh sistem.

| Kondisi | Pesan | Tindakan bila tersedia |
| --- | --- | --- |
| Sedang membuka sesi | Membuka percakapan… | Tidak perlu tombol tambahan |
| Sedang mengambil daftar kitab | Memuat kitab rujukan… | Tidak perlu tombol tambahan |
| Tidak tersambung ke internet | Tidak ada koneksi internet. Periksa koneksi, lalu coba lagi. | Coba lagi |
| Sesi masuk berakhir | Sesi Anda berakhir. Masuk kembali untuk melanjutkan. | Masuk kembali |
| Asisten tersedia untuk digunakan | Tersedia | Buka percakapan |
| Asisten belum dirilis | Asisten ini sedang disiapkan. | Tutup |
| Salin dan simpan berhasil | Jawaban disalin dan disimpan ke Catatan. | Buka Catatan |
| Hanya salin yang dijalankan dan berhasil | Jawaban disalin. | Tidak perlu tombol tambahan |
| Salin berhasil, simpan gagal | Jawaban disalin, tetapi belum tersimpan ke Catatan. | Coba simpan lagi |
| Simpan berhasil, salin gagal | Jawaban tersimpan ke Catatan, tetapi belum bisa disalin. | Coba salin lagi |
| Salin dan simpan sama-sama gagal | Jawaban belum bisa disalin atau disimpan. Coba lagi. | Coba lagi |
| Menutup editor dengan perubahan belum tersimpan | Perubahan belum disimpan. Simpan sebelum menutup catatan. | Simpan, Buang perubahan, Lanjutkan menulis |
| Judul catatan wajib dan kosong | Isi judul catatan. | Fokus ke judul |
| Isi catatan wajib dan kosong | Tulis isi catatan. | Fokus ke isi |
| Pencarian catatan kosong | Belum ada catatan yang cocok. Coba kata kunci lain. | Hapus pencarian |
| Pencarian kitab kosong tanpa filter | Belum ada kitab yang cocok. Coba kata kunci lain. | Hapus pencarian |
| Pencarian kitab kosong dengan filter | Belum ada kitab yang cocok. Coba ubah kata kunci atau hapus filter. | Hapus filter |
| Langganan belum pernah dibuat | Belum berlangganan | Lihat paket |
| Langganan sudah berakhir | Langganan berakhir pada [Tanggal]. | Perpanjang langganan |
| Menyiapkan transaksi | Menyiapkan pembayaran… | Tidak perlu tombol tambahan |
| Pembayaran belum diterima | Menunggu pembayaran. Selesaikan sebelum [Tanggal dan waktu]. | Lanjutkan pembayaran |
| Pembayaran sedang diperiksa | Menunggu konfirmasi pembayaran. | Periksa pembayaran |
| Pembayaran diterima, akses belum aktif | Pembayaran diterima. Langganan sedang diaktifkan. | Periksa akses |
| Pembayaran diterima dan akses aktif | Pembayaran berhasil. Langganan Anda aktif. | Buka asisten AI |
| Status pembayaran belum bisa diperiksa | Status pembayaran belum bisa diperiksa. Coba lagi. | Periksa pembayaran |
| Pembayaran gagal, menurut status transaksi | Pembayaran belum berhasil. Coba lagi atau pilih metode lain. | Pilih metode pembayaran |
| Transaksi kedaluwarsa | Batas waktu pembayaran sudah lewat. Buat pembayaran baru untuk melanjutkan. | Buat pembayaran baru |
| Transaksi dibatalkan | Pembayaran dibatalkan. | Kembali ke langganan |
| Memeriksa voucher | Memeriksa voucher… | Tidak perlu tombol tambahan |
| Voucher valid, aktivasi masih berjalan | Voucher diterima. Langganan sedang diaktifkan. | Periksa akses |
| Voucher diterima dan akses aktif | Voucher berhasil digunakan. Langganan Anda aktif. | Buka asisten AI |
| Versi baru tersedia | Versi baru tersedia. | Unduh pembaruan |
| Pembaruan sedang diunduh | Mengunduh pembaruan… | Sesuai dukungan pembatalan unduhan |
| Pembaruan selesai diunduh | Versi baru siap dipasang. | Perbarui sekarang |

Nama tindakan pada tabel ini adalah usulan. Jangan menampilkan tombol pemulihan, pemeriksaan, atau pembukaan ulang sebelum fungsi tersebut tersedia.

## Penerapan dan pemeriksaan redaksi

Mulai dari AppCopy agar kata yang berulang berubah serentak. Setelah itu, terapkan deskripsi asisten dan bidang, lalu teks khusus di setiap layar. Pertahankan ID internal serta placeholder dinamis. Teks yang tergantung status pembayaran, penyimpanan, dan akses harus dipilih berdasarkan hasil operasi yang sebenarnya.

Periksa hasil pada layar kecil, pengaturan huruf besar, judul Arab panjang, data kosong, pencarian tanpa hasil, serta gangguan jaringan. Pastikan label terlihat utuh dan pembaca layar menyebut tindakan yang sama. Catatan editor dan lampiran tidak ikut masuk ke teks aplikasi.

Dokumen ini memperbaiki redaksi seluruh bagian inventaris. Bagian kebijakan dan klaim fitur yang ditandai belum dinyatakan siap rilis karena memerlukan kepastian fakta implementasi.
