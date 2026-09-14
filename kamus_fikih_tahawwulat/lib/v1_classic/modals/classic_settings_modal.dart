import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/translations.dart';
import '../../core/providers/app_engine_provider.dart';
import '../../core/providers/kamus_providers.dart';
import '../widgets/glass_panel.dart';

class ClassicSettingsModal extends ConsumerWidget {
  final VoidCallback onClose;
  final VoidCallback onOpenAppreciation;

  const ClassicSettingsModal({
    super.key,
    required this.onClose,
    required this.onOpenAppreciation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    final statsAsync = ref.watch(statsProvider);
    final lang = prefs.languageCode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassPanel(
        isThick: true,
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    KamusTranslations.tr('settings', lang),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Theme Selector
              Text(
                KamusTranslations.tr('theme', lang),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildThemeOption(context, ref, ThemeMode.system, KamusTranslations.tr('system', lang), prefs.themeMode),
                  const SizedBox(width: 8),
                  _buildThemeOption(context, ref, ThemeMode.light, KamusTranslations.tr('light', lang), prefs.themeMode),
                  const SizedBox(width: 8),
                  _buildThemeOption(context, ref, ThemeMode.dark, KamusTranslations.tr('dark', lang), prefs.themeMode),
                ],
              ),
              const SizedBox(height: 16),

              // Language Selector
              Text(
                KamusTranslations.tr('language', lang),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLangOption(ref, 'id', 'Indonesia', lang),
                  const SizedBox(width: 8),
                  _buildLangOption(ref, 'ar', 'العربية', lang),
                  const SizedBox(width: 8),
                  _buildLangOption(ref, 'en', 'English', lang),
                ],
              ),
              const SizedBox(height: 20),

              // Switch to OpenTurath Engine Banner
              GlassPanel(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFD97706), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Versi 2: OpenTurath Quiet Scholar',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Beralih ke desain adab ilmiah Obsidian & Sovereign Amber',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD97706)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        onPressed: () {
                          ref.read(appPreferencesProvider.notifier).setEngineVariant(AppEngineVariant.openTurath);
                          onClose();
                        },
                        child: const Text(
                          'Aktifkan Desain OpenTurath',
                          style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats & Achievements
              Text(
                KamusTranslations.tr('statsAchievements', lang),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 10),
              statsAsync.when(
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GlassPanel(
                            borderRadius: 12,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  '${stats.termsViewed}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  KamusTranslations.tr('termsViewed', lang),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GlassPanel(
                            borderRadius: 12,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  '${stats.definitionsFavorited}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  KamusTranslations.tr('definitionsFavorited', lang),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...stats.achievements.map((a) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassPanel(
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                a.isUnlocked ? Icons.stars : Icons.lock_outline,
                                color: a.isUnlocked ? Colors.amber : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      KamusTranslations.tr(a.titleKey, lang),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: a.isUnlocked ? null : Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      KamusTranslations.tr(a.descKey, lang),
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${a.currentProgress}/${a.targetProgress}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Support Development Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                icon: const Icon(Icons.coffee, size: 20),
                label: Text(
                  KamusTranslations.tr('supportDevelopment', lang),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  onClose();
                  onOpenAppreciation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, WidgetRef ref, ThemeMode mode, String label, ThemeMode current) {
    final selected = mode == current;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFF2563EB).withOpacity(0.18) : Colors.transparent,
          side: BorderSide(
            color: selected ? const Color(0xFF2563EB) : Colors.grey.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        onPressed: () => ref.read(appPreferencesProvider.notifier).setThemeMode(mode),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLangOption(WidgetRef ref, String code, String label, String current) {
    final selected = code == current;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFF2563EB).withOpacity(0.18) : Colors.transparent,
          side: BorderSide(
            color: selected ? const Color(0xFF2563EB) : Colors.grey.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        onPressed: () => ref.read(appPreferencesProvider.notifier).setLanguage(code),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
