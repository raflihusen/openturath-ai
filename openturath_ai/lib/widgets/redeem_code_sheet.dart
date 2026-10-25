import '../widgets/adaptive_sheet.dart';
import '../core/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design/ot_colors.dart';
import '../core/design/ot_typography.dart';
import '../core/design/ot_radius.dart';
import '../core/design/ot_spacing.dart';
import '../services/subscription_service.dart';
import 'app_loader.dart';
import 'exclusive_activation_dialog.dart';

class RedeemCodeSheet extends StatefulWidget {
  final VoidCallback? onSuccess;

  const RedeemCodeSheet({
    super.key,
    this.onSuccess,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showAdaptiveSheet(
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

  Future<void> _handleRedeem() async {
    final code = _codeController.text.replaceAll(RegExp(r'\s+'), '').trim();
    if (code.isEmpty) {
      setState(() => _inlineError = Loc.tr('redeemEnterCode'));
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

    if (success) {
      // Isi dialog hanya dari jawaban server; tidak ada judul atau durasi
      // karangan bila server tidak mengirimnya.
      final serviceTitle =
          (result['serviceTitle'] as String?) ?? Loc.tr('redeemFallbackTitle');
      final durationDays = (result['durationDays'] as num?)?.toInt() ?? 0;
      final expiryRaw = result['expiry'] as String?;
      final expiryDate =
          expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;
      final agentId = (result['entitlementKey'] as String?) ?? '';

      final nav = Navigator.of(context);
      widget.onSuccess?.call();
      nav.pop();

      ExclusiveActivationDialog.show(
        nav.context,
        serviceTitle: serviceTitle,
        durationDays: durationDays,
        expiryDate: expiryDate,
        agentId: agentId,
        showValidity: expiryDate != null,
        code: code,
      );
    } else {
      setState(() => _inlineError =
          (result['message'] as String?) ?? Loc.tr('redeemFailedGeneric'));
    }
  }

  @override
  Widget build(BuildContext context) {
    Loc.watch(context);
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
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(OTRadius.dialog)),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: SheetGrabber()),
            const SizedBox(height: OTSpacing.base),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  Loc.tr('ui_6f8fc6f8d5'),
                  style: OTTypography.cardTitle(color: textPrimary).copyWith(
                    fontSize: OTFontSize.s18,
                    fontWeight: FontWeight.w600,
                  ),
                )),
                IconButton(
                  icon:
                      Icon(Icons.close_rounded, size: 20, color: textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              Loc.tr('ui_75edf97617'),
              style: OTTypography.body(color: textSecondary)
                  .copyWith(fontSize: OTFontSize.s12),
            ),
            const SizedBox(height: OTSpacing.md),
            TextField(
              controller: _codeController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-\s_]')),
                LengthLimitingTextInputFormatter(64),
              ],
              onChanged: (_) {
                if (_inlineError != null) setState(() => _inlineError = null);
              },
              style: OTTypography.bodyMedium(color: textPrimary).copyWith(
                fontSize: OTFontSize.s16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: Loc.tr('ui_259e2d8b2c'),
                hintStyle: OTTypography.body(color: textSecondary).copyWith(
                  letterSpacing: 0,
                  fontSize: OTFontSize.s14,
                ),
                errorText: _inlineError,
                errorStyle: const TextStyle(fontSize: OTFontSize.s12),
                filled: true,
                fillColor: canvas,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  elevation: 0,
                ),
                child: _isLoading
                    ? AppLoader(dotSize: 6, color: canvas)
                    : Text(
                        Loc.tr('ui_6f8fc6f8d5'),
                        style: OTTypography.button(color: canvas),
                      ),
              ),
            ),
            const SizedBox(height: OTSpacing.sm),
          ],
        )),
      ),
    );
  }
}
