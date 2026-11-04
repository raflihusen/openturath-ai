# Perbaikan login kedua dan diagnostik OpenTurath

Tanggal: 4 November 2026. Workspace: `/Users/apple/Downloads/ramadhan`.
Branch: `codex/diagnostic-access-session-recovery`. Baseline implementasi: `7e882ab2`.

**Status rilis: DITAHAN.** Perbaikan kode dan pengujian lokal tidak membuktikan login Google nyata, jawaban NotebookLM, atau stabilitas seluruh perangkat. Tidak ada deployment fungsi, upload aplikasi, broadcast OTA, perubahan akun pelanggan, replay undangan, atau pencabutan VIP dalam pekerjaan ini.

## Perilaku yang diperbaiki

1. Login aplikasi dan koneksi AI mempunyai tujuan terpisah. Login kedua untuk masuk aplikasi diarahkan ke akun Google, bukan menunggu NotebookLM. Halaman akun/keamanan/pemulihan Google yang sah dengan cookie sesi dapat mengembalikan pengguna ke dashboard. Tombol **Masuk OpenTurath** juga dapat digunakan saat Google menawarkan langkah tambahan atau browser tidak terbaca, selama sesi aplikasi masih sah.
2. Masuk beranda tidak membuat klaim bahwa identitas Google di WebView sudah terverifikasi. Challenge wajib, cookie, dan cache profil tidak menggantikan autentikasi aplikasi. Identitas yang berubah atau logout membatalkan callback lama.
3. Saat AI dibuka, hak akses tetap diperiksa server. Koneksi Google yang belum terverifikasi diarahkan ke pemeriksaan akun; tidak diperlakukan sebagai alasan membeli ulang. Pemulihan AI hanya dilanjutkan setelah hasil koneksi yang terverifikasi, bukan ketika pengguna menunda atau sekadar masuk beranda.
4. Cookie Google hanya dibaca. Tidak ada replay, perubahan masa berlaku, atau penghapusan global baru. Hasil pemeriksaan sesi yang terlambat setelah kepemilikan dilepas tidak dapat menandai sesi lama sebagai siap.
5. Galat sebelum URL diterima mempertahankan tahap, kode, alasan, modul, ID percobaan, ID insiden, dan ID permintaan server. Laporan menyebut build/edisi, menyaring URL dan metadata, mendukung identitas token opsional, serta memakai kembali nomor tiket untuk insiden yang sama.
6. Server membedakan alasan penyiapan, pemeriksaan legacy, identitas, aplikasi, pembatasan permintaan, notebook tidak tersedia, dan penolakan hak. Keputusan hak yang ada dipertahankan; VIP tetap dilindungi dan modul dievaluasi independen.
7. Halaman login Google dan pembatalan normal dipisahkan dari statistik kegagalan teknis. Statistik baru memisahkan build, edisi, dan alasan. Tidak ada persentase keberhasilan baru yang diklaim tanpa data awal/akhir percobaan.
8. Habisnya timer tidak menyatakan akses siap. Tanpa konfirmasi server, dialog menyatakan akses masih diproses dan mengizinkan pengguna kembali. Tombol masuk diperiksa dalam tiga bahasa pada lebar 320, 390, dan 1280 piksel.

## Preservasi

- Empat sampel kesiapan berturut-turut, minimum 3000 ms, dan jeda 250 ms dipertahankan. Polling, viewport galat `ColoredBox`, CSS composer, serta `desktop_webview_runtime.dart` tidak dirombak.
- Lima sesi macOS dipertahankan dalam uji pengelola tab; tidak ada perubahan batas atau kebijakan eviksi.
- Tidak ada perubahan pada whitelist VIP, hibah, transaksi, proyeksi hak, aturan pencabutan, atau hold legacy. Perubahan resolver akses hanya menambahkan alasan pada hasil penolakan yang sudah ada.
- Delapan penghapusan arsip dan `__pycache__/` yang sudah ada sebelum implementasi tidak dimasukkan ke checkpoint.
- Setiap perubahan dibuatkan checkpoint Git dengan daftar file eksplisit.

## Hasil verifikasi

