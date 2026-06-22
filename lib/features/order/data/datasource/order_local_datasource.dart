import 'package:hive/hive.dart';
import 'package:mini_erp/features/order/domain/model/order_model.dart';

class OrderLocalDatasource {
  final Box box;
  OrderLocalDatasource(this.box);

  static const String key = 'orders';

  Future<List<OrderModel>> getOrders() async {
    final data = box.get(key) ?? [];
    return (data as List)
        .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<OrderModel?> getOrderById(String id) async {
    final orders = await getOrders();
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveOrder(OrderModel order) async {
    final orders = await getOrders();
    orders.add(order);
    await box.put(key, orders.map((item) => item.toJson()).toList());
  }

  Future<void> updateOrder(OrderModel order) async {
    final orders = await getOrders();
    final index = orders.indexWhere((item) => item.id == order.id);
    if (index != -1) {
      orders[index] = order;
    }
    await box.put(key, orders.map((item) => item.toJson()).toList());
  }
}
