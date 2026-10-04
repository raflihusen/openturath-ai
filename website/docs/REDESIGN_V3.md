> Arsip revisi sebelumnya. Status terbaru ada pada AUDIT_WEBSITE_V4.md dan BROWSER_QA.json.

# OpenTurath · Revisi V3

Tanggal: 20 September 2026.
Referensi visual yang dibuka dan diperiksa: https://www.apple.com/

## Arah desain yang diterapkan

Hero hitam memenuhi lebar halaman, judul besar terpusat, visual buku dominan, tombol pil biru/outline, serta panel konten terang dan gelap yang bergantian. Gaya editorial serif pada judul versi sebelumnya diganti dengan sans-serif. Header transparan dan navigasi bagian menetap ketika halaman digulir.

Bento grid memuat pustaka, 20 koleksi, kutipan sumber, tiga bahasa website, Fikih Tahawwulat, dan metode membaca. Susunan berubah menjadi satu kolom pada ponsel. Konten perbandingan menampilkan enam jawaban arsip, diikuti akses, FAQ, dan unduh.

Font Latin: -apple-system/BlinkMacSystemFont pada perangkat yang mendukung, Inter lokal sebagai fallback. Antarmuka Arab memakai sans-serif sistem; teks kutipan Arab memakai Amiri lokal. Tidak menyertakan berkas font proprietary Apple, logo Apple, teks promosi Apple, atau kode situs Apple. Identitas, materi, dan aset tetap OpenTurath; tidak diklaim identik piksel dengan Apple.

## Interaksi

- Panel arsip: pertanyaan, ibarah, dan data rujukan. Klik, Home/End, arah atas-bawah desktop, dan arah kiri-kanan sesuai RTL/LTR pada ponsel.
- Tombol buka sumber menampilkan dialog rujukan yang sudah tersedia.
- Tautan jawaban pada grid pembanding membuka model yang dipilih. Parameter panel memastikan jawaban pembanding langsung terlihat pada ponsel.
- Reveal per bagian menggunakan IntersectionObserver; progress membaca dan gerak hero menggunakan requestAnimationFrame dan scroll pasif. Tidak mengambil alih scrolling.
- Preferensi reduced motion diperhatikan, termasuk ketika berubah saat halaman terbuka. Tanpa JavaScript, isi tetap tersedia dan panel arsip ditampilkan berurutan.
- Semua pencarian, filter, pilihan bahasa, tema, arsip, laporan, dan konfigurasi rilis yang ada tetap dipertahankan.

## Verifikasi

- Build preview: 160 dokumen HTML, 20 koleksi, enam keluaran asli.
- Pemeriksa situs: 159 halaman berbahasa, 8.232 tautan/aset, terjemahan, enam hash transkrip, sepuluh kutipan; tanpa kesalahan.
- Delapan pengujian Node dan sebelas pengujian Python lulus. Sintaks modul JS interaksi dan motion lolos pemeriksaan.
- Desktop: hero, bento grid, panel arsip, mode gelap, dan tab English diperiksa menggunakan browser.
- Ponsel: hero Indonesia/Arab diperiksa pada frame 390 dan 320 CSS px. Tab sumber Indonesia diuji. ArrowLeft pada tab Arab mobile memilih tahap berikutnya sesuai arah RTL.
- URL pembanding `right=nur&panel=right` diuji pada frame mobile: tab Nur AI terpilih dan panel Nur AI terlihat.
- Reviewer kode terpisah meninjau perubahan. Temuan pembanding yang salah tampil pada mobile sudah diperbaiki dan diverifikasi lewat browser.
- Ukuran aset aktual ada di ASSET_SIZES.json. Pratinjau gambar berada dalam previews.

Belum dilakukan: audit aksesibilitas formal, pengujian perangkat fisik/Safari/Firefox, metrik Core Web Vitals lapangan, atau verifikasi ilmiah independen atas kutipan. Reduced motion dan fallback tanpa JavaScript didukung di kode, bukan diklaim lulus audit formal.

## Data dan publikasi

Seluruh transkrip Q001 dan status penelaahan sumber dipertahankan. Tidak menambahkan klaim akurasi 100% atau skor pembanding rekaan.

Paket berisi kode dan build jadi. Jalankan sesuai START_HERE.html. Build masih preview noindex: domain, identitas/kontak pengelola, rilis aplikasi resmi, ketentuan akses, kebijakan final, dan persetujuan publikasi konten belum lengkap. Panduan konfigurasi dan deployment tersedia di CONFIGURATION.md dan DEPLOYMENT.md.
