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


def _build_master_notebooks() -> list[dict[str, str]]:
    """Bangun daftar notebook master + legacy langsung dari shared/product_catalog.json."""
    entries: list[dict[str, str]] = []
    seen_ids: set[str] = set()
    scopes = shared_registry.catalog().get("scopes", {})
    for scope_key, scope_info in scopes.items():
        for nb in scope_info.get("notebooks", []):
            entity = nb.get("entity", scope_key)
            master_id = nb.get("master", "")
            if master_id and master_id not in seen_ids:
                seen_ids.add(master_id)
                entries.append({"name": f"{entity} (Master)", "id": master_id, "key": scope_key, "cuid": ""})
            for legacy_id in nb.get("legacy", []):
                if legacy_id and legacy_id not in seen_ids:
                    seen_ids.add(legacy_id)
                    entries.append({"name": f"{entity} (Legacy)", "id": legacy_id, "key": scope_key, "cuid": ""})
    return entries


MASTER_NOTEBOOKS = _build_master_notebooks()

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
