import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('study room opens the NotebookLM WebView unless a prototype is opted in',
      () {
    final source =
        File('lib/widgets/agent_multi_tab_room.dart').readAsStringSync();
    // Prototipe chat native hanya boleh aktif lewat --dart-define eksplisit.
    expect(
        source.contains(
            "bool.fromEnvironment('OPENTURATH_BACKEND_CHAT_PROTOTYPE');"),
        isTrue);
    expect(
        RegExp(r"OPENTURATH_(BACKEND_CHAT_PROTOTYPE|BROWSER_COMPANION)',\s*defaultValue:\s*true")
            .hasMatch(source),
        isFalse);
  });
}
