import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository repository;
  GetOrderByIdUseCase(this.repository);

  Future<Order?> call(String id) => repository.getOrderById(id);
}
