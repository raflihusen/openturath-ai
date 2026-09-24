# Audit UI/UX OpenTurath AI — 24 September 2026

## Ruang lingkup dan metode

Audit ini memeriksa tiga tangkapan layar terbaru, jalur kode Asisten → Pustaka → Katalog → Detail Edisi, serta alur lain yang berbagi desain dan lokalisasi (Beranda, Catatan, Pengaturan, Langganan, WebView). Bukti visual berasal dari tangkapan layar pengguna. Pemeriksaan kode dan tes widget menunjukkan perilaku pada lebar 320–360 logical pixel; itu belum menggantikan peninjauan pada perangkat nyata. Dokumen/prompt terlampir dipakai sebagai konteks, sedangkan permintaan terbaru pengguna menjadi arahan pekerjaan.

## Temuan prioritas

| Prioritas | Jenis | Bukti | Status |
| --- | --- | --- | --- |
| P0 | Cacat lokalisasi dan RTL | Detail kitab kanonik memaksa seluruh layar ke RTL dan label Arab di semua bahasa; katalog editorial serta filter memakai teks Indonesia langsung. | Diperbaiki untuk dua jalur katalog/detail. Teks sumber Arab tetap RTL dan label UI mengikuti ID/EN/AR. |
| P0 | Luapan layar kecil | Tes 320 px menemukan luapan judul pustaka Arab, dua baris fakta kitab, dan jumlah hasil Indonesia. | Diperbaiki; tes 320 px ID/EN/AR lulus. |
| P1 | Identitas asisten hilang | Kartu menerima peran, disiplin, dan judul rujukan tetapi sebelumnya hanya menampilkan nama serta label “Pustaka” yang berulang. | Peran, simbol disiplin, dan rujukan kini terlihat. Identitas editorial setiap asisten masih perlu telaah bersama pengguna di perangkat. |
| P1 | Hierarki pustaka berat | Hero panjang diikuti empat kartu angka besar menunda akses ke kitab. Uraian Hadis menyebut 1.141, sementara katalog berisi 1.173 entri. | Ringkasan dipadatkan, angka teknis menjadi dua metrik kecil, uraian klaim diganti, dan metadata Hadis diselaraskan dengan berkas katalog. |
| P1 | Metadata teknis bocor | Detail edisi menampilkan “Folder Korpus” dengan nilai “-” dan baris kosong lain. | Baris tanpa nilai dan folder teknis disembunyikan. |
| P1 | Ketergantungan font saat render | Font lokal sudah dibundel, tetapi 18 berkas UI masih memakai GoogleFonts. Upaya render tes tanpa jaringan gagal memuat nama font Google; pratinjau menjadi kotak kosong. | Belum diubah secara global. Perlu konsolidasi ke font lokal dan pembuktian visual sebelum rilis. Ini terbukti pada lingkungan tes; dampak pada perangkat offline masih perlu diuji. |
| P2 | Sisa jalur lama | ResearchLibrarySheet masih berisi teks Indonesia, tetapi pencarian pemanggil saat ini menemukan jalur aktif menuju halaman pustaka dan katalog penuh. | Utang teknis; tinjau sebelum menghapus atau mengaktifkan kembali. |
| P2 | Konsistensi visual lintas fitur | Beranda, Langganan, Catatan, dan Pengaturan memiliki campuran radius, kepadatan, serta gaya judul. Tangkapan layar terdahulu juga menunjukkan harga gelap sulit dibaca. | Sebagian telah dibenahi pada perubahan sebelumnya. Belum dinilai ulang sebagai satu alur visual nyata. |

P0/P1/P2 di sini adalah urutan pengerjaan, bukan klaim seluruh aplikasi telah bebas cacat. “Diperbaiki” berarti kode lokal telah berubah dan pemeriksaan yang disebutkan lulus; penerimaan visual tetap terpisah.

## Arah desain yang dipilih

1. **Asisten adalah pintu ilmu.** Setiap entri memperlihatkan nama, peran atau cakupan telaah, dan rujukan yang membedakannya. Simbol disiplin bersifat kecil dan informatif; kitab serta isi keilmuan tetap menjadi pusat perhatian.
2. **Pustaka adalah indeks, bukan brosur statistik.** Urutan baca: nama koleksi → alasan membuka koleksi → tindakan menelusuri → angka pendukung. Hindari klaim pelatihan AI yang tidak dapat dibuktikan dari katalog.
3. **Katalog adalah alat kerja.** Pencarian, hasil, filter, dan metadata mengikuti bahasa UI. Judul, nama pengarang, penerbit, serta kutipan Arab dipertahankan sebagai data sumber dan diberi arah teks yang benar.
4. **RTL berlaku untuk tata letak, bukan semua string.** Navigasi mengikuti bahasa aplikasi; blok Arab selalu memiliki arah baca Arab. Angka, ID edisi, serta transliterasi perlu isolasi arah sesuai jenis kontennya.
5. **Satu sistem visual OpenTurath.** Monokrom hangat, tipografi editorial yang sudah ada, jarak dan radius konsisten. Identitas ilmiah dibangun oleh isi dan ketelitian, bukan gradasi atau ornamen keagamaan generik.

Arah ini sesuai dengan [Flutter internationalization](https://docs.flutter.dev/ui/internationalization), [Apple HIG Right to Left](https://developer.apple.com/design/human-interface-guidelines/right-to-left), [panduan kartu USWDS](https://designsystem.digital.gov/components/card/), dan kriteria [WCAG 2.2 Reflow](https://www.w3.org/TR/WCAG22/#reflow). USWDS khususnya mengingatkan bahwa isi berulang di tiap kartu membuat anggota koleksi lebih sulit dibedakan.

## Keputusan lokalisasi data

- Semua label, navigasi, tindakan, filter, pesan kosong, dan hitungan pada jalur katalog yang disentuh harus memiliki ID/EN/AR.
- Judul kitab dan nama pengarang Arab tetap dalam bahasa naskah. Itu identitas bibliografi, bukan salinan antarmuka yang perlu diterjemahkan otomatis.
- Nilai klasifikasi yang tersedia dalam peta tiga bahasa diterjemahkan. Nilai katalog yang belum dipetakan tetap tampil sebagai data sumber, tanpa menebak padanan ilmiah.
- Angka katalog tidak boleh berubah menjadi klaim tentang jumlah kitab yang benar-benar digunakan melatih AI.

## Gerbang sebelum APK berikutnya

1. Jalankan analisis dan seluruh tes; tes baru harus mencakup asisten, pustaka, daftar kitab, dan detail edisi pada 320 px untuk ID/EN/AR.
2. Inspeksi layar penuh di perangkat nyata untuk lebar ponsel kecil/besar, tema terang/gelap, skala teks lebih besar, dan alur pencarian serta scroll.
3. Uji Bahasa Arab pada Beranda, Asisten, Pustaka, Detail, Catatan, Pengaturan, dan Langganan dengan perubahan bahasa langsung tanpa memulai ulang.
4. Audit seluruh pemanggilan GoogleFonts dan pindahkan ke font lokal yang sudah dibundel bila hasil visual tetap sesuai identitas OpenTurath. Uji tanpa jaringan agar tipografi tidak berubah atau hilang.
5. Periksa aksesibilitas tindakan sekunder “kitab rujukan”, fokus keyboard desktop, pembaca layar, dan ukuran target sentuh.
6. Minta penilaian visual atas layar representatif sebelum menyatakan desain final. Tes widget dan analisis statis hanya membuktikan sebagian perilaku.

Tidak ada APK atau siaran pembaruan publik yang merupakan bagian dari audit ini.
