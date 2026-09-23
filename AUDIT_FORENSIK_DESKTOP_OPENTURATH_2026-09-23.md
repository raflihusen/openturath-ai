# LAPORAN FORENSIK KESIAPAN EKSPOR DESKTOP: OPENTURATH AI

Tanggal: 23 September 2026 • Target: macOS (Apple Silicon/Intel) dan Windows x64  
Basis audit: `openturath_ai/`, `pubspec.yaml` versi 1.0.51+52, `pubspec.lock` yang tersedia. Ini audit statis atas 97 berkas Dart yang dilacak, runner macOS/Windows, dan jalur kritis yang disebutkan dalam mandat. Belum ada build maupun uji runtime desktop; skor berikut adalah estimasi kesiapan, bukan bukti bebas crash.

## 1. Executive summary dan skor

| Target | Skor | Penilaian |
| --- | ---: | --- |
| macOS | 48/100 | Runner, plugin utama, rail adaptif, network entitlement, dan target 10.15 tersedia. Identitas Firebase/Bundle ID berbeda; alur sesi NotebookLM dan packaging belum tervalidasi. |
| Windows x64 | 24/100 | Runner dan WebView2 plugin terdaftar, tetapi Cloud Functions tidak memiliki implementasi Windows, Firebase Windows masih beta untuk pengembangan lokal, dan pembaruan desktop mengarah ke APK. |

**Gerbang rilis:** (1) tentukan layanan backend yang didukung produksi untuk Auth/Firestore/Functions pada Windows; (2) samakan registrasi Firebase dan Bundle ID macOS; (3) pisahkan metadata pembaruan per platform; (4) validasi alur NotebookLM pada WKWebView/WebView2 dan distribusi WebView2; (5) jalankan build dan uji perangkat nyata pada kedua OS. Klaim “zero crash” belum dapat diberikan dari analisis statis.

Beberapa premis dalam permintaan audit tidak sesuai dengan kode saat ini: rail pada lebar ≥768 sudah ada di `lib/screens/main_shell_screen.dart:112-200`; `NativeAgentLauncher` sudah melindungi MethodChannel Android (`lib/services/native_agent_launcher.dart:13,28,54`); Windows **memiliki** plugin Firebase Auth/Firestore yang terdaftar, tetapi dukungan itu beta dan tidak ditujukan untuk produksi. UpdateService sudah membedakan desktop dari Android, tetapi masih memakai URL APK yang sama.

### Bukti verifikasi

- `dart analyze lib` membaca semua berkas `lib/` dan melaporkan hanya dua *info* lint di `subscription_screen.dart:338,340`; perintah keluar dengan kode 1 karena Dart mencoba menulis sesi telemetri di luar sandbox. Ini bukan bukti build macOS/Windows berhasil.
- `macos/Flutter/GeneratedPluginRegistrant.swift` mendaftarkan Firebase Core/Auth/Firestore/Functions, InAppWebView, Google Sign-In, dan plugin dasar.
- `windows/flutter/generated_plugins.cmake` mendaftarkan Firebase Core/Auth/Firestore dan `flutter_inappwebview_windows`; **tidak** mendaftarkan `cloud_functions`.
- Tidak ada `sqflite`/SQLite API yang dipakai dari `lib/`. Catatan dan bookmark lokal menggunakan `shared_preferences` melalui `lib/services/scoped_json_store.dart:11-43` dan `research_notes_service.dart:70-98`; menambahkan `sqflite_common_ffi` sekarang tidak menyelesaikan masalah nyata.
- `macos/Podfile` tidak dilacak; Flutter SDK setempat memiliki templat `Podfile-macos` dan dapat membuatnya saat penyiapan plugin. Ketiadaannya sendiri belum membuktikan build gagal; hasil `pod install` tetap harus diperiksa pada build bersih.

## 2. Matriks kompatibilitas dependensi langsung

Legenda: **✓** tersedia; **β** plugin tersedia tetapi platform Firebase berstatus beta; **—** tidak ada implementasi resmi; **Dart** tidak memerlukan plugin native; **uji** perlu uji integrasi proyek. Kolom mengacu pada paket yang dikunci saat audit, bukan janji perilaku setiap API.

