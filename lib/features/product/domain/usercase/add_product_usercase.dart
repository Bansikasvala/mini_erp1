import 'package:mini_erp/features/product/domain/model/product.dart';
import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class AddProductUsercase {
  final ProductRepository repository;

  AddProductUsercase(this.repository);

  Future<void> call(Product product) async {
    if (product.price <= 0) {
      throw Exception('Price must be greater than 0');
    }
    if (product.stock < 0) {
      throw Exception('Stock must be 0 or greater');
    }
    return repository.addProduct(product);
  }
}
