import 'package:mini_erp/features/product/domain/model/product_list_result.dart';
import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class GetProductUsercase {
  final ProductRepository repository;

  GetProductUsercase(this.repository);

  Future<ProductListResult> call() {
    return repository.getProductsWithMeta();
  }
}
