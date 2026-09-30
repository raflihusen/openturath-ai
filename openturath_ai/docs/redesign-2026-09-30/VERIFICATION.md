# Verifikasi tahap desain dan autentikasi

Tanggal: 30 September 2026. Semua exit code di bawah diperoleh dari proses yang sudah selesai, bukan dari proses yang masih berjalan.

| Pemeriksaan | Hasil |
| --- | --- |
| Baseline `8286c10`: `flutter analyze --no-pub` | Exit 0; `No issues found!` |
| Baseline `8286c10`: `flutter test --no-pub --reporter expanded` | Exit 0; 252 tes lulus |
| Suite setelah perbaikan login/form Google dan commit menu pekerjaan lain `aa6f23b` | Exit 0; 252 tes lulus, 3 menit 52 detik |
| Setelah perubahan origin login: `flutter test --no-pub test/desktop_transport_test.dart --reporter expanded` | Exit 0; 8 tes lulus |
| Analisis setelah perubahan origin login: `flutter analyze --no-pub` | Exit 0; `No issues found!`, 44,3 detik |
| Build final: `flutter build macos --release --no-pub` | Exit 0; `Built build/macos/Build/Products/Release/OpenTurath AI.app (135.0MB)` |
| `node --check docs/redesign-2026-09-30/prototype/prototype.js` | Exit 0 |
| `git diff --check` | Exit 0 |
| Katalog pratinjau vs katalog asli | SHA-256 identik; 87 record |
| GET hosting `desktop-auth.html` pada `web.app` dan `firebaseapp.com` | HTTP 200; penanda `openturath-desktop-auth-v3` |

Delapan tes transport adalah bagian dari suite yang sama, bukan tambahan sehingga totalnya menjadi 260. Setelah domain login diubah, bagian transport dijalankan ulang secara terarah. Analisis dan build final mencakup perubahan domain tersebut.

Artefak macOS final:

```text
/Users/apple/Downloads/ramadhan/openturath_ai/build/macos/Build/Products/Release/OpenTurath AI.app
```

Timestamp executable setelah build final: `2026-09-30 05:00:05` pada waktu lokal workspace. Tidak ada APK yang dibuat pada tahap ini. Tidak ada upload, broadcast versi, atau perubahan konfigurasi Google/Firebase pada server dari pekerjaan ini.

Build berhasil dengan warning CocoaPods yang sudah muncul pada build sebelumnya: deployment target beberapa dependensi lama, script phase tanpa daftar output, serta duplicate library pada sebagian target. Hasil ini bukan bukti signing/notarization untuk distribusi eksternal.

## Pemeriksaan visual

Pratinjau dijalankan melalui HTTP loopback. Pemeriksaan memakai interaksi browser dan screenshot pada viewport desktop normal, ponsel 390 × 844, ponsel kecil 360 × 800, dan tablet 768 × 1024.

- Navigasi ruang kajian, pustaka, area NotebookLM konseptual, catatan, dan akun.
- Pencarian Arab dan keadaan tanpa hasil.
- Metadata Arab, teks panjang membungkus pada ponsel, dan angka jilid/halaman berarah Latin.
- Draf setelah pindah layar dan muat ulang; catatan tersimpan dibuka kembali dari daftar.
- Tampilan terang/gelap dan font Latin dengan fallback Arab pada input.
- Penutupan dialog melalui Escape; skip link mempertahankan route dan memindahkan fokus ke isi layar.

Screenshot desktop metadata `02` dan area NotebookLM `03` diambil sebelum penyempurnaan tipografi/arah angka pada pratinjau. Bukti setelah koreksi ada pada metadata ponsel `06`, catatan `07`, dan layout tablet `09`. Pembaruan screenshot desktop terakhir tidak dapat dilakukan setelah Mac terkunci; tidak ada gambar yang direkayasa untuk menggantinya.

Permintaan membuka pratinjau di panel Codex menghasilkan status `queued`. Link lokal dapat digunakan setelah aplikasi/perangkat tersedia kembali. Sambungan browser berhenti saat Mac terkunci; tidak ada percobaan membuka kunci atau melewati perlindungan perangkat.

## Yang belum dibuktikan

Pengujian tidak memasukkan password, kode 2FA, passkey, cookie, atau kredensial Google pengguna. Belum ada bukti pada paket final bahwa satu autentikasi Google membuka Firebase dan percakapan NotebookLM tanpa login ulang. Ruang NotebookLM produksi masih memakai WebView. Pilihan wadah browser belum dijawab pada saat tahap ini ditutup.

Screenshot yang disimpan memperlihatkan usulan HTML, bukan aplikasi Flutter produksi yang telah dirombak. Katalog asli dan interaksi lokal tidak membuat status login, ACL notebook, atau jawaban NotebookLM menjadi nyata.

Semua perubahan pekerjaan ini di-checkpoint. Commit menu `aa6f23b` dari pekerjaan lain tetap dipertahankan. Titik pemulihan dan cara membandingkan snapshot tersedia pada [RESTORE.md](RESTORE.md).
