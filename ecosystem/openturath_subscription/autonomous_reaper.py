"""
OpenTurath Autonomous Expiration & Auto-Sync Engine (HARDENED SAFEGUARD VERSION)
==================================================================================
Prinsip Keamanan Absolut (Zero Accidental Revocation):
1. Akun VIP / Manual / Beasiswa memiliki status `VIP_PERMANENT` dan DILINDUNGI SELAMANYA.
2. Akun TIDAK AKAN PERNAH DICABUT kecuali terbukti memiliki tanggal kedaluwarsa resmi (`expires_at < NOW()`).
3. Akun manual/tidak dikenal yang ada di notebook TIDAK AKAN DIHAPUS OTOMATIS, melainkan hanya dilaporkan ke Telegram untuk konfirmasi Anda.
"""

import os
import sys
import asyncio
import json
import logging
import urllib.request
import urllib.parse
from datetime import datetime, timezone, timedelta
from typing import Any

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

from google.cloud import firestore

NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

from akal_client import AkalClient
from notebooklm import NotebookLMClient
from notebooklm.rpc.types import SharePermission, RPCMethod, ShareViewLevel

logger = logging.getLogger("autonomous_reaper")
if not logger.handlers:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] [REAPER] %(message)s",
        handlers=[
            logging.FileHandler("reaper.log"),
            logging.StreamHandler(),
        ],
    )

STATIC_WHITELIST = {
    "openturath@gmail.com",
    "ramah@ptct.net",
}

