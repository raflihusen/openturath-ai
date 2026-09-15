import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_config.dart';
import '../core/app_copy.dart';
import '../core/theme.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_motion.dart';
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
      const DashboardScreen(),
      SpecialistListScreen(
        key: ValueKey('${_selectedFieldId}_${_selectedKind?.name}'),
        field: field,
      ),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canvas = isDark ? AppTheme.canvasDark : AppTheme.canvasLight;
    final surface = isDark ? AppTheme.surfaceCardDark : AppTheme.surfaceCardLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final accent = isDark ? AppTheme.accentDark : AppTheme.accentLight;
    final unselected = isDark ? AppTheme.textTertiaryDark : AppTheme.textTertiaryLight;

    final isWideScreen = MediaQuery.of(context).size.width >= 768;
    final screens = _buildScreens();

    final Widget baseScaffold = isWideScreen
        ? Scaffold(
            backgroundColor: canvas,
            body: Row(
              children: [
                Container(
                  width: 76,
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border(right: BorderSide(color: border, width: 1)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      OpenTurathMark(size: 36, color: accent),
                      const SizedBox(height: 32),
                      _RailItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: AppCopy.navHome,
                        isSelected: _currentIndex == 0,
                        accent: accent,
                        unselected: unselected,
                        onTap: () => _onTabSelected(0),
                      ),
                      const SizedBox(height: 16),
                      _RailItem(
                        icon: Icons.auto_awesome_outlined,
                        activeIcon: Icons.auto_awesome_rounded,
                        label: AppCopy.navStudies,
                        isSelected: _currentIndex == 1,
                        accent: accent,
                        unselected: unselected,
                        onTap: () => _onTabSelected(1),
                      ),
                      const SizedBox(height: 16),
                      _RailItem(
                        icon: Icons.edit_note_rounded,
                        activeIcon: Icons.edit_note_rounded,
                        label: AppCopy.navSaved,
                        isSelected: _currentIndex == 2,
                        accent: accent,
                        unselected: unselected,
                        onTap: () => _onTabSelected(2),
                      ),
                      const SizedBox(height: 16),
                      _RailItem(
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings_rounded,
                        label: AppCopy.navSettings,
                        isSelected: _currentIndex == 3,
                        accent: accent,
                        unselected: unselected,
                        onTap: () => _onTabSelected(3),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: isDark ? 'Beralih ke Tema Terang' : 'Beralih ke Tema Gelap',
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: unselected,
                          size: 20,
                        ),
                        onPressed: () {
                          AppConfig.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                        },
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
            extendBody: true,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                  top: BorderSide(
                    color: border,
                    width: 0.8,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      Expanded(
                        child: _GoogleNavBarItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: AppCopy.navHome,
                          isSelected: _currentIndex == 0,
                          onTap: () => _onTabSelected(0),
                        ),
                      ),
                      Expanded(
                        child: _GoogleNavBarItem(
                          icon: Icons.auto_awesome_outlined,
                          activeIcon: Icons.auto_awesome_rounded,
                          label: AppCopy.navStudies,
                          isSelected: _currentIndex == 1,
                          onTap: () => _onTabSelected(1),
                        ),
                      ),
                      Expanded(
                        child: _GoogleNavBarItem(
                          icon: Icons.edit_note_rounded,
                          activeIcon: Icons.edit_note_rounded,
                          label: AppCopy.navSaved,
                          isSelected: _currentIndex == 2,
                          onTap: () => _onTabSelected(2),
                        ),
                      ),
                      Expanded(
                        child: _GoogleNavBarItem(
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings_rounded,
                          label: AppCopy.navSettings,
                          isSelected: _currentIndex == 3,
                          onTap: () => _onTabSelected(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                final activeController = sessionManager.activeTab?.webController;
                if (activeController != null && await activeController.canGoBack()) {
                  await activeController.goBack();
                  return;
                }
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
                baseScaffold,

                // 2. Ruang AI Multi-Tab (Instant zero-glitch display dengan retensi memori penuh)
                Positioned.fill(
                  child: Visibility(
                    visible: sessionManager.isOpen,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: child!,
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

class _GoogleNavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoogleNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : const Color(0xFF18181B);
    final activeFg = isDark ? const Color(0xFF18181B) : Colors.white;
    final unselected = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final labelColor = isSelected
        ? (isDark ? Colors.white : const Color(0xFF18181B))
        : unselected;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeFg : unselected,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.1,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color accent;
  final Color unselected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.unselected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : const Color(0xFF18181B);
    final activeFg = isDark ? const Color(0xFF18181B) : Colors.white;

    return InkWell(
      onTap: () {
        OTMotion.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: OTMotion.normal,
              curve: OTMotion.curve,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.95,
                duration: OTMotion.normal,
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeFg : unselected,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: OTTypography.captionMedium(
                color: isSelected ? (isDark ? Colors.white : const Color(0xFF18181B)) : unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
