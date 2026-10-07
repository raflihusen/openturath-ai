import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/localization.dart';
import 'package:openturath_ai/widgets/payment_success_dialog.dart';

void main() {
  testWidgets(
      'receipt shows the confirmed invoice and closes without access claims',
      (tester) async {
    Loc.setLanguage('id');
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
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentSuccessDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
