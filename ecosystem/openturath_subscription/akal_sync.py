"""
OpenTurath Sync Engine — Full Sync via Akal REST API
======================================================
Script ini melakukan sinkronisasi PENUH antara data transaksi Akal
dengan akses viewer di NotebookLM.

Gunakan ini untuk:
1. Sync awal pertama kali (semua pelanggan aktif langsung dapat akses)
2. Sync periodik sebagai backup jika webhook sempat gagal
3. Cek apakah state NotebookLM sudah sesuai dengan Akal

Cara pakai:
  # Jalankan full sync untuk semua produk
  python akal_sync.py

  # Dry run (lihat apa yang akan berubah tanpa benar-benar mengubah)
  python akal_sync.py --dry-run

  # Sync satu produk saja
  python akal_sync.py --service-cuid clxxx

  # Hanya tambah yang kurang (jangan hapus)
  python akal_sync.py --add-only
"""

import os
import sys

# Load .env file manually
def load_dotenv():
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, val = line.split("=", 1)
                    # Strip quotes if present
                    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                        val = val[1:-1]
                    os.environ[key] = val

load_dotenv()

import asyncio
import argparse
import logging

# Tambahkan notebooklm-py ke path
NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

from akal_client import AkalClient
import notebooklm_manager as nlm

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("sync.log"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────────────────────
# MAPPING: Akal service_cuid → NotebookLM notebook_id
# Isi sesuai dengan kelas Anda di Akal dan notebook di NotebookLM
# ─────────────────────────────────────────────────────────────
SERVICE_MAPPING: list[dict] = [
    {
        "name": "AI Fikih Tahawwulat",
        "akal_cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", ""),
        "notebook_ids": [
            os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUHAQQIQ", "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"),
            os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_BAYAN", "483d0291-0a70-411c-bff0-f1ea4b83b2fd"),
            os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUKHTABIR", "ac61a7a0-87e7-42a5-a30f-980ff74a78d8"),
            os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_HABIB", "6673e79a-7156-42e1-b116-bc1653a32094"),
            os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_KHATIB", "1288e413-9569-47a3-892f-64008e53c1e8"),
        ],
    },
    {
        "name": "AI Hadits",
        "akal_cuid": os.getenv("AKAL_SERVICE_CUID_HADITS", ""),
        "notebook_ids": [os.getenv("NOTEBOOK_ID_HADITS", "")],
    },
    {
        "name": "AI Tafsir",
        "akal_cuid": os.getenv("AKAL_SERVICE_CUID_TAFSIR", ""),
        "notebook_ids": [os.getenv("NOTEBOOK_ID_TAFSIR", "")],
    },
    {
        "name": "AI Bahasa Arab",
        "akal_cuid": os.getenv("AKAL_SERVICE_CUID_BAHASA_ARAB", ""),
        "notebook_ids": [os.getenv("NOTEBOOK_ID_BAHASA_ARAB", "15bc4cef-4b94-4241-b05a-d50a586bde06")],
    },
    # Tambah produk baru di sini
]


