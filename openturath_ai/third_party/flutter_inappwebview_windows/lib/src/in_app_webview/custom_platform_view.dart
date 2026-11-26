import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '_static_channel.dart';
import 'windows_scroll_processor.dart';

const Map<String, SystemMouseCursor> _cursors = {
  'none': SystemMouseCursors.none,
  'basic': SystemMouseCursors.basic,
  'click': SystemMouseCursors.click,
  'forbidden': SystemMouseCursors.forbidden,
  'wait': SystemMouseCursors.wait,
  'progress': SystemMouseCursors.progress,
  'contextMenu': SystemMouseCursors.contextMenu,
  'help': SystemMouseCursors.help,
  'text': SystemMouseCursors.text,
  'verticalText': SystemMouseCursors.verticalText,
  'cell': SystemMouseCursors.cell,
  'precise': SystemMouseCursors.precise,
  'move': SystemMouseCursors.move,
  'grab': SystemMouseCursors.grab,
  'grabbing': SystemMouseCursors.grabbing,
  'noDrop': SystemMouseCursors.noDrop,
  'alias': SystemMouseCursors.alias,
  'copy': SystemMouseCursors.copy,
  'disappearing': SystemMouseCursors.disappearing,
  'allScroll': SystemMouseCursors.allScroll,
  'resizeLeftRight': SystemMouseCursors.resizeLeftRight,
  'resizeUpDown': SystemMouseCursors.resizeUpDown,
  'resizeUpLeftDownRight': SystemMouseCursors.resizeUpLeftDownRight,
  'resizeUpRightDownLeft': SystemMouseCursors.resizeUpRightDownLeft,
  'resizeUp': SystemMouseCursors.resizeUp,
  'resizeDown': SystemMouseCursors.resizeDown,
  'resizeLeft': SystemMouseCursors.resizeLeft,
  'resizeRight': SystemMouseCursors.resizeRight,
  'resizeUpLeft': SystemMouseCursors.resizeUpLeft,
  'resizeUpRight': SystemMouseCursors.resizeUpRight,
  'resizeDownLeft': SystemMouseCursors.resizeDownLeft,
  'resizeDownRight': SystemMouseCursors.resizeDownRight,
  'resizeColumn': SystemMouseCursors.resizeColumn,
  'resizeRow': SystemMouseCursors.resizeRow,
  'zoomIn': SystemMouseCursors.zoomIn,
  'zoomOut': SystemMouseCursors.zoomOut,
};

SystemMouseCursor _getCursorByName(String name) =>
    _cursors[name] ?? SystemMouseCursors.basic;

/// Pointer button type
// Order must match InAppWebViewPointerEventKind (see in_app_webview.h)
enum PointerButton { none, primary, secondary, tertiary }

/// Pointer Event kind
// Order must match InAppWebViewPointerEventKind (see in_app_webview.h)
enum InAppWebViewPointerEventKind { activate, down, enter, leave, up, update }

/// Attempts to translate a button constant such as [kPrimaryMouseButton]
/// to a [PointerButton]
PointerButton _getButton(int value) {
  switch (value) {
    case kPrimaryMouseButton:
      return PointerButton.primary;
    case kSecondaryMouseButton:
      return PointerButton.secondary;
    case kTertiaryButton:
      return PointerButton.tertiary;
    default:
      return PointerButton.none;
  }
}

const MethodChannel _pluginChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

class CustomFlutterViewControllerValue {
  const CustomFlutterViewControllerValue({
    required this.isInitialized,
  });

  final bool isInitialized;

