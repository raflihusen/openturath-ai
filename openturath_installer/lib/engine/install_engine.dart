/// Satu kemajuan pemasangan: [value] 0..1, [phase] satu dari
/// 'prepare', 'copy', 'finish' (diterjemahkan oleh antarmuka).
class InstallProgress {
  const InstallProgress(this.value, this.phase);
  final double value;
  final String phase;
}

class InstallOptions {
  const InstallOptions({required this.dir, required this.desktopShortcut});
  final String dir;
  final bool desktopShortcut;
}

/// Pemisah antara tampilan dan pekerjaan memasang. Tampilan hanya mendengarkan
/// aliran kemajuan; galat dilempar lewat aliran yang sama.
abstract class InstallEngine {
  String get defaultDir;
  Stream<InstallProgress> install(InstallOptions options);
  Future<void> launch(String dir);
}
