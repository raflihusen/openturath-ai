# Koreksi kebutuhan produk: NotebookLM di balik antarmuka OpenTurath

Tanggal: 1 Oktober 2026, Asia/Aden.

Pengguna menegaskan bahwa tujuan utama aplikasi adalah memberi pengalaman OpenTurath tanpa memperlihatkan antarmuka NotebookLM kepada pengguna. NotebookLM tetap wajib menjadi mesin yang dipakai. Keputusan browser/PWA sebelumnya tidak memenuhi kebutuhan ini karena membuka situs NotebookLM asli. Jangan menganggap publikasi Hosting, build launcher, atau tercapainya pemilihan akun sebagai penyelesaian tujuan produk.

## Keadaan yang terverifikasi

- Source entry native saat ini masih menjadi launcher ruang browser, dan halaman browser sudah live. Klarifikasi ini belum mengubah entry native atau me-rollback publikasi.
- Perbaikan keamanan autentikasi, pemulihan SDK resmi, dan checkpoint source tetap tersedia. Baseline sebelum arah browser adalah `5c188d8`; catatan versi Hosting ada di `publication.json`.
- Uji terakhir mencapai halaman pemilihan akun Google di Arc; pemilihan akun oleh agent ditolak peninjauan izin otomatis karena akun belum ditentukan pengguna. Belum ada bukti OAuth selesai atau NotebookLM menjawab.

## Batas arsitektur yang perlu diselesaikan

Login Google pada browser resmi boleh menjadi langkah autentikasi sementara, lalu kembali ke aplikasi. Itu berbeda dari memindahkan seluruh pengalaman kajian ke situs NotebookLM. Firebase dapat menerima hasil OAuth resmi; hasil tersebut tidak membuat sesi situs NotebookLM pada WKWebView.

Google melarang permintaan OAuth pada embedded user-agent yang dikendalikan pengembang. Mengembalikan formulir Google ke WebView, menyalin cookie, memalsukan user-agent, atau menyimpan flag siap tidak merupakan bukti solusi satu login yang aman dan didukung. [Kebijakan OAuth](https://developers.google.com/identity/protocols/oauth2/policies), [native apps dan disallowed_useragent](https://developers.google.com/identity/protocols/oauth2/native-app).

Dokumentasi NotebookLM Enterprise yang diperiksa pada tanggal di atas memuat pengelolaan notebook, sumber, dan audio. Daftar REST resource notebook yang diperiksa tidak mendokumentasikan endpoint chat/query NotebookLM untuk antarmuka pihak ketiga. Ini membatasi kesimpulan pada dokumentasi publik yang diperiksa; bukan klaim bahwa tidak mungkin ada integrasi privat atau komersial. [Panduan API notebook](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks), [daftar REST Discovery Engine](https://docs.cloud.google.com/generative-ai-app-builder/docs/reference/rest).

Enterprise juga mendokumentasikan antarmuka Google sendiri dan pengelolaan identitas organisasi. Membeli lisensinya saja belum membuktikan dukungan untuk aplikasi publik dengan tampilan sendiri, akses satu login, atau pemindahan notebook personal yang sekarang dipakai. [Overview resmi](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/overview).

## Kriteria sebelum implementasi berikutnya

1. Validasi integrasi NotebookLM resmi yang dapat menerima pertanyaan dan mengembalikan jawaban/sitasi kepada antarmuka OpenTurath, beserta dukungan penggunaan produk tersebut untuk pengguna akhir yang dimaksud.
2. Buktikan satu alur lengkap dengan satu bidang dan satu akun berizin: login resmi, pertanyaan melalui UI OpenTurath, jawaban berasal dari NotebookLM, sitasi sesuai, lalu persistensi/restart dan pergantian akun.
3. Jika jalur tersebut belum tersedia, jelaskan batasannya kepada pengguna sebelum mengklaim bahwa aplikasi native, NotebookLM personal tersembunyi, satu login semua platform, dan keandalan terjamin sudah dapat dipenuhi bersamaan.

NotebookLM tidak boleh diam-diam diganti dengan backend RAG lain. Pemulihan tampilan native saja juga belum menyelesaikan autentikasi NotebookLM. Arah browser yang sudah dibuat merupakan eksperimen autentikasi yang belum lolos kriteria produk ini.
