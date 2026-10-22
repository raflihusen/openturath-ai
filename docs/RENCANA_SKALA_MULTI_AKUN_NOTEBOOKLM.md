# Rencana Skala Multi-Akun NotebookLM — OpenTurath

Versi 1 · 23 Oktober 2026 · Status: **rencana, belum dikerjakan**

Tujuan: menampung 200.000 sampai 1.000.000+ pelanggan dengan menyebar notebook ke beberapa
akun Google pemilik. Setiap pelanggan harus selalu dibuka di notebook yang benar untuk
modulnya, dan satu akun bermasalah tidak boleh memutus semua pelanggan.

---

## 0. Ringkasan

| Hal | Sekarang | Target |
|---|---|---|
| Akun pemilik notebook | 1 | N akun, bisa ditambah tanpa rilis kode |
| Kapasitas per modul | ±27.900 kursi (1 master + 13 clone × 1.995) | ±27.900 × N |
| Daftar notebook | Di kode (`notebook_catalog.ts`), perlu rilis untuk berubah | Registry Firestore, didaftarkan lewat bot, diverifikasi worker |
| Sesi Google | 1 file `storage_state.json` | 1 file sesi per akun, dipantau per akun |
| Pengaman salah link | Cek "notebook ada & tidak publik" | + cek judul & modul langsung dari Google, karantina otomatis |
| Bila satu akun mati | Semua pelanggan di akun itu tertahan | Pelanggan otomatis dipindah ke akun lain |
| Sinkronisasi isi kitab | Manual | Versi isi per notebook + alarm clone tertinggal |

Yang **sudah berjalan dan tidak perlu diubah**: alokasi master → clone 01 → 02 … per
pelanggan, link per pelanggan dari server (aplikasi tidak menyimpan link), pemindahan
pelanggan dari notebook yang hilang, alarm kapasitas per modul.

---

## 1. Keputusan pemilik sebelum mulai (wajib)

### 1.1 Kepatuhan dan jenis akun — keputusan terpenting

Risiko praktisnya adalah akun ditangguhkan, sehingga semua pelanggan di akun itu kehilangan
akses sekaligus. Tiga hal yang perlu dipastikan terhadap ketentuan Google yang berlaku:

1. Bolehkah notebook dari akun yang dipakai untuk usaha berbayar dibagikan ke pelanggan?
2. Bolehkah memakai banyak akun untuk menambah kapasitas?
3. Bolehkah otomasi sharing lewat pustaka tidak resmi (`notebooklm-py`, berbasis cookie)?

Pilihan akun, dari yang paling aman:

| Opsi | Kelebihan | Kekurangan / yang harus diuji |
|---|---|---|
| **A. Produk resmi Google untuk bisnis** (mis. NotebookLM Enterprise di Google Cloud, bila tersedia) | Jalur resmi, ada API, kontrak jelas | Biaya; perlu cek apakah bisa berbagi ke email Gmail pelanggan dan bagaimana lisensi per pengguna |
| **B. Google Workspace domain OpenTurath** (`nb01@openturath.id`, …) | Akun milik organisasi, mudah dipulihkan, tidak terlihat seperti akun massal | Biaya per akun; admin Workspace harus mengizinkan berbagi ke luar domain — **wajib diuji** |
| **C. Gmail pribadi tambahan** | Gratis, cepat | Risiko penangguhan paling besar; pemulihan sulit |

**Rekomendasi:** uji A (bila tersedia) atau B dengan **satu akun percobaan** sebelum membuat
banyak akun. Rencana teknis di bawah sama untuk ketiga opsi; yang berbeda hanya modul adaptor
(untuk opsi A mungkin memakai API resmi, bukan `notebooklm-py`).

### 1.2 Batas Google yang harus diukur dengan akun percobaan

| Batas | Nilai dipakai sekarang | Cara ukur |
|---|---|---|
| Viewer per notebook | 2.000 (sudah diuji pemilik) | — |
| Notebook per akun | ≥ 336 (akun sekarang) | Buat notebook sampai ditolak, di akun uji |
| Operasi sharing per jam per akun | belum diketahui | Worker mencatat latensi & galat per akun (sudah ada p50/p95) |
| Berbagi Workspace → Gmail | belum diketahui | Bagikan 1 notebook akun uji ke Gmail pribadi |

