import 'package:flutter/material.dart';

/// Natural-height reading cards: two across when both reading width and text
/// scaling permit it. A large-text reader always receives one full-width card.
int bookReadingColumns(BuildContext context, double width) =>
    width >= 800 && MediaQuery.textScalerOf(context).scale(16) < 24 ? 2 : 1;

Widget bookReadingRow(BuildContext context, int row, int columns, int count,
    IndexedWidgetBuilder builder) {
  final first = row * columns;
  if (columns == 1) return builder(context, first);
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: builder(context, first)),
    const SizedBox(width: 16),
    Expanded(
        child: first + 1 < count
            ? builder(context, first + 1)
            : const SizedBox.shrink()),
  ]);
}
