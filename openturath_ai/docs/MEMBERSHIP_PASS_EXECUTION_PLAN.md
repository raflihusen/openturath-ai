# Rencana Implementasi Kartu Akses Pro

## Tujuan

Kartu akses pada Pengaturan harus memberi jawaban yang jujur dalam satu pandangan: pengguna memiliki akses apa, sampai kapan, dan tindakan apa yang paling tepat. Kartu bukan bukti pembayaran, melainkan ringkasan hak akses yang bersumber dari data server.

Produk diberi nama **Pro**. Trial adalah cara mencoba Pro, bukan tier yang lebih rendah.

## Keputusan Produk Yang Dikunci

1. Badge utama selalu `PRO` saat akses trial atau berbayar sedang aktif.
2. Trial ditandai dengan penanda sekunder `MASA COBA · N HARI`, bukan badge `TRIAL` yang menggantikan Pro.
3. Trial berdurasi 1, 3, atau 7 hari dan mulai pada pembukaan AI pertama, bukan pada saat akun dibuat.
4. Akses trial dapat memiliki batas penggunaan tambahan hanya bila aturan produk menetapkannya secara eksplisit. Jika batas pertanyaan tetap dipakai, kartu harus menampilkan kedua batas dengan jelas; jika tidak, hapus batas itu agar tidak membingungkan.
5. Status akses adalah keputusan server. Aplikasi hanya merender state yang sudah divalidasi.
6. Pada beberapa AI dengan tanggal berakhir berbeda, kartu menampilkan tanggal akses yang paling dekat berakhir; rincian per AI berada di Kelola Langganan.

## Kontrak Data

### Hak akses per AI

Setiap entitlement harus memiliki data berikut:

| Field | Arti |
|---|---|
| `plan` | asal akses, misalnya trial, pro, voucher, hadiah, atau all access |
| `status` | active, pending, expired, revoked, failed, atau cancelled |
| `startedAt` | waktu akses dimulai |
| `expiry` | waktu akses berakhir, null hanya untuk akses permanen |
| `trialDurationDays` | 1, 3, atau 7 bila entitlement adalah trial |
| `paymentStatus` | none, pending, paid, failed, refunded, atau cancelled |
| `sourceTransactionId` | identitas transaksi bila tersedia |

Migrasi harus menjaga entitlement lama. Data tanpa `startedAt` atau `trialDurationDays` tidak boleh dianggap trial aktif; ia memakai aturan legacy yang aman sampai server menyelesaikan normalisasi.

## Mesin Status Tampilan

| State | Syarat | Badge dan isi | CTA |
|---|---|---|---|
| `activePro` | entitlement berbayar aktif | `PRO`, cakupan AI, tanggal akhir | Kelola langganan |
| `activeTrial` | trial aktif dan belum melewati expiry | `PRO`, `MASA COBA`, sisa hari | Pilih paket Pro |
| `expiringSoon` | akses aktif tersisa 3 hari atau kurang | `PRO`, peringatan waktu yang tenang | Perpanjang Pro |
| `cancelledActive` | pembatalan tercatat tetapi expiry belum lewat | `PRO`, berakhir pada tanggal | Aktifkan lagi |
| `paymentPending` | transaksi dibuat dan belum tervalidasi | Menyiapkan akses Pro | Lihat status pembayaran |
| `paymentFailed` | pembayaran gagal atau kedaluwarsa | Akses belum aktif | Coba pembayaran lagi |
| `locked` | tidak ada entitlement aktif | kartu tertutup | Aktifkan Pro |
| `permanent` | entitlement tanpa expiry yang sah | `PRO`, akses permanen | Kelola akses |
| `offlineUnknown` | status baru tidak dapat diambil | Memeriksa akses | Coba lagi |

Urutan resolusi: revoked/refunded menutup akses, lalu pending/failed transaksi, lalu entitlement aktif, lalu legacy aktif yang tervalidasi, lalu locked. Satu pengguna hanya mendapat satu state ringkasan utama.

## Aturan Ringkasan AI

| Cakupan | Baris utama | Baris pendukung |
|---|---|---|
| Semua akses | Seluruh asisten OpenTurath | Paket semua akses |
| Satu AI | Fikih Syafii | 1 asisten aktif |
| Dua AI | Fikih Syafii dan Hadis | 2 asisten aktif |
| Tiga atau lebih | 3 asisten aktif | Fikih Syafii, Hadis, dan +1 lainnya |

Nama AI tidak pernah dipaksakan melampaui dua baris. Detail lengkap, status, dan tanggal per AI tetap tersedia setelah tombol Kelola Langganan ditekan.

## Aturan Waktu

1. Semua perhitungan memakai waktu server dan dikirim sebagai timestamp.
2. Tampilkan tanggal lokal pengguna; untuk sisa waktu gunakan bahasa relatif: Hari ini, Besok, atau 3 hari lagi.
3. Jika semua entitlement memiliki expiry sama, labelnya `BERLAKU HINGGA`.
4. Jika expiry berbeda, labelnya `AKSES TERDEKAT BERAKHIR`.
5. Akses tanpa tanggal berakhir memakai `AKSES PERMANEN`.
6. Ambang peringatan adalah tiga hari. Peringatan tidak memakai warna alarm kecuali akses sudah habis.