### 1.3 Keputusan lain

- Kebijakan sebaran: isi akun satu per satu **atau** sebar merata (rekomendasi: sebar, §5).
- Kapasitas cadangan minimum per modul (rekomendasi: ≥ kapasitas satu akun terbesar, §5.3).
- Siapa yang boleh menambah akun & clone (rekomendasi: hanya pemilik lewat bot, dengan konfirmasi).

---

## 2. Hitungan kapasitas

Rumus per modul:

```
kursi_per_akun   = (1 + jumlah_clone) × admission_limit      ≈ 14 × 1.995 = 27.930
akun_dibutuhkan  = ceil(pembeli_aktif_modul / kursi_per_akun) + 1 cadangan
```

- Kebutuhan dihitung **per modul**. Satu pembeli Tahawwulat memakai 1 kursi di **setiap** AI
  Tahawwulat (5 AI), tetapi tiap AI punya notebook sendiri sehingga rumusnya sama per AI.
- Paket "semua AI" memakai 1 kursi di setiap modul.

| Pembeli aktif satu modul | Akun (termasuk 1 cadangan) |
|---|---|
| 28.000 | 2 |
| 100.000 | 5 |
| 200.000 | 9 |
| 300.000 | 12 |
| 1.000.000 | 37 |

Akun tidak harus memuat semua modul. Akun tambahan bisa khusus untuk modul yang ramai saja.

---

## 3. Arsitektur target

```
Aplikasi ──getAgentUrl──► Cloud Function resolve() ──► assignment pelanggan ──► link notebook (akun mana pun)
                                                           ▲
Worker VPS: alokasi ─► job sharing ─► adaptor ─► sesi akun X ─► Google NotebookLM (akun X)
            rekonsiliasi per notebook (cek ada, publik?, JUDUL, isi)        
Registry Firestore: notebook_accounts · access_notebooks · notebook_entities
Bot pemilik: /akun /kapasitas /tambah_akun /daftar_clone /drain_akun /karantina
Monitor: sesi per akun, kapasitas per modul, clone hilang/salah judul/tertinggal isi
```

Aplikasi **tidak berubah**. Ia sudah membuka link apa pun yang diberikan server, dan sudah
menolak bila akun Google di WebView berbeda dari email pelanggan.

---

## 4. Model data

### 4.1 `notebook_accounts/{accountId}` (baru)

| Field | Isi |
|---|---|
| `email` | akun pemilik, mis. `nb02@openturath.id` |
| `status` | `active` · `draining` (tidak menerima kursi baru) · `suspended` (Google menolak) · `retired` |
| `session_file` | nama file sesi di VPS: `secrets/sessions/<accountId>.json` |
| `notebook_limit` | hasil pengukuran §1.2 |
| `last_session_ok_ms`, `last_session_error` | diisi worker |
| `share_ops_per_hour_limit` | batas laju per akun (default konservatif, mis. 300) |
| `created_by`, `created_ms`, `notes` | audit |

### 4.2 `access_notebooks/{notebookId}` (ditambah field)

| Field baru | Isi |
|---|---|
| `account` | `accountId` pemilik notebook |
| `expected_title` | judul yang wajib, mis. `06.1 - AL-MUHAQQIQ - 05` |
| `title_ok`, `title_checked_ms`, `observed_title` | hasil verifikasi worker |
| `content_version`, `source_count`, `source_hash` | hasil pemeriksaan isi (§9) |
| `status` | + `pending_verification` (baru didaftarkan) · `quarantined` (judul/isi salah) |

### 4.3 `notebook_entities/{entityCode}` (baru, pengganti `notebook_catalog.ts`)

| Field | Isi |
|---|---|
| `scope` | kunci hak akses, mis. `fiqh_tahawwulat` |
| `master_id` | notebook master |
| `title_prefix` | mis. `06.1 - AL-MUHAQQIQ` |
| `content_version`, `source_manifest` | daftar sumber kitab master yang menjadi acuan |

Selama migrasi, `notebook_catalog.ts` tetap menjadi sumber kebenaran untuk akun pertama.
Registry diisi dari katalog itu, lalu worker membaca registry. Kode lama dihapus setelah stabil.

---