| Paket (`pubspec.yaml`) | Android | iOS | macOS | Windows | Catatan / aksi |
| --- | --- | --- | --- | --- | --- |
| `flutter`, `flutter_localizations` (10,13) | ✓ | ✓ | ✓ | ✓ | Framework. |
| `firebase_core` (17) | ✓ | ✓ | β | β | Konfigurasi desktop perlu registrasi aplikasi yang benar; Windows bukan target produksi resmi. |
| `firebase_auth` (18) | ✓ | ✓ | β | β | `signInWithProvider` Windows belum terbukti dalam alur proyek. |
| `cloud_firestore` (19) | ✓ | ✓ | β | β | Plugin Windows ada, tetapi Firebase membatasi Windows untuk pengembangan lokal. |
| `cloud_functions` (20) | ✓ | ✓ | ✓/β | — | Pemanggilan `getAgentUrl`, checkout, redeem, dan sinkronisasi gagal di Windows. |
| `google_sign_in` (23) | ✓ | ✓ | ✓ | — | Kode Windows memang memilih jalur Firebase Auth lain. |
| `flutter_riverpod` (26) | Dart | Dart | Dart | Dart | Tidak ditemukan penghalang platform. |
| `flutter_inappwebview` (29) | ✓ | ✓ | ✓ | ✓ | Windows memakai WebView2 dan memerlukan Runtime serta NuGet saat build. |
| `google_fonts` (32) | ✓ | ✓ | ✓ | ✓ | Periksa font Arab dan kegagalan jaringan saat cache kosong. |
| `cached_network_image` (33) | ✓ | ✓ | ✓ | ✓ | Perlu uji cache dan gambar pada runner desktop. |
| `shimmer`, `lottie`, `flutter_svg` (34-36) | ✓ | ✓ | ✓ | ✓ | Widget/aset lintas platform. |
| `shared_preferences` (39) | ✓ | ✓ | ✓ | ✓ | Penyimpanan catatan lokal yang sebenarnya. |
| `url_launcher` (40) | ✓ | ✓ | ✓ | ✓ | Jalur desktop harus memakai browser eksternal. |
| `package_info_plus` (41) | ✓ | ✓ | ✓ | ✓ | Nomor build dipakai oleh updater. |
| `flutter_markdown`, `crypto`, `intl` (42-44) | Dart | Dart | Dart | Dart | Tidak memerlukan bridge native. |
| `path_provider` (45) | ✓ | ✓ | ✓ | ✓ | Saat ini dipakai oleh cache pembaruan Android. |
| `open_filex` (46) | ✓ | ✓ | ✓ | ✓ | Pemanggilan installer saat ini dibatasi jalur Android. |
| `device_info_plus` (47) | ✓ | ✓ | ✓ | ✓ | Kode Windows belum menangani `windowsInfo`. |
| `flutter_test`, `flutter_lints` (50-52) | dev | dev | dev | dev | Tidak masuk runtime rilis. |

