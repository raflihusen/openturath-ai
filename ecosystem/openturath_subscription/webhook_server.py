"""
OpenTurath Subscription Automation - Webhook Server
=====================================================
Menerima webhook dari Akal (goakal.com) dan otomatis:
  - PAID / SETTLED → tambah email ke NotebookLM (add viewer)
  - EXPIRED / FAILED → hapus email dari NotebookLM (remove viewer)

Cara jalankan:
  export $(cat .env | grep -v '^#' | xargs)
  export PYTHONPATH="../notebooklm-py/src:$PYTHONPATH"
  python webhook_server.py

Endpoint:
  POST /webhook  ← Akal kirim ke sini
  GET  /health   ← cek status server
"""

from __future__ import annotations

import asyncio
import hashlib
import hmac
import json
import os
import sys
import math

# Load .env file manually
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

import logging
import datetime
from google.cloud import firestore

# Tambahkan notebooklm-py ke path
NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

import notebooklm_manager as nlm
import access_policy
import shared_registry
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# ─────────────────────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("subscription.log"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────────────────────
# KONFIGURASI
# ─────────────────────────────────────────────────────────────
# Token verifikasi dari Akal: Dashboard → Developer → Webhook
AKAL_WEBHOOK_SECRET = os.getenv("AKAL_WEBHOOK_SECRET", "")

# Produk, modul, notebook, dan daftar VIP dibaca dari registry bersama
# (shared/*.json, dibangkitkan dari sumber TypeScript). Berkas ini tidak
# menyimpan salinan sendiri, sehingga server ini dan Cloud Functions tidak
# bisa berbeda pendapat tentang siapa VIP atau notebook mana milik modul apa.
ALL_ACCESS_SCOPES = {"all_access", "all_ai"}
MAX_BODY_BYTES = 64 * 1024
REQUEST_TIMEOUT_SECONDS = 30


def masters_for_scopes(scopes: list[str]) -> list[str]:
    ids: list[str] = []
    for scope in scopes:
        ids.extend(shared_registry.masters_for_scope(scope))
    return list(dict.fromkeys(ids))


def notebooks_for_scopes(scopes: list[str]) -> list[str]:
    ids: list[str] = []
    for scope in scopes:
        ids.extend(shared_registry.notebooks_for_scope(scope))
    return list(dict.fromkeys(ids))


def mask_email(email: str) -> str:
    """Log form of an address: enough to correlate, not enough to harvest."""
    name, _, domain = (email or "").partition("@")
    return f"{name[:1]}***@{domain}" if domain else "***"


# Status Akal → Aksi NotebookLM
# Ref: https://goakal.com/docs/developer/webhook
ACTIVE_STATUSES   = {"PAID", "SETTLED"}                       # → tambah akses
INACTIVE_STATUSES = {"EXPIRED", "FAILED", "CANCELLED"}        # → hapus akses
IGNORED_STATUSES  = {"PENDING"}                                # → abaikan

SERVER_PORT = int(os.getenv("PORT", "8080"))


# ─────────────────────────────────────────────────────────────
# VERIFIKASI TOKEN AKAL
# ─────────────────────────────────────────────────────────────
def _secret_equal(provided, expected: str) -> bool:
    """Perbandingan constant-time yang aman untuk input non-string/non-ASCII."""
    if not isinstance(provided, str) or not isinstance(expected, str):
        return False
    return hmac.compare_digest(provided.encode("utf-8"), expected.encode("utf-8"))


def verify_akal_token(payload: dict) -> bool:
    """
    Verifikasi bahwa webhook benar-benar dikirim oleh Akal.
    Akal mengirim token verifikasi DI DALAM body JSON sebagai field 'token',
    BUKAN di HTTP header. Token ini harus cocok dengan Webhook Verification
    Token yang ada di dashboard Akal → Developer → Webhook.
    """
    if not AKAL_WEBHOOK_SECRET:
        logger.error("🚨 AKAL_WEBHOOK_SECRET tidak diset — MENOLAK semua request!")
        return False

    payload_token = payload.get("token", "")
    if not payload_token:
        logger.warning("🚨 Tidak ada 'token' field di payload webhook.")
        return False

    is_valid = _secret_equal(payload_token, AKAL_WEBHOOK_SECRET)
    if not is_valid:
        logger.warning("🚨 Token webhook Akal tidak cocok.")
    return is_valid


