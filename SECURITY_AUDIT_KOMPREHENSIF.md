# 🔴 AUDIT KEAMANAN & BLIND SPOT — SELURUH REPOSITORY OPENTURATH

**Tanggal Audit:** 12 Juli 2026  
**Auditor:** Kiro AI Security Review  
**Cakupan:** openturath_ai, openturath_proxy, openturath_subscription, openturath_extension, notebooklm scripts, sharing_daemon

---

## 🚨 TEMUAN KRITIS (SEVERITY: CRITICAL)

### 1. SERVICE ACCOUNT KEY TEREKSPOS DALAM PLAINTEXT
**File:** `service-account.json` (ROOT DIRECTORY)  
**Risiko:** TOTAL COMPROMISE — Siapa pun yang mendapat akses ke file ini dapat mengontrol penuh project Firebase "open-turath" termasuk:
- Baca/tulis semua data Firestore
- Mengelola semua user Firebase Auth
- Deploy Cloud Functions
- Akses Cloud Storage
- Impersonate service account untuk GCP resources

**Bukti:**
```
"private_key_id": "932958f83c8f1dc4e25770011bc05e8295be6ca4"
"client_email": "firebase-adminsdk-fbsvc@open-turath.iam.gserviceaccount.com"
```

**TINDAKAN SEGERA:**
1. Rotasi key ini SEKARANG di Firebase Console → Project Settings → Service Accounts → Generate New Key
2. Hapus file dari repo dan tambahkan ke `.gitignore`
3. Gunakan environment variable `GOOGLE_APPLICATION_CREDENTIALS` untuk deployment

---

### 2. SEMUA API KEYS & SECRETS TEREKSPOS DALAM FILE .ENV YANG ADA DI REPO
**File:** `openturath_ai/functions/.env` dan `openturath_subscription/.env`

**Secrets terekspos:**
| Secret | File | Risiko |
|--------|------|--------|
| `MIDTRANS_SERVER_KEY` (Mid-server-UUSqxS1kKrL6WfeR_efAmXat) | functions/.env | Payment fraud |
| `MIDTRANS_CLIENT_KEY` | functions/.env | Medium |
| `AKAL_API_KEY` (ak_054c0e...) | Kedua file | Akses API Akal penuh |
| `AKAL_WEBHOOK_SECRET` | subscription/.env | Webhook forgery |
| `COOKIE_SECRET` | functions/.env | Session hijack |
| `INTERNAL_SECRET` (openturath_internal_sec_2026_x99) | Kedua file | Bypass auth webhook |

**CATATAN:** `openturath_subscription/.gitignore` memang ada dan mengecualikan `.env`, TAPI file `.env` tetap terbaca dari disk. Jika repo ini pernah di-commit ke Git dengan `.env` di dalamnya, secret sudah bocor di history.

---

### 3. GOOGLE SESSION COOKIES LENGKAP TEREKSPOS
**File:** `openturath_subscription/.env` (baris 33, variabel `NOTEBOOKLM_AUTH_JSON`)

**Ini adalah bencana.** File berisi SELURUH cookie session Google Anda termasuk:
- `SID`, `SSID`, `HSID`, `SAPISID`, `__Secure-1PSID`, `__Secure-3PSID`
- Cookie `OSID` untuk: Gmail, Drive, Docs, Firebase Console, Gemini, NotebookLM, Play Store, Calendar, Photos, dll
- `GMAIL_AT` tokens (4 akun berbeda)
- `ACCOUNT_CHOOSER` dengan semua akun
- `LSID` dan `__Host-GAPS` auth tokens

**Dampak:** Siapa pun dengan cookie ini bisa:
- Membaca semua email Anda
- Mengakses Google Drive, Docs, Sheets
- Mengelola Firebase Console
- Membeli di Play Store/Google Store
- Login ke semua layanan Google sebagai Anda

**TINDAKAN SEGERA:**
1. Segera logout dari SEMUA sesi Google: https://myaccount.google.com/device-activity
2. Ubah password Google
3. Hapus baris `NOTEBOOKLM_AUTH_JSON` dari file

---

