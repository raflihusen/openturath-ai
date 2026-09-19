import '../models/bookmark_model.dart';
import 'bookmark_content.dart';

/// Localizes UI fallbacks, never text supplied in a note or source passage.
/// Old personal notes have no generated-title provenance; their saved titles
/// therefore remain verbatim, even when they happen to match a fallback label.
String noteDisplayTitle(BookmarkModel item, {
  required String untitled,
  required String Function(String) translateLabel,
}) {
  if (item.documentKind != BookmarkDocumentKind.aiAnswer) {
    return item.title.trim().isEmpty ? untitled : item.title;
  }
  final title = aiAnswerTitle(item.fullAnswer, item.agentTitle);
  if (title.trim().isEmpty) return untitled;
  const generatedFallbacks = {'Kajian tanpa judul', 'Catatan Kajian'};
  if (generatedFallbacks.contains(title) && !item.fullAnswer.contains(title)) {
    return untitled;
  }
  // Empty AI answers can fall back to the system-owned agent label.
  if (item.fullAnswer.trim().isEmpty && title != item.title) {
    return translateLabel(title);
  }
  return title;
}
