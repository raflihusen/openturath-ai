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

PROTECTED_NOTEBOOKS = [
    {"name": "Al-Muhaqqiq (Tahawwulat)", "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"},
    {"name": "Al-Bayan (Tahawwulat)", "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd"},
    {"name": "Al-Mukhtabir (Tahawwulat)", "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8"},
    {"name": "Al-Habib (Tahawwulat)", "id": "6673e79a-7156-42e1-b116-bc1653a32094"},
    {"name": "Al-Khatib (Tahawwulat)", "id": "1288e413-9569-47a3-892f-64008e53c1e8"},
    {"name": "AI Fikih Syafi'i", "id": "334e7b83-0e76-4787-a1d6-314642a35862"},
    {"name": "AI Bahasa Arab", "id": "15bc4cef-4b94-4241-b05a-d50a586bde06"},
]

CHECK_INTERVAL_SECONDS = 60

async def enforce_restricted_and_chat_only(client: NotebookLMClient, notebook_id: str, name: str):
    try:
        status = await client.sharing.get_status(notebook_id)
        # Jika publik atau bukan restricted, paksa restricted
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