  CustomFlutterViewControllerValue copyWith({
    bool? isInitialized,
  }) {
    return CustomFlutterViewControllerValue(
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  CustomFlutterViewControllerValue.uninitialized()
      : this(
          isInitialized: false,
        );
}

/// Controls a WebView and provides streams for various change events.
class CustomPlatformViewController
    extends ValueNotifier<CustomFlutterViewControllerValue> {
  Completer<void> _creatingCompleter = Completer<void>();
  int _textureId = 0;
  bool _isDisposed = false;

  Future<void> get ready => _creatingCompleter.future;

  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;
  StreamSubscription? _eventStreamSubscription;

  final StreamController<SystemMouseCursor> _cursorStreamController =
      StreamController<SystemMouseCursor>.broadcast();

  /// A stream reflecting the current cursor style.
  Stream<SystemMouseCursor> get _cursor => _cursorStreamController.stream;

  CustomPlatformViewController()
      : super(CustomFlutterViewControllerValue.uninitialized());

  /// Initializes the underlying platform view.
  Future<void> initialize(
      {Function(int id)? onPlatformViewCreated, dynamic arguments}) async {
    if (_isDisposed) {
      if (!_creatingCompleter.isCompleted) {
        _creatingCompleter.complete();
      }
      return;
    }
    try {
      final createdId = await _pluginChannel.invokeMethod<int>(
          'createInAppWebView', arguments);
      if (createdId == null) {
        throw PlatformException(
          code: '0',
          message: 'createInAppWebView returned null texture id',
        );
      }
      _textureId = createdId;

      if (_isDisposed) {
        try {
          await _pluginChannel.invokeMethod('dispose', {"id": _textureId});
        } catch (_) {}
        if (!_creatingCompleter.isCompleted) {
          _creatingCompleter.complete();
        }
        return;
      }

      _methodChannel =
          MethodChannel('com.pichillilorenzo/custom_platform_view_$_textureId');
      _eventChannel = EventChannel(
          'com.pichillilorenzo/custom_platform_view_${_textureId}_events');
      _eventStreamSubscription =
          _eventChannel.receiveBroadcastStream().listen((event) {
        if (_isDisposed || _cursorStreamController.isClosed) return;
        final map = event as Map<dynamic, dynamic>;
        switch (map['type']) {
          case 'cursorChanged':
            _cursorStreamController.add(_getCursorByName(map['value']));
            break;
        }
      });

      _methodChannel.setMethodCallHandler((call) {
        throw MissingPluginException('Unknown method ${call.method}');
      });

      value = value.copyWith(isInitialized: true);

      if (!_creatingCompleter.isCompleted) {
        _creatingCompleter.complete();
      }

      onPlatformViewCreated?.call(_textureId);
    } catch (e, st) {
      if (!_creatingCompleter.isCompleted) {
        _creatingCompleter.completeError(e, st);
      }
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _creatingCompleter.future;
    } catch (_) {}
    if (!_isDisposed) {
      _isDisposed = true;
      await _eventStreamSubscription?.cancel();
      if (!_cursorStreamController.isClosed) {
        await _cursorStreamController.close();
      }
      if (value.isInitialized) {
        try {
          await _pluginChannel.invokeMethod('dispose', {"id": _textureId});
        } catch (_) {}
      }
    }
    super.dispose();
  }

  /// Limits the number of frames per second to the given value.
  Future<void> setFpsLimit([int? maxFps = 0]) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setFpsLimit', maxFps);
  }

  /// Sends a Pointer (Touch) update
  Future<void> _setPointerUpdate(InAppWebViewPointerEventKind kind, int pointer,
      Offset position, double size, double pressure) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerUpdate',
        [pointer, kind.index, position.dx, position.dy, size, pressure]);
  }

  /// Moves the virtual cursor to [position].
  Future<void> _setCursorPos(Offset position) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel
        .invokeMethod('setCursorPos', [position.dx, position.dy]);
  }

  /// Indicates whether the specified [button] is currently down.
  Future<void> _setPointerButtonState(PointerButton button, bool isDown) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerButton',
        <String, dynamic>{'button': button.index, 'isDown': isDown});
  }

  /// Sets the horizontal and vertical scroll delta.
  Future<void> _setScrollDelta(double dx, double dy) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setScrollDelta', [dx, dy]);
  }

  /// Sets the surface size to the provided [size].
  Future<void> _setSize(Size size, double scaleFactor) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel
        .invokeMethod('setSize', [size.width, size.height, scaleFactor]);
  }

  /// Sets the surface size to the provided [size].
  Future<void> _setPosition(Offset position, double scaleFactor) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel
        .invokeMethod('setPosition', [position.dx, position.dy, scaleFactor]);
  }
}

