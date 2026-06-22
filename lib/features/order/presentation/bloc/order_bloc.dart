import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_erp/features/order/domain/usecases/create_order_usecase.dart';
import 'package:mini_erp/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:mini_erp/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:mini_erp/features/order/domain/usecases/update_order_status_usecase.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_event.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  OrderBloc(
    this.getOrdersUseCase,
    this.getOrderByIdUseCase,
    this.createOrderUseCase,
    this.updateOrderStatusUseCase,
  ) : super(OrderInitial()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<LoadOrderByIdEvent>(_onLoadOrderById);
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await getOrdersUseCase();
      if (orders.isEmpty) {
        emit(OrdersEmpty());
        return;
      }
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onLoadOrderById(
    LoadOrderByIdEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final order = await getOrderByIdUseCase(event.orderId);
      if (order == null) {
        emit(OrderError('Order not found'));
        return;
      }
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await createOrderUseCase(event.order);
      emit(OrderActionSuccess('Order created successfully'));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      await updateOrderStatusUseCase(event.orderId, event.status);
      final order = await getOrderByIdUseCase(event.orderId);
      if (order == null) {
        emit(OrderError('Order not found'));
        return;
      }
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
