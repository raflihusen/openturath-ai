#!/usr/bin/env python3
"""
Revoke User Access from 24 Master Pro Notebooks
================================================
Mencabut akses akun tertentu (misal openturath@gmail.com) dari 24 Master Pro Notebooks
di akun Pro (hus180402@gmail.com).
"""

import asyncio
import json
import os
import sys
import time

sys.path.insert(0, '/Users/apple/Downloads/Kitab Tahawwulat RAG/.venv/lib/python3.14/site-packages')

from notebooklm import NotebookLMClient

TARGET_STORAGE = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/storage_state_macbookairm1ku.json"
CATALOG_PATH = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/pro_account_master_catalog.json"
REVOKE_EMAIL = "openturath@gmail.com"

async def main():
    print("=" * 80)
    print(f"🚫 MENCABUT AKSES NOTEBOOK UNTUK: {REVOKE_EMAIL}")
    print("=" * 80)

    with open(CATALOG_PATH) as f:
        catalog = json.load(f)

    async with NotebookLMClient.from_storage(TARGET_STORAGE) as target:
        revoked_count = 0
        already_absent = 0

        for idx, (cat_key, data) in enumerate(catalog.items(), 1):
            nb_id = data["notebook_id"]
            title = data["title"]

            print(f"[{idx:02d}/{len(catalog):02d}] Memeriksa {title} ({nb_id})...", end=" ", flush=True)

            try:
                # Cek apakah user ada di notebook
                status = await target.sharing.get_status(nb_id)
                users = [u.email for u in status.shared_users]

                if REVOKE_EMAIL in users:
                    t0 = time.time()
                    new_status = await target.sharing.remove_user(nb_id, REVOKE_EMAIL)
                    elapsed = time.time() - t0
                    print(f"✅ DICABUT! (Sisa {len(new_status.shared_users)} users, {elapsed:.2f}s)")
                    revoked_count += 1
                else:
                    print("⏭️  (Sudah tidak ada)")
                    already_absent += 1
            except Exception as e:
                print(f"❌ Error: {e}")

        print("\n" + "=" * 80)
        print(f"📊 HASIL PENCABUTAN AKSES:")
        print(f"   - Total notebook: {len(catalog)}")
        print(f"   - Berhasil dicabut: {revoked_count}")
        print(f"   - Sudah tidak ada sebelumnya: {already_absent}")
        print(f"   - Status saat ini: {REVOKE_EMAIL} TIDAK MEMILIKI AKSES ke 24 Master Notebooks.")
        print("=" * 80)

if __name__ == "__main__":
    asyncio.run(main())