async def sync_one_service(
    akal: AkalClient,
    service: dict,
    dry_run: bool = False,
    add_only: bool = False,
) -> dict:
    """
    Sinkronisasi satu service: bandingkan Akal vs NotebookLM,
    lalu tambah/hapus viewer sesuai kebutuhan.

    Returns:
        Summary dict dengan jumlah added, removed, skipped, errors.
    """
    name = service["name"]
    akal_cuid = service["akal_cuid"]
    notebook_ids = service.get("notebook_ids", [])
    notebook_ids = [nid for nid in notebook_ids if nid]

    if not akal_cuid or not notebook_ids:
        logger.warning("⚠️  %s: akal_cuid atau notebook_ids belum dikonfigurasi, skip.", name)
        return {"name": name, "skipped": True}

    logger.info("🔄 Sync: %s (%d notebooks)", name, len(notebook_ids))

    # 1. Ambil email yang harus PUNYA AKSES dari Akal (PAID + SETTLED) yang belum expired
    paid_emails = await akal.get_all_paid_emails(akal_cuid)
    logger.info("   📊 Akal: %d email aktif (PAID/SETTLED)", len(paid_emails))

    # Dapatkan semua transaksi di Akal untuk mengidentifikasi email yang terdaftar di Akal
    # (baik yang masih aktif maupun yang sudah kedaluwarsa)
    all_txns = await akal.get_transactions(akal_cuid, page_size=100)
    all_akal_emails = {t["payerEmail"].strip().lower() for t in all_txns if t.get("payerEmail")}
    expired_akal_emails = all_akal_emails - paid_emails

    # 2. Ambil gabungan email yang sudah ada di semua NotebookLM saat ini
    current_emails = set()
    for notebook_id in notebook_ids:
        try:
            current_viewers = await nlm.list_viewers(notebook_id)
            emails = {v["email"].strip().lower() for v in current_viewers
                      if v["permission"] != "OWNER"}
            current_emails.update(emails)
        except Exception as e:
            logger.error("   ❌ Gagal mengambil viewer untuk notebook %s: %s", notebook_id, e)

    logger.info("   📖 NotebookLM (Gabungan): %d viewer saat ini", len(current_emails))

    # 3. Hitung perbedaan dengan memisahkan user offline vs user Akal yang expired
    to_add = paid_emails - current_emails      # Harus punya akses tapi belum ada di manapun
    # Hanya hapus jika user tersebut terdaftar di Akal tapi sudah expired (bukan user offline/manual)
    to_remove = current_emails & expired_akal_emails

    logger.info("   ➕ Akan ditambah : %d email", len(to_add))
    if not add_only:
        logger.info("   ➖ Akan dihapus : %d email", len(to_remove))
    else:
        logger.info("   ➖ Akan dihapus : %d email (diabaikan karena --add-only)", len(to_remove))
        to_remove = set()

    if dry_run:
        logger.info("   🔍 [DRY RUN] Tidak ada perubahan yang dilakukan.")
        if to_add:
            logger.info("   [DRY RUN] Akan ditambah: %s", ", ".join(sorted(to_add)))
        if to_remove:
            logger.info("   [DRY RUN] Akan dihapus: %s", ", ".join(sorted(to_remove)))
        return {
            "name": name,
            "dry_run": True,
            "would_add": len(to_add),
            "would_remove": len(to_remove),
        }

    # 4. Lakukan perubahan (Dikomentari karena NotebookLM menggunakan public link Chat Only)
    logger.info("   ℹ️  Direct email additions/removals are disabled (NotebookLM uses public link CHAT_ONLY access).")
    return {
        "name": name,
        "added": 0,
        "removed": 0,
        "errors": 0,
        "paid_emails": len(paid_emails),
        "viewers_before": len(current_emails),
    }


async def run_full_sync(
    filter_cuid: str | None = None,
    dry_run: bool = False,
    allow_removal: bool = False,
):
    """Jalankan sync untuk semua (atau satu) service."""
    add_only = not allow_removal
    logger.info("=" * 60)
    logger.info("🚀 OpenTurath Full Sync dimulai")
    if dry_run:
        logger.info("   Mode: DRY RUN (tidak ada perubahan nyata)")
    if add_only:
        logger.info("   Mode: ADD ONLY (tidak ada penghapusan, aman untuk offline subscribers)")
    logger.info("=" * 60)

    results = []
    async with AkalClient() as akal:
        for service in SERVICE_MAPPING:
            # Filter satu service jika diminta
            if filter_cuid and service["akal_cuid"] != filter_cuid:
                continue

            try:
                result = await sync_one_service(akal, service, dry_run=dry_run, add_only=add_only)
                results.append(result)
            except Exception as e:
                logger.exception("❌ Error sync '%s': %s", service["name"], e)
                results.append({"name": service["name"], "error": str(e)})

    # Summary
    logger.info("")
    logger.info("=" * 60)
    logger.info("📊 SUMMARY SYNC")
    logger.info("=" * 60)
    total_added = total_removed = total_errors = 0
    for r in results:
        if r.get("skipped"):
            logger.info("  ⏭️  %s: DILEWATI (belum dikonfigurasi)", r["name"])
        elif r.get("dry_run"):
            logger.info("  🔍 %s: [DRY RUN] +%d -%d", r["name"], r.get("would_add", 0), r.get("would_remove", 0))
        elif r.get("error"):
            logger.info("  ❌ %s: ERROR — %s", r["name"], r.get("error"))
        else:
            added = r.get("added", 0)
            removed = r.get("removed", 0)
            errors = r.get("errors", 0)
            total_added += added
            total_removed += removed
            total_errors += errors
            logger.info("  ✅ %s: +%d ditambah, -%d dihapus, %d error", r["name"], added, removed, errors)

    if not dry_run:
        logger.info("")
        logger.info("  Total: +%d ditambah, -%d dihapus, %d error", total_added, total_removed, total_errors)
    logger.info("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description="OpenTurath Full Sync — Sinkronisasi Akal ↔ NotebookLM",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Tampilkan apa yang akan berubah tanpa benar-benar mengubah",
    )
    parser.add_argument(
        "--allow-removal",
        action="store_true",
        help="Izinkan menghapus viewer yang sudah tidak terdaftar di Akal (HATI-HATI: email offline/manual akan terhapus)",
    )
    parser.add_argument(
        "--service-cuid",
        help="Hanya sync satu service (berikan Akal service CUID)",
    )
    args = parser.parse_args()

    asyncio.run(run_full_sync(
        filter_cuid=args.service_cuid,
        dry_run=args.dry_run,
        allow_removal=args.allow_removal,
    ))


if __name__ == "__main__":
    main()
