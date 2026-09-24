import 'package:flutter/material.dart';

import '../core/design/ot_colors.dart';
import '../core/localization.dart';
import '../core/scholarly_fonts.dart';
import '../models/agent_model.dart';

/// A selected assistant's remit and references, with the existing study routes.
class AssistantDossierCard extends StatelessWidget {
  const AssistantDossierCard({
    super.key,
    required this.agent,
    required this.position,
    required this.total,
    required this.onOpen,
    this.onOpenLibrary,
  });

  final AgentModel agent;
  final int position;
  final int total;
  final VoidCallback onOpen;
  final VoidCallback? onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = OTColors.textPrimary(dark);
    final muted = OTColors.textSecondary(dark);
    final accent = OTColors.accent(dark);
    final references = agent.referenceBooks ?? [];
    final scope = agent.subtitleAcademic.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: OTColors.surface(dark),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${position.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
                style: ScholarlyFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: OTColors.primaryContainer(dark),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  agent.isComingSoon
                      ? Loc.tr('comingSoon')
                      : Loc.tr('assistantAvailable'),
                  style: ScholarlyFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: OTColors.onPrimaryContainer(dark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            agent.title,
            style: ScholarlyFonts.newsreader(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
          if (agent.titleArabic.isNotEmpty && !Loc.isArabic) ...[
            const SizedBox(height: 2),
            Text(
              agent.titleArabic,
              textDirection: TextDirection.rtl,
              style: ScholarlyFonts.scheherazadeNew(
                fontSize: 21,
                height: 1.6,
                color: muted,
              ),
            ),
          ],
          if (scope.isNotEmpty &&
              (Loc.language == 'id' || Loc.text(scope) != scope)) ...[
            const SizedBox(height: 9),
            Text(
              scope,
              style: ScholarlyFonts.outfit(
                fontSize: 14,
                height: 1.5,
                color: muted,
              ),
            ),
          ],
          if (references.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(color: OTColors.border(dark), height: 1),
            const SizedBox(height: 15),
            Text(
              Loc.tr('referenceBooks'),
              style: ScholarlyFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: muted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              references
                  .take(2)
                  .map(
                      (b) => b.titleArabic.isNotEmpty ? b.titleArabic : b.title)
                  .join(' · '),
              style: ScholarlyFonts.scheherazadeNew(
                  fontSize: 15, height: 1.85, color: ink),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(Loc.tr('startStudy')),
              ),
              if (onOpenLibrary != null)
                OutlinedButton.icon(
                  onPressed: onOpenLibrary,
                  icon: const Icon(Icons.auto_stories_outlined, size: 18),
                  label: Text(Loc.tr('assistantLibrary')),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
