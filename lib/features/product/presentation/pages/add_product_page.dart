import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_erp/features/product/domain/model/product.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_bloc.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_event.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_state.dart';
import 'package:mini_erp/features/product/presentation/pages/product_list_page.dart';
import 'package:uuid/uuid.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final decController = TextEditingController();
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    decController.dispose();
    nameController.dispose();
    skuController.dispose();
    categoryController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: BlocProvider(
        create: (_) => createProductBloc(),
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter product name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: skuController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter SKU';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter category';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Price must be greater than 0';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter stock';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Stock must be 0 or greater';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: decController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter description';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                BlocConsumer<ProductBloc, ProductState>(
                  listener: (context, state) {
                    if (state is ProductActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                      context.go('/products');
                    }
                    if (state is ProductError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is ProductLoading;
                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (formkey.currentState!.validate()) {
                                final product = Product(
                                  id: const Uuid().v1(),
                                  name: nameController.text.trim(),
                                  sku: skuController.text.trim(),
                                  category: categoryController.text.trim(),
                                  price: double.parse(priceController.text),
                                  stock: int.parse(stockController.text),
                                  description: decController.text.trim(),
                                  updatedat: DateTime.now(),
                                );
                                context.read<ProductBloc>().add(
                                      AddProductEvent(product),
                                    );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Product'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
