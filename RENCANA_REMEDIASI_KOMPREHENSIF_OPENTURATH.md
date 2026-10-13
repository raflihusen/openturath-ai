# Rencana Remediasi Komprehensif OpenTurath AI

**Tanggal:** 13 Oktober 2026  
**Status:** Rencana teknis; belum merupakan perubahan implementasi atau bukti deployment.  
**Tujuan:** menghilangkan cacat akses dan pembayaran, memperkuat keamanan serta keandalan, dan memperbaiki pengalaman pengguna tanpa mengorbankan hak VIP atau stabilitas WebView.

## 1. Ringkasan eksekutif

Masalah terpenting bukan sekadar validasi satu endpoint, melainkan ketidakkonsistenan keputusan akses antara Cloud Functions, webhook Python, profil Firestore, dan sharing NotebookLM. Perbaikan terbaik adalah **ledger grant terstruktur + satu evaluator akses + satu writer sharing aktif + outbox idempoten**.

Urutan pelaksanaan:

1. Tangani kredensial yang terekspos dan hentikan jalur pencabutan yang keliru.
2. Tambahkan regression test untuk VIP, transaksi nol, retry, event terlambat, dan kegagalan parsial.
3. Terapkan ingest pembayaran terverifikasi, ledger grant, serta evaluator per-modul/per-notebook.
4. Migrasikan dengan shadow evaluation dan rekonsiliasi sebelum mengaktifkan writer baru.
5. Perkuat updater, ketahanan webhook, UI/UX, aksesibilitas, dan pipeline verifikasi.

**Prinsip keberhasilan:** pelanggan tidak kehilangan hak yang sah; VIP selalu terlindungi; satu transaksi tidak menambah durasi berkali-kali; profil dan sharing NotebookLM akhirnya konsisten; kegagalan bisa dipulihkan tanpa intervensi manual berulang.

## 2. Batas bukti dan cakupan

### 2.1 Yang sudah diketahui dari audit

- `flutter analyze` menghasilkan `No issues found` pada pemeriksaan lokal.
- Ada nilai berformat Midtrans server key dalam dokumen tracked Git; keaktifannya belum diketahui.
- Jalur Python dapat tetap menghapus viewer setelah helper database mendeteksi transaksi lain masih aktif.
- Perlindungan VIP pada cabang pencabutan Python hanya memeriksa daftar email statis.
- Cloud Function GoAkal menulis entitlement dari event tanpa deduplikasi pemrosesan atomik.
- Transaksi nol tidak ditolak pada jalur pemberian akses yang diperiksa.
- Default mapping notebook Python berbeda dari master Syafi'i aktif yang ditetapkan proyek.
- Verifikasi hash updater opsional dan unduhan belum memiliki timeout/batas ukuran eksplisit.
- Sheet redeem memiliki risiko overflow dan pesan yang belum terlokalisasi konsisten.
- Percobaan test backend dengan Node standar gagal memuat test; ini bukan bukti assertion aplikasi gagal.

### 2.2 Yang masih wajib diverifikasi

- Endpoint, revision, environment, scheduler, dan writer mana yang benar-benar aktif di produksi.
- Nilai environment notebook; default kode tidak membuktikan nilai deployment.
- Status key pembayaran, jangkauan akses repository, serta riwayat distribusi kredensial.
- Seluruh jalur VIP, reaper, redeem, checkout, penghapusan akun, dan provisioning di luar potongan yang sudah diperiksa.
- Kapabilitas API GoAkal untuk verifikasi transaksi, event ID, refund, dan status terminal.
- Kapabilitas NotebookLM untuk read-back sharing dan semantik retry.
- Kondisi UI nyata di Android/macOS, perangkat kecil, RTL, serta text scaling.
- Cakupan dan mutu test yang sudah tersedia; jangan menyimpulkan tidak ada test hanya karena satu command gagal.

Audit lanjutan menghasilkan register bukti dengan file/baris, revision kode, skenario reproduksi, tingkat dampak, dan status deployment. Temuan yang belum terbukti tidak dijadikan alasan pencabutan akses.

## 3. Aturan mutlak

