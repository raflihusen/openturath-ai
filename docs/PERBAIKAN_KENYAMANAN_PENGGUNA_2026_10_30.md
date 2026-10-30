# Perbaikan kenyamanan pengguna — kelanjutan audit 30 Oktober 2026

Seluruh U01–U15 dari [audit awal](/Users/apple/Downloads/ramadhan/docs/AUDIT_KENYAMANAN_PENGGUNA_2026_10_30.md) sudah memiliki perbaikan kode dan regresi lokal. Pemeriksaan silang juga menemukan dan memperbaiki benturan kredensial Firebase yang terlambat serta label menu ruang AI yang meluber. Ini hasil verifikasi lokal, bukan pernyataan bahwa aplikasi pelanggan sudah diperbarui atau seluruh perilaku Google telah diuji di perangkat.

Snapshot kode akhir: `ee900628`. Versi lokal tetap `1.0.87+88`; nomor versi publik tidak disiarkan.

## Perubahan yang diselesaikan

| Temuan | Perilaku setelah perbaikan |
| --- | --- |
| U01 — trial memendekkan proyeksi paket aktif | Trial tetap sesuai durasi kodenya; akses berbayar/voucher yang lebih panjang dipertahankan. Profil dan entitlement VIP permanen tidak diturunkan. Modul lain tidak diubah. |
| U02 — profil cache dianggap sebagai login | Cache hanya mengikuti UID Firebase yang masih terautentikasi. Dashboard menampilkan pemulihan sesi jika akun terputus dan menolak callback pembukaan AI dari identitas lama. |
| U03 — pemulihan/login menggantung | Pemulihan dibatasi total 15 detik; pertukaran token dan kredensial juga memiliki deadline. Respons lama tidak boleh menerbitkan profil atau metadata setelah login/logout yang lebih baru. |
| U04 — penghapusan akun tanpa sesi dilaporkan berhasil | Operasi tanpa akun Firebase yang sah mengembalikan `requires-recent-login`; UI tidak melanjutkan ke pesan sukses. |
| U05 — coba lagi saat inisialisasi terus sibuk | Retry memiliki deadline dan mengembalikan tombol melalui `finally`; completion setelah layar ditutup tidak mengganti aplikasi. |
| U06 — pemeriksaan pembayaran gagal tanpa penjelasan | Kesalahan pemeriksaan dibedakan dari pembayaran pending dan status akhir. Respons backend lama yang menyamarkan kesalahan sebagai pending juga dikenali. |
| U07 — akses siap setelah timer tidak memperbarui UI | Hasil asinkron memperbarui state sesudah pemeriksaan dan hanya saat widget masih terpasang. |
| U08 — harga lama terus ditolak | Harga disegarkan dari server atau kutipan callable yang tervalidasi. Backend lama dikenali melalui kode/pesan yang tepat. Kegagalan refresh ditampilkan jujur; pengguna tetap harus menekan bayar lagi setelah meninjau harga. |
| U09 — koneksi Google dibatalkan tetapi AI dimuat ulang | Hanya hasil `true` yang melanjutkan pemulihan ruang AI. Hasil `false`/`null` mempertahankan keadaan pemulihan. |
| U10 — salinan cepat tertelan atau sukses palsu | Jawaban berbeda tetap disalin; permintaan clipboard berurutan. Duplikasi identik memakai hasil yang sama. Label sukses mengikuti konfirmasi clipboard. |
| U11 — riwayat dinyatakan terhapus tanpa bukti | Flutter menunggu hasil JavaScript. Sukses memerlukan pemberitahuan keberhasilan provider yang baru dan obrolan kosong stabil; tanpa konfirmasi hasil dinyatakan belum terverifikasi. Tidak menghapus DOM pesan untuk memalsukan keberhasilan. |
| U12 — ekspor membuang giliran dengan teks berulang | Duplikasi pembungkus ditentukan melalui struktur elemen. Pertanyaan/jawaban identik pada giliran berbeda tetap diekspor. |
| U13 — catatan yang diurungkan hilang setelah sinkronisasi | Undo merupakan perubahan baru yang lebih muda daripada tombstone yang diketahui, menghapus status penghapusan secara eksplisit, dan terikat akun saat tindakan dilakukan. |
| U14 — AI yang belum diluncurkan muncul sebagai aktif | Daftar awal dan fallback memakai pembatas peluncuran yang sama. Hanafi tetap belum tersedia saat katalog tertunda maupun timeout. |
| U15 — unduhan tampak macet pada 0% | Total ukuran yang belum diketahui memakai indikator bergerak tanpa persentase; ukuran yang diketahui tetap memakai progres terukur. Paket tetap diverifikasi sebelum siap dipasang. |

## Perlindungan login tambahan dari pemeriksaan silang

[AuthService](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart) kini mengurutkan mutasi Firebase. Permintaan kredensial A yang belum selesai tetap menahan antrean meskipun UI sudah timeout; login B tidak membuka pemilih akun atau mengirim kredensial melewati permintaan itu. Pekerjaan yang masih antre memeriksa pembatalan/generation sebelum memanggil SDK.

