# Checkpoint dan restore

Repository: `/Users/apple/Downloads/ramadhan`.

- Branch: `codex/audit-reliability-2026-09-29`
- Baseline: `c80cd2c0d622b6473984bc1962815c05dbe3d425`
- Tag baseline: `codex/audit-base-2026-09-29`
- Tag hasil akhir: `codex/audit-complete-2026-09-29`

Semua perubahan audit di-checkpoint. File untracked yang sudah ada bukan bagian dari snapshot Git audit. Ada commit pekerjaan lain `e36680a` di branch bersama; petunjuk di bawah menjaga agar rollback audit tidak otomatis membatalkan pemetaan NotebookLM pekerjaan itu.

## Membuka baseline untuk membandingkan

Command ini membuat checkout terpisah di `/private/tmp` dan tidak mengubah checkout aktif. Jalankan hanya jika path tujuan belum dipakai:

```sh
git -C /Users/apple/Downloads/ramadhan worktree add --detach /private/tmp/openturath-audit-base codex/audit-base-2026-09-29
```

Untuk snapshot akhir, gunakan tag `codex/audit-complete-2026-09-29` dengan path tujuan berbeda.

## Mengembalikan hanya source aplikasi yang diperbaiki audit

Sebelum menjalankan restore, simpan perubahan baru setelah audit dalam checkpoint sendiri. Command berikut menimpa **empat file yang disebutkan** pada checkout aktif; periksa diff, lalu commit hasil rollback. Command ini hanya didokumentasikan, tidak dijalankan selama audit.

```sh
cd /Users/apple/Downloads/ramadhan
git restore --source=codex/audit-base-2026-09-29 -- \
  openturath_ai/lib/widgets/note_editor_sheet.dart \
  openturath_ai/lib/services/bookmark_service.dart \
  openturath_ai/lib/screens/book_catalog_screen.dart \
  openturath_ai/lib/screens/book_library_editorial_screen.dart
git diff --stat
```

Empat tes baru menguji perilaku hasil perbaikan; setelah rollback tes itu kemungkinan gagal atau tidak kompatibel dengan seam testing baseline. Jika rollback akan dipertahankan, sesuaikan keberadaan tes audit di checkpoint rollback. `tool/audit_preview.dart` dan dokumentasi dapat disimpan sebagai artefak inspeksi terpisah.

Tidak perlu `reset --hard` atau menghapus file untracked untuk membandingkan maupun mengembalikan source audit. Untuk kembali ke implementasi final, gunakan command restore yang sama dengan tag `codex/audit-complete-2026-09-29` setelah menyimpan perubahan baru.
