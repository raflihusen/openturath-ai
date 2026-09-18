"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onClientErrorLogged = exports.chatGate = exports.cleanupOrphanedDeletions = exports.onUserDeleted = exports.processProvisioningOutbox = exports.dailyRevoke = exports.onUserCreate = exports.redeemCode = exports.checkPaymentStatus = exports.dokuWebhook = exports.createCheckout = exports.recordQuestion = exports.getAgentUrl = exports.MODULE_PLANS = exports.PURCHASABLE_AGENTS = void 0;
exports.addCalendarMonthsClamped = addCalendarMonthsClamped;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios_1 = require("axios");
const crypto = require("crypto");
const notebook_catalog_1 = require("./notebook_catalog");
admin.initializeApp();
const db = admin.firestore();
// ================================================================
// TELEGRAM NOTIFICATION HELPER
// ================================================================
async function sendTelegramNotification(text) {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const chatId = process.env.TELEGRAM_CHAT_ID;
    if (!token || !chatId)
        return;
    try {
        await axios_1.default.post(`https://api.telegram.org/bot${token}/sendMessage`, {
            chat_id: chatId,
            text,
            parse_mode: "HTML",
        }, { timeout: 5000 });
    }
    catch (err) {
        console.error("[Telegram] Failed to send notification:", (err === null || err === void 0 ? void 0 : err.message) || err);
    }
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
const AGENT_ENTITLEMENTS = {
    // Fikih Tahawwulat (Sovereign Flagship)
    fiqh_tahawwulat: "fiqh_tahawwulat",
    fiqh_tahawwulat_muhaqqiq: "fiqh_tahawwulat",
    fiqh_tahawwulat_bayan: "fiqh_tahawwulat",
    fiqh_tahawwulat_mukhtabir: "fiqh_tahawwulat",
    fiqh_tahawwulat_habib: "fiqh_tahawwulat",
    fiqh_tahawwulat_khatib: "fiqh_tahawwulat",
    // 4 Mazhab Fikih & Muqaran
    fiqh_syafii: "fiqh_syafii",
    fiqh_syafii_muhaqqiq: "fiqh_syafii",
    fiqh_hanafi: "fiqh_hanafi",
    fiqh_hanafi_muhaqqiq: "fiqh_hanafi",
    fiqh_maliki: "fiqh_maliki",
    fiqh_maliki_muhaqqiq: "fiqh_maliki",
    fiqh_hanbali: "fiqh_hanbali",
    fiqh_hanbali_muhaqqiq: "fiqh_hanbali",
    fiqh_hambali: "fiqh_hanbali",
    fiqh_muqaran: "fiqh_muqaran",
    fiqh_muqaran_muhaqqiq: "fiqh_muqaran",
    fatawa_masail: "fiqh",
    fatawa_dan_masail: "fiqh",
    fatawa: "fiqh",
    // Kaidah & Ushul Fikih
    qawaid_fiqhiyyah: "ushul_fiqh",
    usul_qawaid: "ushul_fiqh",
    qawaid: "ushul_fiqh",
    ushul_fiqh: "ushul_fiqh",
    ushul_muhaqqiq: "ushul_fiqh",
    usul_maqashid: "ushul_fiqh",
    usul_istinbath: "ushul_fiqh",
    // Bahasa & Sastra Arab
    nahwu_sharaf: "nahwu",
    nahwu_sharaf_muerib: "nahwu",
    nahwu_sharaf_tashrif: "nahwu",
    bahasa_arab: "nahwu",
    lughah_nahwu: "nahwu",
    lughah_sharaf: "nahwu",
    lughah_balaghah: "nahwu",
    lughah_mujam: "nahwu",
    // Tafsir & Al-Qur'an
    tafsir: "tafsir",
    tafsir_muhaqqiq: "tafsir",
    tafsir_ahkam: "tafsir",
    tafsir_matsur: "tafsir",
    tafsir_ulumul_quran: "tafsir",
    tajwid_qiraat: "tafsir",
    tajwid: "tafsir",
    qiraat: "tafsir",
    // Hadits & Syarah
    hadits: "hadits",
    hadits_muhaqqiq: "hadits",
    hadits_syarah: "hadits",
    syarah_hadits: "hadits",
    hadits_takhrij: "hadits",
    hadits_ilal: "hadits",
    musthalah_hadits: "hadits",
    // Akidah & Teologi
    aqidah: "aqidah",
    aqidah_kalam: "aqidah",
    aqidah_ushuluddin: "aqidah",
    ushuluddin: "aqidah",
    // Sejarah, Sirah & Biografi
    tarikh: "tarikh",
    tarikh_khulafa: "tarikh",
    sirah: "tarikh",
    tarikh_thabaqat: "tarikh",
    thabaqat_rijal: "tarikh",
    // Tasawwuf & Ulama
    tasawwuf: "tasawwuf",
    tasawwuf_adzkar: "tasawwuf",
    tasawwuf_ihya: "tasawwuf",
    tasawwuf_adab: "tasawwuf",
    habib_umar: "tasawwuf",
    imam_ghazali: "tasawwuf",
    // Bibliografi & Faharis
    bibliografi_faharis: "all_access",
    faharis: "all_access",
    bibliografi: "all_access",
    all_ai: "all_access",
};
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
    const entitlementKey = AGENT_ENTITLEMENTS[agentId];
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
    const globalPlanPattern = /^(all_access|all_ai.*|full|sultan|tholib.*|bahits.*|premium|pro|custom|voucher.*|redeem.*)$/;
    const isGlobalPlan = typeof userData.plan === "string" && globalPlanPattern.test(userData.plan);
    if (isGlobalPlan && isGlobalExpiryValid) {
        return { premiumPlan: true, active: true };
    }
    if (userData.plan === "single") {
        return { premiumPlan: !!specific, active: false };
    }
    const legacy = ["all_access", "all_ai_1m", "all_ai_6m", "all_ai_1y", "all_ai", "full", "sultan", "tholib_1m", "tholib_6m", "bahits_1y", "tholib", "bahits", "premium", "pro", "custom"].includes(userData.plan);
    return { premiumPlan: legacy, active: legacy && isGlobalExpiryValid };
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
    const questionsUsed = userData.questions_used || 0;
    const entitlementKey = getEntitlementKey(agentId);
    const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
    if (entitlementAccess.active) {
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
function resolvePlanPricing(agentId, plan) {
    const isAllAi = agentId === "all_ai" || agentId === "all_access" || plan.startsWith("all_ai") || plan.startsWith("all_access");
    if (isAllAi) {
        throw new functions.https.HttpsError("failed-precondition", "Paket Semua AI sementara dinonaktifkan. Silakan pilih paket per modul spesialis.");
    }
    // OT-F001: Closed-set whitelist enforcement
    if (!exports.PURCHASABLE_AGENTS.has(agentId)) {
        throw new functions.https.HttpsError("invalid-argument", "Modul spesialis tidak valid atau tidak dapat dibeli.");
    }
    // Harga Mandiri Khusus Fikih Tahawwulat
    if (agentId.startsWith("fiqh_tahawwulat")) {
        const tahawwulatTiers = {
            tholib_1m: { amount: 300000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
            tholib_6m: { amount: 1500000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
            bahits_1y: { amount: 2000000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
            "1m": { amount: 300000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
            "6m": { amount: 1500000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
            "1y": { amount: 2000000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
        };
        const tTier = tahawwulatTiers[plan];
        if (tTier) {
            return {
                amount: tTier.amount,
                durationMonths: tTier.durationMonths,
                label: `AI Fikih Tahawwulat ${tTier.labelSuffix}`,
                entitlementKey: "fiqh_tahawwulat",
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
    const agentTitle = agentId.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
    return {
        amount: tier.amount,
        durationMonths: tier.durationMonths,
        label: `Modul AI ${agentTitle} ${tier.labelSuffix}`,
        entitlementKey,
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
            phone: params.customerPhone || ""
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
    var _a, _b, _c, _d, _e, _f, _g, _h;
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk melakukan transaksi.");
    }
    const { plan, name, email, phone, agentId } = data;
    if (!plan || !name || !email) {
        throw new functions.https.HttpsError("invalid-argument", "Data tidak lengkap (nama dan email diperlukan).");
    }
    const currentAgentId = typeof agentId === "string" && agentId ? agentId : "fiqh_tahawwulat";
    const pricing = resolvePlanPricing(currentAgentId, plan);
    const invoiceNumber = `OT-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
    const trxRef = db.collection("transactions").doc();
    const trxId = trxRef.id;
    const uid = ((_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid) || null;
    // F-07: Tulis dokumen transaksi berstatus pending SEBELUM memanggil gateway DOKU
    await trxRef.set({
        uid,
        plan,
        agent_id: currentAgentId,
        gateway: "doku",
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
    let paymentUrl = "";
    try {
        paymentUrl = await requestDokuCheckout({
            invoiceNumber,
            amount: pricing.amount,
            itemName: pricing.label,
            customerName: name,
            customerEmail: email,
            customerPhone: phone || "",
        });
        // Update URL pembayaran yang berhasil diperoleh
        await trxRef.update({
            payment_url: paymentUrl,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    catch (err) {
        console.error("[createCheckout] DOKU checkout error:", ((_b = err.response) === null || _b === void 0 ? void 0 : _b.data) || err.message);
        await trxRef.update({
            status: "failed",
            error: ((_e = (_d = (_c = err.response) === null || _c === void 0 ? void 0 : _c.data) === null || _d === void 0 ? void 0 : _d.error) === null || _e === void 0 ? void 0 : _e.message) || err.message || "Kendala teknis DOKU",
            failed_at: admin.firestore.FieldValue.serverTimestamp(),
        }).catch(() => { });
        throw new functions.https.HttpsError("internal", "Gagal membuat sesi pembayaran DOKU: " + (((_h = (_g = (_f = err.response) === null || _f === void 0 ? void 0 : _f.data) === null || _g === void 0 ? void 0 : _g.error) === null || _h === void 0 ? void 0 : _h.message) || err.message || "Kendala teknis DOKU"));
    }
    return {
        redirectUrl: paymentUrl,
        paymentUrl: paymentUrl,
        trxId,
        invoiceNumber
    };
});
function generateDokuGetSignature(clientId, requestId, timestamp, targetPath, secretKey) {
    const component = `Client-Id:${clientId}\nRequest-Id:${requestId}\nRequest-Timestamp:${timestamp}\nRequest-Target:${targetPath}`;
    const hmac = crypto.createHmac("sha256", secretKey).update(component).digest("base64");
    return `HMACSHA256=${hmac}`;
}
function getServiceTitleForEntitlement(entitlementKey) {
    if (entitlementKey === "all_access" || entitlementKey === "all_ai")
        return "Paket Semua AI";
    if (entitlementKey === "fiqh_tahawwulat")
        return "AI Fikih Tahawwulat";
    if (entitlementKey === "fiqh_syafii")
        return "AI Fikih Syafi'i";
    if (entitlementKey === "fiqh_hanafi")
        return "AI Fikih Hanafi";
    if (entitlementKey === "fiqh_maliki")
        return "AI Fikih Maliki";
    if (entitlementKey === "fiqh_hanbali")
        return "AI Fikih Hanbali";
    if (entitlementKey === "fiqh_muqaran")
        return "AI Fikih Perbandingan Mazhab";
    if (entitlementKey === "ushul_fiqh")
        return "AI Ushul Fiqih";
    if (entitlementKey === "tafsir")
        return "AI Tafsir";
    if (entitlementKey === "hadits")
        return "AI Hadits";
    if (entitlementKey === "nahwu" || entitlementKey === "bahasa_arab" || entitlementKey === "nahwu_sharaf")
        return "AI Bahasa Arab";
    if (entitlementKey === "aqidah" || entitlementKey === "aqidah_kalam" || entitlementKey === "aqidah_ushuluddin")
        return "AI Aqidah & Ushuluddin";
    if (entitlementKey === "tarikh" || entitlementKey === "tarikh_khulafa" || entitlementKey === "tarikh_thabaqat" || entitlementKey === "sirah")
        return "AI Tarikh & Sirah Nabawiyah";
    if (entitlementKey === "tasawwuf" || entitlementKey === "habib_umar" || entitlementKey === "tasawwuf_ihya" || entitlementKey === "tasawwuf_adab")
        return "AI Tasawwuf & Tazkiyatun Nafs";
    return "Modul kajian";
}
async function processSuccessfulPayment(invoiceNumber, paidAmount) {
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
        const userRef = db.collection("users").doc(uid);
        const uSnap = await t.get(userRef);
        if (!uSnap.exists)
            throw new Error("Payment owner profile is missing");
        const uData = uSnap.data();
        const entitlements = (uData.entitlements || {});
        const currentEnt = entitlements[entitlementKey];
        // F65: Hitung tanggal kedaluwarsa dengan month-end clamp
        const now = new Date();
        let baseDate = now;
        if (currentEnt && currentEnt.expiry && currentEnt.status === "active") {
            const curExpDate = currentEnt.expiry.toDate ? currentEnt.expiry.toDate() : new Date(currentEnt.expiry);
            if (curExpDate > now) {
                baseDate = curExpDate;
            }
        }
        const expiryDate = addCalendarMonthsClamped(baseDate, durationMonths);
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
                source: "doku_payment",
                expiry: admin.firestore.Timestamp.fromDate(expiryDate),
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            } });
        const userUpdate = {
            entitlements: updatedEntitlements,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        };
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
        res.status(500).json({ error: err.message });
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
    if (txData.status === "paid" || txData.status === "success") {
        return { success: true, status: "SUCCESS", message: "Akses langganan sudah aktif." };
    }
    // 2. Jika belum success di Firestore, query langsung ke DOKU Orders Inquiry API
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
        const trxStatus = ((_a = dokuData.transaction) === null || _a === void 0 ? void 0 : _a.status) || "";
        if (trxStatus === "SUCCESS") {
            console.log(`[checkPaymentStatus] DOKU Inquiry verified SUCCESS for ${invoiceNumber}! Activating subscription...`);
            const actResult = await processSuccessfulPayment(invoiceNumber, (_b = dokuData.order) === null || _b === void 0 ? void 0 : _b.amount);
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
        console.error("[checkPaymentStatus] Error checking DOKU status:", ((_c = err.response) === null || _c === void 0 ? void 0 : _c.data) || err.message);
        return {
            success: false,
            status: "PENDING",
            error: ((_d = err.response) === null || _d === void 0 ? void 0 : _d.data) || err.message
        };
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
    const userEmail = (context.auth.token.email || "").trim().toLowerCase();
    let redeemResult = {
        entitlementKey: "fiqh_syafii",
        durationDays: 7,
        expiryIso: "",
        email: userEmail,
        name: "Peneliti",
        serviceTitle: "AI Fikih Syafi'i",
    };
    await db.runTransaction(async (transaction) => {
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
        const redeemedAt = new Date();
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
        };
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
        `📧 Email: <code>${redeemResult.email}</code>\n` +
        `👤 Nama: <b>${redeemResult.name}</b>\n` +
        `📦 Produk: <b>${redeemResult.serviceTitle}</b>\n` +
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
    const uid = context.params.uid;
    const user = await admin.auth().getUser(uid);
    if (!user.emailVerified || !user.email)
        return null;
    // Only owned historical transactions may repair an empty profile.
    const owned = await db.collection("transactions").where("uid", "==", uid)
        .where("status", "in", ["success", "paid"]).get();
    if (owned.empty)
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
        for (const doc of owned.docs)
            txs.push(await t.get(doc.ref));
        for (const tx of txs) {
            const data = tx.data();
            if (!data || data.uid !== uid || !["paid", "success"].includes(data.status))
                continue;
            const key = data.entitlement_key;
            const expiry = data.subscription_expires_at;
            if (typeof key !== "string" || !(expiry === null || expiry === void 0 ? void 0 : expiry.toDate) || expiry.toDate() <= new Date())
                continue;
            if (!entitlements[key] || expiry.toMillis() > entitlements[key].expiry.toMillis()) {
                entitlements[key] = { plan: data.plan || "premium", status: "active", expiry };
            }
        }
        if (!Object.keys(entitlements).length)
            return;
        t.update(snapshot.ref, { entitlements, updated_at: admin.firestore.FieldValue.serverTimestamp() });
        for (const key of Object.keys(entitlements)) {
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
    .pubsub.schedule("0 0 * * *").timeZone("Asia/Jakarta")
    .onRun(async () => {
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
                var _a, _b, _c, _d;
                const snap = await t.get(doc.ref);
                if (!snap.exists)
                    return;
                const data = snap.data();
                const entitlements = Object.assign({}, (data.entitlements || {}));
                const expired = [];
                for (const [key, value] of Object.entries(entitlements)) {
                    const ent = value;
                    const expiry = ((_a = ent === null || ent === void 0 ? void 0 : ent.expiry) === null || _a === void 0 ? void 0 : _a.toDate) ? ent.expiry.toDate() : new Date((_b = ent === null || ent === void 0 ? void 0 : ent.expiry) !== null && _b !== void 0 ? _b : "");
                    if ((ent === null || ent === void 0 ? void 0 : ent.status) === "active" && expiry <= new Date()) {
                        entitlements[key] = Object.assign(Object.assign({}, ent), { status: "expired" });
                        expired.push(key);
                    }
                }
                const legacyExpiry = ((_c = data.subscription_expiry) === null || _c === void 0 ? void 0 : _c.toDate)
                    ? data.subscription_expiry.toDate() : new Date((_d = data.subscription_expiry) !== null && _d !== void 0 ? _d : "");
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
    return null;
});
// ================================================================
// FUNCTION 4b: processProvisioningOutbox (Cron Worker — tiap 5 menit)
// Memproses antrean durable outbox provisioning & revocation NotebookLM
// ================================================================
const PROVISIONED_KEYS = ["fiqh_tahawwulat", "fiqh_syafii", "ushul_fiqh", "hadits", "tafsir", "nahwu"];
function entitlementRevision(data) {
    return JSON.stringify([data === null || data === void 0 ? void 0 : data.plan, data === null || data === void 0 ? void 0 : data.subscription_expiry, data === null || data === void 0 ? void 0 : data.entitlements]);
}
exports.processProvisioningOutbox = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
    .pubsub.schedule("every 5 minutes")
    .onRun(async () => {
    const started = Date.now();
    const pending = await db.collection("provisioning_outbox")
        .where("status", "in", ["pending", "retry", "processing"]).limit(25).get();
    for (const candidate of pending.docs) {
        if (Date.now() - started > 210000)
            break;
        const token = crypto.randomUUID();
        const uid = candidate.data().uid;
        if (typeof uid !== "string" || !uid) {
            await candidate.ref.update({ status: "failed", error: "Missing owner UID" });
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
            const user = await db.collection("users").doc(uid).get();
            const data = user.data();
            const email = ((data === null || data === void 0 ? void 0 : data.email) || job.email || "").trim().toLowerCase();
            if (!email.includes("@"))
                throw new Error("Invalid provisioning email");
            const scope = job.entitlement_key;
            const keys = scope === "all_access" || scope === "all_ai" ? PROVISIONED_KEYS : [scope];
            for (const key of keys) {
                if (!PROVISIONED_KEYS.includes(key))
                    throw new Error("Unsupported provisioning scope");
                const desired = data && getEntitlementAccess(data, key).active;
                await notifySubscriptionServer(email, (data === null || data === void 0 ? void 0 : data.name) || job.name || "Peneliti", desired ? "premium" : "trial", desired ? "add" : "remove", getServiceTitleForEntitlement(key));
            }
            const after = await db.collection("users").doc(uid).get();
            if (entitlementRevision(data) !== entitlementRevision(after.data())) {
                status = "retry";
                error = "Entitlements changed during delivery";
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
// FUNCTION 4c: cleanupOrphanedDeletions (Cron Harian — jam 03.00 WIB)
// Membersihkan dokumen user yang bertanda pending_deletion jika akun Auth sudah terhapus
// ================================================================
async function deleteUserData(uid, authEmail = "") {
    const ref = db.collection("users").doc(uid);
    await db.runTransaction(async (t) => {
        var _a;
        const user = await t.get(ref);
        const email = authEmail || ((_a = user.data()) === null || _a === void 0 ? void 0 : _a.email) || "";
        const jobs = [];
        for (const key of PROVISIONED_KEYS) {
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
async function notifySubscriptionServer(email, name, plan, action, serviceName) {
    const url = "https://openturath-subscription-255541559800.asia-southeast2.run.app/webhook";
    const services = serviceName
        ? [serviceName]
        : [
            "AI Fikih Tahawwulat",
            "AI Fikih Syafi'i",
            "AI Ushul Fiqih",
            "AI Hadits",
            "AI Tafsir",
            "AI Bahasa Arab",
        ];
    for (const service of services) {
        const payload = {
            event: action === "add" ? "subscription.paid" : "subscription.expired",
            data: {
                status: action === "add" ? "PAID" : "EXPIRED",
                payer: {
                    name: name,
                    email: email,
                },
                service: {
                    name: service,
                },
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
                timeout: 10000,
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
// ================================================================
// FUNCTION 5: chatGate (Auth Gate + Iframe for NotebookLM)
// ================================================================
const AGENTS = {
    "fikih-tahawwulat-muhaqqiq": {
        notebookId: "dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
        akalCuid: "cmln2i27k0000jx047oabzw8p",
        label: "AI Fikih Tahawwulat (Al-Muhaqqiq)",
        entitlementKey: "fiqh_tahawwulat"
    },
    "fikih-tahawwulat-bayan": {
        notebookId: "483d0291-0a70-411c-bff0-f1ea4b83b2fd",
        akalCuid: "cmln2i27k0000jx047oabzw8p",
        label: "AI Fikih Tahawwulat (Al-Bayan)",
        entitlementKey: "fiqh_tahawwulat"
    },
    "fikih-tahawwulat-mukhtabir": {
        notebookId: "ac61a7a0-87e7-42a5-a30f-980ff74a78d8",
        akalCuid: "cmln2i27k0000jx047oabzw8p",
        label: "AI Fikih Tahawwulat (Al-Mukhtabir)",
        entitlementKey: "fiqh_tahawwulat"
    },
    "fikih-tahawwulat-habib": {
        notebookId: "6673e79a-7156-42e1-b116-bc1653a32094",
        akalCuid: "cmln2i27k0000jx047oabzw8p",
        label: "AI Fikih Tahawwulat (Al-Habib)",
        entitlementKey: "fiqh_tahawwulat"
    },
    "fikih-tahawwulat-khatib": {
        notebookId: "1288e413-9569-47a3-892f-64008e53c1e8",
        akalCuid: "cmln2i27k0000jx047oabzw8p",
        label: "AI Fikih Tahawwulat (Al-Khatib)",
        entitlementKey: "fiqh_tahawwulat"
    },
    "fikih-syafii": {
        notebookId: "334e7b83-0e76-4787-a1d6-314642a35862",
        akalCuid: "cms4ls3j60001l20439k1nph4",
        label: "Super AI Fikih Syafi'i",
        entitlementKey: "fiqh_syafii"
    },
    "fikih-syafii-muhaqqiq": {
        notebookId: "334e7b83-0e76-4787-a1d6-314642a35862",
        akalCuid: "cms4ls3j60001l20439k1nph4",
        label: "Super AI Fikih Syafi'i",
        entitlementKey: "fiqh_syafii"
    },
    "nahwu-sharaf-muerib": {
        notebookId: "15bc4cef-4b94-4241-b05a-d50a586bde06",
        akalCuid: "cmnd7l4o60002l504ab6qq31x",
        label: "AI Bahasa Arab (Al-Mu'rib)",
        entitlementKey: "nahwu"
    },
    "nahwu-sharaf-tashrif": {
        notebookId: "15bc4cef-4b94-4241-b05a-d50a586bde06",
        akalCuid: "cmnd7l4o60002l504ab6qq31x",
        label: "AI Bahasa Arab (Tashrif)",
        entitlementKey: "nahwu"
    }
};
const COOKIE_NAME = "ot_session";
const COOKIE_MAX_AGE = 8 * 60 * 60; // 8 jam dalam detik
function getWebSessionSecret() {
    var _a;
    // Prefer environment variables, but retain compatibility with older
    // Firebase Runtime Config deployments while the secret is migrated.
    const runtimeConfigSecret = (_a = functions.config().web) === null || _a === void 0 ? void 0 : _a.session_secret;
    return process.env.WEB_SESSION_SECRET || runtimeConfigSecret || "";
}
function getAkalApiKey() {
    var _a;
    const runtimeConfigKey = (_a = functions.config().akal) === null || _a === void 0 ? void 0 : _a.api_key;
    return process.env.AKAL_API_KEY || runtimeConfigKey || "";
}
function resolveAgentRef(value) {
    return typeof value === "string" && AGENTS[value]
        ? value
        : "fikih-tahawwulat-muhaqqiq";
}
function clearSessionCookie(res) {
    res.setHeader("Set-Cookie", `${COOKIE_NAME}=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0`);
}
exports.chatGate = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onRequest(async (req, res) => {
    const sessionSecret = getWebSessionSecret();
    if (!sessionSecret) {
        console.error("WEB_SESSION_SECRET is not configured; web access is disabled.");
        res.status(503).send("Layanan web sedang tidak tersedia. Silakan gunakan aplikasi OpenTurath.");
        return;
    }
    // Normalize path
    let path = req.path || "";
    if (path.endsWith("/") && path.length > 1) {
        path = path.slice(0, -1);
    }
    const ref = resolveAgentRef(req.query.ref);
    if (path === "/" || path === "") {
        res.redirect(`/login?ref=${encodeURIComponent(ref)}`);
        return;
    }
    if (path === "/login") {
        if (req.method === "GET") {
            const error = typeof req.query.error === "string" ? req.query.error : "";
            res.setHeader("Content-Type", "text/html;charset=UTF-8");
            res.send(getLoginHTML(ref, generateCsrfToken(sessionSecret), error));
            return;
        }
        if (req.method === "POST") {
            await handleLogin(req, res, sessionSecret, getAkalApiKey());
            return;
        }
        res.status(405).send("Method Not Allowed");
        return;
    }
    if (path === "/logout") {
        clearSessionCookie(res);
        res.redirect(`/login?ref=${encodeURIComponent(ref)}`);
        return;
    }
    // ROUTE: GET /chat/:agentId
    const chatMatch = path.match(/^\/chat\/([a-zA-Z0-9-]+)$/);
    if (chatMatch) {
        const agentId = chatMatch[1];
        const agent = AGENTS[agentId];
        if (!agent) {
            res.status(404).send("Agent tidak ditemukan.");
            return;
        }
        const session = verifySessionCookie(req.headers.cookie || "", sessionSecret);
        if (!session) {
            res.redirect(`/login?ref=${encodeURIComponent(agentId)}`);
            return;
        }
        // Re-check the local entitlement on each initial page request. This
        // prevents an old session cookie from bypassing expiry/revocation.
        const hasAccess = await verifySubscriptionFirestore(session.email, agent.entitlementKey, session.uid);
        if (!hasAccess) {
            clearSessionCookie(res);
            res.redirect(`/login?ref=${encodeURIComponent(agentId)}&error=not_found`);
            return;
        }
        res.setHeader("Content-Type", "text/html;charset=UTF-8");
        res.send(getChatWrapperHTML(agent, agentId, session.email));
        return;
    }
    res.status(404).send("Not Found");
});
// ── HELPERS FOR CHAT GATE ──
async function handleLogin(req, res, secret, apiKey) {
    const idToken = (req.body.id_token || (req.headers.authorization ? req.headers.authorization.split("Bearer ")[1] : "") || "").trim();
    const csrfTokenForm = req.body.csrf_token || "";
    const ref = req.body.ref || "fikih-tahawwulat-muhaqqiq";
    if (!verifyCsrfToken(csrfTokenForm, secret)) {
        res.redirect(`/login?ref=${ref}&error=invalid_request`);
        return;
    }
    // Wajib memiliki idToken terverifikasi dari Firebase Authentication
    if (!idToken) {
        res.redirect(`/login?ref=${ref}&error=auth_required`);
        return;
    }
    let email = "";
    let uid = "";
    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken, true);
        uid = decodedToken.uid;
        email = (decodedToken.email || "").trim().toLowerCase();
        if (!email || decodedToken.email_verified !== true) {
            res.redirect(`/login?ref=${ref}&error=unverified_email`);
            return;
        }
    }
    catch (err) {
        console.error(`[Auth] Gagal memverifikasi idToken Firebase: ${err.message}`);
        res.redirect(`/login?ref=${ref}&error=invalid_token`);
        return;
    }
    const agent = AGENTS[ref] || AGENTS["fikih-tahawwulat-muhaqqiq"];
    const akalCuid = agent.akalCuid;
    const entitlementKey = agent.entitlementKey || "fiqh_tahawwulat";
    const isSubscriber = await verifySubscriptionFirestore(email, entitlementKey, uid);
    if (isSubscriber) {
        const payload = JSON.stringify({ uid, email, iat: Date.now() });
        const payloadB64 = Buffer.from(payload).toString("base64url");
        const sig = crypto.createHmac("sha256", secret).update(payloadB64).digest("base64url");
        const sessionCookie = `${payloadB64}.${sig}`;
        res.setHeader("Set-Cookie", `${COOKIE_NAME}=${sessionCookie}; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=${COOKIE_MAX_AGE}`);
        res.redirect(`/chat/${ref}`);
    }
    else {
        res.redirect(`/login?ref=${ref}&error=not_found`);
    }
}
async function verifySubscriptionHybrid(email, entitlementKey, serviceCuid, apiKey) {
    // 1. Check local Firestore first (respects manual overrides, bonuses, and active firestore state)
    try {
        const localActive = await verifySubscriptionFirestore(email, entitlementKey);
        if (localActive) {
            console.log(`[Auth] User ${email} verified active locally via Firestore for entitlement '${entitlementKey}'`);
            return true;
        }
    }
    catch (err) {
        console.error(`[Auth] Firestore subscription check failed: ${err.message}`);
    }
    // 2. Fallback to querying GoAkal API directly
    console.log(`[Auth] User ${email} not verified locally. Falling back to GoAkal API...`);
    return await verifyAkalSubscription(email, serviceCuid, apiKey);
}
async function verifySubscriptionFirestore(email, entitlementKey, uid) {
    // Web authorization must carry a verified UID. Billing history is not identity.
    if (!uid)
        return false;
    const user = await db.collection("users").doc(uid).get();
    if (!user.exists)
        return false;
    const data = user.data();
    if (typeof data.email !== "string" || data.email.toLowerCase() !== email.toLowerCase())
        return false;
    return getEntitlementAccess(data, entitlementKey).active;
}
async function verifyAkalSubscription(email, serviceCuid, apiKey) {
    const statuses = ["PAID", "SETTLED"];
    for (const status of statuses) {
        let page = 1;
        const maxPages = 5;
        while (page <= maxPages) {
            const apiUrl = `https://goakal.com/service/api/v1/services/${serviceCuid}/transactions?status=${status}&pageSize=100&page=${page}`;
            try {
                const response = await axios_1.default.get(apiUrl, {
                    headers: { "X-Api-Key": apiKey }
                });
                const result = response.data;
                const txns = result.data || [];
                if (txns.length === 0)
                    break;
                const now = new Date();
                const activeTxn = txns.find((t) => {
                    if (!t.payerEmail)
                        return false;
                    if (t.payerEmail.trim().toLowerCase() !== email)
                        return false;
                    if (t.expiryDate) {
                        return new Date(t.expiryDate) > now;
                    }
                    const startStr = t.paidAt || t.createdAt;
                    if (!startStr)
                        return false;
                    const startDate = new Date(startStr);
                    const durationMonths = detectDurationMonths(t.priceSchemeTitle || "", t.serviceTitle || "");
                    const expiry = new Date(startDate);
                    expiry.setMonth(expiry.getMonth() + durationMonths);
                    return expiry > now;
                });
                if (activeTxn)
                    return true;
                if (txns.length < 100)
                    break;
                page++;
            }
            catch (e) {
                console.error(`Akal API fetch error: ${e.message}`);
                break;
            }
        }
    }
    return false;
}
function detectDurationMonths(priceSchemeTitle, serviceTitle) {
    const s = (priceSchemeTitle + " " + serviceTitle).toLowerCase();
    if (s.includes("tahun") || s.includes("1y") || s.includes("year") || s.includes("annual"))
        return 12;
    if (s.includes("6 bulan") || s.includes("6m"))
        return 6;
    return 1;
}
function verifySessionCookie(cookieHeader, secret) {
    if (!cookieHeader)
        return null;
    const cookies = {};
    cookieHeader.split(";").forEach(c => {
        const parts = c.trim().split("=");
        if (parts.length >= 2) {
            cookies[parts[0]] = parts.slice(1).join("=");
        }
    });
    const cookieValue = cookies[COOKIE_NAME];
    if (!cookieValue)
        return null;
    const parts = cookieValue.split(".");
    if (parts.length !== 2)
        return null;
    const [payloadB64, sigB64] = parts;
    try {
        const expectedSig = crypto.createHmac("sha256", secret).update(payloadB64).digest("base64url");
        if (!safeTimingEqual(sigB64, expectedSig))
            return null;
        const payloadStr = Buffer.from(payloadB64, "base64url").toString("utf8");
        const payload = JSON.parse(payloadStr);
        if (typeof payload.uid !== "string" || !payload.uid ||
            typeof payload.email !== "string" || !Number.isFinite(payload.iat) ||
            payload.iat > Date.now() + 60000 || Date.now() - payload.iat > COOKIE_MAX_AGE * 1000)
            return null;
        return { uid: payload.uid, email: payload.email };
    }
    catch (_a) {
        return null;
    }
}
function generateCsrfToken(secret) {
    const ts = Date.now().toString();
    const signature = crypto.createHmac("sha256", secret).update(ts).digest("base64url");
    return `${ts}.${signature}`;
}
function verifyCsrfToken(token, secret) {
    if (!token)
        return false;
    const parts = token.split(".");
    if (parts.length !== 2)
        return false;
    const [ts, signature] = parts;
    const tsNum = parseInt(ts, 10);
    if (isNaN(tsNum) || Date.now() - tsNum > 3600 * 1000)
        return false; // 1 jam
    const expectedSig = crypto.createHmac("sha256", secret).update(ts).digest("base64url");
    return signature === expectedSig;
}
function escapeHtml(str) {
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#x27;");
}
function maskEmail(email) {
    if (!email || !email.includes("@"))
        return email;
    const [local, domain] = email.split("@");
    const masked = local[0] + "***";
    return `${masked}@${domain}`;
}
// ── HTML TEMPLATES ──
function getLoginHTML(ref, csrfToken, error) {
    const errorMessages = {
        not_found: "Email ini tidak terdaftar sebagai pelanggan aktif. Pastikan email sesuai dengan yang digunakan di Akal.",
        invalid_email: "Format email tidak valid.",
        invalid_request: "Permintaan tidak valid. Silakan coba lagi.",
    };
    const errorHTML = error && errorMessages[error]
        ? `<div class="error-box">${errorMessages[error]}</div>`
        : "";
    return `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OpenTurath AI — Login</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: #0a0e17;
      color: #c9d1d9;
      font-family: 'Outfit', sans-serif;
      display: flex; flex-direction: column;
      justify-content: center; align-items: center;
      min-height: 100vh;
      background-image: radial-gradient(ellipse at 20% 50%, rgba(212,175,55,0.07) 0%, transparent 60%),
                        radial-gradient(ellipse at 80% 20%, rgba(212,175,55,0.04) 0%, transparent 50%);
    }
    .logo {
      font-size: 13px;
      letter-spacing: 3px;
      text-transform: uppercase;
      color: rgba(212,175,55,0.6);
      margin-bottom: 10px;
    }
    h1 {
      font-size: 28px;
      font-weight: 700;
      color: #D4AF37;
      margin-bottom: 6px;
      text-align: center;
    }
    .subtitle {
      font-size: 14px;
      color: rgba(255,255,255,0.4);
      margin-bottom: 36px;
      text-align: center;
    }
    .card {
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(212,175,55,0.2);
      padding: 36px 32px;
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(212,175,55,0.05);
      width: 360px;
      backdrop-filter: blur(12px);
    }
    label { font-size: 13px; color: rgba(255,255,255,0.5); display: block; margin-bottom: 8px; }
    input[type="email"] {
      width: 100%;
      padding: 13px 16px;
      margin-bottom: 20px;
      border-radius: 10px;
      border: 1px solid rgba(255,255,255,0.1);
      background: rgba(0,0,0,0.25);
      color: #fff;
      font-size: 15px;
      font-family: inherit;
      outline: none;
      transition: border-color 0.2s;
    }
    input[type="email"]:focus { border-color: rgba(212,175,55,0.5); }
    button[type="submit"] {
      width: 100%;
      padding: 13px;
      background: linear-gradient(135deg, #D4AF37, #a8872b);
      color: #000;
      border: none;
      border-radius: 10px;
      font-size: 15px;
      font-weight: 700;
      font-family: inherit;
      cursor: pointer;
      transition: opacity 0.2s, transform 0.1s;
    }
    button[type="submit"]:hover { opacity: 0.9; transform: translateY(-1px); }
    button[type="submit"]:active { transform: translateY(0); }
    .error-box {
      background: rgba(220,60,60,0.12);
      border: 1px solid rgba(220,60,60,0.3);
      border-radius: 8px;
      padding: 12px 14px;
      font-size: 13px;
      color: #ff9090;
      margin-bottom: 20px;
      line-height: 1.5;
    }
    .footer { margin-top: 24px; font-size: 12px; color: rgba(255,255,255,0.2); text-align: center; }
  </style>
</head>
<body>
  <div class="logo">OpenTurath</div>
  <h1>Ruang Kajian</h1>
  <p class="subtitle">Masukkan email akun Anda</p>
  <div class="card">
    ${errorHTML}
    <form method="POST" action="/login">
      <input type="hidden" name="ref" value="${escapeHtml(ref)}">
      <input type="hidden" name="csrf_token" value="${escapeHtml(csrfToken)}">
      <label for="email">Alamat Email</label>
      <input type="email" id="email" name="email" placeholder="nama@email.com" required autocomplete="email">
      <button type="submit">Buka ruang kajian →</button>
    </form>
  </div>
  <p class="footer">Belum berlangganan? Buka langganan melalui aplikasi OpenTurath</p>
</body>
</html>`;
}
function getChatWrapperHTML(agent, agentId, email) {
    const chatUrl = `https://notebooklm.google.com/notebook/${agent.notebookId}/preview`;
    let descHtml = "";
    let promptsHtml = "";
    if (agentId === "fiqh_tahawwulat") {
        descHtml = `<p>Kajian **Fikih Tahawwulat** menelaah kaidah tanda zaman dan perubahan peradaban berdasarkan kitab-kitab rujukan.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Bagaimana penjelasan al-ghutsā\\'iyyah dalam kitab?')">
        Penjelasan al-ghutsā'iyyah 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Apa yang dimaksud Rukun Keempat dalam Fikih Tahawwulat?')">
        Rukun Keempat Fikih Tahawwulat 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana para ulama menjelaskan sikap saat masa fitnah?')">
        Sikap saat masa fitnah 📋
      </div>
    `;
    }
    else if (agentId === "fiqh_syafii") {
        descHtml = `<p>Kajian **Fikih Syafi'i** menelaah masalah ibadah, muamalah, dan fatwa para ulama mazhab Syafi'i dari kitab-kitab mu'tamad.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Apa rukun wudu menurut pendapat mu\\'tamad dalam mazhab Syafi\\'i?')">
        Rukun wudu mu'tamad Syafi'i 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Apa syarat sah salat berjamaah menurut Minhāj al-Ṭālibīn?')">
        Syarat salat berjamaah di Minhāj 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana ketentuan zakat perdagangan menurut Imam al-Nawawi?')">
        Zakat perdagangan menurut al-Nawawi 📋
      </div>
    `;
    }
    else if (agentId === "hadits") {
        descHtml = `<p>Kajian **Hadis & Syarah** memuat kitab-kitab hadis induk dan syarahnya untuk memeriksa matan, sanad, dan faedah hukum.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Bagaimana penjelasan hadis tentang niat dalam Fatḥ al-Bārī?')">
        Penjelasan hadis niat di Fatḥ al-Bārī 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana menilai sanad riwayat ini?')">
        Penilaian sanad riwayat 📋
      </div>
    `;
    }
    else {
        descHtml = `<p>Kajian **${escapeHtml(agent.label || "Kitab")}** membantu menelaah kitab-kitab rujukan keilmuan Islam.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Apa pokok bahasan dalam bab ini?')">
        Pokok bahasan bab 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Apa perbedaan pendapat ulama dalam masalah ini?')">
        Perbedaan pendapat ulama 📋
      </div>
    `;
    }
    return `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(agent.label)} — OpenTurath AI</title>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html, body { height: 100%; overflow: hidden; font-family: 'Outfit', sans-serif; background: #0a0e17; color: #ffffff; }

    /* ── Top Bar ── */
    .topbar {
      height: 48px;
      background: #0f1422;
      border-bottom: 1px solid rgba(212,175,55,0.15);
      display: flex;
      align-items: center;
      padding: 0 20px;
      gap: 16px;
      position: relative;
      z-index: 110;
    }
    .menu-toggle {
      display: none;
      background: none;
      border: none;
      color: #D4AF37;
      font-size: 22px;
      cursor: pointer;
      padding: 4px;
    }
    .topbar-brand {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .topbar-brand .dot {
      width: 8px; height: 8px;
      border-radius: 50%;
      background: #D4AF37;
      box-shadow: 0 0 8px rgba(212,175,55,0.8);
    }
    .topbar-brand .name {
      font-size: 15px;
      font-weight: 700;
      color: #D4AF37;
      letter-spacing: 0.5px;
    }
    .topbar-agent {
      font-size: 12px;
      color: rgba(255,255,255,0.35);
      border-left: 1px solid rgba(255,255,255,0.1);
      padding-left: 16px;
    }
    
    /* ── Dashboard Layout ── */
    .dashboard-container {
      display: flex;
      height: calc(100vh - 48px);
      width: 100%;
      position: relative;
    }

    /* Left Sidebar */
    .sidebar-left {
      width: 250px;
      background: #0f1422;
      border-right: 1px solid rgba(212,175,55,0.15);
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      padding: 20px 16px;
      z-index: 100;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .sidebar-section {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .section-title {
      font-size: 11px;
      font-weight: 700;
      color: rgba(255,255,255,0.3);
      letter-spacing: 1px;
      text-transform: uppercase;
      margin-bottom: 4px;
    }
    .menu-list {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .menu-item {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px 12px;
      border-radius: 8px;
      color: rgba(255,255,255,0.65);
      text-decoration: none;
      font-size: 13px;
      font-weight: 500;
      transition: all 0.2s;
      border: 1px solid transparent;
    }
    .menu-item:hover {
      background: rgba(255,255,255,0.03);
      color: #ffffff;
    }
    .menu-item.active {
      background: rgba(212,175,55,0.08);
      color: #D4AF37;
      border-color: rgba(212,175,55,0.15);
      font-weight: 600;
    }
    
    /* User Profile Card */
    .user-card {
      background: rgba(255,255,255,0.02);
      border: 1px solid rgba(255,255,255,0.05);
      border-radius: 12px;
      padding: 14px;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .user-info {
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .user-email {
      font-size: 12px;
      font-weight: 600;
      color: rgba(255,255,255,0.85);
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .user-status {
      font-size: 10px;
      color: #D4AF37;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .status-dot {
      width: 6px; height: 6px;
      background: #D4AF37;
      border-radius: 50%;
      box-shadow: 0 0 6px #D4AF37;
    }
    .btn-logout {
      display: block;
      width: 100%;
      text-align: center;
      padding: 8px;
      background: rgba(212,175,55,0.1);
      border: 1px solid rgba(212,175,55,0.2);
      border-radius: 6px;
      color: #D4AF37;
      text-decoration: none;
      font-size: 11px;
      font-weight: 600;
      transition: all 0.2s;
    }
    .btn-logout:hover {
      background: rgba(212,175,55,0.2);
      border-color: rgba(212,175,55,0.3);
    }

    /* Right Sidebar */
    .sidebar-right {
      width: 280px;
      background: #0f1422;
      border-left: 1px solid rgba(212,175,55,0.15);
      padding: 20px 16px;
      display: flex;
      flex-direction: column;
      gap: 20px;
      overflow-y: auto;
      z-index: 100;
    }
    .desc-box {
      font-size: 12px;
      line-height: 1.6;
      color: rgba(255,255,255,0.5);
      background: rgba(255,255,255,0.01);
      padding: 14px;
      border-radius: 10px;
      border: 1px solid rgba(255,255,255,0.03);
    }
    .desc-box strong { color: rgba(255,255,255,0.8); }
    .prompt-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    .prompt-item {
      padding: 12px;
      background: rgba(255,255,255,0.02);
      border: 1px solid rgba(255,255,255,0.05);
      border-radius: 8px;
      font-size: 12px;
      line-height: 1.5;
      color: rgba(255,255,255,0.7);
      cursor: pointer;
      transition: all 0.2s;
    }
    .prompt-item:hover {
      background: rgba(212,175,55,0.05);
      border-color: rgba(212,175,55,0.25);
      color: #D4AF37;
    }
    
    .btn-help {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 10px;
      background: #25d366;
      color: #ffffff;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      text-decoration: none;
      transition: opacity 0.2s;
    }
    .btn-help:hover { opacity: 0.9; }

    .btn-full-tab {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 12px;
      background: linear-gradient(135deg, #D4AF37, #a8872b);
      color: #000000;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 700;
      text-decoration: none;
      transition: all 0.2s;
      box-shadow: 0 4px 10px rgba(212,175,55,0.2);
      margin-top: 10px;
    }
    .btn-full-tab:hover {
      opacity: 0.9;
      transform: translateY(-1px);
    }

    /* Center Chat Area */
    .chat-area {
      flex: 1;
      height: 100%;
      background: #0a0e17;
      position: relative;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: none;
      display: block;
    }

    /* Toast Alert */
    .toast {
      position: fixed;
      bottom: 24px;
      left: 50%;
      transform: translateX(-50%) translateY(100px);
      background: rgba(212,175,55,0.95);
      color: #0a0e17;
      padding: 10px 20px;
      border-radius: 8px;
      font-size: 13px;
      font-weight: 600;
      transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      z-index: 1000;
      box-shadow: 0 4px 12px rgba(0,0,0,0.5);
      pointer-events: none;
    }
    .toast.show {
      transform: translateX(-50%) translateY(0);
    }

    /* ── Responsive Styling ── */
    @media (max-width: 991px) {
      .menu-toggle {
        display: block;
      }
      .sidebar-right {
        display: none;
      }
      .sidebar-left {
        position: fixed;
        top: 48px;
        left: -250px;
        height: calc(100% - 48px);
        box-shadow: 10px 0 30px rgba(0,0,0,0.5);
      }
      .sidebar-left.open {
        left: 0;
      }
    }
  </style>
</head>
<body>
  <div class="topbar">
    <button class="menu-toggle" onclick="toggleSidebar()">☰</button>
    <div class="topbar-brand">
      <div class="dot"></div>
      <div class="name">OpenTurath AI</div>
    </div>
    <span class="topbar-agent" id="topbar-agent-label">${escapeHtml(agent.label)}</span>
  </div>
  
  <div class="dashboard-container">
    <!-- Left Sidebar -->
    <aside class="sidebar-left" id="sidebar-left">
      <div class="sidebar-section">
        <div class="section-title">Pilih Kajian</div>
        <nav class="menu-list">
          <a href="/chat/fikih-tahawwulat-muhaqqiq" class="menu-item ${agentId === 'fikih-tahawwulat-muhaqqiq' ? 'active' : ''}">
            <span>📗</span> AI Fikih (Al-Muhaqqiq)
          </a>
          <a href="/chat/fikih-tahawwulat-bayan" class="menu-item ${agentId === 'fikih-tahawwulat-bayan' ? 'active' : ''}">
            <span>📘</span> AI Fikih (Al-Bayan)
          </a>
          <a href="/chat/nahwu-sharaf-muerib" class="menu-item ${agentId === 'nahwu-sharaf-muerib' ? 'active' : ''}">
            <span>📙</span> AI Nahwu (Al-Mu'rib)
          </a>
          <a href="/chat/nahwu-sharaf-tashrif" class="menu-item ${agentId === 'nahwu-sharaf-tashrif' ? 'active' : ''}">
            <span>📕</span> AI Nahwu (Tashrif)
          </a>
        </nav>
        <a href="${chatUrl}" target="_blank" class="btn-full-tab">
          Buka Layar Penuh
        </a>
      </div>

      <div class="user-card">
        <div class="user-info">
          <div class="user-status"><div class="status-dot"></div>Akun Google</div>
          <div style="font-size: 11px; color: rgba(255,255,255,0.45); margin-top: 4px; line-height: 1.4;">
            Gunakan akun Google yang memiliki akses ke ruang ini.
          </div>
        </div>
      </div>
    </aside>

    <!-- Center Chat Area (Iframe) -->
    <main class="chat-area">
      <iframe
        src="${chatUrl}"
        allow="microphone"
        title="${escapeHtml(agent.label)}"
        loading="lazy"
      ></iframe>
    </main>

    <!-- Right Sidebar -->
    <aside class="sidebar-right">
      <div class="sidebar-section">
        <div class="section-title">Tentang kajian ini</div>
        <div class="desc-box">
          ${descHtml}
        </div>
      </div>

      <div class="sidebar-section">
        <div class="section-title">Contoh pertanyaan</div>
        <div class="prompt-list">
          ${promptsHtml}
        </div>
      </div>
      
      <div style="flex-grow: 1;"></div>
      
      <a href="mailto:openturath@gmail.com" class="btn-help">
        💬 Bantuan
      </a>
    </aside>
  </div>

  <div id="toast" class="toast"></div>

  <script>
    // Toggle Mobile Sidebar Drawer
    function toggleSidebar() {
      document.getElementById('sidebar-left').classList.toggle('open');
    }

    // Close Mobile Sidebar Drawer when clicking outside or switching modules
    document.addEventListener('click', function(event) {
      const sidebar = document.getElementById('sidebar-left');
      const toggleBtn = document.querySelector('.menu-toggle');
      if (window.innerWidth <= 991 && sidebar.classList.contains('open')) {
        if (!sidebar.contains(event.target) && !toggleBtn.contains(event.target)) {
          sidebar.classList.remove('open');
        }
      }
    });

    // Copy prompt helper function
    function copyPrompt(text) {
      navigator.clipboard.writeText(text).then(() => {
        const toast = document.getElementById('toast');
        toast.innerText = 'Pertanyaan tersalin. Tempelkan di kolom chat.';
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 3500);
      }).catch(err => {
        console.error('Failed to copy text: ', err);
      });
    }

    // Blokir klik kanan untuk menyembunyikan URL dari context menu
    document.addEventListener('contextmenu', e => e.preventDefault());
  </script>
</body>
</html>`;
}
// ================================================================
// TELEMETRY CLOUD FUNCTION: Forward critical errors to Telegram
// ================================================================
exports.onClientErrorLogged = functions.firestore
    .document("client_error_logs/{logId}")
    .onCreate(async (snap, ctx) => {
    const data = snap.data();
    if (!data)
        return;
    const severity = data.severity || "error";
    // Teruskan ke Telegram untuk severity error, critical, dan fatal
    if (severity === "critical" || severity === "fatal" || severity === "error") {
        const errorMsg = String(data.error || "Unknown Error");
        const errContext = String(data.context || "general");
        const user = String(data.userEmail || data.userId || "anonymous");
        const platform = String(data.platform || "unknown");
        const msg = `⚠️ <b>[ALERT CLIENT ERROR]</b>\n` +
            `<b>Context:</b> ${errContext}\n` +
            `<b>Severity:</b> ${severity.toUpperCase()}\n` +
            `<b>Platform:</b> ${platform}\n` +
            `<b>User:</b> ${user}\n` +
            `<b>Error:</b> <code>${errorMsg.substring(0, 300)}</code>\n` +
            `<b>ID:</b> <code>${ctx.params.logId}</code>`;
        await sendTelegramNotification(msg);
    }
});
//# sourceMappingURL=index.js.map