import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import * as crypto from "crypto";

admin.initializeApp();
const db = admin.firestore();


// ================================================================
// HARGA & DURASI OTORITATIF — Ditentukan oleh `resolvePlanPricing`
// ================================================================

// URL NotebookLM — HANYA ADA DI SINI, TIDAK DI CLIENT
const AGENT_URLS: Record<string, string> = {
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
const AGENT_ENTITLEMENTS: Record<string, string> = {
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

function getEntitlementKey(agentId: string): string {
  const entitlementKey = AGENT_ENTITLEMENTS[agentId];
  if (!entitlementKey) {
    // Fallback jika ada id modul baru
    return agentId;
  }
  return entitlementKey;
}

function getEntitlementAccess(userData: FirebaseFirestore.DocumentData, entitlementKey: string): { premiumPlan: boolean; active: boolean } {
  const entitlements = userData.entitlements || {};

  // 1. Cek All Access (Paket Lengkap Semua AI)
  const allAccess = entitlements["all_access"];
  if (allAccess && typeof allAccess === "object") {
    const allExpiryVal = allAccess.expiry;
    const allExpiryDate = allExpiryVal
      ? (typeof allExpiryVal.toDate === "function" ? allExpiryVal.toDate() : new Date(allExpiryVal))
      : null;
    if (allExpiryDate && allExpiryDate > new Date()) {
      return { premiumPlan: true, active: true };
    }
  }

  // 2. Cek Modul Spesifik
  const productEntitlement = entitlements[entitlementKey];
  const access = productEntitlement && typeof productEntitlement === "object"
    ? productEntitlement
    // Dukungan sementara untuk pelanggan lama sebelum migrasi entitlement.
    : { plan: userData.plan, expiry: userData.subscription_expiry };
  const plan = access.plan as string | undefined;
  const expiryValue = access.expiry;
  const expiryDate = expiryValue
    ? (typeof expiryValue.toDate === "function" ? expiryValue.toDate() : new Date(expiryValue))
    : null;
  const premiumPlan = typeof plan === "string" &&
    (plan === "tholib" || plan === "bahits" || plan === "premium" || plan === "all_access" || plan.startsWith("tholib_") || plan.startsWith("bahits_"));

  return {
    premiumPlan,
    active: premiumPlan && expiryDate !== null && !Number.isNaN(expiryDate.getTime()) && expiryDate > new Date(),
  };
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
    const agentId = data.agentId as string;

    if (!agentId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "agentId diperlukan."
      );
    }

    const url = AGENT_URLS[agentId];
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
    const questionsUsed = (userData.questions_used as number) || 0;
    const entitlementKey = getEntitlementKey(agentId);

    const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
    if (entitlementAccess.active) {
      return { url };
    }
    if (entitlementAccess.premiumPlan) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Langganan Anda untuk modul ini telah berakhir atau belum memiliki masa berlaku."
      );
    }

    if (questionsUsed >= TRIAL_QUESTION_LIMIT) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Kuota trial Anda telah habis. Berlangganan untuk melanjutkan."
      );
    }

    return { url };
  });

