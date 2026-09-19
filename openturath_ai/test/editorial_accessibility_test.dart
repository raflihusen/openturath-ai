import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/editorial.dart';

void main() {
  testWidgets('Primary action is at least 48 high and works using keyboard once', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme,
      home: Scaffold(body: EditorialButton(label: 'Lanjutkan', onPressed: () => calls++))));
    final button = find.byType(EditorialButton);
    expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(calls, 1);
  });

  testWidgets('Arabic paragraph preserves RTL, harakat spacing and normal style', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body:
      EditorialArabicText('إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ'))));
    final finder = find.text('إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ');
    final text = tester.widget<Text>(finder);
    expect(text.style!.fontStyle, FontStyle.normal);
    expect(text.style!.height, greaterThanOrEqualTo(1.85));
    expect(Directionality.of(tester.element(finder)), TextDirection.rtl);
  });

  testWidgets('Narrow page supports 200 percent text and reduced motion', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.darkTheme,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(2), disableAnimations: true), child: child!),
      home: EditorialPage(title: 'Ruang untuk mendalami.', children: [
        EditorialReveal(child: EditorialButton(label: 'Lanjutkan membaca rujukan',
          expanded: true, onPressed: () {})),
        const SizedBox(height: 24),
        const EditorialArabicText('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
      ])));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.widget<FadeTransition>(find.byType(FadeTransition).first).opacity.value, 1);
  });
}
