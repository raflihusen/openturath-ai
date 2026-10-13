# Checkpoint implementasi remediasi — 13 Oktober 2026

## Perubahan lokal yang sudah dibuat

| Commit | Perubahan | Verifikasi |
|---|---|---|
| `0b37cbae` | Webhook Python mengantrekan event negatif dan pembayaran tanpa ID/nominal valid untuk verifikasi, alih-alih melakukan revoke/grant langsung | Review diff; integrasi runtime belum diuji |
| `433a445e` | Cloud Function GoAkal mengarantina nominal nol/non-finite/negatif dan transaksi tanpa ID | `npm run build` berhasil |
| `c5788c08` | Artefak JavaScript Functions diperbarui | Hasil compiler TypeScript |
| `fd109dae` | Redeem memakai scroll dan judul fleksibel | `flutter analyze --no-pub` lulus |
| `6c192311` | Unduhan update dibatasi 256 MiB dengan connection/header/idle timeout 30 detik | `flutter analyze --no-pub` lulus |

## Konsekuensi containment

Event negatif pada webhook Python kini disimpan dalam `access_legacy_events` dengan status `verification_required`. Ini menunda pencabutan legacy, bukan membuktikan event sudah diterapkan oleh evaluator. Operator harus memantau antrean tersebut; pastikan consumer aktif sebelum menganggap sinkronisasi end-to-end selesai. Pembayaran valid positif masih memakai jalur existing dan masalah replay/partial failure belum seluruhnya diperbaiki.

Batas download 256 MiB adalah batas containment sementara yang berada di atas artefak APK lokal sekitar 68 MB; revisi berdasarkan manifest ukuran dan pengukuran rilis. Total timeout, cleanup file sementara, dan kewajiban hash masih perlu implementasi.

## Pekerjaan yang belum selesai

- Inventory runtime/deployment dan validasi consumer antrean.
- Regression tests perilaku webhook dan fault injection.
- Evaluator VIP/grant menyeluruh pada semua writer, termasuk reaper.
- Atomic inbox/ledger/outbox, replay safety, dan recovery partial failure.
- Katalog canonical serta verifikasi master notebook produksi.
- Renewal canonical, purchase binding, writer drain/fencing, shadow dan cutover.
- Rotasi key di provider serta redaksi/history review.
- Updater total timeout, hash wajib dengan compatibility gate, dan pengujian jaringan.
- Localization/accessibility serta widget tests viewport/keyboard.

## Batas perubahan

Login kedua tetap wajib. Paket ini tidak mengubah implementasi autentikasi atau lifecycle/polling WebView. Tidak ada deployment, migrasi database, operasi NotebookLM, build APK, upload, atau broadcast rilis yang dilakukan.

## Rollback

Revert commit yang sesuai untuk rollback kode. Jangan menganggap revert Git menghapus event yang sudah tersimpan atau memulihkan membership eksternal. Commit source Functions dan artefak compiled perlu direvert bersama bila membatalkan perubahan billing.

---

# Lanjutan — remediasi audit menyeluruh (13 Oktober 2026, cabang `remediasi/audit-2026-10-13`)

Titik aman: tag `pra-remediasi-2026-10-13`. Setiap perubahan adalah commit terpisah di atas tag itu.
Tidak ada deployment, broadcast rilis, operasi NotebookLM, atau penulisan Firestore produksi.

## Verifikasi lokal

| Suite | Hasil |
|---|---|
| `flutter analyze --no-pub` | bersih |
| `flutter test --no-pub` | 382 lulus, 1 dilewati |
| `npm run check` + `npm test` (functions) | 143 lulus |
| `python3 -m unittest discover -s tests` (ecosystem) | 24 lulus |
| `deploy/build_release.sh` | tarball rilis VPS terbentuk |

## Yang berubah

- **Registry tunggal.** `VIP_EMAILS` (43 alamat, gabungan empat daftar lama) dan katalog produk GoAkal
  hidup di `functions/src`, diekspor ke `ecosystem/openturath_subscription/shared/`, dan dijaga tes drift.
- **Billing GoAkal.** Sync dan webhook memakai satu penulis ledger: nominal nol/ID kosong/produk tak
  dikenal dikarantina, hanya modul yang dibeli yang ditulis, replay tidak memperpanjang, perpanjangan
  dini menyambung dari akhir periode sebelumnya, "12 Bulan" dikenali sebagai tahunan.
- **Gerbang versi akses.** `access_version: 2` hanya disetel dan dipakai saat `writer == "vps-v2"`;
  modul lama tanpa grant membuat akun ditahan (`access_revocation_hold`), bukan kehilangan akses.
- **Reaper (Functions dan Python).** VIP dari semua sumber, evaluasi per-modul, gagal-tutup, dry-run bawaan,
  pencabutan terverifikasi satu per satu dengan batas per siklus.
- **Server sharing.** Katalog bersama, jalur perintah internal dari outbox, HTTP ber-thread dengan batas
  ukuran dan timeout, log tanpa email utuh.
- **Worker VPS.** Konsumen `access_legacy_events`; alat rilis/rollback/kirim-sesi di `deploy/`.
- **Aplikasi.** Hash update wajib dan diverifikasi ulang sebelum pasang; WebView hanya bisa diinspeksi di
  build debug; fallback sesi lintas-akun dihapus; satu ketukan tidak lagi menutup ruang kajian;
  teks legal menyebut Midtrans; 29 string UI/galat diterjemahkan EN/AR.
- **Aturan Firestore.** Nama profil dan field telemetri dibatasi; koleksi ledger ditutup eksplisit.
- **Pembersihan.** `kamus_fikih_tahawwulat/`, gerbang web mati (~1.000 baris), 4 dependensi Flutter,
  paket npm `crypto`, metode/konstanta tak terpakai; skrip sekali-pakai diarsipkan; laporan berisi
  email pelanggan dan 462 berkas hasil-generate keluar dari Git.

## Belum dikerjakan (butuh keputusan atau akses pemilik)

- Rotasi kunci server Midtrans dan `INTERNAL_SECRET`; nilainya masih ada di riwayat Git.
- Nilai `access_control/runtime.writer` dan `revocations_paused` di produksi.
- Deploy Functions, aturan Firestore, image Cloud Run, rilis VPS, dan APK.
- App Check (perlu pendaftaran penyedia atestasi di konsol Firebase).
- Audit visual per layar di emulator (perlu login Google di perangkat).
- 10 advisori npm tersisa menuntut upgrade mayor `firebase-admin`/`firebase-functions`.
- Jalur `master_token` di `notebooklm_manager.py` dibiarkan: server Cloud Run lama masih
  bergantung padanya sampai cutover.

## Membersihkan rahasia dari riwayat Git (jalankan hanya setelah rotasi)

```bash
pip install git-filter-repo
printf 'regex:Mid-server-[A-Za-z0-9_-]{10,}==>***REDACTED***\nregex:openturath_internal_sec_[A-Za-z0-9_]+==>***REDACTED***\n' > /tmp/redact.txt
git filter-repo --replace-text /tmp/redact.txt
git push --force --all && git push --force --tags
```

Perintah ini menulis ulang seluruh riwayat: semua klon lain harus di-clone ulang, dan salinan yang sudah
pernah diunduh pihak lain tidak ikut terhapus — karena itu rotasi tetap wajib.

## Rollback

`git switch codex/reading-cards-2026-10-08` mengembalikan kode ke keadaan sebelum remediasi;
`git revert <commit>` membatalkan satu perubahan. Commit sumber Functions dan `lib/` hasil kompilasi
harus direvert bersama.
