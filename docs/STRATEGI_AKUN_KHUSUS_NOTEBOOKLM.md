# Strategi Cara 1: Akun Google Khusus + Master Token di VPS

Dokumen keputusan dan rencana kerja. Disusun 29 Oktober 2026 setelah audit sistem akses OpenTurath AI.
Status: **rencana, belum dijalankan**. Tidak ada langkah di dokumen ini yang sudah dieksekusi.

---

## 0. Ringkasan satu halaman

**Masalah yang ingin diselesaikan.** Pemberian akses (membagikan notebook NotebookLM ke pengguna yang membayar) hanya
berjalan selama sesi login Google milik pemilik tetap hidup. Di era GoAkal sesi itu menyembuhkan dirinya sendiri dari
*master token*. Di sistem sekarang (worker VPS "vps-v2") sesi harus dikirim manual dari laptop. Kalau sesi mati, semua
pemberian akses berhenti sampai pemilik turun tangan.

**Cara 1** = pindahkan seluruh notebook ke satu **akun Google khusus** yang hanya dipakai untuk NotebookLM, lalu simpan
**master token akun khusus itu di VPS** supaya VPS memperbarui sesinya sendiri.

**Mengapa cara 1 layak dipertimbangkan.** Master token adalah kredensial seumur hidup berdaya penuh atas seluruh akun
Google. Di akun utama pemilik (Gmail, Drive, YouTube, dan sebagainya) kebocoran VPS berarti kebocoran seluruh hidup digital
pemilik. Di akun khusus, dampaknya terbatas pada NotebookLM.

**Biaya cara 1.** NotebookLM tidak punya fitur "alihkan kepemilikan". Notebook harus **digandakan** ke akun baru dan
dibagikan ulang, sehingga **semua ID notebook berubah**. Itu menyentuh katalog, ledger, dan worker.

**Temuan yang mengubah hitungan.** Data produksi menunjukkan hanya ±73 alamat email unik yang punya penugasan `ready`
(79 UID), tetapi ada 632 notebook dengan batas isi 1.995 kursi per notebook. Yang harus dipindah jauh lebih sedikit
daripada yang terlihat: cukup **24 notebook induk + beberapa klon**, bukan 632 (lihat bagian 6).

**Rekomendasi.** Lakukan cara 1 secara bertahap dengan pola *expand → verify → contract*, **dua worker berdampingan**
selama masa transisi (satu per akun), dengan sewa penulis per akun agar tidak saling menimpa. Estimasi 3 sampai 5 hari
kerja, dengan titik berhenti dan jalan mundur di setiap fase.

**Pilihan alternatif (cara 2).** Master token tetap di laptop, sesi dikirim ke VPS berkala. Aman tetapi tidak sepenuhnya
otomatis. Perbandingan lengkap di bagian 3.

---

## 1. Konteks: bagaimana sistem sampai di sini

### 1.1 Dua generasi otomasi

| | Era GoAkal | Sekarang (vps-v2) |
|---|---|---|
| Pembayaran | GoAkal menangani pembayaran dan pelanggan | Midtrans Snap, webhook ke Cloud Functions |
| Pencatatan hak | Dicatat GoAkal + webhook sederhana | Ledger Firestore v2: `access_grants`, `access_jobs`, `access_assignments`, `access_notebooks`, `access_memberships` |
| Pemberi akses | `webhook_server.py` di Cloud Run memanggil `notebooklm_manager.py` | Worker Node `access_worker.js` di VPS memanggil adapter `verified_sharing.py` |
| Sesi Google | **Menyembuhkan diri**: bila `storage_state.json` kedaluwarsa, `_ensure_fresh_cookies()` membuat cookie baru dari `master_token.json` | **Statis**: memakai `storage_state.json` yang dikirim manual (`push_session.sh`); adapter sengaja *tidak* membuat kredensial |
| Titik gagal | Sedikit | Banyak mata rantai, tiap mata rantai punya cara gagalnya sendiri |

Intuisi pemilik benar: sesi era GoAkal "selalu berhasil" karena master token. Itu bagian yang hilang dari rancangan sekarang.

