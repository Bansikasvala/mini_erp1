import 'package:mini_erp/features/dashboard/domain/model/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getStats();
}