## 🟠 TEMUAN HIGH SEVERITY

### 4. CHATGATE FUNCTION TIDAK ADA AUTH — AKSES LANGSUNG KE NOTEBOOKLM
**File:** `openturath_ai/functions/src/index.ts` (baris 437-470)

```typescript
export const chatGate = functions.https.onRequest(async (req, res) => {
  // ...
  if (chatMatch) {
    const agent = AGENTS[agentId];
    if (!agent) { res.status(404).send(...); return; }
    // ⚠️ LANGSUNG KIRIM HTML DENGAN NOTEBOOK URL TANPA VERIFIKASI!
    res.send(getChatWrapperHTML(agent, agentId, ""));
    return;
  }
});
```

**Masalah:** Function `chatGate` mengirim HTML berisi iframe ke NotebookLM **tanpa verifikasi session/auth apapun**. Siapa pun yang tahu URL `/chat/fikih-tahawwulat-muhaqqiq` langsung mendapat akses.

**Kontras:** Function `getAgentUrl` (dipanggil dari Flutter app) melakukan verifikasi auth + plan + expiry dengan benar. Tapi `chatGate` adalah backdoor terbuka.

---

### 5. NOTEBOOK ID HARDCODED & DAPAT DIAKSES LANGSUNG
**File:** Multiple files

Notebook IDs terekspos di:
- `openturath_ai/functions/src/index.ts` (AGENT_URLS & AGENTS)
- `openturath_proxy/src/index.js` (AGENTS object)
- `openturath_extension/lib/constants.js` (OT_CONFIG.AGENTS)
- `openturath_ai/lib/core/constants.dart` (via injection script logic)

**Notebook IDs:**
- `dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4` (Fikih Al-Muhaqqiq)
- `483d0291-0a70-411c-bff0-f1ea4b83b2fd` (Fikih Al-Bayan)
- `405b035c-5b48-471d-9fe2-54d6ae5d654d` (Nahwu Sharaf)

**Risiko:** Jika notebook ini di-set ke "Anyone with the link can view" (untuk mendukung iframe embedding), maka URL langsung ini bisa diakses tanpa berlangganan:
```
https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4/preview
```

---

### 6. INTERNAL_SECRET TERLALU LEMAH & DIGUNAKAN SEBAGAI SHARED SECRET
**File:** `openturath_ai/functions/.env` & `openturath_subscription/.env`

```
INTERNAL_SECRET=openturath_internal_sec_2026_x99
```

Secret ini digunakan untuk:
- Autentikasi Cloud Functions → webhook_server.py (header `X-Internal-Secret`)
- Bypass verifikasi Akal webhook token

**Masalah:**
1. Secret terlalu pendek dan predictable
2. Digunakan di multiple services tanpa rotation mechanism
3. Jika bocor, attacker bisa memicu webhook palsu untuk memberikan akses premium ke email apapun

---

### 7. CSRF TOKEN TIDAK BENAR-BENAR RANDOM
**File:** `openturath_proxy/src/index.js` (baris 300-306) & `openturath_ai/functions/src/index.ts`

```javascript
async function generateCsrfToken(env) {
  const ts = Date.now().toString();
  const key = await importHmacKey(env.COOKIE_SECRET || "fallback-not-secure");
  // ...
}
```

**Masalah:**
1. CSRF token hanya berdasarkan timestamp + HMAC — **tidak ada randomness**. Attacker yang tahu secret bisa generate token valid.
2. Fallback `"fallback-not-secure"` — jika COOKIE_SECRET tidak di-set, CSRF protection tidak berfungsi sama sekali.

---

## 🟡 TEMUAN MEDIUM SEVERITY

### 8. TRIAL QUOTA BYPASS — CLIENT-SIDE ENFORCEMENT
**File:** `openturath_ai/lib/screens/agent_webview_screen.dart`

```dart
void _onQuestionAnswered(int totalResponses) async {
  if (_user?.isPremium == true) return;
  setState(() => _localQuestionCount++);
  await _agentService.incrementQuestionCount(_user!.uid);
  if (_localQuestionCount >= limit) {
    setState(() => _showPaywall = true);
  }
}
```