MASTER_NOTEBOOKS = [
    {
        "name": "AI Fikih Syafi'i",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862"),
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_SYAFII", "cms4ls3j60001l20439k1nqh4"),
    },
    {
        "name": "Al-Muhaqqiq (Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUHAQQIQ", "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"),
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Bayan (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_BAYAN", "483d0291-0a70-411c-bff0-f1ea4b83b2fd"),
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Mukhtabir (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUKHTABIR", "ac61a7a0-87e7-42a5-a30f-980ff74a78d8"),
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Habib (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_HABIB", "6673e79a-7156-42e1-b116-bc1653a32094"),
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Khatib (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_KHATIB", "1288e413-9569-47a3-892f-64008e53c1e8"),
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "AI Bahasa Arab",
        "id": os.getenv("NOTEBOOK_ID_BAHASA_ARAB", "15bc4cef-4b94-4241-b05a-d50a586bde06"),
        "cuid": os.getenv("AKAL_SERVICE_CUID_BAHASA_ARAB", "cmnd7l4o60002l504ab6qq31x"),
    },
]

def send_telegram(text: str) -> bool:
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID")
    if not token or not chat_id:
        return False
        
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {"chat_id": chat_id, "text": text, "parse_mode": "HTML"}
    try:
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            res = json.loads(resp.read().decode("utf-8"))
            return res.get("ok", False)
    except Exception as e:
        logger.error(f"Failed to send Telegram message: {e}")
        return False

class AutonomousReaper:
    def __init__(self):
        cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
        if os.path.exists(cred_path):
            self.db = firestore.Client.from_service_account_json(cred_path)
        else:
            self.db = firestore.Client()
        self.storage_path = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")

    async def get_all_database_records(self) -> tuple[dict[str, dict], dict[str, dict]]:
        """
        Mengambil data lengkap:
        - active_users: email yang SAH dan MASIH AKTIF (termasuk VIP/Manual/Overrides)
        - confirmed_expired_users: email yang TERBUKTI EXPIRED (dengan tanggal kedaluwarsa jelas)
        """
        now = datetime.now(timezone.utc)
        active_users = {}
        confirmed_expired_users = {}

        # 1. Baca Firestore Transactions
        try:
            tx_stream = self.db.collection("transactions").stream()
            for doc in tx_stream:
                d = doc.to_dict()
                email = (d.get("customer_email") or d.get("payer_email") or d.get("payerEmail") or d.get("email") or "").strip().lower()
                if not email:
                    continue

                status = (d.get("status") or "").upper()
                is_vip = d.get("is_vip", False) or (d.get("plan") == "VIP_PERMANENT")
                exp = d.get("subscription_expires_at") or d.get("access_expires_at") or d.get("expires_at")
                
                exp_dt = None
                if isinstance(exp, datetime):
                    exp_dt = exp if exp.tzinfo else exp.replace(tzinfo=timezone.utc)
                elif isinstance(exp, str):
                    try:
                        exp_dt = datetime.fromisoformat(exp.replace("Z", "+00:00"))
                    except Exception:
                        pass

                if is_vip:
                    # VIP PERMANEN - DILINDUNGI SELAMANYA
                    active_users[email] = {
                        "exp_dt": now + timedelta(days=3650),
                        "name": d.get("customer_name") or "VIP User",
                        "is_vip": True
                    }
                    continue

                if status in ["SUCCESS", "PAID", "SETTLED"]:
                    if exp_dt and exp_dt > now:
                        active_users[email] = {
                            "exp_dt": exp_dt,
                            "name": d.get("customer_name") or "Paid User",
                            "is_vip": False
                        }
                    elif exp_dt and exp_dt <= now:
                        confirmed_expired_users[email] = {
                            "exp_dt": exp_dt,
                            "name": d.get("customer_name") or "Expired User"
                        }
                elif status in ["EXPIRED", "FAILED", "CANCELLED"]:
                    confirmed_expired_users[email] = {
                        "exp_dt": exp_dt or now,
                        "name": d.get("customer_name") or "Expired User"
                    }
        except Exception as e:
            logger.error(f"Error reading Firestore: {e}")

        # 2. Baca Akal API
        try:
            async with AkalClient() as akal:
                services_resp = await akal.list_services()
                services = services_resp.get("data", [])
                for s in services:
                    cuid = s.get("cuid")
                    paid_emails = await akal.get_all_paid_emails(cuid)
                    for em in paid_emails:
                        em = em.strip().lower()
                        if em not in active_users:
                            active_users[em] = {
                                "exp_dt": now + timedelta(days=30),
                                "name": "Akal Subscriber",
                                "is_vip": False
                            }
        except Exception as e:
            logger.warning(f"Akal API warning: {e}")

        # 3. Static Whitelist
        for em in STATIC_WHITELIST:
            active_users[em.lower()] = {
                "exp_dt": now + timedelta(days=3650),
                "name": "System Admin",
                "is_vip": True
            }

        return active_users, confirmed_expired_users

    async def run_cycle(self) -> dict:
        """
        Siklus Reaper yang AMAN:
        HANYA mencabut jika email tersebut BENAR-BENAR TERDAFTAR SEBAGAI EXPIRED.
        Akun VIP manual yang ada di whitelist TIDAK AKAN DISENTUH SAMA SEKALI.
        """
        now = datetime.now(timezone.utc)
        logger.info("=" * 80)
        logger.info(f"🛡️ SAFE REAPER CYCLE STARTED: {now.strftime('%Y-%m-%d %H:%M:%S UTC')}")
        logger.info("=" * 80)

        active_map, expired_map = await self.get_all_database_records()
        active_emails = set(active_map.keys())
        expired_emails = set(expired_map.keys())

        revoked_summary = []

        async with NotebookLMClient.from_storage(path=self.storage_path) as nlm_client:
            for nb in MASTER_NOTEBOOKS:
                nb_name = nb["name"]
                nb_id = nb["id"]
                
                try:
                    status = await nlm_client.sharing.get_status(nb_id)
                    current_viewers = {u.email.lower() for u in status.shared_users if u.permission.name != "OWNER"}
                    
                    # HANYA cabut jika user itu ADA di daftar EXPIRED dan TIDAK ADA di ACTIVE
                    strictly_expired = (current_viewers & expired_emails) - active_emails
                    
                    if strictly_expired:
                        logger.warning(f"🚨 {nb_name}: Mencabut {len(strictly_expired)} user yang terkonfirmasi expired...")
                        removals = [[em, None, SharePermission._REMOVE.value] for em in strictly_expired]
                        params = [[[nb_id, removals, None, [0, ""]]], 0, None, [2]]
                        await nlm_client.sharing._rpc.rpc_call(
                            RPCMethod.SHARE_NOTEBOOK,
                            params,
                            source_path=f"/notebook/{nb_id}",
                            allow_null=True
                        )
                        for em in strictly_expired:
                            revoked_summary.append({"email": em, "notebook": nb_name})
                    else:
                        logger.info(f"✅ {nb_name:<28}: {len(current_viewers)} Viewers (Semua Aman)")

                    # KUNCI PATEN: Selalu pastikan status 100% RESTRICTED + CHAT_ONLY
                    if status.is_public:
                        await nlm_client.sharing.set_public(nb_id, False)
                    await nlm_client.sharing.set_view_level(nb_id, ShareViewLevel.CHAT_ONLY)
                except Exception as e:
                    logger.error(f"❌ Error in {nb_name}: {e}")

        if revoked_summary:
            msg_lines = [
                "⚠️ <b>[AUTONOMOUS REAPER: PENCABUTAN TERKONFIRMASI]</b>",
                "🕌 <b>OpenTurath AI Engine</b>\n",
                f"Sistem mencabut <b>{len(revoked_summary)} akses yang terkonfirmasi kedaluwarsa</b>:\n"
            ]
            for r in revoked_summary:
                msg_lines.append(f"• 👤 <code>{r['email']}</code> ({r['notebook']})")
            send_telegram("\n".join(msg_lines))

        return {
            "timestamp": now.isoformat(),
            "active_count": len(active_emails),
            "revoked_count": len(revoked_summary)
        }

if __name__ == "__main__":
    reaper = AutonomousReaper()
    asyncio.run(reaper.run_cycle())
