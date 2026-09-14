import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/catalog_card_content.dart';

void main() {
  group('catalogCardFacts', () {
    test('keeps the three most useful edition facts in a stable order', () {
      expect(
        catalogCardFacts(
          volumes: '8 jilid',
          publisher: 'Dar al-Fikr — Beirut',
          printYear: '1403 H / 1983 M',
          muhaqqiq: 'Tidak dicatat',
        ),
        ['8 jilid', 'Dar al-Fikr — Beirut', '1403 H / 1983 M'],
      );
    });

    test('uses tahqiq only when a primary fact is unavailable', () {
      expect(
        catalogCardFacts(
          volumes: null,
          publisher: null,
          printYear: '1440 H',
          muhaqqiq: 'Ahmad Syakir',
        ),
        ['1440 H', 'Tahqiq: Ahmad Syakir'],
      );
    });

    test('drops placeholders and never returns more than three facts', () {
      expect(
        catalogCardFacts(
          volumes: '-',
          publisher: '  ',
          printYear: '-',
          muhaqqiq: 'غير مدون',
        ),
        isEmpty,
      );
    });
  });
}
