import '../widgets/desktop_shortcuts.dart';
import '../core/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_config.dart';
import '../core/design/ot_colors.dart';
import '../models/agent_model.dart';
import '../models/field_model.dart';
import 'dashboard_screen.dart';
import 'specialist_list_screen.dart';
import 'bookmark_screen.dart';
import 'profile_screen.dart';
import '../widgets/openturath_brand.dart';
import '../core/app_snackbar.dart';
import '../services/agent_session_manager.dart';
import '../widgets/agent_multi_tab_room.dart';

class MainShellController extends InheritedWidget {
  final void Function(int index, {String? fieldId, CorpusKind? kind}) switchTab;

  const MainShellController({
    super.key,
    required this.switchTab,
    required super.child,
  });

  static MainShellController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellController>();
  }

  @override
  bool updateShouldNotify(MainShellController oldWidget) => false;
}

class MainShellScreen extends StatefulWidget {
  final int initialTab;

  const MainShellScreen({super.key, this.initialTab = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final FocusNode _dashboardSearchFocus = FocusNode();
  late int _currentIndex;
  late final PageController _pageController;
  String? _selectedFieldId;
  CorpusKind? _selectedKind;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _dashboardSearchFocus.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index, {String? fieldId, CorpusKind? kind}) {
    AppSnackBar.clear(context);
    if (_pageController.hasClients && _currentIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    setState(() {
      _currentIndex = index;
      _selectedFieldId = fieldId;
      _selectedKind = kind;
    });
  }

  List<Widget> _buildScreens() {
    final field = _selectedFieldId != null
        ? FieldModel.defaultFields.firstWhere(
            (f) => f.id == _selectedFieldId,
            orElse: () => FieldModel.defaultFields.first,
          )
        : null;

    return [
      DashboardScreen(searchFocusNode: _dashboardSearchFocus),
      SpecialistListScreen(
        key: ValueKey('${_selectedFieldId}_${_selectedKind?.name}'),
        field: field,
      ),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];
  }

  void _showPage(int index) {
    AgentSessionManager.instance.closeRoom();
    FocusScope.of(context).unfocus();
    _onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) => DesktopShortcuts(
        onFind: () {
          _showPage(0);
          if (_pageController.hasClients) _pageController.jumpToPage(0);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _dashboardSearchFocus.requestFocus();
          });
        },
        onNewTab: () => _showPage(1),
        onSettings: () => _showPage(3),
        onCloseTab: () {
          final manager = AgentSessionManager.instance;
          if (manager.isOpen) manager.closeTab(manager.activeIndex);
        },
        onReload: () {
          // Dinonaktifkan: Cmd+R di dalam sesi AI merusak layout obrolan (menampilkan bilah Sources/Studio).
          // Pintasan diabaikan secara aman agar tidak mereset sesi aktif.
        },
        onEscape: () {
          final manager = AgentSessionManager.instance;
          if (manager.isOpen) manager.closeRoom();
          FocusScope.of(context).unfocus();
        },
        child: _buildShell(context),
      );

  Widget _buildShell(BuildContext context) {
    Loc.watch(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = OTColors.canvas(isDark);
    final surface = OTColors.surface(isDark);
    final accent = OTColors.accent(isDark);
    final indicator = OTColors.primaryContainer(isDark);

    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    final expandedSidebar = MediaQuery.sizeOf(context).width >= 1100;
    final screens = _buildScreens();

    final Widget baseScaffold = isWideScreen
        ? Scaffold(
            backgroundColor: canvas,
            body: Row(
              children: [
                Container(
                  decoration: BoxDecoration(color: surface,
                    border: BorderDirectional(end: BorderSide(color: OTColors.border(isDark)))) ,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: NavigationRail(
                          backgroundColor: surface,
                          indicatorColor: indicator,
                          minWidth: 92,
                          minExtendedWidth: 208,
                          extended: expandedSidebar,
                          selectedIndex: _currentIndex,
                          labelType: expandedSidebar
                              ? NavigationRailLabelType.none
                              : NavigationRailLabelType.all,
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 28),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              OpenTurathMark(size: 30, color: accent),
                              if (expandedSidebar) ...[
                                const SizedBox(width: 10),
                                Text('OpenTurath', style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ]),
                          ),
                          onDestinationSelected: (index) {
                            HapticFeedback.selectionClick();
                            _onTabSelected(index);
                          },
                          destinations: [
                            NavigationRailDestination(
                              icon: const Icon(Icons.home_outlined),
                              selectedIcon: const Icon(Icons.home_rounded),
                              label: Text(Loc.tr('navHome')),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.auto_stories_outlined),
                              selectedIcon:
                                  const Icon(Icons.auto_stories_rounded),
                              label: Text(Loc.tr('navStudies')),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.edit_note_outlined),
                              selectedIcon: const Icon(Icons.edit_note_rounded),
                              label: Text(Loc.tr('navSaved')),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.settings_outlined),
                              selectedIcon: const Icon(Icons.settings_rounded),
                              label: Text(Loc.tr('navSettings')),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: isDark
                            ? Loc.tr('ui_26894b3c65')
                            : Loc.tr('ui_b16e7fe4e5'),
                        icon: Icon(isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded),
                        onPressed: () => AppConfig.setThemeMode(
                            isDark ? ThemeMode.light : ThemeMode.dark),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: screens,
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: canvas,
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: screens,
            ),
            extendBody: false,
            bottomNavigationBar: NavigationBar(
              backgroundColor: surface,
              indicatorColor: indicator,
              selectedIndex: _currentIndex,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (index) {
                HapticFeedback.selectionClick();
                _onTabSelected(index);
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: Loc.tr('navHome'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.auto_stories_outlined),
                  selectedIcon: const Icon(Icons.auto_stories_rounded),
                  label: Loc.tr('navStudies'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.edit_note_outlined),
                  selectedIcon: const Icon(Icons.edit_note_rounded),
                  label: Loc.tr('navSaved'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings_rounded),
                  label: Loc.tr('navSettings'),
                ),
              ],
            ),
          );

    return MainShellController(
      switchTab: _onTabSelected,
      child: ListenableBuilder(
        listenable: AgentSessionManager.instance,
        builder: (context, child) {
          final sessionManager = AgentSessionManager.instance;

          return PopScope(
            // canPop hanya diizinkan jika ruang tertutup DAN sedang di tab 0
            canPop: !sessionManager.isOpen && _currentIndex == 0,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (sessionManager.isOpen) {
                if (context.mounted) {
                  AppSnackBar.clear(context);
                }
                sessionManager.closeRoom();
                return;
              }
              if (_currentIndex != 0) {
                if (context.mounted) {
                  AppSnackBar.clear(context);
                }
                _onTabSelected(0);
              }
            },
            child: Stack(
              children: [
                // 1. Dashboard latar belakang (Stationary - bebas GPU overhead)
                ExcludeFocus(
                    excluding: sessionManager.isOpen, child: baseScaffold),

                // 2. Ruang AI Multi-Tab (Instant zero-glitch display dengan retensi memori penuh)
                Positioned.fill(
                  child: Visibility(
                    visible: sessionManager.isOpen,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: ExcludeFocus(
                        excluding: !sessionManager.isOpen, child: child!),
                  ),
                ),
              ],
            ),
          );
        },
        child: const AgentMultiTabRoom(),
      ),
    );
  }
}