class CustomPlatformView extends StatefulWidget {
  /// An optional scale factor. Defaults to [FlutterView.devicePixelRatio] for
  /// rendering in native resolution.
  /// Setting this to 1.0 will disable high-DPI support.
  /// This should only be needed to mimic old behavior before high-DPI support
  /// was available.
  final double? scaleFactor;

  /// The [FilterQuality] used for scaling the texture's contents.
  /// Defaults to [FilterQuality.none] as this renders in native resolution
  /// unless specifying a [scaleFactor].
  final FilterQuality filterQuality;

  final dynamic creationParams;

  final Function(int id)? onPlatformViewCreated;

  const CustomPlatformView(
      {this.creationParams,
      this.onPlatformViewCreated,
      this.scaleFactor,
      this.filterQuality = FilterQuality.none});

  @override
  _CustomPlatformViewState createState() => _CustomPlatformViewState();
}

class _CustomPlatformViewState extends State<CustomPlatformView> {
  final GlobalKey _key = GlobalKey();
  final _downButtons = <int, PointerButton>{};

  PointerDeviceKind _pointerKind = PointerDeviceKind.unknown;

  MouseCursor _cursor = SystemMouseCursors.basic;

  final _controller = CustomPlatformViewController();
  final _focusNode = FocusNode();
  final _scrollProcessor = WindowsTouchpadScrollProcessor();
  Offset? _lastSyncedCursorPos;
  bool _hasSyncedSurfaceForScroll = false;

  StreamSubscription? _cursorSubscription;

  void _syncCursorPosIfNeeded(Offset position) {
    final prev = _lastSyncedCursorPos;
    if (prev == null || (prev - position).distanceSquared >= 1.0) {
      _lastSyncedCursorPos = position;
      _controller._setCursorPos(position);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller
        .initialize(
            onPlatformViewCreated: (id) {
              if (!mounted) return;
              widget.onPlatformViewCreated?.call(id);
              if (mounted) {
                setState(() {});
              }
            },
            arguments: widget.creationParams)
        .catchError((_) {});

    // Report initial surface size and widget position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reportSurfaceSize();
      _reportWidgetPosition();
    });

