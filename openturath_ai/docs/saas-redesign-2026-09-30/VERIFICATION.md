# Verifikasi prototipe — 30 September 2026

Lingkup: prototipe statis `prototype/`, dilayani lokal pada `http://127.0.0.1:8794/`. Interaksi dan screenshot dilakukan melalui browser Codex, bukan gambar mockup. Hasil ini tidak membuktikan alur Flutter, autentikasi Google, atau koneksi NotebookLM telah selesai.

## Data dan alur yang diperiksa

| Pemeriksaan | Hasil aktual |
| --- | --- |
| Katalog | 87 rekaman; salinan JSON identik dengan katalog sumber aplikasi. SHA-256: `479172aa97392b0d92d8cdbda31761262f1c1d5eb28d581d8ebbb9b9ca91bc4f`. |
| Pencarian `النووي` | 5 hasil tampil; detail Al-Majmu’ menampilkan metadata sumber, termasuk 9 jilid dan 4.878 halaman. Ini verifikasi kesesuaian data, bukan validasi ilmiah katalog. |
| Filter tahun wafat <=300 H | 4 hasil; sama dengan jumlah yang dihitung dari JSON. Distribusi ketiga rentang data: 4 / 17 / 66. |
| Pencarian tanpa hasil | Filter awal + `النووي`, serta teks `kitab-yang-tidak-ada`, menghasilkan keadaan kosong dengan tindakan reset. Reset mengembalikan katalog. |
| Pagination | 12 baris per halaman. Halaman terakhir menampilkan 85–87 dari 87, tiga baris, tombol berikutnya nonaktif. Reload mempertahankan halaman terakhir melalui URL. |
| Detail dan kembali | Metadata panjang terbaca pada detail desktop dan ponsel. Escape menutup detail desktop, mempertahankan pencarian, lalu mengembalikan fokus ke kitab yang dipilih. |
| Pencarian lintas halaman | Tombol Cari kitab membawa pengguna dari halaman lain ke pustaka dan memfokuskan input. |
| Catatan | Referensi kitab dapat dimasukkan ke editor dan disimpan lokal. URL catatan terpilih dan isi editor tetap pulih setelah reload. Catatan uji diberi konteks pengujian atau berisi referensi metadata sumber. |
| Mode gelap | Pustaka, editor catatan dan navigasi diperiksa secara visual. |
| Asisten dan koneksi | Pemilihan bidang menuju ruang yang menyatakan NotebookLM belum tersambung. Halaman akun menampilkan kedua koneksi belum aktif. Tidak ada simulasi sukses login atau jawaban AI. |
| Console browser | Pembacaan log error pada sesi pemeriksaan menghasilkan daftar kosong. Ini bukan audit semua kemungkinan kegagalan jaringan. |

## Responsivitas dan aksesibilitas terbatas

- Desktop 1280×720, tablet 768×1024, ponsel 390×844, dan ponsel sempit 360×780 diperiksa melalui render browser.
- Lebar dokumen diukur sama dengan viewport pada 1280, 390 dan 360 px. Tablet diperiksa secara visual. Judul Arab, pengarang panjang, filter, detail, editor, navigasi bawah dan keadaan kosong diperiksa pada ukuran relevan.
- Putaran visual pertama menemukan jarak ikon kitab dari judul Arab, kolom pengarang tablet yang menyempit, dan tautan pustaka yang belum menjaga keadaan terbaru. Setelah koreksi gabungan, pemeriksaan konfirmasi menemukan regresi lebar label tahun pada ponsel. Koreksi khusus terakhir (`dec60e6`) diperiksa kembali pada ponsel; screenshot pustaka ponsel diperbarui.
- Tab dari pencarian menuju filter menampilkan fokus yang terlihat. Escape pada detail terbukti bekerja. Percobaan shortcut Meta+K melalui alat browser mengalami timeout tanpa perubahan halaman; shortcut ini **belum terverifikasi**. Tombol pencarian tetap dapat digunakan.
- Kontrol utama ponsel dan pagination diukur 44 px. Beberapa tombol teks sekunder 40 px; tidak ada klaim seluruh target sentuh memenuhi 44 px.
- Font UI dan metadata Arab diperiksa melalui computed style. Tidak ada pengujian pembaca layar, zoom 200%, perangkat fisik, atau audit WCAG menyeluruh.

