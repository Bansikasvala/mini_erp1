import 'package:hive/hive.dart';
import 'package:mini_erp/features/auth/data/datasoures/auth_local_datasource.dart';
import 'package:mini_erp/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:mini_erp/features/auth/domain/repositories/auth_repositoies.dart';
import 'package:mini_erp/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mini_erp/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mini_erp/features/order/data/datasource/order_local_datasource.dart';
import 'package:mini_erp/features/order/data/repositories/order_repository_impl.dart';
import 'package:mini_erp/features/order/domain/repositories/order_repository.dart';
import 'package:mini_erp/features/product/data/datasource/product_local_datasocuse.dart';
import 'package:mini_erp/features/product/data/datasource/product_remote_datasource.dart';
import 'package:mini_erp/features/product/data/repositories/product_repositories_impl.dart';
import 'package:mini_erp/features/product/domain/repositories/product_repositories.dart';

class AppDi {
  static ProductRepository productRepository() {
    return ProductRepositoriesImpl(
      local: ProductLocalDatasocuse(Hive.box('product_box')),
      remote: ProductRemoteDatasource(),
      metaBox: Hive.box('meta'),
    );
  }

  static OrderRepository orderRepository() {
    return OrderRepositoryImpl(
      local: OrderLocalDatasource(Hive.box('order_box')),
      productRepository: productRepository(),
    );
  }

  static DashboardRepository dashboardRepository() {
    return DashboardRepositoryImpl(
      productRepository: productRepository(),
      orderRepository: orderRepository(),
      metaBox: Hive.box('meta'),
    );
  }

  static AuthRepositoies authRepository() {
    return AuthRepositoriesImpl(AuthLocalDatasource());
  }
}
