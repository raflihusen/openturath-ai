# Cetak Biru Rebranding Arsitektur: OpenTurath ➔ Maktabah AI
**Pemetaan Komprehensif Hierarki Perusahaan (OpenTurath) dan Aplikasi Produk (Maktabah AI)**

---

## 1. Ringkasan Eksekutif & Filosofi Brand

Langkah transformasi ini memisahkan secara tegas antara **Entitas Organisasi/Riset Induk (Parent Company/Lab)** dan **Aplikasi Produk Konsumen/Peneliti (Flagship Consumer App)**, mengikuti standar emas perusahaan teknologi terkemuka dunia:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        HIERARKI STRUKTUR BRAND                         │
├───────────────────────────────────┬────────────────────────────────────┤
│ PERUSAHAAN / RISET INDUK (LAB)    │ APLIKASI PRODUK UNGGULAN (APP)     │
├───────────────────────────────────┼────────────────────────────────────┤
│ OpenAI                            │ ChatGPT                            │
│ Alphabet                          │ Google Search                      │
│ Anthropic                         │ Claude                             │
│ OpenTurath                        │ Maktabah AI                        │
└───────────────────────────────────┴────────────────────────────────────┘
```

### A. Definisi Entitas:
1. **OpenTurath (Entitas Induk)**:
   - **Peran**: Laboratorium riset kecerdasan buatan, kurasi korpus turats nabawi, pemelihara metodologi sanad, infrastruktur data, dan pemilik hak cipta hukum.
   - **Misi**: Menjaga kemurnian, mendigitalkan, dan menyediakan infrastruktur data khazanah Islam klasik bagi peradaban modern.
2. **Maktabah AI (Aplikasi Produk)**:
   - **Peran**: Antarmuka perpustakaan digital cerdas, ruang riset multi-agen bagi santri/peneliti, dan asisten telaah naskah kitab kuning interaktif.
   - **Identitas Arab**: `المكتبة الذكية (Maktabah AI) — برعاية أوبن تراث`
   - **Tagline Resmi**:
     - Bahasa Indonesia: *Maktabah AI — Khazanah Turats & Fikih Berbasis Sanad*
     - Bahasa Arab: *تراث الأمة بذكاء العصر*

---

## 2. Prinsip Keamanan & Integritas Teknis (Zero-Risk Migration)

> [!IMPORTANT]
> **Prinsip Dasar: Perubahan Identitas Tampilan TANPA Merusak Fondasi Sistem**

Untuk memastikan pembaruan aplikasi berjalan mulus tanpa merugikan pengguna yang sudah ada:
1. **Application ID / Package Name Tetap Dipertahankan**:
   - `applicationId "com.openturath.ai"` pada Android Gradle **TIDAK DIUBAH**.
   - **Alasan**: Mengubah package name akan menyebabkan Android menganggapnya sebagai aplikasi baru yang berbeda, sehingga pengguna lama tidak bisa melakukan update otomatis dan database SQLite lokal akan terputus.
2. **Skema Database Firestore Tetap Stabil**:
   - Nama koleksi: `users`, `entitlements`, `device_redemptions`, `redeem_codes`, `payment_transactions` tetap sama persis.
3. **Konfigurasi Payment Gateway (DOKU)**:
   - Webhook URL dan credential merchant tetap merujuk ke OpenTurath, hanya deskripsi tagihan yang disesuaikan: *"Langganan Maktabah AI (OpenTurath)"*.
4. **Email Bantuan & Domain**:
   - Email tetap: `openturath@gmail.com`.
   - Domain web: `openturath.web.app` (dengan Maktabah AI sebagai hero product).

---

## 3. Pemetaan Perubahan File demi File (File-by-File Mapping)

### A. Lapisan Native Android (Sistem Operasi)

| File Target | Lokasi | Elemen Lama | Elemen Baru | Catatan Teknis |
| :--- | :--- | :--- | :--- | :--- |
| `AndroidManifest.xml` | `android/app/src/main/` | `android:label="OpenTurath AI"` | `android:label="Maktabah AI"` | Mengubah nama ikon di layar beranda ponsel pengguna. |
| `strings.xml` | `android/app/src/main/res/values/` | `app_name: OpenTurath AI` | `app_name: Maktabah AI` | String lokalisasi bawaan OS Android. |

---

### B. Lapisan Inti & Konfigurasi Flutter (`lib/core/`)

#### 1. [`lib/core/constants.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/constants.dart)
```dart
// SEBELUM:
static const String appName = 'OpenTurath AI';

// SESUDAH:
static const String appName = 'Maktabah AI';
static const String companyName = 'OpenTurath';
static const String appFullName = 'Maktabah AI by OpenTurath';
```

#### 2. [`lib/core/localization.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/localization.dart)
```dart
// id:
'app_name': 'Maktabah AI',
'app_tagline': 'Khazanah Turats & Fikih Berbasis Sanad',
'powered_by': 'Dikembangkan oleh OpenTurath',

// ar:
'app_name': 'المكتبة الذكية',
'app_tagline': 'تراث الأمة بذكاء العصر',
'powered_by': 'برعاية أوبن تراث',
```

#### 3. [`lib/core/legal_copy.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/core/legal_copy.dart)
- Memperjelas klausul hukum bahwa **Maktabah AI** adalah aplikasi yang dimiliki dan dikelola secara sah oleh **OpenTurath**:
```dart
static const aboutAppTitle = 'Tentang Maktabah AI';
static const aboutAppTagline = 'Membaca kitab, menelusuri ibarah.';
static const managerName = 'Pengelola OpenTurath';
static const legalEntityNotice = 'Maktabah AI adalah produk riset dan layanan digital unggulan dari OpenTurath.';
```

