import * as admin from "firebase-admin";
import {execFile} from "child_process";
import {createServer} from "http";
import {AccessControl, Entity, Provider, ShareObservation, isVip, keyOf, millis, normalEmail, rights} from "./access_control";
import {NOTEBOOK_ENTITIES} from "./notebook_catalog";
import {ENTITY_SCOPES} from "./access_catalog";

admin.initializeApp({projectId: process.env.GOOGLE_CLOUD_PROJECT || "open-turath"});
const db = admin.firestore();
const callProvider = (request: any): Promise<ShareObservation> => new Promise((resolve, reject) => {
  const python = process.env.ACCESS_PYTHON;
  const adapter = process.env.ACCESS_SHARING_ADAPTER;
  if (!python || !adapter) return reject(new Error("Sharing adapter not configured"));
  const child = execFile(python, [adapter], {timeout: 100000, maxBuffer: 8 * 1024 * 1024}, (error, out) => {
    if (error) return reject(new Error("Sharing provider unavailable"));
    try { const data = JSON.parse(out); if (data.error) throw new Error(); resolve(data); }
    catch (_) { reject(new Error("Invalid sharing evidence")); }
  });
  child.stdin?.end(JSON.stringify(request));
});
const provider: Provider = {
  observe: notebookId => callProvider({notebookId, operation: "observe"}),
  apply: (notebookId, email, desired) => callProvider({notebookId, email, desired, operation: "apply"}),
};
const engine = new AccessControl(db, NOTEBOOK_ENTITIES, ENTITY_SCOPES, provider);
const runtime = db.collection("access_control").doc("runtime");
const stats = {started_ms: Date.now(), last_cycle_ms: 0, last_success_ms: 0, mode: "starting", error: "", cycles: 0};
async function pages(collection: string, visit: (doc: any) => Promise<void>): Promise<void> {
  let cursor: any;
  while (true) {
    let q = db.collection(collection).orderBy(admin.firestore.FieldPath.documentId()).limit(100);
    if (cursor) q = q.startAfter(cursor);
    const page = await q.get();
    if (page.empty) return;
    for (const doc of page.docs) await visit(doc);
    cursor = page.docs[page.docs.length - 1];
  }
}
function notebooks(e: Entity): Array<{id: string; name: string; legacy?: boolean}> {
  return [{id: e.masterId, name: e.name}, ...e.clones, ...(e.legacyIds || []).map(id => ({id, name: "Legacy", legacy: true}))];
}
async function seed(restrict = false): Promise<void> {
  for (const entity of Object.values(NOTEBOOK_ENTITIES)) {
    for (const n of notebooks(entity)) {
      const nr = db.collection("access_notebooks").doc(n.id);
      const existing = (await nr.get()).data();
      // Never reset a live counter from a snapshot while reservations can run.
      if (existing && !restrict) continue;
      try {
        const observed = restrict
          ? await callProvider({notebookId: n.id, operation: "restrict"}) : await provider.observe(n.id);
        if (!observed.complete || observed.emails.some(e => !normalEmail(e).includes("@"))) throw new Error("Incomplete identity list");
        if (!existing) {
          await nr.set({entity: entity.code, name: n.name, occupied: observed.emails.length,
            admission_limit: 1995, hard_limit: 2000, status: observed.isPublic ? "quarantined" : n.legacy ? "draining" : "active",
            is_public: observed.isPublic, healthy_until_ms: Date.now() + 86400000, observed_ms: Date.now()});
        } else if (restrict) {
          await nr.update({is_public: observed.isPublic, status: observed.isPublic ? "quarantined" : n.legacy ? "draining" : "active",
            healthy_until_ms: Date.now() + 86400000, observed_ms: Date.now()});
        }
        for (const email of observed.emails) {
          const mr = db.collection("access_memberships").doc(keyOf(n.id, normalEmail(email)));
          if (!(await mr.get()).exists) await mr.set({notebook_id: n.id, entity: entity.code, email: normalEmail(email),
            present: true, counted: true, verified_ms: Date.now(), imported: true});
        }
        console.log(JSON.stringify({event: "notebook_observed", notebook: n.id, viewers: observed.emails.length, public: observed.isPublic}));
      } catch (_) {
        console.log(JSON.stringify({event: "notebook_unavailable", notebook: n.id}));
      }
    }
  }
}
async function importOwner(doc: any): Promise<void> {
  const uid = doc.id, u = doc.data(), email = normalEmail(u.email);
  if (!email) return;
  const txs = new Map<string, any>();
  for (const [field, value] of [["uid", uid], ["customer_email", email], ["payer_email", email], ["email", email]]) {
    const snap = await db.collection("transactions").where(field, "==", value).get();
    for (const tx of snap.docs) txs.set(tx.id, tx.data());
  }
  const ids = new Set<string>(u.access_grant_ids || []);
  if (isVip(u) || [...txs.values()].some(t => String(t.status).toUpperCase() === "VIP_PERMANENT" || t.is_vip === true)) {
    const id = keyOf("vip", uid);
    await db.collection("access_grants").doc(id).set({uid, kind: "VIP_PERMANENT", scope: "all_access", status: "active"}, {merge: true});
    ids.add(id);
  }
  for (const [id, tx] of txs) {
    if (tx.uid && tx.uid !== uid) continue;
    if (!["paid", "success", "settled", "settlement", "expired"].includes(String(tx.status).toLowerCase()) || !(Number(tx.amount) > 0)) continue;
    const scope = tx.entitlement_key;
    if (!Object.values(ENTITY_SCOPES).includes(scope) && !["all_access", "all_ai"].includes(scope)) continue;
    const gid = tx.invoice_number ? keyOf("invoice", tx.invoice_number) : keyOf("legacy_tx", id);
    const gr = db.collection("access_grants").doc(gid);
    if ((await gr.get()).exists) { ids.add(gid); continue; }
    const paid = millis(tx.paid_at || tx.payment_time || tx.created_at);
    const explicit = millis(tx.subscription_expires_at || tx.access_expires_at || tx.expires_at);
    // Legacy one-month records are capped by real payment time + 30 days.
    // Unknown timestamps/plan durations are review cases, never auto-removals.
    const plan = String(tx.plan || "").toLowerCase();
    const months = Number(tx.duration_months) || (/(1y|tahun|annual)/.test(plan) ? 12 : /6m/.test(plan) ? 6 : /1m|tholib/.test(plan) ? 1 : 0);
    if (!Number.isFinite(paid) || !months) continue;
    const calculated = paid + months * 30 * 86400000;
    const expiry = Number.isFinite(explicit) ? Math.min(explicit, calculated) : calculated;
    await gr.set({uid, scope, kind: "payment", status: "active", amount: Number(tx.amount), transaction_document: id,
      invoice_number: tx.invoice_number || null, starts_ms: paid, expires_ms: expiry, imported: true});
    ids.add(gid);
  }
  // Do not invent a grant from profile expiry. Unproved legacy voucher/manual
  // access remains reviewable and outside automated revocation until imported.
  if (ids.size) await doc.ref.update({access_grant_ids: [...ids], access_version: 2, access_due_ms: Date.now()});
}
async function assignments(): Promise<void> {
  const due = await db.collection("users").where("access_due_ms", "<=", Date.now()).orderBy("access_due_ms").limit(100).get();
  for (const doc of due.docs) {
    const u = doc.data();
    if (u.access_version !== 2) continue;
    const grants = await engine.grants(doc.id);
    let needsRetry = false;
    for (const [entity, scope] of Object.entries(ENTITY_SCOPES)) {
      if (rights(u, grants, scope)) {
        try { await engine.reserve(doc.id, entity); }
        catch (e: any) { needsRetry = true; await db.collection("access_reviews").doc(keyOf(doc.id, entity)).set({uid: doc.id, entity,
          code: e.code || "unavailable", updated_ms: Date.now()}, {merge: true}); }
      } else await engine.revoke(doc.id, entity);
    }
    const expiry = grants.filter(g => g.status === "active" && g.expires_ms > Date.now()).map(g => g.expires_ms);
    const next = Math.min(Date.now() + (needsRetry ? 60000 : 3600000), ...expiry);
    await db.runTransaction(async t => {
      const current = (await t.get(doc.ref)).data();
      if (current?.access_due_ms === u.access_due_ms) t.update(doc.ref, {access_due_ms: next});
    });
  }
}
async function settleRevokes(): Promise<void> {
  const snap = await db.collection("access_assignments").where("status", "==", "revoking").get();
  for (const doc of snap.docs) {
    const a = doc.data();
    let absent = true;
    for (const id of a.history || [a.notebook_id]) {
      const m = (await db.collection("access_memberships").doc(keyOf(id, a.email)).get()).data();
      if (!m || m.present || !m.verified_ms) absent = false;
    }
    if (absent) await doc.ref.update({status: "revoked", verified_ms: Date.now()});
  }
}
async function cycle(): Promise<void> {
  stats.last_cycle_ms = Date.now();
  const cfg = (await runtime.get()).data();
  stats.mode = cfg?.writer === "vps-v2" ? "active" : "shadow";
  if (cfg?.writer !== "vps-v2") return; // Installed shadow mode until explicit cutover.
  // Consume source jobs incrementally rather than scanning every account/tx.
  const source = await db.collection("provisioning_outbox").where("status", "in", ["pending", "retry", "processing"]).limit(100).get();
  for (const job of source.docs) {
    const uid = job.data().uid;
    if (typeof uid !== "string" || uid.includes("@")) {await job.ref.update({status:"v2_review"}); continue;}
    const doc = await db.collection("users").doc(uid).get();
    if (doc.exists) await importOwner(doc);
    else {
      const a = await db.collection("access_assignments").where("uid", "==", uid).get();
      for (const assignment of a.docs) await engine.revoke(uid, assignment.data().entity);
    }
    await job.ref.update({status:"v2_handed_off", updated_ms:Date.now()});
  }
  await assignments();
  await settleRevokes();
  const jobs = await db.collection("access_jobs").where("due_ms", "<=", Date.now()).count().get();
  stats.last_success_ms = Date.now(); stats.error = ""; stats.cycles++;
  await db.collection("access_control").doc("heartbeat").set({...stats, pending_jobs: jobs.data().count, writer: "vps-v2"});
}
async function runJobs(): Promise<void> {
  while (true) {
    try {
      if ((await runtime.get()).data()?.writer === "vps-v2") {
        const jobs = await db.collection("access_jobs").where("due_ms", "<=", Date.now()).orderBy("due_ms").limit(20).get();
        for (const job of jobs.docs) await engine.runJob(job.ref);
      }
    } catch (_) { console.error("Job loop failed; retrying"); }
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}
async function main(): Promise<void> {
  const mode = process.argv[2];
  if (mode === "--seed" || mode === "--restrict") return seed(mode === "--restrict");
  if (mode === "--import") return pages("users", importOwner);
  if (mode === "--once") return cycle();
  createServer((_, res) => {res.setHeader("Content-Type", "application/json");
    res.statusCode = stats.error ? 503 : 200; res.end(JSON.stringify(stats));
  }).listen(8091, "127.0.0.1");
  void runJobs(); // Separate from scheduler: a slow provider cannot postpone expiry discovery.
  while (true) {
    try { await cycle(); }
    catch (_) {stats.error = "Access cycle failed; inspect authenticated diagnostics"; console.error(stats.error);}
    await new Promise(resolve => setTimeout(resolve, 15000));
  }
}
main().catch(() => {console.error("Access worker startup failed"); process.exitCode = 1;});
