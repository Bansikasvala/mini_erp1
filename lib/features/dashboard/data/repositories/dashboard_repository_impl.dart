import 'package:hive/hive.dart';
import 'package:mini_erp/core/utils/stock_status.dart';
import 'package:mini_erp/features/dashboard/domain/model/dashboard_stats.dart';
import 'package:mini_erp/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mini_erp/features/order/domain/model/order_status.dart';
import 'package:mini_erp/features/order/domain/repositories/order_repository.dart';
import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ProductRepository productRepository;
  final OrderRepository orderRepository;
  final Box metaBox;

  DashboardRepositoryImpl({
    required this.productRepository,
    required this.orderRepository,
    required this.metaBox,
  });

  @override
  Future<DashboardStats> getStats() async {
    final productResult = await productRepository.getProductsWithMeta();
    final orders = await orderRepository.getOrders();
    final pendingOrders = orders
        .where((order) => order.status == OrderStatus.pending)
        .length;
    final lowStockCount = productResult.products.where((p) => isLowStock(p.stock)).length;

    return DashboardStats(
      totalProducts: productResult.products.length,
      lowStockCount: lowStockCount,
      pendingOrdersCount: pendingOrders,
      lastUpdatedAt: productResult.lastUpdatedAt ??
          _readLastSync() ??
          orders
              .map((order) => order.updatedAt)
              .fold<DateTime?>(null, (latest, current) {
            if (latest == null || current.isAfter(latest)) return current;
            return latest;
          }),
    );
  }

  DateTime? _readLastSync() {
    final value = metaBox.get('last_sync');
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
