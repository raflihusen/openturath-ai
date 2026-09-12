import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openturath_ai/core/checkout_completion.dart';
void main() {
  test('A12 completion dismisses confirmation before closing checkout exactly once', () async {
    final gate = CheckoutCompletion();
    final events = <String>[];
    final done = Completer<void>();
    gate.confirmation = done.future;
    final first = gate.finish(dismissConfirmation: () { events.add('dialog'); done.complete(); },
      closeCheckout: () => events.add('checkout'));
    final second = gate.finish(dismissConfirmation: () => events.add('duplicate'),
      closeCheckout: () => events.add('duplicate'));
    await Future.wait([first, second]);
    expect(events, ['dialog', 'checkout']);
  });
}