Dasar status plugin: [matriks Firebase resmi](https://firebase.google.com/docs/flutter/setup), [Cloud Functions pub.dev](https://pub.dev/packages/cloud_functions), [Firebase Auth pub.dev](https://pub.dev/packages/firebase_auth), [Google Sign-In pub.dev](https://pub.dev/packages/google_sign_in), [InAppWebView pub.dev](https://pub.dev/packages/flutter_inappwebview), dan [implementasi Windows InAppWebView](https://pub.dev/packages/flutter_inappwebview_windows). Firebase secara eksplisit menyatakan Windows tidak ditujukan untuk produksi. Jangan mengartikan ikon platform pub.dev sebagai sertifikasi seluruh API aplikasi.

## 3. Temuan menurut urgensi

### P0 — gerbang kompilasi atau fungsi inti

#### D-01 — Cloud Functions tidak tersedia di Windows

**Lokasi:** `windows/flutter/generated_plugins.cmake:5-11`; `lib/services/agent_service.dart:6,16,41`; `lib/services/doku_service.dart:10,24,62`; `lib/services/subscription_service.dart:52,81`.  
**Mekanisme:** `cloud_functions` hanya menyatakan Android/iOS/macOS/web. Pada Windows, `httpsCallable` tidak memiliki implementasi plugin; permintaan URL agen, pembayaran, kode redeem, dan sinkronisasi tidak bisa diandalkan. Tangkapan `FirebaseFunctionsException` tidak menangkap semua bentuk `MissingPluginException`/`UnimplementedError`.  
**Dampak:** fungsi utama dan transaksi tidak dapat dirilis pada Windows.  
**Patch langsung yang aman:** tambahkan gerbang eksplisit sebelum membuat `FirebaseFunctions.instance` di semua service; tampilkan status “fitur belum tersedia di Windows” dan jangan menawarkan checkout. Untuk paritas penuh, implementasikan endpoint HTTPS backend **yang mempertahankan seluruh pemeriksaan otorisasi, kuota, harga, dan idempotensi di server**, lalu gunakan adapter berkontrak sama. Tidak ada patch klien saja yang bisa menjadikan Cloud Functions Windows didukung produksi. Contoh pengganti untuk `AgentService`:

```dart
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class DesktopCapabilityException implements Exception {
  final String message;
  const DesktopCapabilityException(this.message);
  @override String toString() => message;
}

Future<dynamic> callSupportedFunction(String name, Map<String, dynamic> data) async {
  if (!kIsWeb && Platform.isWindows) {
    throw const DesktopCapabilityException(
      'Layanan ini belum tersedia pada aplikasi Windows. Gunakan perangkat yang didukung.',
    );
  }
  final result = await FirebaseFunctions.instance.httpsCallable(name).call(data);
  return result.data;
}
```

Ini **mitigasi kegagalan**, bukan implementasi fitur Windows. Adapter REST baru memerlukan spesifikasi endpoint dan uji keamanan backend; membuat URL atau melewatkan verifikasi server akan berisiko pada pembayaran dan hak akses.

#### D-02 — Windows memakai konfigurasi Firebase Android dan batas dukungan produksi

**Lokasi:** `lib/firebase_options.dart:26-30,61-67`; `lib/main.dart:49-86`; `windows/flutter/generated_plugins.cmake:5-11`.  
**Mekanisme:** `DefaultFirebaseOptions.windows.appId` adalah ID aplikasi Android (`:android:`). `main()` mengirimnya ke Firebase Core Windows. Kesalahan inisialisasi tertangkap dan ditampilkan sebagai layar galat; jadi klaim *force close* tidak didukung bukti, tetapi aplikasi tidak bisa dipakai bila inisialisasi gagal. Firebase Auth/Firestore Windows memang ada, namun dokumentasi Firebase membatasinya untuk pengembangan lokal.  
**Dampak:** konfigurasi lintas aplikasi tak valid dan tidak ada landasan rilis Windows yang didukung vendor.  
**Patch konfigurasi:** daftarkan aplikasi Windows sesuai alur FlutterFire yang tersedia, jalankan `flutterfire configure`, dan **ganti seluruh konstanta `windows` dari hasil CLI**, bukan menyalin ID Android. Pertahankan penanganan startup saat gagal. Untuk produk Windows, pindahkan operasi Auth/data/transaksi ke API backend yang didukung, dengan token disimpan di fasilitas kredensial OS; jangan menaruh service-account key atau secret pembayaran dalam aplikasi. Ini keputusan arsitektur wajib sebelum patch klien lengkap dapat ditulis.

### P1 — fungsi rusak, keamanan, atau pengalaman utama

#### D-03 — identitas macOS/Firebase tidak konsisten

**Lokasi:** `macos/Runner/Configs/AppInfo.xcconfig:8-14`; `macos/Runner/GoogleService-Info.plist:11-12,27-28`; `macos/Runner/Release.entitlements:11-14`; `macos/Runner/DebugProfile.entitlements:13-16`; `lib/firebase_options.dart:44-50`.  
**Mekanisme:** runner/plist memakai `com.example.openturathAi`, sementara `FirebaseOptions.iosBundleId` memakai `com.openturath.ai`; `GOOGLE_APP_ID` di plist berbeda dari `FirebaseOptions.ios.appId`. Penandatanganan, Keychain Sharing, Firebase, dan redirect Google Sign-In dapat gagal atau masuk ke aplikasi Firebase yang salah.  
**Patch:** setelah Bundle ID resmi dan Apple Developer Team dikonfirmasi, ganti `PRODUCT_BUNDLE_IDENTIFIER`, keychain group, dan registrasi aplikasi macOS Firebase secara serempak. Contoh penggantian runner:

```text
# macos/Runner/Configs/AppInfo.xcconfig
PRODUCT_NAME = OpenTurath AI
PRODUCT_BUNDLE_IDENTIFIER = com.openturath.ai
PRODUCT_COPYRIGHT = Copyright © 2026 OpenTurath AI. All rights reserved.

# di kedua entitlements
<key>keychain-access-groups</key>
<array><string>$(AppIdentifierPrefix)com.openturath.ai</string></array>
```

`GoogleService-Info.plist` dan `firebase_options.dart` harus digenerasi ulang bersama dari aplikasi Firebase macOS yang **sama**; nilai `GOOGLE_APP_ID` tidak boleh ditebak atau disalin dari iOS/Android. Uji login baru dan login ulang setelah restart.

#### D-04 — browser internal Google memakai user-agent Android palsu

**Lokasi:** `lib/core/constants.dart:7-9`; `lib/screens/google_session_auth_screen.dart:31-35,226-244`; `lib/widgets/agent_multi_tab_room.dart:1093-1117`; `lib/screens/agent_webview_screen.dart:729-744`; `lib/screens/login_screen.dart:72-76`.  
**Mekanisme:** WKWebView/WebView2 menyamar sebagai Chrome Android 128. Google dapat menolak OAuth dalam embedded user-agent; identitas browser palsu tidak memperbaiki kebijakan OAuth. macOS melompati `GoogleSessionAuthScreen`, sehingga token Firebase tidak otomatis menjadi kuki NotebookLM. Kuki di WebView perlu diuji setelah restart; `cacheEnabled` bukan bukti persistensi.  
**Dampak:** masuk Firebase berhasil tetapi NotebookLM meminta login ulang atau menolak login.  
**Patch aman:** untuk desktop, jangan arahkan pengguna ke halaman OAuth Google dalam WebView. Buka alur OAuth **browser sistem** dengan PKCE dan redirect yang terdaftar, lalu tukarkan kredensial di backend/Firebase Auth. Untuk NotebookLM, tampilkan halaman akun di browser sistem dan jangan mengklaim SSO WebView tanpa API integrasi resmi. Pada WebView yang hanya menampilkan NotebookLM, biarkan user-agent default desktop:

```dart
final isDesktop = !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
     defaultTargetPlatform == TargetPlatform.windows);
final settings = InAppWebViewSettings(
  javaScriptEnabled: true,
  cacheEnabled: true,
  userAgent: isDesktop ? null : AppConstants.chromeMobileUserAgent,
);
```

Terapkan pilihan `userAgent` yang sama pada dua WebView agen dan gerbang sesi. Penggantian ini menghilangkan penyamaran, tetapi **tidak menjamin Google mengizinkan login NotebookLM dalam WebView**. Lihat [kebijakan OAuth aplikasi desktop Google](https://developers.google.com/identity/protocols/oauth2/native-app).

#### D-05 — tidak ada pemeriksaan WebView2 Runtime sebelum membuat WebView

**Lokasi:** `lib/main.dart:27-56`; `lib/widgets/agent_multi_tab_room.dart:1088`; `lib/screens/google_session_auth_screen.dart:226`; `lib/widgets/doku_checkout_sheet.dart:520`.  
**Mekanisme:** plugin Windows terdaftar dan memakai WebView2. Pada Windows 10 tertentu Runtime tidak terpasang; `InAppWebView` dapat gagal diinisialisasi. Aplikasi tidak menyediakan petunjuk pemulihan. `windows/CMakeLists.txt` sendiri tidak perlu diisi bootstrapper plugin; NuGet diperlukan oleh plugin saat build.  
**Patch siap integrasi di `main.dart`:** periksa sebelum semua jalur WebView dan tampilkan layar pemulihan; installer Windows harus memasang Evergreen Runtime bila tidak ada.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> desktopWebViewReady() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) return true;
  try {
    return await WebViewEnvironment.getAvailableVersion() != null;
  } catch (_) {
    return false;
  }
}

