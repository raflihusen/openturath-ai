"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const child_process_1 = require("child_process");
const http_1 = require("http");
const promises_1 = require("fs/promises");
const util_1 = require("util");
const access_control_1 = require("./access_control");
const notebook_catalog_1 = require("./notebook_catalog");
const access_catalog_1 = require("./access_catalog");
admin.initializeApp({ projectId: process.env.GOOGLE_CLOUD_PROJECT || "open-turath" });
const db = admin.firestore();
const telemetry = { last_provider_success_ms: 0, authentication_error: false, session_refreshes: 0 };
const execute = (0, util_1.promisify)(child_process_1.execFile);
let refreshing, lastRefreshAttempt = 0;
async function refreshConsentedSession() {
    if (refreshing)
        return refreshing;
    const cli = process.env.ACCESS_NOTEBOOKLM_CLI, owner = process.env.ACCESS_OWNER_EMAIL;
    const storage = process.env.NOTEBOOKLM_STORAGE_PATH;
    if (!cli || !owner || !storage || Date.now() - lastRefreshAttempt < 60000)
        throw new Error("Owner session unavailable");
    lastRefreshAttempt = Date.now();
    refreshing = (async () => {
        const temporary = `${storage}.refresh`;
        // Reuse only the explicitly consented owner's existing browser login.
        // The CLI does not automate login or mint credentials for another account.
        await execute(cli, ["login", "--browser-cookies", "chrome", "--account", owner, "--storage", temporary], { timeout: 60000, maxBuffer: 1048576 });
        await (0, promises_1.chmod)(temporary, 0o600);
        await (0, promises_1.rename)(temporary, storage);
        telemetry.session_refreshes++;
    })();
    try {
        await refreshing;
    }
    finally {
        refreshing = undefined;
    }
}
const requestProvider = (request) => new Promise((resolve, reject) => {
    var _a;
    const python = process.env.ACCESS_PYTHON;
    const adapter = process.env.ACCESS_SHARING_ADAPTER;
    if (!python || !adapter)
        return reject(new Error("Sharing adapter not configured"));
    const child = (0, child_process_1.execFile)(python, [adapter], { timeout: 100000, maxBuffer: 8 * 1024 * 1024 }, (error, out) => {
        try {
            const data = JSON.parse(out);
            if (data.code === "authentication_unavailable")
                return reject(Object.assign(new Error("Owner session unavailable"), { authentication: true }));
            if (error || data.error)
                return reject(new Error("Sharing provider unavailable"));
            telemetry.last_provider_success_ms = Date.now();
            telemetry.authentication_error = false;
            resolve(data);
        }
        catch (_) {
            reject(new Error("Invalid sharing evidence"));
        }
    });
    (_a = child.stdin) === null || _a === void 0 ? void 0 : _a.end(JSON.stringify(request));
});
async function callProvider(request) {
    try {
        return await requestProvider(request);
    }
    catch (error) {
        if (!error.authentication)
            throw error;
        telemetry.authentication_error = true;
        await refreshConsentedSession();
        return requestProvider(request);
    }
}
const provider = {
    observe: notebookId => callProvider({ notebookId, operation: "observe" }),
    apply: (notebookId, email, desired) => callProvider({ notebookId, email, desired, operation: "apply" }),
};
const engine = new access_control_1.AccessControl(db, notebook_catalog_1.NOTEBOOK_ENTITIES, access_catalog_1.ENTITY_SCOPES, provider);
const runtime = db.collection("access_control").doc("runtime");
const stats = { started_ms: Date.now(), last_cycle_ms: 0, last_success_ms: 0, mode: "starting", error: "", cycles: 0 };
async function pages(collection, visit) {
    let cursor;
    while (true) {
        let q = db.collection(collection).orderBy(admin.firestore.FieldPath.documentId()).limit(100);
        if (cursor)
            q = q.startAfter(cursor);
        const page = await q.get();
        if (page.empty)
            return;
        for (const doc of page.docs)
            await visit(doc);
        cursor = page.docs[page.docs.length - 1];
    }
}
function notebooks(e) {
    return [{ id: e.masterId, name: e.name }, ...e.clones, ...(e.legacyIds || []).map(id => ({ id, name: "Legacy", legacy: true }))];
}
async function seed(restrict = false) {
    const targets = Object.values(notebook_catalog_1.NOTEBOOK_ENTITIES).flatMap(entity => notebooks(entity).map(n => ({ entity, n })));
    let cursor = 0;
    const inspect = async () => {
        while (cursor < targets.length) {
            const { entity, n } = targets[cursor++];
            const nr = db.collection("access_notebooks").doc(n.id);
            const existing = (await nr.get()).data();
            // Never reset a live counter from a snapshot while reservations can run.
            if (existing && !restrict)
                continue;
            try {
                const observed = restrict
                    ? await callProvider({ notebookId: n.id, operation: "restrict" }) : await provider.observe(n.id);
                if (!observed.complete || observed.emails.some(e => !(0, access_control_1.normalEmail)(e).includes("@")))
                    throw new Error("Incomplete identity list");
                if (!existing) {
                    await nr.set({ entity: entity.code, name: n.name, occupied: observed.emails.length,
                        admission_limit: 1995, hard_limit: 2000, status: observed.isPublic ? "quarantined" : n.legacy ? "draining" : "active",
                        is_public: observed.isPublic, healthy_until_ms: Date.now() + 86400000, observed_ms: Date.now() });
                }
                else if (restrict) {
                    await nr.update({ is_public: observed.isPublic, status: observed.isPublic ? "quarantined" : n.legacy ? "draining" : "active",
                        healthy_until_ms: Date.now() + 86400000, observed_ms: Date.now() });
                }
                for (const email of observed.emails) {
                    const mr = db.collection("access_memberships").doc((0, access_control_1.keyOf)(n.id, (0, access_control_1.normalEmail)(email)));
                    if (!(await mr.get()).exists)
                        await mr.set({ notebook_id: n.id, entity: entity.code, email: (0, access_control_1.normalEmail)(email),
                            present: true, counted: true, verified_ms: Date.now(), imported: true });
                }
                console.log(JSON.stringify({ event: "notebook_observed", notebook: n.id, viewers: observed.emails.length, public: observed.isPublic }));
            }
            catch (_) {
                console.log(JSON.stringify({ event: "notebook_unavailable", notebook: n.id }));
            }
        }
    };
    await Promise.all([inspect(), inspect(), inspect()]);
}
async function importOwner(doc) {
    const uid = doc.id, u = doc.data(), email = (0, access_control_1.normalEmail)(u.email);
    if (!email)
        return;
    if (!u.legacy_revoke_only) {
        const authOwner = await admin.auth().getUser(uid);
        if (!authOwner.emailVerified || (0, access_control_1.normalEmail)(authOwner.email) !== email)
            return;
        await engine.adoptLegacy(uid, `legacy_${(0, access_control_1.keyOf)(email)}`);
    }
    const txs = new Map();
    for (const [field, value] of [["uid", uid], ["customer_email", email], ["payer_email", email], ["email", email]]) {
        const snap = await db.collection("transactions").where(field, "==", value).get();
        for (const tx of snap.docs)
            txs.set(tx.id, tx.data());
    }
    const fresh = (await doc.ref.get()).data();
    const ids = new Set(fresh.access_grant_ids || []);
    if ((0, access_control_1.isVip)(u) || [...txs.values()].some(t => String(t.status).toUpperCase() === "VIP_PERMANENT" || String(t.plan).toUpperCase() === "VIP_PERMANENT" || t.is_vip === true)) {
        const id = (0, access_control_1.keyOf)("vip", uid);
        await db.collection("access_grants").doc(id).set({ uid, kind: "VIP_PERMANENT", scope: "all_access", status: "active" }, { merge: true });
        ids.add(id);
    }
    const verifiedProvider = (await engine.grants(uid)).some(g => g.provider === "goakal" && g.provider_verified === true);
    const unresolved = [];
    for (const [id, tx] of txs) {
        if (tx.uid && tx.uid !== uid)
            continue;
        if (verifiedProvider && String(tx.source || "").toLowerCase() === "goakal")
            continue;
        const paidStatus = ["paid", "success", "settled", "settlement"].includes(String(tx.status).toLowerCase());
        const settledBeforeExpiry = String(tx.status).toLowerCase() === "expired" && tx.activation_applied === true && tx.paid_at;
        if ((!paidStatus && !settledBeforeExpiry) || !(Number(tx.amount) > 0))
            continue;
        const labels = {
            "AI Fikih Tahawwulat": "fiqh_tahawwulat", "Fikih Tahawwulat": "fiqh_tahawwulat",
            "AI Fikih Syafi'i": "fiqh_syafii", "AI Fikih Syafii": "fiqh_syafii", "Fikih Syafi'i": "fiqh_syafii",
            "AI Ushul Fiqih": "ushul_fiqh", "AI Hadits": "hadits", "AI Tafsir": "tafsir", "AI Bahasa Arab": "nahwu",
        };
        const scope = tx.entitlement_key || access_catalog_1.AGENT_ENTITLEMENTS[tx.agent_id] || labels[tx.service_name] ||
            (/^all_ai(?:_1m|_6m|_1y)?$/.test(tx.plan || "") ? "all_access" : "");
        if (!Object.values(access_catalog_1.ENTITY_SCOPES).includes(scope) && !["all_access", "all_ai"].includes(scope)) {
            unresolved.push(id);
            continue;
        }
        const gid = tx.invoice_number ? (0, access_control_1.keyOf)("invoice", tx.invoice_number) : (0, access_control_1.keyOf)("legacy_tx", id);
        const gr = db.collection("access_grants").doc(gid);
        const prior = (await gr.get()).data();
        if (prior) {
            if (prior.uid === uid)
                ids.add(gid);
            continue;
        }
        const paid = (0, access_control_1.millis)(tx.paid_at || tx.completed_at || tx.payment_time);
        const explicit = (0, access_control_1.millis)(tx.subscription_expires_at || tx.access_expires_at || tx.expires_at);
        // Legacy one-month records are capped by real payment time + 30 days.
        // Unknown timestamps/plan durations are review cases, never auto-removals.
        const plan = String(tx.plan || "").toLowerCase();
        const months = Number(tx.duration_months) || (/(1y|tahun|annual)/.test(plan) ? 12 : /6m/.test(plan) ? 6 : /1m|tholib/.test(plan) ? 1 : 0);
        if (!Number.isFinite(paid) || !months) {
            unresolved.push(id);
            continue;
        }
        const calculated = (0, access_control_1.billingExpiry)(paid, months);
        const expiry = Number.isFinite(explicit) ? Math.min(explicit, calculated) : calculated;
        await gr.set({ uid, scope, kind: "payment", status: "active", amount: Number(tx.amount), transaction_document: id,
            invoice_number: tx.invoice_number || null, starts_ms: paid, expires_ms: expiry, imported: true });
        ids.add(gid);
    }
    const evidence = await engine.grants(uid);
    if (!(0, access_control_1.isVip)(u, evidence))
        for (const [scope, entitlement] of Object.entries(u.entitlements || {})) {
            const e = entitlement;
            if (e.status === "active" && (0, access_control_1.millis)(e.expiry) > Date.now() && !(0, access_control_1.rights)(u, evidence, scope))
                unresolved.push(`profile_scope:${scope}`);
        }
    if (unresolved.length) {
        await doc.ref.update({ access_revocation_hold: true });
        await db.collection("access_reviews").doc((0, access_control_1.keyOf)(uid, "legacy_evidence")).set({ uid,
            code: "legacy_payment_evidence_incomplete", transaction_documents: unresolved, updated_ms: Date.now() });
    }
    if (unresolved.length && fresh.access_version !== 2)
        return;
    // Do not invent a grant from profile expiry. Unproved legacy voucher/manual
    // access remains reviewable and outside automated revocation until imported.
    if (ids.size)
        await db.runTransaction(async (t) => {
            const current = (await t.get(doc.ref)).data();
            if (!current || current.adopted_by)
                return;
            t.update(doc.ref, { access_grant_ids: [...new Set([...(current.access_grant_ids || []), ...ids])],
                access_version: 2, access_due_ms: Date.now() });
        });
}
async function importVerifiedAkalEvidence(path) {
    var _a, _b;
    // Operator-only input: the deployment audit fetched all service pages from
    // GoAkal over authenticated HTTPS. Invoice expiry is never subscription expiry.
    const rows = JSON.parse(await (0, promises_1.readFile)(path, "utf8"));
    if (!Array.isArray(rows))
        throw new Error("Invalid provider evidence");
    const scopes = { "AI Fikih Tahawwulat": "fiqh_tahawwulat",
        "SUPER AI FIKIH SYAFI'I": "fiqh_syafii", "SUPER AI BAHASA ARAB": "nahwu" };
    const durations = { "1 Bulan": 1, "6 Bulan": 6, "12 Bulan": 12 };
    const users = await db.collection("users").get(), seen = new Set(), ends = new Map();
    rows.sort((a, b) => (Number.isFinite((0, access_control_1.millis)(a.paidAt)) ? (0, access_control_1.millis)(a.paidAt) : Infinity) - (Number.isFinite((0, access_control_1.millis)(b.paidAt)) ? (0, access_control_1.millis)(b.paidAt) : Infinity));
    let imported = 0, excluded = 0;
    for (const row of rows) {
        const scope = scopes[row.serviceTitle], months = durations[row.priceSchemeTitle], paid = (0, access_control_1.millis)(row.paidAt);
        const email = (0, access_control_1.normalEmail)(row.payerEmail), payment = String(row.paymentId || ""), amount = Number(row.incomingAmount);
        if (row.status !== "PAID" || !(amount > 0) || !scope || !months || !email || !payment || !Number.isFinite(paid)) {
            excluded++;
            continue;
        }
        const gid = (0, access_control_1.keyOf)("goakal_verified", payment, scope);
        if (seen.has(gid))
            continue;
        seen.add(gid);
        const chain = (0, access_control_1.keyOf)(email, scope), starts = Math.max(paid, ends.get(chain) || 0), expires = (0, access_control_1.billingExpiry)(starts, months);
        ends.set(chain, expires);
        const matches = users.docs.filter(d => (0, access_control_1.normalEmail)(d.data().email) === email);
        if (matches.length > 1) {
            excluded++;
            continue;
        }
        const uid = ((_a = matches[0]) === null || _a === void 0 ? void 0 : _a.id) || `legacy_${(0, access_control_1.keyOf)(email)}`;
        if (!matches.length)
            await db.collection("access_legacy_owners").doc(uid).set({ email, legacy_revoke_only: true, access_due_ms: Date.now() }, { merge: true });
        const ref = db.collection("access_grants").doc(gid);
        await db.runTransaction(async (t) => {
            const previous = await t.get(ref);
            if (previous.exists)
                return;
            t.create(ref, { uid, email, scope, kind: "payment", status: "active", amount, provider: "goakal",
                transaction_id: payment, starts_ms: starts, expires_ms: expires, paid_ms: paid,
                duration_months: months, provider_verified: true, verified_ms: Date.now() });
        });
        const ownerRef = ((_b = matches[0]) === null || _b === void 0 ? void 0 : _b.ref) || db.collection("access_legacy_owners").doc(uid);
        await db.runTransaction(async (t) => {
            const owner = (await t.get(ownerRef)).data();
            if (!owner || owner.adopted_by)
                return;
            t.update(ownerRef, { access_grant_ids: [...new Set([...(owner.access_grant_ids || []), gid])], access_due_ms: Date.now() });
        });
        imported++;
    }
    await db.collection("access_control").doc("legacy_provider_audit").set({ provider: "goakal", fetched_rows: rows.length,
        imported, excluded, completed_ms: Date.now(), invoice_expiry_ignored: true });
    console.log(JSON.stringify({ provider: "goakal", imported, excluded }));
}
async function prepareLegacy() {
    const transactions = await db.collection("transactions").get();
    const users = await db.collection("users").get();
    const known = new Set(users.docs.map(d => (0, access_control_1.normalEmail)(d.data().email)));
    for (const doc of transactions.docs) {
        const tx = doc.data(), email = (0, access_control_1.normalEmail)(tx.customer_email || tx.payer_email || tx.email);
        if (!email)
            continue;
        if (tx.is_vip === true || String(tx.plan).toUpperCase() === "VIP_PERMANENT" || String(tx.status).toUpperCase() === "VIP_PERMANENT") {
            await db.collection("access_vip_registry").doc((0, access_control_1.keyOf)(email)).set({ email, permanent: true, source_transaction: doc.id }, { merge: true });
        }
        if (known.has(email) || tx.uid || !(Number(tx.amount) > 0))
            continue;
        const id = `legacy_${(0, access_control_1.keyOf)(email)}`, ref = db.collection("access_legacy_owners").doc(id);
        if (!(await ref.get()).exists)
            await ref.set({ email, legacy_revoke_only: true, access_due_ms: Date.now() });
    }
    await pages("access_legacy_owners", async (doc) => { if (!doc.data().adopted_by)
        await importOwner(doc); });
    await pages("users", async (doc) => {
        try {
            await importOwner(doc);
        }
        catch (_) {
            await db.collection("access_reviews").doc((0, access_control_1.keyOf)(doc.id, "owner")).set({ uid: doc.id, code: "identity_review", updated_ms: Date.now() });
        }
    });
}
async function assignments() {
    const dueUsers = await db.collection("users").where("access_due_ms", "<=", Date.now()).orderBy("access_due_ms").limit(100).get();
    const dueLegacy = await db.collection("access_legacy_owners").where("access_due_ms", "<=", Date.now()).orderBy("access_due_ms").limit(100).get();
    const due = { docs: [...dueUsers.docs, ...dueLegacy.docs] };
    for (const doc of due.docs) {
        const u = doc.data();
        if (u.access_version !== 2 || u.adopted_by)
            continue;
        if (!u.legacy_revoke_only && !u.account_deleted && !u.pending_deletion) {
            try {
                const authOwner = await admin.auth().getUser(doc.id);
                if (!authOwner.emailVerified || (0, access_control_1.normalEmail)(authOwner.email) !== (0, access_control_1.normalEmail)(u.email))
                    throw new Error("Owner identity not verified");
            }
            catch (_) {
                await db.collection("access_reviews").doc((0, access_control_1.keyOf)(doc.id, "identity")).set({ uid: doc.id, code: "identity_review", updated_ms: Date.now() });
                await doc.ref.update({ access_due_ms: Date.now() + 3600000 });
                continue;
            }
        }
        const grants = await engine.grants(doc.id);
        let needsRetry = false;
        for (const [entity, scope] of Object.entries(access_catalog_1.ENTITY_SCOPES)) {
            try {
                await engine.importObserved(doc.id, entity);
            }
            catch (_) {
                needsRetry = true;
                continue;
            }
            if ((0, access_control_1.rights)(u, grants, scope)) {
                try {
                    await engine.reserve(doc.id, entity);
                }
                catch (e) {
                    needsRetry = true;
                    await db.collection("access_reviews").doc((0, access_control_1.keyOf)(doc.id, entity)).set({ uid: doc.id, entity,
                        code: e.code || "unavailable", updated_ms: Date.now() }, { merge: true });
                }
            }
            else
                await engine.revoke(doc.id, entity);
        }
        const expiry = grants.filter(g => g.status === "active" && g.expires_ms > Date.now()).map(g => g.expires_ms);
        const next = Math.min(Date.now() + (needsRetry ? 60000 : 3600000), ...expiry);
        await db.runTransaction(async (t) => {
            const current = (await t.get(doc.ref)).data();
            if ((current === null || current === void 0 ? void 0 : current.access_due_ms) === u.access_due_ms)
                t.update(doc.ref, { access_due_ms: next });
        });
    }
}
async function settleRevokes() {
    const snap = await db.collection("access_assignments").where("status", "==", "revoking").get();
    for (const doc of snap.docs) {
        const a = doc.data();
        let absent = true;
        for (const id of a.history || [a.notebook_id]) {
            const m = (await db.collection("access_memberships").doc((0, access_control_1.keyOf)(id, a.email)).get()).data();
            if (!m || m.present || !m.verified_ms)
                absent = false;
        }
        if (absent)
            await doc.ref.update({ status: "revoked", verified_ms: Date.now() });
    }
}
async function cycle() {
    stats.last_cycle_ms = Date.now();
    const cfg = (await runtime.get()).data();
    stats.mode = (cfg === null || cfg === void 0 ? void 0 : cfg.writer) === "vps-v2" ? "active" : "shadow";
    if ((cfg === null || cfg === void 0 ? void 0 : cfg.writer) !== "vps-v2")
        return; // Installed shadow mode until explicit cutover.
    // Consume source jobs incrementally rather than scanning every account/tx.
    const source = await db.collection("provisioning_outbox").where("status", "in", ["pending", "retry", "processing"]).limit(100).get();
    for (const job of source.docs) {
        const uid = job.data().uid;
        if (typeof uid !== "string" || uid.includes("@")) {
            await job.ref.update({ status: "v2_review" });
            continue;
        }
        const doc = await db.collection("users").doc(uid).get();
        if (doc.exists)
            await importOwner(doc);
        else {
            const a = await db.collection("access_assignments").where("uid", "==", uid).get();
            for (const assignment of a.docs)
                await engine.revoke(uid, assignment.data().entity);
        }
        await job.ref.update({ status: "v2_handed_off", updated_ms: Date.now() });
    }
    await assignments();
    await settleRevokes();
    const jobs = await db.collection("access_jobs").where("due_ms", "<=", Date.now()).count().get();
    stats.last_success_ms = Date.now();
    stats.error = "";
    stats.cycles++;
    await db.collection("access_control").doc("heartbeat").set(Object.assign(Object.assign(Object.assign(Object.assign({}, stats), { pending_jobs: jobs.data().count }), telemetry), { writer: "vps-v2" }));
}
async function runJobs() {
    var _a;
    while (true) {
        try {
            if (((_a = (await runtime.get()).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2") {
                const jobs = await db.collection("access_jobs").where("due_ms", "<=", Date.now()).orderBy("due_ms").limit(20).get();
                for (const job of jobs.docs)
                    await engine.runJob(job.ref);
            }
        }
        catch (_) {
            console.error("Job loop failed; retrying");
        }
        await new Promise(resolve => setTimeout(resolve, 1000));
    }
}
async function reconcile() {
    var _a;
    const all = Object.values(notebook_catalog_1.NOTEBOOK_ENTITIES).flatMap(e => notebooks(e));
    let cursor = 0;
    while (true) {
        try {
            if (((_a = (await runtime.get()).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2") {
                const target = all[cursor++ % all.length];
                const ref = db.collection("access_notebooks").doc(target.id);
                const snapshot = await ref.get();
                if (snapshot.exists) {
                    const observation = await provider.observe(target.id);
                    if (!observation.complete)
                        throw new Error("Incomplete health observation");
                    const emails = new Set(observation.emails.map(access_control_1.normalEmail));
                    const memberships = await db.collection("access_memberships").where("notebook_id", "==", target.id).get();
                    const reserved = memberships.docs.filter(d => d.data().counted && !emails.has(d.data().email)).length;
                    await db.runTransaction(async (t) => {
                        const current = (await t.get(ref)).data();
                        if (!current)
                            return;
                        // Account for reservations not yet observed by Google; an external
                        // manual invite must not allow the allocator to overbook.
                        t.update(ref, { occupied: Math.max(current.occupied, emails.size + reserved),
                            observed_count: emails.size, observed_ms: Date.now(), healthy_until_ms: Date.now() + 86400000,
                            is_public: observation.isPublic, status: observation.isPublic ? "quarantined" : current.status });
                    });
                    if (!observation.isPublic)
                        for (const member of memberships.docs) {
                            const m = member.data();
                            if (m.uid && m.present && !emails.has(m.email))
                                await engine.repair(m.uid, m.entity);
                        }
                }
            }
        }
        catch (_) {
            console.error("Notebook reconciliation unavailable; retrying next target");
        }
        await new Promise(resolve => setTimeout(resolve, 15000));
    }
}
async function main() {
    const mode = process.argv[2];
    if (mode === "--seed" || mode === "--restrict")
        return seed(mode === "--restrict");
    if (mode === "--import")
        return pages("users", importOwner);
    if (mode === "--import-akal-evidence")
        return importVerifiedAkalEvidence(process.argv[3]);
    if (mode === "--prepare")
        return prepareLegacy();
    if (mode === "--prepare-assignments")
        return assignments();
    if (mode === "--once")
        return cycle();
    (0, http_1.createServer)((_, res) => {
        res.setHeader("Content-Type", "application/json");
        const providerStale = stats.mode === "active" && Date.now() - telemetry.last_provider_success_ms > 300000;
        res.statusCode = stats.error || telemetry.authentication_error || providerStale ? 503 : 200;
        res.end(JSON.stringify(Object.assign(Object.assign({}, stats), telemetry)));
    }).listen(8091, "127.0.0.1");
    void runJobs(); // Separate from scheduler: a slow provider cannot postpone expiry discovery.
    void reconcile();
    while (true) {
        try {
            await cycle();
        }
        catch (_) {
            stats.error = "Access cycle failed; inspect authenticated diagnostics";
            console.error(stats.error);
        }
        await new Promise(resolve => setTimeout(resolve, 15000));
    }
}
main().catch(() => { console.error("Access worker startup failed"); process.exitCode = 1; });
//# sourceMappingURL=access_worker.js.map