- Backend: **281 lulus, 0 gagal, 0 dilewati**, harness terisolasi dengan Firestore dan pengiriman notifikasi tiruan.
- TypeScript: pemeriksaan tipe dan kompilasi berhasil. Keluaran JavaScript serta source map diperbarui dalam checkpoint `377b6b7b`.
- Pemeriksaan statis seluruh proyek Flutter: **No errors**, termasuk tidak ada peringatan yang tersisa pada hasil pemeriksaan terakhir.
- Suite Flutter final: sedang diselesaikan; hasil akhir dan rincian tes yang dilewati dicatat pada bukti pendamping setelah proses selesai.
- Kompilasi aplikasi lokal: sedang diverifikasi. Tidak ada instalasi atau pengujian akun nyata yang dilakukan oleh proses kompilasi.

Uji regresi terlebih dahulu mereproduksi masalah: navigasi aplikasi masih menunggu NotebookLM, alasan sebelum URL hilang, timer membuat siap palsu, callback sesi lama menjadi siap, dan tata letak tombol meluber. Koreksi kemudian diuji ulang. Uji menyeluruh pertama juga menemukan ekspektasi dialog aktivasi lama; alur dialog dan pengujiannya diselaraskan dengan syarat konfirmasi server sebelum suite diulang.

## Matriks bukti T01–T40

“Lokal” berarti kode, unit/widget test, atau kontrak pada harness; bukan pengujian Google/NotebookLM nyata. Bukti perangkat yang belum tersedia tetap merupakan syarat rilis.

| Skenario | Bukti lokal / batas yang masih berlaku |
|---|---|
| T01 | Kode dan alasan server dipertahankan sampai snapshot/tiket sebelum WebView. Alur autentikasi nyata masih perlu perangkat. |
| T02 | Penolakan hak terstruktur menampilkan paket untuk akun biasa. |
| T03 | Penyiapan akses tidak menampilkan beli ulang; timer tanpa konfirmasi tidak membuat siap. |
| T04 | Kontrak resolver tetap membutuhkan notebook/assignment yang sah. Membership nyata belum diuji. |
| T05 | Regresi backend VIP dan uji UI menjaga VIP dari paywall. Tidak ada data VIP diubah. |
| T06 | Regresi hak per modul tetap dijalankan; bukti penggunaan kedua modul pada perangkat belum tersedia. |
| T07 | Regresi voucher dan hak aktif dijalankan dalam suite backend/model. |
| T08 | Penolakan legacy mempertahankan alasan pemeriksaan; hold tidak dibuka. |
| T09 | Uji UI membedakan keputusan hak server dari cache aktif, dengan pengecualian preservasi VIP. |
| T10 | Halaman login dicatat sebagai fase; hasil terverifikasi dapat melanjutkan AI. Google nyata belum diuji. |
| T11 | Hasil batal/tunda tidak memulihkan AI sebagai sukses; pembatalan normal tidak memicu alarm gagal login. |
| T12 | Cookie tanpa owner terverifikasi tidak membuka AI; koneksi akun ditawarkan tanpa paywall palsu. |
| T13 | Jalur OAuth desktop tetap terpisah dari sesi WebView. Windows nyata belum tersedia. |
| T14 | Metadata skema aman dan kode asli disimpan. Penyebab Android -10 belum direproduksi; tidak ditambahkan handler tebakan. |
| T15 | Kode native dan platform tetap dibawa. Penyebab Windows 9/macOS -1005 belum dipastikan pada perangkat terdampak. |
| T16 | Kode transport dan retry laporan diuji; gangguan jaringan/TLS nyata belum direproduksi. |
| T17 | Timeout kesiapan mempertahankan tahap composer-ready. Perilaku composer pada NotebookLM nyata belum diuji. |
| T18 | Parameter 4 sampel/3000 ms/250 ms diperiksa tetap utuh; stabilitas DOM nyata masih perlu diuji. |
| T19 | Callback tertunda setelah logout, ganti akun, dan tutup layar diuji; snapshot laporan dibekukan sebelum pembacaan asinkron. Background/resume perangkat masih perlu diuji. |
| T20 | Lima objek sesi macOS bertahan saat pindah tab dan kembali dari dashboard. Lima WebView native aktif belum diuji. |
| T21 | Uji cookie membuktikan pemeriksaan tidak menulis/menghapus cookie. Persistensi tutup-buka aplikasi nyata belum diuji. |
| T22 | Redaksi email/token/query/segmen URL dan bentuk metadata diuji di klien serta server. |
| T23 | Klaim UID/VIP dari body tidak dipercaya; owner laporan hanya dari token terverifikasi. Tidak ada efek hak dari telemetry. |
| T24 | Token invalid/gagal tersedia tetap memakai jalur laporan anonim tanpa owner palsu. |
| T25 | Retry gagal tetap dapat dikirim; pengiriman insiden berhasil menggunakan tiket yang sama di klien/server. Interaksi klik pada perangkat belum diuji. |
| T26 | Payload lama diterima server baru; kode lama tanpa details tetap didukung klien. Deployment gabungan belum dilakukan. |
| T27 | Pemeriksaan null, false, gagal, terlambat, dan layar ditutup dicakup uji gate/dialog. |
| T28 | Regresi idempotensi transaksi serta perlindungan nominal nol dijalankan tanpa transaksi produksi. |
| T29 | Widget tombol masuk tiga bahasa/RTL di tiga lebar diuji. Visual native dan aksesibilitas perangkat masih perlu ditinjau. |
| T30 | Belum dilakukan: akun berhak mengirim pertanyaan dan benar-benar menerima jawaban pada setiap platform sasaran. |
| T31 | Halaman akun/pemulihan dapat masuk dashboard tanpa NotebookLM dan tanpa memalsukan owner. Variasi halaman Google nyata masih perlu diuji. |
| T32 | Halaman keamanan dan tindakan masuk aplikasi diuji. |
| T33 | Email DOM/browser tidak terbaca tidak menghalangi masuk aplikasi yang sah; AI tetap menunggu verifikasi akun. |
| T34 | Masuk beranda tidak memuat atau menunggu domain NotebookLM. Gangguan layanan nyata belum diuji. |
| T35 | Login dan pemulihan startup mempertahankan syarat autentikasi aplikasi. Siklus instalasi/tutup-buka nyata belum diuji. |
| T36 | Hasil null/false/batal/tunda/appEntered tidak dianggap sukses koneksi AI. |
| T37 | Challenge password/OTP, host tiruan, dan HTTP tidak otomatis menyelesaikan login Google. |
| T38 | Cookie dan cache tanpa autentikasi aplikasi tidak dapat masuk dashboard. |
| T39 | SID, __Secure-1PSID, __Secure-3PSID dikenali secara konsisten tanpa penulisan cookie. |
| T40 | Hasil terlambat setelah ganti akun/logout/layar ditutup tidak menavigasi atau menetapkan sesi lama. |

