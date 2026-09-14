import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_engine_provider.dart';
import '../../core/i18n/translations.dart';
import '../theme/ot_colors.dart';
import '../theme/ot_typography.dart';
import '../theme/ot_spacing.dart';
import '../theme/ot_radius.dart';
import '../theme/ot_motion.dart';
import '../widgets/apple_interactive_wrapper.dart';

/// OpenTurath Settings Bottom Sheet — Pengaturan dengan Design Engine Switcher
class OTSettingsSheet extends ConsumerWidget {
  final VoidCallback onClose;

  const OTSettingsSheet({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPreferencesProvider);
    final prefsNotifier = ref.read(appPreferencesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = prefs.languageCode;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {}, // Prevent close on sheet tap
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: OTMotion.sheet,
              curve: OTMotion.defaultCurve,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: OTColors.canvas(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(OTRadius.sheet),
                ),
                border: Border(
                  top: BorderSide(
                    color: OTColors.border(isDark),
                    width: 0.8,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    OTSpacing.lg, OTSpacing.md, OTSpacing.lg, OTSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: OTColors.textTertiary(isDark).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.lg),

                      // Title
                      Text(
                        KamusTranslations.tr('settings', lang),
                        style: OTTypography.screenTitle(
                          color: OTColors.textPrimary(isDark),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.xl),

                      // ── Theme Selection ──
                      Text(
                        KamusTranslations.tr('theme', lang).toUpperCase(),
                        style: OTTypography.sectionHeading(
                          color: OTColors.textTertiary(isDark),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.md),
                      _SegmentedPicker<ThemeMode>(
                        isDark: isDark,
                        options: [
                          _PickerOption(ThemeMode.system, KamusTranslations.tr('system', lang)),
                          _PickerOption(ThemeMode.light, KamusTranslations.tr('light', lang)),
                          _PickerOption(ThemeMode.dark, KamusTranslations.tr('dark', lang)),
                        ],
                        selected: prefs.themeMode,
                        onChanged: (mode) => prefsNotifier.setThemeMode(mode),
                      ),
                      const SizedBox(height: OTSpacing.xl),

                      // ── Language Selection ──
                      Text(
                        KamusTranslations.tr('language', lang).toUpperCase(),
                        style: OTTypography.sectionHeading(
                          color: OTColors.textTertiary(isDark),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.md),
                      _SegmentedPicker<String>(
                        isDark: isDark,
                        options: [
                          _PickerOption('id', 'Indonesia'),
                          _PickerOption('ar', 'العربية'),
                          _PickerOption('en', 'English'),
                        ],
                        selected: prefs.languageCode,
                        onChanged: (code) => prefsNotifier.setLanguage(code),
                      ),
                      const SizedBox(height: OTSpacing.xl),

                      // ── Design Engine Switcher ──
                      Divider(color: OTColors.border(isDark)),
                      const SizedBox(height: OTSpacing.lg),
                      Text(
                        KamusTranslations.tr('designEngine', lang).toUpperCase(),
                        style: OTTypography.sectionHeading(
                          color: OTColors.textTertiary(isDark),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.md),
                      AppleInteractiveWrapper(
                        onTap: () {
                          prefsNotifier.toggleEngine();
                          onClose();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(OTSpacing.base),
                          decoration: BoxDecoration(
                            color: OTColors.surface(isDark),
                            borderRadius: BorderRadius.circular(OTRadius.card),
                            border: Border.all(
                              color: OTColors.border(isDark),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.palette_outlined,
                                size: 20,
                                color: OTColors.sovereignAmber,
                              ),
                              const SizedBox(width: OTSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prefs.engineVariant == AppEngineVariant.openTurath
                                          ? KamusTranslations.tr('switchToClassic', lang)
                                          : KamusTranslations.tr('switchToOpenTurath', lang),
                                      style: OTTypography.bodyMedium(
                                        color: OTColors.textPrimary(isDark),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      prefs.engineVariant == AppEngineVariant.openTurath
                                          ? 'Classic Liquid Glass'
                                          : 'Quiet Scholar Edition',
                                      style: OTTypography.caption(
                                        color: OTColors.textTertiary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.swap_horiz,
                                size: 20,
                                color: OTColors.textTertiary(isDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: OTSpacing.xl),

                      // ── Send Feedback ──
                      AppleInteractiveWrapper(
                        onTap: () {
                          // TODO: Open email intent
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: OTSpacing.base,
                            vertical: OTSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: OTColors.surface(isDark),
                            borderRadius: BorderRadius.circular(OTRadius.card),
                            border: Border.all(
                              color: OTColors.border(isDark),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mail_outline,
                                size: 20,
                                color: OTColors.textSecondary(isDark),
                              ),
                              const SizedBox(width: OTSpacing.md),
                              Text(
                                KamusTranslations.tr('sendFeedback', lang),
                                style: OTTypography.bodyMedium(
                                  color: OTColors.textPrimary(isDark),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

/// Helper model for picker options
class _PickerOption<T> {
  final T value;
  final String label;
  const _PickerOption(this.value, this.label);
}

/// Segmented control picker — scholarly monokrom style
class _SegmentedPicker<T> extends StatelessWidget {
  final bool isDark;
  final List<_PickerOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const _SegmentedPicker({
    required this.isDark,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: OTColors.surfaceSubtle(isDark),
        borderRadius: BorderRadius.circular(OTRadius.inputField),
        border: Border.all(
          color: OTColors.border(isDark),
          width: 0.8,
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.value),
              child: AnimatedContainer(
                duration: OTMotion.micro,
                curve: OTMotion.defaultCurve,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? OTColors.surface(isDark) : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opt.label,
                    style: OTTypography.captionMedium(
                      color: isSelected
                          ? OTColors.textPrimary(isDark)
                          : OTColors.textTertiary(isDark),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
