import * as admin from "firebase-admin";
import {execFile} from "child_process";
import {createServer} from "http";
import {rename, chmod, readFile} from "fs/promises";
import {promisify} from "util";
import {AccessControl, Entity, Provider, ShareObservation, isVip, keyOf, millis, normalEmail, rights, billingExpiry, verifiedAkalPeriods, hasLegacyAccessAdjustment, classifyLegacyEvent, REVOCATION_POLICY} from "./access_control";
import {NOTEBOOK_ENTITIES} from "./notebook_catalog";
import {ENTITY_SCOPES, AGENT_ENTITLEMENTS, resolveAkalScopes} from "./access_catalog";

admin.initializeApp({projectId: process.env.GOOGLE_CLOUD_PROJECT || "open-turath"});
const db = admin.firestore();
const telemetry = {last_provider_success_ms:0, authentication_error:false, session_refreshes:0};
const execute = promisify(execFile);
let refreshing: Promise<void> | undefined, lastRefreshAttempt = 0;
async function refreshConsentedSession(): Promise<void> {
  if (refreshing) return refreshing;
  const cli = process.env.ACCESS_NOTEBOOKLM_CLI, owner = process.env.ACCESS_OWNER_EMAIL;
  const storage = process.env.NOTEBOOKLM_STORAGE_PATH;
  if (!cli || !owner || !storage || Date.now()-lastRefreshAttempt < 60000) throw new Error("Owner session unavailable");
  lastRefreshAttempt = Date.now();
  refreshing = (async () => {
    const temporary = `${storage}.refresh`;
    // Reuse only the explicitly consented owner's existing browser login.
    // The CLI does not automate login or mint credentials for another account.
    await execute(cli, ["login", "--browser-cookies", "chrome", "--account", owner, "--storage", temporary],
      {timeout:60000, maxBuffer:1048576});
    await chmod(temporary, 0o600); await rename(temporary, storage);
    telemetry.session_refreshes++;
  })();
  try {await refreshing;} finally {refreshing = undefined;}
}
const requestProvider = (request: any): Promise<ShareObservation> => new Promise((resolve, reject) => {
  const python = process.env.ACCESS_PYTHON;
  const adapter = process.env.ACCESS_SHARING_ADAPTER;
  if (!python || !adapter) return reject(new Error("Sharing adapter not configured"));
  const child = execFile(python, [adapter], {timeout: 100000, maxBuffer: 8 * 1024 * 1024}, (error, out) => {
    try {
      const data = JSON.parse(out);
      if (data.code === "authentication_unavailable") return reject(Object.assign(new Error("Owner session unavailable"), {authentication:true}));
      if (error || data.error) return reject(new Error("Sharing provider unavailable"));
      telemetry.last_provider_success_ms = Date.now(); telemetry.authentication_error = false; resolve(data);
    } catch (_) { reject(new Error("Invalid sharing evidence")); }
  });
  child.stdin?.end(JSON.stringify(request));
});
async function callProvider(request: any): Promise<ShareObservation> {
  try {return await requestProvider(request);} catch (error: any) {
    if (!error.authentication) throw error;
    telemetry.authentication_error = true;
    await refreshConsentedSession();
    return requestProvider(request);
  }
}
const provider: Provider = {
  observe: notebookId => callProvider({notebookId, operation: "observe"}),
  apply: (notebookId, email, desired) => callProvider({notebookId, email, desired, operation: "apply"}),
};
const engine = new AccessControl(db, NOTEBOOK_ENTITIES, ENTITY_SCOPES, provider);
const runtime = db.collection("access_control").doc("runtime");
const stats = {started_ms: Date.now(), last_cycle_ms: 0, last_success_ms: 0, mode: "starting", error: "", cycles: 0,
  revocations_paused:true,revocation_policy:REVOCATION_POLICY};
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
  const targets = Object.values(NOTEBOOK_ENTITIES).flatMap(entity => notebooks(entity).map(n => ({entity, n})));
  let cursor = 0;
  const inspect = async () => {
    while (cursor < targets.length) {
      const {entity, n} = targets[cursor++];
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
  };
  await Promise.all([inspect(), inspect(), inspect()]);
}
async function importOwner(doc: any): Promise<void> {
  const uid = doc.id, u = doc.data(), email = normalEmail(u.email);
  if (!email) return;
  if (!u.legacy_revoke_only) {
    const authOwner = await admin.auth().getUser(uid);
    if (!authOwner.emailVerified || normalEmail(authOwner.email) !== email) return;
    await engine.adoptLegacy(uid, `legacy_${keyOf(email)}`);
  }
  const txs = new Map<string, any>();
  for (const [field, value] of [["uid", uid], ["customer_email", email], ["payer_email", email], ["email", email]]) {
    const snap = await db.collection("transactions").where(field, "==", value).get();
    for (const tx of snap.docs) txs.set(tx.id, tx.data());
  }
  const fresh = (await doc.ref.get()).data();
  const ids = new Set<string>(fresh.access_grant_ids || []);
  if (isVip(u) || [...txs.values()].some(t => String(t.status).toUpperCase() === "VIP_PERMANENT" || String(t.plan).toUpperCase() === "VIP_PERMANENT" || t.is_vip === true)) {
    const id = keyOf("vip", uid);
    await db.collection("access_grants").doc(id).set({uid, kind: "VIP_PERMANENT", scope: "all_access", status: "active"}, {merge: true});
    ids.add(id);
  }
  const verifiedProvider = (await engine.grants(uid)).some(g=>g.provider === "goakal" && g.provider_verified === true);
  const unresolved: string[] = [];
  for (const [id, tx] of txs) {
    // Check before gateway/amount/UID filters: transfers can be free, retain
    // an old UID, and owner bonuses are not visible in the provider API.
    if (hasLegacyAccessAdjustment(tx)) {
      unresolved.push(`owner_adjustment:${id}`);
      continue;
    }
    if (tx.uid && tx.uid !== uid) continue;
    if (verifiedProvider && !["midtrans", "doku"].includes(String(tx.gateway || "").toLowerCase())) continue;
    const paidStatus = ["paid", "success", "settled", "settlement"].includes(String(tx.status).toLowerCase());
    const settledBeforeExpiry = String(tx.status).toLowerCase() === "expired" && tx.activation_applied === true && tx.paid_at;
    if ((!paidStatus && !settledBeforeExpiry) || !(Number(tx.amount) > 0)) continue;
    const labels: Record<string, string> = {
      "AI Fikih Tahawwulat": "fiqh_tahawwulat", "Fikih Tahawwulat": "fiqh_tahawwulat",
      "AI Fikih Syafi'i": "fiqh_syafii", "AI Fikih Syafii": "fiqh_syafii", "Fikih Syafi'i": "fiqh_syafii",
      "AI Ushul Fiqih": "ushul_fiqh", "AI Hadits": "hadits", "AI Tafsir": "tafsir", "AI Bahasa Arab": "nahwu",
    };
    const scope = tx.entitlement_key || AGENT_ENTITLEMENTS[tx.agent_id] || labels[tx.service_name] ||
      (/^all_ai(?:_1m|_6m|_1y)?$/.test(tx.plan || "") ? "all_access" : "");
    if (!Object.values(ENTITY_SCOPES).includes(scope) && !["all_access", "all_ai"].includes(scope)) {unresolved.push(id); continue;}
    if (tx.activation_applied !== true || !["midtrans", "doku"].includes(String(tx.gateway || "").toLowerCase())) {
      unresolved.push(id); continue;
    }
    const gid = tx.invoice_number ? keyOf("invoice", tx.invoice_number) : keyOf("legacy_tx", id);
    const gr = db.collection("access_grants").doc(gid);
    const prior = (await gr.get()).data();
    if (prior) { if (prior.uid === uid) ids.add(gid); continue; }
    const paid = millis(tx.paid_at || tx.completed_at || tx.payment_time);
    const explicit = millis(tx.subscription_expires_at || tx.access_expires_at || tx.expires_at);
    // Legacy one-month records are capped by real payment time + 30 days.
    // Unknown timestamps/plan durations are review cases, never auto-removals.
    const plan = String(tx.plan || "").toLowerCase();
    const months = Number(tx.duration_months) || (/(1y|tahun|annual)/.test(plan) ? 12 : /6m/.test(plan) ? 6 : /1m|tholib/.test(plan) ? 1 : 0);
    if (!Number.isFinite(paid) || !months) {unresolved.push(id); continue;}
    const calculated = billingExpiry(paid, months);
    const expiry = Number.isFinite(explicit) ? Math.min(explicit, calculated) : calculated;
    await gr.set({uid, scope, kind: "payment", status: "active", amount: Number(tx.amount), transaction_document: id,
      invoice_number: tx.invoice_number || null, starts_ms: paid, expires_ms: expiry, imported: true});
    ids.add(gid);
  }
  const evidence = await engine.grants(uid);
  if (!isVip(u, evidence)) for (const [scope, entitlement] of Object.entries(u.entitlements || {})) {
    const e = entitlement as any;
    const automatedProjection = verifiedProvider && /goakal|akal/.test(String(e.source || "").toLowerCase());
    if (!automatedProjection && e.status === "active" && millis(e.expiry) > Date.now() && !rights(u, evidence, scope)) unresolved.push(`profile_scope:${scope}`);
  }
  if (unresolved.length) {
    await doc.ref.update({access_revocation_hold:true});
    await db.collection("access_reviews").doc(keyOf(uid,"legacy_evidence")).set({uid,
      code:"legacy_payment_evidence_incomplete", transaction_documents:unresolved, updated_ms:Date.now()});
  }
  if (!unresolved.length) {
    const review = db.collection("access_reviews").doc(keyOf(uid,"legacy_evidence"));
    const free = await db.collection("access_reviews").doc(keyOf(email,"free_access")).get();
    if ((await review.get()).exists && !free.exists) {
      await doc.ref.update({access_revocation_hold:false});
      await review.update({status:"resolved_by_verified_billing",updated_ms:Date.now()});
    }
  }
  if (unresolved.length && fresh.access_version !== 2) return;
  // Do not invent a grant from profile expiry. Unproved legacy voucher/manual
  // access remains reviewable and outside automated revocation until imported.
  if (ids.size) await db.runTransaction(async (t: any) => {
    const current = (await t.get(doc.ref)).data();
    if (!current || current.adopted_by) return;
    t.update(doc.ref, {access_grant_ids: [...new Set([...(current.access_grant_ids || []), ...ids])],
      access_version: 2, access_due_ms: Date.now()});
  });
}
async function importVerifiedAkalEvidence(path: string): Promise<void> {
  // Operator-only input: the deployment audit fetched all service pages from
  // GoAkal over authenticated HTTPS. Invoice expiry is never subscription expiry.
  const rows = JSON.parse(await readFile(path,"utf8"));
  if (!Array.isArray(rows)) throw new Error("Invalid provider evidence");
  const users = await db.collection("users").get();
  const periods = verifiedAkalPeriods(rows);
  let imported=0, excluded=rows.length-periods.length;
  for (const period of periods) {
    const {id:gid, email, scope, payment, amount, starts, expires, paid, months}=period;
    const matches=users.docs.filter(d=>normalEmail(d.data().email)===email);
    if (matches.length>1) {excluded++;continue;}
    const uid=matches[0]?.id || `legacy_${keyOf(email)}`;
    if (!matches.length) await db.collection("access_legacy_owners").doc(uid).set({email,legacy_revoke_only:true,access_due_ms:Date.now()}, {merge:true});
    const ref=db.collection("access_grants").doc(gid);
    await db.runTransaction(async t=>{
      const previous=await t.get(ref);
      if (previous.exists) return;
      t.create(ref,{uid,email,scope,kind:"payment",status:"active",amount,provider:"goakal",
        transaction_id:payment,starts_ms:starts,expires_ms:expires,paid_ms:paid,
        duration_months:months,provider_verified:true,verified_ms:Date.now()});
    });
    const ownerRef=matches[0]?.ref || db.collection("access_legacy_owners").doc(uid);
    await db.runTransaction(async (t:any)=>{
      const owner=(await t.get(ownerRef)).data();
      if (!owner || owner.adopted_by) return;
      t.update(ownerRef,{access_grant_ids:[...new Set([...(owner.access_grant_ids || []),gid])],access_due_ms:Date.now()});
    });
    imported++;
  }
  const freeEmails = new Set(rows.filter(r=>r.status === "PAID" && Number(r.incomingAmount) === 0).map(r=>normalEmail(r.payerEmail)));
  for (const email of freeEmails) {
    if (!email) continue;
    if ((await db.collection("access_vip_registry").doc(keyOf(email)).get()).exists) continue;
    const owner = users.docs.find(d=>normalEmail(d.data().email)===email);
    if (owner && isVip(owner.data())) continue;
    const ref = owner?.ref || db.collection("access_legacy_owners").doc(`legacy_${keyOf(email)}`);
    if ((await ref.get()).exists) await ref.update({access_revocation_hold:true});
    await db.collection("access_reviews").doc(keyOf(email,"free_access")).set({email,
      code:"zero_amount_requires_admin_evidence",updated_ms:Date.now()});
  }
  await db.collection("access_control").doc("legacy_provider_audit").set({provider:"goakal",fetched_rows:rows.length,
    imported,excluded,completed_ms:Date.now(),invoice_expiry_ignored:true});
  console.log(JSON.stringify({provider:"goakal",imported,excluded}));
}
async function prepareLegacy(): Promise<void> {
  const transactions = await db.collection("transactions").get();
  const users = await db.collection("users").get();
  const known = new Set(users.docs.map(d => normalEmail(d.data().email)));
  for (const doc of users.docs) if (isVip(doc.data())) {
    const email=normalEmail(doc.data().email);
    if (email) await db.collection("access_vip_registry").doc(keyOf(email)).set({email,permanent:true,source_profile:doc.id},{merge:true});
  }
  for (const doc of transactions.docs) {
    const tx = doc.data(), email = normalEmail(tx.customer_email || tx.payer_email || tx.email);
    if (!email) continue;
    if (tx.is_vip === true || String(tx.plan).toUpperCase() === "VIP_PERMANENT" || String(tx.status).toUpperCase() === "VIP_PERMANENT") {
      await db.collection("access_vip_registry").doc(keyOf(email)).set({email, permanent:true, source_transaction:doc.id}, {merge:true});
    }
    if (known.has(email) || tx.uid || !(Number(tx.amount) > 0)) continue;
    const id = `legacy_${keyOf(email)}`, ref = db.collection("access_legacy_owners").doc(id);
    if (!(await ref.get()).exists) await ref.set({email, legacy_revoke_only:true, access_due_ms:Date.now()});
  }
  await pages("access_legacy_owners", async doc => {if (!doc.data().adopted_by) await importOwner(doc);});
  await pages("users", async doc => {
    try {await importOwner(doc);} catch (_) {
      await db.collection("access_reviews").doc(keyOf(doc.id,"owner")).set({uid:doc.id,code:"identity_review",updated_ms:Date.now()});
    }
  });
}
async function projectRights(doc: any, user: any, grants: any[]): Promise<void> {
  if (user.legacy_revoke_only || user.account_deleted || user.pending_deletion) return;
  const protectedOwner = await engine.owner(doc.id);
  if (isVip(protectedOwner.user, grants)) {
    if (user.is_vip !== true) await doc.ref.update({is_vip:true});
    return;
  }
  const updates: Record<string,any> = {};
  for (const scope of new Set([...Object.values(ENTITY_SCOPES),"all_access","all_ai"])) {
    const active = rights(user,grants,scope);
    if (!active && user.access_revocation_hold) continue;
    const matching=grants.filter(g=>[scope,"all_access","all_ai"].includes(g.scope) && g.status === "active" &&
      (g.kind === "payment" && g.amount>0 || g.kind === "voucher" || g.kind === "admin" && g.admin_verified));
    const existing=user.entitlements?.[scope];
    if (!matching.length && !existing) continue;
    const expiry=Math.max(0,...matching.map(g=>g.expires_ms || 0));
    const status=active?"active":"expired";
    if (existing?.status === status && millis(existing.expiry) === expiry) continue;
    updates[`entitlements.${scope}`]={plan:active?"premium":"expired",status,
      expiry:admin.firestore.Timestamp.fromMillis(expiry),source:"access_ledger"};
  }
  if (Object.keys(updates).length) await db.runTransaction(async (t:any)=>{
    const current=(await t.get(doc.ref)).data();
    if (!current || current.access_due_ms !== user.access_due_ms ||
        current.access_revocation_hold !== user.access_revocation_hold ||
        JSON.stringify(current.access_grant_ids || []) !== JSON.stringify(user.access_grant_ids || [])) return;
    t.update(doc.ref,updates);
  });
}
async function assignments(): Promise<void> {
  const dueUsers = await db.collection("users").where("access_due_ms", "<=", Date.now()).orderBy("access_due_ms").limit(100).get();
  const dueLegacy = await db.collection("access_legacy_owners").where("access_due_ms", "<=", Date.now()).orderBy("access_due_ms").limit(100).get();
  const due = {docs:[...dueUsers.docs, ...dueLegacy.docs]};
  for (const doc of due.docs) {
    const u = doc.data();
    if (u.access_version !== 2 || u.adopted_by) continue;
    if (!u.legacy_revoke_only && !u.account_deleted && !u.pending_deletion) {
      try {
        const authOwner = await admin.auth().getUser(doc.id);
        if (!authOwner.emailVerified || normalEmail(authOwner.email) !== normalEmail(u.email)) throw new Error("Owner identity not verified");
      } catch (_) {
        await db.collection("access_reviews").doc(keyOf(doc.id,"identity")).set({uid:doc.id,code:"identity_review",updated_ms:Date.now()});
        await doc.ref.update({access_due_ms:Date.now()+3600000});
        continue;
      }
    }
    const effective = await engine.owner(doc.id), grants = effective.grants;
    await projectRights(doc,u,grants);
    const observed = await db.collection("access_memberships").where("email","==",normalEmail(u.email)).get();
    const existing = await db.collection("access_assignments").where("uid","==",doc.id).get();
    const relevant = new Set([...observed.docs.map(d=>d.data().entity),...existing.docs.map(d=>d.data().entity)]);
    let needsRetry = false;
    for (const [entity, scope] of Object.entries(ENTITY_SCOPES)) {
      if (!relevant.has(entity) && (u.legacy_revoke_only || !rights(effective.user,grants,scope))) continue;
      try { await engine.importObserved(doc.id, entity, observed.docs); }
      catch (_) {needsRetry = true; continue;}
      if (rights(effective.user, grants, scope)) {
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
// The sharing server hands authenticated GoAkal webhook events to this queue
// once the VPS writer is active. Without a consumer a real payment would wait
// forever, so each cycle settles a bounded batch.
async function consumeLegacyEvents(): Promise<void> {
  const events = await db.collection("access_legacy_events").where("status", "==", "verification_required").limit(50).get();
  for (const doc of events.docs) {
    const decision = classifyLegacyEvent(doc.data(), resolveAkalScopes);
    if (decision.action !== "grant") {
      await doc.ref.update({status: decision.action === "noted" ? "noted" : "operator_review",
        decision_reason: decision.reason, processed_ms: Date.now()});
      continue;
    }
    try {
      const matches = await db.collection("users").where("email", "==", decision.email).limit(2).get();
      if (matches.size > 1) {
        await doc.ref.update({status: "operator_review", decision_reason: "ambiguous_owner", processed_ms: Date.now()});
        continue;
      }
      const ownerRef = matches.docs[0]?.ref || db.collection("access_legacy_owners").doc(`legacy_${keyOf(decision.email)}`);
      if (!matches.size) await ownerRef.set({email: decision.email, legacy_revoke_only: true, access_due_ms: Date.now()}, {merge: true});
      const granted: string[] = [];
      for (const scope of decision.scopes) {
        const ref = db.collection("access_grants").doc(keyOf("goakal", decision.transactionId, scope));
        await db.runTransaction(async (t: any) => {
          if ((await t.get(ref)).exists) return;
          t.create(ref, {uid: ownerRef.id, email: decision.email, scope, kind: "payment", status: "active",
            amount: decision.amount, provider: "goakal", source: "akal_webhook", transaction_id: decision.transactionId,
            starts_ms: decision.paidMs, expires_ms: decision.expiresMs, created_ms: Date.now()});
        });
        granted.push(ref.id);
      }
      await db.runTransaction(async (t: any) => {
        const owner = (await t.get(ownerRef)).data();
        if (!owner || owner.adopted_by) return;
        t.update(ownerRef, {access_grant_ids: [...new Set([...(owner.access_grant_ids || []), ...granted])],
          access_version: 2, access_due_ms: Date.now()});
      });
      await doc.ref.update({status: "granted", grant_ids: granted, processed_ms: Date.now()});
    } catch (_) {
      // Leave the event queued; the next cycle retries it.
      console.error("Legacy event could not be settled; retrying next cycle");
    }
  }
}
async function cycle(): Promise<void> {
  stats.last_cycle_ms = Date.now();
  const cfg = (await runtime.get()).data();
  stats.mode = cfg?.writer === "vps-v2" ? "active" : "shadow";
  stats.revocations_paused = cfg?.revocations_paused === true;
  if (cfg?.writer !== "vps-v2") return; // Installed shadow mode until explicit cutover.
  // Consume source jobs incrementally rather than scanning every account/tx.
  const source = await db.collection("provisioning_outbox").where("status", "in", ["pending", "retry", "processing", "failed"]).limit(100).get();
  for (const job of source.docs) {
    if (job.data().next_attempt_ms>Date.now()) continue;
    const uid = job.data().uid;
    if (typeof uid !== "string" || uid.includes("@")) {await job.ref.update({status:"v2_review"}); continue;}
    try {
      const doc = await db.collection("users").doc(uid).get();
      if (doc.exists) {
        await importOwner(doc);
        if ((await doc.ref.get()).data()?.access_version !== 2) {
          await job.ref.update({status:"v2_review",reason:"legacy_evidence_required",updated_ms:Date.now()});
          continue;
        }
      } else {
        const a = await db.collection("access_assignments").where("uid", "==", uid).get();
        for (const assignment of a.docs) await engine.revoke(uid, assignment.data().entity);
      }
      await job.ref.update({status:"v2_handed_off", updated_ms:Date.now()});
    } catch (error:any) {
      const permanent=["auth/user-not-found","auth/invalid-uid","failed-precondition"].includes(error.code);
      await job.ref.update({status:permanent?"v2_review":"retry",reason:permanent?"identity_or_billing_review":"temporary_dependency_failure",
        next_attempt_ms:Date.now()+60000,updated_ms:Date.now()});
    }
  }
  await consumeLegacyEvents();
  await assignments();
  await settleRevokes();
  const jobs = await db.collection("access_jobs").where("due_ms", "<=", Date.now()).count().get();
  stats.last_success_ms = Date.now(); stats.error = ""; stats.cycles++;
  await db.collection("access_control").doc("heartbeat").set({...stats, pending_jobs: jobs.data().count, ...telemetry, writer: "vps-v2"});
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
async function reconcile(): Promise<void> {
  const all = Object.values(NOTEBOOK_ENTITIES).flatMap(e => notebooks(e));
  let cursor = 0;
  while (true) {
    try {
      if ((await runtime.get()).data()?.writer === "vps-v2") {
        const target = all[cursor++ % all.length];
        const ref = db.collection("access_notebooks").doc(target.id);
        const snapshot = await ref.get();
        if (snapshot.exists) {
          const observation = await provider.observe(target.id);
          if (!observation.complete) throw new Error("Incomplete health observation");
          const emails = new Set(observation.emails.map(normalEmail));
          const memberships = await db.collection("access_memberships").where("notebook_id", "==", target.id).get();
          const reserved = memberships.docs.filter(d => d.data().counted && !emails.has(d.data().email)).length;
          await db.runTransaction(async t => {
            const current = (await t.get(ref)).data();
            if (!current) return;
            // Account for reservations not yet observed by Google; an external
            // manual invite must not allow the allocator to overbook.
            t.update(ref, {occupied: Math.max(current.occupied, emails.size + reserved),
              observed_count: emails.size, observed_ms: Date.now(), healthy_until_ms: Date.now() + 86400000,
              is_public: observation.isPublic, status: observation.isPublic ? "quarantined" : current.status});
          });
          if (!observation.isPublic) for (const member of memberships.docs) {
            const m = member.data();
            if (m.uid && m.present && !emails.has(m.email)) await engine.repair(m.uid, m.entity);
          }
        }
      }
    } catch (_) {console.error("Notebook reconciliation unavailable; retrying next target");}
    await new Promise(resolve => setTimeout(resolve, 15000));
  }
}
async function main(): Promise<void> {
  const mode = process.argv[2];
  if (mode === "--seed" || mode === "--restrict") return seed(mode === "--restrict");
  if (mode === "--import") return pages("users", importOwner);
  if (mode === "--import-akal-evidence") return importVerifiedAkalEvidence(process.argv[3]);
  if (mode === "--prepare") return prepareLegacy();
  if (mode === "--prepare-assignments") return assignments();
  if (mode === "--run-one") {
    const id=process.argv[3];
    if (!/^[a-f0-9]{64}$/.test(id || "")) throw new Error("A verified job ID is required");
    const ref=db.collection("access_jobs").doc(id);
    await engine.runJob(ref);
    console.log(JSON.stringify({job_status:(await ref.get()).data()?.status,...telemetry}));
    return;
  }
  if (mode === "--once") return cycle();
  createServer((_, res) => {res.setHeader("Content-Type", "application/json");
    const providerStale = stats.mode === "active" && Date.now()-telemetry.last_provider_success_ms > 300000;
    res.statusCode = stats.error || telemetry.authentication_error || providerStale ? 503 : 200;
    res.end(JSON.stringify({...stats,...telemetry}));
  }).listen(8091, "127.0.0.1");
  void runJobs(); // Separate from scheduler: a slow provider cannot postpone expiry discovery.
  void reconcile();
  while (true) {
    try { await cycle(); }
    catch (_) {stats.error = "Access cycle failed; inspect authenticated diagnostics"; console.error(stats.error);}
    await new Promise(resolve => setTimeout(resolve, 15000));
  }
}
main().catch(() => {console.error("Access worker startup failed"); process.exitCode = 1;});
