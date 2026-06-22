import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_erp/core/utils/app_formatters.dart';
import 'package:mini_erp/core/utils/stock_status.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_bloc.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_event.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_state.dart';
import 'package:mini_erp/features/product/presentation/pages/product_list_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final stockController = TextEditingController();
  bool _hasLoadedOnce = false;

  @override
  void dispose() {
    stockController.dispose();
    super.dispose();
  }

  void _adjustStock(BuildContext context, int delta) {
    final current = int.tryParse(stockController.text) ?? 0;
    final updated = current + delta;
    if (updated < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock cannot be negative')),
      );
      return;
    }
    stockController.text = updated.toString();
    context.read<ProductBloc>().add(
          UpdateStockEvent(widget.productId, updated),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = createProductBloc();
        bloc.add(LoadProductByIdEvent(widget.productId));
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: BlocConsumer<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductDetailLoaded) {
              stockController.text = state.product.stock.toString();
              if (_hasLoadedOnce) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stock updated successfully')),
                );
              } else {
                _hasLoadedOnce = true;
              }
            }
            if (state is ProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProductLoading || state is ProductIntial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/products'),
                      child: const Text('Back to Products'),
                    ),
                  ],
                ),
              );
            }
            if (state is ProductDetailLoaded) {
              final product = state.product;
              final status = stockStatusFromQuantity(product.stock);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(product.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(status.label),
                    backgroundColor: stockStatusColor(status),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'SKU', value: product.sku),
                  _InfoRow(label: 'Category', value: product.category),
                  _InfoRow(
                    label: 'Price',
                    value: '₹${product.price.toStringAsFixed(2)}',
                  ),
                  _InfoRow(label: 'Stock', value: '${product.stock}'),
                  _InfoRow(label: 'Description', value: product.description),
                  _InfoRow(
                    label: 'Updated',
                    value: AppFormatters.dateTime(product.updatedat),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Update Stock',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _adjustStock(context, -1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stock quantity',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _adjustStock(context, 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final stock = int.tryParse(stockController.text);
                      if (stock == null || stock < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a valid stock quantity'),
                          ),
                        );
                        return;
                      }
                      context.read<ProductBloc>().add(
                            UpdateStockEvent(widget.productId, stock),
                          );
                    },
                    child: const Text('Save Stock'),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