### 1.2 Rantai setelah pembayaran (sekarang)

```
Midtrans settlement → midtransWebhook → processSuccessfulPayment
  → users/{uid}.access_due_ms = sekarang
  → worker VPS (siklus 15 s) → access_jobs (dijalankan tiap 1 s)
  → verified_sharing.py → NotebookLM (sharing.add_user)
  → access_assignments.status = ready (+ verified_ms)
  → getAgentUrl memberi URL notebook → aplikasi
```

Pada kondisi sehat seluruh rantai selesai dalam hitungan detik. Jaring pengaman ditambahkan 29 Oktober:
`monitorPaidWithoutAccess` (tiap 2 menit), `auditMidtransLedger` (harian), dan `getAccessReadiness` yang kini membaca
penugasan `ready`, bukan status outbox.

### 1.3 Keadaan produksi saat audit

- Worker VPS sehat: detak 0,2 menit, 4.129 siklus, 4.168 panggilan penyedia, ±50 gagal (1,2%), tanpa galat autentikasi,
  `session_refreshes = 0` (sesi tidak pernah diperbarui otomatis).
- 632 notebook dalam 24 entitas (kajian), 1.949 kursi terisi, 1.260 penugasan `ready`.
- Cookie sesi pemilik: `SID`/`__Secure-1PSID` berlaku sampai 2028, `__Secure-1PSIDTS` sampai September 2027. Namun
  Google dapat membatalkan sesi kapan saja (perubahan kata sandi, pemeriksaan keamanan, pembatasan sesi terikat perangkat).
- `master_token.json` ada di komputer pemilik (dibuat 11 Juli 2026). **Validitasnya belum pernah diuji.**
- Audit Midtrans: 0 pembayaran hilang (92 transaksi dicocokkan satu per satu). Masalahnya bukan di Midtrans.

### 1.4 Risiko tabrakan penulis yang ditemukan

1. Skrip lama (`manual_sync.py`, `notebooklm_manager.py`, reaper) tidak memeriksa penanda `writer`, jadi bila dijalankan
   dari laptop mereka menulis bersamaan dengan worker VPS. Worker VPS lalu "memperbaiki" (menghapus) anggota yang tidak ada
   di ledger. **Sudah diperbaiki di kode** (`writer_guard.py`, fail-closed) namun belum dipasang di server mana pun.
2. Worker tidak punya penjaga satu-instance. **Sudah dibangun** `worker_lease.ts` (primary/standby, fencing),
   belum dipasang di VPS.

---

## 2. Definisi cara 1

1. **Akun khusus** (mis. `notebook@…`): akun Google baru, hanya untuk NotebookLM, dengan verifikasi dua langkah, tanpa
   Gmail/Drive berisi data pribadi. Menjadi **pemilik** semua notebook produksi.
2. **Master token akun khusus** dibuat sekali (login `EmbeddedSetup` di browser), disimpan di VPS (`secrets/`, mode 600,
   tidak di git). VPS membuat cookie sesi sendiri bila sesi mati.
3. **Notebook digandakan** dari akun lama ke akun baru, dibagikan ulang ke pengguna.
4. **Akun lama (utama) tidak lagi memegang kredensial otomasi.** Master token akun utama dihapus dari semua mesin setelah
   masa transisi.

Yang **tidak** berubah: Midtrans, ledger, aplikasi, pengguna, aturan VIP, aturan hak per-modul.

---

## 3. Perbandingan cara 1 dan cara 2

| Kriteria | Cara 1: akun khusus + token di VPS | Cara 2: token di laptop, sesi dikirim berkala |
|---|---|---|
| Otomatis penuh | Ya, VPS memulihkan sesinya sendiri | Tidak. Bergantung laptop menyala dan skrip kirim berjalan |
| Dampak bila VPS bocor | Terbatas pada akun khusus | Sesi pemilik bocor; master token tetap aman di laptop |
| Dampak bila laptop hilang | Tidak berpengaruh pada produksi | Pemulihan sesi tertunda |
| Biaya perubahan | **Tinggi**: ID notebook berubah, ledger dan katalog dipetakan ulang | Rendah: tidak ada migrasi |
| Risiko saat transisi | Sedang: akses sebagian pengguna dapat terganggu bila salah langkah | Hampir nol |
| Ketahanan terhadap pencabutan sesi Google | Baik jika master token masih berlaku | Lemah: pemulihan manual |
| Pemulihan setelah kerusakan | Mudah (token baru di satu mesin) | Perlu operator |
| Waktu pengerjaan | 3 sampai 5 hari kerja | <1 hari |