**Masalah:**
- Quota tracking bergantung pada JavaScript injection yang mendeteksi "Enter key" atau "Send button click"
- User bisa menggunakan browser DevTools/extension untuk menghapus event listener atau memodifikasi `_localQuestionCount`
- Lebih kritis: Firestore rules MEMPROTEKSI `questions_used` dari client update, TAPI function `incrementQuestionCount` menggunakan `FieldValue.increment(1)` — ini BENAR dari security standpoint. Namun, jika user re-install app atau clear data, `_localQuestionCount` reset ke 0 di memori lokal walaupun Firestore tetap benar.

**Blind Spot:** Server function `getAgentUrl` mengecek quota, tapi HANYA saat pertama kali membuka agent. Setelah URL di-load di WebView, user bisa terus bertanya tanpa batas karena **enforcement hanya di client-side JS injection**.

---

### 9. WEBVIEW NAVIGATION WHITELIST TERLALU LEBAR
**File:** `openturath_ai/lib/screens/agent_webview_screen.dart` (baris 341-343)

```dart
final isAllowed = host == 'notebooklm.google.com' ||
                  host == 'accounts.google.com' ||
                  host.endsWith('.google.com');
```

**Masalah:** `host.endsWith('.google.com')` mengizinkan navigasi ke SEMUA subdomain Google termasuk:
- `sites.google.com` (bisa berisi phishing pages)
- `docs.google.com`, `drive.google.com` (data exfiltration)
- `translate.google.com` (proxy bypass)

---

### 10. WEBHOOK SERVER TANPA RATE LIMITING
**File:** `openturath_subscription/webhook_server.py`

Server webhook menggunakan `BaseHTTPRequestHandler` tanpa:
- Rate limiting
- IP whitelist
- Request size limit (hanya `Content-Length` header, tapi tidak ada max cap)

Attacker bisa melakukan denial-of-service atau bruteforce INTERNAL_SECRET.

---

### 11. PUPPETEER AUTOMATION — FRAGILE & INSECURE
**File:** `sharing_daemon.js` & `notebooklm_sharer.js`

