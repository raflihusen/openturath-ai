import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/design/ot_layout.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../core/design/ot_typography.dart';

class OTPageHeader extends StatelessWidget {
  const OTPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: OTTypography.pageTitle(
                      color: OTColors.textPrimary(dark))),
              if (subtitle case final subtitle?) ...[
                const SizedBox(height: OTSpacing.xs),
                Text(
                  subtitle,
                  style: OTTypography.body(color: OTColors.textSecondary(dark)),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: OTSpacing.base),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: OTLayout.minimumTouchTarget,
              minHeight: OTLayout.minimumTouchTarget,
            ),
            child: trailing,
          ),
        ],
      ],
    );
  }
}

/// A native grouped surface. Use this for related controls or rows, never as a
/// decorative frame around a single piece of text.
class OTGroupedSection extends StatelessWidget {
  const OTGroupedSection({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: OTRadius.cardBorder,
      child: ColoredBox(
        color: OTColors.surface(dark),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class OTSectionHeader extends StatelessWidget {
  const OTSectionHeader({
    super.key,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: OTTypography.sectionTitle(
                      color: OTColors.textPrimary(dark))),
              if (description case final description?) ...[
                const SizedBox(height: OTSpacing.xs),
                Text(description,
                    style: OTTypography.caption(
                        color: OTColors.textSecondary(dark))),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 44),
              padding: const EdgeInsets.symmetric(horizontal: OTSpacing.sm),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class OTSearchField extends StatelessWidget {
  const OTSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: OTTypography.body(color: OTColors.textPrimary(dark)),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: OTColors.surfaceSubtle(dark),
            prefixIcon: const Icon(Icons.search_rounded, size: 21),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus pencarian',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(Icons.close_rounded, size: 19),
                  ),
          ),
        );
      },
    );
  }
}

class OTEditorialRow extends StatelessWidget {
  const OTEditorialRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const border = OTColors.borderSubtleLight;
    final row = InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: OTLayout.minimumTouchTarget),
        child: Padding(
          padding: contentPadding ??
              const EdgeInsets.symmetric(vertical: OTSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: OTSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.cardTitle(
                            color: OTColors.textPrimary(dark))),
                    if (subtitle case final subtitle?) ...[
                      const SizedBox(height: OTSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OTTypography.caption(
                            color: OTColors.textSecondary(dark)),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: OTSpacing.md),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: OTSpacing.sm),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: OTColors.textTertiary(dark)),
              ],
            ],
          ),
        ),
      ),
    );

    if (!showDivider) return row;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark ? OTColors.borderSubtleDark : border,
            width: 0.7,
          ),
        ),
      ),
      child: row,
    );
  }
}

class OTEmptyState extends StatelessWidget {
  const OTEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: OTSpacing.xl,
            vertical: OTSpacing.huge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: OTColors.textSecondary(dark)),
              const SizedBox(height: OTSpacing.base),
              Text(
                title,
                textAlign: TextAlign.center,
                style: OTTypography.sectionTitle(
                    color: OTColors.textPrimary(dark)),
              ),
              const SizedBox(height: OTSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: OTTypography.body(color: OTColors.textSecondary(dark)),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: OTSpacing.xl),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class OTStatusPill extends StatelessWidget {
  const OTStatusPill({
    super.key,
    required this.label,
    this.icon,
    this.emphasized = false,
  });

  final String label;
  final IconData? icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground =
        emphasized ? OTColors.onAccent(dark) : OTColors.textSecondary(dark);
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            emphasized ? OTColors.accent(dark) : OTColors.surfaceSubtle(dark),
        borderRadius: OTRadius.chipBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: OTSpacing.md,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: OTSpacing.xs),
            ],
            Text(label, style: OTTypography.captionMedium(color: foreground)),
          ],
        ),
      ),
    );
  }
}
