import * as crypto from "crypto";
import {AccessControl, Entity, keyOf, millis, normalEmail, billingExpiry, rights, VIP_EMAILS} from "./access_control";

// Owner prerogative operations (VIP, manual access, extension, revocation,
// status). Every change goes through the access ledger so the VPS worker
// shares or removes the NotebookLM seats; nothing here talks to Google.
// Callers (the owner bot) must show `preview()` to the owner and run
// `execute()` only after an explicit confirmation of that exact preview.

// Kode bonus sekali pakai untuk satu orang (mis. pengirim testimoni). Dibuat saat
// konfirmasi; kodenya sendiri tidak ikut pratinjau karena acak.
export interface VoucherAction {
  type: "voucher"; kind: "story" | "feed" | "custom"; label: string; days?: number; scopes?: string[]; reason?: string;
}
export type OwnerAction =
  | VoucherAction
  | {type: "grant"; email: string; scopes: string[]; duration: string; reason: string}
  | {type: "extend"; email: string; scope: string; duration: string; reason: string}
  | {type: "vip"; email: string; reason: string}
  | {type: "revoke"; email: string; scopes: string[]; reason: string};

export interface Preview {
  ok: boolean;
  error?: string;
  lines: string[];          // human summary shown before confirmation
  affected: Array<{email: string; name: string; uid: string | null; scopes: string[]; seats: number; until_ms?: number}>;
}

const DAY = 86400000;
// Story hanya tampil 24 jam sehingga bonusnya lebih singkat; kiriman feed/reel/grup bertahan.
export const BONUS_DAYS = {story: 3, feed: 7} as const;
export const BONUS_SCOPES = ["fiqh_tahawwulat", "fiqh_syafii"];
const BONUS_REDEEM_WINDOW_DAYS = 7;
// Tanpa 0/O dan 1/I/L agar kode mudah dibaca dan diketik.
const CODE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
const PERMANENT_MS = Date.UTC(2125, 0, 1);
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const day = (ms: number) => new Date(ms).toISOString().slice(0, 10);

export function parseDuration(text: string, start: number): number {
  const t = String(text || "").trim().toLowerCase();
  if (["permanent", "permanen", "selamanya"].includes(t)) return PERMANENT_MS;
  const m = t.match(/^(\d{1,4})\s*(h|hari|d|day|days|b|bln|bulan|m|month|months|t|thn|tahun|y|year|years)$/);
  if (!m) throw new Error(`Durasi tidak dikenali: "${text}" (contoh: 7h, 1b, 3b, 1t, permanen)`);
  const n = Number(m[1]), unit = m[2];
  if (/^(h|hari|d|day|days)$/.test(unit)) {
    if (n < 1 || n > 3650) throw new Error("Durasi hari harus 1-3650");
    return start + n * DAY;
  }
  const months = /^(t|thn|tahun|y|year|years)$/.test(unit) ? n * 12 : n;
  if (months < 1 || months > 120) throw new Error("Durasi bulan harus 1-120 (maksimal 10 tahun)");
  return billingExpiry(start, months);
}

export class OwnerOps {
  engine: AccessControl;
  constructor(public db: any, public entities: Record<string, Entity>, public scopes: Record<string, string>,
    public labels: Record<string, string>, public clock: () => number = Date.now,
    // Firestore menuntut Timestamp asli untuk expires_at; layanan VPS mengisinya.
    public timestamp: (ms: number) => any = (ms: number) => ({toMillis: () => ms, toDate: () => new Date(ms)})) {
    this.engine = new AccessControl(db, entities, scopes, undefined, clock);
  }
  validScopes(): string[] { return [...new Set(Object.values(this.scopes))].sort(); }
  label(scope: string): string { return this.labels[scope] || scope; }

