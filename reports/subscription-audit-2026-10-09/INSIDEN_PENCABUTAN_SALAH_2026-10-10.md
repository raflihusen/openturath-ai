# Insiden pencabutan hak yang sah — 10 Oktober 2026

## Penyebab yang dibuktikan

Worker VPS baru mencabut akses yang masih sah untuk dua pelanggan. Empat operasi Google yang sebelumnya disebut berhasil merupakan **empat pencabutan yang salah**, bukan bukti keputusan ekspirasi yang benar. Pemeriksaan kemarin membuktikan alamat email hilang dari sharing, tetapi tidak menangkap kesalahan penentuan hak. Laporan deployment sebelumnya perlu dibaca bersama koreksi ini.

| Pelanggan | Bukti hak yang terlewat | Hak berlaku sampai | Dampak worker baru |
| --- | --- | --- | --- |
| muhammadalaydrus65@gmail.com | Transaksi `AKL-7g66d3p-MMBR`, `bonus_reason: specific override request`, `bonus_applied_at`, dan expiry khusus | 26 Agustus 2027, 23:59:59 UTC | Al-Bayan dan Al-Muhaqqiq dicabut |
| riefbois33@gmail.com | `transfer_riefbois33_gmail_com_bahits_1y`, sumber transfer dari basithmuhammad612, original transaction `AKL-r2fvxfo-MMBR`, cakupan fiqh_tahawwulat | 7 April 2027, 14:23:20 UTC | Al-Bayan dan Al-Muhaqqiq dicabut |

Migrasi menganggap riwayat API GoAkal cukup untuk pemilik yang sudah mempunyai receipt terverifikasi. Di `importOwner`, transaksi non-Midtrans/Doku langsung dilewati ketika receipt GoAkal ada; catatan bernilai nol juga tidak menjadi grant pembayaran. Karena itu override pemilik serta transfer paket tidak diikutkan dan bahkan tidak masuk hold. Untuk Muhammad, worker hanya memakai enam bulan dari pembayaran asli dan menganggap masa aktif telah berakhir pada Agustus 2026. Untuk Arie, yang terbaca hanya paket satu bulan lama, sedangkan transfer tahunan bernilai nol terlewat.

Larangan memperpanjang otomatis dari nominal nol tetap benar. Kesalahannya adalah menyamakan transfer/koreksi pemilik dengan transaksi pembayaran nol biasa dan membuang bukti tersebut, bukan mempertahankannya untuk verifikasi.

## Tindakan yang telah selesai

- Worker dihentikan terlebih dahulu selama penelusuran dan pemulihan.
- Dua grant pemulihan admin terverifikasi dibuat, per modul fiqh_tahawwulat, memakai expiry eksplisit pada dokumen sumber. Pelanggan tidak diubah menjadi VIP permanen dan durasi pembayaran asli tidak dikompaun.
- Empat membership pada notebook historis asli dipulihkan dengan adapter Google; presence email dan sharing tertutup diverifikasi. Assignment menjadi ready, bukti membership serta counter kursi diperbarui.
- Empat pekerjaan pencabutan lama dipertahankan sebagai jejak audit dan diberi penanda insiden, bukan dihapus dari riwayat.
- Audit seluruh `access_jobs` worker baru menemukan tepat empat pekerjaan, semuanya pada dua pelanggan tersebut. Temuan ini tidak membuktikan seluruh pencabutan oleh sistem lama sebelum migrasi sudah benar.
- Audit seluruh transaksi menemukan metadata bonus/manual/transfer pada 46 alamat email. Sebanyak 26 dokumen profil/identitas terkait diberi hold. Ini jumlah catatan yang membutuhkan audit, bukan jumlah pelanggan yang terbukti kehilangan akses.
- Pembacaan ulang dua notebook terdampak memeriksa 22 membership berstatus ready: seluruhnya masih tercantum di Google, tidak ada yang hilang pada pemeriksaan tersebut.

