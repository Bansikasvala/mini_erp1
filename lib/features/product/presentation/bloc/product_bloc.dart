import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_erp/core/utils/stock_status.dart';
import 'package:mini_erp/features/product/domain/model/product.dart';
import 'package:mini_erp/features/product/domain/usercase/add_product_usercase.dart';
import 'package:mini_erp/features/product/domain/usercase/get_product_by_id_usercase.dart';
import 'package:mini_erp/features/product/domain/usercase/get_product_usercase.dart';
import 'package:mini_erp/features/product/domain/usercase/update_stock_usercase.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_event.dart';
import 'package:mini_erp/features/product/presentation/bloc/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductUsercase getProductUsercase;
  final GetProductByIdUsercases getProductByIdUsercase;
  final AddProductUsercase addProductUsercase;
  final UpdateStockUsercase updateStockUsercase;

  ProductBloc(
    this.addProductUsercase,
    this.getProductUsercase,
    this.getProductByIdUsercase,
    this.updateStockUsercase,
  ) : super(ProductIntial()) {
    on<LoadProductEvent>(_onLoadProducts);
    on<FilterProductsEvent>(_onFilterProducts);
    on<LoadProductByIdEvent>(_onLoadProductById);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateStockEvent>(_onUpdateStock);
    on<AdjustStockEvent>(_onAdjustStock);
  }

  Future<void> _onLoadProducts(
    LoadProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (!event.refresh || state is! ProductLoaded) {
      emit(ProductLoading());
    }

    try {
      final result = await getProductUsercase();
      if (result.products.isEmpty) {
        emit(
          ProductEmpty(
            isOffline: result.isOffline,
            lastUpdatedAt: result.lastUpdatedAt,
          ),
        );
        return;
      }

      final current = state is ProductLoaded ? state as ProductLoaded : null;
      emit(
        _buildLoadedState(
          products: result.products,
          isOffline: result.isOffline,
          lastUpdatedAt: result.lastUpdatedAt,
          searchQuery: current?.searchQuery ?? '',
          categoryFilter: current?.categoryFilter ?? 'All',
          statusFilter: current?.statusFilter,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onFilterProducts(FilterProductsEvent event, Emitter<ProductState> emit) {
    if (state is! ProductLoaded) return;
    final current = state as ProductLoaded;
    emit(
      _buildLoadedState(
        products: current.products,
        isOffline: current.isOffline,
        lastUpdatedAt: current.lastUpdatedAt,
        searchQuery: event.searchQuery,
        categoryFilter: event.categoryFilter,
        statusFilter: event.statusFilter,
      ),
    );
  }

  Future<void> _onLoadProductById(
    LoadProductByIdEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final product = await getProductByIdUsercase(event.productId);
      if (product == null) {
        emit(ProductError('Product not found'));
        return;
      }
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await addProductUsercase(event.product);
      emit(ProductActionSuccess('Product added successfully'));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateStock(
    UpdateStockEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await updateStockUsercase(event.productID, event.stock);
      final product = await getProductByIdUsercase(event.productID);
      if (product == null) {
        emit(ProductError('Product not found'));
        return;
      }
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAdjustStock(
    AdjustStockEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state is! ProductDetailLoaded) return;
    final current = state as ProductDetailLoaded;
    final newStock = current.product.stock + event.delta;
    add(UpdateStockEvent(current.product.id, newStock));
  }

  ProductLoaded _buildLoadedState({
    required List<Product> products,
    required bool isOffline,
    DateTime? lastUpdatedAt,
    required String searchQuery,
    required String categoryFilter,
    StockStatus? statusFilter,
  }) {
    return ProductLoaded(
      products: products,
      visibleProducts: _applyFilters(
        products,
        searchQuery: searchQuery,
        categoryFilter: categoryFilter,
        statusFilter: statusFilter,
      ),
      isOffline: isOffline,
      lastUpdatedAt: lastUpdatedAt,
      searchQuery: searchQuery,
      categoryFilter: categoryFilter,
      statusFilter: statusFilter,
    );
  }

  List<Product> _applyFilters(
    List<Product> products, {
    required String searchQuery,
    required String categoryFilter,
    StockStatus? statusFilter,
  }) {
    return products.where((product) {
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query);
      final matchesCategory =
          categoryFilter == 'All' || product.category == categoryFilter;
      final matchesStatus =
          statusFilter == null ||
          stockStatusFromQuantity(product.stock) == statusFilter;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }
}