Keluar langsung menyembunyikan identitas dari getter, cache, dan stream. Niat logout disimpan agar startup berikutnya tidak mengakui akun lama. Sign-out segera dan pembersihan wajib sesudah permintaan lama sama-sama diselesaikan sebelum login berikutnya. Penanganan startup atas niat logout hanya menyelesaikan sesi Firebase; tidak membersihkan cookie Google saat inisialisasi. Fallback keychain hanya boleh menerima akun Firebase yang emailnya cocok dengan akun Google yang dipilih.

SDK yang sudah menjalankan permintaan tidak dapat dibatalkan oleh deadline Dart. Jika SDK tidak pernah menyelesaikannya, aplikasi menampilkan pesan yang dapat dicoba ulang dan menahan mutasi akun berikutnya sampai permintaan selesai atau proses aplikasi dimulai ulang. Ini batas yang disengaja untuk mencegah akun saling menimpa.

## Bukti verifikasi

| Pemeriksaan | Hasil |
| --- | --- |
| Flutter: seluruh 99 berkas tes tingkat atas | **601 lulus**, tidak ada kegagalan; mencakup 23 regresi auth/startup. Folder visual terpisah tidak termasuk hitungan ini. |
| Auth, stream, pesan login, dan splash setelah guard cache terakhir | **37 lulus** pada snapshot akhir. |
| Backend lengkap melalui `npm test` | **268 lulus**, tidak gagal atau dilewati. |
| Kompilasi TypeScript melalui `npm run build` | Berhasil; hasil JavaScript/map tersinkron dalam checkpoint `b3a1d82f`. |
| Aksi NotebookLM dan guard dialog melalui Node | **15 lulus**; menjalankan potongan JavaScript yang diekstrak dari sumber aplikasi. |
| Analisis Dart seluruh proyek setelah perubahan akhir | **No errors**. |
| Kompilasi macOS release snapshot akhir | Sedang berjalan; hasil akhir dicatat setelah proses selesai. |

Suite tambahan memakai penyimpanan lokal, server HTTP lokal untuk transfer paket, serta Firebase/callable/provider tiruan untuk memeriksa urutan respons dan kegagalan. Pengujian itu tidak melakukan pembayaran atau menghapus riwayat Google sungguhan.

Bukti khusus tersedia di [regresi auth/startup](/Users/apple/Downloads/ramadhan/openturath_ai/test/auth_startup_recovery_test.dart), [Undo dan sinkronisasi](/Users/apple/Downloads/ramadhan/openturath_ai/test/bookmark_undo_sync_test.dart), [aliran unduhan/instalasi lokal](/Users/apple/Downloads/ramadhan/openturath_ai/test/ota_install_flow_test.dart), [pemulihan harga](/Users/apple/Downloads/ramadhan/openturath_ai/test/checkout_price_refresh_test.dart), [hasil pemeriksaan pembayaran](/Users/apple/Downloads/ramadhan/openturath_ai/test/payment_inquiry_feedback_test.dart), [hasil koneksi Google](/Users/apple/Downloads/ramadhan/openturath_ai/test/room_google_connection_result_test.dart), [hasil hapus riwayat](/Users/apple/Downloads/ramadhan/openturath_ai/test/room_history_result_test.dart), dan [regresi aksi JavaScript](/Users/apple/Downloads/ramadhan/scripts/test_notebook_actions.mjs).

## Batas penerimaan perangkat dan rilis

- Belum menguji login Google nyata, buka AI, tutup aplikasi sepenuhnya, lalu buka kembali dengan akun pelanggan yang terdampak. Tidak ada klaim bahwa auto logout pada screenshot sudah direproduksi dan hilang di perangkat nyata.
- Penghapusan riwayat diverifikasi terhadap konfirmasi UI provider dalam fixture; belum diuji sebagai operasi nyata pada notebook pelanggan. Perubahan DOM/teks Google di masa depan dapat membuat hasil dinyatakan belum terverifikasi.
- Belum menguji pembayaran/refund nyata atau sinkronisasi catatan dua perangkat melalui Firestore produksi.
- Tidak mengubah grant, keanggotaan notebook, penagihan, atau hak akses produksi. Tidak menjalankan pencabutan akses.
- Tidak memasang build ke aplikasi yang sedang digunakan, mengunggah APK/DMG, melakukan deployment backend, atau menyiarkan versi baru. Kompilasi lokal tidak membuktikan signing/notarisasi untuk distribusi publik.

Aturan WebView dipertahankan: minimal empat sampel kesiapan, elapsed minimal 3000 ms, jeda 250 ms, viewport galat yang bersih, dukungan lima tab, dan tanpa penimpaan cookie Google. Perubahan ruang AI terbatas pada handler aksi serta pembungkusan label menu.

Permintaan verifikasi identitas Google tetap merupakan keputusan layanan Google. Screenshot tidak cukup untuk menyimpulkan akun diretas atau menjamin bahwa tantangan tidak akan muncul lagi; lihat [penjelasan Google tentang verifikasi identitas] (https://support.google.com/accounts/answer/7162782?hl=en).

Seluruh perubahan dibuatkan checkpoint otomatis. Empat item untracked yang sudah ada sebelum pekerjaan dipertahankan.
