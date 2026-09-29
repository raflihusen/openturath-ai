# Audit dan perbaikan OpenTurath — 29 September 2026

## 1. Audit summary

Audit ini meninjau alur katalog → pencarian/filter → detail kitab, catatan → draft → simpan, penyimpanan dan sinkronisasi bookmark, serta jalur kode autentikasi, asisten NotebookLM, subscription, checkout DOKU, redeem, dan aturan Firestore. Prioritas implementasi adalah kehilangan perubahan pengguna dan pemulihan state; identitas editorial, warna, font, route, serta kontrak backend dipertahankan.

**Lingkup bukti:** inspeksi source, baseline otomatis sebelum perubahan, regresi yang mereproduksi masalah, pengujian seluruh suite, build web production, dan preview lokal yang menjalankan layar produk dengan katalog bundel. Preview tidak menginisialisasi Firebase, autentikasi, pembayaran, atau telemetry. Pemeriksaan ini tidak membuktikan seluruh perjalanan aplikasi native atau integrasi layanan production.

### Peta aplikasi yang diperiksa

| Area | Implementasi dan alur |
| --- | --- |
| Runtime | Flutter 3.38.4 / Dart 3.10.3; aplikasi `1.0.63+64`; dependencies dari `pubspec.yaml` / `pubspec.lock`. Backend TypeScript, Node 22.19, npm. |
| Entry dan navigasi | `lib/main.dart`, splash/auth, `MainShell` dengan Dashboard, SpecialistList, Bookmark, Profile; overlay asisten multi-tab. |
| UI | Token `lib/core/design/`, tema native/editorial, font lokal; masih terdapat pemakaian GoogleFonts. Lokal ID/EN/AR. |
| Katalog | Repository JSON lokal, katalog canonical dan editorial, pencarian/filter, halaman metadata/detail kitab. |
| Data pengguna | `BookmarkService`, store lokal dengan locked update, SharedPreferences untuk draft, sinkronisasi Firestore per pengguna. |
| Layanan | Firebase Core/Auth/Firestore/Functions, Google Sign-In, callable gateway, DOKU checkout, redeem/subscription, InAppWebView NotebookLM. |
| Verifikasi | `flutter analyze`, `flutter test`, `flutter build web`, `npm run build`, tes Node di `functions/test/`. |

Pengguna utama diasumsikan pembaca/peneliti turats berdasarkan model bidang, katalog Arab, sitasi, dan editor catatan. Tidak ditambahkan persona, metrik, atau konten pemasaran baru.

### Temuan prioritas dan keputusan implementasi

| Prioritas | Gejala / bukti | Akar masalah | Dampak dan koreksi | Status |
| --- | --- | --- | --- | --- |
| P1 | Edit terakhir dapat hilang bila editor ditutup sebelum debounce 1,5 detik. | Timer dibatalkan saat dispose tanpa flush. | Flush draft sebelum tombol Back dan system Back; gagal tulis mempertahankan editor. | Diperbaiki; tes dan pemeriksaan lokal. |
| P1 | Catatan yang sudah disimpan dapat muncul lagi sebagai draft. | Autosave yang masih tertunda menulis setelah draft dihapus. | Batalkan debounce, serialkan write, tunggu antrean selesai, baru hapus draft. | Diperbaiki; tes melampaui jendela debounce. |
| P1 | Draft memakai satu key lintas akun. | Key tidak memuat pemilik; pemilik save dapat berubah selama editor terbuka. | Key draft per UID, pemilik ditangkap saat membuka editor, pemeriksaan pemilik sebelum save; draft lama tanpa pemilik tetap di key legacy. | Diperbaiki pada jalur yang diuji; lihat batas perubahan akun di isu tersisa. |
| P1 | Tambah/edit/hapus lokal ketika fetch cloud berlangsung dapat hilang atau dipulihkan kembali. | Merge memakai snapshot lokal sebelum network await dan `replace` setelah fetch. | Merge dari data lokal terbaru di dalam satu locked update; tombstone dan urutan waktu tetap dipakai. | Tiga regresi konkurensi lulus. |
| P2 | Draft lama menimpa catatan baru; draft Arab dipulihkan LTR; pengosongan editor memulihkan isi lama. | Timestamp, arah teks, dan payload kosong tidak ditangani saat restore. | Bandingkan `savedAt` dengan catatan, deteksi RTL, simpan/restore pengosongan eksplisit. | Regresi lulus. |
| P2 | Pencarian tanpa harakat tidak menemukan judul berharakat. | Editorial memakai lowercase/contains mentah. | Pakai `ArabicUtils.matches` yang sudah dimiliki aplikasi. | Tes normalisasi dan pencarian data bundel lulus. |
| P2 | Reset pencarian canonical dapat dikalahkan oleh callback debounce lama. | Tombol clear/reset tidak membatalkan timer. | Batalkan timer, reset segera, kembalikan fokus; clear menjadi IconButton berlabel. | Regresi lulus. |
| P2 | Filter volume tidak mengungkap selected state standar; metadata Arab overflow pada teks 2× di layar sempit. | Filter custom InkWell dan teks metadata tanpa batas fleksibel. | ChoiceChip dengan target sentuh padded; Flexible pada volume/halaman; label clear lokal. | Tes keyboard/semantics dan 30 kombinasi layout lulus. |

