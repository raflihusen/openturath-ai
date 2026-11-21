import '../models/bookmark_model.dart';

String noteClipboardText(BookmarkModel item) {
  final title = item.title.trim();
  final body = item.fullAnswer.trim().isNotEmpty
      ? item.fullAnswer.trim()
      : item.arabicExcerpt.trim();
  final citations = item.citations
      .map((c) => c.display.trim())
      .where((c) => c.isNotEmpty)
      .toList();

  final buffer = StringBuffer();
  if (title.isNotEmpty) {
    buffer.write('# $title');
    if (body.isNotEmpty) buffer.write('\n\n');
  }
  if (body.isNotEmpty) {
    buffer.write(body);
  }
  if (citations.isNotEmpty) {
    if (buffer.isNotEmpty) buffer.write('\n\n');
    buffer.write(citations.map((c) => '— $c').join('\n'));
  }
  return buffer.toString().trim();
}
