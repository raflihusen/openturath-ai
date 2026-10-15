# Standar Baku & Format Sakral WebView OpenTurath AI (Gold Standard Syafi'i)

> [!CAUTION]
> **DOKUMEN INI BERSIFAT SAKRAL & MUTLAK DILARANG DIOTAK-ATIK.**
> Dilarang merusak, mengubah, memotong, atau "menyederhanakan" logika siklus hidup WebView, injeksi CSS/JS, anti-tamper cookie sesi Google, maupun batas multi-tab yang tercantum dalam dokumen ini. Format ini dirumuskan setelah audit forensik mendalam dan telah divalidasi sempurna pada lingkungan macOS dan ponsel.

---

## 1. Latar Belakang & Masalah Utama yang Dicegah

1. **Angular SPA DOM Transient Glitch / Flicker**:
   Google NotebookLM adalah Single Page Application (Angular SPA) kompleks yang melalui tahapan bootstrap multi-tahap: *splash shell* -> *resource hydration* -> *markdown stream canvas* -> *composer box*. Pengecekan kesiapan dini (misalnya hanya 1–2 sampel atau tanpa elapsed time minimal) akan memicu `activate()` sebelum layout DOM selesai, menyebabkan layar putih kosong (*blank DOM*), layout berantakan, atau input chat membeku (*freeze*).

2. **Celah Kotak Putih 66px & Top Fade Scrim (Discrepansi Antar-Tab)**:
   Pada tab Fikih Syafi'i teks rapat sempurna ke bawah bilah Flutter, namun pada modul lain (seperti Fikih Tahawwulat) sempat muncul kotak putih kosong 66px dan teks atas memudar.
   - **Akar Masalah 1**: Mesin WebKit macOS mengalami kegagalan parsing (*parser error*) jika selektor modern `:has(...)` digabungkan ke dalam blok koma aturan penghilang header standar. WebKit menggugurkan seluruh aturan dalam blok tersebut, sehingga `app-chat-header` setinggi 64px–66px tetap dirender.
   - **Akar Masalah 2**: Wadah obrolan induk (`app-chat-view`, `main`, dll) menerapkan `-webkit-mask-image: linear-gradient(...)` bawaan Google yang memudarkan teks obrolan paling atas.
   - **Akar Masalah 3**: Tab yang baru dibuka belakangan atau beralih dari background tidak memicu siklus pembersihan instan `clean()`.

3. **Mekanisme Google DBSC Token Revocation (Logout Tiba-Tiba)**:
   Pengguna tiba-tiba terlempar ke layar Google *"Choose an account - Signed out"*.
   - **Akar Masalah**: Memodifikasi cookie aktif Google di `WKHTTPCookieStore` (terutama token sesi bergulir `__Secure-1PSIDTS`, `__Secure-3PSIDTS`, `SID`) dengan atribut palsu (`expiresDate` 180 hari, `SameSite=None`) memicu mekanisme pertahanan DBSC (*Device Bound Session Credentials*) pada Google Edge Frontend. Google menganggap token dibajak/diutak-atik sehingga server mencabut sesi secara global.
   - **Akar Masalah Tambahan**: Logika rekonsiliasi yang memanggil `clearOnSignOut()` saat `owner.isEmpty` tanpa sengaja membunuh sesi WebKit aktif.

4. **Penutupan Paksa Tab Pengguna (*Silent Auto-Eviction*)**:
   Pembatasan desktop sebelumnya di-hardcode ke angka 2 tab, sehingga membuka tab ketiga akan langsung menutup tab pertama tanpa izin pengguna.

5. **Platform View Overlay Collision**:
   Menumpuk native platform view (`InAppWebView`) di bawah widget overlay Flutter (`Positioned.fill`) saat terjadi galat menyebabkan tabrakan event klik, memori bocor, dan rusaknya rekoneksi controller.

---

## 2. Format Baku Implementasi (Gold Standard Syafi'i)