## 5. Alokasi kursi antar-akun

### 5.1 Aturan memilih notebook untuk pelanggan baru

1. **Lekat:** jika pelanggan sudah punya kursi aktif di modul itu, pakai itu (sudah ada).
2. Kandidat hanya notebook dengan: `status = active`, `title_ok = true`, `is_public = false`,
   sehat < 24 jam, akun berstatus `active` dengan sesi sehat, isi tidak tertinggal.
3. Di antara kandidat, pilih **akun dengan persentase terisi paling rendah**, lalu di dalam akun
   itu urut master → clone 01 → 02 … (tetap rapat per notebook).
4. Batas sebaran: bila modul punya ≥ 3 akun, satu akun tidak boleh memegang > 40% kursi modul.

### 5.2 Mengapa disebar

Bila satu akun ditangguhkan, yang terdampak hanya sebagian pelanggan, dan mereka bisa dipindah
ke kapasitas akun lain. Mengisi satu akun sampai penuh membuat satu kejadian memutus puluhan
ribu pelanggan sekaligus.

### 5.3 Kapasitas cadangan

Aturan alarm: `kursi_kosong_modul ≥ kursi_terpakai_di_akun_terbesar`. Artinya bila akun terbesar
hilang, semua pelanggannya masih muat di akun lain. Bila tidak terpenuhi, alarm
`capacity_no_failover_headroom` meminta clone baru.

### 5.4 Throughput

`runJobs` sudah paralel per notebook. Ditambah batas **per akun** (`share_ops_per_hour_limit`)
supaya satu akun tidak menembus batas laju Google, dan supaya menambah akun juga menambah
kecepatan sharing.

---

## 6. Pengaman "jangan salah link" (berlapis)

| Lapisan | Kapan | Jika gagal |
|---|---|---|
| L1. Judul dari Google = `expected_title` | Saat didaftarkan, lalu tiap putaran rekonsiliasi | `quarantined`, tidak pernah dibagikan, alarm |
| L2. Notebook terdaftar di entitas yang benar (`entity` & `scope`) | Setiap `reserve()` dan `resolve()` | Ditolak, alarm |
| L3. Akun pemilik dari Google = `account` | Saat didaftarkan & rekonsiliasi | `quarantined` |
| L4. Isi cocok dengan manifest master (jumlah & nama sumber) | Pemeriksaan isi berkala | Tidak menerima kursi baru; alarm `clone_content_drift` |
| L5. Pelanggan & email terverifikasi; WebView harus login email yang sama | Saat membuka (sudah ada) | Pesan "akun berbeda" di aplikasi |
| L6. Link hanya dari assignment pelanggan yang `ready` & terverifikasi | `resolve()` (sudah ada) | "Akses sedang disiapkan" |

Tes yang wajib ada: clone salah judul tidak pernah dialokasikan; clone pindah akun dikarantina;
pelanggan di clone yang dikarantina dipindah; link yang dikembalikan selalu milik modul yang dibuka.

---

## 7. Sesi Google per akun

- File: `secrets/sessions/<accountId>.json` (mode 600) di VPS. Satu file per akun, tidak pernah
  dicampur.
- Adaptor `verified_sharing.py` menerima `account` di permintaan dan memakai file sesi akun itu.
  Notebook tanpa `account` memakai akun pertama (kompatibel dengan data sekarang).
- Perpanjangan sesi dilakukan dari Mac pemilik dengan profil Chrome terpisah per akun:
  `deploy/push_session.sh <host> <accountId>`.
- Pemantauan per akun: `last_session_ok_ms`. Alarm `owner_session_expired:<accountId>` bila
  > 30 menit gagal. Saat sesi satu akun mati, alokasi otomatis berhenti memilih akun itu.
- Jadwal: cek kesehatan sesi setiap akun setiap jam; pengingat login ulang ke pemilik sebelum kedaluwarsa (bila umurnya bisa dibaca).

---

## 8. Pabrik clone (membuat & mendaftarkan clone di akun baru)

1. **Manifest master:** daftar sumber kitab master (nama, berkas, urutan), disimpan di bucket
   privat. Dibuat sekali per modul dari notebook master.
