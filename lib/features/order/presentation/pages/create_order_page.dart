import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_erp/core/di/app_di.dart';
import 'package:mini_erp/features/order/domain/model/order.dart';
import 'package:mini_erp/features/order/domain/model/order_item.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_bloc.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_event.dart';
import 'package:mini_erp/features/order/presentation/bloc/order_state.dart';
import 'package:mini_erp/features/order/presentation/pages/order_list_page.dart';
import 'package:mini_erp/features/product/domain/model/product.dart';
import 'package:mini_erp/features/product/domain/usercase/get_product_usercase.dart';
import 'package:uuid/uuid.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final customerController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Product> products = [];
  final Map<String, int> selectedQuantities = {};
  bool loadingProducts = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    customerController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      loadingProducts = true;
      loadError = null;
    });
    try {
      final result = await GetProductUsercase(AppDi.productRepository())();
      setState(() {
        products = result.products.where((p) => p.stock > 0).toList();
        loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        loadError = e.toString();
        loadingProducts = false;
      });
    }
  }

  double get totalAmount {
    var total = 0.0;
    for (final product in products) {
      final qty = selectedQuantities[product.id] ?? 0;
      total += qty * product.price;
    }
    return total;
  }

  int get itemCount =>
      selectedQuantities.values.fold(0, (sum, qty) => sum + qty);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createOrderBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Order')),
        body: loadingProducts
            ? const Center(child: CircularProgressIndicator())
            : loadError != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(loadError!),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: customerController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter customer name';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Items: $itemCount'),
                              Text('Total: ₹${totalAmount.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: products.isEmpty
                              ? const Center(
                                  child: Text('No products with stock available'),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    final qty =
                                        selectedQuantities[product.id] ?? 0;
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'SKU: ${product.sku} | Stock: ${product.stock} | ₹${product.price.toStringAsFixed(2)}',
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: qty > 0
                                                      ? () => setState(() {
                                                            selectedQuantities[
                                                                product.id] = qty - 1;
                                                            if (selectedQuantities[
                                                                    product.id] ==
                                                                0) {
                                                              selectedQuantities
                                                                  .remove(
                                                                product.id,
                                                              );
                                                            }
                                                          })
                                                      : null,
                                                  icon: const Icon(
                                                    Icons.remove_circle_outline,
                                                  ),
                                                ),
                                                Text('$qty'),
                                                IconButton(
                                                  onPressed: qty < product.stock
                                                      ? () => setState(() {
                                                            selectedQuantities[
                                                                product.id] = qty + 1;
                                                          })
                                                      : null,
                                                  icon: const Icon(
                                                    Icons.add_circle_outline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: BlocConsumer<OrderBloc, OrderState>(
                            listener: (context, state) {
                              if (state is OrderActionSuccess) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                                context.go('/orders');
                              }
                              if (state is OrderError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is OrderLoading;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (!formKey.currentState!.validate()) {
                                            return;
                                          }
                                          if (itemCount == 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Select at least one product',
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          final items = <OrderItem>[];
                                          selectedQuantities.forEach((id, qty) {
                                            if (qty <= 0) return;
                                            final product = products.firstWhere(
                                              (p) => p.id == id,
                                            );
                                            items.add(
                                              OrderItem(
                                                productId: product.id,
                                                productName: product.name,
                                                sku: product.sku,
                                                quantity: qty,
                                                unitPrice: product.price,
                                              ),
                                            );
                                          });

                                          final now = DateTime.now();
                                          final order = Order(
                                            id: const Uuid().v1(),
                                            orderNumber:
                                                'ORD-${now.millisecondsSinceEpoch}',
                                            customerName:
                                                customerController.text.trim(),
                                            items: items,
                                            status: OrderStatus.pending,
                                            createdAt: now,
                                            updatedAt: now,
                                          );

                                          context.read<OrderBloc>().add(
                                                CreateOrderEvent(order),
                                              );
                                        },
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Create Order'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
