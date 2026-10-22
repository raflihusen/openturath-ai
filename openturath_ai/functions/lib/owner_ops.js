"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.OwnerOps = void 0;
exports.parseDuration = parseDuration;
const access_control_1 = require("./access_control");
const DAY = 86400000;
const PERMANENT_MS = Date.UTC(2125, 0, 1);
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const day = (ms) => new Date(ms).toISOString().slice(0, 10);
function parseDuration(text, start) {
    const t = String(text || "").trim().toLowerCase();
    if (["permanent", "permanen", "selamanya"].includes(t))
        return PERMANENT_MS;
    const m = t.match(/^(\d{1,4})\s*(h|hari|d|day|days|b|bln|bulan|m|month|months|t|thn|tahun|y|year|years)$/);
    if (!m)
        throw new Error(`Durasi tidak dikenali: "${text}" (contoh: 7h, 1b, 3b, 1t, permanen)`);
    const n = Number(m[1]), unit = m[2];
    if (/^(h|hari|d|day|days)$/.test(unit)) {
        if (n < 1 || n > 3650)
            throw new Error("Durasi hari harus 1-3650");
        return start + n * DAY;
    }
    const months = /^(t|thn|tahun|y|year|years)$/.test(unit) ? n * 12 : n;
    if (months < 1 || months > 120)
        throw new Error("Durasi bulan harus 1-120 (maksimal 10 tahun)");
    return (0, access_control_1.billingExpiry)(start, months);
}
class OwnerOps {
    constructor(db, entities, scopes, labels, clock = Date.now) {
        this.db = db;
        this.entities = entities;
        this.scopes = scopes;
        this.labels = labels;
        this.clock = clock;
        this.engine = new access_control_1.AccessControl(db, entities, scopes, undefined, clock);
    }
    validScopes() { return [...new Set(Object.values(this.scopes))].sort(); }
    label(scope) { return this.labels[scope] || scope; }
    // users/{uid} for a registered account; access_legacy_owners otherwise.
    async locate(email) {
        const e = (0, access_control_1.normalEmail)(email);
        const users = await this.db.collection("users").where("email", "==", e).limit(2).get();
        if (users.size > 1)
            throw new Error(`Ada lebih dari satu akun dengan email ${e}; selesaikan manual`);
        if (users.size === 1)
            return { ref: users.docs[0].ref, uid: users.docs[0].id, data: users.docs[0].data(), registered: true };
        const ref = this.db.collection("access_legacy_owners").doc(`legacy_${(0, access_control_1.keyOf)(e)}`);
        const snap = await ref.get();
        return snap.exists ? { ref, uid: ref.id, data: snap.data(), registered: false } : null;
    }
    async isProtected(email) {
        const e = (0, access_control_1.normalEmail)(email);
        return access_control_1.VIP_EMAILS.has(e) || (await this.db.collection("access_vip_registry").doc((0, access_control_1.keyOf)(e)).get()).exists;
    }
    async displayName(email, owner) {
        var _a, _b, _c;
        if ((_a = owner === null || owner === void 0 ? void 0 : owner.data) === null || _a === void 0 ? void 0 : _a.name)
            return String(owner.data.name);
        const tx = await this.db.collection("transactions").where("customer_email", "==", (0, access_control_1.normalEmail)(email)).limit(1).get();
        return String(((_c = (_b = tx.docs[0]) === null || _b === void 0 ? void 0 : _b.data()) === null || _c === void 0 ? void 0 : _c.customer_name) || "-");
    }
    async seats(uid, scopes) {
        if (!uid)
            return 0;
        const all = scopes.includes("all_access");
        const a = await this.db.collection("access_assignments").where("uid", "==", uid).get();
        return a.docs.map((d) => d.data()).filter((x) => ["ready", "provisioning"].includes(x.status) &&
            (all || scopes.includes(this.scopes[x.entity]))).length;
    }
    async status(email) {
        var _a, _b;
        const e = (0, access_control_1.normalEmail)(email);
        if (!EMAIL.test(e))
            throw new Error("Email tidak valid");
        const owner = await this.locate(e);
        const vip = await this.isProtected(e) || ((_a = owner === null || owner === void 0 ? void 0 : owner.data) === null || _a === void 0 ? void 0 : _a.is_vip) === true;
        const now = this.clock();
        const { grants } = owner ? await this.engine.owner(owner.uid) : { grants: [] };
        const perScope = {};
        for (const scope of [...this.validScopes(), "all_access"]) {
            const live = grants.filter((g) => g.status === "active" && g.scope === scope && (g.kind === "VIP_PERMANENT" || g.expires_ms > now));
            if (live.length)
                perScope[this.label(scope)] = live.some((g) => g.kind === "VIP_PERMANENT") ? "VIP"
                    : `aktif s/d ${day(Math.max(...live.map((g) => g.expires_ms)))} (${[...new Set(live.map((g) => g.kind === "payment" ? (g.gateway || g.provider || "bayar") : g.kind))].join("+")})`;
        }
        const assignments = owner ? (await this.db.collection("access_assignments").where("uid", "==", owner.uid).get()).docs.map((d) => d.data()) : [];
        const txs = (await this.db.collection("transactions").where("customer_email", "==", e).get()).docs.map((d) => d.data())
            .sort((a, b) => ((0, access_control_1.millis)(b.created_at) || 0) - ((0, access_control_1.millis)(a.created_at) || 0)).slice(0, 5)
            .map((t) => `${t.gateway || t.source || "-"} ${t.status} Rp${Number(t.amount || 0).toLocaleString("id-ID")} ${t.entitlement_key || ""}`.trim());
        return { email: e, name: await this.displayName(e, owner), registered: !!(owner === null || owner === void 0 ? void 0 : owner.registered), known: !!owner, vip,
            hold: ((_b = owner === null || owner === void 0 ? void 0 : owner.data) === null || _b === void 0 ? void 0 : _b.access_revocation_hold) === true, access: perScope,
            seats: assignments.filter((a) => ["ready", "provisioning"].includes(a.status)).map((a) => `${a.entity}:${a.status}`),
            recent_transactions: txs };
    }
    async search(query) {
        const q = (0, access_control_1.normalEmail)(query);
        if (q.length < 3)
            throw new Error("Kata kunci minimal 3 karakter");
        const out = new Map();
        for (const c of ["users", "access_legacy_owners"]) {
            const s = await this.db.collection(c).where("email", ">=", q).where("email", "<=", q + "").limit(10).get();
            for (const d of s.docs)
                out.set(d.data().email, { email: d.data().email, name: d.data().name || "-", registered: c === "users" });
        }
        return [...out.values()];
    }
    async expiring(days) {
        const now = this.clock(), until = now + Math.min(Math.max(1, days), 90) * DAY;
        const s = await this.db.collection("access_grants").where("expires_ms", ">=", now).where("expires_ms", "<=", until).get();
        const rows = new Map();
        for (const d of s.docs) {
            const g = d.data();
            if (g.status !== "active" || g.kind === "VIP_PERMANENT")
                continue;
            const k = `${g.uid}|${g.scope}`, prev = rows.get(k);
            if (!prev || g.expires_ms > prev.expires_ms)
                rows.set(k, g);
        }
        const out = [];
        for (const g of rows.values()) {
            // A later grant for the same scope means this one is not the real end.
            const later = (await this.engine.grants(g.uid)).some((x) => x.status === "active" && [g.scope, "all_access"].includes(x.scope) && x.expires_ms > g.expires_ms);
            if (later)
                continue;
            const owner = (await this.db.collection("users").doc(g.uid).get()).data() || (await this.db.collection("access_legacy_owners").doc(g.uid).get()).data();
            out.push({ email: (owner === null || owner === void 0 ? void 0 : owner.email) || g.email || "-", name: (owner === null || owner === void 0 ? void 0 : owner.name) || "-", scope: this.label(g.scope), ends: day(g.expires_ms) });
        }
        return out.sort((a, b) => a.ends.localeCompare(b.ends));
    }
    async preview(action) {
        var _a;
        const fail = (error) => ({ ok: false, error, lines: [], affected: [] });
        const email = (0, access_control_1.normalEmail)(action.email);
        if (!EMAIL.test(email))
            return fail("Email tidak valid");
        const reason = String(action.reason || "").trim();
        if (reason.length < 3)
            return fail("Alasan wajib diisi (minimal 3 karakter) untuk log audit");
        const owner = await this.locate(email).catch((e) => e);
        if (owner instanceof Error)
            return fail(owner.message);
        const name = await this.displayName(email, owner);
        const protectedVip = await this.isProtected(email) || ((_a = owner === null || owner === void 0 ? void 0 : owner.data) === null || _a === void 0 ? void 0 : _a.is_vip) === true;
        const now = this.clock();
        if (action.type === "vip") {
            if (protectedVip)
                return fail(`${email} sudah VIP permanen`);
            return { ok: true, lines: [`👑 Jadikan VIP PERMANEN (semua AI, tidak pernah dicabut otomatis)`, `👤 ${name} — ${email}`,
                    owner ? "" : "ℹ️ Belum punya akun aplikasi; akses notebook disiapkan lewat emailnya.", `📝 Alasan: ${reason}`].filter(Boolean),
                affected: [{ email, name, uid: (owner === null || owner === void 0 ? void 0 : owner.uid) || null, scopes: ["all_access"], seats: 0 }] };
        }
        const scopes = action.type === "extend" ? [action.scope] : [...new Set(action.scopes.map(s => s === "all" || s === "semua" ? "all_access" : s))];
        const unknown = scopes.filter(s => s !== "all_access" && !this.validScopes().includes(s));
        if (!scopes.length || unknown.length)
            return fail(`Modul tidak dikenal: ${unknown.join(", ") || "(kosong)"}`);
        if (action.type === "grant" || action.type === "extend") {
            let base = now;
            if (action.type === "extend" && owner) {
                const { grants } = await this.engine.owner(owner.uid);
                base = Math.max(now, ...grants.filter((g) => g.status === "active" && [action.scope, "all_access"].includes(g.scope)).map((g) => g.expires_ms || 0));
            }
            if (action.type === "extend" && !owner)
                return fail(`${email} belum punya akses apa pun untuk diperpanjang`);
            let until;
            try {
                until = parseDuration(action.duration, base);
            }
            catch (e) {
                return fail(e.message);
            }
            const verb = action.type === "grant" ? "✅ Beri akses manual" : "⏩ Perpanjang akses";
            return { ok: true, lines: [`${verb}: ${scopes.map(s => this.label(s)).join(", ")}`, `👤 ${name} — ${email}`,
                    `📅 ${action.type === "extend" ? `dari ${day(base)} ` : ""}s/d ${until >= PERMANENT_MS ? "PERMANEN" : day(until)}`,
                    protectedVip ? "ℹ️ Orang ini VIP; akses tambahan tidak mengubah apa pun." : "", `📝 Alasan: ${reason}`].filter(Boolean),
                affected: [{ email, name, uid: (owner === null || owner === void 0 ? void 0 : owner.uid) || null, scopes, seats: 0, until_ms: until }] };
        }
        // revoke
        if (protectedVip)
            return fail(`🛡️ ${email} adalah VIP permanen. VIP tidak bisa dicabut lewat bot (AGENTS.md §5).`);
        if (!owner)
            return fail(`${email} tidak ditemukan di sistem; tidak ada yang bisa dicabut`);
        const { user, grants } = await this.engine.owner(owner.uid);
        const targets = scopes.includes("all_access")
            ? [...new Set([...grants.map((g) => g.scope), ...Object.keys((user === null || user === void 0 ? void 0 : user.entitlements) || {})].filter(Boolean))]
            : scopes;
        if (!scopes.includes("all_access") && grants.some((g) => g.status === "active" && g.scope === "all_access" && g.expires_ms > now))
            return fail(`${email} punya akses SEMUA AI; cabut "semua" atau beri tahu modul yang tetap boleh`);
        const active = targets.filter(s => s === "all_access" || (0, access_control_1.rights)(user, grants, s, now));
        const seats = await this.seats(owner.uid, scopes.includes("all_access") ? ["all_access"] : targets);
        return { ok: true, lines: [`⛔ CABUT akses: ${scopes.includes("all_access") ? "SEMUA AI" : targets.map(s => this.label(s)).join(", ")}`,
                `👤 ${name} — ${email}`, `🪑 Kursi notebook yang akan dilepas: ${seats}`,
                active.length ? `⚠️ Masih aktif (dibayar/diberikan): ${active.map(s => this.label(s)).join(", ")}` : "ℹ️ Tidak ada hak aktif; hanya kursi yang tersisa dibersihkan.",
                `⏱️ Dicabut worker bertahap (maks. per jam sesuai revocation_hourly_limit).`, `📝 Alasan: ${reason}`],
            affected: [{ email, name, uid: owner.uid, scopes: targets, seats }] };
    }
    async execute(action, actor) {
        const preview = await this.preview(action);
        if (!preview.ok)
            throw new Error(preview.error);
        const email = (0, access_control_1.normalEmail)(action.email), now = this.clock(), reason = String(action.reason).trim().slice(0, 300);
        let owner = await this.locate(email);
        if (!owner) {
            // Grants and VIP for an address without an app account: an owner record
            // lets the worker share the seats to that address now.
            const ref = this.db.collection("access_legacy_owners").doc(`legacy_${(0, access_control_1.keyOf)(email)}`);
            await ref.set({ email, legacy_revoke_only: false, access_version: 2, access_due_ms: now, created_by: "owner_bot", created_ms: now }, { merge: true });
            owner = { ref, uid: ref.id, data: { email }, registered: false };
        }
        const o = owner;
        const target = preview.affected[0];
        const all = action.type === "revoke" && action.scopes.some(x => ["all", "semua", "all_access"].includes(x));
        const result = await this.db.runTransaction(async (t) => {
            // Reads first (Firestore transactions require every read before any write).
            const current = (await t.get(o.ref)).data() || {};
            const ids = new Set(current.access_grant_ids || []);
            const existing = [];
            for (const id of ids)
                existing.push({ id, g: (await t.get(this.db.collection("access_grants").doc(id))).data() });
            const grant = (id, data) => {
                t.set(this.db.collection("access_grants").doc(id), Object.assign({ uid: o.uid, email, created_ms: now, created_by: "owner_bot", actor, reason }, data));
                ids.add(id);
            };
            const update = { access_version: 2, access_due_ms: now };
            if (action.type === "vip") {
                t.set(this.db.collection("access_vip_registry").doc((0, access_control_1.keyOf)(email)), { email, permanent: true, source: "owner_bot", actor, reason, added_ms: now }, { merge: true });
                grant((0, access_control_1.keyOf)("vip", o.uid), { kind: "VIP_PERMANENT", scope: "all_access", status: "active" });
                update.is_vip = true;
            }
            else if (action.type === "grant" || action.type === "extend") {
                for (const scope of target.scopes)
                    grant((0, access_control_1.keyOf)("owner_bot", o.uid, scope, String(now)), { kind: "admin", admin_verified: true,
                        scope, status: "active", starts_ms: now, expires_ms: target.until_ms, source_transaction: null });
            }
            else {
                for (const { id, g } of existing)
                    if (g && g.status === "active" && g.kind !== "VIP_PERMANENT" && (all || target.scopes.includes(g.scope)))
                        t.update(this.db.collection("access_grants").doc(id), { status: "revoked", revoked_by_owner: true, revoked_ms: now, revoked_reason: reason, revoked_actor: actor });
                for (const scope of all ? [...new Set([...target.scopes, "all_access"])] : target.scopes)
                    grant((0, access_control_1.keyOf)("owner_revoke", o.uid, scope, String(now)), { kind: "admin", admin_verified: true, scope,
                        status: "revoked", revoked_by_owner: true, revoked_ms: now, starts_ms: now, expires_ms: now });
                const ents = Object.assign({}, (current.entitlements || {}));
                for (const k of Object.keys(ents))
                    if (all || target.scopes.includes(k))
                        ents[k] = Object.assign(Object.assign({}, ents[k]), { status: "revoked", revoked_reason: reason, revoked_ms: now });
                update.entitlements = ents;
            }
            update.access_grant_ids = [...ids];
            t.set(o.ref, update, { merge: true });
            return preview.lines[0];
        });
        await this.db.collection("owner_audit").add({ action, actor, preview: preview.lines, executed_ms: now, uid: o.uid });
        return result;
    }
}
exports.OwnerOps = OwnerOps;
//# sourceMappingURL=owner_ops.js.map