**Keputusan 29 Oktober 2026:** pemilik memilih cara 2 untuk saat ini. Dokumen ini disimpan agar cara 1 bisa dijalankan
tanpa riset ulang bila keputusan berubah.

---

## 4. Fakta yang BELUM diverifikasi (jangan dianggap benar)

Setiap item di bawah harus diuji sebelum fase yang bergantung padanya.

| # | Asumsi | Cara menguji | Bergantung pada |
|---|---|---|---|
| A1 | Master token akun khusus dapat dibuat dari VPS-IP tanpa tantangan keamanan Google | Buat di laptop, pakai di VPS, jalankan `notebooks.list()` | Fase 2 |
| A2 | Master token berumur panjang di dunia nyata (tidak dicabut dalam hitungan hari) | Pantau 7 hari sebelum cutover | Fase 2 |
| A3 | `clone_master_notebook.py` menyalin 100% sumber untuk notebook besar (batas sumber per notebook, batas ukuran) | Gandakan satu notebook kecil dan satu besar, bandingkan jumlah dan isi sumber | Fase 3 |
| A4 | Akun baru dapat membagikan ke ratusan penerima tanpa pembatasan laju Google | Bagikan bertahap, ukur laju gagal | Fase 4 |
| A5 | Pengguna tidak kehilangan sesuatu yang penting dengan notebook baru (riwayat obrolan per-notebook akan kosong) | Konfirmasi dengan beberapa pengguna uji | Fase 4 |
| A6 | Kebijakan Google mengizinkan pola akun khusus + otomasi bagi layanan berbayar ini | Baca ketentuan NotebookLM/akun Google | Sebelum mulai |
| A7 | Worker sesi kedua (akun baru) tidak berbagi `storage_state` dengan yang lama | Pisahkan jalur penyimpanan per akun | Fase 2 |

---

## 5. Strategi teknis

### 5.1 Prinsip

1. **Expand, verify, contract.** Bangun yang baru berdampingan, buktikan benar, baru matikan yang lama. Tidak ada saat
   ketika pengguna berbayar tanpa notebook yang berfungsi.
2. **Satu penulis per akun pada satu waktu.** Sewa penulis diperluas menjadi per-akun.
3. **Tidak ada pencabutan otomatis selama transisi.** `revocations_paused: true` dipertahankan di seluruh migrasi.
4. **VIP tidak pernah disentuh** (Aturan Sakral 5). Semua langkah migrasi mengecualikan pencabutan VIP dan menjaga
   `access_revocation_hold`.
5. **Setiap langkah dapat dibatalkan** tanpa kehilangan data atau akses.

### 5.2 Bahaya terbesar: ganti akun = semua notebook lama "hilang"

Worker menandai notebook `missing` bila Google tidak menampakkannya kepada akun pemilik (3 kali berturut-turut), lalu
mengaktifkan perbaikan dan penugasan ulang. Bila `ACCESS_OWNER_EMAIL` dan `storage_state.json` diganti begitu saja,
**seluruh 632 notebook lama akan dianggap hilang** dan ledger mulai mengacak penugasan. Karena itu:

- **Jangan** mengganti akun pada worker yang berjalan.
- Jalankan **worker kedua** untuk akun baru dengan `storage_state` sendiri, hanya untuk notebook milik akun baru.
- Katalog diberi atribut `owner` per notebook; tiap worker hanya mengamati dan menulis notebook milik akunnya.

### 5.3 Perubahan kode yang dibutuhkan

