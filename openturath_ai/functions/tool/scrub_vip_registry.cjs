#!/usr/bin/env node
/**
 * Safe Firestore VIP Registry Scrubber.
 * 
 * Inspects all documents in `access_vip_registry` collection.
 * - Retains canonical VIPs defined in VIP_EMAILS.
 * - Identifies rogue / legacy entries (e.g. paying single-module customers
 *   who were mistakenly marked VIP or old test accounts).
 * 
 * Usage:
 *   node tool/scrub_vip_registry.cjs            # Dry-run (audit only)
 *   node tool/scrub_vip_registry.cjs --apply    # Execute deletions
 */
const admin = require("firebase-admin");
const { VIP_EMAILS, normalEmail, keyOf } = require("../lib/access_control.js");

if (!admin.apps.length) {
  try {
    admin.initializeApp();
  } catch (e) {
    console.error("Failed to initialize Firebase Admin SDK:", e.message);
    process.exit(1);
  }
}

const db = admin.firestore();

async function main() {
  const isApply = process.argv.includes("--apply");
  console.log(`[SCRUB VIP REGISTRY] Running in ${isApply ? "⚠️ APPLY (DESTRUCTIVE)" : "🔍 DRY-RUN (AUDIT ONLY)"} mode.`);
  console.log(`Canonical VIP Count: ${VIP_EMAILS.size}`);

  const snapshot = await db.collection("access_vip_registry").get();
  console.log(`Total documents in Firestore access_vip_registry: ${snapshot.size}`);

  let canonicalCount = 0;
  let rogueCount = 0;
  const toDelete = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const email = normalEmail(data.email);

    if (VIP_EMAILS.has(email)) {
      canonicalCount++;
      console.log(`  [CANONICAL VIP] ${email} (doc: ${doc.id})`);
    } else {
      rogueCount++;
      console.log(`  [NON-CANONICAL / ROGUE] ${email || "NO_EMAIL"} (doc: ${doc.id}) - source: ${JSON.stringify(data)}`);
      toDelete.push(doc);
    }
  }

  console.log("\n--- SUMMARY ---");
  console.log(`Canonical VIPs retained: ${canonicalCount}`);
  console.log(`Rogue entries found: ${rogueCount}`);

  if (rogueCount > 0) {
    if (isApply) {
      console.log(`\nExecuting removal of ${toDelete.length} non-canonical documents...`);
      const batchSize = 100;
      for (let i = 0; i < toDelete.length; i += batchSize) {
        const batch = db.batch();
        const chunk = toDelete.slice(i, i + batchSize);
        chunk.forEach(d => batch.delete(d.ref));
        await batch.commit();
      }
      console.log(`Successfully purged ${toDelete.length} rogue documents from access_vip_registry.`);
    } else {
      console.log("\nDry-run complete. No changes were made. Pass --apply to perform deletions.");
    }
  } else {
    console.log("Registry is 100% clean and consistent with canonical VIPs.");
  }
}

main().catch(err => {
  console.error("Scrubber failed:", err);
  process.exit(1);
});