### A. Tolok Ukur Visual: Fikih Syafi'i (0px White Gap & Flush Layout)
* Teks dan tabel obrolan **WAJIB rapat ke bawah bilah tab Flutter** (0px jeda putih, tanpa bar kosong 64px/66px, tanpa scrim pudar).
* Seluruh header Google/NotebookLM wajib disembunyikan menggunakan CSS murni berdimensi mutlak nol:
```css
/* Lokasi: openturath_ai/lib/core/notebook_ui_script.dart */
body > header,
top-bar, .top-bar, [class*="top-bar" i],
app-header, .app-header, [class*="app-header" i],
mat-toolbar, mat-toolbar-row,
.notebook-header, app-notebook-header, [class*="notebook-header" i],
.project-header, app-project-header, [class*="project-header" i],
app-chat-header, chat-header, .chat-header, [class*="chat-header" i],
app-conversation-header, .conversation-header, [class*="conversation-header" i],
app-chat-panel-header, .chat-panel-header, [class*="chat-panel-header" i],
app-top-bar, .mobile-header, [class*="mobile-header" i],
.chat-top-bar, [class*="chat-top-bar" i],
header, [role="banner"],
.top-scrim, .header-scrim, .scroll-scrim, [class*="scrim" i],
[class*="top-gradient" i], [class*="scroll-gradient" i], [class*="header-gradient" i],
[class*="fade-overlay" i], [class*="scroll-overlay" i],
mat-tab-header, .mat-mdc-tab-header {
  display: none !important;
  visibility: hidden !important;
  height: 0 !important;
  min-height: 0 !important;
  max-height: 0 !important;
  padding: 0 !important;
  margin: 0 !important;
  border: none !important;
  overflow: hidden !important;
  opacity: 0 !important;
  pointer-events: none !important;
}
```

### B. Isolasi Total Selektor `:has(...)`
* DILARANG menggabungkan selektor `:has(...)` ke dalam aturan CSS koma biasa.
* Semua selektor `:has(...)` wajib dipisahkan ke blok aturan independen:
```css
/* Wajib terpisah agar jika WebKit gagal parsing, aturan inti tidak ikut gugur */
button:has(app-user-avatar),
button:has(mat-icon[fonticon*="copy" i]),
button:has(mat-icon[data-mat-icon-name="more_vert"]),
.cdk-overlay-pane:has(mat-tooltip-component),
.cdk-overlay-backdrop:has(mat-spinner) {
  display: none !important;
  opacity: 0 !important;
  pointer-events: none !important;
  width: 0 !important;
  height: 0 !important;
}
```

### C. Eliminasi Mask Fade & Pseudo-Elemen
* Teks obrolan bagian atas tidak boleh memudar (*fade-out*):
```css
.chat-panel-content, .chat-view, .conversation-container, .message-list, [role="log"],
app-chat-view, app-chat-panel, app-chat, app-conversation,
mat-sidenav-content, main, [role="main"],
cdk-virtual-scroll-viewport {
  box-sizing: border-box !important;
  -webkit-mask-image: none !important;
  mask-image: none !important;
}

.chat-panel-content::before, .chat-panel-content::after,
app-chat-view::before, app-chat-view::after,
main::before, main::after {
  display: none !important;
  content: none !important;
  background: none !important;
  opacity: 0 !important;
  height: 0 !important;
}
```

### D. Tata Letak Alami Kolom Input (*Natural Flexbox Docking*)
* Kapsul input pertanyaan (`.ot-chat-composer`) terpasang secara alami di dasar kolom percakapan (*in-flow flexbox child*):
  - `position: relative !important; flex: 0 0 auto !important; width: calc(100% - 32px) !important; max-width: 768px !important; margin: 8px auto max(18px, env(safe-area-inset-bottom, 0px)) auto !important;`
* Wadah transkrip pesan (`.ot-chat-transcript` dan `.chat-panel-content`):
  - `flex: 1 1 0px !important; min-height: 0 !important; overflow-y: auto !important; padding-bottom: 24px !important;`
* Wadah induk (`.ot-chat-path`, `mat-sidenav-content`, `app-chat-view`):
  - `overflow: hidden !important; min-height: 0 !important;`
* Keunggulan Tata Letak Alami:
  1. **Bebas Clipping & Teks Tertutup**: Kapsul input bukan lagi overlay mengambang (`position: fixed`), sehingga tidak menutupi pesan terakhir.
  2. **Scroll Murni**: Ketika pengguna scroll mentok ke bawah, baris pesan paling akhir berhenti tepat di atas kapsul input dengan jarak aman 24px padding + 8px margin.
  3. **Tanpa Injeksi Spacer Buatan**: Tidak memerlukan elemen `.ot-bottom-spacer` buatan yang rapuh terhadap rekonsiliasi DOM Angular. Elemen spacer lama otomatis dibersihkan oleh `removeLegacySpacers()`.

### E. Pembersihan Instan Saat Pergantian Tab (*Dynamic Tab Cleanup*)
* Setiap kali pengguna beralih antar-tab atau membuka tab yang sudah ada, aplikasi wajib mengeksekusi:
```javascript
window.otSetBackgroundPaused && window.otSetBackgroundPaused(false);
window.otNotebook && window.otNotebook.clean && window.otNotebook.clean();
```
* Diimplementasikan di:
  1. `AgentSessionManager.selectTab(int index)`
  2. `AgentSessionManager.openAgent(...)`
  3. `_SingleAgentTabWebViewState.didUpdateWidget(...)` saat `!oldWidget.isActive && widget.isActive`