2. **Buat clone di akun X:** alat membuat notebook berjudul `<title_prefix> - NN`, mengunggah
   semua sumber dari manifest, menyetel *restricted* + *chat only*, lalu mencatat ID-nya.
   Pengembangan dari `clone_master_notebook.py`, dijalankan di VPS dengan sesi akun X.
3. **Daftarkan:** `access_notebooks/{id}` dengan `status: pending_verification`, `account`,
   `expected_title`. Lewat bot: `/daftar_clone <akun> <modul> <id>` atau otomatis oleh alat.
4. **Verifikasi worker:** L1, L3, L4 lolos → `active`. Gagal → `quarantined`.
5. **Mulai dipakai:** allocator memilihnya sesuai §5.

Tidak ada langkah yang membutuhkan rilis kode atau aplikasi baru.

---

## 9. Sinkronisasi isi kitab

- `content_version` per entitas naik setiap kali master ditambah/diubah sumbernya.
- Pemeriksa isi membandingkan sumber setiap clone dengan manifest. Clone yang tertinggal:
  1. tidak menerima pelanggan **baru**;
  2. masuk antrean pembaruan (alat menambahkan sumber yang kurang);
  3. setelah cocok, `content_version` disamakan dan kembali `active`.
- Alarm `clone_content_drift` bila ada clone tertinggal > 24 jam.

---

## 10. Kegagalan satu akun (failover)

| Kejadian | Deteksi | Tindakan otomatis | Tindakan pemilik |
|---|---|---|---|
| Sesi kedaluwarsa | Sesi gagal > 30 menit | Akun keluar dari alokasi; kursi lama tetap (tidak dicabut) | Login ulang, `push_session.sh` |
| Akun ditangguhkan Google | Semua notebook akun "not found"/ditolak 3× | Akun `suspended`; notebook `missing`; pelanggan dipindah bertahap ke akun lain | Urus banding ke Google; tambah kapasitas bila perlu |
| Satu clone terhapus | Clone "not found" 3× | Sudah ada: `missing` + pindahkan anggotanya | Buat clone pengganti |
| Clone salah judul/isi | L1/L4 | `quarantined`; anggota dipindah | Periksa & perbaiki |
| Kapasitas tidak cukup untuk memindah | Relokasi gagal `resource-exhausted` | Pelanggan menunggu kursi (pembayaran aman), alarm | Buat clone |

Laju pemindahan dibatasi (mis. 200 per jam per akun tujuan) supaya tidak memicu batas Google.

---

## 11. Alarm baru (grup alert Telegram)

| Kode | Pemicu |
|---|---|
| `owner_session_expired:<akun>` | sesi akun gagal > 30 menit |
| `account_suspected_suspended:<akun>` | ≥ 3 notebook akun itu "not found" berturut-turut |
| `capacity_low:<modul>` | kursi kosong < 20% kapasitas modul |
| `capacity_no_failover_headroom:<modul>` | aturan §5.3 tidak terpenuhi |
| `notebook_title_mismatch` | ada notebook dikarantina karena judul/akun |
| `clone_content_drift` | ada clone tertinggal isi > 24 jam |
| `account_rate_limited:<akun>` | galat laju Google berulang |

---

## 12. Perintah bot pemilik baru

| Perintah | Fungsi |
|---|---|
| `/kapasitas [modul]` | Kursi terpakai/kosong per modul & per akun |
| `/akun` | Daftar akun, status, umur sesi, jumlah notebook & kursi |
| `/tambah_akun <email> <alasan>` | Mendaftarkan akun pemilik baru (konfirmasi) |
| `/daftar_clone <akun> <modul> <id…>` | Mendaftarkan clone (konfirmasi; worker memverifikasi) |
| `/drain_akun <akun> <alasan>` | Berhenti memakai akun untuk kursi baru (konfirmasi) |
| `/pindah_akun <akun> <alasan>` | Memindahkan semua pelanggan keluar dari akun (konfirmasi, bertahap) |
| `/karantina` | Notebook yang dikarantina dan alasannya |

Semua mengikuti pola yang sudah ada: pratinjau → tombol ✅ → audit.

---

## 13. Pengujian

1. **Unit:** pemilihan akun (§5.1), batas 40%, cadangan §5.3, L1–L4, sesi per akun di adaptor,
   karantina, failover akun.
