import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);

  Future<List<Order>> call() => repository.getOrders();
}
