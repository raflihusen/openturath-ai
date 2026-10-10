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
