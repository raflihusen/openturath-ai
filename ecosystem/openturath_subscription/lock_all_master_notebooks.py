#!/usr/bin/env python3
"""
Lock All 24 Master Pro Notebooks to RESTRICTED (is_public: False)
=================================================================
Mengunci seluruh 24 Master Pro Notebook agar TIDAK BISA diakses oleh siapapun
yang memiliki tautan (Anyone with link dimatikan).
Hanya akun yang secara eksplisit di-share (shared_users) yang bisa mengakses.
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

TARGET_STORAGE = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/storage_state_macbookairm1ku.json"
CATALOG_PATH = "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/pro_account_master_catalog.json"

async def main():
    print("=" * 80)
    print("🔒 MENGUNCI 24 MASTER PRO NOTEBOOKS (RESTRICTED / PUBLIC = FALSE)")
    print("=" * 80)

    with open(CATALOG_PATH) as f:
        catalog = json.load(f)

    async with NotebookLMClient.from_storage(TARGET_STORAGE) as target:
        account_email = await target.get_account_email()
        print(f"Akun Pemilik Aktif: {account_email}")

        locked_count = 0
        for idx, (cat_key, data) in enumerate(catalog.items(), 1):
            nb_id = data["notebook_id"]
            title = data["title"]
            print(f"[{idx:02d}/{len(catalog):02d}] Mengunci {title} ({nb_id})...", end=" ", flush=True)

            try:
                # 1. Matikan akses publik
                await target.sharing.set_public(nb_id, False)

                # 2. Kunci ke CHAT_ONLY
                await target.sharing.set_view_level(nb_id, ShareViewLevel.CHAT_ONLY)

                # 3. Kunci agar tidak bisa di-copy
                # Rename / mutation RPC
                mut_copy = [None, None, None, [None, None, None, None, 1]] # requiredCopyRole=1 (owner only)
                mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                await target.rpc_call(RPCMethod.RENAME_NOTEBOOK, [nb_id, [mut_copy, mut_chat]], allow_null=True)

                # Verifikasi status
                verify_status = await target.sharing.get_status(nb_id)
                if not verify_status.is_public:
                    print(f"✅ TERKUNCI RAPAT! (Public: False, Users: {len(verify_status.shared_users)})")
                    locked_count += 1
                else:
                    print(f"⚠️ Masih public!")
            except Exception as e:
                print(f"❌ Error: {e}")

        print("\n" + "=" * 80)
        print(f"📊 HASIL PENGUNCIAN: {locked_count}/{len(catalog)} notebook berhasil dikunci total!")
        print("=" * 80)

if __name__ == "__main__":
    asyncio.run(main())
