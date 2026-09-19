import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
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

/// Download policy comes from the signed application build, never the manifest.
/// Configure exact HTTPS hosts with --dart-define=OPENTURATH_UPDATE_HOSTS=host1,host2.
class UpdateDownloadPolicy {
  UpdateDownloadPolicy({required Set<String> allowedHosts})
      : allowedHosts = Set.unmodifiable(allowedHosts.map((host) => host.trim().toLowerCase()).where((host) => host.isNotEmpty));
  final Set<String> allowedHosts;
  static const maximumBytes = 200 * 1024 * 1024;
  static const minimumBytes = 5 * 1024 * 1024;

  bool permits(String url, String? checksum) {
    final uri = Uri.tryParse(url);
    return checksum != null && RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(checksum) &&
      uri != null && uri.scheme == 'https' && uri.userInfo.isEmpty &&
      !uri.hasFragment && uri.port == 443 && allowedHosts.contains(uri.host.toLowerCase());
  }
}

/// Android-only APK updates, with mandatory manifest checksum verification.
/// Transport integrity does not replace Android package-signature validation.
class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final _policy = UpdateDownloadPolicy(allowedHosts: {
    ...const String.fromEnvironment('OPENTURATH_UPDATE_HOSTS').split(','),
    'downloads.openturath.ai',
    'github.com',
    'objects.githubusercontent.com',
    'firebasestorage.googleapis.com',
  }.where((h) => h.isNotEmpty).toSet());
  UpdateStatus _status = UpdateStatus.idle;
  UpdateStatus get status => _status;
  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;
  bool _isChecking = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  bool get _supportsInstallation => !kIsWeb && Platform.isAndroid;
  bool get isUpdateReady => _supportsInstallation && _status == UpdateStatus.readyToInstall &&
    _updateInfo?.isDownloaded == true && _updateInfo?.localFilePath != null;

  void _setStatus(UpdateStatus status) { _status = status; notifyListeners(); }

  static Future<String> _computeFileSha256(File file) async =>
    (await sha256.bind(file.openRead()).first.timeout(const Duration(seconds: 30))).toString();

  @visibleForTesting
  static Future<bool> verifyPackage(File file, String? checksum) async {
    if (checksum == null || !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(checksum)) return false;
    if (await FileSystemEntity.type(file.path, followLinks: false) != FileSystemEntityType.file) return false;
    final length = await file.length();
    if (length < UpdateDownloadPolicy.minimumBytes || length > UpdateDownloadPolicy.maximumBytes) return false;
    return (await _computeFileSha256(file)).toLowerCase() == checksum.toLowerCase();
  }

  Future<void> checkForUpdatesSilently() async {
    // App Store and browser delivery must never enter the APK download path.
    if (!_supportsInstallation || _isChecking || _isDownloading || _isInstalling) return;
    _isChecking = true;
    try {
      _setStatus(UpdateStatus.checking);
      final package = await PackageInfo.fromPlatform().timeout(const Duration(seconds: 15));
      final currentCode = int.tryParse(package.buildNumber) ?? 0;
      final doc = await FirebaseFirestore.instance.collection('app_config').doc('version')
        .get().timeout(const Duration(seconds: 15));
      final data = doc.data();
      if (data == null) { _updateInfo = null; _setStatus(UpdateStatus.idle); return; }
      final code = (data['latest_version_code'] as num?)?.toInt() ?? 0;
      if (code <= currentCode) { _updateInfo = null; _setStatus(UpdateStatus.idle); return; }
      final url = (data['apk_url'] as String?) ?? '';
      final checksum = (data['sha256'] as String?)?.trim();
      if (!_policy.permits(url, checksum)) {
        _updateInfo = null;
        _setStatus(UpdateStatus.error);
        return;
      }
      _updateInfo = UpdateInfo(latestVersion: (data['latest_version'] as String?) ?? package.version,
        latestVersionCode: code, apkUrl: url,
        releaseNotes: (data['release_notes'] as String?) ?? 'Pembaruan aplikasi OpenTurath AI',
        sha256Hash: checksum);
      final file = await _getLocalApkFile(code);
      if (await verifyPackage(file, checksum!)) {
        _updateInfo = _updateInfo!.copyWith(isDownloaded: true, localFilePath: file.path, downloadProgress: 1);
        _setStatus(UpdateStatus.readyToInstall);
      } else {
        await _startSilentDownload(url, file, checksum);
      }
    } catch (_) {
      _updateInfo = null;
      _setStatus(UpdateStatus.error);
    } finally { _isChecking = false; }
  }

  Future<void> _startSilentDownload(String url, File targetFile, String checksum) async {
    if (_isDownloading || !_supportsInstallation || !_policy.permits(url, checksum)) return;
    _isDownloading = true;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    final temporary = File('${targetFile.path}.tmp');
    var expired = false;
    final deadline = Timer(const Duration(minutes: 3), () {
      expired = true;
      client.close(force: true);
    });
    try {
      _setStatus(UpdateStatus.downloading);
      await _cleanOldUpdates(targetFile.path);
      final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 15));
      request.followRedirects = false; // Reject every redirect, including same-host redirects.
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != HttpStatus.ok || expired) throw StateError('Download rejected');
      final expectedLength = response.contentLength;
      if (expectedLength > UpdateDownloadPolicy.maximumBytes ||
          (expectedLength >= 0 && expectedLength < UpdateDownloadPolicy.minimumBytes)) {
        throw StateError('Download size rejected');
      }
      final sink = temporary.openWrite();
      var received = 0;
      try {
        await sink.addStream(response.timeout(const Duration(seconds: 15)).map((chunk) {
          received += chunk.length;
          if (expired || received > UpdateDownloadPolicy.maximumBytes) throw StateError('Download limit exceeded');
          if (expectedLength > 0) _updateInfo = _updateInfo?.copyWith(downloadProgress: received / expectedLength);
          return chunk;
        }));
        await sink.flush().timeout(const Duration(seconds: 15));
      } finally {
        await sink.close().timeout(const Duration(seconds: 15));
      }
      if (expired || (expectedLength >= 0 && received != expectedLength) ||
          !await verifyPackage(temporary, checksum)) throw StateError('Download verification failed');
      if (expired) throw StateError('Download deadline exceeded');
      if (await targetFile.exists()) await targetFile.delete();
      await temporary.rename(targetFile.path);
      _updateInfo = _updateInfo?.copyWith(isDownloaded: true, localFilePath: targetFile.path, downloadProgress: 1);
      _setStatus(UpdateStatus.readyToInstall);
    } catch (_) {
      _updateInfo = null;
      _setStatus(UpdateStatus.error);
    } finally {
      deadline.cancel();
      client.close(force: true);
      _isDownloading = false;
      try { if (await temporary.exists()) await temporary.delete(); } catch (_) {}
    }
  }

  Future<void> _cleanOldUpdates(String currentPath) async {
    try {
      final directory = (await _getLocalApkFile(0)).parent;
      await for (final file in directory.list(followLinks: false)) {
        if (file is File && file.path != currentPath &&
            (file.path.endsWith('.apk') || file.path.endsWith('.tmp'))) {
          try { await file.delete(); } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<File> _getLocalApkFile(int versionCode) async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/updates');
    await directory.create(recursive: true);
    return File('${directory.path}/OpenTurath_v$versionCode.apk');
  }

  Future<void> installNow() async {
    if (!isUpdateReady || _isInstalling) return;
    final info = _updateInfo!;
    _isInstalling = true;
    try {
      if (!_policy.permits(info.apkUrl, info.sha256Hash)) throw StateError('Update policy rejected');
      final expectedFile = await _getLocalApkFile(info.latestVersionCode);
      if (info.localFilePath != expectedFile.path ||
          !await verifyPackage(expectedFile, info.sha256Hash!)) throw StateError('Installation verification failed');
      final result = await OpenFilex.open(expectedFile.path,
        type: 'application/vnd.android.package-archive').timeout(const Duration(seconds: 30));
      if (result.type != ResultType.done) throw StateError('Installer unavailable');
    } catch (_) {
      _updateInfo = null;
      _setStatus(UpdateStatus.error);
    } finally { _isInstalling = false; }
  }
}