  // users/{uid} for a registered account; access_legacy_owners otherwise.
  async locate(email: string): Promise<{ref: any; uid: string; data: any; registered: boolean} | null> {
    const e = normalEmail(email);
    const users = await this.db.collection("users").where("email", "==", e).limit(2).get();
    if (users.size > 1) throw new Error(`Ada lebih dari satu akun dengan email ${e}; selesaikan manual`);
    if (users.size === 1) return {ref: users.docs[0].ref, uid: users.docs[0].id, data: users.docs[0].data(), registered: true};
    const ref = this.db.collection("access_legacy_owners").doc(`legacy_${keyOf(e)}`);
    const snap = await ref.get();
    return snap.exists ? {ref, uid: ref.id, data: snap.data(), registered: false} : null;
  }
  async isProtected(email: string): Promise<boolean> {
    const e = normalEmail(email);
    return VIP_EMAILS.has(e) || (await this.db.collection("access_vip_registry").doc(keyOf(e)).get()).exists;
  }
  async displayName(email: string, owner: any): Promise<string> {
    if (owner?.data?.name) return String(owner.data.name);
    const tx = await this.db.collection("transactions").where("customer_email", "==", normalEmail(email)).limit(1).get();
    return String(tx.docs[0]?.data()?.customer_name || "-");
  }
  async seats(uid: string | null, scopes: string[]): Promise<number> {
    if (!uid) return 0;
    const all = scopes.includes("all_access");
    const a = await this.db.collection("access_assignments").where("uid", "==", uid).get();
    return a.docs.map((d: any) => d.data()).filter((x: any) => ["ready", "provisioning"].includes(x.status) &&
      (all || scopes.includes(this.scopes[x.entity]))).length;
  }

  async status(email: string): Promise<any> {
    const e = normalEmail(email);
    if (!EMAIL.test(e)) throw new Error("Email tidak valid");
    const owner = await this.locate(e);
    const vip = await this.isProtected(e) || owner?.data?.is_vip === true;
    const now = this.clock();
    const {grants} = owner ? await this.engine.owner(owner.uid) : {grants: []};
    const perScope: Record<string, string> = {};
    for (const scope of [...this.validScopes(), "all_access"]) {
      const live = grants.filter((g: any) => g.status === "active" && g.scope === scope && (g.kind === "VIP_PERMANENT" || g.expires_ms > now));
      if (live.length) perScope[this.label(scope)] = live.some((g: any) => g.kind === "VIP_PERMANENT") ? "VIP"
        : `aktif s/d ${day(Math.max(...live.map((g: any) => g.expires_ms)))} (${[...new Set(live.map((g: any) => g.kind === "payment" ? (g.gateway || g.provider || "bayar") : g.kind))].join("+")})`;
    }
    const assignments = owner ? (await this.db.collection("access_assignments").where("uid", "==", owner.uid).get()).docs.map((d: any) => d.data()) : [];
    const txs = (await this.db.collection("transactions").where("customer_email", "==", e).get()).docs.map((d: any) => d.data())
      .sort((a: any, b: any) => (millis(b.created_at) || 0) - (millis(a.created_at) || 0)).slice(0, 5)
      .map((t: any) => `${t.gateway || t.source || "-"} ${t.status} Rp${Number(t.amount || 0).toLocaleString("id-ID")} ${t.entitlement_key || ""}`.trim());
    return {email: e, name: await this.displayName(e, owner), registered: !!owner?.registered, known: !!owner, vip,
      hold: owner?.data?.access_revocation_hold === true, access: perScope,
      seats: assignments.filter((a: any) => ["ready", "provisioning"].includes(a.status)).map((a: any) => `${a.entity}:${a.status}`),
      recent_transactions: txs};
  }

  async search(query: string): Promise<any[]> {
    const q = normalEmail(query);
    if (q.length < 3) throw new Error("Kata kunci minimal 3 karakter");
    const out = new Map<string, any>();
    for (const c of ["users", "access_legacy_owners"]) {
      const s = await this.db.collection(c).where("email", ">=", q).where("email", "<=", q + "").limit(10).get();
      for (const d of s.docs) out.set(d.data().email, {email: d.data().email, name: d.data().name || "-", registered: c === "users"});
    }
    return [...out.values()];
  }

