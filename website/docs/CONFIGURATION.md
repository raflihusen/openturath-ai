# Konfigurasi dan penyuntingan

Semua perubahan dilakukan pada sumber lalu jalankan `npm run build`. Jangan mengedit `dist/` secara manual: folder itu dibuat ulang. Konfigurator `npm run setup` membantu mengisi domain/kontak/rilis tanpa mengirim data ke pihak lain.

## Pengaturan utama

| Kunci | Isi yang diperlukan |
|---|---|
| `canonicalUrl` | Origin HTTPS milik pengelola, tanpa path, query, kredensial atau fragment |
| `operator.name` | Identitas pengelola yang boleh ditampilkan |
| `operator.email` | Kontak bantuan aktif |
| `operator.jurisdiction` | Domisili/yurisdiksi operasional yang benar |
| `operator.privacyEmail` | Kontak privasi aktif |
| `operator.securityEmail` | Kanal pelaporan keamanan aktif |
| `reports.enabled` | `true` jika API tersedia pada origin situs; `false` untuk hosting statis tanpa API |
| `reports.retentionDays` | 1–365 hari; sesuaikan pula artikel privasi dan jadwal purge |
| `policiesApproved` | `true` hanya setelah isi kebijakan dan praktik aplikasi ditinjau |
| `catalogReviewed` | `true` hanya setelah katalog dan deskripsinya disetujui |
| `comparisonRightsConfirmed` | `true` hanya setelah hak publikasi ulang enam jawaban dipastikan |
| `analytics.enabled` | Tetap `false`; tidak ada pengiriman data ke penyedia analitik |
| `appDeepLinkBase` | Kosong sampai app/universal link domain benar-benar disiapkan |
| `appLinksVerified` | Harus `true` untuk menampilkan deep link; pengujian perangkat tetap wajib |

`reports.enabled=false` mempertahankan penulisan dan unduh salinan, dengan kontak email bila tersedia, tanpa tombol kirim server. Retensi tidak diterapkan pada salinan yang diunduh pengunjung. Mengisi email tidak otomatis mengirim email; tautan `mailto:` membuka aplikasi email pengguna.

## Rilis unduhan

Tambahkan objek pada `downloads` dari artefak aktual:

```json
{
  "platform": "Android",
  "type": "apk",
  "version": "ISI_VERSI_ASLI",
  "date": "YYYY-MM-DD",
  "minimumOS": "ISI_OS_MINIMUM",
  "size": "ISI_UKURAN_ASLI",
  "url": "ISI_URL_HTTPS_RESMI",
  "sha256": "ISI_64_DIGIT_HASH_ASLI",
  "revoked": false
}
```

Contoh di atas adalah format, sengaja bukan konfigurasi yang dapat diterbitkan. `type` berupa `apk`, `store`, atau `web`. Hash dan ukuran APK harus berasal dari berkas yang diunduh pengguna. Periksa tanda tangan APK memakai proses rilis aplikasi. Toko aplikasi tidak membutuhkan checksum berkas. Jangan menaruh file executable dengan URL rekaan. Hapus/cabut rilis bermasalah dan build ulang.

Setiap versi aktif harus mempunyai catatan dalam `releaseNotes`:

```json
{
  "version": "ISI_VERSI_ASLI",
  "date": "YYYY-MM-DD",
  "summary": {"id":"Ringkasan yang disetujui","en":"Approved summary","ar":"ملخّص معتمد"},
  "body": {"id":"Catatan rilis lengkap","en":"Full release notes","ar":"تفاصيل الإصدار"}
}
```

Slug versi hanya huruf/angka/titik/tanda hubung, tidak mengandung `..`. Konten Markdown aman dirender; HTML mentah tidak dijalankan. Domain yang sudah diisi menghasilkan QR untuk halaman unduh tiap bahasa. QR menunjuk halaman situs, bukan URL bertoken atau berkas sementara.

## Paket akses

`plans` berisi satu objek per paket resmi:

- `name`, `period`, `coverage`, `renewal`, `refund`, `taxes`, `cancellation`, `paymentLocation`: masing-masing objek lengkap `{id, en, ar}`.
- `price`: angka nol atau positif; nol hanya jika benar-benar gratis.
- `currency`: kode mata uang tiga huruf kapital.

Cakupan harus menyebut posisi koleksi khusus Tahawwulat, durasi akses, biaya total/pajak, perpanjangan, cara berhenti, pengembalian, dan tempat transaksi. Situs mengantar pengguna ke aplikasi; tidak ada checkout atau perhitungan entitlement dari URL.

## Konten dan pembuktian

- `content/catalog.json`: dua puluh koleksi dari metadata yang diberikan. `id` stabil, nama/deskripsi tiga bahasa, teks Arab, bidang. Angka jumlah kitab tidak ditampilkan karena sumber angka awal saling berbeda.
- `content/books.json`: tujuh bibliografi yang dirujuk pada contoh. Edisi dan atribusi yang belum pasti tidak ditebak. Ini bukan daftar seluruh isi aplikasi.
- `content/evaluation.json`: prompt asli, enam run, nama produk, URL percakapan yang diberikan, teks asli, hash SHA-256. Bukan benchmark terkontrol lintas versi terkini.
- `content/q001-original.md`: ekspor asli yang diberikan, jangan diedit diam-diam.
- `content/evidence.json`: sepuluh kutipan bagian B OpenTurath. `locator` adalah rujukan sebagaimana ditulis model. `printPage`/`pdfPage`/`edition` adalah hasil pemeriksaan yang berbeda dari locator tersebut. Semua saat ini belum diperiksa.
- `content/corrections.json`: daftar perubahan publik, objek `id`, `date`, `title:{id,en,ar}`, `body:{id,en,ar}`, `fromVersion`, `toVersion`. Pertahankan versi lama di arsip sumber.
- `content/claims.json`: register klaim, masih kosong; tidak ada klaim skor yang diterbitkan. Menambah klaim baru memerlukan telaah dan implementasi terpisah, jangan mengubah angka dekoratif menjadi bukti.
- `src/copy.mjs`: label antarmuka; urutan setiap array Indonesia, English, Arabic.
- `src/articles.mjs`: panduan/metodologi/kebijakan. Lengkapi praktik autentikasi, pembayaran, penyedia data, penghapusan akun, identitas dan tanggal kebijakan sebelum menandai persetujuan.

Status bukti: `not-reviewed`, `matched`, `partial`, `mismatch`, `unverifiable`. Selain `not-reviewed`, wajib ada penelaah, tanggal, catatan alasan; untuk cocok juga wajib ada edisi, teks sumber dan URL. Jangan menyatakan cocok berdasarkan keluaran model itu sendiri. Catatan yang cocok perlu pemeriksaan makna/dukungan klaim terpisah. Pemeriksaan situs bukan pengesahan keilmuan.

## Alur editorial

Draft → cek sumber/hak → telaah isi → telaah tiga bahasa → build preview → QA → persetujuan penerbit → build produksi → arsip perubahan. Gunakan Git atau arsip versi pada komputer/server Anda. Perubahan jawaban AI adalah run baru; jangan menimpa keluaran historis.

## Batas fitur

Website tidak mengirim newsletter, mengelola akun pengguna aplikasi, membuat pembayaran, menjalankan model AI, atau menghapus akun aplikasi. Tombol terkait mengantar ke panduan dan kanal yang benar. Universal/App Links membutuhkan konfigurasi domain/aplikasi di luar ZIP ini; konteks setelah instalasi baru tidak dijanjikan. Analitik eksternal belum diaktifkan, tidak ada pixel atau cookie iklan.
