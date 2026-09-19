import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';

/// One notebook belongs to one Firebase identity for its entire lifetime.
class AgentSessionTab {
  final AgentModel agent;
  final String ownerUid;
  final String bridgeNonce = base64UrlEncode(
    List<int>.generate(32, (_) => Random.secure().nextInt(256)),
  );
  String? resolvedUrl;
  InAppWebViewController? webController;
  final InAppWebViewKeepAlive keepAlive = InAppWebViewKeepAlive();
  bool isUrlLoading = true;
  bool isWebLoading = true;
  bool isSessionReady = false;
  String? errorMessage;
  bool isPaywallRequired = false;
  bool isTimeoutError = false;
  bool isGooglePermissionError = false;
  double fontScale = 1.0;
  bool hasAcknowledgedAdab = false;
  bool hasInjectedEarlyScript = false;
  bool isDisposed = false;
  bool isRetired = false;

  AgentSessionTab({required this.agent, required this.ownerUid, this.resolvedUrl});

  Future<void> disposeWebResources() async {
    if (isDisposed) return;
    isDisposed = true;
    final controller = webController;
    webController = null;
    resolvedUrl = null;
    isSessionReady = false;
    isWebLoading = false;
    hasInjectedEarlyScript = false;
    try { controller?.removeJavaScriptHandler(handlerName: 'otCopiedAnswer'); } catch (_) {}
    try { await controller?.stopLoading(); } catch (_) {}
    // Dropping the Dart controller alone does not release a kept-alive native view.
    try { await InAppWebViewController.disposeKeepAlive(keepAlive); } catch (_) {}
  }
}

class AgentSessionManager extends ChangeNotifier {
  static final AgentSessionManager instance = AgentSessionManager._();
  AgentSessionManager._()
      : _currentUid = (() => FirebaseAuth.instance.currentUser?.uid),
        _disposeTab = ((tab) => tab.disposeWebResources()),
        _clearBrowser = _clearBrowserStorage {
    try {
      _ownerUid = _currentUid();
      _watchIdentity(FirebaseAuth.instance.authStateChanges().map((user) => user?.uid));
    } catch (_) { /* Firebase bootstrap may not be available in preview/tests. */ }
  }

  /// Dependency injection for ownership/lifecycle tests; production uses [instance].
  @visibleForTesting
  AgentSessionManager.testing({
    required String? Function() currentUid,
    required Future<void> Function(AgentSessionTab) disposeTab,
    required Future<void> Function() clearBrowserData,
    Stream<String?>? identityChanges,
  }) : _currentUid = currentUid, _disposeTab = disposeTab, _clearBrowser = clearBrowserData {
    _ownerUid = _currentUid();
    if (identityChanges != null) _watchIdentity(identityChanges);
  }

  final String? Function() _currentUid;
  final Future<void> Function(AgentSessionTab) _disposeTab;
  final Future<void> Function() _clearBrowser;

  void _watchIdentity(Stream<String?> identities) {
    _authSubscription = identities.listen((uid) {
      if (uid == _ownerUid) return;
      _ownerUid = uid;
      unawaited(closeAll(clearBrowserData: true));
    });
  }

  static Future<void> _clearBrowserStorage() async {
    try { await CookieManager.instance().deleteAllCookies(); } catch (_) {}
    try { await InAppWebViewController.clearAllCache(); } catch (_) {}
    try { await WebStorageManager.instance().deleteAllData(); } catch (_) {}
  }

  static const int maxTabs = 3;
  final List<AgentSessionTab> _tabs = [];
  StreamSubscription<String?>? _authSubscription;
  String? _ownerUid;
  Future<void> _cleanup = Future<void>.value();
  Future<void> _openTail = Future<void>.value();
  int _generation = 0;
  int _activeIndex = 0;
  bool _isOpen = false;

  List<AgentSessionTab> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _activeIndex;
  bool get isOpen => _isOpen;
  bool get hasSessions => _tabs.isNotEmpty;
  AgentSessionTab? get activeTab => _tabs.isEmpty || _activeIndex >= _tabs.length
      ? null : _tabs[_activeIndex];

  Future<void> openAgent(AgentModel agent, {UserModel? user}) {
    final generation = _generation;
    final operation = _openTail.then((_) async {
      if (generation == _generation) await _openAgent(agent, user: user);
    });
    _openTail = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _openAgent(AgentModel agent, {UserModel? user}) async {
    final uid = _currentUid();
    if (uid == null || (user != null && user.uid != uid)) return;
    if (_ownerUid != uid) {
      _ownerUid = uid;
      await closeAll(clearBrowserData: true);
    }
    final generation = _generation;
    await _cleanup;
    if (generation != _generation || _currentUid() != uid) return;
    final existing = _tabs.indexWhere((tab) => tab.agent.id == agent.id && tab.ownerUid == uid);
    if (existing >= 0) {
      _activeIndex = existing;
    } else {
      if (_tabs.length >= maxTabs) await closeTab(_activeIndex == 0 ? 1 : 0);
      if (generation != _generation || _currentUid() != uid) return;
      _tabs.add(AgentSessionTab(agent: agent, ownerUid: uid));
      _activeIndex = _tabs.length - 1;
    }
    _isOpen = true;
    notifyListeners();
  }

  void selectTab(int index) {
    if (index >= 0 && index < _tabs.length && _activeIndex != index) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  Future<void> closeTab(int index) async {
    if (index < 0 || index >= _tabs.length) return;
    final tab = _tabs.removeAt(index);
    tab.isRetired = true;
    if (_tabs.isEmpty) { _isOpen = false; _activeIndex = 0; }
    else if (index < _activeIndex) { _activeIndex--; }
    else if (_activeIndex >= _tabs.length) { _activeIndex = _tabs.length - 1; }
    notifyListeners();
    await _disposeTab(tab);
  }

  void closeRoom() { _isOpen = false; notifyListeners(); }

  Future<void> closeAll({bool clearBrowserData = false}) {
    _generation++;
    final retired = List<AgentSessionTab>.of(_tabs);
    for (final tab in retired) { tab.isRetired = true; }
    _tabs.clear();
    _activeIndex = 0;
    _isOpen = false;
    notifyListeners();
    _cleanup = _cleanup.then((_) async {
      for (final tab in retired) { await _disposeTab(tab); }
      if (clearBrowserData) await _clearBrowser();
    });
    return _cleanup;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    for (final tab in _tabs) { tab.isRetired = true; unawaited(_disposeTab(tab)); }
    _tabs.clear();
    super.dispose();
  }
}