1. Semua VIP resmi dilindungi: whitelist, `is_vip: true`, `role: vip`, dan sumber `VIP_PERMANENT` yang ditetapkan Owner.
2. Kedaluwarsa satu modul tidak boleh mencabut modul lain.
3. Paket satu bulan dihitung 30 hari; durasi lain mengikuti kontrak produk eksplisit yang disahkan, bukan inferensi nama.
4. Transaksi nominal nol tidak memperpanjang otomatis tanpa persetujuan admin.
5. Keunikan transaksi dan event harus diperiksa secara atomik.
6. Error API, timeout, hasil parsial, atau data ambigu bukan bukti expired.
7. Master Syafi'i aktif `c89d09ca-4b48-4000-a98d-59e532607fb6` wajib masuk katalog dan monitoring.
8. Jangan mengubah siklus hidup WebView di `agent_multi_tab_room.dart` atau `desktop_webview_runtime.dart` dalam paket remediasi akses.
9. Readiness NotebookLM tetap minimal 4 sampel berturut-turut, elapsed minimal 3000 ms, dan micro-delay 250 ms. Error menggantikan viewport dengan `ColoredBox`, bukan overlay platform view.
10. Build APK lokal tidak memicu upload atau broadcast update. `publish_auto_update.py` hanya dijalankan atas instruksi eksplisit pengguna.

## 4. Register pekerjaan prioritas

| ID | Prioritas | Masalah | Tindakan utama | Gerbang selesai |
|---|---|---|---|---|
| SEC-01 | P0 | Server key dalam Git | Verifikasi, revoke/rotasi, redaksi, evaluasi history | Key lama tidak berlaku; key baru tidak bocor |
| ACC-01 | P0 | Revoke meskipun grant aktif | Satu keputusan revoke per notebook | Regression event expired lama lulus |
| ACC-02 | P0 | VIP tidak lengkap | Resolver VIP bersama | Semua sumber VIP terlindungi |
| PAY-01 | P1 | Nol/invalid memberi akses | Validasi nominal dan approval gratis | Nol/NaN/negatif tidak auto-grant |
| PAY-02 | P1 | Replay menimpa expiry | Ledger dan event processing atomik | Retry tidak mengubah grant |
| PAY-03 | P1 | Partial failure tidak pulih | Transaction + durable outbox | Retry melanjutkan langkah belum selesai |
| CAT-01 | P1 | Mapping notebook/produk ambigu | Katalog berdasarkan ID stabil | Tidak ada fallback modul otomatis |
| OPS-01 | P1 | Banyak writer | Ownership writer dan fencing | Hanya writer berwenang dapat mengeksekusi |
| UPD-01 | P2 | Download tidak bounded/hash opsional | Hash wajib, timeout, size cap | Unduhan abnormal ditolak dan dibersihkan |
| UX-01 | P2 | Redeem overflow/localization | Scroll, fleksibilitas, error codes | Matriks viewport/locale lulus |
| QA-01 | P1 | Test runner tidak reproducible | Script test resmi dan CI | Fresh checkout menjalankan test |

P0 adalah penanganan dampak langsung. P1 menghilangkan akar masalah. P2 meningkatkan ketahanan dan mutu. Estimasi kalender ditetapkan setelah inventory deployment dan data selesai; jangan memberi tanggal rilis sebelum gerbang bukti terpenuhi.

## 5. Fase 0 — Inventory dan baseline

### 5.1 Inventaris runtime

Catat tanpa menyalin secret:

- Cloud Functions aktif, region, revision, service account, concurrency, timeout, pemicu.
- Cloud Run/VPS/container yang menerima webhook dan mengelola sharing.
- Cron, systemd timer, scheduler, daemon reaper, dan skrip administratif.
- Koleksi Firestore beserta schema aktual dan indeks.
- Provider pembayaran aktif/legacy dan routing notifikasinya.
- Notebook aktif, legacy, replica, pemilik, modul, dan shared membership.
- App version yang digunakan pelanggan dan kontrak response yang masih dibutuhkan.

### 5.2 Baseline data

Buat snapshot yang dilindungi akses sebelum migrasi: transaksi, entitlement, grant/VIP, katalog, outbox, dan membership observasi. Catat waktu, checksum, revision, serta cara restore. Snapshot tidak disimpan di repo publik.

Hasilkan laporan agregat: transaksi tanpa ID, nominal nol, duplikat, tanggal invalid, entitlement tanpa sumber, mismatch katalog, dan selisih desired/observed membership. Email penuh hanya tersedia untuk operator berwenang.

### 5.3 Deliverable

- Diagram aliran aktual dan daftar writer.
- Register temuan terverifikasi.
- Dataset staging sintetis dan snapshot pemulihan.
- Daftar kontrak legacy yang wajib kompatibel.

## 6. Fase 1 — Containment P0

### 6.1 Kredensial pembayaran

