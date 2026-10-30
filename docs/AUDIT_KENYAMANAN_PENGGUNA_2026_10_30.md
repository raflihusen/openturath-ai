# Audit ulang kenyamanan pengguna OpenTurath AI

Tanggal: 30 Oktober 2026, Asia/Aden. Sumber awal: **`a92c71bb`**, cabang `v9-2-integrasi`, workspace **1.0.87+88**.

## Kesimpulan

Masih ada bug yang dapat mengganggu pengguna meskipun perbaikan sesi lokal sebelumnya sudah lolos tes. Audit ini mencatat **15 temuan tersisa: 4 P1, 10 P2, dan 1 P3**. Sebagian merupakan celah yang sudah diketahui tetapi belum diperbaiki; sebagian ditemukan dari interaksi lain yang belum dicakup tes.

Yang paling mendesak adalah tanggal kedaluwarsa profil pelanggan berbayar yang dapat dipendekkan oleh trial, profil cache yang tampak masuk saat Firebase kosong, pemulihan login yang masih dapat menahan splash, dan kabar penghapusan akun yang dapat muncul tanpa penghapusan sebenarnya.

Audit juga menemukan satu integrasi yang belum mengikuti perubahan sesi terbaru: layar koneksi sudah mengembalikan `false` saat pengguna memilih **Tunda**, tetapi dua pemanggil di ruang AI tetap mencoba memuat AI kembali.

**555 tes Flutter dalam 93 berkas lulus; 21 tes backend voucher/harga lulus.** Kelulusan tersebut tidak menutup kasus yang direproduksi di luar cakupan tes lama. Pemeriksaan ini tidak memakai sesi Google pelanggan atau melakukan transaksi nyata.

## Cakupan dan tingkat bukti

- **R — Reproduksi lokal:** kode aktual atau potongan fungsi aktual dijalankan dengan data sintetis/penyimpanan dalam memori; hasil salah teramati.
- **K — Jalur kode:** pemicu dan akibat ditelusuri langsung pada implementasi; belum dijalankan pada perangkat nyata.
- Seluruh temuan berlaku pada sumber yang diaudit. Versi backend yang sedang diterapkan dan binary yang dipakai setiap pelanggan tidak diverifikasi ulang pada audit ini.
- Tidak ada perubahan kode produk, akses pelanggan, VIP, cookie, pembayaran, provisioning, build, instalasi, deploy, atau broadcast rilis. Hanya laporan audit yang ditambahkan.
- P1: perlu diprioritaskan sebelum distribusi lebih luas karena berpotensi memblokir alur utama atau memberi informasi serius yang salah. P2: gangguan fungsi/pemulihan yang perlu diperbaiki berikutnya. P3: kejelasan umpan balik.

## Ringkasan temuan

| ID | Prioritas | Yang dialami pengguna | Bukti |
|---|---|---|---|
| U01 | P1 | Trial mengubah expiry profil berbayar dari sisa 100 hari menjadi 7 hari | R |
| U02 | P1 | Nama/paket terlihat masuk, tetapi sesi online sebenarnya kosong | K |
| U03 | P1 | Aplikasi tertahan pada splash saat pemulihan token tidak selesai | K |
| U04 | P1 | “Akun berhasil dihapus” padahal operasi penghapusan tidak dilakukan | K |
| U05 | P2 | Tombol coba lagi pada kegagalan startup ikut terkunci | K |
| U06 | P2 | Cek pembayaran manual gagal tanpa penjelasan hasil | K |
| U07 | P2 | Akses sudah siap, dialog tetap menyebut masih diproses | K |
| U08 | P2 | Harga berubah, tombol ulang terus mengirim harga lama | R + K |
| U09 | P2 | Sudah memilih Tunda, ruang AI tetap mencoba menyambung lagi | K |
| U10 | P2 | Salin jawaban B segera setelah A, clipboard tetap A | R |
| U11 | P2 | Hapus riwayat terlihat berhasil hanya pada tampilan lokal | R |
| U12 | P2 | Salin percakapan menghilangkan giliran dengan teks sama | R |
| U13 | P2 | Catatan yang dipulihkan lewat Undo hilang lagi setelah sinkronisasi | R |
| U14 | P2 | Bidang belum dirilis sempat tampak dapat dibuka | K |
| U15 | P3 | Unduhan berjalan, indikator kemajuan tampak diam | R |