### E. Polling Kesiapan Sesi (Readiness Stabilization)
* Wajib memenuhi kriteria mutlak: **minimal 4 sampel berturut-turut (2 detik), elapsed time minimum 3000ms, dan jeda mikro 250ms**:
```dart
// Lokasi: _checkSessionReady() di openturath_ai/lib/widgets/agent_multi_tab_room.dart
final result = await controller.evaluateJavascript(
    source: 'window.otNotebook ? window.otNotebook.ready() : false');
_readySamples = result == true ? _readySamples + 1 : 0;
if (!mounted) return;

final elapsedMs = _loadingStarted != null
    ? DateTime.now().difference(_loadingStarted!).inMilliseconds
    : 0;

if (_readySamples >= 4 && elapsedMs >= 3000) {
  _readinessTimer?.cancel();
  _inputRetryTimer?.cancel();
  _loadingStarted = null;
  await controller.evaluateJavascript(
    source: 'window.otNotebook?.activate()',
  );
  await Future.delayed(const Duration(milliseconds: 250));
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('google_session_ready', true);
  } catch (_) {}
  if (mounted) {
    widget.onReady?.call();
    setState(() {});
  }
}
```

### F. Standar Sakral Sesi Google Anti-Tamper
* Mesin WebKit macOS (`WKHTTPCookieStore`) memelihara cookie disk secara bawaan dan permanen.
* **HUKUM SAKRAL**: DILARANG menimpa cookie aktif WebKit (`lockAndPersistCookies()` dilarang memanggil `_setCookieSafely` untuk memodifikasi live cookies).
* `restoreSessionIfAvailable()`: Jika `hasLive == true`, langsung kembalikan `true` tanpa memutasi cookie.
* `reconcileWebSession()` di `auth_service.dart`: Dilarang memanggil `clearOnSignOut()` saat `owner.isEmpty`. Pembersihan HANYA boleh dipicu jika `owner.isNotEmpty && owner != current` (pergantian akun nyata).

### G. Hak Multi-Tab macOS (5 Tab Aktif)
* Di macOS desktop, `maxTabs = 5`.
* Tidak boleh ada tab yang ditutup secara diam-diam (*silent auto-eviction*).
* Tab di background dibekukan observer-nya via `window.otSetBackgroundPaused(true)` untuk menghemat CPU/RAM Mac.

### H. Isolasi Galat Total (*Clean Viewport Replacement*)
* Jika `session.errorMessage != null`, WebView **HARUS digantikan seutuhnya** dengan widget status galat:
```dart
if (session.errorMessage != null) {
  void close() => AgentSessionManager.instance.closeRoom();
  final state = ...; // widget error state
  return ColoredBox(color: canvas, child: state);
}
```

---

## 3. Sepuluh Pantangan Keras (THE 10 COMMANDMENTS)

1. ❌ **JANGAN PERNAH** menurunkan sampel polling kesiapan menjadi `< 4` atau menghapus syarat `elapsedMs >= 3000`.
2. ❌ **JANGAN PERNAH** menghapus jeda mikro `Future.delayed(Duration(milliseconds: 250))` sebelum `widget.onReady`.
3. ❌ **JANGAN PERNAH** menggabungkan selektor `:has(...)` ke dalam aturan koma CSS penghilang bilah utama.
4. ❌ **JANGAN PERNAH** menimpa atau memutasi cookie aktif WebKit (`__Secure-1PSIDTS`, `SID`) dengan masa kedaluwarsa buatan atau `SameSite=None`.
5. ❌ **JANGAN PERNAH** memanggil pembersihan cookie (`deleteAllCookies` / `clearSession`) selain ketika pengguna secara sadar menekan tombol **Log Out / Keluar**.
6. ❌ **JANGAN PERNAH** menurunkan batas tab macOS di bawah 5 tab aktif.
7. ❌ **JANGAN PERNAH** melakukan penutupan tab otomatis (*silent eviction*) saat pengguna membuka tab baru.
8. ❌ **JANGAN PERNAH** membiarkan `-webkit-mask-image` atau pseudo-elemen `::before`/`::after` aktif pada wadah chat (memicu teks atas pudar).
9. ❌ **JANGAN PERNAH** menghapus pemanggilan `clean()` pada saat perpindahan tab aktif (`selectTab` / `didUpdateWidget`).
10. ❌ **JANGAN PERNAH** menumpuk widget overlay Flutter di atas `InAppWebView` yang sedang berstatus galat.
