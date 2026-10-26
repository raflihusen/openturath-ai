import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/notebook_fonts.dart';
import 'package:openturath_ai/core/notebook_skin.dart';
import 'package:openturath_ai/core/notebook_ui_script.dart';

void main() {
  notebookSkinTests();
  test('notebookUiScript defines valid wrapper and exports otNotebook', () {
    expect(notebookUiScript.isNotEmpty, isTrue);
    expect(notebookUiScript.contains('window.otNotebook = {'), isTrue);
    expect(notebookUiScript.contains('ready,'), isTrue);
    expect(notebookUiScript.contains('inputReady,'), isTrue);
    expect(notebookUiScript.contains('clean,'), isTrue);
  });

  test('notebookUiScript has valid JavaScript syntax via node -c', () async {
    final tempDir = await Directory.systemTemp.createTemp('ot_script_test');
    final tempFile = File('${tempDir.path}/test_script.js');
    await tempFile.writeAsString(notebookUiScript);

    try {
      final result = await Process.run('node', ['-c', tempFile.path]);
      expect(
        result.exitCode,
        equals(0),
        reason: 'JavaScript Syntax Error: ${result.stderr}',
      );
    } finally {
      await tempDir.delete(recursive: true);
    }
  });

  test(
      'notebookUiScript preserves message selectors and excludes composer from questions',
      () {
    // questionSelector should NOT loosely match [class*="query" i] or [class*="prompt" i]
    // because that matches .query-box-container and textarea
    expect(
        notebookUiScript.contains(r'[class*="query" i], [class*="prompt" i]'),
        isFalse);
    expect(notebookUiScript.contains(r'[class*="user-query" i]'), isTrue);
    expect(notebookUiScript.contains(r'[class*="user-prompt" i]'), isTrue);

    // ensureStyles should NOT hide chat-intro or conversation-intro
    expect(notebookUiScript.contains('app-chat-intro'), isFalse);
    expect(notebookUiScript.contains('app-conversation-intro'), isFalse);
    expect(notebookUiScript.contains('.chat-intro'), isFalse);
    expect(notebookUiScript.contains('.conversation-intro'), isFalse);

    // message containers must maintain display block and visibility
    expect(
        notebookUiScript
            .contains('.chat-message, .model-message, .user-message'),
        isTrue);
    expect(notebookUiScript.contains('display: block !important;'), isTrue);
    expect(
        notebookUiScript.contains('visibility: visible !important;'), isTrue);
  });

  test(
      'notebookUiScript hides guide card, cover, and mobile tablist while keeping chat selected',
      () {
    expect(notebookUiScript.contains('app-notebook-guide'), isTrue);
    expect(notebookUiScript.contains('app-guide-card'), isTrue);
    expect(notebookUiScript.contains('[role="tablist"]'), isTrue);
    expect(notebookUiScript.contains('isSourceCount'), isTrue);
    expect(
        notebookUiScript.contains(
            'target.style.setProperty(\'display\', \'none\', \'important\')'),
        isTrue);
  });

  test(
      'notebookUiScript suppresses standalone plus button and source count pill in chat input',
      () {
    expect(notebookUiScript.contains('button:has(mat-icon[fonticon="add"])'),
        isTrue);
    expect(notebookUiScript.contains('.add-source-button'), isTrue);
    expect(notebookUiScript.contains('isSourceCounter'), isTrue);
    expect(
        notebookUiScript.contains('app-chat-input [class*="source-count" i]'),
        isTrue);
    expect(notebookUiScript.contains('app-chat-input .sources-button'), isTrue);
  });

  test(
      'notebookUiScript docks chat composer naturally via flexbox without fixed positioning clipping',
      () {
    // Composer must dock naturally via position: relative, not fixed floating
    expect(notebookUiScript.contains('position: relative !important;'), isTrue);
    expect(notebookUiScript.contains('position: fixed !important;'), isFalse);
    expect(notebookUiScript.contains('align-self: center !important;'), isTrue);
    expect(
        notebookUiScript.contains('margin-inline: auto !important;'), isTrue);
    expect(notebookUiScript.contains('max-width: 720px !important;'), isTrue);
    expect(notebookUiScript.contains('.ot-chat-composer'), isTrue);
    expect(notebookUiScript.contains('.ot-chat-composer-path'), isTrue);
    expect(notebookUiScript.contains('removeLegacySpacers'), isTrue);
    expect(notebookUiScript.contains('flex: 0 0 auto !important;'), isTrue);
    expect(
        notebookUiScript.contains('padding-bottom: 24px !important;'), isTrue);
  });
}

