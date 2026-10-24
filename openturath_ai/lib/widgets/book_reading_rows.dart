import 'package:flutter/material.dart';

/// Kartu baca setinggi baris: dua kolom bila lebar dan skala teks mengizinkan,
/// kedua kartu dalam satu baris selalu sama tinggi. Pembaca dengan teks besar
/// selalu mendapat satu kartu selebar penuh.
int bookReadingColumns(BuildContext context, double width) =>
    width >= 800 && MediaQuery.textScalerOf(context).scale(16) < 24 ? 2 : 1;

Widget bookReadingRow(BuildContext context, int row, int columns, int count,
    IndexedWidgetBuilder builder) {
  final first = row * columns;
  if (columns == 1) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: builder(context, first));
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: builder(context, first)),
        const SizedBox(width: 12),
        Expanded(
            child: first + 1 < count
                ? builder(context, first + 1)
                : const SizedBox.shrink()),
      ]),
    ),
  );
}
