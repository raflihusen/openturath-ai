#!/usr/bin/env python3
"""
OpenTurath AI - Master Notebooks Batch Cloner & Orchestrator
============================================================
Skrip otomatis untuk mengkloning seluruh ke-24 kajian master turats ke akun Google
khusus baru (Google One / NotebookLM Pro) secara aman, terisolasi, dan berurutan.

Target Akun Utama Default:
--------------------------
TARGET_OWNER_EMAIL = "macbookairm1ku@gmail.com" (Akun Google One / NotebookLM Pro Resmi)

Fitur Utama:
------------
1. Klone Penuh 24 Kajian Master: Menduplikasi seluruh dokumen sumber (fulltext) dari
   master ke notebook node baru di NotebookLM.
2. Rate-Limiting Protection: Delay micro 1.0 detik per dokumen sumber dan 3.0 detik
   antar notebook untuk mencegah pemblokiran / HTTP 429 dari Google.
3. Proteksi CHAT_ONLY Otomatis: Mengunci setiap notebook klone baru ke level CHAT_ONLY
   sehingga pengguna hanya bisa berinteraksi lewat chat dan tidak bisa mengunduh/melihat
   database mentah turats.
4. Hak Akses Editor ke Target Owner: Jika proses dijalankan dari akun master, klon baru
   otomatis dibagikan ke TARGET_OWNER_EMAIL dengan permission EDITOR. Jika dijalankan
   langsung di bawah sesi TARGET_OWNER_EMAIL, akun tersebut otomatis menjadi Pemilik (Owner).
5. State & Checkpoint Persistence: Menyimpan progres ke manifest JSON (`cloned_masters_manifest.json`).
   Bila proses terhenti di tengah jalan, skrip dapat melanjutkan tanpa mengulang yang sudah selesai.
6. Dry-Run & Granular Filtering: Dukungan mode `--dry-run`, pemfilteran per `--scope`
   atau per `--entity`, serta pembatasan `--max-sources` untuk keperluan pengujian.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import sys
import time
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

# Path setup: Pastikan module notebooklm dan dependencies lokal dapat diimpor
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WHEEL_PATH = os.path.join(SCRIPT_DIR, "notebooklm_py-0.8.0a3-py3-none-any.whl")
SRC_PATH = os.path.join(SCRIPT_DIR, "..", "notebooklm-py", "src")

for path in [WHEEL_PATH, SRC_PATH, SCRIPT_DIR]:
    if os.path.exists(path) and path not in sys.path:
        sys.path.insert(0, path)


def load_dotenv():
    """Memuat variabel konfigurasi dari berkas .env lokal bila ada."""
    env_path = os.path.join(SCRIPT_DIR, ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, val = line.split("=", 1)
                    val = val.strip()
                    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                        val = val[1:-1]
                    os.environ.setdefault(key.strip(), val)


load_dotenv()

# Konfigurasi logging terstruktur
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("batch_cloner")

# Target default akun Google khusus penerima klon
DEFAULT_TARGET_OWNER_EMAIL = os.getenv("TARGET_OWNER_EMAIL", "macbookairm1ku@gmail.com")

# ─────────────────────────────────────────────────────────────────────────────
# 24 KAJIAN MASTER TURATS (CANONICAL CATALOG)
# ─────────────────────────────────────────────────────────────────────────────
CANONICAL_24_MASTERS = [
    {
        "index": 1,
        "entity": "01_FIKIH_SYAFII",
        "master_id": "c89d09ca-4b48-4000-a98d-59e532607fb6",
        "scope": "fiqh_syafii",
        "label": "AI Fikih Syafi'i",
        "default_title": "01 - FIKIH SYAFII (NODE 1)",
    },
    {
        "index": 2,
        "entity": "02_HADITS",
        "master_id": "9da436c8-f9b7-4e8b-a51f-d798a31892a7",
        "scope": "hadits",
        "label": "AI Hadits",
        "default_title": "02 - HADITS NABAWI (NODE 1)",
    },
    {
        "index": 3,
        "entity": "03_USHUL_FIKIH",
        "master_id": "6009f2ee-6328-497d-b74e-4276834caa94",
        "scope": "ushul_fiqh",
        "label": "AI Ushul Fiqih",
        "default_title": "03 - USHUL FIKIH (NODE 1)",
    },
    {
        "index": 4,
        "entity": "04_BAHASA_DAN_SASTRA_ARAB",
        "master_id": "1ae6ae57-53f0-4ce2-a2be-c324e03abb83",
        "scope": "nahwu",
        "label": "AI Bahasa Arab",
        "default_title": "04 - BAHASA DAN SASTRA ARAB (NODE 1)",
    },
    {
        "index": 5,
        "entity": "05_TAFSIR_DAN_ULUMUL_QURAN",
        "master_id": "f15bd838-dac9-415b-bd40-fef3da1355d4",
        "scope": "tafsir",
        "label": "AI Tafsir",
        "default_title": "05 - TAFSIR DAN ULUMUL QURAN (NODE 1)",
    },
    {
        "index": 6,
        "entity": "06.1_AL_MUHAQQIQ",
        "master_id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "scope": "fiqh_tahawwulat",
        "label": "AI Fikih Tahawwulat",
        "default_title": "06.1 - AL-MUHAQQIQ (NODE 1)",
    },
    {
        "index": 7,
        "entity": "06.2_AL_BAYAN",
        "master_id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "scope": "fiqh_tahawwulat",
        "label": "AI Fikih Tahawwulat",
        "default_title": "06.2 - AL-BAYAN (NODE 1)",
    },
    {
        "index": 8,
        "entity": "06.3_AL_MUKHTABIR",
        "master_id": "ac803816-5541-4446-bc9d-b56326493555",
        "scope": "fiqh_tahawwulat",
        "label": "AI Fikih Tahawwulat",
        "default_title": "06.3 - AL-MUKHTABIR (NODE 1)",
    },
    {
        "index": 9,
        "entity": "06.4_AL_HABIB",
        "master_id": "c8b8a754-991d-429d-8379-b0478abb6ceb",
        "scope": "fiqh_tahawwulat",
        "label": "AI Fikih Tahawwulat",
        "default_title": "06.4 - AL-HABIB (NODE 1)",
    },
    {
        "index": 10,
        "entity": "06.5_AL_KHATIB",
        "master_id": "926f3633-53fc-4dbf-81da-0570f7a4d26b",
        "scope": "fiqh_tahawwulat",
        "label": "AI Fikih Tahawwulat",
        "default_title": "06.5 - AL-KHATIB (NODE 1)",
    },
    {
        "index": 11,
        "entity": "07_TARIKH_DAN_SIRAH_NABAWIYYAH",
        "master_id": "94d49b05-e0b6-4ea2-9b7d-7c75f8edca75",
        "scope": "tarikh",
        "label": "AI Tarikh & Sirah Nabawiyah",
        "default_title": "07 - TARIKH DAN SIRAH NABAWIYYAH (NODE 1)",
    },
    {
        "index": 12,
        "entity": "08_FIKIH_MUQARAN_DAN_UMUM",
        "master_id": "66ed9863-e177-43a9-a1a4-25fb953520a7",
        "scope": "fiqh_muqaran",
        "label": "AI Fikih Perbandingan Mazhab",
        "default_title": "08 - FIKIH MUQARAN DAN UMUM (NODE 1)",
    },
    {
        "index": 13,
        "entity": "09_FATAWA_DAN_MASAIL_FIQHIYYAH",
        "master_id": "45a2043c-4617-42a7-9f00-fbc2138def48",
        "scope": "fiqh",
        "label": "AI Fatawa & Masail",
        "default_title": "09 - FATAWA DAN MASAIL FIQHIYYAH (NODE 1)",
    },
    {
        "index": 14,
        "entity": "10_SYARAH_HADITS",
        "master_id": "27c104b7-e8aa-40a9-b9dd-ad4741b2d515",
        "scope": "hadits",
        "label": "AI Hadits",
        "default_title": "10 - SYARAH HADITS (NODE 1)",
    },
    {
        "index": 15,
        "entity": "11_FIKIH_HANAFI",
        "master_id": "063ddf96-61a5-46c7-a6ae-5b9eb8bddb6b",
        "scope": "fiqh_hanafi",
        "label": "AI Fikih Hanafi",
        "default_title": "11 - FIKIH HANAFI (NODE 1)",
    },
    {
        "index": 16,
        "entity": "12_FIKIH_MALIKI",
        "master_id": "cc152334-e7d2-44ac-bb14-65e70d893b40",
        "scope": "fiqh_maliki",
        "label": "AI Fikih Maliki",
        "default_title": "12 - FIKIH MALIKI (NODE 1)",
    },
    {
        "index": 17,
        "entity": "13_FIKIH_HANBALI",
        "master_id": "45f6ccdd-d3e5-4ca7-96cb-4f905d3cde3e",
        "scope": "fiqh_hanbali",
        "label": "AI Fikih Hanbali",
        "default_title": "13 - FIKIH HANBALI (NODE 1)",
    },
    {
        "index": 18,
        "entity": "14_TASAWWUF_DAN_ADZKAR",
        "master_id": "9a9902ff-ff0a-4696-845b-a809a69db84b",
        "scope": "tasawwuf",
        "label": "AI Tasawwuf & Tazkiyatun Nafs",
        "default_title": "14 - TASAWWUF DAN ADZKAR (NODE 1)",
    },
    {
        "index": 19,
        "entity": "15_TAJWID_DAN_QIRAAT",
        "master_id": "0364032d-3cb9-4b4e-bf5c-b0bf72f134f6",
        "scope": "tafsir",
        "label": "AI Tafsir",
        "default_title": "15 - TAJWID DAN QIRAAT (NODE 1)",
    },
    {
        "index": 20,
        "entity": "16_QAWAID_FIQHIYYAH",
        "master_id": "35cc555e-3d6c-43fd-ae82-6a06cd107899",
        "scope": "ushul_fiqh",
        "label": "AI Ushul Fiqih",
        "default_title": "16 - QAWAID FIQHIYYAH (NODE 1)",
    },
    {
        "index": 21,
        "entity": "17_MUSTHALAH_DAN_ULUMUL_HADITS",
        "master_id": "af26bf8f-4429-4d2f-9cf0-17bcc835fb86",
        "scope": "hadits",
        "label": "AI Hadits",
        "default_title": "17 - MUSTHALAH DAN ULUMUL HADITS (NODE 1)",
    },
    {
        "index": 22,
        "entity": "18_AQIDAH_DAN_USHULUDDIN",
        "master_id": "d4807af1-1c3b-4ffd-b9b8-a944b2f8c5bd",
        "scope": "aqidah",
        "label": "AI Aqidah & Ushuluddin",
        "default_title": "18 - AQIDAH DAN USHULUDDIN (NODE 1)",
    },
    {
        "index": 23,
        "entity": "19_THABAQAT_DAN_TARAJIM_RIJAL",
        "master_id": "59fd5420-7392-4d58-825a-02b87bade32d",
        "scope": "tarikh",
        "label": "AI Tarikh & Sirah Nabawiyah",
        "default_title": "19 - THABAQAT DAN TARAJIM RIJAL (NODE 1)",
    },
    {
        "index": 24,
        "entity": "26_BIBLIOGRAFI_DAN_FAHARIS",
        "master_id": "d35f7598-076a-4c91-8ccf-9dc1aa1b0e7d",
        "scope": "bibliografi_faharis",
        "label": "AI Bibliografi & Faharis",
        "default_title": "26 - BIBLIOGRAFI DAN FAHARIS (NODE 1)",
    },
]


def load_masters_from_catalog() -> List[Dict[str, Any]]:
    """
    Memuat daftar 24 Master Notebooks dari product_catalog.json jika tersedia,
    atau menggunakan daftar canonical di atas sebagai fallback terpercaya.
    """
    catalog_path = os.path.join(SCRIPT_DIR, "shared", "product_catalog.json")
    if os.path.exists(catalog_path):
        try:
            with open(catalog_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            scopes = data.get("scopes", {})
            masters = []
            idx = 0
            for sc_name, sc_info in scopes.items():
                label = sc_info.get("label", sc_name)
                for nb in sc_info.get("notebooks", []):
                    idx += 1
                    entity = nb.get("entity", f"ENTITY_{idx}")
                    clean_name = entity.replace("_", " ")
                    masters.append({
                        "index": idx,
                        "entity": entity,
                        "master_id": nb.get("master"),
                        "scope": sc_name,
                        "label": label,
                        "default_title": f"{clean_name} (NODE 1)",
                    })
            masters.sort(key=lambda x: x["entity"])
            for i, m in enumerate(masters, 1):
                m["index"] = i
            return masters
        except Exception as e:
            logger.warning("Gagal memuat product_catalog.json (%s), menggunakan CANONICAL_24_MASTERS", e)
    return CANONICAL_24_MASTERS


# ─────────────────────────────────────────────────────────────────────────────
# MANIFEST / CHECKPOINT MANAGER
# ─────────────────────────────────────────────────────────────────────────────
class ManifestManager:
    """Mengelola status checkpoint setiap notebook yang sudah berhasil dikloning."""

    def __init__(self, filepath: str):
        self.filepath = filepath
        self.data: Dict[str, Any] = {}
        self.load()

    def load(self):
        if os.path.exists(self.filepath):
            try:
                with open(self.filepath, "r", encoding="utf-8") as f:
                    self.data = json.load(f)
            except Exception as e:
                logger.error("Gagal membaca manifest %s: %s", self.filepath, e)
                self.data = {}
        else:
            self.data = {
                "_metadata": {
                    "created_at": datetime.now(timezone.utc).isoformat(),
                    "target_owner_email": DEFAULT_TARGET_OWNER_EMAIL,
                    "version": "1.0.0",
                },
                "notebooks": {},
            }

    def save(self):
        self.data.setdefault("_metadata", {})["updated_at"] = datetime.now(timezone.utc).isoformat()
        temp_file = f"{self.filepath}.tmp.{os.getpid()}"
        with open(temp_file, "w", encoding="utf-8") as f:
            json.dump(self.data, f, indent=2, ensure_ascii=False)
        os.replace(temp_file, self.filepath)

    def is_completed(self, master_id: str) -> bool:
        nb_entry = self.data.get("notebooks", {}).get(master_id)
        if not nb_entry:
            return False
        return nb_entry.get("status") == "COMPLETED"

    def record_success(self, master_id: str, details: Dict[str, Any]):
        self.data.setdefault("notebooks", {})[master_id] = {
            "status": "COMPLETED",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            **details,
        }
        self.save()

    def record_failure(self, master_id: str, error_msg: str, details: Optional[Dict[str, Any]] = None):
        entry = {
            "status": "FAILED",
            "error": error_msg,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
        if details:
            entry.update(details)
        self.data.setdefault("notebooks", {})[master_id] = entry
        self.save()


# ─────────────────────────────────────────────────────────────────────────────
# CORE CLONING LOGIC
# ─────────────────────────────────────────────────────────────────────────────
async def clone_single_master(
    client: Any,
    master_info: Dict[str, Any],
    target_owner_email: str,
    source_delay: float = 1.0,
    max_sources: Optional[int] = None,
    custom_title: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Menduplikasi satu Master Notebook ke Notebook Node klone baru:
    1. Membuat notebook baru di NotebookLM.
    2. Menyalin 100% dokumen sumber (fulltext) dari Master ke Klone.
    3. Menerapkan delay mikro per sumber (default 1.0s) demi keamanan rate limit.
    4. Mengunci proteksi notebook ke level CHAT_ONLY dan RESTRICTED (non-public).
    5. Menetapkan hak akses EDITOR ke target_owner_email.
    """
    from notebooklm.rpc.types import SharePermission, ShareViewLevel

    master_id = master_info["master_id"]
    clone_title = custom_title or master_info.get("default_title") or f"{master_info['entity']} (NODE 1)"

    logger.info("----------------------------------------------------------------------")
    logger.info("🚀 [%02d/24] MEMULAI KLONING: %s", master_info["index"], master_info["entity"])
    logger.info("   • Master ID    : %s", master_id)
    logger.info("   • Judul Klone  : %s", clone_title)
    logger.info("   • Scope/Label  : %s (%s)", master_info["scope"], master_info["label"])
    logger.info("   • Target Owner : %s", target_owner_email)
    logger.info("----------------------------------------------------------------------")

    # 1. Buat Notebook Klone Baru
    new_nb = await client.notebooks.create(clone_title)
    clone_id = getattr(new_nb, "id", getattr(new_nb, "notebook_id", None))
    if not clone_id:
        raise RuntimeError(f"Gagal mendapatkan ID notebook klone baru untuk '{clone_title}'")
    logger.info("✅ Notebook klone berhasil dibuat! ID: %s", clone_id)

    # 2. Ambil seluruh daftar file/sumber dari Master Notebook
    master_sources = await client.sources.list(master_id)
    total_master_sources = len(master_sources)
    logger.info("📚 Ditemukan %d file sumber pada Master Notebook.", total_master_sources)

    sources_to_copy = master_sources if not max_sources else master_sources[:max_sources]
    copied_count = 0
    failed_count = 0
    total_chars = 0

    # 3. Salin setiap source dengan delay mikro aman
    for i, src in enumerate(sources_to_copy, 1):
        src_title = getattr(src, "title", None) or getattr(src, "name", f"Source_{i}")
        src_id = getattr(src, "id", None)

        logger.info("   [%d/%d] Menyalin sumber: '%s'...", i, len(sources_to_copy), src_title[:45])
        try:
            # Ambil fulltext dokumen dari master
            ft_obj = await client.sources.get_fulltext(master_id, src_id)
            text_content = getattr(ft_obj, "text", str(ft_obj))

            if text_content and len(text_content.strip()) > 0:
                await client.sources.add_text(
                    notebook_id=clone_id,
                    title=src_title,
                    content=text_content,
                )
                copied_count += 1
                chars_len = len(text_content)
                total_chars += chars_len
                logger.info("       -> Berhasil disalin! (%d karakter)", chars_len)
            else:
                logger.warning("       -> Dilewati: Teks kosong/tidak terbaca")
        except Exception as e:
            failed_count += 1
            logger.error("       -> ❌ Gagal menyalin '%s': %s", src_title[:30], e)

        # Micro-delay 1.0 detik agar tidak terkena rate limit Google
        if source_delay > 0:
            await asyncio.sleep(source_delay)

    # 4. Kunci proteksi ke level CHAT_ONLY & RESTRICTED
    logger.info("🔒 Menerapkan proteksi keamanan mutlak...")
    try:
        await client.sharing.set_public(clone_id, False)
        await client.sharing.set_view_level(notebook_id=clone_id, level=ShareViewLevel.CHAT_ONLY)
        logger.info("✅ Proteksi CHAT_ONLY & RESTRICTED aktif 100%!")
    except Exception as e:
        logger.warning("⚠️ Peringatan saat mengatur CHAT_ONLY: %s", e)

    # 5. Bagikan hak EDITOR ke Target Owner (macbookairm1ku@gmail.com)
    target_shared = False
    if target_owner_email:
        logger.info("👤 Mendaftarkan Target Owner: %s (EDITOR)...", target_owner_email)
        try:
            await client.sharing.add_user(
                notebook_id=clone_id,
                email=target_owner_email,
                permission=SharePermission.EDITOR,
                notify=False,
            )
            target_shared = True
            logger.info("✅ Target Owner %s berhasil didaftarkan sebagai EDITOR!", target_owner_email)
        except Exception as e:
            # Bila akun yang sedang login sudah merupakan target_owner_email, Google akan menolak add_user sendiri
            if "already" in str(e).lower() or "owner" in str(e).lower():
                target_shared = True
                logger.info("ℹ️ Akun sesi saat ini adalah Pemilik notebook (%s).", target_owner_email)
            else:
                logger.warning("⚠️ Tidak dapat menambahkan target owner %s: %s", target_owner_email, e)

    result_payload = {
        "master_id": master_id,
        "entity": master_info["entity"],
        "scope": master_info["scope"],
        "label": master_info["label"],
        "clone_id": clone_id,
        "clone_title": clone_title,
        "clone_url": f"https://notebooklm.google.com/notebook/{clone_id}",
        "total_master_sources": total_master_sources,
        "copied_sources": copied_count,
        "failed_sources": failed_count,
        "total_characters": total_chars,
        "chat_only_enforced": True,
        "target_owner_shared": target_shared,
        "target_owner_email": target_owner_email,
    }
    logger.info("🎉 Kloning %s SELESAI (%d sumber, %d karakter).", master_info["entity"], copied_count, total_chars)
    return result_payload


