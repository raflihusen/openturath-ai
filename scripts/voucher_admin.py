#!/usr/bin/env python3
"""
voucher_admin.py
================
Alat resmi pembuat dan pengelola kode voucher OpenTurath (koleksi Firestore
`redeem_codes`). Aturan yang diperiksa di sini sama dengan yang dipaksakan
fungsi `redeemCode`, sehingga kode yang dibuat tidak diam-diam gagal ditukar.

  python3 scripts/voucher_admin.py create --all --days 30 --max-uses 50 --note "Kelas Ramadan"
  python3 scripts/voucher_admin.py create --keys fiqh_syafii,hadits --days 14 --count 5
  python3 scripts/voucher_admin.py create --type honor --all --days 365 --prefix ASATIDZ
  python3 scripts/voucher_admin.py bonus --feed --ig @namaakun --apply     # bonus testimoni 7 hari
  python3 scripts/voucher_admin.py bonus --story --ig @namaakun --apply    # bonus story 3 hari
  python3 scripts/voucher_admin.py limit KODE 150                          # ubah batas pemakaian
  python3 scripts/voucher_admin.py list
  python3 scripts/voucher_admin.py report KODE
  python3 scripts/voucher_admin.py deactivate KODE

`create` hanya mencetak rencana (dry-run); tambahkan `--apply` untuk menulis ke
Firestore. Menonaktifkan kode hanya menutup penukaran berikutnya. Akses yang
sudah diberikan sengaja tidak dicabut otomatis, agar akses sah dan akun VIP
tidak terkena; pencabutan per akun dilakukan lewat alur pengelolaan akses.
"""
import argparse
import json
import re
import secrets
import subprocess
import sys
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone

PROJECT_ID = "open-turath"
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

# Cermin SCOPE_LABELS di functions/src/access_catalog.ts. Menambah AI baru berarti
# menambahkannya di sana dan di sini; kunci di luar daftar ini ditolak server.
KNOWN_SCOPES = [
    "all_access", "fiqh_tahawwulat", "fiqh_syafii", "fiqh_hanafi", "fiqh_maliki",
    "fiqh_hanbali", "fiqh_muqaran", "fiqh", "ushul_fiqh", "tafsir", "hadits", "nahwu",
    "aqidah", "tarikh", "tasawwuf", "bibliografi_faharis",
]
# Server memperlakukan awalan ini sebagai kode coba (terikat perangkat dan akun).
TRIAL_PREFIXES = ("PERDANA", "TRIAL", "WELCOME")
# Tanpa huruf/angka yang mudah tertukar (0/O, 1/I/L).
ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"
WIB = timezone(timedelta(hours=7))
# Paket bawaan untuk trial dan bonus testimoni: dua AI utama.
FLAGSHIP_KEYS = ["fiqh_tahawwulat", "fiqh_syafii"]
# Bonus testimoni: story hanya tampil 24 jam sehingga lebih singkat; unggahan feed,
# reel, atau grup komunitas bertahan lama sehingga lebih panjang.
BONUS_DAYS = {"story": 3, "feed": 7}
# Kode bonus harus ditukar dalam sekian hari sejak diterbitkan.
BONUS_REDEEM_WINDOW_DAYS = 7


class VoucherError(ValueError):
    pass


def generate_code(prefix: str = "", length: int = 10) -> str:
    return prefix + "".join(secrets.choice(ALPHABET) for _ in range(length))


def display(code: str) -> str:
    return "-".join(code[i:i + 4] for i in range(0, len(code), 4))


