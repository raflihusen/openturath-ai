import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_config.dart';
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
                            icon: Icons.auto_awesome_outlined,
                            activeIcon: Icons.auto_awesome_rounded,
                            label: 'Spesialis',
                            isSelected: _currentIndex == 1,
                            accent: accent,
                            unselected: unselected,
                            onTap: () => _onTabSelected(1),
                          ),
                          const SizedBox(height: 16),
                          _RailItem(
                            icon: Icons.bookmark_border_rounded,
                            activeIcon: Icons.bookmark_rounded,
                            label: 'Bookmark',
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
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ExpressiveNavItem(
                            icon: Icons.home_outlined,
                            activeIcon: Icons.home_rounded,
                            label: 'Beranda',
                            isSelected: _currentIndex == 0,
                            onTap: () => _onTabSelected(0),
                          ),
                          _ExpressiveNavItem(
                            icon: Icons.auto_awesome_outlined,
                            activeIcon: Icons.auto_awesome_rounded,
                            label: 'Spesialis',
                            isSelected: _currentIndex == 1,
                            onTap: () => _onTabSelected(1),
                          ),
                          _ExpressiveNavItem(
                            icon: Icons.bookmark_border_rounded,
                            activeIcon: Icons.bookmark_rounded,
                            label: 'Bookmark',
                            isSelected: _currentIndex == 2,
                            onTap: () => _onTabSelected(2),
                          ),
                          _ExpressiveNavItem(
                            icon: Icons.person_outline_rounded,
                            activeIcon: Icons.person_rounded,
                            label: 'Profil',
                            isSelected: _currentIndex == 3,
                            onTap: () => _onTabSelected(3),
                          ),
                        ],
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
  final VoidCallback onTap;

  const _ExpressiveNavItem({
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

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeFg : unselected,
              size: 21,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: activeFg,
                ),
              ),
            ],
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
