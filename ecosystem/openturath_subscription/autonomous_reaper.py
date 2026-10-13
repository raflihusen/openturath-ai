"""
OpenTurath Autonomous Expiration & Auto-Sync Engine (HARDENED SAFEGUARD VERSION)
==================================================================================
Prinsip Keamanan Absolut (Zero Accidental Revocation):
1. Akun VIP / Manual / Beasiswa memiliki status `VIP_PERMANENT` dan DILINDUNGI SELAMANYA.
2. Akun TIDAK AKAN PERNAH DICABUT kecuali terbukti memiliki tanggal kedaluwarsa resmi (`expires_at < NOW()`).
3. Akun manual/tidak dikenal yang ada di notebook TIDAK AKAN DIHAPUS OTOMATIS, melainkan hanya dilaporkan ke Telegram untuk konfirmasi Anda.
"""

from __future__ import annotations

import os
import sys
import asyncio
import html
import json
import logging
import urllib.request
import urllib.parse
from datetime import datetime, timezone, timedelta
from typing import Any
import socket

# Optional workaround for hosts whose resolver cannot reach notebooklm.google.com.
# Off unless NOTEBOOKLM_PIN_IP is set; TLS still verifies the certificate.
_PIN_IP = os.getenv("NOTEBOOKLM_PIN_IP", "")
if _PIN_IP:
    _orig_getaddrinfo = socket.getaddrinfo

    def _pinned_getaddrinfo(host, port, *args, **kwargs):
        name = host.decode("utf-8", "ignore") if isinstance(host, (bytes, bytearray)) else str(host)
        return _orig_getaddrinfo(_PIN_IP if name == "notebooklm.google.com" else host, port, *args, **kwargs)

    socket.getaddrinfo = _pinned_getaddrinfo

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
import access_policy
import shared_registry
from notebooklm import NotebookLMClient
from notebooklm.rpc.types import RPCMethod, ShareViewLevel

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

# Permanent VIPs come from the registry shared with the Cloud Functions
# (shared/vip_emails.json). This module keeps no list of its own.
STATIC_WHITELIST = set(shared_registry.vip_emails())

# Removals are simulated unless the operator opts in, and a cycle that wants to
# remove more than this many viewers stops and asks for review instead.
APPLY_REMOVALS = os.getenv("REAPER_APPLY", "") == "1"
MAX_REMOVALS_PER_CYCLE = int(os.getenv("REAPER_MAX_REMOVALS", "20"))


