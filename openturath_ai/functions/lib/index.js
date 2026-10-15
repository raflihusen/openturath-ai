"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onClientErrorLogged = exports.akalWebhook = exports.syncAkalPurchases = exports.cleanupOrphanedDeletions = exports.onUserDeleted = exports.onProvisioningOutboxCreated = exports.processProvisioningOutbox = exports.dailyRevoke = exports.onUserCreate = exports.redeemCode = exports.checkPaymentStatus = exports.midtransWebhook = exports.dokuWebhook = exports.monitorAccessHealth = exports.reconcileMidtransPayments = exports.createCheckout = exports.askAgent = exports.recordQuestion = exports.getAgentUrl = exports.MODULE_PLANS = exports.PURCHASABLE_AGENTS = void 0;
exports.addCalendarMonthsClamped = addCalendarMonthsClamped;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios_1 = require("axios");
const crypto = require("crypto");
const access_control_1 = require("./access_control");
const access_catalog_1 = require("./access_catalog");
const native_chat_1 = require("./native_chat");
const notebook_catalog_1 = require("./notebook_catalog");
admin.initializeApp();
const db = admin.firestore();
// ================================================================
// TELEGRAM NOTIFICATION HELPER
// ================================================================
async function sendTelegramNotification(text) {
    var _a;
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const chatId = process.env.TELEGRAM_CHAT_ID;
    if (!token || !chatId)
        return false;
    try {
        const result = await axios_1.default.post(`https://api.telegram.org/bot${token}/sendMessage`, {
            chat_id: chatId,
            text,
            parse_mode: "HTML",
        }, { timeout: 5000 });
        return ((_a = result.data) === null || _a === void 0 ? void 0 : _a.ok) === true;
    }
    catch (_) {
        console.error("[Telegram] Notification delivery failed; credentials redacted.");
        return false;
    }
}
// Telegram messages use parse_mode HTML; every value that originates from a
// user, a payment provider or a client device must pass through this.
function esc(value) {
    return String(value !== null && value !== void 0 ? value : "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").slice(0, 400);
}
// Cutover switch shared with the VPS worker and the legacy Python writers.
async function vpsWriterActive() {
    var _a;
    return ((_a = (await db.collection("access_control").doc("runtime").get()).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2";
}
// Scopes the profile shows as active that no ledger grant backs. Moving such
// an account to the ledger-only evaluator would silently drop those modules,
// so the caller places it on a revocation hold for review instead.
function unbackedLegacyScopes(entitlements, grants, skipScope, now) {
    return Object.entries(entitlements || {}).filter(([scope, ent]) => {
        if (scope === skipScope || !ent || ent.status === "revoked" || ent.status === "expired")
            return false;
        const expiry = (0, access_control_1.millis)(ent.expiry);
        if (!Number.isFinite(expiry) || expiry <= now)
            return false;
        return !grants.some(g => g && g.status === "active" && Number.isFinite(g.expires_ms) && g.expires_ms > now &&
            [scope, "all_access", "all_ai"].includes(g.scope));
    }).map(([scope]) => scope);
}
// ================================================================
// HARGA & DURASI OTORITATIF — Ditentukan oleh `resolvePlanPricing`
// ================================================================
// URL NotebookLM — Inisialisasi otomatis dari Katalog 24 Entitas OpenTurath
const AGENT_URLS = {};
for (const [agentId, entityCode] of Object.entries(notebook_catalog_1.AGENT_TO_ENTITY)) {
    const entity = notebook_catalog_1.NOTEBOOK_ENTITIES[entityCode];
    if (entity) {
        AGENT_URLS[agentId] = entity.masterUrl;
    }
}
// Mapping eksplisit mencegah agent baru "jatuh" ke entitlement default dan
// tidak sengaja terbuka oleh langganan modul lain.
// Whitelist modul yang diizinkan untuk dibeli via checkout payment (OT-F001)
exports.PURCHASABLE_AGENTS = new Set([
    "fiqh_tahawwulat",
    "fiqh_tahawwulat_muhaqqiq",
    "fiqh_tahawwulat_bayan",
    "fiqh_tahawwulat_mukhtabir",
    "fiqh_tahawwulat_habib",
    "fiqh_tahawwulat_khatib",
    "fiqh_syafii",
    "fiqh_syafii_muhaqqiq",
    "fiqh_hanafi",
    "fiqh_maliki",
    "fiqh_hanbali",
    "fiqh_hambali",
    "fiqh_muqaran",
    "fatawa_masail",
    "qawaid_fiqhiyyah",
    "hadits",
    "syarah_hadits",
    "musthalah_hadits",
    "tafsir",
    "tajwid_qiraat",
    "ushul_fiqh",
    "tarikh",
    "thabaqat_rijal",
    "tasawwuf",
    "habib_umar",
    "imam_ghazali",
    "aqidah",
    "nahwu_sharaf",
    "bibliografi_faharis",
]);
exports.MODULE_PLANS = {
    tholib_1m: { amount: 49000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
    tholib_6m: { amount: 299000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
    bahits_1y: { amount: 499000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
    "1m": { amount: 49000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
    "6m": { amount: 299000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
    "1y": { amount: 499000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
};
function getEntitlementKey(agentId) {
    const entitlementKey = access_catalog_1.AGENT_ENTITLEMENTS[agentId];
    if (!entitlementKey) {
        // OT-F001: Jangan pernah mengembalikan input mentah client untuk mencegah privilege escalation
        return "";
    }
    return entitlementKey;
}
function addCalendarMonthsClamped(baseDate, months) {
    const result = new Date(baseDate.getTime());
    const originalDay = result.getDate();
    result.setDate(1);
    result.setMonth(result.getMonth() + months);
    const maxDays = new Date(result.getFullYear(), result.getMonth() + 1, 0).getDate();
    result.setDate(Math.min(originalDay, maxDays));
    return result;
}
function getEntitlementAccess(userData, entitlementKey) {
    var _a, _b, _c;
    if ((0, access_control_1.isVip)(userData))
        return { premiumPlan: true, active: true };
    if (userData.account_deleted === true)
        return { premiumPlan: false, active: false };
    const entitlements = userData.entitlements && typeof userData.entitlements === "object"
        ? userData.entitlements : {};
    const now = Date.now();
    const active = (ent) => {
        var _a, _b, _c;
        if (!ent || typeof ent.plan !== "string")
            return false;
        if (ent.status === "revoked" || ent.status === "expired")
            return false;
        const allowed = /^(trial|tholib(?:_1m|_6m)?|bahits(?:_1y)?|premium|all_access|all_ai.*|single|sultan|pro|voucher(?:_.*)?|redeem(?:_.*)?|custom|full)$/.test(ent.plan);
        const expiry = ((_a = ent.expiry) === null || _a === void 0 ? void 0 : _a.toDate) ? ent.expiry.toDate() : (((_b = ent.expiry) === null || _b === void 0 ? void 0 : _b._seconds) ? new Date(ent.expiry._seconds * 1000) : new Date((_c = ent.expiry) !== null && _c !== void 0 ? _c : ""));
        return allowed && Number.isFinite(expiry.getTime()) && expiry.getTime() > now;
    };
    const all = (_a = entitlements.all_access) !== null && _a !== void 0 ? _a : entitlements.all_ai;
    if (active(all))
        return { premiumPlan: true, active: true };
    const specific = entitlements[entitlementKey];
    if (active(specific))
        return { premiumPlan: true, active: true };
    // Only explicit revocation of all_access blocks global subscription fallback
    if (all && all.status === "revoked") {
        return { premiumPlan: true, active: false };
    }
    // Account-level active subscription
    const expiry = ((_b = userData.subscription_expiry) === null || _b === void 0 ? void 0 : _b.toDate)
        ? userData.subscription_expiry.toDate() : new Date((_c = userData.subscription_expiry) !== null && _c !== void 0 ? _c : "");
    const isGlobalExpiryValid = Number.isFinite(expiry.getTime()) && expiry.getTime() > now;
    const globalPlanPattern = /^(all_access|all_ai.*|full|sultan)$/;
    const isGlobalPlan = typeof userData.plan === "string" && globalPlanPattern.test(userData.plan);
    if (isGlobalPlan && isGlobalExpiryValid) {
        return { premiumPlan: true, active: true };
    }
    if (userData.plan === "single") {
        return { premiumPlan: !!specific, active: false };
    }
    // Legacy single module plan fallback: only grant if user's scope or active_module matches
    const userScope = String(userData.active_module || userData.scope || userData.entitlement_key || "").toLowerCase();
    const isMatchingModule = userScope === entitlementKey ||
        (entitlementKey === "fiqh_syafii" && (!userScope || userScope.includes("syafi")));
    const legacySinglePlan = ["tholib_1m", "tholib_6m", "bahits_1y", "tholib", "bahits"].includes(userData.plan);
    if (legacySinglePlan && isMatchingModule && isGlobalExpiryValid) {
        return { premiumPlan: true, active: true };
    }
    const legacyGlobal = ["all_access", "all_ai_1m", "all_ai_6m", "all_ai_1y", "all_ai", "full", "sultan"].includes(userData.plan);
    return { premiumPlan: legacyGlobal, active: legacyGlobal && isGlobalExpiryValid };
}
// ================================================================
// FUNCTION 1: getAgentUrl
// Dipanggil oleh Flutter saat user membuka agent
// ================================================================
exports.getAgentUrl = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk mengakses agent.");
    }
    const uid = context.auth.uid;
    await enforceRateLimit(`agent_url_${uid}`, 60, 60, "Terlalu banyak permintaan membuka asisten. Silakan coba kembali sebentar lagi.");
    const agentId = data.agentId;
    if (!agentId) {
        throw new functions.https.HttpsError("invalid-argument", "agentId diperlukan.");
    }
    const resolved = (0, notebook_catalog_1.resolveAgentNotebook)(agentId, uid);
    const url = resolved ? resolved.url : AGENT_URLS[agentId];
    if (!url) {
        throw new functions.https.HttpsError("not-found", "Agent tidak ditemukan atau belum aktif.");
    }
    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
        throw new functions.https.HttpsError("not-found", "User tidak ditemukan.");
    }
    const userData = userDoc.data();
    // Until cutover no worker creates notebook assignments, so ledger-only
    // resolution would lock out every paying account. Legacy evaluation applies.
    const ledgerActive = userData.access_version === 2 && await vpsWriterActive();
    if (ledgerActive && (context.auth.token.email_verified !== true ||
        String(context.auth.token.email || "").trim().toLowerCase() !== String(userData.email || "").trim().toLowerCase())) {
        throw new functions.https.HttpsError("failed-precondition", "Gunakan email terverifikasi yang terdaftar untuk akses notebook ini.");
    }
    if (ledgerActive) {
        const entity = notebook_catalog_1.AGENT_TO_ENTITY[agentId];
        if (!entity)
            throw new functions.https.HttpsError("not-found", "Kajian tidak ditemukan.");
        try {
            return await new access_control_1.AccessControl(db, notebook_catalog_1.NOTEBOOK_ENTITIES, access_catalog_1.ENTITY_SCOPES).resolve(uid, entity);
        }
        catch (e) {
            if (e instanceof access_control_1.AccessFault)
                throw new functions.https.HttpsError(e.code, e.message);
            throw e;
        }
    }
    const questionsUsed = userData.questions_used || 0;
    const entitlementKey = getEntitlementKey(agentId);
    const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
    if (entitlementAccess.active) {
        if (await vpsWriterActive()) {
            const entity = notebook_catalog_1.AGENT_TO_ENTITY[agentId];
            if (!entity)
                throw new functions.https.HttpsError("not-found", "Kajian tidak ditemukan.");
            try {
                return await new access_control_1.AccessControl(db, notebook_catalog_1.NOTEBOOK_ENTITIES, access_catalog_1.ENTITY_SCOPES).resolveObservedLegacy(uid, userData.email, entity);
            }
            catch (e) {
                if (e instanceof access_control_1.AccessFault)
                    throw new functions.https.HttpsError(e.code, e.message);
                throw e;
            }
        }
        return {
            url,
            notebookId: resolved === null || resolved === void 0 ? void 0 : resolved.notebookId,
            cloneName: resolved === null || resolved === void 0 ? void 0 : resolved.cloneName,
            entityCode: resolved === null || resolved === void 0 ? void 0 : resolved.entityCode,
            isMaster: resolved === null || resolved === void 0 ? void 0 : resolved.isMaster,
        };
    }
    throw new functions.https.HttpsError("permission-denied", "Akses modul riset ini membutuhkan langganan aktif atau kode redeem santri. Silakan berlangganan atau masukkan kode akses untuk melanjutkan.");
});
// ================================================================
// FUNCTION 1b: recordQuestion
// Trial sekarang berbasis masa berlaku voucher, bukan kuota pertanyaan.
// ================================================================
exports.recordQuestion = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan.");
    }
    const agentId = data.agentId;
    const resolved = (0, notebook_catalog_1.resolveAgentNotebook)(agentId);
    if (!agentId || (!resolved && !AGENT_URLS[agentId])) {
        throw new functions.https.HttpsError("not-found", "Kajian tidak ditemukan atau belum aktif.");
    }
    const entitlementKey = getEntitlementKey(agentId);
    const userRef = db.collection("users").doc(context.auth.uid);
    return db.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
            throw new functions.https.HttpsError("not-found", "User tidak ditemukan.");
        }
        const userData = snapshot.data();
        const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
        if (entitlementAccess.active) {
            return { isPremium: true, questionsUsed: userData.questions_used || 0, questionsRemaining: null };
        }
        if (entitlementAccess.premiumPlan) {
            throw new functions.https.HttpsError("permission-denied", "Langganan Anda untuk kajian ini telah berakhir.");
        }
        throw new functions.https.HttpsError("permission-denied", "Akses Pro untuk kajian ini belum aktif. Tukarkan voucher atau berlangganan untuk melanjutkan.");
    });
});
// Native chat prototype. Enabling this requires a dedicated operator session,
// an isolated test notebook and an explicitly configured test UID.
exports.askAgent = functions
    .runWith({
    serviceAccount: "open-turath@appspot.gserviceaccount.com",
    secrets: ["NOTEBOOK_BRIDGE_KEY"],
    timeoutSeconds: 120,
    maxInstances: 1,
})
    .https.onCall(async (data, context) => {
    var _a;
    if (context.auth) {
        const header = context.rawRequest.headers.authorization;
        try {
            if (!(header === null || header === void 0 ? void 0 : header.startsWith("Bearer ")))
                throw new Error("Missing token");
            const verified = await admin.auth().verifyIdToken(header.slice(7), true);
            if (verified.uid !== context.auth.uid)
                throw new Error("Identity mismatch");
        }
        catch (_) {
            throw new functions.https.HttpsError("unauthenticated", "Silakan masuk kembali ke OpenTurath.");
        }
    }
    try {
        return await (0, native_chat_1.handleNativeChat)(data, (_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid, {
            testUid: process.env.NOTEBOOK_BRIDGE_TEST_UID,
            authorize: async (uid, agentId) => {
                const key = getEntitlementKey(agentId);
                if (!key || !AGENT_URLS[agentId])
                    return false;
                const snapshot = await db.collection("users").doc(uid).get();
                return snapshot.exists && getEntitlementAccess(snapshot.data(), key).active;
            },
            rateLimit: uid => enforceRateLimit(`native_chat_${uid}`, 10, 60, "Terlalu banyak pertanyaan. Silakan tunggu sebentar."),
            ask: async (request) => {
                const endpoint = process.env.NOTEBOOK_BRIDGE_URL;
                const key = process.env.NOTEBOOK_BRIDGE_KEY;
                if (!endpoint || !key || key.length < 32) {
                    throw new native_chat_1.NativeChatError("failed-precondition", "Koneksi asisten di aplikasi belum diaktifkan.");
                }
                const url = new URL(endpoint);
                const local = process.env.FUNCTIONS_EMULATOR === "true" &&
                    url.protocol === "http:" && ["127.0.0.1", "localhost"].includes(url.hostname);
                if ((!local && url.protocol !== "https:") || url.username || url.password || url.search || url.hash || url.pathname !== "/ask") {
                    throw new native_chat_1.NativeChatError("failed-precondition", "Konfigurasi koneksi asisten belum valid.");
                }
                const response = await axios_1.default.post(url.toString(), request, {
                    headers: { Authorization: `Bearer ${key}` },
                    timeout: 80000,
                    maxRedirects: 0,
                    maxContentLength: 512000,
                    maxBodyLength: 40000,
                });
                return response.data;
            },
        });
    }
    catch (error) {
        if (error instanceof native_chat_1.NativeChatError) {
            throw new functions.https.HttpsError(error.code, error.message);
        }
        if (error instanceof functions.https.HttpsError)
            throw error;
        throw new functions.https.HttpsError("unavailable", "Asisten belum dapat dihubungi.");
    }
});
// ================================================================
// DOKU PAYMENT GATEWAY INTEGRATION
// ================================================================
function getDokuConfig() {
    const env = process.env.DOKU_ENV || "sandbox";
    const baseUrl = env === "production" ? "https://api.doku.com" : "https://api-sandbox.doku.com";
    const clientId = process.env.DOKU_CLIENT_ID || "";
    const secretKey = process.env.DOKU_SECRET_KEY || "";
    const apiKey = process.env.DOKU_API_KEY || "";
    if (!clientId || !secretKey) {
        throw new Error("DOKU credentials are not configured");
    }
    return { env, baseUrl, clientId, secretKey, apiKey };
}
function generateDokuSignature(clientId, requestId, timestamp, targetPath, rawBody, secretKey) {
    const digest = crypto.createHash("sha256").update(rawBody).digest("base64");
    const signatureComponent = `Client-Id:${clientId}\n` +
        `Request-Id:${requestId}\n` +
        `Request-Timestamp:${timestamp}\n` +
        `Request-Target:${targetPath}\n` +
        `Digest:${digest}`;
    const hmac = crypto.createHmac("sha256", secretKey).update(signatureComponent).digest("base64");
    return `HMACSHA256=${hmac}`;
}
let cachedPricingConfig = null;
let cachedPricingTime = 0;
async function getDynamicPricingConfig() {
    const now = Date.now();
    if (cachedPricingConfig && now - cachedPricingTime < 60000) {
        return cachedPricingConfig;
    }
    try {
        const snap = await db.collection("app_config").doc("pricing").get();
        if (snap.exists && snap.data()) {
            cachedPricingConfig = snap.data();
            cachedPricingTime = now;
            return cachedPricingConfig;
        }
    }
    catch (err) {
        console.warn("[PricingConfig] Failed to fetch app_config/pricing, using hardcoded fallback:", err.message);
    }
    return null;
}
let cachedActiveAgentIds = null;
let cachedAgentsTime = 0;
async function getActiveAgentIds() {
    var _a, _b;
    const now = Date.now();
    if (cachedActiveAgentIds && now - cachedAgentsTime < 60000) {
        return cachedActiveAgentIds;
    }
    try {
        const snap = await db.collection("app_config").doc("agents").get();
        if (snap.exists && ((_a = snap.data()) === null || _a === void 0 ? void 0 : _a.active_agent_ids) && Array.isArray((_b = snap.data()) === null || _b === void 0 ? void 0 : _b.active_agent_ids)) {
            const ids = new Set(snap.data().active_agent_ids);
            cachedActiveAgentIds = ids;
            cachedAgentsTime = now;
            return ids;
        }
    }
    catch (err) {
        console.warn("[AgentsConfig] Failed to fetch app_config/agents, using launch default whitelist:", err.message);
    }
    // Default Launch Day Whitelist: Fikih Tahawwulat & Fikih Syafi'i (dan subagennya)
    return new Set([
        "fiqh_tahawwulat",
        "fiqh_tahawwulat_muhaqqiq",
        "fiqh_tahawwulat_bayan",
        "fiqh_tahawwulat_mukhtabir",
        "fiqh_tahawwulat_habib",
        "fiqh_tahawwulat_khatib",
        "fiqh_syafii",
        "fiqh_syafii_muhaqqiq",
    ]);
}
async function resolvePlanPricing(agentId, plan) {
    var _a, _b, _c, _d, _e, _f;
    const isAllAi = agentId === "all_ai" || agentId === "all_access" || plan.startsWith("all_ai") || plan.startsWith("all_access");
    if (isAllAi) {
        throw new functions.https.HttpsError("failed-precondition", "Paket Semua AI sementara dinonaktifkan. Silakan pilih paket per modul spesialis.");
    }
    // OT-F001: Closed-set whitelist enforcement
    if (!exports.PURCHASABLE_AGENTS.has(agentId)) {
        throw new functions.https.HttpsError("invalid-argument", "Modul spesialis tidak valid atau tidak dapat dibeli.");
    }
    // Blind Spot 2: Pastikan modul saat ini aktif untuk rilis (bukan modul terkunci)
    const activeAgents = await getActiveAgentIds();
    const isAgentActive = activeAgents.has(agentId) ||
        (agentId.startsWith("fiqh_tahawwulat") && activeAgents.has("fiqh_tahawwulat")) ||
        (agentId.startsWith("fiqh_syafii") && activeAgents.has("fiqh_syafii"));
    if (!isAgentActive) {
        throw new functions.https.HttpsError("failed-precondition", "Modul kajian ini sedang dalam tahap tahqiq dan belum dibuka untuk pembelian.");
    }
    // Baca konfigurasi dinamis (jika ada di Firestore)
    const dynamicConfig = await getDynamicPricingConfig();
    const activeRevision = (dynamicConfig === null || dynamicConfig === void 0 ? void 0 : dynamicConfig.revision) || "harga-v92-2026-10-14";
    // Harga Mandiri Khusus Fikih Tahawwulat
    if (agentId.startsWith("fiqh_tahawwulat")) {
        const tahawwulatTiers = {
            tholib_1m: { amount: 300000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
            tholib_6m: { amount: 1499000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
            bahits_1y: { amount: 1999000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
            "1m": { amount: 300000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
            "6m": { amount: 1499000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
            "1y": { amount: 1999000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
        };
        const tTier = tahawwulatTiers[plan];
        if (tTier) {
            const dynamicAmount = (_c = (_b = (_a = dynamicConfig === null || dynamicConfig === void 0 ? void 0 : dynamicConfig.plans) === null || _a === void 0 ? void 0 : _a.fiqh_tahawwulat) === null || _b === void 0 ? void 0 : _b[plan]) === null || _c === void 0 ? void 0 : _c.amount;
            const finalAmount = (typeof dynamicAmount === "number" && Number.isSafeInteger(dynamicAmount) && dynamicAmount > 0)
                ? dynamicAmount
                : tTier.amount;
            return {
                amount: finalAmount,
                durationMonths: tTier.durationMonths,
                label: `AI Fikih Tahawwulat ${tTier.labelSuffix}`,
                entitlementKey: "fiqh_tahawwulat",
                revision: activeRevision,
            };
        }
    }
    const tier = exports.MODULE_PLANS[plan];
    if (!tier) {
        throw new functions.https.HttpsError("invalid-argument", "Paket langganan tidak valid.");
    }
    const entitlementKey = getEntitlementKey(agentId);
    if (!entitlementKey || entitlementKey === "all_access" || entitlementKey === "all_ai") {
        throw new functions.https.HttpsError("failed-precondition", "Entitlement untuk modul ini tidak valid atau dinonaktifkan.");
    }
    const dynamicSpecAmount = (_f = (_e = (_d = dynamicConfig === null || dynamicConfig === void 0 ? void 0 : dynamicConfig.plans) === null || _d === void 0 ? void 0 : _d.specialists) === null || _e === void 0 ? void 0 : _e[plan]) === null || _f === void 0 ? void 0 : _f.amount;
    const finalSpecAmount = (typeof dynamicSpecAmount === "number" && Number.isSafeInteger(dynamicSpecAmount) && dynamicSpecAmount > 0)
        ? dynamicSpecAmount
        : tier.amount;
    const agentTitle = agentId.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
    return {
        amount: finalSpecAmount,
        durationMonths: tier.durationMonths,
        label: `Modul AI ${agentTitle} ${tier.labelSuffix}`,
        entitlementKey,
        revision: activeRevision,
    };
}
async function requestDokuCheckout(params) {
    var _a, _b, _c, _d, _e;
    const { baseUrl, clientId, secretKey } = getDokuConfig();
    const requestId = `REQ-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
    const timestamp = new Date().toISOString().slice(0, 19) + "Z";
    const targetPath = "/checkout/v1/payment";
    const requestBody = {
        order: {
            amount: params.amount,
            invoice_number: params.invoiceNumber,
            callback_url: "https://openturath-ai.web.app",
            line_items: [
                {
                    name: params.itemName.slice(0, 50),
                    price: params.amount,
                    quantity: 1
                }
            ]
        },
        payment: {
            payment_due_date: 120 // 2 jam
        },
        customer: {
            name: params.customerName || "Peneliti OpenTurath",
            email: params.customerEmail,
            phone: (params.customerPhone && params.customerPhone.trim().length >= 8) ? params.customerPhone.trim() : "081234567890"
        }
    };
    const rawJson = JSON.stringify(requestBody);
    const signature = generateDokuSignature(clientId, requestId, timestamp, targetPath, rawJson, secretKey);
    console.log(`[DOKU API] Requesting Checkout for ${params.invoiceNumber} (${params.itemName}) - Rp ${params.amount}...`);
    const response = await axios_1.default.post(`${baseUrl}${targetPath}`, requestBody, {
        headers: {
            "Client-Id": clientId,
            "Request-Id": requestId,
            "Request-Timestamp": timestamp,
            "Signature": signature,
            "Content-Type": "application/json"
        },
        timeout: 15000
    });
    const paymentUrl = ((_c = (_b = (_a = response.data) === null || _a === void 0 ? void 0 : _a.response) === null || _b === void 0 ? void 0 : _b.payment) === null || _c === void 0 ? void 0 : _c.url) || ((_e = (_d = response.data) === null || _d === void 0 ? void 0 : _d.payment) === null || _e === void 0 ? void 0 : _e.url);
    if (!paymentUrl) {
        console.error("[DOKU API] No payment URL in response:", JSON.stringify(response.data));
        throw new Error("DOKU tidak mengembalikan payment URL.");
    }
    return paymentUrl;
}
// ================================================================
// MIDTRANS PAYMENT GATEWAY INTEGRATION (SNAP PRODUCTION)
// ================================================================
function getMidtransConfig() {
    const env = process.env.MIDTRANS_ENV || "production";
    const isProd = env === "production";
    const snapUrl = isProd
        ? "https://app.midtrans.com/snap/v1/transactions"
        : "https://app.sandbox.midtrans.com/snap/v1/transactions";
    const apiUrl = isProd
        ? "https://api.midtrans.com/v2"
        : "https://api.sandbox.midtrans.com/v2";
    const merchantId = process.env.MIDTRANS_MERCHANT_ID || "";
    const clientKey = process.env.MIDTRANS_CLIENT_KEY || "";
    const serverKey = process.env.MIDTRANS_SERVER_KEY || "";
    if (!serverKey) {
        throw new Error("MIDTRANS_SERVER_KEY is not configured");
    }
    return { env, isProd, snapUrl, apiUrl, merchantId, clientKey, serverKey };
}
async function requestMidtransSnapCheckout(params) {
    var _a, _b;
    const cfg = getMidtransConfig();
    const authHeader = "Basic " + Buffer.from(cfg.serverKey + ":").toString("base64");
    const payload = {
        transaction_details: {
            order_id: params.invoiceNumber,
            gross_amount: params.amount,
        },
        item_details: [
            {
                id: params.planId.slice(0, 50),
                price: params.amount,
                quantity: 1,
                name: params.itemName.slice(0, 50),
            },
        ],
        customer_details: {
            first_name: params.customerName || "Peneliti OpenTurath",
            email: params.customerEmail,
            phone: (params.customerPhone && params.customerPhone.trim().length >= 8) ? params.customerPhone.trim() : "081234567890",
        },
        callbacks: {
            finish: "https://openturath-ai.web.app/payment-success",
        },
    };
    console.log(`[Midtrans Snap] Requesting Checkout for ${params.invoiceNumber} (${params.itemName}) - Rp ${params.amount}...`);
    const response = await axios_1.default.post(cfg.snapUrl, payload, {
        headers: {
            "Authorization": authHeader,
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
        timeout: 15000,
    });
    const token = (_a = response.data) === null || _a === void 0 ? void 0 : _a.token;
    const redirectUrl = (_b = response.data) === null || _b === void 0 ? void 0 : _b.redirect_url;
    if (!redirectUrl) {
        console.error("[Midtrans Snap] Missing redirect_url in response:", response.data);
        throw new Error("Midtrans tidak mengembalikan redirect_url.");
    }
    return { token, redirectUrl };
}
// ================================================================
// ================================================================
// RATE LIMITING HELPER (In-Memory / Firestore Atomic Window)
// ================================================================
async function enforceRateLimit(key, limit, windowSeconds, errorMessage) {
    const now = Date.now();
    const rateLimitRef = db.collection("rate_limits").doc(key);
    await db.runTransaction(async (t) => {
        var _a;
        const snap = await t.get(rateLimitRef);
        if (!snap.exists) {
            t.set(rateLimitRef, {
                count: 1,
                reset_at: admin.firestore.Timestamp.fromMillis(now + windowSeconds * 1000),
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            });
            return;
        }
        const data = snap.data();
        const resetAt = ((_a = data.reset_at) === null || _a === void 0 ? void 0 : _a.toMillis) ? data.reset_at.toMillis() : (data.reset_at || 0);
        if (now > resetAt) {
            // Window reset
            t.set(rateLimitRef, {
                count: 1,
                reset_at: admin.firestore.Timestamp.fromMillis(now + windowSeconds * 1000),
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            });
            return;
        }
        const currentCount = (data.count || 0);
        if (currentCount >= limit) {
            const waitSec = Math.ceil((resetAt - now) / 1000);
            throw new functions.https.HttpsError("resource-exhausted", `${errorMessage} Harap tunggu ${waitSec} detik lagi.`);
        }
        t.update(rateLimitRef, {
            count: currentCount + 1,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
    });
}
// ================================================================
// FUNCTION 2: createCheckout
// Dipanggil dari app & web — mengembalikan link DOKU Checkout
// ================================================================
exports.createCheckout = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onCall(async (data, context) => {
    var _a, _b, _c, _d, _e;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk melakukan transaksi.");
    }
    const { plan, agentId, expectedAmount, pricingRevision } = data || {};
    const text = (value, max) => typeof value === "string" ? value.trim().slice(0, max) : "";
    const name = text(data === null || data === void 0 ? void 0 : data.name, 120);
    const email = text(data === null || data === void 0 ? void 0 : data.email, 254).toLowerCase();
    const phone = text(data === null || data === void 0 ? void 0 : data.phone, 20).replace(/[^0-9+]/g, "");
    if (typeof plan !== "string" || !plan || !name || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        throw new functions.https.HttpsError("invalid-argument", "Data tidak lengkap (nama dan email diperlukan).");
    }
    const currentAgentId = typeof agentId === "string" && agentId ? agentId : "fiqh_tahawwulat";
    const pricing = await resolvePlanPricing(currentAgentId, plan);
    // Reject stale offers before creating any invoice or contacting the gateway.
    const isRevisionValid = pricingRevision === pricing.revision || pricingRevision === "harga-v92-2026-10-14";
    if (expectedAmount !== undefined &&
        (!Number.isSafeInteger(expectedAmount) || expectedAmount !== pricing.amount || !isRevisionValid)) {
        throw new functions.https.HttpsError("failed-precondition", "Harga penawaran telah berubah. Muat ulang aplikasi.");
    }
    // Each checkout writes two documents and calls the gateway.
    await enforceRateLimit(`checkout_${context.auth.uid}`, 10, 600, "Terlalu banyak permintaan pembayaran.");
    const invoiceNumber = `OT-${crypto.randomUUID()}`;
    const trxRef = db.collection("transactions").doc();
    const trxId = trxRef.id;
    const uid = ((_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid) || null;
    // F-07: Tulis dokumen transaksi berstatus pending SEBELUM memanggil gateway Midtrans
    await trxRef.set({
        uid,
        plan,
        agent_id: currentAgentId,
        gateway: "midtrans",
        invoice_number: invoiceNumber,
        amount: pricing.amount,
        duration_months: pricing.durationMonths,
        entitlement_key: pricing.entitlementKey,
        status: "pending",
        source: uid ? "app" : "website",
        customer_name: name,
        customer_email: email,
        customer_phone: phone || "",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("payment_reconciliation").doc(invoiceNumber).set({ invoice_number: invoiceNumber,
        transaction_document: trxId, uid, gateway: "midtrans", state: "pending", due_ms: Date.now() + 60000, attempts: 0 });
    let paymentUrl = "";
    let snapToken = "";
    try {
        const snapRes = await requestMidtransSnapCheckout({
            invoiceNumber,
            amount: pricing.amount,
            itemName: pricing.label,
            planId: plan,
            customerName: name,
            customerEmail: email,
            customerPhone: phone || "",
        });
        paymentUrl = snapRes.redirectUrl;
        snapToken = snapRes.token;
        // Update URL pembayaran dan Snap Token yang berhasil diperoleh
        await trxRef.update({
            payment_url: paymentUrl,
            snap_token: snapToken,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    catch (err) {
        console.error("[createCheckout] Midtrans checkout error:", ((_b = err.response) === null || _b === void 0 ? void 0 : _b.data) || err.message);
        await trxRef.update({
            status: "failed",
            error: ((_e = (_d = (_c = err.response) === null || _c === void 0 ? void 0 : _c.data) === null || _d === void 0 ? void 0 : _d.error_messages) === null || _e === void 0 ? void 0 : _e.join(", ")) || err.message || "Kendala teknis Midtrans",
            failed_at: admin.firestore.FieldValue.serverTimestamp(),
        }).catch(() => { });
        throw new functions.https.HttpsError("internal", "Sesi pembayaran belum dapat dibuat. Silakan coba lagi sebentar lagi.");
    }
    return {
        redirectUrl: paymentUrl,
        paymentUrl: paymentUrl,
        snapToken: snapToken,
        trxId,
        invoiceNumber,
        amount: pricing.amount,
        pricingRevision: pricing.revision
    };
});
function generateDokuGetSignature(clientId, requestId, timestamp, targetPath, secretKey) {
    const component = `Client-Id:${clientId}\nRequest-Id:${requestId}\nRequest-Timestamp:${timestamp}\nRequest-Target:${targetPath}`;
    const hmac = crypto.createHmac("sha256", secretKey).update(component).digest("base64");
    return `HMACSHA256=${hmac}`;
}
function getServiceTitleForEntitlement(entitlementKey) {
    if (entitlementKey === "all_ai")
        return access_catalog_1.SCOPE_LABELS.all_access;
    return access_catalog_1.SCOPE_LABELS[entitlementKey] || "Modul kajian";
}
async function processSuccessfulPayment(invoiceNumber, paidAmount, gatewayEvidence) {
    const txQuery = await db.collection("transactions")
        .where("invoice_number", "==", invoiceNumber)
        .limit(1)
        .get();
    if (txQuery.empty) {
        console.warn(`[Activation] Transaction not found for invoice: ${invoiceNumber}`);
        throw new Error("Transaction not found");
    }
    const txDocRef = txQuery.docs[0].ref;
    let activationResult = {
        alreadyActivated: false,
        entitlementKey: "fiqh_tahawwulat",
        plan: "premium",
        email: "",
        uid: "",
        serviceTitle: "Ruang Riset",
    };
    // F03, F04, F05: Transaksi Atomik Firestore
    await db.runTransaction(async (t) => {
        var _a;
        const txSnap = await t.get(txDocRef);
        if (!txSnap.exists) {
            throw new Error(`Transaction ${invoiceNumber} tidak ditemukan dalam transaksi`);
        }
        const txData = txSnap.data();
        const amount = typeof paidAmount === "string" && /^\d+(?:\.0+)?$/.test(paidAmount)
            ? Number(paidAmount) : paidAmount;
        if (!Number.isSafeInteger(amount) || amount <= 0 || amount !== txData.amount) {
            throw new Error("Payment amount does not match invoice");
        }
        // F04: Idempotensi invoice - cegah penambahan durasi berulang jika invoice sudah diaktivasi
        if (txData.activation_applied === true) {
            activationResult = {
                alreadyActivated: true,
                entitlementKey: txData.entitlement_key || "fiqh_tahawwulat",
                plan: txData.plan || "premium",
                email: (txData.customer_email || "").trim().toLowerCase(),
                uid: txData.uid || "",
                serviceTitle: getServiceTitleForEntitlement(txData.entitlement_key || "fiqh_tahawwulat"),
            };
            return;
        }
        const uid = txData.uid;
        const email = (txData.customer_email || "").trim().toLowerCase();
        const durationMonths = txData.duration_months || 1;
        const entitlementKey = txData.entitlement_key || "fiqh_tahawwulat";
        const plan = txData.plan || "premium";
        // F07: UID terverifikasi wajib menjadi pemilik dokumen
        if (!uid) {
            throw new Error(`Transaction ${invoiceNumber} tidak memiliki owner UID`);
        }
        const receiptRef = gatewayEvidence ? db.collection("payment_receipts").doc((0, access_control_1.keyOf)("midtrans", gatewayEvidence.transactionId)) : null;
        if (gatewayEvidence) {
            if (gatewayEvidence.orderId !== invoiceNumber || (gatewayEvidence.currency && gatewayEvidence.currency !== "IDR") ||
                typeof gatewayEvidence.transactionId !== "string" || !/^[a-zA-Z0-9_-]{1,128}$/.test(gatewayEvidence.transactionId))
                throw new Error("Invalid gateway identity");
            const receipt = (await t.get(receiptRef)).data();
            if (receipt && receipt.invoice_number !== invoiceNumber)
                throw new Error("Gateway transaction already bound to another invoice");
        }
        const userRef = db.collection("users").doc(uid);
        const uSnap = await t.get(userRef);
        if (!uSnap.exists)
            throw new Error("Payment owner profile is missing");
        const uData = uSnap.data();
        const entitlements = (uData.entitlements || {});
        // Only ledger-backed grants extend a paid period. Profile expiry is a projection.
        const now = new Date();
        let baseDate = now;
        const ownedGrants = [];
        for (const id of uData.access_grant_ids || []) {
            const g = (await t.get(db.collection("access_grants").doc(id))).data();
            if (g)
                ownedGrants.push(g);
            if (g && g.scope === entitlementKey && g.status === "active" && g.expires_ms > baseDate.getTime())
                baseDate = new Date(g.expires_ms);
        }
        const ledgerWriter = ((_a = (await t.get(db.collection("access_control").doc("runtime"))).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2";
        const unbacked = unbackedLegacyScopes(entitlements, ownedGrants, entitlementKey, now.getTime());
        const expiryDate = new Date((0, access_control_1.billingExpiry)(baseDate.getTime(), durationMonths));
        const grantId = (0, access_control_1.keyOf)("invoice", invoiceNumber);
        if (receiptRef)
            t.set(receiptRef, { invoice_number: invoiceNumber, uid, transaction_id: gatewayEvidence.transactionId });
        if (txData.gateway === "midtrans")
            t.set(db.collection("payment_reconciliation").doc(invoiceNumber), {
                invoice_number: invoiceNumber, transaction_document: txDocRef.id, uid, gateway: "midtrans", state: "paid",
                lease: null, expires_ms: expiryDate.getTime(), due_ms: Date.now() + 6 * 3600000
            }, { merge: true });
        t.set(db.collection("access_grants").doc(grantId), {
            uid, scope: entitlementKey, kind: "payment", status: "active", amount,
            invoice_number: invoiceNumber, transaction_document: txDocRef.id,
            transaction_id: (gatewayEvidence === null || gatewayEvidence === void 0 ? void 0 : gatewayEvidence.transactionId) || txData.transaction_id || invoiceNumber,
            gateway: txData.gateway || "doku", starts_ms: baseDate.getTime(), expires_ms: expiryDate.getTime(),
            created_ms: now.getTime(),
        });
        // F03: Update Status Transaksi Atomik
        t.update(txDocRef, {
            status: "paid",
            activation_applied: true,
            paid_at: admin.firestore.FieldValue.serverTimestamp(),
            subscription_expires_at: admin.firestore.Timestamp.fromDate(expiryDate),
            billing_email: email, // F07: Simpan sebagai billing_email kontak terpisah
        });
        const isAllAccess = entitlementKey === "all_access" || entitlementKey === "all_ai";
        const updatedEntitlements = Object.assign(Object.assign({}, entitlements), { [entitlementKey]: {
                plan: plan,
                status: "active",
                source: `${txData.gateway || "doku"}_payment`,
                expiry: admin.firestore.Timestamp.fromDate(expiryDate),
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            } });
        const userUpdate = {
            entitlements: updatedEntitlements,
            access_due_ms: Date.now(),
            access_grant_ids: [...new Set([...(uData.access_grant_ids || []), grantId])],
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        };
        if (ledgerWriter) {
            userUpdate.access_version = 2;
            if (unbacked.length) {
                userUpdate.access_revocation_hold = true;
                userUpdate.access_legacy_audit_required = true;
            }
        }
        // F01: Hanya ubah plan global jika pembelian adalah paket all_access
        if (isAllAccess) {
            userUpdate.plan = plan;
            userUpdate.subscription_expiry = admin.firestore.Timestamp.fromDate(expiryDate);
        }
        // F07: Jangan menimpa email auth user jika sudah ada
        if (!uData.email && email) {
            userUpdate.email = email;
        }
        t.set(userRef, userUpdate, { merge: true });
        // F10, F11: Rekam durable outbox job dalam transaksi yang sama
        const outboxRef = db.collection("provisioning_outbox").doc(`job_${invoiceNumber}`);
        t.set(outboxRef, {
            invoice_number: invoiceNumber,
            uid: userRef.id,
            email: uData.email || email,
            name: uData.name || txData.customer_name || "Peneliti",
            entitlement_key: entitlementKey,
            plan: plan,
            action: "add",
            status: "pending",
            attempts: 0,
            created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        activationResult = {
            alreadyActivated: false,
            entitlementKey,
            plan,
            email: uData.email || email,
            uid: userRef.id,
            serviceTitle: getServiceTitleForEntitlement(entitlementKey),
        };
    });
    if (activationResult.alreadyActivated) {
        console.log(`[Activation] Invoice ${invoiceNumber} sudah diaktivasi sebelumnya (idempoten).`);
        return Object.assign({ success: true }, activationResult);
    }
    console.log(`[Activation] Akses berhasil diaktifkan atomik untuk ${activationResult.uid} (Modul: ${activationResult.entitlementKey})`);
    // Kirim notifikasi Telegram seketika saat pembayaran sukses & akses diaktifkan
    await sendTelegramNotification(`💳 <b>[PEMBAYARAN DITERIMA & AKSES AKTIF]</b>\n` +
        `🕌 OpenTurath AI Server\n` +
        `👤 Pengguna: <code>${esc(activationResult.email)}</code>\n` +
        `🆔 Invoice: <code>${esc(invoiceNumber)}</code>\n` +
        `📦 Produk: <b>${esc(activationResult.serviceTitle)}</b>\n` +
        `🏷️ Paket: <b>${esc(activationResult.plan.toUpperCase())}</b>\n` +
        `🔑 Entitlement: <code>${esc(activationResult.entitlementKey)}</code>\n` +
        `✅ Status: Sukses terdaftar & hak akses aktif.`);
    return Object.assign({ success: true }, activationResult);
}
function safeTimingEqual(a, b) {
    if (typeof a !== "string" || typeof b !== "string")
        return false;
    const bufA = Buffer.from(a);
    const bufB = Buffer.from(b);
    if (bufA.length !== bufB.length)
        return false;
    return crypto.timingSafeEqual(bufA, bufB);
}
async function applyMidtransRefund(invoice, verified) {
    const partial = String(verified.transaction_status).startsWith("partial");
    const query = await db.collection("transactions").where("invoice_number", "==", invoice).limit(1).get();
    const grantRef = db.collection("access_grants").doc((0, access_control_1.keyOf)("invoice", invoice));
    await db.runTransaction(async (t) => {
        var _a, _b, _c, _d, _e, _f;
        const grant = await t.get(grantRef), tx = query.empty ? null : await t.get(query.docs[0].ref);
        const uid = ((_a = grant.data()) === null || _a === void 0 ? void 0 : _a.uid) || ((_b = tx === null || tx === void 0 ? void 0 : tx.data()) === null || _b === void 0 ? void 0 : _b.uid);
        const ownerRef = uid ? db.collection("users").doc(uid) : null, owner = ownerRef ? await t.get(ownerRef) : null;
        const amount = (_d = (_c = grant.data()) === null || _c === void 0 ? void 0 : _c.amount) !== null && _d !== void 0 ? _d : (_e = tx === null || tx === void 0 ? void 0 : tx.data()) === null || _e === void 0 ? void 0 : _e.amount;
        if (amount === undefined || verified.order_id !== invoice || Number(verified.gross_amount) !== amount ||
            verified.currency && verified.currency !== "IDR" ||
            grant.exists && ((_f = grant.data()) === null || _f === void 0 ? void 0 : _f.transaction_id) !== verified.transaction_id)
            throw new Error("Refund identity mismatch");
        if (grant.exists)
            t.update(grantRef, partial ? { review_required: true, payment_status: verified.transaction_status } :
                { status: "revoked", payment_status: verified.transaction_status });
        if (tx === null || tx === void 0 ? void 0 : tx.exists)
            t.update(tx.ref, { status: verified.transaction_status, updated_at: admin.firestore.FieldValue.serverTimestamp() });
        if (ownerRef && (owner === null || owner === void 0 ? void 0 : owner.exists))
            t.update(ownerRef, { access_due_ms: Date.now() });
        if (partial)
            t.set(db.collection("access_reviews").doc((0, access_control_1.keyOf)("refund", invoice)), { uid: uid || null,
                invoice_number: invoice, code: "partial_refund_policy_review", updated_ms: Date.now() }, { merge: true });
        t.set(db.collection("payment_reconciliation").doc(invoice), { invoice_number: invoice, gateway: "midtrans",
            state: partial ? "partial_refund" : "refunded", lease: null, due_ms: partial ? Date.now() + 6 * 3600000 : 8640000000000000 }, { merge: true });
    });
}
// A missing webhook or closed app must not leave a paid invoice unprovisioned.
// The queue also rechecks active payments for refunds that were not delivered.
exports.reconcileMidtransPayments = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
    .pubsub.schedule("every 5 minutes").onRun(async () => {
    var _a;
    if (((_a = (await db.collection("access_control").doc("runtime").get()).data()) === null || _a === void 0 ? void 0 : _a.writer) !== "vps-v2")
        return null;
    const cfg = getMidtransConfig(), jobs = await db.collection("payment_reconciliation").where("due_ms", "<=", Date.now()).orderBy("due_ms").limit(200).get();
    let cursor = 0, completed = 0, failed = 0;
    const started = Date.now();
    const run = async () => {
        var _a;
        while (cursor < jobs.docs.length && Date.now() - started < 240000) {
            const doc = jobs.docs[cursor++], token = crypto.randomUUID();
            const job = await db.runTransaction(async (t) => {
                const current = (await t.get(doc.ref)).data();
                if (!current || current.due_ms > Date.now())
                    return null;
                t.update(doc.ref, { lease: token, due_ms: Date.now() + 300000, attempts: (current.attempts || 0) + 1 });
                return current;
            });
            if (!job)
                continue;
            let due = Date.now() + 60000;
            try {
                const response = await axios_1.default.get(`${cfg.apiUrl}/${encodeURIComponent(job.invoice_number)}/status`, {
                    headers: { Authorization: `Basic ${Buffer.from(`${cfg.serverKey}:`).toString("base64")}` }, timeout: 15000
                });
                const verified = response.data, status = verified.transaction_status;
                if (verified.order_id !== job.invoice_number || verified.currency && verified.currency !== "IDR")
                    throw new Error("Gateway order mismatch");
                if (status === "settlement" || status === "capture" && verified.fraud_status === "accept") {
                    await processSuccessfulPayment(job.invoice_number, verified.gross_amount, { transactionId: verified.transaction_id,
                        orderId: verified.order_id, currency: verified.currency });
                    due = job.expires_ms && job.expires_ms < Date.now() ? 8640000000000000 : Date.now() + 6 * 3600000;
                }
                else if (["refund", "partial_refund", "chargeback", "partial_chargeback"].includes(status)) {
                    await applyMidtransRefund(job.invoice_number, verified);
                    due = String(status).startsWith("partial") ? Date.now() + 6 * 3600000 : 8640000000000000;
                }
                else if (["expire", "deny", "cancel", "failure"].includes(status)) {
                    const tx = await db.collection("transactions").doc(job.transaction_document).get();
                    if (tx.exists && !((_a = tx.data()) === null || _a === void 0 ? void 0 : _a.activation_applied)) {
                        await db.runTransaction(async (t) => { var _a; const current = await t.get(tx.ref); if (current.exists && !((_a = current.data()) === null || _a === void 0 ? void 0 : _a.activation_applied))
                            t.update(tx.ref, { status }); });
                        due = 8640000000000000;
                    }
                }
                completed++;
            }
            catch (_) {
                failed++;
                due = Date.now() + Math.min(6 * 3600000, 60000 * 2 ** Math.min(job.attempts || 0, 12));
            }
            await db.runTransaction(async (t) => {
                const current = (await t.get(doc.ref)).data();
                if ((current === null || current === void 0 ? void 0 : current.lease) === token)
                    t.update(doc.ref, { due_ms: due, lease: null, last_checked_ms: Date.now() });
            });
        }
    };
    await Promise.all([run(), run(), run(), run(), run()]);
    await db.collection("access_control").doc("payment_heartbeat").set({ completed, failed, checked_ms: Date.now() });
    return null;
});
exports.monitorAccessHealth = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 120 })
    .pubsub.schedule("every 1 minutes").onRun(async () => {
    const runtime = (await db.collection("access_control").doc("runtime").get()).data();
    if ((runtime === null || runtime === void 0 ? void 0 : runtime.writer) !== "vps-v2")
        return null;
    const ref = db.collection("access_control").doc("monitor_health");
    const [h, p, cfgSnap, previous] = await Promise.all([
        db.collection("access_control").doc("heartbeat").get(), db.collection("access_control").doc("payment_heartbeat").get(),
        db.collection("access_control").doc("monitor").get(), ref.get()
    ]);
    const now = Date.now(), cfg = cfgSnap.data() || {}, prior = previous.data() || {}, started = prior.started_ms || now;
    const heart = h.data() || {}, payment = p.data() || {}, issues = [];
    if (now - (heart.last_success_ms || runtime.activated_ms || now) > 300000)
        issues.push("worker_stale");
    if (heart.authentication_error || now - (heart.last_provider_success_ms || runtime.activated_ms || now) > 300000)
        issues.push("sharing_provider_stale");
    if (now - (payment.checked_ms || started) > 900000)
        issues.push("payment_reconciliation_stale");
    try {
        const pending = await db.collection("access_jobs").where("status", "in", ["pending", "retry", "processing"]).orderBy("queued_ms").limit(1).get();
        if (!pending.empty && now - pending.docs[0].data().queued_ms > 900000)
            issues.push("access_queue_overdue");
    }
    catch (_) {
        if (now - started > 900000)
            issues.push("queue_observation_unavailable");
    }
    const state = issues.length ? issues.join(",") : "healthy", token = crypto.randomUUID();
    const enabled = cfg.enabled === true && cfg.approved_by_owner === true;
    const notify = await db.runTransaction(async (t) => {
        const current = (await t.get(ref)).data() || {};
        const send = enabled && current.notified_state !== state &&
            (issues.length > 0 || current.notified_state && current.notified_state !== "healthy") && !(current.lease_until_ms > now);
        t.set(ref, Object.assign(Object.assign(Object.assign({}, current), { started_ms: started, checked_ms: now, state, issues, notification_enabled: enabled }), (send ? { lease: token, lease_until_ms: now + 60000 } : {})));
        return send;
    });
    if (notify) {
        const labels = { worker_stale: "Worker VPS belum mengirim bukti siklus sukses lebih dari 5 menit.",
            sharing_provider_stale: "Koneksi NotebookLM belum terverifikasi; pemulihan sesi perlu diperiksa.",
            payment_reconciliation_stale: "Pemeriksaan pembayaran berkala belum berjalan sesuai jadwal.",
            access_queue_overdue: "Ada pekerjaan akses yang tertahan lebih dari 15 menit.",
            queue_observation_unavailable: "Antrean akses belum dapat diperiksa." };
        const text = issues.length ? "⚠️ <b>Otomasi akses OpenTurath perlu perhatian</b>\n" + issues.map(i => labels[i]).join("\n") :
            "✅ <b>Otomasi akses OpenTurath pulih.</b> Pemeriksaan worker, NotebookLM, dan pembayaran kembali berjalan.";
        const delivered = await sendTelegramNotification(text);
        await db.runTransaction(async (t) => {
            const current = (await t.get(ref)).data();
            if ((current === null || current === void 0 ? void 0 : current.lease) === token)
                t.update(ref, Object.assign({ lease: null, lease_until_ms: 0 }, (delivered ? { notified_state: state, notified_ms: Date.now() } : { notification_delivery_failed_ms: Date.now() })));
        });
    }
    return null;
});
// ================================================================
// FUNCTION 2b: dokuWebhook (HTTP Notification dari DOKU)
// Otomatis aktifkan akses santri di Firestore saat bayar sukses
// ================================================================
exports.dokuWebhook = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onRequest(async (req, res) => {
    var _a, _b, _c, _d;
    try {
        if (req.method !== "POST") {
            res.status(405).send("Method Not Allowed");
            return;
        }
        const headers = req.headers;
        const body = req.body || {};
        // F63: Redaksi log sensitif - jangan cetak raw authorization atau full personal payload
        const invoiceNumber = ((_a = body.order) === null || _a === void 0 ? void 0 : _a.invoice_number) || body.invoice_number;
        const status = ((_b = body.transaction) === null || _b === void 0 ? void 0 : _b.status) || body.transactionStatus || body.status;
        console.log(`[DOKU Webhook] Notifikasi diterima untuk invoice: ${invoiceNumber}, status: ${status}`);
        // Verifikasi Signature DOKU wajib di seluruh environment
        const incomingSignature = (headers["signature"] || headers["Signature"]);
        const dokuCfg = getDokuConfig();
        if (!incomingSignature) {
            console.error("[DOKU Webhook] Missing signature header.");
            res.status(401).send("Missing signature header");
            return;
        }
        const clientId = headers["client-id"];
        const requestId = headers["request-id"];
        const timestamp = headers["request-timestamp"];
        if (typeof incomingSignature !== "string" || typeof clientId !== "string" ||
            clientId !== dokuCfg.clientId || typeof requestId !== "string" ||
            requestId.length === 0 || requestId.length > 200 ||
            typeof timestamp !== "string" || !timestamp ||
            !Buffer.isBuffer(req.rawBody)) {
            res.status(401).send("Invalid notification headers");
            return;
        }
        const rawBody = req.rawBody.toString("utf8");
        const expectedSig1 = generateDokuSignature(clientId, requestId, timestamp, req.originalUrl || "/dokuWebhook", rawBody, dokuCfg.secretKey);
        const expectedSig2 = generateDokuSignature(clientId, requestId, timestamp, req.path || "/dokuWebhook", rawBody, dokuCfg.secretKey);
        const expectedSig3 = generateDokuSignature(clientId, requestId, timestamp, "/dokuWebhook", rawBody, dokuCfg.secretKey);
        const expectedSig4 = generateDokuSignature(clientId, requestId, timestamp, "/doku-webhook", rawBody, dokuCfg.secretKey);
        // F-06: Verifikasi signature dengan constant-time comparison mencegah timing attacks
        const isValidSig = safeTimingEqual(incomingSignature, expectedSig1) ||
            safeTimingEqual(incomingSignature, expectedSig2) ||
            safeTimingEqual(incomingSignature, expectedSig3) ||
            safeTimingEqual(incomingSignature, expectedSig4);
        if (!isValidSig) {
            console.error(`[DOKU Webhook] Signature mismatch for request ${requestId}`);
            res.status(401).send("Invalid signature");
            return;
        }
        // F-06: Verifikasi skew timestamp mencegah replay attack (toleransi maksimal 15 menit)
        if (timestamp) {
            const reqTime = new Date(timestamp).getTime();
            if (isNaN(reqTime) || Math.abs(Date.now() - reqTime) > 15 * 60 * 1000) {
                console.error(`[DOKU Webhook] Request-Timestamp invalid or skew > 15 min: ${timestamp}`);
                res.status(401).send("Timestamp expired or invalid");
                return;
            }
        }
        if (typeof invoiceNumber !== "string" || !/^[A-Za-z0-9_-]{1,128}$/.test(invoiceNumber)) {
            console.warn("[DOKU Webhook] Missing invoice_number in notification.");
            res.status(400).send("Missing invoice_number");
            return;
        }
        // F06: State Machine Idempotensi Event (received -> processing -> completed / failed)
        let eventRef = null;
        if (requestId) {
            eventRef = db.collection("webhook_events").doc(crypto.createHash("sha256").update(requestId).digest("hex"));
            const eventSnap = await eventRef.get();
            if (eventSnap.exists) {
                const eventData = eventSnap.data();
                if (eventData.status === "completed") {
                    console.log(`[DOKU Webhook] Request ID ${requestId} sudah berstatus completed. 200 OK.`);
                    res.status(200).json({ status: "ALREADY_PROCESSED", requestId });
                    return;
                }
            }
            await eventRef.set({
                invoice_number: invoiceNumber,
                status: "processing",
                received_at: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
        }
        if (status !== "SUCCESS") {
            console.log(`[DOKU Webhook] Status: ${status}, skipping activation.`);
            if (eventRef) {
                await eventRef.update({ status: "ignored_not_success" });
            }
            res.status(200).json({ status: "OK", message: "Ignored status" });
            return;
        }
        try {
            const actResult = await processSuccessfulPayment(invoiceNumber, (_d = (_c = body.order) === null || _c === void 0 ? void 0 : _c.amount) !== null && _d !== void 0 ? _d : body.amount);
            if (eventRef) {
                await eventRef.update({
                    status: "completed",
                    completed_at: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
            res.status(200).json({ status: "SUCCESS", invoice: invoiceNumber, details: actResult });
        }
        catch (err) {
            console.error(`[DOKU Webhook] Activation error for invoice ${invoiceNumber}:`, err.message);
            if (eventRef) {
                await eventRef.update({
                    status: "failed",
                    error: err.message || "Activation failure",
                    failed_at: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
            res.status(500).json({ status: "ERROR", message: "Failed to activate payment" });
        }
    }
    catch (err) {
        console.error("[DOKU Webhook] Uncaught error in handler:", err.message);
        res.status(500).json({ error: "Internal error" });
    }
});
// ================================================================
// FUNCTION 2b-2: midtransWebhook (HTTP Notification dari Midtrans)
// Otomatis verifikasi Signature SHA-512 & aktifkan akses santri
// ================================================================
exports.midtransWebhook = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onRequest(async (req, res) => {
    var _a;
    try {
        if (req.method !== "POST") {
            res.status(405).send("Method Not Allowed");
            return;
        }
        const body = req.body || {};
        const orderId = body.order_id;
        const statusCode = body.status_code;
        const grossAmount = body.gross_amount;
        const signatureKey = body.signature_key;
        let transactionStatus = body.transaction_status;
        let fraudStatus = body.fraud_status;
        console.log(`[Midtrans Webhook] Notifikasi order: ${orderId}, status: ${transactionStatus}, code: ${statusCode}`);
        if (!orderId || !statusCode || !grossAmount || !signatureKey) {
            console.error("[Midtrans Webhook] Missing required signature parameters in body.");
            res.status(400).send("Bad Request: Incomplete parameters");
            return;
        }
        const cfg = getMidtransConfig();
        // SHA-512 Signature verification
        const rawSig = `${orderId}${statusCode}${grossAmount}${cfg.serverKey}`;
        const expectedSig = crypto.createHash("sha512").update(rawSig).digest("hex");
        if (!safeTimingEqual(String(signatureKey).toLowerCase(), expectedSig.toLowerCase())) {
            console.error(`[Midtrans Webhook] Invalid signature key for order ${orderId}`);
            res.status(401).send("Invalid signature");
            return;
        }
        // Notification signature does not authenticate all status fields. Always
        // inquire using the server key before deciding access, including refunds.
        const inquiry = await axios_1.default.get(`${cfg.apiUrl}/${encodeURIComponent(String(orderId))}/status`, {
            headers: { Authorization: `Basic ${Buffer.from(`${cfg.serverKey}:`).toString("base64")}` }, timeout: 15000,
        });
        const verified = inquiry.data;
        if (verified.order_id !== orderId || Number(verified.gross_amount) !== Number(grossAmount) ||
            (verified.currency && verified.currency !== "IDR")) {
            res.status(400).send("Payment identity mismatch");
            return;
        }
        transactionStatus = verified.transaction_status;
        fraudStatus = verified.fraud_status;
        // State machine idempotensi event
        const eventKey = crypto.createHash("sha256").update(`midtrans_${orderId}_${transactionStatus}_${statusCode}`).digest("hex");
        const eventRef = db.collection("webhook_events").doc(eventKey);
        const eventSnap = await eventRef.get();
        if (eventSnap.exists && ((_a = eventSnap.data()) === null || _a === void 0 ? void 0 : _a.status) === "completed") {
            console.log(`[Midtrans Webhook] Event ${orderId} status ${transactionStatus} already completed.`);
            res.status(200).json({ status: "ALREADY_PROCESSED" });
            return;
        }
        await eventRef.set({
            gateway: "midtrans",
            order_id: orderId,
            transaction_status: transactionStatus,
            status_code: statusCode,
            gross_amount: grossAmount,
            status: "processing",
            received_at: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        const isSuccess = transactionStatus === "settlement" ||
            (transactionStatus === "capture" && fraudStatus === "accept");
        if (isSuccess) {
            console.log(`[Midtrans Webhook] Payment confirmed for ${orderId}. Activating entitlement...`);
            try {
                const actResult = await processSuccessfulPayment(orderId, grossAmount, { transactionId: verified.transaction_id, orderId: verified.order_id, currency: verified.currency });
                await eventRef.update({
                    status: "completed",
                    completed_at: admin.firestore.FieldValue.serverTimestamp(),
                });
                res.status(200).json({ status: "OK", orderId, details: actResult });
            }
            catch (actErr) {
                console.error(`[Midtrans Webhook] Activation error for ${orderId}:`, actErr.message);
                await eventRef.update({
                    status: "failed",
                    error: actErr.message,
                    failed_at: admin.firestore.FieldValue.serverTimestamp(),
                });
                res.status(500).json({ status: "ERROR", message: "Failed to activate payment" });
            }
        }
        else if (transactionStatus === "cancel" || transactionStatus === "expire" || transactionStatus === "deny") {
            console.log(`[Midtrans Webhook] Payment ${transactionStatus} for ${orderId}. Updating transaction record...`);
            const txQuery = await db.collection("transactions").where("invoice_number", "==", orderId).limit(1).get();
            if (!txQuery.empty) {
                await db.runTransaction(async (t) => {
                    var _a;
                    const tx = await t.get(txQuery.docs[0].ref);
                    if (((_a = tx.data()) === null || _a === void 0 ? void 0 : _a.activation_applied) === true)
                        return;
                    t.update(txQuery.docs[0].ref, { status: transactionStatus, updated_at: admin.firestore.FieldValue.serverTimestamp() });
                });
            }
            await eventRef.update({ status: "completed" });
            res.status(200).json({ status: "OK", message: `Transaction marked as ${transactionStatus}` });
        }
        else if (["refund", "partial_refund", "chargeback", "partial_chargeback"].includes(transactionStatus)) {
            await applyMidtransRefund(String(orderId), verified);
            await eventRef.update({ status: "completed" });
            res.status(200).json({ status: "OK" });
        }
        else {
            console.log(`[Midtrans Webhook] Pending status ${transactionStatus} for ${orderId}.`);
            await eventRef.update({ status: "pending" });
            res.status(200).json({ status: "OK", message: "Status pending" });
        }
    }
    catch (err) {
        console.error("[Midtrans Webhook] Uncaught error:", err.message);
        res.status(500).json({ error: "Internal error" });
    }
});
// ================================================================
// FUNCTION 2c: checkPaymentStatus (Active Status Inquiry dari Client/App)
// Memverifikasi status langsung ke DOKU API tanpa menunggu webhook
// ================================================================
exports.checkPaymentStatus = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onCall(async (data, context) => {
    var _a, _b, _c, _d;
    // 0. Wajibkan pengguna terotentikasi
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk memeriksa status pembayaran.");
    }
    const callerUid = context.auth.uid;
    // F-02: Rate limit status inquiry (maksimal 15 panggilan per menit per UID)
    await enforceRateLimit(`chk_${callerUid}`, 15, 60, "Terlalu banyak permintaan pemeriksaan status pembayaran.");
    const invoiceNumber = data.invoiceNumber;
    if (!invoiceNumber) {
        throw new functions.https.HttpsError("invalid-argument", "Invoice number diperlukan.");
    }
    // 1. Cek dulu apakah di Firestore transaksi sudah berstatus success
    const txQuery = await db.collection("transactions")
        .where("invoice_number", "==", invoiceNumber)
        .limit(1)
        .get();
    if (txQuery.empty) {
        throw new functions.https.HttpsError("not-found", "Transaksi tidak ditemukan.");
    }
    const txDoc = txQuery.docs[0];
    const txData = txDoc.data();
    // Verifikasi kepemilikan transaksi
    if (txData.uid !== callerUid) {
        throw new functions.https.HttpsError("permission-denied", "Anda tidak memiliki akses untuk memeriksa transaksi ini.");
    }
    if ((txData.status === "paid" || txData.status === "success") && txData.gateway !== "midtrans") {
        return { success: true, status: "SUCCESS", message: "Akses langganan sudah aktif." };
    }
    const gateway = txData.gateway || "midtrans";
    // 2. Status Inquiry ke Payment Gateway jika belum success di Firestore
    if (gateway === "midtrans") {
        const midtransCfg = getMidtransConfig();
        const statusUrl = `${midtransCfg.apiUrl}/${invoiceNumber}/status`;
        const authHeader = "Basic " + Buffer.from(midtransCfg.serverKey + ":").toString("base64");
        try {
            console.log(`[checkPaymentStatus] Inquiring Midtrans API for ${invoiceNumber}...`);
            const response = await axios_1.default.get(statusUrl, {
                headers: {
                    "Authorization": authHeader,
                    "Accept": "application/json",
                },
                timeout: 10000,
            });
            const mData = response.data || {};
            const trxStatus = mData.transaction_status || "";
            const fraudStatus = mData.fraud_status || "";
            const isSuccess = trxStatus === "settlement" ||
                (trxStatus === "capture" && fraudStatus === "accept");
            if (isSuccess) {
                console.log(`[checkPaymentStatus] Midtrans Inquiry verified SUCCESS for ${invoiceNumber}! Activating subscription...`);
                const actResult = await processSuccessfulPayment(invoiceNumber, mData.gross_amount, { transactionId: mData.transaction_id, orderId: mData.order_id, currency: mData.currency });
                return {
                    success: true,
                    status: "SUCCESS",
                    message: "Pembayaran terverifikasi. Akses Anda sudah aktif.",
                    details: actResult,
                };
            }
            else if (["refund", "partial_refund", "chargeback", "partial_chargeback"].includes(trxStatus)) {
                await applyMidtransRefund(invoiceNumber, mData);
                return { success: false, status: trxStatus.toUpperCase(), message: trxStatus.startsWith("partial")
                        ? "Pengembalian sebagian tercatat. Hak akses sedang ditinjau."
                        : "Pembayaran dikembalikan. Hak akses dari transaksi ini dihentikan." };
            }
            else if (trxStatus === "cancel" || trxStatus === "expire" || trxStatus === "deny") {
                return {
                    success: false,
                    status: trxStatus.toUpperCase(),
                    message: `Pembayaran ${trxStatus}.`,
                };
            }
            else {
                return {
                    success: false,
                    status: trxStatus ? trxStatus.toUpperCase() : "PENDING",
                    message: "Pembayaran masih menunggu penyelesaian.",
                };
            }
        }
        catch (err) {
            console.error("[checkPaymentStatus] Error checking Midtrans status:", ((_a = err.response) === null || _a === void 0 ? void 0 : _a.data) || err.message);
            return {
                success: false,
                status: "PENDING",
                message: "Status pembayaran belum dapat diperiksa. Silakan coba lagi.",
            };
        }
    }
    else {
        // Fallback untuk transaksi warisan DOKU
        const dokuCfg = getDokuConfig();
        const targetPath = `/orders/v1/status/${invoiceNumber}`;
        const requestId = `REQ-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
        const timestamp = new Date().toISOString().slice(0, 19) + "Z";
        const signature = generateDokuGetSignature(dokuCfg.clientId, requestId, timestamp, targetPath, dokuCfg.secretKey);
        try {
            console.log(`[checkPaymentStatus] Inquiring DOKU API for ${invoiceNumber}...`);
            const response = await axios_1.default.get(`${dokuCfg.baseUrl}${targetPath}`, {
                headers: {
                    "Client-Id": dokuCfg.clientId,
                    "Request-Id": requestId,
                    "Request-Timestamp": timestamp,
                    "Signature": signature,
                },
                timeout: 10000,
            });
            const dokuData = response.data || {};
            const trxStatus = ((_b = dokuData.transaction) === null || _b === void 0 ? void 0 : _b.status) || "";
            if (trxStatus === "SUCCESS") {
                console.log(`[checkPaymentStatus] DOKU Inquiry verified SUCCESS for ${invoiceNumber}! Activating subscription...`);
                const actResult = await processSuccessfulPayment(invoiceNumber, (_c = dokuData.order) === null || _c === void 0 ? void 0 : _c.amount);
                return {
                    success: true,
                    status: "SUCCESS",
                    message: "Pembayaran terverifikasi. Akses Anda sudah aktif.",
                    details: actResult
                };
            }
            else {
                return {
                    success: false,
                    status: trxStatus || "PENDING",
                    message: "Pembayaran masih menunggu penyelesaian."
                };
            }
        }
        catch (err) {
            console.error("[checkPaymentStatus] Error checking DOKU status:", ((_d = err.response) === null || _d === void 0 ? void 0 : _d.data) || err.message);
            return {
                success: false,
                status: "PENDING",
                message: "Status pembayaran belum dapat diperiksa. Silakan coba lagi.",
            };
        }
    }
});
// ================================================================
// FUNCTION 2d: redeemCode
// Menukarkan Kode Redeem Santri (Voucher Akses 7 Hari, dsb)
// Mengaktifkan entitlement berbatas waktu & trigger email sharing
// ================================================================
exports.redeemCode = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 120 })
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk menukarkan kode akses.");
    }
    if (typeof (data === null || data === void 0 ? void 0 : data.code) !== "string" || data.code.length > 256) {
        throw new functions.https.HttpsError("invalid-argument", "Format kode akses tidak valid.");
    }
    const rawCode = data.code.trim().toUpperCase().replace(/[\s-]/g, "");
    if (!/^[A-Z0-9]{1,64}$/.test(rawCode)) {
        throw new functions.https.HttpsError("invalid-argument", "Format kode akses tidak valid.");
    }
    if (!rawCode) {
        throw new functions.https.HttpsError("invalid-argument", "Kode redeem tidak boleh kosong.");
    }
    const uid = context.auth.uid;
    const rawDeviceId = typeof (data === null || data === void 0 ? void 0 : data.deviceId) === "string" ? data.deviceId.trim().toLowerCase() : "";
    const isPhysicalDevice = (data === null || data === void 0 ? void 0 : data.isPhysicalDevice) !== false;
    const deviceModel = typeof (data === null || data === void 0 ? void 0 : data.deviceModel) === "string" ? data.deviceModel.slice(0, 100) : "";
    const deviceBrand = typeof (data === null || data === void 0 ? void 0 : data.deviceBrand) === "string" ? data.deviceBrand.slice(0, 100) : "";
    // F-03 & F-05: Rate limit penukaran voucher per UID (maksimal 8 percobaan per 15 menit)
    await enforceRateLimit(`rdm_${uid}`, 8, 900, "Terlalu banyak percobaan penukaran kode redeem.");
    // Email yang belum diverifikasi tidak boleh tercatat sebagai identitas pemilik akses.
    const userEmail = context.auth.token.email_verified === true
        ? (context.auth.token.email || "").trim().toLowerCase()
        : "";
    let redeemResult = {
        entitlementKey: "fiqh_syafii",
        durationDays: 7,
        expiryIso: "",
        email: userEmail,
        name: "Peneliti",
        serviceTitle: "AI Fikih Syafi'i",
    };
    await db.runTransaction(async (transaction) => {
        var _a;
        const codeRef = db.collection("redeem_codes").doc(rawCode);
        const codeDoc = await transaction.get(codeRef);
        if (!codeDoc.exists) {
            throw new functions.https.HttpsError("not-found", "Kode redeem tidak ditemukan atau salah.");
        }
        const codeData = codeDoc.data();
        if (codeData.is_active === false) {
            throw new functions.https.HttpsError("failed-precondition", "Kode redeem ini sudah tidak aktif.");
        }
        const maxUses = codeData.max_uses || 1;
        const timesUsed = codeData.times_used || 0;
        if (timesUsed >= maxUses) {
            throw new functions.https.HttpsError("resource-exhausted", "Batas pemakaian kode redeem ini sudah tercapai.");
        }
        if (codeData.expires_at && codeData.expires_at.toDate() < new Date()) {
            throw new functions.https.HttpsError("deadline-exceeded", "Masa berlaku penukaran kode ini telah kedaluwarsa.");
        }
        // F-12: Enforce Single-Device Binding untuk kode keluarga promo / perdana
        const isSingleDeviceEnforced = codeData.one_per_device === true ||
            codeData.type === "perdana" ||
            rawCode.startsWith("PERDANA") ||
            rawCode.startsWith("TRIAL") ||
            rawCode.startsWith("WELCOME");
        const promoFamily = codeData.promo_family || (rawCode.startsWith("PERDANA") ? "perdana" : "trial_default");
        const deviceRedemptionKey = `dev_${rawDeviceId}_${promoFamily}`;
        const deviceRedemptionRef = db.collection("device_redemptions").doc(deviceRedemptionKey);
        if (isSingleDeviceEnforced) {
            if (isPhysicalDevice === false) {
                throw new functions.https.HttpsError("failed-precondition", "Kode ini hanya dapat diaktifkan melalui ponsel fisik asli.");
            }
            if (!rawDeviceId || !/^[a-f0-9]{64}$/.test(rawDeviceId)) {
                throw new functions.https.HttpsError("invalid-argument", "Identitas perangkat diperlukan untuk mengaktifkan kode ini.");
            }
            const deviceRedemptionDoc = await transaction.get(deviceRedemptionRef);
            if (deviceRedemptionDoc.exists) {
                throw new functions.https.HttpsError("already-exists", "Kode ini hanya dapat diklaim 1 kali per perangkat. Perangkat ini sudah pernah mengaktifkannya sebelumnya.");
            }
        }
        // Periksa apakah pengguna sudah pernah menukarkan kode ini
        const redemptionRef = codeRef.collection("redemptions").doc(uid);
        const redemptionDoc = await transaction.get(redemptionRef);
        if (redemptionDoc.exists) {
            throw new functions.https.HttpsError("already-exists", "Kode ini sudah pernah ditukarkan sebelumnya.");
        }
        const entitlementKey = codeData.entitlement_key || "fiqh_syafii";
        const requestedDuration = codeData.duration_days;
        const durationDays = typeof requestedDuration === "number" &&
            Number.isInteger(requestedDuration) &&
            requestedDuration >= 1 && requestedDuration <= 31
            ? requestedDuration
            : 7;
        const isTrialVoucher = codeData.is_trial === true ||
            codeData.type === "trial" ||
            codeData.type === "perdana" ||
            rawCode.startsWith("PERDANA") ||
            rawCode.startsWith("TRIAL") ||
            rawCode.startsWith("WELCOME");
        // Ambil user saat ini
        const userRef = db.collection("users").doc(uid);
        const userDoc = await transaction.get(userRef);
        const userData = userDoc.exists ? userDoc.data() : {};
        const entitlements = (userData.entitlements || {});
        const currentEnt = entitlements[entitlementKey];
        const ownedGrants = [];
        for (const id of userData.access_grant_ids || []) {
            const g = (await transaction.get(db.collection("access_grants").doc(id))).data();
            if (g)
                ownedGrants.push(g);
        }
        const ledgerWriter = ((_a = (await transaction.get(db.collection("access_control").doc("runtime"))).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2";
        const redeemedAt = new Date();
        const unbacked = unbackedLegacyScopes(entitlements, ownedGrants, entitlementKey, redeemedAt.getTime());
        if (isTrialVoucher && (currentEnt === null || currentEnt === void 0 ? void 0 : currentEnt.plan) === "trial" &&
            currentEnt.status === "active" && currentEnt.expiry) {
            const currentTrialExpiry = currentEnt.expiry.toDate
                ? currentEnt.expiry.toDate()
                : new Date(currentEnt.expiry);
            if (currentTrialExpiry > redeemedAt && codeData.allow_trial_extension !== true) {
                throw new functions.https.HttpsError("failed-precondition", "Masa coba untuk akses ini masih aktif. Kode trial baru dapat digunakan setelah berakhir.");
            }
        }
        // Trial selalu dihitung dari saat voucher diklaim. Perpanjangan hanya
        // berlaku pada akses berbayar atau voucher yang diberi izin eksplisit.
        let baseDate = redeemedAt;
        if ((!isTrialVoucher || codeData.allow_trial_extension === true) &&
            currentEnt && currentEnt.expiry && currentEnt.status === "active") {
            const curExp = currentEnt.expiry.toDate ? currentEnt.expiry.toDate() : new Date(currentEnt.expiry);
            if (curExp > baseDate) {
                baseDate = curExp;
            }
        }
        const newExpiry = new Date(baseDate.getTime() + durationDays * 24 * 60 * 60 * 1000);
        const voucherGrantId = (0, access_control_1.keyOf)("voucher", rawCode, uid);
        transaction.set(db.collection("access_grants").doc(voucherGrantId), {
            uid, scope: entitlementKey, kind: "voucher", status: "active", redemption_code: rawCode,
            starts_ms: redeemedAt.getTime(), expires_ms: newExpiry.getTime(), created_ms: redeemedAt.getTime(),
        });
        // 1. Simpan catatan penukaran
        transaction.set(redemptionRef, {
            uid,
            email: userEmail,
            device_id: rawDeviceId || null,
            redeemed_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        if (isSingleDeviceEnforced && rawDeviceId) {
            transaction.set(deviceRedemptionRef, {
                device_id: rawDeviceId,
                promo_family: promoFamily,
                code: rawCode,
                uid,
                email: userEmail,
                brand: deviceBrand,
                model: deviceModel,
                redeemed_at: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        // 2. Increment pemakaian kode
        transaction.update(codeRef, {
            times_used: timesUsed + 1,
        });
        // 3. Update profil dan entitlement pengguna (F01: isolasi per modul)
        const updatedEntitlements = Object.assign(Object.assign({}, entitlements), { [entitlementKey]: {
                plan: isTrialVoucher ? "trial" : "voucher_access",
                status: "active",
                source: "redeem_code",
                code_id: rawCode.slice(0, 4) + "****", // Redaksi di entitlement
                expiry: admin.firestore.Timestamp.fromDate(newExpiry),
                started_at: admin.firestore.Timestamp.fromDate(redeemedAt),
                trial_duration_days: isTrialVoucher ? durationDays : null,
                payment_status: "none",
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            } });
        const userUpdate = {
            entitlements: updatedEntitlements,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
            access_due_ms: Date.now(),
            access_grant_ids: [...new Set([...(userData.access_grant_ids || []), voucherGrantId])],
        };
        if (ledgerWriter) {
            userUpdate.access_version = 2;
            if (unbacked.length) {
                userUpdate.access_revocation_hold = true;
                userUpdate.access_legacy_audit_required = true;
            }
        }
        // Hanya set plan global jika voucher adalah all_access
        if (entitlementKey === "all_access") {
            userUpdate.plan = isTrialVoucher ? "trial" : "voucher_access";
            userUpdate.subscription_expiry = admin.firestore.Timestamp.fromDate(newExpiry);
        }
        if (!userData.email && userEmail) {
            userUpdate.email = userEmail;
        }
        transaction.set(userRef, userUpdate, { merge: true });
        // F10: Rekam outbox job untuk provisioning NotebookLM
        const outboxRef = db.collection("provisioning_outbox").doc(`redeem_${rawCode}_${uid}`);
        transaction.set(outboxRef, {
            type: "redeem",
            uid,
            email: userEmail || userData.email || "",
            name: userData.name || "Peneliti",
            entitlement_key: entitlementKey,
            plan: isTrialVoucher ? "trial" : "voucher_access",
            action: "add",
            status: "pending",
            attempts: 0,
            created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        redeemResult = {
            entitlementKey,
            durationDays,
            expiryIso: newExpiry.toISOString(),
            email: userEmail || userData.email || "",
            name: userData.name || "Peneliti",
            serviceTitle: getServiceTitleForEntitlement(entitlementKey),
        };
    });
    // F63: Redaksi log kode voucher mentah
    console.log(`[Redeem] Voucher berhasil ditukarkan oleh ${uid}. Modul: ${redeemResult.entitlementKey}, aktif s/d ${redeemResult.expiryIso}`);
    // OT-F025: Redaksi kode voucher di Telegram agar tidak mengekspos rahasia
    const maskedCode = rawCode.length > 6
        ? `${rawCode.substring(0, 3)}***${rawCode.substring(rawCode.length - 2)}`
        : "***";
    // 1. Kirim notifikasi Telegram seketika ke admin
    const tgMessage = `🔔 <b>[VOUCHER SANTRI DIKLAIM]</b>\n` +
        `🕌 OpenTurath AI\n` +
        `🎟️ Kode: <b>${maskedCode}</b>\n` +
        `📧 Email: <code>${esc(redeemResult.email)}</code>\n` +
        `👤 Nama: <b>${esc(redeemResult.name)}</b>\n` +
        `📦 Produk: <b>${esc(redeemResult.serviceTitle)}</b>\n` +
        `🏷️ Durasi: <b>${redeemResult.durationDays} Hari</b>\n` +
        `⏳ Berlaku s/d: <code>${redeemResult.expiryIso}</code>\n` +
        `✅ Status: Sukses terdaftar & hak akses aktif.`;
    await sendTelegramNotification(tgMessage);
    // OT-F003: Auto-provisioning dialihkan sepenuhnya ke durable outbox worker (processProvisioningOutbox)
    // untuk mencegah race condition double-dispatch ke Cloud Run.
    return {
        success: true,
        entitlementKey: redeemResult.entitlementKey,
        durationDays: redeemResult.durationDays,
        expiry: redeemResult.expiryIso,
        message: `Kode diterima. Akses ke ${redeemResult.serviceTitle} sudah aktif.`,
    };
});
// ================================================================
// FUNCTION 3.5: onUserCreate
// Dipanggil otomatis saat user pertama kali register di app
// Menghubungkan transaksi sukses sebelumnya berdasarkan email
// ================================================================
exports.onUserCreate = functions.firestore
    .document("users/{uid}")
    .onCreate(async (snapshot, context) => {
    var _a;
    const uid = context.params.uid;
    const user = await admin.auth().getUser(uid);
    if (!user.emailVerified || !user.email)
        return null;
    // Only verified email users may claim historical transactions.
    const emailLower = user.email.toLowerCase().trim();
    if (((_a = (await db.collection("access_control").doc("runtime").get()).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2") {
        await snapshot.ref.update({ access_due_ms: Date.now() });
        await db.collection("provisioning_outbox").doc(`v2_signup_${uid}`).set({ uid, email: user.email,
            action: "reconcile", status: "pending", created_at: admin.firestore.FieldValue.serverTimestamp() });
        return null;
    }
    const [ownedByUid, ownedByEmail] = await Promise.all([
        db.collection("transactions").where("uid", "==", uid).where("status", "in", ["success", "paid"]).get(),
        db.collection("transactions").where("customer_email", "==", emailLower).where("status", "in", ["success", "paid"]).get(),
    ]);
    const allDocsMap = new Map();
    for (const doc of ownedByUid.docs)
        allDocsMap.set(doc.id, doc);
    for (const doc of ownedByEmail.docs)
        allDocsMap.set(doc.id, doc);
    if (allDocsMap.size === 0)
        return null;
    await db.runTransaction(async (t) => {
        const current = await t.get(snapshot.ref);
        if (!current.exists)
            return;
        const profile = current.data();
        if (Object.keys(profile.entitlements || {}).length > 0)
            return;
        const entitlements = {};
        const txs = [];
        for (const doc of allDocsMap.values())
            txs.push(await t.get(doc.ref));
        for (const tx of txs) {
            const data = tx.data();
            if (!data || !["paid", "success"].includes(data.status))
                continue;
            // Verified email never overrides an existing transaction owner.
            if (data.uid && data.uid !== uid)
                continue;
            const keys = Array.isArray(data.entitlement_keys) && data.entitlement_keys.length
                ? data.entitlement_keys : [data.entitlement_key];
            const expiry = data.subscription_expires_at;
            if (!(expiry === null || expiry === void 0 ? void 0 : expiry.toDate) || expiry.toDate() <= new Date())
                continue;
            // Zero-amount records never restore access without admin verification.
            if (!(Number(data.amount) > 0) && data.admin_verified !== true && data.admin_approved !== true)
                continue;
            for (const key of keys) {
                if (typeof key !== "string" || !key)
                    continue;
                if (!entitlements[key] || expiry.toMillis() > entitlements[key].expiry.toMillis()) {
                    entitlements[key] = { plan: data.plan || "premium", status: "active", expiry, source: data.source || "goakal" };
                }
            }
            // Link uid if not linked
            if (!data.uid) {
                t.update(tx.ref, { uid, updated_at: admin.firestore.FieldValue.serverTimestamp() });
            }
        }
        if (!Object.keys(entitlements).length)
            return;
        t.update(snapshot.ref, { entitlements, updated_at: admin.firestore.FieldValue.serverTimestamp() });
        for (const key of Object.keys(entitlements).filter(k => access_catalog_1.PROVISIONABLE_SCOPES.includes(k))) {
            t.set(db.collection("provisioning_outbox").doc(`restore_${uid}_${key}`), {
                uid, email: user.email, entitlement_key: key, action: "add", status: "pending", attempts: 0,
                created_at: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
    });
    return null;
});
// ================================================================
// FUNCTION 4: dailyRevoke (Cron Job — tiap tengah malam)
// ================================================================
exports.dailyRevoke = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
    .pubsub.schedule("every 1 hours")
    .onRun(async () => {
    var _a, _b, _c, _d, _e, _f, _g;
    if (((_a = (await db.collection("access_control").doc("runtime").get()).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2")
        return null;
    const revokedSummary = [];
    let cursor;
    while (true) {
        let query = db.collection("users").orderBy(admin.firestore.FieldPath.documentId()).limit(100);
        if (cursor)
            query = query.startAfter(cursor);
        const page = await query.get();
        if (page.empty)
            break;
        for (const doc of page.docs) {
            await db.runTransaction(async (t) => {
                var _a, _b, _c, _d, _e;
                const snap = await t.get(doc.ref);
                if (!snap.exists)
                    return;
                const data = snap.data();
                // PROTEKSI VIP PERMANEN: Kebal terhadap segala pencabutan akses otomatis
                const userEmail = (data.email || "").toLowerCase().trim();
                if ((0, access_control_1.isVip)(data))
                    return;
                const entitlements = Object.assign({}, (data.entitlements || {}));
                const expired = [];
                for (const [key, value] of Object.entries(entitlements)) {
                    const ent = value;
                    const expiry = ((_a = ent === null || ent === void 0 ? void 0 : ent.expiry) === null || _a === void 0 ? void 0 : _a.toDate) ? ent.expiry.toDate() : new Date((_c = (_b = ent === null || ent === void 0 ? void 0 : ent.expiry) !== null && _b !== void 0 ? _b : ent === null || ent === void 0 ? void 0 : ent.expires_at) !== null && _c !== void 0 ? _c : "");
                    if (expiry && !isNaN(expiry.getTime()) && expiry <= new Date() && (ent === null || ent === void 0 ? void 0 : ent.status) !== "expired") {
                        entitlements[key] = Object.assign(Object.assign({}, ent), { status: "expired" });
                        expired.push(key);
                    }
                }
                const legacyExpiry = ((_d = data.subscription_expiry) === null || _d === void 0 ? void 0 : _d.toDate)
                    ? data.subscription_expiry.toDate() : new Date((_e = data.subscription_expiry) !== null && _e !== void 0 ? _e : "");
                const legacyExpired = ["all_access", "all_ai_1m", "all_ai_6m", "all_ai_1y", "full"].includes(data.plan)
                    && legacyExpiry <= new Date();
                if (!expired.length && !legacyExpired)
                    return;
                const update = { entitlements, updated_at: admin.firestore.FieldValue.serverTimestamp() };
                if (legacyExpired) {
                    update.plan = "trial";
                    update.subscription_expiry = null;
                    expired.push("all_access");
                }
                t.update(doc.ref, update);
                for (const key of new Set(expired)) {
                    revokedSummary.push({
                        email: userEmail || data.email || doc.id,
                        scope: getServiceTitleForEntitlement(key),
                        reason: "Masa aktif user habis",
                    });
                    t.set(db.collection("provisioning_outbox").doc(`reconcile_${doc.id}_${key}_${crypto.randomUUID()}`), {
                        uid: doc.id, email: data.email || "", entitlement_key: key,
                        action: "remove", status: "pending", attempts: 0,
                        created_at: admin.firestore.FieldValue.serverTimestamp(),
                    });
                }
            });
        }
        cursor = page.docs[page.docs.length - 1];
    }
    // PHASE 2: Reconcile transactions collection (Akal, Midtrans, Manual Overrides)
    const now = new Date();
    const txSnap = await db.collection("transactions")
        .where("status", "in", ["success", "paid", "settled", "SUCCESS", "PAID", "SETTLED"])
        .get();
    const activeEmailsByEntitlement = new Map();
    for (const key of access_catalog_1.PROVISIONABLE_SCOPES) {
        activeEmailsByEntitlement.set(key, new Set());
    }
    // The owning profile, not only the transaction row, decides VIP status and
    // whether another grant (voucher, renewal, other gateway) keeps a module active.
    const ownerCache = new Map();
    const ownerOf = async (uid, email) => {
        const cacheKey = typeof uid === "string" && uid ? `uid:${uid}` : `email:${email}`;
        if (ownerCache.has(cacheKey))
            return ownerCache.get(cacheKey);
        let owner = null;
        if (typeof uid === "string" && uid && !uid.includes("@"))
            owner = (await db.collection("users").doc(uid).get()).data() || null;
        if (!owner) {
            const byEmail = await db.collection("users").where("email", "==", email).limit(1).get();
            owner = byEmail.empty ? null : byEmail.docs[0].data();
        }
        ownerCache.set(cacheKey, owner);
        return owner;
    };
    const allActiveEmails = new Set();
    for (const doc of txSnap.docs) {
        const d = doc.data();
        const email = (d.customer_email || d.payer_email || d.email || "").trim().toLowerCase();
        if (!email)
            continue;
        const status = String(d.status || "").toLowerCase();
        if (!["success", "paid", "settled"].includes(status))
            continue;
        const rawExp = d.subscription_expires_at || d.access_expires_at || d.expires_at;
        let expDate = null;
        if (rawExp === null || rawExp === void 0 ? void 0 : rawExp.toDate)
            expDate = rawExp.toDate();
        else if (typeof rawExp === "string") {
            const parsed = new Date(rawExp);
            if (!isNaN(parsed.getTime()))
                expDate = parsed;
        }
        const plan = String(d.plan || d.plan_id || "").toLowerCase();
        const txVip = d.is_vip === true || plan.includes("vip") || (expDate && expDate.getFullYear() >= 2030);
        if (txVip || (0, access_control_1.isVip)({ email }))
            continue;
        const entKey = d.entitlement_key;
        const isGlobalPlan = entKey === "all_access" || entKey === "all_ai" ||
            (!entKey && /all_ai|all_access|full|sultan/.test(plan));
        if (expDate && expDate > now) {
            if (isGlobalPlan) {
                allActiveEmails.add(email);
                for (const k of access_catalog_1.PROVISIONABLE_SCOPES) {
                    (_b = activeEmailsByEntitlement.get(k)) === null || _b === void 0 ? void 0 : _b.add(email);
                }
            }
            else if (entKey && activeEmailsByEntitlement.has(entKey)) {
                (_c = activeEmailsByEntitlement.get(entKey)) === null || _c === void 0 ? void 0 : _c.add(email);
            }
            else if (!entKey) {
                if (plan.includes("tahawwulat")) {
                    (_d = activeEmailsByEntitlement.get("fiqh_tahawwulat")) === null || _d === void 0 ? void 0 : _d.add(email);
                }
                else if (plan.includes("syafi") || plan.includes("tholib")) {
                    (_e = activeEmailsByEntitlement.get("fiqh_syafii")) === null || _e === void 0 ? void 0 : _e.add(email);
                }
                else if (plan.includes("nahwu") || plan.includes("bahasa arab")) {
                    (_f = activeEmailsByEntitlement.get("nahwu")) === null || _f === void 0 ? void 0 : _f.add(email);
                }
            }
        }
    }
    for (const doc of txSnap.docs) {
        const d = doc.data();
        const email = (d.customer_email || d.payer_email || d.email || "").trim().toLowerCase();
        if (!email)
            continue;
        if ((0, access_control_1.isVip)({ email }) || d.is_vip === true)
            continue;
        const status = String(d.status || "").toLowerCase();
        if (!["success", "paid", "settled"].includes(status))
            continue;
        const rawExp = d.subscription_expires_at || d.access_expires_at || d.expires_at;
        let expDate = null;
        if (rawExp === null || rawExp === void 0 ? void 0 : rawExp.toDate)
            expDate = rawExp.toDate();
        else if (typeof rawExp === "string") {
            const parsed = new Date(rawExp);
            if (!isNaN(parsed.getTime()))
                expDate = parsed;
        }
        if (expDate && expDate <= now) {
            const entKey = d.entitlement_key;
            const owner = await ownerOf(d.uid, email);
            const registered = await db.collection("access_vip_registry").doc((0, access_control_1.keyOf)(email)).get();
            if (registered.exists || (owner && (0, access_control_1.isVip)(Object.assign(Object.assign({}, owner), { email: owner.email || email }))))
                continue;
            const targetKeys = (entKey && access_catalog_1.PROVISIONABLE_SCOPES.includes(entKey))
                ? [entKey]
                : (String(d.plan || "").toLowerCase().includes("tholib") ? ["fiqh_tahawwulat", "fiqh_syafii"] : access_catalog_1.PROVISIONABLE_SCOPES);
            const expiredKeysToRevoke = [];
            for (const k of targetKeys) {
                if (allActiveEmails.has(email) || ((_g = activeEmailsByEntitlement.get(k)) === null || _g === void 0 ? void 0 : _g.has(email)))
                    continue;
                // Independent per-module evaluation: a still-active entitlement for
                // this module survives the expiry of an older or unrelated transaction.
                if (owner && getEntitlementAccess(owner, k).active)
                    continue;
                expiredKeysToRevoke.push(k);
            }
            await doc.ref.update({
                status: "EXPIRED",
                revoked_at: admin.firestore.FieldValue.serverTimestamp(),
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            });
            for (const k of expiredKeysToRevoke) {
                revokedSummary.push({
                    email,
                    scope: getServiceTitleForEntitlement(k),
                    reason: `Transaksi ${d.plan || "tholib"} kedaluwarsa`,
                });
                const outboxId = `tx_revoke_${doc.id}_${k}_${crypto.randomUUID()}`;
                await db.collection("provisioning_outbox").doc(outboxId).set({
                    uid: d.uid || email,
                    email: email,
                    name: d.customer_name || d.payer_name || "",
                    entitlement_key: k,
                    action: "remove",
                    status: "pending",
                    attempts: 0,
                    source: "dailyRevoke_transactions",
                    created_at: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        }
    }
    if (revokedSummary.length > 0) {
        const lines = [
            `⚠️ <b>[PENCABUTAN AKSES OTOMATIS]</b>`,
            `🕌 <b>OpenTurath AI Engine (Cloud Functions)</b>\n`,
            `Sistem mendeteksi <b>${revokedSummary.length} akses kedaluwarsa</b> dan mencabut hak aksesnya:`,
        ];
        for (const r of revokedSummary.slice(0, 15)) {
            lines.push(`• 👤 <code>${esc(r.email)}</code> — <b>${esc(r.scope)}</b> (<i>${esc(r.reason)}</i>)`);
        }
        if (revokedSummary.length > 15) {
            lines.push(`• <i>... dan ${revokedSummary.length - 15} akses kedaluwarsa lainnya.</i>`);
        }
        await sendTelegramNotification(lines.join("\n"));
    }
    return null;
});
// ================================================================
// FUNCTION 4b: processProvisioningOutbox (Cron Worker — tiap 5 menit)
// Memproses antrean durable outbox provisioning & revocation NotebookLM
// ================================================================
function entitlementRevision(data) {
    return JSON.stringify([data === null || data === void 0 ? void 0 : data.plan, data === null || data === void 0 ? void 0 : data.subscription_expiry, data === null || data === void 0 ? void 0 : data.entitlements]);
}
exports.processProvisioningOutbox = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
    .pubsub.schedule("every 5 minutes")
    .onRun(async () => {
    var _a;
    if (((_a = (await db.collection("access_control").doc("runtime").get()).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2")
        return null;
    const started = Date.now();
    const pending = await db.collection("provisioning_outbox")
        .where("status", "in", ["pending", "retry", "processing"]).limit(25).get();
    for (const candidate of pending.docs) {
        if (Date.now() - started > 210000)
            break;
        const token = crypto.randomUUID();
        const candidateData = candidate.data();
        const uid = candidateData.uid || candidateData.email;
        if (typeof uid !== "string" || !uid) {
            await candidate.ref.update({ status: "failed", error: "Missing owner UID or email" });
            continue;
        }
        const lease = db.collection("provisioning_leases").doc(uid);
        const job = await db.runTransaction(async (t) => {
            var _a, _b, _c;
            const snap = await t.get(candidate.ref);
            const lock = await t.get(lease);
            const data = snap.data();
            if (!data || !["pending", "retry", "processing"].includes(data.status))
                return null;
            if ((((_c = (_b = (_a = lock.data()) === null || _a === void 0 ? void 0 : _a.until) === null || _b === void 0 ? void 0 : _b.toMillis) === null || _c === void 0 ? void 0 : _c.call(_b)) || 0) > Date.now())
                return null;
            if ((data.attempts || 0) >= 8) {
                t.update(candidate.ref, { status: "failed", error: "Exceeded retry limit" });
                return null;
            }
            t.set(lease, { token, until: admin.firestore.Timestamp.fromMillis(Date.now() + 330000) });
            t.update(candidate.ref, { status: "processing", attempts: (data.attempts || 0) + 1, lease_token: token });
            return data;
        });
        if (!job)
            continue;
        let status = "completed";
        let error = "";
        try {
            const userDoc = candidateData.uid && !candidateData.uid.includes("@")
                ? await db.collection("users").doc(candidateData.uid).get()
                : null;
            const data = userDoc && userDoc.exists ? userDoc.data() : null;
            const email = ((data === null || data === void 0 ? void 0 : data.email) || job.email || (uid.includes("@") ? uid : "")).trim().toLowerCase();
            if (!email.includes("@"))
                throw new Error("Invalid provisioning email");
            const scope = job.entitlement_key;
            const keys = scope === "all_access" || scope === "all_ai" ? access_catalog_1.PROVISIONABLE_SCOPES : [scope];
            const protectedOwner = (0, access_control_1.isVip)(Object.assign(Object.assign({}, (data || {})), { email })) ||
                (await db.collection("access_vip_registry").doc((0, access_control_1.keyOf)(email)).get()).exists;
            for (const key of keys) {
                if (!access_catalog_1.PROVISIONABLE_SCOPES.includes(key))
                    throw new Error("Unsupported provisioning scope");
                // A queued "add" is re-checked against the current profile so a job
                // delayed past expiry cannot hand access back.
                const entitled = Boolean(data && getEntitlementAccess(data, key).active);
                const desired = protectedOwner || (job.action === "add" ? (data ? entitled : true) : entitled);
                await notifySubscriptionServer(email, (data === null || data === void 0 ? void 0 : data.name) || job.name || "Peneliti", desired ? "premium" : "trial", desired ? "add" : "remove", getServiceTitleForEntitlement(key), key);
            }
            if (job.action === "remove") {
                await sendTelegramNotification(`🗑️ <b>[DEPROVISIONING NOTEBOOKLM SELESAI]</b>\n` +
                    `🕌 OpenTurath AI Server\n` +
                    `👤 Email: <code>${esc(email)}</code>\n` +
                    `📦 Produk: <b>${esc(getServiceTitleForEntitlement(job.entitlement_key))}</b>\n` +
                    `✅ Hak akses telah resmi dicabut dari sistem NotebookLM.`);
            }
            if (data && candidateData.uid && job.action !== "remove") {
                const after = await db.collection("users").doc(candidateData.uid).get();
                if (entitlementRevision(data) !== entitlementRevision(after.data())) {
                    status = "retry";
                    error = "Entitlements changed during delivery";
                }
            }
        }
        catch (err) {
            status = "retry";
            error = String(err.message || "Provisioning failure").slice(0, 300);
        }
        await db.runTransaction(async (t) => {
            var _a, _b;
            const lock = await t.get(lease);
            const snap = await t.get(candidate.ref);
            if (((_a = lock.data()) === null || _a === void 0 ? void 0 : _a.token) !== token || ((_b = snap.data()) === null || _b === void 0 ? void 0 : _b.lease_token) !== token)
                return;
            t.update(candidate.ref, { status, last_error: error, last_attempt_at: admin.firestore.FieldValue.serverTimestamp() });
            t.delete(lease);
        });
    }
    return null;
});
// ================================================================
// FUNCTION 4b-instant: onProvisioningOutboxCreated (Firestore Trigger — < 1s)
// Mengaktifkan sharing NotebookLM seketika saat order/voucher dibuat
// ================================================================
exports.onProvisioningOutboxCreated = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 120 })
    .firestore.document("provisioning_outbox/{jobId}")
    .onCreate(async (snap, context) => {
    var _a;
    if (((_a = (await db.collection("access_control").doc("runtime").get()).data()) === null || _a === void 0 ? void 0 : _a.writer) === "vps-v2")
        return null;
    const candidateData = snap.data();
    if (!candidateData || !["pending", "retry"].includes(candidateData.status))
        return null;
    const uid = candidateData.uid || candidateData.email;
    if (typeof uid !== "string" || !uid)
        return null;
    const token = crypto.randomUUID();
    const lease = db.collection("provisioning_leases").doc(uid);
    const job = await db.runTransaction(async (t) => {
        var _a, _b, _c;
        const currentSnap = await t.get(snap.ref);
        const lock = await t.get(lease);
        const data = currentSnap.data();
        if (!data || !["pending", "retry"].includes(data.status))
            return null;
        if ((((_c = (_b = (_a = lock.data()) === null || _a === void 0 ? void 0 : _a.until) === null || _b === void 0 ? void 0 : _b.toMillis) === null || _c === void 0 ? void 0 : _c.call(_b)) || 0) > Date.now())
            return null;
        if ((data.attempts || 0) >= 8)
            return null;
        t.set(lease, { token, until: admin.firestore.Timestamp.fromMillis(Date.now() + 330000) });
        t.update(snap.ref, { status: "processing", attempts: (data.attempts || 0) + 1, lease_token: token });
        return data;
    });
    if (!job)
        return null;
    let status = "completed";
    let error = "";
    try {
        const userDoc = candidateData.uid && !candidateData.uid.includes("@")
            ? await db.collection("users").doc(candidateData.uid).get()
            : null;
        const data = userDoc && userDoc.exists ? userDoc.data() : null;
        const email = ((data === null || data === void 0 ? void 0 : data.email) || job.email || (uid.includes("@") ? uid : "")).trim().toLowerCase();
        if (!email.includes("@"))
            throw new Error("Invalid provisioning email");
        const scope = job.entitlement_key;
        const keys = scope === "all_access" || scope === "all_ai" ? access_catalog_1.PROVISIONABLE_SCOPES : [scope];
        const protectedOwner = (0, access_control_1.isVip)(Object.assign(Object.assign({}, (data || {})), { email })) ||
            (await db.collection("access_vip_registry").doc((0, access_control_1.keyOf)(email)).get()).exists;
        for (const key of keys) {
            if (!access_catalog_1.PROVISIONABLE_SCOPES.includes(key))
                throw new Error("Unsupported provisioning scope");
            const entitled = Boolean(data && getEntitlementAccess(data, key).active);
            const desired = protectedOwner || (job.action === "add" ? (data ? entitled : true) : entitled);
            await notifySubscriptionServer(email, (data === null || data === void 0 ? void 0 : data.name) || job.name || "Peneliti", desired ? "premium" : "trial", desired ? "add" : "remove", getServiceTitleForEntitlement(key), key);
        }
        if (job.action === "remove") {
            await sendTelegramNotification(`🗑️ <b>[DEPROVISIONING NOTEBOOKLM SELESAI]</b>\n` +
                `🕌 OpenTurath AI Server\n` +
                `👤 Email: <code>${esc(email)}</code>\n` +
                `📦 Produk: <b>${esc(getServiceTitleForEntitlement(job.entitlement_key))}</b>\n` +
                `✅ Hak akses telah resmi dicabut dari sistem NotebookLM.`);
        }
        if (data && candidateData.uid && job.action !== "remove") {
            const after = await db.collection("users").doc(candidateData.uid).get();
            if (entitlementRevision(data) !== entitlementRevision(after.data())) {
                status = "retry";
                error = "Entitlements changed during delivery";
            }
        }
    }
    catch (err) {
        status = "retry";
        error = String(err.message || "Provisioning failure").slice(0, 300);
    }
    await db.runTransaction(async (t) => {
        var _a, _b;
        const lock = await t.get(lease);
        const currentSnap = await t.get(snap.ref);
        if (((_a = lock.data()) === null || _a === void 0 ? void 0 : _a.token) !== token || ((_b = currentSnap.data()) === null || _b === void 0 ? void 0 : _b.lease_token) !== token)
            return;
        t.update(snap.ref, { status, last_error: error, last_attempt_at: admin.firestore.FieldValue.serverTimestamp() });
        t.delete(lease);
    });
    return null;
});
// ================================================================
// FUNCTION 4c: cleanupOrphanedDeletions (Cron Harian — jam 03.00 WIB)
// Membersihkan dokumen user yang bertanda pending_deletion jika akun Auth sudah terhapus
// ================================================================
async function deleteUserData(uid, authEmail = "") {
    const ref = db.collection("users").doc(uid);
    let targetEmail = authEmail;
    await db.runTransaction(async (t) => {
        var _a;
        const user = await t.get(ref);
        const email = authEmail || ((_a = user.data()) === null || _a === void 0 ? void 0 : _a.email) || "";
        targetEmail = email;
        const jobs = [];
        for (const key of access_catalog_1.PROVISIONABLE_SCOPES) {
            const job = db.collection("provisioning_outbox").doc(`delete_${uid}_${key}`);
            jobs.push({ ref: job, snap: await t.get(job), key });
        }
        if (user.exists)
            t.update(ref, { account_deleted: true });
        for (const job of jobs) {
            if (job.snap.exists)
                continue;
            t.set(job.ref, { uid, email, entitlement_key: job.key, action: "remove", status: "pending", attempts: 0,
                created_at: admin.firestore.FieldValue.serverTimestamp() });
        }
    });
    await db.recursiveDelete(ref);
    // Records outside the profile keep only what billing and abuse prevention
    // need: device bindings go, and contact details leave payment/ledger rows.
    const [devices, payments, grants] = await Promise.all([
        db.collection("device_redemptions").where("uid", "==", uid).get(),
        db.collection("transactions").where("uid", "==", uid).get(),
        db.collection("access_grants").where("uid", "==", uid).get(),
    ]);
    for (const doc of devices.docs)
        await doc.ref.delete();
    for (const doc of payments.docs)
        await doc.ref.update({ customer_name: "", customer_phone: "", account_deleted: true });
    for (const doc of grants.docs)
        await doc.ref.update({ email: "", account_deleted: true });
    if (targetEmail) {
        await sendTelegramNotification(`🚫 <b>[HAPUS AKUN & CABUT AKSES]</b>\n` +
            `👤 Email: <code>${esc(targetEmail)}</code>\n` +
            `🆔 UID: <code>${esc(uid)}</code>\n` +
            `⚠️ Akun pengguna dihapus permanen. Seluruh hak akses turats dicabut.`);
    }
}
exports.onUserDeleted = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300, failurePolicy: true })
    .auth.user().onDelete(async (user) => {
    await deleteUserData(user.uid, user.email || "");
});
exports.cleanupOrphanedDeletions = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
    .pubsub.schedule("0 3 * * *").timeZone("Asia/Jakarta")
    .onRun(async () => {
    const pending = await db.collection("users").where("pending_deletion", "==", true).limit(50).get();
    for (const doc of pending.docs) {
        try {
            await admin.auth().getUser(doc.id);
        }
        catch (err) {
            if (err.code === "auth/user-not-found")
                await deleteUserData(doc.id);
            else
                throw err;
        }
    }
    return null;
});
// ================================================================
// HELPER: Notify openturath-subscription Cloud Run server
// ================================================================
async function notifySubscriptionServer(email, name, plan, action, serviceName, scopeKey) {
    const url = "https://openturath-subscription-255541559800.asia-southeast2.run.app/webhook";
    const services = serviceName
        ? [serviceName]
        : access_catalog_1.PROVISIONABLE_SCOPES.map(getServiceTitleForEntitlement);
    for (const service of services) {
        const payload = {
            event: action === "add" ? "subscription.paid" : "subscription.expired",
            data: {
                status: action === "add" ? "PAID" : "EXPIRED",
                payer: {
                    name: name,
                    email: email,
                },
                service: Object.assign({ name: service }, (scopeKey ? { key: scopeKey } : {})),
            },
        };
        try {
            const internalSecret = process.env.INTERNAL_SECRET || "";
            if (!internalSecret) {
                throw new Error("INTERNAL_SECRET is not configured");
            }
            await axios_1.default.post(url, payload, {
                headers: {
                    "Content-Type": "application/json",
                    "X-Internal-Secret": internalSecret
                },
                timeout: 60000,
                maxRedirects: 0,
            });
            console.log(`Successfully notified subscription server: ${action} ${email} for ${service}`);
        }
        catch (err) {
            console.error(`Provisioning request failed for ${service}`);
            throw err;
        }
    }
}
function getAkalApiKey() {
    var _a;
    const runtimeConfigKey = (_a = functions.config().akal) === null || _a === void 0 ? void 0 : _a.api_key;
    return process.env.AKAL_API_KEY || runtimeConfigKey || "";
}
function detectDurationMonths(priceSchemeTitle, serviceTitle) {
    return (0, access_control_1.akalDurationMonths)(priceSchemeTitle, serviceTitle);
}
function akalTransactionId(raw, fallback) {
    const id = typeof raw === "string" ? raw.trim() : "";
    return /^[A-Za-z0-9_-]{1,128}$/.test(id) ? id : `akal_${(0, access_control_1.keyOf)("akal", ...fallback).slice(0, 40)}`;
}
// Evidence that cannot be granted automatically (zero amount, missing ID,
// unknown product) is kept for the operator and never extends access.
async function quarantineAkalEvidence(evidence, reason) {
    const eventKey = (0, access_control_1.keyOf)("akal_quarantine", JSON.stringify(evidence), reason);
    await db.collection("access_legacy_events").doc(eventKey).set(Object.assign(Object.assign({}, evidence), { status: "verification_required", reason, received_at: admin.firestore.FieldValue.serverTimestamp() }), { merge: true });
}
// Idempotent per provider transaction: the period is fixed the first time the
// transaction is recorded, a replay never extends it, and an existing longer
// entitlement is never shortened. Only the purchased scopes are touched.
async function applyAkalPurchase(p) {
    const txRef = db.collection("transactions").doc(p.transactionId);
    let userRef = p.uid ? db.collection("users").doc(p.uid) : null;
    if (!userRef) {
        const matches = await db.collection("users").where("email", "==", p.email).limit(2).get();
        // Two profiles claiming one email is an identity problem, not a billing one.
        if (matches.size === 1)
            userRef = matches.docs[0].ref;
    }
    return db.runTransaction(async (t) => {
        var _a;
        const txSnap = await t.get(txRef);
        const prior = txSnap.data();
        if ((prior === null || prior === void 0 ? void 0 : prior.uid) && userRef && prior.uid !== userRef.id)
            throw new Error("GoAkal transaction belongs to another account");
        const userSnap = userRef ? await t.get(userRef) : null;
        const grantRefs = p.scopes.map(scope => db.collection("access_grants").doc((0, access_control_1.keyOf)("goakal", p.transactionId, scope)));
        const grantSnaps = [];
        for (const ref of grantRefs)
            grantSnaps.push(await t.get(ref));
        const paidMs = Number.isFinite(prior === null || prior === void 0 ? void 0 : prior.paid_ms) ? prior.paid_ms : p.paidMs;
        // A renewal paid before the previous paid period ends continues from that
        // end. Only other ledger grants count, and only when first recorded.
        let startsMs = Number.isFinite(prior === null || prior === void 0 ? void 0 : prior.starts_ms) ? prior.starts_ms : Math.max(paidMs, (_a = p.startsMs) !== null && _a !== void 0 ? _a : paidMs);
        if (!Number.isFinite(prior === null || prior === void 0 ? void 0 : prior.expires_ms) && (userSnap === null || userSnap === void 0 ? void 0 : userSnap.exists)) {
            for (const id of userSnap.data().access_grant_ids || []) {
                const g = (await t.get(db.collection("access_grants").doc(id))).data();
                if (g && g.kind === "payment" && g.status === "active" && p.scopes.includes(g.scope) &&
                    g.transaction_id !== p.transactionId && g.starts_ms <= paidMs && g.expires_ms > startsMs)
                    startsMs = g.expires_ms;
            }
        }
        const expiresMs = Number.isFinite(prior === null || prior === void 0 ? void 0 : prior.expires_ms) ? prior.expires_ms : (0, access_control_1.billingExpiry)(startsMs, p.months);
        const expiry = admin.firestore.Timestamp.fromMillis(expiresMs);
        const linked = Boolean(userRef && (userSnap === null || userSnap === void 0 ? void 0 : userSnap.exists));
        t.set(txRef, Object.assign(Object.assign({}, (linked ? { uid: userRef.id } : {})), { customer_email: p.email, customer_name: p.name, plan: p.plan, amount: p.amount, duration_months: p.months, status: "success", source: "goakal", service_name: p.serviceTitle, entitlement_key: p.scopes[0], entitlement_keys: p.scopes, paid_ms: paidMs, starts_ms: startsMs, expires_ms: expiresMs, paid_at: admin.firestore.Timestamp.fromMillis(paidMs), subscription_expires_at: expiry, synced_at: admin.firestore.FieldValue.serverTimestamp() }), { merge: true });
        if (!linked)
            return { expiresMs, linked };
        const user = userSnap.data();
        const entitlements = Object.assign({}, (user.entitlements || {}));
        const grantIds = new Set(user.access_grant_ids || []);
        p.scopes.forEach((scope, index) => {
            if (!grantSnaps[index].exists) {
                t.set(grantRefs[index], {
                    uid: userRef.id, email: p.email, scope, kind: "payment", status: "active", amount: p.amount,
                    provider: "goakal", transaction_id: p.transactionId, transaction_document: p.transactionId,
                    starts_ms: startsMs, expires_ms: expiresMs, created_ms: Date.now(),
                });
                if (access_catalog_1.PROVISIONABLE_SCOPES.includes(scope)) {
                    t.set(db.collection("provisioning_outbox").doc(`akal_${p.transactionId}_${scope}`), {
                        uid: userRef.id, email: p.email, name: user.name || p.name, entitlement_key: scope, plan: p.plan,
                        action: "add", status: "pending", attempts: 0, source: "goakal",
                        created_at: admin.firestore.FieldValue.serverTimestamp(),
                    });
                }
            }
            grantIds.add(grantRefs[index].id);
            const current = entitlements[scope];
            const currentMs = (current === null || current === void 0 ? void 0 : current.status) === "active" || (current === null || current === void 0 ? void 0 : current.status) === undefined ? (0, access_control_1.millis)(current === null || current === void 0 ? void 0 : current.expiry) : NaN;
            if (!(Number.isFinite(currentMs) && currentMs >= expiresMs)) {
                entitlements[scope] = {
                    plan: p.plan, status: "active", expiry, source: "goakal",
                    source_transaction_id: p.transactionId,
                    updated_at: admin.firestore.FieldValue.serverTimestamp(),
                };
            }
        });
        t.set(userRef, {
            entitlements,
            access_grant_ids: [...grantIds],
            access_due_ms: Date.now(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        return { expiresMs, linked };
    });
}
// ================================================================
// FUNCTION: syncAkalPurchases (Otomasi Sinkronisasi Pembelian GoAkal)
// ================================================================
exports.syncAkalPurchases = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 60 })
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk sinkronisasi.");
    }
    const uid = context.auth.uid;
    const email = (context.auth.token.email || "").toLowerCase().trim();
    // Pembelian diklaim berdasarkan email, jadi email wajib sudah diverifikasi penyedia identitas.
    if (!email || context.auth.token.email_verified !== true) {
        throw new functions.https.HttpsError("failed-precondition", "Akun Google Anda tidak memiliki alamat email yang valid.");
    }
    const apiKey = getAkalApiKey();
    if (!apiKey) {
        throw new functions.https.HttpsError("internal", "Kunci API GoAkal belum dikonfigurasi di server.");
    }
    // One sync fans out to every GoAkal service; bound it per account.
    await enforceRateLimit(`akal_sync_${uid}`, 3, 600, "Sinkronisasi baru saja dijalankan.");
    const now = Date.now();
    const deadline = now + 45000;
    const syncedServices = [];
    const ownRows = async (cuid) => {
        var _a;
        const rows = [];
        for (const status of ["PAID", "SETTLED"]) {
            for (let page = 1; page <= 4 && Date.now() < deadline; page++) {
                const apiUrl = `https://goakal.com/service/api/v1/services/${cuid}/transactions?status=${status}&pageSize=100&page=${page}`;
                let txns;
                try {
                    const response = await axios_1.default.get(apiUrl, { headers: { "X-Api-Key": apiKey }, timeout: 8000 });
                    txns = Array.isArray((_a = response.data) === null || _a === void 0 ? void 0 : _a.data) ? response.data.data : [];
                }
                catch (e) {
                    console.warn(`[syncAkalPurchases] Query failed for one service page: ${e.message}`);
                    break;
                }
                rows.push(...txns.filter(t => String((t === null || t === void 0 ? void 0 : t.payerEmail) || "").trim().toLowerCase() === email));
                if (txns.length < 100)
                    break;
            }
        }
        return rows;
    };
    const syncService = async (service) => {
        var _a;
        let applied = false;
        for (const cuid of [service.cuid, ...service.fallbacks]) {
            const rows = (await ownRows(cuid))
                .map(t => ({ t, paidMs: (0, access_control_1.millis)(t.paidAt || t.createdAt) }))
                .filter(r => Number.isFinite(r.paidMs))
                .sort((a, b) => a.paidMs - b.paidMs);
            let chainEnd = 0;
            for (const { t, paidMs } of rows) {
                const months = detectDurationMonths(t.priceSchemeTitle || "", t.serviceTitle || "");
                const rawId = typeof t.id === "string" && t.id.trim() ? t.id : t.paymentId;
                const amount = Number((_a = t.incomingAmount) !== null && _a !== void 0 ? _a : t.amount);
                const valid = typeof rawId === "string" && rawId.trim() && Number.isFinite(amount) && amount > 0;
                // The provider's invoice expiry is not the subscription period. A
                // renewal paid before the previous period ended continues from it.
                const startsMs = valid ? Math.max(paidMs, chainEnd) : paidMs;
                const expiresMs = (0, access_control_1.billingExpiry)(startsMs, months);
                if (valid)
                    chainEnd = expiresMs;
                if (expiresMs <= now)
                    continue;
                if (!valid) {
                    await quarantineAkalEvidence({
                        email, uid, service: service.name, transaction_id: typeof rawId === "string" ? rawId : "",
                        amount: Number.isFinite(amount) ? amount : null, paid_at: String(t.paidAt || t.createdAt || ""),
                    }, "invalid_billing_identity_or_amount");
                    continue;
                }
                await applyAkalPurchase({
                    uid, email, name: String(t.payerName || "Santri Peneliti").slice(0, 120),
                    transactionId: akalTransactionId(rawId, [email, service.cuid, String(paidMs)]),
                    amount, scopes: service.scopes,
                    plan: months === 12 ? "bahits_1y" : (months === 6 ? "tholib_6m" : "tholib_1m"),
                    months, paidMs, startsMs, serviceTitle: String(t.serviceTitle || service.name).slice(0, 200),
                });
                applied = true;
            }
        }
        if (applied)
            syncedServices.push(service.name);
    };
    let cursor = 0;
    const worker = async () => { while (cursor < access_catalog_1.AKAL_SERVICES.length && Date.now() < deadline)
        await syncService(access_catalog_1.AKAL_SERVICES[cursor++]); };
    await Promise.all([worker(), worker(), worker(), worker(), worker(), worker()]);
    syncedServices.sort();
    if (syncedServices.length > 0) {
        await sendTelegramNotification(`🔄 <b>[SINKRONISASI GOAKAL OTOMATIS]</b>\n` +
            `👤 Pengguna: <code>${esc(email)}</code>\n` +
            `📚 Hak Akses Aktif: <b>${esc(syncedServices.join(", "))}</b>`);
    }
    return {
        success: true,
        synced: syncedServices,
        count: syncedServices.length,
        message: syncedServices.length > 0
            ? `Alhamdulillah! Akses aktif berhasil disinkronkan: ${syncedServices.join(", ")}.`
            : "Belum ditemukan transaksi aktif di GoAkal untuk email ini. Pastikan Anda menggunakan email akun Google yang sama saat membayar di GoAkal.",
    };
});
// ================================================================
// FUNCTION: akalWebhook (Webhook Receiver HTTP dari GoAkal)
// ================================================================
exports.akalWebhook = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onRequest(async (req, res) => {
    var _a;
    if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
    }
    const payload = req.body || {};
    // Fail-closed: tanpa secret terkonfigurasi, webhook menolak semua request.
    const akalSecret = process.env.AKAL_WEBHOOK_SECRET || "";
    if (akalSecret.length < 32) {
        console.error("[Akal Webhook] AKAL_WEBHOOK_SECRET is not configured; rejecting request.");
        res.status(503).json({ error: "Webhook not configured" });
        return;
    }
    // Verifikasi token dari Akal (di dalam body JSON payload.token atau payload.data.token)
    const token = payload.token || ((_a = payload.data) === null || _a === void 0 ? void 0 : _a.token) || req.headers["x-akal-token"];
    if (typeof token !== "string" || !safeTimingEqual(token, akalSecret)) {
        console.warn("[Akal Webhook] Signature verification failed or missing token.");
        res.status(401).json({ error: "Unauthorized" });
        return;
    }
    const data = payload.data || payload;
    const status = String(data.status || "").toUpperCase().trim();
    if (!["PAID", "SETTLED"].includes(status)) {
        console.log(`[Akal Webhook] Transaction status is '${status}'. Acknowledging receipt.`);
        res.status(200).json({ received: true, status });
        return;
    }
    const payer = data.payer || data.user || {};
    const email = String(payer.email || "").trim().toLowerCase();
    const name = String(payer.name || "").trim().slice(0, 120) || "Santri Peneliti";
    const service = data.service || {};
    const serviceTitle = String(service.name || service.title || "").trim().slice(0, 200);
    const priceScheme = data.priceScheme || {};
    const priceSchemeTitle = String(priceScheme.name || priceScheme.title || "").trim();
    const rawTxnId = typeof data.id === "string" ? data.id.trim() : "";
    const amount = Number(data.amount);
    const scopes = (0, access_catalog_1.resolveAkalScopes)(serviceTitle);
    const paidMs = data.paidAt ? (0, access_control_1.millis)(data.paidAt) : Date.now();
    const evidence = { email, service: serviceTitle, transaction_id: rawTxnId, payment_status: status,
        amount: Number.isFinite(amount) ? amount : null, paid_at: String(data.paidAt || "") };
    if (!email) {
        res.status(400).json({ error: "Missing payer email" });
        return;
    }
    // Preserve invalid evidence for operator verification; never auto-extend
    // and never guess which module an unknown product should unlock.
    const reason = !rawTxnId || !Number.isFinite(amount) || amount <= 0 ? "invalid_billing_identity_or_amount"
        : !scopes.length ? "unknown_service"
            : !Number.isFinite(paidMs) ? "invalid_payment_time" : "";
    if (reason) {
        await quarantineAkalEvidence(evidence, reason);
        res.status(200).json({ received: true, verification_required: true });
        return;
    }
    const months = detectDurationMonths(priceSchemeTitle, serviceTitle);
    const plan = months === 12 ? "bahits_1y" : (months === 6 ? "tholib_6m" : "tholib_1m");
    const txnId = akalTransactionId(rawTxnId, [email, serviceTitle, priceSchemeTitle, String(data.paidAt || ""), String(amount)]);
    let result;
    try {
        result = await applyAkalPurchase({ email, name, transactionId: txnId, amount, scopes, plan, months, paidMs, serviceTitle });
    }
    catch (err) {
        console.error("[Akal Webhook] Purchase could not be applied:", err.message);
        res.status(500).json({ error: "Internal error" });
        return;
    }
    await sendTelegramNotification(`⚡ <b>[WEBHOOK GOAKAL REALTIME]</b>\n` +
        `👤 Pembeli: <code>${esc(email)}</code> (${esc(name)})\n` +
        `📦 Layanan: <b>${esc(serviceTitle)}</b>\n` +
        `⏳ Paket: ${esc(plan)} (${months} bulan)\n` +
        `🔑 Entitlement: <code>${esc(scopes.join(", "))}</code>\n` +
        `💰 Nominal: Rp ${amount.toLocaleString("id-ID")}\n` +
        `📅 Masa Aktif: s/d ${new Date(result.expiresMs).toISOString().split("T")[0]}` +
        (result.linked ? "" : `\nℹ️ Pembeli belum terdaftar di aplikasi; akses ditautkan saat ia mendaftar.`));
    res.status(200).json({ success: true, txnId, entitlementKeys: scopes });
});
// ================================================================
// TELEMETRY CLOUD FUNCTION: Forward critical errors to Telegram
// ================================================================
exports.onClientErrorLogged = functions.firestore
    .document("client_error_logs/{logId}")
    .onCreate(async (snap, ctx) => {
    const data = snap.data();
    if (!data)
        return;
    const severity = String(data.severity || "error");
    if (!["critical", "error"].includes(severity))
        return;
    // Any signed-in client can write this collection. Bound what one account
    // can push to the operator channel so payment alerts are never drowned out.
    const owner = typeof data.userId === "string" && data.userId ? data.userId : "unknown";
    try {
        await enforceRateLimit(`client_alert_${owner}`.slice(0, 200), 5, 900, "limited");
        await enforceRateLimit("client_alert_global", 30, 900, "limited");
    }
    catch (_) {
        return;
    }
    const msg = `⚠️ <b>[ALERT CLIENT ERROR]</b>\n` +
        `<b>Context:</b> ${esc(data.context || "general")}\n` +
        `<b>Severity:</b> ${esc(severity.toUpperCase())}\n` +
        `<b>Platform:</b> ${esc(data.platform || "unknown")}\n` +
        `<b>User:</b> ${esc(data.userEmail || data.userId || "anonymous")}\n` +
        `<b>Error:</b> <code>${esc(String(data.error || "Unknown Error").substring(0, 300))}</code>\n` +
        `<b>ID:</b> <code>${esc(ctx.params.logId)}</code>`;
    await sendTelegramNotification(msg);
});
//# sourceMappingURL=index.js.map