import 'package:flutter/material.dart';
import '../core/design/native_design.dart';
import '../core/localization.dart';

/// Compact resume surface. The collection and persona are separate hierarchy.
class NativeResumeCard extends StatelessWidget {
  const NativeResumeCard(
      {super.key,
      required this.title,
      required this.action,
      required this.onOpen,
      this.onLibrary});
  final String title, action;
  final VoidCallback onOpen;
  final VoidCallback? onLibrary;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final parts = title.split(':');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: NativeColors.surface(dark),
          borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (parts.length > 1) ...[
          Text(parts.first.trim(), style: NativeType.meta(dark)),
          const SizedBox(height: 6),
        ],
        Text(
            parts.length > 1
                ? parts.skip(1).join(':').trim().replaceAll('Al-', 'Al‑')
                : title,
            style: NativeType.title(dark, size: 22)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 4, children: [
          FilledButton(onPressed: onOpen, child: Text(action)),
          if (onLibrary != null)
            TextButton(
                onPressed: onLibrary, child: Text(NativeCopy.text('sources'))),
        ]),
      ]),
    );
  }
}

/// Account identity is information, not a promotional membership hero.
class NativeAccountSummary extends StatelessWidget {
  const NativeAccountSummary(
      {super.key,
      required this.name,
      required this.email,
      required this.status,
      required this.access,
      required this.manageLabel,
      required this.onManage,
      this.expiry,
      this.onAccess,
      this.accessLabel});
  final String name, email, status, access, manageLabel;
  final String? expiry, accessLabel;
  final VoidCallback onManage;
  final VoidCallback? onAccess;
  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: NativeColors.surfaceSubtle(dark),
                    shape: BoxShape.circle),
                child: Icon(Icons.person_outline_rounded,
                    color: NativeColors.textSecondary(dark))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name, style: NativeType.title(dark, size: 21)),
                  const SizedBox(height: 4),
                  Text(email,
                      textDirection: TextDirection.ltr,
                      style: NativeType.meta(dark)),
                ])),
          ]),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 4, children: [
            Text(status,
                style: NativeType.body(dark, size: 15)
                    .copyWith(fontWeight: FontWeight.w600)),
            Text(access, style: NativeType.body(dark, size: 15)),
          ]),
          if (expiry != null) ...[
            const SizedBox(height: 4),
            Text(expiry!, style: NativeType.meta(dark))
          ],
          Wrap(spacing: 8, children: [
            TextButton(onPressed: onManage, child: Text(manageLabel)),
            if (onAccess != null)
              TextButton(onPressed: onAccess, child: Text(accessLabel ?? '')),
          ]),
        ]));
  }
}
