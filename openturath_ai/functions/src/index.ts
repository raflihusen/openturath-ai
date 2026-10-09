import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import * as crypto from "crypto";
import {AccessControl, AccessFault, isVip, keyOf, millis, billingExpiry} from "./access_control";
import {AGENT_ENTITLEMENTS, ENTITY_SCOPES} from "./access_catalog";
import { handleNativeChat, NativeChatError } from "./native_chat";
import {
  NOTEBOOK_ENTITIES,
  AGENT_TO_ENTITY,
  resolveAgentNotebook,
} from "./notebook_catalog";

admin.initializeApp();
const db = admin.firestore();

// ================================================================
// TELEGRAM NOTIFICATION HELPER
// ================================================================
async function sendTelegramNotification(text: string): Promise<void> {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_CHAT_ID;
  if (!token || !chatId) return;

  try {
    await axios.post(
      `https://api.telegram.org/bot${token}/sendMessage`,
      {
        chat_id: chatId,
        text,
        parse_mode: "HTML",
      },
      { timeout: 5000 }
    );
  } catch (err: any) {
    console.error("[Telegram] Failed to send notification:", err?.message || err);
  }
}


// ================================================================
// HARGA & DURASI OTORITATIF — Ditentukan oleh `resolvePlanPricing`
// ================================================================

// URL NotebookLM — Inisialisasi otomatis dari Katalog 24 Entitas OpenTurath
const AGENT_URLS: Record<string, string> = {};
for (const [agentId, entityCode] of Object.entries(AGENT_TO_ENTITY)) {
  const entity = NOTEBOOK_ENTITIES[entityCode];
  if (entity) {
    AGENT_URLS[agentId] = entity.masterUrl;
  }
}

// Mapping eksplisit mencegah agent baru "jatuh" ke entitlement default dan
// tidak sengaja terbuka oleh langganan modul lain.
// Whitelist modul yang diizinkan untuk dibeli via checkout payment (OT-F001)
export const PURCHASABLE_AGENTS = new Set([
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

export const MODULE_PLANS: Record<string, { amount: number; durationMonths: number; labelSuffix: string }> = {
  tholib_1m: { amount: 50000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
  tholib_6m: { amount: 299000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
  bahits_1y: { amount: 499000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
  "1m": { amount: 50000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
  "6m": { amount: 299000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
  "1y": { amount: 499000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
};

function getEntitlementKey(agentId: string): string {
  const entitlementKey = AGENT_ENTITLEMENTS[agentId];
  if (!entitlementKey) {
    // OT-F001: Jangan pernah mengembalikan input mentah client untuk mencegah privilege escalation
    return "";
  }
  return entitlementKey;
}

export function addCalendarMonthsClamped(baseDate: Date, months: number): Date {
  const result = new Date(baseDate.getTime());
  const originalDay = result.getDate();
  result.setDate(1);
  result.setMonth(result.getMonth() + months);
  const maxDays = new Date(result.getFullYear(), result.getMonth() + 1, 0).getDate();
  result.setDate(Math.min(originalDay, maxDays));
  return result;
}

function getEntitlementAccess(userData: FirebaseFirestore.DocumentData, entitlementKey: string): { premiumPlan: boolean; active: boolean } {
  if (isVip(userData)) return {premiumPlan:true,active:true};
  if (userData.account_deleted === true) return {premiumPlan:false,active:false};
  const entitlements = userData.entitlements && typeof userData.entitlements === "object"
    ? userData.entitlements as Record<string, any> : {};
  const now = Date.now();
  const active = (ent: any): boolean => {
    if (!ent || typeof ent.plan !== "string") return false;
    if (ent.status === "revoked" || ent.status === "expired") return false;
    const allowed = /^(trial|tholib(?:_1m|_6m)?|bahits(?:_1y)?|premium|all_access|all_ai.*|single|sultan|pro|voucher(?:_.*)?|redeem(?:_.*)?|custom|full)$/.test(ent.plan);
    const expiry = ent.expiry?.toDate ? ent.expiry.toDate() : (ent.expiry?._seconds ? new Date(ent.expiry._seconds * 1000) : new Date(ent.expiry ?? ""));
    return allowed && Number.isFinite(expiry.getTime()) && expiry.getTime() > now;
  };
  const all = entitlements.all_access ?? entitlements.all_ai;
  if (active(all)) return { premiumPlan: true, active: true };
  const specific = entitlements[entitlementKey];
  if (active(specific)) return { premiumPlan: true, active: true };

  // Only explicit revocation of all_access blocks global subscription fallback
  if (all && all.status === "revoked") {
    return { premiumPlan: true, active: false };
  }

  // Account-level active subscription
  const expiry = userData.subscription_expiry?.toDate
    ? userData.subscription_expiry.toDate() : new Date(userData.subscription_expiry ?? "");
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
export const getAgentUrl = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Login diperlukan untuk mengakses agent."
      );
    }

    const uid = context.auth.uid;
    await enforceRateLimit(
      `agent_url_${uid}`,
      60,
      60,
      "Terlalu banyak permintaan membuka asisten. Silakan coba kembali sebentar lagi."
    );
    const agentId = data.agentId as string;

    if (!agentId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "agentId diperlukan."
      );
    }

    const resolved = resolveAgentNotebook(agentId, uid);
    const url = resolved ? resolved.url : AGENT_URLS[agentId];
    if (!url) {
      throw new functions.https.HttpsError(
        "not-found",
        "Agent tidak ditemukan atau belum aktif."
      );
    }

    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User tidak ditemukan.");
    }

    const userData = userDoc.data()!;
    if (userData.access_version === 2) {
      const entity = AGENT_TO_ENTITY[agentId];
      if (!entity) throw new functions.https.HttpsError("not-found", "Kajian tidak ditemukan.");
      try { return await new AccessControl(db, NOTEBOOK_ENTITIES, ENTITY_SCOPES).resolve(uid, entity); }
      catch (e) {
        if (e instanceof AccessFault) throw new functions.https.HttpsError(e.code as functions.https.FunctionsErrorCode, e.message);
        throw e;
      }
    }
    const questionsUsed = (userData.questions_used as number) || 0;
    const entitlementKey = getEntitlementKey(agentId);

    const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
    if (entitlementAccess.active) {
      return {
        url,
        notebookId: resolved?.notebookId,
        cloneName: resolved?.cloneName,
        entityCode: resolved?.entityCode,
        isMaster: resolved?.isMaster,
      };
    }

    throw new functions.https.HttpsError(
      "permission-denied",
      "Akses modul riset ini membutuhkan langganan aktif atau kode redeem santri. Silakan berlangganan atau masukkan kode akses untuk melanjutkan."
    );
  });

// ================================================================
// FUNCTION 1b: recordQuestion
// Trial sekarang berbasis masa berlaku voucher, bukan kuota pertanyaan.
// ================================================================
export const recordQuestion = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login diperlukan.");
    }
    const agentId = data.agentId as string;
    const resolved = resolveAgentNotebook(agentId);
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
      const userData = snapshot.data()!;
      const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
      if (entitlementAccess.active) {
        return { isPremium: true, questionsUsed: userData.questions_used || 0, questionsRemaining: null };
      }
      if (entitlementAccess.premiumPlan) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Langganan Anda untuk kajian ini telah berakhir."
        );
      }

      throw new functions.https.HttpsError(
        "permission-denied",
        "Akses Pro untuk kajian ini belum aktif. Tukarkan voucher atau berlangganan untuk melanjutkan."
      );
    });
  });

