# Strategi privasi dan login ganda

Tanggal: 29 Oktober 2026. Dasar: pembacaan kode `openturath_ai/lib` dan `docs/single-login-audit-2026-09-30.md`. Belum ada klaim yang diuji di perangkat pengguna. Setiap kalimat yang akan dipublikasikan harus diverifikasi dulu (lihat bagian 5).

## 1. Mengapa pengguna login dua kali

Ada dua layanan berbeda, bukan satu layanan yang meminta dua kali:

1. **Masuk OpenTurath**: akun Google dipakai Firebase untuk tahu siapa Anda dan paket apa yang aktif.
2. **Masuk Google di dalam aplikasi**: mesin jawaban adalah NotebookLM milik Google. Ia membaca sesi Google di jendela web di dalam aplikasi, dan jendela itu tidak berbagi sesi dengan login pertama.

Kode: `login_screen.dart` memeriksa sesi tersimpan; bila tidak ada, ia membuka `GoogleSessionAuthScreen`. Itulah login kedua. Menghilangkannya sepenuhnya tidak bisa dijanjikan selama mesinnya NotebookLM (alasan teknis lengkap ada di `single-login-audit-2026-09-30.md`).

Yang bisa diperbaiki: **menjelaskan sebelum login kedua muncul**, supaya tidak terlihat seperti jebakan.

## 2. Fakta yang terbukti dari kode

| Hal | Temuan |
| --- | --- |
| Password Google | Diketik di halaman Google itu sendiri. `GoogleSessionAuthScreen` tidak membaca kolom password. Ia hanya membaca alamat email akun yang aktif dari halaman, untuk mencocokkan dengan akun OpenTurath. |
| Log galat | `TelemetryService` menyamarkan password, token, voucher, dan email sebelum dikirim. |
| Hapus akun | Ada di Profil. Menghapus akun Firebase, menutup sesi AI, membersihkan sesi Google lokal dan preferensi per-pengguna, lalu memutus Google Sign-In. |
| Catatan pengguna | Tersimpan di perangkat. |
| Kebijakan privasi | Sudah ada (id/en/ar) dan tertaut di layar login. Menyatakan tidak menjual data, tidak ada iklan pihak ketiga, percakapan tidak dipakai melatih model publik. |

## 3. Kelemahan nyata yang ditemukan

**Brankas sesi Google di perangkat hanya disamarkan, tidak dienkripsi.** `persistent_google_session.dart` menyimpan cookie sesi Google (SID, PSID, dan sejenisnya) di `SharedPreferences` dengan "Base64 obfuscated". Siapa pun yang memegang berkas aplikasi yang tidak terenkripsi (cadangan perangkat, perangkat ber-root, laptop yang diakses orang lain) bisa membaca sesi Google pengguna. Tidak ditemukan kode yang mengirim cookie itu ke server, jadi ini risiko perangkat, bukan kebocoran ke OpenTurath. Tetapi untuk pengguna yang sedang cemas, ini adalah titik yang paling merugikan bila ditemukan orang lain.

Perbaikan yang disarankan: pindahkan ke Keychain (macOS/iOS) dan Keystore (Android) melalui `flutter_secure_storage` (belum ada di `pubspec.yaml`). Menyentuh jalur sesi Google, jadi harus diuji bersama aturan AGENTS.md pasal 8 (tidak boleh mengubah token aktif di WebKit) dan butuh persetujuan sebelum dikerjakan.

## 4. Strategi dalam urutan dampak

1. **Layar penjelasan sebelum login kedua** (cepat, tanpa risiko). Isi: "OpenTurath memakai NotebookLM Google. Anda masuk ke Google di jendela resmi Google; OpenTurath tidak melihat password Anda." Satu tombol, satu tautan ke kebijakan.
2. **Slide privasi di pengenalan** (cepat). Lima kalimat: apa yang disimpan, apa yang tidak, siapa yang memproses percakapan (Google), catatan hanya di perangkat, dan cara hapus akun.
3. **Enkripsi brankas sesi** (bagian 3). Dampak paling besar pada keamanan sebenarnya.
4. **Hapus akun dan hapus data terlihat jelas** di Profil, dengan teks yang menyebut apa yang dihapus. Mekanisme sudah ada; yang kurang hanyalah penjelasannya.
5. **Halaman privasi bahasa awam di situs** (`openturath.id/privasi`), memakai kalimat yang sama dengan slide. Satu sumber, tiga bahasa.
6. **Pesan kepada yang sudah menghapus akun**: akui kekhawatiran, jelaskan dua login, tawarkan kembali tanpa mendesak.

## 5. Yang harus diverifikasi sebelum dipublikasikan

- Apa saja yang ditulis ke Firestore pada dokumen pengguna (`auth_service.dart` sekitar baris 278 dan 290). Daftar kolom harus cocok dengan bagian "Data yang Diproses" di kebijakan.
- Apakah ada alat analitik atau iklan di `pubspec.yaml` yang tidak tersebut di kebijakan.
- Berapa lama data transaksi disimpan, dan apa yang tersisa setelah akun dihapus (kewajiban pajak).
- Kalimat "OpenTurath tidak melihat password" hanya benar bila diuji pada build rilis; periksa bahwa tidak ada skrip yang disuntikkan ke halaman login Google.
- Jangan menulis "aman 100%" atau jaminan serupa. Tulis apa yang dilakukan dan apa yang tidak.
