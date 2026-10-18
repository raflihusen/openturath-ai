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

  test(
      'notebookUiScript preserves message selectors and excludes composer from questions',
      () {
    // questionSelector should NOT loosely match [class*="query" i] or [class*="prompt" i]
    // because that matches .query-box-container and textarea
    expect(
        notebookUiScript.contains(r'[class*="query" i], [class*="prompt" i]'),
        isFalse);
    expect(notebookUiScript.contains(r'[class*="user-query" i]'), isTrue);
    expect(notebookUiScript.contains(r'[class*="user-prompt" i]'), isTrue);

    // ensureStyles should NOT hide chat-intro or conversation-intro
    expect(notebookUiScript.contains('app-chat-intro'), isFalse);
    expect(notebookUiScript.contains('app-conversation-intro'), isFalse);
    expect(notebookUiScript.contains('.chat-intro'), isFalse);
    expect(notebookUiScript.contains('.conversation-intro'), isFalse);

    // message containers must maintain display block and visibility
    expect(
        notebookUiScript
            .contains('.chat-message, .model-message, .user-message'),
        isTrue);
    expect(notebookUiScript.contains('display: block !important;'), isTrue);
    expect(
        notebookUiScript.contains('visibility: visible !important;'), isTrue);
  });

  test(
      'notebookUiScript hides guide card, cover, and mobile tablist while keeping chat selected',
      () {
    expect(notebookUiScript.contains('app-notebook-guide'), isTrue);
    expect(notebookUiScript.contains('app-guide-card'), isTrue);
    expect(notebookUiScript.contains('[role="tablist"]'), isTrue);
    expect(notebookUiScript.contains('isSourceCount'), isTrue);
    expect(
        notebookUiScript.contains(
            'target.style.setProperty(\'display\', \'none\', \'important\')'),
        isTrue);
  });

  test(
      'notebookUiScript suppresses standalone plus button and source count pill in chat input',
      () {
    expect(notebookUiScript.contains('button:has(mat-icon[fonticon="add"])'),
        isTrue);
    expect(notebookUiScript.contains('.add-source-button'), isTrue);
    expect(notebookUiScript.contains('isSourceCounter'), isTrue);
    expect(
        notebookUiScript.contains('app-chat-input [class*="source-count" i]'),
        isTrue);
    expect(notebookUiScript.contains('app-chat-input .sources-button'), isTrue);
  });

  test(
      'notebookUiScript docks chat composer naturally via flexbox without fixed positioning clipping',
      () {
    // Composer must dock naturally via position: relative, not fixed floating
    expect(notebookUiScript.contains('position: relative !important;'), isTrue);
    expect(notebookUiScript.contains('position: fixed !important;'), isFalse);
    expect(notebookUiScript.contains('align-self: center !important;'), isTrue);
    expect(
        notebookUiScript.contains('margin-inline: auto !important;'), isTrue);
    expect(notebookUiScript.contains('max-width: 720px !important;'), isTrue);
    expect(notebookUiScript.contains('.ot-chat-composer'), isTrue);
    expect(notebookUiScript.contains('.ot-chat-composer-path'), isTrue);
    expect(notebookUiScript.contains('removeLegacySpacers'), isTrue);
    expect(notebookUiScript.contains('flex: 0 0 auto !important;'), isTrue);
    expect(
        notebookUiScript.contains('padding-bottom: 24px !important;'), isTrue);
  });
}
