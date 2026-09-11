import 'package:flutter/material.dart';
import '../models/agent_model.dart';

/// Reusable SegmentedButton control to toggle between [CorpusKind.discipline] (Bidang Ilmu)
/// and [CorpusKind.scholar] (Korpus Ulama).
class CorpusKindControl extends StatelessWidget {
  const CorpusKindControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CorpusKind value;
  final ValueChanged<CorpusKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
        return SegmentedButton<CorpusKind>(
          direction: constraints.maxWidth < 340 || largeText
              ? Axis.vertical
              : Axis.horizontal,
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: true,
          segments: const [
            ButtonSegment(
              value: CorpusKind.discipline,
              label: Text('Bidang Ilmu'),
              icon: Icon(Icons.category_outlined, size: 18),
            ),
            ButtonSegment(
              value: CorpusKind.scholar,
              label: Text('Korpus Ulama'),
              icon: Icon(Icons.person_outline_rounded, size: 18),
            ),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.single),
          style: SegmentedButton.styleFrom(
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        );
      },
    );
  }
}
