import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String? sha256Hash;
  final bool isDownloaded;
  final String? localFilePath;
  final double downloadProgress; // 0.0 to 1.0

  const UpdateInfo({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.apkUrl,
    required this.releaseNotes,
    this.sha256Hash,
    this.isDownloaded = false,
    this.localFilePath,
    this.downloadProgress = 0.0,
  });

  UpdateInfo copyWith({
    String? latestVersion,
    int? latestVersionCode,
    String? apkUrl,
    String? releaseNotes,
    String? sha256Hash,
    bool? isDownloaded,
    String? localFilePath,
    double? downloadProgress,
  }) {
    return UpdateInfo(
      latestVersion: latestVersion ?? this.latestVersion,
      latestVersionCode: latestVersionCode ?? this.latestVersionCode,
      apkUrl: apkUrl ?? this.apkUrl,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localFilePath: localFilePath ?? this.localFilePath,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

/// UpdateService: Background Auto-Downloader & Instant One-Click Installer
/// - Mengunduh file APK di latar belakang secara diam-diam (silent download) di Android
/// - Di macOS/Windows: Membuka laman unduh rilis desktop via browser eksternal
/// - Dilengkapi mutex unduhan, sanitasi sink I/O, dan verifikasi integritas SHA-256
class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  UpdateStatus _status = UpdateStatus.idle;
  UpdateStatus get status => _status;

  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;

  bool get isUpdateReady {
    if (_status != UpdateStatus.readyToInstall || _updateInfo == null) return false;
    if (!kIsWeb && !Platform.isAndroid) {
      // Desktop: siap membuka URL unduhan desktop
      return true;
    }
    return _updateInfo!.isDownloaded && _updateInfo!.localFilePath != null;
  }

  bool _isChecking = false;
  bool _isDownloading = false;

  /// Hitung SHA-256 secara streaming tanpa memuat seluruh file 60MB ke memori RAM (F20)
  static Future<String> _computeFileSha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  /// Memulai pengecekan versi dan unduhan otomatis di background
  Future<void> checkForUpdatesSilently() async {
    if (_isChecking || _isDownloading) return;
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
      final sha256Hash = (data['sha256'] as String?)?.trim();

      // Jika versi di server lebih baru dari versi yang sedang terpasang
      if (latestCode > currentCode && apkUrl.isNotEmpty) {
        _updateInfo = UpdateInfo(
          latestVersion: latestVersion,
          latestVersionCode: latestCode,
          apkUrl: apkUrl,
          releaseNotes: releaseNotes,
          sha256Hash: sha256Hash,
        );

        if (!kIsWeb && !Platform.isAndroid) {
          // macOS / Windows Desktop: tampilkan banner siap update (buka URL)
          _updateInfo = _updateInfo!.copyWith(
            isDownloaded: true,
            downloadProgress: 1.0,
          );
          _status = UpdateStatus.readyToInstall;
          notifyListeners();
          return;
        }

        // Android: Periksa apakah APK versi tersebut SUDAH pernah terunduh di cache (F44)
        final localFile = await _getLocalApkFile(latestCode);
        bool isCachedValid = false;
        if (await localFile.exists() && (await localFile.length()) > 5 * 1024 * 1024) {
          if (sha256Hash != null && sha256Hash.isNotEmpty) {
            try {
              final cachedSha = await _computeFileSha256(localFile);
              if (cachedSha.toLowerCase() == sha256Hash.toLowerCase()) {
                isCachedValid = true;
              } else {
                debugPrint('[UpdateService] Cached APK hash mismatch: $cachedSha vs $sha256Hash');
                await localFile.delete();
              }
            } catch (e) {
              debugPrint('[UpdateService] Error checking cached hash: $e');
              try {
                await localFile.delete();
              } catch (_) {}
            }
          } else {
            isCachedValid = true;
          }
        }

        if (isCachedValid) {
          _updateInfo = _updateInfo!.copyWith(
            isDownloaded: true,
            localFilePath: localFile.path,
            downloadProgress: 1.0,
          );
          _status = UpdateStatus.readyToInstall;
          notifyListeners();
        } else {
          // Belum terunduh atau cache tidak valid: Jalankan silent background download otomatis
          _startSilentDownload(apkUrl, localFile, sha256Hash);
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

  /// Unduh APK di latar belakang tanpa mengganggu user dengan mutex dan try-finally sink
  Future<void> _startSilentDownload(String url, File targetFile, String? expectedSha256) async {
    if (_isDownloading) return;
    _isDownloading = true;

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

      try {
        await for (final chunk in response) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (contentLength > 0) {
            final progress = receivedBytes / contentLength;
            _updateInfo = _updateInfo?.copyWith(downloadProgress: progress);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      // Validasi integritas ukuran file
      final tempLength = await tempFile.length();
      if (tempLength < 5 * 1024 * 1024 || (contentLength > 0 && tempLength < contentLength)) {
        debugPrint('[UpdateService] Unduhan tidak lengkap ($tempLength bytes)');
        if (await tempFile.exists()) await tempFile.delete();
        _status = UpdateStatus.idle;
        notifyListeners();
        return;
      }

      // Validasi SHA-256 secara streaming jika disediakan oleh Firestore app_config/version (F20)
      if (expectedSha256 != null && expectedSha256.isNotEmpty) {
        final calculatedSha256 = await _computeFileSha256(tempFile);
        if (calculatedSha256.toLowerCase() != expectedSha256.toLowerCase()) {
          debugPrint('[UpdateService] SHA256 checksum mismatch: $calculatedSha256 vs $expectedSha256');
          if (await tempFile.exists()) await tempFile.delete();
          _status = UpdateStatus.idle;
          notifyListeners();
          return;
        }
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
      _isDownloading = false;
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

  /// Tombol "Pasang Sekarang" dipanggil:
  /// - Android: Langsung buka Package Installer sistem
  /// - Desktop (macOS/Windows): Buka tautan pembaruan langsung di browser
  Future<void> installNow() async {
    if (!isUpdateReady || _updateInfo == null) return;

    if (!kIsWeb && !Platform.isAndroid) {
      final downloadUrl = _updateInfo!.apkUrl;
      final uri = Uri.tryParse(downloadUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    final filePath = _updateInfo!.localFilePath;
    if (filePath == null) return;

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
