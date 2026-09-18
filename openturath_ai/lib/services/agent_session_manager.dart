import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/agent_model.dart';
import '../models/user_model.dart';

/// Represents a single active AI specialist tab in memory.
class AgentSessionTab {
  final AgentModel agent;
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

  AgentSessionTab({
    required this.agent,
    this.resolvedUrl,
  });

  /// Lepaskan seluruh resource WebView dan handler JavaScript untuk mencegah kebocoran memori.
  Future<void> disposeWebResources() async {
    try {
      await webController?.stopLoading();
      webController?.removeJavaScriptHandler(handlerName: 'otCopiedAnswer');
    } catch (_) {}
    webController = null;
    isSessionReady = false;
    isWebLoading = false;
    hasInjectedEarlyScript = false;
  }
}

/// AgentSessionManager: Singleton state manager for multi-tab AI study sessions.
/// Keeps up to 7 specialists loaded in background memory like Google Chrome tabs.
class AgentSessionManager extends ChangeNotifier {
  static final AgentSessionManager instance = AgentSessionManager._();
  AgentSessionManager._();

  static const int maxTabs = 3;

  final List<AgentSessionTab> _tabs = [];
  int _activeIndex = 0;
  bool _isOpen = false;

  List<AgentSessionTab> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _activeIndex;
  bool get isOpen => _isOpen;
  bool get hasSessions => _tabs.isNotEmpty;

  AgentSessionTab? get activeTab {
    if (_tabs.isEmpty || _activeIndex < 0 || _activeIndex >= _tabs.length) {
      return null;
    }
    return _tabs[_activeIndex];
  }

  /// Open an agent or switch to its existing active tab with zero reload.
  void openAgent(AgentModel agent, {UserModel? user}) {
    final existingIndex = _tabs.indexWhere((t) => t.agent.id == agent.id);
    if (existingIndex != -1) {
      _activeIndex = existingIndex;
    } else {
      if (_tabs.length >= maxTabs) {
        // Tab limit reached: close oldest non-active tab to preserve WebView memory
        final evictIndex = _activeIndex == 0 ? 1 : 0;
        closeTab(evictIndex);
      }
      _tabs.add(AgentSessionTab(agent: agent));
      _activeIndex = _tabs.length - 1;
    }
    _isOpen = true;
    notifyListeners();
  }

  /// Switch active tab (like clicking a Chrome tab).
  void selectTab(int index) {
    if (index >= 0 && index < _tabs.length && _activeIndex != index) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  /// Close a specific tab with the 'x' button.
  void closeTab(int index) {
    if (index < 0 || index >= _tabs.length) return;

    final tabToClose = _tabs[index];
    tabToClose.disposeWebResources();

    _tabs.removeAt(index);

    if (_tabs.isEmpty) {
      _isOpen = false;
      _activeIndex = 0;
    } else if (index < _activeIndex) {
      _activeIndex--;
    } else if (_activeIndex >= _tabs.length) {
      _activeIndex = _tabs.length - 1;
    }
    notifyListeners();
  }

  /// Hide the AI study room to return to the Dashboard while keeping all WebViews alive.
  void closeRoom() {
    _isOpen = false;
    notifyListeners();
  }

  /// Reset all sessions (e.g. on user logout).
  void closeAll() {
    for (final tab in _tabs) {
      tab.disposeWebResources();
    }
    _tabs.clear();
    _activeIndex = 0;
    _isOpen = false;
    notifyListeners();
  }
}
