import 'package:flutter/material.dart';
import '../core/app_copy.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_typography.dart';
import '../core/membership_pass_state.dart';

/// Visible account status and subscription entry, independent of settings.
class MembershipControls extends StatelessWidget {
  const MembershipControls({
    super.key,
    required this.summary,
    required this.onSubscribe,
  });

  final MembershipPassSummary summary;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (summary.isOpen)
          Semantics(
            label: '${AppCopy.subscription}: ${summary.badge}',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: OTColors.primaryContainer(isDark),
                borderRadius: OTRadius.inputBorder,
              ),
              child: Text(summary.badge,
                  style: OTTypography.captionMedium(
                      color: OTColors.textPrimary(isDark))),
            ),
          ),
        FilledButton.icon(
          key: const ValueKey('visible-subscription-button'),
          onPressed: onSubscribe,
          icon: const Icon(Icons.card_membership_outlined, size: 20),
          label: Text(AppCopy.subscription),
        ),
      ],
    );
  }
}
