import 'package:mini_erp/core/utils/stock_status.dart';
import 'package:mini_erp/features/product/domain/model/product.dart';

abstract class ProductState {}

class ProductIntial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> visibleProducts;
  final bool isOffline;
  final DateTime? lastUpdatedAt;
  final String searchQuery;
  final String categoryFilter;
  final StockStatus? statusFilter;

  ProductLoaded({
    required this.products,
    required this.visibleProducts,
    required this.isOffline,
    this.lastUpdatedAt,
    this.searchQuery = '',
    this.categoryFilter = 'All',
    this.statusFilter,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<Product>? visibleProducts,
    bool? isOffline,
    DateTime? lastUpdatedAt,
    String? searchQuery,
    String? categoryFilter,
    StockStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      isOffline: isOffline ?? this.isOffline,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

class ProductDetailLoaded extends ProductState {
  final Product product;
  ProductDetailLoaded(this.product);
}

class ProductEmpty extends ProductState {
  final bool isOffline;
  final DateTime? lastUpdatedAt;

  ProductEmpty({this.isOffline = false, this.lastUpdatedAt});
}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}

class ProductActionSuccess extends ProductState {
  final String message;
  ProductActionSuccess(this.message);
}
