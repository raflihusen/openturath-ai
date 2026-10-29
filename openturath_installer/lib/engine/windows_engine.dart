import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'install_engine.dart';

/// Jumlah berkas yang sudah ditulis, dibaca dari log Inno Setup
/// (satu baris "Dest filename:" per berkas).
int countInstalledFiles(String log) {
  var n = 0;
  for (final line in const LineSplitter().convert(log)) {
    if (line.contains('Dest filename:')) n++;
  }
  return n;
}

/// Kemajuan 0..1 dari jumlah berkas. Dijaga di bawah 1 sampai prosesnya
/// benar-benar selesai.
double progressFromCount(int done, int total) {
  if (total <= 0) return 0;
  return (done / total).clamp(0.0, 0.98);
}

/// Memasang dengan menjalankan mesin pemasang Inno secara senyap, lalu
/// membaca lognya untuk kemajuan nyata. Wizard Inno tidak pernah tampil;
/// pencopotan tetap lewat uninstaller Inno yang terdaftar di Windows.
class WindowsInstallEngine implements InstallEngine {
  WindowsInstallEngine({required this.corePath, required this.totalFiles});

  /// Muat `install_manifest.json` di samping program ini, atau null.
  static WindowsInstallEngine? fromManifest() {
    try {
      final base = p.dirname(Platform.resolvedExecutable);
      final f = File(p.join(base, 'install_manifest.json'));
      if (!f.existsSync()) return null;
      final m = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final core = p.normalize(p.join(base, m['core'] as String));
      if (!File(core).existsSync()) return null;
      return WindowsInstallEngine(
        corePath: core,
        totalFiles: (m['files'] as num).toInt(),
      );
    } catch (_) {
      return null;
    }
  }

  final String corePath;
  final int totalFiles;

  @override
  String get defaultDir => p.join(
    Platform.environment['LOCALAPPDATA'] ?? r'C:\Users\Public',
    'Programs',
    'OpenTurath AI',
  );

  @override
  Stream<InstallProgress> install(InstallOptions o) async* {
    final log = File(
      p.join(Directory.systemTemp.path, 'openturath_setup_$pid.log'),
    );
    if (log.existsSync()) log.deleteSync();
    yield const InstallProgress(0, 'prepare');
    final proc = await Process.start(corePath, [
      '/VERYSILENT',
      '/SUPPRESSMSGBOXES',
      '/NORESTART',
      '/SP-',
      '/LOG=${log.path}',
      '/DIR=${o.dir}',
      if (!o.desktopShortcut) '/MERGETASKS=!desktopicon',
    ]);
    int? code;
    unawaited(proc.exitCode.then((c) => code = c));
    var last = 0.0;
    while (code == null) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      var done = 0;
      try {
        done = countInstalledFiles(log.readAsStringSync());
      } catch (_) {} // log masih terkunci: coba lagi pada putaran berikut
      final v = progressFromCount(done, totalFiles);
      if (v > last) {
        last = v;
        yield InstallProgress(
          v,
          v < 0.97 ? (done == 0 ? 'prepare' : 'copy') : 'finish',
        );
      }
    }
    if (code != 0) {
      throw StateError('Mesin pemasang berhenti dengan kode $code');
    }
    yield const InstallProgress(1, 'finish');
  }

  @override
  Future<void> launch(String dir) async {
    await Process.start(
      p.join(dir, 'openturath_ai.exe'),
      const [],
      mode: ProcessStartMode.detached,
      workingDirectory: dir,
    );
  }
}

/// Dipakai bila berkas pendukung tidak ditemukan: layar galat yang bersih,
/// bukan pemasangan palsu.
class MissingPayloadEngine implements InstallEngine {
  @override
  String get defaultDir => '';
  @override
  Stream<InstallProgress> install(InstallOptions o) =>
      Stream.error(StateError('Berkas pemasang tidak lengkap'));
  @override
  Future<void> launch(String dir) async {}
}
