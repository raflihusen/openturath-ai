// Executes owner-approved decisions on legacy (GoAkal / manual / gift) access so
// the account can be evaluated by the ledger like every Midtrans buyer.
// Only entries with "approved": true run. Each write re-checks the document it
// changes; nothing is deleted, and VIP accounts are never touched.
//
// Actions (one per entry):
//   link_orphan_grant {grant, uid}         attach a paid grant that has no owner
//   honor_until {uid, scope, until_ms, source_transaction?, reason}
//                                          record an owner bonus / gift / transfer as a verified admin grant
//   end_access {uid, scope, reason}        owner confirms the right ended (e.g. transferred away)
//   lift_hold {uid}                        release access_revocation_hold once the evidence is settled
// After the actions, a revocation certificate is issued per (uid, scope) whose
// manual adjustments all have a decision, using the fingerprint at that moment.
const {VIP_EMAILS, normalEmail, keyOf, hasLegacyAccessAdjustment, millis, REVOCATION_POLICY, legacyTransactionScopes} = require("../lib/access_control.js");

const ACTIONS = new Set(["link_orphan_grant", "honor_until", "end_access", "lift_hold", "no_action"]);

async function ownerRef(db, uid) {
  for (const c of ["users", "access_legacy_owners"]) {
    const ref = db.collection(c).doc(uid);
    if ((await ref.get()).exists) return ref;
  }
  return null;
}
async function isProtected(db, email) {
  const e = normalEmail(email);
  return VIP_EMAILS.has(e) || (await db.collection("access_vip_registry").doc(keyOf(e)).get()).exists;
}

async function applyDecisions(db, entries, {engine, now = Date.now()}) {
  const log = [];
  const note = (entry, result) => log.push({uid: entry.uid, action: entry.action, scope: entry.scope || null, result});
  for (const entry of entries) {
    if (entry.approved !== true || entry.action === "no_action") continue;
    if (!ACTIONS.has(entry.action) || typeof entry.uid !== "string" || !entry.uid) { note(entry, "invalid"); continue; }
    const ref = await ownerRef(db, entry.uid);
    if (!ref) { note(entry, "owner_missing"); continue; }
    const email = normalEmail((await ref.get()).data().email);
    if (await isProtected(db, email) || (await ref.get()).data().is_vip === true) { note(entry, "vip_untouched"); continue; }
    const result = await db.runTransaction(async t => {
      const owner = (await t.get(ref)).data();
      if (!owner) return "owner_missing";
      const ids = new Set(owner.access_grant_ids || []);
      if (entry.action === "link_orphan_grant") {
        const g = db.collection("access_grants").doc(entry.grant), cur = (await t.get(g)).data();
        if (!cur || cur.uid || normalEmail(cur.email) !== email || cur.kind !== "payment" || !(cur.amount > 0)) return "grant_not_orphan_or_mismatch";
        t.update(g, {uid: entry.uid, provider_verified: true, verified_ms: now, verified_by: "owner_decision"});
        ids.add(entry.grant);
      } else if (entry.action === "honor_until") {
        if (!Number.isFinite(entry.until_ms) || entry.until_ms <= now || typeof entry.scope !== "string") return "invalid_period";
        const id = keyOf("owner_honor", entry.uid, entry.scope, entry.source_transaction || "profile");
        const g = db.collection("access_grants").doc(id);
        if ((await t.get(g)).exists) return "already_recorded";
        t.set(g, {uid: entry.uid, email, scope: entry.scope, kind: "admin", admin_verified: true, status: "active",
          starts_ms: now, expires_ms: entry.until_ms, source_transaction: entry.source_transaction || null,
          reason: String(entry.reason || "owner_decision").slice(0, 300), created_ms: now, created_by: "owner_decision"});
        ids.add(id);
      } else if (entry.action === "end_access") {
        const ents = {...(owner.entitlements || {})};
        for (const k of [entry.scope, ...(entry.scope === "all_access" ? Object.keys(ents) : [])])
          if (ents[k]) ents[k] = {...ents[k], status: "revoked", revoked_reason: String(entry.reason || "owner_decision").slice(0, 300), revoked_ms: now};
        t.update(ref, {entitlements: ents});
      } else if (entry.action === "lift_hold") {
        if (owner.access_revocation_hold !== true) return "no_hold";
        t.update(ref, {access_revocation_hold: false, access_hold_lifted_ms: now});
        return "applied";
      }
      t.update(ref, {access_grant_ids: [...ids], access_version: 2, access_due_ms: now});
      return "applied";
    });
    note(entry, result);
  }

  return log;
}

// Run after the worker has processed the migrated accounts (their profile
// projection is part of the fingerprint). Idempotent: re-run after any change.
async function certify(db, entries, {engine, now = Date.now()}) {
  const log = [], decisions = entries.filter(e => e.approved === true);
  const pairs = new Set(decisions.flatMap(e => (e.certify || (e.scope ? [e.scope] : [])).map(s => `${e.uid}|${s}`)));
  for (const key of pairs) {
    const [uid, scope] = key.split("|");
    const evidence = await engine.revocationFingerprint(uid, scope);
    if (!evidence) { log.push({uid, scope, result: "owner_missing"}); continue; }
    if (await isProtected(db, evidence.email)) { log.push({uid, scope, result: "vip_untouched"}); continue; }
    const adjustments = {};
    let unresolved = false;
    for (const tx of evidence.txs.values()) {
      if (!hasLegacyAccessAdjustment(tx)) continue;
      const explicit = millis(tx.subscription_expires_at || tx.access_expires_at || tx.expires_at);
      const honored = evidence.grants.find(g => g.kind === "admin" && g.admin_verified === true && g.source_transaction === tx.id &&
        [scope, "all_access"].includes(g.scope) && Number.isFinite(explicit) && g.expires_ms >= explicit);
      const ended = decisions.find(e => e.uid === uid && e.action === "end_access" && [scope, "all_access"].includes(e.scope));
      if (honored) adjustments[tx.id] = {action: "honor", grant_id: honored.id};
      else if (ended) adjustments[tx.id] = {action: "void_owner_confirmed", owner_approved: true, reason: String(ended.reason || "owner_decision")};
      else if (Number.isFinite(explicit) && explicit <= now) adjustments[tx.id] = {action: "expired_owner_confirmed"};
      else unresolved = true;
    }
    if (unresolved) { log.push({uid, scope, result: "adjustment_without_decision"}); continue; }
    await db.collection("access_legacy_audits").doc(keyOf(uid, scope)).set({uid, scope, email: evidence.email, status: "approved",
      owner_approved: true, policy: REVOCATION_POLICY, fingerprint: evidence.fingerprint, approved_ms: now, adjustments});
    log.push({uid, scope, result: "issued"});
  }
  return log;
}

module.exports = {applyDecisions, certify};
