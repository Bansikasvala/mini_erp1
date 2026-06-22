import 'package:mini_erp/features/order/data/datasource/order_local_datasource.dart';
import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/model/order_model.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';
import 'package:mini_erp/features/order/domain/repositories/order_repository.dart';
import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDatasource local;
  final ProductRepository productRepository;

  OrderRepositoryImpl({
    required this.local,
    required this.productRepository,
  });

  @override
  Future<List<Order>> getOrders() {
    return local.getOrders();
  }

  @override
  Future<Order?> getOrderById(String id) {
    return local.getOrderById(id);
  }

  @override
  Future<void> createOrder(Order order) async {
    if (order.items.isEmpty) {
      throw Exception('Order must contain at least one item');
    }

    for (final item in order.items) {
      final product = await productRepository.getproductById(item.productId);
      if (product == null) {
        throw Exception('Product ${item.productName} not found');
      }
      if (item.quantity > product.stock) {
        throw Exception(
          'Quantity for ${item.productName} exceeds available stock (${product.stock})',
        );
      }
    }

    for (final item in order.items) {
      final product = await productRepository.getproductById(item.productId);
      await productRepository.updateStock(
        item.productId,
        product!.stock - item.quantity,
      );
    }

    await local.saveOrder(OrderModel.fromEntity(order));
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final order = await local.getOrderById(orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    await local.updateOrder(
      order.copyWith(status: status, updatedAt: DateTime.now()),
    );
  }
}