  async expiring(days: number): Promise<any[]> {
    const now = this.clock(), until = now + Math.min(Math.max(1, days), 90) * DAY;
    const s = await this.db.collection("access_grants").where("expires_ms", ">=", now).where("expires_ms", "<=", until).get();
    const rows = new Map<string, any>();
    for (const d of s.docs) {
      const g = d.data();
      if (g.status !== "active" || g.kind === "VIP_PERMANENT") continue;
      const k = `${g.uid}|${g.scope}`, prev = rows.get(k);
      if (!prev || g.expires_ms > prev.expires_ms) rows.set(k, g);
    }
    const out = [];
    for (const g of rows.values()) {
      // A later grant for the same scope means this one is not the real end.
      const later = (await this.engine.grants(g.uid)).some((x: any) => x.status === "active" && [g.scope, "all_access"].includes(x.scope) && x.expires_ms > g.expires_ms);
      if (later) continue;
      const owner = (await this.db.collection("users").doc(g.uid).get()).data() || (await this.db.collection("access_legacy_owners").doc(g.uid).get()).data();
      out.push({email: owner?.email || g.email || "-", name: owner?.name || "-", scope: this.label(g.scope), ends: day(g.expires_ms)});
    }
    return out.sort((a, b) => a.ends.localeCompare(b.ends));
  }

  voucherPlan(action: VoucherAction): {days: number; scopes: string[]; expiresMs: number; label: string} | string {
    const label = String(action.label || "").trim().slice(0, 80);
    if (label.length < 2) return "Sebutkan untuk siapa (akun IG atau nama), minimal 2 karakter";
    let days: number;
    if (action.kind === "story") days = BONUS_DAYS.story;
    else if (action.kind === "feed") days = BONUS_DAYS.feed;
    else {
      days = Number(action.days);
      if (!Number.isInteger(days) || days < 1 || days > 31) return "Untuk jenis custom, hari harus bilangan bulat 1-31";
    }
    const scopes = [...new Set((action.scopes?.length ? action.scopes : BONUS_SCOPES).map(x => x === "all" || x === "semua" ? "all_access" : x))];
    const unknown = scopes.filter(x => x !== "all_access" && !this.validScopes().includes(x));
    if (unknown.length) return `Modul tidak dikenal: ${unknown.join(", ")}`;
    return {days, scopes, label, expiresMs: this.clock() + BONUS_REDEEM_WINDOW_DAYS * DAY};
  }

  async executeVoucher(action: VoucherAction, actor: string): Promise<string> {
    const plan = this.voucherPlan(action);
    if (typeof plan === "string") throw new Error(plan);
    const now = this.clock();
    for (let attempt = 0; attempt < 8; attempt++) {
      let code = "BAGI";
      for (let i = 0; i < 10; i++) code += CODE_ALPHABET[crypto.randomInt(CODE_ALPHABET.length)];
      const ref = this.db.collection("redeem_codes").doc(code);
      const created = await this.db.runTransaction(async (t: any) => {
        if ((await t.get(ref)).exists) return false;
        t.set(ref, {is_active: true, max_uses: 1, times_used: 0, duration_days: plan.days, type: "santri",
          ...(plan.scopes.length === 1 ? {entitlement_key: plan.scopes[0]} : {entitlement_keys: plan.scopes}),
          expires_at: this.timestamp(plan.expiresMs), note: `Bonus ${action.kind} ${plan.label}`.slice(0, 160),
          created_by: "owner_bot", created_ms: now});
        return true;
      });
      if (created) {
        await this.db.collection("owner_audit").add({action: {...action, code_prefix: code.slice(0, 6)}, actor, executed_ms: now});
        return code;
      }
    }
    throw new Error("Gagal membuat kode unik; coba lagi");
  }