1. Identifikasi provider/environment dan pemilik key tanpa mencetak key.
2. Verifikasi status aktif melalui console resmi.
3. Rotasi sesuai kapabilitas provider dan deploy kredensial pengganti melalui secret manager.
4. Jika provider mendukung overlap, verifikasi key baru lalu revoke key lama. Jika tidak, jadwalkan cutover dan rekonsiliasi pembayaran selama jendela perubahan.
5. Redaksi dokumen tracked. Tambahkan pemindaian secret untuk perubahan baru dan history yang relevan.
6. Evaluasi history rewrite dengan Owner; jangan force-push otomatis. Rotasi adalah kontrol utama, history cleanup bukan penggantinya.
7. Uji checkout sandbox, status lookup, webhook valid/invalid, dan kegagalan kredensial.

### 6.2 Patch revoke

Helper database tidak cukup hanya `return`. Gunakan hasil terstruktur:

```text
AccessDecision {
  action: KEEP | GRANT | REVOKE | DEFER,
  notebookId,
  reasons[],
  policyVersion,
  evidenceVersion
}
```

- `KEEP`: VIP atau ada grant efektif.
- `GRANT`: ada hak sah tetapi membership belum ada.
- `REVOKE`: bukti lengkap menunjukkan tidak ada hak aktif untuk notebook tersebut.
- `DEFER`: data/observasi tidak lengkap, error API, atau konflik writer.

Sebelum revoke, evaluasi ulang state terbaru untuk menutup race dengan renewal. Catat keputusan dan hasil read-back. Jangan menyimpulkan revoke dari status satu transaksi saja.

### 6.3 Resolver VIP

Bangun satu kontrak resolver lintas TypeScript/Python menggunakan fixture bersama. Resolver menggabungkan whitelist resmi, profil VIP, dan grant/dokumen VIP permanen. Nama koleksi dan schema aktual diverifikasi terlebih dahulu.

Kegagalan membaca sumber VIP menyebabkan pencabutan ditunda. Cache tidak boleh menjadi alasan mencabut ketika sumber resmi tidak tersedia. Perubahan VIP hanya melalui jalur Owner/admin yang sah dan diaudit.

## 7. Arsitektur target

```text
Provider pembayaran
  -> Ingest terautentikasi + validasi payload
  -> Inbox event durable
  -> Normalisasi transaksi canonical
  -> Ledger grant atomik
  -> Evaluator akses per-modul/per-notebook
  -> Desired membership + outbox
  -> Writer sharing tunggal
  -> Observasi/read-back NotebookLM
  -> Rekonsiliasi dan metrik

Flutter <- profil/materialized access view <- evaluator
```

### 7.1 Batas tanggung jawab

- Endpoint ingest menerima dan menyimpan event; tidak melakukan sharing lambat di request utama.
- Ledger adalah sumber bukti transaksi/grant, bukan profil expiry tunggal.
- Profil pengguna adalah view untuk UI dan kompatibilitas, bukan satu-satunya otoritas akses.
- Evaluator adalah fungsi deterministik terhadap input dan waktu yang diinjeksi.
- Worker sharing mengeksekusi desired state; tidak mengarang hak akses.
- Reaper adalah rekonsiliator dengan evaluator yang sama, bukan policy engine kedua.

Gunakan `AccessControl`/outbox yang sudah ada bila memenuhi kontrak. Lakukan gap analysis sebelum menambah koleksi atau mengganti framework; hindari dua sistem baru yang hidup bersamaan tanpa ownership jelas.

## 8. Desain data

Schema berikut adalah usulan; adaptasi nama setelah memeriksa koleksi existing.

### 8.1 Event inbox

```text
payment_events/{provider_event_key}
  provider, environment, provider_event_id
  provider_transaction_id, payload_digest
  received_at, provider_occurred_at
  verification_status, processing_status
  attempts, next_attempt_at, last_error_code
  schema_version
```

Gunakan key bernamespace provider/environment. Jangan memakai transaction ID saja untuk deduplikasi semua jenis event: satu transaksi dapat memiliki payment, refund, dan cancellation berbeda.

Jika provider tidak memberi event ID, fingerprint dibuat dari field canonical terverifikasi. Fingerprint tidak boleh bergantung pada waktu penerimaan. Event tanpa identitas transaksi stabil dikarantina; jangan membuat transaksi auto-grant baru pada setiap retry.

Payload mentah, bila diperlukan untuk investigasi, dibatasi ukuran, akses, dan retensinya; token webhook dihapus sebelum penyimpanan.

### 8.2 Transaksi canonical

```text
payment_transactions/{provider_environment_transaction_key}
  provider_transaction_id, user_id/customer_email_verified
  product_id, entitlement_keys[], amount_minor, currency
  paid_at, provider_status, normalized_status
  expected_amount_minor, verification_evidence
  last_provider_event_at, schema_version
```

