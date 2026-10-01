# Arsip prototipe akun operator NotebookLM

Tanggal: 1 Oktober 2026. Status: **arah akun operator ditolak pengguna dan dihentikan sebagai arah produk**. Kode prototipe tetap tersimpan untuk restore, diuji hanya dengan fixture, belum terhubung ke Google, belum aktif pada build normal, dan belum dirilis. Bagian kandidat di bawah merupakan catatan historis, bukan rencana yang disetujui. Lihat [implementasi dan bukti verifikasi](../../tools/notebook_bridge/README.md) untuk batas persis kode yang tersedia.

## Hasil pemeriksaan ulang login pribadi

Kebutuhan aktif adalah satu login memakai akun Google masing-masing pengguna, NotebookLM asli, dan antarmuka OpenTurath di aplikasi native. Prototipe akun operator tidak memenuhi kebutuhan tersebut.

Kode `DesktopGoogleSignIn` mengirim ID token ke Firebase melalui callback browser, tanpa sesi situs Google. Jalur mobile juga memakai kredensial Google untuk Firebase. Tidak ada pertukaran token yang sudah terbukti menghasilkan sesi NotebookLM pribadi di aplikasi. [Dokumentasi Firebase](https://firebase.google.com/docs/auth/flutter/federated-auth) mendokumentasikan autentikasi Firebase; [kebijakan OAuth Google](https://developers.google.com/identity/protocols/oauth2/policies#use-secure-browsers) melarang otorisasi melalui browser tertanam yang dikendalikan developer. Keberhasilan login Firebase tidak menjadi bukti bahwa NotebookLM sudah terautentikasi.

[Kode Android konektor terbaru](https://github.com/teng-lin/notebooklm-py/blob/main/src/notebooklm/_android/auth.py) memakai master token, scope termasuk `labs-tailwind`, serta identitas paket dan sertifikat aplikasi Google. Scope tersebut tidak ditemukan pada [daftar scope publik Google](https://developers.google.com/identity/protocols/oauth2/scopes) yang diperiksa. Ini bukan bukti bahwa token Google Sign-In milik proyek OpenTurath diterima oleh NotebookLM; mekanisme tersebut tidak diaktifkan atau diuji memakai kredensial pengguna.

Ada integrasi resmi [Ask NotebookLM di Workspace Studio](https://workspaceupdates.googleblog.com/2026/05/notebooklm-in-workspace-studio.html), dengan [API pemicu alur](https://developers.google.com/workspace/add-ons/studio/build-a-starter). Namun pengguna memerlukan akses Studio dan konfigurasi alur. [Persyaratan Studio](https://support.google.com/workspace-studio/answer/16444479?hl=en) membatasi akun pribadi pada Workspace Experiments, dan [panduan langkah Notebook](https://support.google.com/workspace-studio/table/17176961) menyatakan bahwa jawabannya berupa teks tanpa sitasi. Jalur ini belum memenuhi produk untuk semua akun Gmail dengan sitasi kitab.

Kesimpulan pemeriksaan: belum ada alur terverifikasi yang memenuhi seluruh syarat aktif. Tidak ada perubahan autentikasi runtime, ekspor sesi, login tambahan, pertanyaan NotebookLM, atau deployment pada pemeriksaan ini. Tes fixture terdahulu tidak membuktikan satu login Google nyata. Dokumen ini tidak memberi izin baru untuk mengumpulkan cookie atau master token akun pengguna.

## Tujuan dan kesalahan arah sebelumnya

Pengguna meminta satu pengalaman di aplikasi OpenTurath: login, pemilihan bidang, pertanyaan, jawaban, dan sitasi. NotebookLM tetap mesin di balik antarmuka. Keberhasilan membuka NotebookLM di browser tidak memenuhi tujuan tersebut. Signing/Keychain hanya memperbaiki penyimpanan identitas Firebase di macOS, sehingga tidak menjadi penyelesaian integrasi mesin.

Kode sekarang menggabungkan identitas pelanggan Firebase dengan sesi situs Google di WebView. Kedua sesi mempunyai pemilik dan penyimpanan yang berbeda. Menyatukan tampilan saja tidak memperbaiki batas ini.

## Kandidat yang sesuai dengan pengalaman pengguna

Alur yang diteliti:

`Aplikasi OpenTurath → backend OpenTurath → NotebookLM → jawaban dan sitasi → UI OpenTurath`

- Pengguna akhir hanya login ke OpenTurath. Backend memverifikasi identitas Firebase dan hak akses bidang sebelum meminta jawaban.
- NotebookLM diakses backend melalui akun operator khusus yang mempunyai akses sah ke notebook sumber. Akun operator terpisah dari akun pengguna akhir dan akun Google pribadi pengelola.
- Aplikasi menerima teks dan sitasi terstruktur. Aplikasi tidak menerima cookie Google, kredensial operator, atau URL sebagai cara membuka ruang percakapan.
- Percakapan perlu dipisahkan per pengguna dan bidang. ID percakapan upstream tidak boleh diterima langsung dari klien atau digunakan ulang antar pengguna. Jawaban lama dari akun lain tidak boleh menjadi konteks pertanyaan baru.
- Frontend Flutter dapat memakai UI chat native yang sudah ada. Platform klien berkomunikasi dengan backend yang sama; tetap diperlukan uji autentikasi dan runtime pada masing-masing platform.

Ini adalah pengubahan batas arsitektur, bukan penggantian NotebookLM dengan RAG lain. Pengguna tidak login ke situs NotebookLM karena sesi mesin menjadi tanggung jawab operator backend. Login awal/perpanjangan sesi operator tetap merupakan pekerjaan administrasi tersendiri.

## Bukti kelayakan teknis dan batasnya

Repositori [notebooklm-py](https://github.com/teng-lin/notebooklm-py) mendokumentasikan pemanggilan `client.chat.ask` yang menghasilkan jawaban dan referensi, serta penggunaan dari proses Python tanpa WebView. Ini menyediakan kandidat untuk proof of concept melalui backend. Repositori tersebut secara eksplisit menyebut konektornya tidak resmi dan endpoint Google tidak terdokumentasi; perubahan endpoint dan rate limit tetap dapat mengganggu operasi.

[Panduan instalasi penulis](https://github.com/teng-lin/notebooklm-py/blob/main/docs/installation.md) dan [API Python penulis](https://github.com/teng-lin/notebooklm-py/blob/main/docs/python-api.md) menjelaskan bahwa backend Web memerlukan sesi Google. File sesi merupakan kredensial, bukan konfigurasi biasa. Dokumentasi juga menawarkan master token akun penuh; token seperti itu tidak dijadikan syarat prototipe ini dan tidak diambil dari akun pribadi pengguna. Pola produksi multi pengguna, rotasi sesi, batas konkurensi, serta batas kuota perlu diuji tersendiri. Jumlah clone notebook tidak boleh dianggap memperbesar kuota akun.

Dokumentasi [API Enterprise Google](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks) yang diperiksa tetap mendokumentasikan operasi pengelolaan notebook. Belum ditemukan endpoint chat publik resmi pada daftar yang diperiksa. Jadi kandidat konektor sumber terbuka tidak dinyatakan sebagai integrasi resmi yang didukung Google atau sebagai solusi rilis yang pasti stabil.

## Batas isolasi percakapan yang ditemukan

Pada bagian `Conversation semantics`, API Python penulis menyatakan bahwa `conversation_id=None` meneruskan percakapan saat ini pada notebook; pemanggilan berulang tidak membuat percakapan baru. ID percakapan yang diberikan eksplisit meneruskan percakapan bernama. Resep membuat percakapan baru yang didokumentasikan menggunakan penghapusan history lama dan dinyatakan destruktif.

Karena itu satu akun operator yang mengakses satu master notebook untuk banyak pelanggan belum merupakan implementasi yang aman. Tidak boleh mengandalkan UUID percakapan acak yang belum dibuat server, instruksi prompt untuk mengabaikan history, atau penghapusan percakapan pelanggan lain. Prototipe awal hanya dapat memakai satu pengguna/notebook uji terpisah; penggunaan multi pengguna masih memerlukan jalur pembuatan percakapan terisolasi yang tervalidasi atau notebook terpisah per pengguna, dengan perhitungan kapasitas dan kuota yang sesuai. Perilaku ini berasal dari kontrak SDK yang diperiksa dan belum diverifikasi lewat uji konektor langsung.

## Prototipe yang perlu dibuktikan sebelum diaktifkan

1. Satu akun operator khusus dan satu notebook uji, dengan kredensial disimpan terpisah dari Git, log, dan binary aplikasi. Pemindahan/penyimpanan sesi membutuhkan persetujuan yang menyebut akun dan lokasi penyimpanannya. Izin terdahulu untuk satu pertanyaan browser tidak diperluas menjadi izin mengambil sesi akun Google pribadi.
2. Satu panggilan nyata dari UI Flutter: identitas Firebase → backend yang memeriksa hak akses → NotebookLM → jawaban dan sitasi tampil di aplikasi. Fixture atau tes mock hanya memverifikasi kontrak, bukan koneksi mesin.
3. Dua pengguna uji membuktikan isolasi percakapan, lalu uji pergantian akun, logout, restart, sesi operator kedaluwarsa, dan pencabutan hak akses. Kegagalan harus kembali sebagai status yang jelas, tanpa jawaban palsu, kebocoran sesi, atau retry pertanyaan tanpa batas.
4. Uji kuota, kapasitas, dan stabilitas sebelum memutuskan penggunaan publik. Prototipe tidak mengubah sistem produksi atau memicu publikasi APK/Hosting.

## Keputusan yang belum dibuat

Kebutuhan UI aplikasi sudah jelas dan tidak ditanyakan kembali. Keputusan yang tersisa adalah apakah pengguna menerima pengujian **nyata** kandidat konektor NotebookLM yang tidak resmi. Akun operator, lokasi kredensial, dan hak penggunaan notebook belum ditetapkan. Kode lokal disiapkan agar dapat diperiksa tanpa sesi Google; fixture hanya digunakan dalam tes. Tidak ada sesi Google dibaca/diekspor, master token dibuat, SDK konektor dijalankan, pertanyaan NotebookLM tambahan dikirim, atau backend produksi diubah.