class EvidenceUnavailable(RuntimeError):
    """A data source could not be read; revoking on partial data is forbidden."""


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
    # 2. Fikih Tahawwulat (5 Cabang Master Asli & Pool)
    {
        "name": "06.1 - AL-MUHAQQIQ (MASTER)",
        "id": "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Muhaqqiq (Secondary Pool)",
        "id": "67b65ed8-0d1e-4fb4-929c-4fcb735d3be3",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "06.2 - AL-BAYAN (MASTER)",
        "id": "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Bayan (Secondary Pool)",
        "id": "75882649-638f-4729-97f8-19897d90b108",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "06.3 - AL-MUKHTABIR (MASTER)",
        "id": "ac803816-5541-4446-bc9d-b56326493555",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Mukhtabir (Legacy)",
        "id": "ac61a7a0-87e7-42a5-a30f-980ff74a78d8",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "06.4 - AL-HABIB (MASTER)",
        "id": "c8b8a754-991d-429d-8379-b0478abb6ceb",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Habib (Legacy)",
        "id": "6673e79a-7156-42e1-b116-bc1653a32094",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "06.5 - AL-KHATIB (MASTER)",
        "id": "926f3633-53fc-4dbf-81da-0570f7a4d26b",
        "key": "fiqh_tahawwulat",
        "cuid": os.getenv("AKAL_SERVICE_CUID_FIKIH_TAHAWWULAT", "cmln2i27k0000jx047oabzw8p"),
    },
    {
        "name": "Al-Khatib (Legacy)",
        "id": "1288e413-9569-47a3-892f-64008e53c1e8",
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
        # Credentials come from GOOGLE_APPLICATION_CREDENTIALS / the runtime identity.
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
        Load every evidence source, then evaluate per module (access_policy).

        Fail closed: if any source cannot be read completely the cycle aborts.
        A partial picture would make active subscribers look expired.
        """
        now = datetime.now(timezone.utc)
        modules = sorted({nb["key"] for nb in MASTER_NOTEBOOKS})

        try:
            transactions = [doc.to_dict() or {} for doc in self.db.collection("transactions").stream()]
            users = [doc.to_dict() or {} for doc in self.db.collection("users").stream()]
            registry_docs = [doc.to_dict() or {} for doc in self.db.collection("access_vip_registry").stream()]
        except Exception as exc:
            raise EvidenceUnavailable(f"Firestore evidence unavailable: {type(exc).__name__}") from exc

        vip = set(shared_registry.vip_emails())
        vip.update(shared_registry.normal_email(d.get("email")) for d in registry_docs if d.get("email"))

        akal_active: dict[str, set[str]] = {}
        try:
            async with AkalClient() as akal:
                services = (await akal.list_services()).get("data", [])
                for service in services:
                    cuid = service.get("cuid")
                    emails = await akal.get_all_paid_emails(cuid)
                    # A service the catalog does not know keeps its buyers on every module.
                    for scope in shared_registry.scopes_for_cuid(cuid) or ["*"]:
                        akal_active.setdefault("*" if scope in access_policy.ALL_ACCESS else scope, set()).update(emails)
        except Exception as exc:
            raise EvidenceUnavailable(f"GoAkal evidence unavailable: {type(exc).__name__}") from exc

        return access_policy.classify(transactions, users, akal_active, vip, modules, now)

    async def run_cycle(self, apply: bool | None = None) -> dict:
        """
        Siklus Reaper yang AMAN:
        HANYA mencabut jika email tersebut BENAR-BENAR TERDAFTAR SEBAGAI EXPIRED pada modul notebook tersebut.
        VIP tidak pernah menjadi kandidat. Tanpa REAPER_APPLY=1 siklus hanya melaporkan (dry-run).
        """
        apply = APPLY_REMOVALS if apply is None else apply
        control = self.db.collection("access_control").document("runtime").get().to_dict() or {}
        if control.get("writer") == "vps-v2":
            return {"success": True, "action": "vps_writer_active", "revoked": 0}
        if control.get("revocations_paused") is True:
            apply = False
        now = datetime.now(timezone.utc)
        logger.info("=" * 80)
        logger.info(f"🛡️ SAFE REAPER CYCLE STARTED ({'APPLY' if apply else 'DRY-RUN'}): {now.strftime('%Y-%m-%d %H:%M:%S UTC')}")
        logger.info("=" * 80)

        try:
            global_vips, active_map, expired_map = await self.get_all_database_records()
        except EvidenceUnavailable as exc:
            logger.error(f"❌ Cycle aborted, nothing revoked: {exc}")
            send_telegram(f"⚠️ <b>[REAPER DIBATALKAN]</b>\nSumber data tidak lengkap; tidak ada akses yang dicabut.\n<code>{html.escape(str(exc))}</code>")
            return {"timestamp": now.isoformat(), "vip_count": 0, "revoked_count": 0, "errors": 1, "aborted": True}
        logger.info(f"Loaded {len(global_vips)} VIPs protected permanently.")

        plan: list[tuple[dict, set[str]]] = []
        revoked_summary = []
        errors = 0

        async with NotebookLMClient.from_storage(path=self.storage_path) as nlm_client:
            for nb in MASTER_NOTEBOOKS:
                try:
                    status = await nlm_client.sharing.get_status(nb["id"])
                    viewers = {u.email.lower() for u in status.shared_users if u.permission.name != "OWNER"}
                    candidates = access_policy.removal_candidates(viewers, nb["key"], global_vips, active_map, expired_map)
                    if candidates:
                        plan.append((nb, candidates))
                    else:
                        logger.info(f"✅ {nb['name']:<28}: {len(viewers)} Viewers (Semua Aman)")
                    if apply:
                        # Selalu pastikan status RESTRICTED + CHAT_ONLY (hanya email terdaftar yang bisa akses)
                        if status.is_public:
                            await nlm_client.sharing.set_public(nb["id"], False)
                        await nlm_client.sharing.set_view_level(nb["id"], ShareViewLevel.CHAT_ONLY)
                        mut_copy = [None, None, None, [None, None, None, None, 1]]
                        mut_chat = [None, None, None, None, None, None, None, None, [[1]]]
                        await nlm_client.rpc_call(RPCMethod.RENAME_NOTEBOOK, [nb["id"], [mut_copy, mut_chat]], allow_null=True)
                except Exception as e:
                    errors += 1
                    logger.error(f"❌ Error in {nb['name']}: {type(e).__name__}")

            total = sum(len(c) for _, c in plan)
            if apply and total > MAX_REMOVALS_PER_CYCLE:
                logger.error(f"🚨 {total} removals exceed the per-cycle limit ({MAX_REMOVALS_PER_CYCLE}); nothing revoked.")
                send_telegram(f"🚨 <b>[REAPER DITAHAN]</b>\n{total} calon pencabutan melebihi batas {MAX_REMOVALS_PER_CYCLE} per siklus. Tidak ada yang dicabut; mohon tinjau.")
                apply = False

            for nb, candidates in plan:
                for em in sorted(candidates):
                    if not apply:
                        logger.warning(f"🔎 DRY-RUN {nb['name']}: {em} akan dicabut (terkonfirmasi expired)")
                        revoked_summary.append({"email": em, "notebook": nb["name"], "applied": False})
                        continue
                    try:
                        await nlm_client.sharing.remove_user(nb["id"], em)
                        after = await nlm_client.sharing.get_status(nb["id"])
                        if em in {u.email.lower() for u in after.shared_users}:
                            raise RuntimeError("removal not verified")
                        revoked_summary.append({"email": em, "notebook": nb["name"], "applied": True})
                        self.db.collection("sharing_log").add({
                            "email": em, "notebook_id": nb["id"], "notebook_name": nb["name"],
                            "action": "remove", "status": "success", "source": "autonomous_reaper", "created_at": now,
                        })
                    except Exception as e:
                        errors += 1
                        logger.error(f"❌ Removal failed in {nb['name']}: {type(e).__name__}")

        applied = [r for r in revoked_summary if r["applied"]]
        if revoked_summary:
            title = "PENCABUTAN TERKONFIRMASI" if applied else "DRY-RUN — BELUM ADA YANG DICABUT"
            msg_lines = [
                f"⚠️ <b>[AUTONOMOUS REAPER: {title}]</b>",
                "🕌 <b>OpenTurath AI Engine</b>\n",
                f"<b>{len(revoked_summary)} akses terkonfirmasi kedaluwarsa</b>:\n",
            ]
            for r in revoked_summary[:40]:
                msg_lines.append(f"• 👤 <code>{html.escape(r['email'])}</code> ({html.escape(r['notebook'])})")
            if len(revoked_summary) > 40:
                msg_lines.append(f"• … dan {len(revoked_summary) - 40} lainnya")
            if not applied:
                msg_lines.append("\nJalankan dengan <code>REAPER_APPLY=1</code> setelah daftar ini ditinjau.")
            send_telegram("\n".join(msg_lines))

        return {
            "timestamp": now.isoformat(),
            "vip_count": len(global_vips),
            "revoked_count": len(applied),
            "dry_run_count": len(revoked_summary) - len(applied),
            "errors": errors,
        }

if __name__ == "__main__":
    reaper = AutonomousReaper()
    print(json.dumps(asyncio.run(reaper.run_cycle(apply=True if "--apply" in sys.argv else None)), default=str))
