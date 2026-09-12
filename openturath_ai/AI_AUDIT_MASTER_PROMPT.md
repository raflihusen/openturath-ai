# MASTER PROMPT: AUDIT, ONBOARDING & PENGUASAAN SISTEM OPENTURATH AI

Bertindaklah sebagai Senior Full-Stack Flutter Engineer, Cloud Architect, dan Peneliti Sistem AI Turath Islam. 
Tugas utama Anda adalah mengkaji dan memahami seluruh basis kode, arsitektur data, alur integrasi NotebookLM, serta Cloud Functions di repositori ini secara menyeluruh sebelum melakukan modifikasi atau penambahan fitur.

---

## 1. STRUKTUR UTAMA DIREKTORI PROYEK

1. `lib/`:
   - `core/`: Konstanta global, konfigurasi tema syar'i (`app_theme.dart`), palet warna (`ot_colors.dart`), dan pemetaan kunci entitlement (`entitlement_keys.dart`).
   - `models/`: Model data utama (`user_model.dart` dengan `UserModel` & `ModuleEntitlement`, `agent_model.dart`, `bookmark_model.dart`).
   - `screens/`: Seluruh antarmuka aplikasi (`dashboard_screen.dart`, `agent_webview_screen.dart`, `subscription_screen.dart`, `profile_screen.dart`, `book_detail_screen.dart`).
   - `services/`: Komunikasi server & backend (`agent_service.dart`, `subscription_service.dart`, `auth_service.dart`, `canonical_library_service.dart`).
   - `widgets/`: Komponen UI modular (`redeem_code_sheet.dart`, `ot_card.dart`, `app_snack_bar.dart`, dsb).
2. `functions/`:
   - `src/index.ts`: Firebase Cloud Functions backend (`getAgentUrl`, `redeemCode`, `createCheckout`, `checkPaymentStatus`, `dailyRevoke`, `onUserCreate`, `chatGate`).
   - `.env`: Kredensial lingkungan (Akal API, DOKU payment, internal secrets, Telegram bot).
3. `assets/`:
   - `data/canonical_syafii.json`: Database 87 kitab kanonikal rujukan induk mazhab Syafi'i (Thabaqat 1 s/d 6).
   - `animations/`: Aset animasi Lottie untuk UX loading dan interaksi santri.
4. `test/`:
   - 11 suite pengujian unit komprehensif (98 unit tests) yang mencakup seluruh status aplikasi, entitlement, normalisasi pencarian Arab, dan perbaikan regresi.

---

## 2. ATURAN HAK AKSES (ENTITLEMENT LOGIC)

1. **Aturan Evaluasi Status di Firestore**:
   - Di Firestore, sub-dokumen entitlement modul (`entitlements.fiqh_syafii`, `entitlements.all_access`, dll) bisa jadi tidak memiliki atribut `status` secara eksplisit.
   - Jangan pernah mengasumsikan ketiadaan field `status` sebagai `'trial'` jika tanggal kadaluarsa (`expiry`) masih aktif di masa depan. Selama status bukan `'revoked'` atau `'expired'`, akses WAJIB dianggap aktif.
2. **Hierarki Penentuan Hak Akses Modul**:
   - Fungsi `UserModel.isAgentSubscriptionActive(agentId)` memeriksa:
     1. Apakah ada entitlement `all_access` atau `all_ai` yang aktif? Jika ya -> Buka seluruh modul.
     2. Apakah ada entitlement spesifik untuk modul tersebut yang aktif? Jika ya -> Buka modul.
     3. Jika tidak ada blokir eksplisit (`revoked`), periksa apakah akun memiliki paket langganan aktif tingkat akun (`isSubscriptionActive == true`) seperti `tholib_1m`, `tholib_6m`, `bahits_1y`, `voucher_access`, dsb. Jika ya -> Buka akses modul.

---

## 3. INTEGRASI GOOGLE NOTEBOOKLM & PROVISIONING SERVER

1. **Penyedia AI Sebenarnya**:
   - Modul AI OpenTurath beroperasi di atas Google NotebookLM privat yang telah dikurasi dengan naskah kitab primer turath.
   - Pengguna aplikasi mengakses notebook melalui `InAppWebView` di `agent_webview_screen.dart` dengan injeksi skrip `turatsMasterScript` untuk mengeliminasi header/branding eksternal.
2. **Mekanisme Sharing / Izin Pembaca**:
   - Agar akun Google pengguna tidak terbentur halaman "Anda memerlukan akses (403)", email Google pengguna wajib didaftarkan sebagai *viewer* di notebook terkait.
   - Pendaftaran dilakukan melalui Cloud Run subscription server (`openturath-subscription`) via endpoint `POST /webhook` atau Cloud Functions `redeemCode`.
   - Notifikasi pendaftaran langsung dikirimkan ke bot Telegram admin (`@openturath_bot`).

---

## 4. SISTEM REDEEM KODE VOUCHER

1. **Kode Master**: `PERDANA` (case-insensitive).
2. **Dokumen Firestore**: `redeem_codes/PERDANA`.
3. **Masa Berlaku**: 7 hari trial akses penuh (`all_access`) untuk seluruh ruang kajian AI.
4. **Alur Eksekusi**:
   - Pengguna mengklaim kode di menu Langganan -> Cloud Function `redeemCode` memvalidasi kuota -> mengaktifkan entitlement 7 hari -> memicu Cloud Run webhook untuk sharing NotebookLM -> mengirim notifikasi ke bot Telegram admin.

---

## 5. ATURAN INTEGRITAS KERJA

1. **Git Checkpoint Mandatori**:
   - Setiap perubahan sekecil apapun wajib dibuatkan commit: `git commit -m "<type>(<scope>): <pesan deskriptif>"`.
2. **Pengujian Regresi**:
   - Jalankan `flutter test` dan pastikan seluruh test suite (98 tes) lulus 100%.
3. **Build Rilis**:
   - Pastikan kompilasi APK rilis selesai 100% dan file binary disalin ke `/Users/apple/Downloads/ramadhan/app-release-latest.apk`.