Tidak dilakukan perombakan visual umum atau optimasi spekulatif. Tidak ada klaim peningkatan waktu render, throughput, atau penggunaan memori karena belum ada pengukuran aplikasi yang sebanding.

## 2. Implemented changes

- `lib/widgets/note_editor_sheet.dart`: pemulihan draft, flush saat keluar, antrean penulisan, isolasi pemilik, status kegagalan dalam live region, dan penguncian kontrol ketika save/close berlangsung. Tambahan optional dependency injection mendukung regresi akun tanpa Firebase production.
- `lib/services/bookmark_service.dart`: rekonsiliasi remote di locked update lokal terbaru, disertai seam testing untuk fetch cloud yang tertunda. Singleton dan API pemanggil yang ada tetap tersedia.
- `lib/screens/book_library_editorial_screen.dart`: normalisasi Arab, clear berlabel dengan fokus kembali, filter standar dan metadata yang dapat membungkus.
- `lib/screens/book_catalog_screen.dart`: clear/reset/Escape membatalkan debounce, serta clear search yang dapat diakses lewat kontrol standar.
- Empat file regresi baru: `note_editor_reliability_test.dart` (8), `bookmark_concurrent_sync_test.dart` (3), `editorial_catalog_reliability_test.dart` (32), `catalog_search_reset_test.dart` (1): total **44** pengujian.
- `tool/audit_preview.dart`: entrypoint QA terisolasi yang memakai layar produk dan data bundel, mendukung pilihan locale, lebar, tema, dan pembesaran teks melalui kontrol atau parameter URL. Widget-order traversal memperbaiki error fokus sebelum layout pada startup harness. Label QA terlihat pada capture.
- `test/agent_service_canonical_url_test.dart`: hanya unused import dibuang setelah analyzer menemukannya. Test dan pemetaan NotebookLM berasal dari pekerjaan lain yang masuk saat audit.
- `functions/lib/notebook_catalog.js.map`: artefak tracked yang diregenerasi oleh build TypeScript setelah perubahan pemetaan dari pekerjaan lain; source mapping tersebut dipertahankan.

Tidak ada dependency baru, perubahan rules/konfigurasi production, deploy, broadcast versi, pembayaran nyata, atau build APK rilis.

## 3. Verification

Semua command berikut dijalankan di `/Users/apple/Downloads/ramadhan/openturath_ai`, kecuali pemeriksaan Git yang menggunakan root repository `/Users/apple/Downloads/ramadhan`.

| Pemeriksaan | Baseline | Hasil akhir |
| --- | --- | --- |
| `flutter analyze --no-pub` | Exit 0, tidak ada issue. Percobaan awal terbatas oleh izin tulis `engine.stamp`, lalu berhasil dengan akses cache yang disetujui. | Exit 0, tidak ada issue pada source aplikasi dan tool QA final. |
| `flutter test --no-pub --reporter expanded` | Exit 0, **207** lulus. | Exit 0, **252** lulus: 207 baseline + 44 regresi audit + 1 test dari pekerjaan lain. |
| `npm run build` (direktori `functions`) | Exit 0, TypeScript berhasil. | Exit 0. |
| `AUDIT_SOURCE_ROOT=/Users/apple/Downloads/ramadhan/openturath_ai node --experimental-transform-types --test functions/test/*.test.ts` | Exit 0, **41** lulus. Percobaan dengan cwd/transform yang salah adalah masalah cara menjalankan test dan diperbaiki. | Exit 0, **41** lulus, 0 gagal. |
| `flutter build web --release --no-pub` | Exit 0, `Built build/web`; Wasm compatibility dry run berhasil. | Build JS production pada source aplikasi final: `flutter build web --release --no-pub --no-wasm-dry-run`, exit 0, `Built build/web`. Hanya probe Wasm opsional yang tidak diulang. |
| `dart format --output=none --set-exit-if-changed` | Tidak dipakai sebagai baseline. | File aplikasi/tes audit sudah diformat; koreksi format tool QA di-checkpoint terpisah. |
| `git diff --check c80cd2c HEAD -- <file-audit>` | — | Exit 0 pada file audit. Diff branch penuh memiliki satu trailing whitespace pada source NotebookLM dari commit pekerjaan lain; tidak dibersihkan secara diam-diam. |

