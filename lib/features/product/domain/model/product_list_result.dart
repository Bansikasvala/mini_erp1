import 'package:mini_erp/features/product/domain/model/product.dart';

class ProductListResult {
  final List<Product> products;
  final bool isOffline;
  final DateTime? lastUpdatedAt;

  const ProductListResult({
    required this.products,
    required this.isOffline,
    this.lastUpdatedAt,
  });
}
