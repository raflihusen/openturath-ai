import '../models/bookmark_model.dart';

String noteClipboardText(BookmarkModel item) {
  final title = item.title.trim();
  final body = item.fullAnswer.trim();
  if (title.isEmpty) return body;
  if (body.isEmpty) return '# $title';
  return '# $title\n\n$body';
}
