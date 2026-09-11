"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.chatGate = exports.dailyRevoke = exports.onUserCreate = exports.redeemCode = exports.checkPaymentStatus = exports.dokuWebhook = exports.createCheckout = exports.recordQuestion = exports.getAgentUrl = void 0;
exports.addCalendarMonthsClamped = addCalendarMonthsClamped;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios_1 = require("axios");
const crypto = require("crypto");
admin.initializeApp();
const db = admin.firestore();
// ================================================================
// HARGA & DURASI OTORITATIF — Ditentukan oleh `resolvePlanPricing`
// ================================================================
// URL NotebookLM — HANYA ADA DI SINI, TIDAK DI CLIENT
const AGENT_URLS = {
    // Fikih
    fiqh_tahawwulat: "https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
    fiqh_tahawwulat_muhaqqiq: "https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4",
    fiqh_tahawwulat_bayan: "https://notebooklm.google.com/notebook/483d0291-0a70-411c-bff0-f1ea4b83b2fd",
    fiqh_syafii: "https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862",
    fiqh_syafii_muhaqqiq: "https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862",
    // Hadits
    hadits: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
    hadits_muhaqqiq: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
    hadits_takhrij: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
    hadits_syarah: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
    hadits_ilal: "https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6",
    // Tafsir
    tafsir: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
    tafsir_muhaqqiq: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
    tafsir_ahkam: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
    tafsir_matsur: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
    tafsir_ulumul_quran: "https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe",
    // Ushul Fiqih
    ushul_fiqh: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
    ushul_muhaqqiq: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
    usul_qawaid: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
    usul_maqashid: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
    usul_istinbath: "https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12",
    // Bahasa Arab
    nahwu_sharaf: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
    nahwu_sharaf_muerib: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
    nahwu_sharaf_tashrif: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
    bahasa_arab: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
    lughah_nahwu: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
    lughah_sharaf: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
    lughah_balaghah: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
    lughah_mujam: "https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06",
};
// Mapping eksplisit mencegah agent baru "jatuh" ke entitlement default dan
// tidak sengaja terbuka oleh langganan modul lain.
const AGENT_ENTITLEMENTS = {
    fiqh_tahawwulat: "fiqh_tahawwulat",
    fiqh_tahawwulat_muhaqqiq: "fiqh_tahawwulat",
    fiqh_tahawwulat_bayan: "fiqh_tahawwulat",
    fiqh_syafii: "fiqh_syafii",
    fiqh_syafii_muhaqqiq: "fiqh_syafii",
    fiqh_hanafi: "fiqh_hanafi",
    fiqh_maliki: "fiqh_maliki",
    fiqh_hanbali: "fiqh_hanbali",
    fiqh_muqaran: "fiqh_muqaran",
    nahwu_sharaf: "nahwu",
    nahwu_sharaf_muerib: "nahwu",
    nahwu_sharaf_tashrif: "nahwu",
    bahasa_arab: "nahwu",
    lughah_nahwu: "nahwu",
    lughah_sharaf: "nahwu",
    lughah_balaghah: "nahwu",
    lughah_mujam: "nahwu",
    ushul_fiqh: "ushul_fiqh",
    ushul_muhaqqiq: "ushul_fiqh",
    usul_qawaid: "ushul_fiqh",
    usul_maqashid: "ushul_fiqh",
    usul_istinbath: "ushul_fiqh",
    tafsir: "tafsir",
    tafsir_muhaqqiq: "tafsir",
    tafsir_ahkam: "tafsir",
    tafsir_matsur: "tafsir",
    tafsir_ulumul_quran: "tafsir",
    hadits: "hadits",
    hadits_muhaqqiq: "hadits",
    hadits_takhrij: "hadits",
    hadits_syarah: "hadits",
    hadits_ilal: "hadits",
    aqidah: "aqidah",
    aqidah_kalam: "aqidah",
    aqidah_ushuluddin: "aqidah",
    tarikh: "tarikh",
    tarikh_khulafa: "tarikh",
    tarikh_thabaqat: "tarikh",
    habib_umar: "tasawwuf",
    tasawwuf_ihya: "tasawwuf",
    tasawwuf_adab: "tasawwuf",
    all_ai: "all_access",
};
const TRIAL_QUESTION_LIMIT = 10;
function getEntitlementKey(agentId) {
    const entitlementKey = AGENT_ENTITLEMENTS[agentId];
    if (!entitlementKey) {
        // Fallback jika ada id modul baru
        return agentId;
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
    const entitlements = (userData.entitlements || {});
    // 1. Cek All Access (Paket Lengkap Semua AI)
    const allAccess = entitlements["all_access"];
    if (allAccess && typeof allAccess === "object") {
        const status = allAccess.status;
        const allExpiryVal = allAccess.expiry;
        const allExpiryDate = allExpiryVal
            ? (typeof allExpiryVal.toDate === "function" ? allExpiryVal.toDate() : new Date(allExpiryVal))
            : null;
        // Status revoked langsung menolak akses meskipun expiry belum lewat
        if (status === "active" && allExpiryDate && allExpiryDate > new Date()) {
            return { premiumPlan: true, active: true };
        }
        if (status === "revoked") {
            return { premiumPlan: false, active: false };
        }
    }
    // 2. Cek Modul Spesifik
    const productEntitlement = entitlements[entitlementKey];
    if (productEntitlement && typeof productEntitlement === "object") {
        const status = productEntitlement.status;
        if (status === "revoked" || status !== "active") {
            return { premiumPlan: false, active: false };
        }
        const plan = productEntitlement.plan;
        const expiryValue = productEntitlement.expiry;
        const expiryDate = expiryValue
            ? (typeof expiryValue.toDate === "function" ? expiryValue.toDate() : new Date(expiryValue))
            : null;
        const premiumPlan = typeof plan === "string" &&
            (plan === "tholib" ||
                plan === "bahits" ||
                plan === "premium" ||
                plan === "all_access" ||
                plan === "voucher_access" ||
                plan === "voucher" ||
                plan.startsWith("tholib_") ||
                plan.startsWith("bahits_") ||
                plan.startsWith("voucher_"));
        return {
            premiumPlan,
            active: premiumPlan && expiryDate !== null && !Number.isNaN(expiryDate.getTime()) && expiryDate > new Date(),
        };
    }
    // 3. Legacy fallback HANYA jika userData.plan adalah all_access eksplisit (F01: cegah kebocoran modul tunggal)
    const legacyPlan = userData.plan;
    const isLegacyAllAccess = typeof legacyPlan === "string" && (legacyPlan === "all_access" ||
        legacyPlan === "all_ai_1m" ||
        legacyPlan === "all_ai_6m" ||
        legacyPlan === "all_ai_1y");
    if (isLegacyAllAccess) {
        const expiryValue = userData.subscription_expiry;
        const expiryDate = expiryValue
            ? (typeof expiryValue.toDate === "function" ? expiryValue.toDate() : new Date(expiryValue))
            : null;
        return {
            premiumPlan: true,
            active: expiryDate !== null && !Number.isNaN(expiryDate.getTime()) && expiryDate > new Date(),
        };
    }
    return { premiumPlan: false, active: false };
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
    const agentId = data.agentId;
    if (!agentId) {
        throw new functions.https.HttpsError("invalid-argument", "agentId diperlukan.");
    }
    const url = AGENT_URLS[agentId];
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
        return { url };
    }
    throw new functions.https.HttpsError("permission-denied", "Akses modul riset ini membutuhkan langganan aktif atau kode redeem santri. Silakan berlangganan atau masukkan kode akses untuk melanjutkan.");
});
// ================================================================
// FUNCTION 1b: recordQuestion
// Kuota trial hanya dapat berubah melalui transaksi server-side.
// ================================================================
exports.recordQuestion = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan.");
    }
    const agentId = data.agentId;
    if (!agentId || !AGENT_URLS[agentId]) {
        throw new functions.https.HttpsError("not-found", "Agent tidak ditemukan atau belum aktif.");
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
            throw new functions.https.HttpsError("permission-denied", "Langganan Anda untuk modul ini telah berakhir atau belum memiliki masa berlaku.");
        }
        const questionsUsed = Number.isInteger(userData.questions_used) ? userData.questions_used : 0;
        if (questionsUsed >= TRIAL_QUESTION_LIMIT) {
            throw new functions.https.HttpsError("permission-denied", "Kuota trial Anda telah habis. Berlangganan untuk melanjutkan.");
        }
        const updatedQuestionsUsed = questionsUsed + 1;
        transaction.update(userRef, { questions_used: updatedQuestionsUsed });
        return {
            isPremium: false,
            questionsUsed: updatedQuestionsUsed,
            questionsRemaining: TRIAL_QUESTION_LIMIT - updatedQuestionsUsed,
        };
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
        console.error("[DOKU Config] Peringatan kritis: DOKU_CLIENT_ID atau DOKU_SECRET_KEY belum dikonfigurasi di environment!");
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
    const isAllAi = agentId === "all_ai" || plan.startsWith("all_ai");
    let durationMonths = 1;
    if (plan.includes("1y") || plan.includes("year") || plan === "bahits_1y")
        durationMonths = 12;
    else if (plan.includes("6m") || plan === "tholib_6m")
        durationMonths = 6;
    else
        durationMonths = 1;
    if (isAllAi) {
        const entitlementKey = "all_access";
        if (durationMonths === 12) {
            return { amount: 799000, durationMonths, label: "Paket Lengkap Semua AI (1 Tahun)", entitlementKey };
        }
        else if (durationMonths === 6) {
            return { amount: 499000, durationMonths, label: "Paket Lengkap Semua AI (6 Bulan)", entitlementKey };
        }
        else {
            return { amount: 99000, durationMonths, label: "Paket Promo Semua AI (1 Bulan)", entitlementKey };
        }
    }
    // Masing-masing AI per-modul: Rp 50.000 / bulan
    const entitlementKey = getEntitlementKey(agentId);
    const agentTitle = agentId.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
    if (durationMonths === 12) {
        return { amount: 450000, durationMonths, label: `Modul AI ${agentTitle} (1 Tahun)`, entitlementKey };
    }
    else if (durationMonths === 6) {
        return { amount: 250000, durationMonths, label: `Modul AI ${agentTitle} (6 Bulan)`, entitlementKey };
    }
    else {
        return { amount: 50000, durationMonths, label: `Modul AI ${agentTitle} (1 Bulan)`, entitlementKey };
    }
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
    }
    catch (err) {
        console.error("[createCheckout] DOKU checkout error:", ((_b = err.response) === null || _b === void 0 ? void 0 : _b.data) || err.message);
        throw new functions.https.HttpsError("internal", "Gagal membuat sesi pembayaran DOKU: " + (((_e = (_d = (_c = err.response) === null || _c === void 0 ? void 0 : _c.data) === null || _d === void 0 ? void 0 : _d.error) === null || _e === void 0 ? void 0 : _e.message) || err.message || "Kendala teknis DOKU"));
    }
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
        payment_url: paymentUrl,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
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
    return "Ruang Riset";
}
async function processSuccessfulPayment(invoiceNumber) {
    const txQuery = await db.collection("transactions")
        .where("invoice_number", "==", invoiceNumber)
        .limit(1)
        .get();
    if (txQuery.empty) {
        console.warn(`[Activation] Transaction not found for invoice: ${invoiceNumber}`);
        return { success: false, message: "Transaction not found" };
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
        const uData = uSnap.exists ? uSnap.data() : {};
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
    // Non-blocking trigger helper sharing ke server Cloud Run di luar transaksi
    try {
        notifySubscriptionServer(activationResult.email, "Peneliti", activationResult.plan, "add", activationResult.serviceTitle).then(() => console.log(`[Activation] Provisioning helper triggered for ${activationResult.email}`))
            .catch((e) => console.warn(`[Activation] Provisioning helper background error: ${e.message}`));
    }
    catch (e) {
        console.warn(`[Activation] Could not trigger provisioning helper: ${e.message}`);
    }
    return Object.assign({ success: true }, activationResult);
}
// ================================================================
// FUNCTION 2b: dokuWebhook (HTTP Notification dari DOKU)
// Otomatis aktifkan akses santri di Firestore saat bayar sukses
// ================================================================
exports.dokuWebhook = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onRequest(async (req, res) => {
    var _a, _b;
    try {
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
        const clientId = (headers["client-id"] || headers["Client-Id"] || dokuCfg.clientId);
        const requestId = (headers["request-id"] || headers["Request-Id"] || "");
        const timestamp = (headers["request-timestamp"] || headers["Request-Timestamp"] || "");
        const rawBody = req.rawBody
            ? req.rawBody.toString("utf8")
            : (typeof req.body === "string" ? req.body : JSON.stringify(req.body || {}));
        const expectedSig1 = generateDokuSignature(clientId, requestId, timestamp, req.originalUrl || "/dokuWebhook", rawBody, dokuCfg.secretKey);
        const expectedSig2 = generateDokuSignature(clientId, requestId, timestamp, req.path || "/dokuWebhook", rawBody, dokuCfg.secretKey);
        const expectedSig3 = generateDokuSignature(clientId, requestId, timestamp, "/dokuWebhook", rawBody, dokuCfg.secretKey);
        if (incomingSignature !== expectedSig1 && incomingSignature !== expectedSig2 && incomingSignature !== expectedSig3) {
            console.error(`[DOKU Webhook] Signature mismatch for request ${requestId}`);
            res.status(401).send("Invalid signature");
            return;
        }
        // Verifikasi skew timestamp jika ada (toleransi 15 menit)
        if (timestamp) {
            const reqTime = new Date(timestamp).getTime();
            if (!isNaN(reqTime)) {
                const skewMs = Math.abs(Date.now() - reqTime);
                if (skewMs > 15 * 60 * 1000) {
                    console.warn(`[DOKU Webhook] Request-Timestamp skew terlampau jauh: ${timestamp}`);
                }
            }
        }
        if (!invoiceNumber) {
            console.warn("[DOKU Webhook] Missing invoice_number in notification.");
            res.status(400).send("Missing invoice_number");
            return;
        }
        // F06: State Machine Idempotensi Event (received -> processing -> completed / failed)
        let eventRef = null;
        if (requestId) {
            eventRef = db.collection("webhook_events").doc(requestId);
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
            const actResult = await processSuccessfulPayment(invoiceNumber);
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
    var _a, _b, _c;
    // 0. Wajibkan pengguna terotentikasi
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk memeriksa status pembayaran.");
    }
    const callerUid = context.auth.uid;
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
    if (txData.uid && txData.uid !== callerUid) {
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
            const actResult = await processSuccessfulPayment(invoiceNumber);
            return {
                success: true,
                status: "SUCCESS",
                message: "Pembayaran berhasil diverifikasi! Akses Anda telah aktif.",
                details: actResult
            };
        }
        else {
            return {
                success: false,
                status: trxStatus || "PENDING",
                message: "Pembayaran belum diselesaikan atau masih diproses."
            };
        }
    }
    catch (err) {
        console.error("[checkPaymentStatus] Error checking DOKU status:", ((_b = err.response) === null || _b === void 0 ? void 0 : _b.data) || err.message);
        return {
            success: false,
            status: "PENDING",
            error: ((_c = err.response) === null || _c === void 0 ? void 0 : _c.data) || err.message
        };
    }
});
// ================================================================
// FUNCTION 2d: redeemCode
// Menukarkan Kode Redeem Santri (Voucher Akses 7 Hari, dsb)
// Mengaktifkan entitlement berbatas waktu & trigger email sharing
// ================================================================
exports.redeemCode = functions
    .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
    .https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk menukarkan kode akses.");
    }
    const rawCode = (data.code || "").trim().toUpperCase();
    if (!rawCode) {
        throw new functions.https.HttpsError("invalid-argument", "Kode redeem tidak boleh kosong.");
    }
    const uid = context.auth.uid;
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
        // Periksa apakah pengguna sudah pernah menukarkan kode ini
        const redemptionRef = codeRef.collection("redemptions").doc(uid);
        const redemptionDoc = await transaction.get(redemptionRef);
        if (redemptionDoc.exists) {
            throw new functions.https.HttpsError("already-exists", "Anda sudah pernah menukarkan kode ini sebelumnya.");
        }
        const entitlementKey = codeData.entitlement_key || "fiqh_syafii";
        const durationDays = codeData.duration_days || 7;
        // Ambil user saat ini
        const userRef = db.collection("users").doc(uid);
        const userDoc = await transaction.get(userRef);
        const userData = userDoc.exists ? userDoc.data() : {};
        const entitlements = (userData.entitlements || {});
        const currentEnt = entitlements[entitlementKey];
        let baseDate = new Date();
        if (currentEnt && currentEnt.expiry && currentEnt.status === "active") {
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
            redeemed_at: admin.firestore.FieldValue.serverTimestamp(),
        });
        // 2. Increment pemakaian kode
        transaction.update(codeRef, {
            times_used: timesUsed + 1,
        });
        // 3. Update profil dan entitlement pengguna (F01: isolasi per modul)
        const updatedEntitlements = Object.assign(Object.assign({}, entitlements), { [entitlementKey]: {
                plan: "voucher_access",
                status: "active",
                source: "redeem_code",
                code_id: rawCode.slice(0, 4) + "****", // Redaksi di entitlement
                expiry: admin.firestore.Timestamp.fromDate(newExpiry),
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            } });
        const userUpdate = {
            entitlements: updatedEntitlements,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        };
        // Hanya set plan global jika voucher adalah all_access
        if (entitlementKey === "all_access") {
            userUpdate.plan = "voucher_access";
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
            plan: "voucher_access",
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
    // F11: Trigger helper sharing background non-blocking
    try {
        notifySubscriptionServer(redeemResult.email, redeemResult.name, "voucher_access", "add", redeemResult.serviceTitle).then(() => console.log(`[Redeem] Provisioning helper triggered for ${redeemResult.email}`))
            .catch((e) => console.warn(`[Redeem] Provisioning helper error: ${e.message}`));
    }
    catch (e) {
        console.warn(`[Redeem] Could not trigger provisioning helper: ${e.message}`);
    }
    return {
        success: true,
        entitlementKey: redeemResult.entitlementKey,
        durationDays: redeemResult.durationDays,
        expiry: redeemResult.expiryIso,
        message: `Kode diterima. Akses ruang riset ${redeemResult.serviceTitle} telah aktif.`,
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
    var _a, _b;
    try {
        const userData = snapshot.data();
        const email = userData.email;
        const uid = context.params.uid;
        if (!email || typeof email !== "string" || !email.includes("@"))
            return null;
        // Verifikasi bahwa user bukan akun anonim via Firebase Auth record
        const userRecord = await admin.auth().getUser(uid).catch(() => null);
        if (!userRecord || userRecord.providerData.length === 0 || ((_a = userRecord.email) === null || _a === void 0 ? void 0 : _a.toLowerCase()) !== email.toLowerCase()) {
            console.warn(`onUserCreate: Melewati klaim transaksi untuk akun anonim/tidak terverifikasi: ${uid}`);
            return null;
        }
        console.log(`onUserCreate: Checking verified transactions for email: ${email}`);
        // Cari semua transaksi sukses untuk email ini
        const trxQuery = await db
            .collection("transactions")
            .where("customer_email", "==", email.toLowerCase())
            .where("status", "in", ["success", "paid"])
            .get();
        if (trxQuery.empty) {
            console.log(`onUserCreate: No successful transactions found for ${email}`);
            return null;
        }
        // Kumpulkan seluruh entitlement modul yang aktif dan cari tanggal kedaluwarsa terjauh
        let latestTrxDoc = trxQuery.docs[0];
        let latestExpiry = latestTrxDoc.data().subscription_expires_at;
        const entitlements = {};
        const now = new Date();
        let hasActive = false;
        for (const doc of trxQuery.docs) {
            const txData = doc.data();
            const expiry = txData.subscription_expires_at;
            const entKey = txData.entitlement_key || getEntitlementKey(txData.agent_id || "fiqh_tahawwulat");
            // Hubungkan kembali UID ke dokumen transaksi jika belum terhubung
            if (!txData.uid) {
                await doc.ref.update({ uid: uid });
            }
            if (expiry && expiry.toDate() > now) {
                hasActive = true;
                const currentEnt = entitlements[entKey];
                if (!currentEnt || expiry.toDate() > currentEnt.expiry.toDate()) {
                    entitlements[entKey] = {
                        plan: txData.plan || "premium",
                        status: "active",
                        expiry: expiry,
                        updated_at: admin.firestore.FieldValue.serverTimestamp(),
                    };
                }
            }
            if (expiry && (!latestExpiry || expiry.toDate() > latestExpiry.toDate())) {
                latestTrxDoc = doc;
                latestExpiry = expiry;
            }
        }
        if (hasActive && latestExpiry && latestExpiry.toDate() > now) {
            const latestTrxData = latestTrxDoc.data();
            console.log(`onUserCreate: Activating plan ${latestTrxData.plan} and entitlements for user ${uid}`);
            await snapshot.ref.update({
                plan: latestTrxData.plan || "premium",
                subscription_expiry: latestExpiry,
                entitlements: entitlements,
                questions_used: 0,
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Pastikan latestTrxDoc juga terhubung
            if (!latestTrxData.uid) {
                await latestTrxDoc.ref.update({ uid: uid });
            }
            // F13: Kirim per-scope entitlement, jangan broadcast semua 6 layanan
            for (const entKey of Object.keys(entitlements)) {
                try {
                    await notifySubscriptionServer(email, userData.name || "User", ((_b = entitlements[entKey]) === null || _b === void 0 ? void 0 : _b.plan) || latestTrxData.plan, "add", getServiceTitleForEntitlement(entKey));
                }
                catch (err) {
                    console.error(`Failed to notify subscription server in onUserCreate for ${entKey}:`, err.message);
                }
            }
            await db.collection("sharing_log").add({
                email,
                uid,
                action: "add",
                method: "on_user_create_sync",
                entitlements: Object.keys(entitlements),
                created_at: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        else {
            console.log(`onUserCreate: Found transactions for ${email} but they are already expired`);
        }
    }
    catch (err) {
        console.error("Error in onUserCreate trigger:", err);
    }
    return null;
});
// ================================================================
// FUNCTION 4: dailyRevoke (Cron Job — tiap tengah malam)
// ================================================================
exports.dailyRevoke = functions
    .runWith({
    serviceAccount: "open-turath@appspot.gserviceaccount.com",
    timeoutSeconds: 300,
})
    .pubsub.schedule("0 0 * * *")
    .timeZone("Asia/Jakarta")
    .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const expiredUsers = await db
        .collection("users")
        .where("subscription_expiry", "<=", now)
        .get();
    if (expiredUsers.empty) {
        console.log("✅ No expired subscriptions found.");
        return null;
    }
    console.log(`🔄 Memproses ${expiredUsers.size} user expired...`);
    for (const doc of expiredUsers.docs) {
        const userData = doc.data();
        const plan = userData.plan || "";
        // F12: Perluas whitelist plan agar mencakup all_ai dan voucher_access
        const eligiblePlans = [
            "tholib", "bahits", "tholib_1m", "tholib_6m", "bahits_1y",
            "premium", "all_access", "all_ai_1m", "all_ai_6m", "all_ai_1y",
            "voucher_access", "voucher"
        ];
        if (!eligiblePlans.includes(plan)) {
            continue;
        }
        const email = userData.email;
        // Revoke modular entitlements jika expired
        const entitlements = userData.entitlements || {};
        let hasExpiredEntitlement = false;
        const updatedEntitlements = Object.assign({}, entitlements);
        const expiredKeys = [];
        for (const [key, val] of Object.entries(entitlements)) {
            if (val && typeof val === "object") {
                const item = val;
                const exp = item.expiry
                    ? (typeof item.expiry.toDate === "function" ? item.expiry.toDate() : new Date(item.expiry))
                    : null;
                if (exp && exp <= now.toDate() && item.status !== "expired") {
                    updatedEntitlements[key] = Object.assign(Object.assign({}, item), { status: "expired", updated_at: admin.firestore.FieldValue.serverTimestamp() });
                    hasExpiredEntitlement = true;
                    expiredKeys.push(key);
                }
            }
        }
        // F12: Cek apakah masih ada entitlement lain yang aktif sebelum mereset plan global ke trial
        let hasRemainingActive = false;
        for (const val of Object.values(updatedEntitlements)) {
            if (val && typeof val === "object") {
                const item = val;
                const exp = item.expiry
                    ? (typeof item.expiry.toDate === "function" ? item.expiry.toDate() : new Date(item.expiry))
                    : null;
                if (item.status === "active" && exp && exp > now.toDate()) {
                    hasRemainingActive = true;
                    break;
                }
            }
        }
        const updateData = {};
        if (hasExpiredEntitlement) {
            updateData.entitlements = updatedEntitlements;
        }
        // HANYA reset global plan jika TIDAK ADA modul lain yang aktif!
        if (!hasRemainingActive) {
            updateData.plan = "trial";
            updateData.subscription_expiry = null;
            updateData.questions_used = 0;
        }
        if (Object.keys(updateData).length > 0) {
            await doc.ref.update(updateData);
        }
        if (email && expiredKeys.length > 0) {
            for (const expiredKey of expiredKeys) {
                console.log(`🔒 Akses modul ${expiredKey} berakhir untuk ${email}.`);
                try {
                    await notifySubscriptionServer(email, userData.name || "User", "trial", "remove", getServiceTitleForEntitlement(expiredKey));
                }
                catch (err) {
                    console.error(`Failed to notify subscription server in dailyRevoke for ${expiredKey}:`, err.message);
                }
                await db.collection("sharing_log").add({
                    email,
                    uid: doc.id,
                    action: "remove",
                    entitlement_key: expiredKey,
                    method: "daily_revoke_scheduler",
                    created_at: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        }
    }
    console.log(`✅ Selesai memproses ${expiredUsers.size} expired subscriptions.`);
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
                console.error("INTERNAL_SECRET not set! Skipping notification.");
                return;
            }
            await axios_1.default.post(url, payload, {
                headers: {
                    "Content-Type": "application/json",
                    "X-Internal-Secret": internalSecret
                },
            });
            console.log(`Successfully notified subscription server: ${action} ${email} for ${service}`);
        }
        catch (err) {
            console.error(`Failed to notify subscription server for ${service}:`, err.message);
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
        const hasAccess = await verifySubscriptionFirestore(session.email, agent.entitlementKey);
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
    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        email = (decodedToken.email || "").trim().toLowerCase();
        if (!email) {
            res.redirect(`/login?ref=${ref}&error=unverified_email`);
            return;
        }
    }
    catch (err) {
        console.error(`[Auth] Gagal memverifikasi idToken Firebase: ${err.message}`);
        res.redirect(`/login?ref=${ref}&error=invalid_token`);
        return;
    }
    if (!apiKey) {
        console.error("AKAL_API_KEY tidak diset di Functions!");
        res.status(500).send("Server configuration error.");
        return;
    }
    const agent = AGENTS[ref] || AGENTS["fikih-tahawwulat-muhaqqiq"];
    const akalCuid = agent.akalCuid;
    const entitlementKey = agent.entitlementKey || "fiqh_tahawwulat";
    const isSubscriber = await verifySubscriptionHybrid(email, entitlementKey, akalCuid, apiKey);
    if (isSubscriber) {
        const payload = JSON.stringify({ email, iat: Date.now() });
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
async function verifySubscriptionFirestore(email, entitlementKey) {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    // A. Check if user document exists and has active entitlement
    const userQuery = await db.collection("users").where("email", "==", email).limit(1).get();
    if (!userQuery.empty) {
        const userData = userQuery.docs[0].data();
        const entitlements = (userData.entitlements || {});
        // 1. Cek specific entitlement (F02: status wajib active dan bukan revoked)
        const ent = entitlements[entitlementKey];
        if (ent && ent.expiry) {
            if (ent.status === "active" && ent.status !== "revoked" && ent.expiry.toDate() > new Date()) {
                return true;
            }
        }
        // 2. Cek all_access entitlement
        const allAccess = entitlements["all_access"];
        if (allAccess && allAccess.expiry) {
            if (allAccess.status === "active" && allAccess.status !== "revoked" && allAccess.expiry.toDate() > new Date()) {
                return true;
            }
        }
        // 3. Legacy all-access fallback (F01: hanya untuk plan all_access eksplisit)
        const legacyPlan = userData.plan;
        const isAllAccess = typeof legacyPlan === "string" && (legacyPlan === "all_access" ||
            legacyPlan === "all_ai_1m" ||
            legacyPlan === "all_ai_6m" ||
            legacyPlan === "all_ai_1y");
        if (isAllAccess && userData.subscription_expiry) {
            if (userData.subscription_expiry.toDate() > new Date()) {
                return true;
            }
        }
    }
    // B. Check if there is a successful transaction in Firestore
    const txQuery = await db.collection("transactions")
        .where("customer_email", "==", email)
        .where("status", "in", ["success", "paid"])
        .get();
    if (!txQuery.empty) {
        for (const doc of txQuery.docs) {
            const tx = doc.data();
            const expiresAt = tx.subscription_expires_at;
            const txEntitlement = tx.entitlement_key || "fiqh_tahawwulat";
            if (txEntitlement === entitlementKey && expiresAt && expiresAt.toDate() > new Date()) {
                // Auto-initialize user doc if they exist in transactions but not in users collection
                let userRef;
                let userData = {};
                if (!userQuery.empty) {
                    userRef = userQuery.docs[0].ref;
                    userData = userQuery.docs[0].data();
                }
                else {
                    // If no doc exists, create one with auto-generated ID
                    userRef = db.collection("users").doc();
                }
                const expiryDate = expiresAt.toDate();
                const plan = tx.plan || "tholib_1m";
                await userRef.set({
                    email: email,
                    name: userData.name || tx.customer_name || "User",
                    plan: plan,
                    subscription_expiry: expiryDate,
                    entitlements: Object.assign(Object.assign({}, userData.entitlements), { [entitlementKey]: {
                            plan: plan,
                            expiry: expiryDate,
                            updated_at: now
                        } }),
                    questions_used: userData.questions_used || 0,
                    created_at: userData.created_at || now,
                    updated_at: now
                }, { merge: true });
                console.log(`[Auth] Auto-registered/updated user document for ${email} based on active transaction.`);
                return true;
            }
        }
    }
    return false;
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
        if (sigB64 !== expectedSig)
            return null;
        const payloadStr = Buffer.from(payloadB64, "base64url").toString("utf8");
        const payload = JSON.parse(payloadStr);
        if (Date.now() - payload.iat > COOKIE_MAX_AGE * 1000)
            return null;
        return { email: payload.email };
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
  <h1>AI Islamiyah</h1>
  <p class="subtitle">Masukkan email langganan Anda</p>
  <div class="card">
    ${errorHTML}
    <form method="POST" action="/login">
      <input type="hidden" name="ref" value="${escapeHtml(ref)}">
      <input type="hidden" name="csrf_token" value="${escapeHtml(csrfToken)}">
      <label for="email">Alamat Email</label>
      <input type="email" id="email" name="email" placeholder="nama@email.com" required autocomplete="email">
      <button type="submit">Masuk ke Ruang Belajar →</button>
    </form>
  </div>
  <p class="footer">Belum berlangganan? Silakan berlangganan melalui aplikasi resmi OpenTurath AI</p>
</body>
</html>`;
}
function getChatWrapperHTML(agent, agentId, email) {
    const chatUrl = `https://notebooklm.google.com/notebook/${agent.notebookId}/preview`;
    let descHtml = "";
    let promptsHtml = "";
    if (agentId === "fiqh_tahawwulat") {
        descHtml = `<p>Ruang riset **Fikih Tahawwulat** dirancang untuk menelaah kaidah fikih tanda zaman dan krisis peradaban berdasarkan karya rujukan ulama terkait.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Jelaskan konsep Al-Ghuthsa’iyyah (era buih) berdasarkan penjelasan kitab!')">
        Jelaskan konsep Al-Ghuthsa’iyyah 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Apa rukun keempat dalam metodologi Fikih Tahawwulat?')">
        Rukun keempat Fikih Tahawwulat 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana kaidah menyikapi fitnah akhir zaman?')">
        Menyikapi fitnah akhir zaman 📋
      </div>
    `;
    }
    else if (agentId === "fiqh_syafii") {
        descHtml = `<p>Ruang riset **Fikih Syafi'i** memuat korpus naskah primer mazhab Syafi'i untuk penelaahan masalah ibadah, muamalah, dan fatwa para ashab al-wujuh dan muta'akhkhirin.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Bagaimana rukun wudhu menurut qaul mu’tamad mazhab Syafi’i?')">
        Rukun wudhu mu'tamad Syafi'i 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Jelaskan syarat sah shalat berjamaah menurut naskah Minhaj ath-Thalibin!')">
        Syarat shalat berjamaah di Minhaj 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana ketentuan zakat perniagaan dalam fatwa Imam An-Nawawi?')">
        Zakat perniagaan menurut An-Nawawi 📋
      </div>
    `;
    }
    else if (agentId === "hadits") {
        descHtml = `<p>Ruang riset **Hadis & Syarah** memuat himpunan kutubus sittah dan syarah hadis induk untuk verifikasi matan, takhrij, dan faedah hukum nabawi.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Bagaimana penjelasan syarah hadis tentang niat dalam Fathul Bari?')">
        Syarah hadis niat di Fathul Bari 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana kedudukan perawi dan sanad pada riwayat ini?')">
        Takhrij sanad dan faedah hadis 📋
      </div>
    `;
    }
    else {
        descHtml = `<p>Ruang riset **${escapeHtml(agent.label || "Naskah Turats")}** menyediakan fasilitas telaah cerdas terhadap naskah rujukan keilmuan Islam.</p>`;
        promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Sebutkan pokok bahasan utama pada bab ini beserta dalilnya!')">
        Pokok bahasan bab & dalil 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana perbandingan pendapat para ulama dalam masalah ini?')">
        Perbandingan pendapat ulama 📋
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
        <div class="section-title">Pilih Modul AI</div>
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
          🚀 Buka Layar Penuh
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
        <div class="section-title">Tentang ruang ini</div>
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
      
      <a href="mailto:support@openturath.com" class="btn-help">
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
        toast.innerText = 'Pertanyaan disalin! Silakan tempel (paste) ke kolom chat NotebookLM.';
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
//# sourceMappingURL=index.js.map