# ─────────────────────────────────────────────────────────────
# PARSE PAYLOAD AKAL WEBHOOK
# ─────────────────────────────────────────────────────────────
def parse_akal_payload(payload: dict) -> tuple[str, str, str, str, str, float, str, str]:
    """
    Parse payload webhook dari Akal dengan support nested 'data' object.
    Returns:
        (email, user_name, service_name, status, price_scheme_name, amount, transaction_id, paid_at_str)
    """
    # Akal membungkus data transaksi asli di dalam key 'data'
    data = payload.get("data") if isinstance(payload.get("data"), dict) else payload

    status       = data.get("status", "").upper().strip()
    user         = data.get("user", {})
    payer        = data.get("payer", {})  # Alternatif di payload Akal
    service      = data.get("service", {})
    price_scheme = data.get("priceScheme", {})

    # Ekstrak email (coba user.email lalu payer.email)
    email = user.get("email", "") or payer.get("email", "")
    email = email.strip().lower()

    # Ekstrak nama
    user_name = user.get("name", "") or payer.get("name", "")
    user_name = user_name.strip()

    service_name = service.get("name", "").strip()
    
    # Ekstrak price scheme name
    price_scheme_name = price_scheme.get("name", "").strip() if price_scheme else ""
    
    # Ekstrak amount
    try:
        amount = float(data.get("amount", 0))
    except (ValueError, TypeError):
        amount = 0.0
        
    # Ekstrak transaction ID
    transaction_id = data.get("id", "").strip()
    
    # Ekstrak paidAt dari Akal (untuk perhitungan expiry yang akurat)
    paid_at_str = data.get("paidAt", "") or data.get("paid_at", "")

    return email, user_name, service_name, status, price_scheme_name, amount, transaction_id, paid_at_str


# ─────────────────────────────────────────────────────────────
# FIRESTORE INTEGRATION HELPERS
# ─────────────────────────────────────────────────────────────
db_client = None

def get_firestore_client():
    global db_client
    if db_client is None:
        try:
            db_client = firestore.Client()
            logger.info("✅ Firestore client successfully initialized.")
        except Exception as e:
            logger.warning(f"⚠️ Could not initialize Firestore client: {e}. If running locally, make sure GOOGLE_APPLICATION_CREDENTIALS is set.")
    return db_client

def vps_writer_active():
    # Fail closed if the shared control document cannot be read: allowing an
    # old writer during an outage can revoke VIP/module access incorrectly.
    db = get_firestore_client()
    if db is None:
        raise RuntimeError("Access writer coordination unavailable")
    return (db.collection("access_control").document("runtime").get().to_dict() or {}).get("writer") == "vps-v2"

def queue_legacy_event(payload, reason: str = ""):
    # Only called after the HTTP handler has authenticated the webhook. Store
    # normalized billing evidence, never the webhook secret or arbitrary payload.
    email, name, service, status, plan, amount, transaction_id, paid_at = parse_akal_payload(payload)
    identity = str(transaction_id or "")
    digest = hashlib.sha256(json.dumps([identity, str(status), email, service, amount, paid_at], separators=(",", ":")).encode()).hexdigest()
    ref = get_firestore_client().collection("access_legacy_events").document(digest)
    record = {"email": email, "service": service, "payment_status": status,
              "plan": plan, "amount": amount, "transaction_id": identity,
              "paid_at": paid_at, "status": "verification_required",
              "received_at": firestore.SERVER_TIMESTAMP}
    if reason:
        record["reason"] = reason
    try:
        ref.create(record)
    except Exception as exc:
        from google.api_core.exceptions import AlreadyExists
        if not isinstance(exc, AlreadyExists):
            raise
    return {"success": True, "action": "durable_vps_handoff", "event_id": digest}


def is_protected_owner(email: str) -> bool:
    """VIP check before any removal. Fails closed when Firestore is unreachable."""
    email = shared_registry.normal_email(email)
    if email in shared_registry.vip_emails():
        return True
    db = get_firestore_client()
    if db is None:
        raise RuntimeError("VIP evidence unavailable")
    if db.collection("access_vip_registry").document(shared_registry.vip_registry_key(email)).get().exists:
        return True
    for doc in db.collection("users").where("email", "==", email).limit(5).stream():
        if shared_registry.is_vip_profile(doc.to_dict() or {}):
            return True
    return False

def determine_plan_and_expiry(price_scheme_name: str, service_name: str) -> tuple[str, int]:
    # Default to 1 month tholib
    plan = "tholib_1m"
    duration_months = 1
    
    price_scheme_lower = price_scheme_name.lower()
    service_name_lower = service_name.lower()
    
    # 1. Check if 12 months / 1 year
    if "12 bulan" in price_scheme_lower or "12m" in price_scheme_lower or "tahun" in price_scheme_lower or "1y" in price_scheme_lower or "year" in price_scheme_lower or "annual" in price_scheme_lower:
        plan = "bahits_1y"
        duration_months = 12
    # 2. Check if 6 months
    elif "6 bulan" in price_scheme_lower or "6m" in price_scheme_lower or "6-month" in price_scheme_lower:
        plan = "tholib_6m"
        duration_months = 6
    # 3. Check if 1 month
    elif "1 bulan" in price_scheme_lower or "1m" in price_scheme_lower or "month" in price_scheme_lower or "bulan" in price_scheme_lower:
        plan = "tholib_1m"
        duration_months = 1
    else:
        # Fallback based on text match
        if "bahits" in price_scheme_lower or "bahits" in service_name_lower:
            plan = "bahits_1y"
            duration_months = 12
        else:
            plan = "tholib_1m"
            duration_months = 1
            
    return plan, duration_months

