// Phase 2 of the access remediation: settle legacy (GoAkal and manual) evidence
// so expired access can be removed automatically.
//
//   node tool/legacy_access_migration.cjs report [out.json]
//       Read-only. Fetches every PAID/SETTLED GoAkal row over the API, matches it
//       to ledger grants, and lists everything that still needs a decision.
//   node tool/legacy_access_migration.cjs apply <report.json>
//       Writes only what the report proved, and only for entries the owner
//       marked "owner_approved": true. Re-checks each document before writing.
//
// Credentials: GOOGLE_APPLICATION_CREDENTIALS (or ../../service-account.json)
// and AKAL_API_KEY (environment or functions/.env). Never commits either.
const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");
const {VIP_EMAILS, normalEmail, keyOf, billingExpiry, hasLegacyAccessAdjustment, AccessControl, millis, REVOCATION_POLICY, rights} = require("../lib/access_control.js");
const {applyDecisions, certify} = require("./legacy_decisions.cjs");
const {AKAL_SERVICES, ENTITY_SCOPES} = require("../lib/access_catalog.js");
const {NOTEBOOK_ENTITIES} = require("../lib/notebook_catalog.js");

const DURATIONS = {"1 bulan": 1, "6 bulan": 6, "12 bulan": 12, "1 tahun": 12};
const DAY = 86400000;

