import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/term_model.dart';
import '../core/providers/kamus_providers.dart';
import '../core/providers/app_engine_provider.dart';
import '../core/i18n/translations.dart';
import 'theme/ot_colors.dart';
import 'theme/ot_typography.dart';
import 'theme/ot_spacing.dart';
import 'theme/ot_radius.dart';
import 'theme/ot_motion.dart';
import 'views/ot_home_screen.dart';
import 'views/ot_catalog_screen.dart';
import 'views/ot_detail_screen.dart';
import 'views/ot_history_screen.dart';
import 'views/ot_bookmarks_screen.dart';
import 'modals/ot_settings_sheet.dart';
import 'modals/ot_ai_summary_sheet.dart';
import 'modals/ot_share_sheet.dart';

/// OpenTurath Shell — Navigator utama Quiet Scholar Edition
/// Bottom nav pill monokrom + header minimalis
class OTShell extends ConsumerStatefulWidget {
  const OTShell({super.key});

  @override
  ConsumerState<OTShell> createState() => _OTShellState();
}

class _OTShellState extends ConsumerState<OTShell> {
  int _activeNavIndex = 0;
  Term? _selectedTerm;

  // Modal state
  bool _showSettings = false;
  bool _showAiSummary = false;
  MapEntry<Term, Definition>? _shareTarget;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider);
    final allTermsAsync = ref.watch(allTermsProvider);
    final history = ref.watch(historyProvider);
    final favorites = ref.watch(favoritesProvider);
    final lang = prefs.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: OTColors.canvas(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Header: Scholarly Wordmark + Settings ──
                if (_selectedTerm == null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      OTSpacing.lg, OTSpacing.sm, OTSpacing.lg, OTSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        // Wordmark
                        Expanded(
                          child: Text(
                            'OpenTurath',
                            style: OTTypography.brandWordmark(
                              color: OTColors.textPrimary(isDark),
                            ),
                          ),
                        ),
                        // Settings icon
                        GestureDetector(
                          onTap: () => setState(() => _showSettings = true),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: OTColors.surfaceSubtle(isDark),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: OTColors.border(isDark),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              Icons.tune,
                              size: 18,
                              color: OTColors.textSecondary(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Body Content ──
                Expanded(
                  child: allTermsAsync.when(
                    data: (terms) {
                      if (_selectedTerm != null) {
                        return OTDetailScreen(
                          term: _selectedTerm!,
                          langCode: lang,
                          onBack: () => setState(() => _selectedTerm = null),
                          onShare: (term, def) {
                            setState(() => _shareTarget = MapEntry(term, def));
                          },
                          onAiSummary: () => setState(() => _showAiSummary = true),
                        );
                      }

                      switch (_activeNavIndex) {
                        case 0:
                          return OTHomeScreen(
                            terms: terms,
                            langCode: lang,
                            onSelectTerm: _handleSelectTerm,
                          );
                        case 1:
                          return OTCatalogScreen(
                            terms: terms,
                            langCode: lang,
                            onSelectTerm: _handleSelectTerm,
                          );
                        case 2:
                          return OTHistoryScreen(
                            historyIds: history,
                            allTerms: terms,
                            langCode: lang,
                            onSelectTerm: _handleSelectTerm,
                          );
                        case 3:
                          return OTBookmarksScreen(
                            favoriteUids: favorites,
                            allTerms: terms,
                            langCode: lang,
                            onSelectTerm: _handleSelectTerm,
                          );
                        default:
                          return OTHomeScreen(
                            terms: terms,
                            langCode: lang,
                            onSelectTerm: _handleSelectTerm,
                          );
                      }
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (err, _) => Center(
                      child: Text('Error: $err'),
                    ),
                  ),
                ),

                // Bottom nav spacer
                if (_selectedTerm == null) const SizedBox(height: 72),
              ],
            ),

            // ── Floating Bottom Navigation Bar (Monochrome Pill) ──
            if (_selectedTerm == null)
              Positioned(
                left: OTSpacing.lg,
                right: OTSpacing.lg,
                bottom: OTSpacing.base,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: OTSpacing.sm,
                    vertical: OTSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: OTColors.surface(isDark),
                    borderRadius: BorderRadius.circular(OTRadius.pill),
                    border: Border.all(
                      color: OTColors.border(isDark),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_outlined, Icons.home,
                          KamusTranslations.tr('home', lang), isDark),
                      _buildNavItem(1, Icons.format_list_bulleted, Icons.format_list_bulleted,
                          KamusTranslations.tr('list', lang), isDark),
                      _buildNavItem(2, Icons.schedule_outlined, Icons.schedule,
                          KamusTranslations.tr('history', lang), isDark),
                      _buildNavItem(3, Icons.bookmark_border, Icons.bookmark,
                          KamusTranslations.tr('favorites', lang), isDark),
                    ],
                  ),
                ),
              ),

            // ── Modals Layer ──
            if (_showSettings)
              OTSettingsSheet(
                onClose: () => setState(() => _showSettings = false),
              ),

            if (_shareTarget != null)
              OTShareSheet(
                term: _shareTarget!.key,
                definition: _shareTarget!.value,
                langCode: lang,
                onClose: () => setState(() => _shareTarget = null),
              ),

            if (_showAiSummary && _selectedTerm != null)
              OTAiSummarySheet(
                term: _selectedTerm!,
                langCode: lang,
                onClose: () => setState(() => _showAiSummary = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = _activeNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeNavIndex = index;
          _selectedTerm = null;
        });
      },
      child: AnimatedContainer(
        duration: OTMotion.micro,
        curve: OTMotion.defaultCurve,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? OTColors.surfaceSubtle(isDark) : Colors.transparent,
          borderRadius: BorderRadius.circular(OTRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected
                  ? OTColors.textPrimary(isDark)
                  : OTColors.textTertiary(isDark),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: OTTypography.captionMedium(
                  color: OTColors.textPrimary(isDark),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSelectTerm(Term term) {
    ref.read(historyProvider.notifier).addTerm(term.id);
    setState(() {
      _selectedTerm = term;
    });
  }
}
