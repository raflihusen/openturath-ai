# Standar Baku & Format Ideal WebView OpenTurath AI

Dokumen ini mencatat format baku dan pantangan keras implementasi WebView (khususnya ruang telaah AI / NotebookLM pada `agent_multi_tab_room.dart` dan `desktop_webview_runtime.dart`).

> [!IMPORTANT]
> **DILARANG MERUBAH ATAU MENYEDERHANAKAN LOGIKA INI** saat melakukan perbaikan desain, audit UI, pembersihan kode, atau refactoring. Logika ini dirumuskan setelah audit forensik mendalam terhadap siklus hidup Angular SPA di dalam InAppWebView.

---

## 1. Masalah Utama yang Dicegah

1. **Angular SPA DOM Transient Glitch / Flicker**:
   Google NotebookLM adalah aplikasi Angular SPA yang melalui fase bootstrap multi-tahap (splash shell -> parsing sumber daya -> rendering composer chat). Pengecekan kesiapan yang terburu-buru (misal hanya 1-2 sampel atau tanpa durasi minimal) akan memicu `activate()` sebelum DOM selesai terbentuk, menyebabkan layar blank, input freeze, atau layout rusak.
2. **Platform View Overlay Collision**:
   Di Flutter desktop (macOS/Windows) maupun mobile, menumpuk native platform view (`InAppWebView`) di bawah widget overlay Flutter (`Positioned.fill`) saat terjadi error menyebabkan konflik event klik, kebocoran memori, dan kegagalan rekoneksi controller.

---

## 2. Format Baku Implementasi (Gold Standard)

File rujukan: `openturath_ai/lib/widgets/agent_multi_tab_room.dart`

### A. Polling Kesiapan Sesi (Readiness Stabilization)
Pengecekan kesiapan JavaScript wajib memenuhi aturan **4 sampel berturut-turut** (interval 500ms = 2 detik stabil) **DAN minimal 3000ms berlalu** sejak mulai memuat, diikuti **jeda mikro 250ms**:

```dart
// Lokasi: _checkSessionReady() di _SingleAgentTabWebViewState
final result = await controller.evaluateJavascript(
    source: 'window.otNotebook ? window.otNotebook.ready() : false');
_readySamples = result == true ? _readySamples + 1 : 0;
if (!mounted) return;

final elapsedMs = _loadingStarted != null
    ? DateTime.now().difference(_loadingStarted!).inMilliseconds
    : 0;

// WAJIB STABIL: minimal 4 sampel berturut-turut (2 detik) dan minimal 3000ms berlalu
// agar tidak ada flicker atau pemunculan dini sebelum layout Angular selesai sempurna.
if (_readySamples >= 4 && elapsedMs >= 3000) {
  _readinessTimer?.cancel();
  _inputRetryTimer?.cancel();
  _loadingStarted = null;
  await controller.evaluateJavascript(
    source: 'window.otNotebook?.activate()',
  );
  // Jeda mikro stabilisasi 250ms agar rendering WebKit rampung sebelum fade-out loader
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

### B. Isolasi Status Galat (Clean Error State Isolation)
Jika `session.errorMessage != null`, WebView **HARUS digantikan sepenuhnya** dengan widget error visual yang bersih, **TIDAK BOLEH** menumpuk platform view di belakang layar:

```dart
// Lokasi: build() di _SingleAgentTabWebViewState
if (session.errorMessage != null) {
  void close() => AgentSessionManager.instance.closeRoom();

  final state = ...; // widget error state
  return ColoredBox(color: canvas, child: state);
}
```

### C. Stack Viewport Murni
Di dalam stack utama tampilan kamar:
```dart
return Container(
  color: canvas,
  child: Stack(
    children: [
      Positioned.fill(child: webView),
      Positioned.fill(
        child: IgnorePointer(
          ignoring: session.isSessionReady || session.isGoogleAuthPage,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchOutCurve: Curves.easeOut,
            child: (!session.isSessionReady && !session.isGoogleAuthPage)
                ? AppLoader.fullscreen(...)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    ],
  ),
);
```

---

## 3. Daftar Pantangan Keras (DO NOTs)

- ❌ **JANGAN** menurunkan sampel kesiapan menjadi `< 4` atau menghapus syarat `elapsedMs >= 3000`.
- ❌ **JANGAN** menghapus `Future.delayed(Duration(milliseconds: 250))` sebelum `widget.onReady`.
- ❌ **JANGAN** menggunakan `errorOverlay` dengan `Positioned.fill` yang membiarkan WebView tetap aktif di belakang layer pesan error.
- ❌ **JANGAN** menyentuh file runtime `agent_multi_tab_room.dart` ketika tugas Anda hanya perbaikan desain UI (seperti kartu, tombol, atau typography pada dashboard/katalog).
