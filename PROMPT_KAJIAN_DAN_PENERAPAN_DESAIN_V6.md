# MASTER PROMPT: KAJIAN KOMPREHENSIF WEBSITE V6 & PENERAPAN KE UI FLUTTER OPENTURATH AI

Dokumen ini berisi instruksi terstruktur dan menyeluruh bagi AI untuk mengkaji desain website versi 6 (`/Users/apple/Downloads/openturath-website 6`) dan menerapkannya secara komprehensif ke dalam antarmuka aplikasi Flutter (`openturath_ai`).

---

## SALIN DAN BERIKAN PROMPT DI BAWAH INI KEPADA AI:

```markdown
Anda adalah Senior Flutter UI/UX Architect dan Specialist Tipografi Klasik. Tugas Anda adalah mengkaji secara mendalam desain website OpenTurath Versi 6 yang berada di `/Users/apple/Downloads/openturath-website 6` (server lokal berjalan di `http://localhost:4174`), kemudian menerapkannya secara komprehensif, presisi, dan elegan ke dalam aplikasi Flutter di `/Users/apple/Downloads/ramadhan/openturath_ai`.

================================================================================
BATASAN & ATURAN MUTLAK (CRITICAL BOUNDARIES & WORKSPACE RULES):
================================================================================
1. ISOLASI UI NATIVE (STRICT):
   - Seluruh perubahan desain dan tipografi HANYA diterapkan pada komponen UI Flutter native (layar dashboard, kartu spesialis, layar pustaka/marja', bookmark, bottom sheet sitasi, dan tema sistem).
   - DILARANG KERAS memodifikasi atau menyentuh berkas WebView (`lib/widgets/agent_multi_tab_room.dart` dan `lib/core/notebook_ui_script.dart`). WebView harus tetap utuh 100%.

2. AUTOMATIC CHECKPOINT PROTOCOL (RULE 1):
   - Setiap modifikasi sekecil apapun WAJIB langsung dibuatkan Git commit secara otomatis tanpa menunggu instruksi tambahan:
     git add <files> && git commit -m "<type>(<scope>): <pesan detail perubahan>"
   - Buat Git tag titik awal sebelum perubahan dimulai: `git tag pre-v6-redesign-v2` agar aman untuk di-rollback kapan saja.

3. INTEGRITAS BUILD & RELEASE (RULE 2):
   - Kompilasi APK rilis (`flutter build apk --release`) harus memverifikasi bahwa Gradle selesai 100% dan file binary disalin ke `/Users/apple/Downloads/ramadhan/app-release-latest.apk` dengan timestamp baru yang valid.

4. PEMISAHAN BUILD LOKAL & BROADCAST RILIS (RULE 3):
   - Kompilasi APK hanya bersifat lokal. DILARANG mengunggah APK ke CDN atau menyiarkan versi baru ke Firestore (`app_config/version`) tanpa instruksi eksplisit.

5. KEAMANAN ASET WEBSITE & SEO:
   - DILARANG menghapus atau merusak berkas publik web di `openturath_ai/public/` (seperti `sitemap.xml`, `robots.txt`, dan berkas verifikasi Google Search Console `google4906b0efe6a8c108.html`).

================================================================================
FASE 1: KAJIAN MENDALAM WEBSITE V6 (/Users/apple/Downloads/openturath-website 6)
================================================================================
Lakukan audit menyeluruh terhadap kode sumber website V6 (komponen Astro/React/Tailwind/CSS):

1. Tipografi & Karakter Font:
   - Font Arab: Teliti penggunaan font "Scheherazade New" (SIL Naskh). Catat varian bobotnya (Regular 400 & Bold 700) serta line-height khusus untuk teks berharakat (`height: 1.85 - 1.95`) agar diakritik fathah, kasrah, dan shaddah tidak terpotong.
   - Font Latin Serif: "Newsreader" (Regular & SemiBold) untuk judul ilmiah, nama kitab, dan angka monumental.
   - Font Latin Sans: "Outfit" (Regular, SemiBold, Bold) untuk label mikro, status, metrik korpus, dan keterangan teknis.
   - Ekstraksi Font: Ambil file font WOFF2 dari website, konversi menjadi TTF standar Flutter, simpan di `openturath_ai/assets/fonts/`, dan daftarkan di `pubspec.yaml`.

2. Arsitektur Bento Card V6:
   - Identifikasi struktur kartu:
     * Nomor seri monospaced di pojok kiri atas (`01`, `02`, dst.).
     * Badge status ketersediaan minimalis (`TERSEDIA`).
     * Aksen kaligrafi Arab di pojok kanan atas (`Scheherazade New`, contoh: `الفقه`, `الحديث`, `التفسير`).
     * Judul keilmuan menggunakan *Newsreader Serif*.
     * Deskripsi ringkas dalam *Outfit Sans*.
     * Angka figur korpus monumental (misal: `1.240 Kitab · 210 Jt Kata`).
     * Varian kartu unggulan (Featured Inverted `#111111` untuk Hadits).
     * Varian kartu daulat (Sovereign Card dengan double-border ring dan aksen emas terukur untuk Tahawwulat).

3. Bagian Skala Korpus Monumental (Grand Corpus Scale):
   - Angka utama: `5.370 Kitab Klasik`.
   - Watermark kaligrafi latar belakang: `كتب` berukuran besar dengan opasitas sangat halus.
   - Bento baris metrik sekunder: `1,1 M Kata`, `4,1 Jt Halaman`, `11.901+ Jilid`, `20 Disiplin`.
   - Catatan validasi: `2.876 partisi korpus terverifikasi · Abad 1 H – 14 H`.

4. Sistem Gerak & Fisika Animasi:
   - Apple fluid spring physics: Kurva `Cubic(0.16, 1.0, 0.3, 1.0)`, durasi responsif `140ms`, skala tekan `0.985`.
   - Staggered Entrance: Efek transisi masuk kartu secara bertahap (`translateY: 22px -> 0px`, `opacity: 0.0 -> 1.0`, delay bertingkat `min(index, 6) * 60ms`).

================================================================================
FASE 2: PENERAPAN SISTEMATIS PADA FLUTTER APP (openturath_ai)
================================================================================
Terapkan temuan kajian di atas secara berurutan:

Langkah 1: Tipografi & Global Font Fallback
- Tambahkan TTF fonts (`Scheherazade New`, `Newsreader`, `Outfit`) ke `pubspec.yaml`.
- Perbarui `lib/core/scholarly_fonts.dart`, `lib/core/design/ot_typography.dart`, dan `lib/core/theme.dart`.
- Pasang `fontFamilyFallback: const ['Scheherazade New']` secara global sehingga teks campuran Latin-Arab otomatis merender teks Arab dengan Scheherazade New tanpa perlu penanganan manual di setiap widget.

Langkah 2: Sistem Interaksi & Motion
- Perbarui `lib/widgets/apple_interactive_wrapper.dart` dengan kurva spring `Cubic(0.16, 1.0, 0.3, 1.0)` dan skala tekan `0.985`.
- Buat widget `lib/widgets/staggered_entrance.dart` untuk transisi masuk kartu yang mulus.

Langkah 3: Kartu Spesialis Bento & Sovereign Tahawwulat
- Rombak `lib/widgets/specialist_card.dart` mengadopsi arsitektur Bento Card V6 lengkap (nomor seri, aksen Arab Scheherazade New, judul Newsreader, metrik korpus Outfit, varian Inverted Hadits, dan varian Sovereign).
- Rombak `lib/widgets/tahawwulat_flagship_card.dart` dengan radius 24dp, inset double-border ring, dan watermark `تحولات`.

Langkah 4: Layar Beranda (Dashboard)
- Di `lib/screens/dashboard_screen.dart`:
  * Tambahkan watermark kaligrafi `تراث` pada kartu Hero.
  * Tambahkan bento Skala Korpus Monumental (`5.370 Kitab`, watermark `كتب`, 4 metrik sekunder).
  * Perbarui grid disiplin terpilih dengan aksen kaligrafi Arab.

Langkah 5: Layar Bacaan & Sitasi
- Di `lib/widgets/evidence_bottom_sheet.dart`: Terapkan `Scheherazade New` Bold 700 dengan `height: 1.9` untuk kutipan nash Arab.
- Di `lib/screens/bookmark_screen.dart` dan `lib/screens/book_library_editorial_screen.dart`: Terapkan tipografi Scheherazade New dan Newsreader.

================================================================================
FASE 3: VALIDASI & VERIFIKASI
================================================================================
1. Jalankan unit test: `flutter test` dan pastikan seluruh test (166+ test) lulus 100%.
2. Lakukan kompilasi rilis: `flutter build apk --release`.
3. Verifikasi file rilis lokal: Salin ke `/Users/apple/Downloads/ramadhan/app-release-latest.apk` dan periksa timestamp-nya.
4. Perbarui file `walkthrough.md` dengan dokumentasi lengkap perubahan dan hasil pengujian.
```