void notebookSkinTests() {
  test('aturan penyembunyi tidak lagi mengenai tombol Save settings', () {
    // Pencocokan `*=` pada "Settings" ikut menyembunyikan "Save settings" dan
    // "Close user settings" di dialog bahasa NotebookLM.
    expect(notebookUiScript.contains(r'''button[aria-label="Settings" i]'''),
        isTrue);
    expect(
        notebookUiScript.contains(
            '\n      button[aria-label*="Settings" i], button[aria-label*="Setelan" i],'),
        isFalse);
    expect(
        notebookUiScript.contains(
            r"""'button[aria-label*="Settings" i]', 'button[aria-label*="Setelan" i]',"""),
        isFalse);
  });

  test('kulit OpenTurath menimpa token halaman tanpa selektor :has', () {
    expect(notebookSkinScript.contains('--nlm-text-body-text'), isTrue);
    expect(notebookSkinScript.contains('--mat-sys-primary'), isTrue);
    expect(notebookSkinScript.contains('window.otSetOutputLanguage'), isTrue);
    expect(notebookSkinScript.contains(':has('), isFalse);
    expect(notebookSkinScript.contains('.ot-ibarah'), isTrue);
    expect(notebookSkinScript.contains('ot-arch-echo'), isTrue);
    expect(notebookUiScript.endsWith(notebookSkinScript), isTrue);
  });

  test('font aplikasi tertanam di halaman dan skin memakainya', () {
    expect(notebookFontsScript.contains('font-family:"OT Outfit"'), isTrue);
    expect(
        notebookFontsScript.contains('font-family:"OT Scheherazade"'), isTrue);
    expect(notebookFontsScript.contains('data:font/woff2;base64,'), isTrue);
    expect(notebookSkinScript.contains('"OT Outfit"'), isTrue);
    expect(notebookUiScript.contains(notebookFontsScript), isTrue);
  });

  test(
      'kulit memuat tombol salin, status memuat bergilir, tabel dan catatan kaki',
      () {
    expect(notebookSkinScript.contains('ot-copy-answer'), isTrue);
    expect(notebookSkinScript.contains('Mencari ibarah di kitab'), isTrue);
    expect(notebookSkinScript.contains('table-element-view'), isTrue);
    expect(
        notebookSkinScript.contains(
            'OpenTurath AI bisa salah, maka verifikasi ulang jawabannya.'),
        isTrue);
    // Tombol salin tidak boleh berlabel aria "copy/salin": skrip inti menyembunyikannya.
    expect(notebookSkinScript.contains("setAttribute('aria-label'"), isFalse);
  });

  test('band di sekeliling kolom tanya transparan tanpa garis dan bayangan',
      () {
    final start = notebookSkinScript.indexOf('Tanpa kotak:');
    expect(start, greaterThan(0));
    final block = notebookSkinScript.substring(start, start + 900);
    expect(block.contains('.ot-chat-composer-path'), isTrue);
    expect(block.contains('omnibar'), isTrue);
    expect(block.contains('background: transparent !important'), isTrue);
    expect(block.contains('border-top: 0 !important'), isTrue);
    expect(block.contains('box-shadow: none !important'), isTrue);
    // Garis atas dan warna kanvas lama milik omnibar tidak boleh kembali.
    // (Garis serupa pada kepala bagian jawaban sah, jadi hanya blok omnibar diperiksa.)
    final omnibar = RegExp(r'omnibar \{[^}]*\}')
        .allMatches(notebookSkinScript)
        .map((m) => m.group(0)!)
        .join();
    expect(omnibar.contains('border-top: 1px'), isFalse);
    expect(omnibar.contains('--ot-canvas'), isFalse);
  });

  test('bahasa aplikasi bisa dikirim ke halaman tanpa memuat ulang', () {
    expect(notebookSkinScript.contains('window.otSetLang = function'), isTrue);
    expect(notebookSkinScript.contains("sessionStorage.setItem('ot_lang'"),
        isTrue);
    expect(notebookSkinScript.contains("sessionStorage.getItem('ot_lang')"),
        isTrue);
  });

  test('tombol berhenti dicegat dan dialog Google tidak terlihat', () {
    expect(
        notebookSkinScript.contains("callHandler('otStopRequested')"), isTrue);
    expect(
        notebookSkinScript.contains('html.ot-stopping .cdk-overlay-container'),
        isTrue);
    // Tombol berhenti tidak lagi dikecualikan dari gaya OpenTurath.
    expect(
        notebookSkinScript.contains(':not([aria-label*="Stop" i])'), isFalse);
    // Fallback: bila bridge tidak ada, klik diteruskan agar pengguna tidak terjebak.
    expect(notebookSkinScript.contains('passUntouched'), isTrue);
  });

  test('konfirmasi otomatis tidak menyentuh dialog penghapusan', () {
    // Dialog "Stop generating?" milik Google sendiri memuat kata "remove", jadi
    // pemeriksaannya harus lebih cerdas daripada mencocokkan satu kata.
    expect(notebookSkinScript.contains('const STRONG_DESTRUCTIVE ='), isTrue);
    expect(notebookSkinScript.contains('const STOP_DIALOG ='), isTrue);
    expect(notebookSkinScript.contains('isDestructiveDialog(dialog)'), isTrue);
    // Penutup popup selamat datang tidak boleh lagi mengklik ikon svg apa pun.
    final start = notebookUiScript.indexOf('function dismissPopups()');
    expect(start, greaterThan(0));
    final body = notebookUiScript.substring(start, start + 4200);
    expect(body.contains('mat-icon[fonticon="close"], svg'), isFalse);
    expect(body.contains('hapus'), isTrue,
        reason: 'dialog penghapusan harus dikecualikan');
  });
}