| # | Perubahan | Berkas | Catatan |
|---|---|---|---|
| C1 | Atribut `owner` pada setiap notebook di katalog dan `access_notebooks` | `notebook_catalog.ts`, `access_catalog.ts`, `access_worker.ts` | Bawaan `"legacy"` agar data lama tetap valid |
| C2 | Worker hanya memproses notebook dengan `owner == ACCESS_OWNER_ID` | `access_worker.ts` (`reconcile`, `runJobs`, `adoptNotebook`) | Mencegah dua worker saling menandai `missing` |
| C3 | Sewa penulis per akun: `writer_lease_<ownerId>` | `worker_lease.ts` | Saat ini satu sewa global |
| C4 | Alokator memilih notebook berdasarkan `owner` target (baru) untuk penugasan baru | `access_control.ts` (`reserve`) | Penugasan lama tetap di notebook lamanya sampai dimigrasi |
| C5 | Perintah `--migrate-assignment` per pengguna: tambah akses di notebook baru, verifikasi, ubah penugasan, tunda pencabutan di notebook lama | `access_worker.ts` | Idempoten, dapat diulang |
| C6 | Pembuatan sesi dari master token di adapter, dengan persetujuan eksplisit (`ACCESS_ALLOW_MINT=1`) | `verified_sharing.py` | Saat ini secara sengaja dilarang; mengubahnya adalah keputusan pemilik |
| C7 | Alarm kedaluwarsa sesi dini dan alarm kegagalan mint | `monitorAccessHealth` | Telegram |
| C8 | Tes: dua worker + dua akun, tabrakan tidak terjadi, `missing` tidak menjalar | `functions/test/` | Wajib hijau sebelum pemasangan |

### 5.4 Fase kerja

**Fase 0: Persiapan dan keputusan (0,5 hari)**
- Pemilik memutuskan nama dan keamanan akun khusus (verifikasi dua langkah, nomor pemulihan terpisah).
- Baca ketentuan Google untuk A6.
- Bekukan: `revocations_paused: true`, tidak ada perubahan katalog lain, jadwalkan jendela perubahan.
- Cadangkan Firestore (ekspor) dan arsipkan `access_notebooks`, `access_assignments`, `access_memberships`.

**Fase 1: Kode dan tes (1 sampai 1,5 hari)** — C1 sampai C5, C7, C8. Tidak ada perubahan produksi.

**Fase 2: Akun khusus dan master token (0,5 hari)**
1. Buat akun khusus, login `EmbeddedSetup` sekali di browser laptop, buat master token (uji A1).
2. Salin ke VPS (`secrets/master_token_<akun>.json`, mode 600), uji `notebooks.list()` dari VPS.
3. Jalankan sebagai pemantau saja 7 hari (uji A2); tanpa menulis ke pengguna.
4. Aktifkan C6 hanya pada worker akun khusus.

**Fase 3: Gandakan notebook (0,5 sampai 1 hari)**
1. Mulai dengan satu entitas kecil; bandingkan jumlah dan isi sumber dengan aslinya (A3).
2. Gandakan 24 notebook induk, lalu secukupnya klon. **Kapasitas dihitung ulang dari data pengguna nyata**
   (73 email unik, batas 1.995 kursi per notebook): satu induk + satu klon per entitas sudah lebih dari cukup untuk
   saat ini.
3. Catat ID baru ke katalog dengan `owner = "khusus"`. Worker akun khusus mengadopsinya setelah Google menampakkannya.

**Fase 4: Pindahkan pengguna bertahap (1 sampai 2 hari)**
1. **Kanari.** 3 sampai 5 akun uji (termasuk satu akun VIP, satu Tahawwulat, satu legacy) dipindah dengan C5. Setiap
   akun diverifikasi: aplikasi membuka notebook baru, tanya jawab berfungsi.
2. **Gelombang kecil**: 10 pengguna, tunggu 24 jam, periksa alarm dan `access_reviews`.
3. **Sisanya** dalam kelompok. Urutan: pengguna berlangganan aktif dahulu, lalu voucher/trial, lalu akun legacy.
4. Penugasan baru (pembayaran baru) sejak awal fase ini diarahkan ke notebook akun khusus (C4).
5. Notebook lama **tidak dihapus**. Anggotanya hanya dicabut setelah pengguna terverifikasi di notebook baru, dan
   setelah Fase 5.

