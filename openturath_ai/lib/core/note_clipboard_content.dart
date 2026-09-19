import 'scholarly_citation.dart';
import '../models/bookmark_model.dart';

/// Export the stored content without manufacturing bibliographic authority.
/// Legacy excerpt-only bookmarks retain their text. With includeSource true,
/// supplied metadata is exported with its verification status. False exports
/// text alone. Null preserves the original verified-only export contract.
String noteClipboardText(BookmarkModel item, {bool? includeSource, String languageCode = 'id'}) {
  final title = item.title.trim();
  final body = item.fullAnswer.trim().isNotEmpty
      ? item.fullAnswer.trim()
      : item.arabicExcerpt.trim();
  final parts = <String>[
    if (title.isNotEmpty) '# $title',
    if (body.isNotEmpty) body,
  ];
  if (includeSource == true && item.bookReference.trim().isNotEmpty) {
    parts.add(ScholarlyCitation(book: item.bookReference, author: item.author,
      volume: item.volume, page: item.pageNumber, appUrl: item.appUrl,
      verified: item.verificationStatus == BookmarkVerificationStatus.verified)
        .format(languageCode: languageCode));
  } else if (includeSource == null && item.verificationStatus == BookmarkVerificationStatus.verified &&
      item.bookReference.trim().isNotEmpty) {
    final citation = <String>[
      item.bookReference.trim(),
      if (item.author?.trim().isNotEmpty == true) item.author!.trim(),
      if (item.pageNumber.trim().isNotEmpty) 'hlm. ${item.pageNumber.trim()}',
    ].join(' · ');
    parts.add('Rujukan: $citation');
  }
  return parts.join('\n\n');
}
