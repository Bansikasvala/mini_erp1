import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_erp/core/di/app_di.dart';
import 'package:mini_erp/core/utils/app_formatters.dart';
import 'package:mini_erp/features/auth/data/datasoures/auth_local_datasource.dart';
import 'package:mini_erp/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:mini_erp/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mini_erp/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:mini_erp/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboradPage extends StatefulWidget {
  const DashboradPage({super.key});

  @override
  State<DashboradPage> createState() => _DashboradPageState();
}

class _DashboradPageState extends State<DashboradPage> {
  DashboardBloc _createBloc() {
    final bloc = DashboardBloc(
      GetDashboardStatsUseCase(AppDi.dashboardRepository()),
    );
    bloc.add(LoadDashboardEvent());
    return bloc;
  }

  Future<void> _logout() async {
    await AuthLocalDatasource().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<DashboardBloc>().add(
                        LoadDashboardEvent(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is DashboardLoaded) {
              final stats = state.stats;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(LoadDashboardEvent());
                  await context.read<DashboardBloc>().stream.firstWhere(
                    (s) => s is DashboardLoaded || s is DashboardError,
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Last updated: ${AppFormatters.dateTime(stats.lastUpdatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          title: 'Total Products',
                          value: '${stats.totalProducts}',
                          icon: Icons.inventory_2,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Low Stock',
                          value: '${stats.lowStockCount}',
                          icon: Icons.warning_amber,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Pending Orders',
                          value: '${stats.pendingOrdersCount}',
                          icon: Icons.pending_actions,
                          color: Colors.purple,
                        ),
                        _StatCard(
                          title: 'Last Sync',
                          value: stats.lastUpdatedAt == null
                              ? 'Never'
                              : AppFormatters.dateTime(stats.lastUpdatedAt),
                          icon: Icons.sync,
                          color: Colors.teal,
                          smallValue: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _NavButton(
                      label: 'View Products',
                      icon: Icons.list_alt,
                      onTap: () => context.go('/products'),
                    ),
                    const SizedBox(height: 12),
                    _NavButton(
                      label: 'Add Product',
                      icon: Icons.add_box,
                      onTap: () => context.go('/add-product'),
                    ),
                    const SizedBox(height: 12),
                    _NavButton(
                      label: 'View Orders',
                      icon: Icons.receipt_long,
                      onTap: () => context.go('/orders'),
                    ),
                    const SizedBox(height: 12),
                    _NavButton(
                      label: 'Create Order',
                      icon: Icons.add_shopping_cart,
                      onTap: () => context.go('/orders/create'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool smallValue;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.smallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: smallValue
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
