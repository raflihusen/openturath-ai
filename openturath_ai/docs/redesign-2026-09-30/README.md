# OpenTurath: usulan ruang telaah dan perbaikan login

Tanggal: 30 September 2026. Branch kerja: `codex/redesign-auth-2026-09-30`.

**NotebookLM tetap wajib.** Mesin asisten tidak diganti. Hasil UI di folder ini adalah pratinjau interaktif yang terpisah dari UI produksi Flutter. Perubahan produksi pada tahap ini terbatas pada jalur autentikasi dan penghapusan intervensi halaman keamanan Google.

## Arah desain

OpenTurath perlu terasa seperti ruang kerja kajian yang tenang: masuk, pilih bidang, telaah di NotebookLM, periksa rujukan, lalu simpan catatan. Sasaran utamanya pembaca turats dan peneliti yang memakai teks Arab bersama antarmuka Indonesia.

- Navigasi utama: **Ruang kajian, Pustaka, Catatan, Akun**. Desktop memakai navigasi tetap; ponsel memakai empat tujuan pada navigasi bawah.
- Judul, konteks, dan satu tindakan utama mudah ditemukan. Daftar ruang kajian mengutamakan bidang ilmu; banner teknis tidak menutupi halaman Google atau NotebookLM.
- Pustaka menampilkan judul Arab, pengarang, pengenal edisi, dan metadata. Catatan mengenai suatu kitab tidak otomatis dianggap kutipan atau bukti bahwa kitab itu sudah dimasukkan ke NotebookLM.
- Logo OpenTurath dipertahankan. Warna yang diusulkan: kertas hangat `#faf9f5`, tinta `#242c29`, hijau tindakan `#244d41`. Ini usulan baru, bukan perubahan token produksi yang sudah diterapkan.
- Inter dipakai untuk kontrol dan teks Latin; font Arab lokal dipakai untuk isi Arab. Newsreader terbatas pada judul editorial. Ukuran, kontras, dukungan keyboard, dan susunan pada ponsel harus dinilai bersama tampilannya.
- Catatan memiliki draf yang bertahan saat pindah layar. Akun OpenTurath dan koneksi NotebookLM memiliki status yang dapat dibedakan; keberhasilan Firebase tidak diberi label keberhasilan NotebookLM.

Detail yang memberi identitas ialah kitab dan konteks edisinya, bukan hiasan atau statistik aktivitas buatan. Pratinjau tidak mengarang jawaban asisten atau mengutip isi kitab yang belum tersedia.

## Buka pratinjau

Server yang dijalankan pada sesi ini: <http://127.0.0.1:8793/>. Jika server sudah berhenti, jalankan:

```sh
cd /Users/apple/Downloads/ramadhan/openturath_ai
python3 -m http.server 8793 --bind 127.0.0.1 --directory docs/redesign-2026-09-30/prototype
```

Buka alamat tersebut melalui browser. Membuka `index.html` langsung sebagai file dapat menghalangi pemuatan JSON katalog.

Yang dapat dicoba:

1. Pilih ruang kajian untuk melihat rancangan area NotebookLM.
2. Buka Pustaka; cari judul/pengarang Arab, gunakan filter periode, lalu buka metadata kitab.
3. Dari metadata, buat catatan. Ketik draf, pindah layar, lalu muat ulang untuk memeriksa penyimpanannya.
4. Simpan catatan, buka kembali dari daftar, dan buat catatan baru.
5. Buka Akun untuk melihat rancangan login yang secara eksplisit bersifat simulasi.
6. Ubah terang/gelap, pakai keyboard, atau kecilkan ukuran browser.

Katalog berisi **87 record asli** yang disalin dari `assets/data/01_KATALOG_FIKIH_SYAFII.json`. Record, pengarang, halaman, dan tahun tersebut mengikuti data aplikasi; keberadaan di katalog belum merupakan validasi bibliografi independen. Nilai yang belum tersedia ditandai. Logo dan tiga font beserta lisensinya berasal dari aset aplikasi.

Nama “Pengguna demo” serta catatan uji adalah data pratinjau. Catatan memakai kunci penyimpanan browser khusus `openturath-design-20260930-*`, terpisah dari data akun aplikasi. Pratinjau tidak memuat Firebase SDK, iframe NotebookLM, RPC, atau formulir kredensial.

## Bukti tampilan

Screenshot berasal dari pratinjau yang dijalankan dan dioperasikan, bukan gambar hasil generasi:

| Artefak | Keadaan yang diperiksa |
| --- | --- |
| [Desktop ruang kajian](screenshots/01-desktop-workspace.png) | Navigasi, bidang kajian, dan pilihan kitab |
| [Metadata desktop](screenshots/02-desktop-book-metadata.png) | Identitas kitab, pengarang, penerbit, dan edisi Arab |
| [Ruang NotebookLM desktop](screenshots/03-desktop-notebook-layout.png) | Usulan area telaah beserta rujukan; koneksi belum berjalan |
| [Pencarian pustaka](screenshots/04-desktop-library-search.png) | Pencarian Arab nyata pada katalog |
| [Ponsel 390 px](screenshots/05-mobile-workspace.png) | Navigasi bawah dan pencarian tetap tersedia |
| [Metadata ponsel](screenshots/06-mobile-book-metadata.png) | Teks Arab membungkus, angka jilid/halaman memakai arah Latin |
| [Catatan gelap](screenshots/07-mobile-notes-dark.png) | Catatan uji campuran Latin/Arab dapat dibuka kembali |
| [Login 360 px](screenshots/08-mobile-login-proposal.png) | Rancangan masuk tidak menyamar sebagai autentikasi nyata |
| [Tablet 768 px](screenshots/09-tablet-notebook-layout.png) | Susunan panel dan fokus keyboard ke isi layar |

Pemeriksaan mencakup navigasi kajian → metadata → area NotebookLM → pustaka → catatan → akun, pencarian tanpa hasil, dialog lewat Escape, dan draf setelah navigasi/muat ulang. Ini bukti kualitas pratinjau HTML. Ini belum merupakan penerimaan visual aplikasi Flutter atau bukti login NotebookLM berhasil.

## Urutan implementasi yang disarankan

1. **Tetapkan wadah NotebookLM.** Keputusan tentang browser yang didukung menentukan apakah target satu autentikasi Google dapat dicapai. Lihat [analisis login](AUTH_INTEGRATION.md).
2. **Nilai layar perwakilan ini.** Setelah arah disepakati, terapkan sistem navigasi dan token tampilan pada wadah yang dipilih. Periksa layar nyata sebelum menyebarkan perubahan ke seluruh aplikasi.
3. **Buktikan login dan pembukaan notebook.** Uji satu akun dan beberapa akun, profil browser, izin notebook, mulai ulang, dan keluar akun. Tidak cukup hanya melihat Firebase berhasil.
4. **Migrasikan pustaka dan catatan.** Pertahankan metadata, pencarian Arab, status kosong/gagal, draf, dan isolasi data per akun. Integrasi sumber harus mengikuti kemampuan NotebookLM yang benar-benar tersedia.
5. **Periksa alur lengkap pada perangkat.** Desktop dan ponsel, keyboard, teks Arab panjang, pembesaran teks, terang/gelap, jaringan gagal, serta sesi kedaluwarsa. Baru sesudah itu menyiapkan paket distribusi.

Layar konseptual dengan NotebookLM di tengah belum membuktikan bahwa situs Google boleh atau dapat dimasukkan ke iframe milik OpenTurath. Browser, PWA, dan WebView memiliki kemampuan berbeda; bentuk akhir layar telaah mengikuti hasil uji integrasi, bukan dipaksakan dari mockup.

## Hasil perubahan kode

- Login desktop memakai `AuthService.signInWithGoogle()` dan jalur browser sistem yang sudah tersedia, bukan dialog OAuth WKWebView.
- Pembukaan halaman login memakai domain Firebase Hosting yang sama dengan `authDomain` untuk mengurangi ketergantungan pada penyimpanan helper lintas domain saat redirect.
- Handler callback tetap memakai POST ke loopback, state sekali pakai, dan pemeriksaan origin. Tes menolak domain hosting lain, domain tiruan, port lain, serta state salah.
- Token Google yang dipakai untuk Firebase tidak lagi menulis penanda “sesi NotebookLM siap”.
- Pengisian email, klik tombol Google otomatis, dan penulisan ulang URL challenge di ruang asisten aktif serta jalur lama dihapus.
- Teks login desktop dalam Indonesia, Inggris, dan Arab menjelaskan penggunaan browser yang sebenarnya.

Jalur lama `DesktopInAppAuthDialog` masih ada sebagai kode yang tidak dipanggil layar login. Jalur `GoogleSessionAuthScreen` juga belum dimigrasikan. Keberadaan keduanya tidak boleh dipakai untuk menyatakan integrasi NotebookLM sudah diperbaiki menyeluruh. Tidak ada perubahan pada halaman hosting yang disebarkan dari pekerjaan ini.

Petunjuk checkpoint: [RESTORE.md](RESTORE.md). Status satu login: **belum selesai**, menunggu keputusan wadah dan verifikasi autentikasi nyata.