// Setelah WidgetsFlutterBinding.ensureInitialized(), sebelum runApp:
final webViewReady = await desktopWebViewReady();
if (!webViewReady) {
  runApp(MaterialApp(home: Scaffold(body: Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Microsoft Edge WebView2 Runtime diperlukan.'),
      TextButton(
        onPressed: () => launchUrl(
          Uri.parse('https://developer.microsoft.com/microsoft-edge/webview2/'),
          mode: LaunchMode.externalApplication,
        ),
        child: const Text('Unduh WebView2'),
      ),
    ],
  )))));
  return;
}
```

Sumber: [dokumentasi InAppWebView](https://inappwebview.dev/docs/webview/in-app-webview/) dan [panduan distribusi Microsoft](https://learn.microsoft.com/microsoft-edge/webview2/concepts/distribution). Runtime tetap perlu uji installer pada Windows 10 bersih.

#### D-06 — update desktop mengunduh APK Android

**Lokasi:** `lib/services/update_service.dart:121-145,317-329`; `lib/widgets/update_ready_dialog.dart:34,99-103`.  
**Mekanisme:** cabang desktop tidak mengunduh APK ke disk, tetapi menyatakan update siap ketika `apk_url` ada, lalu `installNow()` membuka `apk_url` tersebut di browser. Pengguna macOS/Windows diarahkan ke berkas Android.  
**Patch kontrak data dan pemilihan URL:** tambah `macos_url` dan `windows_url` di dokumen `app_config/version`, validasi HTTPS dan ekstensi/host rilis resmi, lalu pisahkan versi per platform agar nomor build Android tidak memicu update desktop palsu. Pengganti blok pemilihan URL di `checkForUpdatesSilently()`:

```dart
final isMac = !kIsWeb && Platform.isMacOS;
final isWindows = !kIsWeb && Platform.isWindows;
final release = isMac ? data['macos'] :
    isWindows ? data['windows'] : data['android'];
