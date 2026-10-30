import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Owns verified packages only; partial downloads never become installable.
class UpdatePackageStore {
  UpdatePackageStore(this.directory,
      {this.minBytes = 5 * 1024 * 1024,
      this.maxBytes = 512 * 1024 * 1024,
      this.idleTimeout = const Duration(seconds: 30),
      this.totalTimeout = const Duration(minutes: 20),
      required this.allowUrl});
  final Directory directory;
  final int minBytes, maxBytes;
  final Duration idleTimeout, totalTimeout;
  final bool Function(Uri) allowUrl;
  bool _busy = false;

  static Future<String> digest(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  Future<bool> verified(File file, String hash) async {
    if (!RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(hash) || !await file.exists()) {
      return false;
    }
    final size = await file.length();
    return size >= minBytes &&
        size <= maxBytes &&
        await digest(file) == hash.toLowerCase();
  }

  Future<void> _prune(String prefix, File current) async {
    try {
      String? pending;
      final receipt = File(p.join(directory.path, 'pending_install.json'));
      if (await receipt.exists()) {
        pending = (jsonDecode(await receipt.readAsString()) as Map<String, dynamic>)['package'] as String?;
      }
      final candidates = <File>[];
      await for (final entry in directory.list()) {
        if (entry is File && p.basename(entry.path).startsWith(prefix) &&
            RegExp(r'_[0-9]+_[a-f0-9]{64}\.(apk|dmg|exe)$').hasMatch(entry.path) &&
            entry.path != current.path && entry.path != pending) candidates.add(entry);
      }
      candidates.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      // Keep the current package, one predecessor, and any pending installer.
      for (final file in candidates.skip(1)) {
        try { await file.delete(); } on FileSystemException { /* May be in use. */ }
      }
    } catch (_) { /* Cleanup must never invalidate a verified download. */ }
  }

  Future<File> obtain(
      {required Uri url,
      required int build,
      required String platform,
      required String edition,
      required String hash,
      void Function(double)? onProgress}) async {
    if (_busy) throw StateError('An update download is already running');
    if (!allowUrl(url) ||
        build <= 0 ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(hash) ||
        !RegExp(r'^[a-z0-9_]+$').hasMatch('$platform$edition')) {
      throw const FormatException('Invalid update package');
    }
    final ext = p.extension(url.path).toLowerCase();
    if (!{'.apk', '.dmg', '.exe'}.contains(ext)) {
      throw const FormatException('Unsupported update package format');
    }
    _busy = true;
    final client = HttpClient()..connectionTimeout = idleTimeout;
    File? partial;
    try {
      await directory.create(recursive: true);
      final prefix = 'OpenTurath_${platform}_${edition}_';
      final target = File(p.join(directory.path,
          'OpenTurath_${platform}_${edition}_${build}_${hash.toLowerCase()}$ext'));
      if (await verified(target, hash)) {
        await _prune(prefix, target);
        onProgress?.call(1);
        return target;
      }
      partial = File('${target.path}.$pid.partial');
      if (await partial.exists()) await partial.delete();
      final deadline = DateTime.now().add(totalTimeout);
      var location = url;
      HttpClientResponse? response;
      for (var redirects = 0; redirects <= 5; redirects++) {
        final request = await client.getUrl(location).timeout(idleTimeout);
        request.followRedirects = false;
        response = await request.close().timeout(idleTimeout);
        if (!response.isRedirect) break;
        final next = response.headers.value(HttpHeaders.locationHeader);
        if (next == null || redirects == 5) {
          throw const HttpException('Invalid update redirect');
        }
        location = location.resolve(next);
        if (!allowUrl(location)) {
          throw const HttpException('Untrusted update redirect');
        }
      }
      if (response == null ||
          response.statusCode != HttpStatus.ok ||
          response.contentLength > maxBytes ||
          response.headers.contentType?.mimeType == 'text/html') {
        throw const HttpException('Update download was rejected');
      }
      final sink = partial.openWrite();
      var received = 0;
      try {
        await for (final bytes in response.timeout(idleTimeout)) {
          received += bytes.length;
          if (received > maxBytes || DateTime.now().isAfter(deadline)) {
            throw const HttpException('Update download exceeded its limit');
          }
          sink.add(bytes);
          if (response.contentLength > 0) {
            onProgress?.call(received / response.contentLength);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      if ((response.contentLength >= 0 && received != response.contentLength) ||
          !await verified(partial, hash)) {
        throw const FormatException('Update package integrity check failed');
      }
      if (await target.exists() && !await verified(target, hash)) {
        await target.delete();
      }
      if (await verified(target, hash)) {
        await partial.delete();
      } else {
        await partial.rename(target.path);
      }
      await _prune(prefix, target);
      onProgress?.call(1);
      return target;
    } finally {
      client.close(force: true);
      if (partial != null && await partial.exists()) await partial.delete();
      _busy = false;
    }
  }
}
