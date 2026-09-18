#!/usr/bin/env python3
"""
apply_subscription_bundles_ui.py
=================================
Mengintegrasikan UI 6 Paket Tematik Khusus Launching ke dalam SubscriptionScreen.
"""

import re

file_path = "openturath_ai/lib/screens/subscription_screen.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Tambahkan state variables _selectedSegment & _bundleDurationIndices
state_var_insert = """  // Durasi terpisah untuk masing-masing kartu
  int _selectedSegment = 0; // 0: 6 Paket Tematik (Launch Promo), 1: AI Satuan Spesifik
  final Map<String, int> _bundleDurationIndices = {};
  int _tahawwulatDurationIndex = 0; // 0: 1 Bulan, 1: 6 Bulan, 2: 1 Tahun"""

content = content.replace(
    "  // Durasi terpisah untuk masing-masing kartu\n  int _tahawwulatDurationIndex = 0; // 0: 1 Bulan, 1: 6 Bulan, 2: 1 Tahun",
    state_var_insert
)

# 2. Tambahkan helper _formatRupiah dan _handleBundleCheckout
helper_code = """  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  Future<void> _handleBundleCheckout({
    required ThematicBundleMeta bundle,
    required int durationIndex,
  }) async {
    final tiers = bundle.tiers;
    if (tiers.isEmpty) return;
    final safeIdx = durationIndex < tiers.length ? durationIndex : 0;
    final tier = tiers[safeIdx];
    final paymentUrl = tier.applyUrl.isNotEmpty
        ? tier.applyUrl
        : GoAkalCatalogRegistry.storeUrl;
    final planTitle = '${bundle.title} (${tier.title})';

    await DokuCheckoutSheet.show(
      context,
      paymentUrl: paymentUrl,
      invoiceNumber: '',
      planTitle: planTitle,
      amount: tier.amount,
    );

    if (mounted) {
      await _syncAkalPurchases(isSilent: false);
    }
  }

  Future<void> _handleTierCheckout({"""

content = content.replace("  Future<void> _handleTierCheckout({", helper_code)

# 3. Sekarang ubah bagian kartu di ListView:
# Cari baris setelah pintu masuk voucher/sync GoAkal
anchor = """                  const SizedBox(height: OTSpacing.md),

                  // ════════════════════════════════════════════════════════
                  // 1. KARTU MANDIRI MEWAH-MINIMALIS: FIKIH TAHAWWULAT"""

