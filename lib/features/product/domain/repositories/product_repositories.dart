import 'package:mini_erp/features/product/domain/model/product.dart';
import 'package:mini_erp/features/product/domain/model/product_list_result.dart';

abstract class ProductRepository {
  Future<ProductListResult> getProductsWithMeta();
  Future<List<Product>> getProduct();
  Future<Product?> getproductById(String id);
  Future<bool> isSkuUnique(String sku, {String? excludeProductId});
  Future<void> addProduct(Product product);
  Future<void> updateStock(String productId, int stock);
}
