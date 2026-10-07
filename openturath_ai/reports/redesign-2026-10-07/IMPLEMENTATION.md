# OpenTurath — implementasi redesign 7 Oktober 2026

Desain telah diterapkan pada kode Flutter lokal. Arah visual: permukaan tonal netral, sudut lembut, navigasi jelas, dan tipografi ilmiah yang tetap mempertahankan identitas OpenTurath.

## Hasil yang dapat ditinjau

- [Galeri 56 render aplikasi](index.html)
- [Beranda dengan navigasi desktop](screens/shell_desktop.png)
- [Beranda ponsel](screens/shell_phone.png)
- [Jawaban bilingual](screens/chat_mixed.png)
- [Langganan](screens/subscription_wide.png)
- [Pengaturan dengan pembesaran teks 200%](screens/profile_large_text.png)
- [Daftar checkpoint](CHECKPOINTS.txt)

Gambar merupakan render widget dari implementasi aplikasi, dengan akun/jawaban contoh. Jawaban contoh diberi keterangan sebagai contoh tampilan. Ini tidak membuktikan validitas kutipan, sesi Google terautentikasi, atau transaksi live.

## Perubahan utama

| Bagian | Perubahan yang diterapkan |
|---|---|
| Fondasi | Latar #F6F6F6 / #151515; surface #FFFFFF / #202020; tonal #EDEDED / #2B2B2B; garis luar kartu dikurangi |
| Geometri | Input/dialog 28; kartu 24; hero/sheet 32; pil 999; elemen kecil 8 |
| Huruf | Outfit untuk antarmuka; Newsreader untuk koleksi/kitab; font Arab tetap dibundel secara lokal |
| Beranda | Sapaan dan tanggal pendukung, pencarian sebelum hero, bidang tiga kolom di desktop dan dua kolom di ponsel; satu kolom ketika teks diperbesar |
| Navigasi | Rail berlabel mulai 600 px; sidebar diperluas mulai 1100 px; navigasi bawah berlabel untuk ponsel |
| Asisten | Tugas akademik ditampilkan; aksi Buka asisten dan Lihat rujukan dibuat eksplisit; koleksi utama memakai daftar asisten dalam panel tonal |
| Katalog | Langsung membuka daftar; loading/error/retry berada pada satu rute; daftar mengikuti tinggi isi dan tidak memotong judul dua baris |
| Detail kitab | Label dan nilai sebaris di desktop, bertumpuk pada layar kecil; catatan edisi terpisah dari muhaqqiq; keterangan verifikasi berada dekat metadata |
| Pengaturan | Kartu ATM dihapus; identitas, status akses, masa akses, dan tindakan ditampilkan ringkas; pilihan tema mendukung keyboard dan label selected; tersusun vertikal saat teks besar |
| Langganan | Durasi memakai pilihan ringkas; satu harga utama, ekuivalen bulanan untuk periode panjang, dan total pada tombol Bayar; nilai harga/backend tetap dipertahankan |
| Chat dan catatan baca | Renderer bersama mempertahankan Markdown, paragraf bilingual, blok kode, pemilihan teks, dan sumber; isi salin/simpan tetap mentah |
| Composer | Border ganda dihapus, hint berkontras cukup, tombol kirim native berlabel aksesibel, dan indikator disediakan dalam tiga bahasa |
| Streaming | Pembaruan jawaban tidak menarik pembaca ke bawah ketika sedang membaca pesan sebelumnya |
| WebView | Arah paragraf mengikuti huruf awal; wrapper div tidak dipaksa RTL karena kutipan Arab; menu jawaban tetap tersedia dan scrollbar desktop kembali terlihat |

## Penutupan temuan audit

| ID audit | Status lokal dan batasnya |
|---|---|
| D01 | Mekanisme salah arah WebView diperbaiki dan diuji dengan fixture paragraf campuran. Perlu konfirmasi visual pada NotebookLM terautentikasi yang nyata. |
| D02 | Renderer native diganti dengan ScholarlyAnswer; Markdown tidak lagi dibuang ketika ada Arab. Blok kode, harakat utuh, dan intro Arab diikuti paragraf Latin diuji. |
| D03 | Penilaian edisi tidak disajikan sebagai nama muhaqqiq. Nama yang tidak tercatat dinyatakan; raw catalog tetap tersedia. Bookmark tidak otomatis diberi status verified. |
| D04–D05 | Nilai tahun dan jumlah halaman dipertahankan; kondisi mencurigakan diberi penanda review. Tahun/angka pengganti belum ditetapkan tanpa halaman judul/kolofon. |
| D06 | Harness membaca skrip aktif. 56 tes Node lulus, termasuk host guard, font scale, dan paragraf campuran. |
| D07 | Exception render dan pemicu dialog yang tidak ditemukan sekarang menggagalkan tes. 56 gambar disimpan; perbandingan golden otomatis belum diterapkan. |
| D08 | JSON rusak dan aset metadata/kitab yang hilang menghasilkan kegagalan; koleksi kosong tetap berbeda; rute menyediakan coba lagi. Modul tidak dikenal tidak meminjam katalog Syafi‘i. |
| D09 | Email dalam diagnostic text dan context disamarkan. Nilai extra melewati sanitizer yang sama. Tes email/token/password/cookie tetap lulus. Ini bukan sertifikasi semua kemungkinan PII. |
| D10 | Rules lokal menolak log unauthenticated dan klien melewati remote reporting sebelum login. Rules tidak dideploy. App Check, rate limit server, retention, dan ukuran payload nested masih memerlukan audit backend. |
| D11 | Scrollbar dan menu jawaban dipulihkan; arah paragraf dibatasi. Adapter DOM pihak ketiga masih perlu pengujian live dan penanganan perubahan DOM. |
| D12 | Galat umum dan Firebase checkout diteruskan ke telemetry; pemeriksaan amount/pricingRevision sebelum membuka checkout dipertahankan. Transaksi sandbox belum dilakukan. |
| D13 | Fallback versi palsu dihapus; render memock versi 1.0.63+64 sesuai pubspec. Versi tidak dibroadcast ke pengguna. |
| D14 | verificationNotice kini tampil dekat detail edisi. |

