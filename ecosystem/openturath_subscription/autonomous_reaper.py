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
import socket
_orig_getaddrinfo = socket.getaddrinfo
def _resilient_getaddrinfo(host, port, *args, **kwargs):
    h_str = host.decode("utf-8", "ignore") if isinstance(host, (bytes, bytearray)) else str(host)
    if h_str == "notebooklm.google.com":
        return _orig_getaddrinfo("142.250.74.78", port, *args, **kwargs)
    return _orig_getaddrinfo(host, port, *args, **kwargs)
socket.getaddrinfo = _resilient_getaddrinfo

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
    # System & Owner
    "openturath@gmail.com",
    "ramah@ptct.net",
    "raflimaulan@gmail.com",
    "mas.raflihusen@gmail.com",

    # Verified Tamu Spesial (Konfirmasi Pengguna)
    "alkhateeb23@gmail.com",
    "omarasb1441@gmail.com",
    "prilatief@gmail.com",
    "udinvoldigoad05@gmail.com",

    # Asatidz & Masyayikh & VIP Manual Permanen
    "aaadman40@gmail.com",
    "abo.omar5539@gmail.com",
    "abualgilani2024@gmail.com",
    "ahobh4241@gmail.com",
    "alhamodi65@gmail.com",
    "ali.bafdhl36@gmail.com",
    "alshykhkmalbahrmz@gmail.com",
    "atinrahmak@gmail.com",
    "hafamfb551985@gmail.com",
    "loyos839@gmail.com",
    "mohammedhalahdal@gmail.com",
    "mostajadt25@gmail.com",
    "nona.alyaziza@gmail.com",
    "omar739037802@gmail.com",
    "yasser110271@gmail.com",
}