**Fase 5: Stabilisasi (7 hari)**
- Pantau: laju gagal penyedia, `session_refreshes`, `access_reviews`, keluhan pengguna.
- Notebook lama tetap utuh sebagai jalan mundur.
- Tidak ada pencabutan otomatis.

**Fase 6: Contract (0,5 hari, setelah Fase 5 bersih)**
1. Hapus anggota dari notebook lama untuk pengguna yang sudah pindah.
2. Hapus `master_token.json` akun utama dari semua mesin; cabut perangkat terkait di pengaturan keamanan Google.
3. Matikan worker akun lama; arsipkan `storage_state` lama.
4. Nyalakan kembali `revocations_paused: false` hanya setelah daftar calon pencabutan ditinjau pemilik.

### 5.5 Rencana mundur

| Gejala | Tindakan | Dampak |
|---|---|---|
| Penyalinan sumber tidak lengkap (A3) | Berhenti di Fase 3, tidak ada pengguna terpengaruh | Nol |
| Kanari gagal di Fase 4 | Kembalikan penugasan akun uji ke notebook lama (C5 memiliki arah sebaliknya) | Beberapa akun uji |
| Laju gagal tinggi saat membagikan (A4) | Perkecil kelompok, perpanjang jeda | Tertunda |
| Master token akun khusus dicabut Google | Kirim sesi manual (cara 2) sebagai cadangan sementara | Tertunda, tidak hilang |
| Kegagalan umum | `writer: "legacy"`/`revocations_paused: true`, worker lama tetap memegang notebook lama | Pengguna lama tetap terlayani |

Rollback hanya mengembalikan penugasan, bukan keanggotaan di Google; keanggotaan dicabut hanya di Fase 6 dan
tidak dapat dibatalkan otomatis, karena itu Fase 6 hanya dilakukan setelah Fase 5 bersih.

---

## 6. Menghitung beban migrasi yang sebenarnya

Dari data produksi 29 Oktober 2026:

| Besaran | Nilai | Arti |
|---|---|---|
| Notebook | 632 (625 aktif, 7 draining) | Hampir semuanya salinan pra-pembuatan |
| Entitas (kajian) | 24 | 22 dengan 27 sampai 28 notebook, 2 dengan 14 |
| Kursi terisi | 1.949 | Termasuk pengamatan kursi pada notebook legacy |
| Penugasan `ready` | 1.260 | Satu pengguna dapat punya banyak entitas (Tahawwulat = 5) |
| Email unik berpenugasan `ready` | ±73 | **Jumlah manusia yang harus dipindah** |
| Batas penerimaan / batas keras per notebook | 1.995 / 2.000 | Kapasitas per notebook besar sekali dibanding pengguna |

Kesimpulan: pekerjaan nyata adalah **menggandakan kurang lebih 24 sampai 48 notebook** dan **memindah ±79 UID**, bukan
632 notebook. Penggandaan notebook adalah langkah paling berisiko dan paling lama (waktu, kuota, dan kebenaran isi).

Catatan: ±73 hanya penugasan `ready`. Akun legacy yang diadopsi (45 penugasan `adopted`) dan akun dengan hak yang
tertahan di `v2_review` harus didata penuh di Fase 0 sebelum angka migrasi final ditetapkan.

---

## 7. Keamanan

- Master token: berkas `secrets/` mode 600 di VPS, di luar git (sudah di `.gitignore`), tidak pernah dicatat di log.
- Akun khusus: verifikasi dua langkah, kata sandi unik, tidak dipakai untuk apa pun selain NotebookLM, nomor pemulihan
  terpisah dari akun pribadi pemilik.
- VPS: akses SSH hanya kunci, firewall, pembaruan otomatis keamanan, tanpa layanan lain yang tidak perlu.
- Pemulihan: dokumentasikan siapa yang boleh membuat ulang master token dan di mana.
- Aturan sesi Google di aplikasi (Aturan 8) tidak berubah: aplikasi tidak menyentuh cookie sesi Google pengguna.

