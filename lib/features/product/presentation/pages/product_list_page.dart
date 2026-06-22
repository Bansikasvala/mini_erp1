import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_erp/core/di/app_di.dart';
import 'package:mini_erp/core/utils/app_formatters.dart';
import 'package:mini_erp/core/utils/stock_status.dart';
import 'package:mini_erp/features/product/domain/usercase/add_product_usercase.dart';
import 'package:mini_erp/features/product/domain/usercase/get_product_by_id_usercase.dart';
import 'package:mini_erp/features/product/domain/usercase/get_product_usercase.dart';
import 'package:mini_erp/features/product/domain/usercase/update_stock_usercase.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_bloc.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_event.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_state.dart';

ProductBloc createProductBloc() {
  final repository = AppDi.productRepository();
  return ProductBloc(
    AddProductUsercase(repository),
    GetProductUsercase(repository),
    GetProductByIdUsercases(repository),
    UpdateStockUsercase(repository),
  );
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final searchController = TextEditingController();
  String categoryFilter = 'All';
  StockStatus? statusFilter;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _applyFilters(BuildContext context) {
    context.read<ProductBloc>().add(
      FilterProductsEvent(
        searchQuery: searchController.text,
        categoryFilter: categoryFilter,
        statusFilter: statusFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = createProductBloc();
        bloc.add(LoadProductEvent());
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.go('/add-product'),
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
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
                      onPressed: () =>
                          context.read<ProductBloc>().add(LoadProductEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final loaded = state is ProductLoaded ? state : null;
            final isOffline =
                loaded?.isOffline ?? (state is ProductEmpty && state.isOffline);
            final lastUpdated =
                loaded?.lastUpdatedAt ??
                (state is ProductEmpty ? state.lastUpdatedAt : null);
            final products = loaded?.visibleProducts ?? [];
            final categories = loaded == null
                ? <String>['All']
                : ['All', ...loaded.products.map((p) => p.category).toSet()];

            return Column(
              children: [
                if (isOffline) offlineBanner(),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or SKU',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _applyFilters(context);
                        },
                      ),
                    ),
                    onChanged: (_) => _applyFilters(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: categoryFilter,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => categoryFilter = value);
                            _applyFilters(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<StockStatus?>(
                          value: statusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All')),
                            DropdownMenuItem(
                              value: StockStatus.inStock,
                              child: Text('In Stock'),
                            ),
                            DropdownMenuItem(
                              value: StockStatus.lowStock,
                              child: Text('Low Stock'),
                            ),
                            DropdownMenuItem(
                              value: StockStatus.outOfStock,
                              child: Text('Out of Stock'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => statusFilter = value);
                            _applyFilters(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Last updated: ${AppFormatters.dateTime(lastUpdated)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                Expanded(
                  child: state is ProductEmpty
                      ? const Center(child: Text('No products found'))
                      : products.isEmpty
                      ? const Center(
                          child: Text('No products match your filters'),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<ProductBloc>().add(
                              LoadProductEvent(refresh: true),
                            );
                            await context.read<ProductBloc>().stream.firstWhere(
                              (s) =>
                                  s is ProductLoaded ||
                                  s is ProductEmpty ||
                                  s is ProductError,
                            );
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final status = stockStatusFromQuantity(
                                product.stock,
                              );
                              return Card(
                                child: ListTile(
                                  onTap: () =>
                                      context.go('/products/${product.id}'),
                                  title: Text(product.name),
                                  subtitle: Text(
                                    'SKU: ${product.sku} | ${product.category}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${product.price.toStringAsFixed(2)}',
                                      ),
                                      Text('Stock: ${product.stock}'),
                                      Text(
                                        status.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: stockStatusColor(status),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