bundles_ui_block = """                  const SizedBox(height: OTSpacing.md),

                  // ── BANNER PERINGATAN HARGA KHUSUS LAUNCHING ──
                  Container(
                    margin: const EdgeInsets.only(bottom: OTSpacing.base),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2A200B), const Color(0xFF1E170A)]
                            : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: OTRadius.cardBorder,
                      border: Border.all(
                        color: isDark ? const Color(0xFFD97706).withValues(alpha: 0.45) : const Color(0xFFF59E0B),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'HARGA KHUSUS LAUNCHING',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.5,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black26 : Colors.white70,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Diskon s/d 50%',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Peringatan Kuota Promo Perdana: Seluruh harga promo peluncuran ini dirancang khusus untuk santri, asatidz, dan peneliti. Harga bersifat sementara dan dapat mengalami penyesuaian (naik) ke harga reguler sewaktu-waktu seiring pembaruan berkala korpus kitab.',
                          style: OTTypography.caption(
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          ).copyWith(fontSize: 12, height: 1.45),
                        ),
                      ],
                    ),
                  ),

                  // ── PILIHAN MODE: PAKET TEMATIK vs AI SATUAN ──
                  Container(
                    height: 44,
                    margin: const EdgeInsets.only(bottom: OTSpacing.lg),
                    decoration: BoxDecoration(
                      color: surfaceSubtle,
                      borderRadius: OTRadius.chipBorder,
                      border: Border.all(color: border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppleInteractiveWrapper(
                            onTap: () {
                              OTMotion.selection();
                              setState(() => _selectedSegment = 0);
                            },
                            pressedScale: 0.96,
                            child: AnimatedContainer(
                              duration: OTMotion.fast,
                              curve: OTMotion.curve,
                              decoration: BoxDecoration(
                                color: _selectedSegment == 0 ? textPrimary : Colors.transparent,
                                borderRadius: OTRadius.chipBorder,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '📦 6 Paket Tematik',
                                    style: OTTypography.caption(
                                      color: _selectedSegment == 0 ? canvas : textPrimary,
                                    ).copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: _selectedSegment == 0 ? const Color(0xFFE11D48) : accent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PROMO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppleInteractiveWrapper(
                            onTap: () {
                              OTMotion.selection();
                              setState(() => _selectedSegment = 1);
                            },
                            pressedScale: 0.96,
                            child: AnimatedContainer(
                              duration: OTMotion.fast,
                              curve: OTMotion.curve,
                              decoration: BoxDecoration(
                                color: _selectedSegment == 1 ? textPrimary : Colors.transparent,
                                borderRadius: OTRadius.chipBorder,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '🔍 AI Satuan Spesifik',
                                style: OTTypography.caption(
                                  color: _selectedSegment == 1 ? canvas : textSecondary,
                                ).copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_selectedSegment == 0) ...[
                    // ════════════════════════════════════════════════════════
                    // DAFTAR 6 PAKET TEMATIK (REKOMENDASI UTAMA SANTRI)
                    // ════════════════════════════════════════════════════════
                    ...GoAkalCatalogRegistry.thematicBundles.map((bundle) {
                      final currentDurationIdx = _bundleDurationIndices[bundle.slug] ?? 0;
                      final tiers = bundle.tiers;
                      final safeTierIdx = currentDurationIdx < tiers.length ? currentDurationIdx : 0;
                      final activeTier = tiers.isNotEmpty ? tiers[safeTierIdx] : null;

                      final isSultan = bundle.slug == 'paket-sultan-all-access';
                      final isFikih = bundle.slug == 'paket-fikih-pesantren';

                      return Container(
                        margin: const EdgeInsets.only(bottom: OTSpacing.lg),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141418) : const Color(0xFFFAF9F6),
                          borderRadius: OTRadius.cardBorder,
                          border: Border.all(
                            color: isSultan
                                ? (isDark ? const Color(0xFFEAB308) : const Color(0xFFCA8A04))
                                : (isFikih
                                    ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669))
                                    : (isDark ? const Color(0xFF383842) : const Color(0xFFD4D4D8))),
                            width: (isSultan || isFikih) ? 1.6 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(OTSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Badges
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                  decoration: BoxDecoration(
                                    color: isSultan
                                        ? const Color(0xFFFEF3C7)
                                        : (isFikih
                                            ? const Color(0xFFD1FAE5)
                                            : (isDark ? const Color(0xFF22222A) : const Color(0xFFEEEEF0))),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    bundle.badgeText,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.9,
                                      color: isSultan
                                          ? const Color(0xFFB45309)
                                          : (isFikih ? const Color(0xFF047857) : textPrimary),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                    borderRadius: OTRadius.chipBorder,
                                    border: Border.all(color: const Color(0xFFD97706), width: 0.8),
                                  ),
                                  child: Text(
                                    '🏷️ HARGA KHUSUS LAUNCH',
                                    style: GoogleFonts.outfit(
                                      color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: OTSpacing.sm),

                            // Judul & Subtitle
                            Text(
                              '${bundle.iconEmoji} ${bundle.title}',
                              style: OTTypography.corpusTitle(color: textPrimary).copyWith(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              bundle.subtitle,
                              style: GoogleFonts.outfit(
                                color: textSecondary,
                                fontSize: 12.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                            const SizedBox(height: OTSpacing.base),

                            // Durasi Selector
                            if (tiers.isNotEmpty)
                              Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: surfaceSubtle,
                                  borderRadius: OTRadius.chipBorder,
                                  border: Border.all(color: border, width: 0.8),
                                ),
                                child: Row(
                                  children: List.generate(tiers.length, (idx) {
                                    final t = tiers[idx];
                                    final isSelected = safeTierIdx == idx;
                                    return Expanded(
                                      child: AppleInteractiveWrapper(
                                        onTap: () {
                                          OTMotion.selection();
                                          setState(() {
                                            _bundleDurationIndices[bundle.slug] = idx;
                                          });
                                        },
                                        pressedScale: 0.94,
                                        child: AnimatedContainer(
                                          duration: OTMotion.fast,
                                          curve: OTMotion.curve,
                                          decoration: BoxDecoration(
                                            color: isSelected ? textPrimary : Colors.transparent,
                                            borderRadius: OTRadius.chipBorder,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            t.durationKey == '1_month'
                                                ? '1 Bulan'
                                                : (t.durationKey == '6_months' ? '6 Bulan' : '1 Tahun'),
                                            style: OTTypography.caption(
                                              color: isSelected ? canvas : textSecondary,
                                            ).copyWith(
                                              fontSize: 11.5,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),

                            const SizedBox(height: OTSpacing.base),

                            // Harga Normal Coret & Harga Launching
                            if (activeTier != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    activeTier.priceLabel,
                                    style: GoogleFonts.outfit(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    activeTier.periodLabel,
                                    style: OTTypography.caption(color: textSecondary).copyWith(fontSize: 13),
                                  ),
                                  const SizedBox(width: 10),
                                  if (safeTierIdx == 0) ...[
                                    Text(
                                      'Rp ${_formatRupiah(bundle.originalPrice1m)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textSecondary.withValues(alpha: 0.7),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                            const SizedBox(height: OTSpacing.base),
                            Divider(color: border.withValues(alpha: 0.5), height: 1),
                            const SizedBox(height: OTSpacing.base),

                            // Daftar AI yang didapat
                            ...bundle.includedItems.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _benefitRow(item, textSecondary),
                                )),

                            const SizedBox(height: OTSpacing.lg),

                            // Tombol Bayar Langsung GoAkal
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton(
                                onPressed: () => _handleBundleCheckout(
                                  bundle: bundle,
                                  durationIndex: safeTierIdx,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isSultan
                                      ? (isDark ? const Color(0xFFCA8A04) : const Color(0xFFD97706))
                                      : (isFikih
                                          ? (isDark ? const Color(0xFF059669) : const Color(0xFF047857))
                                          : textPrimary),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: OTRadius.buttonBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Ambil Akses ${bundle.title.split('(').first.trim()}',
                                      style: OTTypography.button(color: Colors.white).copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    // ════════════════════════════════════════════════════════
                    // 1. KARTU MANDIRI MEWAH-MINIMALIS: FIKIH TAHAWWULAT"""

content = content.replace(anchor, bundles_ui_block)

# 4. Tutup kurung else block sebelum Container catatan transparansi
end_anchor = """                  const SizedBox(height: OTSpacing.lg),

                  // ── Catatan Transparansi Pembelian ──"""

end_replacement = """                  ], // Akhir _selectedSegment else

                  const SizedBox(height: OTSpacing.lg),

                  // ── Catatan Transparansi Pembelian ──"""

content = content.replace(end_anchor, end_replacement)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("SubscriptionScreen updated successfully!")
