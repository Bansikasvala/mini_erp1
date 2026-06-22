import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<Order?> getOrderById(String id);
  Future<void> createOrder(Order order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