// Native chat prototype. Enabling this requires a dedicated operator session,
// an isolated test notebook and an explicitly configured test UID.
export const askAgent = functions
  .runWith({
    serviceAccount: "open-turath@appspot.gserviceaccount.com",
    secrets: ["NOTEBOOK_BRIDGE_KEY"],
    timeoutSeconds: 120,
    maxInstances: 1,
  })
  .https.onCall(async (data, context) => {
    if (context.auth) {
      const header = context.rawRequest.headers.authorization;
      try {
        if (!header?.startsWith("Bearer ")) throw new Error("Missing token");
        const verified = await admin.auth().verifyIdToken(header.slice(7), true);
        if (verified.uid !== context.auth.uid) throw new Error("Identity mismatch");
      } catch (_) {
        throw new functions.https.HttpsError("unauthenticated", "Silakan masuk kembali ke OpenTurath.");
      }
    }
    try {
      return await handleNativeChat(data, context.auth?.uid, {
        testUid: process.env.NOTEBOOK_BRIDGE_TEST_UID,
        authorize: async (uid, agentId) => {
          const key = getEntitlementKey(agentId);
          if (!key || !AGENT_URLS[agentId]) return false;
          const snapshot = await db.collection("users").doc(uid).get();
          return snapshot.exists && getEntitlementAccess(snapshot.data()!, key).active;
        },
        rateLimit: uid => enforceRateLimit(`native_chat_${uid}`, 10, 60, "Terlalu banyak pertanyaan. Silakan tunggu sebentar."),
        ask: async request => {
          const endpoint = process.env.NOTEBOOK_BRIDGE_URL;
          const key = process.env.NOTEBOOK_BRIDGE_KEY;
          if (!endpoint || !key || key.length < 32) {
            throw new NativeChatError("failed-precondition", "Koneksi asisten di aplikasi belum diaktifkan.");
          }
          const url = new URL(endpoint);
          const local = process.env.FUNCTIONS_EMULATOR === "true" &&
            url.protocol === "http:" && ["127.0.0.1", "localhost"].includes(url.hostname);
          if ((!local && url.protocol !== "https:") || url.username || url.password || url.search || url.hash || url.pathname !== "/ask") {
            throw new NativeChatError("failed-precondition", "Konfigurasi koneksi asisten belum valid.");
          }
          const response = await axios.post(url.toString(), request, {
            headers: {Authorization: `Bearer ${key}`},
            timeout: 80000,
            maxRedirects: 0,
            maxContentLength: 512000,
            maxBodyLength: 40000,
          });
          return response.data;
        },
      });
    } catch (error) {
      if (error instanceof NativeChatError) {
        throw new functions.https.HttpsError(error.code, error.message);
      }
      if (error instanceof functions.https.HttpsError) throw error;
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

function generateDokuSignature(
  clientId: string,
  requestId: string,
  timestamp: string,
  targetPath: string,
  rawBody: string,
  secretKey: string
): string {
  const digest = crypto.createHash("sha256").update(rawBody).digest("base64");
  const signatureComponent =
    `Client-Id:${clientId}\n` +
    `Request-Id:${requestId}\n` +
    `Request-Timestamp:${timestamp}\n` +
    `Request-Target:${targetPath}\n` +
    `Digest:${digest}`;
  const hmac = crypto.createHmac("sha256", secretKey).update(signatureComponent).digest("base64");
  return `HMACSHA256=${hmac}`;
}

function resolvePlanPricing(agentId: string, plan: string): { amount: number; durationMonths: number; label: string; entitlementKey: string } {
  const isAllAi = agentId === "all_ai" || agentId === "all_access" || plan.startsWith("all_ai") || plan.startsWith("all_access");

  if (isAllAi) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Paket Semua AI sementara dinonaktifkan. Silakan pilih paket per modul spesialis."
    );
  }

  // OT-F001: Closed-set whitelist enforcement
  if (!PURCHASABLE_AGENTS.has(agentId)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Modul spesialis tidak valid atau tidak dapat dibeli."
    );
  }

  // Harga Mandiri Khusus Fikih Tahawwulat
  if (agentId.startsWith("fiqh_tahawwulat")) {
    const tahawwulatTiers: Record<string, { amount: number; durationMonths: number; labelSuffix: string }> = {
      tholib_1m: { amount: 300000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
      tholib_6m: { amount: 1499000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
      bahits_1y: { amount: 1999000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
      "1m": { amount: 300000, durationMonths: 1, labelSuffix: "(1 Bulan)" },
      "6m": { amount: 1499000, durationMonths: 6, labelSuffix: "(6 Bulan)" },
      "1y": { amount: 1999000, durationMonths: 12, labelSuffix: "(1 Tahun)" },
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

  const tier = MODULE_PLANS[plan];
  if (!tier) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Paket langganan tidak valid."
    );
  }

  const entitlementKey = getEntitlementKey(agentId);
  if (!entitlementKey || entitlementKey === "all_access" || entitlementKey === "all_ai") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Entitlement untuk modul ini tidak valid atau dinonaktifkan."
    );
  }

  const agentTitle = agentId.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
  return {
    amount: tier.amount,
    durationMonths: tier.durationMonths,
    label: `Modul AI ${agentTitle} ${tier.labelSuffix}`,
    entitlementKey,
  };
}

async function requestDokuCheckout(params: {
  invoiceNumber: string;
  amount: number;
  itemName: string;
  customerName: string;
  customerEmail: string;
  customerPhone: string;
}): Promise<string> {
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
  const signature = generateDokuSignature(
    clientId,
    requestId,
    timestamp,
    targetPath,
    rawJson,
    secretKey
  );

  console.log(`[DOKU API] Requesting Checkout for ${params.invoiceNumber} (${params.itemName}) - Rp ${params.amount}...`);
  const response = await axios.post(`${baseUrl}${targetPath}`, requestBody, {
    headers: {
      "Client-Id": clientId,
      "Request-Id": requestId,
      "Request-Timestamp": timestamp,
      "Signature": signature,
      "Content-Type": "application/json"
    },
    timeout: 15000
  });

  const paymentUrl = response.data?.response?.payment?.url || response.data?.payment?.url;
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

async function requestMidtransSnapCheckout(params: {
  invoiceNumber: string;
  amount: number;
  itemName: string;
  planId: string;
  customerName: string;
  customerEmail: string;
  customerPhone: string;
}): Promise<{ token: string; redirectUrl: string }> {
  const cfg = getMidtransConfig();
  const authHeader = "Basic " + Buffer.from(cfg.serverKey + ":").toString("base64");

  const payload: Record<string, any> = {
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
  const response = await axios.post(cfg.snapUrl, payload, {
    headers: {
      "Authorization": authHeader,
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    timeout: 15000,
  });

  const token = response.data?.token;
  const redirectUrl = response.data?.redirect_url;
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
async function enforceRateLimit(
  key: string,
  limit: number,
  windowSeconds: number,
  errorMessage: string
): Promise<void> {
  const now = Date.now();
  const rateLimitRef = db.collection("rate_limits").doc(key);

  await db.runTransaction(async (t) => {
    const snap = await t.get(rateLimitRef);
    if (!snap.exists) {
      t.set(rateLimitRef, {
        count: 1,
        reset_at: admin.firestore.Timestamp.fromMillis(now + windowSeconds * 1000),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const data = snap.data()!;
    const resetAt = data.reset_at?.toMillis ? data.reset_at.toMillis() : (data.reset_at || 0);

    if (now > resetAt) {
      // Window reset
      t.set(rateLimitRef, {
        count: 1,
        reset_at: admin.firestore.Timestamp.fromMillis(now + windowSeconds * 1000),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    const currentCount = (data.count || 0) as number;
    if (currentCount >= limit) {
      const waitSec = Math.ceil((resetAt - now) / 1000);
      throw new functions.https.HttpsError(
        "resource-exhausted",
        `${errorMessage} Harap tunggu ${waitSec} detik lagi.`
      );
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
export const createCheckout = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Login diperlukan untuk melakukan transaksi."
      );
    }
    const { plan, name, email, phone, agentId, expectedAmount, pricingRevision } = data;

    if (!plan || !name || !email) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Data tidak lengkap (nama dan email diperlukan)."
      );
    }

    const currentAgentId = typeof agentId === "string" && agentId ? agentId : "fiqh_tahawwulat";
    const pricing = resolvePlanPricing(currentAgentId, plan as string);
    // Reject stale offers before creating any invoice or contacting the gateway.
    if (expectedAmount !== undefined &&
        (!Number.isSafeInteger(expectedAmount) || expectedAmount !== pricing.amount ||
         pricingRevision !== "perdana-2026-09-20")) {
      throw new functions.https.HttpsError("failed-precondition", "Harga penawaran telah berubah. Muat ulang aplikasi.");
    }
    const invoiceNumber = `OT-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;

    const trxRef = db.collection("transactions").doc();
    const trxId = trxRef.id;
    const uid = context.auth?.uid || null;

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

    let paymentUrl = "";
    let snapToken = "";
    try {
      const snapRes = await requestMidtransSnapCheckout({
        invoiceNumber,
        amount: pricing.amount,
        itemName: pricing.label,
        planId: plan as string,
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
    } catch (err: any) {
      console.error("[createCheckout] Midtrans checkout error:", err.response?.data || err.message);
      await trxRef.update({
        status: "failed",
        error: err.response?.data?.error_messages?.join(", ") || err.message || "Kendala teknis Midtrans",
        failed_at: admin.firestore.FieldValue.serverTimestamp(),
      }).catch(() => {});
      throw new functions.https.HttpsError(
        "internal",
        "Gagal membuat sesi pembayaran Midtrans: " + (err.response?.data?.error_messages?.join(", ") || err.message || "Kendala teknis Midtrans")
      );
    }

    return {
      redirectUrl: paymentUrl,
      paymentUrl: paymentUrl,
      snapToken: snapToken,
      trxId,
      invoiceNumber,
      amount: pricing.amount,
      pricingRevision: "perdana-2026-09-20"
    };
  });

function generateDokuGetSignature(
  clientId: string,
  requestId: string,
  timestamp: string,
  targetPath: string,
  secretKey: string
): string {
  const component = `Client-Id:${clientId}\nRequest-Id:${requestId}\nRequest-Timestamp:${timestamp}\nRequest-Target:${targetPath}`;
  const hmac = crypto.createHmac("sha256", secretKey).update(component).digest("base64");
  return `HMACSHA256=${hmac}`;
}

function getServiceTitleForEntitlement(entitlementKey: string): string {
  if (entitlementKey === "all_access" || entitlementKey === "all_ai") return "Paket Semua AI";
  if (entitlementKey === "fiqh_tahawwulat") return "AI Fikih Tahawwulat";
  if (entitlementKey === "fiqh_syafii") return "AI Fikih Syafi'i";
  if (entitlementKey === "fiqh_hanafi") return "AI Fikih Hanafi";
  if (entitlementKey === "fiqh_maliki") return "AI Fikih Maliki";
  if (entitlementKey === "fiqh_hanbali") return "AI Fikih Hanbali";
  if (entitlementKey === "fiqh_muqaran") return "AI Fikih Perbandingan Mazhab";
  if (entitlementKey === "ushul_fiqh") return "AI Ushul Fiqih";
  if (entitlementKey === "tafsir") return "AI Tafsir";
  if (entitlementKey === "hadits") return "AI Hadits";
  if (entitlementKey === "nahwu" || entitlementKey === "bahasa_arab" || entitlementKey === "nahwu_sharaf") return "AI Bahasa Arab";
  if (entitlementKey === "aqidah" || entitlementKey === "aqidah_kalam" || entitlementKey === "aqidah_ushuluddin") return "AI Aqidah & Ushuluddin";
  if (entitlementKey === "tarikh" || entitlementKey === "tarikh_khulafa" || entitlementKey === "tarikh_thabaqat" || entitlementKey === "sirah") return "AI Tarikh & Sirah Nabawiyah";
  if (entitlementKey === "tasawwuf" || entitlementKey === "habib_umar" || entitlementKey === "tasawwuf_ihya" || entitlementKey === "tasawwuf_adab") return "AI Tasawwuf & Tazkiyatun Nafs";
  return "Modul kajian";
}

async function processSuccessfulPayment(invoiceNumber: string, paidAmount: unknown, gatewayEvidence?: {transactionId: string; orderId: string; currency?: string}) {
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
    const txData = txSnap.data()!;
    const amount = typeof paidAmount === "string" && /^\d+(?:\.0+)?$/.test(paidAmount)
      ? Number(paidAmount) : paidAmount;
    if (!Number.isSafeInteger(amount) || (amount as number) <= 0 || amount !== txData.amount) {
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

    const receiptRef = gatewayEvidence ? db.collection("payment_receipts").doc(keyOf("midtrans", gatewayEvidence.transactionId)) : null;
    if (gatewayEvidence) {
      if (gatewayEvidence.orderId !== invoiceNumber || (gatewayEvidence.currency && gatewayEvidence.currency !== "IDR") ||
          typeof gatewayEvidence.transactionId !== "string" || !/^[a-zA-Z0-9_-]{1,128}$/.test(gatewayEvidence.transactionId)) throw new Error("Invalid gateway identity");
      const receipt = (await t.get(receiptRef!)).data();
      if (receipt && receipt.invoice_number !== invoiceNumber) throw new Error("Gateway transaction already bound to another invoice");
    }
    const userRef = db.collection("users").doc(uid);
    const uSnap = await t.get(userRef);
    if (!uSnap.exists) throw new Error("Payment owner profile is missing");
    const uData = uSnap.data()!;
    const entitlements = (uData.entitlements || {}) as Record<string, any>;
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
    // Only ledger-backed grants extend a paid period. Profile expiry is a projection.
    baseDate = now;
    for (const id of uData.access_grant_ids || []) {
      const g = (await t.get(db.collection("access_grants").doc(id))).data();
      if (g && g.scope === entitlementKey && g.status === "active" && g.expires_ms > baseDate.getTime()) baseDate = new Date(g.expires_ms);
    }
    const expiryDate = new Date(billingExpiry(baseDate.getTime(), durationMonths));
    const grantId = keyOf("invoice", invoiceNumber);
    if (receiptRef) t.set(receiptRef, {invoice_number: invoiceNumber, uid, transaction_id: gatewayEvidence!.transactionId});
    t.set(db.collection("access_grants").doc(grantId), {
      uid, scope: entitlementKey, kind: "payment", status: "active", amount,
      invoice_number: invoiceNumber, transaction_document: txDocRef.id,
      transaction_id: gatewayEvidence?.transactionId || txData.transaction_id || invoiceNumber,
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

    const updatedEntitlements = {
      ...entitlements,
      [entitlementKey]: {
        plan: plan,
        status: "active",
        source: `${txData.gateway || "doku"}_payment`,
        expiry: admin.firestore.Timestamp.fromDate(expiryDate),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      }
    };

    const userUpdate: any = {
      entitlements: updatedEntitlements,
      access_version: 2,
      access_due_ms: Date.now(),
      access_grant_ids: [...new Set([...(uData.access_grant_ids || []), grantId])],
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
    return { success: true, ...activationResult };
  }

  console.log(`[Activation] Akses berhasil diaktifkan atomik untuk ${activationResult.uid} (Modul: ${activationResult.entitlementKey})`);

  // Kirim notifikasi Telegram seketika saat pembayaran sukses & akses diaktifkan
  await sendTelegramNotification(
    `💳 <b>[PEMBAYARAN DITERIMA & AKSES AKTIF]</b>\n` +
    `🕌 OpenTurath AI Server\n` +
    `👤 Pengguna: <code>${activationResult.email}</code>\n` +
    `🆔 Invoice: <code>${invoiceNumber}</code>\n` +
    `📦 Produk: <b>${activationResult.serviceTitle}</b>\n` +
    `🏷️ Paket: <b>${activationResult.plan.toUpperCase()}</b>\n` +
    `🔑 Entitlement: <code>${activationResult.entitlementKey}</code>\n` +
    `✅ Status: Sukses terdaftar & hak akses aktif.`
  );

  return { success: true, ...activationResult };
}

function safeTimingEqual(a: string, b: string): boolean {
  if (typeof a !== "string" || typeof b !== "string") return false;
  const bufA = Buffer.from(a);
  const bufB = Buffer.from(b);
  if (bufA.length !== bufB.length) return false;
  return crypto.timingSafeEqual(bufA, bufB);
}

// ================================================================
// FUNCTION 2b: dokuWebhook (HTTP Notification dari DOKU)
// Otomatis aktifkan akses santri di Firestore saat bayar sukses
// ================================================================
export const dokuWebhook = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onRequest(async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
      }
      const headers = req.headers;
      const body = req.body || {};

      // F63: Redaksi log sensitif - jangan cetak raw authorization atau full personal payload
      const invoiceNumber = body.order?.invoice_number || body.invoice_number;
      const status = body.transaction?.status || body.transactionStatus || body.status;
      console.log(`[DOKU Webhook] Notifikasi diterima untuk invoice: ${invoiceNumber}, status: ${status}`);

      // Verifikasi Signature DOKU wajib di seluruh environment
      const incomingSignature = (headers["signature"] || headers["Signature"]) as string | undefined;
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
      let eventRef: FirebaseFirestore.DocumentReference | null = null;
      if (requestId) {
        eventRef = db.collection("webhook_events").doc(crypto.createHash("sha256").update(requestId).digest("hex"));
        const eventSnap = await eventRef.get();
        if (eventSnap.exists) {
          const eventData = eventSnap.data()!;
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
        const actResult = await processSuccessfulPayment(invoiceNumber, body.order?.amount ?? body.amount);
        if (eventRef) {
          await eventRef.update({
            status: "completed",
            completed_at: admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        res.status(200).json({ status: "SUCCESS", invoice: invoiceNumber, details: actResult });
      } catch (err: any) {
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
    } catch (err: any) {
      console.error("[DOKU Webhook] Uncaught error in handler:", err.message);
      res.status(500).json({ error: err.message });
    }
  });

// ================================================================
// FUNCTION 2b-2: midtransWebhook (HTTP Notification dari Midtrans)
// Otomatis verifikasi Signature SHA-512 & aktifkan akses santri
// ================================================================
export const midtransWebhook = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onRequest(async (req, res) => {
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
      const inquiry = await axios.get(`${cfg.apiUrl}/${encodeURIComponent(String(orderId))}/status`, {
        headers: {Authorization: `Basic ${Buffer.from(`${cfg.serverKey}:`).toString("base64")}`}, timeout: 15000,
      });
      const verified = inquiry.data;
      if (verified.order_id !== orderId || Number(verified.gross_amount) !== Number(grossAmount) ||
          (verified.currency && verified.currency !== "IDR")) {
        res.status(400).send("Payment identity mismatch"); return;
      }
      transactionStatus = verified.transaction_status;
      fraudStatus = verified.fraud_status;
      // State machine idempotensi event
      const eventKey = crypto.createHash("sha256").update(`midtrans_${orderId}_${transactionStatus}_${statusCode}`).digest("hex");
      const eventRef = db.collection("webhook_events").doc(eventKey);
      const eventSnap = await eventRef.get();
      if (eventSnap.exists && eventSnap.data()?.status === "completed") {
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

      const isSuccess =
        transactionStatus === "settlement" ||
        (transactionStatus === "capture" && fraudStatus === "accept");

      if (isSuccess) {
        console.log(`[Midtrans Webhook] Payment confirmed for ${orderId}. Activating entitlement...`);
        try {
          const actResult = await processSuccessfulPayment(orderId, grossAmount, {transactionId: verified.transaction_id, orderId: verified.order_id, currency: verified.currency});
          await eventRef.update({
            status: "completed",
            completed_at: admin.firestore.FieldValue.serverTimestamp(),
          });
          res.status(200).json({ status: "OK", orderId, details: actResult });
        } catch (actErr: any) {
          console.error(`[Midtrans Webhook] Activation error for ${orderId}:`, actErr.message);
          await eventRef.update({
            status: "failed",
            error: actErr.message,
            failed_at: admin.firestore.FieldValue.serverTimestamp(),
          });
          res.status(500).json({ status: "ERROR", message: actErr.message });
        }
      } else if (transactionStatus === "cancel" || transactionStatus === "expire" || transactionStatus === "deny") {
        console.log(`[Midtrans Webhook] Payment ${transactionStatus} for ${orderId}. Updating transaction record...`);
        const txQuery = await db.collection("transactions").where("invoice_number", "==", orderId).limit(1).get();
        if (!txQuery.empty) {
          await db.runTransaction(async t => {
            const tx = await t.get(txQuery.docs[0].ref);
            if (tx.data()?.activation_applied === true) return;
            t.update(txQuery.docs[0].ref, {status: transactionStatus, updated_at: admin.firestore.FieldValue.serverTimestamp()});
          });
        }
        await eventRef.update({ status: "completed" });
        res.status(200).json({ status: "OK", message: `Transaction marked as ${transactionStatus}` });
      } else if (["refund", "partial_refund", "chargeback", "partial_chargeback"].includes(transactionStatus)) {
        const gr = db.collection("access_grants").doc(keyOf("invoice", String(orderId)));
        await db.runTransaction(async t => {
          const grant = await t.get(gr);
          const ownerRef = grant.data()?.uid ? db.collection("users").doc(grant.data()!.uid) : null;
          const ownerDoc = ownerRef ? await t.get(ownerRef) : null;
          if (grant.exists) t.update(gr, transactionStatus.startsWith("partial")
            ? {review_required: true, payment_status: transactionStatus}
            : {status: "revoked", payment_status: transactionStatus});
          if (ownerRef && ownerDoc?.exists) t.update(ownerRef, {access_due_ms: Date.now()});
        });
        await eventRef.update({status: "completed"});
        res.status(200).json({status: "OK"});
      } else {
        console.log(`[Midtrans Webhook] Pending status ${transactionStatus} for ${orderId}.`);
        await eventRef.update({ status: "pending" });
        res.status(200).json({ status: "OK", message: "Status pending" });
      }
    } catch (err: any) {
      console.error("[Midtrans Webhook] Uncaught error:", err.message);
      res.status(500).json({ error: err.message });
    }
  });

// ================================================================
// FUNCTION 2c: checkPaymentStatus (Active Status Inquiry dari Client/App)
// Memverifikasi status langsung ke DOKU API tanpa menunggu webhook
// ================================================================
export const checkPaymentStatus = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    // 0. Wajibkan pengguna terotentikasi
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk memeriksa status pembayaran.");
    }

    const callerUid = context.auth.uid;
    // F-02: Rate limit status inquiry (maksimal 15 panggilan per menit per UID)
    await enforceRateLimit(
      `chk_${callerUid}`,
      15,
      60,
      "Terlalu banyak permintaan pemeriksaan status pembayaran."
    );

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

    const gateway = txData.gateway || "midtrans";

    // 2. Status Inquiry ke Payment Gateway jika belum success di Firestore
    if (gateway === "midtrans") {
      const midtransCfg = getMidtransConfig();
      const statusUrl = `${midtransCfg.apiUrl}/${invoiceNumber}/status`;
      const authHeader = "Basic " + Buffer.from(midtransCfg.serverKey + ":").toString("base64");

      try {
        console.log(`[checkPaymentStatus] Inquiring Midtrans API for ${invoiceNumber}...`);
        const response = await axios.get(statusUrl, {
          headers: {
            "Authorization": authHeader,
            "Accept": "application/json",
          },
          timeout: 10000,
        });

        const mData = response.data || {};
        const trxStatus = mData.transaction_status || "";
        const fraudStatus = mData.fraud_status || "";

        const isSuccess =
          trxStatus === "settlement" ||
          (trxStatus === "capture" && fraudStatus === "accept");

        if (isSuccess) {
          console.log(`[checkPaymentStatus] Midtrans Inquiry verified SUCCESS for ${invoiceNumber}! Activating subscription...`);
          const actResult = await processSuccessfulPayment(invoiceNumber, mData.gross_amount, {transactionId: mData.transaction_id, orderId: mData.order_id, currency: mData.currency});
          return {
            success: true,
            status: "SUCCESS",
            message: "Pembayaran terverifikasi. Akses Anda sudah aktif.",
            details: actResult,
          };
        } else if (trxStatus === "cancel" || trxStatus === "expire" || trxStatus === "deny") {
          return {
            success: false,
            status: trxStatus.toUpperCase(),
            message: `Pembayaran ${trxStatus}.`,
          };
        } else {
          return {
            success: false,
            status: trxStatus ? trxStatus.toUpperCase() : "PENDING",
            message: "Pembayaran masih menunggu penyelesaian.",
          };
        }
      } catch (err: any) {
        console.error("[checkPaymentStatus] Error checking Midtrans status:", err.response?.data || err.message);
        return {
          success: false,
          status: "PENDING",
          error: err.response?.data?.status_message || err.message,
        };
      }
    } else {
      // Fallback untuk transaksi warisan DOKU
      const dokuCfg = getDokuConfig();
      const targetPath = `/orders/v1/status/${invoiceNumber}`;
      const requestId = `REQ-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;
      const timestamp = new Date().toISOString().slice(0, 19) + "Z";
      const signature = generateDokuGetSignature(dokuCfg.clientId, requestId, timestamp, targetPath, dokuCfg.secretKey);

      try {
        console.log(`[checkPaymentStatus] Inquiring DOKU API for ${invoiceNumber}...`);
        const response = await axios.get(`${dokuCfg.baseUrl}${targetPath}`, {
          headers: {
            "Client-Id": dokuCfg.clientId,
            "Request-Id": requestId,
            "Request-Timestamp": timestamp,
            "Signature": signature,
          },
          timeout: 10000,
        });

        const dokuData = response.data || {};
        const trxStatus = dokuData.transaction?.status || "";

        if (trxStatus === "SUCCESS") {
          console.log(`[checkPaymentStatus] DOKU Inquiry verified SUCCESS for ${invoiceNumber}! Activating subscription...`);
          const actResult = await processSuccessfulPayment(invoiceNumber, dokuData.order?.amount);
          return {
            success: true,
            status: "SUCCESS",
            message: "Pembayaran terverifikasi. Akses Anda sudah aktif.",
            details: actResult
          };
        } else {
          return {
            success: false,
            status: trxStatus || "PENDING",
            message: "Pembayaran masih menunggu penyelesaian."
          };
        }
      } catch (err: any) {
        console.error("[checkPaymentStatus] Error checking DOKU status:", err.response?.data || err.message);
        return {
          success: false,
          status: "PENDING",
          error: err.response?.data || err.message
        };
      }
    }
  });

// ================================================================
// FUNCTION 2d: redeemCode
// Menukarkan Kode Redeem Santri (Voucher Akses 7 Hari, dsb)
// Mengaktifkan entitlement berbatas waktu & trigger email sharing
// ================================================================
export const redeemCode = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 120 })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login diperlukan untuk menukarkan kode akses.");
    }

    if (typeof data?.code !== "string" || data.code.length > 256) {
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
    const rawDeviceId = typeof data?.deviceId === "string" ? data.deviceId.trim().toLowerCase() : "";
    const isPhysicalDevice = data?.isPhysicalDevice !== false;
    const deviceModel = typeof data?.deviceModel === "string" ? data.deviceModel.slice(0, 100) : "";
    const deviceBrand = typeof data?.deviceBrand === "string" ? data.deviceBrand.slice(0, 100) : "";

    // F-03 & F-05: Rate limit penukaran voucher per UID (maksimal 8 percobaan per 15 menit)
    await enforceRateLimit(
      `rdm_${uid}`,
      8,
      900,
      "Terlalu banyak percobaan penukaran kode redeem."
    );

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
      const codeRef = db.collection("redeem_codes").doc(rawCode);
      const codeDoc = await transaction.get(codeRef);

      if (!codeDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Kode redeem tidak ditemukan atau salah.");
      }

      const codeData = codeDoc.data()!;
      if (codeData.is_active === false) {
        throw new functions.https.HttpsError("failed-precondition", "Kode redeem ini sudah tidak aktif.");
      }

      const maxUses = (codeData.max_uses as number) || 1;
      const timesUsed = (codeData.times_used as number) || 0;
      if (timesUsed >= maxUses) {
        throw new functions.https.HttpsError("resource-exhausted", "Batas pemakaian kode redeem ini sudah tercapai.");
      }

      if (codeData.expires_at && codeData.expires_at.toDate() < new Date()) {
        throw new functions.https.HttpsError("deadline-exceeded", "Masa berlaku penukaran kode ini telah kedaluwarsa.");
      }

      // F-12: Enforce Single-Device Binding untuk kode keluarga promo / perdana
      const isSingleDeviceEnforced =
        codeData.one_per_device === true ||
        codeData.type === "perdana" ||
        rawCode.startsWith("PERDANA") ||
        rawCode.startsWith("TRIAL") ||
        rawCode.startsWith("WELCOME");

      const promoFamily = (codeData.promo_family as string) || (rawCode.startsWith("PERDANA") ? "perdana" : "trial_default");
      const deviceRedemptionKey = `dev_${rawDeviceId}_${promoFamily}`;
      const deviceRedemptionRef = db.collection("device_redemptions").doc(deviceRedemptionKey);

      if (isSingleDeviceEnforced) {
        if (isPhysicalDevice === false) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Kode ini hanya dapat diaktifkan melalui ponsel fisik asli."
          );
        }

        if (!rawDeviceId || !/^[a-f0-9]{64}$/.test(rawDeviceId)) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            "Identitas perangkat diperlukan untuk mengaktifkan kode ini."
          );
        }

        const deviceRedemptionDoc = await transaction.get(deviceRedemptionRef);
        if (deviceRedemptionDoc.exists) {
          throw new functions.https.HttpsError(
            "already-exists",
            "Kode ini hanya dapat diklaim 1 kali per perangkat. Perangkat ini sudah pernah mengaktifkannya sebelumnya."
          );
        }
      }

      // Periksa apakah pengguna sudah pernah menukarkan kode ini
      const redemptionRef = codeRef.collection("redemptions").doc(uid);
      const redemptionDoc = await transaction.get(redemptionRef);
      if (redemptionDoc.exists) {
        throw new functions.https.HttpsError("already-exists", "Kode ini sudah pernah ditukarkan sebelumnya.");
      }

      const entitlementKey = (codeData.entitlement_key as string) || "fiqh_syafii";
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
      const userData = userDoc.exists ? userDoc.data()! : {};
      const entitlements = (userData.entitlements || {}) as Record<string, any>;
      const currentEnt = entitlements[entitlementKey];

      const redeemedAt = new Date();
      if (isTrialVoucher && currentEnt?.plan === "trial" &&
          currentEnt.status === "active" && currentEnt.expiry) {
        const currentTrialExpiry = currentEnt.expiry.toDate
          ? currentEnt.expiry.toDate()
          : new Date(currentEnt.expiry);
        if (currentTrialExpiry > redeemedAt && codeData.allow_trial_extension !== true) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Masa coba untuk akses ini masih aktif. Kode trial baru dapat digunakan setelah berakhir."
          );
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

      const voucherGrantId = keyOf("voucher", rawCode, uid);
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
      const updatedEntitlements = {
        ...entitlements,
        [entitlementKey]: {
          plan: isTrialVoucher ? "trial" : "voucher_access",
          status: "active",
          source: "redeem_code",
          code_id: rawCode.slice(0, 4) + "****", // Redaksi di entitlement
          expiry: admin.firestore.Timestamp.fromDate(newExpiry),
          started_at: admin.firestore.Timestamp.fromDate(redeemedAt),
          trial_duration_days: isTrialVoucher ? durationDays : null,
          payment_status: "none",
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        }
      };

      const userUpdate: any = {
        entitlements: updatedEntitlements,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
        access_version: 2,
        access_due_ms: Date.now(),
        access_grant_ids: [...new Set([...(userData.access_grant_ids || []), voucherGrantId])],
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
    const tgMessage = 
      `🔔 <b>[VOUCHER SANTRI DIKLAIM]</b>\n` +
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
export const onUserCreate = functions.firestore
  .document("users/{uid}")
  .onCreate(async (snapshot, context) => {
    const uid = context.params.uid;
    const user = await admin.auth().getUser(uid);
    if (!user.emailVerified || !user.email) return null;
    // Only verified email users may claim historical transactions.
    const emailLower = user.email.toLowerCase().trim();
    const [ownedByUid, ownedByEmail] = await Promise.all([
      db.collection("transactions").where("uid", "==", uid).where("status", "in", ["success", "paid"]).get(),
      db.collection("transactions").where("customer_email", "==", emailLower).where("status", "in", ["success", "paid"]).get(),
    ]);

    const allDocsMap = new Map<string, FirebaseFirestore.QueryDocumentSnapshot>();
    for (const doc of ownedByUid.docs) allDocsMap.set(doc.id, doc);
    for (const doc of ownedByEmail.docs) allDocsMap.set(doc.id, doc);

    if (allDocsMap.size === 0) return null;
    await db.runTransaction(async t => {
      const current = await t.get(snapshot.ref);
      if (!current.exists) return;
      const profile = current.data()!;
      if (Object.keys(profile.entitlements || {}).length > 0) return;
      const entitlements: Record<string, any> = {};
      const txs = [];
      for (const doc of allDocsMap.values()) txs.push(await t.get(doc.ref));
      for (const tx of txs) {
        const data = tx.data();
        if (!data || !["paid", "success"].includes(data.status)) continue;
        // Verified email never overrides an existing transaction owner.
        if (data.uid && data.uid !== uid) continue;
        const key = data.entitlement_key;
        const expiry = data.subscription_expires_at;
        if (typeof key !== "string" || !expiry?.toDate || expiry.toDate() <= new Date()) continue;
        if (!entitlements[key] || expiry.toMillis() > entitlements[key].expiry.toMillis()) {
          entitlements[key] = { plan: data.plan || "premium", status: "active", expiry, source: data.source || "goakal" };
        }
        // Link uid if not linked
        if (!data.uid) {
          t.update(tx.ref, { uid, updated_at: admin.firestore.FieldValue.serverTimestamp() });
        }
      }
      if (!Object.keys(entitlements).length) return;
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
const PERMANENT_VIP_EMAILS = new Set([
  "openturath@gmail.com",
  "ramah@ptct.net",
  "raflimaulan@gmail.com",
  "mas.raflihusen@gmail.com",
  "alkhateeb23@gmail.com",
  "omarasb1441@gmail.com",
  "prilatief@gmail.com",
  "aaadman40@gmail.com",
  "abo.omar5539@gmail.com",
  "abualgilani2024@gmail.com",
  "ahobh4241@gmail.com",
  "alhamodi65@gmail.com",
  "ali.bafdhl36@gmail.com",
  "alshykhkmalbahrmz@gmail.com",
  "atinrahmak@gmail.com",
  "hafamfb551985@gmail.com",
  "loyos839@gmail.com",
  "mohammedhalahdal@gmail.com",
  "mostajadt25@gmail.com",
  "nona.alyaziza@gmail.com",
  "omar739037802@gmail.com",
  "yasser110271@gmail.com",
]);

export const dailyRevoke = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
  .pubsub.schedule("every 1 hours")
  .onRun(async () => {
    if ((await db.collection("access_control").doc("runtime").get()).data()?.writer === "vps-v2") return null;
    const revokedSummary: Array<{ email: string; scope: string; reason: string }> = [];
    let cursor: FirebaseFirestore.QueryDocumentSnapshot | undefined;
    while (true) {
      let query = db.collection("users").orderBy(admin.firestore.FieldPath.documentId()).limit(100);
      if (cursor) query = query.startAfter(cursor);
      const page = await query.get();
      if (page.empty) break;
      for (const doc of page.docs) {
        await db.runTransaction(async t => {
          const snap = await t.get(doc.ref);
          if (!snap.exists) return;
          const data = snap.data()!;

          // PROTEKSI VIP PERMANEN: Kebal terhadap segala pencabutan akses otomatis
          const userEmail = (data.email || "").toLowerCase().trim();
          if (
            data.is_vip === true ||
            ["vip", "admin", "guru", "special"].includes(String(data.role || "").toLowerCase()) ||
            PERMANENT_VIP_EMAILS.has(userEmail)
          ) {
            return;
          }
          const entitlements = { ...(data.entitlements || {}) };
          const expired: string[] = [];
          for (const [key, value] of Object.entries(entitlements)) {
            const ent = value as any;
            const expiry = ent?.expiry?.toDate ? ent.expiry.toDate() : new Date(ent?.expiry ?? ent?.expires_at ?? "");
            if (expiry && !isNaN(expiry.getTime()) && expiry <= new Date() && ent?.status !== "expired") {
              entitlements[key] = { ...ent, status: "expired" };
              expired.push(key);
            }
          }
          const legacyExpiry = data.subscription_expiry?.toDate
            ? data.subscription_expiry.toDate() : new Date(data.subscription_expiry ?? "");
          const legacyExpired = ["all_access", "all_ai_1m", "all_ai_6m", "all_ai_1y", "full"].includes(data.plan)
            && legacyExpiry <= new Date();
          if (!expired.length && !legacyExpired) return;
          const update: any = { entitlements, updated_at: admin.firestore.FieldValue.serverTimestamp() };
          if (legacyExpired) { update.plan = "trial"; update.subscription_expiry = null; expired.push("all_access"); }
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
    const activeEmailsByEntitlement = new Map<string, Set<string>>();
    for (const key of PROVISIONED_KEYS) {
      activeEmailsByEntitlement.set(key, new Set<string>());
    }
    const allActiveEmails = new Set<string>();

    for (const doc of txSnap.docs) {
      const d = doc.data();
      const email = (d.customer_email || d.payer_email || d.email || "").trim().toLowerCase();
      if (!email) continue;
      const status = String(d.status || "").toLowerCase();
      if (!["success", "paid", "settled"].includes(status)) continue;

      const rawExp = d.subscription_expires_at || d.access_expires_at || d.expires_at;
      let expDate: Date | null = null;
      if (rawExp?.toDate) expDate = rawExp.toDate();
      else if (typeof rawExp === "string") {
        const parsed = new Date(rawExp);
        if (!isNaN(parsed.getTime())) expDate = parsed;
      }

      const plan = String(d.plan || d.plan_id || "").toLowerCase();
      const isVip = d.is_vip === true || plan.includes("vip") || (expDate && expDate.getFullYear() >= 2030);
      if (isVip || PERMANENT_VIP_EMAILS.has(email)) continue;

      const isYearly = ["1y", "year", "tahun", "annual", "bahits_1y"].some(y => plan.includes(y));
      const entKey = d.entitlement_key;

      if (expDate && expDate > now) {
        if (isYearly || entKey === "all_access" || entKey === "all_ai" || !entKey) {
          allActiveEmails.add(email);
          for (const k of PROVISIONED_KEYS) {
            activeEmailsByEntitlement.get(k)?.add(email);
          }
        } else if (activeEmailsByEntitlement.has(entKey)) {
          activeEmailsByEntitlement.get(entKey)?.add(email);
        }
      }
    }

    for (const doc of txSnap.docs) {
      const d = doc.data();
      const email = (d.customer_email || d.payer_email || d.email || "").trim().toLowerCase();
      if (!email) continue;
      if (PERMANENT_VIP_EMAILS.has(email) || d.is_vip === true) continue;

      const status = String(d.status || "").toLowerCase();
      if (!["success", "paid", "settled"].includes(status)) continue;

      const rawExp = d.subscription_expires_at || d.access_expires_at || d.expires_at;
      let expDate: Date | null = null;
      if (rawExp?.toDate) expDate = rawExp.toDate();
      else if (typeof rawExp === "string") {
        const parsed = new Date(rawExp);
        if (!isNaN(parsed.getTime())) expDate = parsed;
      }

      if (expDate && expDate <= now) {
        const entKey = d.entitlement_key;
        const targetKeys = (entKey && PROVISIONED_KEYS.includes(entKey))
          ? [entKey]
          : (String(d.plan || "").toLowerCase().includes("tholib") ? ["fiqh_tahawwulat", "fiqh_syafii"] : PROVISIONED_KEYS);

        const expiredKeysToRevoke: string[] = [];
        for (const k of targetKeys) {
          if (!allActiveEmails.has(email) && !activeEmailsByEntitlement.get(k)?.has(email)) {
            expiredKeysToRevoke.push(k);
          }
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
        lines.push(`• 👤 <code>${r.email}</code> — <b>${r.scope}</b> (<i>${r.reason}</i>)`);
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
const PROVISIONED_KEYS = ["fiqh_tahawwulat", "fiqh_syafii", "ushul_fiqh", "hadits", "tafsir", "nahwu"];

function entitlementRevision(data: any): string {
  return JSON.stringify([data?.plan, data?.subscription_expiry, data?.entitlements]);
}

export const processProvisioningOutbox = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com", timeoutSeconds: 300 })
  .pubsub.schedule("every 5 minutes")
  .onRun(async () => {
    if ((await db.collection("access_control").doc("runtime").get()).data()?.writer === "vps-v2") return null;
    const started = Date.now();
    const pending = await db.collection("provisioning_outbox")
      .where("status", "in", ["pending", "retry", "processing"]).limit(25).get();
    for (const candidate of pending.docs) {
      if (Date.now() - started > 210000) break;
      const token = crypto.randomUUID();
      const candidateData = candidate.data();
      const uid = candidateData.uid || candidateData.email;
      if (typeof uid !== "string" || !uid) {
        await candidate.ref.update({status:"failed",error:"Missing owner UID or email"});
        continue;
      }
      const lease = db.collection("provisioning_leases").doc(uid);
      const job = await db.runTransaction(async t => {
        const snap = await t.get(candidate.ref);
        const lock = await t.get(lease);
        const data = snap.data();
        if (!data || !["pending", "retry", "processing"].includes(data.status)) return null;
        if ((lock.data()?.until?.toMillis?.() || 0) > Date.now()) return null;
        if ((data.attempts || 0) >= 8) {
          t.update(candidate.ref, {status:"failed",error:"Exceeded retry limit"});
          return null;
        }
        t.set(lease, {token, until:admin.firestore.Timestamp.fromMillis(Date.now()+330000)});
        t.update(candidate.ref, {status:"processing",attempts:(data.attempts||0)+1,lease_token:token});
        return data;
      });
      if (!job) continue;
      let status = "completed";
      let error = "";
      try {
        const userDoc = candidateData.uid && !candidateData.uid.includes("@")
          ? await db.collection("users").doc(candidateData.uid).get()
          : null;
        const data = userDoc && userDoc.exists ? userDoc.data() : null;
        const email = (data?.email || job.email || (uid.includes("@") ? uid : "")).trim().toLowerCase();
        if (!email.includes("@")) throw new Error("Invalid provisioning email");
        const scope = job.entitlement_key;
        const keys = scope === "all_access" || scope === "all_ai" ? PROVISIONED_KEYS : [scope];
        for (const key of keys) {
          if (!PROVISIONED_KEYS.includes(key)) throw new Error("Unsupported provisioning scope");
          const isVip = data?.is_vip === true ||
            ["vip", "admin", "guru", "special"].includes(String(data?.role || "").toLowerCase()) ||
            PERMANENT_VIP_EMAILS.has(email);
          const desired = isVip || (job.action === "add" ? true : Boolean(data && getEntitlementAccess(data,key).active));
          await notifySubscriptionServer(email,data?.name||job.name||"Peneliti",desired ? "premium" : "trial",
            desired ? "add" : "remove",getServiceTitleForEntitlement(key));
        }
        if (job.action === "remove") {
          await sendTelegramNotification(
            `🗑️ <b>[DEPROVISIONING NOTEBOOKLM SELESAI]</b>\n` +
            `🕌 OpenTurath AI Server\n` +
            `👤 Email: <code>${email}</code>\n` +
            `📦 Produk: <b>${getServiceTitleForEntitlement(job.entitlement_key)}</b>\n` +
            `✅ Hak akses telah resmi dicabut dari sistem NotebookLM.`
          );
        }

        if (data && candidateData.uid && job.action !== "remove") {
          const after = await db.collection("users").doc(candidateData.uid).get();
          if (entitlementRevision(data) !== entitlementRevision(after.data())) {
            status = "retry";
            error = "Entitlements changed during delivery";
          }
        }
      } catch (err: any) {
        status = "retry";
        error = String(err.message || "Provisioning failure").slice(0,300);
      }
      await db.runTransaction(async t => {
        const lock = await t.get(lease);
        const snap = await t.get(candidate.ref);
        if (lock.data()?.token !== token || snap.data()?.lease_token !== token) return;
        t.update(candidate.ref, {status,last_error:error,last_attempt_at:admin.firestore.FieldValue.serverTimestamp()});
        t.delete(lease);
      });
    }
    return null;
  });

// ================================================================
// FUNCTION 4c: cleanupOrphanedDeletions (Cron Harian — jam 03.00 WIB)
// Membersihkan dokumen user yang bertanda pending_deletion jika akun Auth sudah terhapus
// ================================================================
async function deleteUserData(uid: string, authEmail = ""): Promise<void> {
  const ref = db.collection("users").doc(uid);
  let targetEmail = authEmail;
  await db.runTransaction(async t => {
    const user = await t.get(ref);
    const email = authEmail || user.data()?.email || "";
    targetEmail = email;
    const jobs = [];
    for (const key of PROVISIONED_KEYS) {
      const job = db.collection("provisioning_outbox").doc(`delete_${uid}_${key}`);
      jobs.push({ref:job,snap:await t.get(job),key});
    }
    if (user.exists) t.update(ref,{account_deleted:true});
    for (const job of jobs) {
      if (job.snap.exists) continue;
      t.set(job.ref, {uid,email,entitlement_key:job.key,action:"remove",status:"pending",attempts:0,
        created_at:admin.firestore.FieldValue.serverTimestamp()});
    }
  });
  await db.recursiveDelete(ref);
  if (targetEmail) {
    await sendTelegramNotification(
      `🚫 <b>[HAPUS AKUN & CABUT AKSES]</b>\n` +
      `👤 Email: <code>${targetEmail}</code>\n` +
      `🆔 UID: <code>${uid}</code>\n` +
      `⚠️ Akun pengguna dihapus permanen. Seluruh hak akses turats dicabut.`
    );
  }
}

export const onUserDeleted = functions
  .runWith({ serviceAccount:"open-turath@appspot.gserviceaccount.com",timeoutSeconds:300,failurePolicy:true })
  .auth.user().onDelete(async user => {
    await deleteUserData(user.uid,user.email || "");
  });

export const cleanupOrphanedDeletions = functions
  .runWith({ serviceAccount:"open-turath@appspot.gserviceaccount.com",timeoutSeconds:300 })
  .pubsub.schedule("0 3 * * *").timeZone("Asia/Jakarta")
  .onRun(async () => {
    const pending = await db.collection("users").where("pending_deletion","==",true).limit(50).get();
    for (const doc of pending.docs) {
      try { await admin.auth().getUser(doc.id); }
      catch (err: any) {
        if (err.code === "auth/user-not-found") await deleteUserData(doc.id);
        else throw err;
      }
    }
    return null;
  });

// ================================================================
// HELPER: Notify openturath-subscription Cloud Run server
// ================================================================
async function notifySubscriptionServer(
  email: string,
  name: string,
  plan: string,
  action: "add" | "remove",
  serviceName?: string
) {
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
      await axios.post(url, payload, {
        headers: {
          "Content-Type": "application/json",
          "X-Internal-Secret": internalSecret
        },
        timeout: 60000,
        maxRedirects: 0,
      });
      console.log(`Successfully notified subscription server: ${action} ${email} for ${service}`);
    } catch (err: any) {
      console.error(`Provisioning request failed for ${service}`);
      throw err;
    }
  }
}

// ================================================================
// FUNCTION 5: chatGate (Auth Gate + Iframe for NotebookLM)
// ================================================================

const AGENTS: Record<string, { notebookId: string; akalCuid: string; label: string; entitlementKey: string }> = {
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

function getWebSessionSecret(): string {
  // Prefer environment variables, but retain compatibility with older
  // Firebase Runtime Config deployments while the secret is migrated.
  const runtimeConfigSecret = functions.config().web?.session_secret;
  return process.env.WEB_SESSION_SECRET || runtimeConfigSecret || "";
}

function getAkalApiKey(): string {
  const runtimeConfigKey = functions.config().akal?.api_key;
  return process.env.AKAL_API_KEY || runtimeConfigKey || "";
}

function resolveAgentRef(value: unknown): string {
  return typeof value === "string" && AGENTS[value]
    ? value
    : "fikih-tahawwulat-muhaqqiq";
}

function clearSessionCookie(res: functions.Response): void {
  res.setHeader(
    "Set-Cookie",
    `${COOKIE_NAME}=; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=0`
  );
}

export const chatGate = functions
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
      const profile = (await db.collection("users").doc(session.uid).get()).data();
      const hasAccess = profile?.access_version === 2 || await verifySubscriptionFirestore(
        session.email,
        agent.entitlementKey,
        session.uid
      );
      if (!hasAccess) {
        clearSessionCookie(res);
        res.redirect(`/login?ref=${encodeURIComponent(agentId)}&error=not_found`);
        return;
      }

      if (profile?.access_version === 2) {
        try {
          const entity = AGENT_TO_ENTITY[agentId];
          const assigned = await new AccessControl(db, NOTEBOOK_ENTITIES, ENTITY_SCOPES).resolve(session.uid, entity);
          res.setHeader("Content-Type", "text/html;charset=UTF-8");
          res.send(getChatWrapperHTML({...agent, notebookId: assigned.notebookId}, agentId, session.email));
        } catch (e) {
          res.status(e instanceof AccessFault && e.code === "permission-denied" ? 403 : 503)
            .send("Akses notebook sedang disiapkan atau diperiksa. Anda tidak perlu membeli ulang.");
        }
        return;
      }
      res.setHeader("Content-Type", "text/html;charset=UTF-8");
      res.send(getChatWrapperHTML(agent, agentId, session.email));
      return;
    }

    res.status(404).send("Not Found");
  });

// ── HELPERS FOR CHAT GATE ──

async function handleLogin(req: functions.Request, res: functions.Response, secret: string, apiKey: string) {
  const idToken = (req.body.id_token as string || (req.headers.authorization ? req.headers.authorization.split("Bearer ")[1] : "") || "").trim();
  const csrfTokenForm = req.body.csrf_token as string || "";
  // Hanya ID agen yang dikenal; nilai mentah dari body tidak boleh masuk ke URL redirect.
  const ref = resolveAgentRef(req.body.ref);

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
  } catch (err: any) {
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
  } else {
    res.redirect(`/login?ref=${ref}&error=not_found`);
  }
}

async function verifySubscriptionHybrid(email: string, entitlementKey: string, serviceCuid: string, apiKey: string): Promise<boolean> {
  // 1. Check local Firestore first (respects manual overrides, bonuses, and active firestore state)
  try {
    const localActive = await verifySubscriptionFirestore(email, entitlementKey);
    if (localActive) {
      console.log(`[Auth] User ${email} verified active locally via Firestore for entitlement '${entitlementKey}'`);
      return true;
    }
  } catch (err: any) {
    console.error(`[Auth] Firestore subscription check failed: ${err.message}`);
  }

  // 2. Fallback to querying GoAkal API directly
  console.log(`[Auth] User ${email} not verified locally. Falling back to GoAkal API...`);
  return await verifyAkalSubscription(email, serviceCuid, apiKey);
}

async function verifySubscriptionFirestore(email: string, entitlementKey: string, uid?: string): Promise<boolean> {
  // Web authorization must carry a verified UID. Billing history is not identity.
  if (!uid) return false;
  const user = await db.collection("users").doc(uid).get();
  if (!user.exists) return false;
  const data = user.data()!;
  if (typeof data.email !== "string" || data.email.toLowerCase() !== email.toLowerCase()) return false;
  return getEntitlementAccess(data, entitlementKey).active;
}

async function verifyAkalSubscription(email: string, serviceCuid: string, apiKey: string): Promise<boolean> {
  const statuses = ["PAID", "SETTLED"];

  for (const status of statuses) {
    let page = 1;
    const maxPages = 5;

    while (page <= maxPages) {
      const apiUrl = `https://goakal.com/service/api/v1/services/${serviceCuid}/transactions?status=${status}&pageSize=100&page=${page}`;

      try {
        const response = await axios.get(apiUrl, {
          headers: { "X-Api-Key": apiKey }
        });

        const result = response.data;
        const txns = result.data || [];

        if (txns.length === 0) break;

        const now = new Date();
        const activeTxn = txns.find((t: any) => {
          if (!t.payerEmail) return false;
          if (t.payerEmail.trim().toLowerCase() !== email) return false;

          if (t.expiryDate) {
            return new Date(t.expiryDate) > now;
          }

          const startStr = t.paidAt || t.createdAt;
          if (!startStr) return false;

          const startDate = new Date(startStr);
          const durationMonths = detectDurationMonths(t.priceSchemeTitle || "", t.serviceTitle || "");
          const expiry = new Date(startDate);
          expiry.setMonth(expiry.getMonth() + durationMonths);

          return expiry > now;
        });

        if (activeTxn) return true;
        if (txns.length < 100) break;
        page++;
      } catch (e: any) {
        console.error(`Akal API fetch error: ${e.message}`);
        break;
      }
    }
  }
  return false;
}

function detectDurationMonths(priceSchemeTitle: string, serviceTitle: string): number {
  const s = (priceSchemeTitle + " " + serviceTitle).toLowerCase();
  if (s.includes("tahun") || s.includes("1y") || s.includes("year") || s.includes("annual")) return 12;
  if (s.includes("6 bulan") || s.includes("6m")) return 6;
  return 1;
}

// ================================================================
// FUNCTION: syncAkalPurchases (Otomasi Sinkronisasi Pembelian GoAkal)
// ================================================================
export const syncAkalPurchases = functions
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

    // Daftar service GoAkal resmi OpenTurath AI (Seluruh Disiplin Ilmu)
    const akalServices = [
      {
        cuid: "cmln2i27k0000jx047oabzw8p",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_tahawwulat",
        name: "AI Fikih Tahawwulat (5 Bilik AI)",
      },
      {
        cuid: "cms4ls3j60001l20439k1nqh4",
        fallbacks: ["cms4ls3j60001l20439k1nph4"],
        entitlementKey: "fiqh_syafii",
        name: "Super AI Fikih Syafi'i",
      },
      {
        cuid: "cmnd7l4o60002l504ab6qq31x",
        fallbacks: [] as string[],
        entitlementKey: "nahwu",
        name: "Super AI Bahasa Arab",
      },
      {
        cuid: "cmu6hf53s000mkx04jc3vrj02",
        fallbacks: [] as string[],
        entitlementKey: "ushul_fiqh",
        name: "Super AI Ushul Fikih",
      },
      {
        cuid: "cmu6hfbkn0015kx04d87j1b11",
        fallbacks: [] as string[],
        entitlementKey: "hadits",
        name: "Super AI Hadits Nabawi",
      },
      {
        cuid: "cmu6hfi5o000cjt04xziipmr2",
        fallbacks: [] as string[],
        entitlementKey: "tafsir",
        name: "Super AI Tafsir & Ulumul Qur'an",
      },
      {
        cuid: "cmu6hfq7m000cjm0414zlr67i",
        fallbacks: [] as string[],
        entitlementKey: "ushul_fiqh",
        name: "Super AI Qawaid Fiqhiyyah",
      },
      {
        cuid: "cmu6hfx13000xjm04np32pb64",
        fallbacks: [] as string[],
        entitlementKey: "hadits",
        name: "Super AI Musthalah & Ulumul Hadits",
      },
      {
        cuid: "cmu6hg3bh001gjm043hjueyh5",
        fallbacks: [] as string[],
        entitlementKey: "aqidah",
        name: "Super AI Aqidah & Ushuluddin",
      },
      {
        cuid: "cmu6hg9wl001zjm04lyds535x",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_hanafi",
        name: "Super AI Fikih Hanafi",
      },
      {
        cuid: "cmu6hgh6r002ijm040qddnmph",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_maliki",
        name: "Super AI Fikih Maliki",
      },
      {
        cuid: "cmu6hgo4z0031jm04bpdj07ki",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_hanbali",
        name: "Super AI Fikih Hanbali",
      },
      {
        cuid: "cmu6hgv6n003kjm04tit1vsh8",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_muqaran",
        name: "Super AI Fikih Muqaran & Siyasah",
      },
      {
        cuid: "cmu6hh1nn0043jm04r4h40wdb",
        fallbacks: [] as string[],
        entitlementKey: "fatawa",
        name: "Super AI Fatawa & Masail",
      },
      {
        cuid: "cmu6hh86n004mjm04ejgkhlg1",
        fallbacks: [] as string[],
        entitlementKey: "tasawwuf",
        name: "Super AI Tasawwuf & Adzkar",
      },
      {
        cuid: "cmu6hhet70055jm04ew3lb6wq",
        fallbacks: [] as string[],
        entitlementKey: "tajwid",
        name: "Super AI Tajwid & Qiraat",
      },
      {
        cuid: "cmu6hhl7a005ojm04pgptpegm",
        fallbacks: [] as string[],
        entitlementKey: "tarikh",
        name: "Super AI Tarikh & Sirah Nabawiyyah",
      },
      {
        cuid: "cmu6hhrvz0067jm04ljdfmycu",
        fallbacks: [] as string[],
        entitlementKey: "hadits",
        name: "Super AI Syarah Hadits",
      },
      {
        cuid: "cmu6hhyby006qjm04e0l3p11r",
        fallbacks: [] as string[],
        entitlementKey: "tarikh",
        name: "Super AI Thabaqat & Tarajim Rijal",
      },
      {
        cuid: "cmu6hi4lr0079jm0462vczjdm",
        fallbacks: [] as string[],
        entitlementKey: "bibliografi",
        name: "Super AI Bibliografi & Faharis Turath",
      },
      // ══════════════════════════════════════════════════════════════
      // 6 PAKET TEMATIK & SULTAN ALL-ACCESS (LAUNCH PROMO BUNDLES)
      // ══════════════════════════════════════════════════════════════
      {
        cuid: "cmu6rsq7z001gjn044acg1ke4",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_syafii",
        entitlementKeys: ["fiqh_syafii", "ushul_fiqh", "fiqh", "tasawwuf"],
        name: "Paket Fikih Pesantren & Santri Salaf",
      },
      {
        cuid: "cmu6rst3y001xjn0468aypvd0",
        fallbacks: [] as string[],
        entitlementKey: "hadits",
        entitlementKeys: ["hadits", "tarikh"],
        name: "Paket Samudra Hadits & Sirah Nabawiyyah",
      },
      {
        cuid: "cmu6rswk0002ejn04s90o870l",
        fallbacks: [] as string[],
        entitlementKey: "tafsir",
        entitlementKeys: ["tafsir", "nahwu", "tajwid", "bibliografi"],
        name: "Paket Mufassir & Khazanah Bahasa Arab",
      },
      {
        cuid: "cmu6rt0ja002vjn04pimuyd84",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_muqaran",
        entitlementKeys: ["fiqh_hanafi", "fiqh_maliki", "fiqh_hanbali", "fiqh_muqaran", "aqidah", "fiqh"],
        name: "Paket Mufti, Mazhab Akbar & Pemikiran",
      },
      {
        cuid: "cmu6rt3i6003cjn04wp9v6tqt",
        fallbacks: [] as string[],
        entitlementKey: "fiqh_tahawwulat",
        entitlementKeys: ["fiqh_tahawwulat"],
        name: "Paket Khusus Fikih Tahawwulat",
      },
      {
        cuid: "cmu6rt6aa003tjn04psx42goy",
        fallbacks: [] as string[],
        entitlementKey: "all_access",
        entitlementKeys: [
          "all_access",
          "fiqh_tahawwulat",
          "fiqh_syafii",
          "fiqh_hanafi",
          "fiqh_maliki",
          "fiqh_hanbali",
          "fiqh_muqaran",
          "fiqh",
          "ushul_fiqh",
          "nahwu",
          "tafsir",
          "tajwid",
          "hadits",
          "aqidah",
          "tasawwuf",
          "tarikh",
          "bibliografi"
        ],
        name: "Paket Sultan All-Access (Semua 24 AI)",
      },
    ];

    const syncedServices: string[] = [];
    const now = new Date();

    for (const service of akalServices) {
      const allCuids = [service.cuid, ...service.fallbacks];
      let activeTxn: any = null;

      for (const cuid of allCuids) {
        if (activeTxn) break;
        const statuses = ["PAID", "SETTLED"];

        for (const status of statuses) {
          if (activeTxn) break;
          let page = 1;
          const maxPages = 4;

          while (page <= maxPages) {
            const apiUrl = `https://goakal.com/service/api/v1/services/${cuid}/transactions?status=${status}&pageSize=100&page=${page}`;
            try {
              const response = await axios.get(apiUrl, {
                headers: { "X-Api-Key": apiKey },
                timeout: 8000,
              });

              const txns = response.data?.data || [];
              if (txns.length === 0) break;

              for (const t of txns) {
                const payerEmail = (t.payerEmail || "").trim().toLowerCase();
                if (payerEmail !== email) continue;

                let expiryDate: Date | null = null;
                if (t.expiryDate) {
                  expiryDate = new Date(t.expiryDate);
                } else {
                  const startStr = t.paidAt || t.createdAt;
                  if (startStr) {
                    const duration = detectDurationMonths(t.priceSchemeTitle || "", t.serviceTitle || "");
                    expiryDate = new Date(startStr);
                    expiryDate.setMonth(expiryDate.getMonth() + duration);
                  }
                }

                if (expiryDate && expiryDate > now) {
                  const durMonths = detectDurationMonths(t.priceSchemeTitle || "", t.serviceTitle || "");
                  const plan = durMonths === 12 ? "bahits_1y" : (durMonths === 6 ? "tholib_6m" : "tholib_1m");
                  activeTxn = {
                    id: t.id || `akal_${Date.now()}`,
                    payerName: t.payerName || "Santri Peneliti",
                    plan,
                    durationMonths: durMonths,
                    amount: Number(t.amount) || 0,
                    expiryDate,
                    serviceTitle: t.serviceTitle || service.name,
                  };
                  break;
                }
              }

              if (activeTxn || txns.length < 100) break;
              page++;
            } catch (e: any) {
              console.warn(`[syncAkalPurchases] Query failed for cuid ${cuid}: ${e.message}`);
              break;
            }
          }
        }
      }

      if (activeTxn) {
        // Tulis entitlement ke Firestore user (dukung multi-entitlement untuk bundle)
        const targetKeys = (service as any).entitlementKeys || [service.entitlementKey];
        const entUpdates: Record<string, any> = {};
        for (const k of targetKeys) {
          entUpdates[k] = {
            plan: activeTxn.plan,
            status: "active",
            expiry: admin.firestore.Timestamp.fromDate(activeTxn.expiryDate),
            source: "goakal",
            source_transaction_id: activeTxn.id,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          };
        }

        await db.collection("users").doc(uid).set({
          entitlements: entUpdates,
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        // Simpan catatan transaksi idempotensi
        await db.collection("transactions").doc(activeTxn.id).set({
          uid,
          customer_email: email,
          customer_name: activeTxn.payerName,
          plan: activeTxn.plan,
          amount: activeTxn.amount,
          duration_months: activeTxn.durationMonths,
          status: "success",
          source: "goakal",
          service_name: activeTxn.serviceTitle,
          entitlement_key: service.entitlementKey,
          subscription_expires_at: admin.firestore.Timestamp.fromDate(activeTxn.expiryDate),
          synced_at: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        // Auto-provision ke NotebookLM via Cloud Run
        try {
          await notifySubscriptionServer(email, activeTxn.payerName, activeTxn.plan, "add", activeTxn.serviceTitle);
        } catch (_) {}

        syncedServices.push(service.name);
      }
    }

    if (syncedServices.length > 0) {
      await sendTelegramNotification(
        `🔄 <b>[SINKRONISASI GOAKAL OTOMATIS]</b>\n` +
        `👤 Pengguna: <code>${email}</code>\n` +
        `📚 Hak Akses Aktif: <b>${syncedServices.join(", ")}</b>`
      );
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
export const akalWebhook = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onRequest(async (req, res) => {
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
    const token = payload.token || payload.data?.token || req.headers["x-akal-token"];
    if (typeof token !== "string" || !safeTimingEqual(token, akalSecret)) {
      console.warn("[Akal Webhook] Signature verification failed or missing token.");
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    const data = payload.data || payload;
    const status = (data.status || "").toUpperCase().trim();
    if (!["PAID", "SETTLED"].includes(status)) {
      console.log(`[Akal Webhook] Transaction status is '${status}'. Acknowledging receipt.`);
      res.status(200).json({ received: true, status });
      return;
    }

    const payer = data.payer || data.user || {};
    const email = (payer.email || "").trim().toLowerCase();
    const name = (payer.name || "").trim() || "Santri Peneliti";
    const service = data.service || {};
    const serviceTitle = (service.name || service.title || "").trim();
    const priceScheme = data.priceScheme || {};
    const priceSchemeTitle = (priceScheme.name || priceScheme.title || "").trim();
    const rawTxnId = typeof data.id === "string" ? data.id.trim() : "";
    const amount = Number(data.amount) || 0;
    // Tanpa ID dari Akal, turunkan ID deterministik agar retry webhook tetap idempoten.
    const txnId = /^[A-Za-z0-9_-]{1,128}$/.test(rawTxnId)
      ? rawTxnId
      : `akal_${crypto.createHash("sha256")
        .update(`${email}|${serviceTitle}|${priceSchemeTitle}|${data.paidAt || ""}|${amount}`)
        .digest("hex").slice(0, 40)}`;

    if (!email) {
      res.status(400).json({ error: "Missing payer email" });
      return;
    }

    // Tentukan entitlement keys (dukung bundle multi-entitlements)
    let entitlementKeys: string[] = ["fiqh_tahawwulat"];
    const sLower = serviceTitle.toLowerCase();
    if (sLower.includes("all") || sLower.includes("sultan") || sLower.includes("semua")) {
      entitlementKeys = [
        "all_access",
        "fiqh_tahawwulat",
        "fiqh_syafii",
        "fiqh_hanafi",
        "fiqh_maliki",
        "fiqh_hanbali",
        "fiqh_muqaran",
        "fiqh",
        "ushul_fiqh",
        "nahwu",
        "tafsir",
        "tajwid",
        "hadits",
        "aqidah",
        "tasawwuf",
        "tarikh",
        "bibliografi",
      ];
    } else if (sLower.includes("pesantren") || sLower.includes("santri salaf")) {
      entitlementKeys = ["fiqh_syafii", "ushul_fiqh", "fiqh", "tasawwuf"];
    } else if (sLower.includes("samudra hadits") || sLower.includes("hadits & sirah")) {
      entitlementKeys = ["hadits", "tarikh"];
    } else if (sLower.includes("mufassir") || (sLower.includes("bahasa arab") && sLower.includes("tafsir"))) {
      entitlementKeys = ["tafsir", "nahwu", "tajwid", "bibliografi"];
    } else if (sLower.includes("mufti") || sLower.includes("mazhab akbar")) {
      entitlementKeys = ["fiqh_hanafi", "fiqh_maliki", "fiqh_hanbali", "fiqh_muqaran", "aqidah", "fiqh"];
    } else if (sLower.includes("syafii") || sLower.includes("syafi'i")) {
      entitlementKeys = ["fiqh_syafii"];
    } else if (sLower.includes("arab") || sLower.includes("nahwu")) {
      entitlementKeys = ["nahwu"];
    } else if (sLower.includes("ushul")) {
      entitlementKeys = ["ushul_fiqh"];
    } else if (sLower.includes("hadits")) {
      entitlementKeys = ["hadits"];
    } else if (sLower.includes("tafsir")) {
      entitlementKeys = ["tafsir"];
    }

    const durationMonths = detectDurationMonths(priceSchemeTitle, serviceTitle);
    const plan = durationMonths === 12 ? "bahits_1y" : (durationMonths === 6 ? "tholib_6m" : "tholib_1m");

    const now = new Date();
    const baseDate = data.paidAt ? new Date(data.paidAt) : now;
    const expiryDate = new Date(baseDate);
    expiryDate.setDate(expiryDate.getDate() + (30 * durationMonths));

    // 1. Simpan catatan transaksi di Firestore
    await db.collection("transactions").doc(txnId).set({
      customer_email: email,
      customer_name: name,
      plan,
      amount,
      duration_months: durationMonths,
      status: "success",
      source: "goakal",
      service_name: serviceTitle,
      entitlement_key: entitlementKeys[0],
      entitlement_keys: entitlementKeys,
      paid_at: admin.firestore.Timestamp.fromDate(baseDate),
      processed_at: admin.firestore.FieldValue.serverTimestamp(),
      subscription_expires_at: admin.firestore.Timestamp.fromDate(expiryDate),
    }, { merge: true });

    // 2. Update dokumen user jika sudah terdaftar
    const usersSnap = await db.collection("users").where("email", "==", email).limit(1).get();
    if (!usersSnap.empty) {
      const userDoc = usersSnap.docs[0];
      const entUpdates: Record<string, any> = {};
      for (const k of entitlementKeys) {
        entUpdates[k] = {
          plan,
          status: "active",
          expiry: admin.firestore.Timestamp.fromDate(expiryDate),
          source: "goakal",
          source_transaction_id: txnId,
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        };
      }

      await userDoc.ref.set({
        entitlements: entUpdates,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      console.log(`[Akal Webhook] User ${email} entitlements '${entitlementKeys.join(", ")}' updated successfully.`);
    } else {
      console.log(`[Akal Webhook] User ${email} not yet registered in Firestore. Transaction stored.`);
    }

    // 3. Notifikasi Cloud Run sharing
    try {
      await notifySubscriptionServer(email, name, plan, "add", serviceTitle);
    } catch (_) {}

    // 4. Notifikasi Telegram
    await sendTelegramNotification(
      `⚡ <b>[WEBHOOK GOAKAL REALTIME]</b>\n` +
      `👤 Pembeli: <code>${email}</code> (${name})\n` +
      `📦 Layanan: <b>${serviceTitle}</b>\n` +
      `⏳ Paket: ${plan} (${durationMonths} bulan)\n` +
      `🔑 Entitlement: <code>${entitlementKeys.join(", ")}</code>\n` +
      `💰 Nominal: Rp ${amount.toLocaleString("id-ID")}\n` +
      `📅 Masa Aktif: s/d ${expiryDate.toISOString().split("T")[0]}`
    );

    res.status(200).json({ success: true, txnId, entitlementKeys });
  });


function verifySessionCookie(cookieHeader: string, secret: string): { uid: string; email: string } | null {
  if (!cookieHeader) return null;

  const cookies: Record<string, string> = {};
  cookieHeader.split(";").forEach(c => {
    const parts = c.trim().split("=");
    if (parts.length >= 2) {
      cookies[parts[0]] = parts.slice(1).join("=");
    }
  });

  const cookieValue = cookies[COOKIE_NAME];
  if (!cookieValue) return null;

  const parts = cookieValue.split(".");
  if (parts.length !== 2) return null;

  const [payloadB64, sigB64] = parts;

  try {
    const expectedSig = crypto.createHmac("sha256", secret).update(payloadB64).digest("base64url");
    if (!safeTimingEqual(sigB64, expectedSig)) return null;

    const payloadStr = Buffer.from(payloadB64, "base64url").toString("utf8");
    const payload = JSON.parse(payloadStr);

    if (typeof payload.uid !== "string" || !payload.uid ||
        typeof payload.email !== "string" || !Number.isFinite(payload.iat) ||
        payload.iat > Date.now() + 60000 || Date.now() - payload.iat > COOKIE_MAX_AGE * 1000) return null;
    return { uid: payload.uid, email: payload.email };
  } catch {
    return null;
  }
}

function generateCsrfToken(secret: string): string {
  const ts = Date.now().toString();
  const signature = crypto.createHmac("sha256", secret).update(ts).digest("base64url");
  return `${ts}.${signature}`;
}

function verifyCsrfToken(token: string, secret: string): boolean {
  if (!token) return false;
  const parts = token.split(".");
  if (parts.length !== 2) return false;
  const [ts, signature] = parts;
  const tsNum = parseInt(ts, 10);
  if (isNaN(tsNum) || Date.now() - tsNum > 3600 * 1000) return false; // 1 jam

  const expectedSig = crypto.createHmac("sha256", secret).update(ts).digest("base64url");
  return safeTimingEqual(signature, expectedSig);
}

function escapeHtml(str: string): string {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#x27;");
}

function maskEmail(email: string): string {
  if (!email || !email.includes("@")) return email;
  const [local, domain] = email.split("@");
  const masked = local[0] + "***";
  return `${masked}@${domain}`;
}

// ── HTML TEMPLATES ──

function getLoginHTML(ref: string, csrfToken: string, error: string): string {
  const errorMessages: Record<string, string> = {
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

function getChatWrapperHTML(agent: any, agentId: string, email: string): string {
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
  } else if (agentId === "fiqh_syafii") {
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
  } else if (agentId === "hadits") {
    descHtml = `<p>Kajian **Hadis & Syarah** memuat kitab-kitab hadis induk dan syarahnya untuk memeriksa matan, sanad, dan faedah hukum.</p>`;
    promptsHtml = `
      <div class="prompt-item" onclick="copyPrompt('Bagaimana penjelasan hadis tentang niat dalam Fatḥ al-Bārī?')">
        Penjelasan hadis niat di Fatḥ al-Bārī 📋
      </div>
      <div class="prompt-item" onclick="copyPrompt('Bagaimana menilai sanad riwayat ini?')">
        Penilaian sanad riwayat 📋
      </div>
    `;
  } else {
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
export const onClientErrorLogged = functions.firestore
  .document("client_error_logs/{logId}")
  .onCreate(async (snap, ctx) => {
    const data = snap.data();
    if (!data) return;

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
