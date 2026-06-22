import 'package:hive/hive.dart';
import 'package:mini_erp/features/product/data/datasource/product_local_datasocuse.dart';
import 'package:mini_erp/features/product/data/datasource/product_remote_datasource.dart';
import 'package:mini_erp/features/product/domain/model/product.dart';
import 'package:mini_erp/features/product/domain/model/product_list_result.dart';
import 'package:mini_erp/features/product/domain/model/product_model.dart';
import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class ProductRepositoriesImpl implements ProductRepository {
  final ProductLocalDatasocuse local;
  final ProductRemoteDatasource remote;
  final Box metaBox;

  ProductRepositoriesImpl({
    required this.local,
    required this.remote,
    required this.metaBox,
  });

  static const _lastSyncKey = 'last_sync';

  @override
  Future<ProductListResult> getProductsWithMeta() async {
    try {
      await remote.syncProducts();
      final products = await local.getProducts();
      final now = DateTime.now();
      await metaBox.put(_lastSyncKey, now.toIso8601String());
      return ProductListResult(
        products: products,
        isOffline: false,
        lastUpdatedAt: now,
      );
    } catch (_) {
      final products = await local.getProducts();
      return ProductListResult(
        products: products,
        isOffline: true,
        lastUpdatedAt: _readLastSync(),
      );
    }
  }

  DateTime? _readLastSync() {
    final value = metaBox.get(_lastSyncKey);
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  Future<List<Product>> getProduct() async {
    final result = await getProductsWithMeta();
    return result.products;
  }

  @override
  Future<Product?> getproductById(String id) {
    return local.getProductbyid(id);
  }

  @override
  Future<bool> isSkuUnique(String sku, {String? excludeProductId}) async {
    final products = await local.getProducts();
    return !products.any(
      (product) =>
          product.sku.toLowerCase() == sku.toLowerCase() &&
          product.id != excludeProductId,
    );
  }

  @override
  Future<void> addProduct(Product product) async {
    final unique = await isSkuUnique(product.sku);
    if (!unique) {
      throw Exception('SKU already exists');
    }
    await local.addProduct(ProductModel.fromEntity(product));
    await metaBox.put(_lastSyncKey, DateTime.now().toIso8601String());
  }

  @override
  Future<void> updateStock(String productId, int stock) async {
    if (stock < 0) {
      throw Exception('Stock cannot be negative');
    }

    final product = await local.getProductbyid(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    await local.updateProduct(
      product.copyWith(stock: stock, updatedat: DateTime.now()),
    );
    await metaBox.put(_lastSyncKey, DateTime.now().toIso8601String());
  }
}
