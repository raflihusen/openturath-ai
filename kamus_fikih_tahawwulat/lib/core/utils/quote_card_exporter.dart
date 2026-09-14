import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QuoteCardExporter {
  /// Renders a widget wrapped in a [RepaintBoundary] identified by [globalKey]
  /// to high-resolution PNG bytes.
  static Future<ui.Image?> captureToImage(GlobalKey globalKey, {double pixelRatio = 3.0}) async {
    try {
      final boundary = globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Captures widget to PNG and triggers native platform share sheet
  static Future<bool> captureAndShare(
    GlobalKey globalKey, {
    required String title,
    required String text,
    String filenamePrefix = 'tahawwulat_quote',
    double pixelRatio = 3.0,
  }) async {
    try {
      final image = await captureToImage(globalKey, pixelRatio: pixelRatio);
      if (image == null) return false;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = title.replaceAll(RegExp(r'[\s/\\:*?"<>|]'), '_');
      final file = File('${tempDir.path}/${filenamePrefix}_${sanitizedTitle}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      final xFile = XFile(file.path, mimeType: 'image/png');
      await Share.shareXFiles(
        [xFile],
        text: text,
        subject: title,
      );
      return true;
    } catch (e) {
      debugPrint('Error sharing quote image: $e');
      return false;
    }
  }
}
