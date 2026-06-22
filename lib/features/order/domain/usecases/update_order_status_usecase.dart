import 'package:mini_erp/features/order/domain/model/order_status.dart';
import 'package:mini_erp/features/order/domain/repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;
  UpdateOrderStatusUseCase(this.repository);

  Future<void> call(String orderId, OrderStatus status) {
    return repository.updateOrderStatus(orderId, status);
  }
}