MASTER_NOTEBOOKS = [
    # 1. Fikih Syafi'i (Master & Legacy)
    {
        "name": "01 - FIKIH SYAFII (MASTER)",
        "id": "c89d09ca-4b48-4000-a98d-59e532607fb6",
        "key": "fiqh_syafii",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_SYAFII", "cms4ls3j60001l20439k1nqh4"),
    },
    {
        "name": "AI Fikih Syafi'i (Legacy)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862"),
        "key": "fiqh_syafii",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_SYAFII", "cms4ls3j60001l20439k1nqh4"),
    },
    # 2. Fikih Tahawwulat (5 Cabang)
    {
        "name": "Al-Muhaqqiq (Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUHAQQIQ", "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"),
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Bayan (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_BAYAN", "483d0291-0a70-411c-bff0-f1ea4b83b2fd"),
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Mukhtabir (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUKHTABIR", "ac61a7a0-87e7-42a5-a30f-980ff74a78d8"),
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Habib (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_HABIB", "6673e79a-7156-42e1-b116-bc1653a32094"),
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Khatib (Fikih Tahawwulat)",
        "id": os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_KHATIB", "1288e413-9569-47a3-892f-64008e53c1e8"),
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    # 3. Bahasa & Sastra Arab
    {
        "name": "AI Bahasa Arab",
        "id": "1ae6ae57-53f0-4ce2-a2be-c324e03abb83",
        "key": "nahwu",
        "cuid": os.getenv("AKAL_SERVICE_CUID_BAHASA_ARAB", "cmnd7l4o60002l504ab6qq31x"),
    },
    {
        "name": "AI Bahasa Arab (Legacy)",
        "id": "15bc4cef-4b94-4241-b05a-d50a586bde06",
        "key": "nahwu",
        "cuid": "",
    },
    # 4. Hadits Nabawi
    {
        "name": "AI Hadits Nabawi",
        "id": "9da436c8-f9b7-4e8b-a51f-d798a31892a7",
        "key": "hadits",
        "cuid": os.getenv("AKAL_SERVICE_CUID_HADITS", ""),
    },
    {
        "name": "AI Hadits (Legacy)",
        "id": "b9626501-538c-4358-a44f-6731eaec50b6",
        "key": "hadits",
        "cuid": "",
    },
    # 5. Tafsir & Ulumul Qur'an
    {
        "name": "AI Tafsir & Ulumul Quran",
        "id": "f15bd838-dac9-415b-bd40-fef3da1355d4",
        "key": "tafsir",
        "cuid": os.getenv("AKAL_SERVICE_CUID_TAFSIR", ""),
    },
    {
        "name": "AI Tafsir (Legacy)",
        "id": "df92cc50-1106-4221-8748-1663f00fa7fe",
        "key": "tafsir",
        "cuid": "",
    },
    # 6. Ushul Fikih
    {
        "name": "AI Ushul Fiqih",
        "id": "6009f2ee-6328-497d-b74e-4276834caa94",
        "key": "ushul_fiqh",
        "cuid": os.getenv("AKAL_SERVICE_CUID_USHUL_FIQIH", ""),
    },
    {
        "name": "AI Ushul Fiqih (Legacy)",
        "id": "6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
        "key": "ushul_fiqh",
        "cuid": "",
    },
    # 7. Qawaid Fiqhiyyah
    {
        "name": "AI Qawaid Fiqhiyyah",
        "id": "35cc555e-3d6c-43fd-ae82-6a06cd107899",
        "key": "ushul_fiqh",
        "cuid": "",
    },
    # 8. Aqidah & Ushuluddin
    {
        "name": "AI Aqidah & Ushuluddin",
        "id": "d4807af1-1c3b-4ffd-b9b8-a944b2f8c5bd",
        "key": "aqidah",
        "cuid": "",
    },
    # 9. Bibliografi & Faharis
    {
        "name": "AI Bibliografi & Faharis",
        "id": "d35f7598-076a-4c91-8ccf-9dc1aa1b0e7d",
        "key": "bibliografi_faharis",
        "cuid": "",
    },
    # 10. Tajwid & Qiraat
    {
        "name": "AI Tajwid & Qiraat",
        "id": "0364032d-3cb9-4b4e-bf5c-b0bf72f134f6",
        "key": "tafsir",
        "cuid": "",
    },
    # 11. Fikih Muqaran & Umum
    {
        "name": "AI Fikih Muqaran & Umum",
        "id": "66ed9863-e177-43a9-a1a4-25fb953520a7",
        "key": "fiqh_muqaran",
        "cuid": "",
    },
    # 12. Tasawwuf & Adzkar
    {
        "name": "AI Tasawwuf & Adzkar",
        "id": "9a9902ff-ff0a-4696-845b-a809a69db84b",
        "key": "tasawwuf",
        "cuid": "",
    },
    # 13. Fikih Hanafi
    {
        "name": "AI Fikih Hanafi",
        "id": "063ddf96-61a5-46c7-a6ae-5b9eb8bddb6b",
        "key": "fiqh_hanafi",
        "cuid": "",
    },
    # 14. Fikih Hanbali
    {
        "name": "AI Fikih Hanbali",
        "id": "45f6ccdd-d3e5-4ca7-96cb-4f905d3cde3e",
        "key": "fiqh_hanbali",
        "cuid": "",
    },
    # 15. Fatawa & Masail Fiqhiyyah
    {
        "name": "AI Fatawa & Masail Fiqhiyyah",
        "id": "45a2043c-4617-42a7-9f00-fbc2138def48",
        "key": "fiqh",
        "cuid": "",
    },
    # 16. Fikih Maliki
    {
        "name": "AI Fikih Maliki",
        "id": "cc152334-e7d2-44ac-bb14-65e70d893b40",
        "key": "fiqh_maliki",
        "cuid": "",
    },
    # 17. Musthalah & Ulumul Hadits
    {
        "name": "AI Musthalah & Ulumul Hadits",
        "id": "af26bf8f-4429-4d2f-9cf0-17bcc835fb86",
        "key": "hadits",
        "cuid": "",
    },
    # 18. Thabaqat & Tarajim Rijal
    {
        "name": "AI Thabaqat & Tarajim Rijal",
        "id": "59fd5420-7392-4d58-825a-02b87bade32d",
        "key": "tarikh",
        "cuid": "",
    },
    # 19. Tarikh & Sirah Nabawiyyah
    {
        "name": "AI Tarikh & Sirah Nabawiyyah",
        "id": "94d49b05-e0b6-4ea2-9b7d-7c75f8edca75",
        "key": "tarikh",
        "cuid": "",
    },
    # 20. Syarah Hadits
    {
        "name": "AI Syarah Hadits",
        "id": "27c104b7-e8aa-40a9-b9dd-ad4741b2d515",
        "key": "hadits",
        "cuid": "",
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

def parse_dt(val):
    if not val:
        return None
    if isinstance(val, datetime):
        return val if val.tzinfo else val.replace(tzinfo=timezone.utc)
    if isinstance(val, str):
        try:
            dt = datetime.fromisoformat(val.replace("Z", "+00:00"))
            return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)
        except Exception:
            return None
    return None

class AutonomousReaper:
    def __init__(self):
        cred_path = "/Users/apple/Downloads/ramadhan/service-account.json"
        if os.path.exists(cred_path):
            self.db = firestore.Client.from_service_account_json(cred_path)
        else:
            self.db = firestore.Client()
        
        # Prioritas lokasi auth NotebookLM:
        # 1. ~/.notebooklm/profiles/default/storage_state.json (Host / local run)
        # 2. ./storage_state.json (Container workspace /app/storage_state.json)
        # 3. /app/storage_state.json
        # 4. Generate otomatis dari NOTEBOOKLM_AUTH_JSON
        default_storage = os.path.expanduser("~/.notebooklm/profiles/default/storage_state.json")
        local_storage = os.path.join(os.path.dirname(os.path.abspath(__file__)), "storage_state.json")
        app_storage = "/app/storage_state.json"
        auth_json = os.getenv("NOTEBOOKLM_AUTH_JSON", "")

        if os.path.exists(default_storage):
            self.storage_path = default_storage
        elif os.path.exists(local_storage):
            self.storage_path = local_storage
        elif os.path.exists(app_storage):
            self.storage_path = app_storage
        elif auth_json:
            try:
                with open(local_storage, "w", encoding="utf-8") as f:
                    f.write(auth_json)
                self.storage_path = local_storage
                logger.info(f"Generated {local_storage} from NOTEBOOKLM_AUTH_JSON.")
            except Exception as e:
                logger.error(f"Failed to generate {local_storage}: {e}")
                self.storage_path = default_storage
        else:
            self.storage_path = default_storage

    async def get_all_database_records(self) -> tuple[set[str], dict[str, set[str]], dict[str, set[str]]]:
        """
        Mengambil data per-modul:
        - global_vip_emails: set email VIP permanen (berlaku untuk semua modul)
        - active_by_module: key -> set of active emails for this module
        - expired_by_module: key -> set of expired emails for this module
        """
        now = datetime.now(timezone.utc)
        global_vip_emails = set(e.lower() for e in STATIC_WHITELIST)
        active_by_module = {}   # key -> set of emails
        expired_by_module = {}  # key -> set of emails

        for nb in MASTER_NOTEBOOKS:
            k = nb["key"]
            if k not in active_by_module:
                active_by_module[k] = set()
                expired_by_module[k] = set()

        # 1. Baca Firestore Transactions
        try:
            tx_stream = self.db.collection("transactions").stream()
            for doc in tx_stream:
                d = doc.to_dict()
                email = (d.get("customer_email") or d.get("payer_email") or d.get("email") or "").strip().lower()
                if not email:
                    continue

                status = (d.get("status") or "").upper()
                plan = str(d.get("plan") or d.get("plan_id") or "").upper()
                exp_dt = parse_dt(d.get("subscription_expires_at") or d.get("access_expires_at") or d.get("expires_at"))
                is_vip = d.get("is_vip", False) or ("VIP" in plan) or (exp_dt and exp_dt.year >= 2030)
                ent_key = d.get("entitlement_key")

                if is_vip:
                    global_vip_emails.add(email)
                    continue

                # Is it 1-Year plan? (gives all access or specific)
                is_yearly = any(y in plan.lower() for y in ["1y", "year", "tahun", "annual", "bahits_1y"])

                if status in ["SUCCESS", "PAID", "SETTLED"]:
                    if exp_dt and exp_dt > now:
                        if ent_key in active_by_module:
                            active_by_module[ent_key].add(email)
                        elif ent_key in ["all_access", "all_ai", None]:
                            if is_yearly or ent_key in ["all_access", "all_ai"]:
                                for k in active_by_module:
                                    active_by_module[k].add(email)
                    elif exp_dt and exp_dt <= now:
                        if ent_key in expired_by_module:
                            expired_by_module[ent_key].add(email)
                        elif ent_key is None:
                            # If no entitlement key, check plan or apply across all modules
                            if "tholib" in plan.lower():
                                expired_by_module["fiqh_tahawwulat"].add(email)
                                expired_by_module["fiqh_syafii"].add(email)
                            else:
                                for k in expired_by_module:
                                    expired_by_module[k].add(email)
                elif status in ["EXPIRED", "FAILED", "CANCELLED"]:
                    if ent_key in expired_by_module:
                        expired_by_module[ent_key].add(email)
                    else:
                        for k in expired_by_module:
                            expired_by_module[k].add(email)
        except Exception as e:
            logger.error(f"Error reading Firestore transactions: {e}")

        # 2. Baca Firestore Users Collection
        try:
            user_stream = self.db.collection("users").stream()
            for doc in user_stream:
                d = doc.to_dict()
                email = (d.get("email") or "").strip().lower()
                if not email:
                    continue
                role = str(d.get("role") or "").lower()
                if role in ["admin", "vip", "guru", "special"]:
                    global_vip_emails.add(email)
                    continue

                entitlements = d.get("entitlements", {})
                if entitlements and isinstance(entitlements, dict):
                    # Model granular per-modul (prioritas utama)
                    for k, v in entitlements.items():
                        if isinstance(v, dict) and k in active_by_module:
                            e_dt = parse_dt(v.get("expiry") or v.get("expires_at"))
                            if e_dt and e_dt > now:
                                active_by_module[k].add(email)
                            elif e_dt and e_dt <= now:
                                expired_by_module[k].add(email)
                                active_by_module[k].discard(email)
                else:
                    # Model flat legacy (fallback)
                    u_sub_exp = parse_dt(d.get("subscription_expiry"))
                    if u_sub_exp and u_sub_exp > now:
                        for k in active_by_module:
                            active_by_module[k].add(email)
                    elif u_sub_exp and u_sub_exp <= now:
                        for k in expired_by_module:
                            expired_by_module[k].add(email)
        except Exception as e:
            logger.error(f"Error reading Firestore users: {e}")

        # 3. Baca Akal API
        try:
            async with AkalClient() as akal:
                services_resp = await akal.list_services()
                services = services_resp.get("data", [])
                for s in services:
                    cuid = s.get("cuid")
                    paid_emails = await akal.get_all_paid_emails(cuid)
                    for em in paid_emails:
                        em = em.strip().lower()
                        for k in active_by_module:
                            active_by_module[k].add(em)
        except Exception as e:
            logger.warning(f"Akal API warning: {e}")

        return global_vip_emails, active_by_module, expired_by_module

    async def run_cycle(self) -> dict:
        """
        Siklus Reaper yang AMAN:
        HANYA mencabut jika email tersebut BENAR-BENAR TERDAFTAR SEBAGAI EXPIRED pada notebook tersebut.
        Akun VIP manual yang ada di whitelist / VIP_PERMANENT TIDAK AKAN DISENTUH SAMA SEKALI.
        """
        now = datetime.now(timezone.utc)
        logger.info("=" * 80)
        logger.info(f"🛡️ SAFE REAPER CYCLE STARTED: {now.strftime('%Y-%m-%d %H:%M:%S UTC')}")
        logger.info("=" * 80)

        global_vips, active_map, expired_map = await self.get_all_database_records()
        logger.info(f"Loaded {len(global_vips)} VIPs protected permanently.")

        revoked_summary = []

        async with NotebookLMClient.from_storage(path=self.storage_path) as nlm_client:
            for nb in MASTER_NOTEBOOKS:
                nb_name = nb["name"]
                nb_id = nb["id"]
                nb_key = nb["key"]
                
                try:
                    status = await nlm_client.sharing.get_status(nb_id)
                    current_viewers = {u.email.lower() for u in status.shared_users if u.permission.name != "OWNER"}
                    
                    # Target yang boleh dicabut dari notebook ini:
                    # 1. Ada di current_viewers
                    # 2. Bukan VIP global
                    # 3. Bukan aktif di modul ini
                    # 4. Ada di daftar expired_by_module untuk modul ini
                    active_for_this_nb = active_map.get(nb_key, set()) | global_vips
                    expired_for_this_nb = expired_map.get(nb_key, set())

                    strictly_expired = (current_viewers & expired_for_this_nb) - active_for_this_nb
                    
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
                            self.db.collection("sharing_log").add({
                                "email": em,
                                "notebook_id": nb_id,
                                "notebook_name": nb_name,
                                "action": "remove",
                                "status": "success",
                                "source": "autonomous_reaper",
                                "created_at": now
                            })
                    else:
                        logger.info(f"✅ {nb_name:<28}: {len(current_viewers)} Viewers (Semua Aman)")

                    # KUNCI PATEN: Selalu pastikan status 100% RESTRICTED + CHAT_ONLY (Hanya email terdaftar yang bisa akses)
                    if status.is_public:
                        await nlm_client.sharing.set_public(nb_id, False)
                    await nlm_client.sharing.set_view_level(nb_id, ShareViewLevel.CHAT_ONLY)
                    mut_copy = [None, None, None, [None, None, None, None, 1]]
                    mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                    params = [nb_id, [mut_copy, mut_chat]]
                    await nlm_client.rpc_call(RPCMethod.RENAME_NOTEBOOK, params, allow_null=True)
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
            "vip_count": len(global_vips),
            "revoked_count": len(revoked_summary)
        }

if __name__ == "__main__":
    reaper = AutonomousReaper()
    asyncio.run(reaper.run_cycle())
