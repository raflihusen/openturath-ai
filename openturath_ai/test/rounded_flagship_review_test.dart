import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/widgets/dual_calendar.dart';
import 'package:openturath_ai/widgets/tahawwulat_hero.dart';
import 'package:openturath_ai/widgets/tahawwulat_diagram.dart';
import 'package:openturath_ai/widgets/app_loader.dart';
Widget frame(Widget child, {bool reduced = false, double scale = 1}) => MaterialApp(
  theme: AppTheme.lightTheme,
  builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: reduced, textScaler: TextScaler.linear(scale)), child: LocaleScope(child: child!)),
  home: Scaffold(body: SingleChildScrollView(child: child)));
void main() {
  setUp(() => AppConfig.localeNotifier.value = 'id');
  testWidgets('calendar changes snapshot and explains calculation', (tester) async {
    await tester.pumpWidget(frame(DualCalendar(date: DateTime(2026,10,7))));
    expect(find.text('Oktober'),findsOneWidget);expect(find.text('7'),findsOneWidget);
    expect(find.text('Hijriah'),findsOneWidget);expect(find.text('Masehi'),findsOneWidget);
    await tester.pumpWidget(frame(DualCalendar(date: DateTime(2026,11,8))));
    expect(find.text('November'),findsOneWidget);expect(find.text('8'),findsOneWidget);
    await tester.tap(find.byTooltip('Metode kalender'));await tester.pumpAndSettle();
    expect(find.textContaining('bukan penetapan rukyat'),findsOneWidget);
  });
  testWidgets('narrow hero with large text keeps its action working', (tester) async {
    tester.view.physicalSize=const Size(320,900);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    var opened=0;
    await tester.pumpWidget(frame(TahawwulatHero(onOpen:()=>opened++,onIntroduction:(){}),scale:2));
    expect(tester.takeException(),isNull);await tester.tap(find.text('Buka Fikih Tahawwulat'));expect(opened,1);
  });
  testWidgets('sector choice updates the explanation', (tester) async {
    await tester.pumpWidget(frame(const SizedBox(width:390,child:TahawwulatDiagram(interactive:true))));
    await tester.tap(find.widgetWithText(ChoiceChip,'Iman'));await tester.pump();
    expect(find.textContaining('Keyakinan kepada Allah'),findsOneWidget);expect(tester.takeException(),isNull);
  });
  testWidgets('reduced motion stops the loader ticker', (tester) async {
    await tester.pumpWidget(frame(const AppLoader(),reduced:true));await tester.pump(const Duration(seconds:3));
    expect(tester.takeException(),isNull);expect(tester.binding.transientCallbackCount,0);
    await tester.pumpWidget(frame(const AppLoader()));await tester.pump(const Duration(milliseconds:100));
    expect(tester.binding.transientCallbackCount,greaterThan(0));
    await tester.pumpWidget(const SizedBox.shrink());expect(tester.binding.transientCallbackCount,0);
  });
}