if (release is! Map) {
  _status = UpdateStatus.idle;
  notifyListeners();
  return;
}
final latestCode = (release['build'] as num?)?.toInt() ?? 0;
final url = Uri.tryParse(release['url'] as String? ?? '');
if (latestCode <= currentCode || url == null || url.scheme != 'https' ||
    !const {'releases.openturath.ai'}.contains(url.host)) {
  _status = UpdateStatus.idle;
  notifyListeners();
  return;
}
// Isi UpdateInfo memakai release['version'], release['notes'], dan url.toString().
// Pada Android tetap lakukan unduhan/hash APK; pada desktop hanya buka URL.
```

Skema backend yang harus disediakan sebelum mengganti kode: `android`, `macos`, `windows` masing-masing memiliki `build`, `version`, `url`, `notes`, dan checksum artefak. Domain contoh di atas harus diganti dengan domain rilis resmi yang benar; **jangan** mengaktifkan patch dengan domain contoh. Distribusi hanya dijalankan atas instruksi rilis eksplisit pengguna.

#### D-07 — launcher native dan berbagi teks berhenti diam-diam di desktop

**Lokasi:** `lib/services/native_agent_launcher.dart:24-50,52-64`.  
**Mekanisme:** MethodChannel Android sudah aman. Namun `launchNotebook` mencoba `externalNonBrowserApplication` pada semua OS dan mengembalikan `false` jika browser adalah satu-satunya handler; `shareText` langsung `false` di desktop.  
**Patch pengganti dua metode:**

```dart
static Future<bool> launchNotebook(String url) async {
  final uri = Uri.tryParse(url.replaceAll('/preview', ''));
  if (uri == null || uri.scheme != 'https' ||
      !const {'notebooklm.google.com', 'notebook.google.com'}.contains(uri.host)) {
    return false;
  }
  if (Platform.isAndroid) {
    try {
      if (await _channel.invokeMethod<bool>('openInNotebookApp', {'url': '$uri'}) == true) {
        return true;
      }
    } catch (_) {}
  }
  try {
    return await launchUrl(uri, mode: Platform.isAndroid
        ? LaunchMode.externalNonBrowserApplication
        : LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

static Future<bool> shareText({required String text, String title = 'Bagikan Modul'}) async {
  if (Platform.isAndroid) {
    try {
      return await _channel.invokeMethod<bool>('shareText',
          {'text': text, 'title': title}) == true;
    } catch (_) { return false; }
  }
  if (Platform.isMacOS || Platform.isWindows) {
    await Clipboard.setData(ClipboardData(text: text));
    return true; // Pemanggil wajib menampilkan snackbar "Teks disalin".
  }
  return false;
}
```

#### D-08 — semua perangkat Windows memakai sidik jari fallback yang sama

**Lokasi:** `lib/services/device_service.dart:55-118,122-134`; `lib/services/subscription_service.dart:50-59`.  
**Mekanisme:** Windows tidak memiliki cabang `windowsInfo`. Voucher mengirim hash dari konstanta `ot_fallback_dev_0000000000000000` untuk semua PC.  
**Dampak:** pembatasan perangkat salah, benturan akun, dan risiko penyalahgunaan voucher.  
**Patch:** tambahkan cabang Windows sebelum fallback, memakai ID instalasi acak yang disimpan persisten dan dipisahkan per pengguna/aplikasi. Jangan memakai username atau serial hardware mentah:

```dart
if (Platform.isWindows) {
  final prefs = await SharedPreferences.getInstance();
  var installId = prefs.getString('ot_windows_install_id');
  if (installId == null) {
    final random = Random.secure();
    installId = List.generate(32, (_) => random.nextInt(256)
        .toRadixString(16).padLeft(2, '0')).join();
    if (!await prefs.setString('ot_windows_install_id', installId)) {
      throw StateError('Cannot persist installation identity');
    }
  }
  final info = await _deviceInfo.windowsInfo;
  return DeviceFingerprint(
    deviceId: computeHash(rawId: installId, brand: 'windows', model: info.productName),
    brand: 'windows', model: info.productName, isPhysicalDevice: true,
  );
}
```

Tambahkan `dart:io`, `dart:math`, dan `shared_preferences` sesuai kebutuhan. Jika persistensi gagal, tampilkan kesalahan dan jangan mengirim fallback bersama ke endpoint redeem.

### P2 — ergonomi dan kemasan

#### D-09 — sheet melebar pada desktop

**Lokasi:** 12 pemanggilan `showModalBottomSheet` di `lib/`, antara lain `lib/widgets/redeem_code_sheet.dart:20-26`, `lib/screens/library_screen.dart:91-99`, `lib/widgets/agent_multi_tab_room.dart:100`, `lib/screens/book_catalog_screen.dart:455`.  
**Mekanisme:** sebagian sheet tidak membatasi lebar. Pada 24–34 inci, konten melebar atau berada jauh dari titik fokus.  
**Patch pembungkus untuk setiap builder sheet:**

```dart
builder: (ctx) => Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 560),
    child: RedeemCodeSheet(onSuccess: onSuccess),
  ),
),
```

Untuk sheet yang sudah memakai `SafeArea`/scroll, terapkan `ConstrainedBox` pada konten paling luar, bukan pada `Scaffold` aplikasi. Uji keyboard inset dan tinggi jendela 600 px.

#### D-10 — rail ada, tetapi workbench dan shortcut desktop belum lengkap

**Lokasi:** `lib/screens/main_shell_screen.dart:112-200,268-315`; `lib/widgets/agent_multi_tab_room.dart:1088-1279`; `lib/services/agent_session_manager.dart:59-110`; kolom pencarian di `lib/screens/dashboard_screen.dart:297-300` dan `book_library_editorial_screen.dart:150-153`.  
**Mekanisme:** rail minimalis sudah aktif pada ≥768 px. Ruang AI menutupi seluruh shell, tidak memiliki daftar rujukan dua kolom; tidak ditemukan `Shortcuts`, `CallbackShortcuts`, atau `Actions` pada `lib/`. Cmd/Ctrl+F/W/T/,/R belum diarahkan ke aksi aplikasi. Beberapa widget memiliki hover bawaan Material; ketiadaan `MouseRegion` sendiri bukan bukti kursor salah di semua elemen.  
**Patch scaffold yang dapat dipakai tanpa mengubah mobile:**

```dart
// Bungkus Stack pada MainShellScreen.build.
final desktop = MediaQuery.sizeOf(context).width >= 768;
return CallbackShortcuts(
  bindings: desktop ? {
    SingleActivator(LogicalKeyboardKey.keyF, meta: defaultTargetPlatform == TargetPlatform.macOS,
        control: defaultTargetPlatform == TargetPlatform.windows): () => _onTabSelected(0),
    SingleActivator(LogicalKeyboardKey.comma, meta: defaultTargetPlatform == TargetPlatform.macOS,
        control: defaultTargetPlatform == TargetPlatform.windows): () => _onTabSelected(3),
    SingleActivator(LogicalKeyboardKey.keyW, meta: defaultTargetPlatform == TargetPlatform.macOS,
        control: defaultTargetPlatform == TargetPlatform.windows): () {
      final manager = AgentSessionManager.instance;
      if (manager.activeTab != null) manager.closeTab(manager.activeIndex);
    },
  } : const {},
  child: Focus(autofocus: desktop, child: existingShell),
);
```

Contoh ini menyediakan navigasi/penutupan tab, tetapi Cmd/Ctrl+F baru menuju dashboard, belum memfokuskan pencarian; Cmd/Ctrl+T dan R perlu API aksi pada `AgentMultiTabRoom`. Jangan mengklaim shortcut lengkap sebelum fokus WebView, dialog, dan menu native diuji. Untuk workbench dua kolom, pertahankan rail, lalu pada lebar ≥1100 bagi ruang agen menjadi panel marja' 280–340 px dan panel webview yang memakai sisa lebar; daftar referensi harus berasal dari metadata yang sudah dimuat, bukan duplikasi konten NotebookLM.

#### D-11 — ukuran jendela/metadata Windows masih templat

**Lokasi:** `windows/runner/main.cpp:27-30` (1280×720), `windows/runner/win32_window.cpp:177-221` (tanpa `WM_GETMINMAXINFO`), `windows/runner/Runner.rc:92-99`, `macos/Runner/MainFlutterWindow.swift:4-14`.  
**Mekanisme:** jendela dapat dikecilkan hingga layout rusak. Nama, perusahaan, dan deskripsi di resource masih `openturath_ai`/`com.example`.  
**Patch Windows:** set ukuran awal `1280×820` dan judul `OpenTurath AI`; tambahkan batas minimum dalam `MessageHandler`:

```cpp
case WM_GETMINMAXINFO: {
  auto* limits = reinterpret_cast<MINMAXINFO*>(lparam);
  const UINT dpi = GetDpiForWindow(hwnd);
  limits->ptMinTrackSize.x = MulDiv(860, dpi, 96);
  limits->ptMinTrackSize.y = MulDiv(600, dpi, 96);
  return 0;
}
```

Set `contentMinSize = NSSize(width: 860, height: 600)` dan `setContentSize(NSSize(width: 1280, height: 820))` di `MainFlutterWindow.awakeFromNib()` setelah `super.awakeFromNib()`, dengan memastikan ukuran tidak melewati layar aktif. Ubah metadata `Runner.rc` ke merek dan pemegang hak cipta resmi. `windows/runner/runner.exe.manifest:5` **sudah** memakai `PerMonitorV2`; `app_icon.ico` **sudah ada**, tetapi isi resolusi/brandingnya belum dinilai secara visual.

#### D-12 — entitlement server macOS aktif tanpa kebutuhan yang dibuktikan

**Lokasi:** `macos/Runner/Release.entitlements:5-14`; `DebugProfile.entitlements:5-16`.  
**Mekanisme:** `network.client` sudah benar. `network.server` aktif di rilis, sementara kode aplikasi yang diaudit tidak membuka server lokal. Ini memperluas izin sandbox; jika kelak memakai OAuth loopback, kebutuhan itu harus dinilai ulang.  
**Patch rilis:** hapus dua baris berikut dari `Release.entitlements`, setelah menguji ulang plugin dan checkout:

```xml
<key>com.apple.security.network.server</key>
<true/>
```

Pertahankan `network.client`; Keychain group diselaraskan sebagaimana D-03. Jangan hapus izin server pada varian yang benar-benar mengimplementasikan OAuth loopback.

## 4. Cetak biru responsif dan interaksi

Arsitektur yang paling hemat regresi mempertahankan `MainShellScreen` saat lebar <768 px. Pada 768–1099 px, rail 76 px yang sudah ada dipertahankan dan isi diberi lebar baca maksimum; pada ≥1100 px, ruang agen menjadi daftar marja' kiri dan area telaah kanan. Katalog Arab panjang sebaiknya memiliki lebar baca sekitar 72–90 karakter per baris, dengan kontrol ukuran huruf tersimpan per pengguna. Gunakan batas 560 px pada sheet dan dialog; uji 860×600, 1280×820, 4K scaling 125%/150%, serta RTL Arab. Hindari gerakan dan banner update yang menutupi kutipan saat membaca.

Shortcut perlu satu lapisan `CallbackShortcuts`/`Actions` di shell, sementara `FocusNode` pencarian ditangani oleh dashboard/pustaka. WebView menangkap banyak kombinasi tombol; Cmd/Ctrl+R dan W harus diuji saat fokus berada di konten WebView. Esc perlu menutup dialog/sheet lebih dulu, lalu ruang agen. Hover/kursor dinilai per komponen interaktif, bukan ditambahkan `MouseRegion` secara membabi buta ke semua kartu.

## 5. Build dan rilis langkah demi langkah

### macOS

1. Samakan Bundle ID, Firebase app macOS, Google URL scheme, Keychain group, dan sertifikat penandatanganan (D-03). Pastikan target minimal macOS 10.15; Xcode project sudah menetapkannya pada `project.pbxproj:464,546,596`.
2. Pada Mac dengan Xcode dan CocoaPods, jalankan `flutter doctor -v`, `flutter pub get`, lalu `flutter build macos --release`. Periksa `pod install` dari build bersih dan `macos/Podfile` hasil konfigurasi; jangan menganggap registrant yang sudah ada sebagai bukti build.
3. Jalankan `.app` pada Apple Silicon dan Intel (native atau distribusi universal yang diverifikasi); uji login, restart sesi, NotebookLM, pembayaran, catatan lokal, dan update link. Periksa entitlement final dengan `codesign -d --entitlements :- <app>`.
4. Untuk distribusi di luar App Store, tanda tangani, notarize, staple, kemudian kemas DMG dan uji Gatekeeper pada Mac bersih. Untuk App Store, ikuti alur Archive/Xcode dan sandbox review. Lihat [panduan Flutter macOS](https://docs.flutter.dev/deployment/macos).

### Windows x64

1. Selesaikan backend produksi untuk operasi Firebase/Functions; jangan menerbitkan build Windows dari status dukungan sekarang. Pada mesin Windows dengan Visual Studio Desktop C++ workload, SDK Windows, dan NuGet di PATH, jalankan `flutter doctor -v`, `flutter pub get`, `flutter build windows --release`.
2. Jalankan dari `build/windows/x64/runner/Release/` dan paketkan **seluruh** folder: `.exe`, DLL plugin/Flutter, `data/`, dan redistributable Visual C++ sesuai metode distribusi. Jangan mengirim `.exe` saja. Lihat [panduan Flutter Windows](https://docs.flutter.dev/platform-integration/windows/building) dan [perubahan path build x64](https://docs.flutter.dev/release/breaking-changes/windows-build-architecture).
3. Installer MSIX/Inno/WiX harus mendeteksi/menyediakan WebView2 Evergreen Runtime. Uji pada Windows 10 bersih tanpa Runtime dan Windows 11, layar DPI 125%/150%, login, restart kuki, checkout, pembukaan URL eksternal, serta update link. Tandatangani artefak dan verifikasi checksum.
4. Broadcast versi publik (`app_config/version`) dan unggah installer hanya setelah instruksi rilis eksplisit. Build lokal tidak memicu publish.

## 6. Batas bukti dan keputusan berikutnya

- Tidak ada eksekusi aplikasi macOS/Windows, pengujian kuki, validasi dialog Google, screenshot ergonomi, maupun build release di audit ini. Klaim bahwa JS `otCopiedAnswer`, `notebookUiScript`, dan `applyTurathFontScale` identik di WKWebView dan WebView2 belum terbukti; kode handler di `agent_multi_tab_room.dart:1160-1211` sudah memeriksa host HTTPS dan panjang teks, tetapi perilaku engine perlu uji runtime.
- `shouldOverrideUrlLoading` pada `agent_multi_tab_room.dart:1257-1264` dan `google_session_auth_screen.dart:245-251` memakai allowlist `NotebookNavigation.allowed` (`lib/core/notebook_navigation.dart:1-15`). Uji redirect Google dan tautan eksternal pada kedua engine; jangan memperluas allowlist tanpa audit domain.
- Patch contoh D-04/D-05/D-09/D-10/D-11 adalah potongan yang dapat ditempatkan pada lokasi disebutkan; integrasi final tetap harus dijalankan melalui analyzer/build dan uji OS target. D-01/D-02/D-06 membutuhkan kontrak backend, Firebase app, dan domain rilis resmi; mengarang nilai tersebut akan menghasilkan patch yang tidak aman.