    _cursorSubscription = _controller._cursor.listen((cursor) {
      if (!mounted) return;
      setState(() {
        _cursor = cursor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      canRequestFocus: true,
      debugLabel: "flutter_inappwebview_windows_custom_platform_view",
      onFocusChange: (focused) {},
      child: SizedBox.expand(key: _key, child: _buildInner()),
    );
  }

  Widget _buildInner() {
    return NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          _reportSurfaceSize();
          _reportWidgetPosition();
          return true;
        },
        child: SizeChangedLayoutNotifier(
            child: _controller.value.isInitialized
                ? Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerHover: (ev) {
                      if (ev.kind == PointerDeviceKind.touch) {
                        return;
                      }
                      // Recover from 2-in-1 touchscreen usage when user returns to mouse/touchpad.
                      if (_pointerKind == PointerDeviceKind.touch) {
                        _pointerKind = ev.kind;
                      }
                      _syncCursorPosIfNeeded(ev.localPosition);
                    },
                    onPointerDown: (ev) {
                      _reportSurfaceSize();
                      _reportWidgetPosition();
                      _hasSyncedSurfaceForScroll = true;

                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                        Future.delayed(const Duration(milliseconds: 50), () {
                          if (!mounted) return;
                          if (!_focusNode.hasFocus) {
                            _focusNode.requestFocus();
                          }
                        });
                      }

                      _pointerKind = ev.kind;
                      if (ev.kind == PointerDeviceKind.touch) {
                        _controller._setPointerUpdate(
                            InAppWebViewPointerEventKind.down,
                            ev.pointer,
                            ev.localPosition,
                            ev.size,
                            ev.pressure);
                        return;
                      }
                      _syncCursorPosIfNeeded(ev.localPosition);
                      final button = _getButton(ev.buttons);
                      _downButtons[ev.pointer] = button;
                      _controller._setPointerButtonState(button, true);
                    },
                    onPointerUp: (ev) {
                      _pointerKind = ev.kind;
                      if (ev.kind == PointerDeviceKind.touch) {
                        _controller._setPointerUpdate(
                            InAppWebViewPointerEventKind.up,
                            ev.pointer,
                            ev.localPosition,
                            ev.size,
                            ev.pressure);
                        return;
                      }
                      final button = _downButtons.remove(ev.pointer);
                      if (button != null) {
                        _controller._setPointerButtonState(button, false);
                      }
                    },
                    onPointerCancel: (ev) {
                      _pointerKind = ev.kind;
                      final button = _downButtons.remove(ev.pointer);
                      if (button != null) {
                        _controller._setPointerButtonState(button, false);
                      }
                    },
                    onPointerMove: (ev) {
                      _pointerKind = ev.kind;
                      if (ev.kind == PointerDeviceKind.touch) {
                        _controller._setPointerUpdate(
                            InAppWebViewPointerEventKind.update,
                            ev.pointer,
                            ev.localPosition,
                            ev.size,
                            ev.pressure);
                      } else {
                        _lastSyncedCursorPos = ev.localPosition;
                        _controller._setCursorPos(ev.localPosition);
                      }
                    },
                    onPointerSignal: (signal) {
                      if (signal is PointerScrollEvent) {
                        if (!_hasSyncedSurfaceForScroll) {
                          _reportSurfaceSize();
                          _reportWidgetPosition();
                          _hasSyncedSurfaceForScroll = true;
                        }
                        if (signal.kind != PointerDeviceKind.touch) {
                          _pointerKind = signal.kind;
                        }
                        _syncCursorPosIfNeeded(signal.localPosition);
                        final delta = _scrollProcessor.processPointerScroll(
                          dx: signal.scrollDelta.dx,
                          dy: signal.scrollDelta.dy,
                        );
                        if (delta != null) {
                          _controller._setScrollDelta(delta.dx, delta.dy);
                        }
                      } else if (signal is PointerScrollInertiaCancelEvent) {
                        _scrollProcessor.reset();
                      }
                    },
                    onPointerPanZoomStart: (ev) {
                      _reportSurfaceSize();
                      _reportWidgetPosition();
                      _hasSyncedSurfaceForScroll = true;
                      _pointerKind = ev.kind;
                      _scrollProcessor.onPanZoomStart();
                      _syncCursorPosIfNeeded(ev.localPosition);
                    },
                    onPointerPanZoomUpdate: (ev) {
                      _syncCursorPosIfNeeded(ev.localPosition);
                      final delta = _scrollProcessor.processPanZoomUpdate(
                        dx: ev.panDelta.dx,
                        dy: ev.panDelta.dy,
                        scale: ev.scale,
                      );
                      if (delta != null) {
                        _controller._setScrollDelta(delta.dx, delta.dy);
                      }
                    },
                    onPointerPanZoomEnd: (ev) {
                      _scrollProcessor.onPanZoomEnd();
                    },
                    child: MouseRegion(
                        cursor: _cursor,
                        child: Texture(
                          textureId: _controller._textureId,
                          filterQuality: widget.filterQuality,
                        )),
                  )
                : const SizedBox()));
  }

  void _reportSurfaceSize() async {
    try {
      await _controller.ready;
    } catch (_) {
      return;
    }
    if (!mounted || !_controller.value.isInitialized) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize) {
      unawaited(_controller._setSize(
          box.size, widget.scaleFactor ?? window.devicePixelRatio));
    }
  }

  void _reportWidgetPosition() async {
    try {
      await _controller.ready;
    } catch (_) {
      return;
    }
    if (!mounted || !_controller.value.isInitialized) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize) {
      final position = box.localToGlobal(Offset.zero);
      unawaited(_controller._setPosition(
          position, widget.scaleFactor ?? window.devicePixelRatio));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cursorSubscription?.cancel();
    _controller.dispose();
    _focusNode.dispose();
  }
}