def build_voucher(keys, vtype="santri", days=7, max_uses=1, prefix="", expires=None, note="",
                  allow_long=False, code=None):
    """Mengembalikan (kode, dokumen). Melempar VoucherError bila melanggar aturan server."""
    keys = [k.strip() for k in keys if k.strip()]
    keys = ["all_access" if k == "all_ai" else k for k in keys]
    if not keys:
        raise VoucherError("Sebutkan AI: --keys a,b atau --all")
    unknown = [k for k in keys if k not in KNOWN_SCOPES]
    if unknown:
        raise VoucherError("Kunci AI tidak dikenal: " + ", ".join(unknown))
    keys = list(dict.fromkeys(keys))
    if vtype not in ("santri", "trial", "perdana", "honor"):
        raise VoucherError("--type harus santri, trial, perdana, atau honor")
    is_trial = vtype in ("trial", "perdana") or (prefix.upper().startswith(TRIAL_PREFIXES))
    long_ok = (allow_long or vtype == "honor") and not is_trial
    max_days = 400 if long_ok else 31
    if not isinstance(days, int) or days < 1 or days > max_days:
        raise VoucherError(f"--days harus 1..{max_days} untuk jenis ini"
                           + ("" if long_ok else " (pakai --type honor atau --long untuk lebih lama)"))
    if max_uses < 1:
        raise VoucherError("--max-uses minimal 1")
    prefix = prefix.upper()
    if prefix and not re.fullmatch(r"[A-Z0-9]{1,8}", prefix):
        raise VoucherError("--prefix hanya huruf/angka, maksimal 8 karakter")
    if prefix.startswith(TRIAL_PREFIXES) and vtype not in ("trial", "perdana"):
        raise VoucherError("Awalan PERDANA/TRIAL/WELCOME hanya untuk --type trial atau perdana")
    if code is None:
        code = generate_code(prefix)
    code = re.sub(r"[\s-]", "", code).upper()
    if not re.fullmatch(r"[A-Z0-9]{1,64}", code):
        raise VoucherError("Kode hanya boleh huruf besar dan angka (maksimal 64)")
    doc = {
        "is_active": True,
        "max_uses": max_uses,
        "times_used": 0,
        "duration_days": days,
        "type": vtype,
        "note": note,
        "created_by": "voucher_admin.py",
    }
    if len(keys) == 1:
        doc["entitlement_key"] = keys[0]
    else:
        doc["entitlement_keys"] = keys
    if long_ok and vtype != "honor":
        doc["allow_long_duration"] = True
    if vtype in ("trial", "perdana"):
        doc["one_per_device"] = True
        doc["is_trial"] = True
    if expires:
        try:
            end = datetime.strptime(expires, "%Y-%m-%d").replace(hour=23, minute=59, second=59, tzinfo=WIB)
        except ValueError:
            raise VoucherError("--expires harus berformat YYYY-MM-DD")
        doc["expires_at"] = end
    return code, doc