## Perbaikan dan pembatasan operasi

Checkpoint yang diterapkan di VPS: `566cd06`.

1. Bonus, transfer, original_transaction_id, dan koreksi manual diperiksa sebelum filter gateway, nilai pembayaran, dan UID lama. Bukti seperti ini menahan pencabutan; tidak otomatis menambah durasi atau menyetujui transaksi nol.
2. `/access_control/runtime.revocations_paused = true` membekukan pencabutan baru, pekerjaan pencabutan yang sudah mengantre, serta pencabutan kompensasi. Penulis lama tetap dinonaktifkan melalui writer `vps-v2`.
3. Worker sudah berjalan lagi untuk pemberian akses dan pemeriksaan sharing. Pencabutan otomatis tetap dibekukan hingga audit hak manual/transfer selesai.
4. Build TypeScript selesai dengan exit 0. Sebanyak 93 pengujian backend lulus, termasuk bonus pemilik, transfer bernilai nol, hold, dan pemutus pencabutan tanpa memblokir pemberian akses.

## Batas hasil

Pemulihan Google sudah terbukti; tampilan perangkat pelanggan belum diperiksa. Pelanggan dapat perlu memuat ulang NotebookLM dengan akun Google yang sama. Tidak mengirim pesan langsung kepada pelanggan.

Audit cakupan insiden worker baru sudah selesai: dua pelanggan, empat membership salah dicabut, semuanya dipulihkan. Audit substantif atas seluruh 46 alamat dengan metadata penyesuaian masih terbuka. Penahanan dan pembekuan tidak boleh dilepas hanya karena worker sehat atau pengujian lulus. Pemantauan kesehatan teknis tidak membuktikan kebenaran keputusan hak akses.

## Penguatan lanjutan yang telah diterapkan

Checkpoint worker terbaru: `e74ca22`, kebijakan pencabutan versi 3. Deploy Firebase `getAgentUrl` dan `chatGate` berhasil. Pemeriksaan akhir di Google kembali menemukan keempat membership pelanggan terdampak, dengan sharing kedua notebook tetap tertutup. Pembekuan pencabutan tetap aktif; tidak membuat canary pencabutan baru pada pelanggan.

### Syarat keputusan pencabutan

- Identitas sasaran harus cocok dengan pemilik ledger. Profil hilang, penahanan hak, VIP, hak aktif, cakupan tanpa bukti, atau bukti rusak tidak dianggap izin mencabut.
- Hak dievaluasi per modul. Catatan manual dengan modul jelas tidak diperlakukan sebagai hak di modul lain; cakupan yang tidak diketahui harus diperiksa.
- Pelanggan lama memerlukan dokumen `access_legacy_audits` yang disetujui pemilik, terikat pada UID, email, modul, versi kebijakan, dan fingerprint bukti. Dokumen ini hanya dapat ditulis server/admin berdasarkan aturan Firestore; tidak tersedia untuk ditulis pelanggan.
- Fingerprint meliputi grant, profil yang relevan, dan transaksi. Perubahan bukti membatalkan persetujuan sebelumnya. Label approved saja tidak cukup: setiap penyesuaian manual harus dinyatakan dipenuhi lewat grant admin yang cocok, benar-benar berakhir, atau dibatalkan dengan persetujuan dan alasan pemilik. Penyesuaian yang masih berlaku tidak boleh ditandai expired.
- Tidak ada persetujuan audit massal yang diterbitkan dalam pengerjaan ini. Pengaman tidak menyetujui atau menambah durasi transaksi nol secara otomatis.
- Pekerjaan mencabut membawa versi kebijakan dan fingerprint keputusan. Keduanya diperiksa saat pekerjaan dijalankan, sesudah pembacaan sharing awal, dan sesudah tindakan Google. Pekerjaan lama atau bukti berubah masuk peninjauan.
- Pekerjaan memberi akses tidak boleh langsung berubah menjadi pekerjaan mencabut. Pencabutan memerlukan pekerjaan baru beserta penilaian buktinya sendiri.