def process_firestore_updates(email: str, name: str, plan: str, duration_months: int, amount: float,
                              transaction_id: str, scopes: list[str], service_name: str, paid_at_str: str = ""):
    """Record one verified GoAkal purchase.

    Idempotent per transaction ID. Only the purchased modules are written; the
    account-wide `plan` / `subscription_expiry` are never touched, so one
    module cannot unlock the others. A longer existing entitlement is kept.
    """
    db = get_firestore_client()
    if not db:
        raise RuntimeError("Firestore client not available")
    email = email.strip().lower()
    trx_ref = db.collection("transactions").document(transaction_id)
    if trx_ref.get().exists:
        logger.info("⏭️  Transaksi %s sudah tercatat. Idempotent skip.", transaction_id)
        return

    now = datetime.datetime.now(datetime.timezone.utc)
    base_date = access_policy.parse_dt(paid_at_str) or now
    user_doc = next(iter(db.collection("users").where("email", "==", email).limit(1).stream()), None)
    entitlements = (user_doc.to_dict() or {}).get("entitlements", {}) if user_doc else {}
    if not isinstance(entitlements, dict):
        entitlements = {}

    # Renewal bought before the current period ends continues from that end.
    start = base_date
    for scope in scopes:
        current = entitlements.get(scope)
        current_end = access_policy.parse_dt(current.get("expiry")) if isinstance(current, dict) else None
        if current_end and current_end > start and str(current.get("status") or "active") == "active":
            start = current_end
    expiry_date = access_policy.billing_expiry(start, duration_months)

    trx_ref.set({
        "customer_email": email,
        "customer_name": name,
        "plan": plan,
        "amount": amount,
        "duration_months": duration_months,
        "status": "success",
        "source": "akal",
        "service_name": service_name,
        "entitlement_key": scopes[0],
        "entitlement_keys": scopes,
        "paid_at": base_date,
        "paid_ms": int(base_date.timestamp() * 1000),
        "expires_ms": int(expiry_date.timestamp() * 1000),
        "processed_at": now,
        "created_at": now,
        "completed_at": now,
        "subscription_expires_at": expiry_date,
    })
    logger.info("Saved Akal transaction %s.", transaction_id)

    if not user_doc:
        logger.info("Pembeli %s belum terdaftar; akses ditautkan saat ia mendaftar.", mask_email(email))
        return
    updates = {}
    for scope in scopes:
        current = entitlements.get(scope)
        current_end = access_policy.parse_dt(current.get("expiry")) if isinstance(current, dict) else None
        if current_end and current_end >= expiry_date and str(current.get("status") or "active") == "active":
            continue
        updates[f"entitlements.{scope}"] = {
            "plan": plan, "status": "active", "expiry": expiry_date, "source": "goakal",
            "source_transaction_id": transaction_id, "updated_at": now,
        }
    if updates:
        user_doc.reference.update(updates)
        logger.info("Updated %s: %s until %s", mask_email(email), ", ".join(scopes), expiry_date.date())


async def process_internal_provisioning(payload: dict) -> dict:
    """Sharing command from the Cloud Functions outbox (X-Internal-Secret).

    The caller already verified payment and entitlement, so nothing is written
    to billing here: this only makes NotebookLM match the requested state.
    """
    data = payload.get("data") if isinstance(payload.get("data"), dict) else payload
    status = str(data.get("status", "")).upper().strip()
    payer = data.get("payer") or data.get("user") or {}
    email = shared_registry.normal_email(payer.get("email"))
    name = str(payer.get("name") or "").strip()
    service = data.get("service") or {}
    key = service.get("key")
    scopes = [key] if key in shared_registry.all_scopes() else shared_registry.resolve_scopes(service.get("name"))
    scopes = [s for s in scopes if s not in ALL_ACCESS_SCOPES]
    if not email or "@" not in email or not scopes:
        return {"success": False, "error": "Unknown provisioning target"}

    if status in ACTIVE_STATUSES:
        results = []
        for nid in masters_for_scopes(scopes):
            results.append(await nlm.add_viewer(nid, email, name))
            await asyncio.sleep(1.0)
        return {"success": bool(results) and all(r.get("success", False) for r in results), "action": "provisioned"}
    if status in INACTIVE_STATUSES:
        if is_protected_owner(email):
            logger.info("🛡️ SKIP CABUT AKSES: %s adalah VIP permanen.", mask_email(email))
            return {"success": True, "action": "ignored_permanent_vip"}
        results = []
        for nid in notebooks_for_scopes(scopes):
            results.append(await nlm.remove_viewer(nid, email))
            await asyncio.sleep(1.0)
        return {"success": bool(results) and all(r.get("success", False) for r in results), "action": "deprovisioned"}
    return {"success": True, "action": "ignored", "status": status}


