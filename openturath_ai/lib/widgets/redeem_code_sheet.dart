import '../core/l10n/app_dictionary.dart';
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
      return 'membership.code_device_error';
    }
    if (lower.contains('not-found')) {
      return 'membership.code_not_found';
    }
    if (lower.contains('already-exists') || lower.contains('already-used')) {
      return 'membership.code_used';
    }
    if (lower.contains('resource-exhausted') || lower.contains('quota')) {
      return 'membership.code_quota';
    }
    if (lower.contains('deadline-exceeded') || lower.contains('expired')) {
      return 'membership.code_expired';
    }
    if (lower.contains('failed-precondition')) {
      return 'membership.code_inactive';
    }
    if (lower.contains('invalid-argument')) {
      return 'membership.code_format';
    }
    return 'membership.code_error';
  }

  Future<void> _handleRedeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _inlineError = 'membership.code_hint');
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
        (success ? '' : 'invalid-argument');

    if (success) {
      AppSnackBar.show(
        context,
        message: context.tr('membership.code_success'),
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
                Expanded(child: Text(
                  context.tr('membership.use_voucher'),
                  style: OTTypography.cardTitle(color: textPrimary).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )),
                IconButton(
                  tooltip: context.tr('membership.close'),
                  icon: Icon(Icons.close_rounded, size: 20, color: textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('membership.code_instructions'),
              style: OTTypography.body(color: textSecondary).copyWith(fontSize: 12.5),
            ),
            const SizedBox(height: OTSpacing.md),
            TextField(
              controller: _codeController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.characters,
              textDirection: TextDirection.ltr,
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
                hintText: context.tr('membership.code_hint'),
                hintStyle: OTTypography.body(color: textSecondary).copyWith(
                  letterSpacing: 0,
                  fontSize: 14,
                ),
                errorText: _inlineError == null ? null : context.tr(_inlineError!),
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
                        context.tr('membership.use_voucher'),
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


