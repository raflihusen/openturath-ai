#!/usr/bin/env python3
"""
Mass Cloner untuk Akun Pro Baru (10 Klon per Modul)
===================================================
Menduplikasi 24 Master Induk di akun Pro baru (hus180402@gmail.com)
masing-masing sebanyak 10 salinan (total 240 notebook klon baru).

Total notebook di akun Pro setelah kloning:
34 + 240 = 274 notebook (sangat aman di bawah batas 500).

Keamanan:
Setiap klon otomatis disetel:
- is_public = True (Anyone with the link)
- view_level = CHAT_ONLY (Hanya mode percakapan obrolan)
- requiredCopyRole = 1 (Allow copies = OFF / Tombol duplikasi mati)
"""

import asyncio
import json
import os
import sys
import time

sys.path.insert(0, '/Users/apple/Downloads/Kitab Tahawwulat RAG/.venv/lib/python3.14/site-packages')

from notebooklm import NotebookLMClient
from notebooklm.types import ShareViewLevel
from notebooklm.rpc import RPCMethod
from notebooklm._web.params.notebooks import build_copy_notebook_params

TARGET_STORAGE = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/storage_state_macbookairm1ku.json"
MASTER_CATALOG = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/pro_account_master_catalog.json"
OUTPUT_CATALOG = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/pro_account_clones_catalog.json"

COPIES_PER_MODULE = 10
DELAY_BETWEEN_CALLS = 0.8

async def main():
    print("=" * 80)
    print("🚀 MASS CLONER AKUN PRO: 10 KLON PER MODUL (TOTAL 240 KLON)")
    print("=" * 80)

    # 1. Baca 24 Master Notebook di Akun Pro
    with open(MASTER_CATALOG, "r", encoding="utf-8") as f:
        masters = json.load(f)

    # 2. Baca riwayat klon yang sudah ada
    clones_catalog = []
    if os.path.exists(OUTPUT_CATALOG):
        try:
            with open(OUTPUT_CATALOG, "r", encoding="utf-8") as f:
                clones_catalog = json.load(f)
        except Exception:
            clones_catalog = []

    existing_titles = {c["title"]: c["id"] for c in clones_catalog if "title" in c and "id" in c}
    print(f"📦 Ditemukan {len(clones_catalog)} klon sudah selesai sebelumnya.")

    mut_copy_off = [None, None, None, [None, None, None, None, 1]]
    mut_chat_on = [None, None, None, None, None, None, None, None, [[1]]]

    total_created = 0
    t_start = time.time()

    async with NotebookLMClient.from_storage(TARGET_STORAGE) as target_client:
        # Cek jumlah notebook aktif saat ini
        existing_nbs = await target_client.notebooks.list()
        print(f"📊 Total notebook saat ini di akun Pro: {len(existing_nbs)} / 500")

        for mod_idx, (cat_key, mod_info) in enumerate(masters.items(), 1):
            master_id = mod_info["notebook_id"]
            # Bersihkan prefix dari string "(PRO MASTER)" atau "(MASTER)"
            raw_title = mod_info["title"]
            base_prefix = raw_title.replace(" (PRO MASTER)", "").replace(" (MASTER)", "").strip()

            print(f"\n📂 [{mod_idx:02d}/24] Memproses Modul: {base_prefix}")
            print(f"   Master ID: {master_id}")

            for i in range(1, COPIES_PER_MODULE + 1):
                clone_title = f"{base_prefix} - {i:02d}"

                if clone_title in existing_titles:
                    print(f"   ⏭️  [{i:02d}/{COPIES_PER_MODULE:02d}] Sudah ada: {clone_title} -> {existing_titles[clone_title]}")
                    continue

                # Safety check
                current_count = len(existing_nbs) + total_created
                if current_count >= 490:
                    print(f"🛑 PERINGATAN: Mencapai batas aman 490 notebook! Proses dihentikan.")
                    return

                success = False
                for attempt in range(1, 4):
                    try:
                        t0 = time.time()
                        # Langkah 1: Klon via RPC te3DCe
                        params = build_copy_notebook_params(master_id, clone_title)
                        res = await target_client.rpc_call(RPCMethod.COPY_NOTEBOOK, params)
                        elapsed = time.time() - t0
                        new_id = res[2]

                        # Langkah 2: Amankan (Anyone with link, Chat Only, Copies OFF)
                        await target_client.sharing.set_public(new_id, True)
                        await target_client.sharing.set_view_level(new_id, ShareViewLevel.CHAT_ONLY)
                        await target_client.rpc_call(RPCMethod.RENAME_NOTEBOOK, [new_id, [mut_copy_off, mut_chat_on]], allow_null=True)

                        entry = {
                            "category_key": cat_key,
                            "title": clone_title,
                            "id": new_id,
                            "url": f"https://notebooklm.google.com/notebook/{new_id}",
                            "master_id": master_id,
                            "elapsed_seconds": round(elapsed, 2),
                            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
                        }
                        clones_catalog.append(entry)
                        existing_titles[clone_title] = new_id
                        total_created += 1

                        print(f"   ✅ [{i:02d}/{COPIES_PER_MODULE:02d}] ({elapsed:.2f}s) {clone_title} ➔ {new_id}")

                        # Simpan berkala setiap 1 notebook
                        with open(OUTPUT_CATALOG, "w", encoding="utf-8") as f:
                            json.dump(clones_catalog, f, indent=2, ensure_ascii=False)

                        await asyncio.sleep(DELAY_BETWEEN_CALLS)
                        success = True
                        break

                    except Exception as e:
                        err_msg = str(e)
                        print(f"   ⚠️ [{i:02d}/{COPIES_PER_MODULE:02d}] Percobaan {attempt} gagal: {err_msg}")
                        if "401" in err_msg or "code 16" in err_msg or "expired" in err_msg.lower():
                            try:
                                await target_client.refresh_auth()
                            except Exception:
                                pass
                        await asyncio.sleep(2.0 * attempt)

                if not success:
                    print(f"   ❌ [{i:02d}/{COPIES_PER_MODULE:02d}] GAGAL TOTAL kloning {clone_title}")

    total_time = time.time() - t_start
    print("\n" + "=" * 80)
    print(f"🎉 SELESAI DUPLIKASI! Total {total_created} klon baru berhasil dibuat.")
    print(f"Waktu total: {total_time:.1f} detik ({total_time/60:.1f} menit)")
    print(f"Katalog tersimpan di: {OUTPUT_CATALOG}")
    print("=" * 80)

if __name__ == "__main__":
    asyncio.run(main())