# ─────────────────────────────────────────────────────────────
# PROSES WEBHOOK
# ─────────────────────────────────────────────────────────────
async def process_webhook(payload: dict, internal: bool = False) -> dict:
    """Proses satu webhook event dari Akal, atau perintah sharing internal."""
    event = payload.get("event", "")

    # Tangani test event khusus dari dashboard Akal
    if event == "test":
        logger.info("🧪 Test webhook diterima dari Akal. Membalas sukses.")
        return {"success": True, "action": "test_connection", "message": "Connection test successful"}

    if vps_writer_active():
        # After cutover the VPS worker is the only writer of NotebookLM sharing.
        return {"success": True, "action": "vps_writer_active"} if internal else queue_legacy_event(payload)
    if internal:
        return await process_internal_provisioning(payload)

    email, user_name, service_name, status, price_scheme_name, amount, transaction_id, paid_at_str = parse_akal_payload(payload)

    # Legacy writers cannot atomically verify all VIP/grant sources before
    # external removal. Hand off negative events instead of revoking directly.
    if status in INACTIVE_STATUSES:
        return queue_legacy_event(payload)
    if status in IGNORED_STATUSES:
        logger.info("   ⏭️  Status '%s' diabaikan (PENDING = belum bayar)", status)
        return {"success": True, "action": "ignored", "status": status}
    if status not in ACTIVE_STATUSES:
        logger.warning("   ❓ Status '%s' tidak dikenali, diabaikan.", status)
        return {"success": True, "action": "unknown_status", "status": status}
    if not transaction_id or not math.isfinite(amount) or amount <= 0:
        return queue_legacy_event(payload, "invalid_billing_identity_or_amount")
    if not email:
        logger.error("❌ Payload tidak memiliki user.email")
        return {"success": False, "error": "user.email kosong"}

    logger.info("📨 Webhook | event=%-25s | status=%-10s | email=%-25s | service=%s",
                event, status, mask_email(email), service_name)

    # An unknown product is quarantined for the operator, never mapped to a guess.
    scopes = shared_registry.resolve_scopes(service_name)
    if not scopes:
        logger.error("❌ Produk '%s' tidak ada di katalog. Transaksi dikarantina.", service_name)
        return queue_legacy_event(payload, "unknown_service")

    plan, duration_months = determine_plan_and_expiry(price_scheme_name, service_name)
    notebook_ids = masters_for_scopes([s for s in scopes if s not in ALL_ACCESS_SCOPES])
    logger.info("   ✅ TAMBAH akses: %s → %s (%d notebook)", mask_email(email), service_name, len(notebook_ids))

    process_firestore_updates(email, user_name, plan, duration_months, amount, transaction_id,
                              scopes, service_name, paid_at_str)

    results = []
    for nid in notebook_ids:
        results.append(await nlm.add_viewer(nid, email, user_name))
        await asyncio.sleep(1.0)
    success = bool(results) and all(r.get("success", False) for r in results)

    send_telegram_message(
        f"🔔 <b>[AKSES DITAMBAHKAN]</b>\n"
        f"🕌 OpenTurath AI\n"
        f"📧 Email: <code>{escape_html(email)}</code>\n"
        f"👤 Nama: <b>{escape_html(user_name or 'N/A')}</b>\n"
        f"📦 Produk: <b>{escape_html(service_name)}</b>\n"
        f"🏷️ Plan: <b>{escape_html(plan.upper())}</b> ({duration_months} bln)\n"
        f"💰 Nominal: <code>Rp {amount:,.0f}</code>\n"
        f"🆔 Trx: <code>{escape_html(transaction_id)}</code>\n"
        f"✅ Status: {'Sukses' if success else 'Gagal'} terdaftar di {len(notebook_ids)} notebook."
    )
    return {"success": success, "action": "provisioned", "results": results}


# ─────────────────────────────────────────────────────────────
# TELEGRAM INTEGRATION
# ─────────────────────────────────────────────────────────────
import urllib.request
import urllib.parse

