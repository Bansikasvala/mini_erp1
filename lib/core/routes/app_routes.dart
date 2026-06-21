import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:mini_erp/features/auth/presentation/pages/login_page.dart';
import 'package:mini_erp/features/dashborad/presentation/pages/dashborad_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoginIn = Hive.box(
      'session',
    ).get('isloggedIn', defaultValue: false);
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggingIn && !isLoginIn) {
      return '/login';
    }
    if (isLoggingIn && isLoginIn) {
      return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
      // routes: [

      // ],
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const DashboradPage();
      },
    ),
  ],
);