// ================================================================
// FUNCTION 1b: recordQuestion
// Kuota trial hanya dapat berubah melalui transaksi server-side.
// ================================================================
export const recordQuestion = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login diperlukan.");
    }
    const agentId = data.agentId as string;
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
      const userData = snapshot.data()!;
      const entitlementAccess = getEntitlementAccess(userData, entitlementKey);
      if (entitlementAccess.active) {
        return { isPremium: true, questionsUsed: userData.questions_used || 0, questionsRemaining: null };
      }
      if (entitlementAccess.premiumPlan) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Langganan Anda untuk modul ini telah berakhir atau belum memiliki masa berlaku."
        );
      }

      const questionsUsed = Number.isInteger(userData.questions_used) ? userData.questions_used : 0;
      if (questionsUsed >= TRIAL_QUESTION_LIMIT) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "Kuota trial Anda telah habis. Berlangganan untuk melanjutkan."
        );
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
  const clientId = process.env.DOKU_CLIENT_ID || "BRN-0284-1788546176993";
  const secretKey = process.env.DOKU_SECRET_KEY || "SK-kWCZd3D5uGI3jfkGuiNj";
  const apiKey = process.env.DOKU_API_KEY || "doku_key_sandbox_d2b8d2827a02422cbf4d65ac1923ed88";
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
  const isAllAi = agentId === "all_ai" || plan.startsWith("all_ai");

  let durationMonths = 1;
  if (plan.includes("1y") || plan.includes("year") || plan === "bahits_1y") durationMonths = 12;
  else if (plan.includes("6m") || plan === "tholib_6m") durationMonths = 6;
  else durationMonths = 1;

  if (isAllAi) {
    const entitlementKey = "all_access";
    if (durationMonths === 12) {
      return { amount: 799000, durationMonths, label: "Paket Lengkap Semua AI (1 Tahun)", entitlementKey };
    } else if (durationMonths === 6) {
      return { amount: 499000, durationMonths, label: "Paket Lengkap Semua AI (6 Bulan)", entitlementKey };
    } else {
      return { amount: 99000, durationMonths, label: "Paket Promo Semua AI (1 Bulan)", entitlementKey };
    }
  }

  // Masing-masing AI per-modul: Rp 50.000 / bulan
  const entitlementKey = getEntitlementKey(agentId);
  const agentTitle = agentId.replace(/_/g, " ").replace(/\b\w/g, (l) => l.toUpperCase());
  if (durationMonths === 12) {
    return { amount: 450000, durationMonths, label: `Modul AI ${agentTitle} (1 Tahun)`, entitlementKey };
  } else if (durationMonths === 6) {
    return { amount: 250000, durationMonths, label: `Modul AI ${agentTitle} (6 Bulan)`, entitlementKey };
  } else {
    return { amount: 50000, durationMonths, label: `Modul AI ${agentTitle} (1 Bulan)`, entitlementKey };
  }
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
      phone: params.customerPhone || ""
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
    const { plan, name, email, phone, agentId } = data;

    if (!plan || !name || !email) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Data tidak lengkap (nama dan email diperlukan)."
      );
    }

    const currentAgentId = typeof agentId === "string" && agentId ? agentId : "fiqh_tahawwulat";
    const pricing = resolvePlanPricing(currentAgentId, plan as string);
    const invoiceNumber = `OT-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;

    const trxRef = db.collection("transactions").doc();
    const trxId = trxRef.id;
    const uid = context.auth?.uid || null;

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
    } catch (err: any) {
      console.error("[createCheckout] DOKU checkout error:", err.response?.data || err.message);
      throw new functions.https.HttpsError(
        "internal",
        "Gagal membuat sesi pembayaran DOKU: " + (err.response?.data?.error?.message || err.message || "Kendala teknis DOKU")
      );
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

async function processSuccessfulPayment(invoiceNumber: string) {
  const txQuery = await db.collection("transactions")
    .where("invoice_number", "==", invoiceNumber)
    .limit(1)
    .get();

  if (txQuery.empty) {
    console.warn(`[Activation] Transaction not found for invoice: ${invoiceNumber}`);
    return { success: false, message: "Transaction not found" };
  }

  const txDoc = txQuery.docs[0];
  const txData = txDoc.data();

  const uid = txData.uid;
  const email = (txData.customer_email || "").trim().toLowerCase();
  const durationMonths = txData.duration_months || 1;
  const entitlementKey = txData.entitlement_key || "fiqh_tahawwulat";
  const plan = txData.plan || "premium";

  const now = new Date();
  const expiryDate = new Date(now);
  expiryDate.setMonth(expiryDate.getMonth() + durationMonths);

  // 1. Update Dokumen Transaksi
  await txDoc.ref.update({
    status: "success",
    paid_at: admin.firestore.FieldValue.serverTimestamp(),
    subscription_expires_at: admin.firestore.Timestamp.fromDate(expiryDate),
  });

  // 2. Hubungkan & Update Dokumen User
  let userRef: FirebaseFirestore.DocumentReference;
  if (uid) {
    userRef = db.collection("users").doc(uid);
  } else {
    const uQuery = await db.collection("users").where("email", "==", email).limit(1).get();
    if (!uQuery.empty) {
      userRef = uQuery.docs[0].ref;
    } else {
      userRef = db.collection("users").doc();
    }
  }

  const uSnap = await userRef.get();
  const uData = uSnap.exists ? uSnap.data()! : {};
  const entitlements = uData.entitlements || {};

  const updatedEntitlements = {
    ...entitlements,
    [entitlementKey]: {
      plan: plan,
      status: "active",
      expiry: admin.firestore.Timestamp.fromDate(expiryDate),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    }
  };

  await userRef.set({
    email: email,
    name: uData.name || txData.customer_name || "Santri OpenTurath",
    plan: plan,
    subscription_expiry: admin.firestore.Timestamp.fromDate(expiryDate),
    entitlements: updatedEntitlements,
    questions_used: 0,
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log(`[Activation] Akses berhasil diaktifkan untuk ${email} (Modul: ${entitlementKey}) hingga ${expiryDate.toISOString()}`);

  // 3. Trigger NotebookLM sharing pada server Cloud Run
  try {
    let serviceTitle = "Paket Semua AI";
    if (entitlementKey === "all_access" || entitlementKey === "all_ai") {
      serviceTitle = "Paket Semua AI";
    } else if (entitlementKey === "fiqh_tahawwulat") {
      serviceTitle = "AI Fikih Tahawwulat";
    } else if (entitlementKey === "fiqh_syafii") {
      serviceTitle = "AI Fikih Syafi'i";
    } else if (entitlementKey === "fiqh_hanafi") {
      serviceTitle = "AI Fikih Hanafi";
    } else if (entitlementKey === "fiqh_maliki") {
      serviceTitle = "AI Fikih Maliki";
    } else if (entitlementKey === "fiqh_hanbali") {
      serviceTitle = "AI Fikih Hanbali";
    } else if (entitlementKey === "fiqh_muqaran") {
      serviceTitle = "AI Fikih Perbandingan Mazhab";
    } else if (entitlementKey === "ushul_fiqh") {
      serviceTitle = "AI Ushul Fiqih";
    } else if (entitlementKey === "tafsir") {
      serviceTitle = "AI Tafsir";
    } else if (entitlementKey === "hadits") {
      serviceTitle = "AI Hadits";
    } else if (entitlementKey === "nahwu" || entitlementKey === "bahasa_arab" || entitlementKey === "nahwu_sharaf") {
      serviceTitle = "AI Bahasa Arab";
    } else {
      serviceTitle = "Paket Semua AI";
    }

    // Non-blocking asynchronous background execution so client inquiry returns immediately (<1s)
    notifySubscriptionServer(email, txData.customer_name || "User", plan, "add", serviceTitle)
      .then(() => console.log(`[Activation] Background subscription notification completed for ${email}`))
      .catch((e: any) => console.error("[Activation] Background notification to subscription server error:", e.message));
  } catch (e: any) {
    console.error("[Activation] Failed to initiate subscription server notification:", e.message);
  }

  return { success: true, entitlementKey, plan, email };
}

// ================================================================
// FUNCTION 2b: dokuWebhook (HTTP Notification dari DOKU)
// Otomatis aktifkan akses santri di Firestore saat bayar sukses
// ================================================================
export const dokuWebhook = functions
  .runWith({ serviceAccount: "open-turath@appspot.gserviceaccount.com" })
  .https.onRequest(async (req, res) => {
    try {
      const headers = req.headers;
      const body = req.body || {};
      console.log("[DOKU Webhook] Headers:", JSON.stringify(headers));
      console.log("[DOKU Webhook] Payload Body:", JSON.stringify(body));

      // Verifikasi Signature DOKU wajib di seluruh environment
      const incomingSignature = (headers["signature"] || headers["Signature"]) as string | undefined;
      const dokuCfg = getDokuConfig();
      if (!incomingSignature) {
        console.error("[DOKU Webhook] Missing signature header.");
        res.status(401).send("Missing signature header");
        return;
      }

      const clientId = (headers["client-id"] || headers["Client-Id"] || dokuCfg.clientId) as string;
      const requestId = (headers["request-id"] || headers["Request-Id"] || "") as string;
      const timestamp = (headers["request-timestamp"] || headers["Request-Timestamp"] || "") as string;
      const rawBody = (req as any).rawBody
        ? (req as any).rawBody.toString("utf8")
        : (typeof req.body === "string" ? req.body : JSON.stringify(req.body || {}));

      const expectedSig1 = generateDokuSignature(clientId, requestId, timestamp, req.originalUrl || "/dokuWebhook", rawBody, dokuCfg.secretKey);
      const expectedSig2 = generateDokuSignature(clientId, requestId, timestamp, req.path || "/dokuWebhook", rawBody, dokuCfg.secretKey);
      const expectedSig3 = generateDokuSignature(clientId, requestId, timestamp, "/dokuWebhook", rawBody, dokuCfg.secretKey);

      if (incomingSignature !== expectedSig1 && incomingSignature !== expectedSig2 && incomingSignature !== expectedSig3) {
        console.error(`[DOKU Webhook] Signature mismatch. Incoming: ${incomingSignature}`);
        res.status(401).send("Invalid signature");
        return;
      }

      const invoiceNumber = body.order?.invoice_number || body.invoice_number;
      const status = body.transaction?.status || body.transactionStatus || body.status;

      if (!invoiceNumber) {
        console.warn("[DOKU Webhook] Missing invoice_number in notification.");
        res.status(400).send("Missing invoice_number");
        return;
      }

      if (status !== "SUCCESS") {
        console.log(`[DOKU Webhook] Status: ${status}, skipping activation.`);
        res.status(200).json({ status: "OK", message: "Ignored status" });
        return;
      }

      const result = await processSuccessfulPayment(invoiceNumber);
      res.status(200).json({ status: "SUCCESS", result });
    } catch (err: any) {
      console.error("[DOKU Webhook] Uncaught error:", err);
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
    if (txData.status === "success") {
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
        const actResult = await processSuccessfulPayment(invoiceNumber);
        return {
          success: true,
          status: "SUCCESS",
          message: "Pembayaran berhasil diverifikasi! Akses Anda telah aktif.",
          details: actResult
        };
      } else {
        return {
          success: false,
          status: trxStatus || "PENDING",
          message: "Pembayaran belum diselesaikan atau masih diproses."
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
  });

// ================================================================
// FUNCTION 3.5: onUserCreate
// Dipanggil otomatis saat user pertama kali register di app
// Menghubungkan transaksi sukses sebelumnya berdasarkan email
// ================================================================
export const onUserCreate = functions.firestore
  .document("users/{uid}")
  .onCreate(async (snapshot, context) => {
    try {
      const userData = snapshot.data();
      const email = userData.email;
      const uid = context.params.uid;

      if (!email) return null;

      console.log(`onUserCreate: Checking transactions for email: ${email}`);

      // Cari semua transaksi sukses untuk email ini
      const trxQuery = await db
        .collection("transactions")
        .where("customer_email", "==", email)
        .where("status", "==", "success")
        .get();

      if (trxQuery.empty) {
        console.log(`onUserCreate: No successful transactions found for ${email}`);
        return null;
      }

      // Kumpulkan seluruh entitlement modul yang aktif dan cari tanggal kedaluwarsa terjauh
      let latestTrxDoc = trxQuery.docs[0];
      let latestExpiry = latestTrxDoc.data().subscription_expires_at;
      const entitlements: Record<string, any> = {};
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

        try {
          await notifySubscriptionServer(email, userData.name || "User", latestTrxData.plan, "add");
        } catch (err: any) {
          console.error("Failed to notify subscription server in onUserCreate:", err.message);
        }

        await db.collection("sharing_log").add({
          email,
          uid,
          action: "add",
          method: "on_user_create_sync",
          entitlements: Object.keys(entitlements),
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        console.log(`onUserCreate: Found transactions for ${email} but they are already expired`);
      }
    } catch (err) {
      console.error("Error in onUserCreate trigger:", err);
    }
    return null;
  });


// ================================================================
// FUNCTION 4: dailyRevoke (Cron Job — tiap tengah malam)
// ================================================================
export const dailyRevoke = functions
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
      
      // Filter plan in memory to avoid composite index requirement
      if (!["tholib", "bahits", "tholib_1m", "tholib_6m", "bahits_1y", "premium", "all_access"].includes(plan)) {
        continue;
      }
      
      const email = userData.email;

      // Revoke modular entitlements jika expired
      const entitlements = userData.entitlements || {};
      let hasExpiredEntitlement = false;
      const updatedEntitlements = { ...entitlements };

      for (const [key, val] of Object.entries(entitlements)) {
        if (val && typeof val === "object") {
          const item = val as any;
          const exp = item.expiry
            ? (typeof item.expiry.toDate === "function" ? item.expiry.toDate() : new Date(item.expiry))
            : null;
          if (exp && exp <= now.toDate() && item.status !== "expired") {
            updatedEntitlements[key] = {
              ...item,
              status: "expired",
              updated_at: admin.firestore.FieldValue.serverTimestamp(),
            };
            hasExpiredEntitlement = true;
          }
        }
      }

      const updateData: any = {
        plan: "trial",
        subscription_expiry: null,
        questions_used: 0,
      };
      if (hasExpiredEntitlement) {
        updateData.entitlements = updatedEntitlements;
      }

      await doc.ref.update(updateData);

      if (email) {
        console.log(`🔒 Akses premium berakhir untuk ${email}.`);

        try {
          await notifySubscriptionServer(email, userData.name || "User", "trial", "remove");
        } catch (err: any) {
          console.error("Failed to notify subscription server in dailyRevoke:", err.message);
        }

        await db.collection("sharing_log").add({
          email,
          uid: doc.id,
          action: "remove",
          method: "webview_gatekeeper",
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    console.log(
      `✅ Selesai memproses ${expiredUsers.size} expired subscriptions.`
    );
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
        console.error("INTERNAL_SECRET not set! Skipping notification.");
        return;
      }
      await axios.post(url, payload, {
        headers: {
          "Content-Type": "application/json",
          "X-Internal-Secret": internalSecret
        },
      });
      console.log(`Successfully notified subscription server: ${action} ${email} for ${service}`);
    } catch (err: any) {
      console.error(`Failed to notify subscription server for ${service}:`, err.message);
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
      const hasAccess = await verifySubscriptionFirestore(
        session.email,
        agent.entitlementKey
      );
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

async function handleLogin(req: functions.Request, res: functions.Response, secret: string, apiKey: string) {
  const email = (req.body.email as string || "").trim().toLowerCase();
  const csrfTokenForm = req.body.csrf_token as string || "";
  const ref = req.body.ref as string || "fikih-tahawwulat-muhaqqiq";

  if (!email || !email.includes("@")) {
    res.redirect(`/login?ref=${ref}&error=invalid_email`);
    return;
  }

  if (!verifyCsrfToken(csrfTokenForm, secret)) {
    res.redirect(`/login?ref=${ref}&error=invalid_request`);
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

async function verifySubscriptionFirestore(email: string, entitlementKey: string): Promise<boolean> {
  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();

  // A. Check if user document exists and has active entitlement
  const userQuery = await db.collection("users").where("email", "==", email).limit(1).get();
  if (!userQuery.empty) {
    const userData = userQuery.docs[0].data();
    
    // Check specific entitlement expiry
    const entitlements = userData.entitlements || {};
    const ent = entitlements[entitlementKey];
    if (ent && ent.expiry) {
      if (ent.expiry.toDate() > new Date()) {
        return true;
      }
    }
    
    // Legacy global fallback check
    if (userData.subscription_expiry) {
      if (userData.subscription_expiry.toDate() > new Date()) {
        return true;
      }
    }
  }

  // B. Check if there is a successful transaction in Firestore
  const txQuery = await db.collection("transactions")
    .where("customer_email", "==", email)
    .where("status", "==", "success")
    .get();

  if (!txQuery.empty) {
    for (const doc of txQuery.docs) {
      const tx = doc.data();
      const expiresAt = tx.subscription_expires_at;
      const txEntitlement = tx.entitlement_key || "fiqh_tahawwulat";
      
      if (txEntitlement === entitlementKey && expiresAt && expiresAt.toDate() > new Date()) {
        // Auto-initialize user doc if they exist in transactions but not in users collection
        let userRef;
        let userData: any = {};
        
        if (!userQuery.empty) {
          userRef = userQuery.docs[0].ref;
          userData = userQuery.docs[0].data();
        } else {
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
          entitlements: {
            ...userData.entitlements,
            [entitlementKey]: {
              plan: plan,
              expiry: expiryDate,
              updated_at: now
            }
          },
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

function verifySessionCookie(cookieHeader: string, secret: string): { email: string } | null {
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
    if (sigB64 !== expectedSig) return null;

    const payloadStr = Buffer.from(payloadB64, "base64url").toString("utf8");
    const payload = JSON.parse(payloadStr);

    if (Date.now() - payload.iat > COOKIE_MAX_AGE * 1000) return null;

    return { email: payload.email };
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
  return signature === expectedSig;
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

function getChatWrapperHTML(agent: any, agentId: string, email: string): string {
  const chatUrl = `https://notebooklm.google.com/notebook/${agent.notebookId}/preview`;
  const isFikih = agentId.includes("fikih");
  
  const promptsHtml = isFikih ? `
    <div class="prompt-item" onclick="copyPrompt('Jelaskan konsep Al-Ghuthsa’iyyah (era buih) berdasarkan penjelasan kitab!')">
      Jelaskan konsep Al-Ghuthsa’iyyah (era buih) 📋
    </div>
    <div class="prompt-item" onclick="copyPrompt('Apa perbedaan mendasar antara Al-Muhaqqiq dan Al-Bayan dalam Fikih Tahawwulat?')">
      Perbedaan Al-Muhaqqiq & Al-Bayan 📋
    </div>
    <div class="prompt-item" onclick="copyPrompt('Bagaimana cara menyikapi fitnah akhir zaman sesuai petunjuk Habib Abu Bakar?')">
      Menyikapi fitnah akhir zaman 📋
    </div>
  ` : `
    <div class="prompt-item" onclick="copyPrompt('Jelaskan pengertian I\\\'rab dan berikan contohnya!')">
      Jelaskan pengertian I'rab & contohnya 📋
    </div>
    <div class="prompt-item" onclick="copyPrompt('Bagaimana cara men-tashrif fi\\\'il tsulatsi mujarrad bab 1?')">
      Cara men-tashrif tsulatsi mujarrad 📋
    </div>
    <div class="prompt-item" onclick="copyPrompt('Tunjukkan perbedaan isim fail dan isim maful!')">
      Perbedaan isim fa'il & isim maf'ul 📋
    </div>
  `;

  const descHtml = isFikih ? `
    <p>Modul **AI Fikih Tahawwulat** dirancang khusus untuk membedah kajian ilmu Fikih Kontemporer, tanda akhir zaman, dan panduan fiqih praktis berdasarkan kitab kurasi para ulama.</p>
  ` : `
    <p>Modul **AI Bahasa Arab (Nahwu Sharaf)** dikonfigurasi untuk membantu Anda memahami kaidah tata bahasa Arab secara terperinci, termasuk i'rab, bina', dan tashrif kata.</p>
  `;

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
          <div class="user-status"><div class="status-dot"></div>Panduan Akses</div>
          <div style="font-size: 11px; color: rgba(255,255,255,0.45); margin-top: 4px; line-height: 1.4;">
            Pastikan Anda masuk ke Google/Gmail di browser ini menggunakan email yang terdaftar di Akal.
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
        <div class="section-title">Tentang Modul</div>
        <div class="desc-box">
          ${descHtml}
        </div>
      </div>

      <div class="sidebar-section">
        <div class="section-title">Ide Pertanyaan</div>
        <div class="prompt-list">
          ${promptsHtml}
        </div>
      </div>
      
      <div style="flex-grow: 1;"></div>
      
      <a href="https://wa.me/628123456789" target="_blank" class="btn-help">
        💬 Hubungi Bantuan Admin
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
