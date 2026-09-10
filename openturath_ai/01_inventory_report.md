# 01_INVENTORY_REPORT: Pemetaan Lengkap Sumber Daya OpenTurath AI v2

Dokumen ini adalah hasil audit dan inventarisasi 100% dari seluruh berkas sumber daya OpenTurath AI sebelum proses refaktorisasi/rewrite dijalankan.

Total Basis Kode Utama: **13.187 baris**
- **Dart (Flutter):** 41 Berkas (11.198 baris)
- **TypeScript (Cloud Functions):** 1 Berkas Monolitik (1.989 baris)

---

## 1. Inventarisasi & Pemetaan Berkas Dart (Flutter)

| No | Path Berkas | Baris | Status | Tindakan Refactor v2 |
|---|---|---|---|---|
| 1 | `lib/main.dart` | 201 | Aktif | Routing terstruktur, integrasi Riverpod root, inisialisasi aman |
| 2 | `lib/firebase_options.dart` | 62 | Aktif / Konfigurasi | Dipertahankan sebagai konfigurasi Firebase resmi |
| 3 | `lib/core/app_config.dart` | 48 | Aktif | Dipindahkan ke `core/config/`, namespacing storage |
| 4 | `lib/core/app_snackbar.dart` | 119 | Aktif | Dipertahankan di `shared/`, integrasi theme token |
| 5 | `lib/core/arabic_utils.dart` | 43 | Aktif | Dipertahankan di `core/utils/` |
| 6 | `lib/core/constants.dart` | 35 | Aktif | Dipertahankan di `core/constants/` |
| 7 | `lib/core/hijri_date_utils.dart` | 104 | Aktif | Dipertahankan di `core/utils/` |
| 8 | `lib/core/localization.dart` | 87 | Aktif | Dipertahankan di `core/localization/` |
| 9 | `lib/core/routes.dart` | 11 | Aktif | Diperluas untuk routing deskriptif |
| 10 | `lib/core/theme.dart` | 509 | Aktif | Standarisasi token radius & tipografi (Outfit) |
| 11 | `lib/models/agent_model.dart` | 643 | Aktif | Sinkronisasi harga resmi (Rp 50rb / Rp 99rb) |
| 12 | `lib/models/book_model.dart` | 15 | Aktif | Dipertahankan di `features/agents/data/models/` |
| 13 | `lib/models/bookmark_model.dart` | 61 | Aktif | Dipertahankan di `features/bookmarks/data/models/` |
| 14 | `lib/models/field_model.dart` | 124 | Aktif | Dipertahankan di `features/agents/data/models/` |
| 15 | `lib/models/sub_agent_model.dart` | 19 | Aktif | Dipertahankan di `features/agents/data/models/` |
| 16 | `lib/models/user_model.dart` | 220 | Aktif | Hapus `questions_used` & `plan: trial`, transisi ke boolean entitlement |
| 17 | `lib/screens/agent_webview_screen.dart` | 1428 | Kritis / Monolit | Dekomposisi: Controller, OriginPolicy, NotebookAdapter |
| 18 | `lib/screens/bookmark_screen.dart` | 650 | Aktif | Dipindahkan ke `features/bookmarks/presentation/` |
| 19 | `lib/screens/dashboard_screen.dart` | 740 | Aktif | Dipindahkan ke `features/dashboard/presentation/` |
| 20 | `lib/screens/google_session_auth_screen.dart` | 283 | Aktif | Dipindahkan ke `features/auth/presentation/` |
| 21 | `lib/screens/login_screen.dart` | 304 | Aktif | Dipindahkan ke `features/auth/presentation/` |
| 22 | `lib/screens/main_shell_screen.dart` | 390 | Aktif | Dipertahankan sebagai shell navigasi utama |
| 23 | `lib/screens/profile_screen.dart` | 1016 | Aktif | Dipindahkan ke `features/profile/presentation/` |
| 24 | `lib/screens/specialist_list_screen.dart` | 571 | Aktif | Dipindahkan ke `features/agents/presentation/` |
| 25 | `lib/screens/splash_screen.dart` | 118 | Aktif | Pangkas delay buatan, transisi halus ke dashboard/login |
| 26 | `lib/screens/subscription_screen.dart` | 730 | Aktif | Integrasi dialog Kode Redeem santri + katalog harga DOKU |
| 27 | `lib/services/agent_service.dart` | 77 | Aktif | Hapus `recordQuestion`, ganti pengecekan entitlement |
| 28 | `lib/services/auth_service.dart` | 280 | Aktif | Namespacing SharedPreferences, Google Sign In resmi |
| 29 | `lib/services/bookmark_service.dart` | 48 | Kritis | Tambahkan namespacing UID pada storage key |
| 30 | `lib/services/doku_service.dart` | 65 | Aktif | Integrasi backend DOKU |
| 31 | `lib/services/native_agent_launcher.dart` | 65 | Aktif | Utilitas pemanggil agent native |
| 32 | `lib/services/research_notes_service.dart` | 114 | Kritis | Tambahkan namespacing UID pada storage key |
| 33 | `lib/services/subscription_service.dart` | 105 | Aktif | Tambahkan fungsi callable `redeemCode` |
| 34 | `lib/services/update_service.dart` | 271 | Kritis | Mutex `_isDownloading`, penutupan stream di `finally`, SHA-256 |
| 35 | `lib/widgets/app_error_state.dart` | 118 | Aktif | Komponen baku error state |
| 36 | `lib/widgets/app_loader.dart` | 167 | Aktif | Komponen baku pulse loader |
| 37 | `lib/widgets/apple_interactive_wrapper.dart` | 152 | Aktif | Utilitas animasi tekan iOS/macOS |
| 38 | `lib/widgets/doku_checkout_sheet.dart` | 596 | Kritis | Domain allowlist DOKU, realtime Firestore listener |
| 39 | `lib/widgets/evidence_bottom_sheet.dart` | 404 | Aktif | Komponen telaah ibarah kitab |
| 40 | `lib/widgets/openturath_brand.dart` | 98 | Aktif | Wordmark branding konsisten |
| 41 | `lib/widgets/update_ready_banner.dart` | 107 | Aktif | Banner update elegan |

