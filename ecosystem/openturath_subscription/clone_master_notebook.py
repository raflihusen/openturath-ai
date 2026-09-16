"""
OpenTurath AI Master Notebook Auto-Cloner & Source Duplicator
=============================================================
Skrip untuk melakukan KLONING UTUH 100% (Notebook + Seluruh Isi File Sources)
dari Notebook Master ke Notebook Node Klone baru untuk Skalabilitas 10.000 User.
"""

import os
import sys
import asyncio
import logging

NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

def load_dotenv():
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" in line:
                    key, val = line.split("=", 1)
                    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                        val = val[1:-1]
                        os.environ[key] = val

load_dotenv()

import notebooklm_manager as nlm
from notebooklm.rpc.types import ShareViewLevel

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("auto_cloner")

async def clone_notebook_with_all_sources(master_id: str, clone_title: str, max_sources: int = 50) -> dict:
    """
    Membuat Notebook Node baru dan menyalin seluruh isi source dari Master Notebook.
    """
    await nlm._ensure_fresh_cookies()
    NotebookLMClient = nlm._get_client()
    storage_path = os.path.join(os.path.dirname(__file__), "storage_state.json")
    if not os.path.exists(storage_path):
        storage_path = nlm._get_storage_path()
        
    logger.info("🚀 Memulai proses kloning utuh dari Master ID: %s", master_id)
    
    async with NotebookLMClient.from_storage(path=storage_path) as client:
        # 1. Buat Notebook Klone Baru
        new_nb = await client.notebooks.create(clone_title)
        clone_id = getattr(new_nb, 'id', getattr(new_nb, 'notebook_id', None))
        logger.info("✅ Notebook Klone berhasil dibuat! Title: '%s' | ID: %s", clone_title, clone_id)
        
        # 2. Ambil daftar source dari Master Notebook
        master_sources = await client.sources.list(master_id)
        logger.info("📚 Ditemukan %d file/sumber pada Master Notebook.", len(master_sources))
        
        copied_count = 0
        failed_count = 0
        total_chars = 0
        
        # Copy all sources without cap if max_sources is None or 0
        sources_to_copy = master_sources if not max_sources else master_sources[:max_sources]
        
        for i, src in enumerate(sources_to_copy, 1):
            src_title = getattr(src, 'title', None) or getattr(src, 'name', f'Source_{i}')
            src_id = getattr(src, 'id', None)
            
            logger.info("[%d/%d] Menyalin source: '%s'...", i, len(sources_to_copy), src_title[:40])
            try:
                ft_obj = await client.sources.get_fulltext(master_id, src_id)
                text_content = getattr(ft_obj, 'text', str(ft_obj))
                
                if text_content and len(text_content) > 0:
                    await client.sources.add_text(
                        notebook_id=clone_id,
                        title=src_title,
                        content=text_content
                    )
                    copied_count += 1
                    total_chars += len(text_content)
                    logger.info("    -> Success! (%d karakter)", len(text_content))
                else:
                    logger.warning("    -> Skip: Teks kosong")
            except Exception as e:
                failed_count += 1
                logger.error("    -> Gagal menyalin '%s': %s", src_title[:30], e)
                
            # Sleep sebentar untuk menjaga rate limit
            await asyncio.sleep(0.5)
            
        # 3. Kunci View Level ke CHAT_ONLY
        logger.info("🔒 Mengunci proteksi notebook ke CHAT_ONLY...")
        await client.sharing.set_view_level(notebook_id=clone_id, level=ShareViewLevel.CHAT_ONLY)
        logger.info("✅ Proteksi CHAT_ONLY berhasil diterapkan!")
        
        return {
            "success": True,
            "master_id": master_id,
            "clone_id": clone_id,
            "clone_title": clone_title,
            "clone_url": f"https://notebooklm.google.com/notebook/{clone_id}",
            "copied_sources": copied_count,
            "failed_sources": failed_count,
            "total_characters": total_chars
        }

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Penggunaan: python3 clone_master_notebook.py <MASTER_NOTEBOOK_ID> <JUDUL_KLONE_BARU> [MAX_SOURCES]")
        sys.exit(1)
        
    m_id = sys.argv[1]
    title = sys.argv[2]
    max_src = int(sys.argv[3]) if len(sys.argv) > 3 else 50
    
    res = asyncio.run(clone_notebook_with_all_sources(m_id, title, max_src))
    print("\n=== HASIL AKHIR KLONING UTUH ===")
    import json
    print(json.dumps(res, indent=2))
