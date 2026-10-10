# Hasil implementasi dan deployment otomasi akses

**Koreksi insiden 10 Oktober 2026:** empat pencabutan yang dicatat di bawah ternyata salah karena migrasi mengabaikan bonus pemilik dan transfer paket. Dua pelanggan masih berhak; seluruh akses telah dipulihkan. Pencabutan otomatis dibekukan. Lihat [laporan insiden dan pemulihan](INSIDEN_PENCABUTAN_SALAH_2026-10-10.md). Angka dan penilaian di bawah adalah snapshot sebelum koreksi, bukan status akhir kelayakan akses.

Tanggal pemeriksaan: 9 Oktober 2026. Ini adalah catatan hasil nyata, bukan jaminan bahwa semua kemungkinan kegagalan telah tertutup.

## Status produksi

- VPS `43.156.83.60`, akun `ubuntu`, layanan `openturath-access.service`: enabled dan active. Worker memakai Node 22, berjalan sebagai pengguna biasa dengan pembatasan systemd dan kredensial Firestore tersendiri.
- Penulis akses tunggal: `/access_control/runtime.writer = vps-v2`. Checkpoint worker terakhir: `80f0ba6`. Penulis lama di Cloud Run, reaper lokal, dan fungsi provisioning lama telah diberi koordinasi untuk menghindari perubahan izin bersamaan.
- Cloud Run `openturath-subscription`: revisi `00036-hux` menerima 100% traffic. Revisi sebelumnya dipertahankan untuk pemulihan yang terkoordinasi.
- Backend Firebase untuk pembayaran, resolver notebook, onboarding, dan handoff telah diterapkan. Rekonsiliasi Midtrans berjalan setiap 5 menit; pemeriksaan kesehatan setiap 1 menit.
- Pemantauan terakhir: `healthy`, tanpa masalah yang tercatat. Pengiriman Telegram belum diaktifkan karena izin mengirim pesan belum diterima. Pemantauan tanpa pesan sudah berjalan.
- Sesi NotebookLM memakai akun pemilik yang diizinkan: `raflimaulan@gmail.com`. Pemulihan sesi otomatis telah berhasil dalam pemeriksaan nyata dengan pembatasan layanan produksi.

## Alur yang sekarang diterapkan

1. Pembayaran Midtrans diperiksa melalui status resmi penyedia, identitas pesanan, nilai pembayaran, dan mata uang. Status webhook saja tidak cukup untuk menerbitkan hak.
2. Setiap pembayaran menghasilkan bukti hak yang unik; pengiriman webhook berulang tidak menambah durasi lagi. Hak dievaluasi per modul. VIP permanen mendapat perlindungan tersendiri, termasuk ketika profil biasa hilang.
3. Reservasi kursi dilakukan dalam transaksi. Ambang masuk 1.995, batas keras 2.000, dengan anggota nyata dan reservasi yang belum selesai diperhitungkan. Ketika master penuh, allocator memilih cabang sehat yang tersedia. Ketika semua penuh, pelanggan menunggu kapasitas; tidak mendapat tautan notebook penuh secara asal.
4. Worker memberi izin Google, lalu membaca ulang sharing untuk memastikan alamat email yang tepat benar-benar hadir. Assignment baru menjadi siap setelah bukti tersebut ada.
5. Resolver mengembalikan UUID master/cabang tempat pelanggan benar-benar ditempatkan. Permintaan membuka notebook tidak membuat reservasi baru. Pelanggan lama yang belum dimigrasikan memakai bukti membership fisik, bukan tebakan berdasarkan UID.
6. Saat hak suatu modul berakhir, worker memeriksa ulang pembayaran, VIP, dan penahanan migrasi, lalu mencabut izin di seluruh target historis modul tersebut. Kursi dibebaskan hanya sesudah alamat email sasaran terverifikasi tidak hadir.
7. Kegagalan sementara masuk antrean retry. Perubahan hak saat pekerjaan berlangsung diperiksa lagi agar pembayaran baru tidak kalah oleh pekerjaan pencabutan lama. Rekonsiliasi pembayaran tetap berjalan walaupun aplikasi pelanggan ditutup atau webhook terlewat.

## Bukti pemeriksaan

| Pemeriksaan | Hasil |
| --- | --- |
| Pengujian backend terakhir | 91 lulus, 0 gagal |
| Build TypeScript | Selesai dengan exit 0 |
| Pemeriksaan Flutter terarah sebelumnya | 51 pengujian lulus; analyzer bersih |
| Notebook yang diinventarisasi | 346: 24 master, 312 cabang, 10 legacy; sharing tertutup teramati saat seed |
| Registry akhir | 339 active, 7 draining; draining tidak menerima alokasi baru |
| Assignment akhir | 49: 45 ready, 4 revoked |
| Pencabutan pelanggan nyata | 4 pekerjaan completed; seluruh sasaran dicek ulang langsung dan tidak lagi tercantum di Google |
| Antrean pekerjaan akses | 0 menunggu pada pemeriksaan akhir |
| Outbox lama | 78 completed, 6 v2_review; kasus gagal lama dipertahankan untuk peninjauan |
| Simulasi allocator 10.000 pengguna | Distribusi kursi 1.995 × 5 notebook dan 25 pada notebook berikutnya; tidak melampaui ambang |
| Koneksi Midtrans produksi | API status dapat dijangkau; pesanan uji yang tidak ada menghasilkan status resmi 404 |
| Pemantauan terjadwal | Cloud Scheduler enabled; dokumen monitor_health telah terisi healthy, notifikasi disabled |