---

### C. Lapisan Antarmuka Pengguna (UI Screens & Widgets)

#### 1. [`lib/main.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/main.dart)
- `MaterialApp(title: 'Maktabah AI', ...)`

#### 2. [`lib/screens/dashboard_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart) (Beranda Peneliti)
- Header Atas: Menampilkan tipografi logo **Maktabah AI** yang berwibawa, disertai subteks halus `by OpenTurath` dengan tipografi Scheherazade New Naskh.
- Kartu Sambutan: *"Selamat datang di Maktabah AI — Ruang Riset Khazanah Turats Nabawi"*.

#### 3. [`lib/screens/login_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/login_screen.dart)
- Header Gerbang Riset: Menampilkan judul **Maktabah AI** dan deskripsi *"Masuk ke perpustakaan turats cerdas Anda"*. Footer: *"Didukung oleh OpenTurath"*.

#### 4. [`lib/screens/subscription_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/subscription_screen.dart)
- Judul: *"Langganan Maktabah AI"*
- Deskripsi Paket: *"Akses penuh ke seluruh spesialis kecerdasan buatan Maktabah AI"*.
- Informasi Pengelola: *"Layanan dikelola secara resmi oleh OpenTurath"*.

#### 5. [`lib/screens/settings_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/settings_screen.dart) & Dialog Tentang Aplikasi
- Menampilkan Versi: `Maktabah AI v1.0.0 (Build 2026)`
- Kartu Informasi Entitas: 
  > *"Maktabah AI dikembangkan dengan penuh khidmah oleh OpenTurath sebagai kontribusi digital bagi pelestarian khazanah keilmuan Islam Ahlussunnah wal Jama'ah."*

#### 6. Ekspor Kutipan & Catatan Riset
- [`lib/services/research_notes_service.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/services/research_notes_service.dart) & [`lib/screens/bookmark_screen.dart`](file:///Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/bookmark_screen.dart):
  - Watermark sitasi resmi saat santri menyalin teks ke clipboard:
    `Sumber: Maktabah AI by OpenTurath ([Nama Kitab] - [Spesialis AI])`

---

### D. Lapisan Web Publik & Halaman Hukum (`public/`)

Semua dokumen HTML di folder `public/` diperbarui untuk mencerminkan dualitas brand ini:

1. **`public/index.html` (Landing Page)**:
   - `<title>Maktabah AI — Perpustakaan & Asisten Riset Turats Berbasis Sanad | by OpenTurath</title>`
   - Hero Section: *"Maktabah AI: Masa Depan Riset Kitab Kuning"*
   - Footer: *"© 2026 OpenTurath. Seluruh hak cipta dilindungi undang-undang. Maktabah AI adalah produk terdaftar dari OpenTurath."*
2. **`public/terms.html` & `public/privacy.html`**:
   - Klausul Pembuka: *"Ketentuan ini mengatur penggunaan aplikasi Maktabah AI ("Aplikasi") yang disediakan oleh OpenTurath ("Kami")."*
3. **`public/refund.html`, `public/copyright.html`, `public/ai-policy.html`**:
   - Menyelaraskan nama layanan ke Maktabah AI dengan kontak penyelesaian ke `openturath@gmail.com`.

---

### E. Lapisan Backend & Cloud Functions (`functions/src/index.ts`)

1. **Notifikasi Telegram / Webhook Transaksi**:
   - Notifikasi Admin: `[Maktabah AI] Langganan Aktif: ${name} (${planTitle})`.
2. **Template Email Notifikasi & Provisioning**:
   - Subjek Email: *"Selamat Datang di Maktabah AI — Akses Riset Turats Anda Telah Aktif"*.
   - Header Email: Brandmark Maktabah AI dengan footer OpenTurath.

---

## 4. Rencana Tahapan Eksekusi (Implementation Milestones)

```
[Milestone 1] ──> [Milestone 2] ──> [Milestone 3] ──> [Milestone 4]
  Konfigurasi       Pembaruan UI        Web Publik &        Verifikasi
  & Android Native   App & Salinan      Halaman Hukum       & 127 Tests
```

- **Tahap 1 (Konfigurasi & Android)**:
  - Ubah label Android di `AndroidManifest.xml` & `constants.dart`.
  - Checkpoint Git otomatis.
- **Tahap 2 (Antarmuka Flutter & Salinan)**:
  - Perbarui teks pada Dashboard, Login, Subscription, Settings, dan format sitasi kutipan catatan.
  - Checkpoint Git otomatis.
- **Tahap 3 (Web Publik & Legal)**:
  - Perbarui 9 file HTML di `public/` dan salinan hukum `legal_copy.dart`.
  - Checkpoint Git otomatis.
- **Tahap 4 (Verifikasi & Pengujian)**:
  - Jalankan `flutter test` untuk memastikan 127 test suite tetap lulus 100%.
  - Verifikasi bahwa build APK dan deploy web tetap ditahan sesuai perintah Anda.

---

## 5. Kesimpulan Manfaat Rebranding

Dengan pemetaan ini:
1. Pengguna mendapatkan nama aplikasi yang **sangat prestisius, mudah diingat, dan berakar kuat pada tradisi keilmuan Islam (*Maktabah AI*)**.
2. Anda memiliki entitas perusahaan yang **kredibel, siap menerima investasi internasional, dan siap menaungi produk-produk turats lainnya di masa depan (*OpenTurath*)**.
3. Seluruh proses migrasi terjamin **aman 100% tanpa risiko teknis pada database maupun instalasi perangkat**.