## Desain Kartu

### Kartu terbuka

- Badge `PRO` berada di kanan atas.
- Trial memakai chip sekunder kecil `MASA COBA · 3 HARI`.
- Simbol monokrom `☺` sebagai aksen status aktif.
- Area AI menampilkan cakupan akses dengan aturan ringkasan di atas.
- Detail identitas tetap ringkas; email dimasking, misalnya `udin…@gmail.com`.

### Kartu terkunci

- Siluet kartu Pro tetap terlihat, tetapi isi sensitif tidak dapat dibaca.
- Tirai gelap semi-transparan berada di atasnya.
- Simbol monokrom `☹`, judul `Akses Pro belum aktif`, dan kalimat `Aktifkan langganan untuk membuka asisten kajian pilihanmu.`
- CTA tunggal: `Aktifkan Pro`.
- Pengaturan akun tidak pernah ikut dikunci.

### Animasi status

Hanya dijalankan ketika stream entitlement mengonfirmasi perubahan state, bukan saat halaman dibuka ulang.

1. Terkunci ke aktif: tirai memudar dan bergerak 12 px ke atas selama 420 ms.
2. Simbol `☹` mengganti ke `☺` melalui crossfade dan scale ringan.
3. Badge, cakupan AI, dan masa berlaku muncul berurutan dengan jeda sangat singkat.
4. Satu haptic ringan setelah state aktif benar-benar diterima.
5. Mode Reduce Motion mengganti semuanya dengan fade 150 ms tanpa perpindahan posisi.

Tidak memakai konfeti, getaran berat, atau animasi berulang.

## Todo Eksekusi

### Fase 0  Kontrak dan aturan bisnis

- [ ] Tetapkan apakah trial juga memakai batas pertanyaan atau hanya batas hari.
- [ ] Tetapkan durasi trial yang tersedia dan apakah setiap akun hanya menerima satu trial.
- [ ] Tetapkan aturan voucher, hadiah, refund, pembatalan, dan akses permanen.
- [ ] Tetapkan ambang `expiringSoon` tiga hari.
- [ ] Tambahkan definisi state dan prioritasnya pada backend serta dokumentasi.

### Fase 1  Data dan backend

- [ ] Tambahkan metadata trial dan pembayaran ke entitlement.
- [ ] Buat normalisasi entitlement lama yang aman.
- [ ] Pastikan webhook pembayaran membuat `pending` lalu mengubahnya menjadi `active` hanya setelah validasi pembayaran.
- [ ] Pastikan refund atau revoke menutup akses dari server.
- [ ] Tambahkan pengujian resolusi state dan perhitungan expiry dengan waktu server.

### Fase 2  Model aplikasi

- [ ] Tambahkan enum state tampilan kartu, jangan gunakan boolean aktif/tidak aktif.
- [ ] Buat resolver tunggal dari `UserModel` menjadi ringkasan kartu.
- [ ] Buat resolver daftar AI dan resolver expiry terdekat.
- [ ] Tambahkan pengujian: satu AI, dua AI, banyak AI, semua akses, tanggal berbeda, voucher, dan legacy data.

### Fase 3  Kartu Pro

- [ ] Ganti label lama menjadi Pro.
- [ ] Buat varian open, trial, expiring, pending, failed, permanent, dan locked.
- [ ] Terapkan masking email dan teks akses yang tidak overflow pada layar sempit.
- [ ] Buat CTA sesuai state, termasuk navigasi ke paket atau detail transaksi.
- [ ] Tambahkan semantics layar pembaca dan kontras yang memadai pada kartu gelap.

### Fase 4  Kelola Langganan

- [ ] Tampilkan daftar AI aktif dengan tanggal dan status masing-masing.
- [ ] Bedakan paket semua akses dengan pembelian per AI.
- [ ] Tampilkan transaksi pending atau gagal tanpa mengklaim akses aktif.
- [ ] Sediakan tindakan perpanjang, aktifkan lagi, atau bayar ulang sesuai state.

### Fase 5  Motion dan verifikasi

- [ ] Hubungkan animasi hanya pada transisi state yang tervalidasi.
- [ ] Hormati Reduce Motion dan skala teks besar.
- [ ] Uji mode terang/gelap, layar kecil, nama panjang, dan email panjang.
- [ ] Uji offline, refresh status gagal, dan perubahan akses dari perangkat lain.
- [ ] Uji akses server untuk memastikan tampilan lokal tidak dapat membuka AI tanpa entitlement valid.

## Definition of Done

- Semua state di tabel dapat direproduksi dengan test data.
- Trial 1, 3, dan 7 hari menampilkan waktu yang benar dengan zona waktu pengguna.
- Pengguna dengan beberapa AI tidak pernah menerima tanggal akhir yang menyesatkan.
- Kartu terkunci mengarahkan pengguna tanpa mempermalukan atau mengganggu pengaturan lain.
- Pembayaran pending tidak memberikan akses sebelum server mengonfirmasi.
- Semua varian lolos pengujian model, widget, aksesibilitas, dan uji perangkat.