  async preview(action: OwnerAction): Promise<Preview> {
    const fail = (error: string): Preview => ({ok: false, error, lines: [], affected: []});
    if (action.type === "voucher") {
      const plan = this.voucherPlan(action);
      if (typeof plan === "string") return fail(plan);
      return {ok: true, affected: [], lines: [`🎟️ Buat KODE BONUS sekali pakai`, `👤 Untuk: ${plan.label}`,
        `📦 ${plan.scopes.map(x => this.label(x)).join(", ")}`,
        `📅 ${plan.days} hari sejak ditukar; harus ditukar sebelum ${day(plan.expiresMs)}`,
        `📝 ${String(action.reason || "Bonus cerita pengalaman").trim().slice(0, 120)}`]};
    }
    const email = normalEmail(action.email);
    if (!EMAIL.test(email)) return fail("Email tidak valid");
    const reason = String((action as any).reason || "").trim();
    if (reason.length < 3) return fail("Alasan wajib diisi (minimal 3 karakter) untuk log audit");
    const owner = await this.locate(email).catch((e: Error) => e);
    if (owner instanceof Error) return fail(owner.message);
    const name = await this.displayName(email, owner);
    const protectedVip = await this.isProtected(email) || owner?.data?.is_vip === true;
    const now = this.clock();
    if (action.type === "vip") {
      if (protectedVip) return fail(`${email} sudah VIP permanen`);
      return {ok: true, lines: [`👑 Jadikan VIP PERMANEN (semua AI, tidak pernah dicabut otomatis)`, `👤 ${name} — ${email}`,
        owner ? "" : "ℹ️ Belum punya akun aplikasi; akses notebook disiapkan lewat emailnya.", `📝 Alasan: ${reason}`].filter(Boolean),
        affected: [{email, name, uid: owner?.uid || null, scopes: ["all_access"], seats: 0}]};
    }
    const scopes = action.type === "extend" ? [action.scope] : [...new Set(action.scopes.map(s => s === "all" || s === "semua" ? "all_access" : s))];
    const unknown = scopes.filter(s => s !== "all_access" && !this.validScopes().includes(s));
    if (!scopes.length || unknown.length) return fail(`Modul tidak dikenal: ${unknown.join(", ") || "(kosong)"}`);
    if (action.type === "grant" || action.type === "extend") {
      let base = now;
      if (action.type === "extend" && owner) {
        const {grants} = await this.engine.owner(owner.uid);
        base = Math.max(now, ...grants.filter((g: any) => g.status === "active" && [action.scope, "all_access"].includes(g.scope)).map((g: any) => g.expires_ms || 0));
      }
      if (action.type === "extend" && !owner) return fail(`${email} belum punya akses apa pun untuk diperpanjang`);
      let until: number;
      try { until = parseDuration(action.duration, base); } catch (e: any) { return fail(e.message); }
      const verb = action.type === "grant" ? "✅ Beri akses manual" : "⏩ Perpanjang akses";
      return {ok: true, lines: [`${verb}: ${scopes.map(s => this.label(s)).join(", ")}`, `👤 ${name} — ${email}`,
        `📅 ${action.type === "extend" ? `dari ${day(base)} ` : ""}s/d ${until >= PERMANENT_MS ? "PERMANEN" : day(until)}`,
        protectedVip ? "ℹ️ Orang ini VIP; akses tambahan tidak mengubah apa pun." : "", `📝 Alasan: ${reason}`].filter(Boolean),
        affected: [{email, name, uid: owner?.uid || null, scopes, seats: 0, until_ms: until}]};
    }
    // revoke
    if (protectedVip) return fail(`🛡️ ${email} adalah VIP permanen. VIP tidak bisa dicabut lewat bot (AGENTS.md §5).`);
    if (!owner) return fail(`${email} tidak ditemukan di sistem; tidak ada yang bisa dicabut`);
    const {user, grants} = await this.engine.owner(owner.uid);
    const targets = scopes.includes("all_access")
      ? [...new Set([...grants.map((g: any) => g.scope), ...Object.keys(user?.entitlements || {})].filter(Boolean))]
      : scopes;
    if (!scopes.includes("all_access") && grants.some((g: any) => g.status === "active" && g.scope === "all_access" && g.expires_ms > now))
      return fail(`${email} punya akses SEMUA AI; cabut "semua" atau beri tahu modul yang tetap boleh`);
    const active = targets.filter(s => s === "all_access" || rights(user, grants, s, now));
    const seats = await this.seats(owner.uid, scopes.includes("all_access") ? ["all_access"] : targets);
    return {ok: true, lines: [`⛔ CABUT akses: ${scopes.includes("all_access") ? "SEMUA AI" : targets.map(s => this.label(s)).join(", ")}`,
      `👤 ${name} — ${email}`, `🪑 Kursi notebook yang akan dilepas: ${seats}`,
      active.length ? `⚠️ Masih aktif (dibayar/diberikan): ${active.map(s => this.label(s)).join(", ")}` : "ℹ️ Tidak ada hak aktif; hanya kursi yang tersisa dibersihkan.",
      `⏱️ Dicabut worker bertahap (maks. per jam sesuai revocation_hourly_limit).`, `📝 Alasan: ${reason}`],
      affected: [{email, name, uid: owner.uid, scopes: targets, seats}]};
  }