Nominal menggunakan integer satuan terkecil yang sesuai mata uang/provider, bukan floating point. Bedakan identitas payer dari identitas pengguna aplikasi; email cocok harus terverifikasi sebelum binding akses.

### 8.3 Grant

```text
access_grants/{deterministic_grant_key}
  subject_uid/verified_email, entitlement_key
  source_type: PAYMENT | REDEEM | VIP | ADMIN
  source_id, starts_at, ends_at
  state: ACTIVE | REVOKED | QUARANTINED
  duration_days, renewal_policy_version
  approved_by, approval_reason
  created_at, policy_version
```

Keunikan grant berasal dari sumber transaksi + modul + jenis grant. VIP permanen tidak dibuat seolah-olah transaksi berbayar. Grant gratis membutuhkan bukti approval admin.

### 8.4 Membership dan outbox

```text
desired_memberships/{subject_notebook_key}
  desired: PRESENT | ABSENT
  evidence_version, writer_epoch, evaluated_at, reason_codes[]

provisioning_outbox/{job_key}
  subject, notebook_id, desired_state
  evidence_version, writer_epoch
  status, attempt_count, next_attempt_at
  lease_owner, lease_expires_at
  last_error_code, completed_at
```

Jangan menyimpan cookie NotebookLM atau credential provider di dokumen yang dapat dibaca klien.

## 9. Kontrak pembayaran dan idempotensi

### 9.1 Urutan ingest

1. Batasi method, tipe konten, ukuran body, dan schema.
2. Verifikasi autentikasi/signature sesuai dokumentasi provider; gunakan raw body bila algoritma memerlukannya.
3. Validasi timestamp/replay window hanya bila provider mendukung timestamp yang terautentikasi. Event sah yang terlambat tetap bisa diproses lewat rekonsiliasi.
4. Verifikasi transaksi ke API provider bila tersedia dan diperlukan untuk mengikat status/nominal/produk. Timeout menghasilkan pending verification, bukan grant.
5. Simpan inbox secara durable dengan key unik.
6. Balas sukses hanya setelah penerimaan durable; respons retryable untuk kegagalan sebelum durable commit.

Token statis GoAkal bukan signature per-payload. Pertahankan verifikasi token yang benar, lindungi secret, dan gunakan lookup provider bila tersedia; jangan mengklaim payload bertanda tangan jika tidak demikian.

### 9.2 Worker atomik

Dalam satu transaksi Firestore:

- Baca event dan transaksi/grant existing.
- Validasi transition status berdasarkan state provider yang sudah terverifikasi.
- Buat/perbarui grant secara deterministik.
- Perbarui materialized access view dan desired membership jika cocok dengan scope transaksi.
- Buat outbox job yang unik.
- Tandai event sudah diterapkan.

Operasi jaringan tidak dilakukan di callback transaksi Firestore karena callback dapat dijalankan ulang.

### 9.3 Transaksi nol dan input abnormal

Tolak auto-grant untuk `0`, negatif, non-finite, nominal hilang, mata uang salah, atau harga di luar kontrak. Untuk diskon/voucher provider yang sah, gunakan expected amount berdasarkan order resmi; jangan mengharuskan list price jika memang ada diskon sah.

Transaksi gratis masuk `QUARANTINED` sampai admin menyetujui grant eksplisit. VIP existing tetap terlindungi terlepas dari transaksi nol.

### 9.4 Renewal

Tetapkan kontrak sebelum implementasi:

- **Coverage fixed:** masa aktif berasal dari interval yang diberikan provider.
- **Extension:** masa aktif dihitung `max(expiry modul sebelumnya, paid_at) + duration_days` sekali per transaksi.

Jangan mencampur keduanya. Untuk extension, replay tidak menghitung ulang dari profil terbaru. Hasil interval disimpan per grant; transaksi baru dan event terlambat diproses dengan urutan serta policy deterministik. Rekonstruksi historical renewal harus identik dengan pemrosesan online.

Refund/cancellation memengaruhi grant sumber terkait, bukan seluruh akun. Event `FAILED` dari order lain tidak membatalkan grant berbayar aktif.

## 10. Evaluator akses

### 10.1 Algoritma konseptual

```text
evaluate(subject, notebook, now, evidence):
  jika bukti VIP resmi ada -> KEEP/GRANT
  jika bukti wajib tidak lengkap -> DEFER
  scopes = catalog.scopesForNotebook(notebook)
  grants = semua grant sah milik subject yang mencakup scopes
  jika ada starts_at <= now < ends_at atau grant permanen -> KEEP/GRANT
  jika catalog ambigu atau snapshot stale -> DEFER
  selainnya -> kandidat REVOKE
```

