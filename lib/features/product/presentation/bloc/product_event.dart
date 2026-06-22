import 'package:mini_erp/core/utils/stock_status.dart';
import 'package:mini_erp/features/product/domain/model/product.dart';

abstract class ProductEvent {}

class LoadProductEvent extends ProductEvent {
  final bool refresh;
  LoadProductEvent({this.refresh = false});
}

class FilterProductsEvent extends ProductEvent {
  final String searchQuery;
  final String categoryFilter;
  final StockStatus? statusFilter;

  FilterProductsEvent({
    required this.searchQuery,
    required this.categoryFilter,
    this.statusFilter,
  });
}

class LoadProductByIdEvent extends ProductEvent {
  final String productId;
  LoadProductByIdEvent(this.productId);
}

class AddProductEvent extends ProductEvent {
  final Product product;
  AddProductEvent(this.product);
}

class UpdateStockEvent extends ProductEvent {
  final String productID;
  final int stock;
  UpdateStockEvent(this.productID, this.stock);
}

class AdjustStockEvent extends ProductEvent {
  final String productId;
  final int delta;
  AdjustStockEvent(this.productId, this.delta);
}
