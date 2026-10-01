# Prototipe chat NotebookLM di aplikasi OpenTurath

Status 1 Oktober 2026: **kode dan uji lokal tersedia; belum terhubung ke Google, belum diaktifkan pada build normal, belum dirilis**.

Alur implementasi:

`Widget chat Flutter → NotebookChatService → callable askAgent → bridge privat → NotebookLM → teks + sitasi → widget Flutter`

Pengguna memakai identitas Firebase yang sudah ada. Sesi Google milik operator berada di backend; aplikasi tidak menerima cookie, token operator, URL notebook, ID percakapan upstream, atau debug response. NotebookLM tetap mesin yang dituju. Tidak ada browser NotebookLM atau WebView pada tab prototipe.

## Bagian yang sudah ada

- `lib/widgets/agent_multi_tab_room.dart`: memilih tab backend hanya bila build memakai `OPENTURATH_BACKEND_CHAT_PROTOTYPE=true`. Default tetap `false`.
- `lib/services/notebook_chat_controller.dart`: mengunci request pada UID asal, menolak kirim paralel, membersihkan history saat akun berubah, mengabaikan jawaban terlambat, dan tidak melakukan retry otomatis.
- `functions/src/index.ts`, `askAgent`: memverifikasi token termasuk pencabutan, memeriksa hak akses bidang, membatasi request, dan hanya menerima satu UID uji yang ditetapkan server.
- `bridge.py`: HTTP hanya di `127.0.0.1`; kunci backend diperlukan. Notebook dipilih lewat manifest operator, bukan input aplikasi. Setiap notebook hanya boleh dimiliki satu binding. ID request dan percakapan disimpan lokal untuk mencegah pengulangan pertanyaan setelah timeout/restart.
- Riwayat Google yang tidak cocok, sumber yang tidak dikenal, atau hasil upstream yang tidak pasti menghentikan binding. Tidak ada penghapusan history Google atau pemakaian UUID percakapan buatan.
- Jawaban dirender sebagai teks native dengan sitasi. Gambar dari Markdown tidak diambil otomatis. Salin/simpan menyertakan rujukan yang tersedia.

## Konfigurasi uji nyata yang masih diperlukan

Persetujuan memakai konektor tidak resmi masih diminta. Izin terdahulu memakai akun pribadi untuk satu pertanyaan browser tidak digunakan untuk menyalin sesi akun itu.

Setelah keputusan tersebut dan akun operator khusus ditetapkan, tentukan satu notebook **uji terpisah** tanpa riwayat operator, UID pengguna uji, dan lokasi penyimpanan sesi privat yang disetujui. Jangan memakai master/clone pelanggan untuk percobaan, mengekspor sesi browser pribadi, atau membuat master token akun penuh sebagai jalan pintas.

Worker memerlukan Python 3.11+ dan `notebooklm-py`. Versi API yang diperiksa juga terdapat pada wheel proyek `ecosystem/openturath_subscription/notebooklm_py-0.8.0a3-py3-none-any.whl`, SHA256 lokal `f5cb9f5e9bac1064233f889aebd01bf6a92acb1e2738476d4d422d4d42aa0a88`. Fingerprint ini hanya mengidentifikasi file lokal; belum menjadi verifikasi keamanan paket upstream. Tidak ada paket dipasang atau sesi SDK dijalankan pada pekerjaan ini.

Konfigurasi worker (nilai asli disimpan privat, tidak di Git atau pesan chat):

| Nama | Isi |
| --- | --- |
| `NOTEBOOK_OPERATOR_SESSION` | Path eksplisit ke sesi akun operator; mode file 0600 |
| `NOTEBOOK_BRIDGE_RUNTIME` | Direktori privat 0700 untuk lock dan SQLite; bukan direktori build/app |
| `NOTEBOOK_BRIDGE_BINDINGS` | Path manifest privat berisi UID, bidang, notebook khusus uji |
| `NOTEBOOK_BRIDGE_TEST_UID` | Satu UID pengguna uji |
| `NOTEBOOK_BRIDGE_KEY` | Kunci server acak minimal 32 karakter; tidak dikirim ke aplikasi |
| `NOTEBOOK_BRIDGE_PORT` | Opsional; default 8794, tetap loopback |

Contoh **fiktif** manifest:

```json
[{"uid":"UID_UJI_YANG_DITETAPKAN","agentId":"fiqh_syafii","notebookId":"11111111-1111-1111-1111-111111111111"}]
```

Callable memakai UID uji yang sama, `NOTEBOOK_BRIDGE_URL`, dan secret `NOTEBOOK_BRIDGE_KEY`. HTTP loopback hanya diterima bila berjalan di Functions emulator. Di luar emulator URL harus HTTPS; redirect ditolak. Tidak ada server/emulator baru atau secret Google dibuat pada pekerjaan ini. Worker lokal ini tidak dapat dihubungi langsung oleh Cloud Function produksi dan tidak boleh diekspos menjadi HTTP publik.

## Bukti verifikasi lokal

| Pemeriksaan | Hasil final | Batas bukti |
| --- | --- | --- |
| Flutter seluruh suite | 298 tes lulus, exit 0 | Termasuk tab native mengirim, menampilkan sitasi, menerima pertanyaan berikutnya; backend memakai fixture |
| Flutter analyze | Bersih, exit 0 | Tidak membuktikan runtime semua platform |
| TypeScript build | Selesai, exit 0 | Generated output ikut checkpoint Git |
| Backend Node | 51 tes lulus, exit 0 | 14 tes kontrak/callable baru dan 37 regresi sebelumnya; Google/HTTP upstream memakai stub |
| Python bridge | 15 tes lulus, exit 0 | 12 tes engine/provider fixture dan 3 tes HTTP loopback nyata; tidak ada request Google |

Uji HTTP awal dibatasi sandbox; pengulangan dengan izin uji lokal lulus. Uji widget awal diperbaiki agar menunggu frame tombol setelah mengetik. Analisis awal menemukan builder gambar deprecated; diganti dengan API yang didukung. Angka di atas adalah hasil **setelah** perbaikan, bukan klaim bahwa semua percobaan awal langsung lulus.

## Batas sebelum rilis

- Membuktikan pertanyaan nyata dari aplikasi sampai ke NotebookLM dan sitasi kembali dengan akun operator/notebook yang diizinkan. Koneksi browser yang diuji sebelumnya tidak membuktikan jalur ini.
- Prototipe membatasi satu UID. Multi pengguna, kapasitas notebook per pelanggan, kuota akun, retensi/backup, pemulihan binding yang dihentikan, dan observabilitas produksi belum selesai. Jangan menghapus pengunci UID untuk mempercepat rilis.
- SQLite bukan penyimpanan produksi multi instance. UI menyimpan percakapan dalam memori; pemulihan history penuh ke UI setelah menutup tab/restart belum diimplementasikan.
- Uji sesi operator kedaluwarsa, token Firebase dicabut, gangguan jaringan, pergantian akun, dan runtime masing-masing platform. Signing/Keychain macOS tetap diperlukan untuk menyimpan login aplikasi, tetapi tidak menyelesaikan integrasi mesin.
- Konektor [notebooklm-py](https://github.com/teng-lin/notebooklm-py) tidak resmi dan memakai endpoint yang tidak terdokumentasi. Tidak ada jaminan Google tidak mengubah endpoint atau membatasi akun. API chat publik resmi belum ditemukan pada daftar API Enterprise yang diperiksa.

Tidak ada perubahan produksi, deploy Functions/Hosting, publikasi APK, atau broadcast Firestore pada pekerjaan ini. Seluruh perubahan kode dibuatkan checkpoint Git.
