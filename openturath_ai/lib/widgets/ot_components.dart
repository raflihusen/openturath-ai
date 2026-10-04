import 'package:flutter/material.dart';

import '../core/design/ot_motion.dart';

/// Satu-satunya chip pilihan di aplikasi: pil, terpilih berisi tinta.
/// Rupa diatur `chipTheme` di `core/theme.dart`.
class OTChip extends StatelessWidget {
  const OTChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        OTMotion.selection();
        onSelected();
      },
    );
  }
}
