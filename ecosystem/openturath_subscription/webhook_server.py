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

import asyncio
import hashlib
import hmac
import json
import os
import sys

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

import asyncio
import hashlib
import hmac
import json
import logging
import datetime
from google.cloud import firestore

# Tambahkan notebooklm-py ke path
NOTEBOOKLM_PY_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "notebooklm-py", "src")
sys.path.insert(0, os.path.abspath(NOTEBOOKLM_PY_PATH))

import notebooklm_manager as nlm
from http.server import BaseHTTPRequestHandler, HTTPServer

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

# Mapping: nama service/kelas di Akal → list dari notebook_id di NotebookLM
# Nama harus PERSIS SAMA dengan nama kelas di goakal.com
# Notebook ID dari URL: notebooklm.google.com/notebook/<NOTEBOOK_ID>
PRODUCT_TO_NOTEBOOKS: dict[str, list[str]] = {
    "AI Fikih Tahawwulat": [
        os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUHAQQIQ", "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4"),
        os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_BAYAN", "483d0291-0a70-411c-bff0-f1ea4b83b2fd"),
        os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_MUKHTABIR", "ac61a7a0-87e7-42a5-a30f-980ff74a78d8"),
        os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_HABIB", "6673e79a-7156-42e1-b116-bc1653a32094"),
        os.getenv("NOTEBOOK_ID_FIKIH_TAHAWWULAT_AL_KHATIB", "1288e413-9569-47a3-892f-64008e53c1e8"),
    ],
    "SUPER AI FIKIH SYAFI'I": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "AI Fikih Syafi'i": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "Fikih Syafi'i": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "AI Fikih Hanafi": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "Fikih Hanafi": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "AI Fikih Maliki": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "Fikih Maliki": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "AI Fikih Hanbali": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "Fikih Hanbali": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "AI Fikih Perbandingan Mazhab": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "Fikih Perbandingan Mazhab": [os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")],
    "AI Ushul Fiqih": [os.getenv("NOTEBOOK_ID_USHUL_FIQIH", "6ab6dae8-0067-435a-85ca-b6bd4e17dd12")],
    "Ushul Fiqih": [os.getenv("NOTEBOOK_ID_USHUL_FIQIH", "6ab6dae8-0067-435a-85ca-b6bd4e17dd12")],
    "AI Hadits": [os.getenv("NOTEBOOK_ID_HADITS", "b9626501-538c-4358-a44f-6731eaec50b6")],
    "Hadits": [os.getenv("NOTEBOOK_ID_HADITS", "b9626501-538c-4358-a44f-6731eaec50b6")],
    "AI Tafsir": [os.getenv("NOTEBOOK_ID_TAFSIR", "df92cc50-1106-4221-8748-1663f00fa7fe")],
    "Tafsir": [os.getenv("NOTEBOOK_ID_TAFSIR", "df92cc50-1106-4221-8748-1663f00fa7fe")],
    "AI Bahasa Arab": [os.getenv("NOTEBOOK_ID_BAHASA_ARAB", "15bc4cef-4b94-4241-b05a-d50a586bde06")],
    "Bahasa Arab": [os.getenv("NOTEBOOK_ID_BAHASA_ARAB", "15bc4cef-4b94-4241-b05a-d50a586bde06")],
    "Paket Semua AI": [
        "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "ac61a7a0-87e7-42a5-a30f-980ff74a78d8",
        "6673e79a-7156-42e1-b116-bc1653a32094",
        "1288e413-9569-47a3-892f-64008e53c1e8",
        "334e7b83-0e76-4787-a1d6-314642a35862",
        "6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
        "df92cc50-1106-4221-8748-1663f00fa7fe",
        "b9626501-538c-4358-a44f-6731eaec50b6",
        "15bc4cef-4b94-4241-b05a-d50a586bde06",
    ],
    "all_ai": [
        "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "ac61a7a0-87e7-42a5-a30f-980ff74a78d8",
        "6673e79a-7156-42e1-b116-bc1653a32094",
        "1288e413-9569-47a3-892f-64008e53c1e8",
        "334e7b83-0e76-4787-a1d6-314642a35862",
        "6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
        "df92cc50-1106-4221-8748-1663f00fa7fe",
        "b9626501-538c-4358-a44f-6731eaec50b6",
        "15bc4cef-4b94-4241-b05a-d50a586bde06",
    ],
    "all_access": [
        "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        "ac61a7a0-87e7-42a5-a30f-980ff74a78d8",
        "6673e79a-7156-42e1-b116-bc1653a32094",
        "1288e413-9569-47a3-892f-64008e53c1e8",
        "334e7b83-0e76-4787-a1d6-314642a35862",
        "6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
        "df92cc50-1106-4221-8748-1663f00fa7fe",
        "b9626501-538c-4358-a44f-6731eaec50b6",
        "15bc4cef-4b94-4241-b05a-d50a586bde06",
    ],
}

PERMANENT_VIP_EMAILS: set[str] = {
    "openturath@gmail.com",
    "ramah@ptct.net",
    "raflimaulan@gmail.com",
    "mas.raflihusen@gmail.com",
    "alkhateeb23@gmail.com",
    "omarasb1441@gmail.com",
    "prilatief@gmail.com",
}

# Mapping: nama service/kelas di Akal / DOKU → key entitlement di database Firestore
PRODUCT_TO_ENTITLEMENT_KEY: dict[str, str] = {
    "AI Fikih Tahawwulat": "fiqh_tahawwulat",
    "SUPER AI FIKIH SYAFI'I": "fiqh_syafii",
    "AI Fikih Syafi'i": "fiqh_syafii",
    "Fikih Syafi'i": "fiqh_syafii",
    "AI Fikih Hanafi": "fiqh_hanafi",
    "Fikih Hanafi": "fiqh_hanafi",
    "AI Fikih Maliki": "fiqh_maliki",
    "Fikih Maliki": "fiqh_maliki",
    "AI Fikih Hanbali": "fiqh_hanbali",
    "Fikih Hanbali": "fiqh_hanbali",
    "AI Fikih Perbandingan Mazhab": "fiqh_muqaran",
    "Fikih Perbandingan Mazhab": "fiqh_muqaran",
    "AI Ushul Fiqih": "ushul_fiqh",
    "Ushul Fiqih": "ushul_fiqh",
    "AI Hadits": "hadits",
    "AI Tafsir": "tafsir",
    "AI Nahwu": "nahwu",
    "AI Bahasa Arab": "nahwu",
    "Paket Semua AI": "all_access",
    "all_ai": "all_access",
    "all_access": "all_access",
}

# Status Akal → Aksi NotebookLM
# Ref: https://goakal.com/docs/developer/webhook
ACTIVE_STATUSES   = {"PAID", "SETTLED"}                       # → tambah akses
INACTIVE_STATUSES = {"EXPIRED", "FAILED", "CANCELLED"}        # → hapus akses
IGNORED_STATUSES  = {"PENDING"}                                # → abaikan

SERVER_PORT = int(os.getenv("PORT", "8080"))


# ─────────────────────────────────────────────────────────────
# VERIFIKASI TOKEN AKAL
# ─────────────────────────────────────────────────────────────
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

    is_valid = hmac.compare_digest(AKAL_WEBHOOK_SECRET, payload_token)
    if not is_valid:
        logger.warning("🚨 Token tidak cocok! Expected: %s..., Got: %s...",
                       AKAL_WEBHOOK_SECRET[:8], payload_token[:8])
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

def process_firestore_updates(email: str, name: str, plan: str, duration_months: int, amount: float, transaction_id: str, is_active: bool, service_name: str, paid_at_str: str = ""):
    db = get_firestore_client()
    if not db:
        logger.warning("Firestore client not available. Skipping Firestore update.")
        raise RuntimeError("Firestore client not available")

    # Tentukan entitlement key berdasarkan mapping nama produk Akal
    entitlement_key = "fiqh_tahawwulat" # default fallback
    for p_name, e_key in PRODUCT_TO_ENTITLEMENT_KEY.items():
        if p_name.lower() in service_name.lower() or service_name.lower() in p_name.lower():
            entitlement_key = e_key
            break

    # ── IDEMPOTENCY CHECK: Jika transaksi ini sudah pernah diproses, skip ──
    if transaction_id:
        existing_trx = db.collection("transactions").document(transaction_id).get()
        if existing_trx.exists:
            existing_data = existing_trx.to_dict()
            existing_status = existing_data.get("status", "")
            logger.info(f"⏭️  Transaksi {transaction_id} sudah ada (status: {existing_status}). Idempotent skip.")
            return  # Sudah pernah diproses, jangan proses ulang
    else:
        logger.warning("⚠️  Webhook tanpa transaction_id — tidak bisa menjamin idempotency!")
        
    try:
        # Calculate expiry berdasarkan paidAt dari Akal, BUKAN waktu server
        now = datetime.datetime.now(datetime.timezone.utc)
        
        # Parse paidAt dari payload Akal
        base_date = now  # fallback ke now jika paidAt tidak tersedia
        if paid_at_str:
            try:
                # Coba parse ISO format dari Akal
                base_date = datetime.datetime.fromisoformat(paid_at_str.replace('Z', '+00:00'))
                logger.info(f"Using paidAt from Akal: {base_date}")
            except (ValueError, TypeError):
                logger.warning(f"Cannot parse paidAt '{paid_at_str}', using server time")
        
        expiry_date = base_date + datetime.timedelta(days=30 * duration_months)
        
        # 1. Write transaction record (idempotent: set with merge)
        trx_ref = db.collection("transactions").document(transaction_id) if transaction_id else db.collection("transactions").document()
        if is_active:
            trx_ref.set({
                "customer_email": email.strip().lower(),
                "customer_name": name,
                "plan": plan,
                "amount": amount,
                "duration_months": duration_months,
                "status": "success",
                "source": "akal",
                "service_name": service_name,
                "entitlement_key": entitlement_key,
                "paid_at": base_date,
                "processed_at": now,
                "created_at": now,
                "completed_at": now,
                "subscription_expires_at": expiry_date
            })
            logger.info(f"Saved successful Akal transaction {transaction_id} to Firestore.")
        else:
            trx_ref.set({
                "customer_email": email.strip().lower(),
                "customer_name": name,
                "plan": plan,
                "amount": amount,
                "duration_months": duration_months,
                "status": "expired",
                "source": "akal",
                "service_name": service_name,
                "entitlement_key": entitlement_key,
                "processed_at": now,
                "created_at": now,
                "completed_at": now,
                "subscription_expires_at": now
            })
            logger.info(f"Saved expired Akal transaction {transaction_id} to Firestore.")
            
        # 2. Update user if user already exists
        users_ref = db.collection("users")
        query = users_ref.where("email", "==", email.strip().lower()).limit(1).stream()
        user_doc = None
        for doc in query:
            user_doc = doc
            break
            
        if user_doc:
            if is_active:
                # Untuk renewal: gunakan max(current_expiry, paidAt) + duration
                current_data = user_doc.to_dict()
                
                # Check current expiry dari map entitlements per-produk
                current_expiry = None
                entitlements_map = current_data.get("entitlements", {})
                if isinstance(entitlements_map, dict) and entitlement_key in entitlements_map:
                    product_entitlement = entitlements_map[entitlement_key]
                    if isinstance(product_entitlement, dict):
                        current_expiry = product_entitlement.get("expiry")
                
                # Fallback ke global expiry jika model lama
                if not current_expiry:
                    current_expiry = current_data.get("subscription_expiry")

                if current_expiry:
                    try:
                        current_expiry_dt = current_expiry if isinstance(current_expiry, datetime.datetime) else current_expiry.replace(tzinfo=datetime.timezone.utc)
                        if current_expiry_dt > base_date:
                            # User masih aktif, perpanjang dari expiry yang ada
                            expiry_date = current_expiry_dt + datetime.timedelta(days=30 * duration_months)
                            logger.info(f"Renewal detected: extending from {current_expiry_dt} to {expiry_date}")
                    except (AttributeError, TypeError):
                        pass  # Gunakan expiry_date yang sudah dihitung
                
                # Update data model entitlements terstruktur dan model flat lama (kompatibilitas)
                user_doc.reference.update({
                    "plan": plan, # legacy flat
                    "subscription_expiry": expiry_date, # legacy flat
                    f"entitlements.{entitlement_key}": {
                        "plan": plan,
                        "expiry": expiry_date,
                        "updated_at": now
                    },
                    "questions_used": 0
                })
                logger.info(f"Updated Firestore user {email} entitlements.{entitlement_key} to {plan} expiring {expiry_date}")
            else:
                # PENTING: Jangan langsung cabut jika masih ada transaksi aktif lain untuk produk ini!
                trx_docs = db.collection("transactions") \
                    .where("customer_email", "==", email.strip().lower()) \
                    .where("status", "in", ["success", "PAID", "SETTLED"]) \
                    .stream()
                has_active = False
                for t in trx_docs:
                    td = t.to_dict()
                    t_key = td.get("entitlement_key")
                    t_exp = td.get("subscription_expires_at") or td.get("expires_at")
                    if isinstance(t_exp, datetime.datetime):
                        t_exp_dt = t_exp if t_exp.tzinfo else t_exp.replace(tzinfo=datetime.timezone.utc)
                    elif isinstance(t_exp, str):
                        try:
                            t_exp_dt = datetime.datetime.fromisoformat(t_exp.replace("Z", "+00:00"))
                        except Exception:
                            t_exp_dt = None
                    else:
                        t_exp_dt = None
                    
                    if t_exp_dt and t_exp_dt > now and (t_key in [entitlement_key, "all_access", "all_ai", None]):
                        has_active = True
                        break
                
                if has_active:
                    logger.info(f"User {email} masih memiliki transaksi aktif lain untuk {entitlement_key}. Tidak mencabut subscription.")
                else:
                    # Update status per-produk menjadi trial/expired
                    user_doc.reference.update({
                        # Untuk flat legacy, kita reset jika sudah tidak ada active plan sama sekali
                        "plan": "trial",
                        "subscription_expiry": None,
                        f"entitlements.{entitlement_key}": {
                            "plan": "trial",
                            "expiry": None,
                            "updated_at": now
                        },
                        "questions_used": 0
                    })
                    logger.info(f"Updated Firestore user {email} entitlements.{entitlement_key} to trial (expired)")
        else:
            logger.info(f"User {email} not found in Firestore yet. It will be linked when they register.")
            
    except Exception as e:
        logger.error(f"Error updating Firestore for Akal webhook: {e}")
        raise  # Propagasi error agar webhook mengembalikan 500 ke Akal


# ─────────────────────────────────────────────────────────────
# PROSES WEBHOOK
# ─────────────────────────────────────────────────────────────
async def process_webhook(payload: dict) -> dict:
    """Proses satu webhook event dari Akal."""
    event = payload.get("event", "")
    
    # Tangani test event khusus dari dashboard Akal
    if event == "test":
        logger.info("🧪 Test webhook diterima dari Akal. Membalas sukses.")
        return {"success": True, "action": "test_connection", "message": "Connection test successful"}

    email, user_name, service_name, status, price_scheme_name, amount, transaction_id, paid_at_str = parse_akal_payload(payload)

    logger.info(
        "📨 Webhook | event=%-25s | status=%-10s | email=%-35s | service=%s",
        event, status, email, service_name,
    )

    # ── Validasi field wajib ──
    if not email:
        logger.error("❌ Payload tidak memiliki user.email")
        return {"success": False, "error": "user.email kosong"}

    if not service_name:
        logger.error("❌ Payload tidak memiliki service.name")
        return {"success": False, "error": "service.name kosong"}

    # ── Cari notebook_ids dari mapping ──
    notebook_ids = PRODUCT_TO_NOTEBOOKS.get(service_name)
    if not notebook_ids:
        # Coba partial match (case-insensitive) sebagai fallback
        for key, nids in PRODUCT_TO_NOTEBOOKS.items():
            if key.lower() in service_name.lower() or service_name.lower() in key.lower():
                notebook_ids = nids
                logger.info("   ℹ️  Partial match: '%s' → '%s'", service_name, key)
                break

    if not notebook_ids:
        logger.error(
            "❌ Produk '%s' tidak terdaftar di PRODUCT_TO_NOTEBOOKS. Transaksi dikarantina (fail-closed).",
            service_name,
        )
        return {"success": False, "error": f"Produk '{service_name}' tidak terdaftar"}

    # Filter out empty notebook IDs
    notebook_ids = [nid for nid in notebook_ids if nid]
    if not notebook_ids:
        return {"success": True, "action": "ignored_empty_notebook_ids"}

    # Determine plan and duration from price scheme & service
    plan, duration_months = determine_plan_and_expiry(price_scheme_name, service_name)

    # ── Routing berdasarkan status ──
    if status in ACTIVE_STATUSES:
        logger.info("   ✅ TAMBAH akses: %s → %s (%d notebook)", email, service_name, len(notebook_ids))
        
        # 1. Update Firestore
        process_firestore_updates(email, user_name, plan, duration_months, amount, transaction_id, is_active=True, service_name=service_name, paid_at_str=paid_at_str)
        
        # 2. Add viewer to NotebookLM secara otomatis
        results = []
        for nid in notebook_ids:
            res = await nlm.add_viewer(nid, email, user_name)
            results.append(res)
            await asyncio.sleep(1.0)
            
        success = all(r.get("success", False) for r in results)
        
        # Kirim notifikasi Telegram
        msg = (
            f"🔔 <b>[AKSES DITAMBAHKAN]</b>\n"
            f"🕌 OpenTurath AI\n"
            f"📧 Email: <code>{email}</code>\n"
            f"👤 Nama: <b>{user_name or 'N/A'}</b>\n"
            f"📦 Produk: <b>{service_name}</b>\n"
            f"🏷️ Plan: <b>{plan.upper()}</b> ({duration_months} bln)\n"
            f"💰 Nominal: <code>Rp {amount:,.0f}</code>\n"
            f"🆔 Trx: <code>{transaction_id}</code>\n"
            f"✅ Status: {'Sukses' if success else 'Gagal'} terdaftar di {len(notebook_ids)} notebook."
        )
        send_telegram_message(msg)
        
        return {"success": success, "action": "provisioned", "results": results}

    elif status in INACTIVE_STATUSES:
        if email.strip().lower() in PERMANENT_VIP_EMAILS:
            logger.info("🛡️ SKIP CABUT AKSES: %s adalah OWNER / PERMANENT VIP. Akses abadi dijamin.", email)
            return {"success": True, "action": "ignored_permanent_vip"}
        logger.info("   ❌ CABUT akses: %s ← %s (%d notebook)", email, service_name, len(notebook_ids))
        
        # 1. Update Firestore
        process_firestore_updates(email, user_name, plan, duration_months, amount, transaction_id, is_active=False, service_name=service_name, paid_at_str=paid_at_str)
        
        # 2. Remove viewer dari NotebookLM secara otomatis
        results = []
        for nid in notebook_ids:
            res = await nlm.remove_viewer(nid, email)
            results.append(res)
            await asyncio.sleep(1.0)
            
        success = all(r.get("success", False) for r in results)
        
        # Kirim notifikasi Telegram
        msg = (
            f"⚠️ <b>[AKSES DICABUT]</b>\n"
            f"🕌 OpenTurath AI\n"
            f"📧 Email: <code>{email}</code>\n"
            f"📦 Produk: <b>{service_name}</b>\n"
            f"❌ Status: Akses dicabut ({status.upper()})."
        )
        send_telegram_message(msg)
        
        return {"success": success, "action": "deprovisioned", "results": results}

    elif status in IGNORED_STATUSES:
        logger.info("   ⏭️  Status '%s' diabaikan (PENDING = belum bayar)", status)
        return {"success": True, "action": "ignored", "status": status}

    else:
        logger.warning("   ❓ Status '%s' tidak dikenali, diabaikan.", status)
        return {"success": True, "action": "unknown_status", "status": status}



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
    if entitlement_key == "fiqh_tahawwulat":
        return True
    elif entitlement_key == "fiqh_syafii":
        nid = os.getenv("NOTEBOOK_ID_FIKIH_SYAFII", "334e7b83-0e76-4787-a1d6-314642a35862")
        return bool(nid) and "paste_notebook_id" not in nid
    elif entitlement_key == "nahwu":
        nid = os.getenv("NOTEBOOK_ID_BAHASA_ARAB", "")
        return bool(nid) and "paste_notebook_id" not in nid
    elif entitlement_key == "hadits":
        nid = os.getenv("NOTEBOOK_ID_HADITS", "")
        return bool(nid) and "paste_notebook_id" not in nid
    elif entitlement_key == "tafsir":
        nid = os.getenv("NOTEBOOK_ID_TAFSIR", "")
        return bool(nid) and "paste_notebook_id" not in nid
    return False

def handle_telegram_command(text: str, chat_id: int):
    # Check if the chat ID is authorized
    EXPECTED_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID", "")
    if str(chat_id) != EXPECTED_CHAT_ID:
        send_telegram_message(f"⚠️ Akses ditolak untuk Chat ID: {chat_id}")
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
        send_telegram_message("🔄 <b>[REAPER]</b> Memulai siklus pemindaian dan sinkronisasi otomatis...")
        try:
            from autonomous_reaper import AutonomousReaper
            reaper = AutonomousReaper()
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            result = loop.run_until_complete(reaper.run_cycle())
            loop.close()
            send_telegram_message(f"✅ <b>[REAPER SELESAI]</b>\n• User Sah Terdaftar: <code>{result['authorized_count']}</code>\n• Akses Expired Dicabut: <code>{result['revoked_count']}</code>\n• Error: <code>{result['errors']}</code>")
        except Exception as e:
            send_telegram_message(f"❌ <b>[REAPER ERROR]</b> Gagal: {e}")
        
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
            
            KEY_TO_HUMAN_NAME = {
                "fiqh_tahawwulat": "AI Fikih Tahawwulat",
                "fiqh_syafii": "Super AI Fikih Syafi'i",
                "nahwu": "AI Bahasa Arab",
                "hadits": "AI Hadits",
                "tafsir": "AI Tafsir"
            }
            
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
                    service_name = data.get("service_name", "").lower()
                    if "bahasa" in service_name or "nahwu" in service_name or "arab" in service_name:
                        ent_key = "nahwu"
                    else:
                        ent_key = "fiqh_tahawwulat"
                        
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
                f"👤 Nama: <b>{customer_name}</b>\n"
                f"📧 Email: <code>{email}</code>\n"
                f"📱 Status: <i>{reg_status}</i>\n"
                f"💬 Pertanyaan Digunakan: <code>{questions_used}</code>\n\n"
                f"📂 <b>Kategori Langganan AI:</b>\n"
                f"{ent_details or '  • Tidak ada modul aktif'}"
                f"──────────────────────"
            )
            send_telegram_message(status_msg)
        except Exception as e:
            send_telegram_message(f"❌ Gagal mengambil data: {str(e)}")
            
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
            
            KEY_TO_HUMAN_NAME = {
                "fiqh_tahawwulat": "AI Fikih Tahawwulat",
                "fiqh_syafii": "Super AI Fikih Syafi'i",
                "nahwu": "AI Bahasa Arab",
                "hadits": "AI Hadits",
                "tafsir": "AI Tafsir"
            }
            
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
                        service_name = data.get("service_name", "").lower()
                        if "bahasa" in service_name or "nahwu" in service_name or "arab" in service_name:
                            ent_key = "nahwu"
                        else:
                            ent_key = "fiqh_tahawwulat"
                            
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
                        f"👤 <b>{display_name}</b>\n"
                        f"📧 Email: <code>{email}</code>\n"
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
            send_telegram_message(f"❌ Gagal mengambil daftar pengguna: {str(e)}")
            
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

    def log_message(self, format, *args):
        pass  # Matikan default HTTP server logging

    def _send_json(self, code: int, data: dict):
        body = json.dumps(data).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            configured = {k: bool(v) for k, v in PRODUCT_TO_NOTEBOOKS.items()}
            self._send_json(200, {
                "status": "ok",
                "service": "OpenTurath Subscription Automation",
                "products_configured": configured,
                "webhook_secret_set": bool(AKAL_WEBHOOK_SECRET),
            })
        elif self.path == "/keepalive":
            cron_secret = os.getenv("CRON_SECRET", "")
            if cron_secret:
                auth_header = self.headers.get("Authorization", "")
                param_secret = self.headers.get("X-Cron-Secret", "")
                if not (auth_header == f"Bearer {cron_secret}" or param_secret == cron_secret):
                    self._send_json(401, {"error": "Unauthorized keepalive trigger"})
                    return
            try:
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                
                # Cari notebook ID pertama yang valid untuk test ping
                notebook_id = ""
                for nids in PRODUCT_TO_NOTEBOOKS.values():
                    for nid in nids:
                        if nid:
                            notebook_id = nid
                            break
                    if notebook_id:
                        break
                
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
                self._send_json(500, {"success": False, "error": str(e)})
        elif self.path.startswith("/cron/reap"):
            cron_secret = os.getenv("CRON_SECRET", "") or os.getenv("INTERNAL_SECRET", "")
            if cron_secret:
                auth_header = self.headers.get("Authorization", "")
                param_secret = self.headers.get("X-Cron-Secret", "") or self.headers.get("X-Internal-Secret", "")
                is_authorized = (
                    auth_header == f"Bearer {cron_secret}" or 
                    param_secret == cron_secret or
                    hmac.compare_digest(param_secret, cron_secret)
                )
                if not is_authorized:
                    logger.warning("🚨 Unauthorized /cron/reap attempt")
                    self._send_json(401, {"error": "Unauthorized cron trigger"})
                    return
            try:
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
                logger.error(f"❌ Error in /cron/reap: {e}")
                self._send_json(500, {"success": False, "error": str(e)})
        else:
            self._send_json(404, {"error": "Not Found"})

    def do_POST(self):
        if self.path == "/telegram":
            tg_secret = os.getenv("TELEGRAM_WEBHOOK_SECRET", "")
            if tg_secret:
                header_token = self.headers.get("X-Telegram-Bot-Api-Secret-Token", "")
                if not hmac.compare_digest(header_token, tg_secret):
                    logger.warning("❌ Unauthorized Telegram webhook attempt (invalid secret token)")
                    self._send_json(403, {"error": "Unauthorized"})
                    return

            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
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
                logger.error(f"Error handling Telegram webhook POST: {e}")
                self._send_json(500, {"error": str(e)})
            return

        if self.path != "/webhook":
            self._send_json(404, {"error": "Not Found"})
            return

        # Baca body
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length)

        # Parse JSON body terlebih dahulu untuk mendeteksi 'test' event
        try:
            payload = json.loads(body)
        except json.JSONDecodeError as e:
            logger.error("❌ JSON tidak valid: %s", e)
            self._send_json(400, {"error": "Invalid JSON"})
            return

        # Verifikasi token Akal (ada di dalam body JSON) atau internal secret
        internal_secret = self.headers.get("X-Internal-Secret", "")
        EXPECTED_INTERNAL_SECRET = os.getenv("INTERNAL_SECRET", "")
        
        is_test_event = payload.get("event") == "test"
        is_authorized_internal = EXPECTED_INTERNAL_SECRET and internal_secret == EXPECTED_INTERNAL_SECRET
        
        if not is_test_event and not is_authorized_internal and not verify_akal_token(payload):
            logger.warning("🚨 Token tidak valid! Request ditolak dari %s. Event: %s",
                          self.client_address, payload.get('event', 'unknown'))
            self._send_json(401, {"error": "Invalid token"})
            return


        # Proses webhook (async)
        try:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            result = loop.run_until_complete(process_webhook(payload))
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
    logger.info("🔑 Secret set  : %s", "✅ Ya" if AKAL_WEBHOOK_SECRET else "❌ Tidak (dev mode)")
    logger.info("")
    logger.info("📦 Produk yang dikonfigurasi:")
    for name, nids in PRODUCT_TO_NOTEBOOKS.items():
        nids = [nid for nid in nids if nid]
        if nids:
            logger.info("  ✅ %-30s → %d notebooks", name, len(nids))
        else:
            logger.info("  ❌ %-30s → BELUM DIKONFIGURASI", name)
    logger.info("")
    logger.info("📍 Endpoint  : POST http://0.0.0.0:%d/webhook", SERVER_PORT)
    logger.info("📍 Health    : GET  http://0.0.0.0:%d/health", SERVER_PORT)
    logger.info("=" * 60)

    server = HTTPServer(("0.0.0.0", SERVER_PORT), WebhookHandler)
    
    # Register Telegram Webhook if SERVICE_URL is configured
    service_url = os.getenv("SERVICE_URL")
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    if service_url and token:
        webhook_url = f"{service_url.rstrip('/')}/telegram"
        try:
            register_url = f"https://api.telegram.org/bot{token}/setWebhook?url={urllib.parse.quote(webhook_url)}"
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
