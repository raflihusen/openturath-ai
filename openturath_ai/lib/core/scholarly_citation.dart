/// A citation made only from metadata supplied by the caller. A volume is an
/// actual cited volume, never the number of volumes in a catalogue record.
class ScholarlyCitation {
  const ScholarlyCitation({required this.book, this.author, this.volume,
    this.page, this.appUrl, this.verified = false});
  final String book;
  final String? author, volume, page, appUrl;
  final bool verified;

  String format({String languageCode = 'id'}) {
    final ar = languageCode == 'ar';
    final en = languageCode == 'en';
    final parts = <String>[
      if (book.trim().isNotEmpty) book.trim(),
      if (author?.trim().isNotEmpty == true) author!.trim(),
      if (volume?.trim().isNotEmpty == true)
        '${ar ? 'ج.' : en ? 'vol.' : 'jil.'} ${volume!.trim()}',
      if (page?.trim().isNotEmpty == true)
        '${ar ? 'ص.' : en ? 'p.' : 'hlm.'} ${page!.trim()}',
    ];
    if (parts.isEmpty) return '';
    final status = verified
        ? (ar ? 'مرجع متحقق منه' : en ? 'Verified reference' : 'Rujukan terverifikasi')
        : (ar ? 'مرجع مقدم؛ لم يُتحقق منه' : en ? 'Supplied reference; not verified' : 'Rujukan yang diberikan; belum diverifikasi');
    final uri = Uri.tryParse(appUrl?.trim() ?? '');
    final validUrl = uri != null && uri.scheme == 'https' &&
        uri.host.isNotEmpty && uri.userInfo.isEmpty;
    return '$status: ${parts.join(' · ')}${validUrl ? '\n$uri' : ''}';
  }
}

/// Counts Unicode Arabic/Latin letters by scalar value (runes), not UTF-16
/// units. Combining vowel marks (harakat), tatweel, punctuation, whitespace,
/// digits and symbols are excluded. Arabic letter ranges include Persian and
/// Urdu extensions; presentation ligatures count as one encoded letter.
/// This is a text statistic, not a claim about religious reward.
int countScholarlyLetters(String text) {
  final letters = RegExp(r'[A-Za-z\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02af\u1e00-\u1eff\u0620-\u063f\u0641-\u064a\u066e-\u066f\u0671-\u06d3\u06d5\u06ee-\u06ef\u06fa-\u06fc\u06ff\u0750-\u077f\u08a0-\u08c9\ufb50-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfb\ufe80-\ufefc]', unicode: true);
  return text.runes.where((rune) => letters.hasMatch(String.fromCharCode(rune))).length;
}
