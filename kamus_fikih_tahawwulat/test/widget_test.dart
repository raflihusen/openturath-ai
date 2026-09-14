import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kamus_fikih_tahawwulat/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KamusFikihTahawwulatApp()),
    );
    // Just verify it doesn't crash on initial render
    expect(find.byType(KamusFikihTahawwulatApp), findsOneWidget);
  });
}
