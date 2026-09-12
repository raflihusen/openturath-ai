class CheckoutCompletion {
  Future<void>? confirmation;
  bool _finishing = false;
  Future<void> finish({required void Function() dismissConfirmation, required void Function() closeCheckout}) async {
    if (_finishing) return;
    _finishing = true;
    dismissConfirmation();
    await confirmation;
    closeCheckout();
  }
}
