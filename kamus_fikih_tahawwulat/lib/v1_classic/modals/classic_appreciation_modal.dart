import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/i18n/translations.dart';
import '../widgets/glass_panel.dart';

class ClassicAppreciationModal extends StatelessWidget {
  final String langCode;
  final VoidCallback onTriggerConfetti;
  final VoidCallback onClose;

  const ClassicAppreciationModal({
    super.key,
    required this.langCode,
    required this.onTriggerConfetti,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassPanel(
        isThick: true,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  KamusTranslations.tr('appreciationTitle', langCode),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '☕ 🍜',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              KamusTranslations.tr('appreciationBody', langCode),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.45),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.link, size: 20),
                label: Text(
                  KamusTranslations.tr('copyDanaLink', langCode),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () {
                  Clipboard.setData(const TextSelection(baseOffset: 0, extentOffset: 0) as ClipboardData? ??
                      const ClipboardData(text: 'https://link.dana.id/minta/2k78k0a'));
                  onClose();
                  onTriggerConfetti();
                },
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onClose,
              child: Text(KamusTranslations.tr('close', langCode)),
            ),
          ],
        ),
      ),
    );
  }
}
