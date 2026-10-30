import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/localization.dart';
import '../services/diagnostic_report_service.dart';

/// Aksi tombol "Kirim laporan": mengirim laporan diagnostik, menyalin kode
/// rujukan ke papan klip, lalu memberi tahu pengguna hasilnya.
bool _reportInFlight = false;

Future<void> submitDiagnosticFromUi(
  BuildContext context, {
  required String stage,
  required String code,
  String? page,
  Map<String, bool> flags = const {},
}) async {
  if (_reportInFlight) return;
  _reportInFlight = true;
  try {
    AppSnackBar.show(context, message: Loc.tr('reportSending'));
    final ref = await DiagnosticReportService.send(
        stage: stage, code: code, page: page, flags: flags);
    if (!context.mounted) return;
    if (ref == null) {
      AppSnackBar.show(context,
          message: Loc.tr('reportFailed'), type: SnackType.error);
      return;
    }
    await Clipboard.setData(ClipboardData(text: ref));
    if (!context.mounted) return;
    AppSnackBar.show(context,
        message: Loc.tr('reportSent', [ref]),
        type: SnackType.success,
        duration: const Duration(seconds: 12));
  } finally {
    _reportInFlight = false;
  }
}
