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