Gunakan UTC, batas interval half-open, dan clock yang dapat diinjeksi untuk test. Jangan menggunakan waktu perangkat sebagai otoritas server.

### 10.2 Modul dan notebook tidak identik

Satu modul dapat memiliki banyak notebook; satu notebook dapat dipakai lebih dari satu modul. Revoke hanya boleh terjadi setelah tidak ada grant lain yang memberi akses notebook yang sama. Bundle `all_access` diinterpretasikan lewat katalog versi yang jelas.

### 10.3 Keputusan pencabutan

Kandidat revoke membutuhkan bukti lengkap, data terkini, writer ownership valid, dan re-evaluation sebelum eksekusi. Batas anomali operasional menghentikan batch pencabutan jika terjadi lonjakan di luar baseline; ambang ditentukan dari baseline, bukan angka arbitrer.

Keputusan dan eksekusi memiliki audit record berbeda. Jangan melaporkan berhasil sebelum external operation/read-back terkonfirmasi.

## 11. Katalog produk dan notebook

- Buat katalog canonical berdasarkan provider product/service ID, bukan substring nama.
- Simpan modul, notebook aktif/legacy, replica, status, pemilik, dan versi.
- Nama produk hanya label dan alias migrasi yang eksplisit.
- Produk tidak dikenal dikarantina; tidak ada fallback Tahawwulat.
- Notebook Syafi'i master aktif wajib tercantum dan dipantau.
- Verifikasi mengapa beberapa mazhab menunjuk notebook yang sama; bila memang disengaja, katalog harus menyatakan shared scope.
- Uji kesesuaian katalog backend, Python, Flutter, dan URL yang dibuka aplikasi.
- Perubahan katalog menjalankan impact preview: subject mana yang akan bertambah/berkurang membership-nya.

## 12. Writer sharing dan ketahanan operasi

### 12.1 Satu writer aktif

Gunakan runtime ownership/version yang sudah ada bila sesuai. Tambahkan fencing epoch: job dari writer lama tidak boleh dieksekusi setelah cutover. Lease saja tidak cukup jika proses lama terus berjalan setelah lease kedaluwarsa.

Semua jalur legacy, manual sync, reaper, webhook, dan admin tool harus melewati ownership guard yang sama. Skrip ad hoc yang tidak kompatibel dinonaktifkan dari scheduler dan ditandai jelas.

### 12.2 Delivery semantics

Target realistis: **at-least-once delivery dengan efek idempoten**, bukan klaim exactly-once pada API eksternal.

- Add existing viewer dianggap desired state tercapai setelah verifikasi.
- Remove viewer yang sudah tidak ada dianggap tercapai setelah verifikasi.
- Timeout sesudah operasi mungkin berarti hasil tidak diketahui; lakukan read-back sebelum mengulang.
- Retry exponential backoff dengan jitter dan batas attempt.
- Error permanen masuk dead-letter dengan reason code dan prosedur replay.
- Worker memeriksa evidence version terbaru sebelum menjalankan job stale.
- Reconciliation berkala membandingkan desired dengan observed state.

### 12.3 Server webhook Python

Ganti `HTTPServer` sebagai runtime produksi dengan server yang memiliki request timeout, concurrency bounded, body limit, dan graceful shutdown. Pilihan framework mengikuti deployment existing; jangan mengganti hanya demi preferensi.

Endpoint cukup memvalidasi dan enqueue. Sharing NotebookLM yang lambat tidak memblokir penerimaan webhook lain. Terapkan timeout body/header, batas payload, dan response schema yang tidak membocorkan exception internal.

## 13. Migrasi data tanpa kehilangan hak

### 13.1 Tahap migrasi

1. Snapshot dan baseline.
2. Backfill ledger dari transaksi riil dengan script read-only preview terlebih dahulu.
3. Beri label provenance: `VERIFIED`, `LEGACY_UNVERIFIED`, `QUARANTINED`.
4. Jangan mengonversi profil expiry saja menjadi bukti transaksi berbayar.
5. Preservasi semua sumber VIP resmi sebagai grant permanen.
6. Bind user melalui UID/email terverifikasi; konflik email masuk review, bukan digabung otomatis.
7. Shadow evaluator menghasilkan diff terhadap keputusan existing tanpa mengubah membership.
8. Investigasi seluruh diff yang berpotensi mengurangi hak sah.
9. Aktifkan writer baru pada scope canary yang diketahui; hentikan writer lama pada scope yang sama.
10. Rekonsiliasi dan perluas setelah gerbang berhasil.

### 13.2 Backfill idempoten

Script memiliki `migration_version`, deterministic IDs, cursor checkpoint, batch bounded, dan laporan sebelum/sesudah. Menjalankan ulang tidak menambah durasi atau duplikasi grant.

