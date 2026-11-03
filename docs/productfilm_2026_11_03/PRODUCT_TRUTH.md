# Acuan produk dan contoh film OpenTurath AI

3 November 2026 · Pemeriksaan sumber lokal dan satu teks primer digital. Ini bahan produksi untuk **ilustrasi** antarmuka; bukan rekaman respons AI nyata, bukti uji perangkat, atau penetapan bahwa setiap rujukan AI benar.

## Satu pertanyaan dan contoh isi

Pertanyaan di model bawaan aplikasi: **“Apa rukun wudu menurut pendapat mu'tamad dalam mazhab Syafi'i?”** Sumber: `openturath_ai/lib/models/agent_model.dart:278–282`. Pertanyaan ini boleh dipersingkat untuk keterbacaan, dengan arti yang dijaga.

Contoh jawaban yang ditulis untuk film, berdasarkan matan, bukan hasil uji aplikasi:

> **Rukun wudu**  
> Dalam *Safinatun Najah*, fardu wudu ada enam: niat; membasuh wajah; membasuh kedua tangan hingga siku; mengusap sebagian kepala; membasuh kedua kaki hingga mata kaki; dan tertib.

Rujukan yang ditampilkan **sebagai bagian dari isi contoh jawaban**: *Safinatun Najah*, fasal fardu wudu. Kutipan pendek yang diperiksa: **فُرُوضُ الوُضُوءِ سِتَّةٌ**. Huruf dan harakat di sini mengikuti awal fasal pada teks digital yang diperiksa. Pertahankan rangkaian kata Arab utuh, arah kanan ke kiri, dan font Arab yang menyambung; jangan memecah atau mengubahnya sebagai ornamen.

Metode verifikasi: membaca teks Arab fasal dan enam butir dalam [*The Ship of Salvation*, teks *Safīnat al-najāʾ* Arab–Inggris](https://islamicbulletin.org/en/ebooks/hadith/the_ship_of_salvation.pdf), edisi yang menyebut penyunting/penerjemah Abdullah Muhammad al-Marbūqī, 1430 H/2009, halaman bernomor **12** dalam dokumen. Edisi itu dipakai untuk pemeriksaan teks, bukan sebagai bukti identitas edisi yang dipakai oleh AI. Tidak perlu menampilkan nomor halaman dalam film. Daftar Indonesia di atas adalah **parafrasa**, bukan terjemahan yang disalin dari sumber.

Katalog aplikasi `openturath_ai/assets/data/01_KATALOG_FIKIH_SYAFII.json:1400–1409` memang memuat entri `سفينة النجاة وسفينة الصلاة`, penulis Salim bin Sumair, dan sumber teks; metadata tersebut tidak membuktikan bahwa edisi katalog identik dengan PDF 2009. Jangan memberi kesan bahwa PDF ini adalah sumber langsung dari respons NotebookLM atau bahwa nomor halaman berlaku untuk semua cetakan.

## Ruang percakapan dan penelusuran

- Ruang studi memiliki judul agen, tombol kembali, ikon buku **Kitab rujukan**, dan menu opsi. Ikon buku membuka katalog koleksi agen melalui `showResearchLibrary`: `openturath_ai/lib/widgets/agent_multi_tab_room.dart:531–557` dan `openturath_ai/lib/widgets/library_bottom_sheet.dart:22–49`.
- Baris katalog dapat membuka halaman detail metadata kitab: `openturath_ai/lib/screens/book_library_editorial_screen.dart:370–386`. Kode tersebut **tidak membuktikan** bahwa klik nomor sitasi dalam jawaban otomatis membuka halaman tertentu atau teks lengkap kitab. Film tidak perlu menggambarkan navigasi itu.
- Tampilan jawaban NotebookLM adalah isi pihak ketiga yang dapat berubah. Respons contoh film harus diberi penanda **“Ilustrasi percakapan”** dan jangan diklaim sebagai tangkapan sesi nyata. Pemeriksaan di sini bersifat pembacaan kode; perilaku sesi nyata belum diuji untuk tugas ini.

## Salin jawaban → Simpan → buka Catatan

Urutan di bawah khusus jalur WebView yang ditunjukkan oleh kode, dengan sesi dan akun yang memenuhi syarat:

1. Pada akhir jawaban yang selesai, skin menambahkan kontrol berlabel **Salin jawaban**, dengan ikon salin; saat berhasil, label sementara menjadi **Tersalin**. Ia dibuat sebagai elemen `role=button`, bukan sekadar tooltip: `openturath_ai/lib/core/notebook_skin.dart:22–26, 547–572, 639–673`. Skrip menangkap kontrol salin dan meneruskan isi jawaban: `openturath_ai/lib/core/notebook_ui_script.dart:22–30, 74–121`.
2. Handler native menyalin teks dan menampilkan snackbar **“Jawaban disalin.”** dengan aksi **Simpan**: `openturath_ai/lib/widgets/agent_multi_tab_room.dart:1978–2024`, label di `openturath_ai/lib/core/copy_catalog.dart:433,1166`. Menekan Simpan memanggil penambahan bookmark; kode melakukan aksi itu secara asinkron dan tidak menavigasi otomatis ke Catatan. Jangan tampilkan snackbar keberhasilan penyimpanan lain yang tidak terlihat dari jalur ini.
3. Ruang AI menutupi shell. Tekan panah kembali ruang AI untuk menutup tampilan ruang, lalu pilih **Catatan** pada navigasi shell: `openturath_ai/lib/widgets/agent_multi_tab_room.dart:535–543` dan `openturath_ai/lib/screens/main_shell_screen.dart:86–93, 310–327`. Layar Catatan memuat item yang tersimpan; mengetuk kartu membuka pembaca catatan: `openturath_ai/lib/screens/bookmark_screen.dart:275–309, 660–674`.
4. Untuk satu jawaban yang diawali baris **“Rukun wudu”**, parser judul menggunakan baris tersebut sebagai judul kartu dan pembaca (`openturath_ai/lib/core/bookmark_content.dart:17–47,108–139`); pratinjau berasal dari baris setelah judul. Pembaca menampilkan label jenis/agen, judul, nama agen bila sesuai, isi lengkap, kontrol salin, dan menu: `openturath_ai/lib/screens/note_reader_screen.dart:62–151`. Perilaku judul tergantung teks yang benar-benar tersalin; jangan mengganti isi sesudah tindakan itu.

Bookmark dari jalur salin jawaban menyimpan teks lengkap sebagai `fullAnswer`, tanpa otomatis mengisi `bookReference` atau `pageNumber`, dan dengan `verificationStatus: unverified`: `openturath_ai/lib/core/copied_answer.dart:8–31`. Nama kitab yang tertulis di badan jawaban tetap bagian isi, bukan metadata rujukan yang telah diverifikasi aplikasi. Jalur menu **Salin percakapan** berbeda: ia menyimpan percakapan sekaligus menyalinnya (`agent_multi_tab_room.dart:198–229, 614–685`). Jangan mencampurkan dua jalur dalam satu demonstrasi.

## Batas untuk animasi

Gunakan label dan kontrol nyata, tetapi animasi pembesaran dan perpindahan komponen merupakan interpretasi visual, bukan klaim bahwa aplikasi bergerak dengan cara itu. Tampilkan satu contoh konsisten dari pertanyaan, jawaban, rujukan dalam teks, sampai catatan. Nama bidang lain dapat muncul sesuai model lokal; ketersediaan masing-masing bergantung konfigurasi dan akses akun. Periksa naskah Arab, keterbacaan, dan urutan salin–simpan–kembali–Catatan pada hasil akhir.
