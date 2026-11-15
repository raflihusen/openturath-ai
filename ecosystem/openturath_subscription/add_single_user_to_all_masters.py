#!/usr/bin/env python3
"""
Quick Grant Single User to All 24 Pro Master Notebooks
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

async def grant_user(email: str):
    email = email.strip().lower()
    print(f"Adding {email} to all 24 Master Notebooks...")
    
    with open(CATALOG_PATH) as f:
        catalog = json.load(f)

    async with NotebookLMClient.from_storage(TARGET_STORAGE) as target:
        for idx, (cat_key, data) in enumerate(catalog.items(), 1):
            nb_id = data["notebook_id"]
            title = data["title"]
            try:
                # Add user as VIEWER
                status = await target.sharing.add_user(nb_id, email, SharePermission.VIEWER, notify=False)
                print(f"[{idx:02d}/24] ✅ {title} ({nb_id}) -> Shared with {email}")
            except Exception as e:
                print(f"[{idx:02d}/24] ⚠️ {title} ({nb_id}) -> {e}")
            await asyncio.sleep(0.5)

    print("\n✅ All 24 Master Notebooks shared with", email)

if __name__ == "__main__":
    target_email = sys.argv[1] if len(sys.argv) > 1 else "openturath@gmail.com"
    asyncio.run(grant_user(target_email))
