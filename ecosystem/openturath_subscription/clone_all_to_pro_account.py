#!/usr/bin/env python3
"""
Orkestrator Duplikasi 24 Kajian Master ke Akun Pro Baru (hus180402@gmail.com)
=============================================================================
Metode:
1. Memilih Clone 13 dari setiap kategori (agar master utama tidak disentuh).
2. Di akun master (raflimaulan@gmail.com): aktifkan Allow Copies (requiredCopyRole=3)
   dan undang akun target sebagai EDITOR.
3. Di akun Pro baru (hus180402@gmail.com): duplikasi notebook via RPC te3DCe.
4. Di akun Pro baru: amankan notebook baru (Anyone with link, CHAT_ONLY, Allow copies = OFF).
5. Di akun master: kembalikan Clone 13 ke status aman (requiredCopyRole=1) dan cabut akses target.
6. Catat riwayat ke pro_account_master_catalog.json.
"""

import asyncio
import json
import os
import sys
import time

sys.path.insert(0, '/Users/apple/Downloads/Kitab Tahawwulat RAG/.venv/lib/python3.14/site-packages')

from notebooklm import NotebookLMClient
from notebooklm.types import SharePermission, ShareViewLevel
from notebooklm.rpc import RPCMethod
from notebooklm._web.params.notebooks import build_copy_notebook_params

MASTER_STORAGE = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
TARGET_STORAGE = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/storage_state_macbookairm1ku.json"
TARGET_EMAIL = "hus180402@gmail.com"

SOURCE_CATALOG = "/Users/apple/Downloads/Kitab Tahawwulat RAG/cloned_notebooks_master_catalog.json"
OUTPUT_CATALOG = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/pro_account_master_catalog.json"

CATEGORIES = [
    {"key": "01_FIKIH_SYAFII",                "prefix": "01 - FIKIH SYAFII"},
    {"key": "02_HADITS",                      "prefix": "02 - HADITS"},
    {"key": "03_USHUL_FIKIH",                 "prefix": "03 - USHUL FIKIH"},
    {"key": "04_BAHASA_DAN_SASTRA_ARAB",      "prefix": "04 - BAHASA DAN SASTRA ARAB"},
    {"key": "05_TAFSIR_DAN_ULUMUL_QURAN",     "prefix": "05 - TAFSIR DAN ULUMUL QURAN"},
    {"key": "06.1_AL_MUHAQQIQ",               "prefix": "06.1 - AL-MUHAQQIQ"},
    {"key": "06.2_AL_BAYAN",                  "prefix": "06.2 - AL-BAYAN"},
    {"key": "06.3_AL_MUKHTABIR",              "prefix": "06.3 - AL-MUKHTABIR"},
    {"key": "06.4_AL_HABIB",                  "prefix": "06.4 - AL-HABIB"},
    {"key": "06.5_AL_KHATIB",                 "prefix": "06.5 - AL-KHATIB"},
    {"key": "07_TARIKH_DAN_SIRAH_NABAWIYYAH", "prefix": "07 - TARIKH DAN SIRAH NABAWIYYAH"},
    {"key": "08_FIKIH_MUQARAN_DAN_UMUM",      "prefix": "08 - FIKIH MUQARAN"},
    {"key": "09_FATAWA_DAN_MASAIL_FIQHIYYAH", "prefix": "09 - FATAWA & MASAIL FIQHIYYAH"},
    {"key": "10_SYARAH_HADITS",               "prefix": "10 - SYARAH HADITS"},
    {"key": "11_FIKIH_HANAFI",                "prefix": "11 - FIKIH HANAFI"},
    {"key": "12_FIKIH_MALIKI",                "prefix": "12 - FIKIH MALIKI"},
    {"key": "13_FIKIH_HANBALI",               "prefix": "13 - FIKIH HANBALI"},
    {"key": "14_TASAWWUF_DAN_ADZKAR",         "prefix": "14 - TASAWWUF DAN ADZKAR"},
    {"key": "15_TAJWID_DAN_QIRAAT",           "prefix": "15 - TAJWID DAN QIRAAT"},
    {"key": "16_QAWAID_FIQHIYYAH",            "prefix": "16 - QAWAID FIQHIYYAH"},
    {"key": "17_MUSTHALAH_DAN_ULUMUL_HADITS", "prefix": "17 - MUSTHALAH DAN ULUMUL HADITS"},
    {"key": "18_AQIDAH_DAN_USHULUDDIN",       "prefix": "18 - AQIDAH DAN USHULUDDIN"},
    {"key": "19_THABAQAT_DAN_TARAJIM_RIJAL",  "prefix": "19 - THABAQAT DAN TARAJIM RIJAL"},
    {"key": "26_BIBLIOGRAFI_DAN_FAHARIS",     "prefix": "26 - BIBLIOGRAFI DAN FAHARIS"},
]

