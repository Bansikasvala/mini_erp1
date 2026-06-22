class OrderItem {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
  });

  double get lineTotal => quantity * unitPrice;
}
