// Merender katalog kitab Arab (daftar, detail) ke PNG untuk ditinjau. Hanya
// berjalan bila OT_SNAPSHOT_DIR diset.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/core/theme.dart';
import 'package:openturath_ai/models/open_turath_book.dart';
import 'package:openturath_ai/screens/book_library_editorial_screen.dart';

final _dir = Platform.environment['OT_SNAPSHOT_DIR'];
final _key = GlobalKey();

OpenTurathBook _b(int i, String title, String author, int? death, String vol,
        String pages,
        {String editor = '', String publisher = '', String edition = ''}) =>
    OpenTurathBook(
        id: i,
        deathYear: death,
        section: 'فقه التحولات',
        shortName: title,
        title: title,
        author: author,
        editor: editor,
        publisher: publisher,
        edition: edition,
        volumes: vol,
        sourceFolder: '',
        pages: pages);

final _books = [
  _b(
      1,
      'أهل البيت النبوي: طائفة مباركة ممدوحة بالألسن والأقلام مبغوضة في المعاملة والأحكام',
      'عبد الوهاب بن علي الحسيني',
      null,
      '',
      '141',
      publisher: 'مكتبة المهاجر - دار آل الرفاعي'),
  _b(
      2,
      'إحياء لغة الإسلام العالمية وتجديدها من خلال تأصيل البدائل وتحديث الوسائل',
      'الحبيب أبو بكر العدني بن علي المشهور',
      1443,
      '1',
      '214'),
  _b(3, 'إحياء منهجية النمط الأوسط', 'الحبيب أبو بكر العدني بن علي المشهور',
      1443, '1', '59'),
  _b(4, 'إظهار العلم المكنون عن نماذج حيصات الفتن والرداح المطبقة والشرف الجون',
      'الحبيب أبو بكر العدني بن علي المشهور', 1443, '2', '157'),
  _b(5, 'إغاثة الصريخ للربط بين الديانة والتاريخ',
      'الحبيب أبو بكر العدني بن علي المشهور', 1443, '1', '35'),
  _b(
      6,
      'إنقاذ ما يمكن إنقاذه: حوار مكشوف يختص بأتباع مدرسة حضرموت في مرحلة الطوفان المخوف',
      'الحبيب أبو بكر العدني بن علي المشهور',
      1443,
      '3',
      '252'),
];

Future<void> _save(WidgetTester tester, String name) async {
  expect(tester.takeException(), isNull, reason: name);
  await tester.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_dir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render katalog', (tester) async {
    await tester.runAsync(() async {
      final arabic = FontLoader('NativeArabic')
        ..addFont(rootBundle.load('assets/native_fonts/NativeArabic.ttf'))
        ..addFont(rootBundle.load('assets/native_fonts/NativeArabic-700.ttf'));
      await arabic.load();
      for (final f in {
        'NativeArabicUI': 'NativeArabic.ttf',
        'NativeNewsreader': 'NativeNewsreader.ttf',
        'NativeOutfit': 'NativeOutfit.ttf',
        'NativeInter': 'NativeInter.ttf',
      }.entries) {
        final l = FontLoader(f.key)
          ..addFont(rootBundle.load('assets/native_fonts/${f.value}'));
        await l.load();
      }
    });
    AppConfig.localeNotifier.value = 'ar';
    Future<void> shot(String name, Widget page, Size size, bool dark) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(RepaintBoundary(
          key: _key,
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: page)));
      await tester.pump(const Duration(milliseconds: 900));
      await _save(tester, name);
    }

    for (final dark in [false, true]) {
      final t = dark ? 'dark' : 'light';
      await shot(
          'cat_list_wide_$t',
          OpenTurathBookLibraryPage(
              books: _books, collectionName: 'فقه التحولات'),
          const Size(1280, 1000),
          dark);
      await shot(
          'cat_list_phone_$t',
          OpenTurathBookLibraryPage(
              books: _books, collectionName: 'فقه التحولات'),
          const Size(390, 900),
          dark);
      await shot(
          'cat_detail_wide_$t',
          OpenTurathBookDetailPage(book: _books[0]),
          const Size(1280, 900),
          dark);
      await shot(
          'cat_detail_phone_$t',
          OpenTurathBookDetailPage(book: _books[1]),
          const Size(390, 900),
          dark);
    }
    addTearDown(() {
      tester.view.reset();
      AppConfig.localeNotifier.value = 'id';
    });
  }, skip: _dir == null);
}
