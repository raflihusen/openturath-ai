import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_config.dart';
import '../core/theme.dart';
import '../models/field_model.dart';
import 'dashboard_screen.dart';
import 'specialist_list_screen.dart';
import 'bookmark_screen.dart';
import 'profile_screen.dart';
import '../widgets/openturath_brand.dart';

class MainShellController extends InheritedWidget {
  final void Function(int index, {String? fieldId}) switchTab;

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
  String? _selectedFieldId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index, {String? fieldId}) {
    setState(() {
      _currentIndex = index;
      _selectedFieldId = fieldId;
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
      SpecialistListScreen(key: ValueKey(_selectedFieldId), field: field),
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

    return MainShellController(
      switchTab: _onTabSelected,
      child: PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: isWideScreen
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
                            label: 'Beranda',
                            isSelected: _currentIndex == 0,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(0),
                          ),
                          const SizedBox(height: 16),
                          _RailItem(
                            icon: Icons.menu_book_outlined,
                            activeIcon: Icons.menu_book_rounded,
                            label: 'Keilmuan',
                            isSelected: _currentIndex == 1,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(1),
                          ),
                          const SizedBox(height: 16),
                          _RailItem(
                            icon: Icons.collections_bookmark_outlined,
                            activeIcon: Icons.collections_bookmark_rounded,
                            label: 'Rujukan',
                            isSelected: _currentIndex == 2,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(2),
                          ),
                          const SizedBox(height: 16),
                          _RailItem(
                            icon: Icons.person_outline_rounded,
                            activeIcon: Icons.person_rounded,
                            label: 'Profil',
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
                      child: IndexedStack(
                        index: _currentIndex,
                        children: screens,
                      ),
                    ),
                  ],
                ),
              )
            : Scaffold(
                backgroundColor: canvas,
                body: IndexedStack(
                  index: _currentIndex,
                  children: screens,
                ),
                extendBody: true,
                bottomNavigationBar: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.navBarDark : AppTheme.navBarLight,
                        border: Border(
                          top: BorderSide(
                            color: isDark ? AppTheme.navBarBorderDark : AppTheme.navBarBorderLight,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          height: 60,
                          child: Row(
                            children: [
                              Expanded(
                                child: _ExpressiveNavItem(
                                  icon: Icons.home_outlined,
                                  activeIcon: Icons.home_rounded,
                                  label: 'Beranda',
                                  isSelected: _currentIndex == 0,
                                  accent: accent,
                                  unselected: unselected,
                                  onTap: () => _onTabSelected(0),
                                ),
                              ),
                              Expanded(
                                child: _ExpressiveNavItem(
                                  icon: Icons.menu_book_outlined,
                                  activeIcon: Icons.menu_book_rounded,
                                  label: 'Keilmuan',
                                  isSelected: _currentIndex == 1,
                                  accent: accent,
                                  unselected: unselected,
                                  onTap: () => _onTabSelected(1),
                                ),
                              ),
                              Expanded(
                                child: _ExpressiveNavItem(
                                  icon: Icons.collections_bookmark_outlined,
                                  activeIcon: Icons.collections_bookmark_rounded,
                                  label: 'Rujukan',
                                  isSelected: _currentIndex == 2,
                                  accent: accent,
                                  unselected: unselected,
                                  onTap: () => _onTabSelected(2),
                                ),
                              ),
                              Expanded(
                                child: _ExpressiveNavItem(
                                  icon: Icons.person_outline_rounded,
                                  activeIcon: Icons.person_rounded,
                                  label: 'Profil',
                                  isSelected: _currentIndex == 3,
                                  accent: accent,
                                  unselected: unselected,
                                  onTap: () => _onTabSelected(3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ExpressiveNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color accent;
  final Color unselected;
  final VoidCallback onTap;

  const _ExpressiveNavItem({
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
    final activeColor = isDark ? Colors.white : const Color(0xFF18181B);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : unselected,
                size: 21,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.1,
                color: isSelected ? activeColor : unselected,
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
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.05 : 0.94,
                duration: const Duration(milliseconds: 220),
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
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? (isDark ? Colors.white : const Color(0xFF18181B)) : unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