# ---------------- Firestore REST ----------------
def to_value(v):
    if isinstance(v, bool):
        return {"booleanValue": v}
    if isinstance(v, int):
        return {"integerValue": str(v)}
    if isinstance(v, datetime):
        return {"timestampValue": v.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")}
    if isinstance(v, list):
        return {"arrayValue": {"values": [to_value(x) for x in v]}}
    return {"stringValue": str(v)}


def from_value(v):
    for k, x in v.items():
        if k == "integerValue":
            return int(x)
        if k == "arrayValue":
            return [from_value(i) for i in x.get("values", [])]
        if k in ("stringValue", "booleanValue", "timestampValue"):
            return x
    return None


def token():
    try:
        return subprocess.check_output(["gcloud", "auth", "print-access-token"], text=True).strip()
    except Exception as e:  # noqa: BLE001
        sys.exit(f"Gagal mengambil token gcloud ({e}). Jalankan: gcloud auth login")


def call(method, url, tok, body=None):
    req = urllib.request.Request(url, method=method, data=json.dumps(body).encode() if body else None,
                                 headers={"Authorization": f"Bearer {tok}", "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        raise SystemExit(f"Firestore {e.code}: {e.read().decode()[:300]}")


def cmd_create(a):
    keys = ["all_access"] if a.all else (a.keys or "").split(",")
    plans = []
    for _ in range(a.count):
        plans.append(build_voucher(keys, a.type, a.days, a.max_uses, a.prefix or "", a.expires, a.note or "", a.long,
                                   a.code if a.count == 1 else None))
    for code, doc in plans:
        scope = doc.get("entitlement_keys") or [doc["entitlement_key"]]
        print(f"{display(code):<22} {','.join(scope)}  {doc['duration_days']} hari  x{doc['max_uses']}  {doc['type']}")
    if not a.apply:
        print("\nDry-run: belum ditulis. Tambahkan --apply untuk menyimpan ke Firestore.")
        return
    tok = token()
    for code, doc in plans:
        fields = {k: to_value(v) for k, v in {**doc, "created_at": datetime.now(timezone.utc)}.items()}
        call("POST", f"{BASE}/redeem_codes?documentId={code}", tok, {"fields": fields})
    print(f"\n{len(plans)} kode ditulis. Simpan daftar di atas; kode tidak bisa dibaca ulang dari aplikasi.")


def cmd_bonus(a):
    """Satu kode bonus sekali pakai untuk satu pengunggah testimoni."""
    kind = "story" if a.story else "feed"
    expires = (datetime.now(WIB) + timedelta(days=BONUS_REDEEM_WINDOW_DAYS)).strftime("%Y-%m-%d")
    note = f"Bonus testimoni {kind} {a.ig or '-'}"
    code, doc = build_voucher(FLAGSHIP_KEYS, "santri", BONUS_DAYS[kind], 1, "BAGI", expires, note)
    print(f"{display(code)}  {BONUS_DAYS[kind]} hari  sekali pakai  tukar sebelum {expires}  ({note})")
    if not a.apply:
        print("Dry-run: tambahkan --apply untuk menyimpan.")
        return
    tok = token()
    fields = {k: to_value(v) for k, v in {**doc, "created_at": datetime.now(timezone.utc)}.items()}
    call("POST", f"{BASE}/redeem_codes?documentId={code}", tok, {"fields": fields})
    print("Tersimpan. Kirim kode ini lewat DM ke pengunggah.")


def cmd_limit(a):
    code = re.sub(r"[\s-]", "", a.code).upper()
    if a.max_uses < 1:
        sys.exit("Batas minimal 1")
    call("PATCH", f"{BASE}/redeem_codes/{code}?updateMask.fieldPaths=max_uses", token(),
         {"fields": {"max_uses": {"integerValue": str(a.max_uses)}}})
    print(f"Batas pemakaian {display(code)} menjadi {a.max_uses}.")


def cmd_list(a):
    tok = token()
    data = call("GET", f"{BASE}/redeem_codes?pageSize=300", tok)
    for d in data.get("documents", []):
        f = {k: from_value(v) for k, v in d["fields"].items()}
        code = d["name"].rsplit("/", 1)[-1]
        scope = f.get("entitlement_keys") or [f.get("entitlement_key", "fiqh_syafii")]
        print(f"{display(code):<22} {'aktif' if f.get('is_active', True) else 'mati ':<5} "
              f"{f.get('times_used', 0)}/{f.get('max_uses', 1)}  {f.get('duration_days', 7)}h  {','.join(scope)}  {f.get('note', '')}")


def cmd_report(a):
    code = re.sub(r"[\s-]", "", a.code).upper()
    tok = token()
    doc = call("GET", f"{BASE}/redeem_codes/{code}", tok)
    f = {k: from_value(v) for k, v in doc["fields"].items()}
    print(json.dumps(f, ensure_ascii=False, indent=2))
    reds = call("GET", f"{BASE}/redeem_codes/{code}/redemptions?pageSize=300", tok)
    print(f"\nPenukaran: {len(reds.get('documents', []))}")
    for d in reds.get("documents", []):
        r = {k: from_value(v) for k, v in d["fields"].items()}
        email = r.get("email") or "-"
        masked = re.sub(r"^(.).*(@.*)$", r"\1***\2", email)
        print(f"  {d['name'].rsplit('/', 1)[-1][:8]}…  {masked}  {r.get('redeemed_at', '')}")


def cmd_deactivate(a):
    code = re.sub(r"[\s-]", "", a.code).upper()
    tok = token()
    call("PATCH", f"{BASE}/redeem_codes/{code}?updateMask.fieldPaths=is_active", tok,
         {"fields": {"is_active": {"booleanValue": False}}})
    print(f"Kode {display(code)} dinonaktifkan. Akses yang sudah diberikan tetap berlaku sampai habis masa.")


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    c = sub.add_parser("create")
    c.add_argument("--keys", help="AI dipisah koma, mis. fiqh_syafii,hadits")
    c.add_argument("--all", action="store_true", help="semua AI (all_access)")
    c.add_argument("--days", type=int, default=7)
    c.add_argument("--max-uses", type=int, default=1)
    c.add_argument("--count", type=int, default=1)
    c.add_argument("--type", default="santri", help="santri | trial | perdana | honor")
    c.add_argument("--long", action="store_true", help="izinkan durasi sampai 400 hari (bukan trial)")
    c.add_argument("--prefix", help="awalan kode, maks 8 huruf/angka")
    c.add_argument("--code", help="kode tertentu (alih-alih acak), hanya bila --count 1")
    c.add_argument("--expires", help="batas penukaran YYYY-MM-DD (akhir hari WIB)")
    c.add_argument("--note")
    c.add_argument("--apply", action="store_true")
    c.set_defaults(fn=cmd_create)
    b = sub.add_parser("bonus")
    g = b.add_mutually_exclusive_group(required=True)
    g.add_argument("--story", action="store_true", help="bonus 3 hari")
    g.add_argument("--feed", action="store_true", help="bonus 7 hari (feed, reel, grup komunitas)")
    b.add_argument("--ig", help="akun Instagram pengunggah, dicatat pada kode")
    b.add_argument("--apply", action="store_true")
    b.set_defaults(fn=cmd_bonus)
    lim = sub.add_parser("limit")
    lim.add_argument("code")
    lim.add_argument("max_uses", type=int)
    lim.set_defaults(fn=cmd_limit)
    sub.add_parser("list").set_defaults(fn=cmd_list)
    for name, fn in (("report", cmd_report), ("deactivate", cmd_deactivate)):
        s = sub.add_parser(name)
        s.add_argument("code")
        s.set_defaults(fn=fn)
    a = p.parse_args(argv)
    try:
        a.fn(a)
    except VoucherError as e:
        sys.exit(f"Ditolak: {e}")


if __name__ == "__main__":
    main()