def escape_html(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def send_telegram_message(text: str):
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    chat_id = os.getenv("TELEGRAM_CHAT_ID")
    if not token or not chat_id:
        logger.warning("Telegram Bot Token atau Chat ID belum dikonfigurasi.")
        return
        
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "HTML"
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            if not res_data.get("ok"):
                logger.error(f"Gagal mengirim Telegram message: {res_data}")
    except Exception as e:
        logger.error(f"Error mengirim Telegram message: {e}")

def is_product_released(entitlement_key: str) -> bool:
    return bool(shared_registry.masters_for_scope(entitlement_key))

def handle_telegram_command(text: str, chat_id: int):
    # Check if the chat ID is authorized
    EXPECTED_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "")
    if str(chat_id) != EXPECTED_CHAT_ID:
        logger.warning("Telegram command from an unauthorized chat ignored.")
        return

    text = text.strip()
    if text.startswith("/help") or text == "/start":
        help_msg = (
            "🕌 <b>OpenTurath AI Bot Help</b>\n\n"
            "Berikut perintah yang tersedia:\n"
            "• <code>/status [email]</code> - Cek status langganan user (Contoh: <code>/status budi@gmail.com</code>)\n"
            "• <code>/active</code> - Jumlah user premium aktif\n"
            "• <code>/reap</code> - Jalankan Autonomous Expiration Reaper & Sync Otomatis\n"
            "• <code>/logs</code> - Lihat log server terbaru\n"
            "• <code>/help</code> - Tampilkan pesan bantuan ini"
        )
        send_telegram_message(help_msg)

    elif text.startswith("/reap") or text.startswith("/sync"):
        if vps_writer_active():
            return
        send_telegram_message("🔄 <b>[REAPER]</b> Memulai siklus pemindaian dan sinkronisasi otomatis...")
        try:
            from autonomous_reaper import AutonomousReaper
            reaper = AutonomousReaper()
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            result = loop.run_until_complete(reaper.run_cycle())
            vip_cnt = result.get('vip_count', result.get('authorized_count', 0))
            rev_cnt = result.get('revoked_count', 0)
            err_cnt = result.get('errors', 0)
            send_telegram_message(f"✅ <b>[REAPER SELESAI]</b>\n• VIP Terlindungi: <code>{vip_cnt}</code>\n• Akses Expired Dicabut: <code>{rev_cnt}</code>\n• Error: <code>{err_cnt}</code>")
        except Exception as e:
            send_telegram_message(f"❌ <b>[REAPER ERROR]</b> Gagal: {escape_html(type(e).__name__)}")
        
    elif text.startswith("/status"):
        parts = text.split(maxsplit=1)
        if len(parts) < 2:
            send_telegram_message("❌ Format salah. Gunakan: <code>/status [email]</code>\nContoh: <code>/status budi@gmail.com</code>")
            return
        
        email = parts[1].strip().lower()
        if email == "[email]" or (email.startswith("[") and email.endswith("]")):
            send_telegram_message("💡 Silakan masukkan email asli pelanggan Anda (contoh: <code>/status budi@gmail.com</code>), bukan menulis literal <code>[email]</code>.")
            return

        try:
            db = get_firestore_client()
            if not db:
                send_telegram_message("❌ Database tidak tersedia.")
                return
                
            now = datetime.datetime.now(datetime.timezone.utc)
            
            # Query transactions for this email
            tx_ref = db.collection("transactions")
            query = tx_ref.where("customer_email", "==", email).where("status", "in", ["success", "PAID", "SETTLED"]).stream()
            
            entitlements = {}
            customer_name = "User"
            global_plan = "trial"
            questions_used = 0
            
            KEY_TO_HUMAN_NAME = {scope: shared_registry.scope_label(scope) for scope in shared_registry.all_scopes()}
            
            for doc in query:
                data = doc.to_dict()
                c_name = data.get("customer_name") or data.get("payer_name")
                if c_name:
                    customer_name = c_name
                    
                expiry = data.get("subscription_expires_at")
                if not expiry:
                    continue
                    
                if isinstance(expiry, datetime.datetime):
                    exp_dt = expiry
                else:
                    try:
                        exp_dt = datetime.datetime.fromisoformat(expiry.replace("Z", "+00:00"))
                    except:
                        continue
                        
                if exp_dt.tzinfo is None:
                    exp_dt = exp_dt.replace(tzinfo=datetime.timezone.utc)
                    
                ent_key = data.get("entitlement_key")
                if not ent_key:
                    ent_key = (shared_registry.resolve_scopes(data.get("service_name")) or ["tidak_diketahui"])[0]
                        
                plan_val = data.get("plan", "tholib_1m")
                
                # Keep latest expiry
                if ent_key not in entitlements or exp_dt > entitlements[ent_key]["expiry"]:
                    entitlements[ent_key] = {
                        "expiry": exp_dt,
                        "plan": plan_val
                    }
                    
            # Also try to check the users collection for registration details (name, plan, questions_used)
            users_ref = db.collection("users")
            user_data = None
            user_doc = users_ref.document(email).get()
            if user_doc.exists:
                user_data = user_doc.to_dict()
            else:
                uq = users_ref.where("email", "==", email).limit(1).stream()
                for ud in uq:
                    user_data = ud.to_dict()
                    break
            
            is_registered = False
            if user_data:
                customer_name = user_data.get("name") or customer_name
                global_plan = user_data.get("plan", global_plan)
                questions_used = user_data.get("questions_used", 0)
                is_registered = True

            ent_details = ""
            active_ents = 0
            
            for k, v in entitlements.items():
                if not is_product_released(k):
                    continue
                    
                human_name = KEY_TO_HUMAN_NAME.get(k, k.upper())
                plan_val = v["plan"]
                exp_dt = v["expiry"]
                
                if exp_dt > now:
                    remaining_days = (exp_dt - now).days
                    status_str = f"🟢 Aktif (Sisa {remaining_days} hari)"
                    active_ents += 1
                else:
                    status_str = "🔴 Kedaluwarsa"
                exp_str = exp_dt.strftime('%d-%m-%Y')
                
                ent_details += (
                    f"• <b>{human_name}</b>\n"
                    f"  Plan: <code>{plan_val.upper()}</code>\n"
                    f"  Status: {status_str}\n"
                    f"  Exp: <code>{exp_str}</code>\n\n"
                )

            reg_status = "✅ Terdaftar di Aplikasi" if is_registered else "ℹ️ Belum Registrasi di Aplikasi (Hanya Pembelian)"
            
            status_msg = (
                f"👤 <b>Detail Pelanggan</b>\n"
                f"──────────────────────\n"
                f"👤 Nama: <b>{escape_html(str(customer_name))}</b>\n"
                f"📧 Email: <code>{escape_html(email)}</code>\n"
                f"📱 Status: <i>{reg_status}</i>\n"
                f"💬 Pertanyaan Digunakan: <code>{questions_used}</code>\n\n"
                f"📂 <b>Kategori Langganan AI:</b>\n"
                f"{ent_details or '  • Tidak ada modul aktif'}"
                f"──────────────────────"
            )
            send_telegram_message(status_msg)
        except Exception as e:
            send_telegram_message(f"❌ Gagal mengambil data: {escape_html(type(e).__name__)}")
            
    elif text == "/active":
        try:
            db = get_firestore_client()
            if not db:
                send_telegram_message("❌ Database tidak tersedia.")
                return
                
            now = datetime.datetime.now(datetime.timezone.utc)
            
            # Query all successful transactions in transactions collection
            tx_ref = db.collection("transactions")
            query = tx_ref.where("status", "in", ["success", "PAID", "SETTLED"]).stream()
            
            active_by_email = {}
            
            KEY_TO_HUMAN_NAME = {scope: shared_registry.scope_label(scope) for scope in shared_registry.all_scopes()}
            
            for doc in query:
                data = doc.to_dict()
                email = (data.get("customer_email") or data.get("payer_email") or "").strip().lower()
                if not email:
                    continue
                    
                expiry = data.get("subscription_expires_at")
                if not expiry:
                    continue
                    
                if isinstance(expiry, datetime.datetime):
                    exp_dt = expiry
                else:
                    try:
                        exp_dt = datetime.datetime.fromisoformat(expiry.replace("Z", "+00:00"))
                    except:
                        continue
                        
                if exp_dt.tzinfo is None:
                    exp_dt = exp_dt.replace(tzinfo=datetime.timezone.utc)
                    
                if exp_dt > now:
                    ent_key = data.get("entitlement_key")
                    if not ent_key:
                        ent_key = (shared_registry.resolve_scopes(data.get("service_name")) or ["tidak_diketahui"])[0]
                            
                    if not is_product_released(ent_key):
                        continue
                        
                    if email not in active_by_email:
                        active_by_email[email] = {
                            "name": data.get("customer_name") or data.get("payer_name") or "User",
                            "entitlements": {}
                        }
                        
                    if ent_key not in active_by_email[email]["entitlements"] or exp_dt > active_by_email[email]["entitlements"][ent_key]["expiry"]:
                        active_by_email[email]["entitlements"][ent_key] = {
                            "expiry": exp_dt,
                            "plan": data.get("plan", "tholib_1m")
                        }
            
            user_list = []
            sorted_emails = sorted(active_by_email.keys(), key=lambda e: active_by_email[e]["name"].lower())
            
            for email in sorted_emails:
                info = active_by_email[email]
                # Look up name in users collection
                user_data = None
                user_doc = db.collection("users").document(email).get()
                if user_doc.exists:
                    user_data = user_doc.to_dict()
                else:
                    uq = db.collection("users").where("email", "==", email).limit(1).stream()
                    for ud in uq:
                        user_data = ud.to_dict()
                        break
                        
                display_name = info["name"]
                if user_data:
                    display_name = user_data.get("name") or display_name
                    
                ent_lines = []
                for ent, ent_info in info["entitlements"].items():
                    exp_dt = ent_info["expiry"]
                    plan_val = ent_info["plan"]
                    remaining_days = (exp_dt - now).days
                    exp_str = exp_dt.strftime('%d-%m-%Y')
                    human_name = KEY_TO_HUMAN_NAME.get(ent, ent.upper())
                    ent_lines.append(f"   • <b>{human_name}</b>: <code>{plan_val.upper()}</code> (Sisa {remaining_days} hari, Exp: {exp_str})")
                
                if ent_lines:
                    ent_details = "\n".join(ent_lines)
                    user_list.append(
                        f"👤 <b>{escape_html(str(display_name))}</b>\n"
                        f"📧 Email: <code>{escape_html(email)}</code>\n"
                        f"{ent_details}"
                    )
                    
            total_active = len(user_list)
            if total_active == 0:
                send_telegram_message("👥 <b>Daftar Pengguna Premium Aktif:</b> <code>0</code>")
                return
                
            list_separator = "\n──────────────────────\n"
            status_msg = (
                f"👥 <b>Daftar Pengguna Premium Aktif ({total_active})</b>\n"
                f"──────────────────────\n"
                f"{list_separator.join(user_list)}\n"
                f"──────────────────────"
            )
            
            if len(status_msg) > 4000:
                chunk = f"👥 <b>Daftar Pengguna Premium Aktif ({total_active})</b>\n──────────────────────\n"
                for u_entry in user_list:
                    if len(chunk) + len(u_entry) + 50 > 4000:
                        send_telegram_message(chunk)
                        chunk = "──────────────────────\n"
                    chunk += u_entry + "\n──────────────────────\n"
                send_telegram_message(chunk)
            else:
                send_telegram_message(status_msg)
        except Exception as e:
            send_telegram_message(f"❌ Gagal mengambil daftar pengguna: {escape_html(type(e).__name__)}")
            
    elif text == "/logs":
        try:
            log_path = "subscription.log"
            if os.path.exists(log_path):
                with open(log_path, "r") as f:
                    lines = f.readlines()
                last_lines = "".join(lines[-8:])
                send_telegram_message(f"📝 <b>8 Baris Log Terakhir:</b>\n<pre>{escape_html(last_lines)}</pre>")
            else:
                send_telegram_message("❌ File log tidak ditemukan.")
        except Exception as e:
            send_telegram_message(f"❌ Gagal membaca log: {str(e)}")
    else:
        send_telegram_message("❓ Perintah tidak dikenali. Ketik <code>/help</code> untuk daftar perintah.")