  async execute(action: OwnerAction, actor: string): Promise<string> {
    if (action.type === "voucher") return this.executeVoucher(action, actor);
    const preview = await this.preview(action);
    if (!preview.ok) throw new Error(preview.error);
    const email = normalEmail(action.email), now = this.clock(), reason = String(action.reason).trim().slice(0, 300);
    let owner = await this.locate(email);
    if (!owner) {
      // Grants and VIP for an address without an app account: an owner record
      // lets the worker share the seats to that address now.
      const ref = this.db.collection("access_legacy_owners").doc(`legacy_${keyOf(email)}`);
      await ref.set({email, legacy_revoke_only: false, access_version: 2, access_due_ms: now, created_by: "owner_bot", created_ms: now}, {merge: true});
      owner = {ref, uid: ref.id, data: {email}, registered: false};
    }
    const o = owner;
    const target = preview.affected[0];
    const all = action.type === "revoke" && action.scopes.some(x => ["all", "semua", "all_access"].includes(x));
    const result = await this.db.runTransaction(async (t: any) => {
      // Reads first (Firestore transactions require every read before any write).
      const current = (await t.get(o.ref)).data() || {};
      const ids = new Set<string>(current.access_grant_ids || []);
      const existing: Array<{id: string; g: any}> = [];
      for (const id of ids) existing.push({id, g: (await t.get(this.db.collection("access_grants").doc(id))).data()});
      const grant = (id: string, data: any) => {
        t.set(this.db.collection("access_grants").doc(id), {uid: o.uid, email, created_ms: now, created_by: "owner_bot", actor, reason, ...data});
        ids.add(id);
      };
      const update: any = {access_version: 2, access_due_ms: now};
      if (action.type === "vip") {
        t.set(this.db.collection("access_vip_registry").doc(keyOf(email)), {email, permanent: true, source: "owner_bot", actor, reason, added_ms: now}, {merge: true});
        grant(keyOf("vip", o.uid), {kind: "VIP_PERMANENT", scope: "all_access", status: "active"});
        update.is_vip = true;
      } else if (action.type === "grant" || action.type === "extend") {
        for (const scope of target.scopes) grant(keyOf("owner_bot", o.uid, scope, String(now)), {kind: "admin", admin_verified: true,
          scope, status: "active", starts_ms: now, expires_ms: target.until_ms, source_transaction: null});
      } else {
        for (const {id, g} of existing)
          if (g && g.status === "active" && g.kind !== "VIP_PERMANENT" && (all || target.scopes.includes(g.scope)))
            t.update(this.db.collection("access_grants").doc(id), {status: "revoked", revoked_by_owner: true, revoked_ms: now, revoked_reason: reason, revoked_actor: actor});
        for (const scope of all ? [...new Set([...target.scopes, "all_access"])] : target.scopes)
          grant(keyOf("owner_revoke", o.uid, scope, String(now)), {kind: "admin", admin_verified: true, scope,
            status: "revoked", revoked_by_owner: true, revoked_ms: now, starts_ms: now, expires_ms: now});
        const ents = {...(current.entitlements || {})};
        for (const k of Object.keys(ents)) if (all || target.scopes.includes(k)) ents[k] = {...ents[k], status: "revoked", revoked_reason: reason, revoked_ms: now};
        update.entitlements = ents;
      }
      update.access_grant_ids = [...ids];
      t.set(o.ref, update, {merge: true});
      return preview.lines[0];
    });
    await this.db.collection("owner_audit").add({action, actor, preview: preview.lines, executed_ms: now, uid: o.uid});
    return result;
  }
}
