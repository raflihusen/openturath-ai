import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/widgets/adaptive_sheet.dart';
import 'package:openturath_ai/widgets/desktop_shortcuts.dart';
import 'package:openturath_ai/widgets/apple_interactive_wrapper.dart';

void main() {
  for (final platform in [TargetPlatform.windows, TargetPlatform.macOS]) {
    testWidgets('Search shortcut and Escape work with focused text input on $platform', (tester) async {
      final focus = FocusNode();
      final controller = TextEditingController();
      addTearDown(focus.dispose); addTearDown(controller.dispose);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: DesktopShortcuts(
        onFind: focus.requestFocus,
        onEscape: () { controller.clear(); focus.unfocus(); },
        child: TextField(focusNode: focus, controller: controller),
      ))));
      final modifier = platform == TargetPlatform.macOS ? LogicalKeyboardKey.metaLeft : LogicalKeyboardKey.controlLeft;
      await tester.sendKeyDownEvent(modifier);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(modifier);
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await tester.enterText(find.byType(TextField), 'fikih');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(focus.hasFocus, isFalse);
    }, variant: TargetPlatformVariant({platform}));
  }
  for (final size in [const Size(860, 600), const Size(1920, 1080)]) {
    testWidgets('Desktop sheet stays centered, bounded and scrollable at $size', (tester) async {
      tester.view.physicalSize = size; tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (context) => TextButton(
        onPressed: () => showAdaptiveSheet<void>(context: context, isScrollControlled: true,
          builder: (_) => ListView(children: List.generate(100, (i) => ListTile(title: Text('Kitab $i'))))),
        child: const Text('Buka'),
      )))));
      await tester.tap(find.text('Buka')); await tester.pumpAndSettle();
      final box = tester.getRect(find.byType(Dialog));
      // Dialog render box includes inset padding, so measure its content separately.
      final list = tester.getRect(find.byType(ListView));
      expect(list.width, lessThanOrEqualTo(560));
      expect(list.center.dx, closeTo(size.width / 2, 1));
      expect(box.height, lessThanOrEqualTo(size.height));
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
  }
  testWidgets('Interactive cards support keyboard activation', (tester) async {
    var activations = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppleInteractiveWrapper(
      onTap: () => activations++, child: const Text('Kitab'),
    ))));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab); await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter); await tester.pump();
    expect(activations, 1);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));
}
