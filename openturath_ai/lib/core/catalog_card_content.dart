/// Chooses concise, high-value facts for a catalogue card.
/// Full bibliographic data remains available in the book dossier.
List<String> catalogCardFacts({
  required String? volumes,
  required String? publisher,
  required String? printYear,
  required String? muhaqqiq,
}) {
  bool usable(String? value) {
    final normalized = value?.trim();
    return normalized != null &&
        normalized.isNotEmpty &&
        normalized != '-' &&
        normalized != 'غير مدون' &&
        normalized != 'Tidak dicatat';
  }

  final facts = <String>[
    if (usable(volumes)) volumes!.trim(),
    if (usable(publisher)) publisher!.trim(),
    if (usable(printYear)) printYear!.trim(),
  ];
  if (facts.length < 3 && usable(muhaqqiq)) {
    facts.add('Tahqiq: ${muhaqqiq!.trim()}');
  }
  return facts.take(3).toList(growable: false);
}