### Reproduksi regresi

Sebelum fix, tes sinkronisasi gagal pada tambah, edit, dan hapus ketika cloud read ditahan. Tes katalog memperlihatkan kegagalan normalisasi/filter dan empat overflow pada locale Arab, lebar 360/390, teks 2×. Tes reset canonical menangkap callback stale setelah clear. Regresi editor menangkap draft yang muncul kembali, arah RTL yang salah, dan draft lebih lama yang menimpa catatan baru. Kesalahan helper/cleanup pada tes audit sendiri diperbaiki sebelum hasil akhir; tidak ada assertion yang dimatikan untuk meluluskan suite.

Tes layout editorial mencakup **360, 390, 768, 1024, 1440** logical pixels × **ID/EN/AR** × **light/dark**, dengan teks **2×**, dalam state berisi dan tanpa hasil. Itu adalah pemeriksaan render widget, bukan 30 screenshot perangkat nyata. Tes keyboard memfokuskan filter, mengaktifkan dengan Space, dan memeriksa selected semantics. Restore/focus serta sistem Back diperiksa lewat widget test. Draft failure feedback diimplementasikan berdasarkan pemeriksaan jalur error; kegagalan disk nyata tidak disimulasikan di perangkat.

### Pemeriksaan runtime dan gambar

Preview lokal menggunakan **1.173** entri katalog Hadis bundel. Pencarian `الزبير` menemukan 9 hasil; membuka detail `نسخة الزبير بن عدي` dan kembali mempertahankan hasil. Clear memulihkan 1.173 entri dan fokus input. Filter tampil sebagai kontrol dengan checked/selected state pada accessibility tree browser. Pada viewport desktop 1440 px, Space pada “Beberapa jilid” mengubah selected state dan hasil menjadi **119** kitab.

Pada browser, catatan berlabel **CONTOH QA** ditambah teks terakhir dan langsung ditutup dalam satu rangkaian input. Membuka kembali editor memulihkan tambahan terakhir dan status “Draf dipulihkan”. Setelah Simpan, editor baru kosong. Data contoh ini hanya berada pada storage origin localhost QA.

Pemeriksaan visual data aktual mencakup bingkai konten **390 px ID**, **360 px AR/dark/teks 2×** dengan scroll ke metadata panjang, serta viewport browser **768 px EN** dan **1440 px ID**. Pada bingkai 360 px, informasi volume/halaman membungkus tanpa overflow; halaman panjang tetap dapat di-scroll. Pemeriksaan viewport 1024 px ada pada widget matrix, bukan capture runtime tersendiri.

- [Sebelum — editorial, ID, 390 px](screenshots/catalog-before-390-id.jpg)
- [Sesudah — editorial, ID, 390 px](screenshots/catalog-after-390-id.jpg)
- [Sesudah — Arab, bingkai 360 px, teks 2×, dark](screenshots/catalog-after-360-ar-2x-dark.jpg)
- [Sesudah — viewport 768 px, English](screenshots/catalog-after-768-en.jpg)
- [Sesudah — viewport 1440 px, filter keyboard terpilih](screenshots/catalog-after-1440-id-keyboard-filter.jpg)
- [Draft contoh dipulihkan sesudah segera keluar](screenshots/note-draft-restored.jpg)

Capture dibuat dari layar produk di harness QA, bukan mock desain. Startup/reload awal memunculkan error Flutter pada reading-order focus sebelum render box memiliki layout. Harness memakai widget-order traversal karena kontrol QA memiliki urutan tetap; sesudah koreksi, startup dan navigasi katalog diperiksa pada origin baru dan console untuk origin itu menghasilkan **0 error/warning**. Assertion tidak dimatikan dan error tidak disaring dari aplikasi. Entrypoint production dengan Firebase tidak dijalankan melalui browser di sesi ini, sehingga bukti tersebut terbatas pada harness.

Bundle release QA terpisah berhasil dikompilasi dengan exit 0:

```sh
flutter build web --release --no-pub --no-wasm-dry-run --target tool/audit_preview.dart --output /private/tmp/openturath-qa-web-fixed
python3 -m http.server 8792 --bind 127.0.0.1 --directory /private/tmp/openturath-qa-web-fixed
```