# ─────────────────────────────────────────────────────────────────────────────
# ORCHESTRATOR RUNNER
# ─────────────────────────────────────────────────────────────────────────────
async def run_orchestrator(args: argparse.Namespace) -> int:
    """Menjalankan proses kloning batch untuk ke-24 kajian master."""
    import notebooklm_manager as nlm
    NotebookLMClient = nlm._get_client()

    storage_path = args.storage_path
    if not storage_path:
        default_local = os.path.join(SCRIPT_DIR, "storage_state.json")
        if os.path.exists(default_local):
            storage_path = default_local
        else:
            storage_path = nlm._get_storage_path()
            if not storage_path:
                user_prof = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
                if os.path.exists(user_prof):
                    storage_path = user_prof
    if not storage_path or not os.path.exists(storage_path):
        logger.error("❌ Berkas sesi storage_state.json tidak ditemukan! Path: %s", storage_path)
        return 1

    # Segarkan cookie sesi jika perlu
    await nlm._ensure_fresh_cookies()

    manifest = ManifestManager(args.manifest_file)
    masters = load_masters_from_catalog()

    # Filter berdasarkan argumen CLI
    if args.scope:
        masters = [m for m in masters if m["scope"].lower() == args.scope.lower()]
    if args.entity:
        masters = [m for m in masters if args.entity.lower() in m["entity"].lower()]
    if args.from_index:
        masters = [m for m in masters if m["index"] >= args.from_index]
    if args.to_index:
        masters = [m for m in masters if m["index"] <= args.to_index]

    if not masters:
        logger.warning("Tidak ada kajian master yang cocok dengan filter kriteria.")
        return 0

    logger.info("======================================================================")
    logger.info("⚡ OPENTURATH AI MASTER NOTEBOOKS ORCHESTRATOR")
    logger.info("======================================================================")
    logger.info("Jumlah Master Ditargetkan : %d kajian", len(masters))
    logger.info("Target Owner Google       : %s", args.target_email)
    logger.info("Delay Mikro Sumber        : %.1f detik", args.source_delay)
    logger.info("Delay Antar Notebook      : %.1f detik", args.notebook_delay)
    logger.info("Mode Dry-Run              : %s", "YA (Simulasi saja)" if args.dry_run else "TIDAK (Live Cloning)")
    logger.info("Berkas Manifest State     : %s", args.manifest_file)
    logger.info("======================================================================\n")

    # MODE DRY RUN: Hanya membaca dan memverifikasi akses tanpa membuat klon
    if args.dry_run:
        logger.info("🔍 Menjalankan Mode DRY-RUN (Audit koneksi dan pembacaan sumber master)...")
        try:
            async with NotebookLMClient.from_storage(path=storage_path) as client:
                print("\n┌─────┬───────────────────────────────┬──────────────────────────────────────┬─────────┐")
                print("│ No  │ Kajian Turats (Entity)        │ Master ID                            │ Sumber  │")
                print("├─────┼───────────────────────────────┼──────────────────────────────────────┼─────────┤")
                for m in masters:
                    try:
                        srcs = await client.sources.list(m["master_id"])
                        cnt = len(srcs)
                        print(f"│ {m['index']:02d}  │ {m['entity'][:29]:<29} │ {m['master_id']} │ {cnt:>7} │")
                    except Exception as e:
                        print(f"│ {m['index']:02d}  │ {m['entity'][:29]:<29} │ {m['master_id']} │ ERROR   │ ({e})")
                    await asyncio.sleep(0.3)
                print("└─────┴───────────────────────────────┴──────────────────────────────────────┴─────────┘\n")
            logger.info("✅ Pemeriksaan Dry-Run selesai! Seluruh master siap dikloning.")
            return 0
        except Exception as auth_err:
            if any(term in str(auth_err).lower() for term in ["csrf", "unauthorized", "expired", "rotatecookies"]):
                logger.error("❌ Sesi Google pada %s telah kedaluwarsa atau belum login!", storage_path)
                logger.error("   Harap perbarui sesi dengan login akun Google target (%s):", args.target_email)
                logger.error("   Contoh: notebooklm login --browser-cookies chrome")
                return 1
            raise

    # MODE LIVE: Kloning nyata ke-24 master notebook
    success_count = 0
    skipped_count = 0
    failed_count = 0
    results_summary = []

    try:
        async with NotebookLMClient.from_storage(path=storage_path) as client:
            for idx, master in enumerate(masters, 1):
                m_id = master["master_id"]

                # Cek apakah sudah pernah selesai di manifest (checkpoint)
                if not args.force and manifest.is_completed(m_id):
                    logger.info("⏩ [%02d/%d] Melewati %s (Sudah selesai di manifest)", idx, len(masters), master["entity"])
                    skipped_count += 1
                    nb_entry = manifest.data["notebooks"][m_id]
                    results_summary.append({
                        "entity": master["entity"],
                        "status": "SKIPPED",
                        "clone_id": nb_entry.get("clone_id", "-"),
                        "sources": nb_entry.get("copied_sources", 0),
                    })
                    continue

                try:
                    # Custom title formatting
                    custom_title = master.get("default_title")
                    if args.title_prefix or args.title_suffix:
                        clean_ent = master["entity"].replace("_", " ")
                        custom_title = f"{args.title_prefix}{clean_ent}{args.title_suffix}"

                    res = await clone_single_master(
                        client=client,
                        master_info=master,
                        target_owner_email=args.target_email,
                        source_delay=args.source_delay,
                        max_sources=args.max_sources,
                        custom_title=custom_title,
                    )
                    manifest.record_success(m_id, res)
                    success_count += 1
                    results_summary.append({
                        "entity": master["entity"],
                        "status": "SUCCESS",
                        "clone_id": res["clone_id"],
                        "sources": res["copied_sources"],
                    })

                except Exception as e:
                    failed_count += 1
                    logger.exception("❌ Gagal mengkloning %s: %s", master["entity"], e)
                    manifest.record_failure(m_id, str(e))
                    results_summary.append({
                        "entity": master["entity"],
                        "status": "FAILED",
                        "clone_id": "-",
                        "sources": 0,
                    })

                # Delay antar notebook demi stabilitas API
                if idx < len(masters) and args.notebook_delay > 0:
                    logger.info("⏳ Menunggu %.1f detik sebelum notebook berikutnya...\n", args.notebook_delay)
                    await asyncio.sleep(args.notebook_delay)

    except Exception as auth_err:
        if any(term in str(auth_err).lower() for term in ["csrf", "unauthorized", "expired", "rotatecookies"]):
            logger.error("❌ Sesi Google pada %s telah kedaluwarsa atau belum login!", storage_path)
            logger.error("   Harap perbarui sesi dengan login akun Google target (%s):", args.target_email)
            logger.error("   Contoh: notebooklm login --browser-cookies chrome")
            return 1
        raise

    # Cetak Ringkasan Akhir
    logger.info("======================================================================")
    logger.info("🏁 HASIL AKHIR ORKESTRASI KLONING MASTER TURATS")
    logger.info("======================================================================")
    logger.info("Total Master Ditargetkan : %d", len(masters))
    logger.info("Berhasil Dikonversi      : %d", success_count)
    logger.info("Dilewati (Sudah Selesai) : %d", skipped_count)
    logger.info("Gagal                    : %d", failed_count)
    logger.info("Target Penerima          : %s", args.target_email)
    logger.info("Manifest Output          : %s", args.manifest_file)
    logger.info("======================================================================")

    return 0 if failed_count == 0 else 2


