import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_installer/engine/windows_engine.dart';

void main() {
  const log = '''
2026-10-29 07:30:00.100   Log opened.
2026-10-29 07:30:01.200   Dest filename: C:\\Users\\a\\OpenTurath AI\\openturath_ai.exe
2026-10-29 07:30:01.900   Dest filename: C:\\Users\\a\\OpenTurath AI\\flutter_windows.dll
2026-10-29 07:30:02.400   Installation process succeeded.
''';

  test('menghitung berkas dari log Inno', () {
    expect(countInstalledFiles(log), 2);
    expect(countInstalledFiles(''), 0);
  });

  test('kemajuan tidak pernah mencapai 1 sebelum proses selesai', () {
    expect(progressFromCount(0, 59), 0);
    expect(progressFromCount(30, 60), 0.5);
    expect(progressFromCount(59, 59), 0.98);
    expect(progressFromCount(5, 0), 0);
  });
}