Simulasi 10.000 pengguna bukan uji beban Firestore/Google nyata. Pemeriksaan membership membuktikan kondisi saat diperiksa, bukan jaminan layanan pihak ketiga tidak pernah gagal setelahnya.

## Temuan penting dari transaksi lama

Audit API GoAkal mendapatkan 178 transaksi: 74 PAID, 102 EXPIRED, 2 PENDING. Dari PAID, 46 bernilai positif dan 28 bernilai nol. Sebanyak 46 pembayaran positif terverifikasi diimpor secara idempoten; ledger juga memuat 5 hak VIP.

`expiryDate` GoAkal merupakan kedaluwarsa invoice, bukan masa berlangganan. Durasi sekarang direkonstruksi dari `paidAt`, paket yang diketahui, dan urutan pembayaran nyata. Bulanan menggunakan 30 hari dan tahunan kalender. Invoice EXPIRED yang belum dibayar tidak menjadi bukti hak. Pembayaran nol tidak memperpanjang otomatis.

Profil yang belum jelas tidak dipaksa masuk otomasi pencabutan: dari 15 profil, 1 telah managed, 9 mendapat hold, dan 5 belum managed. Ada 41 identitas pelanggan historis, 40 managed dan 1 belum managed. Hold adalah kebutuhan migrasi satu kali, bukan pelanggan baru yang harus dipantau manual selamanya. Dua identitas profil tidak ditemukan dalam Firebase Auth. Daftar kasus disimpan di access_reviews; tidak semua profil lama dapat dinyatakan selesai tanpa bukti tambahan.

## Pekerjaan yang belum dapat dinyatakan selesai

- Pembelian dan refund Midtrans nyata belum diuji menyeluruh. Pengujian backend, pemeriksaan kredensial, dan penjadwalan berhasil, tetapi belum ada transaksi uang nyata yang sengaja dibuat untuk acceptance test.
- Login pelanggan di perangkat nyata, master penuh lalu cabang, serta akses sesudah pencabutan belum diverifikasi melalui akun pelanggan. Tidak menggunakan identitas pelanggan tanpa izin.
- Perubahan Flutter masih lokal. APK baru tidak dibangun, diunggah, atau dibroadcast dalam pekerjaan ini; pengguna aplikasi lama belum otomatis menerima perubahan lokal.
- Webhook GoAkal baru disimpan pada `access_legacy_events` untuk verifikasi. Konsumen otomatis inbox tersebut belum diterapkan. Riwayat GoAkal sudah diaudit dan diimpor, tetapi pembayaran GoAkal baru tidak boleh diklaim telah otomatis diaktifkan oleh worker baru. Jalur otomatis pembayaran utama yang diterapkan adalah Midtrans.
- Sembilan hold migrasi dan enam outbox review membutuhkan penyelesaian bukti identitas/paket; akses yang belum terbukti tidak dicabut secara spekulatif.
- Belum ada uji beban 10.000 pelanggan terhadap provider nyata dan belum ada latihan pemulihan VPS dari backup pada mesin pengganti.
- Firebase deploy memperingatkan runtime Node 20 fungsi cloud akan dinonaktifkan untuk deployment setelah 30 Oktober 2026. Worker VPS sudah Node 22; runtime fungsi cloud masih perlu migrasi dan verifikasi tersendiri sebelum batas tersebut.
- Peringatan Telegram siap secara kode dan telah diuji dengan mock untuk retry/dedup, tetapi belum diizinkan ataupun diuji pengiriman nyata. Tanpa izin, status gangguan hanya tersimpan di Firestore.

## Backup dan pemulihan

Snapshot sebelum cutover disimpan terbatas di VPS dan salinan terpisah pada `/Users/apple/.codex/secure_backups/openturath-access-2026-10-09/`. Perubahan sumber diberi checkpoint Git. Salinan kredensial sementara yang dibuat selama deployment telah dibersihkan; kredensial layanan aktif dan bukti audit privat tetap dilindungi.

Untuk pemulihan, hentikan perubahan izin worker terlebih dahulu dan kembalikan build yang telah diketahui bekerja dengan koordinasi penulis tetap tunggal. Jangan mengganti writer menjadi mode lama secara buta: hal itu dapat menghidupkan kembali logika lama yang salah mencabut atau memperpanjang akses. Pemulihan data dari snapshot harus memperhitungkan pembayaran baru sesudah snapshot agar tidak menghapus hak yang sah. Prosedur ini belum dilatih pada VPS pengganti.
