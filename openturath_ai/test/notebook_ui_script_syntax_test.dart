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

  test('notebookUiScript preserves message selectors and excludes composer from questions', () {
    // questionSelector should NOT loosely match [class*="query" i] or [class*="prompt" i]
    // because that matches .query-box-container and textarea
    expect(notebookUiScript.contains(r'[class*="query" i], [class*="prompt" i]'), isFalse);
    expect(notebookUiScript.contains(r'[class*="user-query" i]'), isTrue);
    expect(notebookUiScript.contains(r'[class*="user-prompt" i]'), isTrue);

    // ensureStyles should NOT hide chat-intro or conversation-intro
    expect(notebookUiScript.contains('app-chat-intro'), isFalse);
    expect(notebookUiScript.contains('app-conversation-intro'), isFalse);
    expect(notebookUiScript.contains('.chat-intro'), isFalse);
    expect(notebookUiScript.contains('.conversation-intro'), isFalse);

    // message containers must maintain display block and visibility
    expect(notebookUiScript.contains('.chat-message, .model-message, .user-message'), isTrue);
    expect(notebookUiScript.contains('display: block !important;'), isTrue);
    expect(notebookUiScript.contains('visibility: visible !important;'), isTrue);
  });
}