**Masalah arsitektural:**
1. Menggunakan persistent Chrome session (`chrome_session/`) — jika session expired, seluruh automation berhenti
2. `headless: false` — membutuhkan display environment
3. Hardcoded executable path: `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
4. Tidak ada retry mechanism yang robust untuk Google UI changes
5. Jika Google mengubah DOM selectors (`mat-dialog-container`, `peoplekitComponentsResultlistitemResultListItem`), seluruh sistem sharing rusak tanpa notifikasi

---

### 12. PRICE INCONSISTENCY ANTARA CLIENT DAN SERVER
**File:** 
- `openturath_ai/lib/core/constants.dart`: `priceTholib1m = 299000`, `priceBahits1y = 1999000`
- `openturath_ai/functions/src/index.ts`: `tholib_1m: { amount: 49000 }`, `bahits_1y: { amount: 449000 }`

**Masalah:** Harga di client (yang ditampilkan ke user) berbeda JAUH dari harga di server catalog. Ini menyebabkan kebingungan dan potential fraud jika payment gateway menagih harga server (lebih murah) tapi UI menampilkan harga lebih tinggi.

---

## 🔵 TEMUAN LOW SEVERITY / BLIND SPOTS ARSITEKTURAL

### 13. TIDAK ADA `.gitignore` DI ROOT DIRECTORY
**Risiko:** File sensitif seperti `service-account.json`, `chrome_session/`, `app-release.apk`, `*.log` dapat ter-commit ke Git.

### 14. EXTENSION TIDAK MEMVALIDASI ORIGIN
**File:** `openturath_extension/content.js`

Extension inject UI ke `notebooklm.google.com` berdasarkan URL pattern match saja. Tidak ada validasi bahwa user memiliki subscription aktif — ekstensi berfungsi penuh untuk siapa pun.

### 15. DUPLIKASI LOGIKA ANTAR KOMPONEN
Auth verification logic ada di 4 tempat berbeda:
1. `openturath_ai/functions/src/index.ts` (getAgentUrl + chatGate)
2. `openturath_proxy/src/index.js` (Cloudflare Worker)
3. `openturath_subscription/webhook_server.py` (Firestore check)
4. Client-side Flutter (trial counter)

Setiap perubahan harus di-sync manual ke 4 tempat — high risk of inconsistency.

### 16. COOKIE-ONLY AUTH DI PROXY TANPA 2FA/OTP
**File:** `openturath_proxy/src/index.js`

Login hanya memerlukan email (tanpa password/OTP). Attacker yang tahu email subscriber bisa saja login jika subscriber memiliki transaksi aktif di Akal.

Namun, cookie hanya berlaku 8 jam dan tidak memberikan akses data — hanya iframe ke NotebookLM.

### 17. NO LOGGING/ALERTING UNTUK SECURITY EVENTS
Tidak ada monitoring untuk:
- Failed login attempts
- Unusual API usage patterns
- Webhook verification failures
- Service account usage anomalies

### 18. APK FILE DI REPO
**File:** `app-release.apk` dan `openturath-release.apk`

APK di repo bisa di-reverse engineer untuk mengekstrak Firebase config, hardcoded strings, dan business logic.

---

## 📋 RINGKASAN PRIORITAS TINDAKAN

| # | Tindakan | Prioritas | Effort |
|---|----------|-----------|--------|
| 1 | **ROTASI service-account.json** & hapus dari repo | 🔴 SEKARANG | 10 min |
| 2 | **Logout semua sesi Google** & hapus cookies dari .env | 🔴 SEKARANG | 5 min |
| 3 | **Rotasi semua API keys** (Midtrans, Akal, secrets) | 🔴 Hari ini | 30 min |
| 4 | Tambahkan `.gitignore` di root (service-account.json, .env, *.apk, chrome_session/) | 🔴 Hari ini | 5 min |
| 5 | Fix `chatGate` — tambahkan session verification | 🟠 Minggu ini | 2 jam |
| 6 | Gunakan Secret Manager (GCP/CF) bukan .env files | 🟠 Minggu ini | 4 jam |
| 7 | Implementasi server-side quota enforcement per-request | 🟠 Minggu ini | 4 jam |
| 8 | Generate INTERNAL_SECRET yang kuat (min 64 char random) | 🟠 Minggu ini | 10 min |
| 9 | Tambahkan rate limiting ke webhook server | 🟡 2 minggu | 2 jam |
| 10 | Sinkronkan harga client ↔ server catalog | 🟡 2 minggu | 1 jam |
| 11 | Tambahkan logging/alerting security events | 🟡 1 bulan | 8 jam |
| 12 | Migrasi dari Puppeteer ke API-based sharing (jika tersedia) | 🔵 Roadmap | Variable |

---

## 🏗️ BLIND SPOTS ARSITEKTURAL

1. **Single Point of Failure:** Seluruh sistem bergantung pada NotebookLM Google tetap bisa di-embed via iframe. Jika Google menonaktifkan iframe/preview mode, seluruh produk mati.

2. **No Graceful Degradation:** Jika Akal API down, proxy worker gagal login user. Tidak ada fallback ke Firestore-only verification di Cloudflare Worker.

3. **Session Persistence:** Puppeteer sharing bergantung pada Google session cookies yang expire. Tidak ada auto-refresh mechanism.

4. **Race Condition pada Webhook:** Jika dua webhook datang bersamaan untuk email yang sama (PAID + EXPIRED), urutan processing bisa menyebabkan state inconsistency di Firestore.

5. **Tidak ada mekanisme subscription renewal notification** ke user sebelum expired. User tiba-tiba kehilangan akses tanpa warning.

6. **Extension bisa di-fork** — karena semua notebook IDs ada di `constants.js`, siapa pun bisa membuat extension serupa yang mengakses notebook tanpa bayar (selama notebook sharing masih aktif).

---

*Laporan ini mencakup temuan dari analisis statis kode. Pengujian penetrasi dinamis dan review infrastruktur GCP/Firebase yang lebih mendalam disarankan sebagai tindak lanjut.*