Jangan menghapus field legacy pada cutover awal. Pertahankan compatibility view untuk versi aplikasi lama sampai observasi penggunaan membuktikan aman untuk deprecation.

### 13.3 Data ambigu

Pisahkan keputusan bisnis dari pemulihan teknis. Data ambigu tidak digunakan untuk mass revoke. Eskalasi kepada admin/Owner dengan sumber bukti yang tersedia, tanpa mempertanyakan hak VIP resmi.

## 14. Keamanan aplikasi dan backend

### 14.1 Firestore

Rules existing sudah mengunci entitlement/plan dari klien; pertahankan itu. Tambahkan emulator tests untuk create/update profil, transaksi lintas UID, collections server-only, serta bentuk payload abnormal.

Audit batas ukuran/nesting telemetry, bookmarks, conversations, dan messages. Pembatasan ukuran tidak menggantikan rate limit atau budget alert. Periksa penggunaan identitas dan retensi PII; jangan menambahkan field sensitif ke collections publik.

### 14.2 Endpoint dan izin

Inventory seluruh callable/onRequest: auth, email verification, ownership, rate limit, schema, timeout, dan response error. Evaluasi App Check sesuai klien yang didukung; jangan mengaktifkan enforcement mendadak yang memutus desktop/legacy.

Gunakan service account least privilege setelah memetakan izin aktual. Pemisahan ingest, evaluator, dan sharing mengurangi jangkauan credential. Semua secret berasal dari secret manager/environment aman, tidak dari kode/dokumen/log.

### 14.3 Dependency dan CI

Tetapkan Node/Flutter version yang reproducible. Jalankan audit dependency lalu triage exploitability aktual; jumlah versi baru bukan bukti kerentanan. Upgrade bertahap dengan regression test, terutama WebView, Firebase, dan Google Sign-In.

## 15. Updater aplikasi

### 15.1 Kontrak manifest

Untuk rilis Android baru: version/build, HTTPS URL host yang disetujui, SHA-256 64 hex, ukuran expected, dan release notes. Missing/invalid hash ditolak sebagai manifest invalid, bukan silently downgraded ke tanpa verifikasi.

Evaluasi kompatibilitas manifest lama sebelum enforcement. Redirect harus tetap HTTPS dan berada dalam kebijakan host; jangan hanya memvalidasi URL awal.

### 15.2 Downloader

- Connection timeout, idle timeout, dan total timeout.
- Maksimum byte ditetapkan dari ukuran APK aktual plus margin terdokumentasi.
- Validasi ukuran sebelum download jika header ada dan selama streaming jika tidak ada.
- Hash streaming, file `.tmp`, rename atomik setelah validasi.
- Bersihkan file parsial pada gagal/batal serta orphan temp saat startup.
- Progress dibatasi frekuensi notifikasi agar UI tidak redraw per chunk.
- Status gagal mempunyai reason code, retry, dan tidak mengunci mutex.
- Android package signature tetap kontrol instalasi; SHA-256 memastikan artefak cocok manifest, bukan pengganti signature.

### 15.3 UX update

Tampilkan ukuran download, status, retry, dan instruksi izin instalasi ketika diperlukan. Hormati kebijakan penggunaan data yang disepakati produk. Desktop link update diberi versi/platform yang jelas.

Verifikasi checksum artefak final setelah penyalinan, timestamp APK baru, dan keberhasilan Gradle penuh. Upload/broadcast tetap tindakan terpisah dengan instruksi pengguna eksplisit.

## 16. UI/UX dan aksesibilitas

### 16.1 Redeem

- Layout scrollable dengan tinggi bounded, SafeArea, dan penyesuaian keyboard.
- Judul memakai Flexible/Expanded; teks error dapat wrap.
- Tombol tidak submit ganda; loading memiliki jalur timeout/retry.
- Error memakai kode terstruktur terlokalisasi ID/EN/AR; jangan mencocokkan kalimat provider.
- Tooltip tombol tutup, semantics, urutan fokus, Enter untuk submit, Escape sesuai platform.
- Hasil aktivasi menampilkan modul, durasi, dan expiry yang berasal dari server.

### 16.2 Pembayaran

Pisahkan `payment pending`, `payment verified`, `access provisioning`, dan `access ready`. Pembayaran sukses tidak selalu berarti sharing langsung siap.

Jika checkout ditutup, simpan order pending dan sediakan pemulihan status. Setelah restart/login ulang, pengguna dapat melihat status transaksi dan mencoba refresh tanpa membuat order baru. Jangan memberi success dialog dari redirect saja; konfirmasi server wajib.

