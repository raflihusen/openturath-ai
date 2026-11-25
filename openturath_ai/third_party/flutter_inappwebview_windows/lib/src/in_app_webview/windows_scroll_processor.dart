/// Axis-locked, sub-pixel accurate scroll processor for Windows WebView2
/// composition (`ICoreWebView2CompositionController::SendMouseInput`).
///
/// Fixes upstream `flutter_inappwebview_windows` 0.6.0 defects (#2503 / #2511):
/// 1. Dual-axis `HORIZONTAL_WHEEL` + `WHEEL` lockup on Windows Precision
///    Touchpads when vertical swipes contain horizontal micro-drift.
/// 2. Sub-pixel truncation to `0` (`static_cast<short>(delta * 6)`) on
///    high-frequency 120Hz/240Hz touchpads and high-res wheels.
/// 3. Calibration mismatch (touchpad `panDelta` is logical pixels, whereas
///    C++ `kScrollMultiplier = 6` targets mouse-wheel clicks) & `int16_t`
///    overflow protection on fast flicks.
/// 4. Correct Win32 `WM_MOUSEHWHEEL` horizontal sign (`+` = right, `-` = left)
///    for both Precision Touchpad (`PointerPanZoomUpdateEvent`) and legacy
///    Synaptics/ELAN drivers (`PointerScrollEvent`).
/// 5. Pinch-to-zoom (`scale != 1.0`) exclusion so zoom never injects scroll.
enum WindowsScrollAxisLock { none, vertical, horizontal }

class WindowsScrollDelta {
  const WindowsScrollDelta(this.dx, this.dy);

  final double dx;
  final double dy;
}

class WindowsTouchpadScrollProcessor {
  /// Matches C++ `InAppWebView::sendScroll` `kScrollMultiplier = 6`.
  static const double cppWheelMultiplier = 6.0;

  /// Scales Precision Touchpad logical-pixel `panDelta` so `panDelta * scale * 6`
  /// yields ~1.68 Win32 wheel units per logical pixel (~1.4 CSS px in Chromium,
  /// matching native Edge/Windows touchpad speed instead of 5x overspeed).
  static const double touchpadWheelScale = 0.28;

  /// Minimum cumulative pan distance (logical px) before locking gesture axis.
  static const double axisLockThresholdPx = 2.0;

  /// Slight vertical bias so natural two-finger vertical reading with slight
  /// diagonal drift never accidentally locks to horizontal scrolling.
  static const double horizontalDominanceRatio = 1.35;

  /// Safe per-event delta ceiling: `4000 * 6 = 24000` (well within `int16_t`).
  static const double maxEmitDelta = 4000.0;

  WindowsScrollAxisLock _axisLock = WindowsScrollAxisLock.none;
  double _gestureAbsX = 0.0;
  double _gestureAbsY = 0.0;
  double _panResidualX = 0.0;
  double _panResidualY = 0.0;
  double _wheelResidualX = 0.0;
  double _wheelResidualY = 0.0;

  WindowsScrollAxisLock get axisLock => _axisLock;

  void onPanZoomStart() {
    _axisLock = WindowsScrollAxisLock.none;
    _gestureAbsX = 0.0;
    _gestureAbsY = 0.0;
    _panResidualX = 0.0;
    _panResidualY = 0.0;
  }

  void onPanZoomEnd() {
    _axisLock = WindowsScrollAxisLock.none;
    _gestureAbsX = 0.0;
    _gestureAbsY = 0.0;
    _panResidualX = 0.0;
    _panResidualY = 0.0;
  }

  void reset() {
    onPanZoomEnd();
    _wheelResidualX = 0.0;
    _wheelResidualY = 0.0;
  }

