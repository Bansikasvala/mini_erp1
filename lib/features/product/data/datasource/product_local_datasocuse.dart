import 'package:hive/hive.dart';
import 'package:mini_erp/features/product/domain/model/product_model.dart';

class ProductLocalDatasocuse {
  final Box box;

  ProductLocalDatasocuse(this.box);

  static const String key = "product";

  Future<List<ProductModel>> getProducts() async {
    final data = box.get(key) ?? [];

    return (data as List)
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ProductModel?> getProductbyid(String id) async {
    final product = await getProducts();

    try {
      return product.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProduct(ProductModel product) async {
    final products = await getProducts();
    products.add(product);
    await box.put(key, products.map((e) => e.toJson()).toList());
  }

  Future<void> updateProduct(ProductModel product) async {
    final products = await getProducts();
    final index = products.indexWhere((e) => e.id == product.id);

    if (index != -1) {
      products[index] = product;
    }
    await box.put(key, products.map((e) => e.toJson()).toList());
  }
}
