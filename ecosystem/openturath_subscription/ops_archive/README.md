# Arsip operasi (jangan dijalankan)

Skrip di folder ini adalah perbaikan sekali-pakai, audit ad-hoc, dan penulis
sharing generasi lama. Semuanya disimpan sebagai catatan, **tidak ikut rilis
VPS maupun image Cloud Run**, dan tidak lagi dirawat.

Jangan menjalankannya terhadap produksi:

- beberapa menyimpan daftar VIP dan pemetaan notebook sendiri yang sudah
  berbeda dari registry bersama (`../shared/`);
- beberapa mencabut atau menambah viewer NotebookLM tanpa evaluator akses,
  sehingga dapat melanggar aturan VIP dan hak per-modul di `AGENTS.md`;
- `puppeteer_sharing_legacy/` adalah daemon berbasis browser yang digantikan
  oleh worker VPS (`access_worker`) dan `verified_sharing.py`.

Jika suatu pekerjaan di sini masih dibutuhkan, tulis ulang di atas
`access_policy.py` / `shared_registry.py` dan beri tes.
