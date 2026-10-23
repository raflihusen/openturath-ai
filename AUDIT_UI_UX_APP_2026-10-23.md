# Audit UI, UX, dan Copywriting OpenTurath AI (23 Oktober 2026)

Metode: analisis statis (`flutter analyze`: bersih), 431 uji unit, tangkapan layar nyata semua layar utama lewat `test/visual/render_screens_test.dart` (ID, EN, AR, terang, gelap, 320 sampai 1440 px), dan pemeriksaan otomatis katalog terjemahan (800 entri). Tidak diuji: alur Firebase, Midtrans, dan WebView pada perangkat sungguhan.

## A. Sudah diperbaiki (UI pembayaran dan sekitarnya)

| # | Temuan | Perbaikan |
|---|---|---|
| 1 | Banner hitung mundur setinggi sekitar 118 px, mendominasi layar sebelum harga terlihat | Dipadatkan jadi sekitar 70 px: judul di kiri, angka di kanan (lebar), atau judul lalu angka rata kiri (sempit) |
| 2 | Pilihan masa akses: tinggi segmen tidak sama (baris "Hemat" hanya ada pada sebagian), tulisan "Hemat 44% dari bulanan" menyentuh tepi | Baris hemat selalu disediakan, teks jadi "Hemat 44%" |
| 3 | Tombol bayar memakai `FittedBox` sehingga huruf mengecil tak terkendali, dan harga tampil tiga kali | Baris "Total · 12 Bulan  Rp ..." lalu satu tombol "Lanjut ke pembayaran" |
| 4 | Tidak ada tautan Ketentuan Layanan dan kebijakan pembayaran sebelum membayar, padahal dokumen hukum menyebut informasi itu ditampilkan sebelum pembelian | Kalimat persetujuan dengan dua tautan di bawah tombol |
| 5 | Teks tiga bahasa tertanam di widget (lencana paket, pemuat, banner), tidak lewat katalog | Dipindah ke katalog `copyCatalog` (23 kunci baru) |
| 6 | Layar sukses di lembar bayar memantul (`elasticOut`), memakai "Alhamdulillah" dan lencana berbeda dari dialog sukses | Satu gerak tenang, tanpa ungkapan keagamaan di antarmuka, lencana sama dengan dialog sukses, menghormati "kurangi animasi" |
| 7 | Pemeriksaan pembayaran otomatis berhenti diam-diam setelah 5 menit | Muncul catatan "Belum terdeteksi? Ketuk ikon segarkan" |
| 8 | Pesan galat kode voucher selalu berbahasa Indonesia, juga untuk pengguna EN dan AR | Enam pesan dilokalkan |
| 9 | Teks: "..." (tiga titik) dan "…" tercampur pada empat string ID; EN "Close payment page" tanpa tanda tanya | Diseragamkan |
| 10 | Tes banner bergantung pada waktu sebenarnya, tiga tes gagal sejak penawaran dimulai | Jam dapat disuntikkan, ditambah tes keadaan berlangsung dan berakhir |
| 11 | Profil: "Hapus akun" menempel di bawah "Keluar" dengan warna sama | Dipisah ke kartu sendiri dan diberi warna peringatan (konfirmasi dialog sudah ada) |

## B. Temuan terbuka, urut prioritas

**Tinggi**
1. **Warna merah banner vs aturan monokrom.** `AGENTS.md` aturan 9 melarang aksen warna, sedangkan banner merah solid adalah keputusan desain peluncuran sebelumnya. Perlu keputusan Pemilik: tetap merah atau hitam-putih.
2. **Dashboard: empat dari enam kartu bidang bertuliskan "Belum tersedia"** dengan bobot visual sama seperti yang tersedia. Pengguna baru menangkap kesan produk kosong. Saran: tampilkan yang tersedia lebih dulu, kelompokkan sisanya sebagai "Segera hadir" yang lebih redup dan lebih kecil.
3. **Daftar AI: kartu "Belum tersedia" setinggi sekitar 160 px**, sehingga untuk sampai ke AI berikutnya perlu menggulir panjang. Saran: baris ringkas satu baris.

**Sedang**
4. **Kartu kalender di Beranda** memakan sekitar 180 px di ponsel di atas pencarian dan bidang. Saran: ringkas satu baris atau pindahkan ke bawah.
5. **Tombol ikon tanpa label** pada kartu AI (obrolan dan buku) dan pemilih tema (ikon "A" tidak jelas artinya). Tambahkan label atau tooltip yang terlihat.
6. **Masuk (Login):** kolom kiri sangat lengang di desktop. Label statistik "pustaka bidang ilmu" dan "entri kitab" terdengar kaku. Saran: "bidang ilmu" dan "kitab".
7. **Dua sistem desain berdampingan** di lembar bayar (`AppTheme.*` dan `OTColors`/`OTExpressive`), dan ratusan kunci terjemahan berupa hash (`ui_56a2f9f730`) yang tak terbaca. Menyulitkan pemeliharaan dan peninjauan terjemahan.
8. **Glif ﷺ** tampil sebagai kotak kosong pada tangkapan layar pengantar Fikih Tahawwulat. Mungkin hanya akibat font tes, tetapi perlu dipastikan di perangkat.

**Rendah**
9. Deteksi sukses pembayaran memakai kecocokan substring ("success", "callback") pada URL dan teks halaman. Aman karena hanya memicu pemeriksaan ke server, tetapi rapuh bila gateway mengubah teksnya.
10. 24 `debugPrint` dan satu `print` pada jalur autentikasi.
11. Penggunaan tombol Material mentah di 56 tempat (uji pelindung hanya mencakup `styleFrom` pada layar).
12. Tes visual `render_screens_test.dart` basi: mencari tombol "Pilih bidang" yang kini berlabel lain, sehingga berhenti di tengah.

## C. Hal yang sudah baik
- Tanpa warna Material liar di luar token, tanpa TODO, tanpa tanda seru pada teks, placeholder terjemahan sejajar di seluruh katalog.
- Alur galat memiliki layar khusus dengan tombol "Coba lagi" dan "Kembali".
- Dialog sukses dan tampilan profil rapi, konsisten, dan terbaca di ketiga bahasa.
