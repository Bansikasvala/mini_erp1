import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:mini_erp/features/auth/presentation/pages/login_page.dart';
import 'package:mini_erp/features/dashboard/presentation/pages/dashborad_page.dart';
import 'package:mini_erp/features/order/presentation/pages/create_order_page.dart';
import 'package:mini_erp/features/order/presentation/pages/order_detail_page.dart';
import 'package:mini_erp/features/order/presentation/pages/order_list_page.dart';
import 'package:mini_erp/features/product/presentation/pages/add_product_page.dart';
import 'package:mini_erp/features/product/presentation/pages/product_detail_page.dart';
import 'package:mini_erp/features/product/presentation/pages/product_list_page.dart';

const _protectedPrefixes = [
  '/dashboard',
  '/products',
  '/add-product',
  '/orders',
];

bool _isProtectedRoute(String location) {
  return _protectedPrefixes.any(
    (prefix) => location == prefix || location.startsWith('$prefix/'),
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = Hive.box('session').get(
      'isloggedIn',
      defaultValue: false,
    ) as bool;
    final location = state.matchedLocation;
    final isLoginRoute = location == '/login';

    if (!isLoggedIn && _isProtectedRoute(location)) {
      return '/login';
    }
    if (isLoggedIn && isLoginRoute) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboradPage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailPage(productId: id);
      },
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductPage(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderListPage(),
    ),
    GoRoute(
      path: '/orders/create',
      builder: (context, state) => const CreateOrderPage(),
    ),
    GoRoute(
      path: '/orders/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrderDetailPage(orderId: id);
      },
    ),
  ],
);
