import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:openturath_ai/models/open_turath_book.dart';
import 'package:openturath_ai/services/open_turath_catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'missing metadata and book assets surface as failures rather than empty catalogs',
      () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (_) async => null);
    addTearDown(() => messenger.setMockMessageHandler('flutter/assets', null));
    rootBundle.clear();
    await expectLater(OpenTurathCatalogRepository.instance.loadAllMetadata(),
        throwsA(isA<FlutterError>()));
    await expectLater(
        OpenTurathCatalogRepository.instance.loadBooksForModule('fiqh_maliki'),
        throwsA(isA<FlutterError>()));
  });
  test('malformed catalogs fail explicitly while valid empty lists stay empty',
      () {
    expect(() => OpenTurathBook.decodeList('{broken'), throwsFormatException);
    expect(() => OpenTurathBook.decodeList('{"books":"invalid"}'),
        throwsFormatException);
    expect(OpenTurathBook.decodeList('[]'), isEmpty);
  });
  test(
      'edition assessments never become editor names; raw evidence is retained',
      () {
    final book = OpenTurathBook.fromJson({
      'tahqiq': 'طبعة أصلية معتمدة',
      'cetakan': 'الأولى، 2003 هـ',
      'halaman': '52244'
    });
    expect(book.editorName, isEmpty);
    expect(book.editionNote, 'طبعة أصلية معتمدة');
    expect(book.editor, 'طبعة أصلية معتمدة');
    expect(book.needsMetadataReview, isTrue);
  });
  test('unknown modules cannot silently load the Shafii catalog', () async {
    await expectLater(
        OpenTurathCatalogRepository.instance
            .loadBooksForModule('missing_module'),
        throwsArgumentError);
  });
}