### Perlindungan kegagalan di tengah tindakan

Sebelum menghapus email yang teramati hadir, worker menyimpan jurnal membership semula dan kewajiban pemulihan. Kewajiban ini hanya dibersihkan bersamaan dengan penyelesaian terverifikasi atau pemulihan terverifikasi.

Jika respons hilang setelah Google sempat menghapus izin, worker mencoba memulihkan membership asli. Jika pemulihan belum berhasil, kewajiban tersebut tetap tersimpan dan dicoba kembali sebelum mengevaluasi kedaluwarsa atau pembekuan. Jika proses mati, pekerjaan dapat dilanjutkan setelah lease sebelumnya habis. Lease pekerjaan adalah 10 menit; pemulihan ketika proses/koneksi putus tidak dijamin seketika.

Membership dipulihkan hanya dari keadaan asal yang direkam, bukan dari permintaan pengguna baru tanpa bukti. Counter tidak dibebaskan sebelum keputusan serta hasil sharing terverifikasi. Pemulihan juga merekonstruksi metadata membership yang hilang dan menjaga pemilik identitas saat adopsi akun.

### Konsistensi pintu masuk aplikasi

Profil yang memiliki hold migrasi boleh membuka notebook tempat emailnya telah terdaftar secara fisik dan terverifikasi. Hal ini tidak membuat grant pembayaran, alokasi kursi, atau akses notebook baru. Akun yang sedang dihapus tidak memakai pengecualian ini. Adopsi identitas historis ke akun aplikasi mempertahankan hold dan kebutuhan audit; tidak menghapus pengaman migrasi.

### Verifikasi terakhir

- Build TypeScript: exit 0.
- 113 pengujian backend: seluruhnya lulus. Kasus tambahan mencakup kedua insiden, transfer nol, persetujuan salah UID/modul/versi, perubahan bukti sebelum dan selama Google berjalan, timeout setelah penghapusan, pemulihan yang gagal lalu dicoba lagi, restart dengan jurnal, metadata membership yang hilang, serta akses aplikasi saat hold.
- Simulasi kegagalan memakai provider/database tiruan. Tidak mematikan worker saat menghapus pelanggan nyata untuk menguji crash.
- Pembacaan nyata: empat membership kedua pelanggan tetap hadir, kedua notebook tertutup, worker aktif, `revocations_paused=true`, `revocation_policy=3`.
- Audit 436 transaksi menemukan 46 email dengan metadata penyesuaian: 23 cocok dengan identitas yang tersedia, 23 belum mempunyai identitas yang cocok. Kategori saling tumpang tindih: 26 email memiliki bonus, 27 memiliki metadata manual, 1 memiliki transfer.

### Syarat sebelum membuka kembali pencabutan

Selesaikan penilaian catatan lama, petakan penyesuaian yang sah ke grant per modul, selesaikan identitas yang belum cocok, dan terbitkan persetujuan berdasarkan bukti yang benar-benar diperiksa. Persetujuan dapat menjadi tidak berlaku lagi ketika bukti berubah; jangan melepas hold atau menerbitkan persetujuan secara massal dari status pembayaran saja. Pelanggan baru dengan alur pembayaran modern yang sah tetap dapat diproses otomatis; kasus migrasi lama ini tidak berarti setiap pelanggan baru harus ditinjau manual.

Penguatan ini menutup kelas kegagalan yang ditemukan dan menambah pemulihan kegagalan eksternal. Hasilnya tidak membuktikan risiko nol, uji beban provider 10.000 pelanggan, uji pembelian/refund nyata, atau penerimaan di perangkat pelanggan. Keterbatasan deployment lain pada laporan sebelumnya, termasuk pemrosesan GoAkal baru dan migrasi runtime Firebase Node 20, masih berlaku.
