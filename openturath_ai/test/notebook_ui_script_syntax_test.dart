import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/notebook_ui_script.dart';

void main() {
  test('notebookUiScript defines valid wrapper and exports otNotebook', () {
    expect(notebookUiScript.isNotEmpty, isTrue);
    expect(notebookUiScript.contains('window.otNotebook = {'), isTrue);
    expect(notebookUiScript.contains('ready,'), isTrue);
    expect(notebookUiScript.contains('inputReady,'), isTrue);
    expect(notebookUiScript.contains('clean,'), isTrue);
  });

  test('notebookUiScript has valid JavaScript syntax via node -c', () async {
    final tempDir = await Directory.systemTemp.createTemp('ot_script_test');
    final tempFile = File('${tempDir.path}/test_script.js');
    await tempFile.writeAsString(notebookUiScript);

    try {
      final result = await Process.run('node', ['-c', tempFile.path]);
      expect(
        result.exitCode,
        equals(0),
        reason: 'JavaScript Syntax Error: ${result.stderr}',
      );
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