## U01 — Trial dapat memendekkan expiry profil berbayar

**Pemicu:** pelanggan paid membuka Langganan dari Profil lalu menukar voucher trial untuk modul yang sama. Jalur UI tetap tersedia pada pelanggan paid: [profile_screen.dart:359](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/profile_screen.dart:359), [subscription_screen.dart:938](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/subscription_screen.dart:938). Backend hanya menghalangi trial aktif lain, bukan paid.

**Penyebab:** [index.ts:2143](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:2143) menghitung expiry trial dari waktu klaim. Cabang paid mempertahankan plan/status pembayaran tetapi menulis expiry baru tersebut pada [index.ts:2169](/Users/apple/Downloads/ramadhan/openturath_ai/functions/src/index.ts:2169).

**Bukti:** source backend aktual dijalankan melalui `loadBackend`/MemoryDB dan axios mock pada [audit_harness.ts:106](/Users/apple/Downloads/ramadhan/openturath_ai/functions/test/audit_harness.ts:106). Profil sintetis paket tahunan, payment paid, sisa 100 hari, serta grant pembayaran valid menghasilkan redemption sukses untuk trial 7 hari. Expiry profil menjadi 7 hari, baik mode writer legacy maupun vps-v2. Grant pembayaran tetap 100 hari.

**Batas penting:** yang terbukti adalah proyeksi profil berkurang 93 hari. Audit ini **tidak membuktikan grant pembayaran dicabut atau pelanggan produksi kehilangan 93 hari**. Worker dapat memulihkan proyeksi; waktu pemulihannya belum diuji.

**Solusi:** trial tidak boleh mengurangi proyeksi/grant paid. Tetapkan kebijakan trial-on-paid secara eksplisit dan tambahkan regresi. Pertahankan VIP serta hak modul lain; jangan menyelesaikan masalah ini melalui pencabutan akses.

## U02 — Cache profil masih menyamar sebagai keadaan masuk

**Pemicu:** Firebase kehilangan sesi, tetapi profil lokal masih tersimpan; atau auth stream mengirim null saat dashboard sedang terbuka.

[auth_service.dart:138](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:138) mengembalikan cache tanpa Firebase. [splash_screen.dart:81](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/splash_screen.dart:81) menerimanya untuk dashboard. [dashboard_screen.dart:248](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart:248) kembali memakai `_initialUser` ketika stream menjadi null. `isCachedProfileOnly` belum digunakan oleh UI.

**Dampak:** nama/paket terlihat tersedia tetapi AI atau pembayaran meminta login. Pada pergantian akun, snapshot identitas lama dapat tetap terlihat. Ini temuan tersisa dari audit sesi, bukan klaim bahwa perbaikan cookie baru gagal.

**Solusi:** tampilkan keadaan offline/perlu autentikasi secara jelas; ikat fallback profil pada UID sesi yang benar. Pertahankan informasi paket tanpa menganggap cache sebagai autentikasi.

## U03 — Pemulihan login masih dapat menahan splash tanpa batas

Sepuluh detik hanya membatasi `signInSilently()`. Sesudah SDK mengembalikan akun, pengambilan `googleUser.authentication` dan `signInWithCredential` belum dibatasi: [auth_service.dart:118](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:118). Splash menunggu seluruh `restoreSession()` pada [splash_screen.dart:67](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/splash_screen.dart:67).

**Pemicu:** Future token atau penukaran credential tidak selesai setelah silent sign-in mengembalikan akun. Tombol melewati animasi tidak membatalkan penantian pemulihan.

**Solusi:** deadline keseluruhan pemulihan dan tiap tahap native; tampilkan hasil pemulihan dengan tindakan yang dapat digunakan. Ini mekanisme hang yang masih mungkin dari source, bukan reproduksi hang SDK pada perangkat pelanggan. Tes splash yang tersedia memakai `resolveInitialRoute` sehingga melewati alur ini.

## U04 — Hapus akun dapat menyatakan sukses tanpa menghapus

