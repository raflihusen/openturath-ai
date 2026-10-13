# Otomasi akses OpenTurath di VPS

Worker VPS (`access_worker.js`) adalah satu-satunya penulis sharing NotebookLM
setelah cutover. Ia membaca ledger `access_grants` di Firestore, memesan kursi
notebook, dan memanggil `verified_sharing.py` untuk setiap perubahan anggota.

## Isi folder

| Berkas | Peran |
|---|---|
| `verified_sharing.py` | Adapter sharing: satu operasi per panggilan, hasil selalu diverifikasi ulang |
| `shared/` | Registry VIP dan katalog produk — **dibangkitkan**, jangan diedit tangan |
| `shared_registry.py`, `access_policy.py` | Pembaca registry dan evaluator akses murni (dipakai server lama dan reaper) |
| `webhook_server.py`, `autonomous_reaper.py` | Penulis generasi lama (Cloud Run); otomatis diam setelah cutover |
| `deploy/` | Build rilis, pasang, rollback, dan kirim sesi |
| `ops_archive/` | Skrip lama; tidak ikut rilis, jangan dijalankan |

## Mengubah VIP atau produk

1. Ubah `VIP_EMAILS` (`openturath_ai/functions/src/access_control.ts`) atau
   katalog (`access_catalog.ts`). Daftar VIP hanya boleh bertambah.
2. `cd openturath_ai/functions && npm run export-shared && npm test`
3. Commit sumber, `lib/`, dan `shared/` bersama-sama. Tes drift menolak salinan yang tertinggal.

## Rilis

```bash
ecosystem/openturath_subscription/deploy/build_release.sh
```

Hasilnya `ecosystem/dist/openturath-access-<versi>.tar.gz` beserta `.sha256`.
Salin keduanya ke VPS lalu, di VPS:

```bash
tar -xzf openturath-access-<versi>.tar.gz openturath-access-<versi>/install_release.sh --strip-components=1
./install_release.sh openturath-access-<versi>.tar.gz
```

Pemasang memeriksa checksum, memasang di samping rilis lama, memindah symlink
`releases/current`, dan kembali sendiri ke rilis sebelumnya bila worker tidak
sehat. Rollback manual: `./rollback.sh` (daftar) atau `./rollback.sh <rilis>`.
Rollback hanya mengembalikan kode, bukan data Firestore atau keanggotaan notebook.

## Rahasia di VPS (`/home/ubuntu/openturath-access/secrets`, mode 700)

- `firestore-key.json` — service account dengan akses Firestore saja
- `storage_state.json` — sesi NotebookLM pemilik; kirim/segarkan dengan
  `deploy/push_session.sh ubuntu@<host>` dari komputer operator (VPS tidak punya browser)
- `worker.env` — opsional

## Urutan cutover

Semua langkah ini keputusan pemilik; tidak ada yang otomatis.

1. Worker berjalan dalam mode `shadow` (nilai `writer` di
   `access_control/runtime` belum `vps-v2`): ia hanya mengamati.
2. `node lib/access_worker.js --seed` lalu `--prepare` untuk mengimpor
   keanggotaan dan bukti lama. Akun dengan bukti belum lengkap otomatis
   ditahan (`access_revocation_hold`) dan muncul di `access_reviews`.
3. Tinjau `access_reviews`. Biarkan `revocations_paused: true`.
4. Set `writer: "vps-v2"`. Sejak saat ini Cloud Functions outbox, server
   Cloud Run, dan reaper berhenti menulis; event GoAkal diteruskan ke
   `access_legacy_events` dan diselesaikan worker.
5. Setelah beberapa hari stabil dan daftar calon pencabutan ditinjau, set
   `revocations_paused: false`.

## Pemantauan

- `curl -s http://127.0.0.1:8091/` di VPS — status worker
- `access_control/heartbeat` dan `monitor_health` di Firestore; fungsi
  `monitorAccessHealth` mengirim peringatan Telegram bila worker, sesi
  NotebookLM, atau rekonsiliasi pembayaran tertinggal
- `journalctl -u openturath-access -f`

## Reaper lama (hanya sebelum cutover)

Tanpa `REAPER_APPLY=1` reaper hanya melaporkan calon pencabutan (dry-run).
Ia batal total bila Firestore atau GoAkal tidak terbaca, tidak pernah
menyentuh VIP, dan berhenti bila calon melebihi `REAPER_MAX_REMOVALS` (20).
