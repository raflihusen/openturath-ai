"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AccessControl = exports.AccessFault = exports.isVip = exports.REVOCATION_POLICY = exports.millis = exports.keyOf = exports.normalEmail = exports.VIP_EMAILS = void 0;
exports.hasLegacyAccessAdjustment = hasLegacyAccessAdjustment;
exports.evidenceHash = evidenceHash;
exports.legacyTransactionScopes = legacyTransactionScopes;
exports.billingExpiry = billingExpiry;
exports.akalDurationMonths = akalDurationMonths;
exports.classifyLegacyEvent = classifyLegacyEvent;
exports.verifiedAkalPeriods = verifiedAkalPeriods;
exports.rights = rights;
const crypto = require("crypto");
// Shared by Firebase callable functions and the Ubuntu worker. No Google RPC in
// database transactions; opening a notebook never allocates a seat.
// Canonical permanent-VIP registry (owner prerogative, AGENTS.md rule 5). Entries are
// only ever added. `npm run export-shared` writes this list for the Python automation;
// test/shared_catalog.test.ts fails when the exported copy drifts.
exports.VIP_EMAILS = new Set([
    // Owner & Core Team
    "openturath@gmail.com", "ramah@ptct.net", "raflimaulan@gmail.com",
    "mas.raflihusen@gmail.com", "udinvoldigoad05@gmail.com",
    // Mitra Kehormatan (Rule 5 AGENTS.md)
    "prilatief@gmail.com",
    // Masyayikh & Asatidz Turats
    "alkhateeb23@gmail.com", "omarasb1441@gmail.com",
    "mohammedhalahdal@gmail.com", "alshykhkmalbahrmz@gmail.com",
    "ali.bafdhl36@gmail.com", "alhamodi65@gmail.com",
    "abualgilani2024@gmail.com", "abo.omar5539@gmail.com",
    "ahobh4241@gmail.com", "omar739037802@gmail.com",
    "yasser110271@gmail.com",
]);
const normalEmail = (s) => typeof s === "string" ? s.trim().toLowerCase() : "";
exports.normalEmail = normalEmail;
const keyOf = (...parts) => crypto.createHash("sha256").update(JSON.stringify(parts)).digest("hex");
exports.keyOf = keyOf;
const millis = (v) => { var _a, _b; return (_b = (_a = v === null || v === void 0 ? void 0 : v.toMillis) === null || _a === void 0 ? void 0 : _a.call(v)) !== null && _b !== void 0 ? _b : ((v === null || v === void 0 ? void 0 : v.toDate) ? v.toDate().getTime() : typeof v === "number" ? v : Date.parse(v || "")); };
exports.millis = millis;
// A verified provider receipt does not supersede an owner's later bonus,
// transfer, or manual correction. Ambiguous adjustments block revocation;
// they do not automatically create or extend a payment grant.
function hasLegacyAccessAdjustment(tx) {
    const source = String(tx.source || "").toLowerCase();
    return Boolean(tx.bonus_reason || tx.bonus_applied_at || tx.original_transaction_id ||
        tx.admin_verified || tx.admin_approved || source.includes("manual") || source.includes("transfer") ||
        tx.access_override || tx.override_reason);
}
exports.REVOCATION_POLICY = 3;
function evidenceHash(value) {
    const canonical = (v) => {
        if ((v === null || v === void 0 ? void 0 : v.toMillis) || (v === null || v === void 0 ? void 0 : v.toDate))
            return (0, exports.millis)(v);
        if (v instanceof Date)
            return v.getTime();
        if (Array.isArray(v))
            return v.map(canonical);
        if (v && typeof v === "object")
            return Object.fromEntries(Object.keys(v).sort().map(k => [k, canonical(v[k])]));
        return v !== null && v !== void 0 ? v : null;
    };
    return crypto.createHash("sha256").update(JSON.stringify(canonical(value))).digest("hex");
}
function legacyTransactionScopes(tx) {
    const explicit = [tx.entitlement_key, tx.scope, ...(Array.isArray(tx.modules) ? tx.modules : [])].filter(Boolean);
    if (explicit.length)
        return explicit;
    const label = String(tx.service_name || tx.serviceTitle || "").toLowerCase();
    if (/tahawwulat|tahawulat/.test(label))
        return ["fiqh_tahawwulat"];
    if (/syafi|syafii/.test(label))
        return ["fiqh_syafii"];
    if (/bahasa arab/.test(label))
        return ["nahwu"];
    if (/^all_ai/.test(String(tx.plan || "")))
        return ["all_access"];
    return []; // Unknown scope must be reviewed, never guessed from package duration.
}
function billingExpiry(baseMs, months) {
    if (!Number.isInteger(months) || months < 1 || months > 120)
        throw new Error("Invalid product duration");
    if (months === 1)
        return baseMs + 30 * 86400000;
    const date = new Date(baseMs), day = date.getUTCDate();
    date.setUTCDate(1);
    date.setUTCMonth(date.getUTCMonth() + months);
    const last = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth() + 1, 0)).getUTCDate();
    date.setUTCDate(Math.min(day, last));
    return date.getTime();
}
function akalDurationMonths(priceSchemeTitle, serviceTitle = "") {
    const s = `${priceSchemeTitle || ""} ${serviceTitle || ""}`.toLowerCase();
    if (["12 bulan", "12m", "tahun", "1y", "year", "annual"].some(k => s.includes(k)))
        return 12;
    if (s.includes("6 bulan") || s.includes("6m"))
        return 6;
    return 1;
}
// Decides what the VPS worker may do with one authenticated GoAkal webhook
// event queued in access_legacy_events. Anything short of complete, positive
// billing evidence for a known product goes to the operator, never to a grant;
// negative events are only recorded because expiry is driven by the ledger.
function classifyLegacyEvent(event, resolveScopes) {
    const status = String((event === null || event === void 0 ? void 0 : event.payment_status) || "").toUpperCase();
    if (["EXPIRED", "FAILED", "CANCELLED"].includes(status))
        return { action: "noted", reason: "negative_event_ledger_decides" };
    if (!["PAID", "SETTLED"].includes(status))
        return { action: "review", reason: "unknown_payment_status" };
    const email = (0, exports.normalEmail)(event.email), id = typeof event.transaction_id === "string" ? event.transaction_id.trim() : "";
    const amount = Number(event.amount), paidMs = (0, exports.millis)(event.paid_at), scopes = resolveScopes(event.service);
    if (event.reason)
        return { action: "review", reason: String(event.reason) };
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
        return { action: "review", reason: "invalid_email" };
    if (!id || id.length > 255)
        return { action: "review", reason: "invalid_transaction_id" };
    if (!Number.isFinite(amount) || amount <= 0)
        return { action: "review", reason: "non_positive_amount" };
    if (!scopes.length)
        return { action: "review", reason: "unknown_service" };
    if (!Number.isFinite(paidMs))
        return { action: "review", reason: "missing_payment_time" };
    const months = akalDurationMonths(event.plan, event.service);
    return { action: "grant", email, transactionId: id, amount, scopes, months, paidMs, expiresMs: billingExpiry(paidMs, months) };
}
function verifiedAkalPeriods(rows) {
    const scopes = { "AI Fikih Tahawwulat": "fiqh_tahawwulat",
        "SUPER AI FIKIH SYAFI'I": "fiqh_syafii", "SUPER AI BAHASA ARAB": "nahwu" };
    const durations = { "1 Bulan": 1, "6 Bulan": 6, "12 Bulan": 12 };
    const valid = rows.filter(r => r.status === "PAID" && Number(r.incomingAmount) > 0 && scopes[r.serviceTitle] &&
        durations[r.priceSchemeTitle] && (0, exports.normalEmail)(r.payerEmail) && r.paymentId && Number.isFinite((0, exports.millis)(r.paidAt)));
    valid.sort((a, b) => (0, exports.millis)(a.paidAt) - (0, exports.millis)(b.paidAt));
    const seen = new Map(), ends = new Map(), periods = [];
    for (const row of valid) {
        const scope = scopes[row.serviceTitle], months = durations[row.priceSchemeTitle], paid = (0, exports.millis)(row.paidAt);
        const email = (0, exports.normalEmail)(row.payerEmail), payment = String(row.paymentId), id = (0, exports.keyOf)("goakal_verified", payment, scope);
        if (seen.has(id)) {
            if (seen.get(id) !== email)
                throw new Error("Provider payment identity collision");
            continue;
        }
        seen.set(id, email);
        const chain = (0, exports.keyOf)(email, scope), starts = Math.max(paid, ends.get(chain) || 0), expires = billingExpiry(starts, months);
        ends.set(chain, expires);
        periods.push({ id, email, scope, payment, amount: Number(row.incomingAmount), paid, months, starts, expires });
    }
    return periods;
}
const isVip = (u, grants = []) => exports.VIP_EMAILS.has((0, exports.normalEmail)(u === null || u === void 0 ? void 0 : u.email)) ||
    (u === null || u === void 0 ? void 0 : u.is_vip) === true || ["vip", "admin", "guru", "special"].includes(String((u === null || u === void 0 ? void 0 : u.role) || "").toLowerCase()) ||
    grants.some(g => g.kind === "VIP_PERMANENT");