[auth_service.dart:484](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/auth_service.dart:484) langsung kembali jika `currentUser==null`. [profile_screen.dart:161](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/profile_screen.dart:161) tetap menampilkan sukses dan menuju login ketika pemanggilan itu selesai tanpa exception.

**Pemicu:** pengguna berada pada profil cache-only U02 lalu menekan Hapus akun dan mengonfirmasi. Tidak ada operasi delete yang dijalankan, tetapi pengguna diberi kabar berhasil.

**Solusi:** hasil terstruktur/kebutuhan autentikasi; sukses hanya setelah penghapusan terkonfirmasi. Audit tidak menekan Hapus akun atau menghapus akun siapa pun.

## U05 — Pemulihan startup sendiri dapat terkunci

Jalur retry Firebase pada [main.dart:141](/Users/apple/Downloads/ramadhan/openturath_ai/lib/main.dart:141) mengatur `_retrying=true`, lalu menunggu initializeApp tanpa timeout. Selama Future belum selesai, tombol retry tidak memiliki callback.

**Pemicu:** inisialisasi pertama gagal, lalu initializeApp berikutnya tidak menyelesaikan Future. **Solusi:** deadline retry dan pemulihan flag melalui finally, dengan pesan tahap gagal.

## U06 — Pemeriksaan pembayaran manual gagal senyap

[payment_service.dart:62](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/payment_service.dart:62) menangkap galat lalu mengembalikan `status=ERROR`. [payment_checkout_sheet.dart:272](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/payment_checkout_sheet.dart:272) hanya menangani SUCCESS. Pesan manual di catch tidak berjalan untuk galat yang sudah ditelan service. Status terminal seperti EXPIRE/DENY/CANCEL juga tidak ditangani di cabang ini.

**Pemicu:** pengguna menekan muat ulang status saat koneksi putus, autentikasi ditolak, atau provider tidak menjawab. Tidak ada penjelasan yang membedakan gagal memeriksa dari transaksi yang masih pending.

**Solusi:** hasil inquiry terstruktur untuk success/pending/gagal memeriksa/berakhir, lalu tampilkan tindakan yang sesuai. Jangan memberi kesan belum membayar hanya karena pemeriksaan gagal.

## U07 — Hasil readiness terakhir tidak menyegarkan dialog

[access_prepare_gate.dart:56](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/access_prepare_gate.dart:56) mengubah `_ready` tanpa setState. Pada tick terakhir, poll dimulai, builder memakai nilai lama, kemudian timer berhenti pada detik 30 (`:71–76`).

**Pemicu:** hasil sebelumnya false; permintaan terakhir baru mengembalikan true sesudah tick terakhir. Tidak ada rebuild berikutnya. Dialog dapat terus menyatakan masih diproses sampai ditutup atau terjadi rebuild lain.

**Solusi:** publikasikan hasil async setelah memastikan mounted. Countdown selesai tidak boleh menghentikan pembaruan hasil permintaan terakhir. Tambahkan kasus Completer yang baru selesai sesudah countdown.

## U08 — Harga berubah, retry tetap memakai penawaran lama

Harga disinkronkan ketika halaman Langganan dibuat: [subscription_screen.dart:68](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/subscription_screen.dart:68). Harga basi ditolak backend sebelum membuat invoice, tetapi `failed-precondition` menjadi pesan umum paket belum dapat diproses (`:83–84`). Retry tidak memuat harga baru.

**Bukti:** source backend dalam MemoryDB dengan expectedPrice 49.000 dan harga server 59.000 menolak dua permintaan ulang yang sama; 0 invoice dibuat. Validasi nominal server bekerja benar. Pemulihan UI tidak menjelaskan perubahan harga dan terus mengirim penawaran lama sampai halaman dimuat ulang.

**Solusi:** alasan harga berubah terstruktur, sinkronkan penawaran, tampilkan harga terbaru, lalu minta pengguna memilih melanjutkan. Pertahankan validasi nominal server.

## U09 — Ruang AI tidak menghormati hasil Tunda

