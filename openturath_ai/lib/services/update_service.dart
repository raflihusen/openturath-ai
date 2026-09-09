import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

enum UpdateStatus {
  idle,
  checking,
  downloading,
  readyToInstall,
  error,
}

class UpdateInfo {
  final String latestVersion;
  final int latestVersionCode;
  final String apkUrl;
  final String releaseNotes;
  final bool isDownloaded;
  final String? localFilePath;
  final double downloadProgress; // 0.0 to 1.0

  const UpdateInfo({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.apkUrl,
    required this.releaseNotes,
    this.isDownloaded = false,
    this.localFilePath,
    this.downloadProgress = 0.0,
  });

  UpdateInfo copyWith({
    String? latestVersion,
    int? latestVersionCode,
    String? apkUrl,
    String? releaseNotes,
    bool? isDownloaded,
    String? localFilePath,
    double? downloadProgress,
  }) {
    return UpdateInfo(
      latestVersion: latestVersion ?? this.latestVersion,
      latestVersionCode: latestVersionCode ?? this.latestVersionCode,
      apkUrl: apkUrl ?? this.apkUrl,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

/// UpdateService: Background Auto-Downloader & Instant One-Click Installer
/// - Mengunduh file APK di latar belakang secara diam-diam (silent download)
/// - Saat selesai, tombol "Pasang Pembaruan" langsung memicu instalasi tanpa perlu unduh lagi
class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  UpdateStatus _status = UpdateStatus.idle;
  UpdateStatus get status => _status;

  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;

  bool get isUpdateReady =>
      _status == UpdateStatus.readyToInstall &&
      _updateInfo != null &&
      _updateInfo!.isDownloaded &&
      _updateInfo!.localFilePath != null;

  bool _isChecking = false;

  /// Memulai pengecekan versi dan unduhan otomatis di background
  Future<void> checkForUpdatesSilently() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      _status = UpdateStatus.checking;
      notifyListeners();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      // Ambil konfigurasi versi dari Firestore (collection: app_config, doc: version)
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();

      if (!doc.exists) {
        _status = UpdateStatus.idle;
        _isChecking = false;
        notifyListeners();
        return;
      }

      final data = doc.data()!;
      final latestCode = (data['latest_version_code'] as num?)?.toInt() ?? 0;
      final latestVersion = (data['latest_version'] as String?) ?? packageInfo.version;
      final apkUrl = (data['apk_url'] as String?) ?? '';
      final releaseNotes = (data['release_notes'] as String?) ?? 'Pembaruan aplikasi OpenTurath AI';

      // Jika versi di server lebih baru dari versi yang sedang terpasang di HP
      if (latestCode > currentCode && apkUrl.isNotEmpty) {
        _updateInfo = UpdateInfo(
          latestVersion: latestVersion,
          latestVersionCode: latestCode,
          apkUrl: apkUrl,
          releaseNotes: releaseNotes,
        );

        // Periksa apakah APK versi tersebut SUDAH pernah terunduh sebelumnya di cache
        final localFile = await _getLocalApkFile(latestCode);
        if (await localFile.exists() && (await localFile.length()) > 5 * 1024 * 1024) {
          // Sudah terunduh dan ukuran valid
          _updateInfo = _updateInfo!.copyWith(
            isDownloaded: true,
            localFilePath: localFile.path,
            downloadProgress: 1.0,
          );
          _status = UpdateStatus.readyToInstall;
          notifyListeners();
        } else {
          // Belum terunduh: Jalankan silent background download otomatis
          _startSilentDownload(apkUrl, localFile);
        }
      } else {
        _status = UpdateStatus.idle;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[UpdateService] Error checking updates: $e');
      _status = UpdateStatus.idle;
      notifyListeners();
    } finally {
      _isChecking = false;
    }
  }

  /// Unduh APK di latar belakang tanpa mengganggu user
  Future<void> _startSilentDownload(String url, File targetFile) async {
    final client = HttpClient();
    try {
      _status = UpdateStatus.downloading;
      notifyListeners();

      // Bersihkan file update lama sebelum mulai unduh baru
      await _cleanOldUpdates(targetFile.path);

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        _status = UpdateStatus.idle;
        notifyListeners();
        return;
      }

      final contentLength = response.contentLength;
      final tempFile = File('${targetFile.path}.tmp');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final sink = tempFile.openWrite();
      int receivedBytes = 0;

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          final progress = receivedBytes / contentLength;
          _updateInfo = _updateInfo?.copyWith(downloadProgress: progress);
        }
      }

      await sink.flush();
      await sink.close();

      // Validasi integritas ukuran file sebelum dipindahkan ke APK final
      final tempLength = await tempFile.length();
      if (tempLength < 10 * 1024 * 1024 || (contentLength > 0 && tempLength < contentLength)) {
        debugPrint('[UpdateService] Unduhan tidak lengkap ($tempLength bytes)');
        if (await tempFile.exists()) await tempFile.delete();
        _status = UpdateStatus.idle;
        notifyListeners();
        return;
      }

      // Rename dari temp ke final APK
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);

      _updateInfo = _updateInfo?.copyWith(
        isDownloaded: true,
        localFilePath: targetFile.path,
        downloadProgress: 1.0,
      );
      _status = UpdateStatus.readyToInstall;
      notifyListeners();
      debugPrint('[UpdateService] Background download complete: ${targetFile.path}');
    } catch (e) {
      debugPrint('[UpdateService] Background download error: $e');
      _status = UpdateStatus.idle;
      notifyListeners();
    } finally {
      client.close();
    }
  }

  /// Bersihkan file APK atau file sementara lama di direktori update
  Future<void> _cleanOldUpdates(String currentPath) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final updateDir = Directory('${dir.path}/updates');
      if (await updateDir.exists()) {
        final list = updateDir.listSync();
        for (final entity in list) {
          if (entity.path != currentPath && (entity.path.endsWith('.apk') || entity.path.endsWith('.tmp'))) {
            try {
              entity.deleteSync();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  /// Lokasi file APK di penyimpanan privat aplikasi
  Future<File> _getLocalApkFile(int versionCode) async {
    final dir = await getApplicationSupportDirectory();
    final updateDir = Directory('${dir.path}/updates');
    if (!await updateDir.exists()) {
      await updateDir.create(recursive: true);
    }
    return File('${updateDir.path}/OpenTurath_v$versionCode.apk');
  }

  /// Tombol "Pasang Sekarang" dipanggil: Langsung buka Package Installer sistem
  Future<void> installNow() async {
    if (!isUpdateReady || _updateInfo?.localFilePath == null) return;

    final filePath = _updateInfo!.localFilePath!;
    final file = File(filePath);

    if (!await file.exists()) {
      _status = UpdateStatus.idle;
      notifyListeners();
      return;
    }

    try {
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );
      debugPrint('[UpdateService] OpenFilex result: ${result.type} - ${result.message}');
    } catch (e) {
      debugPrint('[UpdateService] Install error: $e');
    }
  }
}