exports.isVip = isVip;
function rights(u, grants, scope, now = Date.now()) {
    if ((0, exports.isVip)(u, grants))
        return true;
    if (!u || u.account_deleted || u.pending_deletion)
        return false;
    return grants.some(g => g.status === "active" && [scope, "all_access", "all_ai"].includes(g.scope) &&
        Number.isFinite(g.expires_ms) && g.expires_ms > now &&
        (g.kind === "payment" && g.amount > 0 || g.kind === "admin" && g.admin_verified === true || g.kind === "voucher"));
}
class AccessFault extends Error {
    constructor(code, message) {
        super(message);
        this.code = code;
    }
}
exports.AccessFault = AccessFault;
class AccessControl {
    constructor(db, entities, scopes, provider, clock = Date.now) {
        this.db = db;
        this.entities = entities;
        this.scopes = scopes;
        this.provider = provider;
        this.clock = clock;
    }
    assignmentRef(uid, entity) { return this.db.collection("access_assignments").doc((0, exports.keyOf)(uid, entity)); }
    async grants(uid) {
        const s = await this.db.collection("access_grants").where("uid", "==", uid).get();
        return s.docs.map((d) => (Object.assign({ id: d.id }, d.data())));
    }
    async owner(uid) {
        const [u, grants] = await Promise.all([this.db.collection("users").doc(uid).get(), this.grants(uid)]);
        const legacy = !u.exists ? await this.db.collection("access_legacy_owners").doc(uid).get() : null;
        let user = u.data() || (legacy === null || legacy === void 0 ? void 0 : legacy.data());
        if (user === null || user === void 0 ? void 0 : user.adopted_by)
            user = Object.assign(Object.assign({}, user), { account_deleted: true });
        if (user === null || user === void 0 ? void 0 : user.email) {
            const protectedOwner = await this.db.collection("access_vip_registry").doc((0, exports.keyOf)((0, exports.normalEmail)(user.email))).get();
            if (protectedOwner.exists)
                user = Object.assign(Object.assign({}, user), { is_vip: true });
        }
        return { user, grants };
    }
    async assessRevocation(uid, scope, targetEmail) {
        var _a;
        const { user, grants } = await this.owner(uid);
        const email = (0, exports.normalEmail)(targetEmail || (user === null || user === void 0 ? void 0 : user.email));
        const now = this.clock();
        const runtime = (await this.db.collection("access_control").doc("runtime").get()).data() || {};
        const selected = grants.filter(g => [scope, "all_access", "all_ai"].includes(g.scope));
        const deleted = (user === null || user === void 0 ? void 0 : user.account_deleted) === true;
        const refunded = selected.some(g => g.status === "revoked" && /refund|chargeback/.test(String(g.payment_status || "")));
        const category = deleted ? "account_deleted" : refunded ? "refund" : "expiry";
        // `revocation_pause` pauses one category at a time (refunds and deleted
        // accounts keep flowing while ordinary expiry is under review). The kill
        // switch and the legacy all-or-nothing flag still stop everything.
        const pauses = runtime.revocation_pause && typeof runtime.revocation_pause === "object" ? runtime.revocation_pause : null;
        if (runtime.revocation_kill_switch === true || (pauses ? pauses[category] === true : runtime.revocations_paused === true))
            return { allowed: false, reason: "incident_pause", category };
        if (!user || !email || (0, exports.normalEmail)(user.email) !== email)
            return { allowed: false, reason: "identity_unresolved" };
        const permanent = await this.db.collection("access_vip_registry").doc((0, exports.keyOf)(email)).get();
        if ((0, exports.isVip)(Object.assign(Object.assign({}, user), { email }), grants) || permanent.exists)
            return { allowed: false, reason: "permanent_vip" };
        if (user.access_revocation_hold)
            return { allowed: false, reason: "owner_hold" };
        // The same Google address now belongs to a newer account; its seat moved there.
        for (const [entity, entityScope] of Object.entries(this.scopes)) {
            if (entityScope !== scope)
                continue;
            const bound = (await this.db.collection("access_identities").doc((0, exports.keyOf)(email, entity)).get()).data();
            if ((bound === null || bound === void 0 ? void 0 : bound.uid) && bound.uid !== uid)
                return { allowed: false, reason: "identity_rebound", category };
        }
        if (user.pending_deletion && !deleted)
            return { allowed: false, reason: "deletion_requires_separate_review" };
        if (!deleted && rights(user, grants, scope, now))
            return { allowed: false, reason: "active_scope" };
        // Absence of evidence is not proof of expiry. A deleted account is the
        // exception: its owner asked for the account, and its access, to end.
        if (!deleted && !selected.length)
            return { allowed: false, reason: "missing_scope_evidence" };
        if (!deleted && selected.some(g => !Number.isFinite(g.expires_ms) ||
            !["active", "revoked"].includes(g.status) ||
            !(g.kind === "payment" && g.amount > 0 || g.kind === "admin" && g.admin_verified === true || g.kind === "voucher")))
            return { allowed: false, reason: "invalid_scope_evidence" };
        const gateway = (t) => ["midtrans", "doku"].includes(String(t.gateway || "").toLowerCase());
        const txs = await this.scopeTransactions(uid, scope, email);
        // Legacy evidence blocks automated removal only while it could still be
        // live. An unverified provider period is trusted for at least 13 months
        // from its start, because its recorded duration may have been guessed.
        const TRUST_MS = 395 * 86400000;
        const unverifiedLive = (g) => (g.provider === "goakal" || g.imported) && g.provider_verified !== true &&
            Math.max(Number(g.expires_ms) || 0, (Number(g.starts_ms) || Number(g.paid_ms) || Number(g.created_ms) || 0) + TRUST_MS) > now;
        const txMayBeLive = (t) => {
            const paid = (0, exports.millis)(t.paid_at || t.completed_at || t.paid_ms || t.created_at);
            const explicit = (0, exports.millis)(t.subscription_expires_at || t.access_expires_at || t.expires_at);
            return !Number.isFinite(paid) || Math.max(Number.isFinite(explicit) ? explicit : 0, paid + TRUST_MS) > now;
        };
        const profile = [scope, "all_access", "all_ai"].map(k => { var _a; return (_a = user.entitlements) === null || _a === void 0 ? void 0 : _a[k]; }).filter(Boolean);
        const unbackedProfile = profile.some((e) => e.source !== "access_ledger" && !["expired", "revoked"].includes(e.status) &&
            (0, exports.millis)(e.expiry) > now && !selected.some(g => g.status === "active" && g.expires_ms >= (0, exports.millis)(e.expiry)));
        const legacy = !deleted && (selected.some(unverifiedLive) || unbackedProfile ||
            [...txs.values()].some(t => hasLegacyAccessAdjustment(t) || !gateway(t) && txMayBeLive(t)));
        const fingerprint = this.fingerprint(uid, scope, email, user, selected, txs);
        if (legacy) {
            const certificate = (await this.db.collection("access_legacy_audits").doc((0, exports.keyOf)(uid, scope)).get()).data();
            if ((certificate === null || certificate === void 0 ? void 0 : certificate.status) !== "approved" || certificate.policy !== exports.REVOCATION_POLICY ||
                certificate.fingerprint !== fingerprint || certificate.uid !== uid || certificate.scope !== scope ||
                certificate.email !== email || certificate.owner_approved !== true)
                return { allowed: false, reason: "legacy_audit_missing_or_stale", fingerprint, legacy: true };
            for (const tx of txs.values())
                if (hasLegacyAccessAdjustment(tx)) {
                    const decision = (_a = certificate.adjustments) === null || _a === void 0 ? void 0 : _a[tx.id];
                    const explicit = (0, exports.millis)(tx.subscription_expires_at || tx.access_expires_at || tx.expires_at);
                    const honored = selected.find(g => g.id === (decision === null || decision === void 0 ? void 0 : decision.grant_id) && g.kind === "admin" && g.admin_verified === true &&
                        g.source_transaction === tx.id && Number.isFinite(explicit) && g.expires_ms >= explicit);
                    const resolved = (decision === null || decision === void 0 ? void 0 : decision.action) === "honor" && honored ||
                        (decision === null || decision === void 0 ? void 0 : decision.action) === "expired_owner_confirmed" && Number.isFinite(explicit) && explicit <= this.clock() ||
                        (decision === null || decision === void 0 ? void 0 : decision.action) === "void_owner_confirmed" && decision.owner_approved === true && typeof decision.reason === "string" && decision.reason.length > 0;
                    if (!resolved)
                        return { allowed: false, reason: "manual_adjustment_unresolved", fingerprint, legacy: true };
                    if ((honored === null || honored === void 0 ? void 0 : honored.status) === "active" && honored.expires_ms > this.clock())
                        return { allowed: false, reason: "active_owner_adjustment", fingerprint, legacy: true };
                }
        }
        return { allowed: true, reason: deleted ? "account_deleted" : "verified_scope_expired", category, fingerprint, legacy: !!legacy };
    }
    // Billing evidence for one scope, shared by the revocation gate and by the
    // owner certificate tooling so both always hash exactly the same records.
    async scopeTransactions(uid, scope, email) {
        const gateway = (t) => ["midtrans", "doku"].includes(String(t.gateway || "").toLowerCase());
        const txs = new Map();
        for (const [field, value] of [["uid", uid], ["customer_email", email], ["payer_email", email], ["email", email]]) {
            const s = await this.db.collection("transactions").where(field, "==", value).get();
            for (const d of s.docs) {
                const t = d.data();
                // An unpaid gateway checkout proves nothing, and anyone can open one
                // with someone else's address; it must not churn the decision.
                if (gateway(t) && t.activation_applied !== true)
                    continue;
                const scopes = legacyTransactionScopes(t);
                if (!scopes.length || scopes.some(s => [scope, "all_access", "all_ai"].includes(s)))
                    txs.set(d.id, Object.assign({ id: d.id }, t));
            }
        }
        return txs;
    }
    fingerprint(uid, scope, email, user, selected, txs) {
        var _a;
        return evidenceHash({ policy: exports.REVOCATION_POLICY, uid, email, scope,
            owner: { account_deleted: !!user.account_deleted, pending_deletion: !!user.pending_deletion,
                adopted_by: user.adopted_by || null, entitlement: ((_a = user.entitlements) === null || _a === void 0 ? void 0 : _a[scope]) || null },
            grants: [...selected].sort((a, b) => String(a.id).localeCompare(String(b.id))),
            transactions: [...txs.values()].sort((a, b) => a.id.localeCompare(b.id)) });
    }
    // The fingerprint a revocation of (uid, scope) will be checked against, even
    // while the scope is still active or revocations are paused.
    async revocationFingerprint(uid, scope) {
        const { user, grants } = await this.owner(uid);
        const email = (0, exports.normalEmail)(user === null || user === void 0 ? void 0 : user.email);
        if (!user || !email)
            return null;
        const selected = grants.filter(g => [scope, "all_access", "all_ai"].includes(g.scope));
        const txs = await this.scopeTransactions(uid, scope, email);
        return { email, fingerprint: this.fingerprint(uid, scope, email, user, selected, txs), txs, grants };
    }
    async adoptLegacy(uid, legacyUid) {
        const current = await this.db.collection("users").doc(uid).get();
        const legacyRef = this.db.collection("access_legacy_owners").doc(legacyUid);
        const legacy = await legacyRef.get();
        if (!current.exists || !legacy.exists || legacy.data().adopted_by ||
            (0, exports.normalEmail)(current.data().email) !== (0, exports.normalEmail)(legacy.data().email))
            return;
        const oldAssignments = await this.db.collection("access_assignments").where("uid", "==", legacyUid).get();
        const oldGrants = await this.db.collection("access_grants").where("uid", "==", legacyUid).get();
        await this.db.runTransaction(async (t) => {
            const user = (await t.get(current.ref)).data();
            const prior = (await t.get(legacyRef)).data();
            if (!user || !prior || prior.adopted_by || (0, exports.normalEmail)(user.email) !== (0, exports.normalEmail)(prior.email))
                return;
            const assignments = [], grants = [];
            for (const d of oldAssignments.docs) {
                const a = (await t.get(d.ref)).data();
                const target = this.assignmentRef(uid, a.entity);
                const existing = (await t.get(target)).data();
                const identity = this.db.collection("access_identities").doc((0, exports.keyOf)(a.email, a.entity));
                const bound = (await t.get(identity)).data();
                if (existing || (bound === null || bound === void 0 ? void 0 : bound.uid) !== legacyUid)
                    throw new AccessFault("failed-precondition", "Identity adoption conflict");
                assignments.push({ ref: d.ref, a, target, identity });
            }
            for (const d of oldGrants.docs) {
                const g = (await t.get(d.ref)).data();
                if ((g === null || g === void 0 ? void 0 : g.uid) === legacyUid)
                    grants.push(d);
            }
            for (const a of assignments) {
                const revision = a.a.revision + 1;
                const adopted = Object.assign(Object.assign({}, a.a), { uid, revision });
                t.set(a.target, adopted);
                // Jobs belonging to the old UID become stale after ownership transfer.
                // Recreate in-flight work under the verified new owner and revision.
                if (["provisioning", "revoking"].includes(a.a.status)) {
                    const desired = a.a.status === "provisioning";
                    for (const id of desired ? [a.a.notebook_id] : (a.a.history || [a.a.notebook_id])) {
                        t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, a.a.entity, String(revision), id)), Object.assign(Object.assign({}, adopted), { notebook_id: id, desired, status: "pending", attempts: 0, queued_ms: this.clock(), due_ms: this.clock() }));
                    }
                }
                t.update(a.ref, { status: "adopted", adopted_by: uid });
                t.set(a.identity, { uid, entity: a.a.entity, email: a.a.email });
                for (const id of a.a.history || [a.a.notebook_id])
                    t.set(this.db.collection("access_memberships").doc((0, exports.keyOf)(id, a.a.email)), { uid }, { merge: true });
            }
            for (const g of grants)
                t.update(g.ref, { uid });
            t.update(current.ref, { access_version: 2, access_due_ms: this.clock(),
                access_legacy_audit_required: true,
                access_revocation_hold: !!user.access_revocation_hold || !!prior.access_revocation_hold,
                access_grant_ids: [...new Set([...(user.access_grant_ids || []), ...grants.map(g => g.id)])] });
            t.update(legacyRef, { adopted_by: uid, access_due_ms: null });
        });
    }
    async resolve(uid, entity) {
        const { user, grants } = await this.owner(uid);
        if (!rights(user, grants, this.scopes[entity], this.clock()) && (user === null || user === void 0 ? void 0 : user.access_revocation_hold) === true &&
            !user.account_deleted && !user.pending_deletion) {
            // A migration hold preserves the exact existing physical registration;
            // it never allocates a new notebook or invents a financial entitlement.
            const registered = await this.resolveObservedLegacy(uid, user.email, entity);
            const assignment = (await this.assignmentRef(uid, entity).get()).data();
            return Object.assign(Object.assign({}, registered), { status: "ready", revision: (assignment === null || assignment === void 0 ? void 0 : assignment.revision) || 1, legacyReview: true, validUntil: new Date(this.clock() + 60000).toISOString() });
        }
        if (!rights(user, grants, this.scopes[entity], this.clock()))
            throw new AccessFault("permission-denied", "Hak akses kajian ini sudah tidak aktif.");
        const a = (await this.assignmentRef(uid, entity).get()).data();
        if (!a || a.status !== "ready" || a.email !== (0, exports.normalEmail)(user.email)) {
            throw new AccessFault("failed-precondition", "Pembayaran/hak akses tercatat. Akses notebook sedang disiapkan; Anda tidak perlu membeli ulang.");
        }
        const n = (await this.db.collection("access_notebooks").doc(a.notebook_id).get()).data();
        if (!n || n.entity !== entity || !["active", "draining"].includes(n.status) || n.is_public !== false || !a.verified_ms) {
            throw new AccessFault("unavailable", "Notebook sedang diperiksa. Silakan coba lagi.");
        }
        return { status: "ready", url: `https://notebook.google.com/notebook/${a.notebook_id}`, notebookId: a.notebook_id,
            entityCode: entity, revision: a.revision, isMaster: a.notebook_id === this.entities[entity].masterId,
            cloneName: n.name, validUntil: new Date(this.clock() + 60000).toISOString() };
    }
    async resolveObservedLegacy(uid, email, entity) {
        // During migration, preserve proven physical registrations for legacy
        // manual rights. Never invent an assignment from a UID hash or free slot.
        const members = await this.db.collection("access_memberships").where("email", "==", (0, exports.normalEmail)(email)).get();
        const assignment = (await this.assignmentRef(uid, entity).get()).data();
        const e = this.entities[entity];
        const preferred = [assignment === null || assignment === void 0 ? void 0 : assignment.notebook_id, ...(e.legacyIds || []), e.masterId, ...e.clones.map(c => c.id)];
        const candidates = members.docs.map((d) => d.data()).filter((m) => m.entity === entity && m.present && m.verified_ms)
            .sort((a, b) => preferred.indexOf(a.notebook_id) - preferred.indexOf(b.notebook_id));
        for (const member of candidates) {
            const n = (await this.db.collection("access_notebooks").doc(member.notebook_id).get()).data();
            if ((n === null || n === void 0 ? void 0 : n.entity) === entity && n.is_public === false && ["active", "draining"].includes(n.status))
                return { url: `https://notebook.google.com/notebook/${member.notebook_id}`, notebookId: member.notebook_id,
                    entityCode: entity, isMaster: member.notebook_id === e.masterId, cloneName: n.name };
        }
        throw new AccessFault("failed-precondition", "Hak akses lama sedang dicocokkan dengan notebook terdaftar. Anda tidak perlu membeli ulang.");
    }
    async reserve(uid, entity) {
        const { user, grants } = await this.owner(uid);
        if (!rights(user, grants, this.scopes[entity], this.clock()))
            throw new AccessFault("permission-denied", "No current grant");
        if (user.legacy_revoke_only) {
            const existing = (await this.assignmentRef(uid, entity).get()).data();
            if (existing)
                return existing;
            throw new AccessFault("failed-precondition", "Legacy payment identity awaits application signup");
        }
        const email = (0, exports.normalEmail)(user.email);
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
            throw new AccessFault("failed-precondition", "Verified owner email required");
        const e = this.entities[entity];
        if (!e)
            throw new AccessFault("invalid-argument", "Unknown entity");
        const ids = [e.masterId, ...e.clones.map(c => c.id), ...(e.legacyIds || [])];
        const ar = this.assignmentRef(uid, entity);
        const identity = this.db.collection("access_identities").doc((0, exports.keyOf)(email, entity));
        return this.db.runTransaction(async (t) => {
            var _a, _b;
            const existing = (await t.get(ar)).data();
            const bound = (await t.get(identity)).data();
            if (bound && bound.uid !== uid) {
                // The previous owner of this address deleted their account; the
                // address may start over. Any other conflict needs a human.
                const previous = (await t.get(this.db.collection("access_legacy_owners").doc(bound.uid))).data();
                if (!((previous === null || previous === void 0 ? void 0 : previous.account_deleted) === true && (0, exports.normalEmail)(previous.email) === email))
                    throw new AccessFault("failed-precondition", "Google identity requires ownership recovery");
            }
            if (existing && existing.email !== email)
                throw new AccessFault("failed-precondition", "Email change requires verified migration");
            if (existing && ["ready", "provisioning"].includes(existing.status))
                return existing;
            const candidates = [];
            for (const id of ids) {
                const nr = this.db.collection("access_notebooks").doc(id);
                const mr = this.db.collection("access_memberships").doc((0, exports.keyOf)(id, email));
                candidates.push({ id, nr, mr, n: (await t.get(nr)).data(), m: (await t.get(mr)).data() });
            }
            // Reuse observed registration before waterfall: imports retain the real
            // notebook and do not consume a second seat, including legacy notebooks.
            const found = candidates.find(c => { var _a, _b, _c; return ((_a = c.m) === null || _a === void 0 ? void 0 : _a.present) === true && ((_b = c.n) === null || _b === void 0 ? void 0 : _b.is_public) === false && ["active", "draining"].includes((_c = c.n) === null || _c === void 0 ? void 0 : _c.status); }) ||
                candidates.find(c => {
                    var _a, _b, _c, _d;
                    return !((_a = e.legacyIds) === null || _a === void 0 ? void 0 : _a.includes(c.id)) && ((_b = c.n) === null || _b === void 0 ? void 0 : _b.status) === "active" && ((_c = c.n) === null || _c === void 0 ? void 0 : _c.is_public) === false &&
                        ((_d = c.n) === null || _d === void 0 ? void 0 : _d.healthy_until_ms) > this.clock() && c.n.occupied < Math.min(2000, c.n.admission_limit || 1995);
                });
            if (!found)
                throw new AccessFault("resource-exhausted", "paid_waiting_capacity");
            const revision = ((existing === null || existing === void 0 ? void 0 : existing.revision) || 0) + 1;
            const assignment = { uid, entity, scope: this.scopes[entity], email, notebook_id: found.id,
                status: "provisioning", revision, created_ms: (existing === null || existing === void 0 ? void 0 : existing.created_ms) || this.clock(),
                history: [...new Set([...((existing === null || existing === void 0 ? void 0 : existing.history) || []), found.id])], updated_ms: this.clock() };
            if (!((_a = found.m) === null || _a === void 0 ? void 0 : _a.present))
                t.update(found.nr, { occupied: found.n.occupied + 1 });
            t.set(found.mr, { uid, entity, email, notebook_id: found.id, present: ((_b = found.m) === null || _b === void 0 ? void 0 : _b.present) === true,
                counted: true, revision, reserved_ms: this.clock() }, { merge: true });
            t.set(identity, { uid, email, entity });
            t.set(ar, assignment);
            t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, entity, String(revision))), Object.assign(Object.assign({}, assignment), { desired: true, status: "pending", attempts: 0, queued_ms: this.clock(), due_ms: this.clock() }));
            return assignment;
        });
    }
    async importObserved(uid, entity, observedMembers) {
        const { user } = await this.owner(uid);
        const email = (0, exports.normalEmail)(user === null || user === void 0 ? void 0 : user.email);
        if (!email)
            return;
        const observed = observedMembers || (await this.db.collection("access_memberships").where("email", "==", email).get()).docs;
        const members = observed.map((d) => (Object.assign({ ref: d.ref }, d.data())))
            .filter((m) => m.entity === entity && m.present && m.verified_ms);
        if (!members.length)
            return;
        const ar = this.assignmentRef(uid, entity);
        const identity = this.db.collection("access_identities").doc((0, exports.keyOf)(email, entity));
        await this.db.runTransaction(async (t) => {
            const existing = (await t.get(ar)).data();
            const bound = (await t.get(identity)).data();
            if (existing)
                return;
            if (bound && bound.uid !== uid)
                throw new AccessFault("failed-precondition", "Google identity requires ownership recovery");
            const e = this.entities[entity];
            const preferred = [...(e.legacyIds || []), e.masterId, ...e.clones.map(c => c.id)];
            const ids = members.map((m) => m.notebook_id).sort((a, b) => preferred.indexOf(a) - preferred.indexOf(b));
            t.set(ar, { uid, email, entity, scope: this.scopes[entity], notebook_id: ids[0], history: ids,
                status: "ready", revision: 1, verified_ms: Math.min(...members.map((m) => m.verified_ms)),
                created_ms: this.clock(), updated_ms: this.clock(), imported: true });
            t.set(identity, { uid, email, entity });
            for (const m of members)
                t.set(m.ref, { uid }, { merge: true });
        });
    }
    async revoke(uid, entity) {
        const assessment = await this.assessRevocation(uid, this.scopes[entity]);
        if (assessment.reason === "identity_rebound") {
            await this.db.runTransaction(async (t) => {
                const ar = this.assignmentRef(uid, entity), a = (await t.get(ar)).data();
                if (a && !["revoked", "transferred"].includes(a.status))
                    t.update(ar, { status: "transferred", updated_ms: this.clock() });
            });
            return;
        }
        if (!assessment.allowed) {
            if (!["active_scope", "permanent_vip", "incident_pause"].includes(assessment.reason))
                await this.db.collection("access_reviews").doc((0, exports.keyOf)(uid, entity, "revocation_gate")).set({ uid, entity, scope: this.scopes[entity],
                    code: assessment.reason, fingerprint: assessment.fingerprint || null, status: "blocked", updated_ms: this.clock() });
            return;
        }
        const { user, grants } = await this.owner(uid);
        if ((user === null || user === void 0 ? void 0 : user.access_revocation_hold) || rights(user, grants, this.scopes[entity], this.clock()))
            return;
        const ar = this.assignmentRef(uid, entity);
        await this.db.runTransaction(async (t) => {
            var _a;
            const a = (await t.get(ar)).data();
            if (!a || ["revoked", "revoking", "transferred"].includes(a.status))
                return;
            const permanent = await t.get(this.db.collection("access_vip_registry").doc((0, exports.keyOf)(a.email)));
            if ((0, exports.isVip)({ email: a.email }, grants) || permanent.exists)
                return;
            // A notebook Google no longer has cannot hold the viewer; a removal job
            // there would retry forever and keep the assignment from settling.
            const targets = [];
            for (const notebook of a.history || [a.notebook_id])
                if (((_a = (await t.get(this.db.collection("access_notebooks").doc(notebook))).data()) === null || _a === void 0 ? void 0 : _a.status) !== "missing")
                    targets.push(notebook);
            const revision = a.revision + 1;
            t.update(ar, { status: "revoking", revision, updated_ms: this.clock() });
            for (const notebook of targets) {
                t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, entity, String(revision), notebook)), Object.assign(Object.assign({}, a), { notebook_id: notebook, revision, desired: false, decision_fingerprint: assessment.fingerprint, decision_policy: exports.REVOCATION_POLICY, status: "pending", attempts: 0, queued_ms: this.clock(), due_ms: this.clock() }));
            }
        });
    }
    // Moves a paying member off a notebook that Google no longer has onto the
    // next healthy one (master first, then clones), the same waterfall as reserve.
    async relocate(uid, entity) {
        const { user, grants } = await this.owner(uid);
        if (!rights(user, grants, this.scopes[entity], this.clock()))
            return false;
        const e = this.entities[entity];
        if (!e)
            return false;
        const ar = this.assignmentRef(uid, entity);
        return this.db.runTransaction(async (t) => {
            var _a, _b;
            const a = (await t.get(ar)).data();
            if (!a || !["ready", "provisioning"].includes(a.status))
                return false;
            const current = (await t.get(this.db.collection("access_notebooks").doc(a.notebook_id))).data();
            if ((current === null || current === void 0 ? void 0 : current.status) !== "missing")
                return false;
            const candidates = [];
            for (const id of [e.masterId, ...e.clones.map(c => c.id)]) {
                if (id === a.notebook_id)
                    continue;
                const nr = this.db.collection("access_notebooks").doc(id), mr = this.db.collection("access_memberships").doc((0, exports.keyOf)(id, a.email));
                candidates.push({ id, nr, mr, n: (await t.get(nr)).data(), m: (await t.get(mr)).data() });
            }
            const found = candidates.find(c => {
                var _a, _b, _c;
                return ((_a = c.n) === null || _a === void 0 ? void 0 : _a.status) === "active" && ((_b = c.n) === null || _b === void 0 ? void 0 : _b.is_public) === false &&
                    ((_c = c.n) === null || _c === void 0 ? void 0 : _c.healthy_until_ms) > this.clock() && c.n.occupied < Math.min(2000, c.n.admission_limit || 1995);
            });
            if (!found)
                throw new AccessFault("resource-exhausted", "paid_waiting_capacity");
            const revision = a.revision + 1;
            const moved = Object.assign(Object.assign({}, a), { notebook_id: found.id, status: "provisioning", revision, history: [...new Set([...(a.history || [a.notebook_id]), found.id])], relocated_from: a.notebook_id, updated_ms: this.clock() });
            if (!((_a = found.m) === null || _a === void 0 ? void 0 : _a.present))
                t.update(found.nr, { occupied: found.n.occupied + 1 });
            t.set(found.mr, { uid, entity, email: a.email, notebook_id: found.id, present: ((_b = found.m) === null || _b === void 0 ? void 0 : _b.present) === true,
                counted: true, revision, reserved_ms: this.clock() }, { merge: true });
            t.set(ar, moved);
            t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, entity, String(revision))), Object.assign(Object.assign({}, moved), { desired: true, status: "pending", attempts: 0, queued_ms: this.clock(), due_ms: this.clock() }));
            return true;
        });
    }
    async repair(uid, entity) {
        const owner = await this.owner(uid);
        if (!rights(owner.user, owner.grants, this.scopes[entity], this.clock()))
            return this.revoke(uid, entity);
        const ar = this.assignmentRef(uid, entity);
        await this.db.runTransaction(async (t) => {
            const a = (await t.get(ar)).data();
            if (!a || a.status !== "ready")
                return;
            const revision = a.revision + 1;
            t.update(ar, { status: "provisioning", revision, updated_ms: this.clock() });
            t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, entity, String(revision))), Object.assign(Object.assign({}, a), { revision, desired: true, status: "pending", attempts: 0, queued_ms: this.clock(), due_ms: this.clock() }));
        });
    }
    async restoreOriginalMembership(ref, job) {
        if (!this.provider || job.original_present !== true)
            throw new Error("Restoration requires recorded original membership");
        const restored = await this.provider.apply(job.notebook_id, job.email, true);
        this.validateObservation(restored, job.notebook_id);
        if (!restored.emails.map(exports.normalEmail).includes(job.email))
            throw new Error("Safety restoration not verified");
        const owner = await this.owner(job.uid);
        await this.db.runTransaction(async (t) => {
            const ar = this.assignmentRef(job.uid, job.entity), mr = this.db.collection("access_memberships").doc((0, exports.keyOf)(job.notebook_id, job.email));
            const nr = this.db.collection("access_notebooks").doc(job.notebook_id);
            const a = (await t.get(ar)).data(), m = (await t.get(mr)).data(), n = (await t.get(nr)).data();
            const identity = (await t.get(this.db.collection("access_identities").doc((0, exports.keyOf)(job.email, job.entity)))).data();
            t.set(mr, { uid: (identity === null || identity === void 0 ? void 0 : identity.uid) || (m === null || m === void 0 ? void 0 : m.uid) || job.uid, email: job.email, entity: job.entity, notebook_id: job.notebook_id,
                present: true, counted: true, verified_ms: this.clock() }, { merge: true });
            if (n)
                t.update(nr, { occupied: Math.max(n.occupied + (m && !m.counted ? 1 : 0), restored.emails.length) });
            if ((a === null || a === void 0 ? void 0 : a.revision) === job.revision)
                t.update(ar, { status: rights(owner.user, owner.grants, job.scope, this.clock()) ? "ready" : "revocation_review",
                    verified_ms: this.clock() });
            t.update(ref, { status: "review_required", safety_restore_required: false, restored_ms: this.clock(),
                due_ms: 8640000000000000, review_reason: "incomplete_or_invalidated_removal_restored" });
        });
    }
    async blockRemovalJob(ref, job, reason) {
        await this.db.runTransaction(async (t) => {
            const ar = this.assignmentRef(job.uid, job.entity), current = (await t.get(ar)).data();
            t.update(ref, { status: "review_required", due_ms: 8640000000000000, review_reason: reason, updated_ms: this.clock() });
            if ((current === null || current === void 0 ? void 0 : current.revision) === job.revision)
                t.update(ar, { status: "revocation_review" });
        });
        await this.db.collection("access_reviews").doc((0, exports.keyOf)(job.uid, job.entity, "revocation_gate")).set({ uid: job.uid, entity: job.entity, code: reason, status: "blocked", updated_ms: this.clock() });
    }
    async runJob(ref) {
        if (!this.provider)
            throw new Error("Sharing provider is not configured");
        const token = crypto.randomUUID(), now = this.clock();
        const job = await this.db.runTransaction(async (t) => {
            const j = (await t.get(ref)).data();
            if (!j || !["pending", "retry", "processing"].includes(j.status) || j.due_ms > now)
                return null;
            const lr = this.db.collection("access_locks").doc((0, exports.keyOf)(j.notebook_id, j.email));
            const lock = (await t.get(lr)).data();
            if ((lock === null || lock === void 0 ? void 0 : lock.until_ms) > now)
                return null;
            t.set(lr, { token, until_ms: now + 600000 });
            t.update(ref, { status: "processing", lease: token, due_ms: now + 600000, attempts: (j.attempts || 0) + 1 });
            return Object.assign(Object.assign({}, j), { lockRef: lr, attempts: (j.attempts || 0) + 1 });
        });
        if (!job)
            return;
        let removalAttempted = false, restorationCompleted = false;
        try {
            // This recovery precedes all expiry/pause checks. A process killed after
            // Google removed access must first restore the previously observed state.
            if (job.safety_restore_required === true) {
                await this.restoreOriginalMembership(ref, job);
                return;
            }
            let owner = await this.owner(job.uid);
            const a = (await this.assignmentRef(job.uid, job.entity).get()).data();
            const bound = (await this.db.collection("access_identities").doc((0, exports.keyOf)(job.email, job.entity)).get()).data();
            if (!a || (bound === null || bound === void 0 ? void 0 : bound.uid) !== job.uid || a.revision !== job.revision || job.desired !== rights(owner.user, owner.grants, job.scope, this.clock())) {
                await ref.update({ status: "superseded", due_ms: 8640000000000000 });
                return;
            }
            let assessment;
            if (!job.desired) {
                assessment = await this.assessRevocation(job.uid, job.scope, job.email);
                if (!assessment.allowed || job.decision_policy !== exports.REVOCATION_POLICY || job.decision_fingerprint !== assessment.fingerprint) {
                    await this.blockRemovalJob(ref, job, assessment.allowed ? "stale_decision" : assessment.reason);
                    return;
                }
            }
            let observation;
            if (!job.desired) {
                const before = await this.provider.observe(job.notebook_id);
                this.validateObservation(before, job.notebook_id);
                const preMutation = await this.assessRevocation(job.uid, job.scope, job.email);
                if (!preMutation.allowed || preMutation.fingerprint !== assessment.fingerprint) {
                    await this.blockRemovalJob(ref, job, preMutation.allowed ? "stale_decision" : preMutation.reason);
                    return;
                }
                job.original_present = before.emails.map(exports.normalEmail).includes(job.email);
                if (job.original_present && !(await this.takeRevocationSlot())) {
                    await ref.update({ status: "retry", last_error: "revocation_hourly_quota", due_ms: this.clock() + 600000, updated_ms: this.clock() });
                    return;
                }
                if (job.original_present) {
                    // Persist intent before the external side effect. The flag is only
                    // cleared with verified completion or verified safety restoration.
                    await ref.update({ original_present: true, safety_restore_required: true, mutation_started_ms: this.clock() });
                    removalAttempted = true;
                    observation = await this.provider.apply(job.notebook_id, job.email, false);
                }
                else
                    observation = before;
            }
            else
                observation = await this.provider.apply(job.notebook_id, job.email, true);
            this.validateObservation(observation, job.notebook_id);
            const present = observation.emails.map(exports.normalEmail).includes(job.email);
            if (present !== job.desired)
                throw new Error("Target membership not verified");
            owner = await this.owner(job.uid);
            const desiredNow = rights(owner.user, owner.grants, job.scope, this.clock());
            if (!job.desired) {
                const after = await this.assessRevocation(job.uid, job.scope, job.email);
                if (!after.allowed || after.fingerprint !== assessment.fingerprint) {
                    // A hold, manual change, renewal or pause arriving while Google was
                    // running invalidates the removal even when expiry still looks old.
                    if (job.original_present) {
                        await this.restoreOriginalMembership(ref, job);
                        restorationCompleted = true;
                    }
                    else
                        await this.blockRemovalJob(ref, job, "decision_changed_without_original_membership");
                    return;
                }
            }
            if (desiredNow !== job.desired) {
                if (!desiredNow) {
                    // Grant jobs are never authorized to remove access. Require a new
                    // removal job with its own scope proof and policy fingerprint.
                    throw new Error("Grant changed; a separately assessed revocation is required");
                }
                // Database and Google are not atomic. Repair a concurrent renewal or
                // expiry before declaring the stale operation complete.
                await this.provider.apply(job.notebook_id, job.email, desiredNow);
                throw new Error("Grant changed during external operation; repair queued");
            }
            await this.db.runTransaction(async (t) => {
                const current = (await t.get(this.assignmentRef(job.uid, job.entity))).data();
                const lock = (await t.get(job.lockRef)).data();
                const mr = this.db.collection("access_memberships").doc((0, exports.keyOf)(job.notebook_id, job.email));
                const member = (await t.get(mr)).data();
                const nr = this.db.collection("access_notebooks").doc(job.notebook_id);
                const notebook = (await t.get(nr)).data();
                if ((lock === null || lock === void 0 ? void 0 : lock.token) !== token || (current === null || current === void 0 ? void 0 : current.revision) !== job.revision)
                    throw new Error("Lease/revision changed after sharing");
                t.set(mr, { present, verified_ms: this.clock() }, { merge: true });
                if (!present && (member === null || member === void 0 ? void 0 : member.counted) && notebook) {
                    t.update(nr, { occupied: Math.max(0, notebook.occupied - 1) });
                    t.set(mr, { counted: false }, { merge: true });
                }
                t.update(ref, { status: "completed", safety_restore_required: false, due_ms: 8640000000000000, verified_ms: this.clock() });
                // For multi-target revokes only this target is confirmed here. A later
                // reconciliation marks the overall assignment revoked once all finish.
                if (job.desired)
                    t.update(this.assignmentRef(job.uid, job.entity), { status: "ready", verified_ms: this.clock() });
            });
        }
        catch (e) {
            if (removalAttempted && !restorationCompleted) {
                try {
                    await this.restoreOriginalMembership(ref, job);
                    return;
                }
                catch (_) { /* Keep the durable recovery flag for the next attempt. */ }
            }
            await ref.update({ status: "retry", last_error: String(e.message).slice(0, 240),
                due_ms: this.clock() + Math.min(300000, 1000 * 2 ** Math.min(job.attempts, 8)), updated_ms: this.clock() });
        }
        finally {
            await this.db.runTransaction(async (t) => {
                var _a;
                if (((_a = (await t.get(job.lockRef)).data()) === null || _a === void 0 ? void 0 : _a.token) === token)
                    t.delete(job.lockRef);
            });
        }
    }
    // At most `revocation_hourly_limit` (default 200) removals per clock hour, so
    // a wrong ledger state can never empty the notebooks in one sweep.
    async takeRevocationSlot() {
        const runtime = (await this.db.collection("access_control").doc("runtime").get()).data() || {};
        const limit = Number.isInteger(runtime.revocation_hourly_limit) && runtime.revocation_hourly_limit >= 0 ? runtime.revocation_hourly_limit : 200;
        const ref = this.db.collection("access_control").doc("revocation_quota");
        return this.db.runTransaction(async (t) => {
            const q = (await t.get(ref)).data() || {}, hour = Math.floor(this.clock() / 3600000);
            const used = q.hour === hour ? q.used || 0 : 0;
            if (used >= limit)
                return false;
            t.set(ref, { hour, used: used + 1 });
            return true;
        });
    }
    validateObservation(s, id) {
        if (s.notebookId !== id || !s.complete || s.isPublic || !Array.isArray(s.emails) || s.emails.some(e => !(0, exports.normalEmail)(e).includes("@"))) {
            throw new Error("Notebook is public or sharing evidence is incomplete");
        }
    }
}
exports.AccessControl = AccessControl;
//# sourceMappingURL=access_control.js.map