Pada [agent_multi_tab_room.dart:1674](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:1674) dan [agent_multi_tab_room.dart:1706](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:1706), hasil Navigator ke layar koneksi Google dibuang. Pemanggil tetap menghapus error, mengaktifkan loader, memuat Notebook, dan memulai pemeriksaan kesiapan.

**Pemicu:** dari error akun/izin AI, pilih pemulihan akun lalu Tunda dulu. Layar koneksi sudah mempertahankan cookie dan mengembalikan false, tetapi ruang AI mencoba menyambung lagi.

**Solusi:** lanjutkan urutan pemuatan yang ada hanya jika hasilnya true; hasil false mempertahankan status sebelumnya atau kembali ke beranda. Ini integrasi yang belum tercakup tujuh tes layar pemulihan sebelumnya. Perubahan perlu menjaga seluruh persyaratan lifecycle/polling yang dilindungi.

## U10 — Salin dua jawaban cepat menghasilkan clipboard yang salah

[notebook_ui_script.dart:65](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/notebook_ui_script.dart:65) membuang semua copy dalam 3.500 ms, tanpa membandingkan isi. Dart melakukan pembatasan serupa pada [agent_multi_tab_room.dart:1886](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:1886). Tombol pada [notebook_skin.dart:652](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/notebook_skin.dart:652) tetap memberi label Tersalin.

**Bukti fixture JavaScript aktual:** A lalu B berjarak 300 ms menghasilkan bridge delivery hanya A. Tidak ada clipboard pelanggan yang disentuh.

**Solusi:** deduplikasi kejadian ganda berisi sama, tetap izinkan isi berbeda; status Tersalin mengikuti keberhasilan penyalinan.

## U11 — Hapus riwayat dapat hanya menghapus tampilan lokal

[agent_multi_tab_room.dart:471](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:471) tidak menunggu/memeriksa hasil tindakan provider. [notebook_ui_script.dart:1346](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/notebook_ui_script.dart:1346) dapat mengembalikan true tanpa tombol penghapusan; `otClearChat` tetap menghapus elemen pesan lokal.

**Bukti fixture aktual:** menu provider tidak tersedia menghasilkan `returnedSuccess=true`, dua pesan lokal dibuang, dan 0 tindakan provider. Percakapan dapat muncul kembali setelah reload.

**Solusi:** tunggu konfirmasi penghapusan provider; pertahankan tampilan percakapan jika belum terbukti. Jangan menyatakan riwayat telah dihapus berdasarkan DOM lokal.

## U12 — Ekspor percakapan kehilangan giliran berulang

[notebook_ui_script.dart:39](/Users/apple/Downloads/ramadhan/openturath_ai/lib/core/notebook_ui_script.dart:39) memakai deduplikasi berdasarkan isi pada seluruh percakapan. Hasilnya dapat disimpan ke Catatan oleh [agent_multi_tab_room.dart:203](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/agent_multi_tab_room.dart:203).

**Bukti:** urutan Q, A1, Q, A2 pada fixture fungsi aktual menjadi pertanyaan pertama, jawaban pertama, jawaban kedua. Pertanyaan kedua hilang.

**Solusi:** deduplikasi node/pembungkus pesan sambil menjaga semua giliran dan urutan teks. Isi sama pada giliran berbeda tetap merupakan bagian percakapan yang sah.

## U13 — Undo catatan dapat hilang lagi saat sinkronisasi

[bookmark_screen.dart:220](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/bookmark_screen.dart:220) mengembalikan item lama. Penghapusan menghasilkan tombstone yang lebih baru pada [bookmark_service.dart:128](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/bookmark_service.dart:128); merge memilih `syncTime` terbaru pada [bookmark_service.dart:244](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/bookmark_service.dart:244).

**Bukti:** model aktual dan badan merge aktual diekstrak ke fixture Dart dengan data sintetis. Catatan t0 dihapus pada t1, Undo mengembalikan t0, kemudian merge dengan tombstone cloud t1 menghasilkan `visibleAfterUndo=1`, `visibleAfterSync=0`, `cloudTombstoneWon=true`. Ini bukan sinkronisasi akun pelanggan.