# ─────────────────────────────────────────────────────────────
# HTTP SERVER
# ─────────────────────────────────────────────────────────────
class WebhookHandler(BaseHTTPRequestHandler):
    """HTTP Handler untuk menerima webhook dari Akal."""

    timeout = REQUEST_TIMEOUT_SECONDS  # socket timeout: a stalled client cannot hold a worker

    def _read_body(self):
        """Body within the size limit, or None after replying with an error."""
        try:
            length = int(self.headers.get("Content-Length", ""))
        except ValueError:
            self._send_json(411, {"error": "Content-Length required"})
            return None
        if length < 0 or length > MAX_BODY_BYTES:
            self._send_json(413, {"error": "Payload too large"})
            return None
        return self.rfile.read(length)

    def log_message(self, format, *args):
        pass  # Matikan default HTTP server logging

    def _send_json(self, code: int, data: dict):
        body = json.dumps(data).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _authorize_cron(self, secret: str, route: str) -> bool:
        """Fail-closed: tanpa secret terkonfigurasi, endpoint operasional ditolak."""
        if not secret:
            logger.error("🚨 %s ditolak: secret belum dikonfigurasi.", route)
            self._send_json(503, {"error": "Endpoint not configured"})
            return False
        bearer = self.headers.get("Authorization", "")
        header_secret = self.headers.get("X-Cron-Secret", "") or self.headers.get("X-Internal-Secret", "")
        if _secret_equal(bearer, f"Bearer {secret}") or _secret_equal(header_secret, secret):
            return True
        logger.warning("🚨 Unauthorized %s attempt", route)
        self._send_json(401, {"error": "Unauthorized"})
        return False

    def do_GET(self):
        if self.path == "/health":
            # Liveness only: configuration details are not public.
            self._send_json(200, {"status": "ok", "service": "OpenTurath Subscription Automation"})
        elif self.path == "/keepalive":
            if not self._authorize_cron(os.getenv("CRON_SECRET", ""), "/keepalive"):
                return
            try:
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                
                # Notebook master pertama di katalog dipakai untuk test ping
                notebook_id = next(iter(masters_for_scopes(shared_registry.all_scopes())), "")
                
                if not notebook_id:
                    self._send_json(400, {"success": False, "error": "No notebooks configured for keepalive"})
                    loop.close()
                    return
                
                logger.info(f"🔄 Cloud Scheduler Keep-Alive: Pinging Google NotebookLM for {notebook_id}...")
                result = loop.run_until_complete(nlm.test_connection(notebook_id))
                loop.close()
                
                if result.get("success", False):
                    logger.info("   ✅ Keep-Alive successful: Session is fresh.")
                    self._send_json(200, {"success": True, "message": "Keep-alive ping to Google successful", "details": result})
                else:
                    logger.error(f"   ❌ Keep-Alive failed: {result.get('error')}")
                    self._send_json(500, {"success": False, "error": "Google NotebookLM connection failed", "details": result})
            except Exception as e:
                logger.error(f"   ❌ Keep-Alive exception: {e}")
                self._send_json(500, {"success": False, "error": "Keep-alive failed"})
        elif self.path.startswith("/cron/reap"):
            cron_secret = os.getenv("CRON_SECRET", "") or os.getenv("INTERNAL_SECRET", "")
            if not self._authorize_cron(cron_secret, "/cron/reap"):
                return
            try:
                if vps_writer_active():
                    self._send_json(200, {"success": True, "action": "vps_writer_active"})
                    return
                logger.info("⚡ Executing scheduled autonomous reaper cycle via /cron/reap...")
                from autonomous_reaper import AutonomousReaper
                reaper = AutonomousReaper()
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                result = loop.run_until_complete(reaper.run_cycle())
                loop.close()
                logger.info("✅ Scheduled autonomous reaper cycle finished successfully.")
                self._send_json(200, {"success": True, "reaper_result": result})
            except Exception as e:
                logger.error(f"Error in /cron/reap: {type(e).__name__}")
                self._send_json(500, {"success": False, "error": "Reaper cycle failed"})
        else:
            self._send_json(404, {"error": "Not Found"})

    def do_POST(self):
        if self.path == "/telegram":
            # chat_id di body bisa dipalsukan; hanya secret header dari Telegram yang membuktikan pengirim.
            tg_secret = os.getenv("TELEGRAM_WEBHOOK_SECRET", "")
            if not tg_secret:
                logger.error("🚨 /telegram ditolak: TELEGRAM_WEBHOOK_SECRET belum dikonfigurasi.")
                self._send_json(503, {"error": "Endpoint not configured"})
                return
            header_token = self.headers.get("X-Telegram-Bot-Api-Secret-Token", "")
            if not _secret_equal(header_token, tg_secret):
                logger.warning("❌ Unauthorized Telegram webhook attempt (invalid secret token)")
                self._send_json(403, {"error": "Unauthorized"})
                return

            body = self._read_body()
            if body is None:
                return
            try:
                data = json.loads(body)
                message = data.get("message", {})
                chat = message.get("chat", {})
                chat_id = chat.get("id")
                text = message.get("text", "")
                
                if chat_id and text:
                    handle_telegram_command(text, chat_id)
                self._send_json(200, {"ok": True})
            except Exception as e:
                logger.error(f"Error handling Telegram webhook POST: {type(e).__name__}")
                self._send_json(500, {"error": "Internal server error"})
            return

        if self.path != "/webhook":
            self._send_json(404, {"error": "Not Found"})
            return

        body = self._read_body()
        if body is None:
            return
        try:
            payload = json.loads(body)
        except (json.JSONDecodeError, UnicodeDecodeError):
            self._send_json(400, {"error": "Invalid JSON"})
            return
        if not isinstance(payload, dict):
            self._send_json(400, {"error": "Invalid JSON"})
            return

        # Verifikasi token Akal (ada di dalam body JSON) atau internal secret
        internal_secret = self.headers.get("X-Internal-Secret", "")
        EXPECTED_INTERNAL_SECRET = os.getenv("INTERNAL_SECRET", "")
        
        is_test_event = payload.get("event") == "test"
        is_authorized_internal = bool(EXPECTED_INTERNAL_SECRET) and _secret_equal(internal_secret, EXPECTED_INTERNAL_SECRET)
        
        # The dashboard "test" event carries no billing data; it is answered
        # with a fixed reply but must still present the webhook token.
        if not is_authorized_internal and not verify_akal_token(payload):
            logger.warning("Token tidak valid; request ditolak dari %s.", self.client_address[0])
            self._send_json(401, {"error": "Invalid token"})
            return
        if is_test_event:
            self._send_json(200, {"success": True, "action": "test_connection"})
            return

        # Proses webhook (async)
        try:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            result = loop.run_until_complete(process_webhook(payload, internal=is_authorized_internal))
            loop.close()
        except Exception as e:
            logger.exception("❌ Exception saat proses webhook: %s", e)
            send_telegram_message(f"🚨 <b>[ERROR SERVER]</b>\nProses webhook gagal: <code>{escape_html(str(e))}</code>")
            # KRITIS: Return 500 agar Akal tahu harus retry, BUKAN 200!
            self._send_json(500, {"success": False, "error": "Internal server error"})
            return

        # Return 200 HANYA jika sukses, 500 jika gagal
        if result.get("success", False):
            self._send_json(200, result)
        else:
            self._send_json(500, result)


