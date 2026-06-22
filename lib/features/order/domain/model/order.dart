import 'package:mini_erp/features/order/domain/model/order_item.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';

class Order {
  final String id;
  final String orderNumber;
  final String customerName;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.lineTotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
