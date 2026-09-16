"""
OpenTurath NotebookLM Manager
==============================
Layer tipis di atas notebooklm-py untuk operasi share/unshare.
Dipanggil oleh webhook_server.py dan manual_sync.py.
"""

import asyncio
import logging
import os
from typing import Any

logger = logging.getLogger(__name__)


# ─────────────────────────────────────────────
# LAZY IMPORT — hanya import jika notebooklm-py ada
# ─────────────────────────────────────────────
def _get_client():
    """Buat NotebookLM client dari storage (hasil login sebelumnya)."""
    try:
        from notebooklm import NotebookLMClient

        return NotebookLMClient
    except ImportError as e:
        raise RuntimeError(
            "notebooklm-py tidak terinstall. "
            "Jalankan: cd notebooklm-py && uv sync"
        ) from e


def _get_storage_path():
    """Dapatkan path file storage_state.json."""
    local_path = "storage_state.json"
    if os.path.exists(local_path):
        return local_path
    return None


async def _ensure_fresh_cookies():
    """Memeriksa dan merefresh cookies jika perlu menggunakan master token secara manual."""
    storage_path = "storage_state.json"
    master_token_path = "master_token.json"
    
    if not os.path.exists(master_token_path):
        return
        
    try:
        from pathlib import Path
        from notebooklm._auth.tokens import AuthTokens
        
        # Coba load (ini akan melempar ValueError jika expired)
        await AuthTokens.from_storage(Path(storage_path))
    except Exception as e:
        logger.warning("Sesi Google kedaluwarsa/belum valid. Memicu re-mint menggunakan master token...")
        try:
            from notebooklm._auth.master_token import read_master_token, mint_cookies, persist_minted_jar
            from pathlib import Path
            
            rec = read_master_token(Path(master_token_path))
            if rec:
                jar = await mint_cookies(rec["email"], rec["master_token"], rec["android_id"])
                persist_minted_jar(Path(storage_path), jar, email=rec.get("email"))
                logger.info("🎉 Berhasil memperbarui storage_state.json menggunakan master token!")
        except Exception as mint_err:
            logger.error("Gagal re-mint cookies: %s", mint_err)


# ─────────────────────────────────────────────
# ADD VIEWER
# ─────────────────────────────────────────────
async def add_viewer(notebook_id: str, email: str, user_name: str = "") -> dict[str, Any]:
    """
    Tambahkan email sebagai Viewer ke notebook NotebookLM.

    Args:
        notebook_id: ID notebook dari URL NotebookLM
        email: Email pelanggan yang baru bayar
        user_name: Nama pelanggan (untuk log)

    Returns:
        dict dengan success/error dan detail
    """
    await _ensure_fresh_cookies()
    NotebookLMClient = _get_client()
    storage_path = _get_storage_path()

    try:
        async with NotebookLMClient.from_storage(path=storage_path) as client:
            from notebooklm.rpc.types import SharePermission, ShareViewLevel

            status = await client.sharing.add_user(
                notebook_id=notebook_id,
                email=email,
                permission=SharePermission.VIEWER,
                notify=False,
            )
            # Batasi viewer hanya bisa chat (CHAT_ONLY), hilangkan akses untuk membaca/menyalin database source dokumen
            await client.sharing.set_view_level(
                notebook_id=notebook_id,
                level=ShareViewLevel.CHAT_ONLY,
            )

        logger.info(
            "✅ Berhasil tambah viewer | email=%s | notebook=%s | total_viewers=%d",
            email,
            notebook_id[:20],
            len(status.shared_users),
        )
        return {
            "success": True,
            "action": "add_viewer",
            "email": email,
            "notebook_id": notebook_id,
            "total_shared_users": len(status.shared_users),
        }

    except Exception as e:
        logger.exception("❌ Gagal tambah viewer %s: %s", email, e)
        return {
            "success": False,
            "action": "add_viewer",
            "email": email,
            "error": str(e),
        }


# ─────────────────────────────────────────────
# REMOVE VIEWER
# ─────────────────────────────────────────────
async def remove_viewer(notebook_id: str, email: str) -> dict[str, Any]:
    """
    Cabut akses email dari notebook NotebookLM.

    Args:
        notebook_id: ID notebook dari URL NotebookLM
        email: Email pelanggan yang sudah expired

    Returns:
        dict dengan success/error dan detail
    """
    await _ensure_fresh_cookies()
    NotebookLMClient = _get_client()
    storage_path = _get_storage_path()

    try:
        async with NotebookLMClient.from_storage(path=storage_path) as client:
            from notebooklm.rpc.types import ShareViewLevel
            status = await client.sharing.remove_user(
                notebook_id=notebook_id,
                email=email,
            )
            # Kunci paten: Selalu pastikan status tetap RESTRICTED & CHAT_ONLY setelah pencabutan user
            await client.sharing.set_public(notebook_id, False)
            await client.sharing.set_view_level(
                notebook_id=notebook_id,
                level=ShareViewLevel.CHAT_ONLY,
            )

        logger.info(
            "✅ Berhasil hapus viewer | email=%s | notebook=%s | total_viewers=%d",
            email,
            notebook_id[:20],
            len(status.shared_users),
        )
        return {
            "success": True,
            "action": "remove_viewer",
            "email": email,
            "notebook_id": notebook_id,
            "total_shared_users": len(status.shared_users),
        }

    except Exception as e:
        logger.exception("❌ Gagal hapus viewer %s: %s", email, e)
        return {
            "success": False,
            "action": "remove_viewer",
            "email": email,
            "error": str(e),
        }


# ─────────────────────────────────────────────
# LIST VIEWERS (untuk audit/dashboard)
# ─────────────────────────────────────────────
async def list_viewers(notebook_id: str) -> list[dict[str, str]]:
    """Daftar semua email yang punya akses ke notebook."""
    await _ensure_fresh_cookies()
    NotebookLMClient = _get_client()
    storage_path = _get_storage_path()

    async with NotebookLMClient.from_storage(path=storage_path) as client:
        status = await client.sharing.get_status(notebook_id)

    return [
        {
            "email": u.email,
            "name": u.display_name or "",
            "permission": u.permission.name,
        }
        for u in status.shared_users
    ]


# ─────────────────────────────────────────────
# TEST KONEKSI
# ─────────────────────────────────────────────
async def test_connection(notebook_id: str) -> dict[str, Any]:
    """Test apakah login dan koneksi ke NotebookLM berjalan dengan baik."""
    await _ensure_fresh_cookies()
    NotebookLMClient = _get_client()
    storage_path = _get_storage_path()

    try:
        async with NotebookLMClient.from_storage(path=storage_path) as client:
            status = await client.sharing.get_status(notebook_id)

        return {
            "success": True,
            "notebook_id": notebook_id,
            "is_public": status.is_public,
            "total_shared_users": len(status.shared_users),
            "shared_users": [u.email for u in status.shared_users],
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


if __name__ == "__main__":
    # Quick test
    import sys

    notebook_id = os.getenv("TEST_NOTEBOOK_ID", "")
    if not notebook_id:
        print("Set TEST_NOTEBOOK_ID environment variable terlebih dahulu.")
        sys.exit(1)

    result = asyncio.run(test_connection(notebook_id))
    print(result)
