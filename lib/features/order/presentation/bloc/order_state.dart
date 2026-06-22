import 'package:mini_erp/features/order/domain/model/order.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<Order> orders;
  OrdersLoaded(this.orders);
}

class OrderDetailLoaded extends OrderState {
  final Order order;
  OrderDetailLoaded(this.order);
}

class OrdersEmpty extends OrderState {}

class OrderActionSuccess extends OrderState {
  final String message;
  OrderActionSuccess(this.message);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}
