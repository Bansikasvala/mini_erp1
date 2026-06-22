class ProductRemoteDatasource {
  static bool simulateFailure = false;

  Future<void> syncProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (simulateFailure) {
      throw Exception('Network unavailable');
    }
  }
}
