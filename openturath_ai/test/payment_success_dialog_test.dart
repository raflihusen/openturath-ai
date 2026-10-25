import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/app_config.dart';
import 'package:openturath_ai/widgets/payment_success_dialog.dart';

void main() {
  testWidgets(
      'receipt shows the confirmed invoice and closes without access claims',
      (tester) async {
    AppConfig.localeNotifier.value = 'id';
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => PaymentSuccessDialog.show(context,
                        plan: 'Paket 6 bulan',
                        invoice: 'INV-TEST-246',
                        amount: 1499000),
                    child: const Text('Receipt'))))));
    await tester.tap(find.text('Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('INV-TEST-246'), findsOneWidget);
    expect(find.text('Rp 1.499.000'), findsOneWidget);
    expect(find.text('Paket 6 bulan'), findsOneWidget);
    expect(find.textContaining('sudah aktif'), findsNothing);
    expect(find.textContaining('Menyiapkan akses'), findsOneWidget);
    expect(find.text('Selesai'), findsNothing);
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(find.textContaining('Menyiapkan akses'), findsNothing);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentSuccessDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
