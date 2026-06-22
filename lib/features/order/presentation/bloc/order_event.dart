import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';

abstract class OrderEvent {}

class LoadOrdersEvent extends OrderEvent {}

class LoadOrderByIdEvent extends OrderEvent {
  final String orderId;
  LoadOrderByIdEvent(this.orderId);
}

class CreateOrderEvent extends OrderEvent {
  final Order order;
  CreateOrderEvent(this.order);
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final OrderStatus status;
  UpdateOrderStatusEvent(this.orderId, this.status);
}
