import 'dart:convert';
import 'package:flutter/services.dart';

/// The native Flutter font registry is separate from the WebView font registry.
/// Inject local assets into notebook pages only; never fetch a CDN font at runtime.
abstract final class NotebookFontService {
  static Future<String>? _cached;
  static Future<String> get injection => _cached ??= _build().catchError((Object error) {
    _cached = null;
    throw error;
  });
  static Future<String> _build() async {
    final fonts = <({String family, String file, String weight})>[
      (family: 'Scheherazade New', file: 'ScheherazadeNew-Regular.ttf', weight: '400'),
      (family: 'Scheherazade New', file: 'ScheherazadeNew-Bold.ttf', weight: '700'),
      (family: 'Inter', file: 'Inter.ttf', weight: '100 900'),
      (family: 'Cormorant', file: 'Cormorant.ttf', weight: '300 700'),
    ];
    final rules = <String>[];
    for (final font in fonts) {
      final bytes = await rootBundle.load('assets/fonts/${font.file}');
      final base64 = base64Encode(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      rules.add("@font-face{font-family:'${font.family}';font-style:normal;font-weight:${font.weight};src:url(data:font/ttf;base64,$base64) format('truetype');font-display:swap;}");
    }
    rules.add(".rendered-markdown{font-family:'Inter',sans-serif;} .rendered-markdown h1,.rendered-markdown h2,.rendered-markdown h3{font-family:'Cormorant',serif;}");
    return '''
      (function(){
        if(window.top!==window || location.protocol!=='https:' ||
          !['notebooklm.google.com','notebook.google.com'].includes(location.hostname)) return;
        if(document.getElementById('ot-bundled-fonts')) return;
        const style=document.createElement('style');
        style.id='ot-bundled-fonts'; style.textContent=${jsonEncode(rules.join('\n'))};
        (document.head||document.documentElement).appendChild(style);
      })();
    ''';
  }
}