### 16.3 Audit seluruh screen

Matriks: login, dashboard, catalog/detail, subscription, profile, bookmarks/notes, checkout, redeem, chat/WebView, update.

Untuk setiap screen: loading/empty/error/offline, back navigation, text scaling, focus keyboard, screen reader, RTL, dark mode, dan viewport kecil/besar. Ukur contrast dan target sentuh aktual; jangan menyatakan semuanya gagal tanpa pengukuran.

Gunakan directional padding/alignment saat relevan. Mixed Arabic/Latin memerlukan arah teks per konteks, bukan RTL global yang membalik URL/kode. Hormati reduced motion tanpa mengubah polling readiness WebView.

## 17. Rencana pengujian

### 17.1 Test runner

Tetapkan script test backend resmi dengan compiler/runner TypeScript yang mendukung sintaks proyek. Path fixture berdasarkan lokasi file test, bukan working directory. Command harus berhasil dari fresh checkout dan CI.

Pisahkan unit, emulator, contract, integration sandbox, dan UI tests. Test yang membaca source string bukan pengganti pengujian perilaku.

### 17.2 Matriks regression wajib

| Skenario | Hasil yang diwajibkan |
|---|---|
| Retry event identik 10 kali | Satu grant; expiry tidak berubah |
| Dua worker memproses event bersamaan | Satu efek; tidak double extension |
| Renewal lalu expired transaksi lama | Hak renewal tetap aktif |
| Transaksi baru lalu replay transaksi lama | Expiry tidak mundur |
| PAID tanpa paidAt/ID stabil | Quarantine/verification; tidak grant berdasarkan now |
| Nol/negatif/NaN/currency salah | Tidak auto-grant |
| Produk tidak dikenal | Tidak fallback modul |
| Grant gratis disetujui admin | Akses sesuai approval, bukan nominal palsu |
| VIP whitelist/profil/role/permanent | Tidak pernah dicabut |
| Baca sumber VIP gagal | Revoke ditunda |
| Modul A expired, modul B aktif | B tetap aktif |
| Dua modul berbagi notebook | Notebook dipertahankan selama salah satu aktif |
| Batas expiry tepat | Aktif sebelum batas; expired pada batas |
| Gagal setelah transaksi ditulis | Retry melengkapi entitlement/outbox |
| Timeout sharing setelah side effect | Read-back menentukan langkah berikutnya |
| Writer lama aktif setelah cutover | Fencing menolak operasi |
| API transaksi tidak tersedia | Tidak mass revoke |
| Refund transaksi tertentu | Hanya grant sumber terkait dievaluasi ulang |
| APK hash salah/ukuran besar/stream macet | Gagal bounded, temp bersih, retry tersedia |
| Redeem layar kecil + keyboard + teks besar | Tidak overflow; aksi dapat dijangkau |

Tambahkan randomized event ordering untuk transaksi yang sama, property test bahwa VIP tidak menghasilkan REVOKE, serta fault injection di setiap batas commit/network. Jangan menjalankan destructive test pada notebook produksi.

### 17.3 Verifikasi WebView

Regression harus membuktikan readiness minimum dan error viewport tetap sesuai standar. Uji account switching, tab switching, resume, retry, network loss, dan Google session expiry pada platform yang didukung. Paket perubahan UI tidak boleh diam-diam mengubah lifecycle WebView.

## 18. Observabilitas dan runbook

### 18.1 Metrik

- Event accepted/rejected/quarantined dan alasan.
- Duplicate event rate dan processing latency.
- Age/size inbox, outbox, dead-letter.
- Desired/observed membership drift.
- Provisioning success/timeout/retry.
- Revoke count per scope dan VIP revoke attempted.
- Payment verified tetapi akses belum ready.
- Download update failure per reason.

Log berisi correlation ID, transaction key, job ID, policy version, dan reason code. Hindari secret/raw token dan PII berlebihan. Jangan memakai email sebagai label metrik ber-cardinality tinggi.

### 18.2 Runbook inti

**Pembayaran sukses, akses belum ada:** cek inbox -> transaksi -> grant -> desired -> outbox -> read-back. Replay hanya langkah belum selesai; jangan memperpanjang ulang.

**Pencabutan keliru:** hentikan scope writer, verifikasi VIP/grant, restore desired membership, eksekusi add idempoten, lalu identifikasi policy version penyebab.

**Provider/API down:** pertahankan keputusan yang memiliki bukti sah, defer operasi yang memerlukan bukti baru, retry bounded, informasikan status pending ke UI.

**Credential bocor:** revoke/rotasi, deploy, rekonsiliasi transaksi selama cutover, dan investigasi log tanpa menyalin credential.

