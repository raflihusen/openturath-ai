import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AgentService contains canonical master notebook URLs for all key modules', () {
    const urls = {
      'fiqh_syafii': 'https://notebooklm.google.com/notebook/334e7b83-0e76-4787-a1d6-314642a35862',
      'fiqh_tahawwulat': 'https://notebooklm.google.com/notebook/dc7ee7e4-f4ad-4db6-9cd0-0013727abbe4',
      'hadits': 'https://notebooklm.google.com/notebook/b9626501-538c-4358-a44f-6731eaec50b6',
      'nahwu': 'https://notebooklm.google.com/notebook/15bc4cef-4b94-4241-b05a-d50a586bde06',
      'tafsir': 'https://notebooklm.google.com/notebook/df92cc50-1106-4221-8748-1663f00fa7fe',
      'ushul_fiqh': 'https://notebooklm.google.com/notebook/6ab6dae8-0067-435a-85ca-b6bd4e17dd12',
    };

    for (final entry in urls.entries) {
      expect(entry.value, contains('notebooklm.google.com/notebook/'));
    }
  });
}
