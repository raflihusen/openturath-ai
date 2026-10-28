#!/usr/bin/env python3
"""
voucher_upgrade_all_access.py
=============================
Keputusan Pemilik (28 Okt 2026): kode TURATH7 dan RIBATHNAMATALAWSAT membuka semua AI.
Penukar yang sudah menukar sebelum perubahan itu disusulkan lewat buku besar akses
(`access_grants`), jalur yang sama dengan penukaran voucher, bukan dengan menulis
`entitlements` langsung (pekerja akses yang memproyeksikannya dari hibah).

  - Akun trial: hibah voucher scope all_access, berakhir pada masa trial aslinya.
  - Akun yang punya akses berbayar pada AI itu: masa aktif berbayarnya ditambah lamanya
    voucher (hibah voucher pada scope tersebut, mulai dari akhir akses berbayar), ditambah
    hibah all_access seperti akun lain.

Idempoten: id hibah deterministik dan dibuat hanya bila belum ada. Dry-run secara bawaan.
  python3 scripts/voucher_upgrade_all_access.py            # rencana
  python3 scripts/voucher_upgrade_all_access.py --apply    # tulis
"""
import argparse, hashlib, json, sys, time
sys.path.insert(0, __file__.rsplit("/", 1)[0])
import voucher_admin as v

CODES = ["TURATH7", "RIBATHNAMATALAWSAT"]
DAY = 86400000


def key_of(*parts):
    return hashlib.sha256(json.dumps(list(parts), separators=(",", ":"), ensure_ascii=False).encode()).hexdigest()


def ms(ts):
    from datetime import datetime
    return int(datetime.strptime(ts[:19], "%Y-%m-%dT%H:%M:%S").replace(tzinfo=v.timezone.utc).timestamp() * 1000)


def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--apply", action="store_true"); a = ap.parse_args()
    tok = v.token(); now = int(time.time() * 1000); plan = []
    for code in CODES:
        cdoc = v.call("GET", f"{v.BASE}/redeem_codes/{code}", tok)
        days = v.from_value(cdoc["fields"]["duration_days"])
        reds = v.call("GET", f"{v.BASE}/redeem_codes/{code}/redemptions?pageSize=300", tok).get("documents", [])
        for d in reds:
            uid = d["name"].rsplit("/", 1)[-1]
            rf = {k: v.from_value(x) for k, x in d["fields"].items()}
            redeemed = ms(rf["redeemed_at"])
            u = v.call("GET", f"{v.BASE}/users/{uid}", tok)["fields"]
            ent = u.get("entitlements", {}).get("mapValue", {}).get("fields", {})
            ids = [x.get("stringValue") for x in u.get("access_grant_ids", {}).get("arrayValue", {}).get("values", [])]
            v2 = u.get("access_version", {}).get("integerValue")
            grants = []
            all_id = key_of("voucher", code, uid)
            grants.append((all_id, {"uid": uid, "scope": "all_access", "kind": "voucher", "status": "active", "redemption_code": code,
                                    "starts_ms": redeemed, "expires_ms": redeemed + days * DAY, "created_ms": now}, "semua AI"))
            for key, x in ent.items():
                f = x.get("mapValue", {}).get("fields", {})
                paid = f.get("payment_status", {}).get("stringValue")
                exp = f.get("expiry", {}).get("timestampValue")
                plan_name = f.get("plan", {}).get("stringValue")
                if not exp or key == "all_access" or plan_name in (None, "trial", "voucher_access", "expired"):
                    continue
                if True:  # selain trial/voucher: akses berbayar (mis. 12_months, premium)
                    pe = ms(exp)
                    if pe > now:
                        grants.append((key_of("voucher_extension", code, uid, key),
                                       {"uid": uid, "scope": key, "kind": "voucher", "status": "active", "redemption_code": code,
                                        "starts_ms": pe, "expires_ms": pe + days * DAY, "created_ms": now}, f"perpanjang {key} +{days} hari"))
            plan.append((code, uid, v2, ids, grants))
    for code, uid, v2, ids, grants in plan:
        print(f"{code} {uid[:8]}… access_version={v2} hibah:", [(g[2], __import__('datetime').datetime.fromtimestamp(g[1]['expires_ms']/1000, v.timezone.utc).strftime('%Y-%m-%d %H:%M')) for g in grants])
    bad = [p for p in plan if p[2] != "2"]
    if bad:
        print(f"\n{len(bad)} akun tanpa access_version=2 akan DILEWATI (pekerja akses tidak memprosesnya).")
    if not a.apply:
        print("\nDry-run. Tambahkan --apply untuk menulis."); return
    for code, uid, v2, ids, grants in plan:
        if v2 != "2": continue
        newids = list(ids)
        for gid, doc, _ in grants:
            try:
                v.call("POST", f"{v.BASE}/access_grants?documentId={gid}", tok, {"fields": {k: v.to_value(x) for k, x in doc.items()}})
            except SystemExit as e:
                if "ALREADY_EXISTS" not in str(e) and "409" not in str(e): raise
            if gid not in newids: newids.append(gid)
        v.call("PATCH", f"{v.BASE}/users/{uid}?updateMask.fieldPaths=access_grant_ids&updateMask.fieldPaths=access_due_ms", tok,
               {"fields": {"access_grant_ids": v.to_value(newids), "access_due_ms": {"integerValue": str(now)}}})
        print("ditulis", uid[:8])


main()