## Verifikasi kode final

| Pemeriksaan | Hasil |
|---|---|
| flutter analyze --no-pub | Exit 0; No issues found |
| flutter test --no-pub --reporter expanded | Exit 0; 354 lulus, 1 dilewati |
| Node backend/WebView tests | Exit 0; 56 lulus |
| Render visual opt-in | Exit 0; 56 PNG; tidak ada framework exception |
| git diff --check | Exit 0 |
| Build macOS | Exit 0; universal x86_64/arm64; 130.0 MB menurut Flutter |

Render mencakup desktop, ponsel, terang/gelap, bahasa Indonesia/Arab, dialog, shell navigasi, chat campuran, dan pembesaran teks pengaturan 200%. Saya meninjau visual sampel beranda, shell, chat, katalog/detail, langganan, dan pengaturan. Tes layout katalog juga memeriksa lebar 360–1440 px, tiga bahasa, dan teks 2x.

Log update checker pada widget test menyebut Firebase belum diinisialisasi: fixture ini sengaja tidak melakukan request update produksi. Ini tidak dihitung sebagai bukti kegagalan update live maupun bukti update live berhasil.

Log final disimpan di `verification/`; whitespace akhir baris dinormalisasi tanpa mengubah hasil pemeriksaan. Galeri tidak merender ulang HTML prototype dari audit sebelumnya.

## Build dan distribusi

Artefak: `/Users/apple/Downloads/ramadhan/openturath_ai/build/macos/Build/Products/Release/OpenTurath AI.app`.

Versi: 1.0.63+64; universal Intel/Apple Silicon; 129,994,536 byte berkas bundle. Build exit 0. Pemeriksaan signature deep/strict exit 0; signature ad hoc, TeamIdentifier tidak ditetapkan. Notarization dan peluncuran interaktif binary ini belum diuji. Peringatan dependency Pods tentang deployment target dan script phase tercatat di log build.

SHA-256 manifest isi bundle: `1748081e44239749e23200f3505c784f9839ec50755f482458c812eeedc3555f`. Ini hash manifest path+isi, bukan hash ZIP. Rincian berkas ada di `build-manifest.json`. Timestamp binary Dart hasil kompilasi: 2026-10-07T04:48:46.553666+00:00. Timestamp direktori bundle dapat berasal dari pembuatan sebelumnya dan bukan patokan usia binary.

Tidak ada deployment, push, unggahan CDN, broadcast Firestore, atau APK publik pada pekerjaan ini. Firestore rules yang berubah tetap lokal. Pembayaran, Google/NotebookLM live, screen reader pada perangkat asli, performa perangkat, dan notarization tidak dinyatakan lolos oleh render widget.

## Checkpoint dan pemulihan

Branch: `codex/minimalist-redesign-2026-10-07`.
Recovery point sebelum redesign: `7ad4243`.
Kode terakhir: `3c4d7ba`; checkpoint dokumentasi berikutnya tidak mengubah perilaku aplikasi.

Setiap perubahan dicatat dengan commit khusus. Perubahan lama yang tidak terkait di luar app (44 tracked deletions pada baseline) tidak dimasukkan dalam checkpoint redesign.

Untuk membatalkan satu perubahan, gunakan `git revert <hash-checkpoint>` dari daftar checkpoint. Pembatalan seluruh rangkaian dapat dilakukan dengan `git revert --no-edit 7ad4243..HEAD` pada branch ini setelah meninjau bahwa HEAD masih rangkaian redesign. Perintah ini mencatat pembatalan dalam sejarah Git; pekerjaan lama di luar cakupan harus tetap dipertahankan.

Pedoman desain yang disinkronkan: `DESIGN.md` dan `docs/design-system.json`. Proposal bertanggal 30 September tetap berstatus arsip proposal.
