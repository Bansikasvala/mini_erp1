import 'package:mini_erp/features/dashboard/domain/model/dashboard_stats.dart';
import 'package:mini_erp/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCase(this.repository);

  Future<DashboardStats> call() {
    return repository.getStats();
  }
}
