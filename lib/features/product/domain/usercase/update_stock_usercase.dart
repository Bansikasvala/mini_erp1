import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class UpdateStockUsercase {
  final ProductRepository repository;

  UpdateStockUsercase(this.repository);

  Future<void> call(String productId, int stock) {
    return repository.updateStock(productId, stock);
  }
}