## 19. Rollout dan rollback

### 19.1 Gerbang rollout

1. Unit/emulator/regression lulus dan fresh checkout reproducible.
2. Shadow diff dipahami; tidak ada pengurangan hak sah yang belum dijelaskan.
3. Snapshot restore sudah diuji di staging.
4. Writer ownership/fencing bekerja.
5. Canary provisioning dan retry berhasil.
6. Revoke canary hanya memakai subjek uji non-VIP dengan bukti lengkap.
7. Monitoring, alert, serta operator tersedia selama cutover.

### 19.2 Rollback

Hentikan worker baru dan ubah ownership secara terkontrol. Jangan mengaktifkan kembali writer legacy yang diketahui memiliki bug revoke. Pilihan aman sementara adalah pause mutasi sharing sambil mempertahankan akses sah dan menyelesaikan repair.

Rollback kode tidak membatalkan efek eksternal NotebookLM. Gunakan snapshot desired/observed dan ledger keputusan untuk compensating add/remove yang dievaluasi ulang. Jangan restore database secara buta karena transaksi baru dapat terjadi setelah snapshot.

Feature flags minimum: ingest version, evaluator shadow/live, writer ownership/epoch, scope canary, revoke enabled per scope. Flags server-only dan diaudit.

## 20. Paket implementasi dan dependensi

| Paket | Isi | Dependensi | Bukti selesai |
|---|---|---|---|
| WP-00 | Inventory, baseline, snapshot | Tidak ada | Diagram runtime dan restore staging |
| WP-01 | Secret containment | WP-00 minimum | Key lama revoked dan smoke test |
| WP-02 | VIP/revoke patch + regression | WP-00, runner dasar | Event lama/VIP/per-module tests |
| WP-03 | Test runner/CI | WP-00 | Fresh checkout lulus |
| WP-04 | Katalog canonical | WP-00 | Mapping dan impact preview |
| WP-05 | Inbox/ledger/payment contracts | WP-03, WP-04 | Idempotency/concurrency/fault tests |
| WP-06 | Evaluator dan compatibility view | WP-02, WP-05 | Shadow diff tervalidasi |
| WP-07 | Outbox/fencing/reconciliation | WP-06 | Timeout/retry/stale job tests |
| WP-08 | Backfill/canary/cutover | WP-07 | Migrasi rerunnable tanpa kehilangan hak |
| WP-09 | Updater hardening | WP-03 | Download failure matrix |
| WP-10 | UI/UX/accessibility | WP-03, kontrak status WP-06 | Viewport/locale/platform matrix |
| WP-11 | Full follow-up audit | Semua paket relevan | Register residual risk dan closure |

Setiap paket memiliki PIC engineering, reviewer, operator deployment, dan approver bisnis bila kontrak produk berubah. Satu orang dapat memegang beberapa peran, tetapi artefak review tetap tercatat.

## 21. Definition of Done

- Tidak ada nilai secret nyata dalam perubahan baru; secret terpapar yang aktif sudah dirotasi.
- Seluruh sumber VIP resmi dilindungi pada setiap jalur revoke.
- Evaluasi akses independen per-modul dan agregat per-notebook.
- Satu transaksi menghasilkan interval grant yang stabil dan dapat dijelaskan.
- Event duplikat, out-of-order, dan concurrent tidak menambah/mengurangi hak secara keliru.
- Partial failure dapat pulih otomatis melalui durable state/outbox.
- Satu writer aktif dengan fencing; reaper menggunakan evaluator yang sama.
- Katalog master/legacy/replica selaras dengan aplikasi.
- Nominal nol/produk tidak dikenal dikarantina sesuai aturan.
- Updater bounded dan memverifikasi hash; rilis lokal tidak otomatis broadcast.
- UI penting lulus viewport, keyboard, locale, accessibility, dan status pembayaran.
- WebView lifecycle dan readiness invariants tetap utuh.
- Monitoring dan rollback operasional diuji.
- Dokumen deployment, schema, policy, dan runbook mengikuti implementasi aktual.

## 22. Langkah pertama yang disarankan

Mulai dari **WP-00, WP-01, WP-02, dan WP-03**. Ini menghasilkan containment yang cepat sekaligus fondasi verifikasi. Jangan memulai migrasi besar sebelum mengetahui writer produksi dan memiliki regression test yang dapat dipercaya.

Keputusan bisnis yang perlu disahkan sebelum WP-05: kontrak renewal tiap produk, kebijakan refund, durasi selain satu bulan, binding identitas payer, dan approval grant gratis. Keputusan ini tidak boleh diturunkan dari substring nama produk atau asumsi developer.