Preview akhir: `http://127.0.0.1:8792/?locale=id&width=390`. Parameter yang diterima: `locale=id|en|ar`, `width=360|390|768|1024|1440`, `scale=1|2`, `dark=0|1`. Build ulang dan cache service worker lama sempat menampilkan bundle sebelumnya; pemeriksaan akhir memakai origin lokal baru. URL ini bekerja ketika server lokal masih berjalan; source entrypoint dan capture tersimpan di Git untuk reproduksi berikutnya.

Acuan yang diperiksa: [Flutter accessibility](https://docs.flutter.dev/ui/accessibility) dan [W3C WCAG 2.2 Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html). Perbaikan semantics, keyboard, fokus, dan reflow dibuktikan sesuai lingkup di atas. Belum ada audit screen reader native, seluruh kontras, reduced motion, seluruh dialog, atau seluruh layar; tidak ada klaim kepatuhan WCAG lengkap.

## 4. Remaining issues

| Prioritas | Status | Area dan tindak lanjut / batas bukti |
| --- | --- | --- |
| P1 | Risiko integrasi belum diverifikasi runtime | Login Google/NotebookLM di WebView: flag readiness dan keberhasilan token aplikasi tidak dengan sendirinya membuktikan cookie WebView tersedia. Jalur kode ditelusuri, tetapi login nyata, entitlement, dan provider notebook belum diuji memakai akun. Perlu pengujian native dengan sesi provider serta diagnosis cookie/readiness sebelum perubahan arsitektur. |
| P1 | Verifikasi layanan belum lengkap | Checkout DOKU, redeem, dan entitlement memiliki tes lokal yang lulus; tidak dilakukan transaksi, redeem voucher, atau perubahan Firestore production. Webhook/live request dan Firestore emulator rules belum dijalankan. |
| P2 | Risiko sinkronisasi di luar fix ini | Legacy migration, batch `saveAll`, global `_isSyncing`, dan perubahan akun saat operasi asynchronous berlangsung belum diuji selengkap fetch/merge. Fix locked merge tidak berarti seluruh konflik offline/cross-device atau semua race akun sudah teratasi. |
| P2 | Debt dokumentasi terkonfirmasi | README masih menjelaskan iPaymu dan contoh rules lama, sedangkan jalur pembayaran yang diperiksa memakai DOKU dan file `firestore.rules` aktual lebih ketat. Jangan menerapkan snippet README sebagai rules production tanpa review. |
| P2 | Peringatan build terkonfirmasi | CupertinoIcons dirujuk tanpa asset font yang ditemukan oleh tree shaker. Peringatan ada sebelum perubahan dan tetap ada; build web berhasil. Tampilan setiap ikon terkait belum dibuktikan di native. |
| P2 | Debt lokalisasi terkonfirmasi | Sebagian error redeem masih hardcoded Indonesia; locale switching seluruh state error belum dicakup runtime. |
| P2 | Risiko offline belum diverifikasi | GoogleFonts masih digunakan, termasuk splash. Keberadaan call terlihat di source; dampak runtime tanpa jaringan perlu diukur sebelum mengganti semua pemakaian. |
| P2 | Batas platform | Belum membangun APK/iOS/macOS, menjalankan app native lengkap, atau menguji pembaca layar native. Bukti build web dan widget tidak menggantikan verifikasi tersebut. |

Tidak ada keputusan pengguna yang diperlukan untuk perubahan lokal yang sudah selesai. Rilis, perubahan layanan production, dan perancangan ulang integrasi provider adalah pekerjaan lanjutan dengan ruang lingkup tersendiri.

## Git dan restore

Branch audit: `codex/audit-reliability-2026-09-29`. Baseline: `c80cd2c0d622b6473984bc1962815c05dbe3d425`. Setiap perubahan disimpan sebagai commit checkpoint sesuai `AGENTS.md`.

Commit **`e36680a`** masuk dari pekerjaan NotebookLM lain selama audit pada checkout bersama. Perubahan source mapping dan test tersebut dipertahankan. Karena itu restore seluruh branch ke baseline juga menghilangkan pekerjaan lain dari snapshot yang dibuka. Gunakan petunjuk [RESTORE.md](RESTORE.md) untuk membandingkan baseline tanpa mengubah checkout aktif atau untuk mengembalikan hanya empat source aplikasi audit.

File untracked milik pengguna yang sudah ada tidak di-add atau dihapus. Status tracked diperiksa kembali sesudah checkpoint final. Tidak dilakukan `reset --hard`, force push, push remote, atau perubahan repository production.
