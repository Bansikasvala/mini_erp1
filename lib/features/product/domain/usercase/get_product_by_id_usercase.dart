import 'package:mini_erp/features/product/domain/model/product.dart';
import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class GetProductByIdUsercases {
  final ProductRepository repository;

  GetProductByIdUsercases(this.repository);

  Future<Product?> call(String id) {
    return repository.getproductById(id);
  }
}
