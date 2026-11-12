#!/usr/bin/env python3
"""
Batch Sharing 24 Master Pro Notebooks to VIPs & Customers
=========================================================
Menambahkan seluruh pelanggan aktif dan akun VIP ke dalam 24 Notebook Master
di akun Pro baru (hus180402@gmail.com) sebagai VIEWER dengan Chat Only.
"""

import asyncio
import json
import os
import sys
import time

sys.path.insert(0, '/Users/apple/Downloads/Kitab Tahawwulat RAG/.venv/lib/python3.14/site-packages')

from notebooklm import NotebookLMClient
from notebooklm.types import SharePermission

TARGET_STORAGE = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/storage_state_macbookairm1ku.json"
CATALOG_PATH = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/pro_account_master_catalog.json"
VIP_PATH = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/shared/vip_emails.json"
SUBS_REPORT = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/subscribers_report.txt"
PROGRESS_FILE = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/vip_sharing_progress.json"

async def main():
    print("=" * 80)
    print("👥 SHARING 24 MASTER PRO NOTEBOOKS KE SELURUH VIP & PELANGGAN AKTIF")
    print("=" * 80)

    # 1. Kumpulkan daftar email
    with open(VIP_PATH) as f:
        vips = set(json.load(f))

    import re
    with open(SUBS_REPORT) as f:
        subs_text = f.read()

    sub_emails = set(re.findall(r'[\w\.-]+@[\w\.-]+\.\w+', subs_text))

    target_emails = set()
    for e in vips.union(sub_emails):
        e = e.strip().lower()
        if '@' in e and not e.startswith('test-') and e != 'hus180402@gmail.com':
            # Perbaiki typo email jika ada
            if e == 'idawahidah88@gmai.com':
                continue
            target_emails.add(e)

    sorted_emails = sorted(target_emails)
    print(f"📋 Total email target: {len(sorted_emails)} akun.")

    # 2. Baca 24 Master Notebook
    with open(CATALOG_PATH) as f:
        catalog = json.load(f)

    # 3. Baca progress jika ada
    progress = {}
    if os.path.exists(PROGRESS_FILE):
        try:
            with open(PROGRESS_FILE) as f:
                progress = json.load(f)
        except Exception:
            progress = {}

    grants = [(email, SharePermission.VIEWER) for email in sorted_emails]

    async with NotebookLMClient.from_storage(TARGET_STORAGE) as target:
        for idx, (cat_key, data) in enumerate(catalog.items(), 1):
            nb_id = data["notebook_id"]
            title = data["title"]

            if cat_key in progress and progress[cat_key].get("status") == "DONE":
                print(f"[{idx:02d}/{len(catalog):02d}] ⏭️  {title} sudah di-share sebelumnya.")
                continue

            print(f"\n[{idx:02d}/{len(catalog):02d}] 🚀 Sharing {title} ({nb_id})...")
            
            for attempt in range(1, 4):
                try:
                    t0 = time.time()
                    status = await target.sharing.set_users(nb_id, grants, notify=False)
                    elapsed = time.time() - t0
                    print(f"       ✅ Sukses dibagikan ke {len(status.shared_users)} users dalam {elapsed:.2f}s!")
                    
                    progress[cat_key] = {
                        "category_key": cat_key,
                        "title": title,
                        "notebook_id": nb_id,
                        "shared_users_count": len(status.shared_users),
                        "status": "DONE",
                        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
                    }
                    with open(PROGRESS_FILE, "w") as f:
                        json.dump(progress, f, indent=2)

                    break
                except Exception as e:
                    print(f"       ⚠️ Gagal percobaan {attempt}: {e}")
                    await asyncio.sleep(2.0 * attempt)

            await asyncio.sleep(1.0)

    print("\n" + "=" * 80)
    print("🎉 SELESAI SHARING KE SELURUH VIP & PELANGGAN!")
    print(f"Laporan tersimpan di: {PROGRESS_FILE}")
    print("=" * 80)

if __name__ == "__main__":
    asyncio.run(main())
