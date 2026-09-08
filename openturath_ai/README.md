# 🏛️ OpenTurath AI — Setup Guide
*الذكاء الاصطناعي للعلوم الإسلامية*

Platform AI pertama di dunia dengan sitasi ibarah asli dari sumber primer.

---

## ✅ Checklist Setup (Wajib Dilakukan Sebelum Build)

### LANGKAH 1: Buat Firebase Project

1. Buka [console.firebase.google.com](https://console.firebase.google.com)
2. Klik **"Add Project"** → beri nama `openturath-ai`
3. Aktifkan **Google Analytics** (opsional)
4. Di menu kiri, aktifkan:
   - **Authentication** → Sign-in method → Google → Enable
   - **Firestore Database** → Create database → Production mode
   - **Functions** → Get started (butuh plan **Blaze/Pay-as-you-go**)

---

### LANGKAH 2: FlutterFire Configure

Install FlutterFire CLI jika belum ada:
```bash
dart pub global activate flutterfire_cli
```

Jalankan di dalam folder proyek:
```bash
cd openturath_ai
flutterfire configure
```

Pilih project `openturath-ai` → pilih platform Android & iOS.
Ini akan membuat file `lib/firebase_options.dart` secara otomatis.

Setelah selesai, buka `lib/main.dart` dan:
- Uncomment baris `// import 'firebase_options.dart';`
- Uncomment baris `// options: DefaultFirebaseOptions.currentPlatform,`

---

### LANGKAH 3: Isi URL NotebookLM di Cloud Functions

Buka file `functions/src/index.ts` dan isi bagian ini:
```typescript
const AGENT_URLS: Record<string, string> = {
  fiqh_tahawwulat:
    "https://notebooklm.google.com/notebook/GANTI_INI/preview",
  // Tambahkan agent lain:
  // ushul_fiqh: "https://notebooklm.google.com/notebook/XXX/preview",
};
```

---

### LANGKAH 4: Setup iPaymu

1. Daftar di [my.ipaymu.com](https://my.ipaymu.com)
2. Dapatkan **VA Number** dan **API Key** dari dashboard
3. Set config Firebase Functions:
```bash
firebase functions:config:set ipaymu.va="VA_ANDA" ipaymu.key="API_KEY_ANDA"
```

### LANGKAH 4A: Amankan akses web (wajib bila Firebase Hosting digunakan)

Gateway web tidak akan melayani chat tanpa rahasia sesi. Set secret yang kuat
dan API key Akal sebelum deploy fungsi:

```bash
firebase functions:config:set \
  web.session_secret="GANTI_DENGAN_SECRET_ACAK_MINIMAL_32_KARAKTER" \
  akal.api_key="API_KEY_AKAL_ANDA"
```

Tanpa `web.session_secret`, endpoint web akan merespons 503 secara sengaja agar
iframe NotebookLM tidak dapat diakses tanpa gate. Aplikasi Flutter tidak
menggunakan secret ini.

---

### LANGKAH 5: Deploy Cloud Functions

```bash
cd functions
npm install
npm run build
cd ..
firebase deploy --only functions
```

---

### LANGKAH 6: Isi Data Agents di Firestore

Di Firebase Console → Firestore → Buat collection `agents`:

**Document 1: `fiqh_tahawwulat`**
```json
{
  "title": "Fiqh Tahawwulat AI",
  "title_arabic": "فقه التحولات",
  "description": "AI khusus karya Habib Abu Bakar Al-Masyhur.",
  "emoji": "⚖️",
  "category": "Fiqh",
  "status": "active",
  "sort_order": 1
}
```

*(Catatan: URL tidak disimpan di Firestore — hanya ada di Cloud Functions)*

---

### LANGKAH 7: Set Firestore Security Rules

Di Firebase Console → Firestore → Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: hanya bisa baca/tulis data diri sendiri
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Agents: semua user login bisa baca, tidak bisa tulis
    match /agents/{agentId} {
      allow read: if request.auth != null;
      allow write: if false; // Hanya via Admin SDK
    }

    // Transactions: hanya bisa baca transaksi sendiri
    match /transactions/{trxId} {
      allow read: if request.auth != null
        && resource.data.uid == request.auth.uid;
      allow write: if false; // Hanya via Cloud Function
    }
  }
}
```

---

### LANGKAH 8: Google Sign-In SHA-1 Fingerprint

Di Firebase Console → Project Settings → Android app → **Add fingerprint**:

```bash
# Debug fingerprint (untuk testing)
cd android
./gradlew signingReport
```

Copy SHA-1 debug ke Firebase Console.

---

### LANGKAH 9: Build & Test

```bash
# Test di emulator/device
flutter run

# Build APK release
flutter build apk --release

# Build App Bundle (untuk Play Store)
flutter build appbundle --release
```

---

## 📁 Struktur Proyek Final

```
openturath_ai/
├── lib/
│   ├── main.dart                    ← Entry point
│   ├── firebase_options.dart        ← Auto-generated oleh flutterfire
│   ├── core/
│   │   ├── theme.dart               ← Material Design 3 Islami
│   │   ├── constants.dart           ← Config + JS Injection Script
│   │   └── routes.dart              ← Route names
│   ├── models/
│   │   ├── agent_model.dart         ← Data model agent AI
│   │   └── user_model.dart          ← Data model user + logic trial
│   ├── services/
│   │   ├── auth_service.dart        ← Firebase Auth + Google Sign-In
│   │   ├── agent_service.dart       ← Fetch URL dari Cloud Function
│   │   └── subscription_service.dart ← iPaymu + real-time sub watch
│   ├── screens/
│   │   ├── splash_screen.dart       ← Splash + auth check
│   │   ├── login_screen.dart        ← Google Sign-In UI
│   │   ├── dashboard_screen.dart    ← Grid agent + quota banner
│   │   ├── agent_webview_screen.dart ← INTI: WebView + JS injection
│   │   └── subscription_screen.dart ← Halaman bayar via iPaymu
│   └── widgets/
│       ├── agent_card.dart          ← Kartu agent (aktif/coming soon)
│       └── paywall_overlay.dart     ← Paywall yang tidak bisa ditutup
├── functions/
│   └── src/index.ts                 ← Cloud Functions (server-side logic)
└── android/
    └── app/src/main/AndroidManifest.xml
```

---

## 🔧 Menambah Agent AI Baru

1. Tambah URL di `functions/src/index.ts`:
```typescript
const AGENT_URLS = {
  fiqh_tahawwulat: "...",
  ushul_fiqh: "https://notebooklm.../preview", // ← Tambah di sini
};
```

2. Tambah document di Firestore collection `agents` dengan status `active`.

3. Deploy ulang functions:
```bash
firebase deploy --only functions
```

Selesai! Agent baru langsung muncul di dashboard user.

---

## 💰 Mengelola Subscription Manual (Jika iPaymu Belum Siap)

Untuk sementara, Anda bisa upgrade user secara manual via Firebase Console:

1. Buka Firestore → collection `users` → cari dokumen user
2. Edit field:
   - `plan`: ubah dari `"trial"` ke `"tholib"` atau `"bahits"`
   - `subscription_expiry`: set ke tanggal 30 hari ke depan (Timestamp)
   - `questions_used`: set ke `0`

Akses user terbuka otomatis dalam hitungan detik (real-time Firestore).
