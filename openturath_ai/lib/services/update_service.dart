import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import '../core/app_config.dart';
import '../core/platform_release.dart';
import '../core/localization.dart';
import 'desktop_update_installer.dart';
import 'update_package_store.dart';

enum UpdateStatus {
  idle,
  checking,
  downloading,
  readyToInstall,
  installing,
  error
}

class UpdateInfo {
  final String latestVersion;
  final int latestVersionCode;
  final String apkUrl;
  final String releaseNotes;
  final String? sha256Hash;
  final bool isDownloaded;
  final String? localFilePath;
  final int installerProtocol;
  final double downloadProgress; // 0.0 to 1.0

  const UpdateInfo({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.apkUrl,
    required this.releaseNotes,
    this.sha256Hash,
    this.installerProtocol = 0,
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
      installerProtocol: installerProtocol,
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

/// All platforms download and verify a local package before offering installation.
class UpdateService extends ChangeNotifier {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  @visibleForTesting
  UpdateService.test(
      {required TargetPlatform platform,
      required Future<int> Function() buildLoader,
      required Future<Map<String, dynamic>?> Function() manifestLoader,
      required UpdatePackageStore store,
      required Future<void> Function(UpdateInfo) installer})
      : _platformOverride = platform,
        _buildLoader = buildLoader,
        _manifestLoader = manifestLoader,
        _store = store,
        _installer = installer;

  TargetPlatform? _platformOverride;
  TargetPlatform get platform => _platformOverride ?? defaultTargetPlatform;
  bool get _desktop =>
      platform == TargetPlatform.macOS || platform == TargetPlatform.windows;
  Future<int> Function()? _buildLoader;
  Future<Map<String, dynamic>?> Function()? _manifestLoader;
  Future<void> Function(UpdateInfo)? _installer;
  UpdatePackageStore? _store;
  UpdateStatus _status = UpdateStatus.idle;
  UpdateStatus get status => _status;
  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;
  String? _lastError;
  String? get lastError => _lastError;
  bool get isInstalling => _status == UpdateStatus.installing;
  bool get isUpdateReady =>
      _status == UpdateStatus.readyToInstall &&
      _updateInfo?.isDownloaded == true &&
      _updateInfo?.localFilePath != null;
  bool _isChecking = false;
  DateTime? _lastCheckedAt;
  static const recheckInterval = Duration(minutes: 30);
  @visibleForTesting
  static bool shouldRecheck(
          {required DateTime now,
          required DateTime? last,
          required bool ready,
          Duration interval = recheckInterval}) =>
      !ready && (last == null || now.difference(last) >= interval);

  Future<UpdatePackageStore> _packageStore() async =>
      _store ??=
          UpdatePackageStore(await DesktopUpdateInstaller.updateDirectory(),
              allowUrl: (url) =>
                  url.scheme == 'https' &&
                  url.userInfo.isEmpty &&
                  url.port == 443 &&
                  PlatformRelease.allowedHosts.contains(url.host));

  Future<void> retry() async {
    _lastCheckedAt = null;
    await checkForUpdatesSilently();
  }

  Future<void> checkForUpdatesSilently() async {
    if ((kIsWeb && _platformOverride == null) ||
        (!_desktop && platform != TargetPlatform.android) ||
        _isChecking ||
        isInstalling ||
        !shouldRecheck(
            now: DateTime.now(),
            last: _lastCheckedAt,
            ready: isUpdateReady)) return;
    _isChecking = true;
    _lastError = null;
    _status = UpdateStatus.checking;
    notifyListeners();
    try {
      final current = await (_buildLoader?.call() ??
              PackageInfo.fromPlatform()
                  .then((info) => int.tryParse(info.buildNumber) ?? 0))
          .timeout(const Duration(seconds: 15));
      final data = await (_manifestLoader?.call() ??
              FirebaseFirestore.instance
                  .collection('app_config')
                  .doc('version')
                  .get()
                  .then((doc) => doc.data()))
          .timeout(const Duration(seconds: 20));
      final release = data == null
          ? null
          : PlatformRelease.parse(data, platform,
              edition: AppConfig.isGuruEdition ? 'guru' : 'standard');
      if (release == null || release.build <= current) {
        _updateInfo = null;
        _status = UpdateStatus.idle;
      } else {
        if (release.sha256 == null ||
            (platform == TargetPlatform.windows &&
                release.installerProtocol != 1)) {
          throw const FormatException(
              'Release is not compatible with verified installation');
        }
        final ext = p.extension(release.url.path).toLowerCase();
        if (ext !=
            (platform == TargetPlatform.macOS
                ? '.dmg'
                : platform == TargetPlatform.windows
                    ? '.exe'
                    : '.apk')) {
          throw const FormatException('Unsupported installer format');
        }
        _updateInfo = UpdateInfo(
            latestVersion: release.version,
            latestVersionCode: release.build,
            apkUrl: release.url.toString(),
            releaseNotes: release.notes,
            sha256Hash: release.sha256,
            installerProtocol: release.installerProtocol);
        _status = UpdateStatus.downloading;
        notifyListeners();
        final file = await (await _packageStore()).obtain(
            url: release.url,
            build: release.build,
            platform: platform.name.toLowerCase(),
            edition: AppConfig.isGuruEdition ? 'guru' : 'standard',
            hash: release.sha256!,
            onProgress: (progress) {
              _updateInfo = _updateInfo?.copyWith(downloadProgress: progress);
              notifyListeners();
            });
        _updateInfo = _updateInfo!.copyWith(
            isDownloaded: true, localFilePath: file.path, downloadProgress: 1);
        _status = UpdateStatus.readyToInstall;
      }
      _lastCheckedAt = DateTime.now();
    } catch (error) {
      debugPrint('[Updater] Check/download failed: ${error.runtimeType}');
      _status = UpdateStatus.error;
      _lastError = Loc.tr('updateDownloadFailed');
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> installNow() async {
    if (!isUpdateReady) return false;
    final info = _updateInfo!;
    _status = UpdateStatus.installing;
    _lastError = null;
    notifyListeners();
    var handedOff = false;
    try {
      final file = File(info.localFilePath!);
      if (!await (await _packageStore()).verified(file, info.sha256Hash!)) {
        _updateInfo = null;
        _status = UpdateStatus.error;
        _lastCheckedAt = null;
        _lastError = Loc.tr('updatePackageChanged');
        return false;
      }
      if (_installer != null) {
        await _installer!(info);
      } else if (_desktop) {
        final stage = await const DesktopUpdateInstaller().handoff(
            package: file,
            hash: info.sha256Hash!,
            build: info.latestVersionCode,
            installerProtocol: info.installerProtocol);
        try {
          final closing = await const MethodChannel('com.openturath.ai/updater')
              .invokeMethod<bool>('quitForUpdate').timeout(const Duration(seconds: 5));
          if (closing != true) throw StateError('Application could not close');
          handedOff = true;
        } catch (_) {
          await File(p.join(stage, 'cancelled')).writeAsString('cancelled');
          rethrow;
        }
      } else {
        await const MethodChannel('com.openturath.ai/updater')
            .invokeMethod<String>('install',
                {'path': file.path, 'build': info.latestVersionCode});
      }
      return true;
    } catch (error) {
      debugPrint(
          '[Updater] Installation could not start: ${error.runtimeType}');
      _lastError = Loc.tr('updateInstallFailed');
      return false;
    } finally {
      if (_status == UpdateStatus.installing && !handedOff) {
        _status = UpdateStatus.readyToInstall;
      }
      notifyListeners();
    }
  }
}
