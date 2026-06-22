import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_erp/core/utils/app_formatters.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_bloc.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_event.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_state.dart';
import 'package:mini_erp/features/order/presentation/pages/order_list_page.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = createOrderBloc();
        bloc.add(LoadOrderByIdEvent(orderId));
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderLoading || state is OrderInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderError) {
              return Center(child: Text(state.message));
            }
            if (state is OrderDetailLoaded) {
              final order = state.order;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Customer: ${order.customerName}'),
                  Text('Status: ${order.status.label}'),
                  Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}'),
                  Text('Items: ${order.itemCount}'),
                  Text('Created: ${AppFormatters.dateTime(order.createdAt)}'),
                  Text('Updated: ${AppFormatters.dateTime(order.updatedAt)}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.productName),
                      subtitle: Text('SKU: ${item.sku}'),
                      trailing: Text(
                        '${item.quantity} x ₹${item.unitPrice.toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Update Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: OrderStatus.values.map((status) {
                      final selected = order.status == status;
                      return ChoiceChip(
                        label: Text(status.label),
                        selected: selected,
                        onSelected: selected
                            ? null
                            : (_) {
                                context.read<OrderBloc>().add(
                                      UpdateOrderStatusEvent(order.id, status),
                                    );
                              },
                      );
                    }).toList(),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
