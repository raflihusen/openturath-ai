"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AccessControl = exports.AccessFault = exports.isVip = exports.millis = exports.keyOf = exports.normalEmail = exports.VIP_EMAILS = void 0;
exports.billingExpiry = billingExpiry;
exports.verifiedAkalPeriods = verifiedAkalPeriods;
exports.rights = rights;
const crypto = require("crypto");
// Shared by Firebase callable functions and the Ubuntu worker. No Google RPC in
// database transactions; opening a notebook never allocates a seat.
exports.VIP_EMAILS = new Set([
    "openturath@gmail.com", "ramah@ptct.net", "raflimaulan@gmail.com", "mas.raflihusen@gmail.com",
    "alkhateeb23@gmail.com", "omarasb1441@gmail.com", "prilatief@gmail.com", "udinvoldigoad05@gmail.com",
    "aaadman40@gmail.com", "abo.omar5539@gmail.com", "abualgilani2024@gmail.com", "ahobh4241@gmail.com",
    "alhamodi65@gmail.com", "ali.bafdhl36@gmail.com", "alshykhkmalbahrmz@gmail.com", "atinrahmak@gmail.com",
    "hafamfb551985@gmail.com", "loyos839@gmail.com", "mohammedhalahdal@gmail.com", "mostajadt25@gmail.com",
    "nona.alyaziza@gmail.com", "omar739037802@gmail.com", "yasser110271@gmail.com",
]);
const normalEmail = (s) => typeof s === "string" ? s.trim().toLowerCase() : "";
exports.normalEmail = normalEmail;
const keyOf = (...parts) => crypto.createHash("sha256").update(JSON.stringify(parts)).digest("hex");
exports.keyOf = keyOf;
const millis = (v) => { var _a, _b; return (_b = (_a = v === null || v === void 0 ? void 0 : v.toMillis) === null || _a === void 0 ? void 0 : _a.call(v)) !== null && _b !== void 0 ? _b : ((v === null || v === void 0 ? void 0 : v.toDate) ? v.toDate().getTime() : typeof v === "number" ? v : Date.parse(v || "")); };
exports.millis = millis;
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
                        t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, a.a.entity, String(revision), id)), Object.assign(Object.assign({}, adopted), { notebook_id: id, desired, status: "pending", attempts: 0, due_ms: this.clock() }));
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
                access_grant_ids: [...new Set([...(user.access_grant_ids || []), ...grants.map(g => g.id)])] });
            t.update(legacyRef, { adopted_by: uid });
        });
    }
    async resolve(uid, entity) {
        const { user, grants } = await this.owner(uid);
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
            if (bound && bound.uid !== uid)
                throw new AccessFault("failed-precondition", "Google identity requires ownership recovery");
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
            t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, entity, String(revision))), Object.assign(Object.assign({}, assignment), { desired: true, status: "pending", attempts: 0, due_ms: this.clock() }));
            return assignment;
        });
    }
    async importObserved(uid, entity) {
        const { user } = await this.owner(uid);
        const email = (0, exports.normalEmail)(user === null || user === void 0 ? void 0 : user.email);
        if (!email)
            return;
        const observed = await this.db.collection("access_memberships").where("email", "==", email).get();
        const members = observed.docs.map((d) => (Object.assign({ ref: d.ref }, d.data())))
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
        const { user, grants } = await this.owner(uid);
        if ((user === null || user === void 0 ? void 0 : user.access_revocation_hold) || rights(user, grants, this.scopes[entity], this.clock()))
            return;
        const ar = this.assignmentRef(uid, entity);
        await this.db.runTransaction(async (t) => {
            const a = (await t.get(ar)).data();
            if (!a || ["revoked", "revoking"].includes(a.status))
                return;
            const permanent = await t.get(this.db.collection("access_vip_registry").doc((0, exports.keyOf)(a.email)));
            if ((0, exports.isVip)({ email: a.email }, grants) || permanent.exists)
                return;
            const revision = a.revision + 1;
            t.update(ar, { status: "revoking", revision, updated_ms: this.clock() });
            for (const notebook of a.history || [a.notebook_id]) {
                t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, entity, String(revision), notebook)), Object.assign(Object.assign({}, a), { notebook_id: notebook, revision, desired: false, status: "pending", attempts: 0, due_ms: this.clock() }));
            }
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
            t.set(this.db.collection("access_jobs").doc((0, exports.keyOf)(uid, entity, String(revision))), Object.assign(Object.assign({}, a), { revision, desired: true, status: "pending", attempts: 0, due_ms: this.clock() }));
        });
    }
    async runJob(ref) {
        var _a;
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
            t.set(lr, { token, until_ms: now + 300000 });
            t.update(ref, { status: "processing", lease: token, due_ms: now + 300000, attempts: (j.attempts || 0) + 1 });
            return Object.assign(Object.assign({}, j), { lockRef: lr, attempts: (j.attempts || 0) + 1 });
        });
        if (!job)
            return;
        try {
            let owner = await this.owner(job.uid);
            const a = (await this.assignmentRef(job.uid, job.entity).get()).data();
            const bound = (await this.db.collection("access_identities").doc((0, exports.keyOf)(job.email, job.entity)).get()).data();
            if (!a || (bound === null || bound === void 0 ? void 0 : bound.uid) !== job.uid || a.revision !== job.revision || job.desired !== rights(owner.user, owner.grants, job.scope, this.clock())) {
                await ref.update({ status: "superseded", due_ms: 8640000000000000 });
                return;
            }
            if (!job.desired) {
                const permanent = await this.db.collection("access_vip_registry").doc((0, exports.keyOf)(job.email)).get();
                if (((_a = owner.user) === null || _a === void 0 ? void 0 : _a.access_revocation_hold) || (0, exports.isVip)(Object.assign(Object.assign({}, owner.user), { email: job.email }), owner.grants) || permanent.exists)
                    throw new Error("Protected or unresolved legacy owner");
            }
            const observation = await this.provider.apply(job.notebook_id, job.email, job.desired);
            this.validateObservation(observation, job.notebook_id);
            const present = observation.emails.map(exports.normalEmail).includes(job.email);
            if (present !== job.desired)
                throw new Error("Target membership not verified");
            owner = await this.owner(job.uid);
            const desiredNow = rights(owner.user, owner.grants, job.scope, this.clock());
            if (desiredNow !== job.desired) {
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
                t.update(ref, { status: "completed", due_ms: 8640000000000000, verified_ms: this.clock() });
                // For multi-target revokes only this target is confirmed here. A later
                // reconciliation marks the overall assignment revoked once all finish.
                if (job.desired)
                    t.update(this.assignmentRef(job.uid, job.entity), { status: "ready", verified_ms: this.clock() });
            });
        }
        catch (e) {
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
    validateObservation(s, id) {
        if (s.notebookId !== id || !s.complete || s.isPublic || !Array.isArray(s.emails) || s.emails.some(e => !(0, exports.normalEmail)(e).includes("@"))) {
            throw new Error("Notebook is public or sharing evidence is incomplete");
        }
    }
}
exports.AccessControl = AccessControl;
//# sourceMappingURL=access_control.js.map