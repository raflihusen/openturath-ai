> Arsip revisi sebelumnya. Status terbaru ada pada AUDIT_WEBSITE_V4.md dan BROWSER_QA.json.

# OpenTurath · Revisi desain V2

Tanggal: 20 September 2026.

## Yang berubah

- Beranda dibangun ulang dengan komposisi split, visual buku tiga dimensi, kartu kutipan melayang, dan ritme bagian terang/gelap.
- Hierarki font ditata ulang: judul utama besar, aksen serif, judul bagian yang konsisten, teks baca, dan metadata yang dibedakan. Inter, Cormorant, dan Amiri disertakan lokal.
- Pengalaman sumber interaktif tiga tahap: pertanyaan asli, teks rujukan, dan konteks bibliografi. Tab mendukung keyboard; konten tetap tersedia tanpa JavaScript.
- Empat pintu masuk pustaka disajikan sebagai sampul buku. Katalog penuh mendapat kartu dan panel pencarian baru.
- Bagian perbandingan menampilkan enam keluaran asli, diikuti metode penelaahan, Fikih Tahawwulat, akses, FAQ, dan ajakan unduh.
- Halaman dalam, navigasi, breadcrumb, filter, panel jawaban, dialog, formulir, dan footer mendapat lapisan desain bersama.
- Tata letak Indonesia, English, Arab RTL, layar kecil, mode gelap, dan preferensi reduced motion didukung.

## Isi yang dipertahankan

160 halaman HTML; 20 koleksi; tujuh halaman bibliografi; enam jawaban lengkap Q001; sepuluh panel kutipan; arsip asli beserta pemeriksaan hash; backend laporan privat; konfigurasi unduh, rilis, dan deploy. Visual buku merupakan dekorasi, bukan scan sumber.

Teks perbandingan tetap berdasarkan arsip pengguna. Status penelaahan sumber tidak diubah menjadi terverifikasi. Angka akurasi universal 100% tidak ditambahkan karena arsip yang tersedia belum membuktikannya.

## Verifikasi V2

- Build preview berhasil: 160 HTML, 20 koleksi, enam jawaban asli.
- Pemeriksa situs: 159 halaman berbahasa, 8.214 tautan/aset lokal, seluruh terjemahan, enam hash arsip, sepuluh kutipan; tanpa error.
- Delapan pengujian Node dan sebelas pengujian Python lulus, termasuk build produksi terisolasi memakai fixture.
- Beranda Indonesia desktop dan workbench diperiksa di browser; pergantian tab menampilkan panel terkait.
- Beranda Indonesia diperiksa pada frame ponsel 390/320 px; lebar konten efektif 375/305 px tanpa overflow horizontal pada pengukuran tersebut.
- Beranda Arab diperiksa visual pada frame ponsel 390/320 px; panel sumber Arab dan navigasi keyboard tab diperiksa melalui DOM browser.
- Katalog baru diperiksa visual; pencarian Arab berharakat menghasilkan dua hasil.
- Q001 diperiksa visual; URL dengan `right=nur` memulihkan pilihan Nur AI.
- Reviewer kode terpisah memeriksa lokalisasi, wiring, aksesibilitas, dan alur. Temuan fokus keyboard yang kurang kontras pada bagian gelap sudah diperbaiki.
- Ukuran hasil build yang aktual ada di ASSET_SIZES.json. Gambar buku lokal sekitar 106 KB; tidak ada ketergantungan pada host gambar eksternal.

Pemeriksaan ini tidak mencakup audit aksesibilitas formal, semua browser/perangkat fisik, metrik performa produksi, ataupun verifikasi independen keilmuan. Catatan QA sebelumnya disimpan sebagai riwayat dalam QA.md.

## Menjalankan dan mempublikasikan

Ekstrak ZIP, buka START_HERE.html, lalu jalankan `npm run dev`. Build jadi ada di dist. Kode tidak memerlukan npm install.

Paket tetap preview noindex sampai data resmi dilengkapi. Domain, identitas/kontak pengelola, URL dan metadata rilis aplikasi, ketentuan akses, serta persetujuan konten belum diisi dengan fakta final. Ikuti CONFIGURATION.md dan DEPLOYMENT.md. Tombol unduh menuju halaman unduhan, yang menampilkan keadaan sesuai data rilis yang tersedia.