2. **Simulasi skala:** 300.000 pelanggan sintetis, 3 modul, 12 akun, termasuk satu akun hilang di
   tengah jalan. Lulus bila: tidak ada pelanggan di notebook modul lain, tidak ada notebook > batas,
   semua pelanggan akun yang hilang dipindah atau menunggu dengan alarm.
3. **Akun uji sungguhan:** 1 akun percobaan, 2 clone kecil, 3 pelanggan uji. Uji: berbagi,
   membuka dari aplikasi, judul salah (sengaja), sesi kedaluwarsa (sengaja), akun di-drain.
4. **Uji batas Google** (§1.2) dengan akun percobaan, bukan akun produksi.

---

## 14. Tahapan pelaksanaan

| Tahap | Isi | Butuh dari pemilik | Selesai bila |
|---|---|---|---|
| **0. Keputusan** | §1: jenis akun, kebijakan sebaran, cadangan | Keputusan + cek ketentuan | Keputusan tertulis |
| **1. Pengaman judul** | L1–L3 untuk 336 notebook yang ada; karantina; alarm | — | Semua notebook sekarang `title_ok` atau dikarantina dengan alasan |
| **2. Registry** | Firestore `notebook_accounts`/`notebook_entities`, isi dari katalog sekarang; worker membaca registry | — | Perilaku sama persis dengan sekarang, tes lulus |
| **3. Sesi per akun** | Adaptor & worker per akun; `push_session.sh <akun>`; alarm sesi | — | Akun pertama berjalan lewat jalur baru |
| **4. Akun percobaan** | Daftarkan akun ke-2, 2 clone, pelanggan uji; ukur batas §1.2 | Buat akun ke-2 (jenis sesuai keputusan), login sekali | Uji §13.3 lulus |
| **5. Alokasi & failover** | §5, §10; perintah bot §12 | — | Simulasi §13.2 lulus |
| **6. Pabrik clone & sinkronisasi** | §8, §9 | Manifest sumber per modul | Satu modul penuh (13 clone) dibuat otomatis di akun ke-2 |
| **7. Skala bertahap** | Tambah akun sesuai rumus §2, satu per satu | Membuat akun & login | Alarm kapasitas hijau di semua modul |

Tahap 1 bisa dikerjakan sekarang dan langsung melindungi sistem yang berjalan. Tahap 4 ke atas
sebaiknya menunggu keputusan §1.1.

---

## 15. Runbook singkat

**Menambah akun baru**
1. Buat akun (sesuai §1.1), login di profil Chrome tersendiri di Mac.
2. `/tambah_akun nb03@openturath.id kapasitas tahawwulat` → ✅.
3. `deploy/push_session.sh <host> nb03` untuk mengirim sesi ke VPS.
4. Jalankan pabrik clone untuk modul yang perlu kapasitas.
5. Tunggu worker memverifikasi; `/kapasitas` menunjukkan kursi bertambah.

**Sesi satu akun kedaluwarsa** — login ulang di profil Chrome akun itu, lalu `push_session.sh <akun>`.
Pelanggan lama tidak terdampak; hanya kursi baru yang menunggu.

**Akun ditangguhkan** — `/akun` memastikan; worker sudah memindah pelanggan bila ada kapasitas.
Bila tidak cukup, buat clone di akun lain; `/kapasitas` memantau.

**Laporan "link salah"** — `/status email` menunjukkan notebook pelanggan. `/karantina <id>` bila
notebook itu salah, lalu worker memindah pelanggannya.

---

## 16. Risiko utama

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Penangguhan akun oleh Google | Pelanggan di akun itu terputus | §1.1 jenis akun, §5 sebaran, §5.3 cadangan, §10 failover |
| Pustaka tidak resmi berubah/rusak | Sharing berhenti total | Pantau kegagalan provider (sudah ada); siapkan jalur API resmi (opsi A) |
| Sesi banyak akun sulit dirawat | Kursi baru tertahan | §7 alarm per akun, prosedur perpanjangan sesi |
| Clone salah judul/isi | Pelanggan membuka kitab yang salah | §6 L1–L4 |
| Isi clone tertinggal | Jawaban AI berbeda antar pelanggan | §9 |
| Batas laju Google | Antrean lambat saat ramai | §5.4 batas per akun, lebih banyak akun |