---

## 2. Inventarisasi Cloud Functions (TypeScript)

- `functions/src/index.ts` (1.989 baris monolitik):
  - **Auth & Session Web:** Baris 1145–1183 (`handleLogin`) -> Memerlukan verifikasi Firebase ID Token.
  - **Payment & DOKU:** Baris 270–730 -> Memerlukan sanitasi fallback rahasia, idempotensi `Request-Id`, validasi `context.auth` pada `checkPaymentStatus`, dan perpanjangan `max(now, expiry)`.
  - **Redeem Code Engine (Baru):** Endpoint `redeemCode` untuk klaim voucher akses santri (misal 7 hari Fikih Syafi'i) + otomatisasi email sharing NotebookLM.
  - **Modularisasi:** Akan dipecah menjadi `functions/src/{auth,payments,redeem,agents,users,shared}/`.

---

## 3. Inventarisasi Native & Web

- `android/app/src/main/res/xml/file_paths.xml`: Mengubah root `.` menjadi subfolder privat `updates/`.
- `macos/Runner/*.entitlements`: Menambahkan izin jaringan sandboxing `com.apple.security.network.client`.
- `public/index.html`: Menyelaraskan harga katalog web ke Rp 99.000 / Rp 499.000 / Rp 799.000.
- `firestore.rules`: Menolak email injection dari akun anonim, mengunci transaksi & redeem codes.

---

## 4. Rujukan Verifikasi

Seluruh berkas yang terdaftar di atas dijamin tetap utuh dan fungsional selama proses rewrite berlangsung.
