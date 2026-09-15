/// A display-ready representation of an AI response saved to Catatan.
///
/// The full answer is never rewritten here. The parser only derives a stable
/// title and preview so legacy items remain intact.
class ParsedAiAnswerContent {
  final String title;
  final String preview;
  final bool hasFallbackTitle;

  const ParsedAiAnswerContent({
    required this.title,
    required this.preview,
    required this.hasFallbackTitle,
  });
}

ParsedAiAnswerContent parseAiAnswerContent(String answer) {
  final lines = answer.split(RegExp(r'\r?\n'));
  final headingIndex =
      lines.indexWhere((line) => RegExp(r'^\s{0,3}#{1,6}\s+\S').hasMatch(line));
  final hasHeading = headingIndex >= 0;
  final titleIndex = hasHeading
      ? headingIndex
      : lines.indexWhere((line) => _displayLine(line).isNotEmpty);

  if (titleIndex < 0) {
    return const ParsedAiAnswerContent(
      title: 'Kajian tanpa judul',
      preview: '',
      hasFallbackTitle: true,
    );
  }

  final title = _limitTitle(_displayLine(lines[titleIndex]));
  final previewLines = <String>[];
  for (var index = titleIndex + 1; index < lines.length; index++) {
    final line = _displayLine(lines[index]);
    if (line.isNotEmpty) previewLines.add(line);
    if (previewLines.join(' ').length >= 180) break;
  }

  return ParsedAiAnswerContent(
    title: title.isEmpty ? 'Kajian tanpa judul' : title,
    preview: previewLines.join(' '),
    hasFallbackTitle: !hasHeading,
  );
}

String _displayLine(String line) {
  var value = line.trim();
  value = value.replaceFirst(RegExp(r'^#{1,6}\s*'), '');
  value = value.replaceFirst(RegExp(r'^\[[^\]]{1,12}\]\s*'), '');
  value = value.replaceFirst(
      RegExp(r'^(jawaban\s+langsung|jawaban\s+ai)\s*:\s*',
          caseSensitive: false),
      '');
  value = value.replaceAll(RegExp(r'^[>*\-\s]+'), '').trim();
  value = value.replaceAll(RegExp(r'^\*+|\*+$'), '').trim();
  return value;
}

String _limitTitle(String title) {
  if (title.length <= 80) return title;
  final cutoff = title.substring(0, 80);
  final lastSpace = cutoff.lastIndexOf(' ');
  return '${cutoff.substring(0, lastSpace > 40 ? lastSpace : 80).trim()}…';
}

/// Mengubah artefak teknis hasil salin percakapan menjadi Markdown yang
/// nyaman dibaca, tanpa mengubah isi jawaban itu sendiri.
String readableAiAnswerMarkdown(String answer) {
  final lines = answer.split(RegExp(r'\r?\n'));
  final output = <String>[];
  for (final rawLine in lines) {
    final line = rawLine.trimRight();
    if (RegExp(r'^\s*#\s*percakapan\b', caseSensitive: false).hasMatch(line)) {
      continue;
    }
    final question = RegExp(r'^\s*pertanyaan\s*\d*\s*$', caseSensitive: false)
        .hasMatch(line);
    final answerLabel =
        RegExp(r'^\s*jawaban\s*\d*\s*$', caseSensitive: false).hasMatch(line);
    final section =
        RegExp(r'^\s*\[[A-Za-z]\]\s*(.+?)(?:\*+)?\s*$').firstMatch(line);
    if (question) {
      output.add('## Pertanyaan');
    } else if (answerLabel) {
      output.add('## Jawaban');
    } else if (section != null) {
      final label = section.group(1)!.replaceAll(RegExp(r'\*+$'), '').trim();
      output.add('## $label');
    } else {
      output.add(line);
    }
  }
  return output.join('\n').trim();
}

String aiAnswerTitle(String answer, String agentTitle) {
  final parsed = parseAiAnswerContent(answer);
  final raw = parsed.title.toLowerCase();
  if (!raw.contains('percakapan') &&
      !raw.contains('jawaban langsung') &&
      !raw.contains('jawaban ai') &&
      parsed.title.isNotEmpty) {
    return parsed.title;
  }
  final lines = answer.split(RegExp(r'\r?\n'));
  final questionIndex = lines.indexWhere((line) =>
      RegExp(r'^\s*pertanyaan\s*\d*\s*$', caseSensitive: false).hasMatch(line));
  if (questionIndex >= 0) {
    for (var i = questionIndex + 1; i < lines.length; i++) {
      final candidate = _displayLine(lines[i]);
      if (candidate.isNotEmpty) return _limitTitle(candidate);
    }
  }
  return 'Kajian bersama $agentTitle';
}
