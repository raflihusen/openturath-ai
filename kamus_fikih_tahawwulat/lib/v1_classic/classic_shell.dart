import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/term_model.dart';
import '../core/providers/kamus_providers.dart';
import '../core/providers/app_engine_provider.dart';
import '../core/i18n/translations.dart';
import 'widgets/tahoe_wave_background.dart';
import 'widgets/glass_panel.dart';
import 'widgets/confetti_overlay.dart';
import 'views/classic_home_view.dart';
import 'views/classic_all_terms_view.dart';
import 'views/classic_term_detail_view.dart';
import 'views/classic_history_view.dart';
import 'views/classic_favorites_view.dart';
import 'modals/classic_search_modal.dart';
import 'modals/classic_settings_modal.dart';
import 'modals/classic_appreciation_modal.dart';
import 'modals/classic_share_modal.dart';
import 'modals/classic_ai_summary_modal.dart';

class ClassicShell extends ConsumerStatefulWidget {
  const ClassicShell({super.key});

  @override
  ConsumerState<ClassicShell> createState() => _ClassicShellState();
}

class _ClassicShellState extends ConsumerState<ClassicShell> {
  int _activeNavIndex = 0; // 0: Home, 1: List, 2: History, 3: Favorites
  Term? _selectedTerm;

  // Active modal state
  bool _showSearch = false;
  bool _showSettings = false;
  bool _showAppreciation = false;
  bool _showAiSummary = false;
  MapEntry<Term, Definition>? _shareTarget;
  String? _confettiMessage;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider);
    final allTermsAsync = ref.watch(allTermsProvider);
    final history = ref.watch(historyProvider);
    final favorites = ref.watch(favoritesProvider);
    final lang = prefs.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TahoeWaveBackground(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Main Column: Header + Body Content
              Column(
                children: [
                  // Header (Search Button, Glass Title Pill, Settings Button)
                  if (_selectedTerm == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, size: 24),
                            onPressed: () => setState(() => _showSearch = true),
                          ),
                          Expanded(
                            child: Center(
                              child: GlassPanel(
                                isThick: true,
                                borderRadius: 999,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Text(
                                  KamusTranslations.tr('appName', lang),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, size: 24),
                            onPressed: () => setState(() => _showSettings = true),
                          ),
                        ],
                      ),
                    ),

                  // Body Content
                  Expanded(
                    child: allTermsAsync.when(
                      data: (terms) {
                        if (_selectedTerm != null) {
                          return ClassicTermDetailView(
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
                            return ClassicHomeView(
                              terms: terms,
                              langCode: lang,
                              onSelectTerm: _handleSelectTerm,
                            );
                          case 1:
                            return ClassicAllTermsView(
                              terms: terms,
                              langCode: lang,
                              onSelectTerm: _handleSelectTerm,
                            );
                          case 2:
                            return ClassicHistoryView(
                              historyIds: history,
                              allTerms: terms,
                              langCode: lang,
                              onSelectTerm: _handleSelectTerm,
                            );
                          case 3:
                            return ClassicFavoritesView(
                              favoriteUids: favorites,
                              allTerms: terms,
                              langCode: lang,
                              onSelectTerm: _handleSelectTerm,
                            );
                          default:
                            return ClassicHomeView(
                              terms: terms,
                              langCode: lang,
                              onSelectTerm: _handleSelectTerm,
                            );
                        }
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error loading: $err')),
                    ),
                  ),

                  // Reserve space for floating bottom navigation bar
                  if (_selectedTerm == null) const SizedBox(height: 72),
                ],
              ),

              // Floating Bottom Navigation Bar
              if (_selectedTerm == null)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  child: GlassPanel(
                    isThick: true,
                    borderRadius: 999,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home_outlined, Icons.home, KamusTranslations.tr('home', lang)),
                        _buildNavItem(1, Icons.format_list_bulleted, Icons.format_list_bulleted, KamusTranslations.tr('list', lang)),
                        _buildNavItem(2, Icons.access_time, Icons.access_time_filled, KamusTranslations.tr('history', lang)),
                        _buildNavItem(3, Icons.favorite_border, Icons.favorite, KamusTranslations.tr('favorites', lang)),
                      ],
                    ),
                  ),
                ),

              // Modals & Overlays
              if (_showSearch)
                allTermsAsync.maybeWhen(
                  data: (terms) => ClassicSearchModal(
                    langCode: lang,
                    onSelectTerm: _handleSelectTerm,
                    onClose: () => setState(() => _showSearch = false),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),

              if (_showSettings)
                ClassicSettingsModal(
                  onClose: () => setState(() => _showSettings = false),
                  onOpenAppreciation: () => setState(() => _showAppreciation = true),
                ),

              if (_showAppreciation)
                ClassicAppreciationModal(
                  langCode: lang,
                  onClose: () => setState(() => _showAppreciation = false),
                  onTriggerConfetti: () {
                    setState(() {
                      _confettiMessage = KamusTranslations.tr('danaCopiedMessage', lang);
                    });
                  },
                ),

              if (_shareTarget != null)
                ClassicShareModal(
                  term: _shareTarget!.key,
                  definition: _shareTarget!.value,
                  langCode: lang,
                  onClose: () => setState(() => _shareTarget = null),
                ),

              if (_showAiSummary && _selectedTerm != null)
                ClassicAiSummaryModal(
                  term: _selectedTerm!,
                  langCode: lang,
                  onClose: () => setState(() => _showAiSummary = false),
                ),

              if (_confettiMessage != null)
                ConfettiCelebrationOverlay(
                  message: _confettiMessage!,
                  onDismiss: () => setState(() => _confettiMessage = null),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _activeNavIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        setState(() {
          _activeNavIndex = index;
          _selectedTerm = null;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? activeColor : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelectTerm(Term term) {
    ref.read(historyProvider.notifier).addTerm(term.id);
    setState(() {
      _selectedTerm = term;
      _showSearch = false;
    });
  }
}
