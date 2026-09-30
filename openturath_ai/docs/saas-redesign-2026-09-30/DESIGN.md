# OpenTurath — arah workspace SaaS

Status: usulan yang diwujudkan dalam prototipe lokal. Dokumen ini berlaku untuk `prototype/`; bukan persetujuan penerapan seluruh UI Flutter dan bukan pengganti diam-diam `DESIGN.md` workspace.

## Struktur yang dibangun

OpenTurath bekerja sebagai alat kajian: pengguna memilih asisten, mencari kitab, memeriksa metadata, dan membuat catatan. Identitas terlihat pada merek asli, teks Arab dan isi katalog. UI memakai tata bahasa aplikasi kerja yang familiar.

```text
Desktop
┌──────────────────────┬──────────────────────────────────────────┐
│ OpenTurath           │ Pustaka / Fikih Syafi’i                   │
│ Cari kitab           ├───────────────────────────┬──────────────┤
│ Asisten              │ Judul + jumlah katalog    │              │
│ Pustaka              │ Pencarian / filter / urut │ Detail kitab │
│ Catatan              │                           │ setelah      │
│                      │ Daftar kitab              │ dipilih      │
│ Katalog Fikih Syafi’i │                           │              │
│                      │ Pagination                │              │
│ Akun & koneksi       │                           │              │
└──────────────────────┴───────────────────────────┴──────────────┘

Ponsel: header → tugas → pencarian/filter → baris kitab → navigasi bawah.
Detail menggantikan daftar; tombol kembali menjaga filter dan halaman.
```

Tidak ada hero, slogan, bingkai sampul buatan, angka aktivitas, judul serif dekoratif, atau kartu berulang sebagai struktur utama. Detail tetap dapat ditutup dengan Escape pada desktop. Pengarang dan judul panjang mendapat pemenggalan maksimal dua baris dalam daftar, dengan teks lengkap pada detail.

## Bahasa visual aktual

- Permukaan utama putih, sidebar abu ringan. Mode gelap menggunakan lapisan netral yang sama.
- Biru #0066cc untuk tindakan, pilihan dan fokus. Warna tidak dipakai sebagai dekorasi isi.
- Inter lokal untuk UI Latin; Noto Sans Arabic lokal untuk metadata Arab. Lisensi OFL disertakan. Naskah ilmiah pada aplikasi asli tidak diganti oleh prototipe.
- Judul halaman 24 px; isi UI 14 px; label/metadata 12–13 px. Judul Arab daftar 17 px, detail 20 px, tinggi baris 1.9. Teks Arab tidak memakai tracking Latin.
- Jarak mengikuti langkah 4 px. Kontrol 6 px, editor 8 px. Daftar memakai separator; shadow hanya untuk umpan balik toast.
- Ikon SVG kecil dengan stroke seragam. Ikon kitab berada dekat sisi awal pembacaan judul Arab. Tidak ada badge status akun rekaan.

Token warna, tipe dan layout tersedia di `design-tokens.json`; implementasi CSS di `prototype/workspace.css` adalah sumber render yang diuji.

## Perilaku dan perangkat

Pada desktop, sidebar 224 px tetap terlihat. Daftar memiliki judul, pengarang, tahun wafat dan jumlah jilid; panel detail 320 px muncul sesuai pilihan. Pada tablet kolom pengarang masuk ke baris kitab agar teks tidak menyempit. Pada lebar <=1100 px, detail menjadi halaman tersendiri. Pada lebar <=760 px, sidebar diganti navigasi bawah dan tabel ditata sebagai baris vertikal.

Katalog memakai 12 baris per halaman dari 87 metadata asli, bukan hasil buatan. Pencarian Arab mengabaikan harakat dan variasi alif. Filter, urutan, halaman dan detail tersimpan pada hash URL. Catatan terpilih juga mendapat URL; data catatan disimpan lokal dan dipisahkan dari akun aplikasi. Detail metadata bukan bukti kitab telah terpasang dalam NotebookLM.

## Penilaian dan batas

Penilaian teknis dan visual aktual tersedia di `VERIFICATION.md`. Tidak ada klaim estetika diterima oleh pengguna atau studi usability telah dilakukan. Di iterasi ini satu kesalahan lebar label pada ponsel ditemukan saat konfirmasi, dikoreksi, lalu diperiksa khusus kembali. Tidak ada putaran polish tanpa akhir.

Tradeoff: daftar memungkinkan perbandingan lebih cepat tetapi tidak memuat sampul; judul sangat panjang tetap perlu dibuka. Ponsel menampilkan lebih sedikit baris demi keterbacaan pengarang dan judul Arab. Control border netral halus belum diaudit penuh terhadap seluruh persyaratan WCAG non-teks; hasil pengukuran kontras di VERIFICATION hanya untuk pasangan teks yang disebutkan.

NotebookLM tetap diperlukan. Pratinjau hanya menunjukkan posisi dan alur masuk menuju ruangnya. Penyatuan login Firebase dan NotebookLM belum dibuktikan; arsitektur sesi browser tetap harus dituntaskan pada runtime asli.

Untuk penerapan Flutter, pindahkan token dan pola komponen setelah arah ini ditinjau, lalu verifikasi seluruh alur pada aplikasi sebenarnya. Jangan menyimpulkan hasil widget test atau build sebagai penerimaan visual.
