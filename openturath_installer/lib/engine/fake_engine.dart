import 'dart:async';

import 'install_engine.dart';

/// Mesin tiruan untuk pratinjau (macOS) dan pengujian: kemajuan naik tidak
/// rata, dengan jeda kecil, mirip salinan berkas sungguhan.
class FakeInstallEngine implements InstallEngine {
  FakeInstallEngine({this.total = const Duration(seconds: 9), this.failAt});

  final Duration total;

  /// Bila diisi (0..1), galat dilempar di titik itu.
  final double? failAt;
  int launched = 0;

  @override
  String get defaultDir =>
      r'C:\Users\Anda\AppData\Local\Programs\OpenTurath AI';

  @override
  Stream<InstallProgress> install(InstallOptions options) async* {
    const steps = 120;
    final tick = Duration(microseconds: total.inMicroseconds ~/ steps);
    yield const InstallProgress(0, 'prepare');
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(
        i % 37 == 0 ? tick * 6 : tick,
      ); // jeda seperti berkas besar
      final v = i / steps;
      if (failAt != null && v >= failAt!) {
        throw StateError('Disk penuh');
      }
      yield InstallProgress(
        v,
        v < 0.06 ? 'prepare' : (v < 0.96 ? 'copy' : 'finish'),
      );
    }
  }

  @override
  Future<void> launch(String dir) async => launched++;
}