## Syarat sebelum rilis

1. Catat paket terpasang, edisi, versi/build, perangkat, dan akun uji. Gunakan akun/notebook uji yang disediakan, tanpa mengubah akun pelanggan.
2. Uji login pertama dan kedua, saran pemulihan opsional, challenge wajib, DOM email tidak terbaca, dan kembali ke aplikasi tanpa menunggu NotebookLM.
3. Uji akun Google berbeda, tunda koneksi, login ulang, logout, tutup-buka aplikasi, serta background/resume. Pastikan sesi yang sah tetap tersimpan.
4. Uji VIP, paket aktif per modul, voucher, expired, provisioning, dan legacy hold melalui data uji yang sah. Tidak ada pembelian ulang atau pencabutan yang tidak semestinya.
5. Uji lima tab macOS, tata letak/transkrip/composer, lalu kirim pertanyaan dan terima jawaban pada Android, Windows, dan macOS sasaran.
6. Cocokkan satu insiden terkontrol dengan tiket dan ID permintaan pada kandidat server/klien. Verifikasi kompatibilitas sebelum deployment yang nantinya diizinkan terpisah.
7. Tiket historis dengan halaman/kode yang hilang tidak dapat dipastikan penyebabnya secara retroaktif. Diagnosis kasus produksi yang tersisa membutuhkan reproduksi atau log yang memadai.

Tidak ada platform yang dinyatakan siap rilis hanya karena suite otomatis atau kompilasinya berhasil.