function env(name) {
  if (process.env[name]) return process.env[name];
  const file = path.join(__dirname, "../.env");
  if (!fs.existsSync(file)) return "";
  const line = fs.readFileSync(file, "utf8").split("\n").find(l => l.startsWith(name + "="));
  return line ? line.slice(name.length + 1).trim().replace(/^["']|["']$/g, "") : "";
}
function init() {
  const key = process.env.GOOGLE_APPLICATION_CREDENTIALS || path.join(__dirname, "../../../service-account.json");
  admin.initializeApp({credential: admin.credential.cert(require(path.resolve(key)))});
  return admin.firestore();
}

async function providerRows() {
  const apiKey = env("AKAL_API_KEY");
  if (!apiKey) throw new Error("AKAL_API_KEY is required for the report");
  const rows = [];
  for (const service of AKAL_SERVICES) {
    for (const cuid of [service.cuid, ...service.fallbacks]) {
      console.error(`GoAkal: ${service.name} (${cuid})`);
      for (const status of ["PAID", "SETTLED"]) {
        const seen = new Set();
        for (let page = 1; page < 1000; page++) {
          const url = `https://goakal.com/service/api/v1/services/${cuid}/transactions?status=${status}&pageSize=100&page=${page}`;
          const res = await fetch(url, {headers: {"X-Api-Key": apiKey}, signal: AbortSignal.timeout(30000)});
          // A retired fallback ID may no longer exist; the primary ID must.
          if (res.status === 404 && cuid !== service.cuid) break;
          if (!res.ok) throw new Error(`GoAkal ${res.status} for ${cuid} page ${page}`);
          const body = await res.json();
          if (body.success === false) throw new Error(`GoAkal error for ${cuid}: ${body.error?.code}`);
          const data = Array.isArray(body.data) ? body.data : [];
          // Stop when the provider repeats a page instead of advancing.
          const fresh = data.filter(r => !seen.has(String(r.id || r.paymentId)));
          if (data.length && !fresh.length) break;
          for (const r of fresh) seen.add(String(r.id || r.paymentId));
          for (const r of fresh) rows.push({service: service.name, cuid, scopes: service.scopes, status: r.status,
            id: String(r.id || ""), payment: String(r.paymentId || ""), email: normalEmail(r.payerEmail),
            paid: millis(r.paidAt), scheme: String(r.priceSchemeTitle || ""), amount: Number(r.incomingAmount ?? r.amount)});
          if (data.length < 100) break;
          if (page % 10 === 0) console.error(`… ${service.name} ${status}: ${seen.size} rows`);
        }
      }
    }
  }
  return rows;
}

// Exact price-scheme titles only; anything else stays a human decision.
function periods(rows) {
  const valid = [], rejected = [];
  for (const r of rows) {
    const months = DURATIONS[r.scheme.trim().toLowerCase()];
    if (!months || !(r.amount > 0) || !r.email || !Number.isFinite(r.paid) || !(r.id || r.payment)) rejected.push({...r, why:
      !months ? "unknown_price_scheme" : !(r.amount > 0) ? "non_positive_amount" : !r.email ? "missing_email" : "missing_time_or_id"});
    else valid.push({...r, months});
  }
  valid.sort((a, b) => a.paid - b.paid);
  const ends = new Map(), out = [];
  for (const r of valid) for (const scope of r.scopes) {
    const chain = keyOf(r.email, scope), starts = Math.max(r.paid, ends.get(chain) || 0), expires = billingExpiry(starts, r.months);
    ends.set(chain, expires);
    out.push({...r, scope, starts, expires});
  }
  return {periods: out, rejected};
}

async function report(out) {
  const db = init(), now = Date.now();
  const rows = await providerRows();
  const {periods: verified, rejected} = periods(rows);
  const byTx = new Map();
  for (const p of verified) for (const id of [p.id, p.payment].filter(Boolean)) byTx.set(`${id}|${p.scope}`, p);

  const vipRegistry = new Set((await db.collection("access_vip_registry").get()).docs.map(d => normalEmail(d.data().email)));
  const isVipEmail = e => VIP_EMAILS.has(e) || vipRegistry.has(e);
  const users = new Map((await db.collection("users").get()).docs.map(d => [d.id, d.data()]));
  const owners = new Map((await db.collection("access_legacy_owners").get()).docs.map(d => [d.id, d.data()]));
  const ownerEmail = uid => normalEmail(users.get(uid)?.email || owners.get(uid)?.email);
  const grants = (await db.collection("access_grants").get()).docs.map(d => ({id: d.id, ...d.data()}));

  const goakal = grants.filter(g => g.provider === "goakal").map(g => {
    const match = byTx.get(`${g.transaction_id}|${g.scope}`);
    const email = normalEmail(g.email) || ownerEmail(g.uid);
    return {grant: g.id, uid: g.uid, email, scope: g.scope, recorded_expires_ms: g.expires_ms, already_verified: g.provider_verified === true,
      match: match ? {id: match.id || match.payment, email: match.email, amount: match.amount, scheme: match.scheme,
        starts_ms: match.starts, expires_ms: match.expires} : null,
      email_consistent: !match || match.email === email,
      vip: isVipEmail(email), owner_approved: false};
  });

  // Judge every seat as if revocations were open, so the owner sees what
  // unpausing would actually do. Nothing is written by the report.
  const runtime = (await db.collection("access_control").doc("runtime").get()).data() || {};
  const unpaused = {...runtime, revocations_paused: false, revocation_kill_switch: false, revocation_pause: {}};
  const view = {collection: name => name !== "access_control" ? db.collection(name) : {doc: id => id !== "runtime"
    ? db.collection(name).doc(id) : {get: async () => ({exists: true, data: () => unpaused})}}};
  const engine = new AccessControl(view, NOTEBOOK_ENTITIES, ENTITY_SCOPES);
  const assignments = (await db.collection("access_assignments").get()).docs.map(d => d.data());
  const expiredStillSeated = [];
  for (const a of assignments.filter(a => ["ready", "provisioning", "revocation_review"].includes(a.status))) {
    // Active rights first: the gate reports a hold before it looks at expiry,
    // which would otherwise list paying members as expired.
    const owner = await engine.owner(a.uid);
    if (rights(owner.user, owner.grants, a.scope || ENTITY_SCOPES[a.entity], now)) continue;
    const assessment = await engine.assessRevocation(a.uid, a.scope || ENTITY_SCOPES[a.entity], a.email);
    if (assessment.reason === "active_scope" || assessment.reason === "permanent_vip") continue;
    expiredStillSeated.push({uid: a.uid, email: a.email, entity: a.entity, notebook: a.notebook_id,
      decision: assessment.allowed ? "removable_once_unpaused" : assessment.reason, category: assessment.category || null,
      fingerprint: assessment.fingerprint || null});
  }

  const txs = (await db.collection("transactions").get()).docs.map(d => ({id: d.id, ...d.data()}));
  const adjustments = txs.filter(hasLegacyAccessAdjustment).map(t => ({transaction: t.id, uid: t.uid || null,
    email: normalEmail(t.customer_email || t.payer_email || t.email), source: t.source || null, status: t.status || null,
    scope: t.entitlement_key || null, expires_ms: millis(t.subscription_expires_at || t.access_expires_at || t.expires_at) || null,
    vip: isVipEmail(normalEmail(t.customer_email || t.payer_email || t.email)),
    // Owner fills one of: honor | expired_owner_confirmed | void_owner_confirmed (+ reason).
    decision: null}));
  const holds = [...users.entries()].filter(([, u]) => u.access_revocation_hold).map(([uid, u]) => ({uid, email: normalEmail(u.email)}));
  const reviews = (await db.collection("access_reviews").get()).docs.map(d => ({id: d.id, ...d.data()})).filter(r => r.status !== "resolved_by_verified_billing");

  const result = {generated_ms: now, provider_rows: rows.length, verified_periods: verified.length, rejected_rows: rejected,
    goakal_grants: goakal, expired_still_seated: expiredStillSeated, manual_adjustments: adjustments, holds, open_reviews: reviews,
    summary: {
      goakal_grants: goakal.length,
      goakal_matched: goakal.filter(g => g.match && g.email_consistent).length,
      goakal_unmatched: goakal.filter(g => !g.match).length,
      goakal_email_conflicts: goakal.filter(g => !g.email_consistent).length,
      goakal_expiry_changes: goakal.filter(g => g.match && g.match.expires_ms !== g.recorded_expires_ms).length,
      expired_still_seated: expiredStillSeated.length,
      removable_once_unpaused: expiredStillSeated.filter(x => x.decision === "removable_once_unpaused").length,
      seat_decisions: expiredStillSeated.reduce((m, x) => (m[x.decision] = (m[x.decision] || 0) + 1, m), {}),
      manual_adjustments: adjustments.length, holds: holds.length, open_reviews: reviews.length,
    }};
  fs.writeFileSync(out, JSON.stringify(result, null, 2));
  console.log(JSON.stringify(result.summary, null, 2));
  console.log("Report written to", out, "- review it, set owner_approved/decision, then run: apply", out);
}

async function apply(file) {
  const db = init(), plan = JSON.parse(fs.readFileSync(file, "utf8")), now = Date.now();
  let verified = 0, certified = 0, skipped = 0;
  for (const g of plan.goakal_grants || []) {
    if (g.owner_approved !== true || !g.match || !g.email_consistent || g.already_verified) { skipped++; continue; }
    const ref = db.collection("access_grants").doc(g.grant);
    const done = await db.runTransaction(async t => {
      const cur = (await t.get(ref)).data();
      // The grant must still be exactly what the owner reviewed.
      if (!cur || cur.provider !== "goakal" || cur.expires_ms !== g.recorded_expires_ms || cur.uid !== g.uid || cur.provider_verified) return false;
      t.update(ref, {provider_verified: true, verified_ms: now, verified_by: "legacy_access_migration",
        previous_expires_ms: cur.expires_ms, expires_ms: g.match.expires_ms, starts_ms: g.match.starts_ms});
      const owner = db.collection(g.uid.startsWith("legacy_") ? "access_legacy_owners" : "users").doc(g.uid);
      if ((await t.get(owner)).exists) t.update(owner, {access_due_ms: now});
      return true;
    });
    done ? verified++ : skipped++;
  }
  // Manual adjustments: one certificate per (uid, scope) once every adjustment
  // on it has an owner decision. The fingerprint is re-derived at apply time.
  const engine = new AccessControl(db, NOTEBOOK_ENTITIES, ENTITY_SCOPES);
  const byOwner = new Map();
  for (const a of plan.manual_adjustments || []) if (a.uid && a.scope && !a.vip) {
    const k = `${a.uid}|${a.scope}`; byOwner.set(k, [...(byOwner.get(k) || []), a]);
  }
  for (const [k, list] of byOwner) {
    if (list.some(a => !a.decision || !["honor", "expired_owner_confirmed", "void_owner_confirmed"].includes(a.decision.action))) { skipped++; continue; }
    const [uid, scope] = k.split("|");
    const assessment = await engine.assessRevocation(uid, scope);
    const email = normalEmail((await engine.owner(uid)).user?.email);
    if (!assessment.fingerprint || !email) { skipped++; continue; }
    await db.collection("access_legacy_audits").doc(keyOf(uid, scope)).set({uid, scope, email, status: "approved",
      owner_approved: true, policy: REVOCATION_POLICY, fingerprint: assessment.fingerprint, approved_ms: now,
      adjustments: Object.fromEntries(list.map(a => [a.transaction, {...a.decision, owner_approved: true}]))});
    certified++;
  }
  console.log(JSON.stringify({verified, certified, skipped}));
  console.log("Next: run `node lib/access_worker.js --import` on the VPS so holds backed by verified billing are lifted.");
}

// Owner decisions file: {"decisions": [...]} as documented in legacy_decisions.cjs.
async function runDecisions(file, step) {
  const db = init(), entries = JSON.parse(fs.readFileSync(file, "utf8")).decisions || [];
  const engine = new AccessControl(db, NOTEBOOK_ENTITIES, ENTITY_SCOPES);
  const log = step === "certify" ? await certify(db, entries, {engine}) : await applyDecisions(db, entries, {engine});
  console.log(JSON.stringify(log, null, 1));
}

const [mode, arg] = process.argv.slice(2);
(mode === "report" ? report(arg || `legacy_access_report_${new Date().toISOString().slice(0, 10)}.json`)
  : mode === "apply" && arg ? apply(arg)
  : (mode === "apply-decisions" || mode === "certify") && arg ? runDecisions(arg, mode)
  : Promise.reject(new Error("usage: report [out.json] | apply <report.json> | apply-decisions <decisions.json> | certify <decisions.json>")))
  .then(() => process.exit(0), e => { console.error(e.message); process.exit(1); });