---

## 8. Pemantauan dan kriteria selesai

**Alarm yang harus ada sebelum Fase 4** (beberapa sudah ada):
- Worker per akun tidak berdetak > 5 menit.
- Kegagalan mint master token.
- Sesi mendekati kedaluwarsa (`__Secure-1PSIDTS` < 48 jam).
- Pembayaran lunas tanpa penugasan `ready` > 3 menit (**sudah ada**).
- Selisih Midtrans vs ledger (**sudah ada**, harian).
- Notebook ditandai `missing`.

**Kriteria selesai**
1. Seluruh pengguna aktif membuka notebook baru dan menjawab pertanyaan uji.
2. 7 hari berturut-turut tanpa `authentication_error`.
3. `session_refreshes > 0` terbukti (sesi memulihkan diri setidaknya sekali tanpa campur tangan manusia).
4. Tidak ada entri `access_reviews` baru akibat migrasi.
5. Master token akun utama dihapus dan perangkat dicabut.

---

## 9. Keputusan yang dibutuhkan dari pemilik

| # | Keputusan | Pilihan | Rekomendasi |
|---|---|---|---|
| D1 | Jalankan cara 1 sekarang atau tetap cara 2? | 1 / 2 | Cara 2 sekarang; cara 1 setelah pekerjaan stabilisasi selesai |
| D2 | Identitas dan penyimpanan akun khusus | Bebas | Akun baru, 2SV, pemulihan terpisah |
| D3 | Izinkan adapter membuat cookie dari master token (C6) | Ya/Tidak | Ya, hanya di akun khusus |
| D4 | Jendela waktu migrasi | Tanggal | Di luar jam ramai, bukan saat promosi |
| D5 | Kebijakan notebook lama setelah selesai | Hapus anggota / arsip | Arsip 30 hari lalu hapus anggota |
| D6 | Siapa yang memegang cadangan master token | Pemilik | Hanya pemilik, di pengelola kata sandi |

---

## 10. Daftar periksa eksekusi (ringkas)

- [ ] Ekspor Firestore dan arsipkan koleksi akses
- [ ] `revocations_paused: true` terkonfirmasi
- [ ] Kode C1 sampai C5, C7, C8 selesai dan tes hijau
- [ ] Akun khusus dibuat, 2SV aktif
- [ ] Master token dibuat, dipindah ke VPS, diuji `notebooks.list()` (A1)
- [ ] Pemantauan 7 hari tanpa pencabutan token (A2)
- [ ] Satu notebook kecil dan satu besar digandakan, isi dibandingkan (A3)
- [ ] Kanari 3 sampai 5 akun lulus, termasuk VIP
- [ ] Gelombang 10 pengguna, 24 jam bersih
- [ ] Sisa pengguna dipindah per kelompok
- [ ] 7 hari stabil
- [ ] Contract: anggota notebook lama dicabut, token akun utama dihapus, perangkat dicabut

---

## 11. Rujukan di repositori

- `ecosystem/openturath_subscription/README_VPS.md`: operasi worker, cutover, penulis tunggal
- `ecosystem/openturath_subscription/notebooklm_manager.py`: era GoAkal, `_ensure_fresh_cookies()` (re-mint master token)
- `ecosystem/openturath_subscription/verified_sharing.py`: adapter sekarang ("Never mints Google credentials")
- `ecosystem/openturath_subscription/deploy/push_session.sh`: pengiriman sesi manual dari laptop
- `ecosystem/openturath_subscription/clone_master_notebook.py`: penggandaan notebook
- `ecosystem/openturath_subscription/writer_guard.py`: penjaga skrip lama
- `openturath_ai/functions/src/access_worker.ts`, `worker_lease.ts`, `access_control.ts`, `notebook_catalog.ts`
- `notebooklm_py-0.8.0a3` (`notebooklm/_auth/master_token.py`): alur master token dan peringatan keamanannya
- `AGENTS.md` §5 (VIP sakral), §8 (anti-tamper sesi Google)
