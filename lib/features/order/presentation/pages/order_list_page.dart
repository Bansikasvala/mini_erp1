import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_erp/core/di/app_di.dart';
import 'package:mini_erp/features/order/domain/usecases/create_order_usecase.dart';
import 'package:mini_erp/features/order/domain/usecases/get_order_by_id_usecase.dart';
import 'package:mini_erp/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:mini_erp/features/order/domain/usecases/update_order_status_usecase.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_bloc.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_event.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_state.dart';

OrderBloc createOrderBloc() {
  final repository = AppDi.orderRepository();
  return OrderBloc(
    GetOrdersUseCase(repository),
    GetOrderByIdUseCase(repository),
    CreateOrderUseCase(repository),
    UpdateOrderStatusUseCase(repository),
  );
}

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = createOrderBloc();
        bloc.add(LoadOrdersEvent());
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/orders/create'),
            ),
          ],
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading || state is OrderInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<OrderBloc>().add(LoadOrdersEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is OrdersEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No orders yet'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/orders/create'),
                      child: const Text('Create Order'),
                    ),
                  ],
                ),
              );
            }
            if (state is OrdersLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<OrderBloc>().add(LoadOrdersEvent());
                  await context.read<OrderBloc>().stream.firstWhere(
                        (s) => s is OrdersLoaded || s is OrdersEmpty || s is OrderError,
                      );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return Card(
                      child: ListTile(
                        onTap: () => context.go('/orders/${order.id}'),
                        title: Text(order.orderNumber),
                        subtitle: Text(order.customerName),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${order.totalAmount.toStringAsFixed(2)}'),
                            Text('Items: ${order.itemCount}'),
                            Text(order.status.label),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
