import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;
  CreateOrderUseCase(this.repository);

  Future<void> call(Order order) => repository.createOrder(order);
}
