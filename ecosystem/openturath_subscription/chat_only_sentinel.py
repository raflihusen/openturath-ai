"""
OpenTurath Strict Security Guard & Chat-Only Enforcer
======================================================
1. Menjaga notebook 100% RESTRICTED (is_public=False) -> User expired/luar DIBLOKIR TOTAL.
2. Mengunci view_level ke CHAT_ONLY -> Viewer TIDAK BISA klik/buka/copy isi teks sumber.
"""

import os
import sys
import asyncio
import logging

NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

from notebooklm import NotebookLMClient
from notebooklm.rpc.types import ShareViewLevel

logger = logging.getLogger("security_guard")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [SECURITY] %(message)s",
    handlers=[
        logging.FileHandler("security_guard.log"),
        logging.StreamHandler(),
    ],
)

import shared_registry

PROTECTED_NOTEBOOKS = [
    {"name": f"{nb.get('entity', scope)} (Master)", "id": nb["master"]}
    for scope, info in shared_registry.catalog().get("scopes", {}).items()
    for nb in info.get("notebooks", [])
    if nb.get("master")
]

CHECK_INTERVAL_SECONDS = 60

async def enforce_restricted_and_chat_only(client: NotebookLMClient, notebook_id: str, name: str):
    try:
        status = await client.sharing.get_status(notebook_id)
        # Kunci paten: Wajib RESTRICTED (is_public = False) agar hanya email terdaftar yang bisa akses
        if status.is_public:
            logger.warning(f"🚨 Public link detected on {name}! Forcing RESTRICTED...")
            await client.sharing.set_public(notebook_id, False)
            
        # Selalu kunci view_level ke CHAT_ONLY
        await client.sharing.set_view_level(notebook_id, ShareViewLevel.CHAT_ONLY)
    except Exception as e:
        logger.error(f"❌ Error on {name}: {e}")

async def main():
    logger.info("=" * 80)
    logger.info("🛡️ OPENTURATH RESTRICTED + CHAT-ONLY WATCHDOG ACTIVE")
    logger.info("=" * 80)
    
    storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
    if not os.path.exists(storage_path):
        storage_path = "/Users/apple/Downloads/ramadhan/openturath_subscription/storage_state.json"

    while True:
        try:
            async with NotebookLMClient.from_storage(path=storage_path) as client:
                for nb in PROTECTED_NOTEBOOKS:
                    await enforce_restricted_and_chat_only(client, nb["id"], nb["name"])
        except Exception as e:
            logger.error(f"❌ Guard error: {e}")
        await asyncio.sleep(CHECK_INTERVAL_SECONDS)

if __name__ == "__main__":
    asyncio.run(main())