async def clone_all():
    print("=" * 80)
    print("🚀 DUPLIKASI 24 KAJIAN MASTER KE AKUN GOOGLE PRO BARU")
    print(f"Target Akun: {TARGET_EMAIL}")
    print("=" * 80)

    # 1. Baca katalog klon sumber
    with open(SOURCE_CATALOG, "r", encoding="utf-8") as f:
        source_clones = json.load(f)

    from collections import defaultdict
    clones_by_cat = defaultdict(list)
    for c in source_clones:
        clones_by_cat[c.get("category_key")].append(c)

    # 2. Baca riwayat output yang sudah selesai
    pro_catalog = {}
    if os.path.exists(OUTPUT_CATALOG):
        try:
            with open(OUTPUT_CATALOG, "r", encoding="utf-8") as f:
                pro_catalog = json.load(f)
        except Exception:
            pro_catalog = {}

    # Masukkan Fikih Syafii yang sudah berhasil pada uji coba sebelumnya
    if "01_FIKIH_SYAFII" not in pro_catalog:
        pro_catalog["01_FIKIH_SYAFII"] = {
            "category_key": "01_FIKIH_SYAFII",
            "title": "01 - FIKIH SYAFII (PRO MASTER)",
            "notebook_id": "6f42cb8a-79cc-429b-89c5-9a96561f8f4d",
            "url": "https://notebooklm.google.com/notebook/6f42cb8a-79cc-429b-89c5-9a96561f8f4d",
            "source_clone_id": "c407fc84-5a44-4cc9-938c-3198416f44cb",
            "status": "COMPLETED",
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        with open(OUTPUT_CATALOG, "w", encoding="utf-8") as f:
            json.dump(pro_catalog, f, indent=2, ensure_ascii=False)

    print(f"📦 Ditemukan {len(pro_catalog)} kajian sudah berstatus selesai di target.")

    # 3. Inisialisasi Klien
    async with NotebookLMClient.from_storage(MASTER_STORAGE) as master_client, \
               NotebookLMClient.from_storage(TARGET_STORAGE) as target_client:

        print("🔐 Sesi Master & Target aktif.", flush=True)

        for idx, cat in enumerate(CATEGORIES, 1):
            key = cat["key"]
            prefix = cat["prefix"]

            if key in pro_catalog and pro_catalog[key].get("status") == "COMPLETED":
                print(f"[{idx:02d}/24] ⏭️  {prefix} sudah selesai: {pro_catalog[key]['notebook_id']}")
                continue

            available = clones_by_cat.get(key, [])
            if not available:
                print(f"[{idx:02d}/24] ⚠️  Tidak ada clone untuk kategori {key}! Dilewati.")
                continue

            # Pilih clone terakhir (Clone 13)
            source_clone = available[-1]
            clone_id = source_clone["id"]
            clone_title = source_clone["title"]
            target_title = f"{prefix} (MASTER)"

            print(f"\n[{idx:02d}/24] 🔄 Memproses {prefix}...")
            print(f"       Sumber: {clone_title} ({clone_id})")

            success = False
            for attempt in range(1, 4):
                try:
                    # Langkah A: Master aktifkan Allow Copies & undang Editor
                    mut_copy_on = [None, None, None, [None, None, None, None, 3]]
                    await master_client.rpc_call(RPCMethod.RENAME_NOTEBOOK, [clone_id, [mut_copy_on]], allow_null=True)
                    try:
                        await master_client.sharing.add_user(clone_id, TARGET_EMAIL, SharePermission.EDITOR)
                    except Exception:
                        pass

                    await asyncio.sleep(0.5)

                    # Langkah B: Target menduplikasi notebook
                    t0 = time.time()
                    params = build_copy_notebook_params(clone_id, target_title)
                    res = await target_client.rpc_call(RPCMethod.COPY_NOTEBOOK, params)
                    elapsed = time.time() - t0
                    new_id = res[2]
                    print(f"       ✅ Berhasil diduplikasi ({elapsed:.2f}s) ➔ {new_id}")

                    # Langkah C: Target mengamankan notebook baru
                    await target_client.sharing.set_public(new_id, True)
                    await target_client.sharing.set_view_level(new_id, ShareViewLevel.CHAT_ONLY)
                    mut_copy_off = [None, None, None, [None, None, None, None, 1]]
                    mut_chat_on = [None, None, None, None, None, None, None, None, [[1]]]
                    await target_client.rpc_call(RPCMethod.RENAME_NOTEBOOK, [new_id, [mut_copy_off, mut_chat_on]], allow_null=True)
                    print(f"       🛡️  Keamanan notebook baru dikunci: Chat Only & Copies OFF")

                    # Simpan progres
                    pro_catalog[key] = {
                        "category_key": key,
                        "title": target_title,
                        "notebook_id": new_id,
                        "url": f"https://notebooklm.google.com/notebook/{new_id}",
                        "source_clone_id": clone_id,
                        "status": "COMPLETED",
                        "elapsed_seconds": round(elapsed, 2),
                        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
                    }
                    with open(OUTPUT_CATALOG, "w", encoding="utf-8") as f:
                        json.dump(pro_catalog, f, indent=2, ensure_ascii=False)

                    success = True
                    break

                except Exception as e:
                    print(f"       ⚠️ Percobaan {attempt} gagal: {e}")
                    await asyncio.sleep(2.0 * attempt)

                finally:
                    # Langkah D: Bersihkan selalu izin clone di Master
                    try:
                        mut_copy_off = [None, None, None, [None, None, None, None, 1]]
                        await master_client.rpc_call(RPCMethod.RENAME_NOTEBOOK, [clone_id, [mut_copy_off]], allow_null=True)
                        await master_client.sharing.remove_user(clone_id, TARGET_EMAIL)
                    except Exception:
                        pass

            if not success:
                print(f"       ❌ GAGAL TOTAL menduplikasi {prefix}!")
            
            await asyncio.sleep(1.5)

    print("\n" + "=" * 80)
    print("🎉 SELESAI PROSES DUPLIKASI 24 KAJIAN KE AKUN PRO!")
    print(f"Katalog tersimpan di: {OUTPUT_CATALOG}")
    print("=" * 80)

if __name__ == "__main__":
    asyncio.run(clone_all())
