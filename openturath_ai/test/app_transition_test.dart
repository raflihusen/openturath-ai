import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/app_transition.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppConfig.themeNotifier.value = ThemeMode.light;
    AppConfig.localeNotifier.value = 'id';
  });

  testWidgets('ganti tema memotret layar lama lalu melepasnya setelah animasi',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AppTransitionHost(
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: AppConfig.themeNotifier,
          builder: (_, mode, __) => ColoredBox(
            color: mode == ThemeMode.dark ? Colors.black : Colors.white,
          ),
        ),
      ),
    ));

    await tester.runAsync(() => AppConfig.setThemeMode(ThemeMode.dark));
    await tester.pump();
    expect(find.byType(RawImage), findsOneWidget);
    expect(AppConfig.themeNotifier.value, ThemeMode.dark);

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RawImage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RawImage), findsNothing);
  });

  testWidgets('ganti bahasa memudar lalu melepas potret', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AppTransitionHost(child: SizedBox.expand()),
    ));
    await tester.runAsync(() => AppConfig.setLocale('en'));
    await tester.pump();
    expect(find.byType(RawImage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(RawImage), findsNothing);
    expect(AppConfig.localeNotifier.value, 'en');
  });

  testWidgets('tanpa host atau nilai sama tidak menahan perubahan',
      (tester) async {
    await AppConfig.setThemeMode(ThemeMode.dark);
    expect(AppConfig.themeNotifier.value, ThemeMode.dark);
    await AppConfig.setLocale('id');
    expect(AppConfig.localeNotifier.value, 'id');
  });
}
