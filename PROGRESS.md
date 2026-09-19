# OpenTurath AI — Progress & Context Tracker

> **Panduan Awet Konteks & Ringan Memori**:
> File ini adalah *Single Source of Truth* status proyek. Ketika sesi chat terasa panjang atau laptop mulai lambat, buat **Chat Baru (New Conversation)** lalu cukup instruksikan:
> **"Baca PROGRESS.md dan lanjutkan task berikutnya."**
> Agent akan langsung memahami 100% konteks proyek tanpa membebani RAM laptop.

---

## 1. Identitas & Visi Arsitektur Proyek
- **Nama Proyek**: OpenTurath AI (`openturath_ai`)
- **Platform**: Flutter Cross-Platform (Android APK, macOS, iOS)
- **Filosofi & Desain**: *The Quiet Islamic Scholar* — desain monokrom teduh, tipografi editorial, minim distraksi (tidak memakai kartu warna-warni/gradien norak), mengedepankan adab talaqqi dan riset turats ilmiah.
- **Katalog Turats**: 21 Agen Spesialis Turats terkanonisasi (Fikih Syafi'i, Ushul Fikih, Hadis, Tafsir, Balaghah, dll.) terbagi dalam era *Mutaqaddimin* dan *Muta'akhkhirin*.

---

## 2. Peta Komponen Utama (`openturath_ai/lib`)
1. **Core Design System**:
   - `core/design/ot_colors.dart`: Palet monokrom tenang (adaptif Light/Dark mode).
   - `core/design/ot_typography.dart`: Tipografi editorial dengan skala keterbacaan tinggi.
   - `core/design/ot_motion.dart`: Animasi micro-interaction halus dan subtil.
   - `core/legal_copy.dart`: Unifikasi copywriting adab kanonikal.
2. **Widgets & Navigasi**:
   - `widgets/corpus_kind_control.dart`: Tab navigasi datar tanpa kartu untuk beralih antara "Bidang ilmu" dan "Khazanah ulama".
   - `screens/book_catalog_screen.dart`: Eksplorasi katalog kitab dan biografi ulama.
3. **Services & Integrasi**:
   - `services/native_agent_launcher.dart`: Peluncur agen native turats.
   - `services/bookmark_service.dart`: Sinkronisasi marka rujukan kutipan kitab.
   - `services/device_service.dart` & `telemetry_service.dart`: Telemetri dan verifikasi lisensi perangkat.
   - Payment/Subscription: Alur checkout DOKU Direct & Midtrans dengan guard hak akses (Entitlement).

---

## 3. Hasil Pengujian & Standar Kualitas (Test Suite)
- Memiliki **32+ berkas pengujian unit & widget** di `openturath_ai/test/`.
- Pengujian utama meliputi:
  - `test/deep_test.dart`: Audit menyeluruh integritas UI, warna, dan token desain.
  - `test/design_system_test.dart`: Validasi kepatuhan monokrom.
  - `test/ui_copy_regression_test.dart` & `copywriting_test.dart`: Proteksi regresi teks adab.
  - `test/arabic_search_normalization_test.dart`: Normalisasi harakat dan huruf hijaiyah.
- **Target Standar**: Setiap perubahan WAJIB lulus `flutter analyze` dengan 0 issues.

---

## 4. Konfigurasi Sistem Ramah Memori (Anti-Hang Mac 8GB)
- **Gradle JVM Heap**: Dibatasi maksimal **2048 MB** (bukan 8192 MB) di `android/gradle.properties` dan `~/.gradle/gradle.properties`.
- **Idle Timeout**: Gradle daemon otomatis mati jika idle selama 60 detik (`idletimeout=60000`).
- **File Watchers & Indexing**: Antigravity IDE dikonfigurasi untuk tidak meng-index `.gradle`, `build/`, `.dart_tool/`, dan `.gemini/`.
- **Language Server**: Mode lightweight untuk Java extension; Flutter berjalan independen via Flutter CLI.

---

## 5. Changelog & Milestone Terakhir
- `20502cc` (2026-09-19): Pembatasan JVM Gradle ke 2GB dan idle timeout 60s untuk stabilitas laptop 8GB RAM.
- `ef185a4` (2026-09-19): Perbaruan tab navigasi datar pada `corpus_kind_control.dart`.
- `780e037` (2026-09-18): Penyederhanaan beranda menjadi ruang kajian terfokus.
- `9947497` (2026-09-18): Unifikasi navigasi dengan indikator editorial.
- `6f6e0ae` (2026-09-18): Standardisasi copywriting "The Quiet Islamic Scholar".

---

## 6. Protokol Menutup & Melanjutkan Sesi
1. **Sebelum Tutup Sesi / Ganti Chat**:
   - Pastikan kode sudah ter-commit (`git status` bersih).
   - Minta agent: *"Perbarui PROGRESS.md dengan ringkasan status hari ini"*.
2. **Saat Buka Chat Baru**:
   - Cukup instruksikan: *"Baca PROGRESS.md dan lanjutkan [nama fitur/task]"*.
EOF