Pasangan kontras teks dihitung dari nilai warna CSS menggunakan luminansi relatif sRGB:

| Teks / permukaan | Rasio |
| --- | ---: |
| `#202124` / `#ffffff` | 16,10:1 |
| `#646871` / `#ffffff` | 5,58:1 |
| `#646871` / `#f8f9fb` | 5,30:1 |
| `#0066cc` / `#ffffff` | 5,57:1 |
| `#b0b5be` / `#18191c` | 8,54:1 |
| `#8cbdff` / `#18191c` | 9,07:1 |

Hasil tersebut hanya berlaku untuk pasangan yang disebutkan. Border kontrol terang yang halus belum memenuhi pembuktian kontras non-teks 3:1; perlu ditinjau pada tahap penerapan.

## Bukti visual

Semua berkas berikut berasal dari capture browser asli. API menghasilkan JPEG; ekstensi telah dikoreksi menjadi `.jpg` tanpa mengedit piksel atau melakukan encoding ulang. Full-page capture dapat lebih tinggi daripada viewport.

| Berkas | Dimensi | Isi |
| --- | --- | --- |
| [01-desktop-library.jpg](screenshots/01-desktop-library.jpg) | 1280×720 | Daftar pustaka desktop |
| [02-desktop-search-detail.jpg](screenshots/02-desktop-search-detail.jpg) | 1280×933 | Pencarian Arab dan detail kitab |
| [03-tablet-library.jpg](screenshots/03-tablet-library.jpg) | 768×1024 | Pustaka tablet dan fokus pencarian |
| [04-mobile-library.jpg](screenshots/04-mobile-library.jpg) | 390×844 | Pustaka ponsel setelah koreksi akhir |
| [05-mobile-detail.jpg](screenshots/05-mobile-detail.jpg) | 390×946 | Detail metadata panjang |
| [06-mobile-notes-dark.jpg](screenshots/06-mobile-notes-dark.jpg) | 390×844 | Catatan referensi dalam mode gelap |
| [07-mobile-connections.jpg](screenshots/07-mobile-connections.jpg) | 390×844 | Keadaan koneksi yang sebenarnya pada prototipe |
| [08-mobile-empty-search.jpg](screenshots/08-mobile-empty-search.jpg) | 360×780 | Pencarian kosong dan pemulihannya |
| [09-desktop-notebook-state.jpg](screenshots/09-desktop-notebook-state.jpg) | 1280×720 | Ruang asisten belum tersambung |

## Pemeriksaan berkas dan batas penerapan

`node --check prototype/workspace.js` selesai dengan exit 0. JSON token dapat dibaca dengan exit 0. Pemeriksaan `git diff --check` keseluruhan menghasilkan exit 2 karena masing-masing lisensi OFL asli memiliki satu trailing space pada baris 21; teks lisensi sengaja dipertahankan. Pemeriksaan kode dan dokumen dengan kedua lisensi dikecualikan selesai dengan exit 0. Diff dari baseline hanya menambah folder riset ini; status file tracked bersih setelah checkpoint. Aset font Inter, logo dan katalog berasal dari proyek; Noto Sans Arabic berasal dari repositori resmi Google Fonts, disertai lisensi OFL. SHA-256 font Arab: `63111b5b2e074dd48cc67692e0a2726d86ee94c1c37fe8598257b7b4e87e869e`.

Tidak ada perubahan source Flutter pada iterasi riset ini, sehingga tes Flutter dan build release tidak dipakai sebagai bukti kualitas prototipe. Tidak ada APK, upload, broadcast versi, pemasangan binary skill GitHub, atau autentikasi pengguna yang dilakukan. Panduan skill dibaca dan diterapkan secara selektif; workflow eksternal yang mengunduh atau menjalankan binary tidak dijalankan.

Penerimaan estetika oleh pengguna, kelayakan seluruh alur produksi, dan satu login Firebase + NotebookLM tetap belum terbukti. NotebookLM tetap merupakan kebutuhan produk.