  /// Processes a Windows Precision Touchpad `PointerPanZoomUpdateEvent`.
  ///
  /// Returns `null` when the gesture is a pinch-zoom or the accumulated delta
  /// is still below 1 Win32 wheel unit (preserved in the fractional residual).
  WindowsScrollDelta? processPanZoomUpdate({
    required double dx,
    required double dy,
    double scale = 1.0,
  }) {
    if (!dx.isFinite || !dy.isFinite || !scale.isFinite) {
      return null;
    }
    if ((scale - 1.0).abs() > 0.01) {
      return null;
    }
    if (dx == 0.0 && dy == 0.0) {
      return null;
    }

    _gestureAbsX += dx.abs();
    _gestureAbsY += dy.abs();

    WindowsScrollAxisLock activeAxis = _axisLock;
    if (activeAxis == WindowsScrollAxisLock.none) {
      if (_gestureAbsX + _gestureAbsY >= axisLockThresholdPx) {
        _axisLock = _gestureAbsX > _gestureAbsY * horizontalDominanceRatio
            ? WindowsScrollAxisLock.horizontal
            : WindowsScrollAxisLock.vertical;
        activeAxis = _axisLock;
      } else {
        activeAxis = dx.abs() > dy.abs() * horizontalDominanceRatio
            ? WindowsScrollAxisLock.horizontal
            : WindowsScrollAxisLock.vertical;
      }
    }

    if (activeAxis == WindowsScrollAxisLock.horizontal) {
      // Two-finger pan left (dx < 0) scrolls content right (WM_MOUSEHWHEEL > 0).
      _panResidualX += -dx * touchpadWheelScale;
      final emittedX = _consumeQuantized(_panResidualX);
      if (emittedX == 0.0) {
        return null;
      }
      _panResidualX -= emittedX;
      return WindowsScrollDelta(_clampDelta(emittedX), 0.0);
    } else {
      // Two-finger pan up (dy < 0) scrolls content down (WM_MOUSEWHEEL < 0).
      _panResidualY += dy * touchpadWheelScale;
      final emittedY = _consumeQuantized(_panResidualY);
      if (emittedY == 0.0) {
        return null;
      }
      _panResidualY -= emittedY;
      return WindowsScrollDelta(0.0, _clampDelta(emittedY));
    }
  }

  /// Processes a `PointerScrollEvent` (physical mouse wheel or legacy
  /// Synaptics/ELAN touchpad driver).
  WindowsScrollDelta? processPointerScroll({
    required double dx,
    required double dy,
  }) {
    if (!dx.isFinite || !dy.isFinite) {
      return null;
    }
    if (dx == 0.0 && dy == 0.0) {
      return null;
    }

    final bool isHorizontal;
    if (dx != 0.0 && dy != 0.0) {
      isHorizontal = dx.abs() > dy.abs() * horizontalDominanceRatio;
    } else {
      isHorizontal = dx != 0.0;
    }

    if (isHorizontal) {
      // Flutter scrollDelta.dx > 0 scrolls right; Win32 WM_MOUSEHWHEEL > 0 scrolls right.
      _wheelResidualX += dx;
      final emittedX = _consumeQuantized(_wheelResidualX);
      if (emittedX == 0.0) {
        return null;
      }
      _wheelResidualX -= emittedX;
      return WindowsScrollDelta(_clampDelta(emittedX), 0.0);
    } else {
      // Flutter scrollDelta.dy > 0 scrolls down; Win32 WM_MOUSEWHEEL < 0 scrolls down.
      _wheelResidualY += -dy;
      final emittedY = _consumeQuantized(_wheelResidualY);
      if (emittedY == 0.0) {
        return null;
      }
      _wheelResidualY -= emittedY;
      return WindowsScrollDelta(0.0, _clampDelta(emittedY));
    }
  }

  static double _consumeQuantized(double residual) {
    final int wheelUnits = (residual * cppWheelMultiplier).truncate();
    if (wheelUnits == 0) {
      return 0.0;
    }
    return wheelUnits / cppWheelMultiplier;
  }

  static double _clampDelta(double value) {
    if (value > maxEmitDelta) return maxEmitDelta;
    if (value < -maxEmitDelta) return -maxEmitDelta;
    return value;
  }
}
