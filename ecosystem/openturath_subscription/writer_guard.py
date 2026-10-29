"""Penjaga penulis tunggal untuk skrip lama.

Sejak cutover (`access_control/runtime.writer == "vps-v2"`) hanya worker VPS yang
boleh mengubah daftar anggota notebook. Skrip lama yang tetap berjalan di laptop
atau server lain akan saling menimpa dengan worker, jadi penulisan ditolak.
Gagal membaca penanda berarti DITOLAK (fail closed).

Pengecualian darurat yang disengaja: OPENTURATH_LEGACY_WRITE_OVERRIDE=1.
"""

import os


class LegacyWriterBlocked(RuntimeError):
    pass


def _runtime_control() -> dict:
    from google.cloud import firestore
    snap = firestore.Client().collection("access_control").document("runtime").get()
    return snap.to_dict() or {}


def assert_legacy_writes_allowed(read_control=_runtime_control) -> None:
    if os.environ.get("OPENTURATH_LEGACY_WRITE_OVERRIDE") == "1":
        return
    try:
        control = read_control()
    except Exception as exc:  # fail closed
        raise LegacyWriterBlocked(f"Penanda penulis tidak terbaca ({type(exc).__name__}); penulisan ditolak.") from exc
    if control.get("writer") == "vps-v2":
        raise LegacyWriterBlocked(
            "Penulis aktif adalah worker VPS (vps-v2). Skrip lama ditolak agar tidak menimpa ledger.")