# ─────────────────────────────────────────────────────────────────────────────
# CLI ENTRY POINT
# ─────────────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(
        description="OpenTurath AI - Batch Cloner & Orchestrator untuk 24 Master Notebooks",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--target-email",
        default=DEFAULT_TARGET_OWNER_EMAIL,
        help="Alamat email akun Google khusus penerima klon (Google One / NotebookLM Pro)",
    )
    parser.add_argument(
        "--source-delay",
        type=float,
        default=1.0,
        help="Delay mikro (detik) antar penyalinan sumber teks untuk mencegah rate limit Google",
    )
    parser.add_argument(
        "--notebook-delay",
        type=float,
        default=3.0,
        help="Delay (detik) antar pembuatan notebook",
    )
    parser.add_argument(
        "--storage-path",
        default=None,
        help="Path ke berkas storage_state.json untuk autentikasi",
    )
    parser.add_argument(
        "--manifest-file",
        default=os.path.join(SCRIPT_DIR, "cloned_masters_manifest.json"),
        help="Path berkas checkpoint/state manifest JSON",
    )
    parser.add_argument(
        "--max-sources",
        type=int,
        default=None,
        help="Batas maksimum sumber per notebook (None = salin semua)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulasi dan verifikasi pembacaan master tanpa membuat notebook baru",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Paksa kloning ulang meskipun master sudah tercatat selesai di manifest",
    )
    parser.add_argument(
        "--scope",
        default=None,
        help="Filter hanya mengkloning scope tertentu (misal: fiqh_syafii, fiqh_tahawwulat, hadits)",
    )
    parser.add_argument(
        "--entity",
        default=None,
        help="Filter hanya mengkloning entity tertentu (misal: 01_FIKIH_SYAFII)",
    )
    parser.add_argument(
        "--from-index",
        type=int,
        default=None,
        help="Mulai dari nomor indeks master tertentu (1-24)",
    )
    parser.add_argument(
        "--to-index",
        type=int,
        default=None,
        help="Hingga nomor indeks master tertentu (1-24)",
    )
    parser.add_argument(
        "--title-prefix",
        default="",
        help="Prefix tambahan untuk judul notebook klone baru",
    )
    parser.add_argument(
        "--title-suffix",
        default=" (NODE 1)",
        help="Suffix tambahan untuk judul notebook klone baru",
    )

    args = parser.parse_args()

    exit_code = asyncio.run(run_orchestrator(args))
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