**Solusi:** Undo adalah perubahan baru dengan updatedAt lebih baru daripada penghapusan dan deletedAt kosong. Perhatikan bahwa `copyWith(deletedAt:null)` pada model saat ini menggunakan fallback nilai lama; pemulihan harus benar-benar dapat membersihkan tombstone.

## U14 — Bidang belum dirilis sempat terlihat aktif

Keadaan awal dan fallback dashboard memakai `AgentModel.defaultAgents` mentah: [dashboard_screen.dart:70](/Users/apple/Downloads/ramadhan/openturath_ai/lib/screens/dashboard_screen.dart:70), `:149`. Daftar mentah menandai sejumlah bidang active, sementara whitelist peluncuran diterapkan terpisah oleh [agent_service.dart:20](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/agent_service.dart:20).

**Pemicu:** cari Hanafi sebelum pemuatan agen selesai atau ketika refresh mencapai fallback timeout. Kartu dapat terlihat tidak terkunci dan melewati gerbang coming-soon. Audit tidak membuktikan pembelian bidang tersebut benar-benar berhasil.

**Solusi:** gunakan `getActiveAgentsSync()` untuk keadaan awal/fallback atau pertahankan snapshot valid terakhir.

## U15 — Unduhan tanpa Content-Length terlihat tidak bergerak

[update_package_store.dart:132](/Users/apple/Downloads/ramadhan/openturath_ai/lib/services/update_package_store.dart:132) hanya melaporkan kemajuan antara jika contentLength positif. UI memakai nilai awal 0 pada determinate progress: [update_ready_banner.dart:42](/Users/apple/Downloads/ramadhan/openturath_ai/lib/widgets/update_ready_banner.dart:42).

**Bukti:** store aktual menerima delapan chunk dari server HTTP lokal sintetis, memverifikasi seluruh 29 byte, tetapi callback progress hanya `[1.0]` pada akhir. Tidak ada pembaruan antara. Batas minimum byte diturunkan hanya pada fixture; kebijakan produk tidak diubah.

**Solusi:** gunakan indikator indeterminate ketika panjang tidak diketahui, atau tampilkan byte diterima. Ini masalah umpan balik; fixture tidak membuktikan kecepatan unduh pelanggan.

## Urutan tindakan yang disarankan

1. Lindungi expiry paid U01 dan tutup kabar penghapusan palsu U04; jangan melakukan pencabutan otomatis atau perubahan VIP.
2. Pisahkan cache/autentikasi U02 dan batasi seluruh pemulihan startup U03/U05.
3. Hormati Tunda U09, publikasikan readiness U07, dan jelaskan hasil pembayaran U06/U08.
4. Benahi integritas tindakan salin/hapus/Undo U10–U13 dan fallback katalog U14.
5. Perjelas kemajuan unduhan U15, lalu jalankan perjalanan perangkat nyata dari instalasi pelanggan.

Temuan distribusi/signing sebelumnya tetap menjadi pekerjaan verifikasi sebelum rilis, tetapi artefak publik tidak diunduh/ditandatangani ulang dalam audit ini. Lihat [audit login/distribusi sebelumnya](/Users/apple/Downloads/ramadhan/docs/AUDIT_LOGIN_SESI_DISTRIBUSI_2026_10_30.md) dan [status perbaikan sesi lokal](/Users/apple/Downloads/ramadhan/docs/PERBAIKAN_SESI_GOOGLE_2026_10_30.md).

## Batas pengujian

555 tes Flutter yang lulus mencakup 93 berkas tingkat utama pada `test/`, termasuk layout, navigasi, catatan, sesi, pembayaran, dan update. Berkas render di `test/visual/` tidak dijalankan. Tes backend voucher/harga berjumlah 21. Angka tersebut adalah hasil run audit ini pada sumber awal, bukan pengukuran kualitas seluruh aplikasi atau bukti pengalaman pelanggan.

Reproduksi tambahan menggunakan MemoryDB, fixture JavaScript/Dart, dan HTTP loopback. Temuan bertanda K belum direproduksi pada perangkat. Belum ada uji login Google nyata, instalasi Windows bersih, siklus restart OS, checkout pembayaran nyata, atau verifikasi produksi untuk setiap pemicu. Tidak ada produk yang diterapkan atau dirilis dari audit ini.
