import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_snackbar.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../services/subscription_service.dart';
import 'app_loader.dart';

class RedeemCodeSheet extends StatefulWidget {
  final VoidCallback? onSuccess;

  const RedeemCodeSheet({
    super.key,
    this.onSuccess,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RedeemCodeSheet(onSuccess: onSuccess),
    );
  }

  @override
  State<RedeemCodeSheet> createState() => _RedeemCodeSheetState();
}

class _RedeemCodeSheetState extends State<RedeemCodeSheet> {
  final TextEditingController _codeController = TextEditingController();
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = false;
  String? _inlineError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _humanizeErrorMessage(String raw) {
    final lower = raw.toLowerCase().replaceAll('_', '-');
    if (lower.contains('perangkat') || lower.contains('ponsel')) {
      return raw;
    }
    if (lower.contains('not-found')) {
      return 'Kode voucher tidak ditemukan. Periksa kembali penulisan kode Anda.';
    }
    if (lower.contains('already-exists') || lower.contains('already-used')) {
      return 'Kode ini sudah pernah ditukarkan sebelumnya.';
    }
    if (lower.contains('resource-exhausted') || lower.contains('quota')) {
      return 'Kuota penukaran untuk kode voucher ini sudah habis.';
    }
    if (lower.contains('deadline-exceeded') || lower.contains('expired')) {
      return 'Masa berlaku kode voucher ini telah berakhir.';
    }
    if (lower.contains('failed-precondition')) {
      return 'Kode voucher ini sudah tidak aktif.';
    }
    if (lower.contains('invalid-argument')) {
      return 'Format penulisan kode voucher belum sesuai.';
    }
    return raw;
  }

  Future<void> _handleRedeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _inlineError = 'Masukkan kode voucher');
      return;
    }

    setState(() {
      _isLoading = true;
      _inlineError = null;
    });

    final result = await _subscriptionService.redeemAccessCode(code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    final success = result['success'] == true;
    final message = (result['message'] as String?) ??
        (success ? 'Akses berhasil diaktifkan' : 'Kode tidak valid atau sudah kedaluwarsa');

    if (success) {
      AppSnackBar.show(
        context,
        message: 'Voucher berhasil diaktifkan. Akses telaah telah dibuka.',
        type: SnackType.success,
      );
      widget.onSuccess?.call();
      Navigator.of(context).pop();
    } else {
      setState(() => _inlineError = _humanizeErrorMessage(message));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bgSurface = OTColors.surface(isDark);
    final textPrimary = OTColors.textPrimary(isDark);
    final textSecondary = OTColors.textSecondary(isDark);
    final borderColor = OTColors.border(isDark);
    final canvas = OTColors.canvas(isDark);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: bgSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: OTSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gunakan voucher',
                  style: OTTypography.cardTitle(color: textPrimary).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Masukkan kode voucher yang Anda miliki.',
              style: OTTypography.body(color: textSecondary).copyWith(fontSize: 12.5),
            ),
            const SizedBox(height: OTSpacing.md),
            TextField(
              controller: _codeController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-_]')),
                LengthLimitingTextInputFormatter(25),
              ],
              onChanged: (_) {
                if (_inlineError != null) setState(() => _inlineError = null);
              },
              style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: 'Masukkan kode voucher',
                hintStyle: OTTypography.body(color: textSecondary).copyWith(
                  letterSpacing: 0,
                  fontSize: 14,
                ),
                errorText: _inlineError,
                errorStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: canvas,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: borderColor, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: borderColor, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: OTRadius.inputBorder,
                  borderSide: BorderSide(color: textPrimary, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: OTSpacing.lg),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _handleRedeem,
                style: FilledButton.styleFrom(
                  backgroundColor: textPrimary,
                  foregroundColor: canvas,
                  shape: RoundedRectangleBorder(
                    borderRadius: OTRadius.buttonBorder,
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? AppLoader(dotSize: 6, color: canvas)
                    : Text(
                        'Gunakan voucher',
                        style: OTTypography.button(color: canvas),
                      ),
              ),
            ),
            const SizedBox(height: OTSpacing.sm),
          ],
        ),
      ),
    );
  }
}