# ─────────────────────────────────────────────────────────────
# ENTRY POINT
# ─────────────────────────────────────────────────────────────
def run_server():
    logger.info("=" * 60)
    logger.info("🚀 OpenTurath Subscription Automation")
    logger.info("=" * 60)
    logger.info("🌐 Port        : %d", SERVER_PORT)
    logger.info("🔑 Secret set  : %s", "✅ Ya" if AKAL_WEBHOOK_SECRET else "❌ Tidak — semua webhook ditolak")
    logger.info("")
    logger.info("📦 Modul di katalog bersama:")
    for scope in shared_registry.all_scopes():
        logger.info("  ✅ %-22s → %d notebook master", scope, len(shared_registry.masters_for_scope(scope)))
    logger.info("🛡️ VIP permanen di registry: %d", len(shared_registry.vip_emails()))
    logger.info("")
    logger.info("📍 Endpoint  : POST http://0.0.0.0:%d/webhook", SERVER_PORT)
    logger.info("📍 Health    : GET  http://0.0.0.0:%d/health", SERVER_PORT)
    logger.info("=" * 60)

    # Threaded so a slow NotebookLM call cannot block health checks or other webhooks.
    server = ThreadingHTTPServer(("0.0.0.0", SERVER_PORT), WebhookHandler)
    server.daemon_threads = True
    
    # Register Telegram Webhook if SERVICE_URL is configured
    service_url = os.getenv("SERVICE_URL")
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    tg_secret = os.getenv("TELEGRAM_WEBHOOK_SECRET", "")
    if service_url and token and not tg_secret:
        logger.warning("⚠️ TELEGRAM_WEBHOOK_SECRET belum diset — webhook Telegram tidak didaftarkan.")
    if service_url and token and tg_secret:
        webhook_url = f"{service_url.rstrip('/')}/telegram"
        try:
            # secret_token membuat Telegram mengirim header X-Telegram-Bot-Api-Secret-Token.
            register_url = (
                f"https://api.telegram.org/bot{token}/setWebhook"
                f"?url={urllib.parse.quote(webhook_url, safe='')}"
                f"&secret_token={urllib.parse.quote(tg_secret, safe='')}"
            )
            req = urllib.request.Request(register_url)
            with urllib.request.urlopen(req, timeout=10) as response:
                res_data = json.loads(response.read().decode("utf-8"))
                if res_data.get("ok"):
                    logger.info(f"🤖 Telegram Webhook registered to: {webhook_url}")
                else:
                    logger.warning(f"⚠️ Gagal register Telegram Webhook: {res_data}")
        except Exception as e:
            logger.error(f"Error registering Telegram Webhook: {e}")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("🛑 Server dihentikan.")


if __name__ == "__main__":
    run_server()
